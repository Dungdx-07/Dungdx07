--[[
    DUNGDX PVP v8 — Blox Fruit
    Thêm: Hitbox Player/NPC riêng + Tracer đỏ
    Discord: https://discord.gg/AJBT8F79yf
]]--

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
    AimOn=false, AimMode="Player gần nhất", AimTargetName="", AimAlways=true,
    AimTeam=true, AimVisible=false, AimSmooth=0.35, AimFOV=350, AimPart="Head",
    -- Auto attack
    AttackOn=false, AttackRange=25, AttackMobs=false,
    -- Macro
    MacroAuto=false, MacroRange=30,
    -- ESP
    ESPOn=false, ESPTeam=true, ESPMaxDist=3000,
    -- Hitbox / Tracer (MỚI)
    HitboxPlayer=false, HitboxNPC=false, HitboxTransparency=0.5,
    TracerOn=false, TracerMaxDist=2000, TracerThickness=2,
    -- Misc
    ShowHUD=true, FixLag=false, NoFog=false, WalkWater=false, NoClip=false,
    Fly=false, FlySpeed=50, Speed=16, JumpPower=50, FullBright=false, TPMouse=false,
}

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

-- ============ SAVE / LOAD ============
local SAVE_FILE = "DungdxPvP_Config.json"
local function canSave() return type(writefile) == "function" and type(readfile) == "function" end
local function loadConfig()
    if not canSave() then return false end
    if type(isfile) == "function" and not isfile(SAVE_FILE) then return false end
    local ok, raw = pcall(readfile, SAVE_FILE)
    if not ok or not raw or raw == "" then return false end
    local ok2, data = pcall(function() return HS:JSONDecode(raw) end)
    if not ok2 or type(data) ~= "table" then return false end
    if type(data.Cfg) == "table" then for k,v in pairs(data.Cfg) do if Cfg[k] ~= nil then Cfg[k] = v end end end
    if type(data.Macros) == "table" then for name, steps in pairs(data.Macros) do if type(steps) == "table" then Macros[name] = steps end end end
    if type(data.ActiveMacro) == "string" and Macros[data.ActiveMacro] then ActiveMacro = data.ActiveMacro end
    return true
end
local function saveConfig()
    if not canSave() then return end
    pcall(function()
        writefile(SAVE_FILE, HS:JSONEncode({Cfg=Cfg, Macros=Macros, ActiveMacro=ActiveMacro}))
    end)
end
local loadedFromFile = loadConfig()

-- ============ THEME ============
local T = {
    Bg=Color3.fromRGB(12,10,14), Card=Color3.fromRGB(22,18,22), Row=Color3.fromRGB(32,24,30),
    Neon=Color3.fromRGB(255,45,70), Neon2=Color3.fromRGB(255,100,130), NeonGlow=Color3.fromRGB(255,30,60),
    OrangeRed=Color3.fromRGB(255,100,30), OrangeGlow=Color3.fromRGB(255,150,60),
    Text=Color3.fromRGB(240,235,240), Dim=Color3.fromRGB(160,150,160),
    Green=Color3.fromRGB(80,220,120), Red=Color3.fromRGB(230,60,60), Orange=Color3.fromRGB(255,170,60),
}

local function new(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end
local function corner(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p}) end
local function stroke(p,c,t,tr) return new("UIStroke",{Color=c or T.Neon,Thickness=t or 1,Transparency=tr or 0,Parent=p}) end
local function notify(title, text, dur)
    pcall(function() SG:SetCore("SendNotification", {Title=title, Text=text, Duration=dur or 4}) end)
end
local function isAlly(plr)
    if plr == LP then return true end
    if not Cfg.AimTeam then return false end
    if plr.Team and LP.Team and plr.Team == LP.Team then return true end
    local a = LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Bounty/Honor")
    local b = plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Bounty/Honor")
    if a and b and a.Value==0 and b.Value==0 then return true end
    return false
end
local function alive(plr)
    local c = plr.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return c and h and h.Health>0
end
local function getRoot(char) return char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart) end
local function getHum(char) return char and char:FindFirstChildOfClass("Humanoid") end
local function cam() return workspace.CurrentCamera end
local function neonBorder(frame, color, glow)
    stroke(frame, color or T.Neon, 2)
    stroke(frame, glow or T.NeonGlow, 8, 0.75)
end

-- ============ SCREEN GUI ============
local ScreenGui = new("ScreenGui", {
    Name="DungdxPvP", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    Parent=LP:WaitForChild("PlayerGui"),
})

-- ============ MAIN WINDOW ============
local Main = new("Frame", {
    Name="Main", Size=UDim2.new(0,480,0,520),
    Position=UDim2.new(0.5,-240,0.5,-260),
    BackgroundColor3=T.Bg, BorderSizePixel=0,
    Active=true, Draggable=true, Parent=ScreenGui,
})
corner(Main, 14); neonBorder(Main)

local uiScale = new("UIScale", {Parent=Main})
local function fitUI()
    local c = cam()
    local vp = c and c.ViewportSize or Vector2.new(1000,700)
    uiScale.Scale = math.clamp(math.min((vp.X-40)/480, (vp.Y-90)/520), 0.6, 1)
end
fitUI()
if cam() then cam():GetPropertyChangedSignal("ViewportSize"):Connect(fitUI) end

local Header = new("Frame", {
    Size=UDim2.new(1,0,0,52), BackgroundColor3=T.Card,
    BorderSizePixel=0, Parent=Main,
})
corner(Header, 14)
new("TextLabel", {
    Size=UDim2.new(1,-60,0,20), Position=UDim2.new(0,18,0,8),
    BackgroundTransparency=1, Text="DUNGDX PVP  v8",
    Font=Enum.Font.GothamBold, TextSize=15,
    TextColor3=T.Neon, TextXAlignment=Enum.TextXAlignment.Left, Parent=Header,
})
new("TextLabel", {
    Size=UDim2.new(1,-60,0,14), Position=UDim2.new(0,18,0,30),
    BackgroundTransparency=1, Text="Blox Fruit • Hitbox + Tracer Edition",
    Font=Enum.Font.Gotham, TextSize=10,
    TextColor3=T.Dim, TextXAlignment=Enum.TextXAlignment.Left, Parent=Header,
})
local CloseBtn = new("TextButton", {
    Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-40,0,11),
    BackgroundColor3=T.Red, Text="×",
    Font=Enum.Font.GothamBold, TextSize=18,
    TextColor3=Color3.new(1,1,1), AutoButtonColor=false, Parent=Header,
})
corner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible=false end)

local TabBar = new("Frame", {
    Size=UDim2.new(1,-24,0,34), Position=UDim2.new(0,12,0,62),
    BackgroundTransparency=1, Parent=Main,
})
new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5), Parent=TabBar})

local Content = new("Frame", {
    Size=UDim2.new(1,-24,1,-112), Position=UDim2.new(0,12,0,104),
    BackgroundTransparency=1, Parent=Main,
})

-- ============ FAB DX ============
local FAB = new("TextButton", {
    Size=UDim2.new(0,54,0,54), Position=UDim2.new(0,20,0.5,-27),
    BackgroundColor3=T.Card, Text="DX",
    Font=Enum.Font.GothamBlack, TextSize=18,
    TextColor3=T.OrangeRed, AutoButtonColor=false,
    Draggable=true, Parent=ScreenGui,
})
corner(FAB, 999); neonBorder(FAB, T.OrangeRed, T.OrangeGlow)
FAB.MouseButton1Click:Connect(function() Main.Visible=not Main.Visible end)

