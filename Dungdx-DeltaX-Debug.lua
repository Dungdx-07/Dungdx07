--[[
    ╔══════════════════════════════════════════════════════════════╗
       BLOX COMMUNITY VN — Dungdx
       Utility / Farming / ESP / Travel build
       Discord: discord.gg/AJBT8F79yf

       Architecture:
       Config -> ResourceManager -> LoopManager -> Movement -> Features -> UI

       Notes:
       - Utility-only: no combat/weapon automation.
       - Movement has one writer and priority ownership.
       - Every toggle has a real start/stop lifecycle.
       - Stop All and Unload cancel loops, movement and connections.
    ╚══════════════════════════════════════════════════════════════╝
--]]

local GEN = (type(getgenv) == "function" and getgenv()) or _G
-- Executor-safe stale-load guard: an earlier runtime error must not brick re-execution.
if GEN.BCVN_DX_COMPLETE_LOADED then
    local ok, existing = pcall(function()
        local pg = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
        return pg and pg:FindFirstChild("BloxCommunityVN")
    end)
    if ok and existing then
        return warn("[BCVN] Dungdx is already running.")
    end
    GEN.BCVN_DX_COMPLETE_LOADED = nil
end
GEN.BCVN_DX_COMPLETE_LOADED = true

Debug.Stage("SERVICES")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

--============================================================
-- Dungdx DeltaX DEBUG BOOTSTRAP
--============================================================
local Debug = { Lines = {}, Gui = nil, Label = nil, Max = 12 }

local function DebugRender()
    if not Debug.Label then return end
    local out = {}
    local start = math.max(1, #Debug.Lines - Debug.Max + 1)
    for i = start, #Debug.Lines do
        out[#out + 1] = Debug.Lines[i]
    end
    pcall(function() Debug.Label.Text = table.concat(out, "\n") end)
end

function Debug.Log(message)
    local line = "[BCVN DEBUG] " .. tostring(message)
    Debug.Lines[#Debug.Lines + 1] = line
    pcall(warn, line)
    DebugRender()
end

function Debug.Stage(name)
    Debug.Log("STAGE: " .. tostring(name))
end

function Debug.Error(message)
    Debug.Log("ERROR: " .. tostring(message))
    if Debug.Label then
        pcall(function() Debug.Label.TextColor3 = Color3.fromRGB(255, 100, 100) end)
    end
end

local function CreateDebugOverlay()
    local ok, result = pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        if not lp then return nil end
        local pg = lp:WaitForChild("PlayerGui", 10)
        if not pg then return nil end
        local old = pg:FindFirstChild("BCVN_DeltaX_Debug")
        if old then old:Destroy() end

        local sg = Instance.new("ScreenGui")
        sg.Name = "BCVN_DeltaX_Debug"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 999999
        sg.Parent = pg

        local frame = Instance.new("Frame")
        frame.Name = "Panel"
        frame.Size = UDim2.new(0, 430, 0, 190)
        frame.Position = UDim2.new(0.5, -215, 0, 20)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        frame.BackgroundTransparency = 0.08
        frame.BorderSizePixel = 0
        frame.Parent = sg

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 28)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Text = "Dungdx • DeltaX Debug"
        title.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, -40)
        label.Position = UDim2.new(0, 10, 0, 35)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Code
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextWrapped = false
        label.Text = "Starting..."
        label.Parent = frame

        Debug.Gui = sg
        Debug.Label = label
        return sg
    end)
    if not ok then
        pcall(warn, "[BCVN DEBUG] Overlay error: " .. tostring(result))
    end
    return result
end

CreateDebugOverlay()
Debug.Stage("BOOT")

local function __BCVN_MAIN()
local UI = {}
local Features

local Config = {
    AutoChest = false,
    AutoFruit = false,
    WalkSpeedEnabled = false,
    WalkSpeed = 50,
    JumpPowerEnabled = false,
    JumpPower = 50,
    InfiniteZoom = false,
    RemoveFog = false,
    FullBright = false,
    FPSBoost = false,
    AntiAFK = true,
    ESPPlayer = false,
    ESPChest = false,
    ESPFruit = false,
    ESPIsland = false,
    TweenSpeed = 250,
    SelectedPlayer = "",
    SelectedIsland = "",
    WebhookEnabled = false,
    WebhookURL = "",
    NotifyWebhook = false,
}
GEN.BCVN_Config = Config

local State = {
    Unloaded = false,
    Character = nil,
    Humanoid = nil,
    HRP = nil,
    Camera = Workspace.CurrentCamera,
    CharacterVersion = 0,
    Original = {
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        GlobalShadows = Lighting.GlobalShadows,
        CameraMaxZoomDistance = (Workspace.CurrentCamera and Workspace.CurrentCamera.CameraMaxZoomDistance) or 128,
        Humanoid = nil,
        WalkSpeed = nil,
        UseJumpPower = nil,
        JumpPower = nil,
    },
}

--============================================================
-- Resource manager
--============================================================
Debug.Stage("STATE / RESOURCES")
local Resources = { Connections = {}, Instances = {}, Tasks = {} }
function Resources:AddConnection(c)
    if c then table.insert(self.Connections, c) end
    return c
end
function Resources:AddInstance(i)
    if i then table.insert(self.Instances, i) end
    return i
end
function Resources:AddTask(t, key)
    if not t then return t end
    if key then
        local old = self.Tasks[key]
        if old then pcall(function() task.cancel(old) end) end
        self.Tasks[key] = t
    else
        local id = tostring(t)
        self.Tasks[id] = t
    end
    return t
end
function Resources:RemoveTask(key)
    local t = self.Tasks[key]
    if t then pcall(function() task.cancel(t) end); self.Tasks[key] = nil end
end
function Resources:Cleanup()
    for key, t in pairs(self.Tasks) do
        pcall(function() task.cancel(t) end)
        self.Tasks[key] = nil
    end
    for i = #self.Connections, 1, -1 do
        local c = self.Connections[i]
        pcall(function() c:Disconnect() end)
    end
    table.clear(self.Connections)
    for i = #self.Instances, 1, -1 do
        local inst = self.Instances[i]
        pcall(function() inst:Destroy() end)
    end
    table.clear(self.Instances)
end

--============================================================
-- Loop manager: token + owned task, no accumulation
--============================================================
local LoopManager = { Tokens = {}, Tasks = {} }
function LoopManager:Start(name, interval, callback, persistent)
    self:Stop(name)
    local token = {Persistent = persistent == true}
    self.Tokens[name] = token
    local thread = task.spawn(function()
        while not State.Unloaded and self.Tokens[name] == token do
            local ok, err = pcall(callback)
            if not ok then warn("[BCVN] Loop " .. name .. ": " .. tostring(err)) end
            if interval and interval > 0 then task.wait(interval) else RunService.Heartbeat:Wait() end
        end
    end)
    self.Tasks[name] = thread
    return token
end
function LoopManager:Stop(name)
    self.Tokens[name] = nil
    local thread = self.Tasks[name]
    if thread then pcall(function() task.cancel(thread) end) end
    self.Tasks[name] = nil
