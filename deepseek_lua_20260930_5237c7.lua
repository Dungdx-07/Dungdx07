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

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
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
    Brand = {
        Owner = "Dungdx",
        Discord = "https://discord.gg/Hwwa3VYxW6",
        Name = "Dungdx PvP",
        Version = "2.1.0 BF",
    },
    UI = {
        ToggleKey = Enum.KeyCode.RightShift,
        MainSize = UDim2.fromOffset(620, 420),
        Scale = 0.9,
        ShowDXButton = true,
        ShowMacroButton = true,
    },
    Combat = {
        AimEnabled = true,
        FOV = 150,
        MaxDistance = 160,
        Smoothness = 0.18,
        TeamCheck = true,
        AutoAttack = true,
        AutoAttackRange = 30,
        AttackInterval = 0.15,
        FastAttackDelay = 0,
    },
    Visual = {
        ESPEnabled = true,
        ShowNames = true,
        ShowDistance = true,
        ShowFOV = true,
        ShowHealth = true,
    },
    Movement = {
        SprintEnabled = false,
        SprintSpeed = 24,
        JumpBoostEnabled = false,
        JumpPower = 60,
        DashEnabled = true,
        DashKey = Enum.KeyCode.Q,
        DashSpeed = 85,
        DashCooldown = 1.2,
    },
    Macro = {
        Default = {
            {Action="C", Hold=0.00, Delay=0.30},
            {Action="X", Hold=0.00, Delay=1.00},
            {Action="Z", Hold=0.00, Delay=0.59},
            {Action="Z", Hold=0.00, Delay=1.23},
            {Action="F", Hold=0.00, Delay=0.44},
            {Action="C", Hold=0.60, Delay=1.25},
            {Action="X", Hold=0.00, Delay=0.25},
            {Action="Z", Hold=0.00, Delay=0.50},
        },
        Loop = false,
    },
}

local State = {
    Visible = true,
    Tab = "Combat",
    Aim = Config.Combat.AimEnabled,
    ESP = Config.Visual.ESPEnabled,
    FOV = Config.Visual.ShowFOV,
    Sprint = Config.Movement.SprintEnabled,
    Jump = Config.Movement.JumpBoostEnabled,
    AutoAttack = Config.Combat.AutoAttack,
    Macro = false,
    Target = nil,
    Status = "Sẵn sàng",
    LastDash = 0,
    LastAttack = 0,
}

-- ==================== UTIL ====================
local U = {}
function U.GetRoot(ch) return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart) end
function U.GetHum(ch) return ch and ch:FindFirstChildOfClass("Humanoid") end
function U.Alive(p)
    local ch = p.Character
    if not ch then return end
    local h = U.GetHum(ch); local r = U.GetRoot(ch)
    if h and r and h.Health > 0 then return ch, h, r end
end
function U.Notify(t, x, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=t or "Dungdx", Text=x or "", Duration=d or 5})
    end)
