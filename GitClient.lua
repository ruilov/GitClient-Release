-- GitClient.lua

GitClient = class()

local BASE_URL = "https://api.github.com/"

function GitClient:init(username,password)
    assert(username~=nil,"nil username")
    if password then
        self.authorization = "Basic "..Base64.encode(username..":"..password)
    end
    self.username = username
end

function GitClient:setUsername(username)
    if username ~= self.username then
        self.authorization = nil
        self.username = username
    end
end

function GitClient:setPassword(password)
    --print("setting password",password,"end")
    self.authorization = "Basic "..Base64.encode(self.username..":"..password)
end

function GitClient:removePassword()
    self.authorization = nil
end

function GitClient:setReponame(reponame)
    self.reponame = reponame
end

function GitClient:listRepos(cb,failcb)
    local r = {
        url = BASE_URL.."users/"..self.username.."/repos",
        callback = function(json,status,header)
            if failcb and status ~= 200 then
                failcb(json)
                return nil
            end
            assert(status==200,"failed to retrieve repo list for "..self.username)
            local repos = Json.Decode(json)
            cb(repos)
        end,
        failcb = function(err)
            if failcb then failcb(err) end
        end
    }
    self:submitRequest(r)
end

-- commit is optional, in which case it will list the master branch
function GitClient:listFiles(cb,failcb,commit)
    -- get the actual tree from the tree obj
    local cb3 = function(tree)
        cb(tree.tree)
    end
    
    -- get the tree from the commit
    local cb2 = function(commit)
        self:getTree(commit.commit.tree.sha,cb3)
    end
    
    -- get the commit from the master branch
    local cb1 = function(branch)
        self:getCommit(branch.commit.sha,cb2)
    end
    
    if commit == nil then
        self:getMasterBranch(cb1,failcb)
    else
        cb2(commit)
    end
end

function GitClient:fileContents(sha,cb)
    self:getSha(sha,"git/blobs/",cb,true) -- true for raw
end

-- contents is a table mapping file names to their new contents
-- note that anything that is not in the contents will be erased from the repo
function GitClient:commit(contents,todelete,message,cb,failcb)
    local old_commit_sha = nil
    local new_commit_sha = nil
    local new_tree_sha = nil
    
    -- user callback
    local cb5 = function(data)
        cb({tree=new_tree_sha,commit=new_commit_sha})
    end
    
    -- update the master reference to the new commit
    local cb4 = function(new_commit)
        new_commit_sha = new_commit.sha
        self:updateMasterRef(new_commit.sha,cb5)
    end
    
    -- create the new commit object
    local cb3 = function(new_tree)
        new_tree_sha = new_tree.sha
        self:createCommit(message,new_tree.sha,old_commit_sha,todelete,cb4)
    end
    
    -- get the tree from the commit
    local cb2 = function(commit)
        --print("going to create tree")
        --print("commit",commit.commit.tree.sha)
        self:createTree(commit.commit.tree.sha,contents,cb3)
    end
    
    -- get the commit from the master branch
    local cb1 = function(branch)
        --print("going to get master commit")
        old_commit_sha = branch.commit.sha
        self:getCommit(branch.commit.sha,cb2)
    end
    
    --print("going to get master branch")
    self:getMasterBranch(cb1,failcb)
end

function GitClient:getMasterBranch(cb,failcb)
    assert(self.reponame~=nil,"trying to get master branch without setting the repo")
    local r = {
        url = BASE_URL.."repos/"..self.username.."/"..self.reponame.."/branches",
        callback = function(json,status,header)
            --print("got master branch callback")
            if failcb and status ~= 200 then
                failcb(json)
                return nil
            end
            --assert(status==200,"failed to retrieve branch list for "..self.reponame)
            local branches = Json.Decode(json)
            for _,branch in ipairs(branches) do
                if branch.name == "master" then
                    master = branch
                    break
                end
            end
            
            assert(master~=nil,"could not find master branch for "..self.reponame)
            cb(master)
        end,
        failcb = function(err)
            if failcb then failcb(err) end
        end
    }
    self:submitRequest(r)
end

