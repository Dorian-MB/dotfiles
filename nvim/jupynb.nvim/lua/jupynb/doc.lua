---The document model: a notebook rendered as an editable markdown-ish buffer.
---
---Buffer layout (markers are hidden by the renderer):
---
---    ``````python nb          <- code cell header (fence, 6+ backticks)
---    print("hi")
---    ``````                   <- closing fence, drawn as an empty gap
---
---    <!--nb-->                <- markdown cell header
---    # Title
---
---Because code cells are real fenced blocks, treesitter highlights their
---content with the kernel language, and markdown cells are highlighted as
---plain markdown.
local M = {}

local util = require("jupynb.util")
local ipynb = require("jupynb.ipynb")

M.MD_MARK = "<!--nb-->"
M.RAW_MARK = "<!--nb:raw-->"

M.ns = vim.api.nvim_create_namespace("jupynb.cells")

---@type table<integer, table>
local docs = {}

local Doc = {}
Doc.__index = Doc

--- helpers ------------------------------------------------------------------

local function fence_for(lines)
  local n = 5
  for _, line in ipairs(lines) do
    local run = line:match("^(`+)")
    if run and #run >= n then
      n = #run + 1
    end
  end
  return string.rep("`", math.max(6, n))
end

---@return string|nil kind, string|nil fence
local function header_kind(line)
  local b = line:byte(1)
  if b == 96 then
    local fence = line:match("^(```+)%s*[%w_%+%.%-]*%s+nb%s*$")
    if fence then
      return "code", fence
    end
  elseif b == 60 then
    if line:match("^<!%-%-nb%-%->%s*$") then
      return "markdown", nil
    elseif line:match("^<!%-%-nb:raw%-%->%s*$") then
      return "raw", nil
    end
  end
  return nil, nil
end
M.header_kind = header_kind

local function new_cell(kind)
  return {
    id = util.uuid(),
    kind = kind or "code",
    metadata = vim.empty_dict(),
    outputs = {},
    source_lines = {},
  }
end
M.new_cell = new_cell

--- text generation ----------------------------------------------------------

