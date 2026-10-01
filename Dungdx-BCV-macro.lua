--[[
============================================================
    Dungdx PvP · Blox Fruits Script · v2.1.0
    Full build · Mobile friendly · Responsive
============================================================
]]

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(.3)
if _G.DungdxPvP then pcall(function() _G.DungdxPvP:Destroy() end) end

-- ============================================================
-- SERVICES
-- ============================================================
local Players   = game:GetService("Players")
local UIS       = game:GetService("UserInputService")
local VIM       = game:GetService("VirtualInputManager")
local TW        = game:GetService("TweenService")
local RS        = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting  = game:GetService("Lighting")
local Cam       = Workspace.CurrentCamera
local LP        = Players.LocalPlayer

local function getGuiParent()
    local ok, h = pcall(gethui)
    if ok and h then return h end
    return LP:WaitForChild("PlayerGui")
end
local GUI_PARENT = getGuiParent()

-- ============================================================
-- THEME
-- ============================================================
local T = {
    Bg       = Color3.fromRGB(10, 15, 30),
    Sidebar  = Color3.fromRGB(13, 20, 40),
    Panel    = Color3.fromRGB(19, 27, 50),
    Card     = Color3.fromRGB(23, 33, 60),
    CardHi   = Color3.fromRGB(30, 42, 76),
    Input    = Color3.fromRGB(12, 16, 28),
    Accent   = Color3.fromRGB(59, 130, 246),
    Accent2  = Color3.fromRGB(37, 99, 235),
    On       = Color3.fromRGB(59, 130, 246),
    Off      = Color3.fromRGB(42, 54, 88),
    Text     = Color3.fromRGB(230, 240, 255),
    Sub      = Color3.fromRGB(120, 140, 180),
    Stroke   = Color3.fromRGB(38, 52, 92),
    Danger   = Color3.fromRGB(239, 68, 68),
    Green    = Color3.fromRGB(80, 240, 180),
    Red      = Color3.fromRGB(255, 80, 100),
    Cyan     = Color3.fromRGB(0, 220, 255),
}

-- ============================================================
-- UTILS
-- ============================================================
local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function stroke(p, c, t, tr)
    local s = Instance.new("UIStroke", p)
    s.Color = c or T.Stroke
    s.Thickness = t or 1
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function grad(p, a, b, r)
    local g = Instance.new("UIGradient", p)
    g.Color = ColorSequence.new(a, b)
    g.Rotation = r or 45
    return g
end

local function drag(f, h)
    h = h or f
    local on, st, sp
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            on = true; st = i.Position; sp = f.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if on and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - st
            f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            on = false
        end
    end)
end

-- ============================================================
-- SCREENGUI
-- ============================================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "DungdxPvP"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder = 9999
GUI.Parent = GUI_PARENT

-- ============================================================
-- MAIN + RESPONSIVE
-- ============================================================
local DESIGN_W, DESIGN_H = 820, 520

local Main = Instance.new("Frame", GUI)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(DESIGN_W, DESIGN_H)
Main.BackgroundColor3 = T.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
corner(Main, 14)
stroke(Main, T.Stroke, 1.5)

local Responsive = { device = "pc", autoScale = 1, userScale = 1, uiScale = nil }
Responsive.uiScale = Instance.new("UIScale", Main)
Responsive.uiScale.Scale = 1

local function detectDevice()
    local vp = Cam.ViewportSize
    local isTouch = UIS.TouchEnabled and not UIS.KeyboardEnabled
    if isTouch or vp.X < 720 then return "mobile"
    elseif vp.X < 1100 then return "tablet"
    else return "pc" end
end

local function computeAutoScale()
    local vp = Cam.ViewportSize
    local availW = math.max(vp.X - 24, 200)
    local availH = math.max(vp.Y - 48, 200)
    return math.clamp(math.min(availW / DESIGN_W, availH / DESIGN_H), 0.70, 1.35)
end

local applyResponsiveLayout = nil

local applyScale = function()
    Responsive.device = detectDevice()
    Responsive.autoScale = computeAutoScale()
    Responsive.uiScale.Scale = Responsive.autoScale * Responsive.userScale
    if _G.__toggleBtnRef then
        local s = Responsive.autoScale * Responsive.userScale
        local bs = math.floor(52 * math.clamp(s, 0.85, 1.2))
        _G.__toggleBtnRef.Size = UDim2.fromOffset(bs, bs)
    end
    if applyResponsiveLayout then applyResponsiveLayout() end
end

Cam:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)

_G.__setUserScale = function(v)
    Responsive.userScale = v / 100
    applyScale()
end

-- ============================================================
-- HEADER
-- ============================================================
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = T.Sidebar
Header.BorderSizePixel = 0
corner(Header, 14)
local hc = Instance.new("Frame", Header)
hc.Size = UDim2.new(1, 0, 0, 16)
hc.Position = UDim2.new(0, 0, 1, -16)
hc.BackgroundColor3 = T.Sidebar
hc.BorderSizePixel = 0
drag(Main, Header)

local Logo = Instance.new("Frame", Header)
Logo.Size = UDim2.fromOffset(40, 40)
Logo.Position = UDim2.fromOffset(14, 10)
Logo.BackgroundColor3 = T.Accent2
Logo.BorderSizePixel = 0
corner(Logo, 10)
grad(Logo, Color3.fromRGB(96,165,250), Color3.fromRGB(37,99,235))

local LT = Instance.new("TextLabel", Logo)
LT.Size = UDim2.fromScale(1,1)
LT.BackgroundTransparency = 1
LT.Text = "🅳"
LT.Font = Enum.Font.GothamBlack
LT.TextSize = 22
LT.TextColor3 = Color3.fromRGB(255,255,255)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.fromOffset(220, 22)
Title.Position = UDim2.fromOffset(64, 10)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Dungdx PvP"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextColor3 = T.Text
Title.TextXAlignment = Enum.TextXAlignment.Left

local Sub = Instance.new("TextLabel", Header)
Sub.Size = UDim2.fromOffset(220, 16)
Sub.Position = UDim2.fromOffset(64, 32)
Sub.BackgroundTransparency = 1
Sub.Text = "Blox Fruits Script"
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 12
Sub.TextColor3 = T.Accent
Sub.TextXAlignment = Enum.TextXAlignment.Left

local Ver = Instance.new("TextLabel", Header)
Ver.Size = UDim2.fromOffset(62, 24)
Ver.Position = UDim2.fromOffset(240, 18)
Ver.BackgroundColor3 = T.Accent2
Ver.Text = "v2.1.0"
Ver.Font = Enum.Font.GothamBold
Ver.TextSize = 11
Ver.TextColor3 = Color3.fromRGB(220,235,255)
Ver.BorderSizePixel = 0
corner(Ver, 12)

local Close = Instance.new("TextButton", Header)
Close.Size = UDim2.fromOffset(30, 30)
Close.AnchorPoint = Vector2.new(1, 0)
Close.Position = UDim2.new(1, -14, 0, 15)
Close.BackgroundColor3 = T.Card
Close.Text = "✕"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.TextColor3 = T.Text
Close.BorderSizePixel = 0
Close.AutoButtonColor = false
corner(Close, 8)

local Min = Instance.new("TextButton", Header)
Min.Size = UDim2.fromOffset(30, 30)
Min.AnchorPoint = Vector2.new(1, 0)
Min.Position = UDim2.new(1, -50, 0, 15)
Min.BackgroundColor3 = T.Card
Min.Text = "—"
Min.Font = Enum.Font.GothamBold
Min.TextSize = 14
Min.TextColor3 = T.Text
Min.BorderSizePixel = 0
Min.AutoButtonColor = false
corner(Min, 8)

-- ============================================================
-- BODY
-- ============================================================
local Body = Instance.new("Frame", Main)
Body.Size = UDim2.new(1, 0, 1, -60)
Body.Position = UDim2.new(0, 0, 0, 60)
Body.BackgroundTransparency = 1

local Sidebar = Instance.new("Frame", Body)
Sidebar.Size = UDim2.new(0, 170, 1, 0)
Sidebar.BackgroundColor3 = T.Sidebar
Sidebar.BorderSizePixel = 0
local sbCover = Instance.new("Frame", Sidebar)
sbCover.Size = UDim2.new(0, 16, 1, 0)
sbCover.Position = UDim2.new(1, -16, 0, 0)
sbCover.BackgroundColor3 = T.Sidebar
sbCover.BorderSizePixel = 0

local NavList = Instance.new("Frame", Sidebar)
NavList.Size = UDim2.new(1, -16, 1, -80)
NavList.Position = UDim2.fromOffset(8, 8)
NavList.BackgroundTransparency = 1
local NavLayout = Instance.new("UIListLayout", NavList)
NavLayout.Padding = UDim.new(0, 4)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Owner = Instance.new("Frame", Sidebar)
Owner.Size = UDim2.new(1, -16, 0, 44)
Owner.AnchorPoint = Vector2.new(0.5, 1)
Owner.Position = UDim2.new(0.5, 0, 1, -8)
Owner.BackgroundColor3 = T.Card
Owner.BorderSizePixel = 0
corner(Owner, 10)
stroke(Owner, T.Stroke, 1)

local OI = Instance.new("Frame", Owner)
OI.Size = UDim2.fromOffset(28, 28)
OI.Position = UDim2.fromOffset(8, 8)
OI.BackgroundColor3 = T.Accent2
OI.BorderSizePixel = 0
corner(OI, 8)

local OIT = Instance.new("TextLabel", OI)
OIT.Size = UDim2.fromScale(1,1)
OIT.BackgroundTransparency = 1
OIT.Text = "♛"
OIT.Font = Enum.Font.GothamBold
OIT.TextSize = 16
OIT.TextColor3 = Color3.fromRGB(255,255,255)

local ON1 = Instance.new("TextLabel", Owner)
ON1.Size = UDim2.new(1, -46, 0, 16)
ON1.Position = UDim2.fromOffset(44, 6)
ON1.BackgroundTransparency = 1
ON1.Text = "Dungdx"
ON1.Font = Enum.Font.GothamBold
ON1.TextSize = 12
ON1.TextColor3 = T.Text
ON1.TextXAlignment = Enum.TextXAlignment.Left

