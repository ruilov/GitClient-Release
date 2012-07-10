-- ProjectLoader.lua

ProjectLoader = class()

function ProjectLoader.exists(projectName)
    local d = "Info.plist"
    local v = ProjectLoader.read(d,projectName,true)
    return (v~=nil)
end

function ProjectLoader.readAll(projectName)
    local files = ProjectLoader.list(projectName)
    local contents = {}
    for _,file in ipairs(files) do
        contents[file] = ProjectLoader.read(file,projectName)
    end
    return contents
end

function ProjectLoader.read(filename,projectName,retNil)
    local home = os.getenv("HOME")
    local dir = home.."/Documents/"..projectName..".codea/"
    local fname = dir..filename
    local info_file = io.open(fname,"r")
    if info_file == nil and retNil then return nil end
    
    assert(info_file~=nil,"Could not open "..fname.." in "..projectName)
    local contents = ""
    for lin in io.lines(fname) do
        contents = contents..lin.."\n"
    end
    return contents
end

function ProjectLoader.list(projectName)
    local info_fname = "Info.plist"
    local contents = ProjectLoader.read(info_fname,projectName)
    
    -- find the buffer order
    local bufferKey = "<key>Buffer Order</key>"
    local idx = contents:find(bufferKey)
    assert(idx~=nil,"Could not find buffer order in "..info_fname.." in "..projectName)
    contents = contents:sub(idx)
    
    -- find the end of the buffer order
    local idx2 = contents:find("</array>")
    assert(idx2~=nil,"Could not find the end of the buffer order in "..info_fname.." in "..projectName)
    contents = contents:sub(1,idx2)
    
    local buffers = {}
    for buff in contents:gmatch("<string>([%a%s%d]+)</string>") do
        table.insert(buffers,buff..".lua")
    end
    table.insert(buffers,info_fname)
    
    -- does data plist exist?
    local d = "Data.plist"
    local v = ProjectLoader.read(d,projectName,true)
    if v then table.insert(buffers,d) end
    return buffers
end

function ProjectLoader.save(fileContents,projectName)
    local home = os.getenv("HOME")
    local dir = home.."/Documents/"..projectName..".codea/"
    
    for filename,conts in pairs(fileContents) do
        local fname = dir..filename
        local file = assert(io.open(fname,"w"))
        --print(fname,file)
        file:write(conts)
        file:close()
    end
end
