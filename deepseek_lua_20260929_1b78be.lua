--[[
    DUNGDX PVP v4 — Blox Fruit
    - Fix hoàn toàn overlap UI (dùng AutomaticSize)
    - Thêm: Fly, Speed, JumpPower, FullBright, TP Player,
      Bring Player, Auto Dodge, Combo Presets, Server Hop
    Discord: https://discord.gg/AJBT8F79yf
]]--

-- ============ SERVICES ============
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local TS          = game:GetService("TweenService")
local VIM         = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local Lighting    = game:GetService("Lighting")
local TPS         = game:GetService("TeleportService")
local LP          = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ============ CONFIG ============
local Cfg = {
    AimOn=false, AimTeam=true, AimVisible=false,
    AimSmooth=0.35, AimFOV=350, AimPart="Head", AimKey="E",

    AttackOn=false, AttackRange=25,

    MacroAuto=false, MacroRange=30, MacroKey="Q",

    ESPOn=false, ESPTeam=true, ESPName=true,
    ESPDist=true, ESPHealth=true, ESPMaxDist=3000,

    ShowHUD=true,
    FixLag=false,
    WalkWater=false,
    NoClip=false,

    Fly=false,        FlySpeed=50,
    Speed=16,
    JumpPower=50,
    FullBright=false,

    TPMouse=true,     -- chuột phải để dịch chuyển
}

-- ============ MACRO STORAGE ============
local Macros = {
    ["Combo Melee"] = {
        { type="weapon", value="Melee", delay=0.1 },
        { type="skill",  value="Z", delay=0.1 },
        { type="skill",  value="X", delay=0.1 },
        { type="skill",  value="C", delay=0.15 },
    },
    ["Combo Kiếm"] = {
        { type="weapon", value="Sword", delay=0.1 },
        { type="skill",  value="Z", delay=0.1 },
        { type="skill",  value="X", delay=0.15 },
    },
    ["Combo Súng"] = {
        { type="weapon", value="Gun", delay=0.1 },
        { type="skill",  value="Z", delay=0.15 },
        { type="m1",     value=1,      delay=0.1 },
    },
    ["Combo Trái"] = {
        { type="weapon", value="Blox Fruit", delay=0.1 },
        { type="skill",  value="Z", delay=0.12 },
        { type="skill",  value="X", delay=0.12 },
        { type="skill",  value="C", delay=0.18 },
    },
    ["Combo Full (V+S+BF)"] = {
        { type="weapon", value="Melee",      delay=0.08 },
        { type="skill",  value="Z",          delay=0.1 },
        { type="skill",  value="X",          delay=0.1 },
        { type="weapon", value="Sword",      delay=0.08 },
        { type="skill",  value="Z",          delay=0.12 },
        { type="weapon", value="Blox Fruit", delay=0.08 },
        { type="skill",  value="Z",          delay=0.12 },
        { type="skill",  value="X",          delay=0.15 },
    },
}
local ActiveMacro = "Combo Full (V+S+BF)"

-- ============ THEME ============
local T = {
    Bg=Color3.fromRGB(14,14,20), Card=Color3.fromRGB(22,22,32),
    Row=Color3.fromRGB(30,30,42), RowHov=Color3.fromRGB(40,40,55),
    Accent=Color3.fromRGB(130,85,255), Accent2=Color3.fromRGB(90,175,255),
    Text=Color3.fromRGB(235,235,245), Dim=Color3.fromRGB(150,150,165),
    Green=Color3.fromRGB(80,220,120), Red=Color3.fromRGB(230,75,75),
    Orange=Color3.fromRGB(255,170,60),
}

-- ============ HELPERS ============
local function new(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p}) end
local function stroke(p,c,t) return new("UIStroke",{Color=c or T.Row,Thickness=t or 1,Parent=p}) end

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
local function notify(title, text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = dur or 4,
        })
    end)
end

-- ============ SCREEN GUI ============
local ScreenGui = new("ScreenGui", {
    Name = "DungdxPvP",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = LP:WaitForChild("PlayerGui"),
})

-- ============ MAIN WINDOW ============
local Main = new("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 500, 0, 560),
    Position = UDim2.new(0.5, -250, 0.5, -280),
    BackgroundColor3 = T.Bg,
    BorderSizePixel = 0,
    Active = true, Draggable = true,
    Parent = ScreenGui,
})
corner(Main, 14); stroke(Main, T.Accent, 1.5)

local uiScale = new("UIScale", { Parent = Main })
local function fit()
    local vp = Camera and Camera.ViewportSize or Vector2.new(1000,700)
    uiScale.Scale = math.clamp(math.min((vp.X-40)/500, (vp.Y-100)/560), 0.6, 1)
end
fit()
if Camera then Camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) end

-- Header
local Header = new("Frame", {
    Size = UDim2.new(1,0,0,52),
    BackgroundColor3 = T.Card,
    BorderSizePixel = 0,
    Parent = Main,
})
corner(Header, 14)
new("TextLabel", {
    Size = UDim2.new(1,-60,0,20), Position = UDim2.new(0,18,0,8),
    BackgroundTransparency = 1, Text = "DUNGDX PVP  v4",
    Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})
new("TextLabel", {
    Size = UDim2.new(1,-60,0,14), Position = UDim2.new(0,18,0,30),
    BackgroundTransparency = 1, Text = "Blox Fruit • Full PvP Pack",
    Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})

local CloseBtn = new("TextButton", {
    Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-40,0,11),
    BackgroundColor3 = T.Red, Text = "×",
    Font = Enum.Font.GothamBold, TextSize = 18,
    TextColor3 = Color3.new(1,1,1), AutoButtonColor = false,
    Parent = Header,
})
corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Tab bar
local TabBar = new("Frame", {
    Size = UDim2.new(1,-24,0,34),
    Position = UDim2.new(0,12,0,62),
    BackgroundTransparency = 1,
    Parent = Main,
})
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0,5),
    Parent = TabBar,
})

