-- PushScreen.lua

PushScreen = class(AppleScreen)

function PushScreen:init(repo,proj,repoFiles,projFiles,prevScreen)
    self.projFiles = projFiles
    self.repoFiles = repoFiles
    self.repo = repo
    self.proj = proj
    
    self.toPush = self:filesToPush()
    self.fileElems = {}
    local schema = {
        title = "Push",
        backButton = {
            text = prevScreen.schema.title,
            callback = function() screen = prevScreen end,
        },
        elems = {
            {type="block",elems = {
                {type="TextInput",label="Password",protected=true,tag="password"}
            }},
            {type="blank",amount=20},
            {type="text",text="Commit message"},
            {type="blank",amount=5},
            {type="MultiTextInput",lines = 5,tag="commit"},
            {type="blank",amount=20},
            {type="block",elems = {
                {type="SimpleArrow",text="OK",callback=function() self:pushIt() end,
                    tag="OK"},
            }},
            {type="blank",amount=20},
            {type="selector",elems=self.fileElems}
        }
    }
    
    local addedFiles = {}
    local removedFiles = {}
    local changedFiles = {}
    for file,changeType in pairs(self.toPush) do
        if changeType == "Added" then table.insert(addedFiles,file)
        elseif changeType == "Removed" then table.insert(removedFiles,file)
        else -- changed
            table.insert(changedFiles,file) 
        end
    end
    
    table.sort(addedFiles)
    table.sort(removedFiles)
    table.sort(changedFiles)
    
    for _,file in ipairs(addedFiles) do
        table.insert(self.fileElems,{text=file,tag="file"..file})
    end
    for _,file in ipairs(changedFiles) do
        table.insert(self.fileElems,{text=file,tag="file"..file})
    end
    for _,file in ipairs(removedFiles) do
        table.insert(self.fileElems,{text=file,tag="file"..file})
    end
    
    AppleScreen.init(self,schema)
    
    -- toggle each file as selected
    for file,changeType in pairs(self.toPush) do
        local selector = self.taggedElems["file"..file]
        selector.selected = true
        selector:setRightText(changeType)
        if changeType == "Added" then
            selector:setColors(color(0,0,255),color(0,0,255))
        elseif changeType == "Removed" then
            selector:setColors(color(255,0,0),color(255,0,0))
        else -- changeType should be Changed
            selector:setColors(color(255,255,0),color(255,255,0))
        end
    end
end

function PushScreen:pushIt()
    -- retrieve the password
    local passBox = self.taggedElems.password.textbox
    local password = passBox.text
    
    -- retrieve the commit message
    local msg = self.taggedElems.commit.textbox.text
    if msg:len() == 0 then
        msg = "uploaded from codea's "..self.proj
    end
    
    -- retrieve the list of files
    local changedFiles = {}
    local removedFiles = {}
    for file,changeType in pairs(self.toPush) do
        local selector = self.taggedElems["file"..file]
        if selector.selected then
            if self.projFiles[file] then
                changedFiles[file] = self.projFiles[file] 
            else
                table.insert(removedFiles,file)
            end
        end
    end
    
    --[[
    print("changedfiles")
    for file,c in pairs(changedFiles) do print(file) end
    
    print("removedFiles")
    for _,f in ipairs(removedFiles) do print(f) end
    --assert(false)
    --]]
    
    self.taggedElems["OK"]:showHourGlass(true)
    self.active = false -- we'll wait for thee http request

    local commitcb = function(info)
        self.active = true
        self.taggedElems["OK"]:showHourGlass(false)
        self.taggedElems["OK"]:setRightText("Success")
        GIT_CLIENT:removePassword()
    end
                
    local failcb = function(err)
        self.active = true
        self.taggedElems["OK"]:showHourGlass(false)
        self.taggedElems["OK"]:setRightText("FAILED")
        GIT_CLIENT:removePassword()
        print("ERROR:\n",err)
    end
            
    GIT_CLIENT:setReponame(self.repo)
    GIT_CLIENT:setPassword(password)
    GIT_CLIENT:commit(changedFiles,removedFiles,msg,commitcb,failcb)
end

function PushScreen:filesToPush()
    local toPush = {}
    for file,projConts in pairs(self.projFiles) do
        if self.repoFiles[file] == nil then 
            toPush[file]="Added"
        elseif self.repoFiles[file] ~= projConts then
            toPush[file]="Changed"
        end
    end
    
    for file,repoConts in pairs(self.repoFiles) do
        if self.projFiles[file] == nil then
            toPush[file]="Removed"
        end
    end
    return toPush
end
