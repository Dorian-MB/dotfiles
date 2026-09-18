---Everything visual: cell headers, the left cell bar, outputs, images.
local M = {}

local config = require("jupynb.config")
local doc_mod = require("jupynb.doc")
local output = require("jupynb.output")
local util = require("jupynb.util")

local ns_head = vim.api.nvim_create_namespace("jupynb.head")
local ns_out = vim.api.nvim_create_namespace("jupynb.out")
local ns_active = vim.api.nvim_create_namespace("jupynb.active")

M.ns_head, M.ns_out, M.ns_active = ns_head, ns_out, ns_active

local spinner_frame = 1
local spinner_timer = nil

--- helpers ------------------------------------------------------------------

local function lang_icon(lang)
  local icons = config.get().ui.icons
  if icons.code then
    return icons.code
  end
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok and devicons.get_icon_by_filetype then
    local icon = devicons.get_icon_by_filetype(lang, { default = false })
    if icon and icon ~= "" then
      return icon
    end
  end
  return ""
end

local function lang_label(lang)
  if not lang or lang == "" then
    return "Code"
  end
  return lang:sub(1, 1):upper() .. lang:sub(2)
end

local function width_of(chunks)
  local w = 0
  for _, chunk in ipairs(chunks) do
    w = w + vim.fn.strdisplaywidth(chunk[1])
  end
  return w
end

---Cell containing `row`, without re-parsing the buffer (used by 'statuscolumn',
---which runs for every visible line on every redraw).
---@param loose boolean|nil also return the closest cell above `row`
---@return table|nil cell, integer|nil index
function M.cell_at_cached(doc, row, loose)
  local cells = doc.cells
  local lo, hi = 1, #cells
  local found
  while lo <= hi do
    local mid = math.floor((lo + hi) / 2)
    local cell = cells[mid]
    local start = cell.header or cell.first or 0
    if row < start then
      hi = mid - 1
    else
      found = mid
      lo = mid + 1
    end
  end
  if not found then
    return loose and cells[1] or nil, loose and cells[1] and 1 or nil
  end
  local cell = cells[found]
  if loose or row <= (cell.last_row or cell.first or 0) then
    return cell, found
  end
  return nil
end

--- headers ------------------------------------------------------------------

