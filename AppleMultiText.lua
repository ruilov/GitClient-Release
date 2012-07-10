AppleMultiText = class(Panel)

function AppleMultiText:init(x,y,w,nlins,args)
    Panel.init(self,x,y)
        
    self.textbox = Textbox(5,-5,w - 10)
    self.textbox.background = color(0,0,0,0)
    self.textbox.cursorColor = color(0, 9, 255, 255)
    self.textbox.cursorWidth = 3
    self.textbox.cursorMarginY = -1
    self.textbox.fontProperties.fill=color(46, 112, 112, 255)
    self.textbox.fontProperties.font = "ArialRoundedMTBold"
    self.textbox.align = "LEFT"
    self.textbox:setFontSize(21)
    self.textbox:setLines(nlins)
    --self.textbox:translate(0,(h-self.textbox.h)/2)
     
    self.banner = TextBanner("",0,0,w,self.textbox.h)
    self:add(self.banner)
    self:add(self.textbox)
end