end
function U.EquipMelee()
    if not Backpack or not Humanoid then return end
    for _, t in ipairs(Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Melee" then Humanoid:EquipTool(t) return end
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
                        if sd <= Config.Combat.FOV then
                            local score = sd + d * 0.08
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
    if not tool then
        U.EquipMelee()
        tool = Character:FindFirstChildOfClass("Tool")
        if not tool then return end
    end
    if reRegisterAttack then
        pcall(function() reRegisterAttack:FireServer(Config.Combat.FastAttackDelay) end)
    end
    if tool:FindFirstChild("LeftClickRemote") then
        pcall(function()
            tool.LeftClickRemote:FireServer(Vector3.new(0.01, -500, 0.01), 1, true)
        end)
    end
    if tool.ToolTip == "Gun" and reShootGunEvent then
        local _, _, r = U.Alive(target)
        if r then pcall(function() reShootGunEvent:FireServer(r.Position, {}) end) end
    end
end

-- ==================== ESP ====================
local ESP = { Cache = setmetatable({}, {__mode="k"}) }
function ESP.Clear(cat)
    for inst, data in pairs(ESP.Cache) do
        if not cat or data.Cat == cat then
            if data.BB and data.BB.Parent then data.BB:Destroy() end
            if data.HL and data.HL.Parent then data.HL:Destroy() end
            if data.Conn then data.Conn:Disconnect() end
            ESP.Cache[inst] = nil
        end
    end
end
function ESP.Add(p)
    if p == LP or ESP.Cache[p] then return end
    local ch, _, root = U.Alive(p)
    if not ch or not root then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = ch
    hl.FillColor = Color3.fromRGB(225, 83, 92)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
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
    nameLbl.Size = UDim2.new(1, 0, 0, 22)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextColor3 = Color3.fromRGB(240, 242, 247)
    nameLbl.TextStrokeTransparency = 0.4
    nameLbl.TextSize = 12
    nameLbl.RichText = true
    nameLbl.Parent = bb

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1, -20, 0, 6)
    hpBg.Position = UDim2.new(0, 10, 0, 24)
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = bb
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(70, 205, 126)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

    local conn = RunService.RenderStepped:Connect(function()
        if not bb.Parent then return end
        local _, h2, r2 = U.Alive(p)
        if h2 and r2 then
            local dist = (Camera.CFrame.Position - r2.Position).Magnitude
            local n = Config.Visual.ShowNames and p.Name or ""
            local d = Config.Visual.ShowDistance and string.format(" <font color='#999'>[%.0f]</font>", dist) or ""
            nameLbl.Text = n .. d
            local ratio = math.clamp(h2.Health / math.max(h2.MaxHealth, 1), 0, 1)
            hpFill.Size = UDim2.new(ratio, 0, 1, 0)
            if ratio > 0.6 then hpFill.BackgroundColor3 = Color3.fromRGB(70, 205, 126)
            elseif ratio > 0.3 then hpFill.BackgroundColor3 = Color3.fromRGB(240, 190, 60)
            else hpFill.BackgroundColor3 = Color3.fromRGB(225, 83, 92) end
            hpBg.Visible = Config.Visual.ShowHealth
        end
    end)
    ESP.Cache[p] = {BB=bb, HL=hl, Conn=conn, Cat="Player"}
end
function ESP.Refresh()
    if not State.ESP then ESP.Clear() return end
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then ESP.Add(p) end end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.5) if State.ESP then ESP.Add(p) end end)
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

-- ==================== MACRO ====================
local Macro = {}
Macro._Thread = nil

function Macro.Start()
    if State.Macro then return end
    State.Macro = true
    Macro._Thread = task.spawn(function()
        repeat
            for _, step in ipairs(Config.Macro.Default) do
                if not State.Macro then break end
                local key = Enum.KeyCode[step.Action]
                if key then
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    if (tonumber(step.Hold) or 0) > 0 then
                        task.wait(math.clamp(step.Hold, 0, 3))
                    else
                        task.wait(0.02)
                    end
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
                task.wait(math.max(0, tonumber(step.Delay) or 0))
            end
        until not Config.Macro.Loop or not State.Macro
        State.Macro = false
        if _G.DX_RefreshMacroButton then pcall(_G.DX_RefreshMacroButton) end
    end)
end

function Macro.Stop()
    State.Macro = false
    if _G.DX_RefreshMacroButton then pcall(_G.DX_RefreshMacroButton) end
end

function Macro.Toggle()
    if State.Macro then Macro.Stop() else Macro.Start() end
end

-- ==================== CAMERA AIM LOOP ====================
RunService.RenderStepped:Connect(function()
    if not State.Aim then State.Target = nil return end
    local t = T.Acquire()
    if t then
        local _, _, r = U.Alive(t)
        if r then
            local cur = Camera.CFrame
            local desired = CFrame.lookAt(cur.Position, r.Position)
            Camera.CFrame = cur:Lerp(desired, math.clamp(Config.Combat.Smoothness, 0, 1))
        end
    end
end)

-- ==================== AUTO ATTACK LOOP ====================
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if State.AutoAttack and State.Target then
                local _, _, r = U.Alive(State.Target)
                if r and Root and (Root.Position - r.Position).Magnitude <= Config.Combat.AutoAttackRange then
                    FA.Attack(State.Target)
                end
            end
        end)
    end
end)

-- ==================== SPRINT / JUMP REAPPLY ====================
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if Humanoid and Humanoid.Health > 0 then
                if State.Sprint then Humanoid.WalkSpeed = Config.Movement.SprintSpeed end
                if State.Jump then
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = Config.Movement.JumpPower
                end
            end
        end)
    end
end)

