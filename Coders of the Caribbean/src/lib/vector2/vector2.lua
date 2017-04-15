require 'src.lib.object.object'

Vector2 = {}

mt.Vector2 = {}
mt.Vector2.__index = Object
setmetatable(mt.Vector2, { __index = mt.Object }) 

mt.vector2 = {}
mt.vector2.__index = Vector2
setmetatable(mt.vector2, { __index = mt.object })

setindirectmetatable(Vector2, mt.Vector2)

function Vector2.new(x, y)
  local self = {}
  self.x = x
  self.y = y
  setindirectmetatable(self, mt.vector2)
  return self
end