---Turn nbformat outputs into virtual lines drawn below a cell.
local M = {}

local util = require("jupynb.util")
local config = require("jupynb.config")

local IMAGE_MIMES = { "image/png", "image/jpeg", "image/gif", "image/webp" }

local TEXT_MIMES = {
  "text/plain",
  "text/markdown",
  "application/json",
  "text/html",
}

local function pad(n)
  return string.rep(" ", n)
end

---@return string|nil mime, table|string value
local function pick_image(data)
  if not data then
    return nil
  end
  for _, mime in ipairs(IMAGE_MIMES) do
    if data[mime] then
      return mime, data[mime]
    end
  end
end

local function pick_text(data)
  if not data then
    return nil
  end
  for _, mime in ipairs(TEXT_MIMES) do
    local value = data[mime]
    if value ~= nil then
      if type(value) == "table" then
        if vim.islist(value) then
          value = table.concat(value, "")
        else
          value = vim.inspect(value)
        end
      end
      if mime == "text/html" then
        -- Only useful as a last resort: strip the markup.
        value = value:gsub("<[^>]->", " "):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&")
        value = value:gsub("[ \t]+", " "):gsub("\n%s*\n+", "\n")
      end
      return mime, value
    end
  end
end

---Path on disk for an image payload (kernel output or notebook attachment).
---@return string|nil path, integer|nil width, integer|nil height
function M.image_path(value, mime)
  if type(value) == "table" and value._jupynb_path then
    return value._jupynb_path, value.width, value.height
  end
  if type(value) == "string" then
    -- base64 payload coming from the .ipynb file: materialise it once
    local ext = mime and mime:match("/(%w+)") or "png"
    if ext == "jpeg" then
      ext = "jpg"
    end
    local dir = vim.fn.stdpath("cache") .. "/jupynb"
    vim.fn.mkdir(dir, "p")
    local name = string.format("%s/%s.%s", dir, vim.fn.sha256(value):sub(1, 16), ext)
    if vim.fn.filereadable(name) == 0 then
      local raw = vim.base64.decode((value:gsub("%s", "")))
      local fd = io.open(name, "wb")
      if not fd then
        return nil
      end
      fd:write(raw)
      fd:close()
    end
    return name
  end
end

