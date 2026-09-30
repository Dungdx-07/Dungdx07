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
local HttpService = Services.HttpService

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
        Aimbot = true,
        SilentAim = false,
        SilentAimMode = "FOV",
        FOVSize = 200,
        Smoothness = 0.18,
        MaxDistance = 160,
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
}

local State = {
    Visible = true,
    Tab = "Combat",
    Aimbot = Config.Combat.Aimbot,
    SilentAim = Config.Combat.SilentAim,
    SilentAimMode = Config.Combat.SilentAimMode,
    FOV = Config.Visual.ShowFOV,
    ESP = Config.Visual.ESPEnabled,
    Sprint = Config.Movement.SprintEnabled,
    Jump = Config.Movement.JumpBoostEnabled,
    AutoAttack = Config.Combat.AutoAttack,
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
                        if sd <= Config.Combat.FOVSize then
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

local function findTargetWithin(distance)
    if not Root then return nil end
    local best, bd = nil, distance
    for _, p in ipairs(Players:GetPlayers()) do
        if T.Enemy(p) then
            local _, _, r = U.Alive(p)
            if r then
                local d = (Root.Position - r.Position).Magnitude
                if d <= bd then bd = d best = p end
            end
        end
    end
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

-- ==================== SILENT AIM HOOK ====================
if hookmetamethod and getnamecallmethod and reShootGunEvent then
    local oldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if State.SilentAim and method == "FireServer" and self == reShootGunEvent then
            local target = State.Target or T.Acquire()
            if target then
                local _, _, r = U.Alive(target)
                if r then
                    local args = {...}
                    if #args >= 1 and typeof(args[1]) == "Vector3" then
                        args[1] = r.Position
                        return oldNameCall(self, table.unpack(args))
                    end
                end
            end
        end
        return oldNameCall(self, ...)
    end)
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

-- ==================== MACRO DATA ====================
local MacroData = {
    Current = nil,
    List = {},
    Running = false,
    Thread = nil,
}
local SAVE_FILE = "dungdx_macros.json"

local function saveMacros()
    pcall(function()
        if writefile then
            writefile(SAVE_FILE, HttpService:JSONEncode(MacroData.List))
        end
    end)
end

local function loadMacros()
    pcall(function()
        if isfile and isfile(SAVE_FILE) and readfile then
            local raw = readfile(SAVE_FILE)
            if raw and raw ~= "" then
                local data = HttpService:JSONDecode(raw)
                if type(data) == "table" then MacroData.List = data end
            end
        end
    end)
end

local function newEmptyBlock()
    return { Type="Skill", Weapon="", Skill="", Hold=0, Delay=0.3 }
end
local function newEmptyMacro(name)
    return { name=name, blocks={}, loop=false, autoRun=false, runDistance=30 }
end

-- ==================== MACRO ENGINE ====================
local MacroEngine = {}

local function executeBlock(block)
    if not block.Skill or block.Skill == "" then return end
    local key = Enum.KeyCode[block.Skill]
    if not key then return end
    pcall(function() VirtualInputManager:SendKeyEvent(true, key, false, game) end)
    local hold = tonumber(block.Hold) or 0
    if hold > 0 then task.wait(math.clamp(hold, 0, 10)) else task.wait(0.02) end
    pcall(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
    local delay = tonumber(block.Delay) or 0
    if delay > 0 then task.wait(delay) end
end

function MacroEngine.Start()
    if MacroData.Running then return end
    local macro = MacroData.Current and MacroData.List[MacroData.Current]
    if not macro then U.Notify("Macro","Chưa có Macro. Bấm + CREATE.",3) return end
    if #macro.blocks == 0 then U.Notify("Macro","Macro chưa có Block.",3) return end
    MacroData.Running = true
    if _G.DX_RefreshMacroButton then pcall(_G.DX_RefreshMacroButton) end
    MacroData.Thread = task.spawn(function()
        repeat
            for _, block in ipairs(macro.blocks) do
                if not MacroData.Running then break end
                if macro.autoRun then
                    while MacroData.Running do
                        if findTargetWithin(macro.runDistance) then break end
                        task.wait(0.1)
                    end
                    if not MacroData.Running then break end
                end
                executeBlock(block)
            end
        until (not macro.loop) or (not MacroData.Running)
        MacroData.Running = false
        if _G.DX_RefreshMacroButton then pcall(_G.DX_RefreshMacroButton) end
    end)
end

function MacroEngine.Stop()
    MacroData.Running = false
    if _G.DX_RefreshMacroButton then pcall(_G.DX_RefreshMacroButton) end
end

function MacroEngine.Toggle()
    if MacroData.Running then MacroEngine.Stop() else MacroEngine.Start() end
end

-- ==================== LOOPS ====================
RunService.RenderStepped:Connect(function()
    if not (State.Aimbot or State.SilentAim or State.AutoAttack) then
        State.Target = nil
        return
    end
    local t = T.Acquire()
    if State.Aimbot and t then
        local _, _, r = U.Alive(t)
        if r then
            local cur = Camera.CFrame
            local desired = CFrame.lookAt(cur.Position, r.Position)
            Camera.CFrame = cur:Lerp(desired, math.clamp(Config.Combat.Smoothness, 0, 1))
        end
    end
end)

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
    Name="FloatLayer", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Active=false,
}, gui)

