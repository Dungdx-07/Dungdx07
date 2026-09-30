-- Dungdx PvP v2.1.0 BF
-- Rebuilt from scratch: responsive UI, draggable window, UI scale,
-- independent macro blocks, combat/visual/move/settings systems.
-- Generic Roblox LocalScript implementation.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local CONFIG = {
    Name = "Dungdx PvP",
    Version = "v2.1.0 BF",
    Discord = "https://discord.gg/Hwwa3VYxW6",
    Scale = 0.82,

    Combat = {
        Aimbot = false,
        SilentAimMode = "- FOV -",
        FOVCircle = false,
        FOVSize = 150,
    },

    Visual = {
        PlayerESP = false,
        Hitbox = false,
        Distance = false,
        Health = false,
        Level = false,
        Team = false,
        Transparency = 0.70,
        TeamColors = {
            Blue = Color3.fromRGB(40,140,255),
            Red = Color3.fromRGB(255,55,70),
            Green = Color3.fromRGB(40,220,90),
            Yellow = Color3.fromRGB(255,210,40),
        }
    },

    Move = {
        SpeedBoost = false,
        SpeedPercent = 100,
        JumpBoost = false,
        JumpPercent = 100,
        NoClip = false,
        Fly = false,
    },

    Macros = {}
}

for i = 1, 6 do
    CONFIG.Macros[i] = {
        Enabled = false,
        Blocks = {
            {Weapon="Kiếm", Skill="Z", Hold=0, Delay=0},
            {Weapon="Kiếm", Skill="X", Hold=0, Delay=0.10},
            {Weapon="Kiếm", Skill="C", Hold=0, Delay=0.15},
        }
    }
end

local function deepCopy(t)
    local out = {}
    for k,v in pairs(t) do
        out[k] = type(v) == "table" and deepCopy(v) or v
    end
    return out
end

local DEFAULTS = deepCopy(CONFIG)

local function notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Dungdx PvP",
            Text = text,
            Duration = 2
        })
    end)
end

-- GUI root
local old = CoreGui:FindFirstChild("DungdxPvP")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "DungdxPvP"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Root = Instance.new("Frame")
Root.Name = "Root"
Root.AnchorPoint = Vector2.new(0.5,0.5)
Root.Position = UDim2.fromScale(0.5,0.5)
Root.Size = UDim2.fromOffset(1040,690)
Root.BackgroundColor3 = Color3.fromRGB(5,14,28)
Root.BorderSizePixel = 0
Root.Parent = gui

local RootCorner = Instance.new("UICorner", Root)
RootCorner.CornerRadius = UDim.new(0,16)

local RootStroke = Instance.new("UIStroke", Root)
RootStroke.Color = Color3.fromRGB(20,100,190)
RootStroke.Transparency = 0.28
RootStroke.Thickness = 1

local Scale = Instance.new("UIScale", Root)
Scale.Scale = CONFIG.Scale

local function makeLabel(parent, text, size, color, font)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 16
    l.TextColor3 = color or Color3.fromRGB(220,235,255)
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function corner(obj, radius)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0,radius or 8)
    return c
end

local function stroke(obj, color, transparency)
    local s = Instance.new("UIStroke", obj)
    s.Color = color or Color3.fromRGB(20,105,205)
    s.Transparency = transparency or 0.45
    s.Thickness = 1
    return s
end

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,92)
Header.BackgroundColor3 = Color3.fromRGB(6,18,35)
Header.BorderSizePixel = 0
Header.Parent = Root
corner(Header,16)

local Shield = Instance.new("TextLabel")
Shield.BackgroundTransparency = 1
Shield.Size = UDim2.fromOffset(45,45)
Shield.Position = UDim2.fromOffset(22,20)
Shield.Text = "◆"
Shield.TextColor3 = Color3.fromRGB(20,125,255)
Shield.TextSize = 35
Shield.Font = Enum.Font.GothamBold
Shield.Parent = Header

local Title = makeLabel(Header, "Dungdx PvP", 26, Color3.fromRGB(245,248,255), Enum.Font.GothamBold)
Title.Position = UDim2.fromOffset(68,14)
Title.Size = UDim2.fromOffset(180,35)

local Dot = makeLabel(Header, "•", 23, Color3.fromRGB(20,125,255), Enum.Font.GothamBold)
Dot.Position = UDim2.fromOffset(245,15)
Dot.Size = UDim2.fromOffset(20,35)

local Version = makeLabel(Header, CONFIG.Version, 17, Color3.fromRGB(90,165,245))
Version.Position = UDim2.fromOffset(263,18)
Version.Size = UDim2.fromOffset(100,30)