end
function LoopManager:StopAll(includePersistent)
    local names = {}
    for name, token in pairs(self.Tokens) do
        if includePersistent or not token.Persistent then table.insert(names, name) end
    end
    for _, name in ipairs(names) do self:Stop(name) end
end
function LoopManager:IsRunning(name)
    return self.Tokens[name] ~= nil
end

--============================================================
-- Movement service: single writer + priority owner
--============================================================
local Movement = {
    owner = nil,
    priority = -math.huge,
    generation = 0,
    active = false,
}
function Movement:Stop(owner)
    if owner and self.owner ~= owner then return false end
    self.generation += 1
    self.owner = nil
    self.priority = -math.huge
    self.active = false
    return true
end
function Movement:MoveTo(target, owner, priority, instant)
    priority = tonumber(priority) or 0
    if self.owner and self.owner ~= owner and priority < self.priority then return false end
    if not State.HRP or not State.HRP.Parent or not State.Humanoid or State.Humanoid.Health <= 0 then return false end
    if typeof(target) == "Vector3" then target = CFrame.new(target) end
    if typeof(target) ~= "CFrame" then return false end

    local characterVersion = State.CharacterVersion
    local hrp = State.HRP
    local humanoid = State.Humanoid
    self.generation += 1
    local myGen = self.generation
    self.owner = owner
    self.priority = priority
    self.active = true

    local function Valid()
        return myGen == self.generation
            and not State.Unloaded
            and State.CharacterVersion == characterVersion
            and State.HRP == hrp
            and hrp and hrp.Parent
            and State.Humanoid == humanoid
            and humanoid and humanoid.Parent
            and humanoid.Health > 0
    end

    if instant then
        if not Valid() then return false end
        pcall(function() hrp.CFrame = target end)
        if myGen == self.generation then self.active = false end
        return myGen == self.generation
    end

    local distance = (target.Position - hrp.Position).Magnitude
    if distance <= 5 then
        if not Valid() then return false end
        pcall(function() hrp.CFrame = target end)
        self.active = false
        return true
    end

    local speed = math.clamp(tonumber(Config.TweenSpeed) or 250, 25, 1000)
    local duration = math.clamp(distance / speed, 0.08, 12)
    local start = hrp.CFrame
    local elapsed = 0
    local rot = target - target.Position

    while elapsed < duration and Valid() do
        elapsed += RunService.Heartbeat:Wait()
        if not Valid() then break end
        local a = math.clamp(elapsed / duration, 0, 1)
        local pos = start.Position:Lerp(target.Position, a)
        pcall(function() hrp.CFrame = CFrame.new(pos) * rot end)
    end

    if Valid() then
        pcall(function() hrp.CFrame = target end)
        self.active = false
        return true
    end
    if myGen == self.generation then self.active = false end
    return false
end

--============================================================
Debug.Stage("MOVEMENT / CHARACTER")
-- Character lifecycle
--============================================================
local function SnapshotHumanoid(hum)
    if not hum then return end
    State.Original.Humanoid = hum
    State.Original.WalkSpeed = hum.WalkSpeed
    State.Original.UseJumpPower = hum.UseJumpPower
    State.Original.JumpPower = hum.JumpPower
end

local function RefreshCharacter(char)
    State.CharacterVersion += 1
    State.Character = char
    State.Humanoid = nil
    State.HRP = nil
    State.Original.Humanoid = nil
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 8)
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 8)
    if State.Character ~= char then return end
    State.Humanoid = hum
    State.HRP = hrp
    SnapshotHumanoid(hum)
end

RefreshCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())

Resources:AddConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    Movement:Stop()
    RefreshCharacter(char)
    task.defer(function()
        if not State.Unloaded and Features and Features.ApplyMovement then
            Features.ApplyMovement()
        end
    end)
end))
Resources:AddConnection(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    State.Camera = Workspace.CurrentCamera
    local cam = State.Camera
    if cam and not Config.InfiniteZoom then
        State.Original.CameraMaxZoomDistance = cam.CameraMaxZoomDistance
    end
end))

--============================================================
-- Helpers / targets
--============================================================
local function Notify(title, text, duration)
    if UI and UI.Notify then UI.Notify(title, text, duration or 4) end
end

