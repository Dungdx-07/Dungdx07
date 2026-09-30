--[[
DUNGDX PVP — BLOX FRUITS EDITION v2.1.0 BF
Owner: Dungdx
Discord: https://discord.gg/Hwwa3VYxW6
RightShift = ẩn/hiện UI | DX = toggle UI | MCR = toggle Macro
--]]

local Services = setmetatable({}, {__index = function(self, n)
    local ok, s = pcall(game.GetService, game, n)
    if ok and s then rawset(self, n, s) return s end
end})

local Players = Services.Players
local RunService = Services.RunService
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace = Services.Workspace
local UserInputService = Services.UserInputService
local VirtualInputManager = Services.VirtualInputManager
local StarterGui = Services.StarterGui

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid", 10)
local Root = Character:WaitForChild("HumanoidRootPart", 10)
local Backpack = LP:WaitForChild("Backpack")
local PlayerGui = LP:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

LP.CharacterAdded:Connect(function(c)
    Character = c
    Humanoid = c:WaitForChild("Humanoid", 10)
    Root = c:WaitForChild("HumanoidRootPart", 10)
end)

local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local reRegisterAttack, reShootGunEvent
pcall(function()
    reRegisterAttack = Net:WaitForChild("RE/RegisterAttack")
    reShootGunEvent = Net:FindFirstChild("RE/ShootGunEvent")
    local CU = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CombatUtil"))
    if CU and CU.CanAttack and hookfunction then
        hookfunction(CU.CanAttack, function() return true end)
    end
end)

-- ==================== CONFIG ====================
local Config = {
    Brand = { Owner="Dungdx", Discord="https://discord.gg/Hwwa3VYxW6", Name="Dungdx PvP", Version="2.1.0 BF" },
    UI = { ToggleKey=Enum.KeyCode.RightShift, MainSize=UDim2.fromOffset(640,480), Scale=0.9 },
    Combat = {
        CameraLock=false, SilentAimMode="FOV", FOV=150, MaxDistance=160,
        Smoothness=0.18, TeamCheck=true, AutoAttack=true,
        AutoAttackRange=30, AttackInterval=0.15, FastAttackDelay=0,
    },
    Visual = {
        ESPEnabled=true, ShowHitbox=false, ShowNames=true, ShowDistance=true,
        ShowHealth=true, ShowLevel=false, ShowTeam=false, Transparency=0.7,
        TeamColors = {
            ["Blue"]   = Color3.fromRGB(60,140,255),
            ["Red"]    = Color3.fromRGB(230,60,60),
            ["Green"]  = Color3.fromRGB(60,210,90),
            ["Yellow"] = Color3.fromRGB(240,200,60),
        },
    },
    Move = {
        SpeedEnabled=false, SpeedMultiplier=1.0,
        JumpEnabled=false, JumpMultiplier=1.0,
        NoClip=false, FlyEnabled=false, WalkOnWater=false,
    },
    Setting = { FixLag=false },
}

local State = {
    Visible=true, Tab="Combat",
    -- Combat
    CameraLock=false, SilentAimMode="FOV", FOVCircle=false, FOVSize=150,
    -- Visual
    ESP=Config.Visual.ESPEnabled,
    -- Move
    Sprint=false, Jump=false, NoClip=false, Fly=false, WalkOnWater=false,
    -- Setting
    FixLag=false,
    -- Macro
    MacroActive=false, MacroThread=nil,
    -- Runtime
    Target=nil, Status="Sẵn sàng", LastAttack=0,
    FlyBV=nil, FlyBG=nil, FlyConn=nil,
}

-- ==================== MACRO DATA ====================
local MacroData = {}
local function newMacro(name)
    return { Name=name, Enabled=false, Weapon="Kiếm", Skill="Z", Hold=0.00, Delay=0.30 }
end
for i = 1, 6 do
    local m = newMacro("Macro "..i)
    if i == 4 then m.Enabled = true end
    table.insert(MacroData, m)
end

-- ==================== UTIL ====================
local U = {}
function U.GetRoot(ch) return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart) end
function U.GetHum(ch) return ch and ch:FindFirstChildOfClass("Humanoid") end
function U.Alive(p)
    local ch = p.Character; if not ch then return end
    local h = U.GetHum(ch); local r = U.GetRoot(ch)
    if h and r and h.Health > 0 then return ch, h, r end
end
function U.Notify(t, x, d)
    pcall(function() StarterGui:SetCore("SendNotification", {Title=t or "Dungdx", Text=x or "", Duration=d or 5}) end)
end
function U.EquipWeapon(w)
    if not Backpack or not Humanoid then return end
    for _, t in ipairs(Backpack:GetChildren()) do
        if t:IsA("Tool") then
            if w=="Kiếm" and (t.ToolTip=="Melee" or t.Name:lower():find("sword")) then Humanoid:EquipTool(t) return end
            if w=="Võ" and t.ToolTip=="Melee" then Humanoid:EquipTool(t) return end
            if w=="Súng" and t.ToolTip=="Gun" then Humanoid:EquipTool(t) return end
            if w=="Trái" and t.ToolTip=="Blox Fruit" then Humanoid:EquipTool(t) return end
        end
    end
    for _, t in ipairs(Backpack:GetChildren()) do
        if t:IsA("Tool") then Humanoid:EquipTool(t) return end
    end
end

-- ==================== TARGET ====================
local T = {}
function T.Enemy(p)
    if p == LP then return false end
    if Config.Combat.TeamCheck and LP.Team and p.Team and LP.Team == p.Team then return false end
    return true
end
function T.Acquire()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bs = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if T.Enemy(p) then
            local _, _, r = U.Alive(p)
            if r then
                local d = (Camera.CFrame.Position - r.Position).Magnitude
                if d <= Config.Combat.MaxDistance then
                    local sp, vis = Camera:WorldToViewportPoint(r.Position)
                    if vis and sp.Z > 0 then
                        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if sd <= State.FOVSize then
                            local score = (State.SilentAimMode=="Nearest") and d or (sd + d*0.08)
                            if score < bs then bs = score best = p end
                        end
                    end
                end
            end
        end
    end
    State.Target = best
    return best
end

-- ==================== FAST ATTACK ====================
local FA = {}
function FA.Attack(target)
    if not Character or not Humanoid or Humanoid.Health <= 0 then return end
    local now = tick()
    if now - State.LastAttack < Config.Combat.AttackInterval then return end
    State.LastAttack = now
    local tool = Character:FindFirstChildOfClass("Tool")
    if not tool then U.EquipWeapon("Kiếm"); tool = Character:FindFirstChildOfClass("Tool"); if not tool then return end end
    if reRegisterAttack then pcall(function() reRegisterAttack:FireServer(Config.Combat.FastAttackDelay) end) end
    if tool:FindFirstChild("LeftClickRemote") then
        pcall(function() tool.LeftClickRemote:FireServer(Vector3.new(0.01,-500,0.01), 1, true) end)
    end
    if tool.ToolTip == "Gun" and reShootGunEvent then
        local _, _, r = U.Alive(target)
        if r then pcall(function() reShootGunEvent:FireServer(r.Position, {}) end) end
    end
