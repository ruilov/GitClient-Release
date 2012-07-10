-- DiffScreen.lua

DiffScreen = class(AppleScreen)

function DiffScreen:init(filename,localConts,gitConts,prevScreen)
    self.filename = filename
    local schema = {
        title = filename,
        backButton = {
            text = "Files",
            callback = function() screen = prevScreen end,
        },
        elems = {}
    }
    AppleScreen.init(self,schema)
       
    -- calculate the diffs
    if not localConts then localConts = "" end
    if not gitConts then gitConts = "" end 
    local localFile = DiffScreen.splitLines(localConts)
    local gitFile = DiffScreen.splitLines(gitConts)
    local diff = Differ.diff(localFile,gitFile)
    
    --for idx,elem in ipairs(diff) do
      --  print(idx,elem)
    --end
    
    -- topY = 10 for example means that we start showing only from
    -- 10 on down
    self.tY = 0
    self.textBlocks = {}
    self.lineBlocks = {} -- line numbers
    local lastGitIdx=0
    local row = 0
    for localIdx,gitIdx in ipairs(diff) do
        row = row + 1
        if gitIdx == 0 then
            -- this line has been added
            table.insert(self.textBlocks,{text=localFile[localIdx],col=color(0,255,0),
                type="Added"})
            table.insert(self.lineBlocks,{text=localIdx..".",col=color(255,255,255)})
        else
            if gitIdx - lastGitIdx > 1 then
                -- these lines have been removed
                for idx = lastGitIdx + 1,gitIdx-1 do
                    table.insert(self.textBlocks,{text=gitFile[idx],col=color(255,0,0),
                        type="Removed"})
                    table.insert(self.lineBlocks,{text="",col=color(255,255,255)})
                end
                lastGitIdx = gitIdx
            end
            -- this line stays the same
            table.insert(self.textBlocks,{text=localFile[localIdx],col=color(255,255,255)})
            table.insert(self.lineBlocks,{text=localIdx..".",col=color(255,255,255)})
            lastGitIdx = gitIdx
        end
    end
    
    for i = lastGitIdx + 1,#gitFile do
        table.insert(self.textBlocks,{text=gitFile[i],col=color(255,0,0),type="Removed"})
        table.insert(self.lineBlocks,{text="",col=color(255,255,255)})
    end
    
    -- create the next and prev buttons
    self.next = TextButton("",WIDTH-33,HEIGHT-42,25,35,{type="arrowRight",
        topColor=color(127,127,127),
        bottomColor=color(127,127,127),
        pressedTopColor=color(255,255,255),
        pressedBottomColor=color(255,255,255)
    })
    self.next.onEnded = function(b,t)
        TextButton.onEnded(b,t)
        self:nextDiff()
    end
    self:add(self.next)
    
    self.prev = TextButton("",WIDTH-70,HEIGHT-42,25,35,{type="arrowLeft",
        topColor=color(127,127,127),
        bottomColor=color(127,127,127),
        pressedTopColor=color(255,255,255),
        pressedBottomColor=color(255,255,255)
    })
    self.prev.onEnded = function(b,t)
        TextButton.onEnded(b,t)
        self:prevDiff()
    end
    self:add(self.prev)
end

function DiffScreen.splitLines(str)
    local idx = str:find("\n")
    local ans = {}
    while idx do
        local prefix = str:sub(1,idx-1)
        if prefix:len() == 0 then prefix = " " end
        table.insert(ans,prefix)
        str = str:sub(idx+1)
        idx = str:find("\n")
    end
    
    if str:len() == 0 then str = " " end
    table.insert(ans,str)
    return ans
end

function DiffScreen:nextDiff()
    local si = self.pointedLine
    if not si then si = 0 end
    
    -- first find a non change, then find a change
    local nonFound = false
    for row = si+1,#self.textBlocks do
        if self.textBlocks[row].type == "Added" or self.textBlocks[row].type == "Removed" then
            if nonFound then
                self:setPointedLine(row)
                break
            end
        else
            nonFound = true
        end
    end
end

function DiffScreen:prevDiff()
    local si = self.pointedLine
    if not si then si = 0 end
    
    -- first find a non change, then find a change
    local nonFound = false
    for row = si-1,1,-1 do
        if self.textBlocks[row].type == "Added" or self.textBlocks[row].type == "Removed" then
            if nonFound then
                -- now go back until the start of the diff
                local f = false -- if we don't find the start of the diff, then 
                -- set to line 1
                for r = row,1,-1 do
                    if self.textBlocks[r].type ~= "Added" and 
                        self.textBlocks[r].type ~= "Removed" then
                        self:setPointedLine(r+1)
                        f = true
                        break
                    end
                end
                if not f then self:setPointedLine(1) end
                break
            end
        else
            nonFound = true
        end
    end
end

function DiffScreen:setPointedLine(newPointer)
    self.pointedLine = newPointer
    
    -- move the screen around
    pushStyle()
    self:setTextProperties()
    local startH = HEIGHT-60
    local currentH = startH + self.tY
    for idx,block in ipairs(self.textBlocks) do
        local w,h = textSize(block.text)
        currentH = currentH - h
        if idx == newPointer then
            if currentH < 0 or currentH > startH - 30 then 
                self.tY = startH + self.tY - currentH - 30
            end
            break
        end
    end
    popStyle()
end

function DiffScreen:draw()
    AppleScreen.draw(self)
    
    pushStyle()
   
    -- draw the background 
    noStroke()
    fill(0,0,0)
    rect(0,0,WIDTH,HEIGHT-50)
    
    -- draw the diffs
    self:setTextProperties()
    local startH = HEIGHT-60
    local currentH = startH + self.tY
    for idx,block in ipairs(self.textBlocks) do
        local w,h = textSize(block.text)
        currentH = currentH - h
        if currentH <= startH - h and currentH > -h then
            fill(block.col)
            text(block.text,70,currentH)
            fill(self.lineBlocks[idx].col)
            local linText = self.lineBlocks[idx].text
            if idx == self.pointedLine then 
                fill(0, 13, 255, 255)
                linText = linText .. "->"
            end
            text(linText,5,currentH)
        end
    end
    popStyle()
    
    self.next:draw()
end

function DiffScreen:setTextProperties()
    font("ArialMT")
    textMode(CORNER)
    fontSize(15)
end

function DiffScreen:touched(touch)
    AppleScreen.touched(self,touch)
    if touch.state == MOVING then
        self.tY = self.tY + touch.deltaY
        self.tY = math.max(self.tY,0)
    end
end


