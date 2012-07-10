-- TextButton.lua

-- by Vega from the codea forums
-- a button with rounded corners and nice color mgmt. Looks really good!

TextButton = class(Button)

function TextButton:init(text,x,y,w,h,args)
    Button.init(self,x,y,w,h)
    self.pressed = false
    self.banner = TextBanner(text,x,y,w,h,args)
    
    args = args or {}
    self.topColor = args.topColor or color(255, 255, 255, 255) 
    self.bottomColor = args.bottomColor or color(255,255,255,255)
    self.pressedTopColor = args.pressedTopColor or color(127,127,127,255)
    self.pressedBottomColor = args.pressedBottomColor or color(127,127,127,255)
    
    --print(self.pressed)
end

function TextButton:setColors(top,bot)
    self.topColor = top
    self.bottomColor = bot
    self.banner.topColor = top
    self.banner.bottomColor = bot
    self.banner:recolor()
end

function TextButton:translate(dx,dy)
    Button.translate(self,dx,dy)
    self.banner:translate(dx,dy)
end

function TextButton:setUnpressed()
    self.pressed = false
    self.banner.topColor = self.topColor
    self.banner.bottomColor = self.bottomColor
    self.banner:recolor()
end

function TextButton:setPressed()
    self.pressed = true
    self.banner.topColor = self.pressedTopColor
    self.banner.bottomColor = self.pressedBottomColor
    self.banner:recolor()
end

function TextButton:onBegan(t)
    self:setPressed()
end

function TextButton:onEnded(t)
    self:setUnpressed()
end

function TextButton:touched(t)
    local didTouch = Button.touched(self,t)
    if not didTouch and self.pressed then self:setUnpressed() end
    return didTouch
end

function TextButton:draw()
    self.banner:draw()
end