local Owner = makeLabel(Header, "Owner: Dungdx   |   Discord: discord.gg/Hwwa3VYxW6", 14, Color3.fromRGB(115,165,225))
Owner.Position = UDim2.fromOffset(70,49)
Owner.Size = UDim2.fromOffset(500,25)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(52,52)
MinBtn.Position = UDim2.new(1,-122,0,20)
MinBtn.Text = "−"
MinBtn.TextSize = 25
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.fromRGB(225,235,250)
MinBtn.BackgroundColor3 = Color3.fromRGB(12,35,63)
MinBtn.Parent = Header
corner(MinBtn,10)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(52,52)
CloseBtn.Position = UDim2.new(1,-62,0,20)
CloseBtn.Text = "×"
CloseBtn.TextSize = 29
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(225,45,70)
CloseBtn.Parent = Header
corner(CloseBtn,10)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(12,105)
Sidebar.Size = UDim2.fromOffset(220,573)
Sidebar.BackgroundColor3 = Color3.fromRGB(5,18,35)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Root
corner(Sidebar,12)
stroke(Sidebar, Color3.fromRGB(15,75,145), 0.55)

local tabs = {"Combat","Macro","Visual","Move","Setting"}
local tabButtons = {}
local pages = {}
local currentTab

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(245,105)
Content.Size = UDim2.new(1,-257,1,-117)
Content.BackgroundColor3 = Color3.fromRGB(4,14,28)
Content.BorderSizePixel = 0
Content.Parent = Root
corner(Content,12)
stroke(Content, Color3.fromRGB(15,75,145), 0.58)

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1,1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 5
    page.ScrollBarImageColor3 = Color3.fromRGB(20,120,240)
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = Content

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0,14)
    pad.PaddingBottom = UDim.new(0,14)
    pad.PaddingLeft = UDim.new(0,14)
    pad.PaddingRight = UDim.new(0,14)

    local list = Instance.new("UIListLayout", page)
    list.Padding = UDim.new(0,10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(0,list.AbsoluteContentSize.Y+28)
    end)
    pages[name] = page
    return page
end

for _,name in ipairs(tabs) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,70)
    b.Position = UDim2.fromOffset(10,10 + (#tabButtons)*76)
    b.BackgroundColor3 = Color3.fromRGB(8,29,53)
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = Sidebar
    corner(b,10)

    local icon = makeLabel(b, ({Combat="⚔",Macro="⌘",Visual="◉",Move="➤",Setting="⚙"})[name], 25, Color3.fromRGB(150,195,250), Enum.Font.GothamBold)
    icon.Position = UDim2.fromOffset(18,17)
    icon.Size = UDim2.fromOffset(38,35)
    icon.TextXAlignment = Enum.TextXAlignment.Center

    local text = makeLabel(b,name,18,Color3.fromRGB(150,195,250),Enum.Font.GothamSemibold)
    text.Position = UDim2.fromOffset(65,17)
    text.Size = UDim2.new(1,-75,0,35)

    tabButtons[name] = b
    createPage(name)
end

local function setTab(name)
    currentTab = name
    for n,b in pairs(tabButtons) do
        local active = n == name
        b.BackgroundColor3 = active and Color3.fromRGB(9,69,145) or Color3.fromRGB(8,29,53)
        local bar = b:FindFirstChild("ActiveBar")
        if active and not bar then
            bar = Instance.new("Frame")
            bar.Name = "ActiveBar"
            bar.Size = UDim2.fromOffset(5,54)
            bar.Position = UDim2.fromOffset(0,8)
            bar.BackgroundColor3 = Color3.fromRGB(20,135,255)
            bar.BorderSizePixel = 0
            corner(bar,3)
            bar.Parent = b
        elseif not active and bar then bar:Destroy() end
    end
    for n,p in pairs(pages) do p.Visible = n == name end
end

for n,b in pairs(tabButtons) do
    b.MouseButton1Click:Connect(function() setTab(n) end)
end

-- Generic UI helpers
local function section(page, title, subtitle)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1,0,0,72)
    box.BackgroundColor3 = Color3.fromRGB(7,25,46)
    box.BorderSizePixel = 0
    box.Parent = page
    corner(box,10)
    stroke(box, Color3.fromRGB(18,90,170), 0.55)

    local t = makeLabel(box,title,21,Color3.fromRGB(220,235,255),Enum.Font.GothamBold)
    t.Position = UDim2.fromOffset(18,10)
    t.Size = UDim2.new(1,-36,0,30)
    if subtitle then
        local s = makeLabel(box,subtitle,13,Color3.fromRGB(105,160,225))
        s.Position = UDim2.fromOffset(18,39)
        s.Size = UDim2.new(1,-36,0,22)
    end
    return box
end

local function toggleRow(page, title, subtitle, getValue, setValue)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1,0,0,66)
    box.BackgroundColor3 = Color3.fromRGB(7,25,46)
    box.BorderSizePixel = 0
    box.Parent = page
    corner(box,10)
    stroke(box, Color3.fromRGB(15,80,155), 0.60)

    local t = makeLabel(box,title,17,Color3.fromRGB(220,235,255),Enum.Font.GothamSemibold)
    t.Position = UDim2.fromOffset(18,9)
    t.Size = UDim2.new(1,-105,0,25)

    local s = makeLabel(box,subtitle or "",12,Color3.fromRGB(105,160,225))
    s.Position = UDim2.fromOffset(18,34)
    s.Size = UDim2.new(1,-105,0,20)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(76,34)
    btn.Position = UDim2.new(1,-90,0.5,-17)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = box
    corner(btn,17)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(26,26)
    knob.Position = UDim2.fromOffset(4,4)
    knob.BackgroundColor3 = Color3.fromRGB(235,242,250)
    knob.Parent = btn
    corner(knob,13)

    local function refresh()
        local on = getValue()
        btn.BackgroundColor3 = on and Color3.fromRGB(15,125,245) or Color3.fromRGB(25,55,90)
        knob.Position = on and UDim2.new(1,-30,0,4) or UDim2.fromOffset(4,4)
    end
    btn.MouseButton1Click:Connect(function()
        setValue(not getValue())
        refresh()
    end)
    refresh()
    return box, refresh