local function FindRoot(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    return obj:FindFirstChild("HumanoidRootPart")
        or obj:FindFirstChild("RootPart")
        or obj.PrimaryPart
        or obj:FindFirstChild("Handle")
end

local function DistanceTo(obj)
    local root = FindRoot(obj)
    if not root or not State.HRP then return math.huge end
    return (root.Position - State.HRP.Position).Magnitude
end

local function FindNearestChest()
    local folder = Workspace:FindFirstChild("ChestModels")
    if not folder or not State.HRP then return nil end
    local best, bestDist
    for _, obj in ipairs(folder:GetChildren()) do
        local root = FindRoot(obj)
        if root and root:IsDescendantOf(Workspace) then
            local dist = (root.Position - State.HRP.Position).Magnitude
            if not bestDist or dist < bestDist then best, bestDist = obj, dist end
        end
    end
    return best
end

local function IsFruit(obj)
    if not obj then return false end
    local n = string.lower(obj.Name)
    if n:find("fruit", 1, true) then return true end
    return obj:IsA("Tool") and obj:FindFirstChild("Handle") ~= nil and n ~= "tool"
end

local function FindNearestFruit()
    if not State.HRP then return nil end
    local best, bestDist
    for _, obj in ipairs(Workspace:GetChildren()) do
        if IsFruit(obj) then
            local root = FindRoot(obj)
            if root then
                local dist = (root.Position - State.HRP.Position).Magnitude
                if not bestDist or dist < bestDist then best, bestDist = obj, dist end
            end
        end
    end
    return best
end

local function GetPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    table.sort(list)
    return list
end

local IslandFallback = {
    ["First Sea"] = {
        ["Starter Island"] = Vector3.new(1073, 17, 1426),
        ["Jungle"] = Vector3.new(-1615, 36, 149),
        ["Pirate Village"] = Vector3.new(-1185, 5, 3800),
        ["Desert"] = Vector3.new(944, 21, 4488),
        ["Frozen Village"] = Vector3.new(1347, 87, -1325),
        ["Marine Fortress"] = Vector3.new(-5074, 28, 4257),
        ["Colosseum"] = Vector3.new(-1427, 7, -2792),
        ["Skylands"] = Vector3.new(-4970, 717, -2623),
        ["Prison"] = Vector3.new(4875, 5, 735),
        ["Magma Village"] = Vector3.new(-5231, 12, 8521),
        ["Underwater City"] = Vector3.new(61163, 11, 1819),
        ["Fountain City"] = Vector3.new(5132, 5, 4038),
    },
    ["Second Sea"] = {
        ["Kingdom of Rose"] = Vector3.new(-428, 73, 1836),
        ["Cafe"] = Vector3.new(-381, 73, 297),
        ["Green Zone"] = Vector3.new(-2448, 73, -3210),
        ["Graveyard"] = Vector3.new(-5637, 126, -749),
        ["Snow Mountain"] = Vector3.new(553, 402, -531),
        ["Hot and Cold"] = Vector3.new(-6035, 16, -5072),
        ["Cursed Ship"] = Vector3.new(923, 125, 32852),
        ["Ice Castle"] = Vector3.new(6132, 294, -6741),
        ["Forgotten Island"] = Vector3.new(-3044, 238, -10148),
    },
    ["Third Sea"] = {
        ["Port Town"] = Vector3.new(-290, 44, 5458),
        ["Hydra Island"] = Vector3.new(5229, 1004, 345),
        ["Great Tree"] = Vector3.new(2681, 1682, -7191),
        ["Castle on the Sea"] = Vector3.new(-5076, 315, -2991),
        ["Haunted Castle"] = Vector3.new(-9515, 142, 5537),
        ["Sea of Treats"] = Vector3.new(-2074, 62, -12289),
        ["Tiki Outpost"] = Vector3.new(-16200, 9, 439),
        ["Floating Turtle"] = Vector3.new(-13274, 332, -7575),
    },
}

local function GetSeaName()
    local map = Workspace:GetAttribute("MAP")
    if map == "Sea1" then return "First Sea" end
    if map == "Sea2" then return "Second Sea" end
    if map == "Sea3" then return "Third Sea" end
    local place = game.PlaceId
    if place == 2753915549 then return "First Sea" end
    if place == 4442272183 then return "Second Sea" end
    if place == 7449423635 then return "Third Sea" end
    return "First Sea"
end

local function GetIslandMap()
    local map = {}
    local world = Workspace:FindFirstChild("_WorldOrigin")
    local locations = world and world:FindFirstChild("Locations")
    if locations then
        for _, obj in ipairs(locations:GetChildren()) do
            local root = FindRoot(obj)
            if root then map[obj.Name] = root.Position end
        end
    end
    for name, pos in pairs(IslandFallback[GetSeaName()] or {}) do
        if not map[name] then map[name] = pos end
    end
    return map
end

--============================================================
Debug.Stage("FEATURES")
-- Feature lifecycle
--============================================================
Features = {}

function Features.ApplyMovement()
    local hum = State.Humanoid
    if not hum or hum.Health <= 0 then return end
    if State.Original.Humanoid ~= hum then SnapshotHumanoid(hum) end

    if Config.WalkSpeedEnabled then
        pcall(function() hum.WalkSpeed = math.clamp(tonumber(Config.WalkSpeed) or 16, 0, 500) end)
    else
        pcall(function() hum.WalkSpeed = State.Original.WalkSpeed end)
    end

    if Config.JumpPowerEnabled then
        pcall(function()
            hum.UseJumpPower = true
            hum.JumpPower = math.clamp(tonumber(Config.JumpPower) or 50, 0, 500)
        end)
    else
        pcall(function()
            hum.UseJumpPower = State.Original.UseJumpPower
            hum.JumpPower = State.Original.JumpPower
        end)
    end
end

function Features.RestoreMovement()
    local hum = State.Original.Humanoid
    if not hum or not hum.Parent then return end
    pcall(function() hum.WalkSpeed = State.Original.WalkSpeed end)
    pcall(function() hum.UseJumpPower = State.Original.UseJumpPower end)
    pcall(function() hum.JumpPower = State.Original.JumpPower end)
end

function Features.StopMovement()
    Movement:Stop()
    Features.RestoreMovement()
end

function Features.StartAutoChest()
    Features.StopAutoFruit()
    LoopManager:Start("AutoChest", 0.25, function()
        if not Config.AutoChest then return end
        local chest = FindNearestChest()
        if not chest then
            if Movement.owner == "AutoChest" then Movement:Stop("AutoChest") end
            return
        end
        local root = FindRoot(chest)
        if root then
            Movement:MoveTo(root.CFrame + Vector3.new(0, 3, 0), "AutoChest", 20, false)
        end
    end)
end
function Features.StopAutoChest()
    LoopManager:Stop("AutoChest")
    if Movement.owner == "AutoChest" then Movement:Stop("AutoChest") end
end

function Features.StartAutoFruit()
    Features.StopAutoChest()
    LoopManager:Start("AutoFruit", 0.3, function()
        if not Config.AutoFruit then return end
        local fruit = FindNearestFruit()
        if not fruit then
            if Movement.owner == "AutoFruit" then Movement:Stop("AutoFruit") end
            return
        end
        local root = FindRoot(fruit)
        if root then
            Movement:MoveTo(root.CFrame + Vector3.new(0, 2, 0), "AutoFruit", 15, false)
        end
    end)
end
function Features.StopAutoFruit()
    LoopManager:Stop("AutoFruit")
    if Movement.owner == "AutoFruit" then Movement:Stop("AutoFruit") end
end

--============================================================
Debug.Stage("ESP")
-- ESP
--============================================================
local ESP = { Items = {}, Suppressed = {} }
for _, category in ipairs({"Player", "Chest", "Fruit", "Island"}) do
    ESP.Suppressed[category] = false
end
local function RemoveESP(key)
    local item = ESP.Items[key]
    if item then pcall(function() item:Destroy() end) end
    ESP.Items[key] = nil
end
function ESP.Clear(category, suppress)
    local keys = {}
    for key, gui in pairs(ESP.Items) do
        if (not category) or (gui and gui:GetAttribute("Category") == category) then
            keys[#keys + 1] = key
        end
    end
    for _, key in ipairs(keys) do RemoveESP(key) end
    if category then
        if suppress ~= nil then ESP.Suppressed[category] = suppress end
    elseif suppress ~= nil then
        for name in pairs(ESP.Suppressed) do ESP.Suppressed[name] = suppress end
    end
end
function ESP.Enable(category)
    ESP.Suppressed[category] = false
end
function ESP.Reconcile(category, seen)
    local keys = {}
    for key, gui in pairs(ESP.Items) do
        if gui and gui:GetAttribute("Category") == category and not seen[key] then
            keys[#keys + 1] = key
        end
    end
    for _, key in ipairs(keys) do RemoveESP(key) end
end
function ESP.Add(key, adornee, text, color, category)
    if ESP.Suppressed[category] then return end
    if not key or not adornee or not adornee:IsDescendantOf(Workspace) then return end
    local old = ESP.Items[key]
    if old and old.Parent and old.Adornee == adornee then
        local label = old:FindFirstChild("Label")
        if label then label.Text = text end
        return
    end
    RemoveESP(key)
    local bb = Instance.new("BillboardGui")
    bb.Name = "DxESP"
    bb.Size = UDim2.fromOffset(190, 26)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = adornee
    bb:SetAttribute("Category", category)
    bb.Parent = adornee
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.25
    label.Parent = bb
    ESP.Items[key] = bb
end

local function ESPTick()
    if Config.ESPPlayer then
        local seen = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local head = p.Character:FindFirstChild("Head") or FindRoot(p.Character)
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local key = "Player:" .. p.UserId
                if head and hum and hum.Health > 0 then
                    seen[key] = true
                    ESP.Add(key, head, p.DisplayName .. " [" .. math.floor(hum.Health) .. "]", Color3.fromRGB(255, 90, 90), "Player")
                end
            end
        end
        ESP.Reconcile("Player", seen)
    else
        ESP.Clear("Player")
    end

    if Config.ESPChest then
        local seen = {}
        local folder = Workspace:FindFirstChild("ChestModels")
        if folder then
            for _, chest in ipairs(folder:GetChildren()) do
                local root = FindRoot(chest)
                local key = chest
                if root then
                    seen[key] = true
                    ESP.Add(key, root, "Chest", Color3.fromRGB(80, 220, 120), "Chest")
                end
            end
        end
        ESP.Reconcile("Chest", seen)
    else
        ESP.Clear("Chest")
    end

    if Config.ESPFruit then
        local seen = {}
        for _, obj in ipairs(Workspace:GetChildren()) do
            if IsFruit(obj) then
                local root = FindRoot(obj)
                local key = obj
                if root then
                    seen[key] = true
                    ESP.Add(key, root, obj.Name, Color3.fromRGB(255, 200, 70), "Fruit")
                end
            end
        end
        ESP.Reconcile("Fruit", seen)
    else
        ESP.Clear("Fruit")
    end

    if Config.ESPIsland then
        local seen = {}
        local world = Workspace:FindFirstChild("_WorldOrigin")
        local locations = world and world:FindFirstChild("Locations")
        if locations then
            for _, obj in ipairs(locations:GetChildren()) do
                local root = FindRoot(obj)
                local key = obj
                if root and obj.Name ~= "Sea" then
                    seen[key] = true
                    ESP.Add(key, root, obj.Name, Color3.fromRGB(90, 170, 255), "Island")
                end
            end
        end
        ESP.Reconcile("Island", seen)
    else
        ESP.Clear("Island")
    end
end

LoopManager:Start("ESP", 1, ESPTick, true)

--============================================================
-- Performance / visual settings
--============================================================
local OriginalParts = {}
local function ApplyFog()
    if Config.RemoveFog then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = State.Original.FogEnd
        Lighting.FogStart = State.Original.FogStart
    end
end
local function ApplyFullBright()
    if Config.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = State.Original.Brightness
        Lighting.ClockTime = State.Original.ClockTime
        Lighting.Ambient = State.Original.Ambient
        Lighting.OutdoorAmbient = State.Original.OutdoorAmbient
        Lighting.GlobalShadows = State.Original.GlobalShadows
    end
end
local function ApplyFPSBoost()
    if not Config.FPSBoost then
        for obj, old in pairs(OriginalParts) do
            if obj and obj.Parent then
                pcall(function()
                    obj.Material = old.Material
                    obj.Reflectance = old.Reflectance
                end)
            end
        end
        table.clear(OriginalParts)
        return
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not OriginalParts[obj] then
            OriginalParts[obj] = {Material = obj.Material, Reflectance = obj.Reflectance}
            pcall(function() obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0 end)
        end
    end
end

local function ApplyZoom()
    local cam = Workspace.CurrentCamera
    if cam then
        cam.CameraMaxZoomDistance = Config.InfiniteZoom and 1000 or State.Original.CameraMaxZoomDistance
    end
end

--============================================================
-- Anti AFK
--============================================================
local function StopAntiAFK()
    LoopManager:Stop("AntiAFK")
end
local function StartAntiAFK()
    StopAntiAFK()
    if not Config.AntiAFK then return end
    LoopManager:Start("AntiAFK", 50, function()
        if not Config.AntiAFK then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
    end)
end
StartAntiAFK()

--============================================================
-- Webhook
--============================================================
local function GetRequest()
    return (syn and syn.request) or (http and http.request) or request or http_request
end
local function SendWebhook(title, description)
    if not Config.WebhookEnabled or Config.WebhookURL == "" then return false end
    local req = GetRequest()
    if not req then return false end
    local body = HttpService:JSONEncode({
        embeds = {{
            title = title,
            description = description,
            color = 5814783,
            footer = {text = "Blox Community VN • Dungdx"},
            timestamp = DateTime.now():ToIsoDate(),
        }}
    })
    local ok, response = pcall(function()
        return req({Url = Config.WebhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body})
    end)
    if not ok then return false end
    if type(response) == "table" and response.StatusCode then
        return tonumber(response.StatusCode) and tonumber(response.StatusCode) >= 200 and tonumber(response.StatusCode) < 300
    end
    return true
end

--============================================================
Debug.Stage("UI")
-- UI
--============================================================
local Theme = {
    Bg = Color3.fromRGB(18, 19, 22),
    Panel = Color3.fromRGB(27, 28, 33),
    Card = Color3.fromRGB(35, 36, 42),
    Button = Color3.fromRGB(45, 46, 54),
    Hover = Color3.fromRGB(58, 60, 70),
    Text = Color3.fromRGB(240, 241, 245),
    Dim = Color3.fromRGB(150, 152, 162),
    Accent = Color3.fromRGB(90, 155, 255),
    Green = Color3.fromRGB(80, 205, 125),
    Red = Color3.fromRGB(230, 90, 90),
    Yellow = Color3.fromRGB(245, 200, 80),
}
UI.Theme = Theme

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then
    GEN.BCVN_DX_COMPLETE_LOADED = nil
    return warn("[BCVN] PlayerGui unavailable.")
end
local oldGui = PlayerGui:FindFirstChild("BloxCommunityVN")
if oldGui then oldGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "BloxCommunityVN"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- DeltaX / mobile executor compatibility: prefer hidden UI container when available,
-- then CoreGui, finally PlayerGui. All branches are protected with pcall.
local guiParent
pcall(function()
    if type(gethui) == "function" then
        guiParent = gethui()
    end
end)
if not guiParent then
    pcall(function() guiParent = game:GetService("CoreGui") end)
end
if not guiParent then
    guiParent = PlayerGui
end
Gui.Parent = guiParent
Resources:AddInstance(Gui)

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 7)
    c.Parent = obj
    return c
end
local function Stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Button
    s.Thickness = thickness or 1
    s.Parent = obj
    return s
end

local Root = Instance.new("Frame")
Root.AnchorPoint = Vector2.new(0.5, 0.5)
Root.Position = UDim2.fromScale(0.5, 0.5)
Root.Size = UDim2.fromOffset(620, 455)
Root.BackgroundColor3 = Theme.Bg
Root.BorderSizePixel = 0
Root.Parent = Gui
Corner(Root, 12)
Stroke(Root, Color3.fromRGB(55, 56, 65), 1)

local Scale = Instance.new("UIScale")
Scale.Parent = Root
local function FitUI()
    local cam = Workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1000, 600)
    Scale.Scale = math.min(math.clamp((vp.X - 30) / 620, 0.55, 1.05), math.clamp((vp.Y - 70) / 455, 0.55, 1.05))
end
FitUI()
Resources:AddConnection(Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(FitUI))

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,58)
Header.BackgroundColor3 = Theme.Panel
Header.BorderSizePixel = 0
Header.Parent = Root
Corner(Header, 12)
local Cover = Instance.new("Frame")
Cover.Size = UDim2.new(1,0,0,15)
Cover.Position = UDim2.new(0,0,1,-15)
Cover.BackgroundColor3 = Theme.Panel
Cover.BorderSizePixel = 0
Cover.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(18, 9)
Title.Size = UDim2.fromOffset(390, 22)
Title.Text = "BLOX COMMUNITY VN"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.Text
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.fromOffset(18, 32)
SubTitle.Size = UDim2.fromOffset(430, 16)
SubTitle.Text = "Dungdx • Utility Build • discord.gg/AJBT8F79yf"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextColor3 = Theme.Dim
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.fromOffset(30,30)
HideButton.Position = UDim2.new(1,-42,0,14)
HideButton.BackgroundColor3 = Theme.Button
HideButton.Text = "×"
HideButton.Font = Enum.Font.GothamBold
HideButton.TextSize = 17
HideButton.TextColor3 = Theme.Text
HideButton.AutoButtonColor = false
HideButton.Parent = Header
Corner(HideButton, 7)