local ON2 = Instance.new("TextLabel", Owner)
ON2.Size = UDim2.new(1, -46, 0, 14)
ON2.Position = UDim2.fromOffset(44, 22)
ON2.BackgroundTransparency = 1
ON2.Text = "Fast · Safe · Smooth"
ON2.Font = Enum.Font.Gotham
ON2.TextSize = 9
ON2.TextColor3 = T.Sub
ON2.TextXAlignment = Enum.TextXAlignment.Left

local Content = Instance.new("Frame", Body)
Content.Size = UDim2.new(1, -170, 1, 0)
Content.Position = UDim2.new(0, 170, 0, 0)
Content.BackgroundTransparency = 1

-- ============================================================
-- RESPONSIVE LAYOUT RULES
-- ============================================================
applyResponsiveLayout = function()
    if Responsive.device == "mobile" then
        Sidebar.Size = UDim2.new(0, 132, 1, 0)
        sbCover.Position = UDim2.new(1, -16, 0, 0)
        Content.Position = UDim2.new(0, 132, 0, 0)
        Content.Size = UDim2.new(1, -132, 1, 0)
        NavList.Position = UDim2.fromOffset(6, 6)
        NavList.Size = UDim2.new(1, -12, 1, -56)
        Owner.Size = UDim2.new(1, -12, 0, 40)
        Owner.Position = UDim2.new(0.5, 0, 1, -6)
        OI.Size = UDim2.fromOffset(24, 24)
        OI.Position = UDim2.fromOffset(8, 8)
        ON1.Position = UDim2.fromOffset(38, 4)
        ON2.Position = UDim2.fromOffset(38, 20)
        ON2.Text = "Fast · Safe"
        Sub.Visible = false
        Ver.Position = UDim2.fromOffset(200, 18)
    elseif Responsive.device == "tablet" then
        Sidebar.Size = UDim2.new(0, 155, 1, 0)
        sbCover.Position = UDim2.new(1, -16, 0, 0)
        Content.Position = UDim2.new(0, 155, 0, 0)
        Content.Size = UDim2.new(1, -155, 1, 0)
        NavList.Position = UDim2.fromOffset(8, 8)
        NavList.Size = UDim2.new(1, -16, 1, -70)
        Owner.Size = UDim2.new(1, -16, 0, 44)
        Owner.Position = UDim2.new(0.5, 0, 1, -8)
        OI.Size = UDim2.fromOffset(28, 28)
        OI.Position = UDim2.fromOffset(8, 8)
        ON1.Position = UDim2.fromOffset(44, 6)
        ON2.Position = UDim2.fromOffset(44, 22)
        ON2.Text = "Fast · Safe · Smooth"
        Sub.Visible = true
        Ver.Position = UDim2.fromOffset(240, 18)
    else
        Sidebar.Size = UDim2.new(0, 170, 1, 0)
        sbCover.Position = UDim2.new(1, -16, 0, 0)
        Content.Position = UDim2.new(0, 170, 0, 0)
        Content.Size = UDim2.new(1, -170, 1, 0)
        NavList.Position = UDim2.fromOffset(8, 8)
        NavList.Size = UDim2.new(1, -16, 1, -80)
        Owner.Size = UDim2.new(1, -16, 0, 44)
        Owner.Position = UDim2.new(0.5, 0, 1, -8)
        OI.Size = UDim2.fromOffset(28, 28)
        OI.Position = UDim2.fromOffset(8, 8)
        ON1.Position = UDim2.fromOffset(44, 6)
        ON2.Position = UDim2.fromOffset(44, 22)
        ON2.Text = "Fast · Safe · Smooth"
        Sub.Visible = true
        Ver.Position = UDim2.fromOffset(240, 18)
    end
end

task.defer(applyScale)

-- ============================================================
-- NAV / PAGES
-- ============================================================
local Pages = {}
local NavBtns = {}

local function makePage()
    local p = Instance.new("ScrollingFrame", Content)
    p.Size = UDim2.new(1, -24, 1, -16)
    p.Position = UDim2.fromOffset(12, 8)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = T.Accent
    p.ScrollBarImageTransparency = 0.4
    p.CanvasSize = UDim2.new()
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    local ll = Instance.new("UIListLayout", p)
    ll.Padding = UDim.new(0, 10)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    return p
end

local function addTab(id, icon, label, order)
    local page = makePage()
    Pages[id] = page
    local btn = Instance.new("TextButton", NavList)
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = T.Sidebar
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    corner(btn, 10)

    local ic = Instance.new("TextLabel", btn)
    ic.Size = UDim2.fromOffset(24, 24)
    ic.Position = UDim2.fromOffset(14, 9)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.Font = Enum.Font.GothamBold
    ic.TextSize = 15
    ic.TextColor3 = T.Sub

    local lb = Instance.new("TextLabel", btn)
    lb.Size = UDim2.new(1, -50, 1, 0)
    lb.Position = UDim2.fromOffset(46, 0)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.Font = Enum.Font.GothamMedium
    lb.TextSize = 13
    lb.TextColor3 = T.Sub
    lb.TextXAlignment = Enum.TextXAlignment.Left

    local ac = Instance.new("Frame", btn)
    ac.Size = UDim2.new(0, 3, 0, 20)
    ac.Position = UDim2.new(0, 0, 0.5, -10)
    ac.BackgroundColor3 = T.Accent
    ac.BorderSizePixel = 0
    ac.Visible = false
    corner(ac, 2)

    local function setA(a)
        ac.Visible = a
        btn.BackgroundColor3 = a and T.Card or T.Sidebar
        ic.TextColor3 = a and T.Accent or T.Sub
        lb.TextColor3 = a and T.Text or T.Sub
    end

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(Pages) do p.Visible = (k == id) end
        for k, setter in pairs(NavBtns) do setter(k == id) end
    end)

    NavBtns[id] = setA
    return page
end

local pMacro    = addTab("Macro",    "🎯", "Macro",    1)
local pVisual   = addTab("Visual",   "👁️", "Visual",   2)
local pMove     = addTab("Move",     "🏃", "Move",     3)
local pSettings = addTab("Settings", "⚙️", "Settings", 4)
local pInfo     = addTab("Info",     "💠", "Info",     5)

for k, p in pairs(Pages) do p.Visible = (k == "Macro") end
for k, setter in pairs(NavBtns) do setter(k == "Macro") end

-- ============================================================
-- COMPONENTS
-- ============================================================
local function makeSection(parent, title, desc, order)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = T.Panel
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    corner(card, 12)
    stroke(card, T.Stroke, 1)

    local top = Instance.new("Frame", card)
    top.Size = UDim2.new(1, 0, 0, 48)
    top.BackgroundTransparency = 1

    local tl = Instance.new("TextLabel", top)
    tl.Size = UDim2.new(1, -20, 0, 20)
    tl.Position = UDim2.fromOffset(14, 6)
    tl.BackgroundTransparency = 1
    local lower = string.lower(title)
    local sectionIcon = "◆ "
    if lower:find("combo") then sectionIcon = "⚔️ "
    elseif lower:find("cài đặt macro") then sectionIcon = "🔧 "
    elseif lower:find("player esp") then sectionIcon = "👥 "
    elseif lower:find("esp style") then sectionIcon = "🎨 "
    elseif lower:find("di chuyển") then sectionIcon = "🏃 "
    elseif lower:find("giao diện") then sectionIcon = "🎨 "
    elseif lower:find("tối ưu") then sectionIcon = "⚡ "
    elseif lower:find("hành động") then sectionIcon = "💾 "
    elseif lower:find("thông tin") then sectionIcon = "💠 "
    elseif lower:find("tính năng") then sectionIcon = "✨ "
    end
    tl.Text = sectionIcon .. title
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 14
    tl.TextColor3 = T.Text
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local dl = Instance.new("TextLabel", top)
    dl.Size = UDim2.new(1, -20, 0, 16)
    dl.Position = UDim2.fromOffset(14, 26)
    dl.BackgroundTransparency = 1
    dl.Text = desc or ""
    dl.Font = Enum.Font.Gotham
    dl.TextSize = 11
    dl.TextColor3 = T.Sub
    dl.TextXAlignment = Enum.TextXAlignment.Left

    local rows = Instance.new("Frame", card)
    rows.Size = UDim2.new(1, -20, 0, 0)
    rows.Position = UDim2.fromOffset(10, 48)
    rows.BackgroundTransparency = 1
    rows.AutomaticSize = Enum.AutomaticSize.Y
    local rl = Instance.new("UIListLayout", rows)
    rl.Padding = UDim.new(0, 4)
    rl.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("Frame", card)
    pad.Size = UDim2.new(1, 0, 0, 10)
    pad.Position = UDim2.new(0, 0, 1, 0)
    pad.AnchorPoint = Vector2.new(0, 1)
    pad.BackgroundTransparency = 1

    return rows
end

local function makeRow(parent, order)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = T.Card
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    corner(row, 8)

    row.MouseEnter:Connect(function()
        TW:Create(row, TweenInfo.new(.15), { BackgroundColor3 = T.CardHi }):Play()
    end)
    row.MouseLeave:Connect(function()
        TW:Create(row, TweenInfo.new(.15), { BackgroundColor3 = T.Card }):Play()
    end)

    return row
end

