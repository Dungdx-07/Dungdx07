--[[
DUNGDX PVP — BLOX FRUITS EDITION v2.3.0 BF
Owner: Dungdx | Discord: https://discord.gg/Hwwa3VYxW6
RightShift = UI | DX = toggle | MCR = Macro/Stop
--]]

local Services = setmetatable({}, {__index = function(self, n)
    local ok, s = pcall(game.GetService, game, n)
    if ok and s then rawset(self, n, s) return s end
end})

local Players           = Services.Players
local RunService        = Services.RunService
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace         = Services.Workspace
local UserInputService  = Services.UserInputService
local VirtualInputManager = Services.VirtualInputManager
local StarterGui        = Services.StarterGui

local LP         = Players.LocalPlayer
local Backpack   = LP:WaitForChild("Backpack")
local PlayerGui  = LP:WaitForChild("PlayerGui")
local Camera     = Workspace.CurrentCamera

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Net     = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local reRegisterAttack, reShootGunEvent
pcall(function()
    reRegisterAttack = Net:WaitForChild("RE/RegisterAttack")
    reShootGunEvent  = Net:FindFirstChild("RE/ShootGunEvent")
    local CU = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CombatUtil"))
    if CU and CU.CanAttack and hookfunction then
        hookfunction(CU.CanAttack, function() return true end)
    end
end)

-- ==================== CONFIG ====================
local Config = {
    Brand = { Owner="Dungdx", Discord="https://discord.gg/Hwwa3VYxW6", Name="Dungdx PvP", Version="2.3.0 BF" },
    UI = { ToggleKey=Enum.KeyCode.RightShift, MainSize=UDim2.fromOffset(640, 440), Scale=1.0 },
    Combat = {
        Aim = {
            Enabled     = false,
            TargetMode  = "FOV",
            FOVCircle   = false,
            FOVSize     = 200,
            MaxDistance = 500,
            Target      = "Auto",
            TeamCheck   = true,
        },
        Smoothness      = 0.18,
        AutoAttack      = true,
        AutoAttackRange = 30,
        AttackInterval  = 0.15,
        FastAttackDelay = 0,
    },
    Visual = { ESPEnabled=true, ShowNames=true, ShowDistance=true, ShowFOV=true, ShowHealth=true },
    Movement = {
        JumpBoost  = { Enabled=false, Power=50 },
        SpeedBoost = { Enabled=false, Speed=50 },
        DashBoost  = { Enabled=false, Power=85, Key=Enum.KeyCode.Q, Cooldown=1.2 },
        WaterWalk  = { Enabled=false },
        Limits = { Jump={Min=1,Max=500}, Speed={Min=1,Max=500}, Dash={Min=1,Max=500} },
        Base   = { WalkSpeed=16, JumpPower=50 },
    },
    Macro = {
        Default = {
            {Action="C",Hold=0.00,Delay=0.30},{Action="X",Hold=0.00,Delay=1.00},
            {Action="Z",Hold=0.00,Delay=0.59},{Action="Z",Hold=0.00,Delay=1.23},
            {Action="F",Hold=0.00,Delay=0.44},{Action="C",Hold=0.60,Delay=1.25},
            {Action="X",Hold=0.00,Delay=0.25},{Action="Z",Hold=0.00,Delay=0.50},
        },
        Loop = false,
    },
}

local State = {
    Visible=true, Tab="Combat",
    ESP=Config.Visual.ESPEnabled, FOV=Config.Visual.ShowFOV,
    AutoAttack=Config.Combat.AutoAttack, Macro=false,
    Status="Sẵn sàng", LastDash=0, LastAttack=0,
}

-- ==================== UTIL ====================
local U = {}
function U.GetRoot(ch) return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart) end
function U.GetHum(ch) return ch and ch:FindFirstChildOfClass("Humanoid") end
function U.Alive(p)
    local ch = p.Character; if not ch then return end
    local h=U.GetHum(ch); local r=U.GetRoot(ch)
    if h and r and h.Health>0 then return ch,h,r end
