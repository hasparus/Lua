--- past

map = function(fun, tab) 
    local res = {}
    for k, v in pairs(tab) do
        res[k] = fun(v)
    end 
    return res 
end

--- new helpers

function min(x, y)
  if x < y then return x else return y end
end