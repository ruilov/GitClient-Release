-- StartScreen.lua
-- set the username and sync projects from quick links

StartScreen = class(AppleScreen)

function StartScreen:init()
    local quickLinks = IO.getQuickLinks()
    quickLinks = Table.sub(quickLinks,1,30)
    
    local quickElems = {}
    for _,link in ipairs(quickLinks) do
        local elemCB = function()
            IO.addQuickLink(link.repo,link.proj,link.user)
            screen = CommitsScreen(link.repo,link.proj,3,self)
        end
        local elem = {type="SimpleArrow",
            text = "@"..link.user.."'s "..link.repo.." / "..link.proj,
            callback = elemCB
        }
        table.insert(quickElems,elem)
    end
    
    if #quickElems > 0 then
        quickElems={{type="block",elems=quickElems}}
        table.insert(quickElems,1,{type="text",text="Quick links"})
        table.insert(quickElems,2,{type="blank",amount=5})
    end  
    
    local schema = {
        title = "Menu",
        elems = {
            {type="text",text="Gitty: a GitHub client for codea"},
            {type="blank",amount = 40},
            {type="block",elems = {
                {type="TextInput",label="Username",startText=IO.loadUsername(),
                    shadowText = "GitHub username",
                    keycallback = function(str)
                        IO.saveUsername(str)
                        GIT_CLIENT:setUsername(str)
                    end},
                {type="SimpleArrow",text="OK",callback = function() 
                    screen = RepoScreen(self)
                end},
            }},
            {type="blank",amount=30}
        }
    }
    Table.appendAll(schema.elems,quickElems)
    AppleScreen.init(self,schema)
end