end
function U.Notify(t,x,d) pcall(function()
    StarterGui:SetCore("SendNotification",{Title=t or "Dungdx",Text=x or "",Duration=d or 5})
end) end
function U.EquipMelee()
    if not Backpack then return end
    local hum=U.GetHum(LP.Character); if not hum then return end
    for _,t in ipairs(Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip=="Melee" then hum:EquipTool(t) return end
    end
end

-- ==================== FAST ATTACK ====================
local FA = {}
function FA.Attack(target)
    local c=LP.Character; if not c then return end
    local hum=U.GetHum(c); if not hum or hum.Health<=0 then return end
    local now=tick()
    if now-State.LastAttack<Config.Combat.AttackInterval then return end
    State.LastAttack=now
    local tool=c:FindFirstChildOfClass("Tool")
    if not tool then U.EquipMelee(); tool=c:FindFirstChildOfClass("Tool") end
    if not tool then return end
    if reRegisterAttack then pcall(function() reRegisterAttack:FireServer(Config.Combat.FastAttackDelay) end) end
    if tool:FindFirstChild("LeftClickRemote") then
        pcall(function() tool.LeftClickRemote:FireServer(Vector3.new(0.01,-500,0.01),1,true) end)
    end
    if tool.ToolTip=="Gun" and reShootGunEvent then
        local _,_,r=U.Alive(target)
        if r then pcall(function() reShootGunEvent:FireServer(r.Position,{}) end) end
    end
end

-- ==================== TARGET CONTROLLER ====================
local TargetController = {}
TargetController._currentTarget = nil

function TargetController.TeamCheck(p)
    if not Config.Combat.Aim.TeamCheck then return true end
    if p == LP then return false end
    if LP.Team and p.Team and LP.Team == p.Team then return false end
    return true
end

function TargetController.DistanceCheck(theirRoot)
    if not theirRoot then return false end
    local d = (Camera.CFrame.Position - theirRoot.Position).Magnitude
    return d <= Config.Combat.Aim.MaxDistance
end

function TargetController.FOVCheck(theirRoot)
    if Config.Combat.Aim.TargetMode ~= "FOV" then return true end
    if not theirRoot then return false end
    local screen, onScreen = Camera:WorldToViewportPoint(theirRoot.Position)
    if not onScreen or screen.Z <= 0 then return false end
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local dist2D = (Vector2.new(screen.X, screen.Y) - center).Magnitude
    return dist2D <= Config.Combat.Aim.FOVSize
end

function TargetController.ValidateTarget(p)
    if not p or p == LP then return false end
    if not TargetController.TeamCheck(p) then return false end
    local ch, hum, root = U.Alive(p)
    if not ch or not hum or not root then return false end
    if hum.Health <= 0 then return false end
    return true
end

function TargetController.FindTargets()
    local best, bestScore = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if TargetController.ValidateTarget(p) then
            local _, _, root = U.Alive(p)
            if root then
                if TargetController.DistanceCheck(root) and TargetController.FOVCheck(root) then
                    local d = (Camera.CFrame.Position - root.Position).Magnitude
                    if d < bestScore then bestScore = d best = p end
                end
            end
        end
    end
    TargetController._currentTarget = best
    return best
end

-- ==================== FOV CONTROLLER ====================
local FOVController = {}
FOVController._frame = nil

function FOVController.Create(parent)
    if FOVController._frame and FOVController._frame.Parent then return end
    local size = Config.Combat.Aim.FOVSize * 2
    local f = Instance.new("Frame")
    f.Name = "DX_FOVCircle"
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.fromScale(0.5, 0.5)
    f.Size = UDim2.fromOffset(size, size)
    f.BackgroundTransparency = 1
    f.ZIndex = 3
    f.Visible = false
    f.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = f
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(105, 132, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = f
    FOVController._frame = f
end

function FOVController.UpdateSize()
    if FOVController._frame then
        FOVController._frame.Size = UDim2.fromOffset(Config.Combat.Aim.FOVSize * 2, Config.Combat.Aim.FOVSize * 2)
    end
end

function FOVController.SetVisible(v)
    if FOVController._frame then FOVController._frame.Visible = v end
end

-- ==================== CAMERA CONTROLLER ====================
local CameraController = {}
CameraController._conn = nil

function CameraController.Start()
    if CameraController._conn then return end
    CameraController._conn = RunService.RenderStepped:Connect(function()
        if not Config.Combat.Aim.Enabled then
            TargetController._currentTarget = nil
            return
        end
        local t = TargetController.FindTargets()
        if t then
            local _, _, root = U.Alive(t)
            if root then
                local cur = Camera.CFrame
                local desired = CFrame.lookAt(cur.Position, root.Position)
                Camera.CFrame = cur:Lerp(desired, math.clamp(Config.Combat.Smoothness, 0, 1))
            end
        end
    end)
end

function CameraController.Stop()
    if CameraController._conn then
        pcall(function() CameraController._conn:Disconnect() end)
        CameraController._conn = nil
    end
    TargetController._currentTarget = nil
end

function CameraController.SetEnabled(v)
    if v then CameraController.Start() else CameraController.Stop() end
end

-- ==================== AIM CONTROLLER ====================
local AimController = {}
function AimController.SetAimAssist(v)
    Config.Combat.Aim.Enabled = v
    CameraController.SetEnabled(v)
end
function AimController.SetFOVCircle(v)
    Config.Combat.Aim.FOVCircle = v
    FOVController.SetVisible(v)
end
function AimController.SetFOVSize(v)
    Config.Combat.Aim.FOVSize = v
    FOVController.UpdateSize()
end
function AimController.SetMaxDistance(v) Config.Combat.Aim.MaxDistance = v end
function AimController.SetTargetMode(v)  Config.Combat.Aim.TargetMode = v end
function AimController.SetTarget(v)      Config.Combat.Aim.Target = v end
function AimController.SetTeamCheck(v)   Config.Combat.Aim.TeamCheck = v end

-- ==================== ESP ====================
local ESP = { Cache = setmetatable({}, {__mode="k"}) }
function ESP.Clear(cat)
    for inst,data in pairs(ESP.Cache) do
        if not cat or data.Cat==cat then
            if data.BB and data.BB.Parent then data.BB:Destroy() end
            if data.HL and data.HL.Parent then data.HL:Destroy() end
            if data.Conn then data.Conn:Disconnect() end
            ESP.Cache[inst]=nil
        end
    end
end
function ESP.Add(p)
    if p==LP or ESP.Cache[p] then return end
    local ch,_,root=U.Alive(p); if not ch or not root then return end
    local hl=Instance.new("Highlight")
    hl.Adornee=ch; hl.FillColor=Color3.fromRGB(225,83,92); hl.FillTransparency=0.7
    hl.OutlineColor=Color3.fromRGB(255,255,255); hl.OutlineTransparency=0.2; hl.Parent=ch
    local bb=Instance.new("BillboardGui")
    bb.Adornee=root; bb.Size=UDim2.fromOffset(200,44)
    bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.MaxDistance=5000; bb.Parent=root
    local nl=Instance.new("TextLabel")
    nl.Size=UDim2.new(1,0,0,22); nl.BackgroundTransparency=1; nl.Font=Enum.Font.GothamBold
    nl.TextColor3=Color3.fromRGB(240,242,247); nl.TextStrokeTransparency=0.4; nl.TextSize=12
    nl.RichText=true; nl.Parent=bb
    local hpBg=Instance.new("Frame")
    hpBg.Size=UDim2.new(1,-20,0,6); hpBg.Position=UDim2.new(0,10,0,24)
    hpBg.BackgroundColor3=Color3.fromRGB(30,30,40); hpBg.BorderSizePixel=0; hpBg.Parent=bb
    Instance.new("UICorner",hpBg).CornerRadius=UDim.new(1,0)
    local hpF=Instance.new("Frame")
    hpF.Size=UDim2.new(1,0,1,0); hpF.BackgroundColor3=Color3.fromRGB(70,205,126)
    hpF.BorderSizePixel=0; hpF.Parent=hpBg
    Instance.new("UICorner",hpF).CornerRadius=UDim.new(1,0)
    local conn=RunService.RenderStepped:Connect(function()
        if not bb.Parent then return end
        local _,h2,r2=U.Alive(p)
        if h2 and r2 then
            local dist=(Camera.CFrame.Position-r2.Position).Magnitude
            local n=Config.Visual.ShowNames and p.Name or ""
            local d=Config.Visual.ShowDistance and string.format(" <font color='#999'>[%.0f]</font>",dist) or ""
            nl.Text=n..d
            local ratio=math.clamp(h2.Health/math.max(h2.MaxHealth,1),0,1)
            hpF.Size=UDim2.new(ratio,0,1,0)
            if ratio>0.6 then hpF.BackgroundColor3=Color3.fromRGB(70,205,126)
            elseif ratio>0.3 then hpF.BackgroundColor3=Color3.fromRGB(240,190,60)
            else hpF.BackgroundColor3=Color3.fromRGB(225,83,92) end
            hpBg.Visible=Config.Visual.ShowHealth
        end
    end)
    ESP.Cache[p]={BB=bb,HL=hl,Conn=conn,Cat="Player"}
end
function ESP.Refresh()
    if not State.ESP then ESP.Clear() return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then ESP.Add(p) end end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5) if State.ESP then ESP.Add(p) end end)