-- ==================== UI ====================
local C = {
    bg=Color3.fromRGB(14,15,20), panel=Color3.fromRGB(21,23,30),
    panel2=Color3.fromRGB(29,31,40), text=Color3.fromRGB(240,242,247),
    muted=Color3.fromRGB(155,161,174), accent=Color3.fromRGB(105,132,255),
    good=Color3.fromRGB(70,205,126), bad=Color3.fromRGB(225,83,92),
    stroke=Color3.fromRGB(51,55,68), macro=Color3.fromRGB(255,140,40),
}
local function new(c, p, par) local x=Instance.new(c) for k,v in pairs(p or {}) do x[k]=v end x.Parent=par return x end
local function round(x,r) new("UICorner",{CornerRadius=UDim.new(0,r or 8)},x) end
local function outline(x) new("UIStroke",{Color=C.stroke,Thickness=1},x) end
local function pad(x,n) new("UIPadding",{PaddingTop=UDim.new(0,n),PaddingBottom=UDim.new(0,n),PaddingLeft=UDim.new(0,n),PaddingRight=UDim.new(0,n)},x) end

local gui = new("ScreenGui",{Name="DungdxPvP",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},PlayerGui)

-- ========== FLOAT BUTTONS ==========
local floatLayer = new("Frame",{
    Name="FloatLayer",
    Size=UDim2.new(1,0,1,0),
    BackgroundTransparency=1,
    Active=false,
}, gui)

-- DX Button (toggle UI)
local btnDX = new("TextButton",{
    Name="BtnDX",
    Size=UDim2.fromOffset(46,46),
    Position=UDim2.new(0,14,0.5,-23),
    BackgroundColor3=C.accent,
    Text="DX",
    Font=Enum.Font.GothamBold,
    TextColor3=C.text,
    TextSize=14,
    AutoButtonColor=true,
}, floatLayer)
round(btnDX,23); outline(btnDX)

-- MACRO Button (toggle macro)
local btnMacro = new("TextButton",{
    Name="BtnMacro",
    Size=UDim2.fromOffset(46,46),
    Position=UDim2.new(0,14,0.5,30),
    BackgroundColor3=C.panel2,
    Text="MCR",
    Font=Enum.Font.GothamBold,
    TextColor3=C.muted,
    TextSize=12,
    AutoButtonColor=true,
}, floatLayer)
round(btnMacro,23); outline(btnMacro)

_G.DX_RefreshMacroButton = function()
    if State.Macro then
        btnMacro.BackgroundColor3 = C.macro
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
    -- main will be created below; use deferred call
    if _G.DX_ToggleMain then _G.DX_ToggleMain() end
end)
btnMacro.MouseButton1Click:Connect(function()
    Macro.Toggle()
end)

-- ========== MAIN UI ==========
local main = new("Frame",{
    Name="Main",
    Size=Config.UI.MainSize,
    Position=UDim2.new(0.5,-310,0.5,-210),
    BackgroundColor3=C.bg,
    BorderSizePixel=0,
    Active=true,
}, gui)
round(main,14); outline(main)

-- UIScale for responsive
local uiScale = new("UIScale",{Scale=Config.UI.Scale}, main)

local top = new("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.panel,BorderSizePixel=0}, main)
round(top,14)

new("TextLabel",{
    BackgroundTransparency=1, Position=UDim2.fromOffset(14,6), Size=UDim2.fromOffset(400,22),
    Font=Enum.Font.GothamBold, Text=Config.Brand.Name.."  •  v"..Config.Brand.Version,
    TextColor3=C.text, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left,
}, top)
new("TextLabel",{
    BackgroundTransparency=1, Position=UDim2.fromOffset(14,28), Size=UDim2.fromOffset(500,16),
    Font=Enum.Font.Gotham, Text=Config.Brand.Owner.."  |  discord.gg/Hwwa3VYxW6",
    TextColor3=C.muted, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
}, top)

-- Top buttons: minimize + close
local btnMin = new("TextButton",{
    Size=UDim2.fromOffset(32,28), Position=UDim2.new(1,-76,0,12),
    BackgroundColor3=C.panel2, Text="—", Font=Enum.Font.GothamBold,
    TextColor3=C.text, TextSize=16,
}, top)
round(btnMin,6)

local btnClose = new("TextButton",{
    Size=UDim2.fromOffset(32,28), Position=UDim2.new(1,-40,0,12),
    BackgroundColor3=C.bad, Text="✕", Font=Enum.Font.GothamBold,
    TextColor3=Color3.fromRGB(255,255,255), TextSize=12,
}, top)
round(btnClose,6)

-- Sidebar
local sidebar = new("Frame",{
    Position=UDim2.fromOffset(10,60), Size=UDim2.fromOffset(130,350),
    BackgroundColor3=C.panel, BorderSizePixel=0,
}, main)
round(sidebar,10); pad(sidebar,7)
new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder}, sidebar)