local btnDX = new("TextButton",{
    Name="BtnDX", Size=UDim2.fromOffset(46,46), Position=UDim2.new(0,14,0.5,-23),
    BackgroundColor3=C.accent, Text="DX", Font=Enum.Font.GothamBold,
    TextColor3=C.text, TextSize=14, AutoButtonColor=true,
}, floatLayer)
round(btnDX,23); outline(btnDX)

local btnMacro = new("TextButton",{
    Name="BtnMacro", Size=UDim2.fromOffset(46,46), Position=UDim2.new(0,14,0.5,30),
    BackgroundColor3=C.panel2, Text="MCR", Font=Enum.Font.GothamBold,
    TextColor3=C.muted, TextSize=12, AutoButtonColor=true,
}, floatLayer)
round(btnMacro,23); outline(btnMacro)

_G.DX_RefreshMacroButton = function()
    if MacroData.Running then
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
    if _G.DX_ToggleMain then _G.DX_ToggleMain() end
end)
btnMacro.MouseButton1Click:Connect(function() MacroEngine.Toggle() end)

-- ========== MAIN UI ==========
local main = new("Frame",{
    Name="Main", Size=Config.UI.MainSize,
    Position=UDim2.new(0.5,-310,0.5,-210),
    BackgroundColor3=C.bg, BorderSizePixel=0, Active=true,
}, gui)
round(main,14); outline(main)

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

local sidebar = new("Frame",{
    Position=UDim2.fromOffset(10,60), Size=UDim2.fromOffset(130,350),
    BackgroundColor3=C.panel, BorderSizePixel=0,
}, main)
round(sidebar,10); pad(sidebar,7)
new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder}, sidebar)

-- ⚠️ FIX: ScrollingFrame với CanvasSize cố định để không bị trống
local page = new("ScrollingFrame",{
    Position=UDim2.fromOffset(150,60), Size=UDim2.new(1,-162,1,-72),
    BackgroundTransparency=1, BorderSizePixel=0,
    CanvasSize=UDim2.new(0, 0, 0, 2000),
    ScrollBarThickness=4,
    ScrollingDirection=Enum.ScrollingDirection.Y,
}, main)
local pageLayout = new("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder}, page)

local function updateCanvas()
    pcall(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 40)
    end)
end
pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.spawn(function()
    while task.wait(0.3) do updateCanvas() end
end)

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

-- ========== PICKER POPUP ==========
local pickerOverlay = new("Frame",{
    Name="PickerOverlay", Size=UDim2.new(1,0,1,0),
    BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.55,
    Visible=false, ZIndex=100,
}, gui)
local pickerBg = new("TextButton",{
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="", ZIndex=100,
}, pickerOverlay)
pickerBg.MouseButton1Click:Connect(function() pickerOverlay.Visible = false end)

