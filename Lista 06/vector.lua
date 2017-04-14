local Vector = {}
local mt = {__metatable = 'Vector'} -- Do sprawdzania typu.

function Vector:new(values) 
    self = {}
    for i, v in ipairs(values) do self[i] = v end
    self.n = #values
    setmetatable(self, mt)
    return self
end

setmetatable(Vector, {__call = Vector.new, __metatable = 'Not your business.'})

function mt.__add(v1, v2)
    if v1.n ~= v2.n then error('Cannot add vectors of different size.') end
    local res = {}
    for i = 1, v1.n do res[i] = fun(v1[i], v2[i]) end
    return Vector(res)
end

function mt.__unm(v)
    local res = {}
    for i = 1, v.n do res[i] = -v[i] end
    return Vector(res)
end

function mt.__sub(v1, v2)
    return v1 + (-v2)
end

function mt.__mul(v1, v2)
    if getmetatable(v1) ~= 'Vector' then v1, v2 = v2, v1 end
    if getmetatable(v2) == 'Vector' then
        if v1.n ~= v2.n then error('duh different size sub') end
        local res = 0
        for i = 1, v1.n do res = res + v1[i] * v2[i] end
        return res 
    elseif type(v2) == 'number' then
        local res = {}
        for i = 1, v1.n do res[i] = v1[i] * v2 end
        return Vector(res)
    else error('Invalid param types') end
end

function mt.__div(v, s)
    if type(s) == 'number' then
        local res = {}
        for i = 1, v.n do res[i] = v[i] / s end
        return Vector(res)
    else error('Invalid parameters for vector division', 2) end
end

function mt.__len(v)
    local res = 0
    for i = 1, v.n do res = res + v[i] ^ 2 end
    return math.sqrt(res)
end

function mt.__eq(v1, v2)
    for i = 1, v1.n do
        if v1[i] ~= v2[i] then return false end
    end
    return true
end

function mt.__newindex(v) end

function mt.__tostring(v)
    if v.n == 0 then return '()' end
    local res = '(' .. v[1]
    for i = 2, v.n do
        res = res .. ', ' .. v[i]
    end
    return res .. ')'
end

function mt.__concat(v1, v2)
    return tostring(v1) .. tostring(v2)
end

function mt.__ipairs(v)
    local last_elem = 0
    local key = {}
    for i = 1, v.n do key[i] = 0 end
    key = Vector(key)
    return function()
        last_elem = last_elem + 1
        if last_elem > key.n then return nil end
        key[last_elem - 1], key[last_elem] = 0, 1
        return key, v[last_elem]
    end
end

return Vector