-- Content
local Content = new("Frame", {
    Size = UDim2.new(1,-24,1,-112),
    Position = UDim2.new(0,12,0,104),
    BackgroundTransparency = 1,
    Parent = Main,
})

-- FAB
local FAB = new("TextButton", {
    Size = UDim2.new(0,54,0,54),
    Position = UDim2.new(0,20,0.5,-27),
    BackgroundColor3 = T.Accent, Text = "PVP",
    Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = Color3.new(1,1,1), AutoButtonColor = false,
    Draggable = true, Parent = ScreenGui,
})
corner(FAB, 999); stroke(FAB, Color3.fromRGB(180,140,255), 2)
FAB.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ============ TABS ============
local Tabs = {}
local function makeTab(name)
    local sc = new("ScrollingFrame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,   -- <-- tự tính canvas
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        Parent = Content,
    })
    new("UIListLayout", {
        Padding = UDim.new(0,8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sc,
    })
    new("UIPadding", {
        PaddingTop = UDim.new(0,4),
        PaddingBottom = UDim.new(0,16),
        PaddingRight = UDim.new(0,8),
        Parent = sc,
    })

    local btn = new("TextButton", {
        Size = UDim2.new(0,118,1,0),
        BackgroundColor3 = T.Row,
        Text = name, Font = Enum.Font.GothamSemibold, TextSize = 11,
        TextColor3 = T.Dim, AutoButtonColor = false,
        Parent = TabBar,
    })
    corner(btn, 8)
    btn.MouseButton1Click:Connect(function()
        for _,t in pairs(Tabs) do
            t.frame.Visible = false
            t.btn.BackgroundColor3 = T.Row
            t.btn.TextColor3 = T.Dim
        end
        sc.Visible = true
        btn.BackgroundColor3 = T.Accent
        btn.TextColor3 = Color3.new(1,1,1)
    end)
    Tabs[name] = { frame = sc, btn = btn }
    return sc
end

local TCombat  = makeTab("⚔ Chiến Đấu")
local TMacro   = makeTab("🎬 Macro")
local TVisual  = makeTab("👁 Hiển Thị")
local TMove    = makeTab("🚀 Di Chuyển")
local TMisc    = makeTab("⚙ Cài Đặt")

TCombat.Visible = true
Tabs["⚔ Chiến Đấu"].btn.BackgroundColor3 = T.Accent
Tabs["⚔ Chiến Đấu"].btn.TextColor3 = Color3.new(1,1,1)

-- ============ SECTION (fix overlap bằng AutomaticSize) ============
-- Tất cả row nằm TRỰC TIẾP trong section frame (không có wrapper lồng nhau).
-- Section tự giãn theo UIListLayout bên trong.
local function section(parent, title)
    local sec = new("Frame", {
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,     -- <-- tự giãn chiều cao
        BackgroundColor3 = T.Card,
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(sec, 10); stroke(sec, Color3.fromRGB(45,45,60), 1)

    new("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = sec,
    })

    local ll = new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sec,
    })

    if title then
        new("TextLabel", {
            Size = UDim2.new(1,-10,0,18),
            BackgroundTransparency = 1,
            Text = title,
            Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = T.Accent2,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = -100,
            Parent = sec,
        })
    end
    -- Row bên trong cần giảm width vì đã có padding
    return sec, ll
end