local function makeToggle(parent, name, desc, default, order, cb)
    local row = makeRow(parent, order)
    local state = default or false

    local tl = Instance.new("TextLabel", row)
    tl.Size = UDim2.new(1, -80, 0, 18)
    tl.Position = UDim2.fromOffset(12, 6)
    tl.BackgroundTransparency = 1
    local n = string.lower(name)
    local e = "▸ "
    if n:find("speed") then e = "⚡ "
    elseif n:find("jump") then e = "🦘 "
    elseif n:find("esp") then e = "👁️ "
    elseif n:find("tên") then e = "🏷️ "
    elseif n:find("khoảng cách") then e = "📏 "
    elseif n:find("máu") or n:find("hp") then e = "❤️ "
    elseif n:find("particle") then e = "💫 "
    elseif n:find("hiệu ứng skill") then e = "✨ "
    elseif n:find("ánh sáng") or n:find("light") then e = "💡 "
    elseif n:find("fps") then e = "🚀 "
    end
    tl.Text = e .. name
    tl.Font = Enum.Font.GothamMedium
    tl.TextSize = 12
    tl.TextColor3 = T.Text
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local dl = Instance.new("TextLabel", row)
    dl.Size = UDim2.new(1, -80, 0, 14)
    dl.Position = UDim2.fromOffset(12, 24)
    dl.BackgroundTransparency = 1
    dl.Text = desc or ""
    dl.Font = Enum.Font.Gotham
    dl.TextSize = 10
    dl.TextColor3 = T.Sub
    dl.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("Frame", row)
    sw.Size = UDim2.fromOffset(42, 22)
    sw.AnchorPoint = Vector2.new(1, 0.5)
    sw.Position = UDim2.new(1, -12, 0.5, 0)
    sw.BackgroundColor3 = state and T.On or T.Off
    sw.BorderSizePixel = 0
    corner(sw, 11)

    local kn = Instance.new("Frame", sw)
    kn.Size = UDim2.fromOffset(18, 18)
    kn.AnchorPoint = Vector2.new(0, 0.5)
    kn.Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    kn.BackgroundColor3 = Color3.fromRGB(245,245,250)
    kn.BorderSizePixel = 0
    corner(kn, 9)

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local function set(v)
        state = v
        TW:Create(sw, TweenInfo.new(.15), {BackgroundColor3 = state and T.On or T.Off}):Play()
        TW:Create(kn, TweenInfo.new(.15), {
            Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }):Play()
    end

    btn.MouseButton1Click:Connect(function()
        set(not state)
        if cb then cb(state) end
    end)

    return { Get = function() return state end, Set = set }
end

local function makeSlider(parent, name, desc, min, max, default, order, cb)
    local row = makeRow(parent, order)
    row.Size = UDim2.new(1, 0, 0, 58)

    local tl = Instance.new("TextLabel", row)
    tl.Size = UDim2.new(1, -80, 0, 16)
    tl.Position = UDim2.fromOffset(12, 6)
    tl.BackgroundTransparency = 1
    local n = string.lower(name)
    local e = "🎚️ "
    if n:find("speed") then e = "⚡ "
    elseif n:find("jump") then e = "🦘 "
    elseif n:find("trong suốt") then e = "👻 "
    elseif n:find("kích thước") or n:find("size") then e = "📐 "
    end
    tl.Text = e .. name
    tl.Font = Enum.Font.GothamMedium
    tl.TextSize = 12
    tl.TextColor3 = T.Text
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local vb = Instance.new("TextLabel", row)
    vb.Size = UDim2.fromOffset(56, 20)
    vb.AnchorPoint = Vector2.new(1, 0)
    vb.Position = UDim2.new(1, -12, 0, 6)
    vb.BackgroundColor3 = T.Panel
    vb.Text = tostring(default)
    vb.Font = Enum.Font.GothamMedium
    vb.TextSize = 11
    vb.TextColor3 = T.Text
    vb.BorderSizePixel = 0
    corner(vb, 6)

    local dl = Instance.new("TextLabel", row)
    dl.Size = UDim2.new(1, -80, 0, 14)
    dl.Position = UDim2.fromOffset(12, 22)
    dl.BackgroundTransparency = 1
    dl.Text = desc or ""
    dl.Font = Enum.Font.Gotham
    dl.TextSize = 10
    dl.TextColor3 = T.Sub
    dl.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -24, 0, 6)
    track.AnchorPoint = Vector2.new(0, 1)
    track.Position = UDim2.new(0, 12, 1, -14)
    track.BackgroundColor3 = T.Off
    track.BorderSizePixel = 0
    corner(track, 3)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = T.Accent
    fill.BorderSizePixel = 0
    corner(fill, 3)

    local kn = Instance.new("Frame", track)
    kn.AnchorPoint = Vector2.new(0.5, 0.5)
    kn.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    kn.Size = UDim2.fromOffset(14, 14)
    kn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    kn.BorderSizePixel = 0
    corner(kn, 7)

    local dg = false
    local function upd(i)
        local rl = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rl + 0.5)
        fill.Size = UDim2.new(rl, 0, 1, 0)
        kn.Position = UDim2.new(rl, 0, 0.5, 0)
        vb.Text = tostring(v)
        if cb then cb(v) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dg = true; upd(i)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dg and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dg = false
        end
    end)
end

local function makeButton(parent, name, desc, btnText, order, cb, isDanger)
    local row = makeRow(parent, order)

    local tl = Instance.new("TextLabel", row)
    tl.Size = UDim2.new(0.55, 0, 0, 18)
    tl.Position = UDim2.fromOffset(12, 6)
    tl.BackgroundTransparency = 1
    tl.Text = name
    tl.Font = Enum.Font.GothamMedium
    tl.TextSize = 12
    tl.TextColor3 = T.Text
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local dl = Instance.new("TextLabel", row)
    dl.Size = UDim2.new(0.55, 0, 0, 14)
    dl.Position = UDim2.fromOffset(12, 24)
    dl.BackgroundTransparency = 1
    dl.Text = desc or ""
    dl.Font = Enum.Font.Gotham
    dl.TextSize = 10
    dl.TextColor3 = T.Sub
    dl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.fromOffset(100, 28)
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -12, 0.5, 0)
    btn.BackgroundColor3 = isDanger and T.Danger or T.Accent
    btn.Text = btnText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    corner(btn, 8)
    if cb then btn.MouseButton1Click:Connect(cb) end
    return btn
end

-- ============================================================
-- MACRO ENGINE
-- ============================================================
local WeaponNames = {"Vo", "Kiem", "Sung", "Trai"}
local WeaponSkills = {
    Vo    = {"Z","X","C","V","F"},
    Kiem  = {"Z","X"},
    Sung  = {"Z","X"},
    Trai  = {"Z","X","C","V","F"}
}
local TypeMap = { Vo = "Melee", Kiem = "Sword", Sung = "Gun", Trai = "Blox Fruit" }
local KeyMap = {
    Z = Enum.KeyCode.Z, X = Enum.KeyCode.X, C = Enum.KeyCode.C,
    V = Enum.KeyCode.V, F = Enum.KeyCode.F
}

local function validSkill(w, s)
    for _, x in ipairs(WeaponSkills[w] or {}) do
        if x == s then return true end
    end
    return false
end

local function getToolType(t)
    if not t or not t:IsA("Tool") then return nil end
    local a = t:GetAttribute("ToolType")
    if a then
        local s = tostring(a)
        if s == "Melee" or s == "Sword" or s == "Gun" or s == "Blox Fruit" then
            return s
        end
    end
    local tp = t.ToolTip
    if tp and tp ~= "" then
        local s = string.lower(tp)
        if s:find("melee") or s:find("fighting") then return "Melee" end
        if s:find("sword") then return "Sword" end
        if s:find("gun") then return "Gun" end
        if s:find("fruit") or s:find("blox") then return "Blox Fruit" end
    end
    local n = string.lower(t.Name)
    if n:find("sword") or n:find("katana") or n:find("blade")
    or n:find("saber") or n:find("cutlass") or n:find("dagger") then
        return "Sword"
    end
    if n:find("gun") or n:find("pistol") or n:find("rifle")
    or n:find("musket") or n:find("flintlock") then
        return "Gun"
    end
    return nil
end

local function equipLabel(lb)
    local tt = TypeMap[lb]
    if not tt then return end
    local ch = LP.Character
    if not ch then return end
    local h = ch:FindFirstChildOfClass("Humanoid")
    if not h then return end
    for _, x in ipairs(ch:GetChildren()) do
        if x:IsA("Tool") and getToolType(x) == tt then return end
    end
    if ch:FindFirstChildOfClass("Tool") then
        pcall(function() h:UnequipTools() end)
        task.wait(.08)
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, x in ipairs(bp:GetChildren()) do
            if x:IsA("Tool") and getToolType(x) == tt then
                pcall(function() h:EquipTool(x) end)
                task.wait(.15)
                return
            end
        end
    end
end

local function pressKey(kc, hd)
    pcall(function() VIM:SendKeyEvent(true, kc, false, game) end)
    task.wait(hd and hd > 0 and hd or .03)
    pcall(function() VIM:SendKeyEvent(false, kc, false, game) end)
end

local Macros     = {}
local RUN        = false
local STP        = false
local R_M        = nil
local OnFinishCB = nil
local FBs        = {}

local function addMacro(name)
    local m = { name = name, bl = {}, on = false, open = true }
    table.insert(Macros, m)
    return m
end

local function runMacro(m)
    if RUN or not m.on or #m.bl == 0 then return end
    RUN = true; STP = false; R_M = m
    if OnFinishCB then OnFinishCB(m, true) end
    for _, b in ipairs(m.bl) do
        if STP then break end
        if not validSkill(b.w, b.s) then b.s = (WeaponSkills[b.w] or {"Z"})[1] end
        equipLabel(b.w)
        if KeyMap[b.s] then pressKey(KeyMap[b.s], b.h) end
        if b.d > 0 then task.wait(b.d) end
    end
    RUN = false; R_M = nil
    if OnFinishCB then OnFinishCB(m, false) end
end

-- ============================================================
-- FLOATING MACRO SWITCHES
-- ============================================================
local function updateFB(m)
    local entry = FBs[m]
    if not entry then return end
    local running = (R_M == m and RUN)

    if running then
        TW:Create(entry.sw, TweenInfo.new(.18, Enum.EasingStyle.Quad), {
            BackgroundColor3 = T.On
        }):Play()
        TW:Create(entry.knob, TweenInfo.new(.18, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, -20, 0.5, 0)
        }):Play()
        TW:Create(entry.border, TweenInfo.new(.18), {
            Color = T.Accent, Transparency = 0
        }):Play()
        entry.icon.Text = "■"
        entry.icon.TextColor3 = T.Red
    else
        TW:Create(entry.sw, TweenInfo.new(.18, Enum.EasingStyle.Quad), {
            BackgroundColor3 = T.Off
        }):Play()
        TW:Create(entry.knob, TweenInfo.new(.18, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, 2, 0.5, 0)
        }):Play()
        TW:Create(entry.border, TweenInfo.new(.18), {
            Color = T.Stroke, Transparency = 0.3
        }):Play()
        entry.icon.Text = "▶"
        entry.icon.TextColor3 = T.Green
    end
end

