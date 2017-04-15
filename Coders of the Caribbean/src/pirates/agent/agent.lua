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