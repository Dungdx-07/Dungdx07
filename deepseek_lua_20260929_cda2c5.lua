--[[
    DUNGDX PVP v2 — Blox Fruit
    Modern UI + Custom Macro Editor
    Discord: https://discord.gg/AJBT8F79yf
]]--

-- ============ SERVICES ============
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TS         = game:GetService("TweenService")
local VIM        = game:GetService("VirtualInputManager")
local VirtualUser= game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local LP         = Players.LocalPlayer

-- ============ CONFIG ============
local Cfg = {
    -- Aimbot
    AimOn       = false,
    AimTeam     = true,
    AimVisible  = false,
    AimSmooth   = 0.35,
    AimFOV      = 350,
    AimPart     = "Head",
    AimKey      = "E",

    -- Auto Attack
    AttackOn    = false,
    AttackRange = 25,

    -- Macro
    MacroAuto   = false,     -- auto lặp macro khi gần địch
    MacroHold   = false,     -- chỉ chạy khi giữ phím
    MacroKey    = "Q",
    MacroRange  = 30,

    -- ESP
    ESPOn       = false,
    ESPTeam     = true,
    ESPName     = true,
    ESPDist     = true,
    ESPHealth   = true,
    ESPMaxDist  = 3000,

    -- Misc
    ShowHUD     = true,
}

-- ============ MACRO STORAGE ============
-- Step: { type = "skill"|"m1"|"wait"|"dash", value = string/number, delay = number }
local Macros = {
    ["Combo Cơ Bản"] = {
        { type = "skill", value = "Z", delay = 0.1 },
        { type = "skill", value = "X", delay = 0.1 },
        { type = "skill", value = "C", delay = 0.15 },
        { type = "skill", value = "V", delay = 0.15 },
    },
}
local ActiveMacro = "Combo Cơ Bản"

-- ============ THEME ============
local T = {
    Bg      = Color3.fromRGB(14, 14, 20),
    Card    = Color3.fromRGB(22, 22, 32),
    Row     = Color3.fromRGB(30, 30, 42),
    RowHov  = Color3.fromRGB(40, 40, 55),
    Accent  = Color3.fromRGB(130, 85, 255),
    Accent2 = Color3.fromRGB(90, 175, 255),
    Text    = Color3.fromRGB(235, 235, 245),
    Dim     = Color3.fromRGB(150, 150, 165),
    Green   = Color3.fromRGB(80, 220, 120),
    Red     = Color3.fromRGB(230, 75, 75),
    Orange  = Color3.fromRGB(255, 170, 60),
}

-- ============ HELPERS ============
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p }) end
local function stroke(p, c, t) return new("UIStroke", { Color = c or T.Row, Thickness = t or 1, Parent = p }) end

local function isAlly(plr)
    if plr == LP then return true end
    if not Cfg.AimTeam then return false end
    if plr.Team and LP.Team and plr.Team == LP.Team then return true end
    local a = LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Bounty/Honor")
    local b = plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Bounty/Honor")
    if a and b and a.Value == 0 and b.Value == 0 then return true end
    return false
end

local function alive(plr)
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return c and h and h.Health > 0
end

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
end

-- ============ SCREEN GUI ============
local ScreenGui = new("ScreenGui", {
    Name = "DungdxPvP",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = LP:WaitForChild("PlayerGui"),
})

-- ============ NOTIFICATION (top-right, no overlap) ============
local NotifHolder = new("Frame", {
    Name = "NotifHolder",
    Size = UDim2.new(0, 260, 0, 400),
    Position = UDim2.new(1, -270, 0, 70),
    BackgroundTransparency = 1,
    Parent = ScreenGui,
})
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = NotifHolder })

local function Notify(title, text, dur)
    local n = new("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = T.Card,
        BorderSizePixel = 0,
        Parent = NotifHolder,
    })
    corner(n, 10); stroke(n, T.Accent, 1.2)
    local bar = new("Frame", {
        Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.new(0, 6, 0, 8),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Parent = n,
    })
    corner(bar, 2)
    new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 18),
        Position = UDim2.new(0, 16, 0, 8),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = title, Parent = n,
    })
    new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 24),
        Position = UDim2.new(0, 16, 0, 28),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = T.Dim, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text, Parent = n,
    })
    task.delay(dur or 4, function() pcall(function() n:Destroy() end) end)
end

