-- AppleTextbox.lua

AppleTextbox = class(Panel)

function AppleTextbox:init(label,x,y,w,args)
    local h = 50
    
    Panel.init(self,x,y)
    
    -- create the label
    args = args or {}
    args.text = args.text or {}
    args.text.fontSize = 21
    args.text.textMode = CORNER
    self.banner = TextBanner(label,0,0,w,h,args)
    local tw,th = self.banner.textElem:textSize()
    self.banner.textElem:translate(15 - self.banner.textElem.x,-th/2)
    self:add(self.banner)
    
    -- add the textbox
    local tx = tw+30
    self.textbox = Textbox(tx,0,w-tx-1)
    self.textbox.background = color(0,0,0,0)
    self.textbox.cursorColor = color(0, 9, 255, 255)
    self.textbox.cursorWidth = 3
    self.textbox.cursorMarginY = -1
    self.textbox.fontProperties.fill=color(46, 112, 112, 255)
    self.textbox.fontProperties.font = "ArialRoundedMTBold"
    self.textbox.align = "LEFT"
    self.textbox:setFontSize(21)
    self.textbox:translate(0,(h-self.textbox.h)/2)
    self:add(self.textbox)
end

function AppleTextbox:touched(t)
    Panel.touched(self,t)
    
    -- deal with shadow text
    if not self.textbox.selected and self.textbox.text == "" and self.shadowText then
        self.textbox.text = self.shadowText
        self.textbox.textIsShadow = true
        self.textbox.fontProperties.font = "Arial-BoldItalicMT"
        self.textbox.fontProperties.fill=color(129, 140, 140, 255)
    end
    
    if self.textbox.selected and self.textbox.textIsShadow then
        self.textbox.text = ""
        self.textbox.cursorPos = 0
        self.textbox.textIsShadow = false
        self.textbox.fontProperties.font = "ArialRoundedMTBold"
        self.textbox.fontProperties.fill=color(46, 112, 112, 255)
    end
end