local function createFB(m)
    if FBs[m] then return end

    local c = 0
    for _ in pairs(FBs) do c = c + 1 end

    local fb = Instance.new("TextButton", GUI)
    fb.Size = UDim2.fromOffset(210, 48)
    fb.Position = UDim2.new(0, 20, 0, 180 + c * 58)
    fb.BackgroundColor3 = Color3.fromRGB(14, 22, 42)
    fb.BackgroundTransparency = 0.05
    fb.Text = ""
    fb.AutoButtonColor = false
    fb.BorderSizePixel = 0
    corner(fb, 12)

    local bd = Instance.new("UIStroke", fb)
    bd.Color = T.Stroke
    bd.Thickness = 1.5
    bd.Transparency = 0.3
    bd.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    drag(fb)

    local icon = Instance.new("TextLabel", fb)
    icon.Size = UDim2.fromOffset(20, 20)
    icon.Position = UDim2.fromOffset(14, 14)
    icon.BackgroundTransparency = 1
    icon.Text = "▶"
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 13
    icon.TextColor3 = T.Green

    local nameL = Instance.new("TextLabel", fb)
    nameL.Size = UDim2.new(1, -102, 1, 0)
    nameL.Position = UDim2.fromOffset(40, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = "🎯 "..m.name
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 12
    nameL.TextColor3 = T.Text
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.TextTruncate = Enum.TextTruncate.AtEnd

    local sw = Instance.new("Frame", fb)
    sw.Size = UDim2.fromOffset(42, 22)
    sw.AnchorPoint = Vector2.new(1, 0.5)
    sw.Position = UDim2.new(1, -14, 0.5, 0)
    sw.BackgroundColor3 = T.Off
    sw.BorderSizePixel = 0
    corner(sw, 11)

    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.fromOffset(18, 18)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    knob.BorderSizePixel = 0
    corner(knob, 9)

    FBs[m] = { fb = fb, sw = sw, knob = knob, icon = icon, border = bd }

    fb.MouseButton1Click:Connect(function()
        if R_M == m and RUN then
            STP = true
        else
            task.spawn(function() runMacro(m) end)
        end
    end)

    fb.MouseEnter:Connect(function()
        TW:Create(fb, TweenInfo.new(.15), { BackgroundTransparency = 0 }):Play()
    end)
    fb.MouseLeave:Connect(function()
        TW:Create(fb, TweenInfo.new(.15), { BackgroundTransparency = 0.05 }):Play()
    end)

    updateFB(m)
end

local function removeFB(m)
    local entry = FBs[m]
    if entry then
        entry.fb:Destroy()
        FBs[m] = nil
    end
end

OnFinishCB = function(m) if FBs[m] then updateFB(m) end end

-- Dropdown popup
local Ov = Instance.new("TextButton", GUI)
Ov.Size = UDim2.new(1, 0, 1, 0)
Ov.BackgroundTransparency = 1
Ov.Text = ""
Ov.AutoButtonColor = false
Ov.Visible = false
Ov.ZIndex = 500

local Pop = Instance.new("Frame", GUI)
Pop.BackgroundColor3 = T.Card
Pop.BorderSizePixel = 0
Pop.Visible = false
Pop.ZIndex = 501
corner(Pop, 8)
stroke(Pop, T.Accent, 1)
local PL = Instance.new("UIListLayout", Pop)
PL.Padding = UDim.new(0, 2)
local PP = Instance.new("UIPadding", Pop)
PP.PaddingTop = UDim.new(0, 4)
PP.PaddingBottom = UDim.new(0, 4)
PP.PaddingLeft = UDim.new(0, 4)
PP.PaddingRight = UDim.new(0, 4)

Ov.MouseButton1Click:Connect(function() Ov.Visible = false; Pop.Visible = false end)

local function openDD(btn, opts, cb)
    for _, c in ipairs(Pop:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, o in ipairs(opts) do
        local ob = Instance.new("TextButton", Pop)
        ob.Size = UDim2.new(1, 0, 0, 26)
        ob.BackgroundColor3 = T.Card
        ob.Text = o
        ob.TextColor3 = T.Text
        ob.TextSize = 12
        ob.Font = Enum.Font.GothamMedium
        ob.AutoButtonColor = false
        ob.ZIndex = 502
        corner(ob, 5)
        ob.MouseButton1Click:Connect(function()
            cb(o)
            Ov.Visible = false
            Pop.Visible = false
        end)
    end
    local w = math.max(btn.AbsoluteSize.X, 90)
    Pop.Size = UDim2.fromOffset(w, #opts * 28 + 8)
    local ax = btn.AbsolutePosition.X
    local ay = btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 4
    if ax + w > GUI.AbsoluteSize.X - 10 then ax = GUI.AbsoluteSize.X - w - 10 end
    Pop.Position = UDim2.fromOffset(ax, ay)
    Ov.Visible = true
    Pop.Visible = true
end

local function mkDD(par, getOpts, init, cb)
    local b = Instance.new("TextButton", par)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundColor3 = T.Input
    b.Text = ""
    b.AutoButtonColor = false
    corner(b, 6)
    stroke(b, T.Stroke, 1)
    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1, -20, 1, 0)
    l.Position = UDim2.fromOffset(8, 0)
    l.BackgroundTransparency = 1
    l.Text = init
    l.TextColor3 = T.Text
    l.TextSize = 12
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    b.MouseButton1Click:Connect(function()
        openDD(b, getOpts(), function(v)
            l.Text = v
            cb(v)
        end)
    end)
    return function(v) l.Text = v end
end

refreshMacros = nil

local function mkBlock(par, m, b, bi, mi)
    if not validSkill(b.w, b.s) then b.s = (WeaponSkills[b.w] or {"Z"})[1] end

    local r = Instance.new("Frame", par)
    r.Size = UDim2.new(1, -4, 0, 62)
    r.BackgroundColor3 = T.Card
    r.LayoutOrder = mi * 100 + bi
    corner(r, 8)
    stroke(r, T.Stroke, 1)

    local lab = Instance.new("TextLabel", r)
    lab.Size = UDim2.fromOffset(80, 14)
    lab.Position = UDim2.fromOffset(12, 4)
    lab.BackgroundTransparency = 1
    lab.Text = "🔹 Block "..bi
    lab.TextColor3 = T.Accent
    lab.TextSize = 10
    lab.Font = Enum.Font.GothamBold
    lab.TextXAlignment = Enum.TextXAlignment.Left

    local dl = Instance.new("TextButton", r)
    dl.Size = UDim2.fromOffset(20, 18)
    dl.Position = UDim2.new(1, -26, 0, 4)
    dl.BackgroundColor3 = Color3.fromRGB(50, 20, 28)
    dl.Text = "✕"
    dl.TextColor3 = T.Red
    dl.TextSize = 10
    dl.AutoButtonColor = false
    corner(dl, 4)

    local fd = Instance.new("Frame", r)
    fd.Size = UDim2.new(1, -20, 0, 28)
    fd.Position = UDim2.fromOffset(10, 26)
    fd.BackgroundTransparency = 1

    local wS = Instance.new("Frame", fd)
    wS.BackgroundTransparency = 1
    wS.Size = UDim2.new(.25, -4, 1, 0)
    wS.Position = UDim2.new(0, 0, 0, 0)

    local sS = Instance.new("Frame", fd)
    sS.BackgroundTransparency = 1
    sS.Size = UDim2.new(.25, -4, 1, 0)
    sS.Position = UDim2.new(.25, 2, 0, 0)

    local hS = Instance.new("Frame", fd)
    hS.BackgroundColor3 = T.Input
    hS.Size = UDim2.new(.25, -4, 1, 0)
    hS.Position = UDim2.new(.5, 4, 0, 0)
    corner(hS, 5)
    stroke(hS, T.Stroke, 1)

    local dS = Instance.new("Frame", fd)
    dS.BackgroundColor3 = T.Input
    dS.Size = UDim2.new(.25, -4, 1, 0)
    dS.Position = UDim2.new(.75, 6, 0, 0)
    corner(dS, 5)
    stroke(dS, T.Stroke, 1)

    local sL
    mkDD(wS, function() return WeaponNames end, b.w, function(v)
        b.w = v
        if not validSkill(v, b.s) then
            b.s = (WeaponSkills[v] or {"Z"})[1]
            if sL then sL(b.s) end
        end
    end)
    sL = mkDD(sS, function() return WeaponSkills[b.w] or {"Z"} end, b.s, function(v) b.s = v end)

    local hB = Instance.new("TextBox", hS)
    hB.Size = UDim2.new(1, -8, 1, 0)
    hB.Position = UDim2.fromOffset(4, 0)
    hB.BackgroundTransparency = 1
    hB.Text = string.format("%.2f", b.h)
    hB.TextColor3 = T.Text
    hB.TextSize = 12
    hB.Font = Enum.Font.Gotham
    hB.ClearTextOnFocus = false
    hB.FocusLost:Connect(function()
        local n = tonumber(hB.Text)
        if n and n >= 0 then b.h = n end
        hB.Text = string.format("%.2f", b.h)
    end)

    local dB = Instance.new("TextBox", dS)
    dB.Size = UDim2.new(1, -8, 1, 0)
    dB.Position = UDim2.fromOffset(4, 0)
    dB.BackgroundTransparency = 1
    dB.Text = string.format("%.2f", b.d)
    dB.TextColor3 = T.Text
    dB.TextSize = 12
    dB.Font = Enum.Font.Gotham
    dB.ClearTextOnFocus = false
    dB.FocusLost:Connect(function()
        local n = tonumber(dB.Text)
        if n and n >= 0 then b.d = n end
        dB.Text = string.format("%.2f", b.d)
    end)

    dl.MouseButton1Click:Connect(function()
        table.remove(m.bl, bi)
        if refreshMacros then refreshMacros() end
    end)
end

local function mkHeader(par, m, mi)
    local r = Instance.new("Frame", par)
    r.Size = UDim2.new(1, -4, 0, 52)
    r.BackgroundColor3 = T.Card
    r.LayoutOrder = mi * 100
    corner(r, 10)
    stroke(r, m.on and T.Accent or T.Stroke, m.on and 1.2 or 1)

    local t = Instance.new("TextLabel", r)
    t.Size = UDim2.new(0, 250, 1, 0)
    t.Position = UDim2.fromOffset(60, 0)
    t.BackgroundTransparency = 1
    t.Text = "🎯 "..m.name
    t.TextColor3 = T.Text
    t.TextSize = 14
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left

    local a = Instance.new("TextLabel", r)
    a.Size = UDim2.fromOffset(24, 24)
    a.Position = UDim2.fromOffset(16, 14)
    a.BackgroundTransparency = 1
    a.Text = m.open and "▾" or "▸"
    a.TextColor3 = T.Sub
    a.TextSize = 16
    a.Font = Enum.Font.GothamBold

    local rn = Instance.new("TextButton", r)
    rn.Size = UDim2.fromOffset(30, 26)
    rn.Position = UDim2.new(1, -152, 0, 13)
    rn.BackgroundColor3 = Color3.fromRGB(10, 40, 35)
    rn.Text = "▶"
    rn.TextColor3 = T.Green
    rn.TextSize = 13
    rn.Font = Enum.Font.GothamBold
    rn.AutoButtonColor = false
    corner(rn, 6)
    stroke(rn, T.Green, .8)
    rn.MouseButton1Click:Connect(function()
        task.spawn(function() runMacro(m) end)
    end)

    local d = Instance.new("TextButton", r)
    d.Size = UDim2.fromOffset(26, 26)
    d.Position = UDim2.new(1, -116, 0, 13)
    d.BackgroundColor3 = Color3.fromRGB(45, 20, 30)
    d.Text = "✕"
    d.TextColor3 = T.Red
    d.TextSize = 11
    d.Font = Enum.Font.GothamBold
    d.AutoButtonColor = false
    corner(d, 6)
    d.MouseButton1Click:Connect(function()
        removeFB(m)
        for i, x in ipairs(Macros) do
            if x == m then table.remove(Macros, i) break end
        end
        if refreshMacros then refreshMacros() end
    end)

    local tg = Instance.new("TextButton", r)
    tg.Size = UDim2.fromOffset(44, 24)
    tg.Position = UDim2.new(1, -62, 0, 14)
    tg.AutoButtonColor = false
    tg.BackgroundColor3 = m.on and T.On or T.Off
    tg.Text = ""
    corner(tg, 12)

    local tk = Instance.new("Frame", tg)
    tk.Size = UDim2.fromOffset(18, 18)
    tk.Position = m.on and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)
    tk.BackgroundColor3 = Color3.fromRGB(255,255,255)
    tk.BorderSizePixel = 0
    corner(tk, 9)

    tg.MouseButton1Click:Connect(function()
        m.on = not m.on
        if m.on then createFB(m) else removeFB(m) end
        if refreshMacros then refreshMacros() end
    end)

    local ca = Instance.new("TextButton", r)
    ca.Size = UDim2.new(1, -160, 1, 0)
    ca.BackgroundTransparency = 1
    ca.Text = ""
    ca.AutoButtonColor = false
    ca.ZIndex = 2
    ca.MouseButton1Click:Connect(function()
        m.open = not m.open
        if refreshMacros then refreshMacros() end
    end)
end

function refreshMacros()
    Ov.Visible = false
    Pop.Visible = false
    for _, c in ipairs(pMacro:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") or c:IsA("TextLabel") then
            c:Destroy()
        end
    end

    local topCard = Instance.new("Frame", pMacro)
    topCard.Size = UDim2.new(1, 0, 0, 60)
    topCard.BackgroundColor3 = T.Panel
    topCard.LayoutOrder = -1
    corner(topCard, 12)
    stroke(topCard, T.Stroke, 1)

    local ttl = Instance.new("TextLabel", topCard)
    ttl.Size = UDim2.new(0.5, 0, 0, 22)
    ttl.Position = UDim2.fromOffset(14, 10)
    ttl.BackgroundTransparency = 1
    ttl.Text = "🎯 Macro"
    ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 14
    ttl.TextColor3 = T.Text
    ttl.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", topCard)
    sub.Size = UDim2.new(0.5, 0, 0, 16)
    sub.Position = UDim2.fromOffset(14, 32)
    sub.BackgroundTransparency = 1
    sub.Text = "Tự động combo · Tối ưu PvP"
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextColor3 = T.Sub
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local tb = Instance.new("TextButton", topCard)
    tb.Size = UDim2.fromOffset(140, 36)
    tb.AnchorPoint = Vector2.new(1, 0.5)
    tb.Position = UDim2.new(1, -14, 0.5, 0)
    tb.BackgroundColor3 = T.Accent2
    tb.Text = "➕ Tạo Macro"
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 12
    tb.TextColor3 = Color3.fromRGB(255,255,255)
    tb.BorderSizePixel = 0
    tb.AutoButtonColor = false
    corner(tb, 9)
    tb.MouseButton1Click:Connect(function()
        addMacro("Macro "..#Macros + 1)
        refreshMacros()
    end)

    if #Macros == 0 then
        local empty = Instance.new("Frame", pMacro)
        empty.Size = UDim2.new(1, 0, 0, 160)
        empty.BackgroundTransparency = 1
        empty.LayoutOrder = 10

        local circ = Instance.new("Frame", empty)
        circ.Size = UDim2.fromOffset(64, 64)
        circ.Position = UDim2.new(.5, -32, 0, 30)
        circ.BackgroundColor3 = T.Card
        circ.BorderSizePixel = 0
        corner(circ, 32)
        stroke(circ, T.Accent, 1.2)

        local ico = Instance.new("TextLabel", circ)
        ico.Size = UDim2.fromScale(1,1)
        ico.BackgroundTransparency = 1
        ico.Text = "🎯"
        ico.Font = Enum.Font.GothamBold
        ico.TextSize = 26
        ico.TextColor3 = T.Accent

        local t1 = Instance.new("TextLabel", empty)
        t1.Size = UDim2.new(1, 0, 0, 22)
        t1.Position = UDim2.new(0, 0, 0, 108)
        t1.BackgroundTransparency = 1
        t1.Text = "Chưa có Macro nào"
        t1.TextColor3 = T.Text
        t1.TextSize = 14
        t1.Font = Enum.Font.GothamBold

        local t2 = Instance.new("TextLabel", empty)
        t2.Size = UDim2.new(1, 0, 0, 18)
        t2.Position = UDim2.new(0, 0, 0, 130)
        t2.BackgroundTransparency = 1
        t2.Text = "Bấm '➕ Tạo Macro' để bắt đầu"
        t2.TextColor3 = T.Sub
        t2.TextSize = 11
        t2.Font = Enum.Font.Gotham
        return
    end

    for i, m in ipairs(Macros) do
        mkHeader(pMacro, m, i)
        if m.open then
            for bi, b in ipairs(m.bl) do
                mkBlock(pMacro, m, b, bi, i)
            end
            local ar = Instance.new("Frame", pMacro)
            ar.Size = UDim2.new(1, -4, 0, 30)
            ar.BackgroundTransparency = 1
            ar.LayoutOrder = i * 100 + 99
            local ab = Instance.new("TextButton", ar)
            ab.Size = UDim2.new(1, 0, 1, 0)
            ab.BackgroundColor3 = Color3.fromRGB(12, 18, 32)
            ab.AutoButtonColor = false
            ab.Text = "➕ Thêm Block"
            ab.TextColor3 = T.Accent
            ab.TextSize = 12
            ab.Font = Enum.Font.GothamBold
            corner(ab, 8)
            stroke(ab, Color3.fromRGB(0, 150, 200), .8)
            ab.MouseButton1Click:Connect(function()
                table.insert(m.bl, { w = "Vo", s = "Z", h = 0, d = .15 })
                refreshMacros()
            end)
        end
    end
end

refreshMacros()

-- ============================================================
-- VISUAL ESP
-- ============================================================
local ESP = {
    on = false, name = true, dist = true, hp = true,
    color = Color3.fromRGB(255, 80, 100), transparency = .7
}
local espCache = {}

local function makeESP(plr)
    if espCache[plr] then return espCache[plr] end
    local ch = plr.Character
    if not ch then return nil end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end

    local hl = Instance.new("Highlight", ch)
    hl.FillColor = ESP.color
    hl.FillTransparency = ESP.transparency
    hl.OutlineColor = ESP.color
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    local bb = Instance.new("BillboardGui", ch)
    bb.Size = UDim2.fromOffset(100, 60)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = hrp

    local nameL = Instance.new("TextLabel", bb)
    nameL.Name = "Name"
    nameL.Size = UDim2.new(1, 0, 0, 16)
    nameL.Position = UDim2.new(0, 0, 0, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = "🏷️ "..plr.Name
    nameL.TextColor3 = ESP.color
    nameL.TextStrokeTransparency = .3
    nameL.TextSize = 13
    nameL.Font = Enum.Font.GothamBold

    local distL = Instance.new("TextLabel", bb)
    distL.Name = "Dist"
    distL.Size = UDim2.new(1, 0, 0, 14)
    distL.Position = UDim2.new(0, 0, 0, 16)
    distL.BackgroundTransparency = 1
    distL.Text = "📏 0m"
    distL.TextColor3 = Color3.fromRGB(255,255,255)
    distL.TextStrokeTransparency = .3
    distL.TextSize = 11
    distL.Font = Enum.Font.Gotham

    local hpBg = Instance.new("Frame", bb)
    hpBg.Name = "HpBg"
    hpBg.Size = UDim2.new(1, -20, 0, 4)
    hpBg.Position = UDim2.new(0, 10, 0, 32)
    hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    hpBg.BorderSizePixel = 0
    corner(hpBg, 2)

    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Name = "HpFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(80, 240, 130)
    hpFill.BorderSizePixel = 0
    corner(hpFill, 2)

    espCache[plr] = { hl = hl, bb = bb, hum = hum }
    return espCache[plr]
end

local function removeESP(plr)
    local c = espCache[plr]
    if c then
        pcall(function() c.hl:Destroy() end)
        pcall(function() c.bb:Destroy() end)
        espCache[plr] = nil
    end
end

RS.RenderStepped:Connect(function()
    if not ESP.on then
        local list = {}
        for p in pairs(espCache) do table.insert(list, p) end
        for _, p in ipairs(list) do removeESP(p) end
        return
    end

    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local e = espCache[plr]
            if not e then e = makeESP(plr) end
            if e and e.bb and e.bb.Parent then
                e.hl.FillColor = ESP.color
                e.hl.FillTransparency = ESP.transparency
                e.hl.OutlineColor = ESP.color
                local bb = e.bb
                if bb:FindFirstChild("Name") then bb.Name.Visible = ESP.name end
                if bb:FindFirstChild("Dist") then bb.Dist.Visible = ESP.dist end
                if bb:FindFirstChild("HpBg") then bb.HpBg.Visible = ESP.hp end
                if myHRP and e.hum.Parent and e.hum.Parent:FindFirstChild("HumanoidRootPart") then
                    local d = (e.hum.Parent.HumanoidRootPart.Position - myHRP.Position).Magnitude
                    if bb:FindFirstChild("Dist") then bb.Dist.Text = "📏 " .. math.floor(d) .. "m" end
                end
                local hp = e.hum.Health / math.max(e.hum.MaxHealth, 1)
                local hf = bb:FindFirstChild("HpBg") and bb.HpBg:FindFirstChild("HpFill")
                if hf then
                    hf.Size = UDim2.new(hp, 0, 1, 0)
                    hf.BackgroundColor3 = hp > .5 and Color3.fromRGB(80,240,130)
                        or hp > .25 and Color3.fromRGB(240,200,60)
                        or Color3.fromRGB(240,80,80)
                end
            end
        end
    end
    for p in pairs(espCache) do
        if not p.Parent or not p.Character or not p.Character.Parent then
            removeESP(p)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if espCache[p] then removeESP(p) end
        if ESP.on then makeESP(p) end
    end)
end)

-- ============================================================
-- BUILD VISUAL PAGE
-- ============================================================
local v1 = makeSection(pVisual, "Player ESP", "Hiển thị thông tin người chơi", 1)
makeToggle(v1, "ESP Player", "Bật/tắt hiển thị người chơi", false, 1, function(v) ESP.on = v end)
makeToggle(v1, "Tên Player", "Hiển thị tên người chơi", true, 2, function(v) ESP.name = v end)
makeToggle(v1, "Khoảng cách", "Hiển thị khoảng cách", true, 3, function(v) ESP.dist = v end)
makeToggle(v1, "Thanh máu", "Hiển thị thanh máu", true, 4, function(v) ESP.hp = v end)

local v2 = makeSection(pVisual, "ESP Style", "Tùy chỉnh kiểu hiển thị", 2)
makeButton(v2, "🎨 Đổi màu", "Xoay vòng màu enemy", "🔄 Đổi", 1, function()
    local pool = {
        Color3.fromRGB(255, 80, 100),
        Color3.fromRGB(255, 200, 60),
        Color3.fromRGB(80, 240, 130),
        Color3.fromRGB(0, 220, 255),
    }
    local idx = 1
    for k, c in ipairs(pool) do
        if c == ESP.color then idx = k % #pool + 1 break end
    end
    ESP.color = pool[idx]
end)
makeSlider(v2, "Độ trong suốt", "Điều chỉnh độ trong suốt ESP", 0, 100, 70, 2, function(v)
    ESP.transparency = v / 100
end)

-- ============================================================
-- MOVE ENGINE
-- ============================================================
local speedOn, speedVal = false, 60
local jumpOn,  jumpVal  = false, 120
local baseSpeed, baseJump = 16, 50

local function getHumanoid()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid") or nil
end

local function refreshBase()
    local h = getHumanoid()
    if h then
        baseSpeed = h.WalkSpeed
        baseJump = h.UseJumpPower and h.JumpPower or h.JumpHeight
    end
end
refreshBase()
LP.CharacterAdded:Connect(function() task.wait(.3) refreshBase() end)

pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__newindex", function(self, key, value)
        if speedOn and self and typeof(self) == "Instance"
        and self:IsA("Humanoid") and self.Parent == LP.Character then
            if key == "WalkSpeed" then
                return oldIndex(self, key, speedVal)
            end
        end
        return oldIndex(self, key, value)
    end)
end)

RS.Stepped:Connect(function()
    local h = getHumanoid()
    if not h then return end
    if speedOn then
        if h.WalkSpeed ~= speedVal then h.WalkSpeed = speedVal end
    else
        if h.WalkSpeed ~= baseSpeed then h.WalkSpeed = baseSpeed end
    end
    if jumpOn then
        h.UseJumpPower = true
        if h.JumpPower ~= jumpVal then h.JumpPower = jumpVal end
    else
        if h.JumpPower ~= baseJump then h.JumpPower = baseJump end
    end
end)

local function applyMoveNow()
    local h = getHumanoid()
    if not h then return end
    if speedOn then h.WalkSpeed = speedVal end
    if jumpOn then h.UseJumpPower = true; h.JumpPower = jumpVal end
end

local m1 = makeSection(pMove, "Di chuyển", "Tối ưu tốc độ & nhảy", 1)
makeToggle(m1, "Speed", "Bật tăng tốc độ chạy", false, 1, function(v)
    speedOn = v
    applyMoveNow()
    if not v then
        local h = getHumanoid()
        if h then h.WalkSpeed = baseSpeed end
    end
end)
makeSlider(m1, "Speed Value", "Tốc độ chạy", 16, 200, 60, 2, function(v)
    speedVal = v
    if speedOn then applyMoveNow() end
end)
makeToggle(m1, "Jump", "Bật tăng lực nhảy", false, 3, function(v)
    jumpOn = v
    applyMoveNow()
    if not v then
        local h = getHumanoid()
        if h then h.JumpPower = baseJump end
    end
end)
makeSlider(m1, "Jump Value", "Lực nhảy", 50, 500, 120, 4, function(v)
    jumpVal = v
    if jumpOn then applyMoveNow() end
end)

-- ============================================================
-- EFFECT ENGINE
-- ============================================================
local EffectEngine = {
    particle = false, beams = false, lighting = false, lowFps = false,
    connections = {}
}

local CLASSES_PARTICLE = { "ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles" }
local CLASSES_BEAM     = { "Beam", "Explosion" }
local CLASSES_LIGHTING = {
    "BlurEffect", "SunRaysEffect", "BloomEffect",
    "DepthOfFieldEffect", "ColorCorrectionEffect",
}

local function setAttrOnce(inst)
    if inst:GetAttribute("__ds_touched") then return false end
    inst:SetAttribute("__ds_touched", true)
    return true
end

local function disableOne(inst)
    if not setAttrOnce(inst) then return end
    if inst:IsA("ParticleEmitter") then
        inst:SetAttribute("__ds_rate", inst.Rate)
        inst.Rate = 0
        inst.Enabled = false
    elseif inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire")
        or inst:IsA("Sparkles") or inst:IsA("Beam") then
        inst.Enabled = false
    elseif inst:IsA("Explosion") then
        inst.BlastPressure = 0
        inst.BlastRadius = 0
        inst:Destroy()
    elseif inst:IsA("BlurEffect") or inst:IsA("SunRaysEffect")
        or inst:IsA("BloomEffect") or inst:IsA("DepthOfFieldEffect")
        or inst:IsA("ColorCorrectionEffect") then
        inst.Enabled = false
    end
end

local function enableOne(inst)
    if not inst:GetAttribute("__ds_touched") then return end
    inst:SetAttribute("__ds_touched", nil)
    if inst:IsA("ParticleEmitter") then
        local r = inst:GetAttribute("__ds_rate") or 20
        inst.Rate = r
        inst.Enabled = true
        inst:SetAttribute("__ds_rate", nil)
    elseif inst:IsA("Trail") or inst:IsA("Smoke") or inst:IsA("Fire")
        or inst:IsA("Sparkles") or inst:IsA("Beam") then
        inst.Enabled = true
    elseif inst:IsA("BlurEffect") or inst:IsA("SunRaysEffect")
        or inst:IsA("BloomEffect") or inst:IsA("DepthOfFieldEffect")
        or inst:IsA("ColorCorrectionEffect") then
        inst.Enabled = true
    end
end

local function matches(inst)
    if EffectEngine.particle then
        for _, c in ipairs(CLASSES_PARTICLE) do
            if inst:IsA(c) then return true end
        end
    end
    if EffectEngine.beams then
        for _, c in ipairs(CLASSES_BEAM) do
            if inst:IsA(c) then return true end
        end
    end
    if EffectEngine.lighting then
        for _, c in ipairs(CLASSES_LIGHTING) do
            if inst:IsA(c) then return true end
        end
    end
    return false
end

local function scanContainer(root, depth)
    depth = depth or 0
    if depth > 6 then return end
    for _, inst in ipairs(root:GetChildren()) do
        if matches(inst) then disableOne(inst) end
        if #inst:GetChildren() > 0 and not inst:IsA("BasePart") then
            scanContainer(inst, depth + 1)
        end
    end
end

local function connectEffectHooks()
    scanContainer(Workspace)
    scanContainer(Lighting)

    table.insert(EffectEngine.connections, Workspace.DescendantAdded:Connect(function(inst)
        if matches(inst) then disableOne(inst) end
    end))
    table.insert(EffectEngine.connections, Lighting.DescendantAdded:Connect(function(inst)
        if matches(inst) then disableOne(inst) end
    end))

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            table.insert(EffectEngine.connections, plr.Character.DescendantAdded:Connect(function(inst)
                if matches(inst) then disableOne(inst) end
            end))
        end
    end
end

connectEffectHooks()

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(ch)
        task.wait(.3)
        table.insert(EffectEngine.connections, ch.DescendantAdded:Connect(function(inst)
            if matches(inst) then disableOne(inst) end
        end))
    end)
