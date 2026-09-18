---jupynb.nvim - Jupyter notebooks in Neovim, with real cells.
local M = {}

local config = require("jupynb.config")
local doc_mod = require("jupynb.doc")
local ipynb = require("jupynb.ipynb")
local render = require("jupynb.render")
local theme = require("jupynb.theme")
local util = require("jupynb.util")

M.did_setup = false

function M.setup(opts)
  config.setup(opts)
  theme.apply()
  M.did_setup = true
  return M
end

local function ensure_setup()
  if not M.did_setup then
    M.setup({})
  end
end

--- buffer wiring -----------------------------------------------------------

local function update_commentstring(doc)
  local cell = doc.cells[doc.active or 0]
  if not cell then
    return
  end
  if cell.kind == "code" then
    vim.bo[doc.buf].commentstring = doc.lang == "python" and "# %s" or "// %s"
  else
    vim.bo[doc.buf].commentstring = "<!-- %s -->"
  end
end

---Set every buffer option, mapping and autocommand for a notebook buffer.
function M.attach(buf)
  local doc = doc_mod.get(buf)
  if not doc then
    return
  end

  vim.bo[buf].filetype = "jupynb"
  vim.bo[buf].expandtab = true
  vim.bo[buf].commentstring = "# %s"
  vim.b[buf].jupynb = true

  -- markdown parser + injections give python highlighting inside code cells
  pcall(vim.treesitter.start, buf, "markdown")

  -- python-aware indentation inside code cells
  pcall(vim.cmd, "runtime! indent/python.vim")
  vim.bo[buf].indentexpr = "v:lua.require'jupynb'.indentexpr()"
  vim.bo[buf].indentkeys = "0{,0},0),0],:,!^F,o,O,e,<:>,=elif,=except"

  require("jupynb.keymaps").attach(buf)

  local group = vim.api.nvim_create_augroup("jupynb.buf." .. buf, { clear = true })

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = group,
    buffer = buf,
    callback = function()
      render.refresh(buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    buffer = buf,
    callback = function()
      local d = doc_mod.get(buf)
      if d and render.update_active(d) then
        update_commentstring(d)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufEnter" }, {
    group = group,
    buffer = buf,
    callback = function()
      render.setup_window(vim.api.nvim_get_current_win(), buf)
      -- images can only be drawn once the buffer is in a window
      render.refresh(buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufUnload", "BufDelete" }, {
    group = group,
    buffer = buf,
    callback = function()
      require("jupynb.kernel").shutdown(buf)
      pcall(require("jupynb.image").clear, buf)
      doc_mod.detach(buf)
    end,
  })

  -- gitsigns would diff the rendered buffer against the JSON file
  pcall(function()
    require("gitsigns").detach(buf)
  end)

  -- LSP + completion inside code cells
  if config.get().lsp.otter then
    vim.schedule(function()
      M.activate_otter(buf, doc)
    end)
  end

  render.setup_window(vim.api.nvim_get_current_win(), buf)
end

---Can this command actually run? `executable()` is not enough: a language
---server shipped as a JavaScript launcher is "executable" while its
---interpreter is missing, and starting it only yields `exit code 127`.
local function runnable(cmd)
  if type(cmd) ~= "table" or not cmd[1] then
    return type(cmd) == "function" -- computed at start time, give it a chance
  end
  if vim.fn.executable(cmd[1]) ~= 1 then
    return false
  end
  local path = vim.fn.exepath(cmd[1])
  local fd = path ~= "" and io.open(path, "rb") or nil
  if not fd then
    return true
  end
  local head = fd:read(256) or ""
  fd:close()
  local interpreter = head:match("^#!%s*(%S+)")
  if not interpreter then
    return true -- a real binary
  end
  if interpreter:match("/env$") then
    local program = head:match("^#!%s*%S+%s+(%S+)")
    return program == nil or vim.fn.executable(program) == 1
  end
  return vim.fn.executable(interpreter) == 1
end