end

local function sliderRow(page, title, min, max, getValue, setValue, suffix)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1,0,0,92)
    box.BackgroundColor3 = Color3.fromRGB(7,25,46)
    box.BorderSizePixel = 0
    box.Parent = page
    corner(box,10)
    stroke(box, Color3.fromRGB(15,80,155), 0.60)

    local label = makeLabel(box,title,17,Color3.fromRGB(220,235,255),Enum.Font.GothamSemibold)
    label.Position = UDim2.fromOffset(18,12)
    label.Size = UDim2.fromOffset(260,28)

    local value = makeLabel(box,"",15,Color3.fromRGB(180,210,245),Enum.Font.GothamSemibold)
    value.AnchorPoint = Vector2.new(1,0)
    value.Position = UDim2.new(1,-18,0,12)
    value.Size = UDim2.fromOffset(100,28)
    value.TextXAlignment = Enum.TextXAlignment.Right

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.fromOffset(38,38)
    minus.Position = UDim2.fromOffset(18,48)
    minus.Text = "−"
    minus.TextSize = 20
    minus.TextColor3 = Color3.fromRGB(220,235,255)
    minus.BackgroundColor3 = Color3.fromRGB(10,35,65)
    minus.Parent = box
    corner(minus,8)

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.fromOffset(38,38)
    plus.Position = UDim2.new(1,-56,0,48)
    plus.Text = "+"
    plus.TextSize = 20
    plus.TextColor3 = Color3.fromRGB(220,235,255)
    plus.BackgroundColor3 = Color3.fromRGB(10,35,65)
    plus.Parent = box
    corner(plus,8)

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(68,63)
    bar.Size = UDim2.new(1,-136,0,10)
    bar.BackgroundColor3 = Color3.fromRGB(24,55,90)
    bar.BorderSizePixel = 0
    bar.Parent = box
    corner(bar,5)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0,1)
    fill.BackgroundColor3 = Color3.fromRGB(20,125,255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    corner(fill,5)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18,18)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.BackgroundColor3 = Color3.fromRGB(240,245,255)
    knob.Parent = bar
    corner(knob,9)

    local dragging = false
    local function set(v)
        v = math.clamp(math.floor(v+0.5),min,max)
        setValue(v)
        local pct = (v-min)/(max-min)
        fill.Size = UDim2.fromScale(pct,1)
        knob.Position = UDim2.new(pct,0,0.5,0)
        value.Text = tostring(v)..(suffix or "")
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            set(min+(max-min)*pct)
        end
    end)
    minus.MouseButton1Click:Connect(function() set(getValue()-1) end)
    plus.MouseButton1Click:Connect(function() set(getValue()+1) end)
    set(getValue())
    return box
end

