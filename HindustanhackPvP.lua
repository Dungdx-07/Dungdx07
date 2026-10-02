-- Hindustanhack - Blox Fruits PvP Utility HUD
-- Client-side utility/training interface.
-- RightShift: show/hide UI
-- Q: cooldown visualizer demo
-- Drag header to move; drag bottom-right handle to resize.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("HindustanhackPvP")
if old then old:Destroy() end

local Config = {
    UIVisible = true,
    UIScale = 1,
    WalkSpeed = 16,
    JumpPower = 50,
    CooldownTracker = true,
    FPSCounter = true,
    PingCounter = true,
}

local function Create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function Round(object, radius)
    Create("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
end

local function Stroke(object, thickness, transparency)
    Create("UIStroke", {
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, object)
end

local function Padding(object, amount)
    Create("UIPadding", {
        PaddingTop = UDim.new(0, amount),
        PaddingBottom = UDim.new(0, amount),
        PaddingLeft = UDim.new(0, amount),
        PaddingRight = UDim.new(0, amount)
    }, object)
end

local ScreenGui = Create("ScreenGui", {
    Name = "HindustanhackPvP",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local Root = Create("Frame", {
    Name = "Root",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1)
}, ScreenGui)

local UIScale = Create("UIScale", {Scale = Config.UIScale}, Root)

local Window = Create("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(410, 500),
    BackgroundColor3 = Color3.fromRGB(18, 18, 24)
}, Root)
Round(Window, 14)
Stroke(Window, 1.5, 0.35)

local Header = Create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 55),
    BackgroundColor3 = Color3.fromRGB(25, 25, 34)
}, Window)
Round(Header, 14)

Create("Frame", {
    Position = UDim2.new(0, 0, 1, -14),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundColor3 = Color3.fromRGB(25, 25, 34),
    BorderSizePixel = 0
}, Header)

Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 7),
    Size = UDim2.new(1, -115, 0, 25),
    Font = Enum.Font.GothamBold,
    Text = "HINDUSTANHACK",
    TextSize = 18,
    TextColor3 = Color3.fromRGB(245, 245, 255),
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 31),
    Size = UDim2.new(1, -115, 0, 16),
    Font = Enum.Font.Gotham,
    Text = "PVP UTILITY",
    TextSize = 10,
    TextColor3 = Color3.fromRGB(145, 145, 170),
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local MinimizeButton = Create("TextButton", {
    Name = "Minimize",
    Position = UDim2.new(1, -90, 0, 12),
    Size = UDim2.fromOffset(32, 30),
    BackgroundColor3 = Color3.fromRGB(40, 40, 52),
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "—",
    TextSize = 18,
    TextColor3 = Color3.fromRGB(235, 235, 245)
}, Header)
Round(MinimizeButton, 8)

local CloseButton = Create("TextButton", {
    Name = "Close",
    Position = UDim2.new(1, -50, 0, 12),
    Size = UDim2.fromOffset(32, 30),
    BackgroundColor3 = Color3.fromRGB(65, 35, 42),
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "×",
    TextSize = 19,
    TextColor3 = Color3.fromRGB(255, 205, 210)
}, Header)
Round(CloseButton, 8)

local Content = Create("ScrollingFrame", {
    Name = "Content",
    Position = UDim2.fromOffset(10, 65),
    Size = UDim2.new(1, -20, 1, -75),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageTransparency = 0.35
}, Window)

local ContentLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
}, Content)
Padding(Content, 4)

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 15)
end)

local StatusCard = Create("Frame", {
    Size = UDim2.new(1, -8, 0, 85),
    BackgroundColor3 = Color3.fromRGB(24, 24, 32)
}, Content)
Round(StatusCard, 11)
Stroke(StatusCard, 1, 0.55)

Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 8),
    Size = UDim2.new(1, -26, 0, 18),
    Font = Enum.Font.GothamBold,
    Text = "STATUS",
    TextSize = 11,
    TextColor3 = Color3.fromRGB(135, 135, 160),
    TextXAlignment = Enum.TextXAlignment.Left
}, StatusCard)

local FPSLabel = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 31),
    Size = UDim2.new(0.5, -13, 0, 22),
    Font = Enum.Font.GothamMedium,
    Text = "FPS: --",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(230, 230, 240),
    TextXAlignment = Enum.TextXAlignment.Left
}, StatusCard)

local PingLabel = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0, 31),
    Size = UDim2.new(0.5, -13, 0, 22),
    Font = Enum.Font.GothamMedium,
    Text = "Ping: --",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(230, 230, 240),
    TextXAlignment = Enum.TextXAlignment.Right
}, StatusCard)

