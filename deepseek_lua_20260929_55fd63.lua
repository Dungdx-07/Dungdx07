--[[
    DUNGDX PVP — Blox Fruit PvP Tool
    Discord: https://discord.gg/jbCzvtmSZ
]]

-- ============ SERVICES ============
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local TweenSvc    = game:GetService("TweenService")
local Lighting    = game:GetService("Lighting")
local HttpSvc     = game:GetService("HttpService")
local StarterGui  = game:GetService("StarterGui")
local TeleportSvc = game:GetService("TeleportService")
local CollectionSvc = game:GetService("CollectionService")
local LP          = Players.LocalPlayer

-- Optional services
local VIM, VU
pcall(function() VIM = game:GetService("VirtualInputManager") end)
pcall(function() VU  = game:GetService("VirtualUser") end)

-- Executor capabilities
local HAS_FILE = (type(writefile) == "function" and type(readfile) == "function")
local HAS_HOOK = (type(getrawmetatable) == "function" and type(newcclosure) == "function"
                  and type(setreadonly) == "function" and type(getnamecallmethod) == "function")
local HAS_GETHUI = (type(gethui) == "function")

print("[DUNGDX] Loading... (Hook:", HAS_HOOK, "| File:", HAS_FILE, ")")

-- ============ CONFIG ============
local C = {
    -- Aimbot
    AimOn = false, AimMode = "Player gần nhất",
    AimTeam = true, AimSmooth = 0.35, AimFOV = 250, AimPart = "Head",
    AimSilent = false, AimAutoLock = true,

    -- Soru
    SoruOn = false, SoruRange = 100, SoruTarget = "Cả hai", SoruKey = "R",

    -- Macro
    MacroAuto = false, MacroRange = 30,

    -- ESP
    ESPOn = false, ESPTeam = false, ESPMaxDist = 10000,

    -- Hitbox
    HB_Player = false, HB_NPC = false,

    -- Movement
    Fly = false, FlySpeed = 50,
    Speed = 16, Jump = 50,
    Water = false, NoClip = false,

    -- Misc
    Bright = false, FixLag = false, NoFog = false, ShowHUD = true,
}

-- ============ MACRO PRESETS ============
local Macros = {
    ["Combo Full"] = {
        {t="weapon", v="Melee",       d=0.08},
        {t="skill",  v="Z",           d=0.10},
        {t="skill",  v="X",           d=0.10},
        {t="weapon", v="Sword",       d=0.08},
        {t="skill",  v="Z",           d=0.12},
        {t="weapon", v="Blox Fruit",  d=0.08},
        {t="skill",  v="Z",           d=0.12},
        {t="skill",  v="X",           d=0.15},
    },
    ["Combo Melee"] = {
        {t="weapon", v="Melee", d=0.08},
        {t="skill",  v="Z",     d=0.10},
        {t="skill",  v="X",     d=0.10},
        {t="skill",  v="C",     d=0.15},
    },
    ["Combo Sword"] = {
        {t="weapon", v="Sword", d=0.08},
        {t="skill",  v="Z",     d=0.10},
        {t="skill",  v="X",     d=0.15},
    },
    ["Combo Gun"] = {
        {t="weapon", v="Gun",   d=0.08},
        {t="skill",  v="Z",     d=0.15},
        {t="m1",     v=1,       d=0.10},
    },
    ["Combo Fruit"] = {
        {t="weapon", v="Blox Fruit", d=0.08},
        {t="skill",  v="Z",          d=0.12},
        {t="skill",  v="X",          d=0.12},
        {t="skill",  v="C",          d=0.18},
    },
}
local ActiveMacro = "Combo Full"

-- ============ SAVE / LOAD ============
local SAVE_FILE = "DungdxPvP_Config.json"

local function loadCfg()
    if not HAS_FILE then return false end
    local ok, raw = pcall(readfile, SAVE_FILE)
    if not ok or not raw or raw == "" then return false end
    local ok2, data = pcall(function() return HttpSvc:JSONDecode(raw) end)
    if not ok2 or type(data) ~= "table" then return false end

    if type(data.Cfg) == "table" then
        for k, v in pairs(data.Cfg) do
            if C[k] ~= nil then C[k] = v end
        end
    end

    -- QUAN TRỌNG: XÓA SẠCH macro cũ trước khi load
    if type(data.Macros) == "table" then
        for k in pairs(Macros) do Macros[k] = nil end
        for n, s in pairs(data.Macros) do
            if type(s) == "table" then Macros[n] = s end
        end
    end

    if type(data.ActiveMacro) == "string" and Macros[data.ActiveMacro] then
        ActiveMacro = data.ActiveMacro
    end
    return true
end

local function saveCfg()
    if not HAS_FILE then return end
    pcall(function()
        writefile(SAVE_FILE, HttpSvc:JSONEncode({
            Cfg = C, Macros = Macros, ActiveMacro = ActiveMacro,
        }))
    end)
end

local loaded = loadCfg()

-- ============ HELPERS ============
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r) return mk("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p}) end
local function stroke(p, c, t, tr)
    return mk("UIStroke", {Color = c, Thickness = t or 1, Transparency = tr or 0, Parent = p})
end
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 4})
    end)
end

local function isAlly(plr)
    if plr == LP then return true end
    if not C.AimTeam then return false end
    -- Check Team chính
    if plr.Team and LP.Team and plr.Team == LP.Team then return true end
    -- Check Ally tag (Blox Fruit dùng)
    if plr:HasTag("Ally" .. LP.Name) or LP:HasTag("Ally" .. plr.Name) then return true end
    return false
end

local function isAlive(plr)
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return c and h and h.Health > 0
end

-- Safe Zone check (từ Quantum)
local function inSafeZone(plr)
    if not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")) then
        return false
    end
    if plr.Character:FindFirstChild("ForceField") then
        return true
    end
    local root = plr.Character.HumanoidRootPart
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:find("SafeZone") or obj.Name:find("PeaceZone")) then
            if (root.Position - obj.Position).Magnitude < obj.Size.Magnitude / 2 + 10 then
                return true
            end
        end
    end
    return false
end

local function getRoot(c) return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) end
local function getHum(c) return c and c:FindFirstChildOfClass("Humanoid") end
local function getCam() return workspace.CurrentCamera end

-- ============ THEME ============
local T = {
    Bg = Color3.fromRGB(12, 10, 14),
    Card = Color3.fromRGB(22, 18, 22),
    Row = Color3.fromRGB(32, 24, 30),
    Neon = Color3.fromRGB(255, 45, 70),
    NeonGlow = Color3.fromRGB(255, 30, 60),
    OrangeNeon = Color3.fromRGB(255, 100, 30),
    Text = Color3.fromRGB(240, 240, 245),
    Dim = Color3.fromRGB(160, 160, 170),
    Green = Color3.fromRGB(80, 220, 120),
    Red = Color3.fromRGB(230, 60, 60),
}

-- ============ SCREEN GUI ============
local ScreenGui = mk("ScreenGui", {
    Name = "DungdxPvP", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = HAS_GETHUI and gethui() or LP:WaitForChild("PlayerGui"),
})

-- ============ MAIN WINDOW ============
local Main = mk("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 480, 0, 520),
    Position = UDim2.new(0.5, -240, 0.5, -260),
    BackgroundColor3 = T.Bg, BorderSizePixel = 0,
    Active = true, Draggable = true, Parent = ScreenGui,
})
corner(Main, 14)
stroke(Main, T.Neon, 2)
stroke(Main, T.NeonGlow, 8, 0.75)

-- Scale responsive
local uiScale = mk("UIScale", {Parent = Main})
local function fitUI()
    local c = getCam()
    local vp = c and c.ViewportSize or Vector2.new(1000, 700)
    uiScale.Scale = math.clamp(math.min((vp.X - 40) / 480, (vp.Y - 90) / 520), 0.6, 1)