end)

local function rescanEffects()
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:GetAttribute("__ds_touched") then enableOne(inst) end
    end
    for _, inst in ipairs(Lighting:GetDescendants()) do
        if inst:GetAttribute("__ds_touched") then enableOne(inst) end
    end
    task.wait(.05)
    if EffectEngine.particle or EffectEngine.beams or EffectEngine.lighting then
        scanContainer(Workspace)
        scanContainer(Lighting)
    end
end

-- ============================================================
-- UI ALPHA ENGINE
-- ============================================================
local UIAlpha = { value = 0 }

local function applyAlphaTo(inst)
    if inst:IsA("GuiObject") then
        if inst:GetAttribute("__ui_orig_bg") == nil then
            inst:SetAttribute("__ui_orig_bg", inst.BackgroundTransparency)
        end
        local orig = inst:GetAttribute("__ui_orig_bg")
        inst.BackgroundTransparency = orig + (1 - orig) * UIAlpha.value
    end
end

local function applyAlphaAll()
    for _, inst in ipairs(Main:GetDescendants()) do
        if inst:IsA("GuiObject") then applyAlphaTo(inst) end
    end
    applyAlphaTo(Main)
end

Main.DescendantAdded:Connect(function(inst)
    if inst:IsA("GuiObject") then
        task.defer(function() applyAlphaTo(inst) end)
    end
end)