end)
Players.PlayerRemoving:Connect(function(p)
    local d=ESP.Cache[p]
    if d then
        if d.BB then d.BB:Destroy() end
        if d.HL then d.HL:Destroy() end
        if d.Conn then d.Conn:Disconnect() end
        ESP.Cache[p]=nil
    end
end)

-- ==================== MACRO ====================
local Macro = {}
Macro._Thread = nil
function Macro.Start()
    if State.Macro then return end
    State.Macro = true
    Macro._Thread = task.spawn(function()
        repeat
            for _,step in ipairs(Config.Macro.Default) do
                if not State.Macro then break end
                local key=Enum.KeyCode[step.Action]
                if key then
                    VirtualInputManager:SendKeyEvent(true,key,false,game)
                    if (tonumber(step.Hold) or 0)>0 then task.wait(math.clamp(step.Hold,0,3))
                    else task.wait(0.02) end
                    VirtualInputManager:SendKeyEvent(false,key,false,game)
                end
                task.wait(math.max(0,tonumber(step.Delay) or 0))
            end
        until not Config.Macro.Loop or not State.Macro
        State.Macro = false
        if _G.DX_RefreshMCR then pcall(_G.DX_RefreshMCR) end
    end)
end
function Macro.Stop()
    State.Macro = false
    if _G.DX_RefreshMCR then pcall(_G.DX_RefreshMCR) end
end
function Macro.Toggle() if State.Macro then Macro.Stop() else Macro.Start() end end

-- ==================== MOVEMENT CONTROLLER ====================
local MovementController = {}
MovementController._reapplyThread = nil
MovementController._lastDash = 0
MovementController._dashConn = nil

local function getHum() local c=LP.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=LP.Character return c and c:FindFirstChild("HumanoidRootPart") end

function MovementController.ApplyJumpBoost()
    local hum=getHum(); if not hum then return end
    local m=Config.Movement
    hum.UseJumpPower=true
    hum.JumpPower = m.JumpBoost.Enabled and m.JumpBoost.Power or m.Base.JumpPower
end
function MovementController.ApplySpeedBoost()
    local hum=getHum(); if not hum then return end
    local m=Config.Movement
    hum.WalkSpeed = m.SpeedBoost.Enabled and m.SpeedBoost.Speed or m.Base.WalkSpeed
