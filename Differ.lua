--[[
    lcs is an implementation in lua of the algorithm described in the paper :
        `An Algorithm for Differential File Comparison'
    by J. W. Hunt and M. D. McIlroy

    The paper can be downloaded from http://www.cs.dartmouth.edu/~doug/diff.ps
--]]

-- notes
-- implement binary search in two places - DONE
-- need string hashing function - DONE
-- need to delete jackpot matches at the end - DONE

-- wtf, someone forget to learn how to name variables...

Differ = class()

-- binary search function
-- arr must be in increasing order
function Differ.binSearch(arr,val,evalf,args)
    evalf = evalf or function(v) return v end
    args = args or {}
    inexact = args.inexact or false
    local iStart = args.minIdx or 1
    local iEnd = args.maxIdx or #arr 
    
    local iMid
    while iStart <= iEnd do
        iMid = math.floor((iStart+iEnd)/2)
        local val2 = evalf(arr[iMid])
        if val == val2 then
            local tFound,num = {iMid,iMid},iMid-1
            while val == evalf(arr[num]) do
                tFound[1],num = num,num-1
            end
            num = iMid+1
            while val == evalf(arr[num]) do
                tFound[2],num = num,num+1
            end
            return tFound
        elseif val2 < val then
            iStart = iMid+1
        else
            iEnd = iMid-1
        end
    end
    
    if inexact then return {iEnd,iStart} end
end

-- djb2 hashing function. First reported by Dan Bernstein in comp.lang.c
-- a better version uses xor, but lua doesn't have xor
local p2 = 2^22 -- it seems lua has precision up to 2^31-1. Since we multiply hash
-- 33 and add a small constant let's keep within the 2^24 range
-- ok 2^42 still gave overflow collisions and I don't get why. Take it down to 2^22
function Differ.strHash(str)
    local hash = 5381
    local c
    for i = 1,str:len() do
        c = str:byte(i)
        hash = (hash*33 + c)%p2
    end
    return hash
end

function merge(K, k, i, E, p)
    local bExtract = function(x)
        if not x then return nil end
        return x.b
    end
    
    -- 1. Let r be an integer and c be a reference to a candidate. c will always refer
    -- to the last candidate found, which will always be an r-candidate. K[r] will be 
    -- updated with this reference once the previous value of K[r] is no longer needed
    
    local r, c = 0, K[0]
    -- 2
    while true do
        -- 3
        local j = E[p].serial
        
        -- search K[r:k] for an element K[s] such that K[s].b < j < K[s+1].b
        -- K is sorted on the b key so a binary search will work
        local idxs = Differ.binSearch(K,j,bExtract,{inexact=true,minIdx=r,maxIdx=k+1})
        
        -- we need to find j in between two of K elems. So exclude the cases where
        -- j is below min or above max and also cases where j matches an element exactly
        if idxs[1]==r-1 then idxs = nil
        elseif idxs[2]==k+2 then idxs = nil
        elseif K[idxs[1]].b==j then idxs = nil
        elseif K[idxs[2]].b==j then idxs = nil
        end
        
        if idxs then
            assert(idxs[2]==idxs[1]+1)
            local s = idxs[1]
            -- 4
            if K[s + 1].b > j then
                K[r] = c
                r = s + 1
                c = {a=i,b=j,previous=K[s]}
            end
            -- 5 move fence out
            if s == k then
                K[k + 2] = K[k+1]
                k = k + 1
            end
        end
        
        -- 6
        if E[p].last then
            break
        else
            p = p + 1
        end
    end
    
    -- 7
    K[r] = c
    
    return k
end

function Differ.sort_V(x, y)
    if x.hash ~= y.hash then return x.hash < y.hash
    else return x.serial < y.serial end
end

-- lcs stands for longest common subsequence
-- return an array of size file1 where the elements correspond to lines in file2
function Differ.lcs(file1, file2)
    local m, n = #file1,#file2
    
    -- 1 : Let V be a vector of elements structured (serial,hash), where serial is
    -- a line number and hash is an integer. 
    local V = {}
    for j = 1, n do
        V[j] = {serial = j, hash = Differ.strHash(file2[j])}
    end

    -- 2 : sort V into ascending order on hash as primary key and serial as secondary key
    table.sort(V, Differ.sort_V)

    -- 3 : E lists all the equivalence classes of lines in file 2, with last = true on the
    -- last element of each class. The elements are ordered by serial within classes.
    local E = {}
    E[0] = {serial = 0, last = true}
    for j = 1, n do
        E[j] = {
            serial = V[j].serial,
            last = (j == n or V[j].hash ~= V[j + 1].hash)
        }
    end
    
    -- 4 : P[i] if non zero points in E to the beginning of the class of lines
    -- in file 2 equivalent to line i in file 1
    local extractHash = function(x) 
        if not x then return nil end
        return x.hash 
    end
       
    local P = {}
    for i = 1, m do
        local hash_i = Differ.strHash(file1[i])
        P[i] = 0
        
        -- I need to find j such that E[j-1].last = true and hash_i = V[j].hash
        -- I know V is sorted by hash. So I want to find the last hash_i in V
        local idxs = Differ.binSearch(V,hash_i,extractHash)
        if idxs then P[i] = idxs[1] end
    end
    
    -- 5 : K, k
    -- K stores the k-candidate values as we go from left to right on the
    -- file 1 x file 2 grid.
    -- Little k point in K to its last usefully filled element
    -- Q: do we need this or is k always just #K?
    -- K[1] is a fence beyong the last usefully filled element
    local K, k = {}, 0
    K[0] = { a = 0, b = 0 }
    K[1] = { a = m + 1, b = n + 1 }
    
    -- 6 : merge
    for i = 1, m do
        if P[i] ~= 0 then
            k = merge(K, k, i, E, P[i])
        end
    end
    
    -- 7 : intialize J, which is the return value
    local J = {}
    for i = 0, m do J[i] = 0 end
    
    -- 8
    local c = K[k]
    while c do
        J[c.a] = c.b
        c = c.previous
    end
    
    -- 9. Weed out fake jackpot matches (has collisions)
    for i = 1,m do
        if J[i] ~= 0 and file1[i] ~= file2[J[i]] then
            J[i]=0
        end
    end
    
    return J
end

function Differ.diff(a,b)
    return Differ.lcs(a,b)
end