-- ============ MAIN WINDOW ============
local Main = new("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 500, 0, 520),
    Position = UDim2.new(0.5, -250, 0.5, -260),
    BackgroundColor3 = T.Bg,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    Parent = ScreenGui,
})
corner(Main, 14); stroke(Main, T.Accent, 1.5)

-- responsive scale
local uiScale = new("UIScale", { Parent = Main })
local function fit()
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1000, 700)
    local s = math.min((vp.X - 40) / 500, (vp.Y - 100) / 520)
    uiScale.Scale = math.clamp(s, 0.6, 1)
end
fit()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
end

-- Header
local Header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = T.Card,
    BorderSizePixel = 0,
    Parent = Main,
})
corner(Header, 14)

new("TextLabel", {
    Size = UDim2.new(1, -60, 0, 20),
    Position = UDim2.new(0, 18, 0, 10),
    BackgroundTransparency = 1,
    Text = "DUNGDX PVP",
    Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})
new("TextLabel", {
    Size = UDim2.new(1, -60, 0, 14),
    Position = UDim2.new(0, 18, 0, 30),
    BackgroundTransparency = 1,
    Text = "Blox Fruit • Macro Editor",
    Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})

local CloseBtn = new("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -40, 0, 11),
    BackgroundColor3 = T.Red,
    Text = "×", Font = Enum.Font.GothamBold, TextSize = 18,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
    Parent = Header,
})
corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Floating toggle button
local FAB = new("TextButton", {
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(0, 20, 0.5, -26),
    BackgroundColor3 = T.Accent,
    Text = "PVP", Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
    Draggable = true,
    Parent = ScreenGui,
})
corner(FAB, 999)
stroke(FAB, Color3.fromRGB(180, 140, 255), 2)
FAB.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Tab bar
local TabBar = new("Frame", {
    Size = UDim2.new(1, -24, 0, 34),
    Position = UDim2.new(0, 12, 0, 60),
    BackgroundTransparency = 1,
    Parent = Main,
})
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = TabBar })

-- Content area
local Content = new("Frame", {
    Size = UDim2.new(1, -24, 1, -108),
    Position = UDim2.new(0, 12, 0, 100),
    BackgroundTransparency = 1,
    Parent = Main,
})

local Tabs = {}
local ActiveTabName = nil

local function makeTab(name)
    local sc = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = Content,
    })
    local ll = new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sc })
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sc.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 12)
    end)

    local btn = new("TextButton", {
        Size = UDim2.new(0, 110, 1, 0),
        BackgroundColor3 = T.Row,
        Text = name, Font = Enum.Font.GothamSemibold, TextSize = 11,
        TextColor3 = T.Dim, AutoButtonColor = false,
        Parent = TabBar,
    })
    corner(btn, 8)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.frame.Visible = false
            t.btn.BackgroundColor3 = T.Row
            t.btn.TextColor3 = T.Dim
        end
        sc.Visible = true
        btn.BackgroundColor3 = T.Accent
        btn.TextColor3 = Color3.new(1, 1, 1)
        ActiveTabName = name
    end)

    Tabs[name] = { frame = sc, btn = btn }
    return sc
end

local TCombat = makeTab("Chiến Đấu")
local TMacro  = makeTab("Macro")
local TVisual = makeTab("Hiển Thị")
local TSetting= makeTab("Cài Đặt")

TCombat.Visible = true
Tabs["Chiến Đấu"].btn.BackgroundColor3 = T.Accent
Tabs["Chiến Đấu"].btn.TextColor3 = Color3.new(1, 1, 1)
ActiveTabName = "Chiến Đấu"

-- ============ UI COMPONENTS ============
local function section(parent, title)
    local s = new("Frame", {
        Size = UDim2.new(1, -4, 0, 0),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    local lbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = s,
    })
    local body = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = s,
    })
    local ll = new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = body })
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.Size = UDim2.new(1, -4, 0, 24 + ll.AbsoluteContentSize.Y)
    end)
    return body
end

