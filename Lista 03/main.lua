require('past01');

utf8.normalize = function(s)
  local zmienna = {utf8.codepoint(s, 1, -1)}
  local filtered = filter(zmienna, function(x) if x < 127 then return x end end)
  return string.char(
    table.unpack( filtered ))
end

function lreverser(source, target)
  if target then 
    local t = io.open(target, "r") 
    if t ~= nil then
      io.stdin:write(target .. ' file exists. Do you want to overwrite it?')

      local answer = io.stdin:read()
      io.close()
      if answer ~= 'yes' then
        return -1
      end
    end
  end

  local t = target and io.open(target, 'w') or io.stdout  
  local s = source and io.open(source, 'r') or io.stdin

  local stack = {}

  local i = 0
  while true do
    local line = s:read()
    if line == nil then break end
    i = i + 1
    stack[i] = line
  end

  while i > 0 do
    t:write(stack[i] .. '\n')
    i = i - 1
  end

  t:close()
  s:close()
end

string.split = function(s, delim)
  delim = delim or ' '
  local a = {}
  local index = 1
  for c in s:gmatch('.') do
    a[index] = a[index] or {}
    if delim:match(c) then
      index = index + 1
    else
      table.insert(a[index], c) 
    end
  end
  return map(table.concat, a)
end

utf8.reverse = function(s)
  local stack = {}
  local i = utf8.len(s)
  for _, c in utf8.codes(s) do
    stack[i] = c
    i = i - 1
  end
  return utf8.char(table.unpack(stack))
end

print(string.split(' test string   ', ' '))
print(string.split('test,12,5,,xyz', ','))

print(utf8.normalize("Zażółć gęślą jaźń... serio nie mam ni?"))
print(utf8.reverse("Księżyc"))