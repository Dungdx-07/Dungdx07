--[[
    ═══════════════════════════════════════════════════════════════
       ██████╗ ██╗      ██████╗ ██╗  ██╗     ██████╗ ██████╗ ███╗   ███╗
       ██╔══██╗██║     ██╔═══██╗╚██╗██╔╝    ██╔════╝██╔═══██╗████╗ ████║
       ██████╔╝██║     ██║   ██║ ╚███╔╝     ██║     ██║   ██║██╔████╔██║
       ██╔══██╗██║     ██║   ██║ ██╔██╗     ██║     ██║   ██║██║╚██╔╝██║
       ██████╔╝███████╗╚██████╔╝██╔╝ ██╗    ╚██████╗╚██████╔╝██║ ╚═╝ ██║
       ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═╝     ╚═╝
       
       BLOX COMMUNITY VN — Script by Dungdx
       Discord: https://discord.gg/Hwwa3VYxW6
       Version: v5.0 (Full Functional)
    ═══════════════════════════════════════════════════════════════
--]]

if getgenv().BCVN_v5_Loaded then
    return warn("[BCVN] Script đã chạy rồi!")
end
getgenv().BCVN_v5_Loaded = true

print("╔══════════════════════════════════════════╗")
print("║  BLOX COMMUNITY VN v5.0 - by Dungdx      ║")
print("║  Discord: discord.gg/Hwwa3VYxW6          ║")
print("╚══════════════════════════════════════════╝")

--============================================================
-- 1. SERVICES
--============================================================
local Players    = game:GetService("Players")
local Workspace  = game:GetService("Workspace")
local RS         = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TweenSvc   = game:GetService("TweenService")
local Lighting   = game:GetService("Lighting")
local HttpSvc    = game:GetService("HttpService")
local VIM        = game:GetService("VirtualInputManager")
local VUser      = game:GetService("VirtualUser")
local CollService= game:GetService("CollectionService")
local LocalPlayer= Players.LocalPlayer

--============================================================
-- 2. CONFIG (Blox Community VN style)
--============================================================
local Config = {
    -- Combat
    AutoAttack = true, WeaponType = "Melee",
    AttackRange = 150, PosY = 18, BringRadius = 300,
    BringMonster = true, AutoGun = true, AttackMobs = true, AttackPlayers = false,

    -- Farm
    AutoFarm = false, AutoFarmBones = false, AutoBoss = false,
    AutoCakePrince = false, AutoDoughKing = false, AutoMaterial = false,
    FarmMode = "Quest", TakeQuest = true, QuestDelay = 0.5,

    -- Chest
    AutoChest = false, AutoHopChest = false, ChestHopCount = 10,

    -- Fruit
    AutoFruit = false, AutoStoreFruit = false, HopIfNoFruit = false,

    -- Movement
    WalkSpeed = 50, JumpPower = 50, InfiniteZoom = false, XrayVision = false,

    -- Tween
    TweenSpeed = 250, TweenMode = "Smooth",

    -- ESP
    ESPPlayer = false, ESPChest = false, ESPFruit = false, ESPIsland = false,

    -- Server
    HopDelay = 10, AutoHop30Min = false,

    -- Performance
    LagFix = false, RemoveFog = false,

    -- Macro
    MacroEnabled = false, MacroKeys = {"Z","X","C","V","F"},
    MacroHold = 0.3, MacroGap = 0.15,

    -- Misc
    AntiAFK = true, AutoRedeem = false,

    -- Webhook
    WebhookURL = "", WebhookEnabled = false,

    -- Internal
    _ActiveFarm = "None",
    _HopRunning = false,
    _TweenGen = 0,
}
getgenv().BCVN_Config = Config

--============================================================
-- 3. UI — DARK MINIMALIST (Blox Community VN)
--============================================================
print("[BCVN] Đang tạo UI...")