local function toggle(parent, text, default, cb)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local pill = new("TextButton", {
        Size = UDim2.new(0, 46, 0, 22),
        Position = UDim2.new(1, -58, 0, 6),
        BackgroundColor3 = default and T.Accent or Color3.fromRGB(60, 60, 75),
        Text = "", AutoButtonColor = false,
        Parent = row,
    })
    corner(pill, 999)
    local knob = new("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = pill,
    })
    corner(knob, 999)
    local st = default
    local function paint()
        if st then
            pill.BackgroundColor3 = T.Accent
            TS:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(1, -20, 0, 2) }):Play()
        else
            pill.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            TS:Create(knob, TweenInfo.new(0.15), { Position = UDim2.new(0, 2, 0, 2) }):Play()
        end
    end
    pill.MouseButton1Click:Connect(function()
        st = not st; paint()
        if cb then pcall(cb, st) end
    end)
    return { Set = function(_, v) st = v; paint() end, Get = function() return st end }
end

local function slider(parent, text, min, max, default, step, cb)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(0.7, -20, 0, 16), Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local val = new("TextLabel", {
        Size = UDim2.new(0.3, -14, 0, 16), Position = UDim2.new(0.7, 0, 0, 6),
        BackgroundTransparency = 1, Text = tostring(default),
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    local track = new("Frame", {
        Size = UDim2.new(1, -28, 0, 4),
        Position = UDim2.new(0, 14, 0, 34),
        BackgroundColor3 = Color3.fromRGB(60, 60, 75),
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(track, 999)
    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(fill, 999)
    local cur = default
    local function setV(v, fire)
        v = math.clamp(v, min, max)
        if step and step > 0 then v = math.floor((v - min) / step + 0.5) * step + min end
        cur = v
        local a = (max - min) == 0 and 0 or (v - min) / (max - min)
        fill.Size = UDim2.new(a, 0, 1, 0)
        val.Text = (math.floor(v * 100 + 0.5) / 100)
        if fire and cb then pcall(cb, v) end
    end
    setV(default, false)
    local drag = false
    local function upd(i)
        local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local a = track.AbsoluteSize.X == 0 and 0 or x / track.AbsoluteSize.X
        setV(min + (max - min) * a, true)
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
    return { Get = function() return cur end, Set = function(_, v) setV(v, false) end }
end

local function dropdown(parent, text, default, options, cb)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(0.45, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local btn = new("TextButton", {
        Size = UDim2.new(0.55, -14, 1, -10), Position = UDim2.new(0.45, 0, 0, 5),
        BackgroundColor3 = T.Card,
        Text = tostring(default), Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, AutoButtonColor = false,
        Parent = row,
    })
    corner(btn, 6)
    local cur, idx = default, 1
    for i, v in ipairs(options) do if v == default then idx = i break end end
    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        cur = options[idx]
        btn.Text = tostring(cur)
        if cb then pcall(cb, cur) end
    end)
    return {
        Get = function() return cur end,
        Set = function(_, v)
            cur = v; btn.Text = tostring(v)
            for i, o in ipairs(options) do if o == v then idx = i break end end
            if cb then pcall(cb, v) end
        end,
        SetOptions = function(_, newOpts, newVal)
            options = newOpts
            if newVal then cur = newVal; btn.Text = tostring(newVal) end
            for i, o in ipairs(options) do if o == cur then idx = i break end end
        end
    }
end

local function button(parent, text, color, cb)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = color or T.Accent,
        Text = text, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
        Parent = parent,
    })
    corner(b, 8)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = color and color:Lerp(Color3.new(1,1,1), 0.15) or T.Accent:Lerp(Color3.new(1,1,1), 0.15) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = color or T.Accent end)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return b
end

-- ============ TAB: CHIẾN ĐẤU ============
do
    local sec = section(TCombat, "🎯 AIMBOT")
    toggle(sec, "Bật Aimbot  (giữ phím để lock)", Cfg.AimOn, function(v) Cfg.AimOn = v end)
    toggle(sec, "Kiểm tra đồng đội", Cfg.AimTeam, function(v) Cfg.AimTeam = v end)
    toggle(sec, "Chỉ lock khi nhìn thấy", Cfg.AimVisible, function(v) Cfg.AimVisible = v end)
    slider(sec, "Độ mượt", 0, 1, Cfg.AimSmooth, 0.05, function(v) Cfg.AimSmooth = v end)
    slider(sec, "Vùng FOV", 50, 800, Cfg.AimFOV, 10, function(v) Cfg.AimFOV = v end)
    dropdown(sec, "Bộ phận ngắm", Cfg.AimPart, {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, function(v) Cfg.AimPart = v end)
    dropdown(sec, "Phím giữ Aimbot", Cfg.AimKey, {"E", "Q", "C", "V", "F", "R", "T", "G"}, function(v) Cfg.AimKey = v end)

    local sec2 = section(TCombat, "⚔️ ĐÁNH TỰ ĐỘNG")
    toggle(sec2, "Auto M1 (tự click)", Cfg.AttackOn, function(v) Cfg.AttackOn = v end)
    slider(sec2, "Tầm M1", 10, 40, Cfg.AttackRange, 1, function(v) Cfg.AttackRange = v end)
end

-- ============ TAB: MACRO ============
local macroUI = {}     -- để refresh khi cần
do
    local sec = section(TMacro, "⚙️ CẤU HÌNH MACRO")
    local comboDropdown, keyDropdown

    local macroNames = {}
    for name in pairs(Macros) do table.insert(macroNames, name) end
    table.sort(macroNames)

    comboDropdown = dropdown(sec, "Macro đang dùng", ActiveMacro, macroNames, function(v)
        ActiveMacro = v
        if macroUI.refresh then macroUI.refresh() end
    end)

    keyDropdown = dropdown(sec, "Phím kích hoạt", Cfg.MacroKey, {"Q", "E", "R", "T", "F", "G", "H", "Z"}, function(v) Cfg.MacroKey = v end)

    slider(sec, "Tầm chạy Macro", 10, 60, Cfg.MacroRange, 1, function(v) Cfg.MacroRange = v end)
    toggle(sec, "Tự lặp khi gần địch", Cfg.MacroAuto, function(v) Cfg.MacroAuto = v end)

    -- Quản lý macro
    local sec2 = section(TMacro, "📋 QUẢN LÝ MACRO")
    local btnRow = new("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Parent = sec2,
    })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = btnRow })
    local mkBtn = new("TextButton", {
        Size = UDim2.new(0.5, -3, 1, 0),
        BackgroundColor3 = T.Green,
        Text = "+ Tạo Macro Mới",
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false,
        Parent = btnRow,
    })
    corner(mkBtn, 8)
    local delBtn = new("TextButton", {
        Size = UDim2.new(0.5, -3, 1, 0),
        BackgroundColor3 = T.Red,
        Text = "Xóa Macro Này",
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false,
        Parent = btnRow,
    })
    corner(delBtn, 8)

    -- Hộp tạo macro mới
    local newRow = new("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Visible = false,
        Parent = sec2,
    })
    corner(newRow, 8)
    local tb = new("TextBox", {
        Size = UDim2.new(1, -80, 1, -8),
        Position = UDim2.new(0, 6, 0, 4),
        BackgroundColor3 = T.Card,
        PlaceholderText = "Tên macro mới...",
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, Text = "",
        ClearTextOnFocus = false, Parent = newRow,
    })
    corner(tb, 6)
    local okBtn = new("TextButton", {
        Size = UDim2.new(0, 68, 1, -8),
        Position = UDim2.new(1, -72, 0, 4),
        BackgroundColor3 = T.Green,
        Text = "Tạo",
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false,
        Parent = newRow,
    })
    corner(okBtn, 6)

    mkBtn.MouseButton1Click:Connect(function()
        newRow.Visible = not newRow.Visible
    end)
    okBtn.MouseButton1Click:Connect(function()
        local name = tb.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if name ~= "" and not Macros[name] then
            Macros[name] = {}
            ActiveMacro = name
            local names = {}
            for n in pairs(Macros) do table.insert(names, n) end
            table.sort(names)
            comboDropdown:SetOptions(names, name)
            tb.Text = ""
            newRow.Visible = false
            if macroUI.refresh then macroUI.refresh() end
            Notify("Macro", "Đã tạo: " .. name, 3)
        else
            Notify("Macro", "Tên không hợp lệ hoặc đã tồn tại!", 3)
        end
    end)
    delBtn.MouseButton1Click:Connect(function()
        if ActiveMacro and Macros[ActiveMacro] and ActiveMacro ~= "Combo Cơ Bản" then
            Macros[ActiveMacro] = nil
            local first = nil
            for n in pairs(Macros) do first = n break end
            ActiveMacro = first or "Combo Cơ Bản"
            if not Macros[ActiveMacro] then Macros[ActiveMacro] = {} end
            local names = {}
            for n in pairs(Macros) do table.insert(names, n) end
            table.sort(names)
            comboDropdown:SetOptions(names, ActiveMacro)
            if macroUI.refresh then macroUI.refresh() end
            Notify("Macro", "Đã xóa macro", 3)
        else
            Notify("Macro", "Không thể xóa macro mặc định!", 3)
        end
    end)

    -- Trình soạn thảo bước
    local sec3 = section(TMacro, "🎬 CÁC BƯỚC MACRO")

    -- Add step bar
    local addRow = new("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Parent = sec3,
    })
    corner(addRow, 8)
    new("TextLabel", {
        Size = UDim2.new(0.6, -10, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = "Thêm bước:",
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = addRow,
    })
    local addBtn = new("TextButton", {
        Size = UDim2.new(0.4, -12, 1, -8),
        Position = UDim2.new(0.6, 0, 0, 4),
        BackgroundColor3 = T.Green,
        Text = "+ Thêm Bước",
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false,
        Parent = addRow,
    })
    corner(addBtn, 6)

    -- Step type selector popup
    local stepPopup = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = T.Card,
        BorderSizePixel = 0,
        Visible = false,
        Parent = sec3,
    })
    corner(stepPopup, 8)
    local spL = new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = stepPopup })
    local spPad = new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = stepPopup })
    spL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        stepPopup.Size = UDim2.new(1, 0, 0, spL.AbsoluteContentSize.Y + 12)
    end)

    local stepTypes = {
        { label = "Skill Z", type = "skill", value = "Z" },
        { label = "Skill X", type = "skill", value = "X" },
        { label = "Skill C", type = "skill", value = "C" },
        { label = "Skill V", type = "skill", value = "V" },
        { label = "Skill F", type = "skill", value = "F" },
        { label = "M1 (Click chuột)", type = "m1", value = 1 },
        { label = "Dash (W+W)", type = "dash", value = "W" },
        { label = "Chờ 0.1s", type = "wait", value = 0.1 },
        { label = "Chờ 0.3s", type = "wait", value = 0.3 },
        { label = "Chờ 0.5s", type = "wait", value = 0.5 },
    }
    for _, opt in ipairs(stepTypes) do
        local b = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = T.Row,
            Text = opt.label,
            Font = Enum.Font.Gotham, TextSize = 11,
            TextColor3 = T.Text, AutoButtonColor = false,
            Parent = stepPopup,
        })
        corner(b, 6)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = T.RowHov end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = T.Row end)
        b.MouseButton1Click:Connect(function()
            if ActiveMacro and Macros[ActiveMacro] then
                table.insert(Macros[ActiveMacro], {
                    type = opt.type,
                    value = opt.value,
                    delay = 0.08,
                })
                stepPopup.Visible = false
                if macroUI.refresh then macroUI.refresh() end
            end
        end)
    end

    addBtn.MouseButton1Click:Connect(function()
        stepPopup.Visible = not stepPopup.Visible
    end)

    -- Step list container
    local stepList = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = sec3,
    })
    local slL = new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = stepList })
    slL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        stepList.Size = UDim2.new(1, 0, 0, slL.AbsoluteContentSize.Y)
    end)

    -- Refresh steps
    macroUI.refresh = function()
        for _, c in ipairs(stepList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local steps = Macros[ActiveMacro] or {}
        for i, step in ipairs(steps) do
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = T.Row,
                BorderSizePixel = 0,
                Parent = stepList,
            })
            corner(row, 6)

            new("TextLabel", {
                Size = UDim2.new(0, 26, 1, 0), Position = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1, Text = "#" .. i,
                Font = Enum.Font.GothamBold, TextSize = 10,
                TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local typeText = step.type == "skill" and ("Skill " .. tostring(step.value))
                or step.type == "m1" and "M1 Click"
                or step.type == "dash" and "Dash"
                or step.type == "wait" and ("Chờ " .. step.value .. "s")
                or "?"

            new("TextLabel", {
                Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 34, 0, 0),
                BackgroundTransparency = 1, Text = typeText,
                Font = Enum.Font.Gotham, TextSize = 11,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            -- delay label
            new("TextLabel", {
                Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -108, 0, 0),
                BackgroundTransparency = 1, Text = string.format("%.2f", step.delay or 0.08),
                Font = Enum.Font.Gotham, TextSize = 10,
                TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })

            -- up/down/delete
            local btnBox = new("Frame", {
                Size = UDim2.new(0, 62, 1, -6),
                Position = UDim2.new(1, -66, 0, 3),
                BackgroundTransparency = 1,
                Parent = row,
            })
            new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2), Parent = btnBox })

            local up = new("TextButton", {
                Size = UDim2.new(0, 18, 1, 0), BackgroundColor3 = T.Card,
                Text = "↑", Font = Enum.Font.GothamBold, TextSize = 11,
                TextColor3 = T.Accent2, AutoButtonColor = false, Parent = btnBox,
            }); corner(up, 4)
            local dn = new("TextButton", {
                Size = UDim2.new(0, 18, 1, 0), BackgroundColor3 = T.Card,
                Text = "↓", Font = Enum.Font.GothamBold, TextSize = 11,
                TextColor3 = T.Accent2, AutoButtonColor = false, Parent = btnBox,
            }); corner(dn, 4)
            local del = new("TextButton", {
                Size = UDim2.new(0, 18, 1, 0), BackgroundColor3 = T.Card,
                Text = "×", Font = Enum.Font.GothamBold, TextSize = 13,
                TextColor3 = T.Red, AutoButtonColor = false, Parent = btnBox,
            }); corner(del, 4)

            up.MouseButton1Click:Connect(function()
                if i > 1 then
                    steps[i], steps[i-1] = steps[i-1], steps[i]
                    macroUI.refresh()
                end
            end)
            dn.MouseButton1Click:Connect(function()
                if i < #steps then
                    steps[i], steps[i+1] = steps[i+1], steps[i]
                    macroUI.refresh()
                end
            end)
            del.MouseButton1Click:Connect(function()
                table.remove(steps, i)
                macroUI.refresh()
            end)
        end

        -- Add/clear buttons
        local ctrl = new("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            Parent = stepList,
        })
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = ctrl })
        local runBtn = new("TextButton", {
            Size = UDim2.new(0.5, -3, 1, 0),
            BackgroundColor3 = T.Accent,
            Text = "▶  CHẠY THỬ",
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, Parent = ctrl,
        }); corner(runBtn, 8)
        local clearBtn = new("TextButton", {
            Size = UDim2.new(0.5, -3, 1, 0),
            BackgroundColor3 = T.Row,
            Text = "🗑  XÓA HẾT",
            Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = T.Red, AutoButtonColor = false, Parent = ctrl,
        }); corner(clearBtn, 8)

        runBtn.MouseButton1Click:Connect(function()
            runMacro()
        end)
        clearBtn.MouseButton1Click:Connect(function()
            if ActiveMacro and Macros[ActiveMacro] then
                Macros[ActiveMacro] = {}
                macroUI.refresh()
            end
        end)
    end

    macroUI.refresh()
