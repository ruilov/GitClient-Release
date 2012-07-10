-- FileScreen.lua
-- in the file screen you can see which files exist and see which ones are different
-- from local to repo version

FilesScreen = class(AppleScreen)

function FilesScreen:init(repo,proj,commit,prevScreen)
    self.fileSchema = {}
    self.repoFiles = {}
    self.commit = commit
    self.repo = repo
    self.proj = proj
    
    local schema = {
        title = "Files",
        backButton = {
            text = prevScreen.schema.title,
            callback = function() screen = prevScreen end,
        },
        elems = {
            {type="block",elems = {
                {type="SimpleArrow",text="Push to repo",callback=function() self:pushCB() end},
                {type="SimpleArrow",text="Pull from repo",callback=function() self:pullCB() end},
            }},
            {type="blank",amount=20},
            {type="text",text="Files",tag="label"},
            {type="blank",amount=5},
            {type="block",elems = self.fileSchema}
        }
    }
       
    self.projectFiles = ProjectLoader.readAll(proj)
    for file,localConts in pairs(self.projectFiles) do
        local cb = function()
            screen = DiffScreen(file,self.projectFiles[file],self.repoFiles[file],self)
        end
        local newElem = {type="SimpleArrow",text=file,tag=file,callback=cb}
        table.insert(self.fileSchema,newElem)
    end
    
    AppleScreen.init(self,schema)
    self.taggedElems.label:showHourGlass(true)
    self.active = false
    
    local failcb = function(err)
        self.taggedElems.label:showHourGlass(false)
        self.active = true
        print("FAILED\n",err)
    end
    
    GIT_CLIENT:setReponame(repo)
    GIT_CLIENT:listFiles(function(files) self:gotFiles(files) end,failcb,commit)
end

function FilesScreen:pushCB()
    screen = PushScreen(self.repo,self.proj,self.repoFiles,self.projectFiles,self)
end

function FilesScreen:pullCB()
    screen = PullScreen(self.repo,self.proj,self.repoFiles,self.projectFiles,self)
end

function FilesScreen:gotFiles(files)
    -- first recreate the schema
    for _,k in ipairs(files) do
        local filename = k.path
        self.repoFiles[filename] = 1
        if self.projectFiles[filename] == nil then
            local cb = function()
                screen = DiffScreen(filename,self.projectFiles[filename],
                    self.repoFiles[filename],self)
            end
            local newElem = {type="SimpleArrow",text=filename,tag=filename,callback=cb}
            table.insert(self.fileSchema,1,newElem)
        end
    end
    
    self:reorder()
    
    -- now get the contents of each file
    local nfiles = #files
    local countFiles = 0
    for _,k in ipairs(files) do
        local filename = k.path

        local cb = function(conts)
            self.repoFiles[filename]=conts
            countFiles = countFiles + 1
            if countFiles == nfiles then 
                self.taggedElems.label:showHourGlass(false)
                self.active = true
            end
            
            local arrow = self.taggedElems[filename]
            local localConts = self.projectFiles[filename]
            if not localConts then
                self:reorder()
            else
                if localConts ~= conts then
                    self:reorder()
                end
            end
        end
        
        GIT_CLIENT:fileContents(k.sha,cb)
    end
end

-- move modified items to the top of the list
function FilesScreen:reorder()
    local added = {}
    local removed = {}
    local changed = {}
    local unch = {}
    for _,elem in ipairs(self.fileSchema) do
        local file = elem.text
        if self.repoFiles[file] == nil then
            table.insert(added,elem)
        elseif self.projectFiles[file] == nil then 
            table.insert(removed,elem)
        elseif self.repoFiles[file] ~= 1 and self.projectFiles[file] ~= self.repoFiles[file] then
            table.insert(changed,elem)
        else
            table.insert(unch,elem)
        end
    end
    
    Table.sort(added,"text")
    Table.sort(removed,"text")
    Table.sort(changed,"text")
    Table.sort(unch,"text")
    
    local newFileSchema = {}
    Table.appendAll(newFileSchema,added)
    Table.appendAll(newFileSchema,removed)
    Table.appendAll(newFileSchema,changed)
    Table.appendAll(newFileSchema,unch)

    -- replace the contents of the file schema
    for i=#self.fileSchema,1,-1 do self.fileSchema[i]=nil end
    for _,elem in ipairs(newFileSchema) do table.insert(self.fileSchema,elem) end
    
    self:rebuild()
    
    local waiting = false
    for _,elem in ipairs(self.fileSchema) do
        local file = elem.text
        local arrow = self.taggedElems[file]
        if self.repoFiles[file] == 1 then waiting = true end
        
        -- added files
        if self.repoFiles[file] == nil then 
            arrow:setColors(color(0,0,255),color(0,0,255))
            arrow:setRightText("Added") 
        elseif self.projectFiles[file] == nil then 
            arrow:setColors(color(255,0,0),color(255,0,0))
            arrow:setRightText("Deleted")
        elseif self.repoFiles[file] ~= 1 and self.projectFiles[file] ~= self.repoFiles[file] then
            arrow:setColors(color(255,255,0),color(255,255,0))
            arrow:setRightText("Changed")
        end
    end
    
    if waiting then self.taggedElems.label:showHourGlass(true) end
end
