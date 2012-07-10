-- PositionObj.lua

-- A position object is antyhing that has a position, almost silly really, except
-- that if offers a few useful getters and setters so that you don't need to 
-- define these in your every class
PositionObj = class()

function PositionObj:init(x,y)
    self.x = x
    self.y = y
end

function PositionObj:moveCB() end -- implemented by subclasses

function PositionObj:translate(dx,dy)
    self.x = self.x + dx
    self.y = self.y + dy
    self:moveCB()
end

function PositionObj:setPos(x,y)
    self:translate(x-self.x,y-self.y)
end

function PositionObj:getX()
    return self.x
end

function PositionObj:getY()
    return self.y
end

function PositionObj:getPos()
    return self.x,self.y
end
