---Kernel sessions: one bridge process (and one Jupyter kernel) per notebook.
local M = {}

local config = require("jupynb.config")
local doc_mod = require("jupynb.doc")
local output = require("jupynb.output")
local util = require("jupynb.util")

---@type table<integer, table>
local sessions = {}

local STARTUP_ID = "__jupynb_startup__"

local function bridge_path()
  local source = debug.getinfo(1, "S").source:sub(2)
  local root = vim.fn.fnamemodify(source, ":h:h:h")
  return root .. "/python/jupynb_bridge.py"
end

function M.get(buf)
  buf = util.resolve_buf(buf)
  local session = sessions[buf]
  if session and not util.buf_valid(buf) then
    M.shutdown(buf)
    return nil
  end
  return session
end

function M.all()
  return sessions
end

--- process -----------------------------------------------------------------

local function handle_line(session, line)
  local ok, msg = pcall(vim.json.decode, line, { luanil = { object = true, array = true } })
  if ok and type(msg) == "table" then
    vim.schedule(function()
      M.handle(session, msg)
    end)
  end
end

local function on_stdout(session, data)
  if not data then
    return
  end
  session.pending = (session.pending or "") .. data
  while true do
    local nl = session.pending:find("\n", 1, true)
    if not nl then
      break
    end
    local line = session.pending:sub(1, nl - 1)
    session.pending = session.pending:sub(nl + 1)
    if line ~= "" then
      handle_line(session, line)
    end
  end
end

---Start the bridge process for a buffer (not the kernel itself).
---@return table|nil session
function M.spawn(buf)
  buf = util.resolve_buf(buf)
  local session = sessions[buf]
  if session and session.proc then
    return session
  end

  local py = config.python()
  if vim.fn.executable(py) == 0 then
    util.err(string.format("python not found: %s (see :checkhealth jupynb)", py))
    return nil
  end

  session = {
    buf = buf,
    state = "stopped",
    pending = "",
    waiting = {},
    kernel = nil,
  }

  local doc = doc_mod.get(buf)
  local cwd = doc and doc.path and vim.fn.fnamemodify(doc.path, ":h") or vim.uv.cwd()

  local ok, proc = pcall(vim.system, { py, bridge_path() }, {
    stdin = true,
    text = true,
    cwd = cwd,
    stdout = function(_, data)
      on_stdout(session, data)
    end,
    stderr = function(_, data)
      if data and data:match("Traceback") then
        vim.schedule(function()
          util.err("bridge: " .. data)
        end)
      end
    end,
  }, function()
    vim.schedule(function()
      session.proc = nil
      session.state = "dead"
      M.notify_status(session)
    end)
  end)

  if not ok then
    util.err("cannot start the jupynb bridge: " .. tostring(proc))
    return nil
  end

  session.proc = proc
  sessions[buf] = session
  return session
end

function M.send(session, msg)
  if not session or not session.proc then
    return false
  end
  local ok = pcall(function()
    session.proc:write(vim.json.encode(msg) .. "\n")
  end)
  return ok
end

--- kernels -----------------------------------------------------------------