end
fitUI()
if getCam() then getCam():GetPropertyChangedSignal("ViewportSize"):Connect(fitUI) end

-- Header
local Header = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = T.Card, BorderSizePixel = 0, Parent = Main,
})
corner(Header, 14)
mk("TextLabel", {
    Size = UDim2.new(1, -60, 0, 20), Position = UDim2.new(0, 18, 0, 8),
    BackgroundTransparency = 1, Text = "DUNGDX PVP",
    Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header,
})
mk("TextLabel", {
    Size = UDim2.new(1, -60, 0, 14), Position = UDim2.new(0, 18, 0, 30),
    BackgroundTransparency = 1, Text = "Blox Fruit • PvP Tool",
    Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header,
})
local CloseBtn = mk("TextButton", {
    Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0, 11),
    BackgroundColor3 = T.Red, Text = "×",
    Font = Enum.Font.GothamBold, TextSize = 18,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, Parent = Header,
})
corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Tab bar (ScrollingFrame cuộn ngang — không lòi ra ngoài)
local TabBar = mk("ScrollingFrame", {
    Size = UDim2.new(1, -24, 0, 34),
    Position = UDim2.new(0, 12, 0, 62),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.X,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Parent = Main,
})
local tabLay = mk("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 5), Parent = TabBar,
})
tabLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabBar.CanvasSize = UDim2.new(0, tabLay.AbsoluteContentSize.X + 8, 0, 0)
end)

local Content = mk("Frame", {
    Size = UDim2.new(1, -24, 1, -112),
    Position = UDim2.new(0, 12, 0, 104),
    BackgroundTransparency = 1, Parent = Main,
})

-- ============ FAB DX ============
local FAB = mk("TextButton", {
    Size = UDim2.new(0, 54, 0, 54),
    Position = UDim2.new(0, 20, 0.5, -27),
    BackgroundColor3 = Color3.fromRGB(20, 15, 20),
    BackgroundTransparency = 0.25,
    Text = "DX", Font = Enum.Font.GothamBlack, TextSize = 18,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
    Draggable = true, Parent = ScreenGui,
})
corner(FAB, 999)
stroke(FAB, T.OrangeNeon, 2)
stroke(FAB, T.OrangeNeon, 8, 0.75)
FAB.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ============ FAB MACRO ============
local MacroFAB = mk("TextButton", {
    Size = UDim2.new(0, 54, 0, 54),
    Position = UDim2.new(0, 20, 0.5, 35),
    BackgroundColor3 = Color3.fromRGB(15, 20, 15),
    BackgroundTransparency = 0.25,
    Text = "MC", Font = Enum.Font.GothamBlack, TextSize = 16,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
    Draggable = true, Parent = ScreenGui,
})
corner(MacroFAB, 999)
stroke(MacroFAB, T.Green, 2)
stroke(MacroFAB, T.Green, 8, 0.75)
MacroFAB.MouseButton1Click:Connect(function()
    if macroRunning then
        macroRunning = false
        notify("Macro", "Đã DỪNG", 2)
    else
        runMacro()
        notify("Macro", "Đang chạy: " .. ActiveMacro, 2)
    end
end)

-- ============ NÚT SORU ============
local SoruBtn = mk("TextButton", {
    Size = UDim2.new(0, 62, 0, 62),
    Position = UDim2.new(1, -82, 0.5, 60),
    BackgroundColor3 = Color3.fromRGB(20, 10, 15),
    BackgroundTransparency = 0.15,
    Text = "SORU", Font = Enum.Font.GothamBlack, TextSize = 12,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
    Draggable = true, Visible = false, Parent = ScreenGui,
})
corner(SoruBtn, 999)
stroke(SoruBtn, T.Neon, 2)
stroke(SoruBtn, T.NeonGlow, 8, 0.75)
SoruBtn.MouseButton1Click:Connect(function()
    if C.SoruOn then doSoru() end
end)

-- ============ Nút Fly lên/xuống ============
local flyUp, flyDown = false, false
local FlyUpBtn = mk("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(1, -70, 1, -260),
    BackgroundColor3 = Color3.fromRGB(20, 10, 15),
    BackgroundTransparency = 0.3, Text = "▲",
    Font = Enum.Font.GothamBlack, TextSize = 20,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
    Visible = false, Parent = ScreenGui,
})
corner(FlyUpBtn, 999); stroke(FlyUpBtn, T.Neon, 1.5)
local FlyDownBtn = mk("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(1, -70, 1, -200),
    BackgroundColor3 = Color3.fromRGB(20, 10, 15),
    BackgroundTransparency = 0.3, Text = "▼",
    Font = Enum.Font.GothamBlack, TextSize = 20,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
    Visible = false, Parent = ScreenGui,
})
corner(FlyDownBtn, 999); stroke(FlyDownBtn, T.Neon, 1.5)
FlyUpBtn.MouseButton1Down:Connect(function() flyUp = true end)
FlyUpBtn.MouseButton1Up:Connect(function() flyUp = false end)
FlyUpBtn.MouseLeave:Connect(function() flyUp = false end)
FlyDownBtn.MouseButton1Down:Connect(function() flyDown = true end)
FlyDownBtn.MouseButton1Up:Connect(function() flyDown = false end)
FlyDownBtn.MouseLeave:Connect(function() flyDown = false end)

-- ============ TABS ============
local Tabs = {}
local function makeTab(name)
    local holder = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, Visible = false, Parent = Content,
    })
    local sc = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = T.Neon,
        CanvasSize = UDim2.new(0, 0, 0, 2000),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = holder,
    })
    local lay = mk("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder, Parent = sc,
    })
    mk("UIPadding", {
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 8), Parent = sc,
    })
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sc.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 20)
    end)

    local btn = mk("TextButton", {
        Size = UDim2.new(0, 112, 1, 0),
        BackgroundColor3 = T.Row, Text = name,
        Font = Enum.Font.GothamSemibold, TextSize = 11,
        TextColor3 = T.Dim, AutoButtonColor = false, Parent = TabBar,
    })
    corner(btn, 8)
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.f.Visible = false
            t.b.BackgroundColor3 = T.Row
            t.b.TextColor3 = T.Dim
            for _, s in ipairs(t.b:GetChildren()) do
                if s:IsA("UIStroke") then s:Destroy() end
            end
        end
        holder.Visible = true
        btn.BackgroundColor3 = T.Card
        btn.TextColor3 = T.Text
        stroke(btn, T.Neon, 1.5)
    end)
    Tabs[name] = {f = holder, sc = sc, b = btn}
    return sc
end

local TCombat = makeTab("⚔ Chiến Đấu")
local TMacro  = makeTab("🎬 Macro")
local TVisual = makeTab("👁 Hiển Thị")
local TMove   = makeTab("🚀 Di Chuyển")
local TMisc   = makeTab("⚙ Khác")
local TInfo   = makeTab("ℹ Thông Tin")

Tabs["⚔ Chiến Đấu"].f.Visible = true
Tabs["⚔ Chiến Đấu"].b.BackgroundColor3 = T.Card
Tabs["⚔ Chiến Đấu"].b.TextColor3 = T.Text
stroke(Tabs["⚔ Chiến Đấu"].b, T.Neon, 1.5)

-- ============ COMPONENTS ============
local ORD = 0
local function nx() ORD = ORD + 1; return ORD end

local function addSection(parent, text)
    return mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Neon, TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = nx(), Parent = parent,
    })
end

