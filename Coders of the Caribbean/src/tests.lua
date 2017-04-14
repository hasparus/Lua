require 'object'

function tests()
  local o1 = Object.new {u = 7}
  local o2 = Object.new {k = 12, b = 5, c = '73'}
  log(o1)
end