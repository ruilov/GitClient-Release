supportedOrientations(LANDSCAPE_ANY)

-- Main.lua
function setup()
    --watch("at")
    --clearLocalData()
    --TOUCHES = {}
    screen = StartScreen()
    
    local username = IO.loadUsername()
    if username then
        GIT_CLIENT = GitClient(username)
    else
        GIT_CLIENT = GitClient("")
    end
end

function draw()
    --at = ElapsedTime
    
    background(0)
    screen:draw()
    if GLOBAL_SHOWKEYBOARD then
        GLOBAL_SHOWKEYBOARD = nil
        showKeyboard()
    end
    --[[
    pushStyle() 
    noStroke()
    ellipseMode(CENTER)
    local newTouches = {}
    local lifeT = .3
    for _,elem in ipairs(TOUCHES) do
        local dt = ElapsedTime - elem.time
        local alpha = math.max((1-dt/lifeT),0)*255
        fill(255, 0, 0, alpha)
        ellipse(elem.touch.x,elem.touch.y,50,50)
        
        if dt < lifeT then
            table.insert(newTouches,elem)
        end
    end
    TOUCHES = newTouches
    popStyle()
    --]]
end

function touched(t)
    --table.insert(TOUCHES,{touch=t,time=ElapsedTime})
    screen:touched(t)
end

function keyboard(key)
    if screen.keyboard then screen:keyboard(key) end
end
