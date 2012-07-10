-- AppleHourGlass.lua

AppleHourGlass = class(RectObj)

function AppleHourGlass:init(x,y,w,h)
    RectObj.init(self,x,y,w,h)
    self:makeLines()
    self.pointing = 0
end

function AppleHourGlass:moveCB()
    self:makeLines()
end

function AppleHourGlass:makeLines()
    self.lines = {}
    for ang = 0,360,30 do
        local a = math.rad(ang)
        local x1 = self.w * math.cos(a) * .25 + self.x + self.w/2
        local y1 = self.h * math.sin(a) * .25 + self.y + self.h/2
        local x2 = self.w * math.cos(a) * .5 + self.x + self.w/2
        local y2 = self.h * math.sin(a) * .5 + self.y + self.h/2
        table.insert(self.lines,{x1=x1,y1=y1,x2=x2,y2=y2,ang=ang})
    end
end

function AppleHourGlass:draw()
    pushStyle()
    strokeWidth(3)
    lineCapMode(PROJECT)
    for _,elem in ipairs(self.lines) do
        local dang = math.abs(elem.ang - self.pointing)
        if dang < 45 or dang > 315 then
            stroke(40,60,77)
        else
            stroke(120,140,157)
        end
        line(elem.x1,elem.y1,elem.x2,elem.y2)
    end
    self.pointing = (self.pointing + 5)%360
    popStyle()
end