local pickerPanel = new("Frame",{
    Size=UDim2.fromOffset(280,320),
    Position=UDim2.new(0.5,-140,0.5,-160),
    BackgroundColor3=C.panel, BorderSizePixel=0, ZIndex=101,
}, pickerOverlay)
round(pickerPanel,10); outline(pickerPanel); pad(pickerPanel,10)

local pickerTitle = new("TextLabel",{
    Size=UDim2.new(1,0,0,26), BackgroundTransparency=1,
    Text="Chọn", Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=12,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101,
}, pickerPanel)

local pickerList = new("ScrollingFrame",{
    Position=UDim2.fromOffset(0,32), Size=UDim2.new(1,0,1,-32),
    BackgroundTransparency=1, BorderSizePixel=0,
    CanvasSize=UDim2.new(0,0,0,500),
    ScrollBarThickness=4, ZIndex=101,
}, pickerPanel)
local pickerLayout = new("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder}, pickerList)
pickerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    pcall(function() pickerList.CanvasSize = UDim2.new(0,0,0,pickerLayout.AbsoluteContentSize.Y+10) end)
end)

local function showPicker(title, options, current, cb)
    pickerTitle.Text = title
    for _, c in ipairs(pickerList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for i, opt in ipairs(options) do
        local b = new("TextButton",{
            LayoutOrder=i, Size=UDim2.new(1,0,0,32),
            BackgroundColor3=(opt==current) and C.accent or C.panel2,
            Text=opt, Font=Enum.Font.GothamBold,
            TextColor3=C.text, TextSize=11, ZIndex=101,
        }, pickerList)
        round(b,6)
        b.MouseButton1Click:Connect(function()
            pickerOverlay.Visible = false
            cb(opt)
        end)
    end
    pickerOverlay.Visible = true
end

-- ========== TEXT PROMPT DIALOG ==========
local dialogOverlay = new("Frame",{
    Name="DialogOverlay", Size=UDim2.new(1,0,1,0),
    BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.55,
    Visible=false, ZIndex=110,
}, gui)

local dialogPanel = new("Frame",{
    Size=UDim2.fromOffset(300,140),
    Position=UDim2.new(0.5,-150,0.5,-70),
    BackgroundColor3=C.panel, BorderSizePixel=0, ZIndex=111,
}, dialogOverlay)
round(dialogPanel,10); outline(dialogPanel)

local dialogTitle = new("TextLabel",{
    Position=UDim2.fromOffset(16,12), Size=UDim2.new(1,-32,0,24),
    BackgroundTransparency=1, Text="Nhập tên",
    Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=12,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=111,
}, dialogPanel)

local dialogInput = new("TextBox",{
    Position=UDim2.fromOffset(16,44), Size=UDim2.new(1,-32,0,32),
    BackgroundColor3=C.panel2, Text="",
    Font=Enum.Font.Gotham, TextColor3=C.text, TextSize=11,
    ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=111,
}, dialogPanel)
round(dialogInput,6); pad(dialogInput,6)

local dialogOK = new("TextButton",{
    Position=UDim2.new(1,-16-130,1,-46), Size=UDim2.fromOffset(130,30),
    BackgroundColor3=C.good, Text="OK",
    Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=11, ZIndex=111,
}, dialogPanel)
round(dialogOK,6)

local dialogCancel = new("TextButton",{
    Position=UDim2.new(1,-16-130-8-130,1,-46), Size=UDim2.fromOffset(130,30),
    BackgroundColor3=C.panel2, Text="HỦY",
    Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=11, ZIndex=111,
}, dialogPanel)
round(dialogCancel,6)

local dialogCallback = nil
local function promptText(title, default, cb)
    dialogTitle.Text = title
    dialogInput.Text = default or ""
    dialogCallback = cb
    dialogOverlay.Visible = true
    task.defer(function() pcall(function() dialogInput:CaptureFocus() end) end)
end

dialogOK.MouseButton1Click:Connect(function()
    local cb = dialogCallback; dialogCallback = nil
    dialogOverlay.Visible = false
    if cb then cb(dialogInput.Text) end
end)
dialogCancel.MouseButton1Click:Connect(function()
    dialogCallback = nil; dialogOverlay.Visible = false
end)
dialogInput.FocusLost:Connect(function(enter)
    if enter then
        local cb = dialogCallback; dialogCallback = nil
        dialogOverlay.Visible = false
        if cb then cb(dialogInput.Text) end
    end
end)

-- ========== FOV CIRCLE ==========
local fov = new("Frame",{
    AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(Config.Combat.FOVSize*2, Config.Combat.FOVSize*2),
    BackgroundTransparency=1, Visible=State.FOV, ZIndex=3}, gui)
round(fov,999); outline(fov)

-- ========== UI HELPERS ==========
local function clear()
    for _, x in ipairs(page:GetChildren()) do
        if x:IsA("Frame") or x:IsA("TextButton") or x:IsA("TextLabel") then x:Destroy() end
    end
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

local function groupHeader(text)
    local h = new("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1}, page)
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,
        Text="▎ "..text,TextColor3=C.accent,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left}, h)
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
            lbl.Text = text..": "..string.format("%.0f", v)
            cb(v)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
