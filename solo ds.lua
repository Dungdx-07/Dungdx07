--[[
DUNGDX PVP — BLOX FRUITS EDITION v2.1.0 BF
Owner: Dungdx
Discord: https://discord.gg/Hwwa3VYxW6
RightShift = ẩn/hiện UI | DX = toggle UI | MCR = toggle Macro
--]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local StarterGui          = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace           = game:GetService("Workspace")
local HttpService         = game:GetService("HttpService")

local LP        = Players.LocalPlayer
local Camera    = Workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui")

local Character, Humanoid, Root
local function bindChar(c)
    Character = c
    Humanoid = c:WaitForChild("Humanoid", 10)
    Root     = c:WaitForChild("HumanoidRootPart", 10)
end
if LP.Character then bindChar(LP.Character) end
LP.CharacterAdded:Connect(bindChar)
local Backpack = LP:WaitForChild("Backpack")

-- Remotes (Blox Fruits)
local reRegisterAttack, reShootGunEvent
pcall(function()
    local Modules = ReplicatedStorage:WaitForChild("Modules", 15)
    if Modules then
        local Net = Modules:WaitForChild("Net", 10)
        if Net then
            reRegisterAttack  = Net:WaitForChild("RE/RegisterAttack", 5)
            reShootGunEvent   = Net:FindFirstChild("RE/ShootGunEvent")
        end
    end
    local CU = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CombatUtil"))
    if CU and CU.CanAttack and hookfunction then
        hookfunction(CU.CanAttack, function() return true end)
    end
end)

-- ============================================================
-- BRAND & DEFAULTS
-- ============================================================
local Brand = {
    Owner   = "Dungdx",
    Discord = "https://discord.gg/Hwwa3VYxW6",
    Name    = "Dungdx PvP",
    Version = "2.1.0 BF",
}

local function defaultMacros()
    local list = {}
    for i = 1, 6 do
        local blocks = {}
        if i == 4 then
            blocks = {
                { Weapon = "Kiếm", Skill = "Z", Hold = 0.00, Delay = 0.10 },
                { Weapon = "Kiếm", Skill = "X", Hold = 0.00, Delay = 0.15 },
                { Weapon = "Kiếm", Skill = "C", Hold = 0.00, Delay = 0.20 },
            }
        end
        table.insert(list, {
            Name     = "Macro " .. i,
            Enabled  = false,
            Expanded = (i == 4),
            Blocks   = blocks,
        })
    end
    return list
end

local function defaultConfig()
    return {
        UI = {
            Scale    = 1.0,
            Position = nil,
            Visible  = true,
        },
        Combat = {
            Aimbot      = false,
            SilentAim   = "FOV",
            FOVCircle   = false,
            FOVSize     = 150,
            MaxDistance = 160,
            Smoothness  = 0.2,
            TeamCheck   = true,
        },
        Visual = {
            ESP           = true,
            Hitbox        = false,
            Distance      = true,
            Health        = true,
            Level         = false,
            Team          = false,
            TeamColor     = "Red",
            Transparency  = 0.7,
        },
        Move = {
            SpeedEnabled    = false,
            SpeedMultiplier = 1.0,
            JumpEnabled     = false,
            JumpMultiplier  = 1.0,
            NoClip          = false,
            Fly             = false,
            WalkOnWater     = false,
        },
        Setting = {
            FixLag = false,
        },
        Macro = {
            List = defaultMacros(),
        },
    }
end

-- ============================================================
-- STORAGE
-- ============================================================
local Storage = {}
local SAVE_FILE = "dungdx_pvp_config.json"

function Storage.Load()
    local cfg = defaultConfig()
    if writefile and readfile and isfile then
        pcall(function()
            if isfile(SAVE_FILE) then
                local raw = readfile(SAVE_FILE)
                if raw and raw ~= "" then
                    local data = HttpService:JSONDecode(raw)
                    for section, vals in pairs(data) do
                        if section == "Macro" and type(vals) == "table" and vals.List then
                            cfg.Macro.List = vals.List
                        elseif type(vals) == "table" and cfg[section] then
                            for k, v in pairs(vals) do cfg[section][k] = v end
                        end
                    end
                end
            end
        end)
    end
    return cfg
end

function Storage.Save(cfg)
    if writefile then
        pcall(function()
            writefile(SAVE_FILE, HttpService:JSONEncode(cfg))
        end)
    end
end

function Storage.Delete()
    if delfile and isfile and isfile(SAVE_FILE) then
        pcall(delfile, SAVE_FILE)
    end
end

local Config = Storage.Load()

-- ============================================================
-- UTILS
-- ============================================================
local U = {}

function U.Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Dungdx",
            Text = text or "",
            Duration = dur or 4,
        })
    end)
end

function U.GetHum(ch) return ch and ch:FindFirstChildOfClass("Humanoid") end
function U.GetRoot(ch) return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart) end

function U.Alive(plr)
    local ch = plr.Character
    if not ch then return end
    local h = U.GetHum(ch)
    local r = U.GetRoot(ch)
    if h and r and h.Health > 0 then return ch, h, r end
end

local function isSwordName(n)
    n = tostring(n):lower()
    return n:find("sword") or n:find("blade") or n:find("saber")
        or n:find("katana") or n:find("cutlass") or n:find("rapier")
        or n:find("dragon") or n:find("dark") or n:find("true")
end

function U.EquipWeapon(kind)
    if not Backpack or not Humanoid then return end
    local tools = {}
    for _, t in ipairs(Backpack:GetChildren()) do
        if t:IsA("Tool") then table.insert(tools, t) end
    end
    local target
    if kind == "Võ" then
        for _, t in ipairs(tools) do
            if t.ToolTip == "Melee" and not isSwordName(t.Name) then target = t; break end
        end
        if not target then
            for _, t in ipairs(tools) do if t.ToolTip == "Melee" then target = t; break end end
        end
    elseif kind == "Kiếm" then
        for _, t in ipairs(tools) do
            if t.ToolTip == "Melee" and isSwordName(t.Name) then target = t; break end
        end
        if not target then
            for _, t in ipairs(tools) do if t.ToolTip == "Melee" then target = t; break end end
        end
    elseif kind == "Súng" then
        for _, t in ipairs(tools) do if t.ToolTip == "Gun" then target = t; break end end
    elseif kind == "Trái" then
        for _, t in ipairs(tools) do if t.ToolTip == "Blox Fruit" then target = t; break end end
    end
    if target then pcall(function() Humanoid:EquipTool(target) end) end
end

-- ============================================================
-- PALETTE
-- ============================================================
local P = {
    bg      = Color3.fromRGB(9, 14, 26),
    header  = Color3.fromRGB(13, 20, 36),
    sidebar = Color3.fromRGB(11, 17, 30),
    panel   = Color3.fromRGB(17, 25, 42),
    panel2  = Color3.fromRGB(24, 34, 55),
    panel3  = Color3.fromRGB(32, 45, 70),
    text    = Color3.fromRGB(235, 240, 250),
    muted   = Color3.fromRGB(125, 140, 168),
    accent  = Color3.fromRGB(40, 128, 240),
    accentD = Color3.fromRGB(28, 90, 180),
    good    = Color3.fromRGB(60, 200, 120),
    bad     = Color3.fromRGB(230, 70, 90),
    warn    = Color3.fromRGB(255, 150, 60),
    stroke  = Color3.fromRGB(38, 52, 80),
    icon    = Color3.fromRGB(90, 160, 255),
}

