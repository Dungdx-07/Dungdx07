-- ============================================================
-- VFX COLOR (chỉ đổi màu skill của BẢN THÂN)
-- ============================================================
local VFXColor={enabled=false,color=Color3.fromRGB(150,80,255),
    processed={},backups={},conns={},toolConns={},hookedTools={},
    previewFrame=nil,previewLabel=nil,
    recentActiveUntil=0,retintList={},retintAcc=0}

local VFX_CLASSES={ParticleEmitter=true,Beam=true,Trail=true,Fire=true,Smoke=true,Sparkles=true,
PointLight=true,SpotLight=true,SurfaceLight=true,Decal=true,Texture=true,
Highlight=true,ImageLabel=true}

local BODY={HumanoidRootPart=true,Head=true,Torso=true,["Left Arm"]=true,["Right Arm"]=true,
["Left Leg"]=true,["Right Leg"]=true,UpperTorso=true,LowerTorso=true,
LeftUpperArm=true,RightUpperArm=true,LeftLowerArm=true,RightLowerArm=true,
LeftUpperLeg=true,RightUpperLeg=true,LeftLowerLeg=true,RightLowerLeg=true,
LeftFoot=true,RightFoot=true,LeftHand=true,RightHand=true}

local function isBodyPart(obj)
    if not obj:IsA("BasePart")then return false end
    if not BODY[obj.Name]then return false end
    local p=obj.Parent
    if p and Players:GetPlayerFromCharacter(p)then return true end
    return false
end

local function isVFXBasePart(obj)
    if not obj:IsA("BasePart")then return false end
    if obj==WS.Terrain then return false end
    if isBodyPart(obj)then return false end
    if obj.Anchored and obj.Transparency==0 then
        local m=obj.Material
        if m==Enum.Material.Plastic or m==Enum.Material.Grass or m==Enum.Material.Wood
        or m==Enum.Material.Concrete or m==Enum.Material.Slate or m==Enum.Material.Brick
        or m==Enum.Material.Cobblestone or m==Enum.Material.Rock or m==Enum.Material.Sand
        or m==Enum.Material.Sandstone or m==Enum.Material.Fabric or m==Enum.Material.Leaves
        or m==Enum.Material.Ground or m==Enum.Material.Asphalt or m==Enum.Material.Salt
        or m==Enum.Material.Limestone or m==Enum.Material.Pavement then return false end
    end
    local m=obj.Material
    if m==Enum.Material.Neon or m==Enum.Material.ForceField or m==Enum.Material.Glass then return true end
    if obj.Transparency>0.05 and obj.Transparency<0.99 then return true end
    for _,c in ipairs(obj:GetChildren())do
        if c:IsA("ParticleEmitter")or c:IsA("Beam")or c:IsA("Trail")
        or c:IsA("Fire")or c:IsA("Smoke")or c:IsA("Sparkles")then return true end
    end
    return false
end

-- Kiểm tra ImageLabel nằm trong BillboardGui/SurfaceGui (thuộc workspace)
local function isGuiVFXImage(obj)
    if not obj:IsA("ImageLabel")then return false end
    local p=obj.Parent
    while p do
        if p:IsA("BillboardGui")or p:IsA("SurfaceGui")then
            -- Kiểm tra GUI này có nằm trong Workspace (không phải PlayerGui)
            local a=p
            while a do
                if a==WS then return true end
                if a:IsA("PlayerGui")or a:IsA("ScreenGui")then return false end
                a=a.Parent
            end
            return false
        end
        p=p.Parent
    end
    return false
end

-- Xác định VFX có thuộc về bản thân không
local function isLocalVFX(obj)
    if not obj or not obj.Parent then return false end
    -- Loại trừ: VFX nằm trong character của player khác
    local anc=obj
    while anc do
        local plr=Players:GetPlayerFromCharacter(anc)
        if plr and plr~=LP then return false end
        anc=anc.Parent
    end
    -- Thuộc character của mình?
    local char=LP.Character
    if char and obj:IsDescendantOf(char)then return true end
    -- Thuộc backpack của mình?
    local bp=LP:FindFirstChild("Backpack")
    if bp and obj:IsDescendantOf(bp)then return true end
    -- VFX spawn trong workspace trong "cửa sổ active" sau khi mình Activated tool
    -- Không giới hạn khoảng cách (nhiều skill spawn xa)
    if tick()<=VFXColor.recentActiveUntil then
        -- Vẫn loại trừ nếu là body part của player khác
        return true
    end
    return false
end

