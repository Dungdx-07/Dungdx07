--[[
    BLOX FRUIT PVP - Dungdx Edition
    Discord: https://discord.gg/AJBT8F79yf
    Chỉ dùng cho PvP. Không farm, không auto quest.
]]--

--===== SERVICES =====
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local VirtualUser       = game:GetService("VirtualUser")
local VirtualInput      = game:GetService("VirtualInputManager")
local StarterGui        = game:GetService("StarterGui")
local LocalPlayer       = Players.LocalPlayer

--===== CONFIG =====
local Config = {
    -- ESP
    ESP_Enabled      = true,
    ESP_TeamCheck    = true,
    ESP_ShowHealth   = true,
    ESP_ShowName     = true,
    ESP_ShowDistance = true,
    ESP_MaxDistance  = 3000,

    -- Aimbot
    Aimbot_Enabled   = false,
    Aimbot_TeamCheck = true,
    Aimbot_Smooth    = 0.15,      -- 0 = lock cứng, 1 = mượt
    Aimbot_FOV       = 400,
    Aimbot_Part      = "Head",    -- Head / HumanoidRootPart / UpperTorso
    Aimbot_Key       = Enum.KeyCode.E,
    Aimbot_Visible   = false,     -- chỉ lock khi nhìn thấy

    -- Auto Combo
    Combo_Enabled    = false,
    Combo_Keys       = {"Z", "X", "C", "V"},
    Combo_Delay      = 0.12,
    Combo_Range      = 30,

    -- Auto Attack (M1)
    Attack_Enabled   = false,
    Attack_Range     = 25,

    -- Misc
    Show_HUD         = true,
    Bring_Monster    = false,     -- gom mob về gần
}

--===== HELPER =====
local function isAlly(plr)
    if plr == LocalPlayer then return true end
    if not Config.Aimbot_TeamCheck then return false end
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
    -- Bounty / Honor check
    local myBounty = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Bounty/Honor")
    local hisBounty = plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Bounty/Honor")
    if myBounty and hisBounty and myBounty.Value == hisBounty.Value and myBounty.Value == 0 then
        return true -- cùng faction 0 bounty
    end
    return false
end

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
end

local function getHum(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isAlive(plr)
    local char = plr.Character
    local hum = getHum(char)
    return char and hum and hum.Health > 0
end

--===== UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DungdxPvP"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main panel
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 340)
Main.Position = UDim2.new(0, 20, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(120, 70, 220)
stroke.Thickness = 1.5

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DUNGDX PVP  •  Blox Fruit"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(230, 230, 240)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Floating toggle
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -24)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(120, 70, 220)
ToggleBtn.Text = "PVP"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.AutoButtonColor = false
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Tab bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 28)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main
local TabLay = Instance.new("UIListLayout", TabBar)
TabLay.FillDirection = Enum.FillDirection.Horizontal
TabLay.Padding = UDim.new(0, 6)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -90)
Content.Position = UDim2.new(0, 10, 0, 82)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Tabs = {}
local ActiveTab

local function createTab(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 3
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.Visible = false
    frame.Parent = Content
    local ll = Instance.new("UIListLayout", frame)
    ll.Padding = UDim.new(0, 6)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 10)
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(160, 160, 170)
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Frame.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
            t.Button.TextColor3 = Color3.fromRGB(160, 160, 170)
        end
        frame.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(120, 70, 220)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActiveTab = name
    end)

    Tabs[name] = { Frame = frame, Button = btn }
    return frame
end

local CombatTab = createTab("Combat")
local VisualTab = createTab("Visual")
local MiscTab   = createTab("Misc")

-- Active first tab
Tabs.Combat.Frame.Visible = true
Tabs.Combat.Button.BackgroundColor3 = Color3.fromRGB(120, 70, 220)
Tabs.Combat.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
ActiveTab = "Combat"

