--[[
DUN GDX PVP - BLOX FRUIT EDITION
Owner: Dungdx
Discord: https://discord.gg/Hwwa3VYxW6
Version: 2.0.0 BF

CÁCH DÙNG:
- Chạy bằng executor trong Blox Fruit
- RightShift để ẩn/hiện UI
--]]

local Services = setmetatable({}, {__index = function(self, name)
    local ok, s = pcall(game.GetService, game, name)
    if ok and s then rawset(self, name, s) return s end
    return nil
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

-- Game refs
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")
local CommE = Remotes:FindFirstChild("CommE")
local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local Enemies = Workspace:WaitForChild("Enemies")

local reRegisterAttack, reShootGunEvent
pcall(function()
    reRegisterAttack = Net:WaitForChild("RE/RegisterAttack")
    reShootGunEvent = Net:FindFirstChild("RE/ShootGunEvent")
end)

-- Hook CanAttack
pcall(function()
    local CombatUtil = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CombatUtil"))
    if CombatUtil and CombatUtil.CanAttack and hookfunction then
        hookfunction(CombatUtil.CanAttack, function() return true end)
    end
end)

-- ==================== CONFIG ====================
local Config = {
    Brand = {
        Owner = "Dungdx",
        Discord = "https://discord.gg/Hwwa3VYxW6",
        Name = "Dungdx PvP",
        Version = "2.0.0 BF",
    },
    UI = { ToggleKey = Enum.KeyCode.RightShift },
    Combat = {
        AimEnabled = true,
        FOV = 150,
        MaxDistance = 160,
        Smoothness = 0.18,
        TeamCheck = true,
        AutoAttack = true,
        AutoAttackRange = 30,
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
}

-- ==================== UTIL ====================
local Util = {}

function Util.GetRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
end

function Util.GetHumanoid(char)
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function Util.Alive(p)
    local ch = p.Character
    if not ch then return nil end
    local h = Util.GetHumanoid(ch)
    local r = Util.GetRoot(ch)
    if h and r and h.Health > 0 then return ch, h, r end
    return nil
end

function Util.Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Dungdx PvP",
            Text = text or "",
            Duration = dur or 5,
        })
    end)
end

function Util.EquipWeapon()
    if not Backpack or not Humanoid then return end
    for _, t in ipairs(Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Melee" then
            Humanoid:EquipTool(t)
            return
        end
    end
    for _, t in ipairs(Backpack:GetChildren()) do
        if t:IsA("Tool") then Humanoid:EquipTool(t) return end
    end
end

-- ==================== TARGETING ====================
local Target = {}

function Target.Enemy(p)
    if p == LP then return false end
    if Config.Combat.TeamCheck and LP.Team and p.Team and LP.Team == p.Team then return false end
    return true
end

function Target.Acquire()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestScore = nil, math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if Target.Enemy(p) then
            local _, _, root = Util.Alive(p)
            if root then
                local dist = (Camera.CFrame.Position - root.Position).Magnitude
                if dist <= Config.Combat.MaxDistance then
                    local screen, visible = Camera:WorldToViewportPoint(root.Position)
                    if visible and screen.Z > 0 then
                        local sd = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                        if sd <= Config.Combat.FOV then
                            local score = sd + dist * 0.08
                            if score < bestScore then
                                bestScore = score
                                best = p
                            end
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
local FastAttack = {}

function FastAttack.Attack(target)
    if not Character or not Humanoid or Humanoid.Health <= 0 then return end
    local tool = Character:FindFirstChildOfClass("Tool")
    if not tool then
        Util.EquipWeapon()
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

    if reShootGunEvent and tool.ToolTip == "Gun" and target then
        local _, _, root = Util.Alive(target)
        if root then
            pcall(function() reShootGunEvent:FireServer(root.Position, {}) end)
        end
    end
end

-- ==================== ESP ====================
local ESP = {}
ESP.Cache = setmetatable({}, {__mode = "k"})

function ESP.Clear(cat)
    for inst, data in pairs(ESP.Cache) do
        if not cat or data.Cat == cat then
            if data.BB and data.BB.Parent then data.BB:Destroy() end
            if data.HL and data.HL.Parent then data.HL:Destroy() end
            ESP.Cache[inst] = nil
        end
    end
end

function ESP.Add(p)
    if p == LP or ESP.Cache[p] then return end
    local ch, hum, root = Util.Alive(p)
    if not ch then return end

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
        local _, hum2, root2 = Util.Alive(p)
        if root2 and hum2 then
            local dist = (Camera.CFrame.Position - root2.Position).Magnitude
            local n = Config.Visual.ShowNames and p.Name or ""
            local d = Config.Visual.ShowDistance and string.format(" <font color='#999'>[%.0f]</font>", dist) or ""
            nameLbl.Text = n .. d
            local ratio = math.clamp(hum2.Health / math.max(hum2.MaxHealth, 1), 0, 1)
            hpFill.Size = UDim2.new(ratio, 0, 1, 0)
            if ratio > 0.6 then hpFill.BackgroundColor3 = Color3.fromRGB(70, 205, 126)
            elseif ratio > 0.3 then hpFill.BackgroundColor3 = Color3.fromRGB(240, 190, 60)
            else hpFill.BackgroundColor3 = Color3.fromRGB(225, 83, 92) end
        end
    end)

    ESP.Cache[p] = {BB = bb, HL = hl, Conn = conn, Cat = "Player"}