-- ============================================================
-- SETTINGS PAGE
-- ============================================================
local s1 = makeSection(pSettings, "Giao diện", "Tùy chỉnh giao diện", 1)

makeSlider(s1, "Độ trong suốt UI", "Điều chỉnh độ mờ toàn bộ UI", 0, 100, 0, 1, function(v)
    UIAlpha.value = (v / 100) * 0.9
    applyAlphaAll()
end)

makeSlider(s1, "Kích thước UI", "Phóng to / thu nhỏ", 60, 150, 100, 2, function(v)
    if _G.__setUserScale then _G.__setUserScale(v) end
end)

local s2 = makeSection(pSettings, "Tối ưu hiệu suất", "Giảm lag, tăng FPS", 2)

makeToggle(s2, "Giảm particle", "Tắt hạt / khói / lửa / trail", false, 1, function(v)
    EffectEngine.particle = v
    task.spawn(function()
        if v then scanContainer(Workspace); scanContainer(Lighting) end
    end)
end)

makeToggle(s2, "Giảm hiệu ứng skill", "Tắt Beam, Explosion, Sparkles", false, 2, function(v)
    EffectEngine.beams = v
    task.spawn(function()
        if v then scanContainer(Workspace); scanContainer(Lighting) end
    end)
end)

makeToggle(s2, "Giảm hiệu ứng sáng", "Tắt Blur, Bloom, SunRays, DOF", false, 3, function(v)
    EffectEngine.lighting = v
    task.spawn(function()
        if v then scanContainer(Workspace); scanContainer(Lighting) end
    end)
end)