---Name of a language server that could serve `ft`, and whether it can run.
---@return string|nil name, boolean runnable
function M.lsp_for(ft)
  pcall(require, "lspconfig") -- a notebook never triggers its lazy loading

  local names = {}
  local ok, enabled = pcall(function()
    return vim.lsp._enabled_configs
  end)
  if ok and type(enabled) == "table" then
    for name in pairs(enabled) do
      names[#names + 1] = name
    end
  end
  if #names == 0 then
    -- older/other shapes: a list of config tables
    local ok2, configs = pcall(vim.lsp.get_configs)
    if ok2 and type(configs) == "table" then
      for _, entry in ipairs(configs) do
        local name = type(entry) == "table" and entry.name or entry
        if type(name) == "string" then
          local oke, is_on = pcall(vim.lsp.is_enabled, name)
          if oke and is_on then
            names[#names + 1] = name
          end
        end
      end
    end
  end

  local declared
  for _, name in ipairs(names) do
    local cfg = vim.lsp.config[name]
    if cfg and vim.tbl_contains(cfg.filetypes or {}, ft) then
      declared = declared or name
      if runnable(cfg.cmd) then
        return name, true
      end
    end
  end
  if declared then
    return declared, false
  end
  return nil, true
end

function M.activate_otter(buf, doc)
  local ok, otter = pcall(require, "otter")
  if not ok or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if vim.api.nvim_get_current_buf() ~= buf then
    return
  end
  local lang = doc.lang or "python"
  -- Starting a server that cannot run only produces an error message on every
  -- notebook you open, so leave it alone (`:checkhealth jupynb` explains).
  local _, usable = M.lsp_for(lang)
  if not usable then
    return
  end
  pcall(function()
    otter.activate({ lang }, true, true, nil)
  end)
end

--- reading / writing -------------------------------------------------------

---Open a notebook into `buf`.
function M.open(buf, path, nb)
  ensure_setup()
  local doc = doc_mod.create(buf, path, nb)
  M.attach(buf)
  doc:fill()
  vim.bo[buf].modified = false
  render.render(doc)
  return doc
end

---`BufReadCmd *.ipynb`
function M.read(ev)
  ensure_setup()
  local buf = ev.buf
  local path = vim.fn.fnamemodify(ev.match ~= "" and ev.match or ev.file, ":p")

  -- `:edit notebook.ipynb` on a file that does not exist yet
  if vim.fn.filereadable(path) == 0 then
    M.open(buf, path, ipynb.normalize(ipynb.empty()))
    return
  end

  local nb, err = ipynb.load(path)
  if not nb then
    util.err(string.format("%s: %s — opening the raw JSON", vim.fn.fnamemodify(path, ":t"), err))
    vim.bo[buf].filetype = "json"
    pcall(vim.cmd, string.format("keepalt 0read %s", vim.fn.fnameescape(path)))
    vim.api.nvim_buf_set_lines(buf, -2, -1, false, {})
    vim.bo[buf].modified = false
    return
  end

  M.open(buf, path, nb)
end

---`BufNewFile *.ipynb`
function M.new_file(ev)
  ensure_setup()
  local buf = ev.buf
  local path = vim.fn.fnamemodify(ev.match ~= "" and ev.match or ev.file, ":p")
  M.open(buf, path, ipynb.normalize(ipynb.empty()))
  vim.bo[buf].modified = true
end

---`BufWriteCmd *.ipynb`
function M.write(ev)
  local buf = ev.buf
  local target = vim.fn.fnamemodify(ev.match ~= "" and ev.match or ev.file, ":p")
  local doc = doc_mod.get(buf)

  if not doc then
    -- notebook that could not be parsed: the buffer holds the raw JSON
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local ok, err = pcall(vim.fn.writefile, lines, target)
    if not ok then
      util.err("cannot write " .. target .. ": " .. tostring(err))
      return
    end
    vim.bo[buf].modified = false
    return
  end

  local nb = doc:to_nb({ strip_outputs = config.get().save.strip_outputs })
  local ok, err = ipynb.save(target, nb)
  if not ok then
    util.err("cannot write " .. target .. ": " .. tostring(err))
    return
  end
  doc.nb = nb
  -- `:saveas other.ipynb` makes the buffer follow the new file
  if target == doc.path or vim.api.nvim_buf_get_name(buf) == target then
    doc.path = target
    vim.bo[buf].modified = false
  end
  vim.api.nvim_exec_autocmds("BufWritePost", { buffer = buf, modeline = false })
end

--- indentation -------------------------------------------------------------

function M.indentexpr()
  local lnum = vim.v.lnum
  local doc = doc_mod.get(vim.api.nvim_get_current_buf())
  if not doc then
    return -1
  end
  doc:sync()
  local cell = doc:cell_at(lnum - 1)
  if cell and cell.kind == "code" and lnum - 1 > (cell.first or 0) then
    if doc.lang == "python" and vim.fn.exists("*GetPythonIndent") == 1 then
      local ok, indent = pcall(vim.fn.GetPythonIndent, lnum)
      if ok and type(indent) == "number" then
        return indent
      end
    end
    return -1
  end
  return 0
end

--- commands ----------------------------------------------------------------

local subcommands

local function notebook_buf()
  local buf = vim.api.nvim_get_current_buf()
  if not doc_mod.get(buf) then
    util.err("not a notebook buffer")
    return nil
  end
  return buf
end

subcommands = {
  run = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").run(buf)
    end
  end,
  ["run-advance"] = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").run(buf, { advance = true })
    end
  end,
  runall = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").run_scope(buf, "all")
    end
  end,
  runabove = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").run_scope(buf, "above")
    end
  end,
  runbelow = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").run_scope(buf, "below")
    end
  end,
  insert = function(args)
    local buf = notebook_buf()
    if buf then
      local where = args[1] or "below"
      local kind = args[2] or "code"
      require("jupynb.actions").insert(buf, where, kind)
    end
  end,
  delete = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").delete(buf)
    end
  end,
  type = function(args)
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").change_kind(buf, args[1])
    end
  end,
  split = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").split(buf)
    end
  end,
  merge = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").merge(buf)
    end
  end,
  move = function(args)
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").move(buf, args[1] == "up" and -1 or 1)
    end
  end,
  next = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").goto_cell(buf, 1)
    end
  end,
  prev = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").goto_cell(buf, -1)
    end
  end,
  clear = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").clear(buf, false)
    end
  end,
  clearall = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").clear(buf, true)
    end
  end,
  output = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").show_output(buf)
    end
  end,
  kernel = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.kernel").pick(buf)
    end
  end,
  restart = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.kernel").restart(buf)
    end
  end,
  interrupt = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.kernel").interrupt(buf)
    end
  end,
  shutdown = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.kernel").shutdown(buf)
      util.notify("kernel stopped")
    end
  end,
  status = function()
    local buf = notebook_buf()
    if not buf then
      return
    end
    local doc = doc_mod.get(buf)
    local session = require("jupynb.kernel").get(buf)
    local counts = { code = 0, markdown = 0, raw = 0 }
    for _, cell in ipairs(doc.cells) do
      counts[cell.kind] = (counts[cell.kind] or 0) + 1
    end
    util.notify(
      string.format(
        "%d cells (%d code, %d markdown) · language %s · kernel %s",
        #doc.cells,
        counts.code,
        counts.markdown,
        doc.lang,
        session and (session.kernel and (session.kernel.display or session.kernel.name) or session.state)
          or "not started"
      )
    )
  end,
  fix = function()
    local buf = notebook_buf()
    if buf then
      require("jupynb.actions").fix(buf)
    end
  end,
  images = function()
    local cfg = config.get()
    cfg.images.enabled = not cfg.images.enabled
    local buf = notebook_buf()
    if buf then
      render.render(doc_mod.get(buf))
    end
    util.notify("inline images " .. (cfg.images.enabled and "enabled" or "disabled"))
  end,
}

function M.command(opts)
  local args = vim.split(vim.trim(opts.args or ""), "%s+")
  local name = args[1]
  if not name or name == "" then
    name = "status"
  end
  local fn = subcommands[name]
  if not fn then
    util.err("unknown subcommand: " .. name)
    return
  end
  table.remove(args, 1)
  fn(args)
end

function M.complete(lead, line)
  local parts = vim.split(vim.trim(line), "%s+")
  if #parts > 2 or (#parts == 2 and lead == "") then
    local sub = parts[2]
    local values = {
      insert = { "above", "below" },
      type = { "code", "markdown", "raw" },
      move = { "up", "down" },
    }
    return vim.tbl_filter(function(item)
      return item:find(lead, 1, true) == 1
    end, values[sub] or {})
  end
  local names = vim.tbl_keys(subcommands)
  table.sort(names)
  return vim.tbl_filter(function(item)
    return item:find(lead, 1, true) == 1
  end, names)
end

--- misc --------------------------------------------------------------------

---Kernel status, for a statusline component.
function M.status()
  return require("jupynb.kernel").status_text(vim.api.nvim_get_current_buf())
end

function M.refresh_theme()
  theme.apply()
  for buf, doc in pairs(doc_mod.all()) do
    if vim.api.nvim_buf_is_valid(buf) then
      render.render(doc)
    end
  end
end

return M