end
function MovementController.Dash()
    if not Config.Movement.DashBoost.Enabled then return end
    local root=getRoot(); local hum=getHum()
    if not root or not hum or hum.Health<=0 then return end
    local now=tick()
    if now-MovementController._lastDash < Config.Movement.DashBoost.Cooldown then return end
    MovementController._lastDash = now
    local dir=Camera.CFrame.LookVector
    local flat=Vector3.new(dir.X,0,dir.Z)
    if flat.Magnitude<0.01 then flat=root.CFrame.LookVector end
    flat=flat.Unit
    local p=Config.Movement.DashBoost.Power
    root.AssemblyLinearVelocity=Vector3.new(flat.X*p,root.AssemblyLinearVelocity.Y,flat.Z*p)
end
function MovementController.EnsureReapplyLoop()
    if MovementController._reapplyThread then return end
    MovementController._reapplyThread = task.spawn(function()
        while true do
            task.wait(0.3)
            pcall(function()
                local m=Config.Movement
                if m.JumpBoost.Enabled then MovementController.ApplyJumpBoost() end
                if m.SpeedBoost.Enabled then MovementController.ApplySpeedBoost() end
            end)
        end
    end)
end
function MovementController.EnsureDashKey()
    if MovementController._dashConn then return end
    MovementController._dashConn = UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode==Config.Movement.DashBoost.Key then MovementController.Dash() end
    end)
end
function MovementController.OnCharacterAdded()
    task.wait(0.4)
    pcall(function()
        MovementController.ApplyJumpBoost()
        MovementController.ApplySpeedBoost()
    end)
end
function MovementController.SetJumpBoost(v)
    Config.Movement.JumpBoost.Enabled=v
    MovementController.ApplyJumpBoost()
    if v then MovementController.EnsureReapplyLoop() end
end
function MovementController.SetSpeedBoost(v)
    Config.Movement.SpeedBoost.Enabled=v
    MovementController.ApplySpeedBoost()
    if v then MovementController.EnsureReapplyLoop() end
end
function MovementController.SetDashBoost(v)
    Config.Movement.DashBoost.Enabled=v
    MovementController.EnsureDashKey()
end

-- ==================== WATER WALK CONTROLLER ====================
local WaterWalkController = {}
WaterWalkController._conn = nil
WaterWalkController._bp = nil

local function getWaterLevel()
    local map=Workspace:FindFirstChild("Map")
    local w=map and map:FindFirstChild("WaterBase-Plane")
    if w then return w.Position.Y end
    return 0
end
local function clearBP()
    if WaterWalkController._bp then
        pcall(function() WaterWalkController._bp:Destroy() end)
        WaterWalkController._bp=nil
    end
end
function WaterWalkController.Start()
    if WaterWalkController._conn then return end
    WaterWalkController._conn = RunService.Heartbeat:Connect(function()
        local char=LP.Character
        if not char or not char.Parent then clearBP() return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        local root=char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health<=0 then clearBP() return end
        local wy=getWaterLevel()
        local pos=root.Position
        local vy=root.AssemblyLinearVelocity.Y
        local inRange = pos.Y <= wy+3 and pos.Y >= wy-8
        local falling = vy <= 0.5
        if inRange and falling then
            if not WaterWalkController._bp or WaterWalkController._bp.Parent~=root then
                clearBP()
                local bp=Instance.new("BodyPosition")
                bp.Name="DX_WaterWalkBP"
                bp.MaxForce=Vector3.new(0,math.huge,0)
                bp.P=15000; bp.D=800
                bp.Position=Vector3.new(pos.X,wy+2.5,pos.Z)
                bp.Parent=root
                WaterWalkController._bp=bp
            else
                WaterWalkController._bp.Position=Vector3.new(pos.X,wy+2.5,pos.Z)
            end
        else
            if WaterWalkController._bp then clearBP() end
        end
    end)
end
function WaterWalkController.Stop()
    if WaterWalkController._conn then
        pcall(function() WaterWalkController._conn:Disconnect() end)
        WaterWalkController._conn=nil
    end
    clearBP()
end
function WaterWalkController.SetEnabled(v)
    Config.Movement.WaterWalk.Enabled=v
    if v then WaterWalkController.Start() else WaterWalkController.Stop() end
end
function WaterWalkController.OnCharacterAdded()
    if Config.Movement.WaterWalk.Enabled then
        WaterWalkController.Stop()
        task.wait(0.3)
        if Config.Movement.WaterWalk.Enabled then WaterWalkController.Start() end
    end
end

-- ==================== AUTO ATTACK ====================
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if State.AutoAttack and TargetController._currentTarget then
                local _,_,r=U.Alive(TargetController._currentTarget)
                local root=U.GetRoot(LP.Character)
                if r and root and (root.Position-r.Position).Magnitude<=Config.Combat.AutoAttackRange then
                    FA.Attack(TargetController._currentTarget)
                end
            end
        end)
    end
end)

-- ==================== RESPAWN HOOKS ====================
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    MovementController.OnCharacterAdded()
    WaterWalkController.OnCharacterAdded()
end)