end

local function dropdown(text, options, current, cb)
    local r = new("Frame",{
        Size=UDim2.new(1,0,0,40),
        BackgroundColor3=C.panel, BorderSizePixel=0, ZIndex=5,
    }, page)
    round(r,8); pad(r,8)
    new("TextLabel",{
        BackgroundTransparency=1, Size=UDim2.new(.5,0,1,0), Font=Enum.Font.GothamMedium,
        Text=text, TextColor3=C.text, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    }, r)
    local btn = new("TextButton",{
        Size=UDim2.new(.5,0,1,0), Position=UDim2.new(.5,0,0,0),
        BackgroundColor3=C.panel2, Text=current.."  ▾",
        Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=10, ZIndex=6,
    }, r)
    round(btn,6)
    btn.MouseButton1Click:Connect(function()
        showPicker(text, options, current, function(v)
            current = v
            btn.Text = v.."  ▾"
            cb(v)
        end)
    end)
end

local function fieldRow(parent, order, iconLabel, subLabel, btnText, onClick)
    local r = new("Frame",{
        LayoutOrder=order, Size=UDim2.new(1,0,0,42),
        BackgroundColor3=C.panel2, BorderSizePixel=0,
    }, parent)
    round(r,6)
    new("TextLabel",{
        BackgroundTransparency=1, Position=UDim2.fromOffset(10,4),
        Size=UDim2.new(0.5,-10,0,16), Text=iconLabel,
        Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, r)
    new("TextLabel",{
        BackgroundTransparency=1, Position=UDim2.fromOffset(10,20),
        Size=UDim2.new(0.5,-10,0,14), Text=subLabel,
        Font=Enum.Font.Gotham, TextColor3=C.muted, TextSize=8,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, r)
    local b = new("TextButton",{
        Position=UDim2.new(0.55,0,0.5,-13),
        Size=UDim2.new(0.45,-10,0,26),
        BackgroundColor3=C.panel, Text=btnText,
        Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=10,
    }, r)
    round(b,6)
    b.MouseButton1Click:Connect(onClick)
    return b
end

local function numberField(parent, order, iconLabel, subLabel, value, cb)
    local r = new("Frame",{
        LayoutOrder=order, Size=UDim2.new(1,0,0,42),
        BackgroundColor3=C.panel2, BorderSizePixel=0,
    }, parent)
    round(r,6)
    new("TextLabel",{
        BackgroundTransparency=1, Position=UDim2.fromOffset(10,4),
        Size=UDim2.new(0.5,-10,0,16), Text=iconLabel,
        Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, r)
    new("TextLabel",{
        BackgroundTransparency=1, Position=UDim2.fromOffset(10,20),
        Size=UDim2.new(0.5,-10,0,14), Text=subLabel,
        Font=Enum.Font.Gotham, TextColor3=C.muted, TextSize=8,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, r)
    local tb = new("TextBox",{
        Position=UDim2.new(0.55,0,0.5,-13),
        Size=UDim2.new(0.45,-10,0,26),
        BackgroundColor3=C.panel, Text=tostring(value or 0),
        Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=10,
        ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Center,
    }, r)
    round(tb,6)
    tb.FocusLost:Connect(function()
        local n = tonumber(tb.Text)
        if n then cb(n) else tb.Text = tostring(value or 0) end
    end)
end

-- ========== MACRO UI ==========
local renderMacro

local function blockCard(index, block, macro)
    local card = new("Frame",{
        Size=UDim2.new(1,0,0,270),
        BackgroundColor3=C.panel, BorderSizePixel=0,
    }, page)
    round(card,10); outline(card); pad(card,10)
    new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder}, card)

    new("TextLabel",{
        LayoutOrder=1, Size=UDim2.new(1,0,0,20), BackgroundTransparency=1,
        Text="BLOCK "..index, Font=Enum.Font.GothamBold,
        TextColor3=C.accent, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, card)

    fieldRow(card, 2, "⚔  Weapon", "Select weapon type",
        block.Weapon ~= "" and block.Weapon or "Chọn...",
        function()
            showPicker("Chọn Weapon", {"Võ","Kiếm","Trái","Súng"}, block.Weapon, function(v)
                block.Weapon = v
                saveMacros(); renderMacro()
            end)
        end)

    fieldRow(card, 3, "✨  Skill / Action", "Select skill to use",
        block.Skill ~= "" and block.Skill or "Chọn...",
        function()
            showPicker("Chọn Skill / Action", {"Z","X","C","V","F"}, block.Skill, function(v)
                block.Skill = v
                saveMacros(); renderMacro()
            end)
        end)

    numberField(card, 4, "🔥  Hold Duration", "How long to hold (0 = Instant)",
        block.Hold, function(v) block.Hold = v; saveMacros() end)

    numberField(card, 5, "⏱  Delay After Skill", "Wait time before next block",
        block.Delay, function(v) block.Delay = v; saveMacros() end)

    local btnRow = new("Frame",{
        LayoutOrder=6, Size=UDim2.new(1,0,0,30),
        BackgroundTransparency=1,
    }, card)

    local function miniBtn(text, x, w, color, cb)
        local b = new("TextButton",{
            Position=UDim2.new(x,0,0,0),
            Size=UDim2.new(w,0,1,0),
            BackgroundColor3=color, Text=text,
            Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=10,
        }, btnRow)
        round(b,6)
        b.MouseButton1Click:Connect(cb)
    end

    miniBtn("↑", 0,    0.08, C.panel2, function()
        if index > 1 then
            macro.blocks[index], macro.blocks[index-1] = macro.blocks[index-1], macro.blocks[index]
            saveMacros(); renderMacro()
        end
    end)
    miniBtn("↓", 0.09, 0.08, C.panel2, function()
        if index < #macro.blocks then
            macro.blocks[index], macro.blocks[index+1] = macro.blocks[index+1], macro.blocks[index]
            saveMacros(); renderMacro()
        end
    end)
    miniBtn("DUPLICATE", 0.18, 0.40, C.accent, function()
        table.insert(macro.blocks, index+1, {
            Type=block.Type, Weapon=block.Weapon, Skill=block.Skill,
            Hold=block.Hold, Delay=block.Delay,
        })
        saveMacros(); renderMacro()
    end)
    miniBtn("DELETE", 0.59, 0.41, C.bad, function()
        table.remove(macro.blocks, index)
        saveMacros(); renderMacro()
    end)
end

renderMacro = function()
    clear()
    title("Macro","Trình soạn thảo tự do — người dùng tự tạo Macro và Block")

    if MacroData.Current and not MacroData.List[MacroData.Current] then
        MacroData.Current = nil
    end

    local names = {}
    for n in pairs(MacroData.List) do table.insert(names, n) end
    table.sort(names)

    -- Current Macro
    do
        local r = new("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.panel,BorderSizePixel=0}, page)
        round(r,8); pad(r,10)
        new("TextLabel",{
            BackgroundTransparency=1, Size=UDim2.new(0.45,0,1,0),
            Text="Current Macro", Font=Enum.Font.GothamMedium,
            TextColor3=C.muted, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
        }, r)
        local pickBtn = new("TextButton",{
            Size=UDim2.new(0.5,0,0,28), Position=UDim2.new(0.5,0,0.5,-14),
            BackgroundColor3=C.panel2,
            Text=(MacroData.Current or "(chưa chọn)").."  ▾",
            Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=10,
        }, r)
        round(pickBtn,6)
        pickBtn.MouseButton1Click:Connect(function()
            if #names == 0 then U.Notify("Macro","Chưa có macro nào. Bấm + CREATE.",3) return end
            showPicker("Chọn Macro", names, MacroData.Current, function(v)
                MacroData.Current = v
                renderMacro()
            end)
        end)
    end

    -- CREATE / DELETE
    do
        local r = new("Frame",{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1}, page)
        local createB = new("TextButton",{
            Size=UDim2.new(0.48,0,1,0), BackgroundColor3=C.good,
            Text="+ CREATE", Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=11,
        }, r)
        round(createB,8)
        createB.MouseButton1Click:Connect(function()
            promptText("Tên Macro", "Combo "..(#names+1), function(name)
                name = (name or ""):gsub("^%s+",""):gsub("%s+$","")
                if name ~= "" and not MacroData.List[name] then
                    MacroData.List[name] = newEmptyMacro(name)
                    MacroData.Current = name
                    saveMacros(); renderMacro()
                else
                    U.Notify("Macro","Tên trống hoặc đã tồn tại.",3)
                end
            end)
        end)

        local delB = new("TextButton",{
            Size=UDim2.new(0.48,0,1,0), Position=UDim2.new(0.52,0,0,0),
            BackgroundColor3=C.bad, Text="DELETE",
            Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=11,
        }, r)
        round(delB,8)
        delB.MouseButton1Click:Connect(function()
            if MacroData.Current and MacroData.List[MacroData.Current] then
                MacroData.List[MacroData.Current] = nil
                MacroData.Current = nil
                saveMacros(); renderMacro()
            else
                U.Notify("Macro","Chưa chọn Macro.",3)
            end
        end)
    end

    local macro = MacroData.Current and MacroData.List[MacroData.Current]
    if not macro then
        local info = new("Frame",{
            Size=UDim2.new(1,0,0,80), BackgroundColor3=C.panel, BorderSizePixel=0,
        }, page)
        round(info,8)
        new("TextLabel",{
            BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
            Text="Chưa có Macro.\nBấm + CREATE để tạo Macro mới.",
            Font=Enum.Font.Gotham, TextColor3=C.muted, TextSize=11,
            TextWrapped=true,
        }, info)
        return
    end

    toggle("Auto Run Near Target", macro.autoRun, function(v) macro.autoRun = v; saveMacros() end)
    slider("Run Distance", 5, 100, macro.runDistance, function(v)
        macro.runDistance = math.floor(v); saveMacros()
    end)
    toggle("Loop", macro.loop, function(v) macro.loop = v; saveMacros() end)

    -- RUN / STOP
    do
        local r = new("Frame",{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1}, page)
        local runB = new("TextButton",{
            Size=UDim2.new(0.48,0,1,0), BackgroundColor3=C.good,
            Text="▶ RUN", Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=11,
        }, r)
        round(runB,8)
        runB.MouseButton1Click:Connect(function() MacroEngine.Start() end)

        local stopB = new("TextButton",{
            Size=UDim2.new(0.48,0,1,0), Position=UDim2.new(0.52,0,0,0),
            BackgroundColor3=C.bad, Text="■ STOP",
            Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=11,
        }, r)
        round(stopB,8)
        stopB.MouseButton1Click:Connect(function() MacroEngine.Stop() end)
    end

    do
        local h = new("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1}, page)
        new("TextLabel",{
            BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
            Text="▎ BLOCKS ("..#macro.blocks..")",
            Font=Enum.Font.GothamBold, TextColor3=C.accent, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, h)
    end

    for i, block in ipairs(macro.blocks) do
        blockCard(i, block, macro)
    end

    do
        local b = new("TextButton",{
            Size=UDim2.new(1,0,0,40), BackgroundColor3=C.accent,
            Text="+ ADD BLOCK", Font=Enum.Font.GothamBold, TextColor3=C.text, TextSize=11,
        }, page)
        round(b,8)
        b.MouseButton1Click:Connect(function()
            table.insert(macro.blocks, newEmptyBlock())
            saveMacros(); renderMacro()
        end)
    end
end

-- ========== COMBAT / VISUAL / MOVE / SETTINGS ==========
local renderCombat, renderVisual, renderMove, renderSettings

renderCombat = function()
    clear()
    title("Combat","Aimbot / Silent Aim / Auto Attack")

    groupHeader("Aimbot")
    toggle("Aimbot (Camera Lock)", State.Aimbot, function(v)
        State.Aimbot = v
        if not v and not State.SilentAim then State.Target = nil end
    end)
    toggle("Silent Aim", State.SilentAim, function(v)
        State.SilentAim = v
        if not v and not State.Aimbot then State.Target = nil end
    end)
    dropdown("Silent Aim Mode", {"FOV"}, State.SilentAimMode, function(v)
        State.SilentAimMode = v
    end)
    toggle("FOV Circle", State.FOV, function(v) State.FOV = v; fov.Visible = v end)
    slider("FOV Size", 50, 800, Config.Combat.FOVSize, function(v)
        Config.Combat.FOVSize = v
        fov.Size = UDim2.fromOffset(v*2, v*2)
    end)

    groupHeader("Auto Attack")
    toggle("Auto Attack", State.AutoAttack, function(v) State.AutoAttack=v end)
    slider("Attack Interval", 0.05, 0.5, Config.Combat.AttackInterval, function(v)
        Config.Combat.AttackInterval = v
    end)
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

renderVisual = function()
    clear()
    title("Visual","ESP")
    toggle("Player ESP", State.ESP, function(v) State.ESP=v ESP.Refresh() end)
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
        Config.UI.Scale = v; uiScale.Scale = v
    end)
    toggle("Show DX Float Button", Config.UI.ShowDXButton, function(v)
        Config.UI.ShowDXButton=v; btnDX.Visible=v
    end)
    toggle("Show MCR Float Button", Config.UI.ShowMacroButton, function(v)
        Config.UI.ShowMacroButton=v; btnMacro.Visible=v
    end)
    actionBtn("RESET STATE", C.panel2, function()
        State.Aimbot = Config.Combat.Aimbot
        State.SilentAim = Config.Combat.SilentAim
        State.SilentAimMode = Config.Combat.SilentAimMode
        State.FOV = Config.Visual.ShowFOV
        State.ESP = Config.Visual.ESPEnabled
        State.Sprint = Config.Movement.SprintEnabled
        State.Jump = Config.Movement.JumpBoostEnabled
        State.AutoAttack = Config.Combat.AutoAttack
        State.Target = nil
        fov.Visible = State.FOV
        fov.Size = UDim2.fromOffset(Config.Combat.FOVSize*2, Config.Combat.FOVSize*2)
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
    local ok, err = pcall(function()
        if name=="Combat" then renderCombat()
        elseif name=="Macro" then renderMacro()
        elseif name=="Visual" then renderVisual()
        elseif name=="Move" then renderMove()
        elseif name=="Settings" then renderSettings() end
    end)
    if not ok then
        clear()
        local e = new("Frame",{
            Size=UDim2.new(1,0,0,90),
            BackgroundColor3=C.bad, BorderSizePixel=0,
        }, page)
        round(e,8); pad(e,8)
        new("TextLabel",{
            BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
            Text="⚠ Lỗi render tab "..name..":\n"..tostring(err),
            Font=Enum.Font.Gotham, TextColor3=C.text, TextSize=10,
            TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
        }, e)
    end
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
        main.Size = UDim2.fromOffset(620, 52)
        sidebar.Visible = false; page.Visible = false
    else
        main.Size = Config.UI.MainSize
        sidebar.Visible = true; page.Visible = true
    end
end)

btnClose.MouseButton1Click:Connect(function()
    State.Visible = false; main.Visible = false
end)

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

-- ==================== INIT ====================
loadMacros()
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