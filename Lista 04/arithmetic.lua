require('past01')

testCase1 = '- 2+ 4.503'

function valid_aexp(str)
  
end

--parsuję też takie poniżej
local example = -.523
local numberPattern = '%s*%-?%s*%d*%.?%d+%s*'
local validNumber = '^%s*%-?%s*%d*%.?%d+%s*$'
local validNumbers = '[(^%s*%-?%s*%d*%.?%d+%s*$)]*'
local aExp = '(%b())'

local numberOrBraces = '%s*%-?%s*%d*%.?%d+%s*'

local operation = numberOrBraces .. '[-+*/]' .. numberOrBraces

--[[
for i, v in pairs(
  {' 12', '12.65 ', '12..521', '7.34', '12 . 12',
   '.25', '- 1.15', '-.', ' - .1', '-.25',
   '', '12 13.25', '11.11.11 32 ,32'}
) do
  print(v, '   -> ', v:match(validNumber), ' --> ',
            v:match(validNumbers))
end
--]]

function iter2array(...)
  local i = 1
  local array = {}
  for v in ... do
    array[i] = v
    i = i + 1
  end
  return array
end

for i, v in pairs({ '(2 + 4)(7)', '2 * (6/5)'
}) do
  print(v, '  -> ', iter2array(v:gmatch(aExp)))
end

for i, v in pairs({ ' (6)', '5/2'
}) do
  print(v, '  -> ', iter2array(v:gmatch(
    numberPattern
  )))
end

for i, v in pairs({ '(2 + 4)(7)', '2 * (-6/.25)'
}) do
  print(v, '  -> ', iter2array(v:gmatch(
    operation
  )))
end