local function remapColor(orig)
    if not orig then return VFXColor.color end
    local h,s,v=Color3.toHSV(orig)
    local uh,us,uv=Color3.toHSV(VFXColor.color)
    if us < 0.15 then
        if uv > 0.5 then return Color3.new(v, v, v) end
        return Color3.new(v*0.3, v*0.3, v*0.3)
    end
    if s < 0.03 then
        return Color3.fromHSV(uh, math.min(us * 0.15, 0.15), v)
    end
    local newS=math.clamp(math.max(us,0.55)*(0.4+s*0.6),0.25,1)
    return Color3.fromHSV(uh,newS,v)
end

local function remapSeq(seq)
    if not seq then return seq end
    local kps={}
    for i=1,#seq.Keypoints do
        local kp=seq.Keypoints[i]
        table.insert(kps,ColorSequenceKeypoint.new(kp.Time,remapColor(kp.Value)))
    end
    return ColorSequence.new(kps)
end

local function backup(obj,prop)
    if not VFXColor.backups[obj]then VFXColor.backups[obj]={}end
    if VFXColor.backups[obj][prop]==nil then
        local ok,v=pcall(function()return obj[prop]end)
        if ok then VFXColor.backups[obj][prop]=v end
    end
end

local function tintObj(obj)
    if not obj or not obj.Parent then return end
    if VFXColor.processed[obj]then return end
    if not isLocalVFX(obj)then return end
    local tinted=false
    pcall(function()
        if obj:IsA("ParticleEmitter")then
            backup(obj,"Color")obj.Color=remapSeq(obj.Color)tinted=true
        elseif obj:IsA("Trail")then
            backup(obj,"Color")obj.Color=remapSeq(obj.Color)tinted=true
        elseif obj:IsA("Beam")then
            backup(obj,"Color")backup(obj,"Color2")
            obj.Color=remapSeq(obj.Color)obj.Color2=remapColor(obj.Color2)tinted=true
        elseif obj:IsA("Fire")then
            backup(obj,"Color")obj.Color=remapColor(obj.Color)tinted=true
        elseif obj:IsA("Smoke")then
            backup(obj,"Color")obj.Color=remapColor(obj.Color)tinted=true
        elseif obj:IsA("Sparkles")then
            backup(obj,"SparkleColor")obj.SparkleColor=remapColor(obj.SparkleColor)tinted=true
        elseif obj:IsA("PointLight")or obj:IsA("SpotLight")or obj:IsA("SurfaceLight")then
            backup(obj,"Color")obj.Color=remapColor(obj.Color)tinted=true
        elseif obj:IsA("Highlight")then
            backup(obj,"FillColor")backup(obj,"OutlineColor")
            obj.FillColor=remapColor(obj.FillColor)
            obj.OutlineColor=remapColor(obj.OutlineColor)
            tinted=true
        elseif obj:IsA("Decal")or obj:IsA("Texture")then
            backup(obj,"Color3")obj.Color3=remapColor(obj.Color3)tinted=true
        elseif obj:IsA("ImageLabel")then
            if isGuiVFXImage(obj)then
                backup(obj,"ImageColor3")
                obj.ImageColor3=remapColor(obj.ImageColor3)
                tinted=true
            end
        elseif obj:IsA("BasePart")then
            if isVFXBasePart(obj)then
                backup(obj,"Color")obj.Color=remapColor(obj.Color)tinted=true
                for _,m in ipairs(obj:GetChildren())do
                    if m:IsA("SpecialMesh")then
                        backup(m,"VertexColor")
                        pcall(function()m.VertexColor=remapColor(m.VertexColor)end)
                    end
                end
            end
        end
    end)
    if tinted then
        VFXColor.processed[obj]=true
        -- Đưa vào danh sách re-tint (8 giây)
        if obj:IsA("BasePart")or VFX_CLASSES[obj.ClassName]then
            VFXColor.retintList[obj]=tick()+8
        end
    end
end

local function onNewObj(obj)
    if not VFXColor.enabled then return end
    if not obj or not obj.Parent then return end
    if VFX_CLASSES[obj.ClassName]then
        task.defer(function()if obj and obj.Parent then tintObj(obj)end end)
        return
    end
    if obj:IsA("BasePart")then
        task.defer(function()if obj and obj.Parent and isVFXBasePart(obj)then tintObj(obj)end end)
        return
    end
    if obj:IsA("Model")or obj:IsA("Folder")then
        task.defer(function()
            if not obj or not obj.Parent then return end
            local ok,kids=pcall(function()return obj:GetDescendants()end)
            if not ok or not kids then return end
            for _,c in ipairs(kids)do
                if VFX_CLASSES[c.ClassName]then tintObj(c)end
            end
        end)
    end
end