-- Row dùng chung: tự thích chiều rộng theo section có padding
local function makeToggle(parent, text, default, cb)
    local row = new("Frame", {
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,14,0,0),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    local pill = new("TextButton", {
        Size = UDim2.new(0,46,0,22), Position = UDim2.new(1,-58,0,7),
        BackgroundColor3 = default and T.Accent or Color3.fromRGB(60,60,75),
        Text = "", AutoButtonColor = false, Parent = row,
    })
    corner(pill, 999)
    local knob = new("Frame", {
        Size = UDim2.new(0,18,0,18),
        Position = default and UDim2.new(1,-20,0,2) or UDim2.new(0,2,0,2),
        BackgroundColor3 = Color3.new(1,1,1),
        Parent = pill,
    })
    corner(knob, 999)
    local st = default
    local function paint()
        if st then
            pill.BackgroundColor3 = T.Accent
            TS:Create(knob, TweenInfo.new(0.15), {Position=UDim2.new(1,-20,0,2)}):Play()
        else
            pill.BackgroundColor3 = Color3.fromRGB(60,60,75)
            TS:Create(knob, TweenInfo.new(0.15), {Position=UDim2.new(0,2,0,2)}):Play()
        end
    end
    pill.MouseButton1Click:Connect(function()
        st = not st; paint()
        if cb then pcall(cb, st) end
    end)
    return { Set=function(_,v) st=v; paint() end, Get=function() return st end }
end

local function makeSlider(parent, text, min, max, default, step, cb)
    local row = new("Frame", {
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(0.7,-20,0,16), Position = UDim2.new(0,14,0,6),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    local val = new("TextLabel", {
        Size = UDim2.new(0.3,-14,0,16), Position = UDim2.new(0.7,0,0,6),
        BackgroundTransparency = 1, Text = tostring(default),
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    local track = new("Frame", {
        Size = UDim2.new(1,-28,0,5), Position = UDim2.new(0,14,0,34),
        BackgroundColor3 = Color3.fromRGB(60,60,75),
        BorderSizePixel = 0, Parent = row,
    })
    corner(track, 999)
    local fill = new("Frame", {
        Size = UDim2.new(0,0,1,0),
        BackgroundColor3 = T.Accent, BorderSizePixel = 0, Parent = track,
    })
    corner(fill, 999)
    local cur = default
    local function setV(v, fire)
        v = math.clamp(v, min, max)
        if step and step > 0 then v = math.floor((v-min)/step+0.5)*step+min end
        cur = v
        local a = (max-min)==0 and 0 or (v-min)/(max-min)
        fill.Size = UDim2.new(a,0,1,0)
        val.Text = tostring(math.floor(v*100+0.5)/100)
        if fire and cb then pcall(cb, v) end
    end
    setV(default, false)
    local drag = false
    local function upd(i)
        local x = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local a = track.AbsoluteSize.X==0 and 0 or x/track.AbsoluteSize.X
        setV(min + (max-min)*a, true)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag = true; upd(i)
        end
    end)
    track.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    return { Get=function() return cur end, Set=function(_,v) setV(v,false) end }
end

local function makeDropdown(parent, text, default, options, cb)
    local row = new("Frame", {
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = T.Row,
        BorderSizePixel = 0,
        Parent = parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(0.45,-14,1,0), Position = UDim2.new(0,14,0,0),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    local btn = new("TextButton", {
        Size = UDim2.new(0.55,-14,1,-10), Position = UDim2.new(0.45,0,0,5),
        BackgroundColor3 = T.Card,
        Text = tostring(default), Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, AutoButtonColor = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    corner(btn, 6)
    local cur, idx = default, 1
    for i,v in ipairs(options) do if v == default then idx = i break end end
    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        cur = options[idx]
        btn.Text = tostring(cur)
        if cb then pcall(cb, cur) end
    end)
    return {
        Get=function() return cur end,
        Set=function(_,v)
            cur = v; btn.Text = tostring(v)
            for i,o in ipairs(options) do if o==v then idx=i break end end
            if cb then pcall(cb, v) end
        end,
        SetOptions=function(_,newOpts,newVal)
            options = newOpts
            if newVal then cur = newVal; btn.Text = tostring(newVal) end
            for i,o in ipairs(options) do if o==cur then idx=i break end end
        end
    }
end

local function makeButton(parent, text, color, cb)
    local b = new("TextButton", {
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = color or T.Accent,
        Text = text, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false,
        Parent = parent,
    })
    corner(b, 8)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return b
end

-- ============ TAB 1: CHIẾN ĐẤU ============
do
    local s1 = section(TCombat, "🎯 AIMBOT")
    makeToggle(s1, "Bật Aimbot (giữ phím)", Cfg.AimOn, function(v) Cfg.AimOn=v end)
    makeToggle(s1, "Kiểm tra đồng đội", Cfg.AimTeam, function(v) Cfg.AimTeam=v end)
    makeToggle(s1, "Chỉ lock khi nhìn thấy", Cfg.AimVisible, function(v) Cfg.AimVisible=v end)
    makeSlider(s1, "Độ mượt", 0, 1, Cfg.AimSmooth, 0.05, function(v) Cfg.AimSmooth=v end)
    makeSlider(s1, "Vùng FOV", 50, 800, Cfg.AimFOV, 10, function(v) Cfg.AimFOV=v end)
    makeDropdown(s1, "Bộ phận ngắm", Cfg.AimPart, {"Head","UpperTorso","LowerTorso","HumanoidRootPart"}, function(v) Cfg.AimPart=v end)
    makeDropdown(s1, "Phím Aimbot", Cfg.AimKey, {"E","Q","C","V","F","R","T","G"}, function(v) Cfg.AimKey=v end)

    local s2 = section(TCombat, "⚔ ĐÁNH TỰ ĐỘNG")
    makeToggle(s2, "Auto M1 (tự click)", Cfg.AttackOn, function(v) Cfg.AttackOn=v end)
    makeSlider(s2, "Tầm M1", 10, 40, Cfg.AttackRange, 1, function(v) Cfg.AttackRange=v end)
end

-- ============ TAB 2: MACRO ============
local macroUI = {}
do
    local s1 = section(TMacro, "⚙ CẤU HÌNH MACRO")
    local macroNames = {}
    for n in pairs(Macros) do table.insert(macroNames, n) end
    table.sort(macroNames)
    local comboDrop = makeDropdown(s1, "Macro đang dùng", ActiveMacro, macroNames, function(v)
        ActiveMacro = v
        if macroUI.refresh then macroUI.refresh() end
    end)
    makeDropdown(s1, "Phím kích hoạt", Cfg.MacroKey, {"Q","E","R","T","F","G","H","Z"}, function(v) Cfg.MacroKey=v end)
    makeSlider(s1, "Tầm chạy Macro", 10, 60, Cfg.MacroRange, 1, function(v) Cfg.MacroRange=v end)
    makeToggle(s1, "Tự lặp khi gần địch", Cfg.MacroAuto, function(v) Cfg.MacroAuto=v end)

    local s2 = section(TMacro, "📋 QUẢN LÝ MACRO")
    local btnRow = new("Frame", {
        Size = UDim2.new(1,0,0,36),
        BackgroundTransparency = 1, Parent = s2,
    })
    new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,6), Parent=btnRow})
    local mkBtn = new("TextButton", {
        Size = UDim2.new(0.5,-3,1,0), BackgroundColor3 = T.Green,
        Text = "+ Tạo Macro", Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, Parent = btnRow,
    }); corner(mkBtn, 8)
    local delBtn = new("TextButton", {
        Size = UDim2.new(0.5,-3,1,0), BackgroundColor3 = T.Red,
        Text = "🗑 Xóa Macro", Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, Parent = btnRow,
    }); corner(delBtn, 8)

    local newRow = new("Frame", {
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = T.Row, BorderSizePixel = 0,
        Visible = false, Parent = s2,
    })
    corner(newRow, 8)
    local tb = new("TextBox", {
        Size = UDim2.new(1,-84,1,-10), Position = UDim2.new(0,6,0,5),
        BackgroundColor3 = T.Card, PlaceholderText = "Tên macro mới...",
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, Text = "", ClearTextOnFocus = false,
        Parent = newRow,
    }); corner(tb, 6)
    local okBtn = new("TextButton", {
        Size = UDim2.new(0,70,1,-10), Position = UDim2.new(1,-76,0,5),
        BackgroundColor3 = T.Green, Text = "Tạo",
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, Parent = newRow,
    }); corner(okBtn, 6)

    mkBtn.MouseButton1Click:Connect(function() newRow.Visible = not newRow.Visible end)
    okBtn.MouseButton1Click:Connect(function()
        local name = tb.Text:gsub("^%s+",""):gsub("%s+$","")
        if name ~= "" and not Macros[name] then
            Macros[name] = {}
            ActiveMacro = name
            local names = {}
            for n in pairs(Macros) do table.insert(names,n) end
            table.sort(names)
            comboDrop:SetOptions(names, name)
            tb.Text = ""; newRow.Visible = false
            if macroUI.refresh then macroUI.refresh() end
            notify("Macro", "Đã tạo: "..name, 3)
        else
            notify("Macro", "Tên không hợp lệ hoặc đã tồn tại!", 3)
        end
    end)
    delBtn.MouseButton1Click:Connect(function()
        if ActiveMacro and Macros[ActiveMacro] and #Macros > 1 then
            Macros[ActiveMacro] = nil
            local first = nil
            for n in pairs(Macros) do first = n break end
            ActiveMacro = first
            local names = {}
            for n in pairs(Macros) do table.insert(names,n) end
            table.sort(names)
            comboDrop:SetOptions(names, ActiveMacro)
            if macroUI.refresh then macroUI.refresh() end
            notify("Macro", "Đã xóa", 3)
        else
            notify("Macro", "Không thể xóa macro cuối cùng!", 3)
        end
    end)

    local s3 = section(TMacro, "🎬 CÁC BƯỚC MACRO")
    local addBtn = makeButton(s3, "+  THÊM BƯỚC", T.Green, nil)

    -- Popup thêm bước — nằm trong cùng section, tự đẩy các bước xuống
    local popup = new("Frame", {
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.Card,
        BorderSizePixel = 0,
        Visible = false,
        Parent = s3,
    })
    corner(popup, 8); stroke(popup, T.Accent2, 1)
    new("UIPadding", {
        PaddingTop = UDim.new(0,6), PaddingBottom = UDim.new(0,6),
        PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6),
        Parent = popup,
    })
    new("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, Parent=popup})

    local function popHeader(txt)
        new("TextLabel", {
            Size = UDim2.new(1,0,0,18),
            BackgroundTransparency = 1, Text = txt,
            Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = popup,
        })
    end
    local function popOpt(label, data)
        local b = new("TextButton", {
            Size = UDim2.new(1,0,0,28),
            BackgroundColor3 = T.Row, Text = label,
            Font = Enum.Font.Gotham, TextSize = 11,
            TextColor3 = T.Text, AutoButtonColor = false, Parent = popup,
        })
        corner(b, 6)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = T.RowHov end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = T.Row end)
        b.MouseButton1Click:Connect(function()
            if ActiveMacro and Macros[ActiveMacro] then
                local step = {}
                for k,v in pairs(data) do step[k] = v end
                step.delay = step.delay or 0.08
                table.insert(Macros[ActiveMacro], step)
                popup.Visible = false
                if macroUI.refresh then macroUI.refresh() end
            end
        end)
    end

    popHeader("— VŨ KHÍ —")
    popOpt("🗡 Trang bị Võ (Melee)", {type="weapon", value="Melee"})
    popOpt("⚔ Trang bị Kiếm (Sword)", {type="weapon", value="Sword"})
    popOpt("🔫 Trang bị Súng (Gun)",  {type="weapon", value="Gun"})
    popOpt("🍎 Trang bị Trái (Blox Fruit)", {type="weapon", value="Blox Fruit"})
    popHeader("— SKILL —")
    popOpt("Skill Z", {type="skill", value="Z"})
    popOpt("Skill X", {type="skill", value="X"})
    popOpt("Skill C", {type="skill", value="C"})
    popOpt("Skill V", {type="skill", value="V"})
    popOpt("Skill F", {type="skill", value="F"})
    popHeader("— KHÁC —")
    popOpt("👆 M1 (Click)", {type="m1", value=1})
    popOpt("💨 Dash (W+W)", {type="dash", value="W"})
    popOpt("⏱ Chờ 0.1s", {type="wait", value=0.1})
    popOpt("⏱ Chờ 0.3s", {type="wait", value=0.3})
    popOpt("⏱ Chờ 0.5s", {type="wait", value=0.5})

    addBtn.MouseButton1Click:Connect(function() popup.Visible = not popup.Visible end)

    -- Step list
    local stepList = new("Frame", {
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = s3,
    })
    new("UIListLayout", {Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder, Parent=stepList})

    macroUI.refresh = function()
        for _,c in ipairs(stepList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local steps = Macros[ActiveMacro] or {}
        for i,step in ipairs(steps) do
            local row = new("Frame", {
                Size = UDim2.new(1,0,0,34),
                BackgroundColor3 = T.Row,
                BorderSizePixel = 0, Parent = stepList,
            })
            corner(row, 6)

            new("TextLabel", {
                Size = UDim2.new(0,26,1,0), Position = UDim2.new(0,8,0,0),
                BackgroundTransparency = 1, Text = "#"..i,
                Font = Enum.Font.GothamBold, TextSize = 10,
                TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
            local typeText, color = "?", T.Text
            if step.type=="skill" then typeText = "Skill "..step.value; color = T.Orange
            elseif step.type=="weapon" then typeText = "Trang bị "..step.value; color = T.Accent2
            elseif step.type=="m1" then typeText = "M1 Click"; color = T.Text
            elseif step.type=="dash" then typeText = "Dash"; color = T.Text
            elseif step.type=="wait" then typeText = "Chờ "..step.value.."s"; color = T.Dim end

            new("TextLabel", {
                Size = UDim2.new(1,-130,1,0), Position = UDim2.new(0,36,0,0),
                BackgroundTransparency = 1, Text = typeText,
                Font = Enum.Font.Gotham, TextSize = 11,
                TextColor3 = color, TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })
            new("TextLabel", {
                Size = UDim2.new(0,44,1,0), Position = UDim2.new(1,-110,0,0),
                BackgroundTransparency = 1, Text = string.format("%.2fs", step.delay or 0.08),
                Font = Enum.Font.Gotham, TextSize = 10,
                TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })
            local box = new("Frame", {
                Size = UDim2.new(0,62,1,-6), Position = UDim2.new(1,-66,0,3),
                BackgroundTransparency = 1, Parent = row,
            })
            new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,2), Parent=box})
            local function miniBtn(txt,col,cb)
                local b = new("TextButton", {
                    Size = UDim2.new(0,18,1,0),
                    BackgroundColor3 = T.Card, Text = txt,
                    Font = Enum.Font.GothamBold, TextSize = 11,
                    TextColor3 = col, AutoButtonColor = false, Parent = box,
                }); corner(b, 4)
                b.MouseButton1Click:Connect(cb)
            end
            miniBtn("↑", T.Accent2, function()
                if i>1 then steps[i],steps[i-1]=steps[i-1],steps[i]; macroUI.refresh() end
            end)
            miniBtn("↓", T.Accent2, function()
                if i<#steps then steps[i],steps[i+1]=steps[i+1],steps[i]; macroUI.refresh() end
            end)
            miniBtn("×", T.Red, function()
                table.remove(steps,i); macroUI.refresh()
            end)
        end

        -- Row điều khiển cuối
        local ctrl = new("Frame", {
            Size = UDim2.new(1,0,0,36),
            BackgroundTransparency = 1, Parent = stepList,
        })
        new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,6), Parent=ctrl})
        local runBtn = new("TextButton", {
            Size = UDim2.new(0.5,-3,1,0), BackgroundColor3 = T.Accent,
            Text = "▶ CHẠY THỬ", Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, Parent = ctrl,
        }); corner(runBtn, 8)
        local clearBtn = new("TextButton", {
            Size = UDim2.new(0.5,-3,1,0), BackgroundColor3 = T.Row,
            Text = "🗑 XÓA HẾT", Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = T.Red, AutoButtonColor = false, Parent = ctrl,
        }); corner(clearBtn, 8)
        runBtn.MouseButton1Click:Connect(function() runMacro() end)
        clearBtn.MouseButton1Click:Connect(function()
            if ActiveMacro and Macros[ActiveMacro] then
                Macros[ActiveMacro] = {}
                macroUI.refresh()
            end
        end)
    end
    macroUI.refresh()