end

-- ============ TAB: HIỂN THỊ ============
do
    local sec = section(TVisual, "👁️ ESP")
    toggle(sec, "Bật ESP người chơi", Cfg.ESPOn, function(v)
        Cfg.ESPOn = v
        refreshESP()
    end)
    toggle(sec, "Kiểm tra đồng đội", Cfg.ESPTeam, function(v) Cfg.ESPTeam = v end)
    toggle(sec, "Hiện tên", Cfg.ESPName, function(v) Cfg.ESPName = v end)
    toggle(sec, "Hiện khoảng cách", Cfg.ESPDist, function(v) Cfg.ESPDist = v end)
    toggle(sec, "Hiện thanh máu", Cfg.ESPHealth, function(v) Cfg.ESPHealth = v end)
    slider(sec, "Khoảng cách tối đa", 500, 10000, Cfg.ESPMaxDist, 100, function(v)
        Cfg.ESPMaxDist = v
        for _, b in pairs(espCache) do
            pcall(function() b.MaxDistance = v end)
        end
    end)
end

-- ============ TAB: CÀI ĐẶT ============
do
    local sec = section(TSetting, "⚙️ CHUNG")
    toggle(sec, "Hiện HUD", Cfg.ShowHUD, function(v) Cfg.ShowHUD = v end)
    button(sec, "Tắt Tất Cả Chức Năng", T.Red, function()
        Cfg.AimOn = false; Cfg.AttackOn = false; Cfg.MacroAuto = false; Cfg.ESPOn = false
        clearESP()
        Notify("Dungdx PVP", "Đã tắt toàn bộ chức năng", 3)
    end)
    button(sec, "Rejoin Server", T.Accent2, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end)

    local sec2 = section(TSetting, "💬 DISCORD")
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        Text = "discord.gg/AJBT8F79yf",
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Center,
        Parent = sec2,
    })