local function status_chunks(cell, sfx)
  local cfg = config.get().ui
  local icons = cfg.icons
  if cell.status == "running" then
    local frame = cfg.spinner[(spinner_frame - 1) % #cfg.spinner + 1]
    local elapsed = cell.started and util.human_time(vim.uv.now() / 1000 - cell.started) or ""
    return { { frame .. " " .. elapsed .. " ", "JupynbHeaderRunning" .. sfx } }
  elseif cell.status == "queued" then
    return { { icons.queued .. " queued ", "JupynbHeaderTime" .. sfx } }
  elseif cell.status == "error" then
    return {
      { icons.error .. " ", "JupynbHeaderError" .. sfx },
      { util.human_time(cell.elapsed) .. " ", "JupynbHeaderTime" .. sfx },
    }
  elseif cell.status == "ok" then
    return {
      { icons.ok .. " ", "JupynbHeaderOk" .. sfx },
      { util.human_time(cell.elapsed) .. " ", "JupynbHeaderTime" .. sfx },
    }
  end
  return {}
end

local function header_chunks(doc, cell, active)
  local cfg = config.get().ui
  local icons = cfg.icons
  local sfx = active and "Active" or ""
  local chunks = { { " ", "JupynbHeader" .. sfx } }

  if cell.kind == "code" then
    chunks[#chunks + 1] = { lang_icon(doc.lang) .. "  ", "JupynbHeaderIcon" .. sfx }
    chunks[#chunks + 1] = { lang_label(doc.lang), "JupynbHeaderLabel" .. sfx }
    if cell.exec_count then
      chunks[#chunks + 1] = { "  [" .. tostring(cell.exec_count) .. "]", "JupynbHeaderCount" .. sfx }
    end
  else
    local icon = cell.kind == "markdown" and icons.markdown or icons.raw
    chunks[#chunks + 1] = { icon .. "  ", "JupynbHeaderMd" .. sfx }
    chunks[#chunks + 1] = { cell.kind == "markdown" and "Markdown" or "Raw", "JupynbHeaderLabel" .. sfx }
  end

  return chunks
end

---Draw (or redraw) the header bar of every cell.
function M.render_headers(doc)
  local cfg = config.get().ui
  if not util.buf_valid(doc.buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(doc.buf, ns_head, 0, -1)
  if not cfg.header then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(doc.buf, 0, -1, false)
  local nlines = #lines

  for idx, cell in ipairs(doc.cells) do
    local active = (doc.active == idx)
    local row = cell.header
    if row and row < nlines then
      local chunks = header_chunks(doc, cell, active)
      local line_width = vim.fn.strdisplaywidth(lines[row + 1] or "")
      local w = width_of(chunks)
      if w < line_width + 1 then
        chunks[#chunks + 1] = { string.rep(" ", line_width + 1 - w), "JupynbHeader" .. (active and "Active" or "") }
      end
      pcall(vim.api.nvim_buf_set_extmark, doc.buf, ns_head, row, 0, {
        virt_text = chunks,
        virt_text_pos = "overlay",
        hl_mode = "replace",
        line_hl_group = "JupynbHeader" .. (active and "Active" or ""),
        virt_lines = cfg.gap and { { { "", "JupynbGap" } } } or nil,
        virt_lines_above = cfg.gap or nil,
        priority = 120,
      })

      local status = status_chunks(cell, active and "Active" or "")
      if #status > 0 then
        pcall(vim.api.nvim_buf_set_extmark, doc.buf, ns_head, row, 0, {
          virt_text = status,
          virt_text_pos = "right_align",
          hl_mode = "combine",
          priority = 121,
        })
      end
    end

    -- the closing fence is drawn as an empty separator line
    if cell.closing and cell.closing < nlines then
      local text = lines[cell.closing + 1] or ""
      pcall(vim.api.nvim_buf_set_extmark, doc.buf, ns_head, cell.closing, 0, {
        virt_text = { { string.rep(" ", math.max(#text, 1)), "JupynbGap" } },
        virt_text_pos = "overlay",
        hl_mode = "replace",
        priority = 120,
      })
    end
  end
end

--- outputs ------------------------------------------------------------------

function M.render_outputs(doc)
  if not util.buf_valid(doc.buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(doc.buf, ns_out, 0, -1)
  local image = require("jupynb.image")
  image.begin_frame(doc.buf)

  local nlines = vim.api.nvim_buf_line_count(doc.buf)
  for _, cell in ipairs(doc.cells) do
    if cell.kind == "code" and cell.outputs and #cell.outputs > 0 then
      local row = cell.closing or cell.last_row or cell.first
      if row and row >= 0 and row < nlines then
        local vlines, images = output.render(cell)
        -- `nvim_win_text_height()` does not count virtual lines attached below
        -- a row, so remember how tall the output block is (see reveal_output).
        cell.out_height = #vlines
        if #vlines > 0 then
          pcall(vim.api.nvim_buf_set_extmark, doc.buf, ns_out, row, 0, {
            virt_lines = vlines,
            priority = 110,
          })
        end
        for i, spec in ipairs(images) do
          spec.key = cell.id .. ":" .. i
          image.place(doc.buf, row, spec)
        end
      end
    end
  end

  image.end_frame(doc.buf)

  -- The figures were just anchored on virtual lines that do not exist on
  -- screen yet: draw them again once Neovim has laid the window out.
  if image.has_images(doc.buf) then
    M.schedule_image_refresh(doc.buf)
  end
end

---@type table<integer, uv.uv_timer_t>
local image_timers = {}

---Force a screen layout, then redraw the images of `buf`.
function M.schedule_image_refresh(buf)
  local timer = image_timers[buf]
  if timer then
    timer:stop()
    timer:close()
    image_timers[buf] = nil
  end
  timer = vim.uv.new_timer()
  image_timers[buf] = timer
  timer:start(
    40,
    0,
    vim.schedule_wrap(function()
      local t = image_timers[buf]
      if t then
        t:stop()
        t:close()
        image_timers[buf] = nil
      end
      if not util.buf_valid(buf) then
        return
      end
      -- `screenpos()` only knows about virtual lines that have been drawn
      if vim.api.nvim__redraw then
        pcall(vim.api.nvim__redraw, { buf = buf, flush = true, valid = false })
      else
        pcall(vim.cmd, "redraw")
      end
      require("jupynb.image").refresh(buf)
    end)
  )
end

--- revealing outputs --------------------------------------------------------

---@type table<integer, uv.uv_timer_t>
local reveal_timers = {}

---Reveal, once the outputs have settled. Kernels send `execute_reply` on the
---shell channel while outputs come through iopub, so the last figure often
---lands *after* the reply: revealing only on the reply would scroll too early.
---
---The cell to reveal is resolved when the timer fires, not when it is armed:
---during a "run all" the outputs of every cell arrive, and only the one the
---user is actually looking at should move the view.
function M.schedule_reveal(doc)
  local buf = doc.buf
  local timer = reveal_timers[buf]
  if timer then
    timer:stop()
    timer:close()
    reveal_timers[buf] = nil
  end
  timer = vim.uv.new_timer()
  reveal_timers[buf] = timer
  timer:start(
    120,
    0,
    vim.schedule_wrap(function()
      local t = reveal_timers[buf]
      if t then
        t:stop()
        t:close()
        reveal_timers[buf] = nil
      end
      local d = doc_mod.get(buf)
      if not d or not util.buf_valid(buf) then
        return
      end
      local win = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_get_buf(win) ~= buf then
        return
      end
      local row = vim.api.nvim_win_get_cursor(win)[1] - 1
      local cell = M.cell_at_cached(d, row, true)
      if cell then
        M.reveal_output(d, cell)
      end
    end)
  )
end

---Scroll just enough to show the output a cell just produced, without moving
---the cursor out of the cell (this is what Jupyter/VSCode do after a run).
---Figures in particular are drawn on virtual lines, and a terminal cannot
---draw them at all while they sit below the window.
function M.reveal_output(doc, cell)
  if not config.get().ui.reveal_output then
    return
  end
  if not util.buf_valid(doc.buf) or not cell then
    return
  end
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(win) ~= doc.buf then
    return -- the notebook is not the window the user is looking at
  end

  local anchor = cell.closing or cell.last_row or cell.first
  local start = cell.header or cell.first or 0
  if not anchor then
    return
  end

  -- only follow the cell the cursor is in
  local row = vim.api.nvim_win_get_cursor(win)[1] - 1
  if row < start or row > (cell.last_row or start) then
    return
  end

  local info = vim.fn.getwininfo(win)[1]
  if not info then
    return
  end
  local topline = info.topline
  -- keep the cursor on screen ('scrolloff' lines from the top)
  local limit = math.min(anchor + 1, math.max(1, (row + 1) - vim.o.scrolloff))
  local out_height = cell.out_height or 0
  if out_height == 0 then
    return
  end

  for _ = 1, 500 do
    if topline >= limit then
      break
    end
    local ok, height = pcall(vim.api.nvim_win_text_height, win, {
      start_row = topline - 1,
      end_row = anchor,
    })
    if not ok or not height or (height.all + out_height) <= info.height then
      break
    end
    topline = topline + 1
  end

  if topline ~= info.topline then
    vim.api.nvim_win_call(win, function()
      vim.fn.winrestview({ topline = topline })
    end)
    M.schedule_image_refresh(doc.buf)
  end
end

--- active cell --------------------------------------------------------------

function M.render_active(doc)
  if not util.buf_valid(doc.buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(doc.buf, ns_active, 0, -1)
  local cfg = config.get().ui
  if not cfg.active_bg or not doc.active then
    return
  end
  local cell = doc.cells[doc.active]
  if not cell then
    return
  end
  local nlines = vim.api.nvim_buf_line_count(doc.buf)
  local first, last = cell.first, cell.last
  if not first or not last or last < first then
    return
  end
  if last - first > 400 then
    return -- do not decorate huge cells line by line
  end
  for row = first, math.min(last, nlines - 1) do
    pcall(vim.api.nvim_buf_set_extmark, doc.buf, ns_active, row, 0, {
      line_hl_group = "JupynbCellActive",
      priority = 10,
    })
  end
end

--- statuscolumn -------------------------------------------------------------

---Called by 'statuscolumn' for every visible line: keep it cheap.
function M.statuscolumn()
  local buf = vim.api.nvim_get_current_buf()
  local doc = doc_mod.get(buf)
  local cfg = config.get().ui
  local lnum = vim.v.lnum

  local row = lnum - 1
  local cell, idx = nil, nil
  if doc and vim.v.virtnum == 0 then
    cell, idx = M.cell_at_cached(doc, row)
  end

  -- marker lines are chrome, not content: no line number on them
  local is_marker = cell and (row == cell.header or row == cell.closing)

  local num = ""
  if cfg.number and vim.wo.number and vim.v.virtnum == 0 and not is_marker then
    local n = lnum
    if vim.wo.relativenumber and vim.v.relnum ~= 0 then
      n = vim.v.relnum
    end
    local hl = (vim.v.relnum == 0) and "CursorLineNr" or "LineNr"
    num = "%#" .. hl .. "#" .. n
  end

  local bar = " "
  if cell then
    -- no bar on the closing fence nor on the blank line before the next cell
    local inside = cell and (row == cell.header or (row >= (cell.first or 0) and row <= (cell.last or -1)))
    if cell and inside then
      local active = (doc.active == idx)
      local group
      if cell.kind == "code" then
        if cell.status == "running" then
          group = "JupynbBarRunning"
        elseif cell.status == "error" then
          group = "JupynbBarError"
        else
          group = active and "JupynbBarActive" or "JupynbBar"
        end
      else
        group = active and "JupynbBarMdActive" or "JupynbBarMd"
      end
      local glyph = active and cfg.icons.bar or cfg.icons.bar_dim
      bar = "%#" .. group .. "#" .. glyph
    end
  end

  return "%=" .. num .. " " .. bar
end

---Apply the notebook look to a window showing a notebook buffer.
function M.setup_window(win, buf)
  local cfg = config.get().ui
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  if cfg.statuscolumn then
    pcall(function()
      vim.wo[win][0].statuscolumn = "%{%v:lua.require'jupynb.render'.statuscolumn()%}"
    end)
  end
  pcall(function()
    vim.wo[win][0].signcolumn = cfg.signcolumn
    vim.wo[win][0].foldcolumn = "0"
    vim.wo[win][0].wrap = cfg.wrap
    vim.wo[win][0].linebreak = cfg.wrap
    vim.wo[win][0].breakindent = cfg.wrap
    vim.wo[win][0].conceallevel = 2
    vim.wo[win][0].concealcursor = ""
  end)
end

--- entry points -------------------------------------------------------------

---Full refresh (structure + outputs).
function M.render(doc)
  doc:sync()
  M.update_active(doc, true)
  M.render_headers(doc)
  M.render_outputs(doc)
  M.render_active(doc)
end

M.refresh = util.debounce(30, function(buf)
  local doc = doc_mod.get(buf)
  if doc then
    M.render(doc)
  end
end)

---Recompute which cell holds the cursor; returns true when it changed.
function M.update_active(doc, silent)
  if not util.buf_valid(doc.buf) then
    return false
  end
  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(win) ~= doc.buf then
    return false
  end
  local row = vim.api.nvim_win_get_cursor(win)[1] - 1
  -- cached lookup: this runs on every cursor move
  local _, idx = M.cell_at_cached(doc, row, true)
  if idx == doc.active then
    return false
  end
  doc.active = idx
  if not silent then
    M.render_headers(doc)
    M.render_active(doc)
  end
  return true
end

--- spinner ------------------------------------------------------------------

local function any_running()
  for buf, doc in pairs(doc_mod.all()) do
    if util.buf_valid(buf) then
      for _, cell in ipairs(doc.cells) do
        if cell.status == "running" or cell.status == "queued" then
          return true
        end
      end
    end
  end
  return false
end

function M.start_spinner()
  if spinner_timer then
    return
  end
  spinner_timer = vim.uv.new_timer()
  spinner_timer:start(
    0,
    100,
    vim.schedule_wrap(function()
      if not any_running() then
        M.stop_spinner()
        return
      end
      spinner_frame = spinner_frame + 1
      for buf, doc in pairs(doc_mod.all()) do
        if util.buf_valid(buf) then
          M.render_headers(doc)
        end
      end
    end)
  )
end

function M.stop_spinner()
  if spinner_timer then
    spinner_timer:stop()
    spinner_timer:close()
    spinner_timer = nil
  end
  for buf, doc in pairs(doc_mod.all()) do
    if util.buf_valid(buf) then
      M.render_headers(doc)
    end
  end
end

return M
