-- package.path = "../?.lua;" .. package.path
require('past01');


--[[

Zaprojektuj reprezentację prostego kalendarza zadań, 
która dla każdego dnia pamięta wydarzenia zawierające
   godzinę początkową, 
   końcową i 
   nazwę, 
    np: .’wtorek ’, 16 , 18 , ’Wykład Lua ’
Napisz funkcję która pozwala dodawać nowe wydarzenia i zwraca prawdę jeśli zdarzenie nie powoduje
konfliktów lub fałsz i komunikat o konflikcie w przeciwnym przypadk

--]]

local Day = {}

Day.new = function ()
  return { bits = 0, events = {} }
end

local Calendar = { integer_size = 64 }
function Calendar.new ()
  local new_calendar = setmetatable({}, Calendar)
  for _, day in pairs{'monday', 'tuesday', 'wednesday', 'thursday', 
              'friday', 'saturday', 'sunday'} do
    new_calendar[day] = Day.new()
  end
  return new_calendar
end

function Day:add_event(start_time, end_time, event_name) 
  local event_bits = (-1 << (64 + start_time - end_time)) >> (start_time - 1)
  if event_bits & self.bits ~= 0 then
    print('Oops! There is a conflict between ' .. start_time .. ' and ' .. end_time .. '!');
    -- print(event_bits, self.bits);
    return false
  else 
    self.bits = self.bits | event_bits
    self.events[#self.events + 1] = {event_name, start_time, end_time, event_bits}
  end
  return true
end

Day.__index = Day


print('----------------------------------')

local cal = Calendar.new()

print(cal)
for i, x in pairs(cal) do
    print(i, x.events)
end


-- cal.wednesday:add_event(16, 18, 'Wykład Lua'); -- nil value?

print('----------------------------------')

Day.add_event(cal.wednesday, 16, 18, 'Wykład Lua');


print(cal)
for i, x in pairs(cal) do
    print(i, x.bits, x.events)
end

print('----------------------------------')

Day.add_event(cal.wednesday, 17, 21, 'Harce i swawole');


print(cal)
for i, x in pairs(cal) do
    print(i, x.bits, x.events)
end