end

-- ============ TAB 3: HIỂN THỊ ============
do
    local s1 = section(TVisual, "👁 ESP NGƯỜI CHƠI")
    makeToggle(s1, "Bật ESP", Cfg.ESPOn, function(v)
        Cfg.ESPOn = v
        refreshESP()
    end)
    makeToggle(s1, "Kiểm tra đồng đội", Cfg.ESPTeam, function(v) Cfg.ESPTeam=v end)
    makeToggle(s1, "Hiện tên", Cfg.ESPName, function(v) Cfg.ESPName=v end)
    makeToggle(s1, "Hiện khoảng cách", Cfg.ESPDist, function(v) Cfg.ESPDist=v end)
    makeToggle(s1, "Hiện thanh máu", Cfg.ESPHealth, function(v) Cfg.ESPHealth=v end)
    makeSlider(s1, "Khoảng cách tối đa", 500, 10000, Cfg.ESPMaxDist, 100, function(v)
        Cfg.ESPMaxDist = v
        for _,b in pairs(espCache) do pcall(function() b.MaxDistance=v end) end
    end)

    local s2 = section(TVisual, "🌗 ÁNH SÁNG")
    makeToggle(s2, "Full Bright (nhìn rõ ban đêm)", Cfg.FullBright, function(v)
        Cfg.FullBright = v
        applyFullBright(v)
    end)
