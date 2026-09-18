---User facing cell operations.
local M = {}

local doc_mod = require("jupynb.doc")
local kernel = require("jupynb.kernel")
local render = require("jupynb.render")
local output = require("jupynb.output")
local util = require("jupynb.util")

local function get(buf)
  buf = util.resolve_buf(buf)
  local doc = doc_mod.get(buf)
  if not doc then
    return nil, nil
  end
  doc:sync()
  return doc, buf
end

local function cursor_cell(buf)
  local doc = doc_mod.get(util.resolve_buf(buf))
  if not doc then
    return nil
  end
  doc:sync()
  local cell, idx = doc:cell_at_cursor()
  return doc, cell, idx
end

local function after_change(doc)
  doc:sync(true)
  doc.active = nil
  render.render(doc)
end

---Put the cursor on the first content line of a cell.
local function focus(doc, idx, insert)
  local cell = doc.cells[idx]
  if not cell then
    return
  end
  local row = cell.first or cell.header or 0
  local nlines = vim.api.nvim_buf_line_count(doc.buf)
  row = math.min(row, nlines - 1)
  local line = vim.api.nvim_buf_get_lines(doc.buf, row, row + 1, false)[1] or ""
  vim.api.nvim_win_set_cursor(0, { row + 1, insert and #line or 0 })
  render.update_active(doc)
  if insert then
    vim.cmd("startinsert!")
  end
end

--- running -----------------------------------------------------------------

---@param opts table|nil { advance = boolean, insert = boolean }
function M.run(buf, opts)
  opts = opts or {}
  local doc, cell, idx = cursor_cell(buf)
  if not doc or not cell then
    return
  end

  if cell.kind == "code" then
    kernel.execute(doc.buf, cell)
  end

  if opts.insert then
    M.insert(doc.buf, "below", "code")
    return
  end
  if opts.advance then
    if idx >= #doc.cells then
      M.insert(doc.buf, "below", "code")
    else
      focus(doc, idx + 1)
    end
  end
end

---@param scope "all"|"above"|"below"
function M.run_scope(buf, scope)
  local doc, cell, idx = cursor_cell(buf)
  if not doc then
    return
  end
  local from, to = 1, #doc.cells
  if scope == "above" then
    to = math.max((idx or 1) - 1, 0)
  elseif scope == "below" then
    from = idx or 1
  end
  local count = 0
  for i = from, to do
    local c = doc.cells[i]
    if c and c.kind == "code" and not doc:code_of(c):match("^%s*$") then
      kernel.execute(doc.buf, c)
      count = count + 1
    end
  end
  if count == 0 then
    util.notify("nothing to run")
  end
end

--- structure ---------------------------------------------------------------

---@param where "above"|"below"
---@param kind "code"|"markdown"|"raw"
function M.insert(buf, where, kind)
  local doc, cell, idx = cursor_cell(buf)
  if not doc then
    return
  end
  kind = kind or "code"
  local fresh = doc_mod.new_cell(kind)
  local body = doc_mod.cell_lines(fresh, doc.lang)

  local at, new_idx
  if not cell then
    at, new_idx = 0, 1
  elseif where == "above" then
    at = cell.header or cell.first or 0
    new_idx = idx
    if kind ~= "code" then
      table.insert(body, "") -- separate it from the cell below
    end
  else
    at = (cell.last_row or 0) + 1
    new_idx = (idx or 0) + 1
    if cell.kind ~= "code" then
      table.insert(body, 1, "")
    end
  end

  at = math.min(math.max(at, 0), vim.api.nvim_buf_line_count(doc.buf))
  vim.api.nvim_buf_set_lines(doc.buf, at, at, false, body)
  after_change(doc)
  focus(doc, new_idx, true)
end

function M.delete(buf)
  local doc, cell, idx = cursor_cell(buf)
  if not doc or not cell then
    return
  end
  local start = cell.header or cell.first or 0
  local stop = (cell.last_row or start) + 1
  doc:unpin(cell) -- its anchor would collapse onto the next cell's
  local nlines = vim.api.nvim_buf_line_count(doc.buf)
  local next_line = vim.api.nvim_buf_get_lines(doc.buf, stop, stop + 1, false)[1]
  if next_line and next_line:match("^%s*$") then
    stop = stop + 1
  elseif start > 0 then
    local prev = vim.api.nvim_buf_get_lines(doc.buf, start - 1, start, false)[1]
    if prev and prev:match("^%s*$") then
      start = start - 1
    end
  end
  vim.api.nvim_buf_set_lines(doc.buf, start, math.min(stop, nlines), false, {})

  if vim.api.nvim_buf_line_count(doc.buf) == 0 or #doc:scan() == 0 then
    local fresh = doc_mod.new_cell("code")
    vim.api.nvim_buf_set_lines(doc.buf, 0, -1, false, doc_mod.cell_lines(fresh, doc.lang))
  end
  after_change(doc)
  focus(doc, math.min(idx or 1, #doc.cells))
end

---@param kind "code"|"markdown"|"raw"|nil  nil toggles code <-> markdown
function M.change_kind(buf, kind)
  local doc, cell, idx = cursor_cell(buf)
  if not doc or not cell then
    return
  end
  if not kind then
    kind = cell.kind == "code" and "markdown" or "code"
  end
  if kind == cell.kind then
    return
  end
  local source = vim.deepcopy(cell.source_lines or {})
  local start = cell.header or cell.first or 0
  local stop = (cell.last_row or start) + 1
  local fresh = { kind = kind, source_lines = source }
  vim.api.nvim_buf_set_lines(doc.buf, start, stop, false, doc_mod.cell_lines(fresh, doc.lang))
  doc:pin(cell, start)
  after_change(doc)
  focus(doc, idx or 1)
end

---@param dir -1|1
function M.move(buf, dir)
  local doc, cell, idx = cursor_cell(buf)
  if not doc or not cell or not idx then
    return
  end
  local target = doc.cells[idx + dir]
  if not target then
    return
  end
  local a, b = cell, target
  if dir < 0 then
    a, b = target, cell
  end
  local a_start = a.header or a.first
  local a_stop = (a.last_row or a_start) + 1
  local b_start = b.header or b.first
  local b_stop = (b.last_row or b_start) + 1

  local a_lines = vim.api.nvim_buf_get_lines(doc.buf, a_start, a_stop, false)
  local b_lines = vim.api.nvim_buf_get_lines(doc.buf, b_start, b_stop, false)
  local between = vim.api.nvim_buf_get_lines(doc.buf, a_stop, b_start, false)

  local merged = {}
  vim.list_extend(merged, b_lines)
  vim.list_extend(merged, between)
  vim.list_extend(merged, a_lines)
  vim.api.nvim_buf_set_lines(doc.buf, a_start, b_stop, false, merged)
  doc:pin(b, a_start)
  doc:pin(a, a_start + #b_lines + #between)
  after_change(doc)
  focus(doc, idx + dir)
end

---Split the current cell at the cursor line.
function M.split(buf)
  local doc, cell, idx = cursor_cell(buf)
  if not doc or not cell then
    return
  end
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  if row <= (cell.first or 0) or row > (cell.last or 0) then
    util.notify("place the cursor inside the cell body to split it")
    return
  end
  local head, tail = {}, {}
  for i, line in ipairs(cell.source_lines or {}) do
    local line_row = cell.first + i - 1
    if line_row < row then
      head[#head + 1] = line
    else
      tail[#tail + 1] = line
    end
  end
  local start = cell.header or cell.first
  local stop = (cell.last_row or start) + 1
  local lines = doc_mod.cell_lines({ kind = cell.kind, source_lines = head }, doc.lang)
  if cell.kind ~= "code" then
    lines[#lines + 1] = ""
  end
  vim.list_extend(lines, doc_mod.cell_lines({ kind = cell.kind, source_lines = tail }, doc.lang))
  vim.api.nvim_buf_set_lines(doc.buf, start, stop, false, lines)
  doc:pin(cell, start) -- the first half keeps the identity (and the outputs)
  after_change(doc)
  focus(doc, (idx or 1) + 1)
end

---Merge the current cell with the next one.
function M.merge(buf)
  local doc, cell, idx = cursor_cell(buf)
  if not doc or not cell or not idx then
    return
  end
  local next_cell = doc.cells[idx + 1]
  if not next_cell then
    return
  end
  if next_cell.kind ~= cell.kind then
    util.notify("cannot merge cells of different types")
    return
  end
  local source = vim.deepcopy(cell.source_lines or {})
  if cell.kind ~= "code" then
    source[#source + 1] = ""
  end
  vim.list_extend(source, next_cell.source_lines or {})
  local start = cell.header or cell.first
  local stop = (next_cell.last_row or start) + 1
  doc:unpin(next_cell)
  vim.api.nvim_buf_set_lines(
    doc.buf,
    start,
    stop,
    false,
    doc_mod.cell_lines({ kind = cell.kind, source_lines = source }, doc.lang)
  )
  doc:pin(cell, start) -- the merged cell keeps the first cell's identity
  after_change(doc)
  focus(doc, idx)
end

--- outputs -----------------------------------------------------------------

function M.clear(buf, all)
  local doc, cell = cursor_cell(buf)
  if not doc then
    return
  end
  if all then
    for _, c in ipairs(doc.cells) do
      c.outputs, c.status, c.elapsed, c.exec_count = {}, nil, nil, nil
    end
  elseif cell then
    cell.outputs, cell.status, cell.elapsed = {}, nil, nil
  end
  vim.bo[doc.buf].modified = true
  render.render(doc)
end

---Show the full (untruncated) output of the current cell in a split.
function M.show_output(buf)
  local doc, cell = cursor_cell(buf)
  if not doc or not cell then
    return
  end
  local lines = output.as_text(cell)
  if #lines == 0 then
    util.notify("this cell has no output")
    return
  end
  local scratch = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, lines)
  vim.bo[scratch].filetype = "text"
  vim.bo[scratch].modifiable = false
  vim.bo[scratch].bufhidden = "wipe"
  vim.cmd("botright split")
  vim.api.nvim_win_set_buf(0, scratch)
  vim.api.nvim_win_set_height(0, math.min(#lines + 1, 20))
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = scratch, nowait = true })
end

--- navigation --------------------------------------------------------------

function M.goto_cell(buf, delta)
  local doc, _, idx = cursor_cell(buf)
  if not doc or not idx then
    return
  end
  local target = math.min(math.max(idx + delta, 1), #doc.cells)
  focus(doc, target)
end

function M.goto_index(buf, index)
  local doc = get(buf)
  if not doc then
    return
  end
  focus(doc, math.min(math.max(index, 1), #doc.cells))
end

--- maintenance -------------------------------------------------------------

---Rewrite the buffer from the parsed model (repairs broken markers).
function M.fix(buf)
  local doc = get(buf)
  if not doc then
    return
  end
  doc:rebuild()
  render.render(doc)
  util.notify("notebook structure normalised")
end

return M