end

-- ==================== ESP ====================
local ESP = { Cache = setmetatable({}, {__mode="k"}) }
function ESP.Clear()
    for inst, data in pairs(ESP.Cache) do
        if data.BB then data.BB:Destroy() end
        if data.HL then data.HL:Destroy() end
        if data.Conn then data.Conn:Disconnect() end
        ESP.Cache[inst] = nil
    end
end
function ESP.Add(p)
    if p == LP or ESP.Cache[p] then return end
    local ch, _, root = U.Alive(p); if not ch or not root then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = ch
    hl.FillColor = Color3.fromRGB(225, 83, 92)
    hl.FillTransparency = Config.Visual.Transparency
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.OutlineTransparency = 0.2
    hl.Parent = ch
    local bb = Instance.new("BillboardGui")
    bb.Adornee = root
    bb.Size = UDim2.fromOffset(200, 44)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 5000
    bb.Parent = root
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,0,0,22)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextColor3 = Color3.fromRGB(240,242,247)
    nameLbl.TextStrokeTransparency = 0.4
    nameLbl.TextSize = 12
    nameLbl.RichText = true
    nameLbl.Parent = bb
    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1,-20,0,6); hpBg.Position = UDim2.new(0,10,0,24)
    hpBg.BackgroundColor3 = Color3.fromRGB(30,30,40); hpBg.BorderSizePixel = 0; hpBg.Parent = bb
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1,0)
    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1,0,1,0)
    hpFill.BackgroundColor3 = Color3.fromRGB(70,205,126)
    hpFill.BorderSizePixel = 0; hpFill.Parent = hpBg
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1,0)
    local conn = RunService.RenderStepped:Connect(function()
        if not bb.Parent then return end
        local _, h2, r2 = U.Alive(p)
        if h2 and r2 then
            local dist = (Camera.CFrame.Position - r2.Position).Magnitude
            local n = Config.Visual.ShowNames and p.Name or ""
            local d = Config.Visual.ShowDistance and string.format(" <font color='#999'>[%.0f]</font>", dist) or ""
            nameLbl.Text = n .. d
            local ratio = math.clamp(h2.Health / math.max(h2.MaxHealth,1), 0, 1)
            hpFill.Size = UDim2.new(ratio,0,1,0)
            if ratio > 0.6 then hpFill.BackgroundColor3 = Color3.fromRGB(70,205,126)
            elseif ratio > 0.3 then hpFill.BackgroundColor3 = Color3.fromRGB(240,190,60)
            else hpFill.BackgroundColor3 = Color3.fromRGB(225,83,92) end
            hpBg.Visible = Config.Visual.ShowHealth
        end
    end)
    ESP.Cache[p] = {BB=bb, HL=hl, Conn=conn}
end
function ESP.Refresh()
    ESP.Clear()
    if not State.ESP then return end
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then ESP.Add(p) end end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5); if State.ESP then ESP.Add(p) end end)
end)
Players.PlayerRemoving:Connect(function(p)
    local d = ESP.Cache[p]
    if d then
        if d.BB then d.BB:Destroy() end
        if d.HL then d.HL:Destroy() end
        if d.Conn then d.Conn:Disconnect() end
        ESP.Cache[p] = nil
    end
end)

-- ==================== MACRO LOGIC ====================
local function macroStart()
    if State.MacroActive then return end
    State.MacroActive = true
    State.MacroThread = task.spawn(function()
        while State.MacroActive do
            for _, m in ipairs(MacroData) do
                if not State.MacroActive then break end
                if m.Enabled then
                    U.EquipWeapon(m.Weapon)
                    task.wait(0.08)
                    local key = Enum.KeyCode[m.Skill]
                    if key then
                        VirtualInputManager:SendKeyEvent(true, key, false, game)
                        task.wait(m.Hold > 0 and m.Hold or 0.02)
                        VirtualInputManager:SendKeyEvent(false, key, false, game)
                    end
                    task.wait(math.max(0, m.Delay))
                end
            end
            task.wait(0.05)
        end
    end)
    if _G.DX_RefreshMacroButton then pcall(_G.DX_RefreshMacroButton) end
end
local function macroStop()
    State.MacroActive = false
    if _G.DX_RefreshMacroButton then pcall(_G.DX_RefreshMacroButton) end
end
local function macroToggle()
    if State.MacroActive then macroStop() else macroStart() end
end

-- ==================== CAMERA AIM LOOP ====================
RunService.RenderStepped:Connect(function()
    if not State.CameraLock then State.Target = nil return end
    local t = T.Acquire()
    if t then
        local _, _, r = U.Alive(t)
        if r then
            local cur = Camera.CFrame
            local desired = CFrame.lookAt(cur.Position, r.Position)
            Camera.CFrame = cur:Lerp(desired, 1)
        end
    end
end)

-- ==================== AUTO ATTACK LOOP ====================
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if Config.Combat.AutoAttack and State.Target then
                local _, _, r = U.Alive(State.Target)
                if r and Root and (Root.Position - r.Position).Magnitude <= Config.Combat.AutoAttackRange then
                    FA.Attack(State.Target)
                end
            end
        end)
    end
end)

-- ==================== SPRINT / JUMP ====================
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if Humanoid and Humanoid.Health > 0 then
                Humanoid.WalkSpeed = State.Sprint and (16 * Config.Move.SpeedMultiplier) or 16
                if State.Jump then
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = 50 * Config.Move.JumpMultiplier
                else
                    Humanoid.UseJumpPower = false
                end
            end
        end)
    end
end)

-- ==================== NOCLIP ====================
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if State.NoClip and Character then
                for _, v in ipairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                end
            end
        end)
    end
end)

-- ==================== FLY ====================
local function flySet(on)
    if on then
        if not Root then return end
        if State.FlyBV then State.FlyBV:Destroy() end
        if State.FlyBG then State.FlyBG:Destroy() end
        if State.FlyConn then State.FlyConn:Disconnect() end
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0,0,0); bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = Root
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.P = 1000; bg.Parent = Root
        State.FlyBV = bv; State.FlyBG = bg
        State.FlyConn = RunService.RenderStepped:Connect(function()
            if not State.Fly or not Root or not Humanoid or Humanoid.Health <= 0 then
                if State.FlyBV then State.FlyBV:Destroy() State.FlyBV=nil end
                if State.FlyBG then State.FlyBG:Destroy() State.FlyBG=nil end
                if State.FlyConn then State.FlyConn:Disconnect() State.FlyConn=nil end
                return
            end
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            bv.Velocity = dir.Magnitude > 0 and (dir.Unit * 55) or Vector3.new(0,0,0)
            bg.CFrame = Camera.CFrame
        end)
    else
        if State.FlyBV then State.FlyBV:Destroy() State.FlyBV=nil end
        if State.FlyBG then State.FlyBG:Destroy() State.FlyBG=nil end
        if State.FlyConn then State.FlyConn:Disconnect() State.FlyConn=nil end
    end