local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.fromOffset(54,54)
FloatButton.Position = UDim2.new(0,18,0.5,-27)
FloatButton.BackgroundColor3 = Theme.Panel
FloatButton.Text = "Dx"
FloatButton.Font = Enum.Font.GothamBold
FloatButton.TextSize = 20
FloatButton.TextColor3 = Theme.Text
FloatButton.AutoButtonColor = false
FloatButton.Visible = false
FloatButton.Active = true
FloatButton.Draggable = true
FloatButton.Parent = Gui
Corner(FloatButton, 27)
Stroke(FloatButton, Theme.Accent, 1.5)

Resources:AddConnection(HideButton.MouseButton1Click:Connect(function() Root.Visible = false; FloatButton.Visible = true end))
Resources:AddConnection(FloatButton.MouseButton1Click:Connect(function() Root.Visible = true; FloatButton.Visible = false end))

local TabBar = Instance.new("ScrollingFrame")
TabBar.Position = UDim2.fromOffset(10, 64)
TabBar.Size = UDim2.new(1,-20,0,31)
TabBar.BackgroundTransparency = 1
TabBar.ScrollBarThickness = 0
TabBar.ScrollingDirection = Enum.ScrollingDirection.X
TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
TabBar.CanvasSize = UDim2.new()
TabBar.Parent = Root
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,5)
TabLayout.Parent = TabBar

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(10, 101)
Content.Size = UDim2.new(1,-20,1,-111)
Content.BackgroundTransparency = 1
Content.Parent = Root