-- ============================================================
-- UI HELPERS
-- ============================================================
local function newInst(class, props, parent)
    local x = Instance.new(class)
    for k, v in pairs(props or {}) do x[k] = v end
    x.Parent = parent
    return x
end

local function corner(x, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = x
    return c
end

local function stroke(x, col, t, mode)
    local s = Instance.new("UIStroke")
    s.Color = col or P.stroke
    s.Thickness = t or 1
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.Parent = x
    return s
end

local function padding(x, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or t or 0)
    p.PaddingLeft = UDim.new(0, l or t or 0)
    p.PaddingRight = UDim.new(0, r or l or t or 0)
    p.Parent = x
    return p
end

-- Global dropdown closer registry
local DropdownClosers = {}
local function closeAllDropdowns(except)
    for _, fn in ipairs(DropdownClosers) do
        if fn ~= except then pcall(fn) end
    end
end

-- Cleanup old GUI
do
    local old = PlayerGui:FindFirstChild("DungdxPvP")
    if old then old:Destroy() end
    local old2 = PlayerGui:FindFirstChild("DungdxPvP_Float")
    if old2 then old2:Destroy() end
end

-- ============================================================
-- STATE (runtime)
-- ============================================================
local State = {
    Visible     = Config.UI.Visible ~= false,
    Tab         = "Combat",
    Minimized   = false,
    Target      = nil,
    LastAttack  = 0,
    // macro runtime
    macroRunning = false,
    macroIndex   = nil,
    macroThread  = nil,
    // connections
    Conn = {},
}

-- ============================================================
-- COMBAT LOGIC
-- ============================================================
local Combat = {}

function Combat.getTarget()
    if not Camera then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bs = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            if not (Config.Combat.TeamCheck and LP.Team and p.Team and LP.Team == p.Team) then
                local _, _, r = U.Alive(p)
                if r then
                    local d = (Camera.CFrame.Position - r.Position).Magnitude
                    if d <= Config.Combat.MaxDistance then
                        local sp, vis = Camera:WorldToViewportPoint(r.Position)
                        if vis and sp.Z > 0 then
                            local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if sd <= Config.Combat.FOVSize then
                                local score
                                if Config.Combat.SilentAim == "Nearest" then
                                    score = d
                                else
                                    score = sd + d * 0.08
                                end
                                if score < bs then bs = score; best = p end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

function Combat.Attack(target)
    if not Character or not Humanoid or Humanoid.Health <= 0 then return end
    local now = tick()
    if now - State.LastAttack < 0.15 then return end
    State.LastAttack = now

    local tool = Character:FindFirstChildOfClass("Tool")
    if not tool then
        U.EquipWeapon("Kiếm")
        tool = Character:FindFirstChildOfClass("Tool")
        if not tool then return end
    end
    if reRegisterAttack then
        pcall(function() reRegisterAttack:FireServer(0) end)
    end
    if tool:FindFirstChild("LeftClickRemote") then
        pcall(function()
            tool.LeftClickRemote:FireServer(Vector3.new(0.01, -500, 0.01), 1, true)
        end)
    end
    if tool.ToolTip == "Gun" and reShootGunEvent and target then
        local _, _, r = U.Alive(target)
        if r then pcall(function() reShootGunEvent:FireServer(r.Position, {}) end) end
    end
end

-- Single render-step loop for aimbot
State.Conn.aim = RunService.RenderStepped:Connect(function()
    if not Config.Combat.Aimbot then
        State.Target = nil
        return
    end
    local t = Combat.getTarget()
    State.Target = t
    if t then
        local _, _, r = U.Alive(t)
        if r then
            local cur = Camera.CFrame
            local desired = CFrame.lookAt(cur.Position, r.Position)
            local smooth = 1  -- camlock = snap
            Camera.CFrame = cur:Lerp(desired, smooth)
        end
    end
end)

-- ============================================================
-- ESP LOGIC
-- ============================================================
local ESP = { cache = setmetatable({}, {__mode = "k"}) }

function ESP.clear()
    for plr, data in pairs(ESP.cache) do
        if data.hl and data.hl.Parent then data.hl:Destroy() end
        if data.bb and data.bb.Parent then data.bb:Destroy() end
        if data.conn then data.conn:Disconnect() end
        ESP.cache[plr] = nil
    end
end

local teamColorMap = {
    Blue   = Color3.fromRGB(60, 140, 255),
    Red    = Color3.fromRGB(230, 60, 60),
    Green  = Color3.fromRGB(60, 210, 90),
    Yellow = Color3.fromRGB(240, 200, 60),
}

local function activeFillColor()
    return teamColorMap[Config.Visual.TeamColor] or teamColorMap.Red
end

function ESP.add(plr)
    if plr == LP or ESP.cache[plr] then return end
    local ch, _, root = U.Alive(plr)
    if not ch or not root then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = ch
    hl.FillColor = activeFillColor()
    hl.FillTransparency = Config.Visual.Transparency
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0.2
    hl.Parent = ch

    local bb = Instance.new("BillboardGui")
    bb.Adornee = root
    bb.Size = UDim2.fromOffset(220, 60)
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
    corner(hpBg, 3)

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(70, 205, 126)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    corner(hpFill, 3)

    local conn = RunService.RenderStepped:Connect(function()
        if not bb.Parent then return end
        local _, h2, r2 = U.Alive(plr)
        if h2 and r2 then
            local dist = (Camera.CFrame.Position - r2.Position).Magnitude
            local parts = {}
            if Config.Visual.ESP then table.insert(parts, plr.Name) end
            if Config.Visual.Distance then
                table.insert(parts, string.format("<font color='#8ea0c0'>[%d]</font>", math.floor(dist)))
            end
            nameLbl.Text = table.concat(parts, " ")
            local ratio = math.clamp(h2.Health / math.max(h2.MaxHealth, 1), 0, 1)
            hpFill.Size = UDim2.new(ratio, 0, 1, 0)
            if ratio > 0.6 then hpFill.BackgroundColor3 = Color3.fromRGB(70, 205, 126)
            elseif ratio > 0.3 then hpFill.BackgroundColor3 = Color3.fromRGB(240, 190, 60)
            else hpFill.BackgroundColor3 = Color3.fromRGB(225, 83, 92) end
            hpBg.Visible = Config.Visual.Health
            hl.FillColor = activeFillColor()
            hl.FillTransparency = Config.Visual.Transparency
            bb.Enabled = Config.Visual.ESP or Config.Visual.Distance or Config.Visual.Health
        end
    end)

    ESP.cache[plr] = { hl = hl, bb = bb, conn = conn }
end

function ESP.refresh()
    ESP.clear()
    if not Config.Visual.ESP and not Config.Visual.Distance and not Config.Visual.Health then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then ESP.add(p) end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Config.Visual.ESP or Config.Visual.Distance or Config.Visual.Health then ESP.add(p) end
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    local d = ESP.cache[p]
    if d then
        if d.hl then d.hl:Destroy() end
        if d.bb then d.bb:Destroy() end
        if d.conn then d.conn:Disconnect() end
        ESP.cache[p] = nil
    end
end)

-- ============================================================
-- MACRO LOGIC
-- ============================================================
local Macro = {}

function Macro.stop()
    State.macroRunning = false
    State.macroIndex = nil
    State.macroThread = nil
    if _G.RefreshMacroButton then pcall(_G.RefreshMacroButton) end
end

