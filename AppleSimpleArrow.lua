-- AppleSimpleArrow.lua
-- those buttons with the little arrow
AppleSimpleArrow = class(TextButton)

function AppleSimpleArrow:init(text,x,y,w,args)
    local h = 50
    self.args = args or {}
    self.args.text = self.args.text or {}
    self.args.text.fontSize = 21
    self.args.text.textMode = CORNER
    self.args.pressedTopColor = color(0,130,255,255)
    self.args.pressedBottomColor = color(0,80,255,255)
    TextButton.init(self,text,x,y,w,h,self.args)
    
    local tw,th = self.banner.textElem:textSize()
    self.banner.textElem:translate(15 - self.banner.textElem.x,-th/2)
end

-- sets some text on the right side
function AppleSimpleArrow:setRightText(text)
    self.bannerRight = TextBanner(text,self.x+self.w,self.y,0,self.h,self.args)    
    local tw,th = self.bannerRight.textElem:textSize()
    self.bannerRight.textElem:translate(-tw-35,-th/2)
    self.bannerRight.textElem.fill = color(49, 78, 97, 255)
end

function AppleSimpleArrow:showHourGlass(toggle)
    if not toggle then
        self.hourGlass = nil
        return nil
    end
    
    self.hourGlass = AppleHourGlass(self.x+self.w-25,self.y+(self.h-18)/2,18,18)
end

function AppleSimpleArrow:translate(dx,dy)
    TextButton.translate(self,dx,dy)
    if self.bannerRight then self.bannerRight:translate(dx,dy) end
    if self.hourGlass then self.hourGlass:translate(dx,dy) end
end

function AppleSimpleArrow:draw()
    TextButton.draw(self)
    if self.bannerRight then self.bannerRight:draw() end
    
    -- draw a little arrow at the end
    if self.hourGlass then 
        self.hourGlass:draw()
    else
        pushStyle()
        stroke(40, 60, 77, 255)
        strokeWidth(5)
        lineCapMode(SQUARE)
        line(self.x+self.w-25,self.y+17,self.x+self.w-15,self.y+26)
        line(self.x+self.w-25,self.y+33,self.x+self.w-15,self.y+24)
        popStyle()
    end
end
