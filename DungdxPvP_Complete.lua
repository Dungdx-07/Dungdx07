--[[
DUN GDX / DUN GDX PVP — COMPLETE ROBLOX STUDIO INSTALLER
Owner: Dungdx
Discord: https://discord.gg/Hwwa3VYxW6
Version: 2.0.0

CÁCH DÙNG:
1) Mở Roblox Studio > game CỦA BẠN.
2) Mở View > Command Bar.
3) Dán TOÀN BỘ file này vào Command Bar rồi Run.
4) Script sẽ tạo:
   ReplicatedStorage/DungdxPvP
      ClientConfig
      Remotes/*
   ServerScriptService/DungdxPvPServer
      Config
   StarterPlayer/StarterPlayerScripts/DungdxPvPClient

ĐÂY KHÔNG PHẢI executor script cho Blox Fruits.
Đây là bộ PvP framework hoàn chỉnh để bạn dùng trong game Roblox Studio do bạn sở hữu.

TÍNH NĂNG:
- UI đẹp, kéo thả, RightShift ẩn/hiện
- Combat target/FOV/camera assist
- ESP tên + khoảng cách
- FOV circle
- Macro editor 8 bước: Action/Hold/Delay
- Dash/Sprint/Jump Boost
- Server-side cooldown/range/team/alive/line-of-sight/rate-limit
- Damage do server quyết định
- Config tập trung, dễ chỉnh
- Status + debug
- Không cần asset ngoài
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

local function getOrCreate(parent, className, name)
    local x = parent:FindFirstChild(name)
    if x and x.ClassName == className then
        return x
    end
    if x then x:Destroy() end
    x = Instance.new(className)
    x.Name = name
    x.Parent = parent
    return x
end

local function putSource(parent, className, name, source)
    local x = getOrCreate(parent, className, name)
    x.Source = source
    return x
end

local system = getOrCreate(ReplicatedStorage, "Folder", "DungdxPvP")
local remotes = getOrCreate(system, "Folder", "Remotes")

for _, name in ipairs({
    "RequestAbility",
    "RequestDash",
    "RequestSettings",
    "SyncState",
}) do
    getOrCreate(remotes, "RemoteEvent", name)
end

local clientConfigSource = [==[
local Config = {}

Config.Brand = {
    Owner = "Dungdx",
    Discord = "https://discord.gg/Hwwa3VYxW6",
    Name = "Dungdx PvP",
    Version = "2.0.0",
}

Config.UI = {
    ToggleKey = Enum.KeyCode.RightShift,
    MainSize = UDim2.fromOffset(760, 500),
}

Config.Combat = {
    AimEnabled = true,
    FOV = 150,
    MaxDistance = 160,
    Smoothness = 0.18,
    TeamCheck = true,
    RequireLineOfSight = true,
}

Config.Visual = {
    ESPEnabled = true,
    ShowNames = true,
    ShowDistance = true,
    ShowFOV = true,
}

Config.Movement = {
    SprintEnabled = false,
    SprintSpeed = 24,
    JumpBoostEnabled = false,
    JumpPower = 60,

    DashEnabled = true,
    DashKey = Enum.KeyCode.Q,
    DashSpeed = 85,
    DashCooldown = 1.2,
}

-- Macro của GAME CỦA BẠN.
-- Action có thể là C/X/Z/F hoặc tên ability bạn định nghĩa.
Config.DefaultMacro = {
    {Action="C", Hold=0.00, Delay=0.30},
    {Action="X", Hold=0.00, Delay=1.00},
    {Action="Z", Hold=0.00, Delay=0.59},
    {Action="Z", Hold=0.00, Delay=1.23},
    {Action="F", Hold=0.00, Delay=0.44},
    {Action="C", Hold=0.60, Delay=1.25},
    {Action="X", Hold=0.00, Delay=0.25},
    {Action="Z", Hold=0.00, Delay=0.50},
}

return Config
]==]

local serverConfigSource = [==[
local Config = {}

Config.Abilities = {
    C = {Cooldown=2.00, Range=60, Damage=18},
    X = {Cooldown=2.50, Range=55, Damage=22},
    Z = {Cooldown=3.00, Range=45, Damage=26},
    F = {Cooldown=4.00, Range=70, Damage=14},
}

Config.Movement = {
    SprintSpeed=24,
    JumpPower=60,
    DashSpeed=85,
    DashCooldown=1.2,
}

Config.Security = {
    MaxRemotePerSecond=12,
}

return Config
]==]

local serverSource = [==[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local System = ReplicatedStorage:WaitForChild("DungdxPvP")
local Remotes = System:WaitForChild("Remotes")

local RequestAbility = Remotes:WaitForChild("RequestAbility")
local RequestDash = Remotes:WaitForChild("RequestDash")
local RequestSettings = Remotes:WaitForChild("RequestSettings")
local SyncState = Remotes:WaitForChild("SyncState")

local Config = require(script:WaitForChild("Config"))

local cooldowns = {}
local requestBuckets = {}
local dashTimes = {}

local function clock()
    return os.clock()
end

local function validNumber(n)
    return typeof(n) == "number"
        and n == n
        and n > -100000
        and n < 100000
end

local function validVector3(v)
    return typeof(v) == "Vector3"
        and validNumber(v.X)
        and validNumber(v.Y)
        and validNumber(v.Z)
        and v.Magnitude < 10000
end

local function getCharacter(player)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or humanoid.Health <= 0 then
        return
    end

    return character, humanoid, root
end

local function allowedRequest(player)
    local now = clock()
    local bucket = requestBuckets[player]

    if not bucket or now - bucket.start >= 1 then
        bucket = {start=now, count=0}
        requestBuckets[player] = bucket
    end

    bucket.count += 1

    return bucket.count <= Config.Security.MaxRemotePerSecond
end

local function enemy(a, b)
    if not b or not b:IsA("Player") or a == b then
        return false
    end

    if a.Team ~= nil and b.Team ~= nil and a.Team == b.Team then
        return false
    end

    return true
end

local function visible(attackerCharacter, targetCharacter, origin, targetPosition)
    local direction = targetPosition - origin
    if direction.Magnitude < 0.01 then
        return true
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {attackerCharacter, targetCharacter}
    params.IgnoreWater = true

    return workspace:Raycast(origin, direction, params) == nil
end

local function status(player, message)
    SyncState:FireClient(player, {
        Type="Status",
        Text=tostring(message),
    })
end

local function useAbility(player, action, targetPlayer)
    if not allowedRequest(player) then return end

    if typeof(action) ~= "string" or #action > 16 then
        return
    end

    local ability = Config.Abilities[action]
    if not ability then
        status(player, "Ability không hợp lệ")
        return
    end

    if not enemy(player, targetPlayer) then
        status(player, "Mục tiêu không hợp lệ")
        return
    end

    local attackerCharacter, _, attackerRoot = getCharacter(player)
    local targetCharacter, targetHumanoid, targetRoot = getCharacter(targetPlayer)

    if not attackerRoot or not targetRoot then return end

    local distance = (attackerRoot.Position - targetRoot.Position).Magnitude

    if distance > ability.Range then
        status(player, string.format("Ngoài tầm %.1f / %.1f", distance, ability.Range))
        return
    end

    if not visible(
        attackerCharacter,
        targetCharacter,
        attackerRoot.Position,
        targetRoot.Position
    ) then
        status(player, "Có vật cản")
        return
    end

    cooldowns[player] = cooldowns[player] or {}

    local last = cooldowns[player][action] or -math.huge
    if clock() - last < ability.Cooldown then
        return
    end

    cooldowns[player][action] = clock()

    -- QUYẾT ĐỊNH DAMAGE Ở SERVER.
    targetHumanoid:TakeDamage(ability.Damage)

    SyncState:FireClient(player, {
        Type="AbilityUsed",
        Action=action,
        Target=targetPlayer,
        Cooldown=ability.Cooldown,
    })
end

RequestAbility.OnServerEvent:Connect(function(player, action, targetPlayer, hold)
    if typeof(hold) ~= "number" or not validNumber(hold) then
        hold = 0
    end

    hold = math.clamp(hold, 0, 3)

    useAbility(player, action, targetPlayer)
end)

RequestDash.OnServerEvent:Connect(function(player, direction)
    if not allowedRequest(player) then return end
    if not validVector3(direction) then return end

    local _, _, root = getCharacter(player)
    if not root then return end

    local t = clock()
    local cd = Config.Movement.DashCooldown

    if t - (dashTimes[player] or -math.huge) < cd then
        return
    end

    dashTimes[player] = t

    local flat = Vector3.new(direction.X, 0, direction.Z)

    if flat.Magnitude < 0.01 then
        flat = root.CFrame.LookVector
    else
        flat = flat.Unit
    end

    local speed = math.clamp(Config.Movement.DashSpeed, 0, 120)

    root.AssemblyLinearVelocity = Vector3.new(
        flat.X * speed,
        root.AssemblyLinearVelocity.Y,
        flat.Z * speed
    )
end)

RequestSettings.OnServerEvent:Connect(function(player, settings)
    if not allowedRequest(player) then return end
    if typeof(settings) ~= "table" then return end

    local _, humanoid = getCharacter(player)
    if not humanoid then return end

    if typeof(settings.Sprint) == "boolean" then
        humanoid.WalkSpeed = settings.Sprint
            and math.clamp(Config.Movement.SprintSpeed, 8, 32)
            or 16
    end

    if typeof(settings.JumpBoost) == "boolean" then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = settings.JumpBoost
            and math.clamp(Config.Movement.JumpPower, 30, 100)
            or 50
    end
end)

Players.PlayerRemoving:Connect(function(player)
    cooldowns[player] = nil
    requestBuckets[player] = nil
    dashTimes[player] = nil
end)

print("[Dungdx PvP] Server loaded.")
]==]

local clientSource = [==[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local System = ReplicatedStorage:WaitForChild("DungdxPvP")
local Remotes = System:WaitForChild("Remotes")

local RequestAbility = Remotes:WaitForChild("RequestAbility")
local RequestDash = Remotes:WaitForChild("RequestDash")
local RequestSettings = Remotes:WaitForChild("RequestSettings")
local SyncState = Remotes:WaitForChild("SyncState")

local Config = require(System:WaitForChild("ClientConfig"))

local State = {
    Visible=true,
    Tab="Combat",
    Aim=Config.Combat.AimEnabled,
    ESP=Config.Visual.ESPEnabled,
    FOV=Config.Visual.ShowFOV,
    Sprint=Config.Movement.SprintEnabled,
    Jump=Config.Movement.JumpBoostEnabled,
    Macro=false,
    Target=nil,
    Status="Sẵn sàng",
}

local C = {
    bg=Color3.fromRGB(14,15,20),
    panel=Color3.fromRGB(21,23,30),
    panel2=Color3.fromRGB(29,31,40),
    text=Color3.fromRGB(240,242,247),
    muted=Color3.fromRGB(155,161,174),
    accent=Color3.fromRGB(105,132,255),
    good=Color3.fromRGB(70,205,126),
    bad=Color3.fromRGB(225,83,92),
    stroke=Color3.fromRGB(51,55,68),
}

local function new(className, props, parent)
    local x=Instance.new(className)
    for k,v in pairs(props or {}) do x[k]=v end
    x.Parent=parent
    return x
end

local function round(x,r)
    new("UICorner",{CornerRadius=UDim.new(0,r or 8)},x)
end

local function outline(x)
    new("UIStroke",{Color=C.stroke,Thickness=1},x)
end

local function pad(x,n)
    new("UIPadding",{
        PaddingTop=UDim.new(0,n),
        PaddingBottom=UDim.new(0,n),
        PaddingLeft=UDim.new(0,n),
        PaddingRight=UDim.new(0,n),
    },x)
end

local gui=new("ScreenGui",{
    Name="DungdxPvP",
    ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
},playerGui)

local main=new("Frame",{
    Size=Config.UI.MainSize,
    Position=UDim2.new(.5,-380,.5,-250),
    BackgroundColor3=C.bg,
    BorderSizePixel=0,
    Active=true,
},gui)
round(main,14)
outline(main)

local top=new("Frame",{
    Size=UDim2.new(1,0,0,64),
    BackgroundColor3=C.panel,
    BorderSizePixel=0,
},main)
round(top,14)

new("TextLabel",{
    BackgroundTransparency=1,
    Position=UDim2.fromOffset(18,8),
    Size=UDim2.fromOffset(550,28),
    Font=Enum.Font.GothamBold,
    Text=Config.Brand.Name.."  •  v"..Config.Brand.Version,
    TextColor3=C.text,
    TextSize=19,
    TextXAlignment=Enum.TextXAlignment.Left,
},top)

new("TextLabel",{
    BackgroundTransparency=1,
    Position=UDim2.fromOffset(18,37),
    Size=UDim2.fromOffset(650,18),
    Font=Enum.Font.Gotham,
    Text="Owner: "..Config.Brand.Owner.."  |  "..Config.Brand.Discord,
    TextColor3=C.muted,
    TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left,
},top)

local hide=new("TextButton",{
    Size=UDim2.fromOffset(40,34),
    Position=UDim2.new(1,-52,0,15),
    BackgroundColor3=C.panel2,
    Text="—",
    Font=Enum.Font.GothamBold,
    TextColor3=C.text,
    TextSize=18,
},top)
round(hide,8)

local sidebar=new("Frame",{
    Position=UDim2.fromOffset(12,76),
    Size=UDim2.fromOffset(150,410),
    BackgroundColor3=C.panel,
    BorderSizePixel=0,
},main)
round(sidebar,10)
pad(sidebar,9)

new("UIListLayout",{
    Padding=UDim.new(0,7),
    SortOrder=Enum.SortOrder.LayoutOrder,
},sidebar)

local page=new("ScrollingFrame",{
    Position=UDim2.fromOffset(174,76),
    Size=UDim2.new(1,-186,1,-88),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=4,
},main)

new("UIListLayout",{
    Padding=UDim.new(0,8),
    SortOrder=Enum.SortOrder.LayoutOrder,
},page)

local statusLabel=new("TextLabel",{
    LayoutOrder=99,
    Size=UDim2.new(1,0,0,60),
    BackgroundTransparency=1,
    Font=Enum.Font.Gotham,
    TextColor3=C.muted,
    TextSize=10,
    TextWrapped=true,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Bottom,
},sidebar)

local tabs={}

local function tabButton(name,order)
    local b=new("TextButton",{
        LayoutOrder=order,
        Size=UDim2.new(1,0,0,40),
        BackgroundColor3=C.panel2,
        Text=name,
        Font=Enum.Font.GothamMedium,
        TextColor3=C.muted,
        TextSize=12,
    },sidebar)
    round(b,8)
    tabs[name]=b
    return b
end

local tCombat=tabButton("⚔  Combat",1)
local tMacro=tabButton("⌁  Macro",2)
local tVisual=tabButton("◉  Visual",3)
local tMove=tabButton("✦  Movement",4)
local tSettings=tabButton("⚙  Settings",5)

local function status(s)
    State.Status=tostring(s)
    statusLabel.Text="STATUS\n"..State.Status
end

local function title(text,sub)
    local box=new("Frame",{
        Size=UDim2.new(1,0,0,58),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
    },page)
    round(box,10)
    pad(box,11)

    new("TextLabel",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,23),
        Font=Enum.Font.GothamBold,
        Text=text,
        TextColor3=C.text,
        TextSize=16,
        TextXAlignment=Enum.TextXAlignment.Left,
    },box)

    new("TextLabel",{
        BackgroundTransparency=1,
        Position=UDim2.fromOffset(0,23),
        Size=UDim2.new(1,0,0,22),
        Font=Enum.Font.Gotham,
        Text=sub or "",
        TextColor3=C.muted,
        TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,
    },box)
end

local function row(text,left,right)
    local r=new("Frame",{
        Size=UDim2.new(1,0,0,40),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
    },page)
    round(r,9)
    pad(r,9)

    new("TextLabel",{
        BackgroundTransparency=1,
        Size=UDim2.new(.55,0,1,0),
        Font=Enum.Font.Gotham,
        Text=text,
        TextColor3=C.muted,
        TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
    },r)

    new("TextLabel",{
        BackgroundTransparency=1,
        Position=UDim2.new(.55,0,0,0),
        Size=UDim2.new(.45,0,1,0),
        Font=Enum.Font.GothamBold,
        Text=right or "",
        TextColor3=C.text,
        TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Right,
    },r)
end

local function toggle(text,value,callback)
    local r=new("Frame",{
        Size=UDim2.new(1,0,0,44),
        BackgroundColor3=C.panel,
        BorderSizePixel=0,
    },page)
    round(r,9)
    pad(r,9)

    new("TextLabel",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,-64,1,0),
        Font=Enum.Font.GothamMedium,
        Text=text,
        TextColor3=C.text,
        TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,
    },r)

    local b=new("TextButton",{
        Size=UDim2.fromOffset(48,25),
        Position=UDim2.new(1,-48,.5,-12),
        BackgroundColor3=value and C.good or C.panel2,
        Text=value and "ON" or "OFF",
        Font=Enum.Font.GothamBold,
        TextColor3=C.text,
        TextSize=9,
    },r)
    round(b,13)

    b.MouseButton1Click:Connect(function()
        value=not value
        b.Text=value and "ON" or "OFF"
        b.BackgroundColor3=value and C.good or C.panel2
        callback(value)
    end)
end

local function actionButton(text,color,callback)
    local b=new("TextButton",{
        Size=UDim2.new(1,0,0,42),
        BackgroundColor3=color or C.accent,
        Text=text,
        Font=Enum.Font.GothamBold,
        TextColor3=C.text,
        TextSize=11,
    },page)
    round(b,9)
    b.MouseButton1Click:Connect(callback)
    return b
end

local fov=new("Frame",{
    AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(Config.Combat.FOV*2,Config.Combat.FOV*2),
    BackgroundTransparency=1,
    Visible=State.FOV,
    ZIndex=3,
},gui)
round(fov,999)
outline(fov)

local function clear()
    for _,x in ipairs(page:GetChildren()) do
        if x:IsA("Frame") or x:IsA("TextButton") or x:IsA("TextLabel") then
            x:Destroy()
        end
    end
end

local function alive(p)
    local ch=p.Character
    if not ch then return end
    local hum=ch:FindFirstChildOfClass("Humanoid")
    local root=ch:FindFirstChild("HumanoidRootPart")
    if hum and root and hum.Health>0 then
        return ch,hum,root
    end
end

local function enemy(p)
    if p==player then return false end
    if Config.Combat.TeamCheck
        and player.Team
        and p.Team
        and player.Team==p.Team then
        return false
    end
    return true
end

local function acquire()
    local center=Vector2.new(
        camera.ViewportSize.X/2,
        camera.ViewportSize.Y/2
    )

    local best=nil
    local bestScore=math.huge

    for _,p in ipairs(Players:GetPlayers()) do
        if enemy(p) then
            local _,_,root=alive(p)
            if root then
                local d=(camera.CFrame.Position-root.Position).Magnitude
                if d<=Config.Combat.MaxDistance then
                    local screen,visible=camera:WorldToViewportPoint(root.Position)
                    if visible and screen.Z>0 then
                        local sd=(Vector2.new(screen.X,screen.Y)-center).Magnitude
                        if sd<=Config.Combat.FOV then
                            local score=sd+d*.08
                            if score<bestScore then
                                bestScore=score
                                best=p
                            end
                        end
                    end
                end
            end
        end
    end

    State.Target=best
    return best
end

local esp={}

local function removeESP(p)
    local list=esp[p]
    if not list then return end

    for _,x in ipairs(list) do
        if typeof(x)=="RBXScriptConnection" then
            x:Disconnect()
        elseif typeof(x)=="Instance" then
            x:Destroy()
        end
    end

    esp[p]=nil
end

local function addESP(p)
    if p==player or esp[p] then return end

    local ch=p.Character
    if not ch then return end

    local list={}

    local h=new("Highlight",{
        Adornee=ch,
        FillTransparency=.86,
        OutlineTransparency=.1,
        Parent=ch,
    })
    table.insert(list,h)

    local head=ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
    if head and (Config.Visual.ShowNames or Config.Visual.ShowDistance) then
        local bill=new("BillboardGui",{
            Adornee=head,
            Size=UDim2.fromOffset(190,35),
            StudsOffset=Vector3.new(0,3,0),
            AlwaysOnTop=true,
            Parent=head,
        })

        local label=new("TextLabel",{
            BackgroundTransparency=1,
            Size=UDim2.fromScale(1,1),
            Font=Enum.Font.GothamBold,
            TextColor3=C.text,
            TextStrokeTransparency=.5,
            TextSize=10,
        },bill)

        local connection=RunService.RenderStepped:Connect(function()
            if not bill.Parent then return end

            local _,_,root=alive(p)
            if root then
                local distance=(camera.CFrame.Position-root.Position).Magnitude
                local a=Config.Visual.ShowNames and p.Name or ""
                local b=Config.Visual.ShowDistance and string.format("  %.0f studs",distance) or ""
                label.Text=a..b
            end
        end)

        table.insert(list,bill)
        table.insert(list,connection)
    end

    esp[p]=list
end

local function refreshESP()
    for p in pairs(esp) do
        if not State.ESP or not p.Parent then
            removeESP(p)
        end
    end

    if not State.ESP then return end

    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player then addESP(p) end
    end
end

local function renderCombat()
    clear()
    title("Combat","Target, FOV và camera assist")

    toggle("Aim / CamLock",State.Aim,function(v)
        State.Aim=v
        if not v then State.Target=nil end
    end)

    row("FOV Radius",nil,tostring(Config.Combat.FOV).." px")
    row("Max Distance",nil,tostring(Config.Combat.MaxDistance).." studs")
    row("Target",nil,State.Target and State.Target.Name or "None")

    actionButton("ACQUIRE TARGET",C.accent,function()
        local t=acquire()
        status(t and ("Target: "..t.Name) or "Không có target trong FOV")
    end)

    row("Line of Sight",nil,Config.Combat.RequireLineOfSight and "ON" or "OFF")
    row("Team Check",nil,Config.Combat.TeamCheck and "ON" or "OFF")
end

local macroButton

local function renderMacro()
    clear()
    title("Macro","Action / Hold / Delay — có thể sửa trong ClientConfig")

    row("Profile",nil,"Default Macro")
    row("Steps",nil,tostring(#Config.DefaultMacro))

    macroButton=actionButton(
        State.Macro and "STOP MACRO" or "RUN MACRO",
        State.Macro and C.bad or C.good,
        function()
            if State.Macro then
                State.Macro=false
                status("Macro đã dừng")
                renderMacro()
                return
            end

            local t=acquire()
            if not t then
                status("Không có target")
                return
            end

            State.Macro=true
            status("Macro: "..t.Name)

            task.spawn(function()
                for i,step in ipairs(Config.DefaultMacro) do
                    if not State.Macro then break end

                    local target=State.Target
                    if not target or not target.Parent then
                        target=acquire()
                    end

                    if target then
                        RequestAbility:FireServer(
                            tostring(step.Action),
                            target,
                            math.clamp(tonumber(step.Hold) or 0,0,3)
                        )
                    end

                    task.wait(math.max(0,tonumber(step.Delay) or 0))
                end

                State.Macro=false
                status("Macro hoàn tất")
                if page.Parent then
                    renderMacro()
                end
            end)
        end
    )

    for i,step in ipairs(Config.DefaultMacro) do
        row(
            string.format("#%d  %s",i,tostring(step.Action)),
            nil,
            string.format("Hold %.2f | Delay %.2f",step.Hold or 0,step.Delay or 0)
        )
    end
end

local function renderVisual()
    clear()
    title("Visual","ESP và FOV")

    toggle("Player ESP",State.ESP,function(v)
        State.ESP=v
        refreshESP()
    end)

    toggle("FOV Circle",State.FOV,function(v)
        State.FOV=v
        fov.Visible=v
    end)

    row("ESP Names",nil,Config.Visual.ShowNames and "ON" or "OFF")
    row("ESP Distance",nil,Config.Visual.ShowDistance and "ON" or "OFF")
end

local function renderMove()
    clear()
    title("Movement","Movement hợp lệ cho game của bạn")

    toggle("Sprint",State.Sprint,function(v)
        State.Sprint=v
        RequestSettings:FireServer({Sprint=v})
    end)

    toggle("Jump Boost",State.Jump,function(v)
        State.Jump=v
        RequestSettings:FireServer({JumpBoost=v})
    end)

    row("Dash Key",nil,Config.Movement.DashKey.Name)
    row("Dash Speed",nil,tostring(Config.Movement.DashSpeed))
    row("Dash Cooldown",nil,tostring(Config.Movement.DashCooldown).." sec")
end

local function renderSettings()
    clear()
    title("Settings","Thông tin và phím tắt")

    row("Owner",nil,Config.Brand.Owner)
    row("Version",nil,Config.Brand.Version)
    row("Discord",nil,Config.Brand.Discord)
    row("UI Toggle",nil,Config.UI.ToggleKey.Name)
    row("Dash",nil,Config.Movement.DashKey.Name)

    actionButton("RESET LOCAL STATE",C.panel2,function()
        State.Aim=Config.Combat.AimEnabled
        State.ESP=Config.Visual.ESPEnabled
        State.FOV=Config.Visual.ShowFOV
        State.Sprint=Config.Movement.SprintEnabled
        State.Jump=Config.Movement.JumpBoostEnabled
        State.Target=nil
        fov.Visible=State.FOV
        refreshESP()
        status("Đã reset")
        renderSettings()
    end)
end

local function show(name)
    State.Tab=name

    for n,b in pairs(tabs) do
        b.BackgroundColor3=(n==name) and C.accent or C.panel2
        b.TextColor3=(n==name) and C.text or C.muted
    end

    if name=="Combat" then renderCombat()
    elseif name=="Macro" then renderMacro()
    elseif name=="Visual" then renderVisual()
    elseif name=="Movement" then renderMove()
    elseif name=="Settings" then renderSettings()
    end
end

tCombat.MouseButton1Click:Connect(function() show("Combat") end)
tMacro.MouseButton1Click:Connect(function() show("Macro") end)
tVisual.MouseButton1Click:Connect(function() show("Visual") end)
tMove.MouseButton1Click:Connect(function() show("Movement") end)
tSettings.MouseButton1Click:Connect(function() show("Settings") end)

local dragging=false
local dragStart
local startPosition

top.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then

        dragging=true
        dragStart=input.Position
        startPosition=main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch then

        local delta=input.Position-dragStart

        main.Position=UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset+delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset+delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end)

local function toggleUI()
    State.Visible=not State.Visible
    main.Visible=State.Visible
end

hide.MouseButton1Click:Connect(toggleUI)

UserInputService.InputBegan:Connect(function(input,processed)
    if processed then return end

    if input.KeyCode==Config.UI.ToggleKey then
        toggleUI()
        return
    end

    if Config.Movement.DashEnabled
        and input.KeyCode==Config.Movement.DashKey then

        RequestDash:FireServer(camera.CFrame.LookVector)
    end
end)

SyncState.OnClientEvent:Connect(function(data)
    if typeof(data)~="table" then return end

    if data.Type=="Status" then
        status(data.Text)
    elseif data.Type=="AbilityUsed" then
        status("Ability "..tostring(data.Action).." → "..(data.Target and data.Target.Name or "?"))
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(.4)
        if State.ESP then addESP(p) end
    end)
end)

Players.PlayerRemoving:Connect(removeESP)

for _,p in ipairs(Players:GetPlayers()) do
    if p~=player then
        if p.Character then task.defer(addESP,p) end
        p.CharacterAdded:Connect(function()
            task.wait(.4)
            if State.ESP then addESP(p) end
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if State.Aim then
        local target=acquire()

        if target then
            local _,_,root=alive(target)

            if root then
                local current=camera.CFrame
                local desired=CFrame.lookAt(current.Position,root.Position)

                camera.CFrame=current:Lerp(
                    desired,
                    math.clamp(Config.Combat.Smoothness,0,1)
                )
            end
        end
    else
        State.Target=nil
    end
end)

show("Combat")
refreshESP()
status("Sẵn sàng • RightShift = UI")

print("[Dungdx PvP] Client loaded.")
]==]

putSource(system, "ModuleScript", "ClientConfig", clientConfigSource)

local serverScript = putSource(ServerScriptService, "Script", "DungdxPvPServer", serverSource)
putSource(serverScript, "ModuleScript", "Config", serverConfigSource)

putSource(StarterPlayerScripts, "LocalScript", "DungdxPvPClient", clientSource)

print("==============================================")
print("DUNGDY/DUN GDX PVP INSTALLED SUCCESSFULLY")
print("Owner: Dungdx")
print("Discord: https://discord.gg/Hwwa3VYxW6")
print("Version: 2.0.0")
print("Client + Server + Config + Remotes đã được tạo.")
print("Nhấn Play để test.")
print("==============================================")