local function dropdownRow(page, title, options, getValue, setValue)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1,0,0,66)
    box.BackgroundColor3 = Color3.fromRGB(7,25,46)
    box.BorderSizePixel = 0
    box.Parent = page
    corner(box,10)
    stroke(box, Color3.fromRGB(15,80,155), 0.60)

    local label = makeLabel(box,title,17,Color3.fromRGB(220,235,255),Enum.Font.GothamSemibold)
    label.Position = UDim2.fromOffset(18,18)
    label.Size = UDim2.fromOffset(240,30)

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(240,42)
    button.Position = UDim2.new(1,-258,0.5,-21)
    button.Text = getValue()
    button.TextSize = 15
    button.TextColor3 = Color3.fromRGB(220,235,255)
    button.BackgroundColor3 = Color3.fromRGB(8,31,57)
    button.Parent = box
    corner(button,8)
    stroke(button,Color3.fromRGB(20,110,220),0.40)

    local list
    button.MouseButton1Click:Connect(function()
        if list then list:Destroy(); list=nil; return end
        list = Instance.new("Frame")
        list.Size = UDim2.new(0,240,0,math.min(38*#options,190))
        list.Position = UDim2.new(1,-258,0,70)
        list.BackgroundColor3 = Color3.fromRGB(8,28,52)
        list.ZIndex = 20
        list.Parent = box
        corner(list,8)
        stroke(list,Color3.fromRGB(20,110,220),0.25)
        local lay = Instance.new("UIListLayout",list)
        for _,opt in ipairs(options) do
            local o = Instance.new("TextButton")
            o.Size = UDim2.new(1,0,0,38)
            o.Text = opt
            o.TextSize = 14
            o.TextXAlignment = Enum.TextXAlignment.Left
            o.TextColor3 = Color3.fromRGB(220,235,255)
            o.BackgroundColor3 = opt == getValue() and Color3.fromRGB(12,90,190) or Color3.fromRGB(8,28,52)
            o.ZIndex = 21
            o.Parent = list
            local p = Instance.new("UIPadding",o)
            p.PaddingLeft = UDim.new(0,12)
            o.MouseButton1Click:Connect(function()
                setValue(opt)
                button.Text = opt
                list:Destroy()
                list=nil
            end)
        end
    end)
    return box
end

-- Combat page
do
    local p = pages.Combat
    section(p,"Combat","Target assistance and FOV controls")
    toggleRow(p,"Aimbot (Camera Lock)","Smoothly track a nearby target",
        function() return CONFIG.Combat.Aimbot end,
        function(v) CONFIG.Combat.Aimbot=v end)
    dropdownRow(p,"Silent Aim",{"- FOV -","- Nearest -"},
        function() return CONFIG.Combat.SilentAimMode end,
        function(v) CONFIG.Combat.SilentAimMode=v end)
    toggleRow(p,"FOV Circle","Display target selection radius",
        function() return CONFIG.Combat.FOVCircle end,
        function(v) CONFIG.Combat.FOVCircle=v end)
    sliderRow(p,"FOV Size",50,500,
        function() return CONFIG.Combat.FOVSize end,
        function(v) CONFIG.Combat.FOVSize=v end," px")
end

-- Macro page
local macroListContainer
do
    local p = pages.Macro
    section(p,"Macro","Independent action sequences")
    local addMacro = Instance.new("TextButton")
    addMacro.Size = UDim2.new(1,0,0,50)
    addMacro.Text = "+  Tạo Macro"
    addMacro.TextSize = 16
    addMacro.Font = Enum.Font.GothamBold
    addMacro.TextColor3 = Color3.fromRGB(245,250,255)
    addMacro.BackgroundColor3 = Color3.fromRGB(10,105,220)
    addMacro.Parent = p
    corner(addMacro,9)

    macroListContainer = Instance.new("Frame")
    macroListContainer.Size = UDim2.new(1,0,0,0)
    macroListContainer.AutomaticSize = Enum.AutomaticSize.Y
    macroListContainer.BackgroundTransparency = 1
    macroListContainer.Parent = p
    local ml = Instance.new("UIListLayout",macroListContainer)
    ml.Padding = UDim.new(0,10)

    local function rebuildMacro(index)
        local old = macroListContainer:FindFirstChild("Macro_"..index)
        if old then old:Destroy() end
        local data = CONFIG.Macros[index]
        local box = Instance.new("Frame")
        box.Name = "Macro_"..index
        box.Size = UDim2.new(1,0,0,66)
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.BackgroundColor3 = Color3.fromRGB(7,25,46)
        box.BorderSizePixel = 0
        box.Parent = macroListContainer
        corner(box,10)
        stroke(box,Color3.fromRGB(15,80,155),0.55)

        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1,-90,0,66)
        header.BackgroundTransparency = 1
        header.Text = "⌄   Macro "..index
        header.TextSize = 17
        header.TextColor3 = Color3.fromRGB(220,235,255)
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = box

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.fromOffset(72,34)
        toggle.Position = UDim2.new(1,-82,0,16)
        toggle.Text = data.Enabled and "ON" or "OFF"
        toggle.TextSize = 13
        toggle.TextColor3 = Color3.fromRGB(240,245,255)
        toggle.BackgroundColor3 = data.Enabled and Color3.fromRGB(15,125,245) or Color3.fromRGB(25,55,90)
        toggle.Parent = box
        corner(toggle,17)

        local body = Instance.new("Frame")
        body.Size = UDim2.new(1,-20,0,0)
        body.Position = UDim2.fromOffset(10,70)
        body.AutomaticSize = Enum.AutomaticSize.Y
        body.Visible = false
        body.BackgroundTransparency = 1
        body.Parent = box

        local bl = Instance.new("UIListLayout",body)
        bl.Padding = UDim.new(0,8)

        local function addBlock()
            table.insert(data.Blocks,{Weapon="Kiếm",Skill="Z",Hold=0,Delay=0})
            rebuildMacro(index)
            notify("Đã thêm Block vào Macro "..index)
        end

        local function drawBlocks()
            for i,b in ipairs(data.Blocks) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1,0,0,105)
                row.BackgroundColor3 = Color3.fromRGB(5,20,38)
                row.BorderSizePixel = 0
                row.Parent = body
                corner(row,8)
                stroke(row,Color3.fromRGB(15,75,145),0.65)

                local title = makeLabel(row,"Block "..i,14,Color3.fromRGB(130,185,245),Enum.Font.GothamBold)
                title.Position=UDim2.fromOffset(12,8)
                title.Size=UDim2.fromOffset(80,22)

                local weapon = Instance.new("TextButton")
                weapon.Size=UDim2.fromOffset(125,34)
                weapon.Position=UDim2.fromOffset(10,42)
                weapon.Text=b.Weapon
                weapon.TextSize=13
                weapon.TextColor3=Color3.fromRGB(220,235,255)
                weapon.BackgroundColor3=Color3.fromRGB(8,31,57)
                weapon.Parent=row
                corner(weapon,7)

                local skills={"Z","X","C","V","F"}
                local skill=Instance.new("TextButton")
                skill.Size=UDim2.fromOffset(65,34)
                skill.Position=UDim2.fromOffset(145,42)
                skill.Text=b.Skill
                skill.TextSize=14
                skill.TextColor3=Color3.fromRGB(220,235,255)
                skill.BackgroundColor3=Color3.fromRGB(8,31,57)
                skill.Parent=row
                corner(skill,7)

                local hold=Instance.new("TextBox")
                hold.Size=UDim2.fromOffset(75,34)
                hold.Position=UDim2.fromOffset(220,42)
                hold.Text=string.format("%.2f",b.Hold)
                hold.TextSize=13
                hold.TextColor3=Color3.fromRGB(220,235,255)
                hold.BackgroundColor3=Color3.fromRGB(8,31,57)
                hold.Parent=row
                corner(hold,7)

                local delay=Instance.new("TextBox")
                delay.Size=UDim2.fromOffset(75,34)
                delay.Position=UDim2.fromOffset(303,42)
                delay.Text=string.format("%.2f",b.Delay)
                delay.TextSize=13
                delay.TextColor3=Color3.fromRGB(220,235,255)
                delay.BackgroundColor3=Color3.fromRGB(8,31,57)
                delay.Parent=row
                corner(delay,7)

                local del=Instance.new("TextButton")
                del.Size=UDim2.fromOffset(50,34)
                del.Position=UDim2.new(1,-62,0,42)
                del.Text="×"
                del.TextSize=20
                del.TextColor3=Color3.fromRGB(255,100,115)
                del.BackgroundColor3=Color3.fromRGB(45,22,35)
                del.Parent=row
                corner(del,7)

                weapon.MouseButton1Click:Connect(function()
                    local list={"Võ","Kiếm","Súng","Trái"}
                    local idx=table.find(list,b.Weapon) or 2
                    b.Weapon=list[(idx%#list)+1]
                    weapon.Text=b.Weapon
                end)
                skill.MouseButton1Click:Connect(function()
                    local idx=table.find(skills,b.Skill) or 1
                    b.Skill=skills[(idx%#skills)+1]
                    skill.Text=b.Skill
                end)
                hold.FocusLost:Connect(function()
                    b.Hold=tonumber(hold.Text) or b.Hold
                    hold.Text=string.format("%.2f",b.Hold)
                end)
                delay.FocusLost:Connect(function()
                    b.Delay=tonumber(delay.Text) or b.Delay
                    delay.Text=string.format("%.2f",b.Delay)
                end)
                del.MouseButton1Click:Connect(function()
                    table.remove(data.Blocks,i)
                    rebuildMacro(index)
                end)
            end
            local add=Instance.new("TextButton")
            add.Size=UDim2.new(1,0,0,42)
            add.Text="+  Add Block"
            add.TextSize=14
            add.TextColor3=Color3.fromRGB(130,195,255)
            add.BackgroundColor3=Color3.fromRGB(8,35,65)
            add.Parent=body
            corner(add,8)
            add.MouseButton1Click:Connect(addBlock)
        end

        header.MouseButton1Click:Connect(function()
            body.Visible=not body.Visible
            header.Text=(body.Visible and "⌃   " or "⌄   ").."Macro "..index
            if body.Visible then
                drawBlocks()
            else
                for _,c in ipairs(body:GetChildren()) do
                    if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
                end
            end
        end)

        toggle.MouseButton1Click:Connect(function()
            data.Enabled=not data.Enabled
            toggle.Text=data.Enabled and "ON" or "OFF"
            toggle.BackgroundColor3=data.Enabled and Color3.fromRGB(15,125,245) or Color3.fromRGB(25,55,90)
        end)
    end

    for i=1,#CONFIG.Macros do rebuildMacro(i) end
    addMacro.MouseButton1Click:Connect(function()
        table.insert(CONFIG.Macros,{Enabled=false,Blocks={{Weapon="Kiếm",Skill="Z",Hold=0,Delay=0}}})
        rebuildMacro(#CONFIG.Macros)
    end)
end

-- Visual page
do
    local p=pages.Visual
    section(p,"Visual","Player information and overlays")
    toggleRow(p,"Player ESP","Show player information",
        function() return CONFIG.Visual.PlayerESP end,
        function(v) CONFIG.Visual.PlayerESP=v end)
    toggleRow(p,"Show Hitbox","Display character bounds",
        function() return CONFIG.Visual.Hitbox end,
        function(v) CONFIG.Visual.Hitbox=v end)
    toggleRow(p,"ESP Distance","Show distance",
        function() return CONFIG.Visual.Distance end,
        function(v) CONFIG.Visual.Distance=v end)
    toggleRow(p,"ESP Health","Show health",
        function() return CONFIG.Visual.Health end,
        function(v) CONFIG.Visual.Health=v end)
    toggleRow(p,"ESP Level","Show level when available",
        function() return CONFIG.Visual.Level end,
        function(v) CONFIG.Visual.Level=v end)
    toggleRow(p,"ESP Team","Show team",
        function() return CONFIG.Visual.Team end,
        function(v) CONFIG.Visual.Team=v end)
    dropdownRow(p,"Team Color",{"Blue","Red","Green","Yellow"},
        function() return "Blue" end,
        function(_) end)
    sliderRow(p,"Transparency",0,100,
        function() return math.floor(CONFIG.Visual.Transparency*100) end,
        function(v) CONFIG.Visual.Transparency=v/100 end,"%")
end

-- Move page
do
    local p=pages.Move
    section(p,"Move","Movement controls")
    toggleRow(p,"Speed Boost","Increase movement speed",
        function() return CONFIG.Move.SpeedBoost end,
        function(v) CONFIG.Move.SpeedBoost=v end)
    sliderRow(p,"Speed Boost",50,300,
        function() return CONFIG.Move.SpeedPercent end,
        function(v) CONFIG.Move.SpeedPercent=v end,"%")
    toggleRow(p,"Jump Boost","Increase jump power",
        function() return CONFIG.Move.JumpBoost end,
        function(v) CONFIG.Move.JumpBoost=v end)
    sliderRow(p,"Jump Boost",50,300,
        function() return CONFIG.Move.JumpPercent end,
        function(v) CONFIG.Move.JumpPercent=v end,"%")
    toggleRow(p,"No Clip","Disable character collision",
        function() return CONFIG.Move.NoClip end,
        function(v) CONFIG.Move.NoClip=v end)
    toggleRow(p,"Fly button","Enable flight control",
        function() return CONFIG.Move.Fly end,
        function(v) CONFIG.Move.Fly=v end)
end

-- Setting page
do
    local p=pages.Setting
    section(p,"Setting","Configuration and utility")
    toggleRow(p,"Bật FixLag","Performance options",
        function() return CONFIG.FixLag == true end,
        function(v) CONFIG.FixLag=v end)

    local copy=Instance.new("TextButton")
    copy.Size=UDim2.new(1,0,0,62)
    copy.Text="🔗   Copy Link Discord"
    copy.TextSize=16
    copy.TextColor3=Color3.fromRGB(225,240,255)
    copy.BackgroundColor3=Color3.fromRGB(7,25,46)
    copy.Parent=p
    corner(copy,10)
    stroke(copy,Color3.fromRGB(15,80,155),0.60)
    copy.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(CONFIG.Discord)
            notify("Đã copy Discord")
        else
            notify(CONFIG.Discord)
        end
    end)

    local reset=Instance.new("TextButton")
    reset.Size=UDim2.new(1,0,0,62)
    reset.Text="↻   Đặt về Mặc định"
    reset.TextSize=16
    reset.TextColor3=Color3.fromRGB(220,235,255)
    reset.BackgroundColor3=Color3.fromRGB(8,31,57)
    reset.Parent=p
    corner(reset,10)
    reset.MouseButton1Click:Connect(function()
        CONFIG=deepCopy(DEFAULTS)
        Scale.Scale=CONFIG.Scale
        notify("Đã khôi phục mặc định")
    end)

    local save=Instance.new("TextButton")
    save.Size=UDim2.new(1,0,0,62)
    save.Text="▣   Lưu cài đặt"
    save.TextSize=16
    save.TextColor3=Color3.fromRGB(245,250,255)
    save.BackgroundColor3=Color3.fromRGB(10,105,220)
    save.Parent=p
    corner(save,10)
    save.MouseButton1Click:Connect(function()
        local ok=false
        if writefile then
            ok=pcall(function()
                writefile("DungdxPvP_Settings.json",HttpService:JSONEncode(CONFIG))
            end)
        end
        notify(ok and "Đã lưu cài đặt" or "Cấu hình hiện tại đã được giữ trong phiên")
    end)

    toggleRow(p,"Đi trên nước","Movement surface option",
        function() return CONFIG.WalkOnWater == true end,
        function(v) CONFIG.WalkOnWater=v end)

    sliderRow(p,"UI Scale",70,120,
        function() return math.floor(Scale.Scale*100) end,
        function(v) CONFIG.Scale=v/100; Scale.Scale=CONFIG.Scale end,"%")
end

-- FOV circle
local FOVGui = Instance.new("Frame")
FOVGui.Name="FOVCircle"
FOVGui.AnchorPoint=Vector2.new(0.5,0.5)
FOVGui.BackgroundTransparency=1
FOVGui.Visible=false
FOVGui.Parent=gui
local fovStroke=Instance.new("UIStroke",FOVGui)
fovStroke.Color=Color3.fromRGB(30,145,255)
fovStroke.Thickness=2
local fovCorner=Instance.new("UICorner",FOVGui)
fovCorner.CornerRadius=UDim.new(1,0)

-- Feature connections
local connections={}
local espObjects={}
local flyBV
local flyBG
local savedWalkSpeed=16
local savedJumpPower=50

local function disconnect(name)
    if connections[name] then connections[name]:Disconnect(); connections[name]=nil end
end

local function cleanupESP()
    for p,items in pairs(espObjects) do
        for _,obj in pairs(items) do
            if obj and obj.Parent then obj:Destroy() end
        end
        espObjects[p]=nil
    end
end

local function createESP(player)
    if player==LocalPlayer or not player.Character then return end
    if espObjects[player] then return end

    local char=player.Character
    local root=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local highlight=Instance.new("Highlight")
    highlight.Name="DungdxESP"
    highlight.Adornee=char
    highlight.FillColor=Color3.fromRGB(30,120,255)
    highlight.FillTransparency=CONFIG.Visual.Transparency
    highlight.OutlineColor=Color3.fromRGB(80,180,255)
    highlight.Parent=char

    local billboard=Instance.new("BillboardGui")
    billboard.Name="DungdxInfo"
    billboard.Adornee=root
    billboard.Size=UDim2.fromOffset(180,70)
    billboard.StudsOffset=Vector3.new(0,3.5,0)
    billboard.AlwaysOnTop=true
    billboard.Parent=char

    local txt=Instance.new("TextLabel")
    txt.Size=UDim2.fromScale(1,1)
    txt.BackgroundTransparency=1
    txt.TextColor3=Color3.fromRGB(225,240,255)
    txt.TextStrokeTransparency=0.35
    txt.TextSize=13
    txt.Font=Enum.Font.GothamSemibold
    txt.Parent=billboard

    espObjects[player]={highlight,billboard}

    connections["ESP_"..player.UserId]=RunService.RenderStepped:Connect(function()
        if not char.Parent or not root.Parent then
            disconnect("ESP_"..player.UserId)
            return
        end
        local parts={player.DisplayName}
        if CONFIG.Visual.Distance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local d=(root.Position-LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            table.insert(parts,string.format("%.0f studs",d))
        end
        if CONFIG.Visual.Health then
            table.insert(parts,string.format("HP %.0f/%.0f",hum.Health,hum.MaxHealth))
        end
        if CONFIG.Visual.Team and player.Team then table.insert(parts,"Team: "..player.Team.Name) end
        if CONFIG.Visual.Level then
            local ls=player:FindFirstChild("leaderstats")
            local lv=ls and (ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl"))
            if lv then table.insert(parts,"Lv. "..tostring(lv.Value)) end
        end
        txt.Text=table.concat(parts,"\n")
        highlight.Enabled=CONFIG.Visual.PlayerESP
        billboard.Enabled=CONFIG.Visual.PlayerESP
        highlight.FillTransparency=CONFIG.Visual.Transparency
    end)
end

local function updateESP()
    if CONFIG.Visual.PlayerESP then
        for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
    else
        cleanupESP()
    end
end

local function nearestTarget()
    local myChar=LocalPlayer.Character
    local myRoot=myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local best, bestDist=nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local root=p.Character:FindFirstChild("HumanoidRootPart")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health>0 then
                local screen,on=Camera:WorldToViewportPoint(root.Position)
                if on then
                    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
                    local dist=(Vector2.new(screen.X,screen.Y)-center).Magnitude
                    if CONFIG.Combat.SilentAimMode=="- Nearest -" then
                        dist=(root.Position-myRoot.Position).Magnitude
                    end
                    if dist<bestDist and (CONFIG.Combat.SilentAimMode=="- Nearest -" or dist<=CONFIG.Combat.FOVSize) then
                        bestDist=dist
                        best=p
                    end
                end
            end
        end
    end
    return best
end

local function applyMovement()
    local char=LocalPlayer.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if CONFIG.Move.SpeedBoost then
        hum.WalkSpeed=16*(CONFIG.Move.SpeedPercent/100)
    else
        hum.WalkSpeed=savedWalkSpeed
    end
    if CONFIG.Move.JumpBoost then
        hum.UseJumpPower=true
        hum.JumpPower=50*(CONFIG.Move.JumpPercent/100)
    else
        hum.JumpPower=savedJumpPower
    end
end

local function stopFly()
    if flyBV then flyBV:Destroy(); flyBV=nil end
    if flyBG then flyBG:Destroy(); flyBG=nil end
end

local function startFly()
    stopFly()
    local char=LocalPlayer.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    flyBV=Instance.new("BodyVelocity")
    flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity=Vector3.zero
    flyBV.Parent=root
    flyBG=Instance.new("BodyGyro")
    flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
    flyBG.P=1e4
    flyBG.CFrame=Camera.CFrame
    flyBG.Parent=root
end

-- Central update loop
connections.Main=RunService.RenderStepped:Connect(function()
    FOVGui.Visible=CONFIG.Combat.FOVCircle
    local size=CONFIG.Combat.FOVSize*2
    FOVGui.Size=UDim2.fromOffset(size,size)
    FOVGui.Position=UDim2.fromOffset(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)

    if CONFIG.Combat.Aimbot then
        local target=nearestTarget()
        if target and target.Character then
            local root=target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local desired=CFrame.lookAt(Camera.CFrame.Position,root.Position)
                Camera.CFrame=Camera.CFrame:Lerp(desired,0.12)
            end
        end
    end

    applyMovement()

    if CONFIG.Move.NoClip and LocalPlayer.Character then
        for _,part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide=false end
        end
    end

    if CONFIG.Move.Fly and flyBV and flyBG then
        local char=LocalPlayer.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local move=Vector3.zero
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then move=hum.MoveDirection end
            local y=0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then y=45 end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then y=-45 end
            flyBV.Velocity=move*70+Vector3.new(0,y,0)
            flyBG.CFrame=Camera.CFrame
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if CONFIG.Visual.PlayerESP then createESP(p) end
    end)
end)

-- Dragging
do
    local dragging=false
    local dragStart
    local startPos

    local function update(input)
        local delta=input.Position-dragStart
        Root.Position=UDim2.new(
            startPos.X.Scale,startPos.X.Offset+delta.X,
            startPos.Y.Scale,startPos.Y.Offset+delta.Y
        )
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            dragStart=input.Position
            startPos=Root.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

local minimized=false
local savedRootSize=Root.Size
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    Sidebar.Visible=not minimized
    Content.Visible=not minimized
    if minimized then
        Root.Size=UDim2.fromOffset(500,92)
        MinBtn.Text="+"
    else
        Root.Size=savedRootSize
        MinBtn.Text="−"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    CONFIG.Combat.Aimbot=false
    CONFIG.Visual.PlayerESP=false
    CONFIG.Move.Fly=false
    stopFly()
    cleanupESP()
    for k in pairs(connections) do
        if k~="Main" then disconnect(k) end
    end
    gui:Destroy()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    savedWalkSpeed=16
    savedJumpPower=50
    stopFly()
    if CONFIG.Move.Fly then startFly() end
end)

-- Optional load of saved configuration where supported
if isfile and readfile then
    pcall(function()
        if isfile("DungdxPvP_Settings.json") then
            local data=HttpService:JSONDecode(readfile("DungdxPvP_Settings.json"))
            if type(data)=="table" then
                for k,v in pairs(data) do CONFIG[k]=v end
                Scale.Scale=CONFIG.Scale or 0.82
            end
        end
    end)
end

setTab("Combat")
notify("Dungdx PvP đã khởi động")