-- ============ FAB MACRO ============
local MacroFAB = new("TextButton", {
    Size=UDim2.new(0,54,0,54), Position=UDim2.new(0,20,0.5,35),
    BackgroundColor3=T.Card, Text="MC",
    Font=Enum.Font.GothamBlack, TextSize=14,
    TextColor3=T.Green, AutoButtonColor=false,
    Draggable=true, Parent=ScreenGui,
})
corner(MacroFAB, 999); neonBorder(MacroFAB, T.Green, T.Green)
MacroFAB.MouseButton1Click:Connect(function()
    if macroRunning then macroRunning=false; notify("Macro", "Đã DỪNG", 2)
    else runMacro(); notify("Macro", "Đang chạy "..ActiveMacro, 2) end
end)

-- ============ TABS ============
local Tabs = {}
local function makeTab(name)
    local sc = new("ScrollingFrame", {
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=T.Neon,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        Visible=false, Parent=Content,
    })
    new("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, Parent=sc})
    new("UIPadding", {PaddingTop=UDim.new(0,4), PaddingBottom=UDim.new(0,16), PaddingRight=UDim.new(0,8), Parent=sc})

    local btn = new("TextButton", {
        Size=UDim2.new(0,112,1,0), BackgroundColor3=T.Row, Text=name,
        Font=Enum.Font.GothamSemibold, TextSize=11,
        TextColor3=T.Dim, AutoButtonColor=false, Parent=TabBar,
    })
    corner(btn, 8)
    btn.MouseButton1Click:Connect(function()
        for _,t in pairs(Tabs) do
            t.frame.Visible=false
            t.btn.BackgroundColor3=T.Row
            t.btn.TextColor3=T.Dim
            for _,s in ipairs(t.btn:GetChildren()) do if s:IsA("UIStroke") then s:Destroy() end end
        end
        sc.Visible=true
        btn.BackgroundColor3=T.Card
        btn.TextColor3=T.Neon
        stroke(btn, T.Neon, 1.5)
    end)
    Tabs[name] = {frame=sc, btn=btn}
    return sc
end

local TCombat = makeTab("⚔ Chiến Đấu")
local TMacro  = makeTab("🎬 Macro")
local TVisual = makeTab("👁 Hiển Thị")
local TMove   = makeTab("🚀 Di Chuyển")
local TMisc   = makeTab("⚙ Khác")

TCombat.Visible=true
Tabs["⚔ Chiến Đấu"].btn.BackgroundColor3=T.Card
Tabs["⚔ Chiến Đấu"].btn.TextColor3=T.Neon
stroke(Tabs["⚔ Chiến Đấu"].btn, T.Neon, 1.5)

-- ============ COMPONENTS ============
local ORDER=0
local function nextOrder() ORDER=ORDER+1; return ORDER end
local function addSection(parent, text)
    return new("TextLabel", {
        Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, Text=text,
        Font=Enum.Font.GothamBold, TextSize=11,
        TextColor3=T.Neon2, TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=nextOrder(), Parent=parent,
    })
end
local function addToggle(parent, text, default, cb)
    local row = new("Frame", {
        Size=UDim2.new(1,0,0,36), BackgroundColor3=T.Row,
        BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1, Text=text,
        Font=Enum.Font.Gotham, TextSize=12,
        TextColor3=T.Text, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, Parent=row,
    })
    local pill = new("TextButton", {
        Size=UDim2.new(0,46,0,22), Position=UDim2.new(1,-58,0,7),
        BackgroundColor3=default and T.Neon or Color3.fromRGB(60,50,55),
        Text="", AutoButtonColor=false, Parent=row,
    })
    corner(pill, 999)
    local knob = new("Frame", {
        Size=UDim2.new(0,18,0,18),
        Position=default and UDim2.new(1,-20,0,2) or UDim2.new(0,2,0,2),
        BackgroundColor3=Color3.new(1,1,1), Parent=pill,
    })
    corner(knob, 999)
    local st = default
    local function paint()
        if st then
            pill.BackgroundColor3=T.Neon
            TS:Create(knob, TweenInfo.new(0.15), {Position=UDim2.new(1,-20,0,2)}):Play()
        else
            pill.BackgroundColor3=Color3.fromRGB(60,50,55)
            TS:Create(knob, TweenInfo.new(0.15), {Position=UDim2.new(0,2,0,2)}):Play()
        end
    end
    pill.MouseButton1Click:Connect(function()
        st=not st; paint()
        if cb then pcall(cb, st) end
        saveConfig()
    end)
    return {Set=function(_,v) st=v; paint() end, Get=function() return st end}
end
local function addNumberBox(parent, text, default, min, max, cb)
    local row = new("Frame", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Row,
        BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size=UDim2.new(0.55,-14,1,0), Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1, Text=text,
        Font=Enum.Font.Gotham, TextSize=11,
        TextColor3=T.Text, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, Parent=row,
    })
    local tb = new("TextBox", {
        Size=UDim2.new(0.45,-14,1,-10), Position=UDim2.new(0.55,0,0,5),
        BackgroundColor3=T.Card, Text=tostring(default),
        Font=Enum.Font.GothamBold, TextSize=11,
        TextColor3=T.Neon, TextXAlignment=Enum.TextXAlignment.Center,
        ClearTextOnFocus=false, Parent=row,
    })
    corner(tb, 6); stroke(tb, T.Neon, 1)
    tb.FocusLost:Connect(function()
        local n = tonumber(tb.Text)
        if n then
            n = math.clamp(math.floor(n), min, max)
            tb.Text = tostring(n)
            if cb then pcall(cb, n) end
            saveConfig()
        else tb.Text = tostring(default) end
    end)
    return {Get=function() return tonumber(tb.Text) or default end}
end
local function addDropdown(parent, text, default, options, cb)
    local row = new("Frame", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Row,
        BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=parent,
    })
    corner(row, 8)
    new("TextLabel", {
        Size=UDim2.new(0.45,-14,1,0), Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1, Text=text,
        Font=Enum.Font.Gotham, TextSize=11,
        TextColor3=T.Text, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, Parent=row,
    })
    local btn = new("TextButton", {
        Size=UDim2.new(0.55,-14,1,-10), Position=UDim2.new(0.45,0,0,5),
        BackgroundColor3=T.Card, Text=tostring(default),
        Font=Enum.Font.Gotham, TextSize=11,
        TextColor3=T.Neon, AutoButtonColor=false,
        TextTruncate=Enum.TextTruncate.AtEnd, Parent=row,
    })
    corner(btn, 6); stroke(btn, T.Neon, 1)
    local cur, idx = default, 1
    for i,v in ipairs(options) do if v==default then idx=i break end end
    btn.MouseButton1Click:Connect(function()
        if #options==0 then return end
        idx = idx % #options + 1
        cur = options[idx]
        btn.Text = tostring(cur)
        if cb then pcall(cb, cur) end
        saveConfig()
    end)
    return {
        Get=function() return cur end,
        SetOptions=function(_,newOpts,newVal)
            options=newOpts
            if newVal then cur=newVal; btn.Text=tostring(newVal) end
            for i,o in ipairs(options) do if o==cur then idx=i break end end
        end
    }