end

-- ============ ESP SYSTEM ============
local espCache = {}
function clearESP()
    for k, v in pairs(espCache) do pcall(function() v:Destroy() end) end
    espCache = {}
end

local function createESP(plr)
    if plr == LP then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if espCache[plr] then return end

    local bb = new("BillboardGui", {
        Name = "DungdxESP",
        Adornee = head,
        Size = UDim2.new(0, 200, 0, 42),
        StudsOffset = Vector3.new(0, 3.2, 0),
        AlwaysOnTop = true,
        MaxDistance = Cfg.ESPMaxDist,
        Parent = head,
    })

    local nameL = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 80, 80),
        TextStrokeTransparency = 0.4, TextStrokeColor3 = Color3.new(0,0,0),
        Text = "", Parent = bb,
    })
    local distL = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextStrokeTransparency = 0.4, TextStrokeColor3 = Color3.new(0,0,0),
        Text = "", Parent = bb,
    })
    local hpBg = new("Frame", {
        Size = UDim2.new(0.7, 0, 0, 4), Position = UDim2.new(0.15, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0, Parent = bb,
    }); corner(hpBg, 999)
    local hpFill = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(80, 220, 120),
        BorderSizePixel = 0, Parent = hpBg,
    }); corner(hpFill, 999)

    espCache[plr] = bb

    task.spawn(function()
        while bb.Parent and plr.Parent and Cfg.ESPOn do
            pcall(function()
                local ally = isAlly(plr) and Cfg.ESPTeam
                bb.Enabled = not ally
                if ally then return end
                local c = plr.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                local myChar = LP.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local hRoot = c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
                if h and myRoot and hRoot then
                    nameL.Text = Cfg.ESPName and plr.Name or ""
                    distL.Text = Cfg.ESPDist and ("[" .. math.floor((myRoot.Position - hRoot.Position).Magnitude) .. " studs]") or ""
                    if Cfg.ESPHealth then
                        hpBg.Visible = true
                        hpFill.Size = UDim2.new(math.clamp(h.Health / h.MaxHealth, 0, 1), 0, 1, 0)
                    else
                        hpBg.Visible = false
                    end
                end
            end)
            task.wait(0.12)
        end
        if espCache[plr] == bb then espCache[plr] = nil end
    end)
