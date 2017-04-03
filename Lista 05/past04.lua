do
  local old_tostring = tostring
  function tostring(x) 
    if type(x) == 'table' then
      return ('{' .. table.concat(
              map(tostring, x), ", ") 
              .. '}')
    end
    return old_tostring(x)
  end
end

function map(fun, tab) 
    local res = {}
    for k, v in pairs(tab) do
        res[k] = fun(v)
    end 
    return res 
end

function hash2array(tab) 
    local res = {}
    local i = 1
    for k, v in pairs(tab) do
        res[i] = {k, v}
        i = i + 1
    end 
    return res 
end

function hash2string(tab)
    local res = {}
    local i = 1
    for k, v in pairs(tab) do
        res[i] = tostring(k) .. ' = ' .. tostring(v)
        i = i + 1
    end 
    return res 
end

function imap(fun, tab) 
    local res = {}
    for i, x in ipairs(tab) do
        res[i] = fun(x)
    end 
    return res 
end

function iter2array(...)
  local i = 1
  local array = {}
  for v in ... do
    array[i] = v
    i = i + 1
  end
  return array
end

function ieach(tab, fun)
    for k, v in ipairs(tab) do
        fun(k, v)
    end 
end 

function filter(tbl, func)
    local newtbl = {}
    for i, v in pairs(tbl) do
        if func(v) then
        table.insert(newtbl, v)
        end
    end
    return newtbl
end

function any(tab, predicate)
  for k, v in pairs(tab) do
    if predicate(v) then
      return true, k
    end
  end
  return false
end

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
      io.stdout:write(target .. ' file exists. Do you want to overwrite it?')

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
    if delim:find(c, 1, true) then
      index = index + 1
    else
      table.insert(a[index], c) 
    end
  end
  return map(table.concat, a)
end

string.tokenize = function(s, delim)
  delim = delim or ' '
  local a = {}
  local index = 1
  local braceFound = 0
  for c in s:gmatch('.') do
    a[index] = a[index] or {}
    if c == '(' then braceFound = braceFound + 1 end
    if c == ')' and braceFound > 0 then braceFound = braceFound - 1 end
    if braceFound == 0 and delim:find(c, 1, true) then
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