end

-- ==================== WALK ON WATER ====================
task.spawn(function()
    while task.wait(0.15) do
        pcall(function()
            if State.WalkOnWater and Character then
                for _, v in ipairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5, 1, 1)
                    end
                end
            end
        end)
    end
end)

-- ==================== FIX LAG ====================
local function fixLagSet(on)
    if on then
        for _, v in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                elseif v:IsA("Light") then
                    v.Enabled = false
                end
            end)
        end
        U.Notify("FixLag", "Đã bật FixLag", 3)
    else
        U.Notify("FixLag", "Đã tắt FixLag (cần rejoin để khôi phục)", 3)
    end
end

-- ==================== UI LIBRARY ====================
local C = {
    bg=Color3.fromRGB(11,17,32), panel=Color3.fromRGB(17,24,39),
    panel2=Color3.fromRGB(24,33,52), panelHover=Color3.fromRGB(32,44,68),
    text=Color3.fromRGB(240,244,250), muted=Color3.fromRGB(130,145,170),
    accent=Color3.fromRGB(40,130,240), accentDark=Color3.fromRGB(28,90,180),
    good=Color3.fromRGB(70,205,126), bad=Color3.fromRGB(230,70,80),
    stroke=Color3.fromRGB(40,52,78), sidebar=Color3.fromRGB(13,20,36),
    icon=Color3.fromRGB(90,160,255),
}
local function new(c,p,par) local x=Instance.new(c) for k,v in pairs(p or {}) do x[k]=v end x.Parent=par return x end
local function round(x,r) new("UICorner",{CornerRadius=UDim.new(0,r or 8)},x) end
local function stroke(x,col,t) new("UIStroke",{Color=col or C.stroke,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},x) end
local function pad(x,n,hh) new("UIPadding",{PaddingTop=UDim.new(0,n),PaddingBottom=UDim.new(0,n),PaddingLeft=UDim.new(0,hh or n),PaddingRight=UDim.new(0,hh or n)},x) end

local gui = new("ScreenGui",{Name="DungdxPvP",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PlayerGui)

-- FOV circle overlay
local fovCircle = new("Frame",{
    AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(State.FOVSize*2, State.FOVSize*2),
    BackgroundTransparency=1, Visible=State.FOVCircle, ZIndex=3}, gui)
round(fovCircle,999)
new("UIStroke",{Color=C.icon,Thickness=1.5,Transparency=0.3}, fovCircle)

-- Float buttons
local floatLayer = new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Active=false}, gui)
local btnDX = new("TextButton",{
    Size=UDim2.fromOffset(46,46), Position=UDim2.new(0,14,0.5,-23),
    BackgroundColor3=C.accent, Text="DX", Font=Enum.Font.GothamBold,
    TextColor3=C.text, TextSize=14, AutoButtonColor=true,
}, floatLayer)
round(btnDX,23); stroke(btnDX,C.accent,1.5)
local btnMacro = new("TextButton",{
    Size=UDim2.fromOffset(46,46), Position=UDim2.new(0,14,0.5,30),
    BackgroundColor3=C.panel2, Text="MCR", Font=Enum.Font.GothamBold,
    TextColor3=C.muted, TextSize=12, AutoButtonColor=true,
}, floatLayer)
round(btnMacro,23); stroke(btnMacro)

_G.DX_RefreshMacroButton = function()
    if State.MacroActive then
        btnMacro.BackgroundColor3 = Color3.fromRGB(255,140,40)
        btnMacro.TextColor3 = Color3.fromRGB(255,255,255)
        btnMacro.Text = "ON"
    else
        btnMacro.BackgroundColor3 = C.panel2
        btnMacro.TextColor3 = C.muted
        btnMacro.Text = "MCR"
    end
end

btnDX.MouseButton1Click:Connect(function()
    State.Visible = not State.Visible
    if _G.DX_ToggleMain then _G.DX_ToggleMain() end
end)
btnMacro.MouseButton1Click:Connect(macroToggle)

-- Main frame
local main = new("Frame",{
    Name="Main", Size=Config.UI.MainSize,
    Position=UDim2.new(0.5,-320,0.5,-240),
    BackgroundColor3=C.bg, BorderSizePixel=0, Active=true,
}, gui)
round(main,14); stroke(main,C.stroke,1.5)

local uiScale = new("UIScale",{Scale=Config.UI.Scale}, main)

-- Top bar
local top = new("Frame",{Size=UDim2.new(1,0,0,60),BackgroundColor3=C.panel,BorderSizePixel=0}, main)
round(top,14)
new("TextLabel",{
    BackgroundTransparency=1, Position=UDim2.fromOffset(16,8), Size=UDim2.fromOffset(400,22),
    Font=Enum.Font.GothamBold, Text=Config.Brand.Name.."  •  v"..Config.Brand.Version,
    TextColor3=C.text, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left,
}, top)
new("TextLabel",{
    BackgroundTransparency=1, Position=UDim2.fromOffset(16,32), Size=UDim2.fromOffset(500,16),
    Font=Enum.Font.Gotham, Text=Config.Brand.Owner.."  |  discord.gg/Hwwa3VYxW6",
    TextColor3=C.muted, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
}, top)

local btnMin = new("TextButton",{
    Size=UDim2.fromOffset(34,30), Position=UDim2.new(1,-86,0,15),
    BackgroundColor3=C.panel2, Text="—", Font=Enum.Font.GothamBold,
    TextColor3=C.text, TextSize=16,
}, top)
round(btnMin,6)
local btnClose = new("TextButton",{
    Size=UDim2.fromOffset(34,30), Position=UDim2.new(1,-46,0,15),
    BackgroundColor3=C.bad, Text="✕", Font=Enum.Font.GothamBold,
    TextColor3=Color3.fromRGB(255,255,255), TextSize=12,
}, top)
round(btnClose,6)

-- Sidebar
local sidebar = new("Frame",{
    Position=UDim2.fromOffset(14,74), Size=UDim2.fromOffset(150,390),
    BackgroundColor3=C.sidebar, BorderSizePixel=0,
}, main)
round(sidebar,10); pad(sidebar,8)
new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder}, sidebar)