end

-- ============ TAB 4: DI CHUYỂN ============
do
    local s1 = section(TMove, "🚀 BAY")
    makeToggle(s1, "Fly (Space lên, Ctrl xuống)", Cfg.Fly, function(v)
        Cfg.Fly = v
        applyFly(v)
    end)
    makeSlider(s1, "Tốc độ Fly", 20, 300, Cfg.FlySpeed, 5, function(v) Cfg.FlySpeed=v end)

    local s2 = section(TMove, "🏃 TỐC ĐỘ")
    makeSlider(s2, "WalkSpeed", 16, 300, Cfg.Speed, 1, function(v)
        Cfg.Speed = v
        applySpeed()
    end)
    makeSlider(s2, "JumpPower", 50, 500, Cfg.JumpPower, 5, function(v)
        Cfg.JumpPower = v
        applyJump()
    end)
    makeButton(s2, "🔄 Reset về mặc định", T.Row, function()
        Cfg.Speed = 16; Cfg.JumpPower = 50
        applySpeed(); applyJump()
        notify("Reset", "Đã reset tốc độ", 3)
    end)

    local s3 = section(TMove, "🌊 XUYÊN / NƯỚC")
    makeToggle(s3, "Đi Trên Mặt Nước", Cfg.WalkWater, function(v)
        Cfg.WalkWater = v
        applyWalkWater(v)
    end)
    makeToggle(s3, "No Clip (xuyên vật thể)", Cfg.NoClip, function(v)
        Cfg.NoClip = v
        applyNoClip(v)
    end)

    local s4 = section(TMove, "📍 DỊCH CHUYỂN NHANH")
    makeToggle(s4, "Click chuột phải để bay đến", Cfg.TPMouse, function(v) Cfg.TPMouse=v end)

    local plrList = new("Frame", {
        Size = UDim2.new(1,0,0,36),
        BackgroundTransparency = 1, Parent = s4,
    })
    new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,6), Parent=plrList})

    local plrDropdown = makeDropdown(s4, "Chọn người chơi", "", {"(Trống)"}, function() end)

    local refreshBtn = makeButton(s4, "🔄 Refresh danh sách người chơi", T.Accent2, function()
        local names = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LP then table.insert(names, p.Name) end
        end
        if #names == 0 then names = {"(Không có ai)"} end
        plrDropdown:SetOptions(names, names[1])
    end)

    local tpBtn = makeButton(s4, "📍 Bay tới người chơi đã chọn", T.Accent, function()
        local target = Players:FindFirstChild(plrDropdown:Get())
        if target and target.Character then
            local root = getRoot(target.Character)
            local myRoot = getRoot(LP.Character)
            if root and myRoot then
                myRoot.CFrame = root.CFrame * CFrame.new(0, 0, 3)
                notify("TP", "Đã bay tới "..target.Name, 3)
            end
        else
            notify("TP", "Không tìm thấy người chơi", 3)
        end
    end)