end
local function addButton(parent, text, color, cb)
    local b = new("TextButton", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=color or T.Card, Text=text,
        Font=Enum.Font.GothamBold, TextSize=12,
        TextColor3=T.Neon, AutoButtonColor=false,
        LayoutOrder=nextOrder(), Parent=parent,
    })
    corner(b, 8); stroke(b, color or T.Neon, 1.5)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return b
end

-- ============ TAB: CHIẾN ĐẤU ============
addSection(TCombat, "🎯 AIMBOT")
addToggle(TCombat, "Bật Aimbot", Cfg.AimOn, function(v) Cfg.AimOn=v end)
addDropdown(TCombat, "Chế độ aim", Cfg.AimMode,
    {"NPC gần nhất", "Player gần nhất", "Player cụ thể"},
    function(v)
        Cfg.AimMode = v
        if selRow then selRow.Visible = (v == "Player cụ thể") end
    end)

local selRow = new("Frame", {
    Size=UDim2.new(1,0,0,0), BackgroundTransparency=1,
    LayoutOrder=nextOrder(), Parent=TCombat,
})
selRow.AutomaticSize = Enum.AutomaticSize.Y
new("UIListLayout", {Padding=UDim.new(0,6), Parent=selRow})
local selDrop = addDropdown(selRow, "Người chơi", Cfg.AimTargetName ~= "" and Cfg.AimTargetName or "(Trống)", {"(Trống)"}, function(v)
    Cfg.AimTargetName = v
end)
addButton(selRow, "🔄 Refresh danh sách", T.Card, function()
    local names = {}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(names, p.Name) end end
    if #names==0 then names={"(Không có ai)"} end
    selDrop:SetOptions(names, names[1])
    Cfg.AimTargetName = names[1]
    saveConfig()
end)
selRow.Visible = (Cfg.AimMode == "Player cụ thể")

addToggle(TCombat, "Luôn lock", Cfg.AimAlways, function(v) Cfg.AimAlways=v end)
addToggle(TCombat, "Kiểm tra đồng đội", Cfg.AimTeam, function(v) Cfg.AimTeam=v end)
addToggle(TCombat, "Chỉ lock khi nhìn thấy", Cfg.AimVisible, function(v) Cfg.AimVisible=v end)
addNumberBox(TCombat, "Độ mượt (0-100)", math.floor(Cfg.AimSmooth*100), 0, 100, function(v) Cfg.AimSmooth=v/100 end)
addNumberBox(TCombat, "Vùng FOV", Cfg.AimFOV, 50, 800, function(v) Cfg.AimFOV=v end)
addDropdown(TCombat, "Bộ phận ngắm", Cfg.AimPart, {"Head","UpperTorso","HumanoidRootPart"}, function(v) Cfg.AimPart=v end)