-- Page
local page = new("ScrollingFrame",{
    Position=UDim2.fromOffset(174,74), Size=UDim2.new(1,-188,1,-88),
    BackgroundTransparency=1, BorderSizePixel=0,
    CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=4, ScrollBarImageColor3=C.accent,
}, main)
new("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder}, page)

local tabs = {}
local function tabBtn(icon, name, order)
    local b = new("TextButton",{
        LayoutOrder=order, Size=UDim2.new(1,0,0,40),
        BackgroundColor3=C.sidebar, Text="", Font=Enum.Font.GothamMedium,
        TextColor3=C.muted, TextSize=11,
    }, sidebar)
    round(b,8)
    local ic = new("TextLabel",{
        BackgroundTransparency=1, Size=UDim2.fromOffset(28,28), Position=UDim2.fromOffset(8,6),
        Font=Enum.Font.GothamBold, Text=icon, TextColor3=C.icon, TextSize=14,
    }, b)
    local tx = new("TextLabel",{
        BackgroundTransparency=1, Position=UDim2.fromOffset(40,0), Size=UDim2.new(1,-44,1,0),
        Font=Enum.Font.GothamMedium, Text=name, TextColor3=C.muted, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, b)
    tabs[name] = {btn=b, icon=ic, text=tx}
    return b
end
local tCombat   = tabBtn("⚔", "Combat", 1)
local tMacro    = tabBtn("⌨", "Macro", 2)
local tVisual   = tabBtn("◉", "Visual", 3)
local tMove     = tabBtn("✦", "Move", 4)
local tSetting  = tabBtn("⚙", "Setting", 5)

-- ========== UI COMPONENTS ==========
local function card(h)
    local c = new("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
    round(c,10)
    return c
end

-- Row layout: icon | title+desc | control
local function settingRow(iconGlyph, titleText, descText, controlBuild, rowH)
    rowH = rowH or 60
    local c = card(rowH)
    pad(c, 10, 12)
    -- Icon box
    local ib = new("Frame",{Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(0,(rowH-20-38)/2),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, c)
    round(ib,8); stroke(ib,C.stroke,1)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text=iconGlyph,TextColor3=C.icon,TextSize=16}, ib)
    -- Title / Desc
    local tx = new("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,0),
        Size=UDim2.new(1,-160,1,0)}, c)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,-6),Size=UDim2.new(1,0,0,20),
        Font=Enum.Font.GothamBold,Text=titleText,TextColor3=C.text,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left}, tx)
    if descText then
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,16),Size=UDim2.new(1,0,0,16),
            Font=Enum.Font.Gotham,Text=descText,TextColor3=C.muted,TextSize=9,
            TextXAlignment=Enum.TextXAlignment.Left}, tx)
    end
    -- Control area
    local ca = new("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),
        Position=UDim2.new(1,0,0.5,0),Size=UDim2.fromOffset(110,rowH-20)}, c)
    if controlBuild then controlBuild(ca) end
    return c, ca
end

-- Modern toggle switch
local function mkToggle(parent, value, cb)
    local root = new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(58,26),BackgroundColor3=value and C.accent or C.panel2,
        BorderSizePixel=0}, parent)
    round(root,13); stroke(root,value and C.accent or C.stroke,1)
    local knob = new("Frame",{Size=UDim2.fromOffset(20,20),
        Position=value and UDim2.new(1,-23,0.5,-10) or UDim2.fromOffset(3,3),
        BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0}, root)
    round(knob,10)
    local lbl = new("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.fromOffset(-60,0),Size=UDim2.fromOffset(56,26),
        Font=Enum.Font.GothamBold,Text=value and "ON" or "OFF",
        TextColor3=value and C.good or C.muted,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Right}, root)
    local hit = new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""}, root)
    hit.MouseButton1Click:Connect(function()
        value = not value
        root.BackgroundColor3 = value and C.accent or C.panel2
        knob.Position = value and UDim2.new(1,-23,0.5,-10) or UDim2.fromOffset(3,3)
        lbl.Text = value and "ON" or "OFF"
        lbl.TextColor3 = value and C.good or C.muted
        cb(value)
    end)
    return root
end

-- Dropdown
local dropClose = {}
local function mkDropdown(parent, options, current, cb, width)
    width = width or 120
    local btn = new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(width,28),BackgroundColor3=C.panel2,
        Text="",Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=10,
        AutoButtonColor=false}, parent)
    round(btn,6); stroke(btn)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-30,1,0),
        Font=Enum.Font.GothamBold,Text="- "..tostring(current).." -",TextColor3=C.text,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left}, btn)
    new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),
        Size=UDim2.fromOffset(14,14),Font=Enum.Font.GothamBold,Text="⌄",TextColor3=C.muted,TextSize=12}, btn)
    local list = new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,1,4),
        Size=UDim2.fromOffset(width, 0), BackgroundColor3=C.panel2,
        BorderSizePixel=0,Visible=false,ZIndex=50}, btn)
    round(list,6); stroke(list,C.accent,1)
    local ll = new("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder}, list)
    local content = new("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y}, list)
    content.Position = UDim2.fromOffset(4,4); content.Size = UDim2.new(1,-8,0,0)
    new("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder}, content)
    for i, opt in ipairs(options) do
        local ob = new("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=(tostring(opt)==tostring(current)) and C.accent or C.panel,
            Text="",Font=Enum.Font.GothamMedium,TextSize=10,LayoutOrder=i,AutoButtonColor=false}, content)
        round(ob,4)
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(8,0),Size=UDim2.new(1,-16,1,0),
            Font=Enum.Font.GothamMedium,Text=tostring(opt),TextColor3=C.text,TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left}, ob)
        ob.MouseButton1Click:Connect(function()
            list.Visible = false
            btn:FindFirstChildOfClass("TextLabel").Text = "- "..tostring(opt).." -"
            cb(opt)
        end)
    end
    list.Size = UDim2.fromOffset(width, #options * 28 + 8)
    table.insert(dropClose, function() list.Visible = false end)
    btn.MouseButton1Click:Connect(function()
        local wasOpen = list.Visible
        for _, fn in ipairs(dropClose) do fn() end
        list.Visible = not wasOpen
    end)
    return btn
end

-- Slider with -/+ buttons
local function mkSliderButtons(parent, min, max, value, unit, cb)
    local root = new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(300,30), BackgroundTransparency=1}, parent)
    local minus = new("TextButton",{Size=UDim2.fromOffset(28,28),BackgroundColor3=C.panel2,
        Text="−",Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=16}, root)
    round(minus,6); stroke(minus)
    local plus = new("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-70,0,0),
        Size=UDim2.fromOffset(28,28),BackgroundColor3=C.panel2,
        Text="+",Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=16}, root)
    round(plus,6); stroke(plus)
    local valBox = new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
        Size=UDim2.fromOffset(62,28),BackgroundColor3=C.panel2,BorderSizePixel=0}, root)
    round(valBox,6); stroke(valBox)
    local valLbl = new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold,Text=tostring(value)..unit,TextColor3=C.text,TextSize=10}, valBox)
    -- Track
    local track = new("Frame",{Position=UDim2.fromOffset(36,12),Size=UDim2.new(1,-180,0,4),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, root)
    round(track,2)
    local fill = new("Frame",{Size=UDim2.new((value-min)/math.max(max-min,1),0,1,0),
        BackgroundColor3=C.accent,BorderSizePixel=0}, track)
    round(fill,2)
    local knob = new("Frame",{AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new((value-min)/math.max(max-min,1),0,0.5,0),
        Size=UDim2.fromOffset(12,12),BackgroundColor3=Color3.fromRGB(255,255,255),
        BorderSizePixel=0,ZIndex=3}, track)
    round(knob,6)
    -- Drag
    local dragging = false
    local function setVal(v)
        v = math.clamp(v, min, max)
        fill.Size = UDim2.new((v-min)/math.max(max-min,1),0,1,0)
        knob.Position = UDim2.new((v-min)/math.max(max-min,1),0,0.5,0)
        valLbl.Text = tostring(math.floor(v))..unit
        cb(v)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local rx = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
            setVal(min + (max-min)*rx)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    minus.MouseButton1Click:Connect(function() setVal(value - (max-min)/20) end)
    plus.MouseButton1Click:Connect(function() setVal(value + (max-min)/20) end)
    return root
end

-- Stepper (numeric input with +/- arrows)
local function mkStepper(parent, value, step, cb, width)
    width = width or 78
    local root = new("Frame",{Size=UDim2.fromOffset(width,28),BackgroundColor3=C.panel2,BorderSizePixel=0}, parent)
    round(root,6); stroke(root)
    local box = new("TextBox",{BackgroundTransparency=1,Position=UDim2.fromOffset(8,0),
        Size=UDim2.new(1,-24,1,0),Font=Enum.Font.GothamBold,Text=string.format("%.2f", value),
        TextColor3=C.text,TextSize=10,ClearTextOnFocus=false,
        TextXAlignment=Enum.TextXAlignment.Left}, root)
    local up = new("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-2,0,2),
        Size=UDim2.fromOffset(18,12),BackgroundTransparency=1,Text="▲",
        Font=Enum.Font.GothamBold,TextColor3=C.muted,TextSize=8}, root)
    local dn = new("TextButton",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-2,0,14),
        Size=UDim2.fromOffset(18,12),BackgroundTransparency=1,Text="▼",
        Font=Enum.Font.GothamBold,TextColor3=C.muted,TextSize=8}, root)
    local function setVal(v)
        v = math.max(0, v)
        box.Text = string.format("%.2f", v)
        cb(v)
    end
    box.FocusLost:Connect(function() setVal(tonumber(box.Text) or 0) end)
    up.MouseButton1Click:Connect(function() setVal((tonumber(box.Text) or 0) + step) end)
    dn.MouseButton1Click:Connect(function() setVal((tonumber(box.Text) or 0) - step) end)
    return root