-- Component helpers
local function makeToggle(parent, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local pill = Instance.new("TextButton")
    pill.Size = UDim2.new(0, 44, 0, 20)
    pill.Position = UDim2.new(1, -54, 0, 5)
    pill.BackgroundColor3 = default and Color3.fromRGB(120, 70, 220) or Color3.fromRGB(55, 55, 62)
    pill.Text = ""
    pill.AutoButtonColor = false
    pill.Parent = row
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = pill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    local function paint()
        if state then
            pill.BackgroundColor3 = Color3.fromRGB(120, 70, 220)
            TweenService:Create(knob, TweenInfo.new(0.12), {Position = UDim2.new(1, -18, 0, 2)}):Play()
        else
            pill.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
            TweenService:Create(knob, TweenInfo.new(0.12), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        end
    end
    pill.MouseButton1Click:Connect(function()
        state = not state
        paint()
        if callback then pcall(callback, state) end
    end)
    return { Set = function(_, v) state = v; paint(); if callback then pcall(callback, v) end end }
end

local function makeSlider(parent, text, min, max, default, step, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 0, 16)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.3, 0, 0, 16)
    val.Position = UDim2.new(0.7, -12, 0, 4)
    val.BackgroundTransparency = 1
    val.Text = tostring(default)
    val.Font = Enum.Font.GothamBold
    val.TextColor3 = Color3.fromRGB(160, 120, 255)
    val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 4)
    track.Position = UDim2.new(0, 12, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(120, 70, 220)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local cur = default
    local function setV(v, fire)
        v = math.clamp(v, min, max)
        if step and step > 0 then v = math.floor((v - min) / step + 0.5) * step + min end
        cur = v
        local alpha = (max - min) == 0 and 0 or (v - min) / (max - min)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        val.Text = tostring(math.floor(v * 100 + 0.5) / 100)
        if fire and callback then pcall(callback, v) end
    end
    setV(default, false)

    local dragging = false
    local function upd(input)
        local x = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local alpha = track.AbsoluteSize.X == 0 and 0 or x / track.AbsoluteSize.X
        setV(min + (max - min) * alpha, true)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; upd(i)
        end
    end)
    track.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    return { Get = function() return cur end, Set = function(_, v) setV(v, false) end }
end

local function makeDropdown(parent, text, default, options, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -24, 1, -8)
    btn.Position = UDim2.new(0.5, 12, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.Text = tostring(default)
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(230, 230, 240)
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local cur = default
    local idx = 1
    for i, v in ipairs(options) do if v == default then idx = i break end end
    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        cur = options[idx]
        btn.Text = tostring(cur)
        if callback then pcall(callback, cur) end
    end)
    return { Get = function() return cur end, Set = function(_, v) cur = v; btn.Text = tostring(v); if callback then pcall(callback, v) end end }
end

--===== ESP =====
local espCache = {}

local function clearESP()
    for plr, obj in pairs(espCache) do
        pcall(function() obj:Destroy() end)
    end
    espCache = {}
end

local function createESP(plr)
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "DungdxESP"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 220, 0, 46)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = Config.ESP_MaxDistance
    bb.Parent = head

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = bb

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0, 16)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 12
    nameLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    nameLbl.TextStrokeTransparency = 0.4
    nameLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLbl.Text = ""
    nameLbl.Parent = container

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1, 0, 0, 12)
    distLbl.Position = UDim2.new(0, 0, 0, 16)
    distLbl.BackgroundTransparency = 1
    distLbl.Font = Enum.Font.Gotham
    distLbl.TextSize = 10
    distLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    distLbl.TextStrokeTransparency = 0.4
    distLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    distLbl.Text = ""
    distLbl.Parent = container

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1, 0, 0, 4)
    hpBg.Position = UDim2.new(0, 0, 0, 30)
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = container
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

    espCache[plr] = bb

    task.spawn(function()
        while bb.Parent and plr.Parent and Config.ESP_Enabled do
            pcall(function()
                if isAlly(plr) and Config.ESP_TeamCheck then
                    bb.Enabled = false
                else
                    bb.Enabled = true
                    local c = plr.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local hisRoot = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
                    if h and myRoot and hisRoot then
                        local dist = (myRoot.Position - hisRoot.Position).Magnitude
                        nameLbl.Text = Config.ESP_ShowName and plr.Name or ""
                        distLbl.Text = Config.ESP_ShowDistance and string.format("[%d studs]", math.floor(dist)) or ""
                        if Config.ESP_ShowHealth then
                            hpFill.Size = UDim2.new(math.clamp(h.Health / h.MaxHealth, 0, 1), 0, 1, 0)
                            hpBg.Visible = true
                        else
                            hpBg.Visible = false
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function refreshESP()
    clearESP()
    if not Config.ESP_Enabled then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            createESP(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(0.5)
                if Config.ESP_Enabled then createESP(plr) end
            end)
        end
    end
end

--===== AIMBOT =====
local aimTarget = nil
local camera = workspace.CurrentCamera

local function getClosestPlayer()
    local closest = nil
    local closestDist = Config.Aimbot_FOV
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) and not isAlly(plr) then
            local char = plr.Character
            local part = char:FindFirstChild(Config.Aimbot_Part) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
            if part then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                    if dist < closestDist then
                        if Config.Aimbot_Visible then
                            local ray = Ray.new(myRoot.Position, (part.Position - myRoot.Position).Unit * (part.Position - myRoot.Position).Magnitude)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {myChar, char})
                            if hit and not hit:IsDescendantOf(char) then
                                continue
                            end
                        end
                        closestDist = dist
                        closest = { Player = plr, Part = part }
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function(dt)
    if not Config.Aimbot_Enabled then aimTarget = nil return end
    if not UserInputService:IsKeyDown(Config.Aimbot_Key) then aimTarget = nil return end

    local closest = getClosestPlayer()
    if closest then
        aimTarget = closest
        local goal = CFrame.new(camera.CFrame.Position, closest.Part.Position)
        camera.CFrame = Config.Aimbot_Smooth > 0 and camera.CFrame:Lerp(goal, 1 - Config.Aimbot_Smooth) or goal
    end