end

function ESP.Refresh()
    if not State.ESP then ESP.Clear() return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then ESP.Add(p) end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if State.ESP then ESP.Add(p) end
    end)
end)
Players.PlayerRemoving:Connect(function(p) ESP.Clear() end)

-- ==================== CAMERA AIM ====================
RunService.RenderStepped:Connect(function()
    if not State.Aim then State.Target = nil return end
    local t = Target.Acquire()
    if t then
        local _, _, root = Util.Alive(t)
        if root then
            local cur = Camera.CFrame
            local desired = CFrame.lookAt(cur.Position, root.Position)
            Camera.CFrame = cur:Lerp(desired, math.clamp(Config.Combat.Smoothness, 0, 1))
        end
    end
end)

-- ==================== AUTO ATTACK ====================
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if State.AutoAttack and State.Target then
                local _, _, root = Util.Alive(State.Target)
                if root and Root then
                    local dist = (Root.Position - root.Position).Magnitude
                    if dist <= Config.Combat.AutoAttackRange then
                        FastAttack.Attack(State.Target)
                    end
                end
            end
        end)
    end
end)

-- ==================== UI ====================
local C = {
    bg = Color3.fromRGB(14, 15, 20),
    panel = Color3.fromRGB(21, 23, 30),
    panel2 = Color3.fromRGB(29, 31, 40),
    text = Color3.fromRGB(240, 242, 247),
    muted = Color3.fromRGB(155, 161, 174),
    accent = Color3.fromRGB(105, 132, 255),
    good = Color3.fromRGB(70, 205, 126),
    bad = Color3.fromRGB(225, 83, 92),
    stroke = Color3.fromRGB(51, 55, 68),
}

local function new(class, props, parent)
    local x = Instance.new(class)
    for k, v in pairs(props or {}) do x[k] = v end
    x.Parent = parent
    return x
end

local function round(x, r)
    new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, x)
end

local function outline(x)
    new("UIStroke", {Color = C.stroke, Thickness = 1}, x)
end

local function pad(x, n)
    new("UIPadding", {
        PaddingTop = UDim.new(0, n),
        PaddingBottom = UDim.new(0, n),
        PaddingLeft = UDim.new(0, n),
        PaddingRight = UDim.new(0, n),
    }, x)
end

local gui = new("ScreenGui", {
    Name = "DungdxPvP",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local main = new("Frame", {
    Size = UDim2.fromOffset(760, 500),
    Position = UDim2.new(0.5, -380, 0.5, -250),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    Active = true,
}, gui)
round(main, 14)
outline(main)

local top = new("Frame", {
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, main)
round(top, 14)

new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 8),
    Size = UDim2.fromOffset(600, 28),
    Font = Enum.Font.GothamBold,
    Text = Config.Brand.Name .. "  •  v" .. Config.Brand.Version,
    TextColor3 = C.text,
    TextSize = 19,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)

new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 37),
    Size = UDim2.fromOffset(700, 18),
    Font = Enum.Font.Gotham,
    Text = "Owner: " .. Config.Brand.Owner .. "  |  " .. Config.Brand.Discord,
    TextColor3 = C.muted,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local hide = new("TextButton", {
    Size = UDim2.fromOffset(40, 34),
    Position = UDim2.new(1, -52, 0, 15),
    BackgroundColor3 = C.panel2,
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextColor3 = C.text,
    TextSize = 18,
}, top)
round(hide, 8)

