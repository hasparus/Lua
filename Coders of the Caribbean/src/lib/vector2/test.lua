require 'src.lib.vector2.vector2'

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

Vector2Test.execute = function()
  print('Running Vector2 tests: ')
  for i, v in ipairs(simpleTests) do
    load('res = ' .. v)()
    print(string.format('| %3d | ', i),
      string.format('%60s', v),
      '~~>', res)
  end

  for i, fun in ipairs(complexTests) do
    fun()
  end
end

return Vector2Test