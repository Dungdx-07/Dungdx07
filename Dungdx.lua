--[[
    Blox Community VN - UI Redesign (Dark Minimalist)
    Author: Dungdx | Discord: discord.gg/Hwwa3VYxW6
    Style: Dark Mode, Clean, Modern (Based on user's reference image)
--]]

getgenv().BloxCommunityVN_Loaded = nil
print("[BCVN] Bat dau load script...")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenSvc = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VIM = game:GetService("VirtualInputManager")
local HttpSvc = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Config
local T = {
    FastAttack = true, FastAttackDelay = 0, AutoAttackGun = true,
    BringMonster = true, BringMonsterRadius = 350, PosY = 18, SelectWeapon = "Melee",
    WalkSpeed = 50, JumpPower = 50, InfiniteZoom = false, XrayVision = false,
    RemoveFog = false, LagFix = false, ESPChest = false, ESPFruit = false,
    AutoFarm = false, AutoFarmBones = false, AutoFarmBoss = false, AutoKillAllBosses = false,
    AutoChest = false, AutoFruitFarm = false, AutoStoreFruit = false, HopIfNoFruit = false,
    HopDelay = 10, AutoHop30Min = false, AntiAFK = true,
    MacroEnabled = false, MacroSkillKeys = {"Z","X","C","V","F"},
    MacroDelay = 0.3, MacroDelayBetween = 0.15,
    TweenSpeed = 250, checknearestdist = 1500,
    Webhook = "", WebhookEnabled = false,
}
getgenv().BCVN_Config = T

--============================================================
-- UI CREATION (DARK MINIMALIST THEME)
--============================================================
local UI = (function()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("BloxCommunityVN")
    if old then old:Destroy() end

    -- Theme (Trich xuat tu anh)
    local TH = {
        Bg = Color3.fromRGB(22, 23, 26),       -- Nen chinh (Dark Gray)
        Panel = Color3.fromRGB(30, 31, 35),    -- Nen panel
        Card = Color3.fromRGB(38, 39, 44),     -- Nen card/section
        Button = Color3.fromRGB(48, 49, 55),   -- Nen nut
        ButtonHover = Color3.fromRGB(60, 61, 68),
        Text = Color3.fromRGB(240, 240, 245),  -- Chu trang
        TextDim = Color3.fromRGB(150, 152, 160),-- Chu xam
        Accent = Color3.fromRGB(70, 140, 255), -- Xanh duong nhe (Active)
        Green = Color3.fromRGB(80, 200, 120),
        Red = Color3.fromRGB(220, 80, 80),
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = "BloxCommunityVN"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = pg

    -- Nut Dx Toggle
    local dxBtn = Instance.new("TextButton")
    dxBtn.Size = UDim2.fromOffset(50, 50)
    dxBtn.Position = UDim2.new(0, 20, 0.5, -25)
    dxBtn.BackgroundColor3 = TH.Panel
    dxBtn.Text = "Dx"
    dxBtn.Font = Enum.Font.GothamBold
    dxBtn.TextColor3 = TH.Text
    dxBtn.TextSize = 20
    dxBtn.AutoButtonColor = false
    dxBtn.Draggable = true
    dxBtn.Parent = gui
    Instance.new("UICorner", dxBtn).CornerRadius = UDim.new(1, 0)
    local dxStroke = Instance.new("UIStroke", dxBtn)
    dxStroke.Color = TH.Accent
    dxStroke.Thickness = 1.5

    -- Main Window
    local root = Instance.new("Frame")
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.Size = UDim2.fromOffset(580, 440)
    root.BackgroundColor3 = TH.Bg
    root.BorderSizePixel = 0
    root.Parent = gui
    Instance.new("UICorner", root).CornerRadius = UDim.new(0, 12)
    local rootStroke = Instance.new("UIStroke", root)
    rootStroke.Color = Color3.fromRGB(50, 51, 56)
    rootStroke.Thickness = 1

    -- Scale
    local scale = Instance.new("UIScale", root)
    local cam = Workspace.CurrentCamera
    local function fitScale()
        local vp = cam and cam.ViewportSize or Vector2.new(1000, 600)
        scale.Scale = math.min(math.clamp((vp.X-40)/580, 0.6, 1.1), math.clamp((vp.Y-100)/440, 0.6, 1.1))
    end
    fitScale()
    if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(fitScale) end

    -- Header (Top Bar)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 55)
    header.BackgroundColor3 = TH.Panel
    header.BorderSizePixel = 0
    header.Parent = root
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)
    local headerCover = Instance.new("Frame")
    headerCover.Size = UDim2.new(1, 0, 0, 15)
    headerCover.Position = UDim2.new(0, 0, 1, -15)
    headerCover.BackgroundColor3 = TH.Panel
    headerCover.BorderSizePixel = 0
    headerCover.Parent = header

    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(18, 10)
    title.Size = UDim2.fromOffset(200, 20)
    title.BackgroundTransparency = 1
    title.Text = "BLOX COMMUNITY"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = TH.Text
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.fromOffset(18, 30)
    subtitle.Size = UDim2.fromOffset(200, 14)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Rebuild - startup-safe"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextColor3 = TH.TextDim
    subtitle.TextSize = 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -38, 0, 14)
    closeBtn.BackgroundColor3 = TH.Button
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = TH.Text
    closeBtn.TextSize = 16
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

    -- Tab Bar
    local tabBar = Instance.new("ScrollingFrame")
    tabBar.Position = UDim2.fromOffset(10, 60)
    tabBar.Size = UDim2.new(1, -20, 0, 30)
    tabBar.BackgroundTransparency = 1
    tabBar.ScrollBarThickness = 0
    tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabBar.CanvasSize = UDim2.fromOffset(0, 0)
    tabBar.Parent = root
    local tabLay = Instance.new("UIListLayout", tabBar)
    tabLay.FillDirection = Enum.FillDirection.Horizontal
    tabLay.Padding = UDim.new(0, 6)

    -- Content Area
    local content = Instance.new("Frame")
    content.Position = UDim2.fromOffset(10, 95)
    content.Size = UDim2.new(1, -20, 1, -105)
    content.BackgroundTransparency = 1
    content.Parent = root

    -- Components
    local Tabs, ActiveTab = {}, nil
    local TabOrder = {"Home", "Farm", "Combat", "Player", "Fruit", "Chest", "Island", "Macro", "Perf", "Misc", "Webhook", "Credit"}

    local function CreateTab(name)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromScale(1, 1)
        frame.BackgroundTransparency = 1
        frame.Visible = false
        frame.Parent = content

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.fromScale(1, 1)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = TH.Button
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.fromOffset(0, 0)
        scroll.Parent = frame
        local sLay = Instance.new("UIListLayout", scroll)
        sLay.SortOrder = Enum.SortOrder.LayoutOrder
        sLay.Padding = UDim.new(0, 10)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(80, 26)
        btn.BackgroundColor3 = TH.Panel
        btn.Text = name
        btn.Font = Enum.Font.GothamSemibold
        btn.TextColor3 = TH.TextDim
        btn.TextSize = 10
        btn.AutoButtonColor = false
        btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            if ActiveTab == name then return end
            for _, tD in pairs(Tabs) do
                tD.Frame.Visible = false
                tD.Button.BackgroundColor3 = TH.Panel
                tD.Button.TextColor3 = TH.TextDim
            end
            frame.Visible = true
            btn.BackgroundColor3 = TH.Button
            btn.TextColor3 = TH.Text
            ActiveTab = name
        end)

        local tabObj = {Frame = frame, Button = btn, Scroll = scroll, _order = 0}
        function tabObj:AddSection(secName)
            self._order = self._order + 1
            local sec = Instance.new("Frame")
            sec.Size = UDim2.new(1, -4, 0, 0)
            sec.AutomaticSize = Enum.AutomaticSize.Y
            sec.BackgroundColor3 = TH.Card
            sec.BorderSizePixel = 0
            sec.LayoutOrder = self._order
            sec.Parent = scroll
            Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 10)
            local sStroke = Instance.new("UIStroke", sec)
            sStroke.Color = Color3.fromRGB(45, 46, 52)
            sStroke.Thickness = 1

            local sHead = Instance.new("TextLabel")
            sHead.Size = UDim2.new(1, 0, 0, 32)
            sHead.Position = UDim2.fromOffset(16, 0)
            sHead.BackgroundTransparency = 1
            sHead.Text = secName
            sHead.Font = Enum.Font.GothamBold
            sHead.TextColor3 = TH.Text
            sHead.TextSize = 11
            sHead.TextXAlignment = Enum.TextXAlignment.Left
            sHead.Parent = sec

            local sBody = Instance.new("Frame")
            sBody.Position = UDim2.fromOffset(12, 32)
            sBody.Size = UDim2.new(1, -24, 0, 0)
            sBody.AutomaticSize = Enum.AutomaticSize.Y
            sBody.BackgroundTransparency = 1
            sBody.Parent = sec
            local bLay = Instance.new("UIListLayout", sBody)
            bLay.SortOrder = Enum.SortOrder.LayoutOrder
            bLay.Padding = UDim.new(0, 8)
            bLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sec.Size = UDim2.new(1, -4, 0, 32 + bLay.AbsoluteContentSize.Y + 12)
            end)
            return {Frame = sBody}
        end
        Tabs[name] = tabObj
        return tabObj
    end

    for _, n in ipairs(TabOrder) do CreateTab(n) end
    Tabs.Home.Frame.Visible = true
    Tabs.Home.Button.BackgroundColor3 = TH.Button
    Tabs.Home.Button.TextColor3 = TH.Text
    ActiveTab = "Home"

    local C = {}
    function C:Label(parent, text, desc)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, desc and 30 or 18)
        f.BackgroundTransparency = 1
        f.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 16)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.Gotham
        l.TextColor3 = TH.TextDim
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        local d
        if desc then
            d = Instance.new("TextLabel")
            d.Position = UDim2.fromOffset(0, 15)
            d.Size = UDim2.new(1, 0, 0, 15)
            d.BackgroundTransparency = 1
            d.Text = desc
            d.Font = Enum.Font.Gotham
            d.TextColor3 = TH.Text
            d.TextSize = 10
            d.TextWrapped = true
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Parent = f
        end
        return {Set = function(_, t) if d then d.Text = t end end}
    end

    function C:Button(parent, text, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundColor3 = TH.Button
        b.Text = text
        b.Font = Enum.Font.GothamSemibold
        b.TextColor3 = TH.Text
        b.TextSize = 10
        b.AutoButtonColor = false
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = TH.ButtonHover end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = TH.Button end)
        b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
        return b
    end

    function C:Toggle(parent, text, default, cb, desc)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, desc and 38 or 28)
        row.BackgroundTransparency = 1
        row.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -60, 0, 14)
        l.Position = UDim2.fromOffset(0, 3)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.Gotham
        l.TextColor3 = TH.Text
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = row
        if desc then
            local d = Instance.new("TextLabel")
            d.Position = UDim2.fromOffset(0, 17)
            d.Size = UDim2.new(1, -60, 0, 18)
            d.BackgroundTransparency = 1
            d.Text = desc
            d.Font = Enum.Font.Gotham
            d.TextColor3 = TH.TextDim
            d.TextSize = 8
            d.TextWrapped = true
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Parent = row
        end
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.fromOffset(42, 20)
        pill.Position = UDim2.new(1, -46, 0, 2)
        pill.BackgroundColor3 = default and TH.Accent or Color3.fromRGB(55, 56, 62)
        pill.Text = ""
        pill.AutoButtonColor = false
        pill.Parent = row
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(16, 16)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Position = default and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
        knob.Parent = pill
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local st = default and true or false
        local function paint()
            if st then
                pill.BackgroundColor3 = TH.Accent
                TweenSvc:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0, 2)}):Play()
            else
                pill.BackgroundColor3 = Color3.fromRGB(55, 56, 62)
                TweenSvc:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(2, 2)}):Play()
            end
        end
        pill.MouseButton1Click:Connect(function()
            st = not st
            paint()
            if cb then pcall(cb, st) end
        end)
        return {Set = function(_, v) st = not not v; paint(); if cb then pcall(cb, st) end end, Get = function() return st end}
    end

    function C:Slider(parent, text, min, max, default, cb, step)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundTransparency = 1
        row.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6, 0, 0, 14)
        l.Position = UDim2.fromOffset(0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.Gotham
        l.TextColor3 = TH.Text
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = row
        local vL = Instance.new("TextLabel")
        vL.Size = UDim2.new(0.4, 0, 0, 14)
        vL.Position = UDim2.new(0.6, 0, 0, 0)
        vL.BackgroundTransparency = 1
        vL.Text = tostring(default)
        vL.Font = Enum.Font.GothamBold
        vL.TextColor3 = TH.Accent
        vL.TextSize = 10
        vL.TextXAlignment = Enum.TextXAlignment.Right
        vL.Parent = row
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -2, 0, 6)
        track.Position = UDim2.fromOffset(1, 22)
        track.BackgroundColor3 = Color3.fromRGB(55, 56, 62)
        track.BorderSizePixel = 0
        track.Parent = row
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = TH.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(14, 14)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local cur = tonumber(default) or min
        local lo, hi = tonumber(min), tonumber(max)
        local stp = tonumber(step) or 0
        local function setV(v, fire)
            v = math.clamp(v, lo, hi)
            if stp > 0 then v = math.floor((v-lo)/stp+0.5)*stp+lo end
            cur = v
            local t = (hi-lo) == 0 and 0 or (v-lo)/(hi-lo)
            fill.Size = UDim2.new(t, 0, 1, 0)
            knob.Position = UDim2.new(t, 0, 0.5, 0)
            vL.Text = tostring(v)
            if fire and cb then pcall(cb, v) end
        end
        setV(cur, false)
        local dg = false
        local function upd(i)
            local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local t = track.AbsoluteSize.X == 0 and 0 or x/track.AbsoluteSize.X
            setV(lo + (hi-lo)*t, true)
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = true; upd(i) end
        end)
        track.InputChanged:Connect(function(i)
            if dg and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = false end
        end)
        return {Set = function(_, v) setV(tonumber(v) or cur, false) end, Get = function() return cur end}
    end

    function C:Dropdown(parent, text, default, options, cb)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.4, 0, 1, 0)
        l.Position = UDim2.fromOffset(0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.Font = Enum.Font.Gotham
        l.TextColor3 = TH.Text
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = row
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.6, -4, 1, 0)
        btn.Position = UDim2.new(0.4, 0, 0, 0)
        btn.BackgroundColor3 = TH.Button
        btn.Text = tostring(default or "None")
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = TH.Text
        btn.TextSize = 10
        btn.AutoButtonColor = false
        btn.Parent = row
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local list = type(options) == "table" and options or {}
        local cur = default
        local popup
        local function closeP() if popup then popup:Destroy(); popup = nil end end
        local function openP()
            closeP()
            popup = Instance.new("Frame")
            popup.Size = UDim2.new(0, 160, 0, math.min(180, 24*#list+6))
            popup.Position = UDim2.new(1, -160, 0, 32)
            popup.BackgroundColor3 = TH.Panel
            popup.ZIndex = 100
            popup.Parent = row
            Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)
            local pStroke = Instance.new("UIStroke", popup)
            pStroke.Color = Color3.fromRGB(60, 61, 68)
            pStroke.Thickness = 1
            local sc = Instance.new("ScrollingFrame")
            sc.Size = UDim2.fromScale(1, 1)
            sc.BackgroundTransparency = 1
            sc.BorderSizePixel = 0
            sc.ScrollBarThickness = 2
            sc.ScrollBarImageColor3 = TH.Accent
            sc.ZIndex = 101
            sc.Parent = popup
            local ll = Instance.new("UIListLayout", sc)
            ll.Padding = UDim.new(0, 2)
            for _, opt in ipairs(list) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, -6, 0, 22)
                ob.Position = UDim2.fromOffset(3, 0)
                ob.BackgroundColor3 = TH.Card
                ob.Text = tostring(opt)
                ob.Font = Enum.Font.Gotham
                ob.TextColor3 = TH.Text
                ob.TextSize = 10
                ob.AutoButtonColor = false
                ob.ZIndex = 102
                ob.Parent = sc
                Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 4)
                ob.MouseEnter:Connect(function() ob.BackgroundColor3 = TH.ButtonHover end)
                ob.MouseLeave:Connect(function() ob.BackgroundColor3 = TH.Card end)
                ob.MouseButton1Click:Connect(function()
                    cur = opt
                    btn.Text = tostring(opt)
                    closeP()
                    if cb then pcall(cb, opt) end
                end)
            end
            sc.CanvasSize = UDim2.fromOffset(0, ll.AbsoluteContentSize.Y + 6)
        end
        btn.MouseButton1Click:Connect(openP)
        return {Set = function(_, v) cur = v; btn.Text = tostring(v); if cb then pcall(cb, v) end end}
    end

    function C:Textbox(parent, placeholder, cb, default)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.Parent = parent
        local box = Instance.new("TextBox")
        box.Size = UDim2.fromScale(1, 1)
        box.BackgroundColor3 = TH.Button
        box.Text = default or ""
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = TH.TextDim
        box.Font = Enum.Font.Gotham
        box.TextColor3 = TH.Text
        box.TextSize = 10
        box.ClearTextOnFocus = false
        box.Parent = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        box.FocusLost:Connect(function() if cb then pcall(cb, box.Text) end end)
        return {Set = function(_, v) box.Text = tostring(v or "") end, Get = function() return box.Text end}
    end

    -- Notification
    local notifHolder
    local function Notify(title, desc, dur)
        if not notifHolder then
            notifHolder = Instance.new("Frame")
            notifHolder.Size = UDim2.fromOffset(240, 400)
            notifHolder.Position = UDim2.new(1, -252, 0, 60)
            notifHolder.BackgroundTransparency = 1
            notifHolder.Parent = gui
            local ll = Instance.new("UIListLayout", notifHolder)
            ll.Padding = UDim.new(0, 6)
        end
        local n = Instance.new("Frame")
        n.Size = UDim2.fromOffset(240, 56)
        n.BackgroundColor3 = TH.Panel
        n.BorderSizePixel = 0
        n.Parent = notifHolder
        Instance.new("UICorner", n).CornerRadius = UDim.new(0, 8)
        local acc = Instance.new("Frame")
        acc.Size = UDim2.fromOffset(4, 56)
        acc.BackgroundColor3 = TH.Accent
        acc.BorderSizePixel = 0
        acc.Parent = n
        Instance.new("UICorner", acc).CornerRadius = UDim.new(0, 8)
        local t = Instance.new("TextLabel")
        t.Position = UDim2.fromOffset(14, 8)
        t.Size = UDim2.new(1, -20, 0, 15)
        t.BackgroundTransparency = 1
        t.Text = tostring(title or "Thông báo")
        t.Font = Enum.Font.GothamBold
        t.TextColor3 = TH.Text
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = n
        local d = Instance.new("TextLabel")
        d.Position = UDim2.fromOffset(14, 24)
        d.Size = UDim2.new(1, -20, 0, 26)
        d.BackgroundTransparency = 1
        d.Text = tostring(desc or "")
        d.Font = Enum.Font.Gotham
        d.TextColor3 = TH.TextDim
        d.TextSize = 9
        d.TextWrapped = true
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Parent = n
        task.delay(dur or 5, function() pcall(function() n:Destroy() end) end)
    end

    return {Gui = gui, Root = root, Tabs = Tabs, Components = C, Theme = TH, Notify = Notify}