function Macro.start(index)
    Macro.stop()
    local m = Config.Macro.List[index]
    if not m then return end
    if not m.Blocks or #m.Blocks == 0 then
        U.Notify("Macro", "Macro này chưa có Block nào!", 3)
        return
    end
    State.macroRunning = true
    State.macroIndex = index
    State.macroThread = task.spawn(function()
        while State.macroRunning and State.macroIndex == index do
            local cur = Config.Macro.List[index]
            if not cur or not cur.Enabled then break end
            for _, blk in ipairs(cur.Blocks) do
                if not State.macroRunning or State.macroIndex ~= index then break end
                U.EquipWeapon(blk.Weapon)
                task.wait(0.08)
                local key = Enum.KeyCode[blk.Skill]
                if key then
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(math.max(0.02, blk.Hold or 0))
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
                task.wait(math.max(0, blk.Delay or 0))
            end
            task.wait(0.05)
        end
        if State.macroIndex == index then Macro.stop() end
    end)
    if _G.RefreshMacroButton then pcall(_G.RefreshMacroButton) end
end

function Macro.toggle(index, isOn)
    -- Mutually exclusive: only one macro runs at a time
    if isOn then
        for i, m in ipairs(Config.Macro.List) do
            if i ~= index then m.Enabled = false end
        end
        Config.Macro.List[index].Enabled = true
        Macro.start(index)
    else
        Config.Macro.List[index].Enabled = false
        if State.macroIndex == index then Macro.stop() end
    end
end

-- ============================================================
-- MOVE LOGIC
-- ============================================================
local Move = {}

-- Speed / Jump periodic
State.Conn.move = task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if Humanoid and Humanoid.Health > 0 then
                Humanoid.WalkSpeed = Config.Move.SpeedEnabled and (16 * Config.Move.SpeedMultiplier) or 16
                if Config.Move.JumpEnabled then
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = 50 * Config.Move.JumpMultiplier
                else
                    Humanoid.UseJumpPower = false
                end
            end
        end)
    end
end)

-- NoClip periodic
State.Conn.noclip = task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if Config.Move.NoClip and Character then
                for _, v in ipairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- Fly
local FlyBV, FlyBG, FlyConn
local function setFly(on)
    if on then
        if not Root then return end
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
        if FlyConn then FlyConn:Disconnect() end
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.Velocity = Vector3.new(0, 0, 0)
        FlyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        FlyBV.Parent = Root
        FlyBG = Instance.new("BodyGyro")
        FlyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        FlyBG.P = 1000
        FlyBG.Parent = Root
        FlyConn = RunService.RenderStepped:Connect(function()
            if not Config.Move.Fly or not Root or not Humanoid or Humanoid.Health <= 0 then
                if FlyBV then FlyBV:Destroy() FlyBV = nil end
                if FlyBG then FlyBG:Destroy() FlyBG = nil end
                if FlyConn then FlyConn:Disconnect() FlyConn = nil end
                return
            end
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            FlyBV.Velocity = dir.Magnitude > 0 and (dir.Unit * 55) or Vector3.new(0, 0, 0)
            FlyBG.CFrame = Camera.CFrame
        end)
    else
        if FlyBV then FlyBV:Destroy() FlyBV = nil end
        if FlyBG then FlyBG:Destroy() FlyBG = nil end
        if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    end
end
Move.setFly = setFly

-- Walk on water
State.Conn.water = task.spawn(function()
    while task.wait(0.15) do
        pcall(function()
            if Config.Move.WalkOnWater and Character then
                for _, v in ipairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5, 1, 1)
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- SETTING LOGIC
-- ============================================================
local Setting = {}

function Setting.fixLag(on)
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
        U.Notify("FixLag", "Đã tắt FixLag (cần rejoin để phục hồi)", 3)
    end
end

-- ============================================================
-- UI BUILD
-- ============================================================
local gui = newInst("ScreenGui", {
    Name = "DungdxPvP",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, PlayerGui)

-- FOV circle (independent overlay)
local fovCircle = newInst("Frame", {
    Name = "FOVCircle",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(Config.Combat.FOVSize * 2, Config.Combat.FOVSize * 2),
    BackgroundTransparency = 1,
    Visible = Config.Combat.FOVCircle,
    ZIndex = 2,
}, gui)
corner(fovCircle, 9999)
stroke(fovCircle, P.icon, 1.5)

-- Main frame
local main = newInst("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(660, 500),
    Position = UDim2.new(0.5, -330, 0.5, -250),
    BackgroundColor3 = P.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
corner(main, 14)
stroke(main, P.stroke, 1.5)

local uiScale = newInst("UIScale", { Scale = Config.UI.Scale }, main)

-- Restore position if saved
if Config.UI.Position and Config.UI.Position.X and Config.UI.Position.Y then
    main.Position = UDim2.new(0, Config.UI.Position.X, 0, Config.UI.Position.Y)
end

-- Header
local header = newInst("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = P.header,
    BorderSizePixel = 0,
}, main)
corner(header, 14)

newInst("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 8),
    Size = UDim2.fromOffset(460, 22),
    Font = Enum.Font.GothamBold,
    Text = Brand.Name .. "  •  v" .. Brand.Version,
    TextColor3 = P.text,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

newInst("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 32),
    Size = UDim2.fromOffset(500, 16),
    Font = Enum.Font.Gotham,
    Text = "Owner: " .. Brand.Owner .. "   |   Discord: discord.gg/Hwwa3VYxW6",
    TextColor3 = P.muted,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local btnMin = newInst("TextButton", {
    Size = UDim2.fromOffset(34, 30),
    Position = UDim2.new(1, -86, 0, 16),
    BackgroundColor3 = P.panel2,
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextColor3 = P.text,
    TextSize = 16,
    AutoButtonColor = true,
}, header)
corner(btnMin, 6)

local btnClose = newInst("TextButton", {
    Size = UDim2.fromOffset(34, 30),
    Position = UDim2.new(1, -46, 0, 16),
    BackgroundColor3 = P.bad,
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    AutoButtonColor = true,
}, header)
corner(btnClose, 6)

-- Sidebar
local sidebar = newInst("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(14, 76),
    Size = UDim2.fromOffset(148, 408),
    BackgroundColor3 = P.sidebar,
    BorderSizePixel = 0,
}, main)
corner(sidebar, 10)
padding(sidebar, 8, 8, 8, 8)
newInst("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    FillDirection = Enum.FillDirection.Vertical,
}, sidebar)

-- Page
local page = newInst("ScrollingFrame", {
    Name = "Page",
    Position = UDim2.fromOffset(176, 76),
    Size = UDim2.new(1, -190, 1, -92),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = P.accent,
    ScrollingDirection = Enum.ScrollingDirection.Y,
}, main)
newInst("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, page)

-- ============================================================
-- WIDGET LIBRARY
-- ============================================================
local Widgets = {}

function Widgets.card(h, parent)
    local c = newInst("Frame", {
        Size = UDim2.new(1, 0, 0, h),
        BackgroundColor3 = P.panel,
        BorderSizePixel = 0,
    }, parent or page)
    corner(c, 10)
    return c
end

function Widgets.row(icon, title, desc, buildControl, rowH, parent)
    rowH = rowH or 62
    local c = Widgets.card(rowH, parent)
    padding(c, 12)

    -- Icon
    local ib = newInst("Frame", {
        Size = UDim2.fromOffset(38, 38),
        Position = UDim2.fromOffset(0, (rowH - 24 - 38) / 2),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, c)
    corner(ib, 9)
    stroke(ib, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = icon,
        TextColor3 = P.icon,
        TextSize = 16,
    }, ib)

    -- Title + Desc
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 8),
        Size = UDim2.new(1, -220, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = P.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, c)
    if desc then
        newInst("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(52, 26),
            Size = UDim2.new(1, -220, 0, 16),
            Font = Enum.Font.Gotham,
            Text = desc,
            TextColor3 = P.muted,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, c)
    end

    -- Control container (right aligned)
    local ca = newInst("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(200, rowH - 24),
    }, c)
    if buildControl then buildControl(ca) end
    return c
end

function Widgets.toggle(parent, initial, cb)
    local value = initial
    local root = newInst("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(48, 26),
        BackgroundColor3 = value and P.accent or P.panel2,
        BorderSizePixel = 0,
    }, parent)
    corner(root, 13)
    stroke(root, value and P.accent or P.stroke, 1)

    local knob = newInst("Frame", {
        Size = UDim2.fromOffset(20, 20),
        Position = value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, root)
    corner(knob, 10)

    local hit = newInst("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
    }, root)

    local function apply(v)
        value = v
        root.BackgroundColor3 = value and P.accent or P.panel2
        knob.Position = value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        local s = root:FindFirstChildOfClass("UIStroke")
        if s then s.Color = value and P.accent or P.stroke end
    end

    hit.MouseButton1Click:Connect(function()
        apply(not value)
        cb(value)
    end)

    return { Set = apply, Get = function() return value end }
