require('past01');

Event = {}
Event.__index = Event
function Event.new(_startTime, _description, _endTime)
  local newEvent = setmetatable(
    {startTime = os.time(_startTime), 
     description = _description,
     endTime = os.time(_endTime)}, Event)
  return newEvent
end

function Event:toString(verbose)
  if verbose == nil then verbose = true end
  local start; local _end;
  if verbose then
    start = hash2string(os.date('*t', self.startTime))
    _end = hash2string(os.date('*t', self.endTime))
  else
    start = self.startTime
    _end = self.endTime
  end

  return tostring({start,
                   self.description,
                   _end})
end


local function inside(start, inside, _end)
  return start <= inside and inside <= _end
end

local function onewaycollide(interval1, interval2)
  return inside(interval1.startTime, interval2.startTime, interval1.endTime) or 
         inside(interval1.startTime, interval2.endTime, interval1.endTime)
end

function Event:collides(other)
  return onewaycollide(self, other) or onewaycollide(other, self)
end

Calendar = {}
Calendar.__index = Calendar
function Calendar.new()
  local newCalendar = setmetatable({}, Calendar)
  newCalendar.list = {}
  newCalendar.eventsCount = 0
  return newCalendar
end

function Calendar:add(event)
  --print('Lista: ', self.list, 'eventsCount: ', self.eventsCount)
  if (event == nil) then return end

  local collision; local where
  collision, where = any(self.list, function(x) return event:collides(x) end)
  --print('Collision occured?', collision, where)

  if collision then return nil, where, self.list[where] end
  self.eventsCount = self.eventsCount + 1
  self.list[self.eventsCount] = event

  return self.eventsCount, self.list[self.eventsCount]
end

function Calendar:toString(all, verbose)
  local printAll = all == true
  local now = os.time()
  local stringBuilder = {}; local sbCount = 0;
  for i, v in ipairs(self.list) do
    if printAll or v.endTime > now then
      sbCount = sbCount + 1
      stringBuilder[sbCount] = v:toString(verbose) .. '\n'
    end
  end
  return table.concat(stringBuilder)
end

function Calendar:show(all, verbose)
  print('Printing calendar: {')
  print(self:toString(all, verbose))
  print('}')
end

e = Event.new({year = 2017, month = 3, day = 7, hour = 20}, 
               'Improcepcja w Wedrowki Pub',
               {year = 2017, month = 3, day = 7, hour = 20, min = 15})
e1 = Event.new( {year = 2017, month = 1, day = 1}, 'Rok 2017', {year = 2017, month = 12, day = 31} )
e2 = Event.new( {year = 2018, month = 1, day = 1}, 'Rok 2018', {year = 2018, month = 12, day = 31} )
print(e:toString(false))
print(e1:toString(false))
print('7 marca 2017 koliduje z 2017:', e:collides(e1))
print('7 marca 2017 koliduje z 2018:', e:collides(e2))

cal = Calendar.new()

print(cal:add(e))
print(cal:add(e1))
print(cal:add(e2))
print('Events count: ', cal.eventsCount)

cal:show()

cal1 = Calendar.new()
cal1:add(e1)
cal1:add(e2)
cal1:show(false, false)