local sidebar = new("Frame", {
    Position = UDim2.fromOffset(12, 76),
    Size = UDim2.fromOffset(150, 410),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, main)
round(sidebar, 10)
pad(sidebar, 9)

new("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)

local page = new("ScrollingFrame", {
    Position = UDim2.fromOffset(174, 76),
    Size = UDim2.new(1, -186, 1, -88),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 4,
}, main)

new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)

local statusLabel = new("TextLabel", {
    LayoutOrder = 99,
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    TextColor3 = C.muted,
    TextSize = 10,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Bottom,
}, sidebar)

local tabs = {}
local function tabBtn(name, order)
    local b = new("TextButton", {
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.panel2,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextColor3 = C.muted,
        TextSize = 12,
    }, sidebar)
    round(b, 8)
    tabs[name] = b
    return b
end

local tCombat = tabBtn("⚔  Combat", 1)
local tMacro = tabBtn("⌁  Macro", 2)
local tVisual = tabBtn("◉  Visual", 3)
local tMove = tabBtn("✦  Movement", 4)
local tSettings = tabBtn("⚙  Settings", 5)

local function status(s)
    State.Status = tostring(s)
    statusLabel.Text = "STATUS\n" .. State.Status
end

local function title(text, sub)
    local box = new("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
    }, page)
    round(box, 10)
    pad(box, 11)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 23),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = C.text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 23),
        Size = UDim2.new(1, 0, 0, 22),
        Font = Enum.Font.Gotham,
        Text = sub or "",
        TextColor3 = C.muted,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)
end

local function row(text, right)
    local r = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
    }, page)
    round(r, 9)
    pad(r, 9)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.55, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = C.muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, r)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.55, 0, 0, 0),
        Size = UDim2.new(0.45, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = right or "",
        TextColor3 = C.text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, r)
end

local function toggle(text, value, cb)
    local r = new("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
    }, page)
    round(r, 9)
    pad(r, 9)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -64, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = C.text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, r)

    local b = new("TextButton", {
        Size = UDim2.fromOffset(48, 25),
        Position = UDim2.new(1, -48, 0.5, -12),
        BackgroundColor3 = value and C.good or C.panel2,
        Text = value and "ON" or "OFF",
        Font = Enum.Font.GothamBold,
        TextColor3 = C.text,
        TextSize = 9,
    }, r)
    round(b, 13)

    b.MouseButton1Click:Connect(function()
        value = not value
        b.Text = value and "ON" or "OFF"
        b.BackgroundColor3 = value and C.good or C.panel2
        cb(value)
    end)
end

local function actionBtn(text, color, cb)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = color or C.accent,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextColor3 = C.text,
        TextSize = 11,
    }, page)
    round(b, 9)
    b.MouseButton1Click:Connect(cb)
    return b
end

local fov = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(Config.Combat.FOV * 2, Config.Combat.FOV * 2),
    BackgroundTransparency = 1,
    Visible = State.FOV,
    ZIndex = 3,
}, gui)
round(fov, 999)
outline(fov)

local function clear()
    for _, x in ipairs(page:GetChildren()) do
        if x:IsA("Frame") or x:IsA("TextButton") or x:IsA("TextLabel") then
            x:Destroy()
        end
    end
end

-- Render functions
local renderMacro

local function renderCombat()
    clear()
    title("Combat", "Target, FOV và camera assist")

    toggle("Aim / CamLock", State.Aim, function(v)
        State.Aim = v
        if not v then State.Target = nil end
    end)

    toggle("Auto Attack", State.AutoAttack, function(v) State.AutoAttack = v end)

    row("FOV Radius", tostring(Config.Combat.FOV) .. " px")
    row("Max Distance", tostring(Config.Combat.MaxDistance) .. " studs")
    row("Target", State.Target and State.Target.Name or "None")
    row("Team Check", Config.Combat.TeamCheck and "ON" or "OFF")

    actionBtn("ACQUIRE TARGET", C.accent, function()
        local t = Target.Acquire()
        status(t and ("Target: " .. t.Name) or "Không có target trong FOV")
    end)

    actionBtn("ATTACK NOW", C.bad, function()
        local t = State.Target or Target.Acquire()
        if t then FastAttack.Attack(t) status("Attack: " .. t.Name)
        else status("Không có target") end
    end)
end

