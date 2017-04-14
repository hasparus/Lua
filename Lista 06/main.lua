require 'past05'
local frac = require 'frac'
local vector = require 'vector'


frac.example()
frac.exampleGiven()
frac.exampleExercise3()

--[[
print('\nvector:')
print ( vector {1 ,2 ,3} * 2 == 2 * vector {1 ,2 ,3}) --> true
print ( vector {3 , 4 , 5 , 6}[3]) --> 5
for k , v in ipairs ( vector {2 ,2 ,3}) do print (k , ' -> ', v ) end

print ( vector {1 ,2 ,3} + vector { -2 ,0 ,4}) --> ( -1 ,2 ,7)
print ( vector {1 ,2 ,3} * 2) --> (2 , 4 , 6)
print ( vector {1 ,2 ,3} * vector {2 , 2 , -1}) --> 3
print ( vector {4 , 3})
--]]