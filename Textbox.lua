-- Textbox.lua

-- for receiving input from keyboard

Textbox = class(Button)

function Textbox:init(x,y,w)
    Button.init(self,x,y,w,0) -- we don't know the height yet
    
    self.text = ""

    -- in font properties you can set fill,font,fontSize
    self.fontProperties = {font="Futura-CondensedExtraBold",fill=color(255,255,255)}   
    self.cursorColor = color(206,206,206,255)
    self.cursorWidth = 2
    self.cursorMarginY = 4
    self.align = "CENTER" -- can also be "LEFT"
    self.protected = false -- for passwords
    self.background = color(255,255,255,255)
    
    -- internal state
    self.selected = false
    self.cursorPos = 0   -- 0 means before the first letter, 1 after the first, so on
    self:setFontSize(30)
end

function Textbox:setLines(n)
    self.h = self.h * n
    textWrapWidth(self.w)
    self.multiText = true
    self:calcCoords()
end

function Textbox:setFontSize(x)
    self.fontProperties.fontSize = x
    -- calculate the height based on font properties
    pushStyle()
    self:applyTextProperties()
    local w,h = textSize("dummy")
    popStyle()
    self.h = h
    self:calcCoords()
end

-- call back for when a key is pressed
function Textbox:keyboard(key)
    -- if not active, ignore
    if not self.selected then return nil end

    if key == BACKSPACE then
        --print(self.cursorPos)
        -- note if we're already at the start, nothing to do
        if self.cursorPos > 0 then
            local prefix = self.text:sub(1,self.cursorPos-1)
            local posfix = self.text:sub(self.cursorPos+1,self.text:len())
            self.text = prefix..posfix
            self.cursorPos = self.cursorPos - 1
        end
    else
        local prefix = self.text:sub(1,self.cursorPos)
        local posfix = self.text:sub(self.cursorPos+1,self.text:len())
        local proposedText = prefix..key..posfix
        pushStyle()
        self:applyTextProperties()
        local proposedW = textSize(proposedText)
        popStyle()
        if proposedW <= self:maxX() or self.multiText then
            -- we can add the new char
            self.text = proposedText
            self.cursorPos = self.cursorPos + 1
        end
    end
    
    if self.keycallback then self.keycallback(self.text) end
    
    self:calcCoords()
end

function Textbox:displayText()
    local displayText = self.text
    if self.protected then
        displayText = ""
        for i = 1,self.text:len() do displayText = displayText.."*" end
    end

    if self.multiText then
        -- codea has a bug (feature?) that a new line at the end of the text doesn't do anything
        -- this helps us locate the cursor in the right line
        local len = displayText:len()
        if len > 0 and displayText:sub(len,len) == "\n" then
            displayText = displayText .. " "
        end
        
        -- now truncate the text to make sure we don't overflow heightwise
        pushStyle()
        self:applyTextProperties()
        local h = select(2,textSize(displayText))
        local startPos = 1
        while h > self.h - 10 do
            displayText = displayText:sub(2,displayText:len())
            startPos = startPos + 1
            h = select(2,textSize(displayText))
        end
        popStyle()
    end

    return displayText,startPos
end

function Textbox:applyTextProperties()
    textMode(CORNER)
    font(self.fontProperties.font)
    fontSize(self.fontProperties.fontSize)
    fill(self.fontProperties.fill)
end

function Textbox:maxX()
    return self.w - 10
end

function Textbox:translate(dx,dy)
    Button.translate(self,dx,dy)
    self:calcCoords()
end

