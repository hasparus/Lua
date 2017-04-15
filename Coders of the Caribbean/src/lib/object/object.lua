Object = {}

if mt == nil then mt = {} end

---[[ Initializing tables.
mt.Object = {}
mt.object = {}
mt.object.__index = Object
setmetatable(Object, mt.Object)
--]]

---[[ Factory function and constructor syntax:
function Object.new(args)
  local self = {}
  for k, v in pairs(args) do
    self[k] = v
  end
  setmetatable(self, mt.object)
  return self
end

mt.Object.__call = function(table, ...) return table.new(...) end
--]]

---[[ __tostring and __concat
mt.object.__tostring = function(obj)
  local res = {}
  local n = 0
  for k, v in pairs(obj) do
    n = n + 1
    local vstring
    if (type(v) == type('string')) then
      vstring = "'" .. v .. "'"
    else
      vstring = tostring(v)
    end
    res[n] = tostring(k) .. ' = ' .. vstring
  end
  return '{ ' .. table.concat(res, ', ') .. ' }'
end

mt.object.__concat = function(a, b)
  return tostring(a) .. tostring(b)
end
--]]


