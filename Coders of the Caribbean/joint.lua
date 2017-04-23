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
    if type(k) == 'string' and k:match('^__') then
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

log = function(s)
  if type(s) == 'table' then 
    if not s.__type then
      io.stderr:write(tostring(Object.new(s)))
    else
      io.stderr:write(tostring(s))
    end
  else
    io.stderr:write(tostring(s))
  end
  io.stderr:write('\n')
end

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

mt.vector2.__mul = function(v, a)
  if type(a) == 'number' then
    return Vector2(a * v.x, a * v.y)
  elseif type(a) == 'table' and a.__type == 'vector2' then
    return v:dotProduct(a)
  end
  error("__mul wrong params")
end

mt.vector2.__eq = function(v, u)
  return v.x == u.x and v.y == u.y
end
--]]



PriorityQueue = (function() 
  -- Copyright (c) 2007-2011 Incremental IP Limited.

  --[[
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  --]]


  -- heap construction ---------------------------------------------------------

  local heap = {}
  heap.__index = heap

  local function default_comparison(k1, k2)
    return k1 < k2
  end

  function heap:new(comparison)
    log("_______________ HEAP NEW CALLED")
    return setmetatable(
      { length = 0, comparison = comparison or default_comparison }, self)
  end

  -- info ----------------------------------------------------------------------

  function heap:next_key()
    assert(self.length > 0, "The heap is empty")
    return self[1].key
  end

  function heap:empty()
    return self.length == 0
  end

  -- insertion and popping -----------------------------------------------------

  function heap:insert(k, v)
    assert(k, "You can't insert nil into a heap")

    local cmp = self.comparison

    -- float the new key up from the bottom of the heap
    self.length = self.length + 1
    local new_record = self[self.length]  -- keep the old table to save garbage
    local child_index = self.length
    while child_index > 1 do
      local parent_index = math.floor(child_index / 2)
      local parent_rec = self[parent_index]
      if cmp(k, parent_rec.key) then
        self[child_index] = parent_rec
      else
        break
      end
      child_index = parent_index
    end
    if new_record then
      new_record.key = k
      new_record.value = v
    else
      new_record = {key = k, value = v}
    end
    self[child_index] = new_record
  end


  function heap:pop()
    assert(self.length > 0, "The heap is empty")

    local cmp = self.comparison

    -- pop the top of the heap
    local result = self[1]

    -- push the last element in the heap down from the top
    local last = self[self.length]
    local last_key = (last and last.key) or nil
    -- keep the old record around to save on garbage
    self[self.length] = self[1]
    self.length = self.length - 1

    local parent_index = 1
    while parent_index * 2 <= self.length do
      local child_index = parent_index * 2
      if child_index+1 <= self.length and
        cmp(self[child_index+1].key, self[child_index].key) then
        child_index = child_index + 1
      end
      local child_rec = self[child_index]
      local child_key = child_rec.key
      if cmp(last_key, child_key) then
        break
      else
        self[parent_index] = child_rec
        parent_index = child_index
      end
    end
    self[parent_index] = last
    return result.key, result.value
  end


  -- checking ------------------------------------------------------------------

  function heap:check()
    local cmp = self.comparison
    local i = 1
    while true do
      if i*2 > self.length then return true end
      if cmp(self[i*2].key, self[i].key) then return false end
      if i*2+1 > self.length then return true end
      if cmp(self[i*2+1].key, self[i].key) then return false end
      i = i + 1
    end
  end

  -- pretty printing -----------------------------------------------------------

  function heap:write(f, tostring_func)
    f = f or io.stdout
    tostring_func = tostring_func or tostring

    local function write_node(lines, i, level, end_spaces)
      if self.length < 1 then return 0 end

      i = i or 1
      level = level or 1
      end_spaces = end_spaces or 0
      lines[level] = lines[level] or ""

      local my_string = tostring_func(self[i].key)

      local left_child_index = i * 2
      local left_spaces, right_spaces = 0, 0
      if left_child_index <= self.length then
        left_spaces = write_node(lines, left_child_index, level+1, my_string:len())
      end
      if left_child_index + 1 <= self.length then
        right_spaces = write_node(lines, left_child_index + 1, level+1, end_spaces)
      end
      lines[level] = lines[level]..string.rep(' ', left_spaces)..
                    my_string..string.rep(' ', right_spaces + end_spaces)
      return left_spaces + my_string:len() + right_spaces
    end

    local lines = {}
    write_node(lines)
    for _, l in ipairs(lines) do
      f:write(l, '\n')
    end
  end


  ------------------------------------------------------------------------------

  return heap

  ------------------------------------------------------------------------------
  end 
)()
function astar(origin, goal, nodeCost, heuristic, neighbors)

  local frontier = PriorityQueue:new()
  frontier:insert(0, origin)
  log('origin: ' .. origin)

  local cameFrom = Object.new { [origin] = 'NONE' }
  local costSoFar = Object.new { [origin] = 0 }

  local _; local current

  while not frontier:empty() do
    _, current = frontier:pop()


    log("current ?= goal")
    log(current)
    log(goal)
    if current == goal then break end

    for _, next in pairs(neighbors(current)) do
      log(costSoFar)
      log(costSoFar[current])
      log(nodeCost(current, next))
      local newCost = costSoFar[current] + nodeCost(current, next)
      if (not costSoFar[next]) or newCost < costSoFar[next] then
        costSoFar[next] = newCost
        local priority = newCost + heuristic(goal, next)
        frontier:insert(priority, next)
        cameFrom[next] = current
      end
    end
  end

  local path = {}; local pathlen = 0
  while current ~= origin do
    pathlen = pathlen + 1
    path[pathlen] = current
    current = cameFrom[current]
  end
  path.len = pathlen
  return path