makeToggle(s2, "Tối ưu FPS", "Hạ chất lượng render toàn cục", false, 4, function(v)
    EffectEngine.lowFps = v
    if v then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    else
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    end
end)

makeButton(s2, "🔁 Quét lại hiệu ứng", "Ép tắt effect ngay lập tức", "↻ Quét", 5, function()
    task.spawn(rescanEffects)
end)

local s3 = makeSection(pSettings, "Hành động", "Lưu và khôi phục", 3)

makeButton(s3, "🔄 Đặt lại về mặc định", "Reset vị trí và kích thước UI", "↻ Reset", 1, function()
    Main.Position = UDim2.fromScale(.5, .5)
    if _G.__setUserScale then _G.__setUserScale(100) end
    if applyScale then task.spawn(applyScale) end
end, true)

-- ============================================================
-- INFO PAGE
-- ============================================================
for _, c in ipairs(pInfo:GetChildren()) do
    if c:IsA("Frame") or c:IsA("TextButton") or c:IsA("TextLabel") then
        c:Destroy()
    end
end

local function buildInfoSection(parent, title, desc, order)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = T.Panel
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    corner(card, 12)
    stroke(card, T.Stroke, 1)

    local headerF = Instance.new("Frame", card)
    headerF.Size = UDim2.new(1, 0, 0, 48)
    headerF.BackgroundTransparency = 1

    local tL = Instance.new("TextLabel", headerF)
    tL.Size = UDim2.new(1, -20, 0, 20)
    tL.Position = UDim2.fromOffset(14, 6)
    tL.BackgroundTransparency = 1
    local lower = string.lower(title)
    local icon = "💠 "
    if lower:find("tính năng") then icon = "✨ " end
    tL.Text = icon .. title
    tL.Font = Enum.Font.GothamBold
    tL.TextSize = 14
    tL.TextColor3 = T.Text
    tL.TextXAlignment = Enum.TextXAlignment.Left

    local dL = Instance.new("TextLabel", headerF)
    dL.Size = UDim2.new(1, -20, 0, 16)
    dL.Position = UDim2.fromOffset(14, 26)
    dL.BackgroundTransparency = 1
    dL.Text = desc or ""
    dL.Font = Enum.Font.Gotham
    dL.TextSize = 11
    dL.TextColor3 = T.Sub
    dL.TextXAlignment = Enum.TextXAlignment.Left

    local rows = Instance.new("Frame", card)
    rows.Size = UDim2.new(1, -20, 0, 0)
    rows.Position = UDim2.fromOffset(10, 48)
    rows.BackgroundTransparency = 1
    rows.AutomaticSize = Enum.AutomaticSize.Y
    local rl = Instance.new("UIListLayout", rows)
    rl.Padding = UDim.new(0, 4)
    rl.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("Frame", card)
    pad.Size = UDim2.new(1, 0, 0, 10)
    pad.Position = UDim2.new(0, 0, 1, 0)
    pad.AnchorPoint = Vector2.new(0, 1)
    pad.BackgroundTransparency = 1

    return rows
end

local infoRows = buildInfoSection(pInfo, "Thông tin Script", "Tất cả thông tin về Dungdx PvP", 1)

local function addInfoRow(parent, label, value, order, withCopy)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = T.Card
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    corner(row, 8)

    local lL = Instance.new("TextLabel", row)
    lL.Size = UDim2.new(0.45, -20, 1, 0)
    lL.Position = UDim2.fromOffset(12, 0)
    lL.BackgroundTransparency = 1
    lL.Text = label
    lL.Font = Enum.Font.GothamMedium
    lL.TextSize = 12
    lL.TextColor3 = T.Sub
    lL.TextXAlignment = Enum.TextXAlignment.Left

    local vL = Instance.new("TextLabel", row)
    vL.AnchorPoint = Vector2.new(1, 0.5)
    vL.Position = UDim2.new(1, withCopy and -46 or -12, 0.5, 0)
    vL.Size = UDim2.new(0.55, withCopy and -40 or -20, 1, 0)
    vL.BackgroundTransparency = 1
    vL.Text = value
    vL.Font = Enum.Font.GothamBold
    vL.TextSize = 12
    vL.TextColor3 = T.Text
    vL.TextXAlignment = Enum.TextXAlignment.Right
    vL.TextTruncate = Enum.TextTruncate.AtEnd

    if withCopy then
        local copy = Instance.new("TextButton", row)
        copy.Size = UDim2.fromOffset(28, 28)
        copy.AnchorPoint = Vector2.new(1, 0.5)
        copy.Position = UDim2.new(1, -8, 0.5, 0)
        copy.BackgroundColor3 = T.Panel
        copy.Text = "⧉"
        copy.Font = Enum.Font.GothamBold
        copy.TextSize = 13
        copy.TextColor3 = T.Accent
        copy.BorderSizePixel = 0
        copy.AutoButtonColor = false
        corner(copy, 6)
        stroke(copy, T.Accent, 1, 0.5)
        copy.MouseButton1Click:Connect(function()
            if setclipboard then
                pcall(function() setclipboard(value) end)
            end
            copy.Text = "✓"
            copy.TextColor3 = T.Green
            task.wait(1.2)
            copy.Text = "⧉"
            copy.TextColor3 = T.Accent
        end)
    end
end

addInfoRow(infoRows, "Tên Script",     "Dungdx PvP",                    1)
addInfoRow(infoRows, "Phiên bản",      "v2.1.0",                        2)
addInfoRow(infoRows, "Game hỗ trợ",    "Blox Fruits (Roblox)",          3)
addInfoRow(infoRows, "Chủ sở hữu",     "Dungdx",                        4)
addInfoRow(infoRows, "Tên thật",       "Lê Thanh Anh Dũng",             5)
addInfoRow(infoRows, "Discord Server", "Blox Community VN",             6)
addInfoRow(infoRows, "Link Discord",   "https://discord.gg/jbCzvtmSZt", 7, true)

local bannerCard = Instance.new("Frame", pInfo)
bannerCard.Size = UDim2.new(1, 0, 0, 170)
bannerCard.BackgroundColor3 = T.Panel
bannerCard.BorderSizePixel = 0
bannerCard.LayoutOrder = 2
corner(bannerCard, 12)
stroke(bannerCard, T.Accent, 1.5)

local bgGrad = Instance.new("UIGradient", bannerCard)
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 42, 76)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 30, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 20, 42)),
})
bgGrad.Rotation = 135

local ring = Instance.new("Frame", bannerCard)
ring.Size = UDim2.fromOffset(88, 88)
ring.Position = UDim2.new(0.5, -44, 0, 14)
ring.BackgroundTransparency = 1
ring.BorderSizePixel = 0
corner(ring, 44)
local rStroke = Instance.new("UIStroke", ring)
rStroke.Color = T.Accent
rStroke.Thickness = 1
rStroke.Transparency = 0.6

local logoF = Instance.new("Frame", bannerCard)
logoF.Size = UDim2.fromOffset(72, 72)
logoF.Position = UDim2.new(0.5, -36, 0, 22)
logoF.BackgroundColor3 = T.Accent2
logoF.BorderSizePixel = 0
corner(logoF, 20)
grad(logoF, Color3.fromRGB(96, 165, 250), Color3.fromRGB(37, 99, 235))

local logoL = Instance.new("TextLabel", logoF)
logoL.Size = UDim2.fromScale(1, 1)
logoL.BackgroundTransparency = 1
logoL.Text = "D"
logoL.Font = Enum.Font.GothamBlack
logoL.TextSize = 42
logoL.TextColor3 = Color3.fromRGB(255, 255, 255)

local brandL = Instance.new("TextLabel", bannerCard)
brandL.Size = UDim2.new(1, -20, 0, 26)
brandL.Position = UDim2.new(0, 10, 0, 104)
brandL.BackgroundTransparency = 1
brandL.Text = "👑 Dungdx"
brandL.Font = Enum.Font.GothamBlack
brandL.TextSize = 22
brandL.TextColor3 = T.Text

local tagL = Instance.new("TextLabel", bannerCard)
tagL.Size = UDim2.new(1, -20, 0, 18)
tagL.Position = UDim2.new(0, 10, 0, 132)
tagL.BackgroundTransparency = 1
tagL.Text = "PvP Script for Blox Fruits"
tagL.Font = Enum.Font.GothamMedium
tagL.TextSize = 12
tagL.TextColor3 = T.Accent

local featRows = buildInfoSection(pInfo, "Tính năng hiện có", "Những tính năng chính của script", 3)