addSection(TCombat, "⚔ ĐÁNH TỰ ĐỘNG")
addToggle(TCombat, "Auto M1 (tự click chuột)", Cfg.AttackOn, function(v) Cfg.AttackOn=v end)
addToggle(TCombat, "Đánh cả quái (NPC)", Cfg.AttackMobs, function(v) Cfg.AttackMobs=v end)
addNumberBox(TCombat, "Tầm M1", Cfg.AttackRange, 10, 40, function(v) Cfg.AttackRange=v end)

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
    addNumberBox(TMacro, "Tầm chạy Macro", Cfg.MacroRange, 10, 60, function(v) Cfg.MacroRange=v end)
    addToggle(TMacro, "Tự chạy khi gần địch", Cfg.MacroAuto, function(v) Cfg.MacroAuto=v end)

    addSection(TMacro, "🎬 ĐIỀU KHIỂN")
    addButton(TMacro, "▶  CHẠY MACRO NGAY", T.Green, function() runMacro() end)
    addButton(TMacro, "🛑  DỪNG MACRO", T.Red, function() macroRunning=false; notify("Macro", "Đã dừng", 2) end)
    addButton(TMacro, "💾  LƯU CÀI ĐẶT", T.Card, function() saveConfig(); notify("Save", "Đã lưu", 3) end)

    addSection(TMacro, "📋 QUẢN LÝ")
    local btnRow = new("Frame", {Size=UDim2.new(1,0,0,38), BackgroundTransparency=1, LayoutOrder=nextOrder(), Parent=TMacro})
    new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,6), Parent=btnRow})
    local mkBtn = new("TextButton", {
        Size=UDim2.new(0.5,-3,1,0), BackgroundColor3=T.Card,
        Text="+ Tạo Macro", Font=Enum.Font.GothamBold, TextSize=11,
        TextColor3=T.Neon, AutoButtonColor=false, Parent=btnRow,
    }); corner(mkBtn, 8); stroke(mkBtn, T.Neon, 1.5)
    local delBtn = new("TextButton", {
        Size=UDim2.new(0.5,-3,1,0), BackgroundColor3=T.Card,
        Text="🗑 Xóa Macro", Font=Enum.Font.GothamBold, TextSize=11,
        TextColor3=T.Red, AutoButtonColor=false, Parent=btnRow,
    }); corner(delBtn, 8); stroke(delBtn, T.Red, 1.5)

    local newRow = new("Frame", {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, LayoutOrder=nextOrder(), Parent=TMacro})
    local newInner = new("Frame", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Row,
        BorderSizePixel=0, Visible=false, Parent=newRow,
    })
    corner(newInner, 8); stroke(newInner, T.Neon, 1)
    local tb = new("TextBox", {
        Size=UDim2.new(1,-84,1,-10), Position=UDim2.new(0,6,0,5),
        BackgroundColor3=T.Card, PlaceholderText="Tên macro mới...",
        Font=Enum.Font.Gotham, TextSize=11,
        TextColor3=T.Text, Text="", ClearTextOnFocus=false, Parent=newInner,
    }); corner(tb, 6)
    local okBtn = new("TextButton", {
        Size=UDim2.new(0,70,1,-10), Position=UDim2.new(1,-76,0,5),
        BackgroundColor3=T.Green, Text="Tạo",
        Font=Enum.Font.GothamBold, TextSize=11,
        TextColor3=Color3.new(1,1,1), AutoButtonColor=false, Parent=newInner,
    }); corner(okBtn, 6)

    mkBtn.MouseButton1Click:Connect(function() newInner.Visible = not newInner.Visible end)
    okBtn.MouseButton1Click:Connect(function()
        local name = tb.Text:gsub("^%s+",""):gsub("%s+$","")
        if name~="" and not Macros[name] then
            Macros[name]={}
            ActiveMacro=name
            local nn={}
            for n in pairs(Macros) do table.insert(nn,n) end
            table.sort(nn)
            combo:SetOptions(nn, name)
            tb.Text=""; newInner.Visible=false
            if macroRefresh then macroRefresh() end
            saveConfig()
            notify("Macro", "Đã tạo: "..name, 3)
        else notify("Macro", "Tên trống hoặc đã tồn tại!", 3) end
    end)
    delBtn.MouseButton1Click:Connect(function()
        local cnt = 0
        for _ in pairs(Macros) do cnt = cnt + 1 end
        if ActiveMacro and Macros[ActiveMacro] and cnt > 1 then
            Macros[ActiveMacro]=nil
            local first=nil
            for n in pairs(Macros) do first=n break end
            ActiveMacro=first
            local nn={}
            for n in pairs(Macros) do table.insert(nn,n) end
            table.sort(nn)
            combo:SetOptions(nn, ActiveMacro)
            if macroRefresh then macroRefresh() end
            saveConfig()
            notify("Macro", "Đã xóa", 3)
        else notify("Macro", "Không thể xóa macro cuối!", 3) end
    end)

    addSection(TMacro, "🎬 CÁC BƯỚC")
    addButton(TMacro, "+  THÊM BƯỚC MỚI", T.Green, function() addStepPopup() end)

    local stepHolder = new("Frame", {
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, LayoutOrder=nextOrder(), Parent=TMacro,
    })
    new("UIListLayout", {Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder, Parent=stepHolder})

    macroRefresh = function()
        for _,c in ipairs(stepHolder:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
        end
        local steps = Macros[ActiveMacro] or {}
        for i, step in ipairs(steps) do
            local row = new("Frame", {
                Size=UDim2.new(1,0,0,34), BackgroundColor3=T.Row,
                BorderSizePixel=0, Parent=stepHolder,
            })
            corner(row, 6); stroke(row, T.Neon, 0.8, 0.5)
            new("TextLabel", {
                Size=UDim2.new(0,26,1,0), Position=UDim2.new(0,8,0,0),
                BackgroundTransparency=1, Text="# "..i,
                Font=Enum.Font.GothamBold, TextSize=10,
                TextColor3=T.Neon2, TextXAlignment=Enum.TextXAlignment.Left, Parent=row,
            })
            local typeText, color = "?", T.Text
            if step.type=="skill" then typeText="Skill "..step.value; color=T.Orange
            elseif step.type=="weapon" then typeText="Trang bị "..step.value; color=T.Neon2
            elseif step.type=="m1" then typeText="M1 Click"; color=T.Text
            elseif step.type=="dash" then typeText="Dash"; color=T.Text
            elseif step.type=="wait" then typeText="Chờ "..step.value.."s"; color=T.Dim end
            new("TextLabel", {
                Size=UDim2.new(1,-130,1,0), Position=UDim2.new(0,36,0,0),
                BackgroundTransparency=1, Text=typeText,
                Font=Enum.Font.Gotham, TextSize=11,
                TextColor3=color, TextXAlignment=Enum.TextXAlignment.Left,
                TextTruncate=Enum.TextTruncate.AtEnd, Parent=row,
            })
            new("TextLabel", {
                Size=UDim2.new(0,44,1,0), Position=UDim2.new(1,-110,0,0),
                BackgroundTransparency=1, Text=string.format("%.2fs", step.delay or 0.08),
                Font=Enum.Font.Gotham, TextSize=10,
                TextColor3=T.Dim, TextXAlignment=Enum.TextXAlignment.Right, Parent=row,
            })
            local box = new("Frame", {
                Size=UDim2.new(0,62,1,-6), Position=UDim2.new(1,-66,0,3),
                BackgroundTransparency=1, Parent=row,
            })
            new("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,2), Parent=box})
            local function miniBtn(txt,col,cb)
                local b = new("TextButton", {
                    Size=UDim2.new(0,18,1,0), BackgroundColor3=T.Card, Text=txt,
                    Font=Enum.Font.GothamBold, TextSize=11,
                    TextColor3=col, AutoButtonColor=false, Parent=box,
                }); corner(b, 4)
                b.MouseButton1Click:Connect(cb)
            end
            miniBtn("↑", T.Neon2, function() if i>1 then steps[i],steps[i-1]=steps[i-1],steps[i]; macroRefresh(); saveConfig() end end)
            miniBtn("↓", T.Neon2, function() if i<#steps then steps[i],steps[i+1]=steps[i+1],steps[i]; macroRefresh(); saveConfig() end end)
            miniBtn("×", T.Red, function() table.remove(steps,i); macroRefresh(); saveConfig() end)
        end
        if #steps==0 then
            new("TextLabel", {
                Size=UDim2.new(1,0,0,26), BackgroundTransparency=1,
                Text="(Chưa có bước nào)", Font=Enum.Font.Gotham, TextSize=11,
                TextColor3=T.Dim, Parent=stepHolder,
            })
        end
    end
    macroRefresh()
end

-- ============ POPUP THÊM BƯỚC ============
function addStepPopup()
    local existing = ScreenGui:FindFirstChild("StepPopup")
    if existing then existing:Destroy() end
    local pop = new("Frame", {
        Name="StepPopup", Size=UDim2.new(0,300,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        Position=UDim2.new(0.5,-150,0.5,-260),
        BackgroundColor3=T.Card, BorderSizePixel=0,
        Active=true, Draggable=true, ZIndex=100, Parent=ScreenGui,
    })
    corner(pop, 12); neonBorder(pop)
    local body = new("Frame", {
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, ZIndex=101, Parent=pop,
    })
    new("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, Parent=body})
    new("UIPadding", {
        PaddingTop=UDim.new(0,40), PaddingBottom=UDim.new(0,10),
        PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10), Parent=body,
    })
    new("TextLabel", {
        Size=UDim2.new(1,0,0,30), Position=UDim2.new(0,12,0,6),
        BackgroundTransparency=1, Text="Chọn Bước Macro",
        Font=Enum.Font.GothamBold, TextSize=13,
        TextColor3=T.Neon, TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=102, Parent=pop,
    })
    local closeB = new("TextButton", {
        Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-34,0,6),
        BackgroundColor3=T.Red, Text="×",
        Font=Enum.Font.GothamBold, TextSize=16,
        TextColor3=Color3.new(1,1,1), AutoButtonColor=false,
        ZIndex=102, Parent=pop,
    }); corner(closeB, 6)
    closeB.MouseButton1Click:Connect(function() pop:Destroy() end)
    local function addH(txt)
        new("TextLabel", {
            Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text=txt,
            Font=Enum.Font.GothamBold, TextSize=10,
            TextColor3=T.Neon2, TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=102, Parent=body,
        })
    end
    local function addO(label, data)
        local b = new("TextButton", {
            Size=UDim2.new(1,0,0,30), BackgroundColor3=T.Row, Text=label,
            Font=Enum.Font.Gotham, TextSize=11,
            TextColor3=T.Text, AutoButtonColor=false,
            ZIndex=102, Parent=body,
        })
        corner(b, 6)
        b.MouseButton1Click:Connect(function()
            if ActiveMacro and Macros[ActiveMacro] then
                local s = {}
                for k,v in pairs(data) do s[k] = v end
                s.delay = s.delay or 0.08
                table.insert(Macros[ActiveMacro], s)
                if macroRefresh then macroRefresh() end
                saveConfig()
                pop:Destroy()
                notify("Macro", "Đã thêm: "..label, 2)
            end
        end)
    end
    addH("— VŨ KHÍ —")
    addO("Trang bị Võ (Melee)",   {type="weapon", value="Melee"})
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
addSection(TVisual, "👁 ESP")
addToggle(TVisual, "Bật ESP", Cfg.ESPOn, function(v) Cfg.ESPOn=v; refreshESP() end)
addToggle(TVisual, "Kiểm tra đồng đội", Cfg.ESPTeam, function(v) Cfg.ESPTeam=v end)
addNumberBox(TVisual, "Khoảng cách ESP", Cfg.ESPMaxDist, 500, 10000, function(v)
    Cfg.ESPMaxDist = v
    for _,b in pairs(espCache) do pcall(function() b.MaxDistance=v end) end
end)

-- ========== MỚI: HITBOX ==========
addSection(TVisual, "📦 HITBOX (khung quanh nhân vật)")
addToggle(TVisual, "Hitbox Người Chơi", Cfg.HitboxPlayer, function(v)
    Cfg.HitboxPlayer = v
    refreshHitbox()
end)
addToggle(TVisual, "Hitbox Quái (NPC)", Cfg.HitboxNPC, function(v)
    Cfg.HitboxNPC = v
    refreshHitbox()
end)
addNumberBox(TVisual, "Độ trong suốt (0-100)", math.floor(Cfg.HitboxTransparency*100), 0, 100, function(v)
    Cfg.HitboxTransparency = v/100
    for _, box in pairs(hitboxCache) do
        pcall(function() box.Transparency = Cfg.HitboxTransparency end)
    end
end)

-- ========== MỚI: TRACER ==========
addSection(TVisual, "📡 TRACER (đường đỏ tới địch)")
addToggle(TVisual, "Bật Tracer", Cfg.TracerOn, function(v) Cfg.TracerOn = v end)
addNumberBox(TVisual, "Tầm Tracer", Cfg.TracerMaxDist, 100, 5000, function(v) Cfg.TracerMaxDist = v end)
addNumberBox(TVisual, "Độ dày (px)", Cfg.TracerThickness, 1, 6, function(v) Cfg.TracerThickness = v end)

addSection(TVisual, "🌗 ÁNH SÁNG")
addToggle(TVisual, "Full Bright (sáng rõ ban đêm)", Cfg.FullBright, function(v) Cfg.FullBright=v; applyFullBright(v) end)

-- ============ TAB: DI CHUYỂN ============
addSection(TMove, "🚀 BAY")
addToggle(TMove, "Fly (Space lên, Ctrl xuống)", Cfg.Fly, function(v) Cfg.Fly=v; applyFly(v) end)
addNumberBox(TMove, "Tốc độ Fly", Cfg.FlySpeed, 20, 300, function(v) Cfg.FlySpeed=v end)
addSection(TMove, "🏃 TỐC ĐỘ")
addNumberBox(TMove, "WalkSpeed", Cfg.Speed, 16, 300, function(v) Cfg.Speed=v; applySpeed() end)
addNumberBox(TMove, "JumpPower", Cfg.JumpPower, 50, 500, function(v) Cfg.JumpPower=v; applyJump() end)
addButton(TMove, "🔄 Reset tốc độ", T.Card, function()
    Cfg.Speed=16; Cfg.JumpPower=50
    applySpeed(); applyJump(); saveConfig()
    notify("Reset", "Đã reset tốc độ", 3)
end)
addSection(TMove, "🌊 XUYÊN / NƯỚC")
addToggle(TMove, "Đi Trên Mặt Nước", Cfg.WalkWater, function(v) Cfg.WalkWater=v; applyWalkWater(v) end)
addToggle(TMove, "No Clip (xuyên vật thể)", Cfg.NoClip, function(v) Cfg.NoClip=v; applyNoClip(v) end)
addSection(TMove, "📍 DỊCH CHUYỂN NHANH")
addToggle(TMove, "Click chuột phải để bay đến", Cfg.TPMouse, function(v) Cfg.TPMouse=v end)

-- ============ TAB: KHÁC ============
addSection(TMisc, "⚡ HIỆU NĂNG")
addToggle(TMisc, "Fix Lag (giảm hiệu ứng chiêu)", Cfg.FixLag, function(v) Cfg.FixLag=v; applyFixLag(v) end)
addToggle(TMisc, "Xóa Sương Mù", Cfg.NoFog, function(v) Cfg.NoFog=v; applyNoFog(v) end)
addButton(TMisc, "🔄 Khôi phục ánh sáng gốc", T.Card, function()
    restoreLighting(); notify("Lighting", "Đã khôi phục ánh sáng gốc", 3)
end)
addSection(TMisc, "🎮 HUD")
addToggle(TMisc, "Hiện HUD", Cfg.ShowHUD, function(v) Cfg.ShowHUD=v end)
addSection(TMisc, "💾 LƯU CẤU HÌNH")
addButton(TMisc, "💾  LƯU NGAY", T.Card, function() saveConfig(); notify("Save", "Đã lưu: "..SAVE_FILE, 3) end)
addButton(TMisc, "📂  LOAD LẠI", T.Card, function()
    if loadConfig() then notify("Load", "Đã tải. Restart script để áp dụng.", 4)
    else notify("Load", "Không tìm thấy file save", 3) end
end)
addButton(TMisc, "🗑  XÓA FILE SAVE", T.Red, function()
    if canSave() and type(delfile) == "function" then pcall(delfile, SAVE_FILE); notify("Save", "Đã xóa file save", 3) end
end)
addSection(TMisc, "🌐 SERVER")
addButton(TMisc, "Rejoin Server", T.Card, function() pcall(function() TPS:Teleport(game.PlaceId, LP) end) end)
addButton(TMisc, "Server Hop", T.Card, function()
    task.spawn(function()
        pcall(function()
            local res = HS:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
            if res and res.data then
                for _, s in ipairs(res.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LP); return
                    end
                end
            end
        end)
    end)
end)
addSection(TMisc, "🛑 KHẨN CẤP")
addButton(TMisc, "⛔ TẮT TẤT CẢ", T.Red, function()
    Cfg.AimOn=false; Cfg.AttackOn=false; Cfg.MacroAuto=false
    Cfg.ESPOn=false; Cfg.FixLag=false; Cfg.NoFog=false
    Cfg.WalkWater=false; Cfg.NoClip=false; Cfg.Fly=false; Cfg.FullBright=false
    Cfg.HitboxPlayer=false; Cfg.HitboxNPC=false; Cfg.TracerOn=false
    applyFixLag(false); applyNoFog(false); applyNoClip(false); applyFly(false)
    applyWalkWater(false); applyFullBright(false)
    clearESP(); refreshHitbox()
    -- xóa tracers
    for _, f in pairs(tracerFrames) do pcall(function() f:Destroy() end) end
    tracerFrames = {}
    saveConfig()
    notify("Dungdx PVP", "Đã tắt toàn bộ", 3)
end)
addSection(TMisc, "💬 DISCORD")
new("TextLabel", {
    Size=UDim2.new(1,0,0,24), BackgroundTransparency=1,
    Text="discord.gg/AJBT8F79yf",
    Font=Enum.Font.GothamBold, TextSize=12,
    TextColor3=T.Neon, TextXAlignment=Enum.TextXAlignment.Center,
    LayoutOrder=nextOrder(), Parent=TMisc,
})

-- ============ ESP ============
local espCache = {}
function clearESP()
    for k,v in pairs(espCache) do pcall(function() v:Destroy() end) end
    espCache = {}
end

local function createESP(plr)
    if plr==LP then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if espCache[plr] then return end
    local bb = new("BillboardGui", {
        Name="DungdxESP", Adornee=head,
        Size=UDim2.new(0,200,0,44), StudsOffset=Vector3.new(0,3.2,0),
        AlwaysOnTop=true, MaxDistance=Cfg.ESPMaxDist, Parent=head,
    })
    local nameL = new("TextLabel", {
        Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=T.Neon,
        TextStrokeTransparency=0.4, TextStrokeColor3=Color3.new(0,0,0),
        Text="", Parent=bb,
    })
    local distL = new("TextLabel", {
        Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,0,16),
        BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=10,
        TextColor3=Color3.fromRGB(255,200,200),
        TextStrokeTransparency=0.4, TextStrokeColor3=Color3.new(0,0,0),
        Text="", Parent=bb,
    })
    local hpBg = new("Frame", {
        Size=UDim2.new(0.7,0,0,4), Position=UDim2.new(0.15,0,0,32),
        BackgroundColor3=Color3.fromRGB(30,20,25),
        BorderSizePixel=0, Parent=bb,
    }); corner(hpBg, 999)
    local hpFill = new("Frame", {
        Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(80,220,120),
        BorderSizePixel=0, Parent=hpBg,
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
        if plr~=LP then
            createESP(plr)
            plr.CharacterAdded:Connect(function()
                task.wait(0.5)
                if Cfg.ESPOn then createESP(plr) end
            end)
        end
    end
end
Players.PlayerAdded:Connect(function(plr)
    if Cfg.ESPOn and plr~=LP then task.wait(1); createESP(plr) end
end)
Players.PlayerRemoving:Connect(function(plr)
    if espCache[plr] then pcall(function() espCache[plr]:Destroy() end); espCache[plr]=nil end
end)

-- ============ 🆕 HITBOX SYSTEM ============
local hitboxCache = {}   -- key: model/character → BoxHandleAdornment
local HITBOX_PLAYER_COLOR = Color3.fromRGB(255,60,60)   -- đỏ cho player
local HITBOX_NPC_COLOR    = Color3.fromRGB(255,150,40)  -- cam cho NPC

local function clearHitbox()
    for k, box in pairs(hitboxCache) do
        pcall(function() box:Destroy() end)
    end
    hitboxCache = {}
end

local function addHitbox(target, color)
    if not target then return end
    local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not root then return end
    if hitboxCache[target] and hitboxCache[target].Parent then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "DungdxHitbox"
    box.Adornee = root
    box.AlwaysOnTop = true
    box.ZIndex = 5
    -- size = to hơn root 1 chút cho đẹp
    local sz = root.Size
    box.Size = Vector3.new(sz.X + 0.6, sz.Y + 0.6, sz.Z + 0.6)
    box.Transparency = Cfg.HitboxTransparency
    box.Color3 = color
    box.Parent = root
    hitboxCache[target] = box
end

local function clearHitboxOf(target)
    if hitboxCache[target] then
        pcall(function() hitboxCache[target]:Destroy() end)
        hitboxCache[target] = nil
    end
end

function refreshHitbox()
    clearHitbox()
    -- Player
    if Cfg.HitboxPlayer then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                addHitbox(plr.Character, HITBOX_PLAYER_COLOR)
            end
        end
    end
    -- NPC
    if Cfg.HitboxNPC then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in ipairs(enemies:GetChildren()) do
                local hum = mob:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    addHitbox(mob, HITBOX_NPC_COLOR)
                end
            end
        end
    end
end

-- Player respawn → thêm lại hitbox
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if Cfg.HitboxPlayer then addHitbox(char, HITBOX_PLAYER_COLOR) end
    end)
end)
LP.CharacterAdded:Connect(function() task.wait(1); if Cfg.HitboxPlayer then refreshHitbox() end end)

-- NPC mới spawn → thêm hitbox
task.spawn(function()
    while task.wait(0.5) do
        if not Cfg.HitboxNPC then continue end
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in ipairs(enemies:GetChildren()) do
                if not hitboxCache[mob] then
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        addHitbox(mob, HITBOX_NPC_COLOR)
                    end
                end
            end
        end
    end
end)

-- ============ 🆕 TRACER SYSTEM ============
local TracerGui = new("ScreenGui", {
    Name = "DungdxTracer",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = LP:WaitForChild("PlayerGui"),
})

tracerFrames = {}
local tracerPool = {}
local TRACER_COLOR = Color3.fromRGB(255,30,30)   -- ĐỎ

local function getTracerFrame(i)
    if tracerPool[i] and tracerPool[i].Parent then return tracerPool[i] end
    local f = new("Frame", {
        Name = "Tracer_"..i,
        BackgroundColor3 = TRACER_COLOR,
        BorderSizePixel = 0,
        Visible = false,
        Parent = TracerGui,
    })
    f.AnchorPoint = Vector2.new(0, 0.5)
    new("UICorner", {CornerRadius=UDim.new(1,0), Parent=f})
    tracerPool[i] = f
    return f
end

RunService.RenderStepped:Connect(function()
    if not Cfg.TracerOn then
        for _, f in pairs(tracerPool) do
            if f.Parent then f.Visible = false end
        end
        return
    end
    local c = cam()
    if not c then return end
    local vp = c.ViewportSize
    local origin = Vector2.new(vp.X/2, vp.Y)   -- giữa dưới màn hình

    local idx = 0
    -- Thu thập player trong tầm
    local myRoot = getRoot(LP.Character)
    if not myRoot then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and alive(plr) and not isAlly(plr) then
            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            if root then
                local dist = (myRoot.Position - root.Position).Magnitude
                if dist <= Cfg.TracerMaxDist then
                    local sp, onScreen = c:WorldToViewportPoint(root.Position)
                    if onScreen then
                        idx = idx + 1
                        local f = getTracerFrame(idx)
                        local target = Vector2.new(sp.X, sp.Y)
                        local delta = target - origin
                        local length = delta.Magnitude
                        if length > 1 then
                            local angle = math.deg(math.atan2(delta.Y, delta.X))
                            f.Visible = true
                            f.BackgroundColor3 = TRACER_COLOR
                            f.Position = UDim2.fromOffset(origin.X, origin.Y)
                            f.Size = UDim2.fromOffset(length, Cfg.TracerThickness)
                            f.Rotation = angle
                        end
                    end
                end
            end
        end
    end
    -- Ẩn frame thừa
    for i = idx+1, #tracerPool do
        if tracerPool[i].Parent then tracerPool[i].Visible = false end
    end
end)

-- ============ AIMBOT 3 CHẾ ĐỘ ============
local function getPartOfPlayer(plr, partName)
    local c = plr.Character
    if not c then return nil end
    return c:FindFirstChild(partName) or c:FindFirstChild("HumanoidRootPart")
end

local function getNearestNPC()
    local c = cam()
    local myRoot = getRoot(LP.Character)
    if not c or not myRoot then return nil end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local closest, closestDist = nil, Cfg.AimFOV
    for _, mob in ipairs(enemies:GetChildren()) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if hum and hum.Health > 0 and root then
            local sp, onScreen = c:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(sp.X, sp.Y) - c.ViewportSize/2).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = {part = root, obj = mob, isNPC = true}
                end
            end
        end
    end
    return closest
end

local function getNearestPlayer()
    local c = cam()
    local myRoot = getRoot(LP.Character)
    if not c or not myRoot then return nil end
    local closest, closestDist = nil, Cfg.AimFOV
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and alive(plr) and not isAlly(plr) then
            local char = plr.Character
            local part = char:FindFirstChild(Cfg.AimPart) or char:FindFirstChild("HumanoidRootPart")
            if part then
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
                        closest = {part = part, obj = plr, isNPC = false}
                    end
                end
            end
        end
    end
    return closest
end

local function getSelectedPlayerTarget()
    if not Cfg.AimTargetName or Cfg.AimTargetName == "" or Cfg.AimTargetName == "(Trống)" then return nil end
    local plr = Players:FindFirstChild(Cfg.AimTargetName)
    if plr and plr ~= LP and alive(plr) and not isAlly(plr) then
        local part = getPartOfPlayer(plr, Cfg.AimPart)
        if part then return {part = part, obj = plr, isNPC = false} end
    end
    return nil
end

local function getTarget()
    if Cfg.AimMode == "NPC gần nhất" then return getNearestNPC()
    elseif Cfg.AimMode == "Player gần nhất" then return getNearestPlayer()
    elseif Cfg.AimMode == "Player cụ thể" then return getSelectedPlayerTarget() end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not Cfg.AimOn then return end
    if not Cfg.AimAlways then return end
    local c = cam()
    if not c then return end
    local tgt = getTarget()
    if tgt and tgt.part and tgt.part.Parent then
        local goal = CFrame.new(c.CFrame.Position, tgt.part.Position)
        if Cfg.AimSmooth > 0 then
            c.CFrame = c.CFrame:Lerp(goal, 1 - Cfg.AimSmooth)
        else c.CFrame = goal end
    end
end)

