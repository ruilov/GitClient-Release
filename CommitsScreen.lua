-- CommitsScreen.lua

CommitsScreen = class(AppleScreen)

function CommitsScreen:init(repo,proj,maxCommits,prevScreen)
    self.commitElems = {}
    self.commitData = {}
    self.repo = repo
    self.proj = proj
    self.maxCommits = maxCommits
    local username = GIT_CLIENT.username
    
    local schema = {
        title = "Versions",
        backButton = {
            text = prevScreen.schema.title,
            callback = function() screen = prevScreen end,
        },
        elems = {
            {type="text",text = "@"..username.."'s "..repo.." / "..proj, tag = "label"},
            {type="blank",amount=40}
        }
    }

    AppleScreen.init(self,schema)
    self.taggedElems.label:showHourGlass(true)
    
    GIT_CLIENT:setReponame(repo)
    GIT_CLIENT:listCommits(function(c) self:commitsCB(c) end)
end

function CommitsScreen:commitsCB(commits)
    self.commits = commits
    
    -- only send a few commit requests at a time
    local topCommits = Table.sub(commits,1,1)
    self.currentIdx = #topCommits
    for _,commit in ipairs(topCommits) do
        GIT_CLIENT:getCommit(commit.sha,function(c) self:commitDataCB(c) end)
    end
end

function CommitsScreen:commitDataCB(commit)
    -- parse the date/time for this commit
    --2012-06-01T18:04:49-07:00
    local dateStr = commit.commit.committer.date
    local pack = function(...) return arg end
    local dateToks = pack(dateStr:match("(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)"))
    dateToks = Table.map(tonumber,dateToks)
    local date = {year=dateToks[1],month=dateToks[2],day=dateToks[3],hour=dateToks[4],
        minute=dateToks[5],seconds=dateToks[6]}
    date.commit = commit
    date.str = dateStr
    table.insert(self.commitData,date)
    
    -- resort all commits because although they are in order in the commits list
    -- we may get the http answer out of order
    Table.sort(self.commitData,"-year","-month","-day","-hour","-minute","-seconds")
    local schemaElems = {self.schema.elems[1],self.schema.elems[2]}
    for _,elem in ipairs(self.commitData) do
        local label = "@"..elem.commit.commit.committer.name.." at "
        label = label..elem.month.."/"..elem.day.."/"..elem.year.." "
        local min = elem.minute..""
        if min:len() == 1 then min = "0"..min end
        local sec = elem.seconds..""
        if sec:len() == 1 then sec = "0"..sec end
        label = label..elem.hour..":"..min..":"..sec
        table.insert(schemaElems,{type="text",text=label})
        table.insert(schemaElems,{type="blank",amount=5})
        
        local maxS = 60
        local label = elem.commit.commit.message
        if label:len() > maxS then label = label:sub(1,maxS-3).."..." end
        table.insert(schemaElems,{type="block",elems={{type="SimpleArrow",text=label,
            callback = function() self:chosen(elem.commit) end}}})
        table.insert(schemaElems,{type="blank",amount=20})
    end
    
    self.schema.elems=schemaElems
    self:rebuild()
    
    -- send a new commit request
    if self.currentIdx < math.min(#self.commits,self.maxCommits) then
        self.currentIdx = self.currentIdx + 1
        GIT_CLIENT:getCommit(self.commits[self.currentIdx].sha,
            function(c) self:commitDataCB(c) end)
        -- keep the hour glass
        self.taggedElems.label:showHourGlass(true)
    elseif self.currentIdx >= self.maxCommits and self.currentIdx < #self.commits then
        -- add a view all button
        local allCB = function()
            -- remove the view more button and the extra blank we added
            schemaElems = Table.sub(schemaElems,1,#schemaElems-2)
            self.schema.elems = schemaElems
            self:rebuild()
            
            self.currentIdx = self.currentIdx + 1            
            self.maxCommits = self.maxCommits + 5
            GIT_CLIENT:getCommit(self.commits[self.currentIdx].sha,
                function(c) self:commitDataCB(c) end)
            -- show the hour glass again
            self.taggedElems.label:showHourGlass(true)
        end
        
        local newElem = {type="block",elems={
            {type="SimpleArrow",text="View more",callback=allCB}
        }}
        table.insert(schemaElems,{type="blank",amount=20})
        table.insert(schemaElems,newElem)
        self.schema.elems = schemaElems
        self:rebuild()
    end
end

function CommitsScreen:chosen(commit)
    screen = FilesScreen(self.repo,self.proj,commit,self)
end