local Tabs = {}
local TabButtons = {}
local ActiveTab
local function CreateTab(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(84,29)
    button.BackgroundColor3 = Theme.Button
    button.Text = name
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 10
    button.TextColor3 = Theme.Dim
    button.AutoButtonColor = false
    button.Parent = TabBar
    Corner(button, 7)

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromScale(1,1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = Content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = page
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    Tabs[name] = page
    TabButtons[name] = button
    Resources:AddConnection(button.MouseButton1Click:Connect(function()
        for n,p in pairs(Tabs) do p.Visible = (n == name) end
        for n,b in pairs(TabButtons) do
            b.BackgroundColor3 = n == name and Theme.Accent or Theme.Button
            b.TextColor3 = n == name and Color3.new(1,1,1) or Theme.Dim
        end
        ActiveTab = name
    end))
    return page
end

local function Section(parent, title)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-2,0,0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundColor3 = Theme.Panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Corner(frame, 9)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0,9); pad.PaddingBottom = UDim.new(0,9)
    pad.PaddingLeft = UDim.new(0,10); pad.PaddingRight = UDim.new(0,10)
    pad.Parent = frame
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0,6)
    lay.Parent = frame
    local label = Instance.new("TextLabel")
    label.LayoutOrder = -10
    label.Size = UDim2.new(1,0,0,18)
    label.BackgroundTransparency = 1
    label.Text = title
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    return frame
end

local function Label(parent, text, sub)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,35)
    f.BackgroundColor3 = Theme.Card
    f.BorderSizePixel = 0
    f.Parent = parent
    Corner(f,7)
    local t = Instance.new("TextLabel")
    t.Position = UDim2.fromOffset(10,5); t.Size = UDim2.new(1,-20,0,15)
    t.BackgroundTransparency = 1; t.Text = text
    t.Font = Enum.Font.GothamSemibold; t.TextSize = 10; t.TextColor3 = Theme.Text
    t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = f
    local s = Instance.new("TextLabel")
    s.Position = UDim2.fromOffset(10,19); s.Size = UDim2.new(1,-20,0,12)
    s.BackgroundTransparency = 1; s.Text = sub or ""
    s.Font = Enum.Font.Gotham; s.TextSize = 8; s.TextColor3 = Theme.Dim
    s.TextXAlignment = Enum.TextXAlignment.Left; s.Parent = f
    return {Frame=f, Set=function(_,v) t.Text=v end}
end

local ToggleBindings = {}
local function SyncToggle(key, value)
    local group = ToggleBindings[key]
    if not group then return end
    for _, binding in ipairs(group) do
        if binding and binding.Set then pcall(binding.Set, value, false) end
    end
end

local function Button(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundColor3 = Theme.Button
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 10
    b.TextColor3 = Theme.Text
    b.AutoButtonColor = false
    b.Parent = parent
    Corner(b,7)
    Resources:AddConnection(b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.Hover end))
    Resources:AddConnection(b.MouseLeave:Connect(function() b.BackgroundColor3 = Theme.Button end))
    Resources:AddConnection(b.MouseButton1Click:Connect(function() pcall(callback) end))
    return b
end

local function Toggle(parent, text, default, callback, sub)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,40)
    b.BackgroundColor3 = Theme.Card
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    Corner(b,7)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(10,5); title.Size = UDim2.new(1,-60,0,15)
    title.BackgroundTransparency = 1; title.Text = text
    title.Font = Enum.Font.GothamSemibold; title.TextSize = 10; title.TextColor3 = Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = b
    local desc = Instance.new("TextLabel")
    desc.Position = UDim2.fromOffset(10,21); desc.Size = UDim2.new(1,-60,0,12)
    desc.BackgroundTransparency = 1; desc.Text = sub or ""
    desc.Font = Enum.Font.Gotham; desc.TextSize = 8; desc.TextColor3 = Theme.Dim
    desc.TextXAlignment = Enum.TextXAlignment.Left; desc.Parent = b
    local sw = Instance.new("Frame")
    sw.Size = UDim2.fromOffset(38,20); sw.Position = UDim2.new(1,-48,0.5,-10)
    sw.BackgroundColor3 = Theme.Button; sw.Parent = b; Corner(sw,10)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16,16); knob.Position = UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = Theme.Dim; knob.Parent = sw; Corner(knob,8)
    local value = default == true
    local api = {}
    local function Paint()
        sw.BackgroundColor3 = value and Theme.Accent or Theme.Button
        knob.BackgroundColor3 = value and Color3.new(1,1,1) or Theme.Dim
        knob.Position = value and UDim2.new(1,-18,0,2) or UDim2.fromOffset(2,2)
    end
    function api.Set(v, fire)
        value = v == true
        Paint()
        if fire ~= false then
            local ok, err = pcall(callback, value)
            if not ok then warn("[BCVN] Toggle " .. tostring(text) .. ": " .. tostring(err)) end
        end
    end
    ToggleBindings[text] = ToggleBindings[text] or {}
    table.insert(ToggleBindings[text], api)
    Paint()
    Resources:AddConnection(b.MouseButton1Click:Connect(function()
        api.Set(not value, true)
        SyncToggle(text, value)
    end))
    return api