local StateLabel = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 13, 1, -27),
    Size = UDim2.new(1, -26, 0, 18),
    Font = Enum.Font.Gotham,
    Text = "READY",
    TextSize = 10,
    TextColor3 = Color3.fromRGB(130, 205, 160),
    TextXAlignment = Enum.TextXAlignment.Left
}, StatusCard)

local function Section(title)
    return Create("TextLabel", {
        LayoutOrder = 1,
        Size = UDim2.new(1, -8, 0, 25),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(145, 145, 175),
        TextXAlignment = Enum.TextXAlignment.Left
    }, Content)
end

local function Toggle(name, description, defaultValue, callback)
    local Holder = Create("Frame", {
        LayoutOrder = 2,
        Size = UDim2.new(1, -8, 0, 58),
        BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    }, Content)
    Round(Holder, 10)
    Stroke(Holder, 1, 0.6)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(1, -75, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = name,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(235, 235, 245),
        TextXAlignment = Enum.TextXAlignment.Left
    }, Holder)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 29),
        Size = UDim2.new(1, -75, 0, 17),
        Font = Enum.Font.Gotham,
        Text = description,
        TextSize = 9,
        TextColor3 = Color3.fromRGB(120, 120, 145),
        TextXAlignment = Enum.TextXAlignment.Left
    }, Holder)

    local Button = Create("TextButton", {
        Position = UDim2.new(1, -58, 0.5, -14),
        Size = UDim2.fromOffset(45, 28),
        BackgroundColor3 = defaultValue and Color3.fromRGB(80, 155, 105) or Color3.fromRGB(55, 55, 68),
        AutoButtonColor = false,
        Text = ""
    }, Holder)
    Round(Button, 14)

    local Knob = Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = defaultValue and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    }, Button)
    Round(Knob, 10)

    local enabled = defaultValue
    local function update(value)
        enabled = value
        Button.BackgroundColor3 = enabled and Color3.fromRGB(80, 155, 105) or Color3.fromRGB(55, 55, 68)
        Knob.Position = enabled and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)
        callback(enabled)
    end

    Button.Activated:Connect(function()
        update(not enabled)
    end)

    return {Set = update, Get = function() return enabled end}
end

Section("PLAYER PRACTICE")

local function makeSlider(parent, title, minValue, maxValue, initial, valueColor)
    local Box = Create("Frame", {
        LayoutOrder = 2,
        Size = UDim2.new(1, -8, 0, 75),
        BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    }, parent)
    Round(Box, 10)
    Stroke(Box, 1, 0.6)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(0.5, 0, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(235, 235, 245),
        TextXAlignment = Enum.TextXAlignment.Left
    }, Box)

    local Value = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, 8),
        Size = UDim2.new(0.5, -13, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = tostring(initial),
        TextSize = 13,
        TextColor3 = valueColor,
        TextXAlignment = Enum.TextXAlignment.Right
    }, Box)

    local Slider = Create("TextButton", {
        Position = UDim2.fromOffset(13, 42),
        Size = UDim2.new(1, -26, 0, 7),
        BackgroundColor3 = Color3.fromRGB(52, 52, 66),
        AutoButtonColor = false,
        Text = ""
    }, Box)
    Round(Slider, 4)

    local Fill = Create("Frame", {
        Size = UDim2.new((initial-minValue)/(maxValue-minValue), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(105, 140, 230)
    }, Slider)
    Round(Fill, 4)

    local function setFromX(x)
        local ratio = math.clamp((x - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
        local value = math.floor(minValue + ratio * (maxValue-minValue) + 0.5)
        Value.Text = tostring(value)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        return value
    end

    Slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local value = setFromX(input.Position.X)
            if title == "WalkSpeed" then
                Config.WalkSpeed = value
            else
                Config.JumpPower = value
            end
        end
    end)

    return Box
end

makeSlider(Content, "WalkSpeed", 8, 48, Config.WalkSpeed, Color3.fromRGB(160, 200, 255))
makeSlider(Content, "JumpPower", 35, 135, Config.JumpPower, Color3.fromRGB(160, 200, 255))

Section("PVP UTILITY")

Toggle("FPS Counter", "Display current client frame rate", true, function(value)
    Config.FPSCounter = value
    FPSLabel.Visible = value
end)

Toggle("Ping Counter", "Display current network latency", true, function(value)
    Config.PingCounter = value
    PingLabel.Visible = value
end)

Toggle("Cooldown Tracker", "Show local ability cooldown timing", true, function(value)
    Config.CooldownTracker = value
end)

local CooldownCard = Create("Frame", {
    LayoutOrder = 2,
    Size = UDim2.new(1, -8, 0, 95),
    BackgroundColor3 = Color3.fromRGB(24, 24, 32)
}, Content)
Round(CooldownCard, 10)
Stroke(CooldownCard, 1, 0.6)

Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 9),
    Size = UDim2.new(1, -26, 0, 18),
    Font = Enum.Font.GothamBold,
    Text = "ABILITY TIMER",
    TextSize = 11,
    TextColor3 = Color3.fromRGB(145, 145, 170),
    TextXAlignment = Enum.TextXAlignment.Left
}, CooldownCard)