local function addToggle(parent, text, default, cb)
    local row = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = T.Row,
        BorderSizePixel = 0, LayoutOrder = nx(), Parent = parent,
    })
    corner(row, 8)
    mk("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
    local pill = mk("TextButton", {
        Size = UDim2.new(0, 46, 0, 22), Position = UDim2.new(1, -58, 0, 7),
        BackgroundColor3 = default and T.Neon or Color3.fromRGB(60, 50, 55),
        Text = "", AutoButtonColor = false, Parent = row,
    })
    corner(pill, 999)
    local knob = mk("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.new(1, 1, 1), Parent = pill,
    })
    corner(knob, 999)
    local st = default
    local function paint()
        if st then
            pill.BackgroundColor3 = T.Neon
            TweenSvc:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -20, 0, 2)}):Play()
        else
            pill.BackgroundColor3 = Color3.fromRGB(60, 50, 55)
            TweenSvc:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0, 2)}):Play()
        end
    end
    pill.MouseButton1Click:Connect(function()
        st = not st; paint()
        if cb then pcall(cb, st) end
        saveCfg()
    end)
    return {Set = function(_, v) st = v; paint() end, Get = function() return st end}
end

local function addNum(parent, text, default, min, max, cb)
    local row = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = T.Row,
        BorderSizePixel = 0, LayoutOrder = nx(), Parent = parent,
    })
    corner(row, 8)
    mk("TextLabel", {
        Size = UDim2.new(0.55, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
    local tb = mk("TextBox", {
        Size = UDim2.new(0.45, -14, 1, -10),
        Position = UDim2.new(0.55, 0, 0, 5),
        BackgroundColor3 = T.Card, Text = tostring(default),
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false, Parent = row,
    })
    corner(tb, 6); stroke(tb, T.Neon, 1)
    tb.FocusLost:Connect(function()
        local n = tonumber(tb.Text)
        if n then
            n = math.clamp(math.floor(n), min, max)
            tb.Text = tostring(n)
            if cb then pcall(cb, n) end
            saveCfg()
        else tb.Text = tostring(default) end
    end)
    return {Get = function() return tonumber(tb.Text) or default end}
end

local function addDrop(parent, text, default, options, cb)
    local row = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = T.Row,
        BorderSizePixel = 0, LayoutOrder = nx(), Parent = parent,
    })
    corner(row, 8)
    mk("TextLabel", {
        Size = UDim2.new(0.45, -14, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
    local btn = mk("TextButton", {
        Size = UDim2.new(0.55, -14, 1, -10),
        Position = UDim2.new(0.45, 0, 0, 5),
        BackgroundColor3 = T.Card, Text = tostring(default),
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, AutoButtonColor = false,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
    corner(btn, 6); stroke(btn, T.Neon, 1)
    local cur, idx = default, 1
    for i, v in ipairs(options) do if v == default then idx = i; break end end
    btn.MouseButton1Click:Connect(function()
        if #options == 0 then return end
        idx = idx % #options + 1
        cur = options[idx]
        btn.Text = tostring(cur)
        if cb then pcall(cb, cur) end
        saveCfg()
    end)
    return {
        Get = function() return cur end,
        SetOpts = function(_, newOpts, newVal)
            options = newOpts
            if newVal then cur = newVal; btn.Text = tostring(newVal) end
            for i, o in ipairs(options) do if o == cur then idx = i; break end end
        end,
    }
end

local function addBtn(parent, text, color, cb)
    local b = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = color or T.Card, Text = text,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = T.Text, AutoButtonColor = false,
        LayoutOrder = nx(), Parent = parent,
    })
    corner(b, 8); stroke(b, color or T.Neon, 1.5)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return b
end

local function addLabel(parent, text, desc)
    local l = mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, desc and 34 or 20),
        BackgroundTransparency = 1, Text = desc and (text .. "\n" .. desc) or text,
        Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = desc and T.Dim or T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, LayoutOrder = nx(), Parent = parent,
    })
    return l
end

-- ============ TAB: CHIẾN ĐẤU ============
addSection(TCombat, "🎯 AIMBOT")
addToggle(TCombat, "Bật Aimbot", C.AimOn, function(v) C.AimOn = v end)
addDrop(TCombat, "Chế độ aim", C.AimMode,
    {"NPC gần nhất", "Player gần nhất", "Player trong vòng FOV"},
    function(v) C.AimMode = v end)
addToggle(TCombat, "Silent Aim (ẩn, không xoay cam)", C.AimSilent, function(v)
    C.AimSilent = v
    if v and not HAS_HOOK then
        notify("Silent Aim", "Executor không hỗ trợ hook!", 4)
        C.AimSilent = false
    end
end)
addToggle(TCombat, "Kiểm tra đồng đội", C.AimTeam, function(v) C.AimTeam = v end)
addNum(TCombat, "Độ mượt (0-100)", math.floor(C.AimSmooth * 100), 0, 100,
    function(v) C.AimSmooth = v / 100 end)
addNum(TCombat, "Vùng FOV (px)", C.AimFOV, 50, 800, function(v) C.AimFOV = v end)
addDrop(TCombat, "Bộ phận ngắm", C.AimPart,
    {"Head", "UpperTorso", "HumanoidRootPart"}, function(v) C.AimPart = v end)

addSection(TCombat, "⚡ AUTO SORU")
addToggle(TCombat, "Bật Auto Soru", C.SoruOn, function(v)
    C.SoruOn = v
    SoruBtn.Visible = v
end)
addDrop(TCombat, "Mục tiêu Soru", C.SoruTarget,
    {"Player gần nhất", "NPC gần nhất", "Cả hai"},
    function(v) C.SoruTarget = v end)
addNum(TCombat, "Phạm vi Soru", C.SoruRange, 10, 500, function(v) C.SoruRange = v end)
addDrop(TCombat, "Phím Soru", C.SoruKey, {"R", "Z", "X", "C", "V", "F"}, function(v) C.SoruKey = v end)

-- ============ TAB: MACRO ============
macroRefresh = nil
do
    addSection(TMacro, "⚙ CẤU HÌNH")
    local names = {}
    for n in pairs(Macros) do table.insert(names, n) end
    table.sort(names)
    local combo = addDrop(TMacro, "Macro đang dùng", ActiveMacro, names, function(v)
        ActiveMacro = v
        if macroRefresh then macroRefresh() end
    end)
    addNum(TMacro, "Tầm chạy Macro", C.MacroRange, 10, 60, function(v) C.MacroRange = v end)
    addToggle(TMacro, "Tự chạy khi gần địch", C.MacroAuto, function(v) C.MacroAuto = v end)

    addSection(TMacro, "🎬 ĐIỀU KHIỂN")
    addBtn(TMacro, "▶  CHẠY MACRO NGAY", T.Green, function() runMacro() end)
    addBtn(TMacro, "🛑  DỪNG MACRO", T.Red, function()
        macroRunning = false
        notify("Macro", "Đã dừng", 2)
    end)
    addBtn(TMacro, "💾  LƯU CÀI ĐẶT", T.Card, function()
        saveCfg()
        notify("Save", "Đã lưu!", 3)
    end)

    addSection(TMacro, "📋 QUẢN LÝ")
    local btnRow = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1,
        LayoutOrder = nx(), Parent = TMacro,
    })
    mk("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = btnRow})
    local mkBtn = mk("TextButton", {
        Size = UDim2.new(0.5, -3, 1, 0), BackgroundColor3 = T.Card,
        Text = "+ Tạo Macro", Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Text, AutoButtonColor = false, Parent = btnRow,
    }); corner(mkBtn, 8); stroke(mkBtn, T.Green, 1.5)
    local delBtn = mk("TextButton", {
        Size = UDim2.new(0.5, -3, 1, 0), BackgroundColor3 = T.Card,
        Text = "🗑 Xóa Macro", Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Text, AutoButtonColor = false, Parent = btnRow,
    }); corner(delBtn, 8); stroke(delBtn, T.Red, 1.5)

    local newRow = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1,
        LayoutOrder = nx(), Parent = TMacro,
    })
    local newInner = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = T.Row,
        BorderSizePixel = 0, Visible = false, Parent = newRow,
    })
    corner(newInner, 8); stroke(newInner, T.Neon, 1)
    local tb = mk("TextBox", {
        Size = UDim2.new(1, -84, 1, -10), Position = UDim2.new(0, 6, 0, 5),
        BackgroundColor3 = T.Card, PlaceholderText = "Tên macro mới...",
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, Text = "", ClearTextOnFocus = false, Parent = newInner,
    }); corner(tb, 6)
    local okB = mk("TextButton", {
        Size = UDim2.new(0, 70, 1, -10), Position = UDim2.new(1, -76, 0, 5),
        BackgroundColor3 = T.Green, Text = "Tạo",
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, Parent = newInner,
    }); corner(okB, 6)

    mkBtn.MouseButton1Click:Connect(function() newInner.Visible = not newInner.Visible end)
    okB.MouseButton1Click:Connect(function()
        local name = tb.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if name ~= "" and not Macros[name] then
            Macros[name] = {}
            ActiveMacro = name
            local nn = {}
            for n in pairs(Macros) do table.insert(nn, n) end
            table.sort(nn)
            combo:SetOpts(nn, name)
            tb.Text = ""; newInner.Visible = false
            if macroRefresh then macroRefresh() end
            saveCfg()
            notify("Macro", "Đã tạo: " .. name, 3)
        else
            notify("Macro", "Tên trống hoặc đã tồn tại!", 3)
        end
    end)
    delBtn.MouseButton1Click:Connect(function()
        local cnt = 0
        for _ in pairs(Macros) do cnt = cnt + 1 end
        if ActiveMacro and Macros[ActiveMacro] and cnt > 1 then
            Macros[ActiveMacro] = nil
            local first = nil
            for n in pairs(Macros) do first = n; break end
            ActiveMacro = first
            local nn = {}
            for n in pairs(Macros) do table.insert(nn, n) end
            table.sort(nn)
            combo:SetOpts(nn, ActiveMacro)
            if macroRefresh then macroRefresh() end
            saveCfg()
            notify("Macro", "Đã xóa", 3)
        else
            notify("Macro", "Không thể xóa macro cuối!", 3)
        end
    end)

    addSection(TMacro, "🎬 CÁC BƯỚC")
    addBtn(TMacro, "+  THÊM BƯỚC MỚI", T.Green, function() showStepPopup() end)

    local stepHolder = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
        LayoutOrder = nx(), Parent = TMacro,
    })
    local stepLay = mk("UIListLayout", {
        Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = stepHolder,
    })
    stepLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        stepHolder.Size = UDim2.new(1, 0, 0, math.max(40, stepLay.AbsoluteContentSize.Y))
    end)

    macroRefresh = function()
        for _, c in ipairs(stepHolder:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
        end
        local steps = Macros[ActiveMacro] or {}
        for i, step in ipairs(steps) do
            local row = mk("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = T.Row, BorderSizePixel = 0, Parent = stepHolder,
            })
            corner(row, 6); stroke(row, T.Neon, 0.8, 0.5)

            mk("TextLabel", {
                Size = UDim2.new(0, 26, 1, 0), Position = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1, Text = "# " .. i,
                Font = Enum.Font.GothamBold, TextSize = 10,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local tt = "?"
            if step.t == "skill" then tt = "Skill " .. step.v
            elseif step.t == "weapon" then tt = "Trang bị " .. step.v
            elseif step.t == "m1" then tt = "M1 Click"
            elseif step.t == "dash" then tt = "Dash"
            elseif step.t == "wait" then tt = "Chờ " .. step.v .. "s" end

            mk("TextLabel", {
                Size = UDim2.new(1, -160, 1, 0), Position = UDim2.new(0, 34, 0, 0),
                BackgroundTransparency = 1, Text = tt,
                Font = Enum.Font.Gotham, TextSize = 11,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
            })

            -- TextBox delay (nhập số)
            local dTB = mk("TextBox", {
                Size = UDim2.new(0, 50, 1, -12),
                Position = UDim2.new(1, -94, 0, 6),
                BackgroundColor3 = T.Card,
                Text = string.format("%.2f", step.d or 0.08),
                Font = Enum.Font.GothamBold, TextSize = 10,
                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Center,
                ClearTextOnFocus = false, Parent = row,
            })
            corner(dTB, 4); stroke(dTB, T.Neon, 0.8)
            dTB.FocusLost:Connect(function()
                local n = tonumber(dTB.Text)
                if n then
                    n = math.clamp(n, 0.01, 5)
                    n = math.floor(n * 100 + 0.5) / 100
                    step.d = n
                    dTB.Text = string.format("%.2f", n)
                    saveCfg()
                else
                    dTB.Text = string.format("%.2f", step.d or 0.08)
                end
            end)

            -- Nút xóa
            local xb = mk("TextButton", {
                Size = UDim2.new(0, 24, 1, -12),
                Position = UDim2.new(1, -38, 0, 6),
                BackgroundColor3 = T.Card, Text = "×",
                Font = Enum.Font.GothamBold, TextSize = 14,
                TextColor3 = T.Red, AutoButtonColor = false, Parent = row,
            })
            corner(xb, 4)
            xb.MouseButton1Click:Connect(function()
                table.remove(steps, i)
                macroRefresh()
                saveCfg()
            end)
        end
        if #steps == 0 then
            mk("TextLabel", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1, Text = "(Chưa có bước nào)",
                Font = Enum.Font.Gotham, TextSize = 11,
                TextColor3 = T.Dim, Parent = stepHolder,
            })
        end
    end
    macroRefresh()
end

-- ============ POPUP THÊM BƯỚC ============
function showStepPopup()
    local old = ScreenGui:FindFirstChild("StepPopup")
    if old then old:Destroy() end

    local pop = mk("Frame", {
        Name = "StepPopup", Size = UDim2.new(0, 300, 0, 380),
        Position = UDim2.new(0.5, -150, 0.5, -190),
        BackgroundColor3 = T.Card, BorderSizePixel = 0,
        Active = true, Draggable = true, ZIndex = 100, Parent = ScreenGui,
    })
    corner(pop, 12)
    stroke(pop, T.Neon, 2); stroke(pop, T.NeonGlow, 8, 0.75)

    mk("TextLabel", {
        Size = UDim2.new(1, -60, 0, 30), Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1, Text = "Chọn Bước Macro",
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102, Parent = pop,
    })
    local closeB = mk("TextButton", {
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -34, 0, 6),
        BackgroundColor3 = T.Red, Text = "×",
        Font = Enum.Font.GothamBold, TextSize = 16,
        TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
        ZIndex = 102, Parent = pop,
    }); corner(closeB, 6)
    closeB.MouseButton1Click:Connect(function() pop:Destroy() end)

    local sc = mk("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -48),
        Position = UDim2.new(0, 8, 0, 40),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = T.Neon,
        CanvasSize = UDim2.new(0, 0, 0, 700),
        ZIndex = 101, Parent = pop,
    })
    mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sc})

    local function hdr(txt)
        mk("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1, Text = txt,
            Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = T.Neon, TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 102, Parent = sc,
        })
    end
    local function opt(label, data)
        local b = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = T.Row, Text = label,
            Font = Enum.Font.Gotham, TextSize = 11,
            TextColor3 = T.Text, AutoButtonColor = false,
            ZIndex = 102, Parent = sc,
        })
        corner(b, 6)
        b.MouseButton1Click:Connect(function()
            if ActiveMacro and Macros[ActiveMacro] then
                local s = {}
                for k, v in pairs(data) do s[k] = v end
                s.d = s.d or 0.08
                table.insert(Macros[ActiveMacro], s)
                if macroRefresh then macroRefresh() end
                saveCfg()
                pop:Destroy()
                notify("Macro", "Đã thêm: " .. label, 2)
            end
        end)
    end

    hdr("— VŨ KHÍ —")
    opt("Trang bị Võ (Melee)",   {t = "weapon", v = "Melee"})
    opt("Trang bị Kiếm (Sword)", {t = "weapon", v = "Sword"})
    opt("Trang bị Súng (Gun)",   {t = "weapon", v = "Gun"})
    opt("Trang bị Trái (Blox Fruit)", {t = "weapon", v = "Blox Fruit"})
    hdr("— SKILL —")
    opt("Skill Z", {t = "skill", v = "Z"})
    opt("Skill X", {t = "skill", v = "X"})
    opt("Skill C", {t = "skill", v = "C"})
    opt("Skill V", {t = "skill", v = "V"})
    opt("Skill F", {t = "skill", v = "F"})
    hdr("— KHÁC —")
    opt("M1 (Click chuột)", {t = "m1", v = 1})
    opt("Dash (W+W)", {t = "dash", v = "W"})
    opt("Chờ 0.1s", {t = "wait", v = 0.1})
    opt("Chờ 0.3s", {t = "wait", v = 0.3})
    opt("Chờ 0.5s", {t = "wait", v = 0.5})