end)()

local Tabs = UI.Tabs
local C = UI.Components
local TH = UI.Theme
local function Notify(t, d, dur) pcall(function() UI.Notify(t, d, dur) end) end

--============================================================
-- BACKEND LOGIC
--============================================================
task.spawn(function()
    local ok, err = pcall(function()
        local Remotes = RS:WaitForChild("Remotes", 20)
        local NetMod = RS:FindFirstChild("Modules")
        local Net = NetMod and NetMod:WaitForChild("Net", 10) or nil
        local CommF = Remotes:WaitForChild("CommF_", 10)

        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid", 10)
        local HRP = Character:WaitForChild("HumanoidRootPart", 10)
        local Data = LocalPlayer:FindFirstChild("Data") or LocalPlayer:WaitForChild("Data", 20)
        local Level = Data and Data:FindFirstChild("Level") or nil
        local Beli = Data and Data:FindFirstChild("Beli") or nil
        local Fragments = Data and Data:FindFirstChild("Fragments") or nil

        local Enemies = Workspace:WaitForChild("Enemies", 30)
        local ChestModels = Workspace:FindFirstChild("ChestModels")
        local MapAttr = Workspace:GetAttribute("MAP")
        local IsSea1 = MapAttr == "Sea1"
        local IsSea2 = MapAttr == "Sea2"
        local IsSea3 = MapAttr == "Sea3"

        LocalPlayer.CharacterAdded:Connect(function(nc)
            Character = nc
            Humanoid = nc:WaitForChild("Humanoid", 10)
            HRP = nc:WaitForChild("HumanoidRootPart", 10)
        end)

        -- Tween
        local TweenState = {Cancel=false, BodyVel=nil, Gen=0}
        local function TweenTo(target, keep)
            if not HRP or not HRP.Parent then return end
            if typeof(target) == "Vector3" then target = CFrame.new(target) end
            if typeof(target) ~= "CFrame" then return end
            TweenState.Cancel = false
            TweenState.Gen = TweenState.Gen + 1
            local myGen = TweenState.Gen
            local startCF = HRP.CFrame
            local dist = (target.Position - startCF.Position).Magnitude
            if dist < 5 then HRP.CFrame = target; return end
            if not TweenState.BodyVel or not TweenState.BodyVel.Parent then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "DxTween"
                bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                bv.Velocity = Vector3.zero; bv.P = 10000; bv.Parent = HRP
                TweenState.BodyVel = bv
            end
            local speed = T.TweenSpeed or 250
            local steps = math.clamp(math.ceil(dist/(speed*0.02)), 3, 500)
            local startPos = startCF.Position
            for i = 1, steps do
                if TweenState.Gen ~= myGen or TweenState.Cancel then break end
                if not HRP or not HRP.Parent then break end
                local a = i/steps
                local newPos = startPos:Lerp(target.Position, a)
                TweenState.BodyVel.Velocity = (newPos - HRP.Position) * 60
                if dist > 50 then
                    HRP.CFrame = CFrame.new(HRP.Position:Lerp(target.Position, a*0.3), HRP.Position + (target.Position - HRP.Position).Unit)
                end
                RunService.Heartbeat:Wait()
            end
            if TweenState.Gen == myGen then
                pcall(function() HRP.CFrame = target
                    if TweenState.BodyVel then TweenState.BodyVel.Velocity = Vector3.zero end end)
                if not keep and TweenState.BodyVel then
                    TweenState.BodyVel:Destroy(); TweenState.BodyVel = nil
                end
            end
        end

        -- Combat
        local function GetEnemies(range)
            range = range or 2000
            local list = {}
            if not HRP or not Enemies then return list end
            local p = HRP.Position
            for _, m in ipairs(Enemies:GetChildren()) do
                local mH = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                local mHu = m:FindFirstChildOfClass("Humanoid")
                if mH and mHu and mHu.Health > 0 then
                    local d = (mH.Position - p).Magnitude
                    if d <= range then table.insert(list,{m,mH,d,mHu}) end
                end
            end
            table.sort(list, function(a,b) return a[3] < b[3] end)
            return list
        end

        local function GetEquippedWeapon()
            if not Character then return nil end
            return Character:FindFirstChildOfClass("Tool")
        end

        local function EquipWeaponType(tip)
            if not Humanoid or not Character or not tip then return end
            local cur = Character:FindFirstChildOfClass("Tool")
            if cur and cur.ToolTip == tip then return end
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == tip then
                    Humanoid:EquipTool(tool); task.wait(0.05); return tool
                end
            end
        end

        local function FastAttack()
            if not T.FastAttack then return end
            if not Character or not Humanoid or Humanoid.Health <= 0 then return end
            local tool = GetEquippedWeapon()
            if not tool then return end
            if T.SelectWeapon == "Gun" and tool.ToolTip == "Gun" then
                local remote = tool:FindFirstChild("RemoteEvent")
                local targets = GetEnemies(500)
                if #targets > 0 then
                    local tP = targets[1][2].Position
                    if remote then pcall(function() remote:FireServer("TAP", tP) end) end
                    local sR = Net and Net:FindFirstChild("RE/ShootGunEvent")
                    if sR then pcall(function() sR:FireServer(tP, {targets[1][2]}) end) end
                end
                return
            end
            local lc = tool:FindFirstChild("LeftClickRemote")
            local targets = GetEnemies(200)
            if #targets > 0 then
                local target = targets[1][2]
                local dist = targets[1][3]
                if dist > 15 then TweenTo(CFrame.new(target.Position + Vector3.new(0, T.PosY or 18, 0))) end
                if lc then pcall(function() lc:FireServer(Vector3.new(0.01,-500,0.01), 1, true) end) end
                local reg = Net and Net:FindFirstChild("RE/RegisterHit")
                if reg then
                    local hits = {}
                    for i = 1, math.min(3,#targets) do table.insert(hits, {targets[i][1], targets[i][2]}) end
                    pcall(function()
                        reg:FireServer(target, hits, nil, nil, tostring(LocalPlayer.UserId):sub(2,4)..tostring(tick()):sub(-5))
                    end)
                end
            end
        end

        local lastBring = 0
        local function BringMonsters()
            if not T.BringMonster or not HRP or not HRP.Parent then return end
            local n = tick()
            if n - lastBring < 0.5 then return end
            lastBring = n
            pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", T.BringMonsterRadius or 350) end)
            for _, m in ipairs(Enemies:GetChildren()) do
                local mH = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                local mHu = m:FindFirstChildOfClass("Humanoid")
                if mH and mHu and mHu.Health > 0 then
                    local d = (mH.Position - HRP.Position).Magnitude
                    if d <= (T.BringMonsterRadius or 350) and d > 20 then
                        pcall(function() mH.CFrame = CFrame.new(HRP.Position + Vector3.new(math.random(-5,5),5,math.random(-5,5))) end)
                    end
                end
            end
        end

        -- Chest & Fruit
        local ChestCounter = 0
        local function GetNearestChest()
            if not ChestModels or not HRP or not HRP.Parent then return nil end
            local p = HRP.Position
            local near, nd = nil, math.huge
            for _, c in ipairs(ChestModels:GetChildren()) do
                local r = c:FindFirstChild("RootPart")
                if r and r.Parent and c:GetAttribute("IsDisabled") ~= true then
                    local d = (r.Position - p).Magnitude
                    if d < nd then near, nd = r, d end
                end
            end
            return near
        end
        local function AutoChestLoop()
            if not T.AutoChest or not HRP or not HRP.Parent then return end
            local ch = GetNearestChest()
            if ch then
                TweenTo(ch.CFrame + Vector3.new(0,3,0))
                ChestCounter = ChestCounter + 1
                task.wait(0.05)
            else
                if ChestCounter > 0 then Notify("Chest", "Da nhat "..ChestCounter.." ruong", 5); ChestCounter = 0 end
                task.wait(1)
            end
        end

        local FruitBL = {}
        local function GetNearestFruit()
            local p = HRP and HRP.Position
            if not p then return nil end
            local near, nd = nil, math.huge
            for _, o in ipairs(Workspace:GetChildren()) do
                if o:IsA("Tool") and (o.Name:find("Fruit") or o:FindFirstChild("Handle")) then
                    local h = o:FindFirstChild("Handle")
                    if h then
                        local d = (h.Position - p).Magnitude
                        if d < nd and not FruitBL[o] then near, nd = o, d end
                    end
                end
                if o:IsA("Model") and o.Name:find("Fruit") then
                    local h = o:FindFirstChild("Handle") or o.PrimaryPart
                    if h then
                        local d = (h.Position - p).Magnitude
                        if d < nd and not FruitBL[o] then near, nd = o, d end
                    end
                end
            end
            return near, nd
        end
        local function AutoFruitLoop()
            if not T.AutoFruitFarm or not HRP or not HRP.Parent then return end
            local f, d = GetNearestFruit()
            if f then
                local h = f:FindFirstChild("Handle") or f.PrimaryPart
                if h then
                    if d > 10 then TweenTo(h.CFrame + Vector3.new(0,2,0))
                    else
                        pcall(function() firetouchinterest(HRP, h, 0); task.wait(0.05); firetouchinterest(HRP, h, 1) end)
                        FruitBL[f] = true
                        task.delay(2, function() FruitBL[f] = nil end)
                    end
                end
                task.wait(0.1)
            else
                if T.HopIfNoFruit then
                    Notify("Fruit", "Khong co trai, hop...", 4)
                    task.wait(T.HopDelay or 10)
                    pcall(function() RS.__ServerBrowser:InvokeServer("teleport", RS.__ServerBrowser:InvokeServer("getjob")) end)
                end
                task.wait(0.5)
            end
        end

        -- Macro
        local MacroRunning = false
        local function StopMacro() MacroRunning = false end
        local function RunMacro()
            if not T.MacroEnabled or MacroRunning then return end
            MacroRunning = true
            task.spawn(function()
                while T.MacroEnabled and MacroRunning do
                    for _, k in ipairs(T.MacroSkillKeys) do
                        if not T.MacroEnabled or not MacroRunning then break end
                        local kc = Enum.KeyCode[k]
                        if kc then pcall(function() VIM:SendKeyEvent(true, kc, false, game); task.wait(T.MacroDelay or 0.3); VIM:SendKeyEvent(false, kc, false, game) end) end
                        task.wait(T.MacroDelayBetween or 0.15)
                    end
                    task.wait(0.5)
                end
                MacroRunning = false
            end)
        end

        -- Islands
        local IslandCoords = {
            Sea1 = { ["Starter Island"]=Vector3.new(-1053,5,4251), ["Marine Fortress"]=Vector3.new(-4895,8,4350), ["Middle Town"]=Vector3.new(-916,5,4500), ["Jungle"]=Vector3.new(-1610,36,149), ["Pirate Village"]=Vector3.new(-1160,5,3845), ["Desert"]=Vector3.new(1055,5,4280), ["Frozen Village"]=Vector3.new(1200,30,-1400), ["Marine Ford"]=Vector3.new(-5100,15,-4200), ["Skylands"]=Vector3.new(-4880,720,-3230), ["Colosseum"]=Vector3.new(-1500,5,-2100), ["Prison"]=Vector3.new(4850,5,710), ["Magma Village"]=Vector3.new(-5220,3,870), ["Underwater City"]=Vector3.new(60500,4,1100), ["Fountain City"]=Vector3.new(5150,5,3000), ["Rumble Arena"]=Vector3.new(-6500,5,8500) },
            Sea2 = { ["Kingdom of Rose"]=Vector3.new(0,0,0), ["Swan Mansion"]=Vector3.new(-245,73,300), ["Hot and Cold"]=Vector3.new(2500,8,-1200), ["Cursed Ship"]=Vector3.new(912,125,32800), ["Ice Castle"]=Vector3.new(5630,25,-6000), ["Forgotten Island"]=Vector3.new(-3000,8,-1000), ["Cafe"]=Vector3.new(-380,73,260), ["Green Zone"]=Vector3.new(-5500,8,-350), ["Graveyard"]=Vector3.new(-9500,6,6000), ["Snow Mountain"]=Vector3.new(1350,87,-1300), ["Factory"]=Vector3.new(430,8,-1350) },
            Sea3 = { ["Port Town"]=Vector3.new(-260,6,5245), ["Hydra Island"]=Vector3.new(5660,1000,850), ["Great Tree"]=Vector3.new(2950,2280,-7200), ["Castle on the Sea"]=Vector3.new(-5100,314,-3150), ["Haunted Castle"]=Vector3.new(-9500,150,6000), ["Sea of Treats"]=Vector3.new(-1000,10,-12000), ["Peanut Island"]=Vector3.new(1950,8,-12200), ["Tiki Outpost"]=Vector3.new(-16300,8,400), ["Floating Turtle"]=Vector3.new(-12400,375,-7500), ["Mansion"]=Vector3.new(-12300,320,-6630) },
        }
        local function GetIslandList() return IsSea1 and IslandCoords.Sea1 or IsSea2 and IslandCoords.Sea2 or IsSea3 and IslandCoords.Sea3 or {} end
        local function GetIslandNames() local n = {}; for k in pairs(GetIslandList()) do table.insert(n, k) end; table.sort(n); return n end

        -- ESP
        local ESPSprites = {}
        local function ClearESP() for _, o in pairs(ESPSprites) do if o and o.Parent then pcall(function() o:Destroy() end) end end; ESPSprites = {} end
        local function CreateESP(parent, text, color)
            if parent:FindFirstChild("DxESP") then return end
            local bb = Instance.new("BillboardGui"); bb.Name = "DxESP"; bb.Size = UDim2.new(0,200,0,30); bb.StudsOffset = Vector3.new(0,3,0); bb.AlwaysOnTop = true; bb.Parent = parent
            local l = Instance.new("TextLabel"); l.Size = UDim2.fromScale(1,1); l.BackgroundTransparency = 1; l.Text = text; l.Font = Enum.Font.GothamBold; l.TextColor3 = color or TH.Accent; l.TextStrokeTransparency = 0.3; l.TextSize = 12; l.Parent = bb
            ESPSprites[parent] = bb
        end
        local function UpdateESP()
            if T.ESPChest and ChestModels then for _, ch in ipairs(ChestModels:GetChildren()) do local r = ch:FindFirstChild("RootPart"); if r then CreateESP(r, "Chest", TH.Green) end end end
            if T.ESPFruit then for _, o in ipairs(Workspace:GetChildren()) do if o:IsA("Tool") and o.Name:find("Fruit") then local h = o:FindFirstChild("Handle"); if h then CreateESP(h, o.Name, TH.Red) end end end end
        end

        -- Helpers
        local function ApplyWalkSpeed() if Humanoid and T.WalkSpeed then pcall(function() Humanoid.WalkSpeed = T.WalkSpeed end) end end
        local function ApplyJumpPower() if Humanoid and T.JumpPower then pcall(function() Humanoid.UseJumpPower = true; Humanoid.JumpPower = T.JumpPower end) end end
        local function SendWebhook(title, desc)
            if not T.WebhookEnabled or T.Webhook == "" then return end
            local req = (syn and syn.request) or http_request; if not req then return end
            local body = HttpSvc:JSONEncode({ embeds = {{ title = title, description = desc, color = 3066993, footer = {text = "Blox Community VN - Dungdx"}, timestamp = DateTime.now():ToIsoDate() }} })
            pcall(function() req({Url = T.Webhook, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body = body}) end)
        end

        -- ==================== BUILD UI TABS ====================
        -- HOME (Giong anh nguoi dung gui)
        do
            local s1 = Tabs.Home:AddSection("Trạng Thái")
            local statusLbl = C:Label(s1.Frame, "Status: Optional loops stopped")
            C:Label(s1.Frame, "Level: "..(Level and Level.Value or "?").." • Sea "..(MapAttr and MapAttr:sub(4) or "?"))
            C:Label(s1.Frame, "Bạn đang ở UI đơn giản, thao tác mobile và trang thái sẽ rõ ràng. Những route chưa có remote xác thực sẽ bảo thay vì gửi ở hoạt động.")
            local s2 = Tabs.Home:AddSection("Hành Động Nhanh")
            C:Button(s2.Frame, "Refresh ESP", function() ClearESP(); UpdateESP(); Notify("ESP", "Đã refresh!", 3) end)
            C:Button(s2.Frame, "Stop optional loops", function()
                T.AutoChest = false; T.AutoFruitFarm = false; T.AutoFarm = false; T.FastAttack = false; T.BringMonster = false; T.MacroEnabled = false
                StopMacro()
                statusLbl:Set("Status: All loops stopped")
                Notify("Hệ thống", "Đã dừng tất cả vòng lặp phụ!", 4)
            end)
            local s3 = Tabs.Home:AddSection("Bật Nhanh")
            C:Toggle(s3.Frame, "Fast Attack", T.FastAttack, function(v) T.FastAttack = v end)
            C:Toggle(s3.Frame, "Auto Chest", T.AutoChest, function(v) T.AutoChest = v; ChestCounter = 0 end)
            C:Toggle(s3.Frame, "Auto Nhặt Trái", T.AutoFruitFarm, function(v) T.AutoFruitFarm = v end)
            C:Toggle(s3.Frame, "Bring Monster", T.BringMonster, function(v) T.BringMonster = v end)
            C:Toggle(s3.Frame, "Lag Fix", T.LagFix, function(v) T.LagFix = v; ApplyLagFix(v) end)
            C:Toggle(s3.Frame, "Xóa Sương Mù", T.RemoveFog, function(v) T.RemoveFog = v; ApplyRemoveFog(v) end)
        end

        -- FARM
        do
            local s1 = Tabs.Farm:AddSection("Auto Farm")
            C:Toggle(s1.Frame, "Auto Farm Quest", T.AutoFarm, function(v) T.AutoFarm = v end)
            C:Toggle(s1.Frame, "Auto Farm Bones", T.AutoFarmBones, function(v) T.AutoFarmBones = v end)
            C:Dropdown(s1.Frame, "Vũ khí", T.SelectWeapon, {"Melee","Sword","Blox Fruit","Gun"}, function(v) T.SelectWeapon = v end)
            C:Slider(s1.Frame, "Độ cao bay", 5, 100, T.PosY, function(v) T.PosY = v end)
            C:Slider(s1.Frame, "Bring Radius", 50, 500, T.BringMonsterRadius, function(v) T.BringMonsterRadius = v end)
            C:Slider(s1.Frame, "Tween Speed", 50, 500, T.TweenSpeed, function(v) T.TweenSpeed = v end)
            local s2 = Tabs.Farm:AddSection("Boss Farm")
            local bossList = IsSea1 and {"The Gorilla King","Yeti","Warden","Swan","Magma Admiral","Fishman Lord","Thunder God","Cyborg"} or IsSea2 and {"Diamond","Jeremy","Orbitus","Don Swan","Tide Keeper"} or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen"}
            C:Dropdown(s2.Frame, "Boss", bossList[1], bossList, function(v) T.SelectBoss = v end)
            C:Toggle(s2.Frame, "Auto Boss", T.AutoFarmBoss, function(v) T.AutoFarmBoss = v end)
            C:Toggle(s2.Frame, "Kill All Bosses", T.AutoKillAllBosses, function(v) T.AutoKillAllBosses = v end)
        end

        -- COMBAT
        do
            local s1 = Tabs.Combat:AddSection("Combat Settings")
            C:Toggle(s1.Frame, "Fast Attack", T.FastAttack, function(v) T.FastAttack = v end)
            C:Toggle(s1.Frame, "Auto Gun", T.AutoAttackGun, function(v) T.AutoAttackGun = v end)
            C:Slider(s1.Frame, "Attack Delay", 0, 1, T.FastAttackDelay, function(v) T.FastAttackDelay = v end, 0.01)
            C:Toggle(s1.Frame, "Bring Monster", T.BringMonster, function(v) T.BringMonster = v end)
            local s2 = Tabs.Combat:AddSection("Macro Combo")
            C:Toggle(s2.Frame, "Bật Macro", T.MacroEnabled, function(v) T.MacroEnabled = v; if v then RunMacro() else StopMacro() end end)
            C:Slider(s2.Frame, "Giữ phím (s)", 0.05, 2, T.MacroDelay, function(v) T.MacroDelay = v end, 0.05)
            C:Slider(s2.Frame, "Delay giữa phím", 0.05, 2, T.MacroDelayBetween, function(v) T.MacroDelayBetween = v end, 0.05)
            C:Textbox(s2.Frame, "VD: Z,X,C,V,F", function(v) local ks = {}; for k in v:gmatch("[^,%s]+") do table.insert(ks, k:upper()) end; if #ks > 0 then T.MacroSkillKeys = ks end end, table.concat(T.MacroSkillKeys, ","))
        end

        -- PLAYER
        do
            local s1 = Tabs.Player:AddSection("Di Chuyển")
            C:Slider(s1.Frame, "Walk Speed", 16, 500, T.WalkSpeed, function(v) T.WalkSpeed = v; ApplyWalkSpeed() end)
            C:Slider(s1.Frame, "Jump Power", 50, 500, T.JumpPower, function(v) T.JumpPower = v; ApplyJumpPower() end)
            C:Toggle(s1.Frame, "Infinite Zoom", T.InfiniteZoom, function(v) T.InfiniteZoom = v; LocalPlayer.CameraMaxZoomDistance = v and math.huge or 128 end)
            local s2 = Tabs.Player:AddSection("ESP")
            C:Toggle(s2.Frame, "ESP Chest", T.ESPChest, function(v) T.ESPChest = v end)
            C:Toggle(s2.Frame, "ESP Fruit", T.ESPFruit, function(v) T.ESPFruit = v end)
            C:Button(s2.Frame, "Xóa ESP", function() ClearESP(); Notify("ESP", "Đã xóa", 3) end)
            local s3 = Tabs.Player:AddSection("Nhân Vật")
            C:Button(s3.Frame, "Reset Nhân Vật", function() if Character and Character:FindFirstChild("Head") then Character.Head:Destroy() end end)
        end

        -- FRUIT
        do
            local s1 = Tabs.Fruit:AddSection("Auto Nhặt Trái")
            C:Toggle(s1.Frame, "Auto Nhặt Trái", T.AutoFruitFarm, function(v) T.AutoFruitFarm = v end)
            C:Toggle(s1.Frame, "Hop nếu không có", T.HopIfNoFruit, function(v) T.HopIfNoFruit = v end)
            C:Slider(s1.Frame, "Hop Delay (s)", 1, 60, T.HopDelay, function(v) T.HopDelay = v end)
            local s2 = Tabs.Fruit:AddSection("Lưu Trái")
            C:Toggle(s2.Frame, "Auto Store Fruit", T.AutoStoreFruit, function(v) T.AutoStoreFruit = v end)
        end

        -- CHEST
        do
            local s1 = Tabs.Chest:AddSection("Chest Farm")
            C:Toggle(s1.Frame, "Auto Chest", T.AutoChest, function(v) T.AutoChest = v; ChestCounter = 0 end)
            C:Toggle(s1.Frame, "Hop hết rương", T.AutoHopChest, function(v) T.AutoHopChest = v end)
            C:Slider(s1.Frame, "Số rương trước hop", 1, 50, 10, function(v) T.ChestHopCount = v end)
            C:Toggle(s1.Frame, "ESP Chest", T.ESPChest, function(v) T.ESPChest = v end)
        end

        -- ISLAND
        do
            local s1 = Tabs.Island:AddSection("TP Đảo")
            local islNames = GetIslandNames()
            local selIsl = islNames[1] or "None"
            if #islNames > 0 then C:Dropdown(s1.Frame, "Chọn đảo", selIsl, islNames, function(v) selIsl = v end)
            else C:Label(s1.Frame, "Không có đảo") end
            C:Button(s1.Frame, "TP tới đảo", function() local c = GetIslandList()[selIsl]; if c then Notify("TP","Tới: "..selIsl,3); TweenTo(CFrame.new(c)) end end)
            local s2 = Tabs.Island:AddSection("TP Sea")
            C:Button(s2.Frame, "Sea 1", function() pcall(function() CommF:InvokeServer("TravelMain") end) end)
            C:Button(s2.Frame, "Sea 2", function() pcall(function() CommF:InvokeServer("TravelDressrosa") end) end)
            C:Button(s2.Frame, "Sea 3", function() pcall(function() CommF:InvokeServer("TravelZou") end) end)
            local s3 = Tabs.Island:AddSection("Server Hop")
            C:Button(s3.Frame, "Rejoin", function() pcall(function() RS.__ServerBrowser:InvokeServer("teleport", game.JobId) end) end)
            C:Button(s3.Frame, "Random Hop", function()
                Notify("Hop","Đang tìm server...",3)
                task.spawn(function()
                    for i = 1, 100 do local servers = RS.__ServerBrowser:InvokeServer(i)
                        if typeof(servers) == "table" then for jobId, info in pairs(servers) do
                            if info.Count and info.Count < 12 and jobId ~= game.JobId then pcall(function() RS.__ServerBrowser:InvokeServer("teleport", jobId) end); return end
                        end end
                    end
                end)
            end)
        end

        -- MACRO
        do
            local s1 = Tabs.Macro:AddSection("Combo Macro")
            C:Toggle(s1.Frame, "Bật Macro", T.MacroEnabled, function(v) T.MacroEnabled = v; if v then RunMacro() else StopMacro() end end)
            C:Textbox(s1.Frame, "Z,X,C,V,F", function(v) local ks = {}; for k in v:gmatch("[^,%s]+") do table.insert(ks, k:upper()) end; if #ks > 0 then T.MacroSkillKeys = ks; Notify("Macro","Đã set: "..table.concat(ks," > "),3) end end, table.concat(T.MacroSkillKeys, ","))
            C:Slider(s1.Frame, "Giữ phím (s)", 0.05, 2, T.MacroDelay, function(v) T.MacroDelay = v end, 0.05)
            C:Slider(s1.Frame, "Delay giữa phím", 0.05, 2, T.MacroDelayBetween, function(v) T.MacroDelayBetween = v end, 0.05)
            local s2 = Tabs.Macro:AddSection("Preset")
            C:Button(s2.Frame, "Z-X-C", function() T.MacroSkillKeys = {"Z","X","C"}; Notify("Macro","Preset Z-X-C",3) end)
            C:Button(s2.Frame, "Z-X-C-V-F", function() T.MacroSkillKeys = {"Z","X","C","V","F"}; Notify("Macro","Preset full",3) end)
            C:Button(s2.Frame, "Z-Z-X-X", function() T.MacroSkillKeys = {"Z","Z","X","X"}; Notify("Macro","Preset combo đôi",3) end)
        end

        -- PERF
        do
            local s1 = Tabs.Perf:AddSection("Hiệu Năng")
            C:Toggle(s1.Frame, "Lag Fix", T.LagFix, function(v) T.LagFix = v; ApplyLagFix(v) end)
            C:Toggle(s1.Frame, "Xóa Sương Mù", T.RemoveFog, function(v) T.RemoveFog = v; ApplyRemoveFog(v) end)
            C:Button(s1.Frame, "Dọn Bộ Nhớ", function()
                pcall(function()
                    if collectgarbage then collectgarbage("collect") end
                    for _, o in ipairs(Workspace:GetChildren()) do if o:IsA("BasePart") and (o.Name:find("Slash") or o.Name:find("Effect")) then o:Destroy() end end
                end)
                Notify("Cleaner","Đã dọn!",3)
            end)
            local s2 = Tabs.Perf:AddSection("FPS Monitor")
            local fpsL = C:Label(s2.Frame, "FPS: --")
            task.spawn(function()
                local fr, lu = 0, tick()
                RunService.RenderStepped:Connect(function()
                    fr = fr + 1
                    if tick() - lu >= 1 then fpsL:Set("FPS: "..fr); fr = 0; lu = tick() end
                end)
            end)
        end

        -- MISC
        do
            local s1 = Tabs.Misc:AddSection("Anti-AFK")
            C:Toggle(s1.Frame, "Anti AFK", T.AntiAFK, function(v) T.AntiAFK = v end)
            local s2 = Tabs.Misc:AddSection("Server")
            C:Toggle(s2.Frame, "Auto Hop 30 phút", T.AutoHop30Min, function(v) T.AutoHop30Min = v end)
            C:Slider(s2.Frame, "Hop Delay (s)", 1, 60, T.HopDelay, function(v) T.HopDelay = v end)
            local s3 = Tabs.Misc:AddSection("Team")
            C:Button(s3.Frame, "Pirates", function() pcall(function() CommF:InvokeServer("SetTeam","Pirates") end) end)
            C:Button(s3.Frame, "Marines", function() pcall(function() CommF:InvokeServer("SetTeam","Marines") end) end)
            local s4 = Tabs.Misc:AddSection("Codes")
            C:Button(s4.Frame, "Redeem Codes", function()
                Notify("Codes","Đang redeem...",3)
                task.spawn(function()
                    local codes = {"SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","KITTGAMING","FUDDSM0NEY","GAMER_ROBOT_1M"}
                    for _, cd in ipairs(codes) do pcall(function() Remotes.Redeem:InvokeServer(cd) end); task.wait(0.5) end
                    Notify("Codes","Đã thử "..#codes.." codes!",5)
                end)
            end)
        end

        -- WEBHOOK
        do
            local s1 = Tabs.Webhook:AddSection("Discord Webhook")
            C:Textbox(s1.Frame, "https://discord.com/api/webhooks/...", function(v) T.Webhook = v end, T.Webhook)
            C:Toggle(s1.Frame, "Bật Webhook", T.WebhookEnabled, function(v) T.WebhookEnabled = v end)
            C:Button(s1.Frame, "Test Webhook", function()
                if T.Webhook == "" then Notify("Webhook","Chưa có URL!",3); return end
                SendWebhook("Blox Community VN", "Test OK!\nUser: **"..LocalPlayer.Name.."**")
                Notify("Webhook","Đã gửi test!",3)
            end)
        end

        -- CREDIT
        do
            local s1 = Tabs.Credit:AddSection("Thông Tin")
            C:Label(s1.Frame, "Blox Community VN", "UI Redesign v3.2")
            C:Label(s1.Frame, "Tác giả", "Dungdx")
            C:Label(s1.Frame, "Discord", "discord.gg/Hwwa3VYxW6")
            C:Button(s1.Frame, "Copy Discord Link", function()
                pcall(function() setclipboard("https://discord.gg/Hwwa3VYxW6") end)
                Notify("Credit","Đã copy!",3)
            end)
        end

        -- ==================== MAIN LOOPS ====================
        task.spawn(function() while task.wait(T.FastAttackDelay or 0) do if T.FastAttack then pcall(FastAttack) end end end)
        task.spawn(function() while task.wait(0.5) do if T.BringMonster then pcall(BringMonsters) end end end)
        task.spawn(function() while task.wait(0.2) do if T.AutoChest then pcall(AutoChestLoop) end end end)
        task.spawn(function() while task.wait(0.3) do if T.AutoFruitFarm then pcall(AutoFruitLoop) end end end)
        task.spawn(function()
            while task.wait(0.5) do
                if T.AutoFarm or T.AutoFarmBones or T.AutoFarmBoss or T.AutoKillAllBosses then
                    pcall(function()
                        local targets = GetEnemies(T.checknearestdist or 1500)
                        if #targets > 0 then
                            local tH = targets[1][2]; local d = targets[1][3]
                            if d > 30 then TweenTo(CFrame.new(tH.Position + Vector3.new(0, T.PosY or 18, 0))) end
                            EquipWeaponType(T.SelectWeapon)
                        end
                    end)
                end
            end
        end)
        task.spawn(function() while task.wait(1) do if T.ESPChest or T.ESPFruit then pcall(UpdateESP) end end end)
        task.spawn(function() while task.wait(1) do if Humanoid then pcall(ApplyWalkSpeed); pcall(ApplyJumpPower) end end end)
        task.spawn(function()
            while task.wait(2) do
                if T.AutoStoreFruit then
                    pcall(function()
                        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:find("Fruit") then
                                local nm = tool:GetAttribute("OriginalName") or tool.Name:match("^(.-)%-") or tool.Name
                                pcall(function() CommF:InvokeServer("StoreFruit", nm, tool) end)
                            end
                        end
                    end)
                end
            end
        end)
        task.spawn(function() while task.wait(60) do if T.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new(0,0)) end) end end end)
        local startT = tick()
        task.spawn(function()
            while task.wait(30) do
                if T.AutoHop30Min and tick() - startT >= 1800 then
                    startT = tick(); Notify("Hop","30 phút rồi, đang hop...",5)
                    pcall(function() RS.__ServerBrowser:InvokeServer("teleport", RS.__ServerBrowser:InvokeServer("getjob")) end)
                end
            end
        end)
        task.spawn(function()
            while task.wait(5) do
                if T.LagFix then pcall(function() Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9 end) end
                if T.RemoveFog then pcall(ApplyRemoveFog, true) end
            end
        end)

        task.spawn(function()
            task.wait(1)
            Notify("Blox Community VN","UI Dark Mode đã load!\nDungdx | discord.gg/Hwwa3VYxW6", 8)
        end)
        print("[BCVN] BACKEND LOAD XONG!")
    end)
    if not ok then warn("[BCVN] Lỗi backend:", tostring(err)); Notify("Lỗi", tostring(err):sub(1,60), 10) end
end)

getgenv().BloxCommunityVN_Loaded = true
print("[BCVN] ========== SẴN SÀNG ==========")
return "Blox Community VN v3.2 - Dark Minimalist"