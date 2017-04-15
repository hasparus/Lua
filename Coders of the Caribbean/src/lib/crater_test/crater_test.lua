require 'src.lib.object.object'
require 'src.lib.console_color'

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
    return Console.Colorize('white', 'PASSED')
  end

  local accu
  local passed = true

  for _, fun in ipairs({
    function()
      accu = conditions.shouldBe
      return not accu or
        math.type(res) == 'float' and math.abs(res - accu) < 0.000001 or
        res == accu 
    end
  }) do
    passed = passed and fun()
  end
  
  if passed then 
    return Console.Colorize('green', 'PASSED')
  else 
    return Console.Colorize('red', 'FAILED')
  end 
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
  print(Console.Colorize('white', ' | %3d | ' % i) 
          .. passed,
        '%60s' % case,
        Console.Colorize('cyan', ' ~~> '), 
        res)
  if conditions ~= nil and not passed then
    print(Console.Colorize('white', ' | --> | ') ..
          Console.Colorize('yellow', tostring(Object.new(conditions, {notype = true}))))
  end
end

CraterTest.execute = function(self)
  print(Console.Colorize('gray', [[
~.~^~.~^~.~^~.~^~.~^~.~^~.~^~.~  
Running %s tests:
_______________________________]] % 
  Console.Colorize('pink', self.name)))

  for i, v in ipairs(self.simpleTests) do
    doSimpleTest(i, v)
  end

  for i, fun in ipairs(self.complexTests) do
    fun()
  end
end 

return CraterTest