renderMacro = function()
    clear()
    title("Macro", "Action / Hold / Delay — dùng abilities của Blox Fruit")

    row("Profile", "Default")
    row("Steps", tostring(#Config.Macro.Default))

    actionBtn(
        State.Macro and "STOP MACRO" or "RUN MACRO",
        State.Macro and C.bad or C.good,
        function()
            if State.Macro then
                State.Macro = false
                status("Macro dừng")
                renderMacro()
                return
            end
            local t = State.Target or Target.Acquire()
            if not t then status("Không có target") return end
            State.Macro = true
            status("Macro: " .. t.Name)

            task.spawn(function()
                for i, step in ipairs(Config.Macro.Default) do
                    if not State.Macro then break end
                    local tgt = State.Target
                    if not tgt or not tgt.Parent then
                        tgt = Target.Acquire()
                    end
                    if tgt then
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
                    end
                    task.wait(math.max(0, tonumber(step.Delay) or 0))
                end
                State.Macro = false
                status("Macro hoàn tất")
                if page.Parent then renderMacro() end
            end)
        end
    )

    for i, step in ipairs(Config.Macro.Default) do
        row(string.format("#%d  %s", i, tostring(step.Action)),
            string.format("H %.2f | D %.2f", step.Hold or 0, step.Delay or 0))
    end
end

local function renderVisual()
    clear()
    title("Visual", "ESP và FOV")

    toggle("Player ESP", State.ESP, function(v)
        State.ESP = v
        ESP.Refresh()
    end)

    toggle("FOV Circle", State.FOV, function(v)
        State.FOV = v
        fov.Visible = v
    end)

    toggle("ESP Names", Config.Visual.ShowNames, function(v) Config.Visual.ShowNames = v end)
    toggle("ESP Distance", Config.Visual.ShowDistance, function(v) Config.Visual.ShowDistance = v end)
    toggle("ESP Health Bar", Config.Visual.ShowHealth, function(v) Config.Visual.ShowHealth = v end)
end

local function renderMove()
    clear()
    title("Movement", "Client-side movement")

    toggle("Sprint", State.Sprint, function(v)
        State.Sprint = v
        if Humanoid then
            Humanoid.WalkSpeed = v and Config.Movement.SprintSpeed or 16
        end
    end)

    toggle("Jump Boost", State.Jump, function(v)
        State.Jump = v
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = v and Config.Movement.JumpPower or 50
        end
    end)

    row("Dash Key", Config.Movement.DashKey.Name)
    row("Dash Speed", tostring(Config.Movement.DashSpeed))
    row("Dash Cooldown", tostring(Config.Movement.DashCooldown) .. "s")
end

local function renderSettings()
    clear()
    title("Settings", "Thông tin và phím tắt")

    row("Owner", Config.Brand.Owner)
    row("Version", Config.Brand.Version)
    row("Discord", "discord.gg/Hwwa3VYxW6")
    row("UI Toggle", Config.UI.ToggleKey.Name)
    row("Dash", Config.Movement.DashKey.Name)

    actionBtn("RESET LOCAL STATE", C.panel2, function()
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
                Util.Notify("Copied", "Discord link copied!", 3)
            end
        end)
    end)
end

local function show(name)
    State.Tab = name
    for n, b in pairs(tabs) do
        b.BackgroundColor3 = (n == name) and C.accent or C.panel2
        b.TextColor3 = (n == name) and C.text or C.muted
    end
    if name == "Combat" then renderCombat()
    elseif name == "Macro" then renderMacro()
    elseif name == "Visual" then renderVisual()
    elseif name == "Movement" then renderMove()
    elseif name == "Settings" then renderSettings() end
end

tCombat.MouseButton1Click:Connect(function() show("Combat") end)
tMacro.MouseButton1Click:Connect(function() show("Macro") end)
tVisual.MouseButton1Click:Connect(function() show("Visual") end)
tMove.MouseButton1Click:Connect(function() show("Movement") end)
tSettings.MouseButton1Click:Connect(function() show("Settings") end)

-- Drag
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local function toggleUI()
    State.Visible = not State.Visible
    main.Visible = State.Visible
end

hide.MouseButton1Click:Connect(toggleUI)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.UI.ToggleKey then toggleUI() return end

    if Config.Movement.DashEnabled and input.KeyCode == Config.Movement.DashKey then
        local now = tick()
        if now - State.LastDash >= Config.Movement.DashCooldown then
            State.LastDash = now
            if Root and Humanoid and Humanoid.Health > 0 then
                local dir = Camera.CFrame.LookVector
                local flat = Vector3.new(dir.X, 0, dir.Z)
                if flat.Magnitude < 0.01 then flat = Root.CFrame.LookVector end
                flat = flat.Unit
                Root.AssemblyLinearVelocity = Vector3.new(flat.X * Config.Movement.DashSpeed, Root.AssemblyLinearVelocity.Y, flat.Z * Config.Movement.DashSpeed)
            end
        end
    end
end)

-- Init
show("Combat")
ESP.Refresh()
status("Sẵn sàng • RightShift = UI")

task.spawn(function()
    task.wait(1)
    Util.Notify("Dungdx PvP", "Loaded! RightShift = UI", 5)
    task.wait(2)
    Util.Notify("Discord", "discord.gg/Hwwa3VYxW6", 6)
end)

print("==============================================")
print("DUNGDX PVP - BLOX FRUIT EDITION")
print("Owner: Dungdx")
print("Discord: https://discord.gg/Hwwa3VYxW6")
print("Version: 2.0.0 BF")
print("==============================================")