---[[
local makeNameClassy = function(name)
  if type(name) ~= 'string' then error('wtf, wrong class name') end
  local firstLetter = name:sub(1, 1)
  local tail = name:sub(2, -1)
  return (firstLetter:upper() .. tail), (firstLetter:lower() .. tail)
end

declareClass = function(name, super)
  local className, objectName = makeNameClassy(name)
  
end
--]]


---[[ Ruby style string interpolation
getmetatable("").__mod = function(a, b)
  if not b then
    return a
  elseif type(b) == "table" then
    return string.format(a, unpack(b))
  else
    return string.format(a, b)
  end
end
--]]

---[[ Set indirect metatable. [Chain calls, lookup through __index].
local metamethods = { --no index nor newindex
  '__add', '__sub', '__mul', '__div', '__mod', '__pow', '__unm', '__concat', 
  '__len', '__eq', '__lt', '__le', '__call', '__gc', '__tostring'
}

-- kudos kikito@stackoverflow
function setindirectmetatable(t, mt) 
  for _,m in ipairs(metamethods) do
    rawset(mt, m, rawget(mt,m) or function(...)
      local supermt = getmetatable(mt) or {}
      local index = supermt.__index
      if(type(index)=='function') then return index(t,m)(...) end
      if(type(index)=='table') then return index[m](...) end
      return nil
    end)
  end

  return setmetatable(t, mt)
end
--]]

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