local page = new("ScrollingFrame",{
    Position=UDim2.fromOffset(150,60), Size=UDim2.new(1,-162,1,-72),
    BackgroundTransparency=1, BorderSizePixel=0,
    CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=4,
}, main)
new("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder}, page)

local statusLabel = new("TextLabel",{
    LayoutOrder=99, Size=UDim2.new(1,0,0,50), BackgroundTransparency=1,
    Font=Enum.Font.Gotham, TextColor3=C.muted, TextSize=9,
    TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Bottom,
}, sidebar)

local tabs = {}
local function tabBtn(n, o)
    local b = new("TextButton",{
        LayoutOrder=o, Size=UDim2.new(1,0,0,34),
        BackgroundColor3=C.panel2, Text=n, Font=Enum.Font.GothamMedium,
        TextColor3=C.muted, TextSize=11,
    }, sidebar)
    round(b,7); tabs[n]=b; return b
end
local tCombat=tabBtn("⚔ Combat",1)
local tMacro=tabBtn("⌁ Macro",2)
local tVisual=tabBtn("◉ Visual",3)
local tMove=tabBtn("✦ Move",4)
local tSettings=tabBtn("⚙ Settings",5)

local function status(s)
    State.Status=tostring(s)
    statusLabel.Text="STATUS\n"..State.Status
end

local function title(text, sub)
    local b = new("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
    round(b,9); pad(b,9)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),Font=Enum.Font.GothamBold,
        Text=text,TextColor3=C.text,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left}, b)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,20),Size=UDim2.new(1,0,0,18),
        Font=Enum.Font.Gotham,Text=sub or "",TextColor3=C.muted,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left}, b)
end

local function row(text, right)
    local r = new("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
    round(r,8); pad(r,8)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(.55,0,1,0),Font=Enum.Font.Gotham,
        Text=text,TextColor3=C.muted,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}, r)
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(.55,0,0,0),Size=UDim2.new(.45,0,1,0),
        Font=Enum.Font.GothamBold,Text=right or "",TextColor3=C.text,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Right}, r)
end

local function toggle(text, value, cb)
    local r = new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
    round(r,8); pad(r,8)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-56,1,0),Font=Enum.Font.GothamMedium,
        Text=text,TextColor3=C.text,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}, r)
    local b = new("TextButton",{Size=UDim2.fromOffset(42,22),Position=UDim2.new(1,-42,.5,-11),
        BackgroundColor3=value and C.good or C.panel2,Text=value and "ON" or "OFF",
        Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=9}, r)
    round(b,11)
    b.MouseButton1Click:Connect(function()
        value = not value
        b.Text = value and "ON" or "OFF"
        b.BackgroundColor3 = value and C.good or C.panel2
        cb(value)
    end)
end

local function actionBtn(text, color, cb)
    local b = new("TextButton",{Size=UDim2.new(1,0,0,36),BackgroundColor3=color or C.accent,
        Text=text,Font=Enum.Font.GothamBold,TextColor3=C.text,TextSize=10}, page)
    round(b,8); b.MouseButton1Click:Connect(cb); return b
end

local function slider(text, min, max, value, cb)
    local r = new("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
    round(r,8); pad(r,8)
    local lbl = new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),Font=Enum.Font.Gotham,
        Text=text..": "..tostring(value),TextColor3=C.text,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left}, r)
    local track = new("Frame",{Size=UDim2.new(1,0,0,6),Position=UDim2.fromOffset(0,26),
        BackgroundColor3=C.panel2,BorderSizePixel=0}, r)
    round(track,3)
    local fill = new("Frame",{Size=UDim2.new((value-min)/math.max(max-min,1),0,1,0),
        BackgroundColor3=C.accent,BorderSizePixel=0}, track)
    round(fill,3)
    local dragging = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local rx = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
            local v = min + (max-min)*rx
            fill.Size = UDim2.new(rx,0,1,0)
            lbl.Text = text..": "..string.format("%.2f", v)
            cb(v)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
