---Inline images (matplotlib figures, PIL, ...) drawn by image.nvim over the
---blank virtual lines that `jupynb.output` reserves under a cell.
---
---image.nvim positions an "inline" image relative to a buffer row: the first
---image row lands on the first virtual line below that row, and
---`render_offset_top` pushes it further down. jupynb reserves the exact number
---of virtual lines it needs, so the image simply sits in the hole.
local M = {}

local config = require("jupynb.config")

local function api()
  local ok, image = pcall(require, "image")
  if not ok then
    return nil
  end
  return image
end

---Terminal cell size in pixels, or nil when the terminal cannot report it
---(no graphics protocol, headless, ...). Cached: querying costs a round trip.
---nil = not asked yet, false = the terminal cannot tell, table = {w, h}
local cached_size, cached_at = nil, 0

function M.term_cell_size()
  local now = vim.uv.now()
  if cached_size ~= nil and (now - cached_at) < 10000 then
    if cached_size == false then
      return nil
    end
    return cached_size[1], cached_size[2]
  end
  cached_at = now
  cached_size = false
  local ok, utils = pcall(require, "image/utils")
  if ok and utils and utils.term and utils.term.get_size then
    local ok2, size = pcall(utils.term.get_size)
    if ok2 and size and (size.cell_width or 0) > 0 and (size.cell_height or 0) > 0 then
      cached_size = { size.cell_width, size.cell_height }
      return size.cell_width, size.cell_height
    end
  end
  return nil
end

--- terminal multiplexers ----------------------------------------------------

---Graphics escapes travel from Neovim to the terminal emulator untouched; a
---multiplexer in between has to be told to forward them, otherwise it eats
---them (tmux) or refuses to render them (herdr).
local function tmux_forwards_graphics()
  local ok, res = pcall(function()
    return vim.system({ "tmux", "show", "-Apv", "allow-passthrough" }, { text = true }):wait(1000)
  end)
  if not ok or not res or res.code ~= 0 then
    return true -- cannot tell, do not get in the way
  end
  local value = vim.trim(res.stdout or "")
  return value == "on" or value == "all"
end

local function herdr_forwards_graphics()
  local path = vim.env.HERDR_CONFIG_PATH
  if not path or path == "" then
    path = vim.fn.expand("~/.config/herdr/config.toml")
  elseif vim.fn.isdirectory(path) == 1 then
    path = path .. "/config.toml"
  end
  if vim.fn.filereadable(path) == 0 then
    return false
  end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return false
  end
  for _, line in ipairs(lines) do
    local stripped = line:gsub("%s", "")
    if stripped:match("^kitty_graphics=true") then
      return true
    end
  end
  return false
end

local blocker = { checked_at = 0, reason = nil, notified = false }

---Why figures cannot be drawn here, or nil when they can.
---@return string|nil reason, string|nil fix
function M.blocker()
  local now = vim.uv.now()
  if blocker.checked_at > 0 and (now - blocker.checked_at) < 30000 then
    return blocker.reason, blocker.fix
  end

  local reason, fix = nil, nil
  if vim.env.TMUX and vim.env.TMUX ~= "" and not tmux_forwards_graphics() then
    reason = "tmux is swallowing the graphics escape codes"
    fix = "add `set -g allow-passthrough on` to your tmux.conf, then restart the tmux server"
  elseif vim.env.HERDR_PANE_ID and not herdr_forwards_graphics() then
    reason = "herdr does not forward kitty graphics yet"
    fix =
      "add `kitty_graphics = true` under `[experimental]` in ~/.config/herdr/config.toml, then `herdr server reload-config`"
  end

  blocker = { checked_at = now, reason = reason, fix = fix, notified = blocker.notified }
  return reason, fix
end

---Tell the user once per session why they only get placeholders.
function M.warn_blocked()
  local reason, fix = M.blocker()
  if reason and not blocker.notified then
    blocker.notified = true
    require("jupynb.util").notify(
      string.format("figures shown as placeholders: %s.\n%s", reason, fix or ""),
      vim.log.levels.WARN
    )
  end
end

---True when figures can really be drawn; otherwise jupynb prints a compact
---`image/png 640x480` placeholder instead of reserving empty lines.
function M.available()
  if not config.get().images.enabled then
    return false
  end
  local image = api()
  if not image then
    return false
  end
  if image.is_enabled and not image.is_enabled() then
    return false
  end
  if M.blocker() then
    return false
  end
  return M.term_cell_size() ~= nil
end

---@return integer width, integer height
function M.cell_size()
  local w, h = M.term_cell_size()
  return w or 10, h or 20
end

---Pixel size of a PNG, read straight from its IHDR chunk. Notebook files
---store images as base64 without any size metadata.
---@return integer|nil width, integer|nil height
function M.probe_size(path)
  local fd = io.open(path, "rb")
  if not fd then
    return nil
  end
  local header = fd:read(24)
  fd:close()
  if not header or #header < 24 or header:sub(2, 4) ~= "PNG" then
    return nil
  end
  local function be32(offset)
    local a, b, c, d = header:byte(offset, offset + 3)
    return ((a * 256 + b) * 256 + c) * 256 + d
  end
  local w, h = be32(17), be32(21)
  if w > 0 and h > 0 then
    return w, h
  end