local features = {
    { icon = "🎯", name = "Macro",    desc = "Tự động hóa thao tác",         color = Color3.fromRGB(96, 165, 250)  },
    { icon = "👁️", name = "Visual",   desc = "Hiển thị thông tin trong game", color = Color3.fromRGB(167, 139, 250) },
    { icon = "🏃", name = "Move",     desc = "Hỗ trợ di chuyển, né skill",    color = Color3.fromRGB(52, 211, 153)  },
    { icon = "⚙️", name = "Settings", desc = "Tùy chỉnh & cá nhân hóa",       color = Color3.fromRGB(251, 191, 36)  },
}

for i, f in ipairs(features) do
    local card = Instance.new("Frame", featRows)
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = T.Card
    card.BorderSizePixel = 0
    card.LayoutOrder = i
    corner(card, 10)
    stroke(card, f.color, 1.2, 0.3)

    local iconF = Instance.new("Frame", card)
    iconF.Size = UDim2.fromOffset(36, 36)
    iconF.Position = UDim2.fromOffset(10, 12)
    iconF.BackgroundColor3 = f.color
    iconF.BackgroundTransparency = 0.82
    iconF.BorderSizePixel = 0
    corner(iconF, 9)

    local iconL = Instance.new("TextLabel", iconF)
    iconL.Size = UDim2.fromScale(1, 1)
    iconL.BackgroundTransparency = 1
    iconL.Text = f.icon
    iconL.Font = Enum.Font.GothamBold
    iconL.TextSize = 17
    iconL.TextColor3 = f.color

    local nameL = Instance.new("TextLabel", card)
    nameL.Size = UDim2.new(1, -90, 0, 16)
    nameL.Position = UDim2.fromOffset(56, 12)
    nameL.BackgroundTransparency = 1
    nameL.Text = f.name
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 13
    nameL.TextColor3 = T.Text
    nameL.TextXAlignment = Enum.TextXAlignment.Left

    local descL = Instance.new("TextLabel", card)
    descL.Size = UDim2.new(1, -90, 0, 14)
    descL.Position = UDim2.fromOffset(56, 30)
    descL.BackgroundTransparency = 1
    descL.Text = f.desc
    descL.Font = Enum.Font.Gotham
    descL.TextSize = 10
    descL.TextColor3 = T.Sub
    descL.TextXAlignment = Enum.TextXAlignment.Left

    local arrowL = Instance.new("TextLabel", card)
    arrowL.Size = UDim2.fromOffset(24, 24)
    arrowL.AnchorPoint = Vector2.new(1, 0.5)
    arrowL.Position = UDim2.new(1, -10, 0.5, 0)
    arrowL.BackgroundTransparency = 1
    arrowL.Text = "›"
    arrowL.Font = Enum.Font.GothamBold
    arrowL.TextSize = 22
    arrowL.TextColor3 = T.Sub
end

local footerCard = Instance.new("Frame", pInfo)
footerCard.Size = UDim2.new(1, 0, 0, 88)
footerCard.BackgroundColor3 = T.Panel
footerCard.BorderSizePixel = 0
footerCard.LayoutOrder = 4
corner(footerCard, 12)
stroke(footerCard, T.Stroke, 1)

local heartF = Instance.new("Frame", footerCard)
heartF.Size = UDim2.fromOffset(44, 44)
heartF.Position = UDim2.fromOffset(16, 22)
heartF.BackgroundColor3 = T.Accent2
heartF.BackgroundTransparency = 0.7
heartF.BorderSizePixel = 0
corner(heartF, 22)
stroke(heartF, T.Accent, 1, 0.4)

local heartL = Instance.new("TextLabel", heartF)
heartL.Size = UDim2.fromScale(1, 1)
heartL.BackgroundTransparency = 1
heartL.Text = "♥"
heartL.Font = Enum.Font.GothamBold
heartL.TextSize = 20
heartL.TextColor3 = T.Accent

local thankL = Instance.new("TextLabel", footerCard)
thankL.Size = UDim2.new(1, -80, 0, 18)
thankL.Position = UDim2.fromOffset(72, 18)
thankL.BackgroundTransparency = 1
thankL.Text = "Cảm ơn bạn đã sử dụng script!"
thankL.Font = Enum.Font.GothamBold
thankL.TextSize = 12
thankL.TextColor3 = T.Text
thankL.TextXAlignment = Enum.TextXAlignment.Left

local wishL = Instance.new("TextLabel", footerCard)
wishL.Size = UDim2.new(1, -80, 0, 16)
wishL.Position = UDim2.fromOffset(72, 38)
wishL.BackgroundTransparency = 1
wishL.Text = "Chúc bạn có những trận PvP thật tuyệt vời!"
wishL.Font = Enum.Font.Gotham
wishL.TextSize = 10
wishL.TextColor3 = T.Sub
wishL.TextXAlignment = Enum.TextXAlignment.Left

local signL = Instance.new("TextLabel", footerCard)
signL.Size = UDim2.new(1, -80, 0, 14)
signL.Position = UDim2.fromOffset(72, 58)
signL.BackgroundTransparency = 1
signL.Text = "— Dungdx  ♛"
signL.Font = Enum.Font.GothamMedium
signL.TextSize = 11
signL.TextColor3 = T.Accent
signL.TextXAlignment = Enum.TextXAlignment.Left

-- ============================================================
-- NEON GLOW + PRESS ANIMATION
-- ============================================================
local Neon = {
    enabled = true,
    pressAnim = true,
    thicknessBoost = 0.8,
    pulse = true,
}

local function neonize(c)
    local h, s, v = Color3.toHSV(c)
    s = math.min(1, s * 1.4 + 0.15)
    v = math.min(1, v * 1.15 + 0.25)
    return Color3.fromHSV(h, s, v)
end

local function applyNeonStroke(st)
    if not st or not st.Parent then return end
    if st:GetAttribute("__neon") then return end
    st:SetAttribute("__neon", true)

    local base = st.Color
    local bright = neonize(base)

    st.Transparency = 0
    if st.Thickness < 1.5 + Neon.thicknessBoost then
        st.Thickness = 1.5 + Neon.thicknessBoost
    end
    st.Color = bright

    local g = Instance.new("UIGradient", st)
    g.Name = "__neonGrad"
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, bright),
        ColorSequenceKeypoint.new(0.5, Color3.new(
            math.min(1, bright.R + .3),
            math.min(1, bright.G + .3),
            math.min(1, bright.B + .3)
        )),
        ColorSequenceKeypoint.new(1, bright),
    })
    g.Rotation = 45

    if Neon.pulse then
        task.spawn(function()
            while st.Parent and st:GetAttribute("__neon") do
                TW:Create(st, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Transparency = 0.15
                }):Play()
                task.wait(1.2)
                if not st.Parent then break end
                TW:Create(st, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Transparency = 0
                }):Play()
                task.wait(1.2)
            end
        end)
    end
end

local function attachPress(btn)
    if not btn or not btn.Parent then return end
    if btn:GetAttribute("__press") then return end
    btn:SetAttribute("__press", true)

    local target = btn
    if btn:IsA("GuiObject") and btn.BackgroundTransparency >= 0.9 then
        local par = btn.Parent
        if par and par:IsA("GuiObject") then target = par end
    end

    local sc = target:FindFirstChildOfClass("UIScale")
    if not sc then
        sc = Instance.new("UIScale", target)
        sc.Scale = 1
    end

    local pressing = false

    local function down()
        pressing = true
        TW:Create(sc, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Scale = 0.93
        }):Play()
    end
    local function up()
        if not pressing then return end
        pressing = false
        TW:Create(sc, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = 1
        }):Play()
    end

    btn.MouseButton1Down:Connect(down)
    btn.MouseButton1Up:Connect(up)
    btn.MouseLeave:Connect(up)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then down() end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then up() end
    end)
end

local function scanNeonAll()
    if not Neon.enabled and not Neon.pressAnim then return end
    for _, inst in ipairs(GUI:GetDescendants()) do
        if inst:IsA("UIStroke") and Neon.enabled then
            applyNeonStroke(inst)
        elseif (inst:IsA("TextButton") or inst:IsA("ImageButton")) and Neon.pressAnim then
            attachPress(inst)
        end
    end
end

GUI.DescendantAdded:Connect(function(inst)
    task.defer(function()
        if inst:IsA("UIStroke") and Neon.enabled then
            applyNeonStroke(inst)
        elseif (inst:IsA("TextButton") or inst:IsA("ImageButton")) and Neon.pressAnim then
            attachPress(inst)
        end
    end)
end)

scanNeonAll()

-- ============================================================
-- TOGGLE BUTTON
-- ============================================================
local ToggleBtn = Instance.new("TextButton", GUI)
ToggleBtn.Size = UDim2.fromOffset(52, 52)
ToggleBtn.Position = UDim2.new(0, 16, .5, -26)
ToggleBtn.BackgroundColor3 = T.Accent2
ToggleBtn.Text = "⚙"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 22
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Visible = false
corner(ToggleBtn, 26)
stroke(ToggleBtn, T.Accent, 2, .4)
grad(ToggleBtn, Color3.fromRGB(96,165,250), Color3.fromRGB(37,99,235))
drag(ToggleBtn)

_G.__toggleBtnRef = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = true
    ToggleBtn.Visible = false
end)

Close.MouseButton1Click:Connect(function() GUI.Enabled = false end)
Min.MouseButton1Click:Connect(function()
    Main.Visible = false
    ToggleBtn.Visible = true
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
        ToggleBtn.Visible = not Main.Visible
    end
end)

-- applyScale lần cuối khi mọi thứ đã sẵn sàng
task.defer(applyScale)
task.delay(0.1, applyScale)

-- ============================================================
-- PUBLIC API
-- ============================================================
_G.DungdxPvP = {
    GUI      = GUI,
    Main     = Main,
    Theme    = T,
    Macros   = Macros,
    Refresh  = refreshMacros,
    Destroy  = function()
        for _, p in ipairs(Players:GetPlayers()) do removeESP(p) end
        pcall(function() GUI:Destroy() end)
        _G.DungdxPvP = nil
        _G.__toggleBtnRef = nil
    end,
}

_G.DungdxNeon = {
    Set = function(on)
        Neon.enabled = on
        if on then scanNeonAll() end
    end,
    Press = function(on)
        Neon.pressAnim = on
        if on then scanNeonAll() end
    end,
    Pulse = function(on) Neon.pulse = on end,
}

print("[Dungdx PvP] Loaded · v2.1.0 · 5 tabs · Macro engine sẵn sàng")
print("[Dungdx PvP] RightShift để ẩn/hiện UI · nút ⚙ nổi để mở lại")