end

function Widgets.dropdown(parent, options, current, cb, width)
    width = width or 150
    local btn = newInst("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(width, 30),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, parent)
    corner(btn, 6)
    stroke(btn, P.stroke, 1)

    local label = newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "- " .. tostring(current) .. " -",
        TextColor3 = P.text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, btn)

    newInst("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Font = Enum.Font.GothamBold,
        Text = "▾",
        TextColor3 = P.muted,
        TextSize = 12,
    }, btn)

    local list = newInst("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 1, 4),
        Size = UDim2.fromOffset(width, #options * 26 + 8),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 60,
    }, btn)
    corner(list, 6)
    stroke(list, P.accent, 1)
    padding(list, 4)
    newInst("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)

    local value = current
    for i, opt in ipairs(options) do
        local isSel = tostring(opt) == tostring(value)
        local ob = newInst("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = isSel and P.accent or P.panel,
            BorderSizePixel = 0,
            Text = "",
            LayoutOrder = i,
            AutoButtonColor = true,
        }, list)
        corner(ob, 4)
        newInst("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(1, -16, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = tostring(opt),
            TextColor3 = P.text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, ob)
        ob.MouseButton1Click:Connect(function()
            list.Visible = false
            label.Text = "- " .. tostring(opt) .. " -"
            value = opt
            cb(opt)
        end)
    end

    local function closeFn() list.Visible = false end
    table.insert(DropdownClosers, closeFn)

    btn.MouseButton1Click:Connect(function()
        local wasOpen = list.Visible
        closeAllDropdowns(closeFn)
        list.Visible = not wasOpen
    end)

    return btn
end

