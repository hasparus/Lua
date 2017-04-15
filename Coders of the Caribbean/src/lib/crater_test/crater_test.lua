require 'src.lib.object.object'

local CraterTest = declareClass('CraterTest', Object)

CraterTest.new = function(name, simpleTests, complexTests) 
  local self = {}
  self.name = name
  self.simpleTests = simpleTests
  self.complexTests = complexTests
  setindirectmetatable(self, mt.craterTest)
  return self
end

CraterTest.execute = function(self)
  print([[
~.~^~.~^~.~^~.~^~.~^~.~^~.~^~.~  
Running %s tests:
_______________________________]] % self.name)

  for i, v in ipairs(self.simpleTests) do
    load('res = ' .. v)()
    print(string.format('| %3d | ', i),
          string.format('%60s', v),
          '~~>', 
          res)
  end

  for i, fun in ipairs(self.complexTests) do
    fun()
  end
end 

return CraterTest