end
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

function findClosest(toWhom, collection) --[[go to closest barrel]]
  local closest = { id = -1, dist = 9999 }
  for id, dist in 
    pairs(map(function(x) return x.pos:distance(toWhom.pos) end, collection)) do
    if dist <= closest.dist then
      closest.dist = dist
      closest.id = id
    end
  end
  return closest
end

      
-----------------------------------------------------------
local cannonballCooldown = {}
setmetatable(cannonballCooldown, {__index = function (t, k)
    log(k)
    return 0
  end
})
-----------------------------------------------------------
 
 
local directions = {
  even = {
    --[[right]]     [0] = Vector2(1, 0),
    --[[top-right]] [1] = Vector2(0, -1),
    --[[top-left]]  [2] = Vector2(-1, -1),
    --[[left]]      [3] = Vector2(-1, 0),
    --[[bot-left]]  [4] = Vector2(-1, 1),
    --[[bot-right]] [5] = Vector2(0, 1)
  },
  odd = {
    --[[right]]     [0] = Vector2(1, 0),
    --[[top-right]] [1] = Vector2(1, -1),
    --[[top-left]]  [2] = Vector2(0, -1),
    --[[left]]      [3] = Vector2(-1, 0),
    --[[bot-left]]  [4] = Vector2(0, 1),
    --[[bot-right]] [5] = Vector2(1 ,1) 
  }
}
local nextPos = function (--[[Entity]] ship)
    local t
    if ship.pos.y % 2 == 0 then t = directions.even
    else t = directions.odd end

    log('---------------- <>')
    log(ship.rotation)
    log(t[ship.rotation])
    log(ship.speed)
    log(t[ship.rotation] * ship.speed)
    log(ship.pos)
    
    return t[ship.rotation] * (ship.speed * 3) + ship.pos
end

function neighbors(v)
  local t
  if v.y % 2 == 0 then t = directions.even
  else t = directions.odd end

  return map(function(x) return v + x end, t)
end

function move(ship, goal, nodeCost)
  local path = astar(ship.pos,
                     goal,
                     nodeCost,
                     Vector2.distance,
                     neighbors)

  --todo: port starboard
  local nextMove = path[path.len]
  print('MOVE %d %d' % 
    {nextMove.x, nextMove.y})              
end
    
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
    local barrels_count = 0

    local nodeCost = {}
    
    for i = 1, entityCount do
        local next_token = string.gmatch(io.read(), "[^%s]+")
        entity = Entity.new {}

        entity.id = tonumber(next_token())
        entity.type = next_token()
        x = tonumber(next_token())
        y = tonumber(next_token())
        entity.pos = Vector2(x, y)
        
        log(entity.type)
        if entity.type == 'SHIP' then
          entity.rotation, -- rotation [0, 5]
          entity.speed, -- speed [0, 2]
          entity.rumStock, -- rumStock
          entity.faction = read4(next_token) -- faction { 1 -- mine, 0 -- enemy}
          if entity.faction == 1 then myShips[entity.id] = entity
          else enemies[entity.id] = entity end
          
          if (cannonballCooldown[entity.id] > 0) then 
            cannonballCooldown[entity.id] = cannonballCooldown[entity.id] - 1
          end

        elseif entity.type == 'BARREL' then
          entity.rumAmount = read4(next_token)
          barrels[entity.id] = entity
          barrels_count = barrels_count + 1

        elseif entity.type == 'CANNONBALL' then
          entity.shooterid,
          entity.turnsToImpact = read4(next_token) 
          -- 1 means cannonball will hit at the end of current turn

          if entity.turnsToImpact == 1 then
            nodeCost[entity.pos.x + entity.pos.y * 24] = 700
            for _, n in pairs(neighbors(entity.pos)) do
              nodeCost[n.x + n.y * 24] = 700
            end
          end

        elseif entity.type == 'MINE' then
          read4(next_token)
          nodeCost[entity.pos.x + entity.pos.y * 24] = 999
        end
        log('entities[' .. entity.id .. ']: ' .. entity)
        entities[entity.id] = entity
    end

    log 'end reading data'
    log (myShips)

    for id, ship in pairs(myShips) do
      
      local closestEnemyPair = findClosest(ship, enemies)
      local closestEnemy = enemies[closestEnemyPair.id]
      log(Object.new(closestEnemyPair))
      log(Object.new(enemies[closestEnemyPair.id]))
      log(enemies[closestEnemyPair.id].pos:distance(ship.pos))
      local enemyNear = 
        barrels_count < 1 or 
        closestEnemy.pos:distance(ship.pos) < 8
      log(enemyNear)
      if enemyNear and cannonballCooldown[id] == 0 then
        log('barrels; ' .. barrels_count)
        log('bout to fire')
        -- this time just fire on his position
        cannonballCooldown[id] = 4
        
        local nextEnemyPos = nextPos(closestEnemy)
        
        print('FIRE %d %d' % {
            nextEnemyPos.x, 
            nextEnemyPos.y
        })
        goto continue
      end

      if barrels_count > 0 then
        local closestBarrel = findClosest(ship, barrels)
        log("MOVING: ")
        move(ship, barrels[closestBarrel.id].pos, 
          function(edgestart, edgeend) --[[nodecost]]
            return nodeCost[edgeend.x + 24 * edgeend.y] or 1
          end)
        goto continue
      end

      log('end')
      print('MINE')
      ::continue::
    end  
  end
end

agent()