-- ==================== UI ====================
local C = {
    bg=Color3.fromRGB(14,15,20), panel=Color3.fromRGB(21,23,30),
    panel2=Color3.fromRGB(29,31,40), text=Color3.fromRGB(240,242,247),
    muted=Color3.fromRGB(155,161,174), accent=Color3.fromRGB(105,132,255),
    good=Color3.fromRGB(70,205,126), bad=Color3.fromRGB(225,83,92),
    macro=Color3.fromRGB(255,140,40), stroke=Color3.fromRGB(51,55,68),
}
local function new(c,p,par) local x=Instance.new(c) for k,v in pairs(p or {}) do x[k]=v end x.Parent=par return x end
local function round(x,r) new("UICorner",{CornerRadius=UDim.new(0,r or 8)},x) end
local function outline(x) new("UIStroke",{Color=C.stroke,Thickness=1},x) end
local function pad(x,n) new("UIPadding",{PaddingTop=UDim.new(0,n),PaddingBottom=UDim.new(0,n),PaddingLeft=UDim.new(0,n),PaddingRight=UDim.new(0,n)},x) end

local gui = new("ScreenGui",{Name="DungdxPvP",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PlayerGui)

local btnDX = new("TextButton",{Size=UDim2.fromOffset(48,48),Position=UDim2.new(0,14,0.5,-23),
    BackgroundColor3=C.accent,Text="DX",Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=14}, gui)
round(btnDX,24); outline(btnDX)

local btnMCR = new("TextButton",{Size=UDim2.fromOffset(48,48),Position=UDim2.new(0,14,0.5,32),
    BackgroundColor3=C.panel2,Text="MCR",Font=Enum.Font.GothamBold,TextColor3=C.muted,TextSize=12}, gui)
round(btnMCR,24); outline(btnMCR)

_G.DX_RefreshMCR = function()
    if State.Macro then
        btnMCR.BackgroundColor3=C.macro; btnMCR.TextColor3=Color3.fromRGB(255,255,255); btnMCR.Text="ON"
    else
        btnMCR.BackgroundColor3=C.panel2; btnMCR.TextColor3=C.muted; btnMCR.Text="MCR"
    end
end

btnMCR.MouseButton1Click:Connect(function() Macro.Toggle() end)

local main = new("Frame",{Size=Config.UI.MainSize,Position=UDim2.new(0.5,-320,0.5,-220),
    BackgroundColor3=C.bg,BorderSizePixel=0,Active=true}, gui)
round(main,14); outline(main)
new("UIScale",{Scale=Config.UI.Scale}, main)

local top = new("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.panel,BorderSizePixel=0}, main)
round(top,14)
new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(14,6),Size=UDim2.fromOffset(400,22),
    Font=Enum.Font.GothamBold,Text=Config.Brand.Name.."  •  v"..Config.Brand.Version,
    TextColor3=C.text,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left}, top)
new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(14,28),Size=UDim2.fromOffset(500,16),
    Font=Enum.Font.Gotham,Text=Config.Brand.Owner.."  |  discord.gg/Hwwa3VYxW6",
    TextColor3=C.muted,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}, top)

local btnMin = new("TextButton",{Size=UDim2.fromOffset(32,28),Position=UDim2.new(1,-76,0,12),
    BackgroundColor3=C.panel2,Text="—",Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=16}, top)
round(btnMin,6)
local btnClose = new("TextButton",{Size=UDim2.fromOffset(32,28),Position=UDim2.new(1,-40,0,12),
    BackgroundColor3=C.bad,Text="✕",Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextSize=12}, top)
round(btnClose,6)

local sidebar = new("Frame",{Position=UDim2.fromOffset(10,60),Size=UDim2.fromOffset(130,368),
    BackgroundColor3=C.panel,BorderSizePixel=0}, main)
round(sidebar,10); pad(sidebar,7)
new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder}, sidebar)

local page = new("ScrollingFrame",{Position=UDim2.fromOffset(150,60),Size=UDim2.new(1,-162,1,-72),
    BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4}, main)
new("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder}, page)

local statusLabel = new("TextLabel",{LayoutOrder=99,Size=UDim2.new(1,0,0,60),
    BackgroundTransparency=1,Font=Enum.Font.Gotham,TextColor3=C.muted,TextSize=9,
    TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Bottom}, sidebar)

local tabs = {}
local function tabBtn(n,o)
    local b=new("TextButton",{LayoutOrder=o,Size=UDim2.new(1,0,0,34),
        BackgroundColor3=C.panel2,Text=n,Font=Enum.Font.GothamMedium,
        TextColor3=C.muted,TextSize=11}, sidebar)
    round(b,7); tabs[n]=b; return b
end
local tCombat=tabBtn("⚔ Combat",1)
local tMacro=tabBtn("⌁ Macro",2)
local tVisual=tabBtn("◉ Visual",3)
local tMove=tabBtn("✦ Movement",4)
local tSettings=tabBtn("⚙ Settings",5)

local function status(s) State.Status=tostring(s); statusLabel.Text="STATUS\n"..State.Status end

local function titleBar(text,sub)
    local b=new("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
    round(b,9); pad(b,9)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),Font=Enum.Font.GothamBold,
        Text=text,TextColor3=C.text,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left}, b)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,20),Size=UDim2.new(1,0,0,18),
        Font=Enum.Font.Gotham,Text=sub or "",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, b)
end

-- ============ CARD UI HELPERS (AIM style) ============
local function card(parent, height)
    local c = new("Frame", {
        Size = UDim2.new(1, 0, 0, height or 56),
        BackgroundColor3 = C.panel, BorderSizePixel = 0,
    }, parent)
    round(c, 12); pad(c, 12)
    return c
end

