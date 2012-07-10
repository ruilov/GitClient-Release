-- PushScreen.lua

PullScreen = class(AppleScreen)

function PullScreen:init(repo,proj,repoFiles,projFiles,prevScreen)
    self.projFiles = projFiles
    self.repoFiles = repoFiles
    self.repo = repo
    self.proj = proj
    
    self.toPull = self:filesToPull()
    self.fileElems = {}
    local schema = {
        title = "Pull",
        backButton = {
            text = prevScreen.schema.title,
            callback = function() screen = prevScreen end,
        },
        elems = {
            {type="text",text="Pull to "..proj.." from "..repo},
            {type="blank",amount=20},
            {type="block",elems = {
                {type="SimpleArrow",text="OK",callback=function() self:pullIt() end,
                    tag="OK"},
            }},
            {type="blank",amount=20},
            {type="selector",elems=self.fileElems}
        }
    }
    
    for file,changeType in pairs(self.toPull) do
        table.insert(self.fileElems,{text=file,tag="file"..file})
    end
    
    AppleScreen.init(self,schema)
    
    -- toggle each file as selected
    for file,changeType in pairs(self.toPull) do
        local selector = self.taggedElems["file"..file]
        selector.selected = true
        selector:setRightText(changeType)
        if changeType == "Removed" then
            selector:setColors(color(255,0,0),color(255,0,0))
        else -- changeType should be Changed
            selector:setColors(color(255,255,0),color(255,255,0))
        end
    end
end

function PullScreen:pullIt()
    ProjectLoader.save(self.repoFiles,self.proj)
    self.taggedElems["OK"]:setRightText("Success")
end

function PullScreen:filesToPull()
    local toPull = {}
    for file,repoConts in pairs(self.repoFiles) do
        if self.projFiles[file] == nil then 
            toPull[file]="Removed"
        elseif self.projFiles[file] ~= repoConts then
            toPull[file]="Changed"
        end
    end
    return toPull
end
