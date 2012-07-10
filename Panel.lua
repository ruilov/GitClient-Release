-- Panel.lua

-- A panel is a container for other panels or objects that can be drawn. Used to form a 
-- hierarchical representation of what's in the screen
-- objs need to have a translate method since they are added with coords relative
-- to this and need to be translated

Panel = class(PositionObj)

function Panel:init(x,y)
    PositionObj.init(self,x,y)
    self.active = true -- if not active, touch events are not handled
    self.elems = {}
end

-- object should have coordinates relative to this panel
function Panel:add(obj)
    Table.map(function(x) assert(x~=obj,"adding duplicate obj") end,self.elems)
    obj:translate(self.x,self.y)
    table.insert(self.elems,obj)
end

function Panel:remove(obj)
    Table.remove(self.elems,obj)
end

function Panel:removeAll()
    self.elems = {}
end

function Panel:translate(dx,dy)
    PositionObj.translate(self,dx,dy)
    self:forwardMsg("translate",false,dx,dy)
end

-- called in every frame update
function Panel:tick()
    self:forwardMsg("tick")
end

function Panel:draw()
    self:forwardMsg("draw",false)
end

function Panel:keyboard(key)
    self:forwardMsg("keyboard",false,key)
end

function Panel:touched(t)
    if not self.active then return nil end
    self:forwardMsg("touched",true,t)
end

function Panel:setActive(val)
    self.active = val
    Table.map(function(x)
        if x.setActive then x:setActive(val)
        else x.active = val end
    end, self.elems)
end

function Panel:forwardMsg(message,onClone,...)
    local elems = self.elems
    if onClone then elems = Table.clone(elems) end
    Table.map(function(x) 
        if x[message] then x[message](x,unpack(arg)) end
    end,elems)
end
