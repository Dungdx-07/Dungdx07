--[[
    DUNGDX PVP v5 — Blox Fruit
    - UI phẳng 100%, không overlap
    - Mobile-friendly: Aimbot & Macro dùng nút bấm
    - Chạy được cả PC và Mobile
    Discord: https://discord.gg/AJBT8F79yf
]]--

-- ============ SERVICES ============
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TS         = game:GetService("TweenService")
local VIM        = game:GetService("VirtualInputManager")
local VU         = game:GetService("VirtualUser")
local LG         = game:GetService("Lighting")
local TPS        = game:GetService("TeleportService")
local HS         = game:GetService("HttpService")
local SG         = game:GetService("StarterGui")
local LP         = Players.LocalPlayer

-- ============ CONFIG ============
local Cfg = {
    -- Aimbot
    AimOn=false, AimAlways=true, AimTeam=true, AimVisible=false,
    AimSmooth=0.35, AimFOV=350, AimPart="Head",

    -- Auto M1
    AttackOn=false, AttackRange=25,

    -- Macro
    MacroAuto=false, MacroRange=30, MacroManual=false,

    -- ESP
    ESPOn=false, ESPTeam=true, ESPMaxDist=3000,

    -- Misc
    ShowHUD=true, FixLag=false, WalkWater=false, NoClip=false,
    Fly=false, FlySpeed=50,
    Speed=16, JumpPower=50, FullBright=false, TPMouse=false,
}

-- ============ MACRO PRESETS ============
local Macros = {
    ["Combo Full"] = {
        {type="weapon", value="Melee", delay=0.08},
        {type="skill", value="Z", delay=0.10},
        {type="skill", value="X", delay=0.10},
        {type="weapon", value="Sword", delay=0.08},
        {type="skill", value="Z", delay=0.12},
        {type="weapon", value="Blox Fruit", delay=0.08},
        {type="skill", value="Z", delay=0.12},
        {type="skill", value="X", delay=0.15},
    },
    ["Combo Melee"] = {
        {type="weapon", value="Melee", delay=0.08},
        {type="skill", value="Z", delay=0.10},
        {type="skill", value="X", delay=0.10},
        {type="skill", value="C", delay=0.15},
    },
    ["Combo Sword"] = {
        {type="weapon", value="Sword", delay=0.08},
        {type="skill", value="Z", delay=0.10},
        {type="skill", value="X", delay=0.15},
    },
    ["Combo Gun"] = {
        {type="weapon", value="Gun", delay=0.08},
        {type="skill", value="Z", delay=0.15},
        {type="m1", value=1, delay=0.10},
    },
    ["Combo Fruit"] = {
        {type="weapon", value="Blox Fruit", delay=0.08},
        {type="skill", value="Z", delay=0.12},
        {type="skill", value="X", delay=0.12},
        {type="skill", value="C", delay=0.18},
    },
}
local ActiveMacro = "Combo Full"

-- ============ THEME ============
local T = {
    Bg=Color3.fromRGB(14,14,20), Card=Color3.fromRGB(22,22,32),
    Row=Color3.fromRGB(30,30,42),
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
local function notify(title, text, dur)
    pcall(function()
        SG:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 4})
    end)
end
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
local function getHum(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function cam() return workspace.CurrentCamera end

-- ============ SCREEN GUI ============
local ScreenGui = new("ScreenGui", {
    Name = "DungdxPvP", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = LP:WaitForChild("PlayerGui"),
})

-- ============ MAIN WINDOW ============
local Main = new("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 480, 0, 520),
    Position = UDim2.new(0.5, -240, 0.5, -260),
    BackgroundColor3 = T.Bg, BorderSizePixel = 0,
    Active = true, Draggable = true, Parent = ScreenGui,
})
corner(Main, 14); stroke(Main, T.Accent, 1.5)

local uiScale = new("UIScale", { Parent = Main })
local function fitUI()
    local c = cam()
    local vp = c and c.ViewportSize or Vector2.new(1000, 700)
    uiScale.Scale = math.clamp(math.min((vp.X-40)/480, (vp.Y-90)/520), 0.6, 1)
end
fitUI()
if cam() then cam():GetPropertyChangedSignal("ViewportSize"):Connect(fitUI) end