end

local fov = new("Frame",{
    AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(Config.Combat.FOV*2, Config.Combat.FOV*2),
    BackgroundTransparency=1, Visible=State.FOV, ZIndex=3}, gui)
round(fov,999); outline(fov)

local function clear()
    for _, x in ipairs(page:GetChildren()) do
        if x:IsA("Frame") or x:IsA("TextButton") or x:IsA("TextLabel") then x:Destroy() end
    end
end

local renderMacro, renderCombat, renderVisual, renderMove, renderSettings

renderCombat = function()
    clear()
    title("Combat","Target / FOV / Auto Attack")
    toggle("Aim / CamLock", State.Aim, function(v) State.Aim=v if not v then State.Target=nil end end)
    toggle("Auto Attack", State.AutoAttack, function(v) State.AutoAttack=v end)
    slider("Attack Interval", 0.05, 0.5, Config.Combat.AttackInterval, function(v) Config.Combat.AttackInterval=v end)
    row("FOV Radius", tostring(Config.Combat.FOV).." px")
    row("Max Distance", tostring(Config.Combat.MaxDistance).." studs")
    row("Target", State.Target and State.Target.Name or "None")
    row("Team Check", Config.Combat.TeamCheck and "ON" or "OFF")
    actionBtn("ACQUIRE TARGET", C.accent, function()
        local t = T.Acquire()
        status(t and ("Target: "..t.Name) or "Không có target")
    end)
    actionBtn("ATTACK NOW", C.bad, function()
        local t = State.Target or T.Acquire()
        if t then FA.Attack(t); status("Attack: "..t.Name) else status("Không có target") end
    end)
end

