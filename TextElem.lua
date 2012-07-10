-- TextElem.lua

-- encapsulates codea's text api so that text can be put inside panels (for example)
TextElem = class(PositionObj)

function TextElem:init(text,x,y,args)
    PositionObj.init(self,x,y)
    self.text = text
    
    args = args or {}
    self.font = args.font or "ArialRoundedMTBold"
    self.fontSize = args.fontSize or 20
    self.fill = args.fill or color(255,255,255,255)
    self.textMode = args.textMode or CORNER
end

function TextElem:showHourGlass(toggle)
    if not toggle then
        self.hourGlass = nil
        return nil
    end
    
    local w,h = self:textSize()
    self.hourGlass = AppleHourGlass(self.x+w*1.1,self.y+(h-18)/2,18,18)
end

function TextElem:draw()
    pushStyle()
    self:applyProperties()
    text(self.text,self.x,self.y)
    popStyle()
    
    if self.hourGlass then self.hourGlass:draw() end
end

function TextElem:textSize()
    pushStyle()
    self:applyProperties()
    local w,h = textSize(self.text)
    popStyle()
    return w,h
end

function TextElem:applyProperties()
    smooth()
    font(self.font)
    fontSize(self.fontSize)
    fill(self.fill)
    textMode(self.textMode)
end