---Build the virtual lines for one cell.
---@param cell table
---@return table[] virt_lines, table[] images  images = { {path, row, width, height} }
function M.render(cell)
  local cfg = config.get().ui
  local icons = cfg.icons
  local vlines = {}
  local images = {}
  local truncated = 0

  local function add(chunks)
    if #vlines >= cfg.max_output_lines then
      truncated = truncated + 1
      return
    end
    vlines[#vlines + 1] = chunks
  end

  local function add_text(text, hl, border_hl)
    border_hl = border_hl or "JupynbOutBorder"
    for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
      add({
        { pad(2) },
        { icons.out .. " ", border_hl },
        { util.sanitize(line, cfg.max_output_width), hl },
      })
    end
  end

  ---ANSI has to be parsed before sanitising, otherwise the escape bytes are
  ---stripped and their parameters end up as literal text.
  local function add_ansi(text, default_hl, border_hl)
    for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
      local chunks = { { pad(2) }, { icons.out .. " ", border_hl or "JupynbOutBorder" } }
      local width = 0
      for _, chunk in ipairs(util.ansi_chunks(line, default_hl)) do
        local piece = util.sanitize(chunk[1])
        if piece ~= "" and width < cfg.max_output_width then
          local w = vim.fn.strdisplaywidth(piece)
          if width + w > cfg.max_output_width then
            piece = vim.fn.strcharpart(piece, 0, cfg.max_output_width - width) .. "…"
          end
          width = width + w
          chunks[#chunks + 1] = { piece, chunk[2] }
        end
      end
      add(chunks)
    end
  end

  for _, output in ipairs(cell.outputs or {}) do
    local kind = output.output_type
    if kind == "stream" then
      local text = output.text
      if type(text) == "table" then
        text = table.concat(text, "")
      end
      text = (text or ""):gsub("\n$", "")
      local hl = output.name == "stderr" and "JupynbOutStderr" or "JupynbOutText"
      add_text(text, hl)
    elseif kind == "error" then
      local tb = output.traceback or {}
      if #tb == 0 then
        add({
          { pad(2) },
          { icons.out .. " ", "JupynbOutErrBorder" },
          {
            util.sanitize(string.format("%s: %s", output.ename or "Error", output.evalue or ""), cfg.max_output_width),
            "JupynbOutErrName",
          },
        })
      end
      for _, frame in ipairs(tb) do
        -- IPython opens the traceback with a row of dashes: pure noise here
        if not util.strip_ansi(frame):match("^%-+%s*$") then
          add_ansi(frame:gsub("\n$", ""), "JupynbOutErrText", "JupynbOutErrBorder")
        end
      end
    elseif kind == "execute_result" or kind == "display_data" then
      local mime, value = pick_image(output.data)
      local handled = false
      if mime then
        local image = require("jupynb.image")
        local path, w, h = M.image_path(value, mime)
        if path and not w then
          w, h = image.probe_size(path)
        end
        local images_on = config.get().images.enabled and image.available()
        if path and images_on then
          local rows, cols = image.size_in_cells(w, h)
          local anchor = #vlines
          for _ = 1, rows do
            add({ { pad(2) }, { icons.out .. " ", "JupynbOutBorder" }, { pad(cols) } })
          end
          images[#images + 1] = { path = path, offset = anchor, rows = rows, cols = cols }
          handled = true
        elseif path then
          image.warn_blocked() -- says why, once per session
          local label = string.format("%s %s", icons.image, mime)
          if w and h then
            label = string.format("%s %s  %d×%d", icons.image, mime, w, h)
          end
          add({
            { pad(2) },
            { icons.out .. " ", "JupynbOutBorder" },
            { label, "JupynbOutImage" },
          })
          handled = true
        end
      end
      if not handled then
        local tmime, text = pick_text(output.data)
        if text then
          local hl = (tmime == "text/markdown") and "JupynbOutLabel" or "JupynbOutText"
          add_text((text:gsub("\n$", "")), hl)
        end
      end
    end
  end

  if truncated > 0 then
    vlines[#vlines + 1] = {
      { pad(2) },
      { icons.out .. " ", "JupynbOutBorder" },
      { string.format("… %d more lines (%s to open)", truncated, ":Jupynb output"), "JupynbOutMore" },
    }
  end

  if #vlines > 0 then
    vlines[#vlines + 1] = { { "" } }
  end

  return vlines, images
end

---Plain text version of the outputs, for `:Jupynb output`.
---@return string[]
function M.as_text(cell)
  local lines = {}
  for _, output in ipairs(cell.outputs or {}) do
    local kind = output.output_type
    if kind == "stream" then
      local text = output.text
      if type(text) == "table" then
        text = table.concat(text, "")
      end
      vim.list_extend(lines, vim.split((text or ""):gsub("\n$", ""), "\n", { plain = true }))
    elseif kind == "error" then
      for _, line in ipairs(output.traceback or {}) do
        vim.list_extend(lines, vim.split(util.strip_ansi(line), "\n", { plain = true }))
      end
    else
      local mime, value = pick_image(output.data)
      if mime then
        local path = M.image_path(value, mime)
        lines[#lines + 1] = string.format("[%s] %s", mime, path or "")
      end
      local _, text = pick_text(output.data)
      if text then
        vim.list_extend(lines, vim.split(text:gsub("\n$", ""), "\n", { plain = true }))
      end
    end
  end
  return lines
end

---Append an output to a cell, merging consecutive streams like Jupyter does.
function M.append(cell, output)
  cell.outputs = cell.outputs or {}
  local last = cell.outputs[#cell.outputs]
  if
    output.output_type == "stream"
    and last
    and last.output_type == "stream"
    and last.name == output.name
    and type(last.text) == "string"
  then
    last.text = last.text .. (output.text or "")
    return
  end
  cell.outputs[#cell.outputs + 1] = output
end

return M
