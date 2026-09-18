---Highlight groups, derived from whatever colorscheme is currently active.
---Nothing is hardcoded: colors come from the base46 palette when NvChad is
---used, and from the standard highlight groups otherwise.
local M = {}

M.colors = {}
M.transparent = false

local function hl(name)
  local ok, tbl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return (ok and tbl) or {}
end

local function hex(n)
  if type(n) ~= "number" then
    return nil
  end
  return string.format("#%06x", n)
end

local function rgb(color)
  if type(color) ~= "string" then
    return nil
  end
  local h = color:gsub("#", "")
  if #h ~= 6 then
    return nil
  end
  return {
    tonumber(h:sub(1, 2), 16),
    tonumber(h:sub(3, 4), 16),
    tonumber(h:sub(5, 6), 16),
  }
end

---Mix `fg` into `bg`, `t` in [0, 1].
local function blend(bg, fg, t)
  local a, b = rgb(bg), rgb(fg)
  if not a or not b then
    return bg or fg
  end
  local out = {}
  for i = 1, 3 do
    out[i] = math.floor(a[i] + (b[i] - a[i]) * t + 0.5)
  end
  return string.format("#%02x%02x%02x", out[1], out[2], out[3])
end
M.blend = blend

local function luminance(color)
  local c = rgb(color)
  if not c then
    return 0
  end
  return (0.299 * c[1] + 0.587 * c[2] + 0.114 * c[3]) / 255
end

local function first(...)
  for _, v in ipairs({ ... }) do
    if type(v) == "string" and v:match("^#%x%x%x%x%x%x$") then
      return v
    end
  end
end

---Collect a palette from base46 (NvChad) or from standard groups.
local function palette()
  local p = {}
  local ok, base46 = pcall(require, "base46")
  if ok then
    local ok30, b30 = pcall(base46.get_theme_tb, "base_30")
    if ok30 and type(b30) == "table" then
      p = vim.tbl_extend("force", p, b30)
    end
    local ok16, b16 = pcall(base46.get_theme_tb, "base_16")
    if ok16 and type(b16) == "table" then
      p.base16 = b16
    end
  end

  local normal = hl("Normal")
  local comment = hl("Comment")
  local cursorline = hl("CursorLine")
  local visual = hl("Visual")
  local func = hl("Function")
  local keyword = hl("Keyword")
  local str = hl("String")
  local err = hl("DiagnosticError")
  local warn = hl("DiagnosticWarn")
  local okhl = hl("DiagnosticOk")
  local info = hl("DiagnosticInfo")
  local statusline = hl("StatusLine")
  local pmenu = hl("Pmenu")

  M.transparent = normal.bg == nil

  local c = {}
  c.fg = first(hex(normal.fg), p.white, "#d0d0d0")
  c.bg = first(hex(normal.bg), p.black, hex(pmenu.bg), "#1e1e2e")
  c.dark = first(p.darker_black, blend(c.bg, "#000000", 0.25))
  c.surface = first(p.one_bg, hex(cursorline.bg), blend(c.bg, c.fg, 0.06))
  c.surface2 = first(p.one_bg2, blend(c.bg, c.fg, 0.10))
  c.surface3 = first(p.one_bg3, blend(c.bg, c.fg, 0.14))
  c.muted = first(hex(comment.fg), p.grey_fg, blend(c.bg, c.fg, 0.45))
  c.line = first(p.line, hex(visual.bg), blend(c.bg, c.fg, 0.12))
  c.blue = first(p.blue, hex(func.fg), hex(info.fg), "#89b4fa")
  c.purple = first(p.purple, hex(keyword.fg), "#cba6f7")
  c.green = first(p.green, hex(okhl.fg), hex(str.fg), "#a6e3a1")
  c.red = first(p.red, hex(err.fg), "#f38ba8")
  c.yellow = first(p.yellow, hex(warn.fg), "#f9e2af")
  c.orange = first(p.orange, c.yellow)
  c.cyan = first(p.cyan, p.teal, "#94e2d5")
  c.statusbg = first(p.statusline_bg, hex(statusline.bg), c.surface)

  -- Light themes need the opposite blend direction for elevated surfaces.
  if luminance(c.bg) > 0.5 then
    c.surface = blend(c.bg, "#000000", 0.05)
    c.surface2 = blend(c.bg, "#000000", 0.09)
    c.surface3 = blend(c.bg, "#000000", 0.13)
  end

  return c
