require 'src.lib.object.object'

Vector2 = declareClass('Vector2', Object)

function Vector2.new(x, y)
  local self = { __type = 'vector2' }
  self.x = x
  self.y = y
  setindirectmetatable(self, mt.vector2)
  return self
end