local function cardTitle(c, name, desc)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0.62, 0, 0, 20), Font = Enum.Font.GothamBold,
        Text = name, TextColor3 = C.text, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, c)
    if desc then
        new("TextLabel", {
            BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(0.68, 0, 0, 16), Font = Enum.Font.Gotham,
            Text = desc, TextColor3 = C.muted, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, c)
    end
end

local function cardToggle(parent, name, desc, value, cb)
    local c = card(parent, 62)
    cardTitle(c, name, desc)
    local pill = new("Frame", {
        Size = UDim2.fromOffset(50, 26),
        Position = UDim2.new(1, -50, 0.5, -13),
        BackgroundColor3 = value and C.good or C.panel2,
        BorderSizePixel = 0,
    }, c)
    round(pill, 13)
    new("UIStroke", {Color = C.stroke, Thickness = 1}, pill)
    local knob = new("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
    }, pill)
    round(knob, 10)
    local click = new("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, pill)
    local state = value
    click.MouseButton1Click:Connect(function()
        state = not state
        pill.BackgroundColor3 = state and C.good or C.panel2
        knob.Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        if cb then pcall(cb, state) end
    end)
    return pill
end

local function cardDropdown(parent, name, desc, options, current, cb)
    local c = card(parent, 62)
    cardTitle(c, name, desc)
    local btn = new("TextButton", {
        Position = UDim2.new(0.66, 0, 0.5, -13),
        Size = UDim2.new(0.34, 0, 0, 26),
        BackgroundColor3 = C.panel2,
        Text = tostring(current) .. "   ⇅",
        Font = Enum.Font.GothamBold,
        TextColor3 = C.text, TextSize = 11,
    }, c)
    round(btn, 8)
    local open, list = false, nil
    btn.MouseButton1Click:Connect(function()
        if open and list then list:Destroy() list = nil open = false return end
        open = true
        list = new("Frame", {
            Size = UDim2.new(0.34, 0, 0, math.min(#options * 24, 144)),
            Position = UDim2.new(0.66, 0, 1, 4),
            BackgroundColor3 = C.panel2, BorderSizePixel = 0, ZIndex = 20,
        }, c)
        round(list, 8)
        new("UIListLayout", { Padding = UDim.new(0, 2) }, list)
        for _, opt in ipairs(options) do
            local b = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = C.panel,
                Text = tostring(opt), Font = Enum.Font.Gotham,
                TextColor3 = C.text, TextSize = 11, ZIndex = 21,
            }, list)
            b.MouseButton1Click:Connect(function()
                btn.Text = tostring(opt) .. "   ⇅"
                if list then list:Destroy() end
                list = nil; open = false
                if cb then pcall(cb, opt) end
            end)
        end
    end)
    return btn
end

local function cardSlider(parent, name, desc, min, max, value, cb)
    local c = card(parent, 76)
    cardTitle(c, name, desc)
    local valLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.72, 0, 0, 0),
        Size = UDim2.new(0.28, 0, 0, 20),
        Font = Enum.Font.GothamBold, Text = tostring(value),
        TextColor3 = C.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, c)
    local track = new("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.fromOffset(0, 50),
        BackgroundColor3 = C.panel2, BorderSizePixel = 0,
    }, c)
    round(track, 3)
    local ratio = (value - min) / math.max(max - min, 1)
    local fill = new("Frame", { Size = UDim2.new(ratio, 0, 1, 0), BackgroundColor3 = C.accent, BorderSizePixel = 0 }, track)
    round(fill, 3)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(ratio, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, ZIndex = 2,
    }, track)
    round(knob, 7)
    local dragging = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local rx = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * rx + 0.5)
            fill.Size = UDim2.new(rx, 0, 1, 0)
            knob.Position = UDim2.new(rx, 0, 0.5, 0)
            valLbl.Text = tostring(v)
            if cb then pcall(cb, v) end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function cardNumber(parent, name, desc, value, min, max, cb)
    local c = card(parent, 62)
    cardTitle(c, name, desc)
    local box = new("TextBox", {
        Position = UDim2.new(0.72, 0, 0.5, -13),
        Size = UDim2.new(0.28, 0, 0, 26),
        BackgroundColor3 = C.panel2, Font = Enum.Font.GothamBold,
        Text = tostring(value), TextColor3 = C.text, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center, ClearTextOnFocus = false,
    }, c)
    round(box, 8)
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if not n or n ~= n or n == math.huge or n == -math.huge then
            box.Text = tostring(value) return
        end
        n = math.floor(n)
        if n < min then n = min end
        if n > max then n = max end
        box.Text = tostring(n); value = n
        if cb then pcall(cb, n) end
    end)
end

local function sectionHeader(parent, icon, title)
    local h = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1 }, parent)
    new("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 1, 0), Font = Enum.Font.GothamBold,
        Text = icon .. "  " .. title, TextColor3 = C.text, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, h)
end

-- ============ SIMPLE ROW / TOGGLE / NUMBOX (cho các tab còn lại) ============
local function row(text,right)
    local r=new("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
    round(r,8); pad(r,8)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(.55,0,1,0),Font=Enum.Font.Gotham,
        Text=text,TextColor3=C.muted,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}, r)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(.55,0,0,0),Size=UDim2.new(.45,0,1,0),
        Font=Enum.Font.GothamBold,Text=right or "",TextColor3=C.text,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Right}, r)
end