-- ============ AUTO M1 ============
task.spawn(function()
    while task.wait(0.1) do
        if not Cfg.AttackOn then continue end
        local myRoot = getRoot(LP.Character)
        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if not myRoot or not tool then continue end
        local attacked = false
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and alive(plr) and not isAlly(plr) then
                local hisRoot = getRoot(plr.Character)
                if hisRoot and (myRoot.Position-hisRoot.Position).Magnitude <= Cfg.AttackRange then
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(hisRoot.Position.X, myRoot.Position.Y, hisRoot.Position.Z))
                    attacked = true; break
                end
            end
        end
        if not attacked and Cfg.AttackMobs then
            local enemies = workspace:FindFirstChild("Enemies")
            if enemies then
                for _, mob in ipairs(enemies:GetChildren()) do
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                    if hum and hum.Health > 0 and root and (myRoot.Position-root.Position).Magnitude <= Cfg.AttackRange then
                        myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(root.Position.X, myRoot.Position.Y, root.Position.Z))
                        attacked = true; break
                    end
                end
            end
        end
        if attacked then
            pcall(function()
                VIM:SendMouseButtonEvent(0,0,0,true,game,1)
                task.wait(0.03)
                VIM:SendMouseButtonEvent(0,0,0,false,game,1)
            end)
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
    if not steps or #steps == 0 then notify("Macro", "Macro trống!", 3); return end
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