end

-- ============ TAB: HIỂN THỊ ============
addSection(TVisual, "👁 ESP")
addToggle(TVisual, "Bật ESP (hiện tất cả player)", C.ESPOn, function(v)
    C.ESPOn = v
    refreshESP()
end)
addToggle(TVisual, "Kiểm tra đồng đội", C.ESPTeam, function(v) C.ESPTeam = v end)
addNum(TVisual, "Khoảng cách ESP", C.ESPMaxDist, 500, 100000, function(v)
    C.ESPMaxDist = v
    for _, b in pairs(espCache) do
        pcall(function() b.MaxDistance = v end)
    end
end)

addSection(TVisual, "📦 HITBOX (khung quanh nhân vật)")
addToggle(TVisual, "Hitbox Người Chơi (đỏ)", C.HB_Player, function(v)
    C.HB_Player = v
    refreshHB()
end)
addToggle(TVisual, "Hitbox Quái (cam)", C.HB_NPC, function(v)
    C.HB_NPC = v
    refreshHB()
end)

addSection(TVisual, "🌗 ÁNH SÁNG")
addToggle(TVisual, "Full Bright (sáng ban đêm)", C.Bright, function(v)
    C.Bright = v
    applyBright(v)
end)

-- ============ TAB: DI CHUYỂN ============
addSection(TMove, "🚀 BAY")
addToggle(TMove, "Fly (hiện nút ▲▼)", C.Fly, function(v)
    C.Fly = v
    applyFly(v)
    FlyUpBtn.Visible = v
    FlyDownBtn.Visible = v
end)
addNum(TMove, "Tốc độ Fly", C.FlySpeed, 20, 300, function(v) C.FlySpeed = v end)

