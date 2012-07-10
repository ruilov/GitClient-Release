-- Stack.lua

-- a generic stack class. Piles of blocks are stacks. 
-- Also used to keep track of the user program stack

Stack = class()

function Stack:init()
    self.elems = {}
end

-- removes and return the top elem
function Stack:pop()
    local elem = self:peek()
    table.remove(self.elems,#self.elems)
    return elem
end

-- adds a new elem at the top
function Stack:push(elem)
    table.insert(self.elems,elem)
end

-- returns the last elem, but doesn't remove it
function Stack:peek(idx)
    idx = idx or #self.elems
    return self.elems[idx]
end

function Stack:size()
    return #self.elems
end

-- returns an iterator over the elems of the stack
function Stack:iter()
    local i = 0
    local n = self:size()
    return function() 
        i = i + 1
        if i <= n then return self.elems[i] end
    end
end