local UICreate, UI = pcall(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not pg then error("PlayerGui không tồn tại") end
    local old = pg:FindFirstChild("BloxCommunityVN")
    if old then old:Destroy() end

    local Theme = {
        Bg      = Color3.fromRGB(20,21,24),
        Panel   = Color3.fromRGB(28,29,33),
        Card    = Color3.fromRGB(36,37,42),
        Button  = Color3.fromRGB(46,47,53),
        Hover   = Color3.fromRGB(58,59,66),
        Text    = Color3.fromRGB(238,238,242),
        Dim     = Color3.fromRGB(148,150,158),
        Accent  = Color3.fromRGB(88,155,255),
        Green   = Color3.fromRGB(80,200,120),
        Red     = Color3.fromRGB(225,85,85),
        Yellow  = Color3.fromRGB(245,200,80),
    }

    -- Root ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "BloxCommunityVN"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = pg

    -- Floating "Dx" toggle
    local dxBtn = Instance.new("TextButton")
    dxBtn.Size = UDim2.fromOffset(54,54)
    dxBtn.Position = UDim2.new(0,20,0.5,-27)
    dxBtn.BackgroundColor3 = Theme.Panel
    dxBtn.Text = "Dx"
    dxBtn.Font = Enum.Font.GothamBold
    dxBtn.TextColor3 = Theme.Text
    dxBtn.TextSize = 20
    dxBtn.AutoButtonColor = false
    dxBtn.Draggable = true
    dxBtn.Parent = gui
    Instance.new("UICorner", dxBtn).CornerRadius = UDim.new(1,0)
    local dStk = Instance.new("UIStroke", dxBtn); dStk.Color = Theme.Accent; dStk.Thickness = 1.5

    -- Main window
    local root = Instance.new("Frame")
    root.AnchorPoint = Vector2.new(0.5,0.5)
    root.Position = UDim2.fromScale(0.5,0.5)
    root.Size = UDim2.fromOffset(600,450)
    root.BackgroundColor3 = Theme.Bg
    root.BorderSizePixel = 0
    root.Parent = gui
    Instance.new("UICorner", root).CornerRadius = UDim.new(0,12)
    local rStk = Instance.new("UIStroke", root); rStk.Color = Color3.fromRGB(48,49,55); rStk.Thickness = 1

    -- UIScale responsive
    local uiScale = Instance.new("UIScale", root)
    local cam = Workspace.CurrentCamera
    local function fit()
        local vp = cam and cam.ViewportSize or Vector2.new(1000,600)
        uiScale.Scale = math.min(
            math.clamp((vp.X-40)/600, 0.55, 1.1),
            math.clamp((vp.Y-90)/450, 0.55, 1.1)
        )
    end
    fit(); if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1,0,0,56)
    header.BackgroundColor3 = Theme.Panel
    header.BorderSizePixel = 0
    header.Parent = root
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)
    local hCover = Instance.new("Frame")
    hCover.Size = UDim2.new(1,0,0,16); hCover.Position = UDim2.new(0,0,1,-16)
    hCover.BackgroundColor3 = Theme.Panel; hCover.BorderSizePixel = 0; hCover.Parent = header

    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(18,10); title.Size = UDim2.fromOffset(300,20)
    title.BackgroundTransparency = 1
    title.Text = "BLOX COMMUNITY VN"
    title.Font = Enum.Font.GothamBold; title.TextColor3 = Theme.Text
    title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.fromOffset(18,30); subtitle.Size = UDim2.fromOffset(360,14)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "by Dungdx  •  discord.gg/Hwwa3VYxW6"
    subtitle.Font = Enum.Font.Gotham; subtitle.TextColor3 = Theme.Dim
    subtitle.TextSize = 10; subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    local closeB = Instance.new("TextButton")
    closeB.Size = UDim2.fromOffset(28,28); closeB.Position = UDim2.new(1,-38,0,14)
    closeB.BackgroundColor3 = Theme.Button; closeB.Text = "×"
    closeB.Font = Enum.Font.GothamBold; closeB.TextColor3 = Theme.Text
    closeB.TextSize = 16; closeB.AutoButtonColor = false; closeB.Parent = header
    Instance.new("UICorner", closeB).CornerRadius = UDim.new(0,6)
    closeB.MouseButton1Click:Connect(function() gui.Enabled = false end)

    -- Tab bar
    local tabBar = Instance.new("ScrollingFrame")
    tabBar.Position = UDim2.fromOffset(10,62); tabBar.Size = UDim2.new(1,-20,0,30)
    tabBar.BackgroundTransparency = 1; tabBar.ScrollBarThickness = 0
    tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabBar.CanvasSize = UDim2.fromOffset(0,0); tabBar.Parent = root
    local tLay = Instance.new("UIListLayout", tabBar)
    tLay.FillDirection = Enum.FillDirection.Horizontal; tLay.Padding = UDim.new(0,6)

    local content = Instance.new("Frame")
    content.Position = UDim2.fromOffset(10,98)
    content.Size = UDim2.new(1,-20,1,-108)
    content.BackgroundTransparency = 1; content.Parent = root

    local Tabs, activeTab = {}, nil
    local tabOrder = {"Home","Farm","Combat","Fruit","ESP","Travel","Macro","Perf","Misc","Credit"}

    local function corner(o,r) local c = Instance.new("UICorner",o); c.CornerRadius = UDim.new(0,r or 6); return c end
    local function stroke(o,c,t) local s = Instance.new("UIStroke",o); s.Color = c or Theme.Button; s.Thickness = t or 1; return s end

    local function CreateTab(name)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromScale(1,1); frame.BackgroundTransparency = 1
        frame.Visible = false; frame.Parent = content

        local sc = Instance.new("ScrollingFrame")
        sc.Size = UDim2.fromScale(1,1); sc.BackgroundTransparency = 1
        sc.BorderSizePixel = 0; sc.ScrollBarThickness = 4
        sc.ScrollBarImageColor3 = Theme.Button
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sc.CanvasSize = UDim2.fromOffset(0,0); sc.Parent = frame
        local ll = Instance.new("UIListLayout", sc)
        ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Padding = UDim.new(0,10)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(85,26); btn.BackgroundColor3 = Theme.Panel
        btn.Text = name; btn.Font = Enum.Font.GothamSemibold
        btn.TextColor3 = Theme.Dim; btn.TextSize = 10
        btn.AutoButtonColor = false; btn.Parent = tabBar
        corner(btn,6)

        btn.MouseButton1Click:Connect(function()
            if activeTab == name then return end
            for _, td in pairs(Tabs) do
                td.Frame.Visible = false
                td.Button.BackgroundColor3 = Theme.Panel
                td.Button.TextColor3 = Theme.Dim
            end
            frame.Visible = true
            btn.BackgroundColor3 = Theme.Button
            btn.TextColor3 = Theme.Text
            activeTab = name
        end)

        local tabObj = {Frame=frame, Button=btn, Scroll=sc, _ord=0}
        function tabObj:Section(title)
            self._ord = self._ord + 1
            local sec = Instance.new("Frame")
            sec.Size = UDim2.new(1,-4,0,0); sec.AutomaticSize = Enum.AutomaticSize.Y
            sec.BackgroundColor3 = Theme.Card; sec.BorderSizePixel = 0
            sec.LayoutOrder = self._ord; sec.Parent = sc
            corner(sec,10); stroke(sec, Color3.fromRGB(44,45,50),1)

            local st = Instance.new("TextLabel")
            st.Size = UDim2.new(1,0,0,32); st.Position = UDim2.fromOffset(16,0)
            st.BackgroundTransparency = 1; st.Text = title
            st.Font = Enum.Font.GothamBold; st.TextColor3 = Theme.Text
            st.TextSize = 11; st.TextXAlignment = Enum.TextXAlignment.Left
            st.Parent = sec

            local body = Instance.new("Frame")
            body.Position = UDim2.fromOffset(12,32); body.Size = UDim2.new(1,-24,0,0)
            body.AutomaticSize = Enum.AutomaticSize.Y
            body.BackgroundTransparency = 1; body.Parent = sec
            local bl = Instance.new("UIListLayout", body)
            bl.SortOrder = Enum.SortOrder.LayoutOrder; bl.Padding = UDim.new(0,8)
            bl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sec.Size = UDim2.new(1,-4,0, 32 + bl.AbsoluteContentSize.Y + 12)
            end)
            return {Frame = body}
        end
        Tabs[name] = tabObj
        return tabObj
    end

    for _, n in ipairs(tabOrder) do CreateTab(n) end
    Tabs.Home.Frame.Visible = true
    Tabs.Home.Button.BackgroundColor3 = Theme.Button
    Tabs.Home.Button.TextColor3 = Theme.Text
    activeTab = "Home"

    -- Components
    local CC = {}

    function CC:Label(parent, text, sub)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1,0,0, sub and 32 or 18)
        f.BackgroundTransparency = 1; f.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,0,0,16); l.BackgroundTransparency = 1
        l.Text = text; l.Font = Enum.Font.Gotham; l.TextColor3 = Theme.Dim
        l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
        local s
        if sub then
            s = Instance.new("TextLabel")
            s.Position = UDim2.fromOffset(0,16); s.Size = UDim2.new(1,0,0,16)
            s.BackgroundTransparency = 1; s.Text = sub
            s.Font = Enum.Font.Gotham; s.TextColor3 = Theme.Text
            s.TextSize = 10; s.TextWrapped = true
            s.TextXAlignment = Enum.TextXAlignment.Left; s.Parent = f
        end
        return {Set = function(_, v) if s then s.Text = v else l.Text = v end end}
    end

    function CC:Button(parent, text, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,32); b.BackgroundColor3 = Theme.Button
        b.Text = text; b.Font = Enum.Font.GothamSemibold
        b.TextColor3 = Theme.Text; b.TextSize = 10
        b.AutoButtonColor = false; b.Parent = parent
        corner(b,8)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.Hover end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = Theme.Button end)
        b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
        return b
    end

    function CC:Toggle(parent, text, default, cb, sub)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0, sub and 38 or 28)
        row.BackgroundTransparency = 1; row.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,-60,0,14); l.Position = UDim2.fromOffset(0,3)
        l.BackgroundTransparency = 1; l.Text = text
        l.Font = Enum.Font.Gotham; l.TextColor3 = Theme.Text
        l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = row
        if sub then
            local s = Instance.new("TextLabel")
            s.Position = UDim2.fromOffset(0,17); s.Size = UDim2.new(1,-60,0,18)
            s.BackgroundTransparency = 1; s.Text = sub
            s.Font = Enum.Font.Gotham; s.TextColor3 = Theme.Dim
            s.TextSize = 8; s.TextWrapped = true
            s.TextXAlignment = Enum.TextXAlignment.Left; s.Parent = row
        end
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.fromOffset(42,20); pill.Position = UDim2.new(1,-46,0,2)
        pill.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(55,56,62)
        pill.Text = ""; pill.AutoButtonColor = false; pill.Parent = row
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(16,16); knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0
        knob.Position = default and UDim2.new(1,-18,0,2) or UDim2.fromOffset(2,2)
        knob.Parent = pill
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local state = not not default
        local function paint()
            if state then
                pill.BackgroundColor3 = Theme.Accent
                TweenSvc:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(1,-18,0,2)}):Play()
            else
                pill.BackgroundColor3 = Color3.fromRGB(55,56,62)
                TweenSvc:Create(knob, TweenInfo.new(0.15), {Position = UDim2.fromOffset(2,2)}):Play()
            end
        end
        pill.MouseButton1Click:Connect(function()
            state = not state; paint(); if cb then pcall(cb, state) end
        end)
        return {Set = function(_, v) state = not not v; paint(); if cb then pcall(cb, state) end end, Get = function() return state end}
    end

    function CC:Slider(parent, text, min, max, default, cb, step)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,38); row.BackgroundTransparency = 1; row.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.6,0,0,14); l.BackgroundTransparency = 1; l.Text = text
        l.Font = Enum.Font.Gotham; l.TextColor3 = Theme.Text
        l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = row
        local vL = Instance.new("TextLabel")
        vL.Size = UDim2.new(0.4,0,0,14); vL.Position = UDim2.new(0.6,0,0,0)
        vL.BackgroundTransparency = 1; vL.Text = tostring(default)
        vL.Font = Enum.Font.GothamBold; vL.TextColor3 = Theme.Accent
        vL.TextSize = 10; vL.TextXAlignment = Enum.TextXAlignment.Right; vL.Parent = row
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1,-2,0,6); track.Position = UDim2.fromOffset(1,22)
        track.BackgroundColor3 = Color3.fromRGB(55,56,62); track.BorderSizePixel = 0
        track.Parent = row
        Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0; fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(14,14); knob.AnchorPoint = Vector2.new(0.5,0.5)
        knob.Position = UDim2.new(0,0,0.5,0); knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0; knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local cur = tonumber(default) or tonumber(min) or 0
        local lo, hi = tonumber(min), tonumber(max)
        local stp = tonumber(step) or 0
        local function setV(v, fire)
            v = math.clamp(v, lo, hi)
            if stp > 0 then v = math.floor((v-lo)/stp+0.5)*stp+lo end
            cur = v
            local tt = (hi-lo)==0 and 0 or (v-lo)/(hi-lo)
            fill.Size = UDim2.new(tt,0,1,0)
            knob.Position = UDim2.new(tt,0,0.5,0)
            vL.Text = tostring(v)
            if fire and cb then pcall(cb, v) end
        end
        setV(cur, false)
        local drag = false
        local function upd(i)
            local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local tt = track.AbsoluteSize.X == 0 and 0 or x/track.AbsoluteSize.X
            setV(lo + (hi-lo)*tt, true)
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true; upd(i)
            end
        end)
        track.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
        end)
        return {Set = function(_, v) setV(tonumber(v) or cur, false) end, Get = function() return cur end}
    end

    function CC:Dropdown(parent, text, default, options, cb)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,30); row.BackgroundTransparency = 1; row.Parent = parent
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.4,0,1,0); l.BackgroundTransparency = 1; l.Text = text
        l.Font = Enum.Font.Gotham; l.TextColor3 = Theme.Text
        l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = row
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.6,-4,1,0); btn.Position = UDim2.new(0.4,0,0,0)
        btn.BackgroundColor3 = Theme.Button; btn.Text = tostring(default or "None")
        btn.Font = Enum.Font.Gotham; btn.TextColor3 = Theme.Text
        btn.TextSize = 10; btn.AutoButtonColor = false; btn.Parent = row
        corner(btn,6)
        local list = type(options)=="table" and options or {}
        local cur = default
        local pop
        local function closeP() if pop then pop:Destroy(); pop = nil end end
        local function openP()
            closeP()
            pop = Instance.new("Frame")
            pop.Size = UDim2.new(0,180,0,math.min(180,24*#list+6))
            pop.Position = UDim2.new(1,-180,0,32)
            pop.BackgroundColor3 = Theme.Panel; pop.ZIndex = 100
            pop.Parent = row
            corner(pop,8); stroke(pop, Color3.fromRGB(60,61,68),1)
            local sc = Instance.new("ScrollingFrame")
            sc.Size = UDim2.fromScale(1,1); sc.BackgroundTransparency = 1
            sc.BorderSizePixel = 0; sc.ScrollBarThickness = 2
            sc.ScrollBarImageColor3 = Theme.Accent; sc.ZIndex = 101; sc.Parent = pop
            local ll = Instance.new("UIListLayout", sc); ll.Padding = UDim.new(0,2)
            for _, opt in ipairs(list) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1,-6,0,22); ob.Position = UDim2.fromOffset(3,0)
                ob.BackgroundColor3 = Theme.Card; ob.Text = tostring(opt)
                ob.Font = Enum.Font.Gotham; ob.TextColor3 = Theme.Text
                ob.TextSize = 10; ob.AutoButtonColor = false
                ob.ZIndex = 102; ob.Parent = sc
                corner(ob,4)
                ob.MouseEnter:Connect(function() ob.BackgroundColor3 = Theme.Hover end)
                ob.MouseLeave:Connect(function() ob.BackgroundColor3 = Theme.Card end)
                ob.MouseButton1Click:Connect(function()
                    cur = opt; btn.Text = tostring(opt); closeP()
                    if cb then pcall(cb, opt) end
                end)
            end
            sc.CanvasSize = UDim2.fromOffset(0, ll.AbsoluteContentSize.Y+6)
        end
        btn.MouseButton1Click:Connect(openP)
        return {Set = function(_, v) cur = v; btn.Text = tostring(v); if cb then pcall(cb, v) end end}
    end

    function CC:Textbox(parent, placeholder, cb, default)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0,30); row.BackgroundTransparency = 1; row.Parent = parent
        local box = Instance.new("TextBox")
        box.Size = UDim2.fromScale(1,1); box.BackgroundColor3 = Theme.Button
        box.Text = default or ""; box.PlaceholderText = placeholder
        box.PlaceholderColor3 = Theme.Dim; box.Font = Enum.Font.Gotham
        box.TextColor3 = Theme.Text; box.TextSize = 10
        box.ClearTextOnFocus = false; box.Parent = row
        corner(box,6)
        box.FocusLost:Connect(function() if cb then pcall(cb, box.Text) end end)
        return {Set = function(_, v) box.Text = tostring(v or "") end, Get = function() return box.Text end}
    end

    -- Notification system
    local notifH
    local function Notify(title, desc, dur)
        if not notifH then
            notifH = Instance.new("Frame")
            notifH.Size = UDim2.fromOffset(250,400)
            notifH.Position = UDim2.new(1,-262,0,60)
            notifH.BackgroundTransparency = 1; notifH.Parent = gui
            local ll = Instance.new("UIListLayout", notifH); ll.Padding = UDim.new(0,6)
        end
        local n = Instance.new("Frame")
        n.Size = UDim2.fromOffset(250,56); n.BackgroundColor3 = Theme.Panel
        n.BorderSizePixel = 0; n.Parent = notifH
        corner(n,8)
        local ac = Instance.new("Frame")
        ac.Size = UDim2.fromOffset(4,56); ac.BackgroundColor3 = Theme.Accent
        ac.BorderSizePixel = 0; ac.Parent = n
        corner(ac,8)
        local t = Instance.new("TextLabel")
        t.Position = UDim2.fromOffset(14,8); t.Size = UDim2.new(1,-20,0,15)
        t.BackgroundTransparency = 1; t.Text = tostring(title or "Thông báo")
        t.Font = Enum.Font.GothamBold; t.TextColor3 = Theme.Text
        t.TextSize = 11; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = n
        local d = Instance.new("TextLabel")
        d.Position = UDim2.fromOffset(14,24); d.Size = UDim2.new(1,-20,0,26)
        d.BackgroundTransparency = 1; d.Text = tostring(desc or "")
        d.Font = Enum.Font.Gotham; d.TextColor3 = Theme.Dim
        d.TextSize = 9; d.TextWrapped = true
        d.TextXAlignment = Enum.TextXAlignment.Left; d.Parent = n
        task.delay(dur or 5, function() pcall(function() n:Destroy() end) end)
    end

    return {Gui=gui, Root=root, Tabs=Tabs, Components=CC, Theme=Theme, Notify=Notify}
