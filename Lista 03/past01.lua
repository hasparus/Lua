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

function ieach(tab, fun)
    for k, v in ipairs(tab) do
        fun(k, v)
    end 
end 

 function filter(tbl, func)
     local newtbl = {}
     for i,v in pairs(tbl) do
         if func(v) then
	     table.insert(newtbl, v)
         end
     end
     return newtbl
 end

function map(fun, tab) 
    local res = {}
    for i, x in pairs(tab) do
        res[i] = fun(x)
    end 
    return res 
end 