---Interpreters found next to the notebook (.venv, venv, $VIRTUAL_ENV).
local function discover_venvs(start_dir)
  local found, seen = {}, {}
  local function add(python, label)
    python = vim.fn.resolve(vim.fn.expand(python))
    if python ~= "" and vim.fn.executable(python) == 1 and not seen[python] then
      seen[python] = true
      found[#found + 1] = { python = python, label = label }
    end
  end

  if vim.env.VIRTUAL_ENV then
    add(vim.env.VIRTUAL_ENV .. "/bin/python", "$VIRTUAL_ENV")
  end

  local dir = start_dir or vim.uv.cwd()
  for _ = 1, 6 do
    for _, name in ipairs({ ".venv", "venv", "env" }) do
      local python = dir .. "/" .. name .. "/bin/python"
      if vim.fn.executable(python) == 1 then
        add(python, vim.fn.fnamemodify(dir, ":t") .. "/" .. name)
      end
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end
    dir = parent
  end
  return found
end

---@param cb fun(specs: table[])
function M.list_kernels(buf, cb)
  local session = M.spawn(buf)
  if not session then
    return
  end
  session.kernels_cb = cb
  M.send(session, { op = "kernels" })
end

---Ask the user which kernel to use, then (re)start it.
function M.pick(buf, cb)
  local doc = doc_mod.get(buf)
  M.list_kernels(buf, function(specs)
    local items = {}
    for _, spec in ipairs(specs) do
      items[#items + 1] = {
        label = string.format("%s  (%s)", spec.display_name, spec.name),
        kernel = spec.name,
      }
    end
    if config.get().kernel.discover_venvs then
      local dir = doc and doc.path and vim.fn.fnamemodify(doc.path, ":h") or vim.uv.cwd()
      for _, venv in ipairs(discover_venvs(dir)) do
        items[#items + 1] = {
          label = string.format("%s  (%s)", venv.label, vim.fn.fnamemodify(venv.python, ":~")),
          kernel = "python3",
          python = venv.python,
        }
      end
    end
    if #items == 0 then
      util.err("no Jupyter kernel found (pip install ipykernel)")
      return
    end
    vim.ui.select(items, {
      prompt = "Jupyter kernel",
      format_item = function(item)
        return item.label
      end,
    }, function(choice)
      if choice then
        M.start(buf, { kernel = choice.kernel, python = choice.python }, cb)
      end
    end)
  end)
end

---@param spec table|nil { kernel = string, python = string|nil }
function M.start(buf, spec, cb)
  local session = M.spawn(buf)
  if not session then
    return
  end
  local doc = doc_mod.get(buf)
  spec = spec or {}
  local name = spec.kernel
    or config.get().kernel.name
    or (doc and doc.nb and require("jupynb.ipynb").kernel_name(doc.nb))
    or "python3"

  session.state = "starting"
  session.kernel = { name = name, python = spec.python }
  if cb then
    table.insert(session.waiting, cb)
  end
  M.notify_status(session)
  M.send(session, {
    op = "start",
    kernel = name,
    python = spec.python,
    cwd = doc and doc.path and vim.fn.fnamemodify(doc.path, ":h") or vim.uv.cwd(),
    timeout = config.get().kernel.timeout,
  })
end

---Run `fn(session)` once a kernel is up, starting one when needed.
function M.with_kernel(buf, fn)
  local session = M.get(buf)
  if session and (session.state == "idle" or session.state == "busy") then
    fn(session)
    return
  end
  if session and session.state == "starting" then
    table.insert(session.waiting, fn)
    return
  end
  if not config.get().kernel.auto_start then
    util.err("no kernel running: :Jupynb kernel")
    return
  end
  M.start(buf, nil, fn)
end

--- execution ---------------------------------------------------------------

function M.execute(buf, cell)
  local doc = doc_mod.get(buf)
  if not doc or cell.kind ~= "code" then
    return
  end
  local code = doc:code_of(cell)
  if code:match("^%s*$") then
    return
  end
  cell.status = "queued"
  cell.outputs = {}
  cell.elapsed = nil
  require("jupynb.render").render(doc)
  require("jupynb.render").start_spinner()

  M.with_kernel(buf, function(session)
    M.send(session, { op = "execute", id = cell.id, code = code })
  end)
end

function M.interrupt(buf)
  local session = M.get(buf)
  if session then
    M.send(session, { op = "interrupt" })
  end
end

function M.restart(buf, cb)
  local session = M.get(buf)
  if not session or not session.kernel then
    util.notify("no kernel to restart")
    return
  end
  if cb then
    table.insert(session.waiting, cb)
  end
  session.state = "starting"
  M.send(session, { op = "restart" })
end

function M.shutdown(buf)
  buf = util.resolve_buf(buf)
  local session = sessions[buf]
  if not session then
    return
  end
  if session.proc then
    pcall(function()
      session.proc:write(vim.json.encode({ op = "shutdown" }) .. "\n")
      session.proc:write(nil) -- close stdin -> the bridge exits
    end)
    vim.defer_fn(function()
      pcall(function()
        if session.proc then
          session.proc:kill(15)
        end
      end)
    end, 1500)
  end
  sessions[buf] = nil
end

function M.shutdown_all()
  for buf, _ in pairs(sessions) do
    M.shutdown(buf)
  end
end

--- events ------------------------------------------------------------------

function M.notify_status(session)
  local doc = doc_mod.get(session.buf)
  if doc then
    doc.kernel_state = session.state
    doc.kernel_name = session.kernel and session.kernel.name
  end
  vim.api.nvim_exec_autocmds("User", { pattern = "JupynbKernelStatus", modeline = false })
end

local function flush_waiting(session)
  local waiting = session.waiting or {}
  session.waiting = {}
  for _, fn in ipairs(waiting) do
    pcall(fn, session)
  end
end

function M.handle(session, msg)
  local buf = session.buf
  local doc = doc_mod.get(buf)
  local render = require("jupynb.render")
  local ev = msg.ev

  if ev == "ready" then
    session.bridge_ready = true
  elseif ev == "kernels" then
    local cb = session.kernels_cb
    session.kernels_cb = nil
    if cb then
      cb(msg.specs or {})
    end
  elseif ev == "kernel_status" then
    local state = msg.state
    if state == "starting" or state == "restarting" then
      session.state = "starting"
    elseif state == "dead" then
      session.state = "dead"
      session.waiting = {}
    elseif state == "idle" or state == "busy" then
      local was_starting = session.state == "starting" or session.state == "stopped"
      session.state = state
      if msg.display then
        session.kernel = session.kernel or {}
        session.kernel.display = msg.display
        session.kernel.language = msg.language
        if doc and doc.nb then
          doc.nb.metadata = doc.nb.metadata or {}
          doc.nb.metadata.kernelspec = {
            name = session.kernel.name,
            display_name = msg.display,
            language = msg.language,
          }
        end
      end
      if was_starting then
        local startup = config.get().kernel.startup or {}
        local code = startup[session.kernel and session.kernel.language or "python"]
          or startup[doc and doc.lang or "python"]
        if code and code ~= "" then
          M.send(session, { op = "execute", id = STARTUP_ID, code = code })
        end
        local label = msg.display or (session.kernel and (session.kernel.display or session.kernel.name)) or "kernel"
        util.notify(string.format("kernel ready: %s", label))
        flush_waiting(session)
      end
    end
    M.notify_status(session)
    if doc then
      render.render_headers(doc)
    end
    return
  elseif ev == "cell_status" then
    if not doc or msg.id == STARTUP_ID then
      return
    end
    local cell = doc:cell_by_id(msg.id)
    if cell then
      cell.status = msg.state
      if msg.state == "running" then
        cell.started = vim.uv.now() / 1000
        if msg.execution_count then
          cell.exec_count = msg.execution_count
        end
      end
      render.start_spinner()
      render.render_headers(doc)
    end
  elseif ev == "output" then
    if not doc or msg.id == STARTUP_ID then
      return
    end
    local cell = doc:cell_by_id(msg.id)
    if cell then
      if cell.clear_pending then
        cell.outputs = {}
        cell.clear_pending = nil
      end
      output.append(cell, msg.output)
      vim.bo[buf].modified = true
      render.refresh(buf)
      render.schedule_reveal(doc)
    end
  elseif ev == "clear" then
    if not doc then
      return
    end
    local cell = doc:cell_by_id(msg.id)
    if cell then
      if msg.wait then
        cell.clear_pending = true
      else
        cell.outputs = {}
        render.refresh(buf)
      end
    end
  elseif ev == "exec_reply" then
    if not doc or msg.id == STARTUP_ID then
      return
    end
    local cell = doc:cell_by_id(msg.id)
    if cell then
      cell.status = (msg.status == "ok") and "ok" or "error"
      cell.elapsed = msg.elapsed
      cell.started = nil
      if msg.execution_count then
        cell.exec_count = msg.execution_count
      end
      vim.bo[buf].modified = true
      render.refresh(buf)
      -- an output stuck below the window is invisible, and a terminal cannot
      -- draw a figure there at all: bring it into view
      render.schedule_reveal(doc)
    end
  elseif ev == "input_request" then
    vim.ui.input({ prompt = msg.prompt ~= "" and msg.prompt or "stdin: " }, function(value)
      M.send(session, { op = "input", text = value or "" })
    end)
  elseif ev == "error" then
    util.err(msg.msg or "kernel error")
  end
end

--- status ------------------------------------------------------------------

---Short kernel status, handy in a statusline.
function M.status_text(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local session = sessions[buf]
  if not session then
    return ""
  end
  local name = session.kernel and (session.kernel.display or session.kernel.name) or "kernel"
  local icons = config.get().ui.icons
  if session.state == "busy" then
    return icons.run .. " " .. name
  elseif session.state == "idle" then
    return icons.ok .. " " .. name
  elseif session.state == "starting" then
    return "… " .. name
  end
  return icons.error .. " " .. name
end

return M
