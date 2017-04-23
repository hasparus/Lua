require 'src.lib.object.object'

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