end

function refreshESP()
    clearESP()
    if not Cfg.ESPOn then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            createESP(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(0.5)
                if Cfg.ESPOn then createESP(plr) end
            end)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if Cfg.ESPOn and plr ~= LP then
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

-- ============ AIMBOT ============
local camera = workspace.CurrentCamera
local function getClosestTarget()
    local closest, closestDist = nil, Cfg.AimFOV
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and alive(plr) and not isAlly(plr) then
            local char = plr.Character
            local part = char:FindFirstChild(Cfg.AimPart) or char:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(sp.X, sp.Y) - camera.ViewportSize / 2).Magnitude
                    if dist < closestDist then
                        if Cfg.AimVisible then
                            local ray = Ray.new(myRoot.Position, (part.Position - myRoot.Position).Unit * (part.Position - myRoot.Position).Magnitude)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {myChar, char})
                            if hit and not hit:IsDescendantOf(char) then
                                continue
                            end
                        end
                        closestDist = dist
                        closest = { plr = plr, part = part }
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not Cfg.AimOn then return end
    local key = Enum.KeyCode[Cfg.AimKey] or Enum.KeyCode.E
    if not UIS:IsKeyDown(key) then return end
    local tgt = getClosestTarget()
    if tgt then
        local goal = CFrame.new(camera.CFrame.Position, tgt.part.Position)
        if Cfg.AimSmooth > 0 then
            camera.CFrame = camera.CFrame:Lerp(goal, 1 - Cfg.AimSmooth)
        else
            camera.CFrame = goal
        end
    end