end

-- ============ TAB 5: CÀI ĐẶT ============
do
    local s1 = section(TMisc, "⚡ HIỆU NĂNG")
    makeToggle(s1, "Fix Lag (giảm đồ hoạ)", Cfg.FixLag, function(v)
        Cfg.FixLag = v
        applyFixLag(v)
    end)

    local s2 = section(TMisc, "🎮 HUD")
    makeToggle(s2, "Hiện HUD", Cfg.ShowHUD, function(v) Cfg.ShowHUD=v end)

    local s3 = section(TMisc, "🌐 SERVER")
    makeButton(s3, "Rejoin Server", T.Accent2, function()
        TPS:Teleport(game.PlaceId, LP)
    end)
    makeButton(s3, "Server Hop (đổi server)", T.Accent, function()
        local ok = pcall(function()
            local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")).data
            for _,s in ipairs(servers) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                    return
                end
            end
        end)
        if not ok then notify("Hop", "Không hop được, thử lại sau", 3) end
    end)

    local s4 = section(TMisc, "🛑 KHẨN CẤP")
    makeButton(s4, "⛔ TẮT TẤT CẢ CHỨC NĂNG", T.Red, function()
        Cfg.AimOn=false; Cfg.AttackOn=false; Cfg.MacroAuto=false
        Cfg.ESPOn=false; Cfg.FixLag=false; Cfg.WalkWater=false
        Cfg.NoClip=false; Cfg.Fly=false; Cfg.FullBright=false
        applyFixLag(false); applyNoClip(false); applyFly(false)
        applyWalkWater(false); applyFullBright(false)
        clearESP()
        notify("Dungdx PVP", "Đã tắt toàn bộ chức năng", 3)
    end)

    local s5 = section(TMisc, "💬 DISCORD")
    new("TextLabel", {
        Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1,
        Text = "discord.gg/AJBT8F79yf",
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Center,
        Parent = s5,
    })
end

-- ============ ESP SYSTEM ============
local espCache = {}
function clearESP()
    for k,v in pairs(espCache) do pcall(function() v:Destroy() end) end
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
        Size = UDim2.new(0,200,0,44),
        StudsOffset = Vector3.new(0,3.2,0),
        AlwaysOnTop = true,
        MaxDistance = Cfg.ESPMaxDist,
        Parent = head,
    })
    local nameL = new("TextLabel", {
        Size = UDim2.new(1,0,0,16), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.fromRGB(255,80,80),
        TextStrokeTransparency = 0.4, TextStrokeColor3 = Color3.new(0,0,0),
        Text = "", Parent = bb,
    })
    local distL = new("TextLabel", {
        Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,16),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = Color3.fromRGB(220,220,220),
        TextStrokeTransparency = 0.4, TextStrokeColor3 = Color3.new(0,0,0),
        Text = "", Parent = bb,
    })
    local hpBg = new("Frame", {
        Size = UDim2.new(0.7,0,0,4), Position = UDim2.new(0.15,0,0,32),
        BackgroundColor3 = Color3.fromRGB(30,30,40),
        BorderSizePixel = 0, Parent = bb,
    }); corner(hpBg, 999)
    local hpFill = new("Frame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.fromRGB(80,220,120),
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
                local myRoot = getRoot(LP.Character)
                local hRoot = getRoot(c)
                if h and myRoot and hRoot then
                    nameL.Text = Cfg.ESPName and plr.Name or ""
                    distL.Text = Cfg.ESPDist and ("["..math.floor((myRoot.Position-hRoot.Position).Magnitude).." studs]") or ""
                    if Cfg.ESPHealth then
                        hpBg.Visible = true
                        hpFill.Size = UDim2.new(math.clamp(h.Health/h.MaxHealth,0,1),0,1,0)
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
    for _,plr in ipairs(Players:GetPlayers()) do
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
        task.wait(1); createESP(plr)
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    if espCache[plr] then
        pcall(function() espCache[plr]:Destroy() end)
        espCache[plr] = nil
    end
end)

