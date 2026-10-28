---HTML tables (pandas / polars DataFrames) drawn as aligned box tables,
---instead of the unreadable wrapped `text/plain` repr.
local M = {}

local MAX_COL = 40 -- display cells per column before truncation

local ENTITIES = { lt = "<", gt = ">", amp = "&", quot = '"', apos = "'", nbsp = " " }

local function clean(html)
  local s = html:gsub("<[^>]->", ""):gsub("&(#?x?)(%w+);", function(kind, code)
    if kind == "#" then
      return vim.fn.nr2char(tonumber(code) or 63)
    elseif kind == "#x" then
      return vim.fn.nr2char(tonumber(code, 16) or 63)
    end
    return ENTITIES[code]
  end)
  return vim.trim((s:gsub("%s+", " ")))
end

local function parse_rows(html, spans)
  local rows = {}
  for tr in html:gmatch("<tr[^>]*>(.-)</tr>") do
    local row, col = {}, 1
    local function skip_spanned()
      while spans[col] and spans[col] > 0 do
        spans[col] = spans[col] - 1
        row[col] = { text = "", th = true }
        col = col + 1
      end
    end
    for tag, attrs, body in tr:gmatch("<(t[hd])([^>]*)>(.-)</t[hd]>") do
      skip_spanned()
      local colspan = tonumber(attrs:match('colspan="?(%d+)')) or 1
      local rowspan = tonumber(attrs:match('rowspan="?(%d+)')) or 1
      for i = 1, colspan do
        row[col] = { text = i == 1 and clean(body) or "", th = tag == "th" }
        if rowspan > 1 then
          spans[col] = rowspan - 1
        end
        col = col + 1
      end
    end
    skip_spanned()
    rows[#rows + 1] = row
  end
  return rows
end

---@param html string
---@return table|nil { head = rows, body = rows, notes = string[] }
function M.parse(html)
  html = html:gsub("<style.-</style>", "")
  local before, tbl, after = html:match("^(.-)(<table.-</table>)(.*)$")
  if not tbl then
    return nil
  end
  local thead = tbl:match("<thead[^>]*>(.-)</thead>")
  local tbody = tbl:match("<tbody[^>]*>(.-)</tbody>")
  local head, body
  if thead or tbody then
    head = parse_rows(thead or "", {})
    body = parse_rows(tbody or "", {})
  else
    body = parse_rows(tbl, {})
    head = {}
    if body[1] and vim.iter(body[1]):all(function(c)
      return c.th
    end) then
      head = { table.remove(body, 1) }
    end
  end
  if #head + #body == 0 then
    return nil
  end
  local notes = {}
  for _, s in ipairs({ clean(before), clean(after) }) do
    if s ~= "" then
      notes[#notes + 1] = s
    end
  end
  return { head = head, body = body, notes = notes }
end

local function fit(text, width, right)
  local w = vim.fn.strdisplaywidth(text)
  if w > width then
    text = vim.fn.strcharpart(text, 0, width - 1) .. "…"
    w = vim.fn.strdisplaywidth(text)
  end
  local gap = string.rep(" ", width - w)
  return right and (gap .. text) or (text .. gap)
end

local function numeric(text)
  return text:match("^[-+]?[%d.,_]+[eE]?[-+]?%d*%%?$") ~= nil or text == "NaN" or text == "null"
end

---@param t table result of `parse`
---@param hl table { border, head, index, text, note }
---@return table[] lines, each a list of { text, hl } chunks
function M.render(t, hl)
  local widths = {}
  for _, rows in ipairs({ t.head, t.body }) do
    for _, row in ipairs(rows) do
      for i, c in ipairs(row) do
        widths[i] = math.min(math.max(widths[i] or 1, vim.fn.strdisplaywidth(c.text)), MAX_COL)
      end
    end
  end

  local function rule(l, m, r)
    local parts = {}
    for i, w in ipairs(widths) do
      parts[i] = string.rep("─", w + 2)
    end
    return { { l .. table.concat(parts, m) .. r, hl.border } }
  end

  local function line(row, in_head)
    local chunks = { { "│", hl.border } }
    for i, w in ipairs(widths) do
      local c = row[i] or { text = "" }
      local group = in_head and hl.head or (c.th and hl.index or hl.text)
      chunks[#chunks + 1] = { " " .. fit(c.text, w, not in_head and numeric(c.text)) .. " ", group }
      chunks[#chunks + 1] = { "│", hl.border }
    end
    return chunks
  end

  local out = { rule("┌", "┬", "┐") }
  for _, row in ipairs(t.head) do
    out[#out + 1] = line(row, true)
  end
  if #t.head > 0 then
    out[#out + 1] = rule("├", "┼", "┤")
  end
  for _, row in ipairs(t.body) do
    out[#out + 1] = line(row, false)
  end
  out[#out + 1] = rule("└", "┴", "┘")
  for _, note in ipairs(t.notes) do
    out[#out + 1] = { { note, hl.note } }
  end
  return out
end

return M