end

-- ========== CLEAR PAGE ==========
local function clear()
    for _, x in ipairs(page:GetChildren()) do
        if x:IsA("Frame") or x:IsA("TextButton") or x:IsA("TextLabel") then x:Destroy() end
    end
end

-- ========== RENDER TAB: COMBAT ==========
local renderCombat
renderCombat = function()
    clear()
    settingRow("◎", "Aimbot (Camera Lock)", nil, function(ca)
        mkToggle(ca, State.CameraLock, function(v) State.CameraLock = v; if not v then State.Target=nil end end)
    end)
    settingRow("⛨", "Silent Aim", nil, function(ca)
        mkDropdown(ca, {"FOV", "Nearest"}, State.SilentAimMode, function(v)
            State.SilentAimMode = v; Config.Combat.SilentAimMode = v
        end, 130)
    end)
    settingRow("⭕", "FOV Circle", nil, function(ca)
        mkToggle(ca, State.FOVCircle, function(v) State.FOVCircle = v; fovCircle.Visible = v end)
    end)
    settingRow("⛶", "FOV Size", nil, function(ca)
        mkSliderButtons(ca, 50, 300, State.FOVSize, " px", function(v)
            State.FOVSize = v; Config.Combat.FOV = v
            fovCircle.Size = UDim2.fromOffset(v*2, v*2)
        end)
    end, 70)
end

-- ========== RENDER TAB: MACRO ==========
local renderMacro
renderMacro = function()
    clear()
    -- Header
    local head = card(52)
    pad(head, 10, 12)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,0),Size=UDim2.new(1,-180,1,0),
        Font=Enum.Font.GothamBold,Text="Macro",TextColor3=C.text,TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left}, head)
    local hicon = new("Frame",{Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(0,6),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, head)
    round(hicon,8); stroke(hicon)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="⌨",TextColor3=C.icon,TextSize=16}, hicon)
    local addBtn = new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(130,34),BackgroundColor3=C.accent,
        Text="+  Tạo Macro",Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=11}, head)
    round(addBtn,8)
    addBtn.MouseButton1Click:Connect(function()
        table.insert(MacroData, newMacro("Macro "..(#MacroData+1)))
        renderMacro()
    end)

    -- Macro rows
    for i, m in ipairs(MacroData) do
        local acc = card(52)
        pad(acc,10,12)
        local arrow = new("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromOffset(20,52),
            Font=Enum.Font.GothamBold,Text="⌄",TextColor3=C.muted,TextSize=14}, acc)
        local icon = new("Frame",{Size=UDim2.fromOffset(34,34),Position=UDim2.fromOffset(28,9),
            BackgroundColor3=C.panel2,BorderSizePixel=0}, acc)
        round(icon,7); stroke(icon)
        new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
            Text="</>",TextColor3=C.icon,TextSize=11}, icon)
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(74,0),Size=UDim2.new(1,-200,1,0),
            Font=Enum.Font.GothamBold,Text=m.Name,TextColor3=C.text,TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left}, acc)
        mkToggle(acc, m.Enabled, function(v) m.Enabled = v end)

        -- Expand body
        local body = new("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,
            AutomaticSize=Enum.AutomaticSize.Y}, page)
        new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder}, body)
        body.Visible = (i == 4)  -- chỉ macro 4 mở rộng mặc định

        -- Inner card
        local inner = new("Frame",{Size=UDim2.new(1,0,0,110),BackgroundColor3=C.panel,
            BorderSizePixel=0,LayoutOrder=1}, body)
        round(inner,10); pad(inner,14,14)
        -- 4-column header
        local colW = {}
        local totalW = 620 - 174 - 28 -- approximate content width
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,0),Size=UDim2.new(.28,0,0,16),
            Font=Enum.Font.Gotham,Text="Vũ khí",TextColor3=C.muted,TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left}, inner)
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(.30,0,0,0),Size=UDim2.new(.28,0,0,16),
            Font=Enum.Font.Gotham,Text="Chiêu thức",TextColor3=C.muted,TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left}, inner)
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(.62,0,0,0),Size=UDim2.new(.18,0,0,16),
            Font=Enum.Font.Gotham,Text="Hold",TextColor3=C.muted,TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left}, inner)
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(.80,0,0,0),Size=UDim2.new(.20,0,0,16),
            Font=Enum.Font.Gotham,Text="Delay",TextColor3=C.muted,TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left}, inner)
        -- Row 2: controls
        local wWrap = new("Frame",{Position=UDim2.fromOffset(0,26),Size=UDim2.new(.28,0,0,34),
            BackgroundTransparency=1}, inner)
        mkDropdown(wWrap, {"Võ","Kiếm","Súng","Trái"}, m.Weapon, function(v) m.Weapon = v end, 150)
        local sWrap = new("Frame",{Position=UDim2.new(.30,0,0,26),Size=UDim2.new(.28,0,0,34),
            BackgroundTransparency=1}, inner)
        mkDropdown(sWrap, {"Z","X","C","V","F"}, m.Skill, function(v) m.Skill = v end, 150)
        local hWrap = new("Frame",{Position=UDim2.new(.62,0,0,26),Size=UDim2.new(.18,0,0,34),
            BackgroundTransparency=1}, inner)
        mkStepper(hWrap, m.Hold, 0.05, function(v) m.Hold = v end, 100)
        local dWrap = new("Frame",{Position=UDim2.new(.80,0,0,26),Size=UDim2.new(.20,0,0,34),
            BackgroundTransparency=1}, inner)
        mkStepper(dWrap, m.Delay, 0.05, function(v) m.Delay = v end, 100)

        arrow.Parent.MouseButton1Click = nil
        local hit = new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=2}, acc)
        hit.MouseButton1Click:Connect(function()
            body.Visible = not body.Visible
            arrow.Text = body.Visible and "⌃" or "⌄"
        end)
        arrow.Text = body.Visible and "⌃" or "⌄"
    end
