require 'src.lib.object.object'
require 'src.lib.console_color'

local EPSILON = 0.000001
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
  if conditions == nil then 
    return Console.colorize('white', 'PASSED')
  end

  local accu
  local passed = true

  for _, fun in ipairs({
    function()
      accu = conditions.shouldBe
      return not accu or
        math.type(res) == 'float' and math.abs(res - accu) < EPSILON or
        res == accu 
    end,
    function()
      accu = conditions.shouldntBe
      return not accu or 
        math.type(res) == 'float' and math.abs(res - accu) > EPSILON or
        res ~= accu
    end,
    function()
      accu = conditions.isNil
      return not accu or res == nil 
    end
  }) do
    passed = passed and fun()
  end
  
  return passed
end

local colorizePassed = function(x)
  return
    type(x) ~= 'boolean' and x or 
    x and Console.colorize('green', 'PASSED') or
    Console.colorize('red', 'FAILED')
end

local doSimpleTest = function(i, v)
  local case = ''
  local conditions = nil
  if type(v) == 'string' then
    case = v
  elseif type(v) == 'table' then
    case = v[1]
    conditions = v[2]
  end
  load('res = ' .. case)()
  local passed = check(res, conditions)
  print(Console.colorize('white', ' | %3d | ' % i) 
          .. colorizePassed(passed),
        '%60s' % case,
        Console.colorize('cyan', ' ~~> '), 
        tostringverbose(res))
  if conditions ~= nil and not passed then
    print(Console.colorize('white', ' | --> | ') ..
          Console.colorize('yellow', tostring(Object.new(conditions, {notype = true}))))
  end
end

CraterTest.execute = function(self)
  print(Console.colorize('gray', [[
~.~^~.~^~.~^~.~^~.~^~.~^~.~^~.~  
Running %s tests:
_______________________________]] % 
  Console.colorize('pink', self.name)))

  for i, v in ipairs(self.simpleTests) do
    doSimpleTest(i, v)
  end

  for i, fun in ipairs(self.complexTests) do
    fun()
  end
end 

return CraterTest