end)

-- ============ AUTO M1 ============
task.spawn(function()
    while task.wait(0.08) do
        if not Cfg.AttackOn then continue end
        local myChar = LP.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local tool = myChar and myChar:FindFirstChildOfClass("Tool")
        if not myRoot or not tool then continue end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and alive(plr) and not isAlly(plr) then
                local hisChar = plr.Character
                local hisRoot = getRoot(hisChar)
                if hisRoot and (myRoot.Position - hisRoot.Position).Magnitude <= Cfg.AttackRange then
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(hisRoot.Position.X, myRoot.Position.Y, hisRoot.Position.Z))
                    pcall(function()
                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.02)
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end)
                    break
                end
            end
        end
    end
end)

-- ============ MACRO RUNNER ============
local macroRunning = false

function runMacro()
    if macroRunning then return end
    local steps = Macros[ActiveMacro]
    if not steps or #steps == 0 then
        Notify("Macro", "Macro trống, thêm bước trước!", 3)
        return
    end
    macroRunning = true
    task.spawn(function()
        for _, step in ipairs(steps) do
            pcall(function()
                if step.type == "skill" then
                    local k = Enum.KeyCode[step.value]
                    if k then
                        VIM:SendKeyEvent(true, k, false, game)
                        task.wait(0.02)
                        VIM:SendKeyEvent(false, k, false, game)
                    end
                elseif step.type == "m1" then
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.02)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                elseif step.type == "dash" then
                    local k = Enum.KeyCode[step.value] or Enum.KeyCode.W
                    VIM:SendKeyEvent(true, k, false, game)
                    task.wait(0.03)
                    VIM:SendKeyEvent(false, k, false, game)
                    task.wait(0.03)
                    VIM:SendKeyEvent(true, k, false, game)
                    task.wait(0.03)
                    VIM:SendKeyEvent(false, k, false, game)
                elseif step.type == "wait" then
                    task.wait(tonumber(step.value) or 0.1)
                end
            end)
            task.wait(step.delay or 0.08)
        end
        macroRunning = false
    end)
