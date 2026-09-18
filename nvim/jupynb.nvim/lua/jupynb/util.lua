local M = {}

function M.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "jupynb" })
end

function M.err(msg)
  M.notify(msg, vim.log.levels.ERROR)
end

local counter = 0
function M.uuid()
  counter = counter + 1
  return string.format("%s-%d-%d", os.time(), counter, math.random(0, 99999))
end

---Run `fn` at most once every `ms` milliseconds, on the trailing edge.
function M.debounce(ms, fn)
  local timer = nil
  return function(...)
    local args = { ... }
    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end
    timer = vim.uv.new_timer()
    timer:start(
      ms,
      0,
      vim.schedule_wrap(function()
        if timer then
          timer:stop()
          timer:close()
          timer = nil
        end
        fn(unpack(args))
      end)
    )
  end
end

---Split a string into lines, keeping empty ones.
---@param str string
---@return string[]
function M.split_lines(str)
  local lines = vim.split(str or "", "\n", { plain = true })
  -- a trailing newline should not produce a spurious empty last line
  if #lines > 1 and lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

---nbformat stores sources as a list of lines, each ending with "\n" except
---the last one. Accept both that and a plain string.
---@return string[] lines
function M.source_to_lines(source)
  if source == nil then
    return { "" }
  end
  if type(source) == "string" then
    return vim.split(source, "\n", { plain = true })
  end
  local text = table.concat(source, "")
  return vim.split(text, "\n", { plain = true })
end

---@param lines string[]
---@return string[] nbformat source
function M.lines_to_source(lines)
  local out = {}
  for i, line in ipairs(lines) do
    out[i] = (i < #lines) and (line .. "\n") or line
  end
  if #out == 1 and out[1] == "" then
    return {}
  end
  return out
end

function M.trim_trailing_blanks(lines)
  local last = #lines
  while last > 0 and lines[last]:match("^%s*$") do
    last = last - 1
  end
  local out = {}
  for i = 1, last do
    out[i] = lines[i]
  end
  return out
end

function M.human_time(sec)
  if not sec then
    return ""
  end
  if sec < 1 then
    return string.format("%dms", math.floor(sec * 1000 + 0.5))
  elseif sec < 60 then
    return string.format("%.1fs", sec)
  end
  local m = math.floor(sec / 60)
  return string.format("%dm%02ds", m, math.floor(sec - m * 60))
end

--- ANSI ---------------------------------------------------------------------

local ANSI_FG = {
  [30] = "JupynbAnsiBlack",
  [31] = "JupynbAnsiRed",
  [32] = "JupynbAnsiGreen",
  [33] = "JupynbAnsiYellow",
  [34] = "JupynbAnsiBlue",
  [35] = "JupynbAnsiMagenta",
  [36] = "JupynbAnsiCyan",
  [37] = "JupynbAnsiWhite",
  [90] = "JupynbAnsiBlack",
  [91] = "JupynbAnsiRed",
  [92] = "JupynbAnsiGreen",
  [93] = "JupynbAnsiYellow",
  [94] = "JupynbAnsiBlue",
  [95] = "JupynbAnsiMagenta",
  [96] = "JupynbAnsiCyan",
  [97] = "JupynbAnsiWhite",
}

function M.strip_ansi(str)
  return (str:gsub("\27%[[%d;]*[A-Za-z]", ""))
end

---Convert a string with ANSI SGR escapes into extmark virt_text chunks.
---@param str string
---@param default_hl string
---@return table[] chunks
function M.ansi_chunks(str, default_hl)
  local chunks = {}
  local hl = default_hl
  local pos = 1
  while true do
    local s, e, params, final = str:find("\27%[([%d;]*)(%a)", pos)
    if not s then
      break
    end
    if s > pos then
      chunks[#chunks + 1] = { str:sub(pos, s - 1), hl }
    end
    if final == "m" then
      if params == "" or params == "0" then
        hl = default_hl
      else
        for code in params:gmatch("%d+") do
          local n = tonumber(code)
          if ANSI_FG[n] then
            hl = ANSI_FG[n]
          elseif n == 39 or n == 0 then
            hl = default_hl
          end
        end
      end
    end
    pos = e + 1
  end
  if pos <= #str then
    chunks[#chunks + 1] = { str:sub(pos), hl }
  end
  if #chunks == 0 then
    chunks[1] = { "", default_hl }
  end
  return chunks
end

--- misc ---------------------------------------------------------------------

function M.buf_valid(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

---Turn `nil` / `0` into the real buffer number (session tables are keyed by it).
function M.resolve_buf(buf)
  if buf == nil or buf == 0 then
    return vim.api.nvim_get_current_buf()
  end
  return buf
end

---Replace tabs/control chars so virtual text never breaks the layout.
function M.sanitize(line, max_width)
  line = line:gsub("\r", ""):gsub("\t", "    ")
  line = line:gsub("[%z\1-\8\11\12\14-\31]", "")
  if max_width and vim.fn.strdisplaywidth(line) > max_width then
    line = vim.fn.strcharpart(line, 0, max_width) .. "…"
  end
  return line
end

return M