end

-- ========== RENDER TAB: VISUAL ==========
local renderVisual
renderVisual = function()
    clear()
    settingRow("👤", "Player ESP", "Hiển thị người chơi (Box, Name, Line,...)", function(ca)
        mkToggle(ca, State.ESP, function(v) State.ESP = v; ESP.Refresh() end)
    end)
    settingRow("👁", "Show Hitbox", "Hiển thị hitbox của người chơi", function(ca)
        mkToggle(ca, Config.Visual.ShowHitbox, function(v) Config.Visual.ShowHitbox = v end)
    end)
    settingRow("↔", "ESP Distance", "Hiển thị khoảng cách đến người chơi", function(ca)
        mkToggle(ca, Config.Visual.ShowDistance, function(v) Config.Visual.ShowDistance = v end)
    end)
    settingRow("✚", "ESP Health", "Hiển thị thanh máu của người chơi", function(ca)
        mkToggle(ca, Config.Visual.ShowHealth, function(v) Config.Visual.ShowHealth = v end)
    end)
    settingRow("★", "ESP Level", "Hiển thị cấp độ của người chơi", function(ca)
        mkToggle(ca, Config.Visual.ShowLevel, function(v) Config.Visual.ShowLevel = v end)
    end)
    settingRow("👥", "ESP Team", "Hiển thị team của người chơi", function(ca)
        mkToggle(ca, Config.Visual.ShowTeam, function(v) Config.Visual.ShowTeam = v end)
    end)
    -- Bottom 2-column
    local bottom = new("Frame",{Size=UDim2.new(1,0,0,190),BackgroundTransparency=1}, page)
    local left = new("Frame",{Size=UDim2.new(.48,0,1,0),BackgroundColor3=C.panel,BorderSizePixel=0}, bottom)
    round(left,10); pad(left,12)
    local lic = new("Frame",{Size=UDim2.fromOffset(32,32),Position=UDim2.fromOffset(0,0),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, left)
    round(lic,7); stroke(lic)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="🎨",TextColor3=C.icon,TextSize=14}, lic)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(42,0),Size=UDim2.new(1,-42,0,16),
        Font=Enum.Font.GothamBold,Text="Team Color",TextColor3=C.text,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left}, left)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(42,16),Size=UDim2.new(1,-42,0,14),
        Font=Enum.Font.Gotham,Text="Chọn màu cho từng team",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, left)
    local teams = {"Blue","Red","Green","Yellow"}
    for idx, tname in ipairs(teams) do
        local tRow = new("Frame",{Position=UDim2.fromOffset(0, 44 + (idx-1)*30),
            Size=UDim2.new(1,0,0,26),BackgroundColor3=C.panel2,BorderSizePixel=0}, left)
        round(tRow,6)
        local dot = new("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(8,6),
            BackgroundColor3=Config.Visual.TeamColors[tname],BorderSizePixel=0}, tRow)
        round(dot,4)
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(28,0),Size=UDim2.new(1,-50,1,0),
            Font=Enum.Font.GothamMedium,Text=tname,TextColor3=C.text,TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left}, tRow)
        new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),
            Size=UDim2.fromOffset(14,14),Font=Enum.Font.GothamBold,Text="⌄",TextColor3=C.muted,TextSize=11}, tRow)
        local hit = new("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""}, tRow)
        hit.MouseButton1Click:Connect(function()
            for _, data in pairs(ESP.Cache) do
                if data.HL then data.HL.FillColor = Config.Visual.TeamColors[tname] end
            end
            U.Notify("Team Color", "Đã chọn "..tname, 2)
        end)
    end

    local right = new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
        Size=UDim2.new(.48,0,1,0),BackgroundColor3=C.panel,BorderSizePixel=0}, bottom)
    round(right,10); pad(right,12)
    local ric = new("Frame",{Size=UDim2.fromOffset(32,32),Position=UDim2.fromOffset(0,0),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, right)
    round(ric,7); stroke(ric)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="◐",TextColor3=C.icon,TextSize=14}, ric)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(42,0),Size=UDim2.new(1,-42,0,16),
        Font=Enum.Font.GothamBold,Text="Transparency",TextColor3=C.text,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left}, right)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(42,16),Size=UDim2.new(1,-42,0,14),
        Font=Enum.Font.Gotham,Text="Độ trong suốt ESP",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, right)
    -- Slider simple
    local sTrack = new("Frame",{Position=UDim2.fromOffset(0,80),Size=UDim2.new(1,-70,0,4),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, right)
    round(sTrack,2)
    local sFill = new("Frame",{Size=UDim2.new(1 - Config.Visual.Transparency,0,1,0),
        BackgroundColor3=C.accent,BorderSizePixel=0}, sTrack)
    round(sFill,2)
    local sKnob = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(1 - Config.Visual.Transparency,0,0.5,0),
        Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=3}, sTrack)
    round(sKnob,7)
    local sVal = new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,64),
        Size=UDim2.fromOffset(60,28),BackgroundColor3=C.panel2,BorderSizePixel=0}, right)
    round(sVal,6); stroke(sVal)
    local sLbl = new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold,Text=string.format("%d%%", math.floor((1-Config.Visual.Transparency)*100)),
        TextColor3=C.text,TextSize=10}, sVal)
    local dragging = false
    sTrack.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local rx = math.clamp((i.Position.X - sTrack.AbsolutePosition.X)/sTrack.AbsoluteSize.X, 0, 1)
            local t = 1 - rx
            sFill.Size = UDim2.new(rx,0,1,0)
            sKnob.Position = UDim2.new(rx,0,0.5,0)
            sLbl.Text = string.format("%d%%", math.floor(rx*100))
            Config.Visual.Transparency = t
            for _, data in pairs(ESP.Cache) do
                if data.HL then data.HL.FillTransparency = t end
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