local function toggle(text,value,cb)
    local r=new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
    round(r,8); pad(r,8)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-56,1,0),Font=Enum.Font.GothamMedium,
        Text=text,TextColor3=C.text,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}, r)
    local b=new("TextButton",{Size=UDim2.fromOffset(42,22),Position=UDim2.new(1,-42,.5,-11),
        BackgroundColor3=value and C.good or C.panel2,Text=value and "ON" or "OFF",
        Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=9}, r)
    round(b,11)
    b.MouseButton1Click:Connect(function()
        value=not value
        b.Text=value and "ON" or "OFF"
        b.BackgroundColor3=value and C.good or C.panel2
        cb(value)
    end)
    return b
end

local function numBox(text,value,min,max,cb)
    local r=new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
    round(r,8); pad(r,8)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(.5,0,1,0),Font=Enum.Font.Gotham,
        Text=text,TextColor3=C.muted,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}, r)
    local box=new("TextBox",{Position=UDim2.new(.55,0,0,3),Size=UDim2.new(.45,-8,0,26),
        BackgroundColor3=C.panel2,Font=Enum.Font.GothamBold,Text=tostring(value),
        TextColor3=C.text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Center,
        ClearTextOnFocus=false}, r)
    round(box,6)
    box.FocusLost:Connect(function()
        local n=tonumber(box.Text)
        if not n or n~=n or n==math.huge or n==-math.huge then box.Text=tostring(value) return end
        n=math.floor(n)
        if n<min then n=min end
        if n>max then n=max end
        box.Text=tostring(n); value=n; cb(n)
    end)
end

local function actionBtn(text,color,cb)
    local b=new("TextButton",{Size=UDim2.new(1,0,0,36),BackgroundColor3=color or C.accent,
        Text=text,Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=10}, page)
    round(b,8); b.MouseButton1Click:Connect(cb); return b
end

local function clear()
    for _,x in ipairs(page:GetChildren()) do
        if x:IsA("Frame") or x:IsA("TextButton") or x:IsA("TextLabel") then x:Destroy() end
    end
end

local renderCombat, renderMacro, renderVisual, renderMovement, renderSettings

renderCombat = function()
    clear()
    titleBar("Combat", "Aim Assist • Target • FOV")
    sectionHeader(page, "◉", "AIM")

    cardToggle(page, "Aim Assist", "Stick camera toward selected target",
        Config.Combat.Aim.Enabled, function(v) AimController.SetAimAssist(v) end)

    cardDropdown(page, "Target Mode", "Select target selection mode",
        { "FOV" }, Config.Combat.Aim.TargetMode,
        function(v) AimController.SetTargetMode(v) end)

    cardToggle(page, "FOV Circle", "Show FOV area on screen",
        Config.Combat.Aim.FOVCircle, function(v) AimController.SetFOVCircle(v) end)

    cardSlider(page, "FOV Size", "The size of the FOV circle",
        50, 500, Config.Combat.Aim.FOVSize,
        function(v) AimController.SetFOVSize(v) end)

    cardNumber(page, "Max Distance", "Maximum distance to consider target valid",
        Config.Combat.Aim.MaxDistance, 50, 5000,
        function(v) AimController.SetMaxDistance(v) end)

    cardDropdown(page, "Target", "Current target selection mode",
        { "Auto" }, Config.Combat.Aim.Target,
        function(v) AimController.SetTarget(v) end)

    cardToggle(page, "Team Check", "Only target players from other teams",
        Config.Combat.Aim.TeamCheck, function(v) AimController.SetTeamCheck(v) end)
end

