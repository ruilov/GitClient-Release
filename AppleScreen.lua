-- AppleScreen.lua
-- takes a schema and shows the screen, handles everything really
AppleScreen = class(Panel)

function AppleScreen:init(schema)
    Panel.init(self,0,0)
    self.topY = 0 -- larger topY means the user scrolled down
    self.movableObjs = {}
    self.taggedElems = {}
    self.schema = schema 
    self:buildFromSchema()
end

function AppleScreen:rebuild()
    self:removeAll()
    self.movableObjs = {}
    self.taggedElems = {}
    local oldTopY = self.topY
    self:buildFromSchema()
    self:setTopY(oldTopY)
end

function AppleScreen:touched(t)
    if t.state == BEGAN then
        self.dontFwd = false
        Panel.touched(self,t)
    elseif t.state == MOVING then
        local newY = self.topY + t.deltaY
        self:setTopY(newY)
        self.dontFwd = true
        Panel.touched(self,t)
    elseif t.state == ENDED then
        if not self.dontFwd then 
            Panel.touched(self,t)
        end
    end
end

function AppleScreen:setTopY(newY)
    if newY < 0 then newY = 0 end
    if self.maxH < 0 then
        if newY > -self.maxH+20 then newY = -self.maxH+20 end
    else
        newY = 0
    end

    local deltaY = newY - self.topY
    self.topY = newY
        
    if deltaY ~= 0 then
        for _,obj in ipairs(self.movableObjs) do
            obj:translate(0,deltaY)
            if obj.setUnpressed and obj.pressed then obj:setUnpressed() end
        end
    end
end

function AppleScreen:buildFromSchema()
    self.topY = 0
    -- the background
    local back = TextBanner("",0,0,WIDTH,HEIGHT,
        {type="round",topColor=color(218,221,226),bottomColor=color(218,221,226)})
    self:add(back)
    
    -- create the title
    local title = TextBanner(self.schema.title,0,HEIGHT-50,WIDTH,50,
        {type="topRound",topColor=color(244,245,247),bottomColor=color(141,145,157),
        text={fill=color(73,90,98)}})
    self:add(title)

    -- create the back button
    if self.schema.backButton then
        self.backBut = TextButton(self.schema.backButton.text,7,HEIGHT-40,74,30,
            {type="back",topColor=color(140,140,150),bottomColor=color(78,85,96),
            pressedTopColor=color(38,38,38),pressedBottomColor=color(38,38,38),
            text={fill=color(224,224,225),fontSize=13,font="ArialRoundedMTBold"}})
        self.backBut.onEnded = function(b,t) 
            TextButton.onEnded(b,t) 
            self.schema.backButton.callback() 
        end
        self:add(self.backBut)
    end
    
    local currentH = title.y - 40
    for idx,elem in ipairs(self.schema.elems) do
        currentH = self:addElem(elem,currentH,p)
    end
    self.maxH = currentH

    self:remove(title)
    self:add(title)
    if self.backBut then
        self:remove(self.backBut)
        self:add(self.backBut)
    end
end

function AppleScreen:addElem(elem,currentH)
    local type = elem.type
    if type == "block" then
        return self:addBlock(elem.elems,currentH)
    elseif type == "text" then
        return self:addText(elem,currentH)
    elseif type == "blank" then
        return self:addBlank(elem.amount,currentH)
    elseif type == "MultiTextInput" then
        return self:addMultiTextInput(elem,currentH)
    elseif type=="selector" then
        return self:addSelector(elem.elems,currentH)
    end 
    
    assert(false,"unknown type: "..type)
end

function AppleScreen:addSelector(elems,currentH)
    local numElems = #elems
    if numElems == 0 then return currentH end

    local elemH = 50
    for idx,elem in ipairs(elems) do
        local type = "square"
        if idx == 1 then type = "topRound"
        elseif idx == #elems then type = "bottomRound" end
        if #elems == 1 then type = "round" end
        currentH = currentH - elemH
        
        local but = AppleSelector(elem.text,50,currentH,WIDTH-100,
            {text={fontSize=21},type=type})
          
        if elem.rightText then but:setRightText(elem.rightText) end
            
        self:add(but)
        table.insert(self.movableObjs,but)
            
        if elem.tag then self.taggedElems[elem.tag] = but end
    end    
    return currentH
end

function AppleScreen:addMultiTextInput(elem,currentH)
    local multi = AppleMultiText(50,currentH,WIDTH-100,elem.lines)
    multi:translate(0,-multi.textbox.h)
    self:add(multi)
    table.insert(self.movableObjs,multi)
    
    if elem.tag then
        self.taggedElems[elem.tag]=multi
    end
    
    return currentH - multi.textbox.h
end

-- text that you can't interact with
function AppleScreen:addText(elem,currentH)
    local textElem = TextElem(elem.text,55,currentH,
        {fill=color(59, 59, 61, 255)})   
    local h = select(2,textElem:textSize())
    textElem:translate(0,-h)

    --textElem:showHourGlass(true)
    
    self:add(textElem)
    table.insert(self.movableObjs,textElem)
    
    if elem.tag then
        self.taggedElems[elem.tag]=textElem
    end
    
    return currentH - h 
end

-- just blank space
function AppleScreen:addBlank(amount,currentH)
    return currentH - amount
end

-- a block of continuous elements
function AppleScreen:addBlock(elems,currentH)
    local numElems = #elems
    if numElems == 0 then return currentH end

    local elemH = 50    
    for idx,elem in ipairs(elems) do
        local type = "square"
        if idx == 1 then type = "topRound"
        elseif idx == #elems then type = "bottomRound" end
        if #elems == 1 then type = "round" end
        currentH = currentH - elemH
        
        -- those things with a little arrow at the end
        if elem.type == "SimpleArrow" then    
            local but = AppleSimpleArrow(elem.text,50,currentH,WIDTH-100,
                {text={fontSize=21},type=type})
            if elem.callback then
                but.onEnded = function(b,t)
                    AppleSimpleArrow.onEnded(b,t)
                    elem.callback()
                end
            end
            
            if elem.rightText then but:setRightText(elem.rightText) end
            
            self:add(but)
            table.insert(self.movableObjs,but)
            
            if elem.tag then self.taggedElems[elem.tag] = but end
            
        elseif elem.type == "TextInput" then
            -- here's where you can enter some input
            local box = AppleTextbox(elem.label,50,currentH,WIDTH-100,
                {text={fontSize=21},type=type})

            if elem.protected then
                box.textbox.protected = true
            end
            
            if elem.startText then
                box.textbox.text = elem.startText
            end
            
            if elem.keycallback then
                box.textbox.keycallback = elem.keycallback
            end
            
            if elem.shadowText then
                box.shadowText = elem.shadowText
                if box.textbox.text == "" then 
                    box.textbox.text = elem.shadowText 
                    box.textbox.textIsShadow = true
                    box.textbox.fontProperties.font = "Arial-BoldItalicMT"
                    box.textbox.fontProperties.fill=color(129, 140, 140, 255)
                end
            end
            self:add(box)
            table.insert(self.movableObjs,box)
            
            if elem.tag then self.taggedElems[elem.tag] = box end
        end      
    end
    return currentH
end