task.spawn(function()
    while task.wait(0.15) do
        if not Cfg.MacroAuto then continue end
        if macroRunning then continue end
        local myRoot = getRoot(LP.Character)
        if not myRoot then continue end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and alive(plr) and not isAlly(plr) then
                local hisRoot = getRoot(plr.Character)
                if hisRoot and (myRoot.Position-hisRoot.Position).Magnitude <= Cfg.MacroRange then
                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(hisRoot.Position.X, myRoot.Position.Y, hisRoot.Position.Z))
                    runMacro(); break
                end
            end
        end
    end
end)

-- ============ LIGHTING BACKUP ============
local lightingBackup = nil
local function backupLighting()
    if lightingBackup then return end
    lightingBackup = {
        Ambient = LG.Ambient, OutdoorAmbient = LG.OutdoorAmbient,
        Brightness = LG.Brightness, ClockTime = LG.ClockTime,
        GlobalShadows = LG.GlobalShadows,
        FogEnd = LG.FogEnd, FogStart = LG.FogStart, FogColor = LG.FogColor,
        ColorShift_Top = LG.ColorShift_Top, ColorShift_Bottom = LG.ColorShift_Bottom,
        ExposureCompensation = LG.ExposureCompensation,
        EnvironmentDiffuseScale = LG.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = LG.EnvironmentSpecularScale,
        Quality = settings().Rendering.QualityLevel,
    }
    local atm = LG:FindFirstChildOfClass("Atmosphere")
    if atm then
        lightingBackup.Atmosphere = {
            Instance = atm, Density = atm.Density, Offset = atm.Offset,
            Color = atm.Color, Decay = atm.Decay, Glare = atm.Glare, Haze = atm.Haze,
        }
    end