-- ========== RENDER TAB: MOVE ==========
local renderMove
renderMove = function()
    clear()
    -- Speed Boost row
    local c1 = card(90); pad(c1, 12, 12)
    local ic1 = new("Frame",{Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(0,4),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, c1)
    round(ic1,8); stroke(ic1)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="⚡",TextColor3=C.icon,TextSize=16}, ic1)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,4),Size=UDim2.new(1,-180,0,18),
        Font=Enum.Font.GothamBold,Text="Speed Boost",TextColor3=C.text,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left}, c1)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,22),Size=UDim2.new(1,-180,0,16),
        Font=Enum.Font.Gotham,Text="Tăng tốc độ di chuyển",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, c1)
    mkToggle(c1, State.Sprint, function(v) State.Sprint = v end)
    mkSliderButtons(c1, 0.5, 3.0, Config.Move.SpeedMultiplier, "", function(v)
        Config.Move.SpeedMultiplier = v
    end).Position = UDim2.new(0, 50, 0, 46)
    -- Wait, slider should be inside card, repositioned. Use direct parent instead.
    -- The mkSliderButtons returns root; reposition it inside card:
    -- Actually simpler: create slider as child of card at appropriate position
end

-- Override renderMove properly
renderMove = function()
    clear()
    -- Speed Boost
    local c1 = card(96); pad(c1, 12, 12)
    local ic1 = new("Frame",{Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(0,4),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, c1)
    round(ic1,8); stroke(ic1)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="⚡",TextColor3=C.icon,TextSize=16}, ic1)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,4),Size=UDim2.new(1,-180,0,18),
        Font=Enum.Font.GothamBold,Text="Speed Boost",TextColor3=C.text,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left}, c1)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,22),Size=UDim2.new(1,-180,0,16),
        Font=Enum.Font.Gotham,Text="Tăng tốc độ di chuyển",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, c1)
    mkToggle(c1, State.Sprint, function(v) State.Sprint = v end)
    -- Slider row inside card
    local sWrap1 = new("Frame",{Position=UDim2.fromOffset(50,48),Size=UDim2.new(1,-62,0,36),
        BackgroundTransparency=1}, c1)
    local sTrack = new("Frame",{Position=UDim2.fromOffset(0,16),Size=UDim2.new(1,-90,0,4),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, sWrap1)
    round(sTrack,2)
    local initRatio = (Config.Move.SpeedMultiplier - 0.5)/2.5
    local sFill = new("Frame",{Size=UDim2.new(initRatio,0,1,0),BackgroundColor3=C.accent,BorderSizePixel=0}, sTrack)
    round(sFill,2)
    local sKnob = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(initRatio,0,0.5,0),
        Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=3}, sTrack)
    round(sKnob,7)
    local sValBox = new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,4),
        Size=UDim2.fromOffset(78,28),BackgroundColor3=C.panel2,BorderSizePixel=0}, sWrap1)
    round(sValBox,6); stroke(sValBox)
    local sLbl = new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold,Text=string.format("%d%%", math.floor(Config.Move.SpeedMultiplier*100)),
        TextColor3=C.text,TextSize=10}, sValBox)
    local drg = false
    sTrack.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local rx = math.clamp((i.Position.X - sTrack.AbsolutePosition.X)/sTrack.AbsoluteSize.X, 0, 1)
            sFill.Size = UDim2.new(rx,0,1,0)
            sKnob.Position = UDim2.new(rx,0,0.5,0)
            Config.Move.SpeedMultiplier = 0.5 + rx*2.5
            sLbl.Text = string.format("%d%%", math.floor(Config.Move.SpeedMultiplier*100))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=false end
    end)

    -- Jump Boost
    local c2 = card(96); pad(c2, 12, 12)
    local ic2 = new("Frame",{Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(0,4),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, c2)
    round(ic2,8); stroke(ic2)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="🦘",TextColor3=C.icon,TextSize=15}, ic2)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,4),Size=UDim2.new(1,-180,0,18),
        Font=Enum.Font.GothamBold,Text="Jump Boost",TextColor3=C.text,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left}, c2)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,22),Size=UDim2.new(1,-180,0,16),
        Font=Enum.Font.Gotham,Text="Tăng lực nhảy",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, c2)
    mkToggle(c2, State.Jump, function(v) State.Jump = v end)
    local sWrap2 = new("Frame",{Position=UDim2.fromOffset(50,48),Size=UDim2.new(1,-62,0,36),
        BackgroundTransparency=1}, c2)
    local jTrack = new("Frame",{Position=UDim2.fromOffset(0,16),Size=UDim2.new(1,-90,0,4),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, sWrap2)
    round(jTrack,2)
    local jRatio = (Config.Move.JumpMultiplier - 0.5)/2.5
    local jFill = new("Frame",{Size=UDim2.new(jRatio,0,1,0),BackgroundColor3=C.accent,BorderSizePixel=0}, jTrack)
    round(jFill,2)
    local jKnob = new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(jRatio,0,0.5,0),
        Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=3}, jTrack)
    round(jKnob,7)
    local jValBox = new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,4),
        Size=UDim2.fromOffset(78,28),BackgroundColor3=C.panel2,BorderSizePixel=0}, sWrap2)
    round(jValBox,6); stroke(jValBox)
    local jLbl = new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold,Text=string.format("%d%%", math.floor(Config.Move.JumpMultiplier*100)),
        TextColor3=C.text,TextSize=10}, jValBox)
    local drg2 = false
    jTrack.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg2=true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drg2 and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local rx = math.clamp((i.Position.X - jTrack.AbsolutePosition.X)/jTrack.AbsoluteSize.X, 0, 1)
            jFill.Size = UDim2.new(rx,0,1,0)
            jKnob.Position = UDim2.new(rx,0,0.5,0)
            Config.Move.JumpMultiplier = 0.5 + rx*2.5
            jLbl.Text = string.format("%d%%", math.floor(Config.Move.JumpMultiplier*100))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg2=false end
    end)

    -- No Clip
    settingRow("↔", "No clip", "Xuyên vật thể", function(ca)
        mkToggle(ca, State.NoClip, function(v) State.NoClip = v end)
    end)
    -- Fly
    settingRow("✈", "Fly button", "Bật nút bay", function(ca)
        mkToggle(ca, State.Fly, function(v) State.Fly = v; flySet(v) end)
    end)
