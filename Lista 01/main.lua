--local table = require("table")

function map(fun, tab) 
    local res = {}
    for i, x in ipairs(tab) do
        res[i] = fun(x)
    end 
    return res 
end 

function printf(x)
  local old_tostring = tostring
  function tostring(x) 
    if type(x) == 'table' then
      return ('{' .. table.concat(
              map(tostring, x), ", ") 
              .. '}')
    end
    return old_tostring(x)
  end
  print(x)
end

printf({{'WOW'}, 'to', 'są', 'zagnieżdżone', {{'tablice', {true}}}});
print({{'Super'}, 'na', 'zwykłym', 'princie', {{'dziala', {'bo przepisałem tostring tabla, żeby traktować je jak wartość. To zabija możliwość wypisywania ich jako słownika'}}}});

do
  local fibs = {0, 1}
  function fibonacci(n)
    if n == nil then return tostring(fibs) end
    n = n + 1
    while (n > #fibs) do
      fibs[#fibs + 1] = fibs[#fibs] + fibs[#fibs - 1]
      print('Adding fibs[' .. #fibs .. '] = ' .. fibs[#fibs] .. '.')
    end
    return fibs[n]
  end
end

print(fibonacci(0))
print(fibonacci(1))
print(fibonacci(2))
print(fibonacci(5))
print(fibonacci(9))
print(fibonacci(1))
print(fibonacci(5))
print(fibs);
print(fibonacci());