-- Chỉ scan character + backpack (VFX thuộc bản thân)
local function scanBatch()
    local roots={}
    if LP.Character then table.insert(roots,LP.Character)end
    local bp=LP:FindFirstChild("Backpack")
    if bp then table.insert(roots,bp)end
    for _,root in ipairs(roots)do
        if not VFXColor.enabled then return end
        local list=root:GetDescendants()
        for _,obj in ipairs(list)do
            if VFXColor.enabled and VFX_CLASSES[obj.ClassName]then tintObj(obj)end
        end
        for _,obj in ipairs(list)do
            if VFXColor.enabled and obj:IsA("BasePart")and isVFXBasePart(obj)then tintObj(obj)end
        end
    end
end

-- Re-tint loop: đối phó với VFX bị server ghi đè màu
local function startRetintLoop()
    VFXColor.retintAcc=0
    return RS.Heartbeat:Connect(function(dt)
        if not VFXColor.enabled then return end
        VFXColor.retintAcc=VFXColor.retintAcc+dt
        if VFXColor.retintAcc<0.4 then return end
        VFXColor.retintAcc=0
        local now=tick()
        for obj,until_ in pairs(VFXColor.retintList)do
            if not obj or not obj.Parent or now>until_ then
                VFXColor.retintList[obj]=nil
            else
                local props=VFXColor.backups[obj]
                if props then
                    for prop,val in pairs(props)do
                        pcall(function()
                            if typeof(val)=="ColorSequence"then
                                obj[prop]=remapSeq(val)
                            elseif typeof(val)=="Color3"then
                                obj[prop]=remapColor(val)
                            end
                        end)
                    end
                end
            end
        end
    end)
end

local function hookTool(t)
    if not t or not t:IsA("Tool")then return end
    if VFXColor.hookedTools[t]then return end
    VFXColor.hookedTools[t]=true
    -- Window 8 giây để bắt VFX spawn trễ
    local c=t.Activated:Connect(function()
        if VFXColor.enabled then VFXColor.recentActiveUntil=tick()+8 end
    end)
    table.insert(VFXColor.toolConns,c)
end

local function hookContainer(container)
    if not container then return end
    for _,c in ipairs(container:GetChildren())do hookTool(c)end
    table.insert(VFXColor.toolConns,container.ChildAdded:Connect(function(child)hookTool(child)end))
end

local function startVFX()
    if VFXColor.enabled then return end
    VFXColor.enabled=true
    VFXColor.processed={}
    VFXColor.backups={}
    VFXColor.conns={}
    VFXColor.toolConns={}
    VFXColor.hookedTools={}
    VFXColor.recentActiveUntil=0
    VFXColor.retintList={}
    task.spawn(scanBatch)
    table.insert(VFXColor.conns,WS.DescendantAdded:Connect(onNewObj))
    table.insert(VFXColor.conns,startRetintLoop())
    if LP.Character then hookContainer(LP.Character)end
    local bp=LP:FindFirstChild("Backpack")
    if bp then hookContainer(bp)end
    table.insert(VFXColor.toolConns,LP.ChildAdded:Connect(function(c)
        if c.Name=="Backpack"and VFXColor.enabled then hookContainer(c)end
    end))
    table.insert(VFXColor.toolConns,LP.CharacterAdded:Connect(function(ch)
        task.wait(0.3)
        if VFXColor.enabled then hookContainer(ch)end
    end))
    print("[VFX] Started (self only, 8s window, retint)")
end

local function stopVFX()
    VFXColor.enabled=false
    for _,c in ipairs(VFXColor.conns)do pcall(function()c:Disconnect()end)end
    VFXColor.conns={}
    for _,c in ipairs(VFXColor.toolConns)do pcall(function()c:Disconnect()end)end
    VFXColor.toolConns={}
    VFXColor.hookedTools={}
    for obj,props in pairs(VFXColor.backups)do
        if obj and obj.Parent then
            for prop,val in pairs(props)do pcall(function()obj[prop]=val end)end
        end
    end
    VFXColor.backups={}
    VFXColor.processed={}
    VFXColor.retintList={}
    print("[VFX] Stopped")
end

local function reapplyVFX()
    if not VFXColor.enabled then return end
    for obj,props in pairs(VFXColor.backups)do
        if obj and obj.Parent then
            for prop,val in pairs(props)do pcall(function()obj[prop]=val end)end
        end
    end
    VFXColor.backups={}
    VFXColor.processed={}
    VFXColor.retintList={}
    task.spawn(scanBatch)
end

local function updateVFXPreview()
    if VFXColor.previewFrame and VFXColor.previewFrame.Parent then
        VFXColor.previewFrame.BackgroundColor3=VFXColor.color
    end
    if VFXColor.previewLabel and VFXColor.previewLabel.Parent then
        local c=VFXColor.color
        VFXColor.previewLabel.Text=string.format("#%02X%02X%02X",
            math.floor(c.R*255+.5),math.floor(c.G*255+.5),math.floor(c.B*255+.5))
    end
end