addSection(TMove, "🏃 TỐC ĐỘ")
addNum(TMove, "WalkSpeed", C.Speed, 16, 500, function(v) C.Speed = v end)
addNum(TMove, "JumpPower", C.Jump, 50, 800, function(v) C.Jump = v end)
addBtn(TMove, "🔄 Reset tốc độ", T.Card, function()
    C.Speed = 16; C.Jump = 50
    saveCfg()
    notify("Reset", "Đã reset tốc độ", 3)
end)

addSection(TMove, "🌊 XUYÊN / NƯỚC")
addToggle(TMove, "Đi Trên Mặt Nước", C.Water, function(v)
    C.Water = v
    applyWater(v)
end)
addToggle(TMove, "No Clip (xuyên vật thể)", C.NoClip, function(v)
    C.NoClip = v
    applyNoClip(v)
end)

-- ============ TAB: KHÁC ============
addSection(TMisc, "⚡ HIỆU NĂNG")
addToggle(TMisc, "Fix Lag (giảm hiệu ứng chiêu)", C.FixLag, function(v)
    C.FixLag = v
    applyFixLag(v)
end)
addToggle(TMisc, "Xóa Sương Mù", C.NoFog, function(v)
    C.NoFog = v
    applyNoFog(v)
end)
addBtn(TMisc, "🔄 Khôi phục ánh sáng gốc", T.Card, function()
    restoreLighting()
    notify("Lighting", "Đã khôi phục", 3)
end)

addSection(TMisc, "🎮 HUD")
addToggle(TMisc, "Hiện HUD", C.ShowHUD, function(v) C.ShowHUD = v end)

addSection(TMisc, "💾 LƯU CẤU HÌNH")
addBtn(TMisc, "💾 LƯU NGAY", T.Card, function()
    saveCfg()
    notify("Save", "Đã lưu!", 3)
end)
addBtn(TMisc, "📂 LOAD LẠI", T.Card, function()
    if loadCfg() then
        notify("Load", "Đã tải. Restart script để áp dụng.", 4)
    else
        notify("Load", "Không có file save", 3)
    end
end)
addBtn(TMisc, "🗑 XÓA FILE SAVE", T.Red, function()
    if HAS_FILE and type(delfile) == "function" then
        pcall(delfile, SAVE_FILE)
        notify("Save", "Đã xóa file save", 3)
    end
end)

addSection(TMisc, "🌐 SERVER")
addBtn(TMisc, "Rejoin Server", T.Card, function()
    pcall(function() TeleportSvc:Teleport(game.PlaceId, LP) end)
end)
addBtn(TMisc, "Server Hop", T.Card, function()
    task.spawn(function()
        pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
            local res = HttpSvc:JSONDecode(game:HttpGet(url))
            if res and res.data then
                for _, s in ipairs(res.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        TeleportSvc:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                        return
                    end
                end
            end
        end)
    end)
end)

addSection(TMisc, "🛑 KHẨN CẤP")
addBtn(TMisc, "⛔ TẮT TẤT CẢ", T.Red, function()
    C.AimOn = false; C.AimSilent = false; C.MacroAuto = false
    C.ESPOn = false; C.FixLag = false; C.NoFog = false
    C.Water = false; C.NoClip = false; C.Fly = false; C.Bright = false
    C.HB_Player = false; C.HB_NPC = false; C.SoruOn = false
    applyFixLag(false); applyNoFog(false); applyNoClip(false); applyFly(false)
    applyWater(false); applyBright(false)
    clearESP(); refreshHB()
    SoruBtn.Visible = false
    FlyUpBtn.Visible = false; FlyDownBtn.Visible = false
    saveCfg()
    notify("DUNGDX PVP", "Đã tắt toàn bộ", 3)
end)

-- ============ TAB: THÔNG TIN ============
addSection(TInfo, "👑 CHỦ SỞ HỮU")
mk("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1, Text = "DUNGDX",
    Font = Enum.Font.GothamBlack, TextSize = 24,
    TextColor3 = T.Neon,
    TextXAlignment = Enum.TextXAlignment.Center,
    LayoutOrder = nx(), Parent = TInfo,
})
mk("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1, Text = "Blox Fruit PvP Tool",
    Font = Enum.Font.Gotham, TextSize = 11,
    TextColor3 = T.Dim,
    TextXAlignment = Enum.TextXAlignment.Center,
    LayoutOrder = nx(), Parent = TInfo,
})

addSection(TInfo, "💬 DISCORD")
mk("TextButton", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
    Text = "discord.gg/jbCzvtmSZ",
    Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false,
    LayoutOrder = nx(), Parent = TInfo,
}).Parent = TInfo