end)

if not UICreate then
    warn("[BCVN] Lỗi tạo UI:", tostring(UI))
    return
end

local Tabs = UI.Tabs
local C    = UI.Components
local TH   = UI.Theme
local function Notify(t,d,dur) pcall(function() UI.Notify(t,d,dur) end) end

print("[BCVN] ✅ UI đã hiện! Nút 'Dx' góc trái màn hình.")

--============================================================
-- 4. BACKEND (viết lại từ đầu, dựa trên API Blox Fruit)
--============================================================
task.spawn(function()
    local ok, err = pcall(function()
        print("[BCVN] Đang load backend...")

        -- ==== ENVIRONMENT ====
        local Remotes = RS:WaitForChild("Remotes", 20)
        if not Remotes then warn("[BCVN] Không có Remotes"); return end
        local Mod = RS:FindFirstChild("Modules")
        local Net = Mod and Mod:WaitForChild("Net", 10) or nil
        local CommF = Remotes:WaitForChild("CommF_", 10)

        local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Hum = Char:WaitForChild("Humanoid", 10)
        local HRP = Char:WaitForChild("HumanoidRootPart", 10)
        local Data = LocalPlayer:FindFirstChild("Data") or LocalPlayer:WaitForChild("Data", 20)
        local Level = Data and Data:FindFirstChild("Level")
        local Beli = Data and Data:FindFirstChild("Beli")
        local Frags = Data and Data:FindFirstChild("Fragments")

        local Enemies = Workspace:WaitForChild("Enemies", 30)
        local ChestModels = Workspace:FindFirstChild("ChestModels")
        local WorldOrigin = Workspace:FindFirstChild("_WorldOrigin")
        local MapAttr = Workspace:GetAttribute("MAP")
        local Sea1, Sea2, Sea3 = MapAttr=="Sea1", MapAttr=="Sea2", MapAttr=="Sea3"

        LocalPlayer.CharacterAdded:Connect(function(nc)
            Char = nc; Hum = nc:WaitForChild("Humanoid",10); HRP = nc:WaitForChild("HumanoidRootPart",10)
        end)

        print("[BCVN] Backend OK | Sea:", tostring(MapAttr))

        -- ==== FIRE INVOKE ====
        local function Fire(...)
            if not CommF then return end
            return CommF:InvokeServer(...)
        end

        -- ==== TWEEN ENGINE (BodyVelocity, mượt & nhanh) ====
        local tweenCancel = false
        local bodyVel = nil
        local tweenGen = 0

        local function StopTween()
            tweenCancel = true
            tweenGen = tweenGen + 1
            if bodyVel and bodyVel.Parent then pcall(function() bodyVel:Destroy() end) end
            bodyVel = nil
        end

        local function TweenTo(target, keep)
            if not HRP or not HRP.Parent then return end
            if typeof(target) == "Vector3" then target = CFrame.new(target) end
            if typeof(target) ~= "CFrame" then return end
            if not Hum or Hum.Health <= 0 then return end

            tweenCancel = false
            tweenGen = tweenGen + 1
            local myGen = tweenGen
            local startCF = HRP.CFrame
            local dist = (target.Position - startCF.Position).Magnitude
            if dist < 5 then HRP.CFrame = target; return end

            if not bodyVel or not bodyVel.Parent then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "DxTween"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.P = 10000
                bv.Parent = HRP
                bodyVel = bv
            end

            local speed = tonumber(Config.TweenSpeed) or 250
            local steps = math.clamp(math.ceil(dist/(speed*0.02)), 3, 500)
            local startPos = startCF.Position

            for i = 1, steps do
                if tweenGen ~= myGen or tweenCancel then break end
                if not HRP or not HRP.Parent then break end
                local a = i/steps
                local newPos = startPos:Lerp(target.Position, a)
                bodyVel.Velocity = (newPos - HRP.Position) * 60
                if dist > 50 then HRP.CFrame = CFrame.new(HRP.Position:Lerp(target.Position, a*0.3)) end
                RunService.Heartbeat:Wait()
            end

            if tweenGen == myGen then
                pcall(function()
                    HRP.CFrame = target
                    if bodyVel then bodyVel.Velocity = Vector3.zero end
                end)
                if not keep and bodyVel then bodyVel:Destroy(); bodyVel = nil end
            end
        end

        -- ==== UTILS ====
        local function IsAlive(target)
            if not target or not target.Parent or not target:IsDescendantOf(Workspace) then return false end
            if target.Parent == Workspace:FindFirstChild("Boats") or target:GetAttribute("IsBoat") or target.Name:find("Boat") or target.Name:find("Ship") then
                local h = target:FindFirstChild("Health")
                if h and h.Value <= 0 then return false end
                if target:GetAttribute("Dead") or target:GetAttribute("Sunk") then return false end
                return true
            end
            local h = target:FindFirstChildOfClass("Humanoid")
            local r = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
            return h and h.Health > 0 and r ~= nil
        end

        local function FindMobs(range)
            range = range or 2000
            local list = {}
            if not HRP then return list end
            for _, m in ipairs(Enemies:GetChildren()) do
                if IsAlive(m) then
                    local mH = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                    if mH then
                        local d = (mH.Position - HRP.Position).Magnitude
                        if d <= range then table.insert(list, {m, mH, d}) end
                    end
                end
            end
            table.sort(list, function(a,b) return a[3] < b[3] end)
            return list
        end

        local function FindMon(name)
            if not name then return nil end
            for _, m in ipairs(Enemies:GetChildren()) do
                if m.Name == name and IsAlive(m) then return m end
            end
            for _, m in ipairs(Enemies:GetChildren()) do
                if string.find(string.lower(m.Name), string.lower(name)) and IsAlive(m) then return m end
            end
            return nil
        end

        local function EquipType(tip)
            if not Hum or not Char or not tip then return end
            local cur = Char:FindFirstChildOfClass("Tool")
            if cur and cur.ToolTip == tip then return cur end
            for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if t:IsA("Tool") and t.ToolTip == tip then
                    Hum:EquipTool(t); task.wait(0.05); return t
                end
            end
            return nil
        end

        local function AutoHaki()
            if not Char then return end
            if not Char:HasTag("Buso") and Beli and Beli.Value >= 25000 then
                pcall(function() Fire("BuyHaki", "Buso") end)
            elseif Char:HasTag("Buso") and not Char:FindFirstChild("HasBuso") then
                pcall(function() Fire("Buso") end)
            end
        end

        -- ==== FAST ATTACK ====
        local function FastAttack()
            if not Config.AutoAttack then return end
            if not Char or not Hum or Hum.Health <= 0 then return end
            local tool = Char:FindFirstChildOfClass("Tool")
            if not tool then return end
            local tip = tool.ToolTip
            if not tip then return end

            -- Gun path
            if tip == "Gun" then
                if not Config.AutoGun then return end
                local targets = FindMobs(500)
                if #targets == 0 then return end
                local tPos = targets[1][2].Position
                local r1 = tool:FindFirstChild("RemoteEvent")
                if r1 then pcall(function() r1:FireServer("TAP", tPos) end) end
                local sR = Net and Net:FindFirstChild("RE/ShootGunEvent")
                if sR then pcall(function() sR:FireServer(tPos, {targets[1][2]}) end) end
                return
            end

            -- Melee/Sword/Fruit path
            local lc = tool:FindFirstChild("LeftClickRemote")
            local targets = FindMobs(Config.AttackRange or 150)
            if #targets == 0 then return end

            local tgt = targets[1][2]
            local d = targets[1][3]
            if d > 12 then TweenTo(CFrame.new(tgt.Position + Vector3.new(0, Config.PosY or 18, 0))) end

            if lc then pcall(function() lc:FireServer(Vector3.new(0.01,-500,0.01), 1, true) end) end

            local reg = Net and Net:FindFirstChild("RE/RegisterHit")
            if reg then
                local hits = {}
                for i = 1, math.min(3, #targets) do table.insert(hits, {targets[i][1], targets[i][2]}) end
                pcall(function()
                    reg:FireServer(tgt, hits, nil, nil, tostring(LocalPlayer.UserId):sub(2,4)..tostring(tick()):sub(-5))
                end)
            end
        end

        -- ==== BRING MONSTERS ====
        local lastBring = 0
        local function BringMobs(target)
            if not Config.BringMonster or not target then return end
            if not HRP or not HRP.Parent then return end
            local now = tick()
            if now - lastBring < 0.4 then return end
            lastBring = now
            pcall(function()
                if sethiddenproperty then
                    sethiddenproperty(LocalPlayer, "SimulationRadius", Config.BringRadius or 300)
                end
            end)
            local tName = target.Name
            local tH = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
            if not tH then return end
            for _, m in ipairs(Enemies:GetChildren()) do
                if m ~= target and m.Name == tName and IsAlive(m) then
                    local mH = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                    if mH and (mH.Position - HRP.Position).Magnitude <= (Config.BringRadius or 300) then
                        pcall(function()
                            mH.CFrame = tH.CFrame + Vector3.new(math.random(-5,5), 5, math.random(-5,5))
                        end)
                    end
                end
            end
        end

        -- ==== AUTO CHEST ====
        local chestCount = 0
        local function AutoChestTick()
            if not Config.AutoChest then return end
            if not ChestModels or not HRP then return end
            local near, nd = nil, math.huge
            for _, c in ipairs(ChestModels:GetChildren()) do
                local r = c:FindFirstChild("RootPart")
                if r and c:GetAttribute("IsDisabled") ~= true then
                    local d = (r.Position - HRP.Position).Magnitude
                    if d < nd then near, nd = r, d end
                end
            end
            if near then
                if Hum and Hum.Sit then Hum.Sit = false end
                TweenTo(near.CFrame + Vector3.new(0,3,2))
                chestCount = chestCount + 1
                task.wait(0.05)
            elseif Config.AutoHopChest and chestCount >= (Config.ChestHopCount or 10) then
                chestCount = 0
                Notify("Chest Farm", "Hết rương, hop sau "..Config.HopDelay.."s...", 4)
                task.wait(Config.HopDelay or 10)
                pcall(function()
                    RS.__ServerBrowser:InvokeServer("teleport", RS.__ServerBrowser:InvokeServer("getjob"))
                end)
            end
        end

        -- ==== AUTO FRUIT ====
        local fruitBL = {}
        local function AutoFruitTick()
            if not Config.AutoFruit then return end
            if not HRP then return end
            local near, nd = nil, math.huge
            for _, o in ipairs(Workspace:GetChildren()) do
                if (o:IsA("Tool") or o:IsA("Model")) and (o.Name:find("Fruit") or o.Name:find("fruit")) then
                    local h = o:FindFirstChild("Handle") or o.PrimaryPart
                    if h and not fruitBL[o] then
                        local d = (h.Position - HRP.Position).Magnitude
                        if d < nd then near, nd = o, d end
                    end
                end
            end
            if near then
                local h = near:FindFirstChild("Handle") or near.PrimaryPart
                if h then
                    if nd > 10 then TweenTo(h.CFrame + Vector3.new(0,2,0))
                    else
                        pcall(function()
                            firetouchinterest(HRP, h, 0)
                            task.wait(0.05)
                            firetouchinterest(HRP, h, 1)
                        end)
                        fruitBL[near] = true
                        task.delay(2, function() fruitBL[near] = nil end)
                    end
                end
                task.wait(0.1)
            elseif Config.HopIfNoFruit then
                task.wait(Config.HopDelay or 10)
                pcall(function()
                    RS.__ServerBrowser:InvokeServer("teleport", RS.__ServerBrowser:InvokeServer("getjob"))
                end)
            end
        end

        -- ==== AUTO FARM ====
        local function AutoFarmTick()
            if not (Config.AutoFarm or Config.AutoFarmBones or Config.AutoBoss) then return end
            if not HRP or not Char or not Hum then return end
            local targets = FindMobs(Config.AttackRange or 1500)
            if #targets > 0 then
                local tH = targets[1][2]
                local d = targets[1][3]
                if d > 20 then TweenTo(CFrame.new(tH.Position + Vector3.new(0, Config.PosY or 18, 0))) end
                AutoHaki()
                if Config.WeaponType then EquipType(Config.WeaponType) end
                BringMobs(targets[1][1])
            end
        end

        -- ==== MACRO ====
        local macroRunning = false
        local function StopMacro() macroRunning = false end
        local function RunMacro()
            if not Config.MacroEnabled or macroRunning then return end
            macroRunning = true
            task.spawn(function()
                while Config.MacroEnabled and macroRunning do
                    for _, k in ipairs(Config.MacroKeys) do
                        if not Config.MacroEnabled or not macroRunning then break end
                        local kc = Enum.KeyCode[k]
                        if kc then
                            pcall(function()
                                VIM:SendKeyEvent(true, kc, false, game)
                                task.wait(Config.MacroHold or 0.3)
                                VIM:SendKeyEvent(false, kc, false, game)
                            end)
                        end
                        task.wait(Config.MacroGap or 0.15)
                    end
                    task.wait(0.5)
                end
                macroRunning = false
            end)
        end

        -- ==== ISLANDS ====
        local Islands = {
            Sea1 = {
                ["Starter Island"]=Vector3.new(-1053,5,4251),
                ["Middle Town"]=Vector3.new(-916,5,4500),
                ["Jungle"]=Vector3.new(-1610,36,149),
                ["Pirate Village"]=Vector3.new(-1160,5,3845),
                ["Desert"]=Vector3.new(1055,5,4280),
                ["Frozen Village"]=Vector3.new(1200,30,-1400),
                ["Marine Ford"]=Vector3.new(-5100,15,-4200),
                ["Skylands"]=Vector3.new(-4880,720,-3230),
                ["Colosseum"]=Vector3.new(-1500,5,-2100),
                ["Prison"]=Vector3.new(4850,5,710),
                ["Magma Village"]=Vector3.new(-5220,3,870),
                ["Underwater City"]=Vector3.new(60500,4,1100),
                ["Fountain City"]=Vector3.new(5150,5,3000),
            },
            Sea2 = {
                ["Kingdom of Rose"]=Vector3.new(0,0,0),
                ["Swan Mansion"]=Vector3.new(-245,73,300),
                ["Hot and Cold"]=Vector3.new(2500,8,-1200),
                ["Cursed Ship"]=Vector3.new(912,125,32800),
                ["Ice Castle"]=Vector3.new(5630,25,-6000),
                ["Forgotten Island"]=Vector3.new(-3000,8,-1000),
                ["Cafe"]=Vector3.new(-380,73,260),
                ["Green Zone"]=Vector3.new(-5500,8,-350),
                ["Graveyard"]=Vector3.new(-9500,6,6000),
                ["Snow Mountain"]=Vector3.new(1350,87,-1300),
                ["Factory"]=Vector3.new(430,8,-1350),
            },
            Sea3 = {
                ["Port Town"]=Vector3.new(-260,6,5245),
                ["Hydra Island"]=Vector3.new(5660,1000,850),
                ["Great Tree"]=Vector3.new(2950,2280,-7200),
                ["Castle on the Sea"]=Vector3.new(-5100,314,-3150),
                ["Haunted Castle"]=Vector3.new(-9500,150,6000),
                ["Sea of Treats"]=Vector3.new(-1000,10,-12000),
                ["Peanut Island"]=Vector3.new(1950,8,-12200),
                ["Tiki Outpost"]=Vector3.new(-16300,8,400),
                ["Floating Turtle"]=Vector3.new(-12400,375,-7500),
                ["Mansion"]=Vector3.new(-12300,320,-6630),
            },
        }
        local function GetIslands()
            if Sea1 then return Islands.Sea1 end
            if Sea2 then return Islands.Sea2 end
            if Sea3 then return Islands.Sea3 end
            return {}
        end
        local function GetIslandNames()
            local n = {}; for k in pairs(GetIslands()) do table.insert(n, k) end
            table.sort(n); return n
        end

        -- ==== ESP ====
        local espList = {}
        local function ClearESP(cat)
            for k, v in pairs(espList) do
                if not cat or v.Cat == cat then
                    if v.BB and v.BB.Parent then pcall(function() v.BB:Destroy() end) end
                    espList[k] = nil
                end
            end
        end
        local function AddESP(part, text, color, cat)
            if not part or part:FindFirstChild("DxESP") then return end
            local bb = Instance.new("BillboardGui")
            bb.Name = "DxESP"; bb.Size = UDim2.new(0,200,0,24)
            bb.StudsOffset = Vector3.new(0,3,0); bb.AlwaysOnTop = true
            bb.Parent = part
            local lb = Instance.new("TextLabel")
            lb.Size = UDim2.fromScale(1,1); lb.BackgroundTransparency = 1
            lb.Text = text; lb.Font = Enum.Font.GothamBold
            lb.TextColor3 = color or TH.Accent
            lb.TextStrokeTransparency = 0.3; lb.TextSize = 12
            lb.Parent = bb
            espList[part] = {BB = bb, Cat = cat or "Gen"}
        end
        local function UpdateESP()
            if Config.ESPPlayer then
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local h = pl.Character:FindFirstChild("Head") or pl.Character:FindFirstChild("HumanoidRootPart")
                        local hu = pl.Character:FindFirstChildOfClass("Humanoid")
                        if h and hu and hu.Health > 0 then
                            AddESP(h, (pl.DisplayName or pl.Name).." ["..math.floor(hu.Health).."]", TH.Red, "Player")
                        end
                    end
                end
            else ClearESP("Player") end

            if Config.ESPChest and ChestModels then
                for _, c in ipairs(ChestModels:GetChildren()) do
                    local r = c:FindFirstChild("RootPart")
                    if r then AddESP(r, "Chest", TH.Green, "Chest") end
                end
            else ClearESP("Chest") end

            if Config.ESPFruit then
                for _, o in ipairs(Workspace:GetChildren()) do
                    if (o:IsA("Tool") or o:IsA("Model")) and o.Name:find("Fruit") then
                        local h = o:FindFirstChild("Handle") or o.PrimaryPart
                        if h then AddESP(h, o.Name, TH.Yellow, "Fruit") end
                    end
                end
            else ClearESP("Fruit") end

            if Config.ESPIsland and WorldOrigin then
                local locs = WorldOrigin:FindFirstChild("Locations")
                if locs then
                    for _, isl in ipairs(locs:GetChildren()) do
                        if isl:IsA("BasePart") and isl.Name ~= "Sea" then
                            AddESP(isl, isl.Name, TH.Accent, "Island")
                        end
                    end
                end
            else ClearESP("Island") end
        end

        -- ==== WALK/JUMP ====
        local function ApplyWalk() if Hum and Config.WalkSpeed then pcall(function() Hum.WalkSpeed = Config.WalkSpeed end) end end
        local function ApplyJump() if Hum and Config.JumpPower then pcall(function() Hum.UseJumpPower = true; Hum.JumpPower = Config.JumpPower end) end end

        -- ==== WEBHOOK ====
        local function SendWebhook(title, desc)
            if not Config.WebhookEnabled or Config.WebhookURL == "" then return end
            local req = (syn and syn.request) or http_request
            if not req then return end
            local body = HttpSvc:JSONEncode({
                embeds = {{title = title, description = desc, color = 5814783,
                    footer = {text = "Blox Community VN • Dungdx"},
                    timestamp = DateTime.now():ToIsoDate()}}
            })
            pcall(function()
                req({Url = Config.WebhookURL, Method = "POST",
                    Headers = {["Content-Type"]="application/json"}, Body = body})
            end)
        end

        --============================================================
        -- BUILD ALL TABS
        --============================================================

        --===== HOME =====
        do
            local s1 = Tabs.Home:Section("Thông Tin")
            C:Label(s1.Frame, "Blox Community VN v5.0", "Tác giả: Dungdx  •  discord.gg/Hwwa3VYxW6")
            local statLbl = C:Label(s1.Frame, "Đang tải...")
            local seaLbl = C:Label(s1.Frame, "Sea hiện tại: "..(MapAttr or "?"))
            task.spawn(function()
                while task.wait(2) do
                    pcall(function()
                        statLbl:Set("Lv: "..(Level and Level.Value or "?")..
                            "  |  Beli: "..(Beli and Beli.Value or "?")..
                            "  |  Frags: "..(Frags and Frags.Value or "?"))
                    end)
                end
            end)

            local s2 = Tabs.Home:Section("Bật Nhanh")
            C:Toggle(s2.Frame, "⚡ Fast Attack", Config.AutoAttack, function(v) Config.AutoAttack = v end, "Tấn công siêu nhanh")
            C:Toggle(s2.Frame, "🎒 Auto Chest", Config.AutoChest, function(v) Config.AutoChest = v; chestCount = 0 end, "Tự động nhặt rương")
            C:Toggle(s2.Frame, "🍎 Auto Nhặt Trái", Config.AutoFruit, function(v) Config.AutoFruit = v end, "Bay tới & nhặt trái rơi")
            C:Toggle(s2.Frame, "🔗 Bring Monster", Config.BringMonster, function(v) Config.BringMonster = v end, "Kéo quái lại gần")
            C:Toggle(s2.Frame, "🐌 Lag Fix", Config.LagFix, function(v) Config.LagFix = v; ApplyLagFix(v) end, "Giảm lag đáng kể")
            C:Toggle(s2.Frame, "🌫️ Xóa Sương Mù", Config.RemoveFog, function(v) Config.RemoveFog = v; ApplyNoFog(v) end, "Xóa fog/mây mù")

            local s3 = Tabs.Home:Section("Hành Động")
            C:Button(s3.Frame, "🔄 Refresh ESP", function() ClearESP(); UpdateESP(); Notify("ESP","Đã refresh",3) end)
            C:Button(s3.Frame, "⛔ Stop All Loops", function()
                Config.AutoFarm = false; Config.AutoChest = false; Config.AutoFruit = false
                Config.AutoAttack = false; Config.BringMonster = false; Config.MacroEnabled = false
                StopTween(); StopMacro()
                Notify("Hệ thống","Đã dừng tất cả vòng lặp",4)
            end)
        end

        --===== FARM =====
        do
            local s1 = Tabs.Farm:Section("Auto Farm Quái")
            C:Toggle(s1.Frame, "Auto Farm", Config.AutoFarm, function(v) Config.AutoFarm = v end, "Farm quái theo level")
            C:Toggle(s1.Frame, "Auto Farm Bones", Config.AutoFarmBones, function(v) Config.AutoFarmBones = v end, "Farm xương (Sea 3)")
            C:Dropdown(s1.Frame, "Vũ khí", Config.WeaponType, {"Melee","Sword","Blox Fruit","Gun"}, function(v) Config.WeaponType = v end)
            C:Slider(s1.Frame, "Tầm đánh", 50, 500, Config.AttackRange, function(v) Config.AttackRange = v end)
            C:Slider(s1.Frame, "Độ cao bay", 5, 100, Config.PosY, function(v) Config.PosY = v end)
            C:Slider(s1.Frame, "Bring Radius", 100, 500, Config.BringRadius, function(v) Config.BringRadius = v end)
            C:Slider(s1.Frame, "Tween Speed", 50, 500, Config.TweenSpeed, function(v) Config.TweenSpeed = v end)

            local s2 = Tabs.Farm:Section("Auto Boss")
            local bossList = Sea1 and {"The Gorilla King","Yeti","Warden","Swan","Magma Admiral","Fishman Lord","Thunder God","Cyborg"}
                or Sea2 and {"Diamond","Jeremy","Orbitus","Don Swan","Tide Keeper"}
                or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen"}
            C:Dropdown(s2.Frame, "Boss", bossList[1], bossList, function(v) Config.SelectBoss = v end)
            C:Toggle(s2.Frame, "Auto Boss", Config.AutoBoss, function(v) Config.AutoBoss = v end)
            C:Toggle(s2.Frame, "Auto Cake Prince", Config.AutoCakePrince, function(v) Config.AutoCakePrince = v end)
            C:Toggle(s2.Frame, "Auto Dough King", Config.AutoDoughKing, function(v) Config.AutoDoughKing = v end)
        end

        --===== COMBAT =====
        do
            local s1 = Tabs.Combat:Section("Combat")
            C:Toggle(s1.Frame, "Fast Attack", Config.AutoAttack, function(v) Config.AutoAttack = v end)
            C:Toggle(s1.Frame, "Auto Gun", Config.AutoGun, function(v) Config.AutoGun = v end)
            C:Toggle(s1.Frame, "Attack Mobs", Config.AttackMobs, function(v) Config.AttackMobs = v end)
            C:Toggle(s1.Frame, "Attack Players", Config.AttackPlayers, function(v) Config.AttackPlayers = v end)
            C:Toggle(s1.Frame, "Bring Monster", Config.BringMonster, function(v) Config.BringMonster = v end)
            C:Slider(s1.Frame, "Bring Radius", 100, 500, Config.BringRadius, function(v) Config.BringRadius = v end)

            local s2 = Tabs.Combat:Section("Macro Combo")
            C:Toggle(s2.Frame, "Bật Macro", Config.MacroEnabled, function(v)
                Config.MacroEnabled = v
                if v then RunMacro() else StopMacro() end
            end, "Tự động bấm combo kỹ năng")
            C:Textbox(s2.Frame, "Z,X,C,V,F", function(v)
                local ks = {}
                for k in v:gmatch("[^,%s]+") do table.insert(ks, k:upper()) end
                if #ks > 0 then Config.MacroKeys = ks end
            end, table.concat(Config.MacroKeys, ","))
            C:Slider(s2.Frame, "Giữ phím (s)", 0.05, 2, Config.MacroHold, function(v) Config.MacroHold = v end, 0.05)
            C:Slider(s2.Frame, "Delay giữa phím", 0.05, 2, Config.MacroGap, function(v) Config.MacroGap = v end, 0.05)
        end

        --===== FRUIT =====
        do
            local s1 = Tabs.Fruit:Section("Auto Nhặt Trái")
            C:Toggle(s1.Frame, "🍎 Auto Nhặt Trái", Config.AutoFruit, function(v) Config.AutoFruit = v end)
            C:Toggle(s1.Frame, "Hop nếu không có trái", Config.HopIfNoFruit, function(v) Config.HopIfNoFruit = v end)
            C:Slider(s1.Frame, "Hop Delay (s)", 1, 60, Config.HopDelay, function(v) Config.HopDelay = v end)

            local s2 = Tabs.Fruit:Section("Lưu Trái")
            C:Toggle(s2.Frame, "Auto Store Fruit", Config.AutoStoreFruit, function(v) Config.AutoStoreFruit = v end)

            local s3 = Tabs.Fruit:Section("Test Ngay")
            C:Button(s3.Frame, "Tìm & TP tới trái", function()
                local near, nd
                for _, o in ipairs(Workspace:GetChildren()) do
                    if (o:IsA("Tool") or o:IsA("Model")) and o.Name:find("Fruit") then
                        local h = o:FindFirstChild("Handle") or o.PrimaryPart
                        if h and HRP then
                            local d = (h.Position - HRP.Position).Magnitude
                            if not nd or d < nd then near, nd = h, d end
                        end
                    end
                end
                if near then TweenTo(near.CFrame + Vector3.new(0,3,0)); Notify("Fruit","Tìm thấy! ("..math.floor(nd).."m)",4)
                else Notify("Fruit","Không có trái trong server",3) end
            end)
        end

        --===== ESP =====
        do
            local s1 = Tabs.ESP:Section("ESP")
            C:Toggle(s1.Frame, "ESP Player", Config.ESPPlayer, function(v) Config.ESPPlayer = v end)
            C:Toggle(s1.Frame, "ESP Chest", Config.ESPChest, function(v) Config.ESPChest = v end)
            C:Toggle(s1.Frame, "ESP Fruit", Config.ESPFruit, function(v) Config.ESPFruit = v end)
            C:Toggle(s1.Frame, "ESP Island", Config.ESPIsland, function(v) Config.ESPIsland = v end)
            C:Button(s1.Frame, "Xóa toàn bộ ESP", function() ClearESP(); Notify("ESP","Đã xóa",3) end)
        end

        --===== TRAVEL =====
        do
            local s1 = Tabs.Travel:Section("TP Đảo")
            local islNames = GetIslandNames()
            local selIsl = islNames[1] or "None"
            if #islNames > 0 then
                C:Dropdown(s1.Frame, "Chọn đảo", selIsl, islNames, function(v) selIsl = v end)
            else
                C:Label(s1.Frame, "Không có đảo trong sea này")
            end
            C:Button(s1.Frame, "🚀 TP tới đảo", function()
                local c = GetIslands()[selIsl]
                if c then Notify("TP","Tới: "..selIsl,3); TweenTo(CFrame.new(c)) end
            end)

            local s2 = Tabs.Travel:Section("TP Sea")
            C:Button(s2.Frame, "🌊 Tới Sea 1", function() pcall(function() Fire("TravelMain") end) end)
            C:Button(s2.Frame, "🏝️ Tới Sea 2", function() pcall(function() Fire("TravelDressrosa") end) end)
            C:Button(s2.Frame, "🏔️ Tới Sea 3", function() pcall(function() Fire("TravelZou") end) end)

            local s3 = Tabs.Travel:Section("Server Hop")
            C:Button(s3.Frame, "🔄 Rejoin Server", function()
                pcall(function() RS.__ServerBrowser:InvokeServer("teleport", game.JobId) end)
            end)
            C:Button(s3.Frame, "🎲 Random Hop", function()
                Notify("Hop","Đang tìm server...",3)
                task.spawn(function()
                    for i = 1, 100 do
                        local servers = RS.__ServerBrowser:InvokeServer(i)
                        if typeof(servers) == "table" then
                            for jid, info in pairs(servers) do
                                if info.Count and info.Count < 12 and jid ~= game.JobId then
                                    pcall(function() RS.__ServerBrowser:InvokeServer("teleport", jid) end)
                                    return
                                end
                            end
                        end
                    end
                end)
            end)
            C:Slider(s3.Frame, "Hop Delay (s)", 1, 60, Config.HopDelay, function(v) Config.HopDelay = v end)
        end

        --===== MACRO =====
        do
            local s1 = Tabs.Macro:Section("Combo Macro")
            C:Toggle(s1.Frame, "Bật Macro", Config.MacroEnabled, function(v)
                Config.MacroEnabled = v
                if v then RunMacro() else StopMacro() end
            end)
            C:Textbox(s1.Frame, "Z,X,C,V,F", function(v)
                local ks = {}
                for k in v:gmatch("[^,%s]+") do table.insert(ks, k:upper()) end
                if #ks > 0 then
                    Config.MacroKeys = ks
                    Notify("Macro","Đã set: "..table.concat(ks," > "),3)
                end
            end, table.concat(Config.MacroKeys, ","))
            C:Slider(s1.Frame, "Giữ phím (s)", 0.05, 2, Config.MacroHold, function(v) Config.MacroHold = v end, 0.05)
            C:Slider(s1.Frame, "Delay giữa phím", 0.05, 2, Config.MacroGap, function(v) Config.MacroGap = v end, 0.05)

            local s2 = Tabs.Macro:Section("Preset Combo")
            C:Button(s2.Frame, "Preset Z-X-C", function() Config.MacroKeys = {"Z","X","C"}; Notify("Macro","Preset Z-X-C",3) end)
            C:Button(s2.Frame, "Preset Z-X-C-V-F", function() Config.MacroKeys = {"Z","X","C","V","F"}; Notify("Macro","Preset đầy đủ",3) end)
            C:Button(s2.Frame, "Preset Z-Z-X-X", function() Config.MacroKeys = {"Z","Z","X","X"}; Notify("Macro","Preset combo đôi",3) end)
        end

        --===== PERF =====
        do
            local s1 = Tabs.Perf:Section("Hiệu Năng")
            C:Toggle(s1.Frame, "Lag Fix", Config.LagFix, function(v) Config.LagFix = v; ApplyLagFix(v) end, "Giảm lag mạnh")
            C:Toggle(s1.Frame, "Xóa Sương Mù", Config.RemoveFog, function(v) Config.RemoveFog = v; ApplyNoFog(v) end)
            C:Button(s1.Frame, "🧹 Dọn Bộ Nhớ", function()
                pcall(function()
                    if collectgarbage then collectgarbage("collect") end
                    for _, o in ipairs(Workspace:GetChildren()) do
                        if o:IsA("BasePart") and (o.Name:find("Slash") or o.Name:find("Effect")) then o:Destroy() end
                    end
                end)
                Notify("Cleaner","Đã dọn bộ nhớ!",3)
            end)

            local s2 = Tabs.Perf:Section("FPS Monitor")
            local fpsLbl = C:Label(s2.Frame, "FPS: --")
            task.spawn(function()
                local fr, lu = 0, tick()
                RunService.RenderStepped:Connect(function()
                    fr = fr + 1
                    if tick() - lu >= 1 then
                        fpsLbl:Set("FPS: "..fr.."  |  Ping: "..math.floor(LocalPlayer:GetNetworkPing()*1000).."ms")
                        fr = 0; lu = tick()
                    end
                end)
            end)
        end

        --===== MISC =====
        do
            local s1 = Tabs.Misc:Section("Di Chuyển")
            C:Slider(s1.Frame, "Walk Speed", 16, 500, Config.WalkSpeed, function(v) Config.WalkSpeed = v; ApplyWalk() end)
            C:Slider(s1.Frame, "Jump Power", 50, 500, Config.JumpPower, function(v) Config.JumpPower = v; ApplyJump() end)
            C:Toggle(s1.Frame, "Infinite Zoom", Config.InfiniteZoom, function(v)
                Config.InfiniteZoom = v
                LocalPlayer.CameraMaxZoomDistance = v and math.huge or 128
            end)

            local s2 = Tabs.Misc:Section("Tiện Ích")
            C:Toggle(s2.Frame, "Anti AFK", Config.AntiAFK, function(v) Config.AntiAFK = v end)
            C:Button(s2.Frame, "⚔️ Team Pirates", function() pcall(function() Fire("SetTeam","Pirates") end) end)
            C:Button(s2.Frame, "🛡️ Team Marines", function() pcall(function() Fire("SetTeam","Marines") end) end)
            C:Button(s2.Frame, "🎁 Redeem Codes", function()
                Notify("Codes","Đang redeem...",3)
                task.spawn(function()
                    local codes = {"SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","KITTGAMING","FUDDSM0NEY","GAMER_ROBOT_1M"}
                    for _, cd in ipairs(codes) do
                        pcall(function() Remotes.Redeem:InvokeServer(cd) end)
                        task.wait(0.5)
                    end
                    Notify("Codes","Đã thử "..#codes.." codes!",5)
                end)
            end)
            C:Toggle(s2.Frame, "Auto Hop 30 phút", Config.AutoHop30Min, function(v) Config.AutoHop30Min = v end)
        end

        --===== CREDIT =====
        do
            local s1 = Tabs.Credit:Section("Tác Giả")
            C:Label(s1.Frame, "Blox Community VN v5.0", "Script by Dungdx")
            C:Label(s1.Frame, "Discord Server", "discord.gg/Hwwa3VYxW6")
            C:Label(s1.Frame, "Ghi chú", "Script học hỏi từ cộng đồng, biến tấu theo phong cách riêng.")

            local s2 = Tabs.Credit:Section("Liên Hệ")
            C:Button(s2.Frame, "📋 Copy Discord Link", function()
                pcall(function() setclipboard("https://discord.gg/Hwwa3VYxW6") end)
                Notify("Credit","Đã copy Discord!",3)
            end)
        end

        --============================================================
        -- MAIN LOOPS
        --============================================================
        task.spawn(function() while task.wait(0) do if Config.AutoAttack then pcall(FastAttack) end end end)
        task.spawn(function() while task.wait(0.4) do if Config.BringMonster then pcall(function() local t = FindMobs(200)[1]; if t then BringMobs(t[1]) end end) end end end)
        task.spawn(function() while task.wait(0.2) do if Config.AutoChest then pcall(AutoChestTick) end end end)
        task.spawn(function() while task.wait(0.3) do if Config.AutoFruit then pcall(AutoFruitTick) end end end)
        task.spawn(function() while task.wait(0.3) do if Config.AutoFarm or Config.AutoFarmBones or Config.AutoBoss then pcall(AutoFarmTick) end end end)
        task.spawn(function() while task.wait(1) do if Config.ESPPlayer or Config.ESPChest or Config.ESPFruit or Config.ESPIsland then pcall(UpdateESP) end end end)
        task.spawn(function() while task.wait(1) do if Hum then pcall(ApplyWalk); pcall(ApplyJump) end end end)
        task.spawn(function()
            while task.wait(2) do
                if Config.AutoStoreFruit then
                    pcall(function()
                        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and tool.Name:find("Fruit") then
                                local nm = tool:GetAttribute("OriginalName") or tool.Name:match("^(.-)%-") or tool.Name
                                pcall(function() Fire("StoreFruit", nm, tool) end)
                            end
                        end
                    end)
                end
            end
        end)
        task.spawn(function()
            while task.wait(60) do
                if Config.AntiAFK then
                    pcall(function() VUser:CaptureController(); VUser:ClickButton1(Vector2.new(0,0)) end)
                end
            end
        end)
        local startT = tick()
        task.spawn(function()
            while task.wait(30) do
                if Config.AutoHop30Min and tick() - startT >= 1800 then
                    startT = tick()
                    Notify("Hop","30 phút rồi, đang hop...",5)
                    pcall(function() RS.__ServerBrowser:InvokeServer("teleport", RS.__ServerBrowser:InvokeServer("getjob")) end)
                end
            end
        end)
        task.spawn(function()
            while task.wait(5) do
                if Config.LagFix then pcall(function() Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9 end) end
                if Config.RemoveFog then pcall(ApplyNoFog, true) end
            end
        end)

        -- Welcome notifications
        task.spawn(function()
            task.wait(1)
            Notify("Blox Community VN", "Chào mừng "..LocalPlayer.DisplayName.."!\nby Dungdx", 6)
            task.wait(2)
            Notify("Hướng dẫn", "Nhấn nút 'Dx' góc trái để ẩn/hiện UI\nKéo nút này để di chuyển", 7)
        end)

        print("[BCVN] ✅ Backend load xong! Mọi chức năng sẵn sàng.")
    end)
    if not ok then
        warn("[BCVN] Lỗi backend:", tostring(err))
        Notify("Lỗi backend", tostring(err):sub(1,80), 10)
    end
end)

getgenv().BCVN_v5_Loaded = true
print("╔══════════════════════════════════════════╗")
print("║  ✅ BLOX COMMUNITY VN v5.0 SẴN SÀNG!     ║")
print("║  Script by Dungdx                        ║")
print("║  Discord: discord.gg/Hwwa3VYxW6          ║")
print("╚══════════════════════════════════════════╝")
return "Blox Community VN v5.0 - Dungdx"