end)

--===== AUTO COMBO =====
local function fireKeys(keys)
    for _, k in ipairs(keys) do
        local keyCode = Enum.KeyCode[k]
        if keyCode then
            VirtualInput:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.02)
            VirtualInput:SendKeyEvent(false, keyCode, false, game)
            task.wait(Config.Combo_Delay)
        end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if not Config.Combo_Enabled then continue end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        -- Tìm địch gần nhất trong range
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) and not isAlly(plr) then
                local hisChar = plr.Character
                local hisRoot = hisChar and hisChar:FindFirstChild("HumanoidRootPart")
                if hisRoot then
                    local dist = (myRoot.Position - hisRoot.Position).Magnitude
                    if dist <= Config.Combo_Range then
                        -- Face target
                        myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(hisRoot.Position.X, myRoot.Position.Y, hisRoot.Position.Z))
                        -- Fire skills
                        fireKeys(Config.Combo_Keys)
                        break
                    end
                end
            end
        end
    end
end)

--===== AUTO ATTACK (M1) =====
task.spawn(function()
    while task.wait(0.08) do
        if not Config.Attack_Enabled then continue end
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local tool = myChar and myChar:FindFirstChildOfClass("Tool")
        if not myRoot or not tool then continue end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) and not isAlly(plr) then
                local hisChar = plr.Character
                local hisRoot = hisChar and hisChar:FindFirstChild("HumanoidRootPart")
                if hisRoot and (myRoot.Position - hisRoot.Position).Magnitude <= Config.Attack_Range then
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(hisRoot.Position.X, myRoot.Position.Y, hisRoot.Position.Z))
                    pcall(function()
                        VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.02)
                        VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end)
                    break
                end
            end
        end
    end
end)

--===== ANTI AFK =====
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

--===== HUD =====
local hud = Instance.new("TextLabel")
hud.Size = UDim2.new(0, 300, 0, 20)
hud.Position = UDim2.new(0, 20, 0, 20)
hud.BackgroundTransparency = 1
hud.Font = Enum.Font.Code
hud.TextSize = 12
hud.TextColor3 = Color3.fromRGB(120, 220, 120)
hud.TextStrokeTransparency = 0.5
hud.TextXAlignment = Enum.TextXAlignment.Left
hud.Parent = ScreenGui

RunService.RenderStepped:Connect(function()
    if not Config.Show_HUD then hud.Visible = false return end
    hud.Visible = true
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local count = 0
    if myRoot then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and isAlive(plr) and not isAlly(plr) then
                local hisChar = plr.Character
                local hisRoot = hisChar and hisChar:FindFirstChild("HumanoidRootPart")
                if hisRoot and (myRoot.Position - hisRoot.Position).Magnitude <= Config.ESP_MaxDistance then
                    count = count + 1
                end
            end
        end
    end
    hud.Text = string.format("DUNGDX PVP | Aimbot:%s | Combo:%s | Attack:%s | Enemies:%d",
        Config.Aimbot_Enabled and "ON" or "OFF",
        Config.Combo_Enabled and "ON" or "OFF",
        Config.Attack_Enabled and "ON" or "OFF",
        count)
end)

