---Minimal JSON encoder that mimics `json.dumps(nb, indent=1, sort_keys=True)`,
---i.e. exactly what nbformat writes, so notebooks saved by jupynb stay
---diff-friendly against notebooks saved by Jupyter or VSCode.
local M = {}

local EMPTY_DICT_MT = getmetatable(vim.empty_dict())

local ESCAPES = {
  ['"'] = '\\"',
  ["\\"] = "\\\\",
  ["\b"] = "\\b",
  ["\f"] = "\\f",
  ["\n"] = "\\n",
  ["\r"] = "\\r",
  ["\t"] = "\\t",
}

local function encode_string(s)
  local out = s:gsub('[%z\1-\31\\"]', function(ch)
    return ESCAPES[ch] or string.format("\\u%04x", ch:byte())
  end)
  return '"' .. out .. '"'
end

local function encode_number(n)
  if n ~= n or n == math.huge or n == -math.huge then
    return "null"
  end
  if math.type and math.type(n) == "integer" then
    return string.format("%d", n)
  end
  if n == math.floor(n) and math.abs(n) < 2 ^ 53 then
    return string.format("%d", n)
  end
  return (string.format("%.17g", n))
end

local function is_array(t)
  if vim.islist(t) then
    return #t > 0 or getmetatable(t) ~= EMPTY_DICT_MT
  end
  return false
end

local function sorted_keys(t)
  local keys = {}
  for k in pairs(t) do
    keys[#keys + 1] = tostring(k)
  end
  table.sort(keys)
  return keys
end

local function encode(value, indent, out)
  local t = type(value)
  if value == nil or value == vim.NIL then
    out[#out + 1] = "null"
  elseif t == "boolean" then
    out[#out + 1] = tostring(value)
  elseif t == "number" then
    out[#out + 1] = encode_number(value)
  elseif t == "string" then
    out[#out + 1] = encode_string(value)
  elseif t == "table" then
    local pad = string.rep(" ", indent + 1)
    local endpad = string.rep(" ", indent)
    if is_array(value) then
      if #value == 0 then
        out[#out + 1] = "[]"
        return
      end
      out[#out + 1] = "[\n"
      for i, item in ipairs(value) do
        out[#out + 1] = pad
        encode(item, indent + 1, out)
        out[#out + 1] = (i < #value) and ",\n" or "\n"
      end
      out[#out + 1] = endpad .. "]"
    else
      local keys = sorted_keys(value)
      if #keys == 0 then
        out[#out + 1] = "{}"
        return
      end
      out[#out + 1] = "{\n"
      for i, key in ipairs(keys) do
        out[#out + 1] = pad .. encode_string(key) .. ": "
        encode(value[key], indent + 1, out)
        out[#out + 1] = (i < #keys) and ",\n" or "\n"
      end
      out[#out + 1] = endpad .. "}"
    end
  else
    out[#out + 1] = "null"
  end
end

---@param value any
---@return string
function M.encode(value)
  local out = {}
  encode(value, 0, out)
  return table.concat(out)
end

---@param str string
---@return table|nil, string|nil
function M.decode(str)
  local ok, res = pcall(vim.json.decode, str, { luanil = { object = true, array = true } })
  if not ok then
    return nil, tostring(res)
  end
  return res, nil
end

return M