function Widgets.slider(parent, min, max, value, unit, cb, opts)
    opts = opts or {}
    local withButtons = opts.withButtons ~= false
    unit = unit or ""
    local root = newInst("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(320, 30),
        BackgroundTransparency = 1,
    }, parent)

    local leftPad, rightPad = 0, 70
    if withButtons then
        -- minus
        local minus = newInst("TextButton", {
            Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = P.panel2,
            Text = "−",
            Font = Enum.Font.GothamBold,
            TextColor3 = P.text,
            TextSize = 16,
            AutoButtonColor = true,
        }, root)
        corner(minus, 6)
        stroke(minus, P.stroke, 1)
        -- plus
        local plus = newInst("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -rightPad, 0, 0),
            Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = P.panel2,
            Text = "+",
            Font = Enum.Font.GothamBold,
            TextColor3 = P.text,
            TextSize = 16,
            AutoButtonColor = true,
        }, root)
        corner(plus, 6)
        stroke(plus, P.stroke, 1)
        leftPad = 36
        rightPad = rightPad + 36
    end

    -- Value box
    local valBox = newInst("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(66, 28),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, root)
    corner(valBox, 6)
    stroke(valBox, P.stroke, 1)
    local valLbl = newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = math.floor(value) .. unit,
        TextColor3 = P.text,
        TextSize = 11,
    }, valBox)

    -- Track
    local track = newInst("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromOffset(leftPad, 14),
        Size = UDim2.new(1, -(leftPad + rightPad + 76), 0, 6),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, root)
    corner(track, 3)

    local function ratio(v) return math.clamp((v - min) / math.max(max - min, 1), 0, 1) end

    local fill = newInst("Frame", {
        Size = UDim2.new(ratio(value), 0, 1, 0),
        BackgroundColor3 = P.accent,
        BorderSizePixel = 0,
    }, track)
    corner(fill, 3)

    local knob = newInst("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(ratio(value), 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 3,
    }, track)
    corner(knob, 7)
    stroke(knob, P.accent, 1)

    local function apply(v)
        v = math.clamp(v, min, max)
        fill.Size = UDim2.new(ratio(v), 0, 1, 0)
        knob.Position = UDim2.new(ratio(v), 0, 0.5, 0)
        valLbl.Text = math.floor(v + 0.5) .. unit
        cb(v)
    end

    local dragging = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
           or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                        or i.UserInputType == Enum.UserInputType.Touch) then
            local rx = math.clamp(
                (i.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            apply(min + (max - min) * rx)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
           or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    if withButtons then
        local kids = root:GetChildren()
        for _, k in ipairs(kids) do
            if k:IsA("TextButton") and k.Text == "−" then
                k.MouseButton1Click:Connect(function() apply((tonumber(valLbl.Text:gsub("%D", "")) or value) - (max - min) / 20) end)
            elseif k:IsA("TextButton") and k.Text == "+" then
                k.MouseButton1Click:Connect(function() apply((tonumber(valLbl.Text:gsub("%D", "")) or value) + (max - min) / 20) end)
            end
        end
    end

    return { Set = apply }
end

function Widgets.stepper(parent, value, step, cb, width)
    width = width or 84
    local root = newInst("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(width, 28),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, parent)
    corner(root, 6)
    stroke(root, P.stroke, 1)

    local box = newInst("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -26, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = string.format("%.2f", value),
        TextColor3 = P.text,
        TextSize = 11,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, root)

    local up = newInst("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -2, 0, 2),
        Size = UDim2.fromOffset(18, 12),
        BackgroundTransparency = 1,
        Text = "▲",
        Font = Enum.Font.GothamBold,
        TextColor3 = P.muted,
        TextSize = 8,
        AutoButtonColor = true,
    }, root)
    local dn = newInst("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -2, 0, 14),
        Size = UDim2.fromOffset(18, 12),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.GothamBold,
        TextColor3 = P.muted,
        TextSize = 8,
        AutoButtonColor = true,
    }, root)

    local function apply(v)
        v = math.max(0, v)
        box.Text = string.format("%.2f", v)
        cb(v)
    end
    box.FocusLost:Connect(function() apply(tonumber(box.Text) or 0) end)
    up.MouseButton1Click:Connect(function() apply((tonumber(box.Text) or 0) + step) end)
    dn.MouseButton1Click:Connect(function() apply((tonumber(box.Text) or 0) - step) end)
    return { Set = apply }
end

function Widgets.button(parent, text, color, cb, width)
    local b = newInst("TextButton", {
        Size = UDim2.fromOffset(width or 120, 32),
        BackgroundColor3 = color or P.accent,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextColor3 = P.text,
        TextSize = 11,
        AutoButtonColor = true,
    }, parent)
    corner(b, 7)
    if cb then b.MouseButton1Click:Connect(cb) end
    return b
end

-- ============================================================
-- PAGE BUILDERS
-- ============================================================
local builders = {}
local function clearPage()
    for _, c in ipairs(page:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
            c:Destroy()
        end
    end
    DropdownClosers = {}
end

-- ---------- COMBAT ----------
function builders.Combat()
    clearPage()

    Widgets.row("◎", "Aimbot (Camera Lock)", nil, function(ca)
        Widgets.toggle(ca, Config.Combat.Aimbot, function(v)
            Config.Combat.Aimbot = v
            if not v then State.Target = nil end
        end)
    end)

    Widgets.row("⛨", "Silent Aim", nil, function(ca)
        Widgets.dropdown(ca, {"FOV", "Nearest"}, Config.Combat.SilentAim, function(v)
            Config.Combat.SilentAim = v
        end, 140)
    end)

    Widgets.row("⭕", "FOV Circle", nil, function(ca)
        Widgets.toggle(ca, Config.Combat.FOVCircle, function(v)
            Config.Combat.FOVCircle = v
            fovCircle.Visible = v
        end)
    end)

    Widgets.row("⛶", "FOV Size", nil, function(ca)
        Widgets.slider(ca, 50, 300, Config.Combat.FOVSize, " px", function(v)
            Config.Combat.FOVSize = v
            fovCircle.Size = UDim2.fromOffset(v * 2, v * 2)
        end)
    end, 72)
end

-- ---------- MACRO ----------
function builders.Macro()
    clearPage()

    -- Header card
    local head = Widgets.card(56)
    padding(head, 12, 12, 12, 12)

    local hic = newInst("Frame", {
        Size = UDim2.fromOffset(38, 38),
        Position = UDim2.fromOffset(0, 3),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, head)
    corner(hic, 9)
    stroke(hic, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "⌨",
        TextColor3 = P.icon,
        TextSize = 16,
    }, hic)

    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(50, 0),
        Size = UDim2.new(1, -180, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "Macro",
        TextColor3 = P.text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, head)

    local addBtn = newInst("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(140, 34),
        BackgroundColor3 = P.accent,
        Text = "+  Tạo Macro",
        Font = Enum.Font.GothamBold,
        TextColor3 = P.text,
        TextSize = 11,
        AutoButtonColor = true,
    }, head)
    corner(addBtn, 8)
    addBtn.MouseButton1Click:Connect(function()
        table.insert(Config.Macro.List, {
            Name = "Macro " .. (#Config.Macro.List + 1),
            Enabled = false,
            Expanded = false,
            Blocks = {},
        })
        builders.Macro()
    end)

    -- Macro list
    for i, m in ipairs(Config.Macro.List) do
        -- Each macro = a container frame
        local macroCard = Widgets.card(56)
        padding(macroCard, 10, 10, 12, 12)

        -- arrow
        local arrow = newInst("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(22, 36),
            Font = Enum.Font.GothamBold,
            Text = m.Expanded and "⌃" or "⌄",
            TextColor3 = P.muted,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
        }, macroCard)

        -- icon
        local mic = newInst("Frame", {
            Size = UDim2.fromOffset(34, 34),
            Position = UDim2.fromOffset(28, 1),
            BackgroundColor3 = P.panel2,
            BorderSizePixel = 0,
        }, macroCard)
        corner(mic, 8)
        stroke(mic, P.stroke, 1)
        newInst("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "</>",
            TextColor3 = P.icon,
            TextSize = 10,
        }, mic)

        newInst("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(74, 0),
            Size = UDim2.new(1, -240, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = m.Name,
            TextColor3 = P.text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, macroCard)

        -- toggle
        local tglHolder = newInst("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(50, 26),
        }, macroCard)
        Widgets.toggle(tglHolder, m.Enabled, function(v)
            Macro.toggle(i, v)
        end)

        -- click area for expand (excluding toggle)
        local hit = newInst("TextButton", {
            Size = UDim2.new(1, -70, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 2,
        }, macroCard)
        hit.MouseButton1Click:Connect(function()
            m.Expanded = not m.Expanded
            arrow.Text = m.Expanded and "⌃" or "⌄"
            builders.Macro()
        end)

        -- Expanded body
        if m.Expanded then
            local body = newInst("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = P.panel,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, page)
            corner(body, 10)
            padding(body, 14)
            newInst("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, body)

            -- Add Block button
            local addBlk = newInst("TextButton", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = P.panel2,
                Text = "+  Add Block",
                Font = Enum.Font.GothamBold,
                TextColor3 = P.text,
                TextSize = 11,
                LayoutOrder = 1,
                AutoButtonColor = true,
            }, body)
            corner(addBlk, 6)
            stroke(addBlk, P.stroke, 1)
            addBlk.MouseButton1Click:Connect(function()
                table.insert(m.Blocks, {
                    Weapon = "Kiếm", Skill = "Z", Hold = 0.00, Delay = 0.10,
                })
                builders.Macro()
            end)

            -- Blocks
            for bi, blk in ipairs(m.Blocks) do
                local blkRow = newInst("Frame", {
                    Size = UDim2.new(1, 0, 0, 60),
                    BackgroundColor3 = P.panel2,
                    BorderSizePixel = 0,
                    LayoutOrder = 10 + bi,
                }, body)
                corner(blkRow, 8)
                padding(blkRow, 10)

                -- Block label
                newInst("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.fromOffset(70, 18),
                    Font = Enum.Font.GothamBold,
                    Text = "Block " .. bi,
                    TextColor3 = P.muted,
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, blkRow)

                -- Delete button
                local del = newInst("TextButton", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.fromOffset(24, 20),
                    BackgroundColor3 = P.bad,
                    Text = "✕",
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10,
                    AutoButtonColor = true,
                }, blkRow)
                corner(del, 5)
                del.MouseButton1Click:Connect(function()
                    table.remove(m.Blocks, bi)
                    builders.Macro()
                end)

                -- Move up / down
                if bi > 1 then
                    local upBtn = newInst("TextButton", {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -30, 0, 0),
                        Size = UDim2.fromOffset(24, 20),
                        BackgroundColor3 = P.panel3,
                        Text = "▲",
                        Font = Enum.Font.GothamBold,
                        TextColor3 = P.text,
                        TextSize = 9,
                        AutoButtonColor = true,
                    }, blkRow)
                    corner(upBtn, 5)
                    upBtn.MouseButton1Click:Connect(function()
                        m.Blocks[bi], m.Blocks[bi - 1] = m.Blocks[bi - 1], m.Blocks[bi]
                        builders.Macro()
                    end)
                end
                if bi < #m.Blocks then
                    local dnBtn = newInst("TextButton", {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -58, 0, 0),
                        Size = UDim2.fromOffset(24, 20),
                        BackgroundColor3 = P.panel3,
                        Text = "▼",
                        Font = Enum.Font.GothamBold,
                        TextColor3 = P.text,
                        TextSize = 9,
                        AutoButtonColor = true,
                    }, blkRow)
                    corner(dnBtn, 5)
                    dnBtn.MouseButton1Click:Connect(function()
                        m.Blocks[bi], m.Blocks[bi + 1] = m.Blocks[bi + 1], m.Blocks[bi]
                        builders.Macro()
                    end)
                end

                -- 4-column row: Weapon | Skill | Hold | Delay
                local cols = newInst("Frame", {
                    Position = UDim2.fromOffset(0, 26),
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                }, blkRow)

                -- Weapon
                local wWrap = newInst("Frame", {
                    Size = UDim2.new(0.26, -4, 1, 0),
                    BackgroundTransparency = 1,
                }, cols)
                Widgets.dropdown(wWrap, {"Võ", "Kiếm", "Súng", "Trái"}, blk.Weapon, function(v)
                    blk.Weapon = v
                end, 140)

                -- Skill
                local sWrap = newInst("Frame", {
                    Position = UDim2.new(0.26, 4, 0, 0),
                    Size = UDim2.new(0.26, -4, 1, 0),
                    BackgroundTransparency = 1,
                }, cols)
                Widgets.dropdown(sWrap, {"Z", "X", "C", "V", "F"}, blk.Skill, function(v)
                    blk.Skill = v
                end, 140)

                -- Hold
                local hWrap = newInst("Frame", {
                    Position = UDim2.new(0.52, 4, 0, 0),
                    Size = UDim2.new(0.22, -4, 1, 0),
                    BackgroundTransparency = 1,
                }, cols)
                Widgets.stepper(hWrap, blk.Hold, 0.05, function(v) blk.Hold = v end, 140)

                -- Delay
                local dWrap = newInst("Frame", {
                    Position = UDim2.new(0.74, 4, 0, 0),
                    Size = UDim2.new(0.26, 0, 1, 0),
                    BackgroundTransparency = 1,
                }, cols)
                Widgets.stepper(dWrap, blk.Delay, 0.05, function(v) blk.Delay = v end, 140)
            end
        end
    end