end

---Pixel size -> terminal rows/columns, aspect ratio preserved.
---@return integer rows, integer cols
function M.size_in_cells(width, height)
  local cfg = config.get().images
  local cw, ch = M.cell_size()
  width = (width and width > 0) and width or 640
  height = (height and height > 0) and height or 480

  local cols = math.ceil(width / cw)
  local rows = math.ceil(height / ch)

  local max_cols = math.min(cfg.max_width, math.max(vim.o.columns - 12, 20))
  if cols > max_cols then
    rows = math.max(math.floor(rows * (max_cols / cols)), 1)
    cols = max_cols
  end
  if rows > cfg.max_height then
    cols = math.max(math.floor(cols * (cfg.max_height / rows)), 1)
    rows = cfg.max_height
  end
  return math.max(rows, 1), math.max(cols, 1)
end

---Images are keyed by cell + output index, so a redraw moves them instead of
---uploading them again (no flicker while typing).
---@type table<integer, table<string, table>>
local live = {}

---Start a redraw cycle for a buffer.
function M.begin_frame(buf)
  for _, entry in pairs(live[buf] or {}) do
    entry.used = false
  end
end

---@param buf integer
---@param row integer 0-based anchor row (the cell's closing line)
---@param spec table { key, path, offset, rows, cols }
function M.place(buf, row, spec)
  local image = api()
  if not image or not spec.path or not spec.key then
    return
  end
  local win = vim.fn.bufwinid(buf)
  if win == -1 then
    return
  end

  live[buf] = live[buf] or {}
  local entry = live[buf][spec.key]

  if entry and entry.path == spec.path and entry.obj then
    entry.used = true
    local obj = entry.obj
    local changed = obj.geometry.y ~= row
      or obj.render_offset_top ~= (spec.offset or 0)
      or obj.geometry.width ~= spec.cols
      or obj.geometry.height ~= spec.rows
    if changed then
      obj.geometry.y = row
      obj.geometry.x = 4
      obj.geometry.width = spec.cols
      obj.geometry.height = spec.rows
      obj.render_offset_top = spec.offset or 0
    end
    obj.window = win
    pcall(function()
      obj:render()
    end)
    return
  end

  if entry and entry.obj then
    pcall(function()
      entry.obj:clear()
    end)
  end

  local id = string.format("jupynb:%d:%s", buf, spec.key)
  local ok, obj = pcall(image.from_file, spec.path, {
    id = id,
    buffer = buf,
    window = win,
    with_virtual_padding = false, -- jupynb reserves the lines itself
    inline = true,
    x = 4, -- aligned with the output gutter
    y = row,
    render_offset_top = spec.offset or 0,
    width = spec.cols,
    height = spec.rows,
  })
  if not ok or not obj then
    return
  end

  pcall(function()
    obj:render()
  end)
  live[buf][spec.key] = { obj = obj, path = spec.path, used = true }
end

---Redraw every image of a buffer.
---
---image.nvim positions an image from `screenpos()` of its anchor line, so it
---needs an up to date screen layout. Right after a cell produces a figure the
---virtual lines exist but the screen has not been laid out yet, and the render
---silently bails ("below viewport"); this is called again once it has.
function M.refresh(buf)
  local entries = live[buf]
  if not entries or vim.tbl_isempty(entries) then
    return
  end
  local win = vim.fn.bufwinid(buf)
  if win == -1 then
    return
  end
  for _, entry in pairs(entries) do
    if entry.obj then
      entry.obj.window = win
      pcall(function()
        entry.obj:render()
      end)
    end
  end
end

---True when the buffer currently holds at least one image.
function M.has_images(buf)
  return not vim.tbl_isempty(live[buf] or {})
end

---Remove the images that were not placed during this cycle.
function M.end_frame(buf)
  local entries = live[buf]
  if not entries then
    return
  end
  for key, entry in pairs(entries) do
    if not entry.used then
      pcall(function()
        entry.obj:clear()
      end)
      entries[key] = nil
    end
  end
end

function M.clear(buf)
  for key, entry in pairs(live[buf] or {}) do
    pcall(function()
      entry.obj:clear()
    end)
    live[buf][key] = nil
  end
  live[buf] = nil
end

function M.clear_all()
  for buf in pairs(live) do
    M.clear(buf)
  end
end

---Images currently placed in a buffer: { key = { path, y, offset } }.
---Exposed for `:checkhealth` and tests.
function M.placed(buf)
  local out = {}
  for key, entry in pairs(live[buf] or {}) do
    out[key] = {
      path = entry.path,
      y = entry.obj and entry.obj.geometry and entry.obj.geometry.y,
      offset = entry.obj and entry.obj.render_offset_top,
      width = entry.obj and entry.obj.geometry and entry.obj.geometry.width,
      height = entry.obj and entry.obj.geometry and entry.obj.geometry.height,
    }
  end
  return out
end

return M
