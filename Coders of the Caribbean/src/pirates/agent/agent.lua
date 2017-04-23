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