--===== BUILD UI =====
-- Combat tab
makeToggle(CombatTab, "Aimbot (giữ E để lock)", Config.Aimbot_Enabled, function(v) Config.Aimbot_Enabled = v end)
makeToggle(CombatTab, "Aimbot Team Check", Config.Aimbot_TeamCheck, function(v) Config.Aimbot_TeamCheck = v end)
makeToggle(CombatTab, "Aimbot Visible Check", Config.Aimbot_Visible, function(v) Config.Aimbot_Visible = v end)
makeSlider(CombatTab, "Aimbot Smooth", 0, 1, Config.Aimbot_Smooth, 0.01, function(v) Config.Aimbot_Smooth = v end)
makeSlider(CombatTab, "Aimbot FOV", 50, 1000, Config.Aimbot_FOV, 10, function(v) Config.Aimbot_FOV = v end)
makeDropdown(CombatTab, "Aimbot Part", Config.Aimbot_Part, {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, function(v) Config.Aimbot_Part = v end)
makeToggle(CombatTab, "Auto Combo (Z X C V)", Config.Combo_Enabled, function(v) Config.Combo_Enabled = v end)
makeSlider(CombatTab, "Combo Range", 10, 60, Config.Combo_Range, 1, function(v) Config.Combo_Range = v end)
makeSlider(CombatTab, "Combo Delay", 0.05, 0.5, Config.Combo_Delay, 0.01, function(v) Config.Combo_Delay = v end)
makeToggle(CombatTab, "Auto M1 (Click)", Config.Attack_Enabled, function(v) Config.Attack_Enabled = v end)
makeSlider(CombatTab, "M1 Range", 10, 40, Config.Attack_Range, 1, function(v) Config.Attack_Range = v end)

-- Visual tab
makeToggle(VisualTab, "ESP Player", Config.ESP_Enabled, function(v)
    Config.ESP_Enabled = v
    refreshESP()
end)
makeToggle(VisualTab, "ESP Team Check", Config.ESP_TeamCheck, function(v) Config.ESP_TeamCheck = v end)
makeToggle(VisualTab, "ESP Hiện Tên", Config.ESP_ShowName, function(v) Config.ESP_ShowName = v end)
makeToggle(VisualTab, "ESP Hiện Khoảng Cách", Config.ESP_ShowDistance, function(v) Config.ESP_ShowDistance = v end)
makeToggle(VisualTab, "ESP Hiện Máu", Config.ESP_ShowHealth, function(v) Config.ESP_ShowHealth = v end)
makeSlider(VisualTab, "ESP Max Distance", 500, 10000, Config.ESP_MaxDistance, 100, function(v)
    Config.ESP_MaxDistance = v
    for _, bb in pairs(espCache) do pcall(function() bb.MaxDistance = v end) end
end)

-- Misc tab
makeToggle(MiscTab, "Hiện HUD", Config.Show_HUD, function(v) Config.Show_HUD = v end)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, 0, 0, 32)
resetBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
resetBtn.Text = "Tắt Tất Cả Chức Năng"
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 12
resetBtn.AutoButtonColor = false
resetBtn.Parent = MiscTab
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
resetBtn.MouseButton1Click:Connect(function()
    Config.Aimbot_Enabled = false
    Config.Combo_Enabled = false
    Config.Attack_Enabled = false
    Config.ESP_Enabled = false
    clearESP()
    -- rebuild UI state bằng cách reset lại toàn bộ -- đơn giản chỉ notify
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Dungdx PVP";
            Text = "Đã tắt toàn bộ chức năng PvP.";
            Duration = 3;
        })
    end)
end)

--===== INIT =====
refreshESP()

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer and Config.ESP_Enabled then
        task.wait(1)
        createESP(plr)
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    if espCache[plr] then
        pcall(function() espCache[plr]:Destroy() end)
        espCache[plr] = nil
    end
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Dungdx PVP đã load";
        Text = "Nhấn nút PVP để mở/đóng. Discord: AJBT8F79yf";
        Duration = 6;
    })
end)

print("[Dungdx PVP] Loaded successfully.")