end

local function Slider(parent, text, min, max, default, callback, step)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,48)
    f.BackgroundColor3 = Theme.Card; f.Parent = parent; Corner(f,7)
    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(10,6); title.Size = UDim2.new(1,-70,0,14)
    title.BackgroundTransparency=1; title.Text=text; title.Font=Enum.Font.GothamSemibold
    title.TextSize=10; title.TextColor3=Theme.Text; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=f
    local val = Instance.new("TextLabel")
    val.Position=UDim2.new(1,-60,0,6); val.Size=UDim2.fromOffset(50,14)
    val.BackgroundTransparency=1; val.Font=Enum.Font.Gotham; val.TextSize=9; val.TextColor3=Theme.Dim
    val.TextXAlignment=Enum.TextXAlignment.Right; val.Parent=f
    local track=Instance.new("Frame"); track.Position=UDim2.fromOffset(10,29); track.Size=UDim2.new(1,-20,0,5)
    track.BackgroundColor3=Theme.Button; track.Parent=f; Corner(track,3)
    local fill=Instance.new("Frame"); fill.Size=UDim2.fromScale(0,1); fill.BackgroundColor3=Theme.Accent; fill.Parent=track; Corner(fill,3)
    local dragging=false
    local value=tonumber(default) or min
    local function Set(v,fire)
        v=math.clamp(tonumber(v) or min,min,max)
        if step and step>0 then v=math.floor(v/step+0.5)*step end
        value=v; local a=(v-min)/(max-min); fill.Size=UDim2.fromScale(a,1); val.Text=tostring(v)
        if fire ~= false then pcall(callback,v) end
    end
    Set(value,false)
    local function FromX(x)
        local a=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1); Set(min+(max-min)*a,true)
    end
    Resources:AddConnection(track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; FromX(i.Position.X) end end))
    Resources:AddConnection(UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then FromX(i.Position.X) end end))
    Resources:AddConnection(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end))
    return {Set=Set,Get=function() return value end}
end