function GitClient:createTree(base_tree,contents,cb)
    assert(self.reponame~=nil,"trying to create a tree without setting the repo")
    
    local inputs = {base_tree = base_tree,tree={}}
    --print("base = ",base_tree)
    for file,conts in pairs(contents) do
        --print("FILE = "..file)
        table.insert(inputs.tree,{path=file,content=conts})
    end
    
    --[[
    for _,file in ipairs(todelete) do
        print(file)
        table.insert(inputs.tree,{path=file,content=Json.Null()})
    end
    --]]
    
    local r = {
        url = BASE_URL.."repos/"..self.username.."/"..self.reponame.."/git/trees",
        method = "POST",
        authorization = true,
        inputs = inputs,
        callback = function(data,status,header)
            --print(status,data,header)
            assert(status==201,"failed to create tree in "..self.reponame)
            cb(Json.Decode(data))
        end
    }
    r.headers = {}
    r.headers["Content-Type"] = "application/json"
    self:submitRequest(r)
end

function GitClient:createCommit(message,tree_sha,parent_sha,todelete,cb)
    assert(self.reponame~=nil,"trying to create a tree without setting the repo")

    local inputs = {message=message,tree=tree_sha,parents={parent_sha}}
    
    --[[
    print("todelete in createcommit")
    inputs.files = {}
    for _,f in ipairs(todelete) do 
        print(f)
        table.insert(inputs.files,{status="removed",filename=f})
    end
    --]]
    
    local r = {
        url = BASE_URL.."repos/"..self.username.."/"..self.reponame.."/git/commits",
        method = "POST",
        authorization = true,
        inputs = inputs,
        callback = function(data,status,header)
            --print(status,data)
            assert(status==201,"failed to create commit in "..self.reponame)
            cb(Json.Decode(data))
        end
    }
    r.headers = {}
    r.headers["Content-Type"] = "application/json"
    self:submitRequest(r)
end

function GitClient:listCommits(cb,failcb)
    local r = {
        url = BASE_URL.."repos/"..self.username.."/"..self.reponame.."/commits",
        callback = function(json,status,header)
            if failcb and status ~= 200 then
                failcb(json)
                return nil
            end
            assert(status==200,"failed to retrieve commit list for "..self.reponame)
            local commits = Json.Decode(json)
            cb(commits)
        end,
        failcb = function(err)
            if failcb then failcb(err) end
        end
    }
    self:submitRequest(r)
end

function GitClient:updateMasterRef(commit_sha,cb)
    assert(self.reponame~=nil,"trying to create a tree without setting the repo")
    
    local r = {
        url = BASE_URL.."repos/"..self.username.."/"..self.reponame.."/git/refs/heads/master",
        method = "POST",
        authorization = true,
        inputs = {sha=commit_sha,force=true},
        callback = function(data,status,header)
            --print(commit_sha)
            --print(status,data)
            assert(status==200,"failed to update reference in "..self.reponame)
            cb(data)
        end
    }
    self:submitRequest(r)
end

function GitClient:getCommit(sha,cb)
    self:getSha(sha,"commits/",cb)
end

function GitClient:getTree(sha,cb)
    self:getSha(sha,"git/trees/",cb)
end

function GitClient:getSha(sha,path,cb,raw)    
    assert(self.reponame~=nil,"trying to get "..path.." without setting the repo")
    
    if raw then headers = {Accept="application/vnd.github.v3.raw"}
    else headers = {} end
    
    local r = {
        url = BASE_URL.."repos/"..self.username.."/"..self.reponame.."/"..path..sha,
        headers = headers,
        callback = function(json,status,header)
            --print("in callback")
            assert(status==200,"failed to retrieve "..path.." "..sha)
            local val = json
            if not raw then val = Json.Decode(json) end
            cb(val)
        end
    }
    self:submitRequest(r)
end

-- PRIVATE METHODS

-- req should have at least url and callback
-- optional cpnts: method, inputs (a table used only for post requests) and headers (table)
-- if req has authorization then
function GitClient:submitRequest(req)
    local method = req.method or "GET"
    local inputs = ""
    
    if req.inputs then
        inputs = Json.Encode(req.inputs)
    end
    
    local headers = req.headers or {}
    if self.authorization then
        headers.Authorization = self.authorization
    else 
        assert(req.authorization==nil,"this requests needs authorization")
    end

    --print("submitting request ",headers.Authorization)
    http.get(req.url,req.callback,req.failcb,{
        method = method,
        headers = headers,
        data = inputs
    })
    
    --[[
    print("sent request")
    print("url = "..req.url)
    print("method = "..method)
    print("data = "..inputs)
    print("headers")
    for c,v in pairs(headers) do print(c.." = "..v) end
    print("")
    --]]
    
    --req.callback()
end
