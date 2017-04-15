log = function(...)
  io.stderr:write(...)
  io.stderr:write('\n')
end

---[[ Ruby style string interpolation
getmetatable("").__mod = function(a, b)
  if not b then
    return a
  elseif type(b) == 'table' then
    return string.format(a, table.unpack(b))
  else
    return string.format(a, b)
  end
end
--]]

---[[ print strings with quotes
tostringverbose = function(x)
  if type(x) == 'string' then
    return '"' .. x .. '"'
  end
  return tostring(x)
end
--]]

---[[ Set indirect metatable. [Chain calls, lookup through __index].
local metamethods = { --no index nor newindex
  '__add', '__sub', '__mul', '__div', '__mod', '__pow', '__unm', '__concat', 
  '__len', '__eq', '__lt', '__le', '__call', '__tostring'
}

-- kudos kikito@stackoverflow
function setindirectmetatable(t, mt) 
  for _,m in ipairs(metamethods) do
    rawset(mt, m, rawget(mt,m) or function(...)
      local supermt = getmetatable(mt) or {}
      local index = supermt.__index
      if type(index) == 'function' then return index(t,m)(...) end
      if type(index) == 'table' then return index[m](...) end
      return nil
    end)
  end

  return setmetatable(t, mt)
end
--]]

Object = { __type = 'Object' }
if mt == nil then mt = {} end

---[[ Initializing tables.
mt.Object = {}
mt.object = {}
mt.object.__index = Object
setmetatable(Object, mt.Object)
--]]

---[[ Factory function and constructor syntax:
function Object.new(args)
  local self = { __type = 'object' }
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
  local joinSpecials = false
  local res = {}
  local specials = {}
  local n = 0
  for k, v in pairs(obj) do
    local s = tostring(k) .. ' = ' .. tostringverbose(v)
    if k:match('^__') then
      specials[#specials + 1] = s
      if k == '__showAllKeys' then joinSpecials = true end
    else
      n = n + 1
      res[n] = s
    end
  end

  if joinSpecials then
    for _, v in ipairs(specials) do
      n = n + 1
      res[n] = v 
    end
  end

  return '{ ' .. table.concat(res, ', ') .. ' }'
end

mt.object.__concat = function(a, b)
  return tostring(a) .. tostring(b)
end
--]]



---[[ declareClass helper
local makeNameClassy = function(name)
  if type(name) ~= 'string' then error('wtf, wrong class name') end
  local firstLetter = name:sub(1, 1)
  local tail = name:sub(2, -1)
  return (firstLetter:upper() .. tail), (firstLetter:lower() .. tail)
end

-- usage: A = declareClass('A', 'superclassA', privateMetatable)
declareClass = function(name, super, meta)
  if super == null then
    super = Object
  end
  if meta == null then
    if type(mt) ~= 'table' then 
      error('hey, global metatable store is not present!') 
    else
      meta = mt
    end
  end

  local className, instanceName = makeNameClassy(name)
  local superClassName, superInstanceName =
    makeNameClassy(super.__type)
  local class = { __type = className }

  meta[className] = { __index = super }
  meta[instanceName] = { __index = class }
  setmetatable(meta[className], { __index = meta[superClassName] })
  setmetatable(meta[instanceName], { __index = meta[superInstanceName]})
  setindirectmetatable(class, meta[className])

  return class
end
--]]

Vector2 = declareClass('Vector2', Object)

---[[ Vector2 class functions
function Vector2.new(x, y)
  local self = { __type = 'vector2' }
  self.x = x
  self.y = y
  setindirectmetatable(self, mt.vector2)
  return self
end

function Vector2.dotProduct(v, u) -- moze tez dzialac jako self u
  return v.x * u.x + v.y * u.y
end
--]]

---[[ vector2 instance functions
function Vector2:magnitude()
  return math.sqrt(Vector2.dotProduct(self, self))
end

function Vector2:distance(u)
  return (self - u):magnitude()
end
--]]

---[[ mt.vector2 stuff
mt.vector2.__add = function(v, u)
  return Vector2(v.x + u.x, v.y + u.y)
end

mt.vector2.__unm = function(v)
  return Vector2(-v.x, -v.y)
end

mt.vector2.__sub = function(v, u)
  return v + (-u)
end
--]]



--- past

map = function(fun, tab) 
    local res = {}
    for k, v in pairs(tab) do
        res[k] = fun(v)
    end 
    return res 
end

--- new helpers

function min(x, y)
  if x < y then return x else return y end
end
local read4 = function(next) 
  local results = {}
  for i = 1, 4 do
    results[i] = tonumber(next())
  end
  return table.unpack(results)
end

Entity = declareClass('Entity', Object)

function agent()
  while true do
    local myShipsCount = tonumber(io.read()) 
    -- the number of entities (e.g. ships, mines or cannonballs)
    local entityCount = tonumber(io.read())
    log(entityCount)

    local entities = {}
    local myShips = {}
    local enemies = {}
    local barrels = {}
    
    for i = 1, entityCount do
        local next_token = string.gmatch(io.read(), "[^%s]+")
        entity = Entity.new {}

        entity.Id = tonumber(next_token())
        entity.type = next_token()
        x = tonumber(next_token())
        y = tonumber(next_token())
        entity.pos = Vector2(x, y)
        
        if entity.type == 'SHIP' then
          entity.rotation, -- rotation [0, 5]
          entity.speed, -- speed [0, 2]
          entity.rumStock, -- rumStock
          entity.faction = read4(next_token) -- faction { 1 -- mine, 0 -- enemy}
          if entity.faction == 1 then myShips[entity.Id] = entity
          else enemies[entity.Id] = entity end

        elseif entity.type == 'BARREL' then
          entity.rumAmount = read4(next_token)
          barrels[entity.Id] = entity
        end
        entities[entity.Id] = entity
    end

    for id, entity in pairs(entities) do
      log('entities[' .. id .. ']: ' .. entity)
    end

    for id, ship in pairs(myShips) do
      
      -- dla kazdego statku znajdz najblizsza beczke, plyn do niej
      local closestBarrelId = -1
      local minDist = 9999
      for id, dist in 
        pairs(map(function(x) return x.pos:distance(ship.pos) end, barrels)) do
        if dist <= minDist then
          minDist = dist
          closestBarrelId = id
        end
      end

      print('MOVE %d %d' % 
        {barrels[closestBarrelId].pos.x, barrels[closestBarrelId].pos.y})
    end  
  end
end

agent()