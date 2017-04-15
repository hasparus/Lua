require 'src.lib.vector2.vector2'
CraterTest = require 'src.lib.crater_test.crater_test'

local Vector2Test = {}

local simpleTests = {
  [[ Vector2.new(5, 7) ]],
  [[ Vector2.new(5, 7).y ]],
  [[ Vector2(5, 7).x ]],
  [[ Vector2(2, 1) + Vector2(3,2)]],
  [[ Vector2(3, 4):magnitude() ]],
  [[ Vector2(-7, 6):magnitude() ]],
  {[[ Vector2(3, 4):distance(Vector2(-7, 6)) ]], {shouldBe = 10.198039}}
}

local complexTests = {
  function() 

  end,
}

return CraterTest.new('Vector2', simpleTests, complexTests)