-- ============ AIMBOT ============
local function getClosestTarget()
    local closest, closestDist = nil, Cfg.AimFOV
    local myRoot = getRoot(LP.Character)
    if not myRoot then return nil end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and alive(plr) and not isAlly(plr) then
            local char = plr.Character
            local part = char:FindFirstChild(Cfg.AimPart) or char:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(sp.X, sp.Y) - Camera.ViewportSize/2).Magnitude
                    if dist < closestDist then
                        if Cfg.AimVisible then
                            local ray = Ray.new(myRoot.Position, (part.Position-myRoot.Position).Unit*(part.Position-myRoot.Position).Magnitude)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, char})
                            if hit and not hit:IsDescendantOf(char) then continue end
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
        local goal = CFrame.new(Camera.CFrame.Position, tgt.part.Position)
        if Cfg.AimSmooth > 0 then
            Camera.CFrame = Camera.CFrame:Lerp(goal, 1 - Cfg.AimSmooth)
        else
            Camera.CFrame = goal
        end
    end
end)

-- ============ AUTO M1 ============
task.spawn(function()
    while task.wait(0.08) do
        if not Cfg.AttackOn then continue end
        local myRoot = getRoot(LP.Character)
        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if not myRoot or not tool then continue end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and alive(plr) and not isAlly(plr) then
                local hisRoot = getRoot(plr.Character)
                if hisRoot and (myRoot.Position-hisRoot.Position).Magnitude <= Cfg.AttackRange then
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(hisRoot.Position.X, myRoot.Position.Y, hisRoot.Position.Z))
                    pcall(function()
                        VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                        task.wait(0.02)
                        VIM:SendMouseButtonEvent(0,0,0,false,game,1)
                    end)
                    break
                end
            end
        end
    end
end)

-- ============ MACRO RUNNER ============
local macroRunning = false

local function equipWeapon(tooltip)
    local char = LP.Character
    local backpack = LP:FindFirstChild("Backpack")
    if not char or not backpack then return false end
    local current = char:FindFirstChildOfClass("Tool")
    if current and current.ToolTip == tooltip then return true end
    for _,tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == tooltip then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(tool); task.wait(0.05); return true end
        end
    end
    if tooltip == "Blox Fruit" then
        for _,tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool:FindFirstChild("LeftClickRemote") or tool:GetAttribute("IsBloxFruit")) then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(tool); task.wait(0.05); return true end
            end
        end
    end
    return false
end