end

-- ---------- VISUAL ----------
function builders.Visual()
    clearPage()

    local function espRefresh()
        ESP.refresh()
    end

    Widgets.row("👤", "Player ESP", "Hiển thị người chơi (Box, Name, Line,...)", function(ca)
        Widgets.toggle(ca, Config.Visual.ESP, function(v) Config.Visual.ESP = v; espRefresh() end)
    end)

    Widgets.row("👁", "Show Hitbox", "Hiển thị hitbox của người chơi", function(ca)
        Widgets.toggle(ca, Config.Visual.Hitbox, function(v) Config.Visual.Hitbox = v end)
    end)

    Widgets.row("↔", "ESP Distance", "Hiển thị khoảng cách đến người chơi", function(ca)
        Widgets.toggle(ca, Config.Visual.Distance, function(v) Config.Visual.Distance = v end)
    end)

    Widgets.row("✚", "ESP Health", "Hiển thị thanh máu của người chơi", function(ca)
        Widgets.toggle(ca, Config.Visual.Health, function(v) Config.Visual.Health = v end)
    end)

    Widgets.row("★", "ESP Level", "Hiển thị cấp độ của người chơi", function(ca)
        Widgets.toggle(ca, Config.Visual.Level, function(v) Config.Visual.Level = v end)
    end)

    Widgets.row("👥", "ESP Team", "Hiển thị team của người chơi", function(ca)
        Widgets.toggle(ca, Config.Visual.Team, function(v) Config.Visual.Team = v end)
    end)

    -- Bottom 2 columns
    local bottom = newInst("Frame", {
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundTransparency = 1,
    }, page)

    -- Left: Team Color
    local left = newInst("Frame", {
        Size = UDim2.new(0.49, -4, 1, 0),
        BackgroundColor3 = P.panel,
        BorderSizePixel = 0,
    }, bottom)
    corner(left, 10)
    padding(left, 12)

    local lic = newInst("Frame", {
        Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, left)
    corner(lic, 8)
    stroke(lic, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "🎨",
        TextColor3 = P.icon,
        TextSize = 14,
    }, lic)

    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(42, 0),
        Size = UDim2.new(1, -42, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "Team Color",
        TextColor3 = P.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, left)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(42, 16),
        Size = UDim2.new(1, -42, 0, 14),
        Font = Enum.Font.Gotham,
        Text = "Chọn màu cho từng team",
        TextColor3 = P.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, left)

    local teams = { "Blue", "Red", "Green", "Yellow" }
    for i, tname in ipairs(teams) do
        local tRow = newInst("TextButton", {
            Position = UDim2.fromOffset(0, 44 + (i - 1) * 34),
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = P.panel2,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = true,
        }, left)
        corner(tRow, 6)
        local dot = newInst("Frame", {
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.fromOffset(8, 8),
            BackgroundColor3 = teamColorMap[tname],
            BorderSizePixel = 0,
        }, tRow)
        corner(dot, 4)
        newInst("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(28, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = tname,
            TextColor3 = P.text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, tRow)
        newInst("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            Font = Enum.Font.GothamBold,
            Text = "▾",
            TextColor3 = P.muted,
            TextSize = 11,
        }, tRow)
        tRow.MouseButton1Click:Connect(function()
            Config.Visual.TeamColor = tname
            for _, d in pairs(ESP.cache) do
                if d.hl then d.hl.FillColor = teamColorMap[tname] end
            end
        end)
    end

    -- Right: Transparency
    local right = newInst("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0.49, -4, 1, 0),
        BackgroundColor3 = P.panel,
        BorderSizePixel = 0,
    }, bottom)
    corner(right, 10)
    padding(right, 12)

    local ric = newInst("Frame", {
        Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, right)
    corner(ric, 8)
    stroke(ric, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "◐",
        TextColor3 = P.icon,
        TextSize = 14,
    }, ric)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(42, 0),
        Size = UDim2.new(1, -42, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "Transparency",
        TextColor3 = P.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, right)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(42, 16),
        Size = UDim2.new(1, -42, 0, 14),
        Font = Enum.Font.Gotham,
        Text = "Độ trong suốt ESP",
        TextColor3 = P.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, right)

    local trTrack = newInst("Frame", {
        Position = UDim2.fromOffset(0, 82),
        Size = UDim2.new(1, -84, 0, 6),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, right)
    corner(trTrack, 3)
    local trValBox = newInst("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0, 85),
        Size = UDim2.fromOffset(66, 28),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, right)
    corner(trValBox, 6)
    stroke(trValBox, P.stroke, 1)
    local trValLbl = newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = math.floor((1 - Config.Visual.Transparency) * 100) .. "%",
        TextColor3 = P.text,
        TextSize = 11,
    }, trValBox)
    local trFill = newInst("Frame", {
        Size = UDim2.new(1 - Config.Visual.Transparency, 0, 1, 0),
        BackgroundColor3 = P.accent,
        BorderSizePixel = 0,
    }, trTrack)
    corner(trFill, 3)
    local trKnob = newInst("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1 - Config.Visual.Transparency, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 3,
    }, trTrack)
    corner(trKnob, 7)
    stroke(trKnob, P.accent, 1)

    local trDragging = false
    trTrack.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
           or i.UserInputType == Enum.UserInputType.Touch then
            trDragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if trDragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                          or i.UserInputType == Enum.UserInputType.Touch) then
            local rx = math.clamp((i.Position.X - trTrack.AbsolutePosition.X) / math.max(trTrack.AbsoluteSize.X, 1), 0, 1)
            trFill.Size = UDim2.new(rx, 0, 1, 0)
            trKnob.Position = UDim2.new(rx, 0, 0.5, 0)
            trValLbl.Text = math.floor(rx * 100) .. "%"
            Config.Visual.Transparency = 1 - rx
            for _, d in pairs(ESP.cache) do
                if d.hl then d.hl.FillTransparency = Config.Visual.Transparency end
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
           or i.UserInputType == Enum.UserInputType.Touch then
            trDragging = false
        end
    end)
end