end

-- ========== RENDER TAB: SETTING ==========
local renderSetting
renderSetting = function()
    clear()
    settingRow("⚡", "Bật FixLag", "Giảm lag, tăng FPS, tối ưu hiệu suất game", function(ca)
        mkToggle(ca, State.FixLag, function(v) State.FixLag = v; fixLagSet(v) end)
    end)
    -- Copy Discord
    local dcRow = card(60); pad(dcRow, 10, 12)
    local dIc = new("Frame",{Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(0,1),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, dcRow)
    round(dIc,8); stroke(dIc)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="🎮",TextColor3=C.icon,TextSize=15}, dIc)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,-4),Size=UDim2.new(1,-180,0,18),
        Font=Enum.Font.GothamBold,Text="Copy Link Discord",TextColor3=C.text,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left}, dcRow)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,14),Size=UDim2.new(1,-180,0,16),
        Font=Enum.Font.Gotham,Text="Sao chép link Discord của chủ sở hữu",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, dcRow)
    local cBtn = new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(100,34),BackgroundColor3=C.accent,
        Text="🔗  Copy",Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=11}, dcRow)
    round(cBtn,8)
    cBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then setclipboard(Config.Brand.Discord); U.Notify("Copy","Đã copy Discord link",2) end
        end)
    end)
    -- Divider
    local div = new("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=C.panel2,BorderSizePixel=0}, page)
    -- Reset
    local rRow = card(60); pad(rRow, 10, 12)
    local rIc = new("Frame",{Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(0,1),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, rRow)
    round(rIc,8); stroke(rIc)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="↺",TextColor3=C.icon,TextSize=16}, rIc)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,-4),Size=UDim2.new(1,-180,0,18),
        Font=Enum.Font.GothamBold,Text="Đặt về Mặc định",TextColor3=C.text,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left}, rRow)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,14),Size=UDim2.new(1,-180,0,16),
        Font=Enum.Font.Gotham,Text="Khôi phục toàn bộ cài đặt về mặc định",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, rRow)
    local rBtn = new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(110,34),BackgroundColor3=C.panel2,
        Text="↺  Reset",Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=11}, rRow)
    round(rBtn,8); stroke(rBtn)
    rBtn.MouseButton1Click:Connect(function()
        State.CameraLock=false; State.SilentAimMode="FOV"; State.FOVCircle=false; State.FOVSize=150
        State.ESP=true; State.Sprint=false; State.Jump=false; State.NoClip=false
        State.Fly=false; State.WalkOnWater=false; State.FixLag=false
        Config.Move.SpeedMultiplier=1.0; Config.Move.JumpMultiplier=1.0
        Config.Visual.Transparency=0.7; Config.Visual.ShowHitbox=false
        Config.Visual.ShowLevel=false; Config.Visual.ShowTeam=false
        fovCircle.Visible=false; fovCircle.Size=UDim2.fromOffset(300,300)
        flySet(false); ESP.Refresh()
        U.Notify("Reset","Đã khôi phục mặc định",2)
        renderSetting()
    end)
    -- Save
    local svRow = card(60); pad(svRow, 10, 12)
    local svIc = new("Frame",{Size=UDim2.fromOffset(38,38),Position=UDim2.fromOffset(0,1),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, svRow)
    round(svIc,8); stroke(svIc)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="💾",TextColor3=C.icon,TextSize=14}, svIc)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,-4),Size=UDim2.new(1,-180,0,18),
        Font=Enum.Font.GothamBold,Text="Lưu cài Liệu",TextColor3=C.text,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left}, svRow)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(50,14),Size=UDim2.new(1,-180,0,16),
        Font=Enum.Font.Gotham,Text="Lưu lại cài đặt hiện tại",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, svRow)
    local svBtn = new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,0,0.5,0),
        Size=UDim2.fromOffset(110,34),BackgroundColor3=C.accent,
        Text="💾  Save",Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=11}, svRow)
    round(svBtn,8)
    svBtn.MouseButton1Click:Connect(function()
        U.Notify("Save","Đã lưu cài đặt hiện tại",2)
    end)
    -- Walk on water
    settingRow("🌊", "Đi trên nước", "Cho phép di chuyển trên mặt nước", function(ca)
        mkToggle(ca, State.WalkOnWater, function(v) State.WalkOnWater = v end)
    end)
end

-- ========== TAB SWITCHING ==========
local function show(name)
    State.Tab = name
    for n, t in pairs(tabs) do
        if n == name then
            t.btn.BackgroundColor3 = C.accent
            t.icon.TextColor3 = C.text
            t.text.TextColor3 = C.text
        else
            t.btn.BackgroundColor3 = C.sidebar
            t.icon.TextColor3 = C.icon
            t.text.TextColor3 = C.muted
        end
    end
    for _, fn in ipairs(dropClose) do fn() end
    if name == "Combat" then renderCombat()
    elseif name == "Macro" then renderMacro()
    elseif name == "Visual" then renderVisual()
    elseif name == "Move" then renderMove()
    elseif name == "Setting" then renderSetting() end
end

tCombat.MouseButton1Click:Connect(function() show("Combat") end)
tMacro.MouseButton1Click:Connect(function() show("Macro") end)
tVisual.MouseButton1Click:Connect(function() show("Visual") end)
tMove.MouseButton1Click:Connect(function() show("Move") end)
tSetting.MouseButton1Click:Connect(function() show("Setting") end)

-- Drag
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end)

_G.DX_ToggleMain = function() main.Visible = State.Visible end

local minimized = false
btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main.Size = UDim2.fromOffset(640,60)
        sidebar.Visible=false; page.Visible=false
    else
        main.Size = Config.UI.MainSize
        sidebar.Visible=true; page.Visible=true
    end
end)
btnClose.MouseButton1Click:Connect(function() State.Visible=false; main.Visible=false end)

-- Keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.UI.ToggleKey then
        State.Visible = not State.Visible
        main.Visible = State.Visible
    end
end)

-- Init
show("Combat")
ESP.Refresh()
_G.DX_RefreshMacroButton()

task.spawn(function()
    task.wait(1)
    U.Notify("Dungdx PvP","Loaded! RightShift = UI",5)
end)

print("==============================================")
print("DUNGDX PVP — v2.1.0 BF")
print("Owner: Dungdx")
print("Discord: https://discord.gg/Hwwa3VYxW6")
print("==============================================")