addSection(TInfo, "📌 THÔNG TIN SCRIPT")
addLabel(TInfo, "• Tên script: DUNGDX PVP")
addLabel(TInfo, "• Chức năng: Aimbot, Macro, ESP, Hitbox, Di chuyển")
addLabel(TInfo, "• Save config tự động mỗi 20s")
addLabel(TInfo, "• Có Silent Aim (nếu executor hỗ trợ hook)")
addLabel(TInfo, "• Bỏ qua Safe Zone, có Team check")

addSection(TInfo, "🔧 TRẠNG THÁI EXECUTOR")
mk("TextLabel", {
    Size = UDim2.new(1, 0, 0, 80),
    BackgroundTransparency = 1,
    Text = string.format(
        "Hook (Silent Aim): %s\nFile (Save/Load): %s\nGethui: %s",
        HAS_HOOK and "✓ Có" or "✗ Không",
        HAS_FILE and "✓ Có" or "✗ Không",
        HAS_GETHUI and "✓ Có" or "✗ Không"
    ),
    Font = Enum.Font.Code, TextSize = 11,
    TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    LayoutOrder = nx(), Parent = TInfo,
})

-- ============ ESP SYSTEM ============
espCache = {}
espThreads = {}

function clearESP()
    for k, v in pairs(espCache) do
        pcall(function() v:Destroy() end)
    end
    espCache = {}
    for _, th in ipairs(espThreads) do
        pcall(function() task.cancel(th) end)
    end
    espThreads = {}
end

local function createESP(plr)
    if plr == LP then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if espCache[plr] then return end

    local bb = mk("BillboardGui", {
        Name = "DungdxESP", Adornee = head,
        Size = UDim2.new(0, 130, 0, 28),
        StudsOffset = Vector3.new(0, 2.5, 0),
        AlwaysOnTop = true, LightInfluence = 0,
        MaxDistance = 100000, ClipsDescendants = false,
        Parent = head,
    })
    local nL = mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 10,
        TextColor3 = T.Neon,
        TextStrokeTransparency = 0.3, TextStrokeColor3 = Color3.new(0, 0, 0),
        Text = "", Parent = bb,
    })
    local dL = mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, TextSize = 8,
        TextColor3 = Color3.fromRGB(255, 200, 200),
        TextStrokeTransparency = 0.3, TextStrokeColor3 = Color3.new(0, 0, 0),
        Text = "", Parent = bb,
    })
    local hBg = mk("Frame", {
        Size = UDim2.new(0.65, 0, 0, 3), Position = UDim2.new(0.175, 0, 0, 23),
        BackgroundColor3 = Color3.fromRGB(30, 20, 25),
        BorderSizePixel = 0, Parent = bb,
    }); corner(hBg, 999)
    local hFill = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(80, 220, 120),
        BorderSizePixel = 0, Parent = hBg,
    }); corner(hFill, 999)

    espCache[plr] = bb
    local th = task.spawn(function()
        while bb.Parent and plr.Parent and C.ESPOn do
            pcall(function()
                local ally = isAlly(plr) and C.ESPTeam
                bb.Enabled = not ally
                if ally then return end
                local c = plr.Character
                local h = getHum(c)
                local myRoot = getRoot(LP.Character)
                local hRoot = getRoot(c)
                if h and myRoot and hRoot then
                    nL.Text = plr.Name
                    dL.Text = "[" .. math.floor((myRoot.Position - hRoot.Position).Magnitude) .. "]"
                    hFill.Size = UDim2.new(math.clamp(h.Health / h.MaxHealth, 0, 1), 0, 1, 0)
                end
            end)
            task.wait(0.15)
        end
        if espCache[plr] == bb then espCache[plr] = nil end
    end)
    table.insert(espThreads, th)
end

function refreshESP()
    clearESP()
    if not C.ESPOn then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then createESP(plr) end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if C.ESPOn and plr ~= LP then task.wait(1); createESP(plr) end
end)
Players.PlayerRemoving:Connect(function(plr)
    if espCache[plr] then
        pcall(function() espCache[plr]:Destroy() end)
        espCache[plr] = nil
    end
end)

-- ============ HITBOX (SelectionBox quanh toàn thân) ============
hbCache = {}
local HB_P = Color3.fromRGB(255, 50, 50)
local HB_N = Color3.fromRGB(255, 150, 50)

function refreshHB()
    for k, b in pairs(hbCache) do
        pcall(function() b:Destroy() end)
    end
    hbCache = {}
    if C.HB_Player then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local sb = Instance.new("SelectionBox")
                sb.Adornee = plr.Character
                sb.LineThickness = 0.15
                sb.Color3 = HB_P
                sb.SurfaceTransparency = 1
                sb.Parent = plr.Character
                hbCache[plr.Character] = sb
            end
        end
    end
    if C.HB_NPC then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in ipairs(enemies:GetChildren()) do
                local h = mob:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    local sb = Instance.new("SelectionBox")
                    sb.Adornee = mob
                    sb.LineThickness = 0.15
                    sb.Color3 = HB_N
                    sb.SurfaceTransparency = 1
                    sb.Parent = mob
                    hbCache[mob] = sb
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if C.HB_Player and not hbCache[char] then
            local sb = Instance.new("SelectionBox")
            sb.Adornee = char; sb.LineThickness = 0.15
            sb.Color3 = HB_P; sb.SurfaceTransparency = 1
            sb.Parent = char; hbCache[char] = sb
        end
    end)
end)

-- NPC auto spawn hitbox
task.spawn(function()
    while task.wait(0.5) do
        if C.HB_NPC then
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, mob in ipairs(enemies:GetChildren()) do
                    if not hbCache[mob] then
                        local h = mob:FindFirstChildOfClass("Humanoid")
                        if h and h.Health > 0 then
                            local sb = Instance.new("SelectionBox")
                            sb.Adornee = mob; sb.LineThickness = 0.15
                            sb.Color3 = HB_N; sb.SurfaceTransparency = 1
                            sb.Parent = mob; hbCache[mob] = sb
                        end
                    end
                end
            end
        end
    end
end)

-- ============ AIMBOT ============
local currentTarget = nil

local function getNearestNPC()
    local c = getCam()
    local myRoot = getRoot(LP.Character)
    if not c or not myRoot then return nil end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local closest, closestD = nil, C.AimFOV
    for _, mob in ipairs(enemies:GetChildren()) do
        local h = mob:FindFirstChildOfClass("Humanoid")
        local r = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if h and h.Health > 0 and r then
            local sp, on = c:WorldToViewportPoint(r.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - c.ViewportSize / 2).Magnitude
                if d < closestD then
                    closestD = d
                    closest = {part = r, obj = mob}
                end
            end
        end
    end
    return closest
end

local function getNearestPlayer()
    local c = getCam()
    local myRoot = getRoot(LP.Character)
    if not c or not myRoot then return nil end
    local closest, closestD = nil, C.AimFOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlive(plr) and not isAlly(plr) and not inSafeZone(plr) then
            local ch = plr.Character
            local part = ch:FindFirstChild(C.AimPart) or ch:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, on = c:WorldToViewportPoint(part.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - c.ViewportSize / 2).Magnitude
                    if d < closestD then
                        closestD = d
                        closest = {part = part, obj = plr}
                    end
                end
            end
        end
    end
    return closest
end

local function getPlayerInFOV()
    return getNearestPlayer()  -- cùng logic
end

local function getTarget()
    if C.AimMode == "NPC gần nhất" then return getNearestNPC()
    elseif C.AimMode == "Player gần nhất" then return getNearestPlayer()
    elseif C.AimMode == "Player trong vòng FOV" then return getPlayerInFOV() end
    return nil
end

-- Cache target để không đổi liên tục
local aimCache = nil
local aimCacheTime = 0

local function getCachedTarget()
    local now = tick()
    if aimCache and now - aimCacheTime < 0.5 then
        if aimCache.part and aimCache.part.Parent then
            local hum = aimCache.obj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return aimCache
            end
        end
    end
    aimCache = getTarget()
    aimCacheTime = now
    return aimCache