-- ---------- MOVE ----------
function builders.Move()
    clearPage()

    -- Speed Boost
    local sp = Widgets.card(100)
    padding(sp, 12)
    local spIc = newInst("Frame", {
        Size = UDim2.fromOffset(38, 38),
        Position = UDim2.fromOffset(0, 6),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, sp)
    corner(spIc, 9)
    stroke(spIc, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "⚡",
        TextColor3 = P.icon,
        TextSize = 16,
    }, spIc)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 6),
        Size = UDim2.new(1, -220, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = "Speed Boost",
        TextColor3 = P.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sp)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 24),
        Size = UDim2.new(1, -220, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "Tăng tốc độ di chuyển",
        TextColor3 = P.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sp)

    local spTgl = newInst("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 6),
        Size = UDim2.fromOffset(50, 26),
    }, sp)
    Widgets.toggle(spTgl, Config.Move.SpeedEnabled, function(v)
        Config.Move.SpeedEnabled = v
    end)

    local spSlide = newInst("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 54),
        Size = UDim2.new(1, -60, 0, 30),
    }, sp)
    Widgets.slider(spSlide, 0.5, 3.0, Config.Move.SpeedMultiplier, "%", function(v)
        Config.Move.SpeedMultiplier = v
        spSlide:FindFirstChildOfClass("Frame")
    end, { withButtons = false })
    -- override label to show % (from v*100)
    -- The slider shows math.floor(v+0.5)% which for 1.0 gives 1% — not good.
    -- Use a custom display: we need a proper "×100" slider. Let's just rebuild with 50..300.
    -- (Handled below by replacing value semantics)
    spSlide:Destroy()
    local spSlide2 = newInst("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 54),
        Size = UDim2.new(1, -60, 0, 30),
    }, sp)
    Widgets.slider(spSlide2, 50, 300, Config.Move.SpeedMultiplier * 100, "%", function(v)
        Config.Move.SpeedMultiplier = v / 100
    end, { withButtons = false })

    -- Jump Boost
    local jp = Widgets.card(100)
    padding(jp, 12)
    local jpIc = newInst("Frame", {
        Size = UDim2.fromOffset(38, 38),
        Position = UDim2.fromOffset(0, 6),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, jp)
    corner(jpIc, 9)
    stroke(jpIc, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "🦘",
        TextColor3 = P.icon,
        TextSize = 15,
    }, jpIc)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 6),
        Size = UDim2.new(1, -220, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = "Jump Boost",
        TextColor3 = P.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, jp)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 24),
        Size = UDim2.new(1, -220, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "Tăng lực nhảy",
        TextColor3 = P.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, jp)

    local jpTgl = newInst("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 6),
        Size = UDim2.fromOffset(50, 26),
    }, jp)
    Widgets.toggle(jpTgl, Config.Move.JumpEnabled, function(v)
        Config.Move.JumpEnabled = v
    end)

    local jpSlide = newInst("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 54),
        Size = UDim2.new(1, -60, 0, 30),
    }, jp)
    Widgets.slider(jpSlide, 50, 300, Config.Move.JumpMultiplier * 100, "%", function(v)
        Config.Move.JumpMultiplier = v / 100
    end, { withButtons = false })

    -- NoClip
    Widgets.row("↔", "No clip", "Xuyên vật thể", function(ca)
        Widgets.toggle(ca, Config.Move.NoClip, function(v) Config.Move.NoClip = v end)
    end)

    -- Fly
    Widgets.row("✈", "Fly button", "Bật chế độ bay (WASD + Space/Ctrl)", function(ca)
        Widgets.toggle(ca, Config.Move.Fly, function(v)
            Config.Move.Fly = v
            Move.setFly(v)
        end)
    end)
end

-- ---------- SETTING ----------
function builders.Setting()
    clearPage()

    -- FixLag
    Widgets.row("⚡", "Bật FixLag", "Giảm lag, tăng FPS, tối ưu hiệu suất game", function(ca)
        Widgets.toggle(ca, Config.Setting.FixLag, function(v)
            Config.Setting.FixLag = v
            Setting.fixLag(v)
        end)
    end)

    -- Copy Discord
    local dc = Widgets.card(60)
    padding(dc, 12)
    local dcIc = newInst("Frame", {
        Size = UDim2.fromOffset(38, 38),
        Position = UDim2.fromOffset(0, 1),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, dc)
    corner(dcIc, 9)
    stroke(dcIc, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "🎮",
        TextColor3 = P.icon,
        TextSize = 15,
    }, dcIc)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 4),
        Size = UDim2.new(1, -220, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = "Copy Link Discord",
        TextColor3 = P.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, dc)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 22),
        Size = UDim2.new(1, -220, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "Sao chép link Discord của chủ sở hữu",
        TextColor3 = P.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, dc)
    local copyBtn = newInst("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(110, 34),
        BackgroundColor3 = P.accent,
        Text = "🔗  Copy",
        Font = Enum.Font.GothamBold,
        TextColor3 = P.text,
        TextSize = 11,
        AutoButtonColor = true,
    }, dc)
    corner(copyBtn, 8)
    copyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(Brand.Discord)
                U.Notify("Copy", "Đã copy link Discord", 2)
            end
        end)
    end)

    -- Divider
    newInst("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, page)

    -- Reset
    local rs = Widgets.card(60)
    padding(rs, 12)
    local rsIc = newInst("Frame", {
        Size = UDim2.fromOffset(38, 38),
        Position = UDim2.fromOffset(0, 1),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, rs)
    corner(rsIc, 9)
    stroke(rsIc, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "↺",
        TextColor3 = P.icon,
        TextSize = 16,
    }, rsIc)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 4),
        Size = UDim2.new(1, -220, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = "Đặt về Mặc định",
        TextColor3 = P.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, rs)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 22),
        Size = UDim2.new(1, -220, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "Khôi phục toàn bộ cài đặt về mặc định",
        TextColor3 = P.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, rs)
    local resetBtn = newInst("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(110, 34),
        BackgroundColor3 = P.panel2,
        Text = "↺  Reset",
        Font = Enum.Font.GothamBold,
        TextColor3 = P.text,
        TextSize = 11,
        AutoButtonColor = true,
    }, rs)
    corner(resetBtn, 8)
    stroke(resetBtn, P.stroke, 1)
    resetBtn.MouseButton1Click:Connect(function()
        -- Reset all to defaults
        Storage.Delete()
        Config = defaultConfig()
        Storage.Save(Config)
        -- Reset runtime visuals
        fovCircle.Visible = Config.Combat.FOVCircle
        fovCircle.Size = UDim2.fromOffset(Config.Combat.FOVSize * 2, Config.Combat.FOVSize * 2)
        uiScale.Scale = Config.UI.Scale
        Move.setFly(false)
        Macro.stop()
        ESP.refresh()
        builders.Setting()
        U.Notify("Reset", "Đã khôi phục mặc định", 2)
    end)

    -- Save
    local sv = Widgets.card(60)
    padding(sv, 12)
    local svIc = newInst("Frame", {
        Size = UDim2.fromOffset(38, 38),
        Position = UDim2.fromOffset(0, 1),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, sv)
    corner(svIc, 9)
    stroke(svIc, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "💾",
        TextColor3 = P.icon,
        TextSize = 14,
    }, svIc)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 4),
        Size = UDim2.new(1, -220, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = "Lưu cài Liệu",
        TextColor3 = P.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sv)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 22),
        Size = UDim2.new(1, -220, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "Lưu lại cài đặt hiện tại",
        TextColor3 = P.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sv)
    local saveBtn = newInst("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(110, 34),
        BackgroundColor3 = P.accent,
        Text = "💾  Save",
        Font = Enum.Font.GothamBold,
        TextColor3 = P.text,
        TextSize = 11,
        AutoButtonColor = true,
    }, sv)
    corner(saveBtn, 8)
    saveBtn.MouseButton1Click:Connect(function()
        -- Save current position
        Config.UI.Position = {
            X = main.Position.X.Offset,
            Y = main.Position.Y.Offset,
        }
        Storage.Save(Config)
        U.Notify("Save", "Đã lưu cài đặt hiện tại", 2)
    end)

    -- UI Scale
    local sc = Widgets.card(70)
    padding(sc, 12)
    local scIc = newInst("Frame", {
        Size = UDim2.fromOffset(38, 38),
        Position = UDim2.fromOffset(0, 4),
        BackgroundColor3 = P.panel2,
        BorderSizePixel = 0,
    }, sc)
    corner(scIc, 9)
    stroke(scIc, P.stroke, 1)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "⌗",
        TextColor3 = P.icon,
        TextSize = 15,
    }, scIc)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 4),
        Size = UDim2.new(1, -260, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = "UI Scale",
        TextColor3 = P.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sc)
    newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 22),
        Size = UDim2.new(1, -260, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "Thay đổi kích thước toàn bộ UI",
        TextColor3 = P.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sc)
    local scWrap = newInst("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(200, 18),
        Size = UDim2.new(1, -220, 0, 30),
    }, sc)
    Widgets.slider(scWrap, 70, 120, Config.UI.Scale * 100, "%", function(v)
        Config.UI.Scale = v / 100
        uiScale.Scale = Config.UI.Scale
    end)

    -- Walk on water
    Widgets.row("🌊", "Đi trên nước", "Cho phép di chuyển trên mặt nước", function(ca)
        Widgets.toggle(ca, Config.Move.WalkOnWater, function(v) Config.Move.WalkOnWater = v end)
    end)
