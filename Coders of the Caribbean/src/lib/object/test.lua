require 'src.lib.object.object'
CraterTest = require 'src.lib.crater_test.crater_test'

local simpleTests = {
  [[ Object.new{name = 'o1', value = 17} ]],
  {[[ Object.new{name = 'o1', value = 17}['name'] ]], {shouldBe = 'o1'}},
  {[[ Object.new{name = 'o1', value = 17}.value ]], {shouldBe = 17}},
  {[[ Object{k = '12'}['k'] ]], {shouldBe = '12'}},
  [[ tostring(Object{k = '12', x = 5, __showAllKeys = true}) ]],
  {[[ Object{k = '12', x = 5}.__type ]], {shouldBe = 'object'}},
  {[[ Object{k = '12', x = 5} ]], }
}

local complexTests = {
  function() 
    local o1 = Object.new{name = 'o1', value = 17}
    local o2 = Object{name = 'o2', value = 25}
  end,
}

return CraterTest.new('Object', simpleTests, complexTests)