local CooldownText = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(13, 34),
    Size = UDim2.new(1, -26, 0, 25),
    Font = Enum.Font.GothamBold,
    Text = "READY",
    TextSize = 17,
    TextColor3 = Color3.fromRGB(130, 205, 160),
    TextXAlignment = Enum.TextXAlignment.Left
}, CooldownCard)

local CooldownBar = Create("Frame", {
    Position = UDim2.new(0, 13, 1, -20),
    Size = UDim2.new(1, -26, 0, 6),
    BackgroundColor3 = Color3.fromRGB(48, 48, 62)
}, CooldownCard)
Round(CooldownBar, 4)

local CooldownFill = Create("Frame", {
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = Color3.fromRGB(110, 145, 230)
}, CooldownBar)
Round(CooldownFill, 4)

local dragging, dragStart, startPosition = false, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    Window.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
end)

local ResizeHandle = Create("TextButton", {
    Name = "ResizeHandle",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.fromScale(1, 1),
    Size = UDim2.fromOffset(24, 24),
    BackgroundTransparency = 1,
    AutoButtonColor = false,
    Text = "◢",
    TextSize = 15,
    TextColor3 = Color3.fromRGB(110, 110, 130)
}, Window)

local resizing, resizeStart, startSize = false, nil, nil
ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        startSize = Window.AbsoluteSize
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then resizing = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not resizing then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - resizeStart
    Window.Size = UDim2.fromOffset(math.clamp(startSize.X + delta.X, 300, 650), math.clamp(startSize.Y + delta.Y, 300, 760))
end)

local minimized = false
local savedSize = Window.Size
MinimizeButton.Activated:Connect(function()
    minimized = not minimized
    if minimized then
        savedSize = Window.Size
        Window.Size = UDim2.fromOffset(savedSize.X.Offset, 55)
        Content.Visible = false
        ResizeHandle.Visible = false
    else
        Window.Size = savedSize
        Content.Visible = true
        ResizeHandle.Visible = true
    end
end)

CloseButton.Activated:Connect(function()
    ScreenGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Config.UIVisible = not Config.UIVisible
        Window.Visible = Config.UIVisible
    end
end)

local function ApplyCharacterSettings(character)
    local humanoid = character:WaitForChild("Humanoid", 8)
    if not humanoid then return end
    humanoid.WalkSpeed = Config.WalkSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = Config.JumpPower
end

if LocalPlayer.Character then task.spawn(ApplyCharacterSettings, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.2)
    ApplyCharacterSettings(character)
end)

local frames, elapsed, fps = 0, 0, 60
RunService.RenderStepped:Connect(function(dt)
    frames += 1
    elapsed += dt
    if elapsed >= 0.5 then
        fps = math.floor(frames / elapsed + 0.5)
        frames, elapsed = 0, 0
        if Config.FPSCounter then FPSLabel.Text = "FPS: " .. tostring(fps) end
        if Config.PingCounter then
            local ping = 0
            pcall(function()
                ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            PingLabel.Text = "Ping: " .. tostring(math.floor(ping + 0.5)) .. " ms"
        end
    end
end)

local cooldownLength = 2.5
local cooldownStart = 0

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Q then cooldownStart = os.clock() end
end)

RunService.RenderStepped:Connect(function()
    if not Config.CooldownTracker then
        CooldownText.Text = "DISABLED"
        CooldownFill.Size = UDim2.fromScale(0, 1)
        return
    end

    if cooldownStart <= 0 then
        CooldownText.Text = "READY"
        CooldownText.TextColor3 = Color3.fromRGB(130, 205, 160)
        CooldownFill.Size = UDim2.fromScale(0, 1)
        return
    end

    local passed = os.clock() - cooldownStart
    local remaining = math.max(cooldownLength - passed, 0)
    CooldownFill.Size = UDim2.new(math.clamp(passed / cooldownLength, 0, 1), 0, 1, 0)

    if remaining <= 0 then
        CooldownText.Text = "READY"
        CooldownText.TextColor3 = Color3.fromRGB(130, 205, 160)
        cooldownStart = 0
    else
        CooldownText.Text = string.format("COOLDOWN %.1fs", remaining)
        CooldownText.TextColor3 = Color3.fromRGB(235, 190, 120)
    end
end)

StateLabel.Text = "RIGHT SHIFT • SHOW / HIDE"
StateLabel.TextColor3 = Color3.fromRGB(135, 150, 190)

print("[Hindustanhack] PvP Utility HUD loaded.")
