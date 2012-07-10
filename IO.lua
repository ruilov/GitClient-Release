IO = class()

function IO.saveUsername(username)
    saveLocalData("username",username)
end

function IO.loadUsername()
    return readLocalData("username")
end

function IO.addQuickLink(repo,proj,user)
    local links = IO.getQuickLinks()
    
    -- see if this link already exists, and if so, move it up to the start
    for idx,elem in ipairs(links) do
        if elem.proj == proj and elem.repo == repo and elem.user == user then
            table.remove(links,idx)
            table.insert(links,1,elem)
            local newLinks = Json.Encode(links)
            saveLocalData("quickLinks",newLinks)
            return nil
        end
    end
    
    -- if we get here it's because this elem doesn't exist yet
    local elem = {proj=proj,repo=repo,user=user}
    table.insert(links,1,elem)
    local newLinks = Json.Encode(links)
    saveLocalData("quickLinks",newLinks)
end

function IO.getQuickLinks()
    local links = readLocalData("quickLinks")
    if not links then links = "[]" end
    local links = Json.Decode(links)
    return links
end