end

-- Auto macro + hold key
task.spawn(function()
    local holdKey = Enum.KeyCode[Cfg.MacroKey] or Enum.KeyCode.Q
    local lastKey = Cfg.MacroKey
    local lastAuto = false
    local cooldown = 0

    while task.wait(0.05) do
        if Cfg.MacroKey ~= lastKey then
            lastKey = Cfg.MacroKey
            holdKey = Enum.KeyCode[Cfg.MacroKey] or Enum.KeyCode.Q
        end

        if macroRunning then continue end

        -- Chạy khi giữ phím
        if UIS:IsKeyDown(holdKey) then
            if tick() - cooldown > 0.3 then
                cooldown = tick()
                runMacro()
            end
            continue
        end

        -- Auto loop khi có địch gần
        if Cfg.MacroAuto then
            local myChar = LP.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and alive(plr) and not isAlly(plr) then
                        local hisRoot = getRoot(plr.Character)
                        if hisRoot and (myRoot.Position - hisRoot.Position).Magnitude <= Cfg.MacroRange then
                            myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(hisRoot.Position.X, myRoot.Position.Y, hisRoot.Position.Z))
                            runMacro()
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- ============ ANTI-AFK ============
LP.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

-- ============ HUD ============
local hud = new("TextLabel", {
    Size = UDim2.new(0, 340, 0, 20),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code, TextSize = 12,
    TextColor3 = T.Green,
    TextStrokeTransparency = 0.5,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = ScreenGui,
})

RunService.RenderStepped:Connect(function()
    if not Cfg.ShowHUD then hud.Visible = false return end
    hud.Visible = true
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local cnt = 0
    if myRoot then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and alive(plr) and not isAlly(plr) then
                local r = getRoot(plr.Character)
                if r and (myRoot.Position - r.Position).Magnitude <= Cfg.ESPMaxDist then
                    cnt = cnt + 1
                end
            end
        end
    end
    hud.Text = string.format("[DUNGDX PVP]  Aim:%s  M1:%s  Macro:%s  ESP:%s  |  Enemies: %d",
        Cfg.AimOn and "ON" or "--",
        Cfg.AttackOn and "ON" or "--",
        Cfg.MacroAuto and "ON" or "--",
        Cfg.ESPOn and "ON" or "--",
        cnt)
end)

-- ============ INIT ============
refreshESP()

Notify("Dungdx PVP", "Script đã sẵn sàng! Nhấn nút PVP để mở menu.", 5)
Notify("Hướng dẫn Macro", "Vào tab Macro → Thêm Bước → Chạy Thử. Giữ phím kích hoạt để dùng.", 6)

print("[Dungdx PVP v2] Loaded.")