-- Table.lua
-- contains various useful functions related to tables
Table = class()

function Table.remove(array,obj,allInstances)
    local n = #array
    for i = n,1,-1 do
        if array[i] == obj then
            table.remove(array,i)
            if not allInstances then return nil end
        end
    end
end

-- shallow clone the array
function Table.clone(array)
    local clone = {}
    for _,elem in ipairs(array) do table.insert(clone,elem) end
    return clone
end

-- applyes this func to all elems of the second argument, which is an array
-- func should take as many arguments as the number of arrays that are passed in
function Table.map(func,...)
    assert(arg.n > 0,"Table.map called with no arguments")
    local result = {}
    local n = #arg[1]
    for i = 1,n do
        -- fixme: isn't there a function that does this for me?
        local args = {}
        for _,arr in ipairs(arg) do table.insert(args,arr[i]) end
        local r = func(unpack(args))
        table.insert(result,r)
    end
    return result
end

-- returns a random element of this array
function Table.random(array)
    local n = #array
    local r = math.random(n)
    return array[r]
end

-- check whether this table contains this obj
function Table.contains(array,obj)
    for _,elem in ipairs(array) do
        if elem == obj then return true end
    end
    return false
end

-- return the size of a table (which is not an array, otherwise you could just do #)    
function Table.size(tab)
    local n = 0
    for k,v in pairs(tab) do n = n + 1 end
    return n
end

-- optional arguments for secondary keys
-- the keys must be numerical values for now
-- you can use the format -key for descending order
function Table.sort(tab,key, ...)
    local keys = arg or {}
    table.insert(keys,1,key)
    
    local sortF = function(x,y)
        if x==nil then return true end
        if y==nil then return false end
        
        for _,key in ipairs(keys) do
            local realkey = key
            local order = 1
            if key:sub(1,1) == "-" then
                realkey = key:sub(2,key:len())
                order = -1
            end
            
            local xv = x[realkey]
            local yv = y[realkey]
            
            assert(xv~=nil and yv~=nil,"sorting table on nil value for "..key)
            
            local v
            if xv < yv then v = 1
            elseif xv > yv then v = -1
            else v = 0 end

            v = v * order
            if v > 0  then return true
            elseif v < 0 then return false end
        end
        
        return false
    end
    
    table.sort(tab,sortF)
end

function Table.sub(tab,s,e)
    e = e or #tab
    local ret = {}
    s = math.max(s,1)
    e = math.min(e,#tab)
    for i = s,e do 
        table.insert(ret,tab[i])
    end
    return ret
end

function Table.appendAll(tab,toInsert)
    for _,elem in ipairs(toInsert) do
        table.insert(tab,elem)
    end
end