-- Header
local Header = new("Frame", {
    Size = UDim2.new(1,0,0,52),
    BackgroundColor3 = T.Card, BorderSizePixel = 0, Parent = Main,
})
corner(Header, 14)
new("TextLabel", {
    Size = UDim2.new(1,-60,0,20), Position = UDim2.new(0,18,0,8),
    BackgroundTransparency = 1, Text = "DUNGDX PVP  v5",
    Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header,
})
new("TextLabel", {
    Size = UDim2.new(1,-60,0,14), Position = UDim2.new(0,18,0,30),
    BackgroundTransparency = 1, Text = "Blox Fruit • Mobile Edition",
    Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header,
})
local CloseBtn = new("TextButton", {
    Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-40,0,11),
    BackgroundColor3 = T.Red, Text = "×",
    Font = Enum.Font.GothamBold, TextSize = 18,
    TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, Parent = Header,
})
corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Tab bar
local TabBar = new("Frame", {
    Size = UDim2.new(1,-24,0,34), Position = UDim2.new(0,12,0,62),
    BackgroundTransparency = 1, Parent = Main,
})
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0,5), Parent = TabBar,
})

-- Content
local Content = new("Frame", {
    Size = UDim2.new(1,-24,1,-112), Position = UDim2.new(0,12,0,104),
    BackgroundTransparency = 1, Parent = Main,
})

