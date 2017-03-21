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

function imap(fun, tab) 
    local res = {}
    for i, x in ipairs(tab) do
        res[i] = fun(x)
    end 
    return res 
end 

function map(fun, tab) 
    local res = {}
    for i, x in pairs(tab) do
        res[i] = fun(x)
    end 
    return res 
end 