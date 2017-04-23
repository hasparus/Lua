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