end

---@return table<string, table> groups
local function groups(c)
  local header_bg = blend(c.bg, c.surface2, 1.0)
  -- the focused cell is signalled by a brighter bar, not by a coloured bar:
  -- a neutral tint works for code and markdown cells alike
  local header_active_bg = blend(header_bg, c.fg, 0.14)
  local cell_bg = blend(c.bg, c.surface, 0.55)

  return {
    -- cell chrome
    JupynbHeader = { bg = header_bg, fg = c.muted },
    JupynbHeaderActive = { bg = header_active_bg, fg = c.fg },
    JupynbHeaderIcon = { bg = header_bg, fg = c.blue },
    JupynbHeaderIconActive = { bg = header_active_bg, fg = c.blue },
    JupynbHeaderMd = { bg = header_bg, fg = c.purple },
    JupynbHeaderMdActive = { bg = header_active_bg, fg = c.purple },
    JupynbHeaderLabel = { bg = header_bg, fg = c.muted },
    JupynbHeaderLabelActive = { bg = header_active_bg, fg = c.fg, bold = true },
    JupynbHeaderCount = { bg = header_bg, fg = blend(c.bg, c.blue, 0.75) },
    JupynbHeaderCountActive = { bg = header_active_bg, fg = c.blue, bold = true },
    JupynbHeaderTime = { bg = header_bg, fg = c.muted },
    JupynbHeaderTimeActive = { bg = header_active_bg, fg = c.muted },
    JupynbHeaderOk = { bg = header_bg, fg = c.green },
    JupynbHeaderOkActive = { bg = header_active_bg, fg = c.green },
    JupynbHeaderError = { bg = header_bg, fg = c.red },
    JupynbHeaderErrorActive = { bg = header_active_bg, fg = c.red },
    JupynbHeaderRunning = { bg = header_bg, fg = c.yellow },
    JupynbHeaderRunningActive = { bg = header_active_bg, fg = c.yellow },

    -- the vertical bar next to the text (statuscolumn)
    JupynbBar = { fg = blend(c.bg, c.blue, 0.35) },
    JupynbBarActive = { fg = c.blue },
    JupynbBarMd = { fg = blend(c.bg, c.purple, 0.35) },
    JupynbBarMdActive = { fg = c.purple },
    JupynbBarRunning = { fg = c.yellow },
    JupynbBarError = { fg = c.red },

    -- cell body
    JupynbCellActive = { bg = cell_bg },
    JupynbGap = { fg = c.bg },

    -- outputs
    JupynbOutBorder = { fg = blend(c.bg, c.fg, 0.28) },
    JupynbOutText = { fg = blend(c.fg, c.bg, 0.12) },
    JupynbOutLabel = { fg = c.muted, italic = true },
    JupynbOutStderr = { fg = c.yellow },
    JupynbOutErrBorder = { fg = c.red },
    JupynbOutErrName = { fg = c.red, bold = true },
    JupynbOutErrText = { fg = blend(c.red, c.fg, 0.35) },
    JupynbOutMore = { fg = c.muted, italic = true },
    JupynbOutImage = { fg = c.cyan, italic = true },

    -- misc
    JupynbStatus = { fg = c.blue },
    JupynbStatusDead = { fg = c.muted },
    JupynbStatusBusy = { fg = c.yellow },

    -- ANSI palette used by tracebacks
    JupynbAnsiBlack = { fg = c.muted },
    JupynbAnsiRed = { fg = c.red },
    JupynbAnsiGreen = { fg = c.green },
    JupynbAnsiYellow = { fg = c.yellow },
    JupynbAnsiBlue = { fg = c.blue },
    JupynbAnsiMagenta = { fg = c.purple },
    JupynbAnsiCyan = { fg = c.cyan },
    JupynbAnsiWhite = { fg = c.fg },
  }
end

---(Re)define every highlight group from the active colorscheme.
function M.apply()
  local c = palette()
  M.colors = c
  local defs = groups(c)
  local overrides = require("jupynb.config").get().highlights or {}
  for name, def in pairs(defs) do
    local merged = vim.tbl_deep_extend("force", def, overrides[name] or {})
    pcall(vim.api.nvim_set_hl, 0, name, merged)
  end
  for name, def in pairs(overrides) do
    if not defs[name] then
      pcall(vim.api.nvim_set_hl, 0, name, def)
    end
  end
end

return M
