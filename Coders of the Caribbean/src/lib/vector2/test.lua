require 'src.lib.vector2.vector2'
CraterTest = require 'src.lib.crater_test.crater_test'

local Vector2Test = {}

local simpleTests = {
  [[ Vector2.new(5, 7) ]],
  [[ Vector2.new(5, 7).y ]],
  [[ Vector2(5, 7).x ]]
}

local complexTests = {
  function() 

  end,
}

return CraterTest.new('Vector2', simpleTests, complexTests)