end

-- Camera aim
RunService.RenderStepped:Connect(function()
    if not C.AimOn then return end
    if C.AimSilent then return end
    local c = getCam()
    if not c then return end
    local t = getCachedTarget()
    if t and t.part and t.part.Parent then
        local goal = CFrame.new(c.CFrame.Position, t.part.Position)
        if C.AimSmooth > 0 then
            c.CFrame = c.CFrame:Lerp(goal, 1 - C.AimSmooth)
        else
            c.CFrame = goal
        end
    end
end)

-- Silent Aim (hook namecall)
if HAS_HOOK then
    pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()

            if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
                if C.AimOn and C.AimSilent then
                    local t = getCachedTarget()
                    if t and t.part and t.part.Parent then
                        for i = 1, math.min(6, #args) do
                            if typeof(args[i]) == "Vector3" then
                                args[i] = t.part.Position
                                return oldNamecall(self, unpack(args))
                            end
                            if typeof(args[i]) == "CFrame" then
                                args[i] = CFrame.new(args[i].Position, t.part.Position)
                                return oldNamecall(self, unpack(args))
                            end
                        end
                    end
                end
            end

            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
        print("[DUNGDX] Silent Aim hook OK")
    end)
end

-- ============ AUTO SORU ============
function doSoru()
    local myRoot = getRoot(LP.Character)
    if not myRoot then return end
    local target, minD = nil, C.SoruRange

    if C.SoruTarget == "Player gần nhất" or C.SoruTarget == "Cả hai" then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and isAlive(plr) and not isAlly(plr) and not inSafeZone(plr) then
                local r = getRoot(plr.Character)
                if r then
                    local d = (myRoot.Position - r.Position).Magnitude
                    if d < minD then minD = d; target = r end
                end
            end
        end
    end
    if C.SoruTarget == "NPC gần nhất" or C.SoruTarget == "Cả hai" then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in ipairs(enemies:GetChildren()) do
                local h = mob:FindFirstChildOfClass("Humanoid")
                local r = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                if h and h.Health > 0 and r then
                    local d = (myRoot.Position - r.Position).Magnitude
                    if d < minD then minD = d; target = r end
                end
            end
        end
    end
    if not target then
        notify("Soru", "Không có địch trong tầm", 2)
        return
    end
    local c = getCam()
    if c then
        c.CFrame = CFrame.new(c.CFrame.Position, target.Position)
    end
    task.wait(0.08)
    if VIM then
        local k = Enum.KeyCode[C.SoruKey] or Enum.KeyCode.R
        VIM:SendKeyEvent(true, k, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, k, false, game)
    end
end

-- ============ MACRO RUNNER ============
macroRunning = false

local function equipWeapon(tip)
    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    if not char or not bp then return end
    local cur = char:FindFirstChildOfClass("Tool")
    if cur and cur.ToolTip == tip then return end
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == tip then
            local h = getHum(char)
            if h then
                pcall(function() h:EquipTool(tool) end)
                task.wait(0.05)
                return
            end
        end
    end
    if tip == "Blox Fruit" then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool:FindFirstChild("LeftClickRemote") or tool:GetAttribute("IsBloxFruit")) then
                local h = getHum(char)
                if h then
                    pcall(function() h:EquipTool(tool) end)
                    task.wait(0.05)
                    return
                end
            end
        end
    end
end

function runMacro()
    if macroRunning then return end
    local steps = Macros[ActiveMacro]
    if not steps or #steps == 0 then
        notify("Macro", "Macro trống!", 3)
        return
    end
    macroRunning = true
    task.spawn(function()
        for _, step in ipairs(steps) do
            if not macroRunning then break end
            pcall(function()
                if step.t == "weapon" then
                    equipWeapon(step.v)
                elseif step.t == "skill" then
                    local k = Enum.KeyCode[step.v]
                    if k and VIM then
                        VIM:SendKeyEvent(true, k, false, game)
                        task.wait(0.03)
                        VIM:SendKeyEvent(false, k, false, game)
                    end
                elseif step.t == "m1" then
                    if VIM then
                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.03)
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                elseif step.t == "dash" then
                    if VIM then
                        local k = Enum.KeyCode[step.v] or Enum.KeyCode.W
                        VIM:SendKeyEvent(true, k, false, game); task.wait(0.03)
                        VIM:SendKeyEvent(false, k, false, game); task.wait(0.03)
                        VIM:SendKeyEvent(true, k, false, game); task.wait(0.03)
                        VIM:SendKeyEvent(false, k, false, game)
                    end
                elseif step.t == "wait" then
                    task.wait(tonumber(step.v) or 0.1)
                end
            end)
            task.wait(step.d or 0.08)
        end
        macroRunning = false
    end)
end

task.spawn(function()
    while task.wait(0.15) do
        if not C.MacroAuto then continue end
        if macroRunning then continue end
        local myRoot = getRoot(LP.Character)
        if not myRoot then continue end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and isAlive(plr) and not isAlly(plr) and not inSafeZone(plr) then
                local r = getRoot(plr.Character)
                if r and (myRoot.Position - r.Position).Magnitude <= C.MacroRange then
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(r.Position.X, myRoot.Position.Y, r.Position.Z))
                    runMacro()
                    break
                end
            end
        end
    end
end)

-- ============ LIGHTING BACKUP ============
lgBackup = nil
hiddenAtm = {}

local function backupLighting()
    if lgBackup then return end
    lgBackup = {
        A = Lighting.Ambient, O = Lighting.OutdoorAmbient,
        B = Lighting.Brightness, T = Lighting.ClockTime,
        S = Lighting.GlobalShadows,
        FE = Lighting.FogEnd, FS = Lighting.FogStart, FC = Lighting.FogColor,
        Q = settings().Rendering.QualityLevel,
    }
end

function restoreLighting()
    if not lgBackup then return end
    pcall(function()
        Lighting.Ambient = lgBackup.A
        Lighting.OutdoorAmbient = lgBackup.O
        Lighting.Brightness = lgBackup.B
        Lighting.ClockTime = lgBackup.T
        Lighting.GlobalShadows = lgBackup.S
        Lighting.FogEnd = lgBackup.FE
        Lighting.FogStart = lgBackup.FS
        Lighting.FogColor = lgBackup.FC
        settings().Rendering.QualityLevel = lgBackup.Q
    end)
    -- Khôi phục Atmosphere/Sky/Clouds
    for obj, parent in pairs(hiddenAtm) do
        if obj and not obj.Parent and parent then
            pcall(function() obj.Parent = parent end)
        end
    end
    hiddenAtm = {}
end

-- ============ FIX LAG (LOOP MỖI FRAME) ============
fixLagConn = nil
local function applyFixLag(on)
    if fixLagConn then
        pcall(function() fixLagConn:Disconnect() end)
        fixLagConn = nil
    end
    if on then
        backupLighting()
        -- Setup 1 lần
        for _, d in ipairs(Lighting:GetDescendants()) do
            if d:IsA("BlurEffect") or d:IsA("SunRaysEffect")
                or d:IsA("ColorCorrectionEffect") or d:IsA("BloomEffect")
                or d:IsA("DepthOfFieldEffect") then
                pcall(function() d.Enabled = false end)
            end
        end
        pcall(function()
            local t = workspace:FindFirstChildOfClass("Terrain")
            if t then
                t.WaterWaveSize = 0; t.WaterWaveSpeed = 0
                t.WaterReflectance = 0; t.WaterTransparency = 0
            end
        end)
        -- Loop mỗi frame
        fixLagConn = RunService.Heartbeat:Connect(function()
            if not C.FixLag then return end
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                Lighting.GlobalShadows = false
                -- Tắt effect mới spawn
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                        or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                        obj.Enabled = false
                    end
                end
            end)
        end)
        notify("Fix Lag", "Đã BẬT", 3)
    else
        restoreLighting()
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                    or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = true
                end
            end
        end)
        notify("Fix Lag", "Đã TẮT", 3)
    end
