-- This file is loaded before any user scripts, removing unsafe environment functions

------------------------------------------------
-- Block out any dangerous or insecure functions
------------------------------------------------

arg=nil

__loadedProjects = {}
import = function(projectName)
	if NO_IMPORT then return nil end
	
	if __loadedProjects[projectName] then return nil end -- prevents re-loading of a project
	__loadedProjects[projectName]=1
	
    -- load Info.plist
    local home = os.getenv("HOME")
    local dir = home.."/Documents/"..projectName..".codea/"
    local info_fname = dir.."Info.plist"
    local info_file = io.open(info_fname,"r")
    assert(info_file~=nil,"Could not open "..info_fname.." in "..projectName)
    local contents = ""
    for line in io.lines(info_fname) do
        contents = contents..line.."\n"
    end
    
    -- find the buffer order
    local bufferKey = "<key>Buffer Order</key>"
    local idx = contents:find(bufferKey)
    assert(idx~=nil,"Could not find buffer order in "..info_fname.." in "..projectName)
    contents = contents:sub(idx)
    
    -- find the end of the buffer order
    local idx2 = contents:find("</array>")
    assert(idx2~=nil,"Could not find the end of the buffer order in "..info_fname.." in "..projectName)
    contents = contents:sub(1,idx2)
    
    -- fin the buffer names
    local buffers = {}
    for buff in contents:gmatch("<string>([%a%s%d]+)</string>") do
        table.insert(buffers,buff)
    end
    
    -- load each buffer
    for _,buff in ipairs(buffers) do
        local buff_fname = dir..buff..".lua"
        local f = loadfile(buff_fname)
		assert(f~=nil,"Could not load file "..buff..".lua in "..projectName)
        f()
    end
end

--[[
rawget=nil
rawset=nil
rawequal=nil
setfenv=nil
getfenv=nil
string.dump=nil
dofile=nil
io={write=io.write}

load=nil
loadfile=nil

os.execute=nil
os.getenv=nil
os.remove=nil
os.rename=nil
os.tmpname=nil
os.exit=nil
--]]
--[[
-- We allow:
os.time
os.setlocale
os.difftime
os.date
os.clock
--]]
--[[
package.loaded.io=io
package.loaded.package=nil
package=nil
require=nil
--]]