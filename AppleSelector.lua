-- AppleSelector.lua
-- This represents one elem that can be selected

AppleSelector = class(AppleSimpleArrow)

function AppleSelector:init(text,x,y,w,args)
    AppleSimpleArrow.init(self,text,x,y,w,args)
    self.banner.textElem:translate(30,0)
    self.selected = false
end

function AppleSelector:onEnded(t)
    self.selected = not self.selected
    AppleSimpleArrow.onEnded(self,t)
end

function AppleSelector:draw()
    TextButton.draw(self)
    if self.bannerRight then self.bannerRight:draw() end
    
    local elR = 26
    local elX = self.x + elR
    local elY = self.y + self.h / 2
     
    pushStyle()
    ellipseMode(CENTER)
    -- draw the outter circle
    noFill()
    stroke(192, 192, 192, 255)
    strokeWidth(2)
    ellipse(elX,elY,elR)
    if self.selected then
        -- draw the innter circle
        stroke(255,255,255,255)
        fill(207, 14, 23, 255)
        ellipse(elX,elY,elR-2)
        
        -- draw the lines
        strokeWidth(5)
        lineCapMode(SQUARE)
        line(elX-6,elY+1,elX+1,elY-6)
        line(elX-1,elY-6,elX+6,elY+5)
    end

    popStyle()
end