function runMacro()
    if macroRunning then return end
    local steps = Macros[ActiveMacro]
    if not steps or #steps == 0 then
        notify("Macro", "Macro trống, thêm bước trước!", 3)
        return
    end
    macroRunning = true
    task.spawn(function()
        for _,step in ipairs(steps) do
            pcall(function()
                if step.type == "weapon" then
                    equipWeapon(step.value)
                elseif step.type == "skill" then
                    local k = Enum.KeyCode[step.value]
                    if k then
                        VIM:SendKeyEvent(true, k, false, game)
                        task.wait(0.02)
                        VIM:SendKeyEvent(false, k, false, game)
                    end
                elseif step.type == "m1" then
                    VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                    task.wait(0.02)
                    VIM:SendMouseButtonEvent(0,0,0,false,game,1)
                elseif step.type == "dash" then
                    local k = Enum.KeyCode[step.value] or Enum.KeyCode.W
                    VIM:SendKeyEvent(true, k, false, game); task.wait(0.03)
                    VIM:SendKeyEvent(false, k, false, game); task.wait(0.03)
                    VIM:SendKeyEvent(true, k, false, game); task.wait(0.03)
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

task.spawn(function()
    local holdKey = Enum.KeyCode[Cfg.MacroKey] or Enum.KeyCode.Q
    local lastKey = Cfg.MacroKey
    local cooldown = 0
    while task.wait(0.05) do
        if Cfg.MacroKey ~= lastKey then
            lastKey = Cfg.MacroKey
            holdKey = Enum.KeyCode[Cfg.MacroKey] or Enum.KeyCode.Q
        end
        if macroRunning then continue end
        if UIS:IsKeyDown(holdKey) then
            if tick() - cooldown > 0.3 then
                cooldown = tick(); runMacro()
            end
            continue
        end
        if Cfg.MacroAuto then
            local myRoot = getRoot(LP.Character)
            if myRoot then
                for _,plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and alive(plr) and not isAlly(plr) then
                        local hisRoot = getRoot(plr.Character)
                        if hisRoot and (myRoot.Position-hisRoot.Position).Magnitude <= Cfg.MacroRange then
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

-- ============ FIX LAG ============
local fixLagConn = nil
local origSettings = {}
function applyFixLag(on)
    if on then
        origSettings.GlobalShadows = Lighting.GlobalShadows
        origSettings.FogEnd = Lighting.FogEnd
        origSettings.Quality = settings().Rendering.QualityLevel
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        for _,d in ipairs(Lighting:GetDescendants()) do
            if d:IsA("BlurEffect") or d:IsA("SunRaysEffect") or d:IsA("ColorCorrectionEffect")
                or d:IsA("BloomEffect") or d:IsA("DepthOfFieldEffect") then
                pcall(function() d.Enabled = false end)
            end
        end
        pcall(function()
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0; terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0; terrain.WaterTransparency = 0
            end
        end)
        if fixLagConn then fixLagConn:Disconnect() end
        fixLagConn = task.spawn(function()
            while Cfg.FixLag do
                pcall(function()
                    for _,obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                            or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                            obj.Enabled = false
                        end
                    end
                    for _,obj in ipairs(workspace:GetChildren()) do
                        if obj.Name == "Debris" or obj.Name == "Effects" or obj.Name == "Effect" then
                            obj:ClearAllChildren()
                        end
                    end
                end)
                task.wait(2)
            end
        end)
        notify("Fix Lag", "Đã bật chế độ giảm lag", 3)
    else
        pcall(function()
            Lighting.GlobalShadows = origSettings.GlobalShadows or true
            Lighting.FogEnd = origSettings.FogEnd or 100000
            settings().Rendering.QualityLevel = origSettings.Quality or Enum.QualityLevel.Automatic
        end)
        for _,d in ipairs(Lighting:GetDescendants()) do
            if d:IsA("BlurEffect") or d:IsA("SunRaysEffect") or d:IsA("ColorCorrectionEffect")
                or d:IsA("BloomEffect") or d:IsA("DepthOfFieldEffect") then
                pcall(function() d.Enabled = true end)
            end
        end
        if fixLagConn then pcall(function() task.cancel(fixLagConn) end); fixLagConn = nil end
        notify("Fix Lag", "Đã tắt chế độ giảm lag", 3)
    end
end

-- ============ WALK ON WATER ============
local waterThread = nil
function applyWalkWater(on)
    if waterThread then pcall(function() task.cancel(waterThread) end); waterThread = nil end
    if not on then
        local hrp = getRoot(LP.Character)
        if hrp and hrp:FindFirstChild("DungdxWaterPlat") then hrp.DungdxWaterPlat:Destroy() end
        return
    end
    waterThread = task.spawn(function()
        while Cfg.WalkWater do
            pcall(function()
                local hrp = getRoot(LP.Character)
                if hrp then
                    local plat = hrp:FindFirstChild("DungdxWaterPlat")
                    if not plat then
                        plat = Instance.new("Part")
                        plat.Name = "DungdxWaterPlat"
                        plat.Size = Vector3.new(6,1,6)
                        plat.Transparency = 1
                        plat.CanCollide = true
                        plat.Anchored = true
                        plat.Parent = hrp
                    end
                    plat.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3.2, hrp.Position.Z)
                end
            end)
            task.wait(0.15)
        end
    end)
end

-- ============ NO CLIP ============
local noclipConn = nil
function applyNoClip(on)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if not on then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not Cfg.NoClip then return end
        local char = LP.Character
        if not char then return end
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

-- ============ FLY ============
local flyBV = nil, flyBG = nil, flyConn = nil
function applyFly(on)
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    if not on then return end

    flyConn = RunService.RenderStepped:Connect(function()
        if not Cfg.Fly then return end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not flyBV then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
            flyBV.Velocity = Vector3.zero
            flyBV.P = 1e4
            flyBV.Parent = hrp
        end
        if not flyBG then
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
            flyBG.P = 1e4
            flyBG.D = 1e2
            flyBG.CFrame = hrp.CFrame
            flyBG.Parent = hrp
        end

        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then
            dir = dir - Vector3.new(0,1,0)
        end

        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * Cfg.FlySpeed or Vector3.zero
        flyBG.CFrame = Camera.CFrame
    end)
end

-- ============ SPEED / JUMP ============
function applySpeed()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Cfg.Speed end
end
function applyJump()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = Cfg.JumpPower; hum.UseJumpPower = true end
end

-- ============ FULL BRIGHT ============
local origBrightness = nil
function applyFullBright(on)
    if on then
        origBrightness = { Ambient = Lighting.Ambient, Outdoor = Lighting.OutdoorAmbient, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime }
        Lighting.Ambient = Color3.fromRGB(178,178,178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        for _,d in ipairs(Lighting:GetDescendants()) do
            if d:IsA("Atmosphere") or d:IsA("Sky") then
                d.Parent = nil
            end
        end
    else
        if origBrightness then
            Lighting.Ambient = origBrightness.Ambient
            Lighting.OutdoorAmbient = origBrightness.Outdoor
            Lighting.Brightness = origBrightness.Brightness
            Lighting.ClockTime = origBrightness.ClockTime
        end
    end
end

-- ============ TP CHUỘT PHẢI ============
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Cfg.TPMouse then
        local mouse = LP:GetMouse()
        local hrp = getRoot(LP.Character)
        if mouse and mouse.Hit and hrp then
            hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- ============ ANTI-AFK ============
LP.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end)

-- ============ RESPAWN RE-APPLY ============
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if Cfg.NoClip then applyNoClip(true) end
    if Cfg.Fly then applyFly(true) end
    applySpeed(); applyJump()
    if Cfg.WalkWater then applyWalkWater(true) end
end)

-- ============ HUD ============
local hud = new("TextLabel", {
    Size = UDim2.new(0,500,0,18),
    Position = UDim2.new(0,20,1,-30),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code, TextSize = 11,
    TextColor3 = T.Green,
    TextStrokeTransparency = 0.5,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = ScreenGui,
})
RunService.RenderStepped:Connect(function()
    if not Cfg.ShowHUD then hud.Visible = false return end
    hud.Visible = true
    local myRoot = getRoot(LP.Character)
    local cnt = 0
    if myRoot then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and alive(plr) and not isAlly(plr) then
                local r = getRoot(plr.Character)
                if r and (myRoot.Position-r.Position).Magnitude <= Cfg.ESPMaxDist then
                    cnt = cnt + 1
                end
            end
        end
    end
    hud.Text = string.format("[DUNGDX v4] Aim:%s M1:%s Macro:%s ESP:%s Fly:%s NoClip:%s Water:%s Lag:%s | Địch: %d",
        Cfg.AimOn and "ON" or "--", Cfg.AttackOn and "ON" or "--",
        Cfg.MacroAuto and "ON" or "--", Cfg.ESPOn and "ON" or "--",
        Cfg.Fly and "ON" or "--", Cfg.NoClip and "ON" or "--",
        Cfg.WalkWater and "ON" or "--", Cfg.FixLag and "ON" or "--", cnt)
end)

-- ============ INIT ============
refreshESP()
applySpeed(); applyJump()

notify("Dungdx PVP v4", "Script sẵn sàng!", 4)
notify("Macro mới", "Có sẵn 5 combo preset: Melee, Kiếm, Súng, Trái, Full", 6)

print("[Dungdx PVP v4] Loaded.")