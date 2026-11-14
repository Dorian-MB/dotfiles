---Reading and writing `.ipynb` files (nbformat 4).
local M = {}

local json = require("jupynb.json")
local util = require("jupynb.util")

local KINDS = { code = true, markdown = true, raw = true }

---@return table nb
function M.empty(lang)
  lang = lang or "python"
  return {
    cells = {},
    metadata = {
      kernelspec = {
        display_name = "Python 3 (ipykernel)",
        language = lang,
        name = "python3",
      },
      language_info = { name = lang },
    },
    nbformat = 4,
    nbformat_minor = 5,
  }
end

---Normalise a decoded notebook so the rest of the plugin can rely on it.
function M.normalize(nb)
  nb = nb or {}
  nb.nbformat = nb.nbformat or 4
  nb.nbformat_minor = nb.nbformat_minor or 5
  nb.metadata = nb.metadata or {}
  nb.cells = nb.cells or {}
  for _, cell in ipairs(nb.cells) do
    if not KINDS[cell.cell_type] then
      cell.cell_type = "raw"
    end
    if cell.cell_type == "code" then
      cell.outputs = cell.outputs or {}
    end
  end
  return nb
end

---@param path string
---@return table|nil nb, string|nil err
function M.load(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil, "cannot open " .. path
  end
  local content = fd:read("*a")
  fd:close()
  if content == nil or content:match("^%s*$") then
    return M.normalize(M.empty()), nil
  end
  local nb, err = json.decode(content)
  if not nb then
    return nil, "invalid JSON: " .. tostring(err)
  end
  if type(nb) ~= "table" or nb.cells == nil then
    return nil, "not a Jupyter notebook (no `cells` key)"
  end
  return M.normalize(nb), nil
end

---@param path string
---@param nb table
---@return boolean ok, string|nil err
function M.save(path, nb)
  local ok, encoded = pcall(json.encode, nb)
  if not ok then
    return false, "encode failed: " .. tostring(encoded)
  end
  -- write next to the target then rename: a failed write never truncates the notebook
  path = vim.uv.fs_realpath(path) or path -- rename must not replace a symlink
  local tmp = path .. ".jupynb-tmp"
  local fd, oerr = io.open(tmp, "w")
  if not fd then
    return false, tostring(oerr)
  end
  local wok, werr = fd:write(encoded, "\n")
  local cok, cerr = fd:close()
  if not (wok and cok) then
    os.remove(tmp)
    return false, tostring(werr or cerr)
  end
  local rok, rerr = os.rename(tmp, path)
  if not rok then
    os.remove(tmp)
    return false, tostring(rerr)
  end
  return true, nil
end

---Language of the notebook, from its metadata.
function M.language(nb)
  local md = nb and nb.metadata or {}
  local ks = md.kernelspec or {}
  local li = md.language_info or {}
  return ks.language or li.name or "python"
end

function M.kernel_name(nb)
  local ks = (nb and nb.metadata or {}).kernelspec or {}
  return ks.name
end

---Build the nbformat cell list out of the plugin's cell model.
---@param cells table[] plugin cells (kind, source_lines, outputs, ...)
---@param nb table original notebook (metadata is preserved)
---@param opts table|nil { strip_outputs = boolean }
function M.to_nb(cells, nb, opts)
  opts = opts or {}
  local out = vim.deepcopy(nb or M.empty())
  local minor = out.nbformat_minor or 5
  local list = {}

  for _, cell in ipairs(cells) do
    local entry = vim.deepcopy(cell.raw or {})
    entry.cell_type = cell.kind
    entry.source = util.lines_to_source(cell.source_lines or {})
    entry.metadata = cell.metadata or vim.empty_dict()
    if minor >= 5 then
      entry.id = cell.nb_id or cell.id
    else
      entry.id = nil
    end
    if cell.kind == "code" then
      entry.execution_count = cell.exec_count or vim.NIL -- required by nbformat, null if never run
      if opts.strip_outputs then
        entry.outputs = {}
      else
        entry.outputs = M.outputs_for_disk(cell.outputs or {})
      end
    else
      entry.outputs = nil
      entry.execution_count = nil
      entry.attachments = entry.attachments
    end
    list[#list + 1] = entry
  end

  out.cells = list
  return out
end

---Images produced by a kernel live on disk while the notebook is open; they
---are inlined again (base64) when the notebook is written.
function M.outputs_for_disk(outputs)
  local out = {}
  for i, output in ipairs(outputs) do
    local copy = vim.deepcopy(output)
    copy._display_id = nil -- runtime-only, like nbformat's `transient`
    if type(copy.data) == "table" then
      for mime, value in pairs(copy.data) do
        if type(value) == "table" and value._jupynb_path then
          local fd = io.open(value._jupynb_path, "rb")
          if fd then
            local raw = fd:read("*a")
            fd:close()
            copy.data[mime] = vim.base64.encode(raw)
          else
            util.err("image lost, not saved: " .. value._jupynb_path)
            copy.data[mime] = ""
          end
        end
      end
    end
    if copy.output_type == "stream" and type(copy.text) == "string" then
      copy.text = util.lines_to_source(vim.split(copy.text, "\n", { plain = true }))
    end
    -- `data` values are stored as multi-line lists by nbformat
    if type(copy.data) == "table" then
      for mime, value in pairs(copy.data) do
        if type(value) == "string" and mime ~= "application/json" and value:find("\n") then
          copy.data[mime] = util.lines_to_source(vim.split(value, "\n", { plain = true }))
        end
      end
    end
    -- only rich outputs carry metadata; nbformat rejects it on stream/error
    if copy.output_type == "display_data" or copy.output_type == "execute_result" then
      copy.metadata = copy.metadata or vim.empty_dict()
    end
    out[i] = copy
  end
  return out
end

---Inverse normalisation: turn on-disk outputs into the in-memory shape
---(strings instead of line lists).
function M.outputs_from_disk(outputs)
  local out = {}
  for i, output in ipairs(outputs or {}) do
    local copy = vim.deepcopy(output)
    if copy.output_type == "stream" then
      copy.text = table.concat(util.source_to_lines(copy.text), "\n")
    end
    if type(copy.data) == "table" then
      for mime, value in pairs(copy.data) do
        if type(value) == "table" and not value._jupynb_path then
          -- same exception as outputs_for_disk: a JSON payload is data, not split lines
          if vim.islist(value) and mime ~= "application/json" then
            copy.data[mime] = table.concat(value, "")
          end
        end
      end
    end
    out[i] = copy
  end
  return out
end

return M