local function Dropdown(parent, text, default, getOptions, callback)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,36); b.BackgroundColor3=Theme.Card; b.Text=""; b.AutoButtonColor=false; b.Parent=parent; Corner(b,7)
    local title=Instance.new("TextLabel"); title.Position=UDim2.fromOffset(10,5); title.Size=UDim2.new(0.5,0,0,13); title.BackgroundTransparency=1
    title.Text=text; title.Font=Enum.Font.GothamSemibold; title.TextSize=10; title.TextColor3=Theme.Text; title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=b
    local selected=Instance.new("TextLabel"); selected.Position=UDim2.new(0.45,0,0,5); selected.Size=UDim2.new(0.55,-10,0,24); selected.BackgroundTransparency=1
    selected.Text=tostring(default or "Select..."); selected.Font=Enum.Font.Gotham; selected.TextSize=9; selected.TextColor3=Theme.Dim; selected.TextXAlignment=Enum.TextXAlignment.Right; selected.Parent=b
    local popup
    local api = {}
    local function Close() if popup then popup:Destroy(); popup=nil end end
    local function SetSelected(v, fire)
        selected.Text = (v and tostring(v) ~= "" and tostring(v)) or "Select..."
        if fire and v then pcall(callback, v) end
    end
    function api.Set(v) SetSelected(v, false) end
    function api.Refresh()
        local options=type(getOptions)=="function" and getOptions() or getOptions or {}
        if default and tostring(default) ~= "" then
            for _, opt in ipairs(options) do
                if tostring(opt) == tostring(default) then
                    SetSelected(opt, false)
                    return options
                end
            end
        end
        if selected.Text ~= "Select..." then
            local keep = selected.Text
            for _, opt in ipairs(options) do
                if tostring(opt) == keep then return options end
            end
            SetSelected(nil, false)
        end
        return options
    end
    local function Open()
        Close()
        local options=api.Refresh() or {}
        popup=Instance.new("Frame"); popup.Size=UDim2.new(1,0,0,math.min(#options*30+6,180)); popup.Position=UDim2.new(0,0,1,4)
        popup.BackgroundColor3=Theme.Panel; popup.ZIndex=20; popup.Parent=b; Corner(popup,7); Stroke(popup,Theme.Button,1)
        local scroll=Instance.new("ScrollingFrame"); scroll.Size=UDim2.fromScale(1,1); scroll.BackgroundTransparency=1; scroll.ScrollBarThickness=2; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=UDim2.new(); scroll.Parent=popup
        local lay=Instance.new("UIListLayout"); lay.Padding=UDim.new(0,2); lay.Parent=scroll
        if #options == 0 then
            local empty=Instance.new("TextLabel"); empty.Size=UDim2.new(1,-6,0,28); empty.BackgroundTransparency=1; empty.Text="No options"; empty.Font=Enum.Font.Gotham; empty.TextSize=9; empty.TextColor3=Theme.Dim; empty.Parent=scroll
        else
            for _,opt in ipairs(options) do
                local item=Instance.new("TextButton"); item.Size=UDim2.new(1,-6,0,28); item.BackgroundColor3=Theme.Button; item.Text=tostring(opt); item.Font=Enum.Font.Gotham; item.TextSize=9; item.TextColor3=Theme.Text; item.AutoButtonColor=false; item.Parent=scroll; Corner(item,5)
                item.MouseButton1Click:Connect(function() SetSelected(opt, true); Close() end)
            end
        end
    end
    Resources:AddConnection(b.MouseButton1Click:Connect(Open))
    Resources:AddConnection(UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 and popup then
            local hit = GuiService:GetGuiObjectsAtPosition(i.Position.X,i.Position.Y)[1]
            if not hit or not hit:IsDescendantOf(b) then Close() end
        end
    end))
    return api
end

local function Textbox(parent, placeholder, default, callback)
    local box=Instance.new("TextBox"); box.Size=UDim2.new(1,0,0,34); box.BackgroundColor3=Theme.Card; box.Text=tostring(default or ""); box.PlaceholderText=placeholder; box.Font=Enum.Font.Gotham; box.TextSize=9; box.TextColor3=Theme.Text; box.PlaceholderColor3=Theme.Dim; box.ClearTextOnFocus=false; box.Parent=parent; Corner(box,7)
    Resources:AddConnection(box.FocusLost:Connect(function() pcall(callback,box.Text) end))
    return box
end

UI.Notify=function(title,text,duration)
    local holder=Gui:FindFirstChild("Notifications")
    if not holder then
        holder=Instance.new("Frame"); holder.Name="Notifications"; holder.Size=UDim2.fromOffset(270,400); holder.Position=UDim2.new(1,-280,0,65); holder.BackgroundTransparency=1; holder.Parent=Gui
        local lay=Instance.new("UIListLayout"); lay.Padding=UDim.new(0,6); lay.VerticalAlignment=Enum.VerticalAlignment.Top; lay.Parent=holder
    end
    local n=Instance.new("Frame"); n.Size=UDim2.fromOffset(270,58); n.BackgroundColor3=Theme.Panel; n.BorderSizePixel=0; n.Parent=holder; Corner(n,8); Stroke(n,Theme.Button,1)
    local t=Instance.new("TextLabel"); t.Position=UDim2.fromOffset(12,7); t.Size=UDim2.new(1,-20,0,16); t.BackgroundTransparency=1; t.Text=tostring(title); t.Font=Enum.Font.GothamBold; t.TextSize=10; t.TextColor3=Theme.Text; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=n
    local d=Instance.new("TextLabel"); d.Position=UDim2.fromOffset(12,24); d.Size=UDim2.new(1,-20,0,28); d.BackgroundTransparency=1; d.Text=tostring(text); d.Font=Enum.Font.Gotham; d.TextSize=8; d.TextColor3=Theme.Dim; d.TextWrapped=true; d.TextXAlignment=Enum.TextXAlignment.Left; d.Parent=n
    Resources:AddTask(task.delay(duration or 4,function() pcall(function() n:Destroy() end) end))
end

local ToggleControls = {}
local function BindToggle(configKey, parent, label, sub, onChanged)
    local list = ToggleControls[configKey] or {}
    ToggleControls[configKey] = list
    local control
    control = Toggle(parent, label, Config[configKey] == true, function(value)
        Config[configKey] = value
        for _, other in ipairs(list) do
            if other ~= control then other.Set(value, false) end
        end
        if onChanged then pcall(onChanged, value) end
    end, sub)
    list[#list + 1] = control
    return control
end
local function SetToggle(configKey, value)
    Config[configKey] = value == true
    for _, control in ipairs(ToggleControls[configKey] or {}) do
        control.Set(Config[configKey], false)
    end
end
local function StopAutomation()
    SetToggle("AutoChest", false)
    SetToggle("AutoFruit", false)
    SetToggle("ESPPlayer", false)
    SetToggle("ESPChest", false)
    SetToggle("ESPFruit", false)
    SetToggle("ESPIsland", false)
    SetToggle("AntiAFK", false)
    Features.StopAutoChest()
    Features.StopAutoFruit()
    StopAntiAFK()
    Movement:Stop()
    ESP.Clear(nil, false)
    Resources:RemoveTask("Travel")
end

--============================================================
Debug.Stage("BUILD TABS")
-- Build tabs
--============================================================
local Home=CreateTab("Home")
local Farm=CreateTab("Farm")
local ESPTab=CreateTab("ESP")
local Travel=CreateTab("Travel")
local PlayerTab=CreateTab("Player")
local Misc=CreateTab("Misc")
local Settings=CreateTab("Settings")

-- Home
local hs=Section(Home,"Blox Community VN")
Label(hs,"Dungdx Complete Utility","Không combat / weapon automation • lifecycle-safe")
local status=Label(hs,"Status: Ready","Movement / Loop / Resource manager online")
local info=Label(hs,"Đang đọc dữ liệu...","")
LoopManager:Start("HomeStats",2,function()
    local data=LocalPlayer:FindFirstChild("Data")
    local level=data and data:FindFirstChild("Level")
    local beli=data and data:FindFirstChild("Beli")
    local frags=data and data:FindFirstChild("Fragments")
    local sea=GetSeaName()
    info:Set("Sea: "..sea.."  |  Lv: "..tostring(level and level.Value or "?").."  |  Beli: "..tostring(beli and beli.Value or "?").."  |  Frags: "..tostring(frags and frags.Value or "?"))
end, true)
local ha=Section(Home,"Quick Actions")
BindToggle("AutoChest",ha,"Auto Chest","Tự tìm rương gần nhất và di chuyển tới",function(v)
    if v then SetToggle("AutoFruit",false); Features.StopAutoFruit(); Features.StartAutoChest() else Features.StopAutoChest() end
end)
BindToggle("AutoFruit",ha,"Auto Fruit","Tự tìm trái rơi gần nhất và di chuyển tới",function(v)
    if v then SetToggle("AutoChest",false); Features.StopAutoChest(); Features.StartAutoFruit() else Features.StopAutoFruit() end
end)
Button(ha,"Refresh ESP",function() ESP.Clear(nil,false); ESPTick(); Notify("ESP","Đã refresh ESP.") end)
Button(ha,"STOP ALL",function()
    StopAutomation()
    Notify("System","Đã dừng Auto Chest, Auto Fruit, ESP, Anti AFK và Movement.")
end)

-- Farm
local fs=Section(Farm,"Chest / Fruit")
BindToggle("AutoChest",fs,"Auto Chest","Exclusive movement target",function(v)
    if v then SetToggle("AutoFruit",false); Features.StopAutoFruit(); Features.StartAutoChest() else Features.StopAutoChest() end
end)
BindToggle("AutoFruit",fs,"Auto Fruit","Exclusive movement target",function(v)
    if v then SetToggle("AutoChest",false); Features.StopAutoChest(); Features.StartAutoFruit() else Features.StopAutoFruit() end
end)
Slider(fs,"Movement Speed",25,600,Config.TweenSpeed,function(v) Config.TweenSpeed=v end,5)
local ff=Section(Farm,"Current Target")
local targetLabel=Label(ff,"Target: None","")
LoopManager:Start("TargetStatus",1,function()
    local c=FindNearestChest(); local f=FindNearestFruit()
    targetLabel:Set("Chest: "..tostring(c and c.Name or "None").." | Fruit: "..tostring(f and f.Name or "None"))
end, true)

-- ESP
local es=Section(ESPTab,"ESP")
BindToggle("ESPPlayer",es,"Player ESP","Tên + HP",function(v) if v then ESP.Enable("Player") else ESP.Clear("Player",false) end end)
BindToggle("ESPChest",es,"Chest ESP","Rương",function(v) if v then ESP.Enable("Chest") else ESP.Clear("Chest",false) end end)
BindToggle("ESPFruit",es,"Fruit ESP","Trái rơi",function(v) if v then ESP.Enable("Fruit") else ESP.Clear("Fruit",false) end end)
BindToggle("ESPIsland",es,"Island ESP","Tên địa điểm",function(v) if v then ESP.Enable("Island") else ESP.Clear("Island",false) end end)
Button(es,"Clear All ESP",function()
    ESP.Clear(nil,true)
    Notify("ESP","Đã xóa ESP; bật lại toggle hoặc Refresh ESP để tạo lại.")
end)

-- Travel
local ts=Section(Travel,"Island Teleport")
Dropdown(ts,"Island","",function() local names={}; for n in pairs(GetIslandMap()) do table.insert(names,n) end; table.sort(names); return names end,function(v) Config.SelectedIsland=v end)
Button(ts,"Teleport To Island",function()
    local pos=GetIslandMap()[Config.SelectedIsland]
    if not pos then Notify("Travel","Chưa chọn island hợp lệ."); return end
    Resources:AddTask(task.spawn(function()
        local ok=Movement:MoveTo(CFrame.new(pos+Vector3.new(0,5,0)),"Travel",30,false)
        if ok then Notify("Travel","Đã tới "..Config.SelectedIsland..".") else Notify("Travel","Teleport bị hủy hoặc nhân vật chưa sẵn sàng.") end
    end),"Travel")
end)
local tp=Section(Travel,"Player Teleport")
local playerDrop=Dropdown(tp,"Player","",GetPlayers,function(v) Config.SelectedPlayer=v end)
Resources:AddConnection(Players.PlayerRemoving:Connect(function(p)
    if Config.SelectedPlayer == p.Name then
        Config.SelectedPlayer = ""
        if playerDrop then playerDrop.Set("") end
    end
end))

Button(tp,"Refresh Player List",function()
    local options = playerDrop.Refresh()
    local valid = false
    for _, name in ipairs(options or {}) do if name == Config.SelectedPlayer then valid = true break end end
    if not valid then Config.SelectedPlayer = ""; playerDrop.Set("") end
    Notify("Travel","Player list đã được cập nhật.")
end)
Button(tp,"Teleport To Player",function()
    local p=Players:FindFirstChild(Config.SelectedPlayer)
    local root=p and p.Character and FindRoot(p.Character)
    if not root then Notify("Travel","Player không còn tồn tại hoặc chưa spawn."); return end
    Resources:AddTask(task.spawn(function()
        Movement:MoveTo(root.CFrame+Vector3.new(0,3,0),"Travel",30,false)
    end),"Travel")
end)

-- Player
local ps=Section(PlayerTab,"Movement")
BindToggle("WalkSpeedEnabled",ps,"Enable WalkSpeed","Áp dụng tốc độ tùy chỉnh",function() Features.ApplyMovement() end)
Slider(ps,"WalkSpeed",16,150,Config.WalkSpeed,function(v) Config.WalkSpeed=v; if Config.WalkSpeedEnabled then Features.ApplyMovement() end end,1)
BindToggle("JumpPowerEnabled",ps,"Enable JumpPower","Áp dụng lực nhảy tùy chỉnh",function() Features.ApplyMovement() end)
Slider(ps,"JumpPower",20,150,Config.JumpPower,function(v) Config.JumpPower=v; if Config.JumpPowerEnabled then Features.ApplyMovement() end end,1)
BindToggle("InfiniteZoom",ps,"Extended Zoom","Tối đa 1000 thay vì vô hạn thật",function() ApplyZoom() end)

-- Misc
local ms=Section(Misc,"Visual / Performance")
BindToggle("RemoveFog",ms,"Remove Fog","Xóa sương",function() ApplyFog() end)
BindToggle("FullBright",ms,"Full Bright","Tăng độ sáng",function() ApplyFullBright() end)
BindToggle("FPSBoost",ms,"FPS Boost","Tối ưu BasePart hiện tại",function(v) ApplyFPSBoost(); Notify("Performance",v and "Đã tối ưu material hiện tại." or "Đã khôi phục material đã lưu.") end)
BindToggle("AntiAFK",ms,"Anti AFK","Chống idle kick",function(v) if v then StartAntiAFK() else StopAntiAFK() end end)
local wh=Section(Misc,"Webhook")
Toggle(wh,"Enable Webhook",Config.WebhookEnabled,function(v) Config.WebhookEnabled=v end,"Chỉ gửi khi URL hợp lệ và executor có request API")
Textbox(wh,"Discord Webhook URL",Config.WebhookURL,function(v) Config.WebhookURL=v end)
Button(wh,"Send Test Webhook",function()
    if SendWebhook("Dungdx Test","Webhook của Blox Community VN đang hoạt động.") then Notify("Webhook","Đã gửi test.") else Notify("Webhook","Không gửi được: kiểm tra URL/request API.") end
end)
Button(wh,"Open Discord Link (copy)",function()
    if setclipboard then pcall(setclipboard,"https://discord.gg/AJBT8F79yf"); Notify("Discord","Đã copy invite link.") else Notify("Discord","Link: discord.gg/AJBT8F79yf") end
end)

-- Settings
local ss=Section(Settings,"System")
Button(ss,"Stop All Automation",function()
    StopAutomation()
    Notify("System","Đã dừng toàn bộ automation movement, ESP và Anti AFK.")
end)
Button(ss,"Restore Visual Settings",function()
    SetToggle("RemoveFog",false)
    SetToggle("FullBright",false)
    SetToggle("FPSBoost",false)
    SetToggle("InfiniteZoom",false)
    ApplyFog()
    ApplyFullBright()
    ApplyFPSBoost()
    ApplyZoom()
    Notify("System","Đã khôi phục visual/performance.")
end)
Button(ss,"Unload Dungdx",function()
    if State.Unloaded then return end
    State.Unloaded=true
    Config.AutoChest=false; Config.AutoFruit=false
    Config.ESPPlayer=false; Config.ESPChest=false; Config.ESPFruit=false; Config.ESPIsland=false
    Config.AntiAFK=false
    Config.WalkSpeedEnabled=false; Config.JumpPowerEnabled=false
    Config.InfiniteZoom=false; Config.RemoveFog=false; Config.FullBright=false; Config.FPSBoost=false
    LoopManager:StopAll(true)
    Movement:Stop()
    Features.RestoreMovement()
    ESP.Clear(nil,false)
    ApplyFog(); ApplyFullBright(); ApplyZoom(); ApplyFPSBoost()
    Resources:Cleanup()
    GEN.BCVN_DX_COMPLETE_LOADED=nil
    GEN.BCVN_Config=nil
end)
Label(ss,"Architecture","Config → State → Resources → LoopManager → Movement → Features → UI → Unload")
Label(ss,"Scope","Utility / ESP / Travel / Performance. Không tự động đánh hoặc dùng weapon.")

-- Default tab
TabButtons.Home.BackgroundColor3=Theme.Accent
TabButtons.Home.TextColor3=Color3.new(1,1,1)
Tabs.Home.Visible=true
ActiveTab="Home"

-- Lightweight settings enforcement while enabled
LoopManager:Start("MovementSettings",1,function()
    if Config.WalkSpeedEnabled or Config.JumpPowerEnabled then Features.ApplyMovement() end
    if Config.InfiniteZoom then ApplyZoom() end
end, true)

Debug.Stage("READY")
Notify("Blox Community VN","Dungdx Debug đã khởi động. Giữ bảng debug để kiểm tra.",5)
print("[BCVN] Dungdx Complete Utility DEBUG loaded successfully.")

end

local __ok, __err = xpcall(__BCVN_MAIN, function(err)
    local trace = tostring(err)
    pcall(function()
        if type(debug) == "table" and type(debug.traceback) == "function" then
            trace = debug.traceback(trace, 2)
        end
    end)
    return trace
end)

if not __ok then
    Debug.Error(__err)
    GEN.BCVN_DX_COMPLETE_LOADED = nil
    pcall(warn, "[BCVN DEBUG] Script stopped during initialization. Send the Debug panel/console error to continue.")
else
    Debug.Stage("EXECUTION FINISHED")
end
