require('past04')

local function chain(...)
  return function(a, i)
    i[2] = i[2] + 1
    while i[2] > #a[ i[1] ] do
      i[1] = i[1] + 1
      i[2] = 1

      if a[ i[1] ] == nil then
        return
      end
    end
    return i, a[ i[1] ][ i[2] ]
  end, table.pack(...), {1, 0}
end

local function chainNoKey(...)
  return function(state)
    local a = state[1]
    local i = state[2]

    i[2] = i[2] + 1
    while i[2] > #a[ i[1] ] do
      i[1] = i[1] + 1
      i[2] = 1

      if a[ i[1] ] == nil then
        return
      end
    end
    return a[ i[1] ][ i[2] ]
  end, {table.pack(...), {1, 0}}
end

local zip = function(...)
  return function(arrs, i)
    local res = {}
    for j = 1, arrs.n do
      local v = arrs[j][i]
      if v == nil then return end
      res[j] = v
    end
    return i + 1, res
  end, table.pack(...), 1
end

local zipNoKey = function(...)
  return function(state)
    local arrs = state[1]
    local i = state[2]
    
    local res = {}
    for j = 1, arrs.n do
      local v = arrs[j][i]
      if v == nil then return end
      res[j] = v
    end
    state[2] = i + 1
    return res
  end, {table.pack(...), 1}
end