-- RepoScreen.lua
-- in the repo screen the user will enter the name of a codea project and
-- a repo. So this screen knows how to list GitHub repos

RepoScreen = class(AppleScreen)

function RepoScreen:init(prevScreen)
    local schema = {
        title = "Repos",
        backButton = {
            text = prevScreen.schema.title,
            callback = function() screen = prevScreen end,
        },
        elems = {
            {type="block",elems = {
                {type="TextInput",label="Project",shadowText = "codea project",tag="project"},
            }},
            {type="blank",amount=20},
            {type="text",text="Repos for "..GIT_CLIENT.username,tag="label"},
            {type="blank",amount = 5},
            {type="block",elems = {}},
        }
    }
    AppleScreen.init(self,schema)
    
    self.taggedElems.label:showHourGlass(true)
    
    -- now send a request for the repos
    local failcb = function(err)
        self.taggedElems.label:showHourGlass(false)
        print("FAILED\n",err)
    end
    GIT_CLIENT:listRepos(function(repos) self:listReposCB(repos) end, failcb)
end

function RepoScreen:listReposCB(repos)
    local lastBlock = self.schema.elems[#self.schema.elems]
    
    for _,repo in ipairs(repos) do
        local cb = function()
            -- clean out status on all repos
            for _,r in ipairs(repos) do
                self.taggedElems[r.name]:setRightText("")
            end
            
            -- retrieve the project name
            local projBox = self.taggedElems.project.textbox
            local projName = projBox.text
            if projBox.textIsShadow then projName = "" end

            -- see if the project exists
            if not ProjectLoader.exists(projName) then
                self.taggedElems[repo.name]:setRightText("Codea project above not found")
                return nil
            end
            
            IO.addQuickLink(repo.name,projName,GIT_CLIENT.username)
            screen = CommitsScreen(repo.name,projName,3,self)
        end
        
        local newElem = {type="SimpleArrow",text=repo.name,callback=cb,tag=repo.name}
        table.insert(lastBlock.elems,newElem)
    end
    
    -- note this also gets rid of the hour glass in the label
    self:rebuild()
end
