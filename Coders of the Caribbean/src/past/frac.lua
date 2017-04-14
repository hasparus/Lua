require 'past05'

--[[
  [ [ L5E2A (4pkt) ] ]
  [ [ L5E2B (2pkt) ] ]
--]]

--[[
    * Zadbaj o to, aby ułamki zawsze były trzymane w skróconej formie.
    Prosty algorytm euklidesa:
--]]
local gcd = function(x, y)
  if x == y then return x end
  if x > y then x, y = y, x end
  while x ~= 0 do x, y = y % x, x end
  return y
end

local shortenFrac = function(frac)
  local g = gcd(frac.a, frac.b)
  local a = frac.a // g
  local b = frac.b // g
  if a | b < 0 and a & b >= 0 then
    a = -math.abs(a)
    b = math.abs(b)
  end
  rawset(frac, 'a', a)
  rawset(frac, 'b', b)
end

-- [ [ Frac ] ] ---------------------------------->
local Frac = {type = 'Frac'}
local mt = { frac = {} }
mt.frac.__index = function (frac, key)
  if key == 'a' or key == 'b' then return frac.values[key] end
  return Frac[key]
end

function Frac.toFrac(a)
    if type(a) ~= 'number' 
      then error('Invalid argument type. Should be number and is ' .. type(a)) 
    end
    local b = 1
    while a ~= math.floor(a) do 
      a, b = a * 10, b * 10 
    end
    return Frac(a | 0, b | 0)
end

function mt.frac.__pow(frac, ex)
    if type(ex) ~= 'number' or math.floor(ex) ~= ex then error('Wrong second argument.')
    else return Frac(math.floor(frac.a ^ ex), math.floor(frac.b ^ ex)) end
end

mt.frac.__newindex = function (table, key, value)
  local valuesChanged = false
  if key == 'values' then
    rawset(table, key, value)
    return
  end
  if key == 'a' then
    valuesChanged = true
  end
  if key == 'b' then
    valuesChanged = true
  end
  rawset(table.values, key, value)
  if valuesChanged then
    shortenFrac(table.values)
  end
end
--[[
    Klasa powinna być:
    * inicjalizowana dwiema liczbami całkowitymi                           
--]]
Frac.set = function (self, a, b)
  rawset(self.values, 'a', a)
  rawset(self.values, 'b', b)
  shortenFrac(self.values)
end

Frac.new = function (a, b)
  local self = {}
  setmetatable(self, mt.frac)
  self.values = {}
  self:set(a, b)
  return self
end

setmetatable(Frac, {
  __call = function(table, a, b) return Frac.new(a, b) end,
  __metatable = 'Not your business.'
  }
)

--[[    
    * obsługiwać operacje arytmetyczne (
        * dodawanie, 
--]]
mt.frac.__add = function(x, y)
  if type(x) == 'number' then 
    x = Frac.toFrac(x) 
  end
  if type(y) == 'number' then 
    y = Frac.toFrac(y) 
  end
  return Frac.new(
    x.a * y.b + y.a * x.b,
    x.b * y.b
  )
end
--[[
        * odejmowanie,
--]]
mt.frac.__sub = function(x, y)
  return Frac.new(
    x.a * y.b - y.a * x.b,
    x.b * y.b
  )
end
--[[
        * unarny minus,
--]]
mt.frac.__unm = function(self)
  return Frac.new(
    -self.a,
    self.b
  )
end
--[[ 
        * mnożenie,
--]]
mt.frac.__mul = function(x, y)
  return Frac.new(
    x.a * y.a,
    x.b * y.b
  )
end
--[[ 
        * dzielenie) pomiędzy dwoma ułamkami; 
--]]
mt.frac.__div = function(x, y)
  return Frac.new(
    x.a * y.b,
    x.b * y.a
  )
end
--[[    
    * wszystkie operacje boolowskie;
--]]

mt.frac.__eq = function(x, y)
  return x.a == y.a and x.b == y.b
end

mt.frac.__lt = function(x, y)
  return x.a * y.b < y.a * x.b
end

mt.frac.__le = function(x, y)
  return x == y or x < y
end

--[[
    * metodę tostring 
    * konkatenację z napisami (na wzór typu number).
--]]

Frac.toString = function(self)
  return '(' .. self.a .. '/' .. self.b .. ')' 
end

mt.frac.__tostring = function(self)
  return self:toString()
end

mt.frac.__concat = function(x, y)
  return tostring(x) .. tostring(y)
end

--[[ 
    * Klasa powinna także udostępniać funkcję konwertującą ułamek na liczbę.
--]]
Frac.toNumber = function(self)
  return self.a / self.b
end

Frac.toIntAndFrac = function(self)
  if (self.a < 0) then
    return -((-self.a) // self.b), Frac.new(-((-self.a) % self.b), self.b)
  end
  return self.a // self.b, Frac.new(self.a % self.b, self.b)
end


Frac.exampleGiven = function()
  print '\n---'
  print ('Wynik : ' .. Frac(2, 3) + Frac(3, 4))
  print ('(Frac(2, 3) * Frac(3 ,4)):toNumber() --> ' .. (Frac(2, 3) * Frac(3 ,4)):toNumber())
  print ( Frac (2 ,3) < Frac (3 ,4))
  print (Frac (2, 3) == Frac (8, 12))
end

Frac.exampleExercise3 = function()
  print '\n---'
  print ('Frac (2, 3) + 2 --> ' .. Frac (2, 3) + 2) --> 2 i 2/3
  print ('Frac (2, 3) + 2.5 --> ' .. Frac (2, 3) + 2.5) --> ???
  print ('Frac (2, 3) ^ 3 --> ' .. Frac (2, 3) ^ 3) --> 8/27
end

---[[
Frac.example = function()
  local f = Frac.new(6,4)
  print('Frac.new(6,4)', '       ' ,
   ' --> ' .. f:toString())
  f.b = 9
  print('f.b = 9', '             ' ,
   ' --> ' .. f:toString())
  f.a = 9
  print('f.a = 9', '             ' ,
   ' --> ' .. f)
  local x = Frac.new(2, 7)
  local y = Frac.new(5, 3)
  local w = x + y
  print()
  print('x + y = w')
  print(x .. ' + ' .. y .. ' = ' .. w)
  print(x:toNumber() .. ' + ' .. y:toNumber() .. ' = ' .. w:toNumber())
  local w1, w2 = w:toIntAndFrac()
  print(w1 .. ' and ' .. w2)
  print()
  print('Frac.new(6, -4) ', '             ' ,
   ' --> ' .. Frac.new(6, -4))
  print('Frac.new(-6, 4) ', '             ' ,
   ' --> ' .. Frac.new(-6, 4))
  local w1, w2 = Frac.new(6, -4):toIntAndFrac()
  print('Frac.new(6, -4):toIntAndFrac()', '       ' ,
   ' --> ' .. w1 .. ' and ' .. w2)
  print('Frac.new(-6, -4) ', '             ' ,
   ' --> ' .. Frac.new(-6, -4))
  print('Frac.new(5, 10) - Frac.new(3, 10) ',
   ' --> ' .. Frac.new(5, 10) - Frac.new(3, 10))
  print('Frac.new(-7, -18) ', '             ' ,
   ' --> ' .. Frac.new(-7, -18))
  print('-Frac.new(7, 18) ', '             ' ,
   ' --> ' .. -Frac.new(7, 18))
  print(x .. ' * ' .. y .. '                   ' ,
   ' --> ' .. x * y)
   print(x .. ' / ' .. y .. '                   ' ,
   ' --> ' .. x / y)

end
--]]

return Frac