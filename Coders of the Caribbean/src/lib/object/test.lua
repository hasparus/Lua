require 'src.lib.object.object'

local simpleTests = {
  [[ Object.new{name = 'o1', value = 17} ]],
  [[ Object.new{name = 'o1', value = 17}['name'] ]],
  [[ Object.new{name = 'o1', value = 17}.value ]],
  [[ Object{k = '12'}['k'] ]],
  [[ tostring(Object{k = '12', x = 5}) ]]
}

local complexTests = {
  function() 
    local o1 = Object.new{name = 'o1', value = 17}
    local o2 = Object{name = 'o2', value = 25}
  end,
}

return TestExecutor.new('Object', simpleTests, complexTests)