function Textbox:calcCoords()
    pushStyle()

    -- the text    
    self:applyTextProperties()
    local displayText = self:displayText()
    local singleH = select(2,textSize("dummy"))
    local textW,textH = textSize(displayText)
    if textH == 0 then textH = singleH end -- for when displayText is empty
    
    local textX = self.x + (self.w - textW)/2 -- default alignment is CENTER
    if self.align == "LEFT" then textX = self.x end
    local textY = self.y
    -- when protected we'll be showing *, but let's show in the middle of the line
    if self.protected then textY = textY - self.h*.2 end
    -- for multie text we show from the top
    if self.multiText then textY = self.y + self.h - textH end
    
    self.textCoords = {x=textX,y=textY}

    ------------
    --- THE CURSOR
    -------------
    local prefix = displayText:sub(1,self.cursorPos)
    
    if self.multiText then    -- prefix should only be the last line
        -- but we can't just look for new lines, because sometimes the text wraps just
        -- because it's long
        
        -- again we need to add a blank space in case the cursor is just after a
        -- new line
        local prefix2 = prefix
        if prefix2:len() > 0 and prefix2:sub(prefix2:len(),prefix2:len())=="\n" then
            prefix2 = prefix2 .. " "
        end
        local totalH = select(2,textSize(prefix2))
        
        local lastLin = ""
        for i = prefix:len(),1,-1 do
            local thisH = select(2,textSize(prefix:sub(1,i)))
            if thisH < totalH then 
                -- now we have to go backwards until we find a space, because
                -- the whole last word will be in the new line
                for j = i,1,-1 do
                    local ch = prefix:sub(j,j)
                    if ch == " " or ch == "\n" then break end
                    lastLin = ch..lastLin
                end
                break 
            end
            lastLin = prefix:sub(i,i) .. lastLin
        end
        prefix = lastLin
        --print("textbox.calc = ",lastLin)
    end
        
    local len = textSize(prefix)
    local cursorH = self.h
    local cursorY = self.y
    if self.multiText then 
        cursorH = singleH
        cursorY = self.y + self.h - textH
    end
    
    self.cursorCoords = {
        x1 = textX + len,
        y1 = cursorY + self.cursorMarginY,
        x2 = textX + len,
        y2 = cursorY + cursorH - 2 * self.cursorMarginY
    }
    popStyle()
end

function Textbox:draw()
    pushStyle()
    noSmooth()
    
    -- draw the bounding box
    rectMode(CORNER)
    strokeWidth(2)
    stroke(self.background)
    noFill()
    rect(self.x,self.y,self.w,self.h)
    
    -- draw the text
    self:applyTextProperties()
    local displayText = self:displayText()
    text(displayText,self.textCoords.x,self.textCoords.y)

    if not self.selected then
        popStyle()
        return nil
    end

    -- draw the cursor
    if math.floor(ElapsedTime*4)%2 == 0 then
        stroke(self.cursorColor)
        strokeWidth(self.cursorWidth) 
        local c = self.cursorCoords       
        line(c.x1,c.y1,c.x2,c.y2)
    end

     popStyle()
end

function Textbox:touched(t)
    local didTouch = Button.touched(self,t)
    if not didTouch and self.selected then self:unselect() end
    return didTouch
end

-- when the text box is active, the keyboard shows up (and coursor and other elements too)
function Textbox:select()
    self.selected = true
    -- move the cursor to the end
    self.cursorPos = self:displayText():len()
    GLOBAL_SHOWKEYBOARD = true
end

function Textbox:unselect()
    self.selected = false
    hideKeyboard()
end

function Textbox:onEnded(touch)
    if not self.selected then self:select() end
end

-- moves the cursor to the x coordinate of the touch
function Textbox:onTouched(touch)
    if not self.selected then return nil end
    
    self.cursorPos = 0

    pushStyle()
    self:applyTextProperties()
    local displayText,startPos = self:displayText()
    if startPos ~= nil then self.cursorPos = startPos end
    
    local textW = textSize(displayText)
    local textX = self.x + (self.w - textW)/2
    if self.align == "LEFT" then textX = self.x end
    local touchX = touch.x - textX
    
    for idx = 1,displayText:len() do
        local len = textSize(displayText:sub(1,idx))
        if len > touchX then break end
        self.cursorPos = self.cursorPos + 1
    end
    popStyle()
    
    self:calcCoords()
end