renderMacro = function()
    clear()
    title("Macro","Bật/tắt nhanh bằng nút MCR bên ngoài")
    row("Profile","Default")
    row("Steps", tostring(#Config.Macro.Default))
    row("Loop", Config.Macro.Loop and "ON" or "OFF")
    toggle("Loop Macro", Config.Macro.Loop, function(v) Config.Macro.Loop=v end)
    toggle("Show MCR Button", Config.UI.ShowMacroButton, function(v)
        Config.UI.ShowMacroButton=v
        btnMacro.Visible=v
    end)
    toggle("Show DX Button", Config.UI.ShowDXButton, function(v)
        Config.UI.ShowDXButton=v
        btnDX.Visible=v
    end)
    actionBtn(
        State.Macro and "STOP MACRO" or "RUN MACRO",
        State.Macro and C.bad or C.good,
        function()
            Macro.Toggle()
            if page.Parent then renderMacro() end
        end
    )
    for i, step in ipairs(Config.Macro.Default) do
        row(string.format("#%d  %s", i, tostring(step.Action)),
            string.format("H %.2f | D %.2f", step.Hold or 0, step.Delay or 0))
    end
end

renderVisual = function()
    clear()
    title("Visual","ESP & FOV")
    toggle("Player ESP", State.ESP, function(v) State.ESP=v ESP.Refresh() end)
    toggle("FOV Circle", State.FOV, function(v) State.FOV=v fov.Visible=v end)
    toggle("ESP Names", Config.Visual.ShowNames, function(v) Config.Visual.ShowNames=v end)
    toggle("ESP Distance", Config.Visual.ShowDistance, function(v) Config.Visual.ShowDistance=v end)
    toggle("ESP Health Bar", Config.Visual.ShowHealth, function(v) Config.Visual.ShowHealth=v end)
end

renderMove = function()
    clear()
    title("Movement","Client-side")
    toggle("Sprint", State.Sprint, function(v) State.Sprint=v end)
    toggle("Jump Boost", State.Jump, function(v) State.Jump=v end)
    row("Dash Key", Config.Movement.DashKey.Name)
    row("Dash Speed", tostring(Config.Movement.DashSpeed))
    row("Dash Cooldown", tostring(Config.Movement.DashCooldown).."s")
end

renderSettings = function()
    clear()
    title("Settings","UI và thông tin")
    row("Owner", Config.Brand.Owner)
    row("Version", Config.Brand.Version)
    row("Discord","discord.gg/Hwwa3VYxW6")
    row("UI Toggle", Config.UI.ToggleKey.Name)
    row("Dash", Config.Movement.DashKey.Name)
    slider("UI Scale", 0.6, 1.2, Config.UI.Scale, function(v)
        Config.UI.Scale = v
        uiScale.Scale = v
    end)
    toggle("Show DX Float Button", Config.UI.ShowDXButton, function(v)
        Config.UI.ShowDXButton=v
        btnDX.Visible=v
    end)
    toggle("Show MCR Float Button", Config.UI.ShowMacroButton, function(v)
        Config.UI.ShowMacroButton=v
        btnMacro.Visible=v
    end)
    actionBtn("RESET STATE", C.panel2, function()
        State.Aim = Config.Combat.AimEnabled
        State.ESP = Config.Visual.ESPEnabled
        State.FOV = Config.Visual.ShowFOV
        State.Sprint = Config.Movement.SprintEnabled
        State.Jump = Config.Movement.JumpBoostEnabled
        State.AutoAttack = Config.Combat.AutoAttack
        State.Target = nil
        fov.Visible = State.FOV
        ESP.Refresh()
        status("Đã reset")
        renderSettings()
    end)
    actionBtn("COPY DISCORD LINK", C.accent, function()
        pcall(function()
            if setclipboard then
                setclipboard(Config.Brand.Discord)
                U.Notify("Copied","Discord link copied!",3)
            end
        end)
    end)
end

local function show(name)
    State.Tab = name
    for n, b in pairs(tabs) do
        b.BackgroundColor3 = (n==name) and C.accent or C.panel2
        b.TextColor3 = (n==name) and C.text or C.muted
    end
    if name=="Combat" then renderCombat()
    elseif name=="Macro" then renderMacro()
    elseif name=="Visual" then renderVisual()
    elseif name=="Move" then renderMove()
    elseif name=="Settings" then renderSettings() end
end

tCombat.MouseButton1Click:Connect(function() show("Combat") end)
tMacro.MouseButton1Click:Connect(function() show("Macro") end)
tVisual.MouseButton1Click:Connect(function() show("Visual") end)
tMove.MouseButton1Click:Connect(function() show("Move") end)
tSettings.MouseButton1Click:Connect(function() show("Settings") end)

-- Drag
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        startPos=main.Position
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

_G.DX_ToggleMain = function()
    main.Visible = State.Visible
end

-- Minimize: ẩn page/sidebar, chỉ giữ top bar
local minimized = false
btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main.Size = UDim2.fromOffset(620, 52)
        sidebar.Visible = false
        page.Visible = false
    else
        main.Size = Config.UI.MainSize
        sidebar.Visible = true
        page.Visible = true
    end
end)

-- Close: ẩn hẳn main, dùng DX để mở lại
btnClose.MouseButton1Click:Connect(function()
    State.Visible = false
    main.Visible = false
end)

-- Keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.UI.ToggleKey then
        State.Visible = not State.Visible
        main.Visible = State.Visible
        return
    end
    if Config.Movement.DashEnabled and input.KeyCode == Config.Movement.DashKey then
        local now = tick()
        if now - State.LastDash >= Config.Movement.DashCooldown then
            State.LastDash = now
            if Root and Humanoid and Humanoid.Health > 0 then
                local dir = Camera.CFrame.LookVector
                local flat = Vector3.new(dir.X, 0, dir.Z)
                if flat.Magnitude < 0.01 then flat = Root.CFrame.LookVector end
                flat = flat.Unit
                Root.AssemblyLinearVelocity = Vector3.new(
                    flat.X * Config.Movement.DashSpeed,
                    Root.AssemblyLinearVelocity.Y,
                    flat.Z * Config.Movement.DashSpeed
                )
            end
        end
    end
end)

-- Init
show("Combat")
ESP.Refresh()
status("Sẵn sàng • RightShift = UI • DX = toggle • MCR = macro")
_G.DX_RefreshMacroButton()

task.spawn(function()
    task.wait(1)
    U.Notify("Dungdx PvP","Loaded! RightShift = UI",5)
    task.wait(2)
    U.Notify("Discord","discord.gg/Hwwa3VYxW6",6)
end)

print("==============================================")
print("DUNGDX PVP — v2.1.0 BF")
print("Owner: Dungdx")
print("Discord: https://discord.gg/Hwwa3VYxW6")
print("==============================================")