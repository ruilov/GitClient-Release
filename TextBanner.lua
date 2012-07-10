-- TextBanner.lua

-- TextBanner is a text elem with a background
-- supported background types are round,square,back (for back buttons),bottomRound,topRound

TextBanner = class(RectObj)

function TextBanner:init(text,x,y,w,h,args)
    RectObj.init(self,x,y,w,h)

    args = args or {}
    args.text = args.text or {}
    args.text.textMode = args.text.textMode or CENTER
    args.text.fill = args.text.fill or color(0,0,0,255)
    args.text.fontSize = args.text.fontSize or 28

    self.type = args.type or "round"
    local tx = w/2
    local ty = h/2
    
    if self.type == "back" then 
        tx = tx + 3 
        ty = ty + 2
    end

    self.textElem = TextElem(text,tx,ty,args.text)

    self.topColor = args.topColor or color(255, 255, 255, 255) 
    self.bottomColor = args.bottomColor or color(255,255,255,255)

    self.myMesh = mesh()
    self.vertColors = {}
    self:moveCB()
end

function TextBanner:moveCB()
    self.verts = self:createVerts()
    self.myMesh.vertices = triangulate(self.verts)
    self:recolor()
end

-- for a translation we don't have to call moveCB so let's overwrite that
-- method. This saves a lot of speed
function TextBanner:translate(dx,dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function TextBanner:draw()
    pushMatrix()
    pushStyle()
    translate(self.x,self.y)
    
    -- draw the background
    self.myMesh:draw()

    -- draw the text
    self.textElem:draw()
    
    -- draw the border
    self:drawLines(self.verts)
    popStyle()
    popMatrix()
end

function TextBanner:createVerts()
    local w,h = self.w,self.h 
    local v = {}
    if w == 0 then return v end
    
    local r = 1    
    if self.type == "round" then    
        v[1] = vec2(w,6*r)
        v[2] = vec2(w-r,4*r)
        v[3] = vec2(w-2*r,2*r)
        v[4] = vec2(w-4*r,r)
        v[5] = vec2(w-6*r,0)
        
        v[6] = vec2(6*r,0)
        v[7] = vec2(4*r,r)
        v[8] = vec2(2*r,2*r)
        v[9] = vec2(r,4*r)
        v[10] = vec2(0,6*r)
        
        v[11] = vec2(0,h-6*r)
        v[12] = vec2(r,h-4*r)
        v[13] = vec2(2*r,h-2*r)
        v[14] = vec2(4*r,h-r)
        v[15] = vec2(6*r,h)
        
        v[16] = vec2(w-6*r,h)
        v[17] = vec2(w-4*r,h-r)
        v[18] = vec2(w-2*r,h-2*r)
        v[19] = vec2(w-r,h-4*r)
        v[20] = vec2(w,h-6*r)
    elseif self.type == "bottomRound" then
        v[1] = vec2(w,6*r)
        v[2] = vec2(w-r,4*r)
        v[3] = vec2(w-2*r,2*r)
        v[4] = vec2(w-4*r,r)
        v[5] = vec2(w-6*r,0)
        
        v[6] = vec2(6*r,0)
        v[7] = vec2(4*r,r)
        v[8] = vec2(2*r,2*r)
        v[9] = vec2(r,4*r)
        v[10] = vec2(0,6*r)
        
        v[11] = vec2(0,h)
        v[12] = vec2(w,h)
    elseif self.type == "topRound" then
        v[1] = vec2(w,0)
        v[2] = vec2(0,0)
        
        v[3] = vec2(0,h-6*r)
        v[4] = vec2(r,h-4*r)
        v[5] = vec2(2*r,h-2*r)
        v[6] = vec2(4*r,h-r)
        v[7] = vec2(6*r,h)
        
        v[8] = vec2(w-6*r,h)
        v[9] = vec2(w-4*r,h-r)
        v[10] = vec2(w-2*r,h-2*r)
        v[11] = vec2(w-r,h-4*r)
        v[12] = vec2(w,h-6*r)
    elseif self.type == "back" then
        v[1] = vec2(w,0)
        v[2] = vec2(14,0)
        v[3] = vec2(0,math.floor(h/2))
        v[4] = vec2(14,h)
        v[5] = vec2(w,h)
    elseif self.type == "arrowRight" then
        v[1] = vec2(0,0)
        v[2] = vec2(w,math.floor(h/2))
        v[3] = vec2(0,h)
    elseif self.type == "arrowLeft" then
        v[1] = vec2(w,0)
        v[2] = vec2(0,math.floor(h/2))
        v[3] = vec2(w,h)
    else
        v[1] = vec2(w,0)
        v[2] = vec2(0,0)
        v[3] = vec2(0,h)
        v[4] = vec2(w,h)
    end
    
    return v
end

function TextBanner:drawLines(v)
    noSmooth()
    strokeWidth(1)
    stroke(143, 143, 143, 255)
    lineCapMode(PROJECT)
    for i=1, #v do
        local nextI = i%(#v)+1
        line(v[i].x,v[i].y,v[nextI].x,v[nextI].y)
    end
end

function TextBanner:recolor()
    --print(#self.myMesh.vertices,3 * #self.verts - 6)
    for i=1,#self.myMesh.vertices do
        if self.myMesh.vertices[i].y > self.h/2 then
            self.vertColors[i] = self.topColor
        else
            self.vertColors[i] = self.bottomColor
        end
    end
    self.myMesh.colors = self.vertColors
end
