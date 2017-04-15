Vector2 = {}

mt.Vector2 = {}
mt.Vector2.__index = Object
setmetatable(mt.Vector2, { __index = mt.Object }) -- nie dziala
                                                  -- chciałbym odziedziczyć mt.Object.__call

mt.vector2 = {}
mt.vector2.__index = Vector2
setmetatable(mt.vector2, { __index = mt.object }) -- nie dziala

setmetatable(Vector2, mt.Vector2)

function Vector2.new(x, y)
  local self = {}
  self.x = x
  self.y = y
  setmetatable(self, mt.vector2)
  return self
end