end

function restoreLighting()
    if not lightingBackup then return end
    pcall(function()
        LG.Ambient = lightingBackup.Ambient
        LG.OutdoorAmbient = lightingBackup.OutdoorAmbient
        LG.Brightness = lightingBackup.Brightness
        LG.ClockTime = lightingBackup.ClockTime
        LG.GlobalShadows = lightingBackup.GlobalShadows
        LG.FogEnd = lightingBackup.FogEnd
        LG.FogStart = lightingBackup.FogStart
        LG.FogColor = lightingBackup.FogColor
        LG.ColorShift_Top = lightingBackup.ColorShift_Top
        LG.ColorShift_Bottom = lightingBackup.ColorShift_Bottom
        LG.ExposureCompensation = lightingBackup.ExposureCompensation
        LG.EnvironmentDiffuseScale = lightingBackup.EnvironmentDiffuseScale
        LG.EnvironmentSpecularScale = lightingBackup.EnvironmentSpecularScale
        settings().Rendering.QualityLevel = lightingBackup.Quality
    end)
    if lightingBackup.Atmosphere and lightingBackup.Atmosphere.Instance then
        local atm = lightingBackup.Atmosphere
        pcall(function()
            if atm.Instance.Parent then
                atm.Instance.Density = atm.Density; atm.Instance.Offset = atm.Offset
                atm.Instance.Color = atm.Color; atm.Instance.Decay = atm.Decay
                atm.Instance.Glare = atm.Glare; atm.Instance.Haze = atm.Haze
            end
        end)
    end
end

-- ============ FIX LAG ============
local effectCleaner = nil
local hiddenEffects = {}

local function hideAllEffects()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local isEff = obj:IsA("ParticleEmitter") or obj:IsA("Trail")
            or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
        if isEff then
            if obj.Enabled then
                hiddenEffects[obj] = true
                obj.Enabled = false
            end
        end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("effect") or n:find("slash") or n:find("hiteffect")
                or n:find("explosion") or n:find("impact") or n:find("vfx") or n:find("beam") then
                obj.Transparency = 1
                obj.CanCollide = false
            end
        end
    end
end

local function showAllEffects()
    for obj in pairs(hiddenEffects) do
        if obj and obj.Parent then pcall(function() obj.Enabled = true end) end
    end
    hiddenEffects = {}
end

local function applyFixLag(on)
    if on then
        backupLighting()
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            LG.GlobalShadows = false
            LG.FogEnd = 100000
        end)
        for _, d in ipairs(LG:GetDescendants()) do
            if d:IsA("BlurEffect") or d:IsA("SunRaysEffect")
                or d:IsA("ColorCorrectionEffect") or d:IsA("BloomEffect")
                or d:IsA("DepthOfFieldEffect") then
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
        hideAllEffects()
        if effectCleaner then pcall(function() task.cancel(effectCleaner) end) end
        effectCleaner = task.spawn(function()
            while Cfg.FixLag do
                pcall(hideAllEffects)
                pcall(function()
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if obj.Name == "Debris" or obj.Name == "Effects" or obj.Name == "Effect" then
                            obj:ClearAllChildren()
                        end
                    end
                end)
                task.wait(1.5)
            end
        end)
        notify("Fix Lag", "Đã BẬT giảm lag + ẩn hiệu ứng chiêu", 3)
    else
        restoreLighting()
        showAllEffects()
        if effectCleaner then pcall(function() task.cancel(effectCleaner) end); effectCleaner = nil end
        notify("Fix Lag", "Đã TẮT", 3)
    end