-- FAB
local FAB = new("TextButton", {
    Size = UDim2.new(0,54,0,54), Position = UDim2.new(0,20,0.5,-27),
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
    -- ScrollingFrame với AutomaticCanvasSize — UI phẳng 100%
    local sc = new("ScrollingFrame", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false, Parent = Content,
    })
    new("UIListLayout", {
        Padding = UDim.new(0,6),
        SortOrder = Enum.SortOrder.LayoutOrder, Parent = sc,
    })
    new("UIPadding", {
        PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,16),
        PaddingRight = UDim.new(0,8), Parent = sc,
    })

    local btn = new("TextButton", {
        Size = UDim2.new(0,112,1,0),
        BackgroundColor3 = T.Row,
        Text = name, Font = Enum.Font.GothamSemibold, TextSize = 11,
        TextColor3 = T.Dim, AutoButtonColor = false, Parent = TabBar,
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

local TCombat = makeTab("⚔ Chiến Đấu")
local TMacro  = makeTab("🎬 Macro")
local TVisual = makeTab("👁 Hiển Thị")
local TMove   = makeTab("🚀 Di Chuyển")
local TMisc   = makeTab("⚙ Khác")

TCombat.Visible = true
Tabs["⚔ Chiến Đấu"].btn.BackgroundColor3 = T.Accent
Tabs["⚔ Chiến Đấu"].btn.TextColor3 = Color3.new(1,1,1)

-- ============ COMPONENT BUILDERS (UI PHẲNG - mọi thứ nằm trực tiếp trong ScrollingFrame) ============
local ORDER = 0
local function nextOrder() ORDER = ORDER + 1; return ORDER end

local function addSection(parent, text)
    return new("TextLabel", {
        Size = UDim2.new(1,0,0,22),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = nextOrder(), Parent = parent,
    })
end

local function addToggle(parent, text, default, cb)
    local row = new("Frame", {
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = T.Row, BorderSizePixel = 0,
        LayoutOrder = nextOrder(), Parent = parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,14,0,0),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
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
        BackgroundColor3 = Color3.new(1,1,1), Parent = pill,
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
    return {Set=function(_,v) st=v; paint() end, Get=function() return st end}
end

local function addSlider(parent, text, min, max, default, step, cb)
    local row = new("Frame", {
        Size = UDim2.new(1,0,0,50),
        BackgroundColor3 = T.Row, BorderSizePixel = 0,
        LayoutOrder = nextOrder(), Parent = parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(0.7,-20,0,16), Position = UDim2.new(0,14,0,6),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
    local val = new("TextLabel", {
        Size = UDim2.new(0.3,-14,0,16), Position = UDim2.new(0.7,0,0,6),
        BackgroundTransparency = 1, Text = tostring(default),
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
    })
    local track = new("Frame", {
        Size = UDim2.new(1,-28,0,5), Position = UDim2.new(0,14,0,36),
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
    return {Get=function() return cur end, Set=function(_,v) setV(v,false) end}
end

local function addDropdown(parent, text, default, options, cb)
    local row = new("Frame", {
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = T.Row, BorderSizePixel = 0,
        LayoutOrder = nextOrder(), Parent = parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size = UDim2.new(0.45,-14,1,0), Position = UDim2.new(0,14,0,0),
        BackgroundTransparency = 1, Text = text,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
    local btn = new("TextButton", {
        Size = UDim2.new(0.55,-14,1,-10), Position = UDim2.new(0.45,0,0,5),
        BackgroundColor3 = T.Card, Text = tostring(default),
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, AutoButtonColor = false,
        TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
    corner(btn, 6)
    local cur, idx = default, 1
    for i,v in ipairs(options) do if v==default then idx=i break end end
    btn.MouseButton1Click:Connect(function()
        if #options == 0 then return end
        idx = idx % #options + 1
        cur = options[idx]
        btn.Text = tostring(cur)
        if cb then pcall(cb, cur) end
    end)
    return {
        Get=function() return cur end,
        Set=function(_,v)
            cur=v; btn.Text=tostring(v)
            for i,o in ipairs(options) do if o==v then idx=i break end end
            if cb then pcall(cb,v) end
        end,
        SetOptions=function(_,newOpts,newVal)
            options = newOpts
            if newVal then cur=newVal; btn.Text=tostring(newVal) end
            for i,o in ipairs(options) do if o==cur then idx=i break end end
        end
    }
end

local function addButton(parent, text, color, cb)
    local b = new("TextButton", {
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = color or T.Accent, Text = text,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false,
        LayoutOrder = nextOrder(), Parent = parent,
    })
    corner(b, 8)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return b
end

-- ============ TAB: CHIẾN ĐẤU ============
addSection(TCombat, "🎯 AIMBOT")
addToggle(TCombat, "Bật Aimbot (tự lock địch)", Cfg.AimOn, function(v) Cfg.AimOn=v end)
addToggle(TCombat, "Luôn lock (không cần giữ phím)", Cfg.AimAlways, function(v) Cfg.AimAlways=v end)
addToggle(TCombat, "Kiểm tra đồng đội", Cfg.AimTeam, function(v) Cfg.AimTeam=v end)
addToggle(TCombat, "Chỉ lock khi nhìn thấy", Cfg.AimVisible, function(v) Cfg.AimVisible=v end)
addSlider(TCombat, "Độ mượt (0=cứng, 1=mượt)", 0, 1, Cfg.AimSmooth, 0.05, function(v) Cfg.AimSmooth=v end)
addSlider(TCombat, "Vùng FOV", 50, 800, Cfg.AimFOV, 10, function(v) Cfg.AimFOV=v end)
addDropdown(TCombat, "Bộ phận ngắm", Cfg.AimPart, {"Head","UpperTorso","HumanoidRootPart"}, function(v) Cfg.AimPart=v end)

addSection(TCombat, "⚔ ĐÁNH TỰ ĐỘNG")
addToggle(TCombat, "Auto M1 (tự click chuột)", Cfg.AttackOn, function(v) Cfg.AttackOn=v end)
addSlider(TCombat, "Tầm M1", 10, 40, Cfg.AttackRange, 1, function(v) Cfg.AttackRange=v end)

-- ============ TAB: MACRO ============
local macroRefresh = nil
do
    addSection(TMacro, "⚙ CẤU HÌNH")
    local names = {}
    for n in pairs(Macros) do table.insert(names, n) end
    table.sort(names)

    local combo = addDropdown(TMacro, "Macro đang dùng", ActiveMacro, names, function(v)
        ActiveMacro = v
        if macroRefresh then macroRefresh() end
    end)

    addSlider(TMacro, "Tầm chạy Macro", 10, 60, Cfg.MacroRange, 1, function(v) Cfg.MacroRange=v end)
    addToggle(TMacro, "Tự chạy khi gần địch", Cfg.MacroAuto, function(v) Cfg.MacroAuto=v end)

    addSection(TMacro, "🎬 ĐIỀU KHIỂN")
    addButton(TMacro, "▶  CHẠY MACRO NGAY", T.Green, function()
        runMacro()
    end)
    addButton(TMacro, "🛑  DỪNG MACRO", T.Red, function()
        macroRunning = false
        notify("Macro", "Đã dừng", 2)
    end)

    addSection(TMacro, "📋 QUẢN LÝ")
    local btnRow = new("Frame", {
        Size = UDim2.new(1,0,0,38),
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(), Parent = TMacro,
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
        Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1,
        LayoutOrder = nextOrder(), Parent = TMacro,
    })
    local newRowInner = new("Frame", {
        Size = UDim2.new(1,0,0,38), BackgroundColor3 = T.Row,
        BorderSizePixel = 0, Visible = false, Parent = newRow,
    })
    corner(newRowInner, 8)
    local tb = new("TextBox", {
        Size = UDim2.new(1,-84,1,-10), Position = UDim2.new(0,6,0,5),
        BackgroundColor3 = T.Card, PlaceholderText = "Tên macro mới...",
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = T.Text, Text = "", ClearTextOnFocus = false, Parent = newRowInner,
    }); corner(tb, 6)
    local okBtn = new("TextButton", {
        Size = UDim2.new(0,70,1,-10), Position = UDim2.new(1,-76,0,5),
        BackgroundColor3 = T.Green, Text = "Tạo",
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false, Parent = newRowInner,
    }); corner(okBtn, 6)

    mkBtn.MouseButton1Click:Connect(function()
        newRowInner.Visible = not newRowInner.Visible
    end)
    okBtn.MouseButton1Click:Connect(function()
        local name = tb.Text:gsub("^%s+",""):gsub("%s+$","")
        if name ~= "" and not Macros[name] then
            Macros[name] = {}
            ActiveMacro = name
            local nn = {}
            for n in pairs(Macros) do table.insert(nn, n) end
            table.sort(nn)
            combo:SetOptions(nn, name)
            tb.Text = ""; newRowInner.Visible = false
            if macroRefresh then macroRefresh() end
            notify("Macro", "Đã tạo: "..name, 3)
        else
            notify("Macro", "Tên trống hoặc đã tồn tại!", 3)
        end
    end)
    delBtn.MouseButton1Click:Connect(function()
        if ActiveMacro and Macros[ActiveMacro] and #names > 1 then
            Macros[ActiveMacro] = nil
            local first = nil
            for n in pairs(Macros) do first = n break end
            ActiveMacro = first
            local nn = {}
            for n in pairs(Macros) do table.insert(nn, n) end
            table.sort(nn)
            combo:SetOptions(nn, ActiveMacro)
            if macroRefresh then macroRefresh() end
            notify("Macro", "Đã xóa", 3)
        else
            notify("Macro", "Không thể xóa macro cuối!", 3)
        end
    end)

    addSection(TMacro, "🎬 CÁC BƯỚC (giữ để sắp xếp)")
    addButton(TMacro, "+  THÊM BƯỚC MỚI", T.Green, function()
        addStepPopup()
    end)

    -- Danh sách bước
    local stepHolder = new("Frame", {
        Size = UDim2.new(1,0,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = nextOrder(), Parent = TMacro,
    })
    new("UIListLayout", {Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder, Parent=stepHolder})

    macroRefresh = function()
        for _,c in ipairs(stepHolder:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local steps = Macros[ActiveMacro] or {}
        for i, step in ipairs(steps) do
            local row = new("Frame", {
                Size = UDim2.new(1,0,0,34),
                BackgroundColor3 = T.Row, BorderSizePixel = 0,
                Parent = stepHolder,
            })
            corner(row, 6)
            new("TextLabel", {
                Size = UDim2.new(0,26,1,0), Position = UDim2.new(0,8,0,0),
                BackgroundTransparency = 1, Text = "#"..i,
                Font = Enum.Font.GothamBold, TextSize = 10,
                TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
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
                TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
            })
            new("TextLabel", {
                Size = UDim2.new(0,44,1,0), Position = UDim2.new(1,-110,0,0),
                BackgroundTransparency = 1, Text = string.format("%.2fs", step.delay or 0.08),
                Font = Enum.Font.Gotham, TextSize = 10,
                TextColor3 = T.Dim, TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
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
            miniBtn("↑", T.Accent2, function() if i>1 then steps[i],steps[i-1]=steps[i-1],steps[i]; macroRefresh() end end)
            miniBtn("↓", T.Accent2, function() if i<#steps then steps[i],steps[i+1]=steps[i+1],steps[i]; macroRefresh() end end)
            miniBtn("×", T.Red, function() table.remove(steps,i); macroRefresh() end)
        end
        if #steps == 0 then
            new("TextLabel", {
                Size = UDim2.new(1,0,0,26),
                BackgroundTransparency = 1, Text = "(Chưa có bước nào)",
                Font = Enum.Font.Gotham, TextSize = 11,
                TextColor3 = T.Dim, Parent = stepHolder,
            })
        end
    end

    macroRefresh()
end

-- Popup thêm bước (định nghĩa sau macroRefresh)
function addStepPopup()
    local existing = ScreenGui:FindFirstChild("StepPopup")
    if existing then existing:Destroy() end

    local pop = new("Frame", {
        Name = "StepPopup",
        Size = UDim2.new(0, 300, 0, 380),
        Position = UDim2.new(0.5, -150, 0.5, -190),
        BackgroundColor3 = T.Card, BorderSizePixel = 0,
        Active = true, Draggable = true,
        ZIndex = 50, Parent = ScreenGui,
    })
    corner(pop, 12); stroke(pop, T.Accent, 2)

    new("TextLabel", {
        Size = UDim2.new(1,0,0,34), Position = UDim2.new(0,12,0,4),
        BackgroundTransparency = 1, Text = "Chọn Bước Macro",
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 51, Parent = pop,
    })
    local closeB = new("TextButton", {
        Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-36,0,4),
        BackgroundColor3 = T.Red, Text = "×",
        Font = Enum.Font.GothamBold, TextSize = 16,
        TextColor3 = Color3.new(1,1,1), AutoButtonColor = false,
        ZIndex = 51, Parent = pop,
    }); corner(closeB, 6)
    closeB.MouseButton1Click:Connect(function() pop:Destroy() end)

    local sc = new("ScrollingFrame", {
        Size = UDim2.new(1,-16,1,-48), Position = UDim2.new(0,8,0,40),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 51, Parent = pop,
    })
    new("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, Parent=sc})

    local function addH(txt)
        new("TextLabel", {
            Size = UDim2.new(1,0,0,18),
            BackgroundTransparency = 1, Text = txt,
            Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52, Parent = sc,
        })
    end
    local function addO(label, data)
        local b = new("TextButton", {
            Size = UDim2.new(1,0,0,30),
            BackgroundColor3 = T.Row, Text = label,
            Font = Enum.Font.Gotham, TextSize = 11,
            TextColor3 = T.Text, AutoButtonColor = false,
            ZIndex = 52, Parent = sc,
        })
        corner(b, 6)
        b.MouseButton1Click:Connect(function()
            if ActiveMacro and Macros[ActiveMacro] then
                local s = {}
                for k,v in pairs(data) do s[k] = v end
                s.delay = s.delay or 0.08
                table.insert(Macros[ActiveMacro], s)
                if macroRefresh then macroRefresh() end
                pop:Destroy()
            end
        end)
    end

    addH("— VŨ KHÍ —")
    addO("Trang bị Võ (Melee)",  {type="weapon", value="Melee"})
    addO("Trang bị Kiếm (Sword)", {type="weapon", value="Sword"})
    addO("Trang bị Súng (Gun)",   {type="weapon", value="Gun"})
    addO("Trang bị Trái (Blox Fruit)", {type="weapon", value="Blox Fruit"})
    addH("— SKILL —")
    addO("Skill Z", {type="skill", value="Z"})
    addO("Skill X", {type="skill", value="X"})
    addO("Skill C", {type="skill", value="C"})
    addO("Skill V", {type="skill", value="V"})
    addO("Skill F", {type="skill", value="F"})
    addH("— KHÁC —")
    addO("M1 (Click chuột)", {type="m1", value=1})
    addO("Dash (W+W)", {type="dash", value="W"})
    addO("Chờ 0.1s", {type="wait", value=0.1})
    addO("Chờ 0.3s", {type="wait", value=0.3})
    addO("Chờ 0.5s", {type="wait", value=0.5})
end

-- ============ TAB: HIỂN THỊ ============
addSection(TVisual, "👁 ESP NGƯỜI CHƠI")
addToggle(TVisual, "Bật ESP", Cfg.ESPOn, function(v)
    Cfg.ESPOn = v
    refreshESP()
end)
addToggle(TVisual, "Kiểm tra đồng đội", Cfg.ESPTeam, function(v) Cfg.ESPTeam=v end)
addSlider(TVisual, "Khoảng cách tối đa", 500, 10000, Cfg.ESPMaxDist, 100, function(v)
    Cfg.ESPMaxDist = v
    for _,b in pairs(espCache) do pcall(function() b.MaxDistance=v end) end
end)

addSection(TVisual, "🌗 ÁNH SÁNG")
addToggle(TVisual, "Full Bright (sáng rõ ban đêm)", Cfg.FullBright, function(v)
    Cfg.FullBright = v
    applyFullBright(v)
end)

-- ============ TAB: DI CHUYỂN ============
addSection(TMove, "🚀 BAY")
addToggle(TMove, "Fly (Space lên, Ctrl xuống)", Cfg.Fly, function(v)
    Cfg.Fly = v
    applyFly(v)
end)
addSlider(TMove, "Tốc độ Fly", 20, 300, Cfg.FlySpeed, 5, function(v) Cfg.FlySpeed=v end)

addSection(TMove, "🏃 TỐC ĐỘ")
addSlider(TMove, "WalkSpeed", 16, 300, Cfg.Speed, 1, function(v)
    Cfg.Speed = v; applySpeed()
end)
addSlider(TMove, "JumpPower", 50, 500, Cfg.JumpPower, 5, function(v)
    Cfg.JumpPower = v; applyJump()
end)
addButton(TMove, "🔄 Reset tốc độ", T.Card, function()
    Cfg.Speed = 16; Cfg.JumpPower = 50
    applySpeed(); applyJump()
    notify("Reset", "Đã reset tốc độ", 3)
end)

addSection(TMove, "🌊 XUYÊN / NƯỚC")
addToggle(TMove, "Đi Trên Mặt Nước", Cfg.WalkWater, function(v)
    Cfg.WalkWater = v; applyWalkWater(v)
end)
addToggle(TMove, "No Clip (xuyên vật thể)", Cfg.NoClip, function(v)
    Cfg.NoClip = v; applyNoClip(v)
end)

addSection(TMove, "📍 DỊCH CHUYỂN NHANH")
addToggle(TMove, "Click chuột phải để bay đến", Cfg.TPMouse, function(v) Cfg.TPMouse=v end)

local plrDrop = addDropdown(TMove, "Chọn người chơi", "(Trống)", {"(Trống)"}, function() end)
addButton(TMove, "🔄 Refresh danh sách", T.Accent2, function()
    local names = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(names, p.Name) end
    end
    if #names == 0 then names = {"(Không có ai)"} end
    plrDrop:SetOptions(names, names[1])
end)
addButton(TMove, "📍 Bay tới người chơi đã chọn", T.Accent, function()
    local target = Players:FindFirstChild(plrDrop:Get())
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

-- ============ TAB: KHÁC ============
addSection(TMisc, "⚡ HIỆU NĂNG")
addToggle(TMisc, "Fix Lag (giảm đồ hoạ)", Cfg.FixLag, function(v)
    Cfg.FixLag = v; applyFixLag(v)
end)

addSection(TMisc, "🎮 HUD")
addToggle(TMisc, "Hiện HUD", Cfg.ShowHUD, function(v) Cfg.ShowHUD=v end)

addSection(TMisc, "🌐 SERVER")
addButton(TMisc, "Rejoin Server", T.Accent2, function()
    pcall(function() TPS:Teleport(game.PlaceId, LP) end)
end)
addButton(TMisc, "Server Hop", T.Accent, function()
    task.spawn(function()
        local ok = pcall(function()
            local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"
            local res = HS:JSONDecode(game:HttpGet(url))
            if res and res.data then
                for _, s in ipairs(res.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                        return
                    end
                end
            end
        end)
        if not ok then notify("Hop", "Không hop được", 3) end
    end)
end)

addSection(TMisc, "🛑 KHẨN CẤP")
addButton(TMisc, "⛔ TẮT TẤT CẢ", T.Red, function()
    Cfg.AimOn=false; Cfg.AttackOn=false; Cfg.MacroAuto=false
    Cfg.ESPOn=false; Cfg.FixLag=false; Cfg.WalkWater=false
    Cfg.NoClip=false; Cfg.Fly=false; Cfg.FullBright=false
    applyFixLag(false); applyNoClip(false); applyFly(false)
    applyWalkWater(false); applyFullBright(false)
    clearESP()
    notify("Dungdx PVP", "Đã tắt toàn bộ", 3)
end)

addSection(TMisc, "💬 DISCORD")
new("TextLabel", {
    Size = UDim2.new(1,0,0,24),
    BackgroundTransparency = 1,
    Text = "discord.gg/AJBT8F79yf",
    Font = Enum.Font.GothamBold, TextSize = 12,
    TextColor3 = T.Accent2, TextXAlignment = Enum.TextXAlignment.Center,
    LayoutOrder = nextOrder(), Parent = TMisc,
})

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
        Name = "DungdxESP", Adornee = head,
        Size = UDim2.new(0,200,0,44),
        StudsOffset = Vector3.new(0,3.2,0),
        AlwaysOnTop = true, MaxDistance = Cfg.ESPMaxDist,
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
                local h = getHum(c)
                local myRoot = getRoot(LP.Character)
                local hRoot = getRoot(c)
                if h and myRoot and hRoot then
                    nameL.Text = plr.Name
                    distL.Text = "["..math.floor((myRoot.Position-hRoot.Position).Magnitude).." studs]"
                    hpFill.Size = UDim2.new(math.clamp(h.Health/h.MaxHealth,0,1),0,1,0)
                end
            end)
            task.wait(0.15)
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
                local c = cam()
                if not c then continue end
                local sp, onScreen = c:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(sp.X, sp.Y) - c.ViewportSize/2).Magnitude
                    if dist < closestDist then
                        if Cfg.AimVisible then
                            local ray = Ray.new(myRoot.Position, (part.Position-myRoot.Position).Unit*(part.Position-myRoot.Position).Magnitude)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, char})
                            if hit and not hit:IsDescendantOf(char) then continue end
                        end
                        closestDist = dist
                        closest = {plr = plr, part = part}
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not Cfg.AimOn then return end
    if not Cfg.AimAlways then return end
    local c = cam()
    if not c then return end
    local tgt = getClosestTarget()
    if tgt then
        local goal = CFrame.new(c.CFrame.Position, tgt.part.Position)
        if Cfg.AimSmooth > 0 then
            c.CFrame = c.CFrame:Lerp(goal, 1 - Cfg.AimSmooth)
        else
            c.CFrame = goal
        end
    end
end)

-- ============ AUTO M1 ============
task.spawn(function()
    while task.wait(0.1) do
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
                        task.wait(0.03)
                        VIM:SendMouseButtonEvent(0,0,0,false,game,1)
                    end)
                    break
                end
            end
        end
    end
end)

-- ============ MACRO RUNNER ============
macroRunning = false

local function equipWeapon(tooltip)
    local char = LP.Character
    local backpack = LP:FindFirstChild("Backpack")
    if not char or not backpack then return end
    local current = char:FindFirstChildOfClass("Tool")
    if current and current.ToolTip == tooltip then return end
    for _,tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == tooltip then
            local h = getHum(char)
            if h then pcall(function() h:EquipTool(tool) end); task.wait(0.05); return end
        end
    end
    if tooltip == "Blox Fruit" then
        for _,tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool:FindFirstChild("LeftClickRemote") or tool:GetAttribute("IsBloxFruit")) then
                local h = getHum(char)
                if h then pcall(function() h:EquipTool(tool) end); task.wait(0.05); return end
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
                if step.type == "weapon" then
                    equipWeapon(step.value)
                elseif step.type == "skill" then
                    local k = Enum.KeyCode[step.value]
                    if k then
                        VIM:SendKeyEvent(true, k, false, game)
                        task.wait(0.03)
                        VIM:SendKeyEvent(false, k, false, game)
                    end
                elseif step.type == "m1" then
                    VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                    task.wait(0.03)
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

-- Auto macro khi địch gần
task.spawn(function()
    while task.wait(0.15) do
        if not Cfg.MacroAuto then continue end
        if macroRunning then continue end
        local myRoot = getRoot(LP.Character)
        if not myRoot then continue end
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
end)

-- ============ FIX LAG ============
local fixLagThread = nil
local origLag = {}
function applyFixLag(on)
    if on then
        origLag.Shadows = LG.GlobalShadows
        origLag.FogEnd = LG.FogEnd
        origLag.Quality = settings().Rendering.QualityLevel
        LG.GlobalShadows = false
        LG.FogEnd = 9e9
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        for _,d in ipairs(LG:GetDescendants()) do
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
        if fixLagThread then pcall(function() task.cancel(fixLagThread) end) end
        fixLagThread = task.spawn(function()
            while Cfg.FixLag do
                pcall(function()
                    for _,obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                            or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                            obj.Enabled = false
                        end
                    end
                end)
                task.wait(3)
            end
        end)
        notify("Fix Lag", "Đã BẬT giảm lag", 3)
    else
        pcall(function()
            LG.GlobalShadows = origLag.Shadows or true
            LG.FogEnd = origLag.FogEnd or 100000
            settings().Rendering.QualityLevel = origLag.Quality or Enum.QualityLevel.Automatic
        end)
        for _,d in ipairs(LG:GetDescendants()) do
            if d:IsA("BlurEffect") or d:IsA("SunRaysEffect") or d:IsA("ColorCorrectionEffect")
                or d:IsA("BloomEffect") or d:IsA("DepthOfFieldEffect") then
                pcall(function() d.Enabled = true end)
            end
        end
        if fixLagThread then pcall(function() task.cancel(fixLagThread) end); fixLagThread = nil end
        notify("Fix Lag", "Đã TẮT giảm lag", 3)
    end
end

-- ============ WALK ON WATER ============
local waterThread = nil
function applyWalkWater(on)
    if waterThread then pcall(function() task.cancel(waterThread) end); waterThread = nil end
    if not on then
        local hrp = getRoot(LP.Character)
        if hrp and hrp:FindFirstChild("DungdxPlat") then hrp.DungdxPlat:Destroy() end
        return
    end
    waterThread = task.spawn(function()
        while Cfg.WalkWater do
            pcall(function()
                local hrp = getRoot(LP.Character)
                if hrp then
                    local plat = hrp:FindFirstChild("DungdxPlat")
                    if not plat then
                        plat = Instance.new("Part")
                        plat.Name = "DungdxPlat"
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
local flyConn = nil
function applyFly(on)
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local char = LP.Character
    local hrp = getRoot(char)
    if hrp then
        local oldBV = hrp:FindFirstChild("DungdxFlyBV")
        local oldBG = hrp:FindFirstChild("DungdxFlyBG")
        if oldBV then oldBV:Destroy() end
        if oldBG then oldBG:Destroy() end
    end
    if not on then return end

    flyConn = RunService.RenderStepped:Connect(function()
        if not Cfg.Fly then return end
        local c = cam()
        local hrp = getRoot(LP.Character)
        if not hrp or not c then return end

        local bv = hrp:FindFirstChild("DungdxFlyBV")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "DungdxFlyBV"
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.zero
            bv.P = 1e4
            bv.Parent = hrp
        end
        local bg = hrp:FindFirstChild("DungdxFlyBG")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name = "DungdxFlyBG"
            bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bg.P = 1e4; bg.D = 1e2
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
        end

        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + c.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - c.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - c.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + c.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl) then
            dir = dir - Vector3.new(0,1,0)
        end

        bv.Velocity = dir.Magnitude > 0 and dir.Unit * Cfg.FlySpeed or Vector3.zero
        bg.CFrame = c.CFrame
    end)
end

-- ============ SPEED / JUMP ============
function applySpeed()
    local h = getHum(LP.Character)
    if h then h.WalkSpeed = Cfg.Speed end
end
function applyJump()
    local h = getHum(LP.Character)
    if h then h.UseJumpPower = true; h.JumpPower = Cfg.JumpPower end
end

-- ============ FULL BRIGHT ============
local origBright = nil
function applyFullBright(on)
    if on then
        origBright = {A = LG.Ambient, O = LG.OutdoorAmbient, B = LG.Brightness, T = LG.ClockTime}
        LG.Ambient = Color3.fromRGB(178,178,178)
        LG.OutdoorAmbient = Color3.fromRGB(178,178,178)
        LG.Brightness = 3
        LG.ClockTime = 14
    else
        if origBright then
            LG.Ambient = origBright.A
            LG.OutdoorAmbient = origBright.O
            LG.Brightness = origBright.B
            LG.ClockTime = origBright.T
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
        VU:CaptureController()
        VU:ClickButton2(Vector2.new(0,0))
    end)
end)

-- ============ CHARACTER RESPAWN ============
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if Cfg.NoClip then applyNoClip(true) end
    if Cfg.Fly then applyFly(true) end
    if Cfg.WalkWater then applyWalkWater(true) end
    applySpeed(); applyJump()
end)

-- ============ HUD ============
local hud = new("TextLabel", {
    Size = UDim2.new(0,600,0,18),
    Position = UDim2.new(0,20,1,-28),
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
    hud.Text = string.format("[DUNGDX v5] Aim:%s M1:%s Macro:%s ESP:%s Fly:%s NoClip:%s Water:%s Lag:%s | Địch:%d",
        Cfg.AimOn and "ON" or "--", Cfg.AttackOn and "ON" or "--",
        Cfg.MacroAuto and "ON" or "--", Cfg.ESPOn and "ON" or "--",
        Cfg.Fly and "ON" or "--", Cfg.NoClip and "ON" or "--",
        Cfg.WalkWater and "ON" or "--", Cfg.FixLag and "ON" or "--", cnt)
end)

-- ============ INIT ============
refreshESP()
applySpeed()
applyJump()

task.wait(1)
notify("Dungdx PVP v5", "Đã load thành công!", 4)
notify("Mẹo mobile", "Bật Aimbot, nhấn Always=ON để tự lock mà không cần giữ phím", 8)

print("[Dungdx PVP v5] Loaded successfully.")