end

-- ============ NO FOG (DESTROY ATMOSPHERE) ============
noFogConn = nil
local function applyNoFog(on)
    if noFogConn then
        pcall(function() noFogConn:Disconnect() end)
        noFogConn = nil
    end
    if on then
        backupLighting()
        -- Xóa Atmosphere/Sky/Clouds
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("Clouds") then
                hiddenAtm[obj] = obj.Parent
                obj.Parent = nil
            end
        end
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        -- Loop chống respawn
        noFogConn = RunService.Heartbeat:Connect(function()
            if not C.NoFog then return end
            pcall(function()
                for _, obj in ipairs(Lighting:GetChildren()) do
                    if obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("Clouds") then
                        hiddenAtm[obj] = obj.Parent
                        obj.Parent = nil
                    end
                end
                Lighting.FogEnd = 100000
                Lighting.FogStart = 0
            end)
        end)
        notify("Sương mù", "Đã xóa", 3)
    else
        restoreLighting()
        notify("Sương mù", "Đã bật lại", 3)
    end
end

-- ============ WATER WALK (đi ngang mặt nước) ============
waterConn = nil
function applyWater(on)
    if waterConn then waterConn:Disconnect(); waterConn = nil end
    local map = workspace:FindFirstChild("Map") or workspace
    if on then
        -- Bật CanCollide cho part có tên "water"
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("water") then
                obj.CanCollide = true
            end
        end
        -- Loop bảo trì
        waterConn = RunService.Heartbeat:Connect(function()
            if not C.Water then return end
            pcall(function()
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name:lower():find("water") then
                        if not obj.CanCollide then obj.CanCollide = true end
                    end
                end
            end)
        end)
    else
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("water") then
                obj.CanCollide = false
            end
        end
    end
end

-- ============ NO CLIP ============
noclipConn = nil
function applyNoClip(on)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if not on then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not C.NoClip then return end
        local char = LP.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end)
end

-- ============ FLY (mobile fix) ============
flyConn = nil
function applyFly(on)
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local char = LP.Character
    local hrp = getRoot(char)
    if hrp then
        local bv = hrp:FindFirstChild("DungdxFlyBV"); if bv then bv:Destroy() end
        local bg = hrp:FindFirstChild("DungdxFlyBG"); if bg then bg:Destroy() end
    end
    local h = getHum(char)
    if h then h.PlatformStand = on end
    if not on then return end
    flyConn = RunService.RenderStepped:Connect(function()
        if not C.Fly then return end
        local c = getCam()
        local char = LP.Character
        local hrp = getRoot(char)
        local h = getHum(char)
        if not hrp or not c then return end
        if h and not h.PlatformStand then h.PlatformStand = true end

        local bv = hrp:FindFirstChild("DungdxFlyBV")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "DungdxFlyBV"
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bv.Velocity = Vector3.zero; bv.P = 1e5
            bv.Parent = hrp
        end
        local bg = hrp:FindFirstChild("DungdxFlyBG")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name = "DungdxFlyBG"
            bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            bg.P = 1e4; bg.D = 1e3
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
        end

        -- Mobile: dùng MoveDirection (joystick phản ánh vào đây)
        local dir = Vector3.zero
        if h then
            local mv = h.MoveDirection
            if mv.Magnitude > 0 then dir = dir + mv.Unit * C.FlySpeed end
        end
        -- Lên/xuống: Space/Ctrl hoặc nút UI
        if UIS:IsKeyDown(Enum.KeyCode.Space) or flyUp then
            dir = dir + Vector3.new(0, C.FlySpeed, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) or flyDown then
            dir = dir - Vector3.new(0, C.FlySpeed, 0)
        end
        bv.Velocity = dir
        bg.CFrame = c.CFrame
    end)
end

-- ============ SPEED / JUMP LOOP (chống game reset) ============
task.spawn(function()
    while task.wait() do
        local char = LP.Character
        local h = char and char:FindFirstChildOfClass("Humanoid")
        if h then
            if h.WalkSpeed ~= C.Speed then h.WalkSpeed = C.Speed end
            if h.JumpPower ~= C.Jump then
                h.UseJumpPower = true
                h.JumpPower = C.Jump
            end
        end
    end
end)

-- ============ FULL BRIGHT ============
brightBackup = nil
function applyBright(on)
    if on then
        if not brightBackup then
            brightBackup = {
                A = Lighting.Ambient, O = Lighting.OutdoorAmbient,
                B = Lighting.Brightness, T = Lighting.ClockTime,
            }
        end
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
    else
        if brightBackup then
            Lighting.Ambient = brightBackup.A
            Lighting.OutdoorAmbient = brightBackup.O
            Lighting.Brightness = brightBackup.B
            Lighting.ClockTime = brightBackup.T
        end
    end
end

-- ============ ANTI-AFK ============
LP.Idled:Connect(function()
    if VU then
        pcall(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- ============ RESPAWN ============
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if C.NoClip then applyNoClip(true) end
    if C.Fly then applyFly(true) end
    if C.Water then applyWater(true) end
    if C.HB_Player then refreshHB() end
    if C.ESPOn then refreshESP() end
end)

-- ============ HUD ============
local hud = mk("TextLabel", {
    Size = UDim2.new(0, 760, 0, 18),
    Position = UDim2.new(0, 20, 1, -28),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code, TextSize = 11,
    TextColor3 = Color3.fromRGB(255, 220, 220),
    TextStrokeTransparency = 0.5,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = ScreenGui,
})

RunService.RenderStepped:Connect(function()
    if not C.ShowHUD then hud.Visible = false; return end
    hud.Visible = true
    local myRoot = getRoot(LP.Character)
    local cnt = 0
    if myRoot then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and isAlive(plr) and not isAlly(plr) then
                local r = getRoot(plr.Character)
                if r and (myRoot.Position - r.Position).Magnitude <= C.ESPMaxDist then
                    cnt = cnt + 1
                end
            end
        end
    end
    hud.Text = string.format(
        "[DUNGDX] Aim:%s%s ESP:%s HB:%s/%s Soru:%s Fly:%s Water:%s Lag:%s Fog:%s | Địch:%d",
        C.AimOn and "ON" or "--",
        C.AimSilent and "-S" or "",
        C.ESPOn and "ON" or "--",
        C.HB_Player and "P" or "-",
        C.HB_NPC and "N" or "-",
        C.SoruOn and "ON" or "--",
        C.Fly and "ON" or "--",
        C.Water and "ON" or "--",
        C.FixLag and "ON" or "--",
        C.NoFog and "ON" or "--",
        cnt
    )
end)

-- ============ AUTO SAVE ============
task.spawn(function()
    while task.wait(20) do saveCfg() end
end)

-- ============ INIT ============
task.spawn(function()
    task.wait(1)
    if C.ESPOn then refreshESP() end
    if C.FixLag then applyFixLag(true) end
    if C.NoFog then applyNoFog(true) end
    if C.NoClip then applyNoClip(true) end
    if C.Fly then
        applyFly(true)
        FlyUpBtn.Visible = true
        FlyDownBtn.Visible = true
    end
    if C.Water then applyWater(true) end
    if C.Bright then applyBright(true) end
    if C.HB_Player or C.HB_NPC then refreshHB() end
    if C.SoruOn then SoruBtn.Visible = true end
end)

refreshESP()

task.wait(0.5)
notify("DUNGDX PVP", loaded and "Đã load cài đặt!" or "Script đã sẵn sàng!", 4)
print("[DUNGDX PVP] Loaded. Discord: discord.gg/jbCzvtmSZ")