end

-- ============ NO FOG ============
local origFog = nil
local function applyNoFog(on)
    if on then
        if not origFog then origFog = {FogEnd = LG.FogEnd, FogStart = LG.FogStart, FogColor = LG.FogColor} end
        LG.FogEnd = 100000
        LG.FogStart = 0
        LG.FogColor = Color3.fromRGB(200, 200, 255)
    else
        if origFog then
            LG.FogEnd = origFog.FogEnd
            LG.FogStart = origFog.FogStart
            LG.FogColor = origFog.FogColor
        end
    end
end

-- ============ WATER WALK ============
local waterConn = nil
function applyWalkWater(on)
    if waterConn then waterConn:Disconnect(); waterConn = nil end
    local hrp = getRoot(LP.Character)
    if hrp then local old = hrp:FindFirstChild("DungdxWaterBP"); if old then old:Destroy() end end
    if not on then return end
    waterConn = RunService.Heartbeat:Connect(function()
        if not Cfg.WalkWater then return end
        local hrp = getRoot(LP.Character)
        if not hrp then return end
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if not terrain then return end
        local ok, waterY = pcall(function() return terrain:GetWaterHeightAtPosition(hrp.Position) end)
        if not ok or not waterY or waterY == -math.huge or waterY == math.huge then return end
        local diff = hrp.Position.Y - waterY
        if math.abs(diff) > 20 then
            local old = hrp:FindFirstChild("DungdxWaterBP"); if old then old:Destroy() end
            return
        end
        local bp = hrp:FindFirstChild("DungdxWaterBP")
        if not bp then
            bp = Instance.new("BodyPosition")
            bp.Name = "DungdxWaterBP"
            bp.MaxForce = Vector3.new(0, math.huge, 0)
            bp.P = 1e5; bp.D = 1e3
            bp.Parent = hrp
        end
        local hum = getHum(LP.Character)
        local hipH = hum and hum.HipHeight or 2
        bp.Position = Vector3.new(hrp.Position.X, waterY + hipH + 0.5, hrp.Position.Z)
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
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
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
        local bv = hrp:FindFirstChild("DungdxFlyBV"); if bv then bv:Destroy() end
        local bg = hrp:FindFirstChild("DungdxFlyBG"); if bg then bg:Destroy() end
    end
    local hum = getHum(char)
    if hum then hum.PlatformStand = on end
    if not on then return end
    flyConn = RunService.RenderStepped:Connect(function()
        if not Cfg.Fly then return end
        local c = cam()
        local char = LP.Character
        local hrp = getRoot(char)
        local hum = getHum(char)
        if not hrp or not c then return end
        if hum and not hum.PlatformStand then hum.PlatformStand = true end
        local bv = hrp:FindFirstChild("DungdxFlyBV")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "DungdxFlyBV"
            bv.MaxForce = Vector3.new(1e6,1e6,1e6)
            bv.Velocity = Vector3.zero; bv.P = 1e5
            bv.Parent = hrp
        end
        local bg = hrp:FindFirstChild("DungdxFlyBG")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name = "DungdxFlyBG"
            bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
            bg.P = 1e4; bg.D = 1e3
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
local fullBrightBackup = nil
function applyFullBright(on)
    if on then
        if not fullBrightBackup then
            fullBrightBackup = {A=LG.Ambient, O=LG.OutdoorAmbient, B=LG.Brightness, T=LG.ClockTime}
        end
        LG.Ambient = Color3.fromRGB(178,178,178)
        LG.OutdoorAmbient = Color3.fromRGB(178,178,178)
        LG.Brightness = 3
        LG.ClockTime = 14
    else
        if fullBrightBackup then
            LG.Ambient = fullBrightBackup.A
            LG.OutdoorAmbient = fullBrightBackup.O
            LG.Brightness = fullBrightBackup.B
            LG.ClockTime = fullBrightBackup.T
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
            hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
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

-- ============ RESPAWN ============
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if Cfg.NoClip then applyNoClip(true) end
    if Cfg.Fly then applyFly(true) end
    if Cfg.WalkWater then applyWalkWater(true) end
    applySpeed(); applyJump()
    if Cfg.HitboxPlayer then refreshHitbox() end
end)

-- ============ HUD ============
local hud = new("TextLabel", {
    Size=UDim2.new(0,760,0,18), Position=UDim2.new(0,20,1,-28),
    BackgroundTransparency=1, Font=Enum.Font.Code, TextSize=11,
    TextColor3=T.Neon, TextStrokeTransparency=0.5,
    TextXAlignment=Enum.TextXAlignment.Left, Parent=ScreenGui,
})
RunService.RenderStepped:Connect(function()
    if not Cfg.ShowHUD then hud.Visible=false return end
    hud.Visible = true
    local myRoot = getRoot(LP.Character)
    local cnt = 0
    if myRoot then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and alive(plr) and not isAlly(plr) then
                local r = getRoot(plr.Character)
                if r and (myRoot.Position-r.Position).Magnitude <= Cfg.ESPMaxDist then cnt=cnt+1 end
            end
        end
    end
    hud.Text = string.format("[DX v8] Aim:%s M1:%s Macro:%s ESP:%s HB-P:%s HB-N:%s Trace:%s Fly:%s Water:%s Lag:%s | Địch:%d",
        Cfg.AimOn and "ON" or "--", Cfg.AttackOn and "ON" or "--",
        Cfg.MacroAuto and "ON" or "--", Cfg.ESPOn and "ON" or "--",
        Cfg.HitboxPlayer and "ON" or "--", Cfg.HitboxNPC and "ON" or "--",
        Cfg.TracerOn and "ON" or "--", Cfg.Fly and "ON" or "--",
        Cfg.WalkWater and "ON" or "--", Cfg.FixLag and "ON" or "--", cnt)
end)

-- ============ AUTO SAVE ============
task.spawn(function()
    while task.wait(20) do saveConfig() end
end)

-- ============ INIT ============
task.spawn(function()
    task.wait(1)
    if Cfg.ESPOn then refreshESP() end
    if Cfg.FixLag then applyFixLag(true) end
    if Cfg.NoFog then applyNoFog(true) end
    if Cfg.NoClip then applyNoClip(true) end
    if Cfg.Fly then applyFly(true) end
    if Cfg.WalkWater then applyWalkWater(true) end
    if Cfg.FullBright then applyFullBright(true) end
    if Cfg.HitboxPlayer or Cfg.HitboxNPC then refreshHitbox() end
    applySpeed(); applyJump()
end)

refreshESP()
applySpeed()
applyJump()

task.wait(0.5)
if loadedFromFile then notify("Dungdx PVP v8", "Đã load cài đặt từ file save!", 4)
else notify("Dungdx PVP v8", "Chưa có file save — cài đặt sẽ lưu khi bạn thay đổi", 5) end
notify("Đã thêm", "Hitbox Player/NPC + Tracer đỏ (tab Hiển Thị)", 6)
print("[Dungdx PVP v8] Loaded. Save: "..SAVE_FILE)