end

-- ============================================================
-- SIDEBAR TAB BUTTONS
-- ============================================================
local tabRefs = {}
local function makeTabBtn(icon, name, order)
    local b = newInst("TextButton", {
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = P.sidebar,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, sidebar)
    corner(b, 8)

    -- left accent bar (visible when selected)
    local bar = newInst("Frame", {
        Size = UDim2.new(0, 3, 0, 22),
        Position = UDim2.new(0, 0, 0.5, -11),
        BackgroundColor3 = P.accent,
        BorderSizePixel = 0,
        Visible = false,
    }, b)
    corner(bar, 2)

    local ic = newInst("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.fromOffset(12, 6),
        Font = Enum.Font.GothamBold,
        Text = icon,
        TextColor3 = P.muted,
        TextSize = 14,
    }, b)

    local tx = newInst("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(44, 0),
        Size = UDim2.new(1, -48, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = name,
        TextColor3 = P.muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, b)

    tabRefs[name] = { btn = b, icon = ic, text = tx, bar = bar }

    b.MouseButton1Click:Connect(function()
        builders.showTab(name)
    end)
end

makeTabBtn("⚔", "Combat", 1)
makeTabBtn("⌨", "Macro", 2)
makeTabBtn("◉", "Visual", 3)
makeTabBtn("✦", "Move", 4)
makeTabBtn("⚙", "Setting", 5)

-- ============================================================
-- TAB SWITCHING
-- ============================================================
function builders.showTab(name)
    State.Tab = name
    for n, t in pairs(tabRefs) do
        local sel = (n == name)
        t.btn.BackgroundColor3 = sel and P.accent or P.sidebar
        t.icon.TextColor3 = sel and P.text or P.muted
        t.text.TextColor3 = sel and P.text or P.muted
        t.bar.Visible = sel
    end
    closeAllDropdowns()
    local b = builders[name]
    if b then b() end
end

-- ============================================================
-- DRAGGING (header)
-- ============================================================
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        -- Clamp to screen
        local vp = Camera.ViewportSize
        local w = main.AbsoluteSize.X
        local h = main.AbsoluteSize.Y
        newX = math.clamp(newX, -w + 80, vp.X - 80)
        newY = math.clamp(newY, 0, vp.Y - 40)
        main.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
-- MINIMIZE / CLOSE
-- ============================================================
btnMin.MouseButton1Click:Connect(function()
    State.Minimized = not State.Minimized
    sidebar.Visible = not State.Minimized
    page.Visible = not State.Minimized
    if State.Minimized then
        main.Size = UDim2.fromOffset(660, 62)
    else
        main.Size = UDim2.fromOffset(660, 500)
    end
end)
btnClose.MouseButton1Click:Connect(function()
    State.Visible = false
    main.Visible = false
    Config.UI.Visible = false
end)

-- ============================================================
-- FLOAT BUTTONS
-- ============================================================
local floatGui = newInst("ScreenGui", {
    Name = "DungdxPvP_Float",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, PlayerGui)

local btnDX = newInst("TextButton", {
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.new(0, 14, 0.5, -24),
    BackgroundColor3 = P.accent,
    Text = "DX",
    Font = Enum.Font.GothamBold,
    TextColor3 = P.text,
    TextSize = 14,
    AutoButtonColor = true,
}, floatGui)
corner(btnDX, 24)
stroke(btnDX, P.accent, 1.5)

local btnMacro = newInst("TextButton", {
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.new(0, 14, 0.5, 30),
    BackgroundColor3 = P.panel2,
    Text = "MCR",
    Font = Enum.Font.GothamBold,
    TextColor3 = P.muted,
    TextSize = 12,
    AutoButtonColor = true,
}, floatGui)
corner(btnMacro, 24)
stroke(btnMacro, P.stroke, 1)

_G.RefreshMacroButton = function()
    if State.macroRunning then
        btnMacro.BackgroundColor3 = P.warn
        btnMacro.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnMacro.Text = "ON"
    else
        btnMacro.BackgroundColor3 = P.panel2
        btnMacro.TextColor3 = P.muted
        btnMacro.Text = "MCR"
    end
end

btnDX.MouseButton1Click:Connect(function()
    State.Visible = not State.Visible
    main.Visible = State.Visible
    Config.UI.Visible = State.Visible
end)

btnMacro.MouseButton1Click:Connect(function()
    -- Toggle the first enabled macro, or the 4th default
    if State.macroRunning then
        Macro.stop()
        for _, m in ipairs(Config.Macro.List) do m.Enabled = false end
        builders.Macro()
    else
        -- find first macro with blocks
        for i, m in ipairs(Config.Macro.List) do
            if m.Blocks and #m.Blocks > 0 then
                Macro.toggle(i, true)
                builders.Macro()
                break
            end
        end
    end
end)

-- ============================================================
-- KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        State.Visible = not State.Visible
        main.Visible = State.Visible
        Config.UI.Visible = State.Visible
    end
end)

-- ============================================================
-- INIT
-- ============================================================
builders.showTab("Combat")
ESP.refresh()
_G.RefreshMacroButton()

-- Apply saved state at startup
if Config.Combat.FOVCircle then
    fovCircle.Visible = true
end
if Config.Move.Fly then
    Move.setFly(true)
end

task.spawn(function()
    task.wait(1)
    U.Notify("Dungdx PvP", "Loaded! RightShift = ẩn/hiện UI", 5)
end)

print("==============================================")
print("DUNGDX PVP — v" .. Brand.Version)
print("Owner: " .. Brand.Owner)
print("Discord: " .. Brand.Discord)
print("==============================================")