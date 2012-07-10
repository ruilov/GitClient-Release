-- Button.lua

-- a little useful class for objects that know how to handle touches

Button = class(RectObj)

function Button:init(x,y,w,h)
    RectObj.init(self,x,y,w,h)
    self.active = true
end

function Button:onTouched(t) end -- user defined
function Button:onEnded(t) end -- user defined
function Button:onBegan(t) end -- user defined
function Button:onMoving(t) end -- user defined

-- return true if the touch was inside while this button was active, false otherwise
function Button:touched(t)
    if self:inbounds(t) and self.active then
        self:onTouched(t)
        if t.state == BEGAN then self:onBegan(t)
        elseif t.state == MOVING then self:onMoving(t)
        elseif t.state == ENDED then self:onEnded(t)
        end
        return true
    end
    return false
end
