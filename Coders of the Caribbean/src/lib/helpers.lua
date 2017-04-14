
local function map(fun, tab) 
    local res = {}
    for k, v in pairs(tab) do
        res[k] = fun(v)
    end 
    return res 
end

function hash2string(tab)
    local res = {}
    local i = 1
    for k, v in pairs(tab) do
        res[i] = tostring(k) .. ': ' .. tostring(v)
        i = i + 1
    end 
    return res 
end

local log = function(...) return io.stderr:write(...) end;