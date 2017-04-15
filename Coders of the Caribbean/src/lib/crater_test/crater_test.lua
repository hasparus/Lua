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

local check = function(res, conditions)
  local accu
  local passed = true

  for _, fun in ipairs({
    function()
      accu = conditions.shouldBe
      return not accu or (res == accu)
    end
  }) do
    passed = passed and fun()
  end
  
  if passed then return '\x1b[32m PASSED \x1b[0m' 
  else return '\x1b[31m FAILED \x1b[0m' end 
end

CraterTest.execute = function(self)
  print([[
~.~^~.~^~.~^~.~^~.~^~.~^~.~^~.~  
Running %s tests:
_______________________________]] % self.name)

  for i, v in ipairs(self.simpleTests) do
    local case = ''
    local conditions = {}
    if type(v) == 'string' then
      case = v
    elseif type(v) == 'table' then
      case = v[0]
      conditions = v[1]
    end
    load('res = ' .. v)()
    print('\x1b[36m | %3d | \x1b[0m' % i .. check(res, conditions),
          string.format('%60s', v),
          '\x1b[36m ~~> \x1b[0m', 
          res)
  end

  for i, fun in ipairs(self.complexTests) do
    fun()
  end
end 

return CraterTest