renderMacro = function()
    clear()
    titleBar("Macro","Bật/tắt bằng nút MCR bên ngoài")
    row("Profile","Default")
    row("Steps",tostring(#Config.Macro.Default))
    row("Loop",Config.Macro.Loop and "ON" or "OFF")
    toggle("Loop Macro",Config.Macro.Loop,function(v) Config.Macro.Loop=v end)
    actionBtn(State.Macro and "STOP MACRO" or "RUN MACRO",State.Macro and C.bad or C.good,function()
        Macro.Toggle()
        if page.Parent then renderMacro() end
    end)
    for i,step in ipairs(Config.Macro.Default) do
        row(string.format("#%d  %s",i,tostring(step.Action)),
            string.format("H %.2f | D %.2f",step.Hold or 0,step.Delay or 0))
    end
end

renderVisual = function()
    clear()
    titleBar("Visual","ESP & FOV")
    toggle("Player ESP",State.ESP,function(v) State.ESP=v ESP.Refresh() end)
    toggle("FOV Circle (Standalone)",State.FOV,function(v)
        State.FOV=v
        if v then FOVController.SetVisible(true)
        else
            if not Config.Combat.Aim.FOVCircle then FOVController.SetVisible(false) end
        end
    end)
    toggle("ESP Names",Config.Visual.ShowNames,function(v) Config.Visual.ShowNames=v end)
    toggle("ESP Distance",Config.Visual.ShowDistance,function(v) Config.Visual.ShowDistance=v end)
    toggle("ESP Health Bar",Config.Visual.ShowHealth,function(v) Config.Visual.ShowHealth=v end)
end

renderMovement = function()
    clear()
    titleBar("Movement","Jump / Speed / Dash / Water Walk • Dash = Q")

    toggle("Jump Boost",Config.Movement.JumpBoost.Enabled,function(v) MovementController.SetJumpBoost(v) end)
    numBox("Power",Config.Movement.JumpBoost.Power,
        Config.Movement.Limits.Jump.Min,Config.Movement.Limits.Jump.Max,function(v)
        Config.Movement.JumpBoost.Power=v
        if Config.Movement.JumpBoost.Enabled then MovementController.ApplyJumpBoost() end
    end)

    toggle("Speed Boost",Config.Movement.SpeedBoost.Enabled,function(v) MovementController.SetSpeedBoost(v) end)
    numBox("Speed",Config.Movement.SpeedBoost.Speed,
        Config.Movement.Limits.Speed.Min,Config.Movement.Limits.Speed.Max,function(v)
        Config.Movement.SpeedBoost.Speed=v
        if Config.Movement.SpeedBoost.Enabled then MovementController.ApplySpeedBoost() end
    end)

    toggle("Dash Boost",Config.Movement.DashBoost.Enabled,function(v) MovementController.SetDashBoost(v) end)
    numBox("Power",Config.Movement.DashBoost.Power,
        Config.Movement.Limits.Dash.Min,Config.Movement.Limits.Dash.Max,function(v)
        Config.Movement.DashBoost.Power=v
    end)

    toggle("Water Walk",Config.Movement.WaterWalk.Enabled,function(v) WaterWalkController.SetEnabled(v) end)

    actionBtn("↺  RESET",C.bad,function()
        Config.Movement.JumpBoost.Enabled=false
        Config.Movement.SpeedBoost.Enabled=false
        Config.Movement.DashBoost.Enabled=false
        Config.Movement.WaterWalk.Enabled=false
        Config.Movement.JumpBoost.Power=50
        Config.Movement.SpeedBoost.Speed=50
        Config.Movement.DashBoost.Power=50
        WaterWalkController.Stop()
        MovementController.ApplyJumpBoost()
        MovementController.ApplySpeedBoost()
        U.Notify("Movement","Đã reset toàn bộ",3)
        renderMovement()
    end)
end

renderSettings = function()
    clear()
    titleBar("Settings","UI và thông tin")
    row("Owner",Config.Brand.Owner)
    row("Version",Config.Brand.Version)
    row("Discord","discord.gg/Hwwa3VYxW6")
    row("UI Toggle",Config.UI.ToggleKey.Name)
    row("Dash",Config.Movement.DashBoost.Key.Name)
    actionBtn("COPY DISCORD LINK",C.accent,function()
        pcall(function()
            if setclipboard then setclipboard(Config.Brand.Discord) U.Notify("Copied","Link copied!",3) end
        end)
    end)
end

local function show(name)
    State.Tab=name
    for n,b in pairs(tabs) do
        b.BackgroundColor3=(n==name) and C.accent or C.panel2
        b.TextColor3=(n==name) and C.text or C.muted
    end
    if name=="Combat" then renderCombat()
    elseif name=="Macro" then renderMacro()
    elseif name=="Visual" then renderVisual()
    elseif name=="Movement" then renderMovement()
    elseif name=="Settings" then renderSettings() end
end

tCombat.MouseButton1Click:Connect(function() show("Combat") end)
tMacro.MouseButton1Click:Connect(function() show("Macro") end)
tVisual.MouseButton1Click:Connect(function() show("Visual") end)
tMove.MouseButton1Click:Connect(function() show("Movement") end)
tSettings.MouseButton1Click:Connect(function() show("Settings") end)

local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        local delta=input.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end)

btnMin.MouseButton1Click:Connect(function()
    local min=main:GetAttribute("Min") or false
    min=not min; main:SetAttribute("Min",min)
    if min then
        main.Size=UDim2.fromOffset(640,52); sidebar.Visible=false; page.Visible=false
    else
        main.Size=Config.UI.MainSize; sidebar.Visible=true; page.Visible=true
    end
end)
btnClose.MouseButton1Click:Connect(function() main.Visible=false end)
btnDX.MouseButton1Click:Connect(function() main.Visible=not main.Visible end)
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Config.UI.ToggleKey then main.Visible=not main.Visible end
end)

-- ==================== INIT ====================
FOVController.Create(gui)
FOVController.SetVisible(Config.Combat.Aim.FOVCircle)
FOVController.UpdateSize()
if Config.Combat.Aim.Enabled then CameraController.Start() end

if Config.Movement.JumpBoost.Enabled then MovementController.SetJumpBoost(true) end
if Config.Movement.SpeedBoost.Enabled then MovementController.SetSpeedBoost(true) end
if Config.Movement.DashBoost.Enabled then MovementController.SetDashBoost(true) end
if Config.Movement.WaterWalk.Enabled then WaterWalkController.SetEnabled(true) end

show("Combat")
ESP.Refresh()
status("Sẵn sàng • RightShift = UI • DX = toggle • MCR = macro")
_G.DX_RefreshMCR()

task.spawn(function()
    task.wait(1)
    U.Notify("Dungdx PvP","Loaded! RightShift = UI",5)
    task.wait(2)
    U.Notify("Discord","discord.gg/Hwwa3VYxW6",6)
end)

print("==============================================")
print("DUNGDX PVP v" .. Config.Brand.Version)
print("Owner: Dungdx")
print("Discord: https://discord.gg/Hwwa3VYxW6")
print("==============================================")