---Render a single cell to buffer lines.
---@return string[]
function M.cell_lines(cell, lang)
  local src = cell.source_lines or {}
  if #src == 0 then
    src = { "" }
  end
  local lines = {}
  if cell.kind == "code" then
    local fence = fence_for(src)
    lines[#lines + 1] = fence .. (lang or "python") .. " nb"
    vim.list_extend(lines, src)
    lines[#lines + 1] = fence
  else
    lines[#lines + 1] = cell.kind == "markdown" and M.MD_MARK or M.RAW_MARK
    vim.list_extend(lines, src)
  end
  return lines
end

---Full buffer text for a notebook.
---@return string[] lines, table[] cells, integer[] header rows (0-based)
function M.build(nb, lang)
  local lines, cells, rows = {}, {}, {}
  for _, nbcell in ipairs(nb.cells or {}) do
    local raw = {}
    for k, v in pairs(nbcell) do
      if
        k ~= "source"
        and k ~= "outputs"
        and k ~= "execution_count"
        and k ~= "cell_type"
        and k ~= "id"
        and k ~= "metadata"
      then
        raw[k] = v
      end
    end
    local cell = {
      id = util.uuid(),
      nb_id = nbcell.id,
      kind = nbcell.cell_type,
      raw = raw,
      metadata = nbcell.metadata or vim.empty_dict(),
      exec_count = nbcell.execution_count,
      outputs = ipynb.outputs_from_disk(nbcell.outputs),
      source_lines = util.source_to_lines(nbcell.source),
    }
    -- A code cell already ends with its (invisible) closing fence, which acts
    -- as the separator; other cells need a blank line before the next header.
    if #cells > 0 and cells[#cells].kind ~= "code" then
      lines[#lines + 1] = ""
    end
    rows[#cells + 1] = #lines
    vim.list_extend(lines, M.cell_lines(cell, lang))
    cells[#cells + 1] = cell
  end

  if #cells == 0 then
    local cell = new_cell("code")
    rows[1] = 0
    vim.list_extend(lines, M.cell_lines(cell, lang))
    cells[1] = cell
  end
  return lines, cells, rows
end

--- Doc ----------------------------------------------------------------------

---@return table doc
function M.create(buf, path, nb)
  local doc = setmetatable({
    buf = buf,
    path = path,
    nb = nb,
    lang = ipynb.language(nb),
    cells = {},
    tick = -1,
    active = nil,
  }, Doc)
  docs[buf] = doc
  return doc
end

function M.get(buf)
  if buf == nil or buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  local doc = docs[buf]
  if doc and not vim.api.nvim_buf_is_valid(doc.buf) then
    docs[buf] = nil
    return nil
  end
  return doc
end

function M.detach(buf)
  docs[buf] = nil
end

function M.all()
  return docs
end

---Anchor each cell to its header line so `sync()` can recognise it later.
---Without this, a freshly built buffer would be parsed as brand new cells and
---their outputs would be dropped.
function Doc:anchor(cells, rows)
  for i, cell in ipairs(cells) do
    cell.mark = nil
    -- right gravity: text inserted right before a header pushes the whole
    -- cell down, which is what makes "insert a cell above" keep identities.
    local ok, id = pcall(vim.api.nvim_buf_set_extmark, self.buf, M.ns, rows[i] or 0, 0, {
      right_gravity = true,
    })
    if ok then
      cell.mark = id
    end
  end
  self.cells = cells
end

---Force a cell's anchor back onto `row`.
---
---Extmark gravity alone cannot survive an in-place rewrite of a cell: a mark
---sitting at the start of a replaced range ends up *after* the replacement.
---Operations that rewrite a cell (change type, split, merge, move) therefore
---re-pin the identity themselves, right before the next `sync()`.
function Doc:pin(cell, row)
  if not cell or not cell.mark then
    return
  end
  pcall(vim.api.nvim_buf_set_extmark, self.buf, M.ns, math.max(row, 0), 0, {
    id = cell.mark,
    right_gravity = true,
  })
end

---Drop a cell's anchor, so a cell that is about to disappear cannot be
---confused with its neighbour once their rows collapse onto each other.
function Doc:unpin(cell)
  if cell and cell.mark then
    pcall(vim.api.nvim_buf_del_extmark, self.buf, M.ns, cell.mark)
    cell.mark = nil
  end
end

---Fill the buffer with the notebook text (used on read / on `:Jupynb fix`).
function Doc:fill()
  local lines, cells, rows = M.build(self.nb, self.lang)
  local undolevels = vim.bo[self.buf].undolevels
  vim.bo[self.buf].undolevels = -1
  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
  vim.bo[self.buf].undolevels = undolevels
  vim.api.nvim_buf_clear_namespace(self.buf, M.ns, 0, -1)
  self:anchor(cells, rows)
  self.tick = -1
  self:sync(true)
end

---Rebuild the buffer from the current cell model, keeping cell identities.
function Doc:rebuild()
  self:sync()
  local cells = self.cells
  local lines, rows = {}, {}
  for i, cell in ipairs(cells) do
    if i > 1 and cells[i - 1].kind ~= "code" then
      lines[#lines + 1] = ""
    end
    rows[i] = #lines
    vim.list_extend(lines, M.cell_lines(cell, self.lang))
  end
  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(self.buf, M.ns, 0, -1)
  self:anchor(cells, rows)
  self.tick = -1
  self:sync(true)
end

---Scan the buffer text and return the cell layout.
---@return table[] items, string[] lines
function Doc:scan()
  local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
  local items = {}
  local n = #lines
  local i = 1

  local function is_header(idx)
    return header_kind(lines[idx]) ~= nil
  end

  while i <= n do
    local kind, fence = header_kind(lines[i])
    if kind == "code" then
      local close = nil
      for j = i + 1, n do
        local run = lines[j]:match("^(`+)%s*$")
        if run and #run >= #fence then
          close = j
          break
        end
      end
      local content_last = (close or (n + 1)) - 1
      items[#items + 1] = {
        kind = "code",
        header = i - 1,
        first = i,
        last = content_last - 1,
        closing = close and (close - 1) or nil,
        last_row = (close or n) - 1,
      }
      i = (close or n) + 1
    elseif kind then
      local j = i + 1
      while j <= n and not is_header(j) do
        j = j + 1
      end
      -- blank lines before the next cell are separators, not content
      local last = j - 2
      while last >= i and (lines[last + 1] or ""):match("^%s*$") do
        last = last - 1
      end
      items[#items + 1] = {
        kind = kind,
        header = i - 1,
        first = i,
        last = last,
        last_row = j - 2,
      }
      i = j
    else
      -- Text that lives outside of any cell (the user typed between cells,
      -- or the buffer starts with prose): treat it as a markdown cell
      -- without a header, unless it is only blank lines.
      local j = i
      local has_text = false
      while j <= n and not is_header(j) do
        if not lines[j]:match("^%s*$") then
          has_text = true
        end
        j = j + 1
      end
      if has_text then
        items[#items + 1] = {
          kind = "markdown",
          header = nil,
          first = i - 1,
          last = j - 2,
          last_row = j - 2,
          headerless = true,
        }
      end
      i = j
    end
  end

  return items, lines
end

---Refresh the cell model from the buffer, preserving outputs across edits.
---@param force boolean|nil
function Doc:sync(force)
  if not util.buf_valid(self.buf) then
    return
  end
  local tick = vim.api.nvim_buf_get_changedtick(self.buf)
  if not force and tick == self.tick then
    return
  end
  self.tick = tick

  local items, lines = self:scan()

  -- Where does each known cell live now?
  local by_row = {}
  for _, cell in ipairs(self.cells) do
    cell.__used = nil
    if cell.mark then
      local pos = vim.api.nvim_buf_get_extmark_by_id(self.buf, M.ns, cell.mark, {})
      if pos and pos[1] then
        local row = pos[1]
        by_row[row] = by_row[row] or cell
      end
    end
  end

  local cells = {}
  for _, item in ipairs(items) do
    local anchor = item.header or item.first
    local cell = by_row[anchor]
    if cell and cell.__used then
      cell = nil
    end
    if not cell then
      cell = new_cell(item.kind)
    end
    cell.__used = true
    if cell.kind ~= item.kind then
      cell.kind = item.kind
      cell.outputs = {}
      cell.exec_count = nil
      cell.status = nil
      cell.elapsed = nil
    end
    cell.header = item.header
    cell.first = item.first
    cell.last = item.last
    cell.closing = item.closing
    cell.last_row = item.last_row
    cell.headerless = item.headerless

    local src = {}
    for row = item.first, item.last do
      src[#src + 1] = lines[row + 1] or ""
    end
    if item.kind ~= "code" then
      src = util.trim_trailing_blanks(src)
    end
    cell.source_lines = src

    cells[#cells + 1] = cell
  end

  -- Drop marks of cells that disappeared.
  for _, cell in ipairs(self.cells) do
    if not cell.__used and cell.mark then
      pcall(vim.api.nvim_buf_del_extmark, self.buf, M.ns, cell.mark)
      cell.mark = nil
    end
  end

  self.cells = cells

  -- Re-anchor every cell.
  for _, cell in ipairs(cells) do
    local row = cell.header or cell.first
    local ok, id = pcall(vim.api.nvim_buf_set_extmark, self.buf, M.ns, row, 0, {
      id = cell.mark,
      right_gravity = true,
    })
    if ok then
      cell.mark = id
    end
    cell.__used = nil
  end
end

---@param row integer 0-based
---@return table|nil cell, integer|nil index
function Doc:cell_at(row)
  self:sync()
  local last
  for i, cell in ipairs(self.cells) do
    local start = cell.header or cell.first
    if row < start then
      break
    end
    last = i
    if row <= cell.last_row then
      return cell, i
    end
  end
  -- Between two cells: attach to the previous one.
  if last then
    return self.cells[last], last
  end
  return self.cells[1], self.cells[1] and 1 or nil
end

function Doc:cell_at_cursor(win)
  win = win or 0
  local row = vim.api.nvim_win_get_cursor(win)[1] - 1
  return self:cell_at(row)
end

function Doc:cell_by_id(id)
  for i, cell in ipairs(self.cells) do
    if cell.id == id then
      return cell, i
    end
  end
end

function Doc:code_of(cell)
  return table.concat(cell.source_lines or {}, "\n")
end

---Notebook table ready to be written to disk.
function Doc:to_nb(opts)
  self:sync()
  local cells = {}
  for _, cell in ipairs(self.cells) do
    cells[#cells + 1] = cell
  end
  return ipynb.to_nb(cells, self.nb, opts)
end

M.Doc = Doc

return M
