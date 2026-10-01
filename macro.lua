--[[
============================================================
  DUNGDX PVP - MACRO UI (Layout theo hình mẫu)
  Version: v13
============================================================
]]
if not game:IsLoaded() then game.Loaded:Wait() end task.wait(.5)
local UIS=game:GetService("UserInputService")
local VIM=game:GetService("VirtualInputManager")
local LP=game:GetService("Players").LocalPlayer
while not LP do task.wait(.1) LP=game:GetService("Players").LocalPlayer end
local P=(pcall(gethui) and gethui()) or LP:WaitForChild("PlayerGui")

-- CONFIG
local WN={"Võ","Kiếm","Súng","Trái"}
local WS={["Võ"]={"Z","X","C","V","F"},["Kiếm"]={"Z","X"},["Súng"]={"Z","X"},["Trái"]={"Z","X","C","V","F"}}
local TM={["Võ"]="Melee",["Kiếm"]="Sword",["Súng"]="Gun",["Trái"]="Blox Fruit"}
local SK={Z=Enum.KeyCode.Z,X=Enum.KeyCode.X,C=Enum.KeyCode.C,V=Enum.KeyCode.V,F=Enum.KeyCode.F}

-- TOOL DETECT
local function toolType(t)
    if not t or not t:IsA("Tool") then return nil end
    local a=t:GetAttribute("ToolType")
    if a then local s=tostring(a)
        if s=="Melee" or s=="Sword" or s=="Gun" or s=="Blox Fruit" then return s end end
    local tip=t.ToolTip
    if tip and tip~="" then local s=string.lower(tip)
        if s:find("melee") or s:find("fighting") then return "Melee" end
        if s:find("sword") then return "Sword" end
        if s:find("gun") then return "Gun" end
        if s:find("fruit") or s:find("blox") then return "Blox Fruit" end end
    local n=string.lower(t.Name)
    if n:find("sword") or n:find("katana") or n:find("blade") or n:find("saber")
        or n:find("cutlass") or n:find("scimitar") or n:find("dagger") then return "Sword" end
    if n:find("gun") or n:find("pistol") or n:find("rifle") or n:find("musket")
        or n:find("slingshot") or n:find("flintlock") then return "Gun" end
    return nil
end

local function equip(label)
    local tt=TM[label] if not tt then return end
    local ch=LP.Character if not ch then return end
    local hum=ch:FindFirstChildOfClass("Humanoid") if not hum then return end
    for _,t in ipairs(ch:GetChildren()) do
        if t:IsA("Tool") and toolType(t)==tt then return end end
    local cur=ch:FindFirstChildOfClass("Tool")
    if cur then pcall(function() hum:UnequipTools() end) task.wait(.08) end
    local bp=LP:FindFirstChild("Backpack")
    if bp then for _,t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and toolType(t)==tt then
            pcall(function() hum:EquipTool(t) end) task.wait(.15) return
        end end end
end

-- STATE
local M,running,stopFlag={},false,false
local function addM(n) local m={name=n,bl={},on=false,open=false} table.insert(M,m) return m end
local function addB(m,w,s,h,d) table.insert(m.bl,{weapon=w or "Võ",skill=s or "Z",hold=h or 0,delay=d or 0}) end
local function valid(w,s) for _,v in ipairs(WS[w] or {}) do if v==s then return true end end return false end
local function press(k,h)
    pcall(function() VIM:SendKeyEvent(true,k,false,game) end)
    task.wait(h>0 and h or .03)
    pcall(function() VIM:SendKeyEvent(false,k,false,game) end)
end
local function run(m)
    if running or not m.on or #m.bl==0 then return end
    running=true stopFlag=false
    for _,b in ipairs(m.bl) do
        if stopFlag then break end
        if not valid(b.weapon,b.skill) then b.skill=(WS[b.weapon] or {"Z"})[1] end
        equip(b.weapon)
        if SK[b.skill] then press(SK[b.skill],b.hold) end
        if b.delay>0 then task.wait(b.delay) end
    end
    running=false
end

-- SAMPLE
do
    local m=addM("Macro 1") addB(m,"Võ","Z",0,.15) addB(m,"Võ","X",0,.2) addB(m,"Kiếm","Z",.1,.3) addB(m,"Súng","X",0,0)
    addM("Macro 2") addM("Macro 3") addM("Macro 4") addM("Macro 5") addM("Macro 6")
end

-- CLEANUP
pcall(function() local o=P:FindFirstChild("DxV13") if o then o:Destroy() end end)
local function cor(p,r) local u=Instance.new("UICorner") u.CornerRadius=UDim.new(0,r or 6) u.Parent=p end
local function str(p,c,t) local s=Instance.new("UIStroke") s.Color=c or Color3.fromRGB(40,60,100) s.Thickness=t or 1 s.Parent=p end
local function pad(p,t,b,l,r)
    local u=Instance.new("UIPadding") u.PaddingTop=UDim.new(0,t or 0) u.PaddingBottom=UDim.new(0,b or t or 0)
    u.PaddingLeft=UDim.new(0,l or t or 0) u.PaddingRight=UDim.new(0,r or t or 0) u.Parent=p
end

-- COLOR PALETTE
local C={
    bg=Color3.fromRGB(10,15,28),
    header=Color3.fromRGB(12,18,32),
    side=Color3.fromRGB(14,20,36),
    sideActive=Color3.fromRGB(20,55,130),
    card=Color3.fromRGB(22,30,48),
    cardDark=Color3.fromRGB(16,22,38),
    input=Color3.fromRGB(18,26,44),
    border=Color3.fromRGB(35,50,80),
    text=Color3.fromRGB(230,238,250),
    textDim=Color3.fromRGB(140,155,180),
    accent=Color3.fromRGB(45,110,240),
    success=Color3.fromRGB(60,200,120),
    danger=Color3.fromRGB(230,70,90),
}

-- GUI ROOT
local G=Instance.new("ScreenGui") G.Name="DxV13" G.ResetOnSpawn=false G.IgnoreGuiInset=true G.DisplayOrder=9999 G.Parent=P

-- MAIN FRAME
local Mn=Instance.new("Frame",G) Mn.Size=UDim2.new(0,760,0,520) Mn.Position=UDim2.new(.5,-380,.5,-260)
Mn.BackgroundColor3=C.bg Mn.BorderSizePixel=0 Mn.Active=true Mn.Draggable=true cor(Mn,12) str(Mn,C.border,1.5)

-- UIScale cho resize
local scale=Instance.new("UIScale",Mn) scale.Scale=1

-- ============ HEADER ============
local H=Instance.new("Frame",Mn) H.Size=UDim2.new(1,0,0,56) H.BackgroundColor3=C.header H.BorderSizePixel=0 cor(H,12)
local Hfix=Instance.new("Frame",H) Hfix.Size=UDim2.new(1,0,0,14) Hfix.Position=UDim2.new(0,0,1,-14) Hfix.BackgroundColor3=C.header Hfix.BorderSizePixel=0

-- Shield icon
local sh=Instance.new("TextLabel",H) sh.Size=UDim2.new(0,32,0,32) sh.Position=UDim2.new(0,16,0,12) sh.BackgroundTransparency=1
sh.Text="🛡" sh.TextSize=24 sh.TextColor3=C.accent sh.Font=Enum.Font.GothamBold

-- Title
local Tt=Instance.new("TextLabel",H) Tt.Size=UDim2.new(0,200,0,22) Tt.Position=UDim2.new(0,58,0,10) Tt.BackgroundTransparency=1
Tt.Text="Dungdx PvP" Tt.TextColor3=C.text Tt.TextSize=18 Tt.Font=Enum.Font.GothamBold Tt.TextXAlignment=Enum.TextXAlignment.Left

-- Version badge
local vb=Instance.new("TextLabel",H) vb.Size=UDim2.new(0,90,0,18) vb.Position=UDim2.new(0,180,0,12) vb.BackgroundTransparency=1
vb.Text="● v2.1.0 BF" vb.TextColor3=Color3.fromRGB(100,180,255) vb.TextSize=12 vb.Font=Enum.Font.GothamMedium vb.TextXAlignment=Enum.TextXAlignment.Left

-- Subtitle
local sb=Instance.new("TextLabel",H) sb.Size=UDim2.new(0,400,0,16) sb.Position=UDim2.new(0,58,0,32) sb.BackgroundTransparency=1
sb.Text="Owner: Dungdx   |   Discord: discord.gg/Hwwa3VYxW6" sb.TextColor3=C.textDim sb.TextSize=11 sb.Font=Enum.Font.Gotham sb.TextXAlignment=Enum.TextXAlignment.Left

-- Nút thu nhỏ (resize -)
local rsm=Instance.new("TextButton",H) rsm.Size=UDim2.new(0,30,0,30) rsm.Position=UDim2.new(1,-160,0,13)
rsm.BackgroundColor3=Color3.fromRGB(35,45,70) rsm.Text="−" rsm.TextColor3=C.text rsm.TextSize=18 rsm.Font=Enum.Font.GothamBold rsm.AutoButtonColor=false cor(rsm,6)
rsm.MouseButton1Click:Connect(function() scale.Scale=math.max(.6,scale.Scale-.1) end)

-- Nút phóng to (resize +)
local rpl=Instance.new("TextButton",H) rpl.Size=UDim2.new(0,30,0,30) rpl.Position=UDim2.new(1,-124,0,13)
rpl.BackgroundColor3=Color3.fromRGB(35,45,70) rpl.Text="+" rpl.TextColor3=C.text rpl.TextSize=18 rpl.Font=Enum.Font.GothamBold rpl.AutoButtonColor=false cor(rpl,6)
rpl.MouseButton1Click:Connect(function() scale.Scale=math.min(1.5,scale.Scale+.1) end)

-- Nút minimize
local mn=Instance.new("TextButton",H) mn.Size=UDim2.new(0,30,0,30) mn.Position=UDim2.new(1,-88,0,13)
mn.BackgroundColor3=Color3.fromRGB(40,55,85) mn.Text="─" mn.TextColor3=C.text mn.TextSize=14 mn.Font=Enum.Font.GothamBold mn.AutoButtonColor=false cor(mn,6)
mn.MouseButton1Click:Connect(function() Mn.Visible=false end)

-- Nút close
local cl=Instance.new("TextButton",H) cl.Size=UDim2.new(0,30,0,30) cl.Position=UDim2.new(1,-52,0,13)
cl.BackgroundColor3=C.danger cl.Text="✕" cl.TextColor3=C.text cl.TextSize=14 cl.Font=Enum.Font.GothamBold cl.AutoButtonColor=false cor(cl,6)
cl.MouseButton1Click:Connect(function() G.Enabled=false end)

-- ============ SIDEBAR ============
local Sd=Instance.new("Frame",Mn) Sd.Size=UDim2.new(0,170,1,-70) Sd.Position=UDim2.new(0,10,0,60)
Sd.BackgroundColor3=C.side Sd.BorderSizePixel=0 cor(Sd,10) str(Sd,C.border)

local tabs={"⚔  Combat","📋  Macro","👁  Visual","🏃  Move","⚙  Setting"}
local activeTab="Macro"
local sideButtons={}

for i,name in ipairs(tabs) do
    local realName=name:gsub("^%S+%s+","")
    local b=Instance.new("TextButton",Sd) b.Size=UDim2.new(1,-16,0,40) b.Position=UDim2.new(0,8,0,8+(i-1)*48)
    b.BackgroundColor3=(realName==activeTab) and C.sideActive or C.side
    b.Text=name b.TextColor3=(realName==activeTab) and Color3.new(1,1,1) or C.textDim
    b.TextSize=14 b.Font=Enum.Font.GothamMedium b.AutoButtonColor=false b.TextXAlignment=Enum.TextXAlignment.Left
    b.Parent=Sd cor(b,8)
    local padL=Instance.new("UIPadding",b) padL.PaddingLeft=UDim.new(0,14)
    sideButtons[realName]=b
    b.MouseButton1Click:Connect(function()
        for n,btn in pairs(sideButtons) do
            btn.BackgroundColor3=(n==realName) and C.sideActive or C.side
            btn.TextColor3=(n==realName) and Color3.new(1,1,1) or C.textDim
        end
    end)
end

-- ============ CONTENT AREA ============
local Co=Instance.new("Frame",Mn) Co.Size=UDim2.new(1,-190,1,-70) Co.Position=UDim2.new(0,180,0,60)
Co.BackgroundColor3=C.bg Co.BorderSizePixel=0 Co.BackgroundTransparency=1

-- Content header
local Ch=Instance.new("Frame",Co) Ch.Size=UDim2.new(1,0,0,44) Ch.BackgroundTransparency=1
local ChI=Instance.new("Frame",Ch) ChI.Size=UDim2.new(0,36,0,36) ChI.Position=UDim2.new(0,0,0,4) ChI.BackgroundColor3=C.accent ChI.BorderSizePixel=0 cor(ChI,8)
local ChIt=Instance.new("TextLabel",ChI) ChIt.Size=UDim2.new(1,0,1,0) ChIt.BackgroundTransparency=1 ChIt.Text="📋" ChIt.TextSize=18 ChIt.TextColor3=Color3.new(1,1,1)
local ChTt=Instance.new("TextLabel",Ch) ChTt.Size=UDim2.new(0,200,1,0) ChTt.Position=UDim2.new(0,46,0,0) ChTt.BackgroundTransparency=1
ChTt.Text="Macro" ChTt.TextColor3=C.text ChTt.TextSize=20 ChTt.Font=Enum.Font.GothamBold ChTt.TextXAlignment=Enum.TextXAlignment.Left

-- Nút + Tạo Macro
local cb=Instance.new("TextButton",Ch) cb.Size=UDim2.new(0,150,0,36) cb.Position=UDim2.new(1,-150,0,4)
cb.BackgroundColor3=C.accent cb.Text="+  Tạo Macro" cb.TextColor3=Color3.new(1,1,1) cb.TextSize=13 cb.Font=Enum.Font.GothamBold cb.AutoButtonColor=false cor(cb,8)

-- Scroll danh sách Macro
local Scr=Instance.new("ScrollingFrame",Co) Scr.Size=UDim2.new(1,0,1,-50) Scr.Position=UDim2.new(0,0,0,50)
Scr.BackgroundTransparency=1 Scr.BorderSizePixel=0 Scr.ScrollBarThickness=4 Scr.ScrollBarImageColor3=C.accent Scr.CanvasSize=UDim2.new()
local LL=Instance.new("UIListLayout",Scr) LL.Padding=UDim.new(0,8) LL.SortOrder=Enum.SortOrder.LayoutOrder
LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scr.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+10) end)

-- ============ DROPDOWN OVERLAY ============
local ov=Instance.new("TextButton",G) ov.Size=UDim2.new(1,0,1,0) ov.BackgroundTransparency=1 ov.Text="" ov.AutoButtonColor=false ov.Visible=false ov.ZIndex=500
local pp=Instance.new("Frame",G) pp.BackgroundColor3=C.card pp.BorderSizePixel=0 pp.Visible=false pp.ZIndex=501 cor(pp,8) str(pp,C.accent,1.5)
local pl=Instance.new("UIListLayout",pp) pl.Padding=UDim.new(0,2) pl.Parent=pp
pad(pp,4)
ov.MouseButton1Click:Connect(function() ov.Visible=false pp.Visible=false end)

local function openDD(b,opts,cb2)
    for _,c in ipairs(pp:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _,o in ipairs(opts) do
        local ob=Instance.new("TextButton",pp) ob.Size=UDim2.new(1,0,0,26) ob.BackgroundColor3=C.card ob.AutoButtonColor=false
        ob.Text=o ob.TextColor3=C.text ob.TextSize=13 ob.Font=Enum.Font.Gotham ob.ZIndex=502 cor(ob,5)
        ob.MouseButton1Click:Connect(function() cb2(o) ov.Visible=false pp.Visible=false end)
    end
    local w=math.max(b.AbsoluteSize.X,100) local h=#opts*26+8 pp.Size=UDim2.new(0,w,0,h)
    local ax=b.AbsolutePosition.X local ay=b.AbsolutePosition.Y+b.AbsoluteSize.Y+4
    if ax+w>G.AbsoluteSize.X-10 then ax=G.AbsoluteSize.X-w-10 end
    pp.Position=UDim2.new(0,ax,0,ay) ov.Visible=true pp.Visible=true
end

local function mkDD(par,getOpts,init,cb2)
    local b=Instance.new("TextButton",par) b.Size=UDim2.new(1,0,1,0) b.BackgroundColor3=C.input b.Text="" b.AutoButtonColor=false cor(b,6) str(b,C.border)
    local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,-26,1,0) l.Position=UDim2.new(0,10,0,0) l.BackgroundTransparency=1
    l.Text=init l.TextColor3=C.text l.TextSize=13 l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left
    local a=Instance.new("TextLabel",b) a.Size=UDim2.new(0,20,1,0) a.Position=UDim2.new(1,-24,0,0) a.BackgroundTransparency=1
    a.Text="⌄" a.TextColor3=C.textDim a.TextSize=14 a.Font=Enum.Font.GothamBold
    b.MouseButton1Click:Connect(function() openDD(b,getOpts(),function(v) l.Text=v cb2(v) end) end)
    return b,function(v) l.Text=v end
end

-- ============ MACRO ROW ============
local ref
local function mkMH(m,o)
    local r=Instance.new("Frame",Scr) r.Size=UDim2.new(1,-4,0,48) r.BackgroundColor3=C.card r.BorderSizePixel=0 r.LayoutOrder=o*100 cor(r,10) str(r,C.border)
    
    local a=Instance.new("TextButton",r) a.Size=UDim2.new(0,24,0,24) a.Position=UDim2.new(0,14,0,12) a.BackgroundTransparency=1 a.AutoButtonColor=false
    a.Text=m.open and "⌄" or "›" a.TextColor3=C.textDim a.TextSize=18 a.Font=Enum.Font.GothamBold
    
    local ic=Instance.new("TextLabel",r) ic.Size=UDim2.new(0,22,0,22) ic.Position=UDim2.new(0,44,0,13) ic.BackgroundTransparency=1
    ic.Text="📄" ic.TextSize=15
    
    local t=Instance.new("TextLabel",r) t.Size=UDim2.new(0,300,1,0) t.Position=UDim2.new(0,74,0,0) t.BackgroundTransparency=1
    t.Text=m.name t.TextColor3=C.text t.TextSize=15 t.Font=Enum.Font.GothamMedium t.TextXAlignment=Enum.TextXAlignment.Left
    
    local rn=Instance.new("TextButton",r) rn.Size=UDim2.new(0,42,0,24) rn.Position=UDim2.new(1,-60,0,12) rn.AutoButtonColor=false
    rn.BackgroundColor3=C.success rn.Text="▶" rn.TextColor3=Color3.new(1,1,1) rn.TextSize=11 rn.Font=Enum.Font.GothamBold cor(rn,12)
    
    local tg=Instance.new("TextButton",r) tg.Size=UDim2.new(0,44,0,24) tg.Position=UDim2.new(1,-110,0,12) tg.AutoButtonColor=false
    tg.BackgroundColor3=m.on and C.accent or Color3.fromRGB(45,55,80)
    tg.Text="" tg.Font=Enum.Font.GothamBold cor(tg,12)
    local tk=Instance.new("Frame",tg) tk.Size=UDim2.new(0,18,0,18) tk.Position=m.on and UDim2.new(1,-20,0,3) or UDim2.new(0,3,0,3)
    tk.BackgroundColor3=Color3.new(1,1,1) tk.BorderSizePixel=0 tk.Parent=tg cor(tk,9)
    
    a.MouseButton1Click:Connect(function() m.open=not m.open ref() end)
    tg.MouseButton1Click:Connect(function() m.on=not m.on ref() end)
    rn.MouseButton1Click:Connect(function() task.spawn(function() run(m) end) end)
end

-- BLOCK ROW (theo hình: label hàng + input hàng)
local function mkBR(m,b,bi,mi)
    if not valid(b.weapon,b.skill) then b.skill=(WS[b.weapon] or {"Z"})[1] end
    
    local container=Instance.new("Frame",Scr) container.Size=UDim2.new(1,-4,0,60) container.BackgroundColor3=C.cardDark container.BorderSizePixel=0
    container.LayoutOrder=mi*100+bi cor(container,10) str(container,C.border)
    
    -- Row 1: chỉ là hàng đầu của block (không có label riêng, để giống hình)
    local fd=Instance.new("Frame",container) fd.Size=UDim2.new(1,-16,0,32) fd.Position=UDim2.new(0,8,0,14) fd.BackgroundTransparency=1
    local gr=Instance.new("UIGridLayout",fd) gr.CellSize=UDim2.new(.24,-6,1,0) gr.CellPadding=UDim2.new(0,8,0,0)
    
    local wS=Instance.new("Frame",fd) wS.BackgroundTransparency=1 wS.LayoutOrder=1
    local sS=Instance.new("Frame",fd) sS.BackgroundTransparency=1 sS.LayoutOrder=2
    local setSL
    
    mkDD(wS,function() return WN end,b.weapon,function(v)
        b.weapon=v
        if not valid(v,b.skill) then b.skill=(WS[v] or {"Z"})[1] if setSL then setSL(b.skill) end end end)
    local _,sl=mkDD(sS,function() return WS[b.weapon] or {"Z"} end,b.skill,function(v) b.skill=v end)
    setSL=sl
    
    local hS=Instance.new("Frame",fd) hS.BackgroundColor3=C.input hS.LayoutOrder=3 cor(hS,6) str(hS,C.border)
    local hB=Instance.new("TextBox",hS) hB.Size=UDim2.new(1,-8,1,0) hB.Position=UDim2.new(0,4,0,0) hB.BackgroundTransparency=1
    hB.Text=string.format("%.2f",b.hold) hB.TextColor3=C.text hB.TextSize=13 hB.Font=Enum.Font.Gotham hB.ClearTextOnFocus=false
    hB.FocusLost:Connect(function() local n=tonumber(hB.Text) if n and n>=0 then b.hold=n end hB.Text=string.format("%.2f",b.hold) end)
    
    local dS=Instance.new("Frame",fd) dS.BackgroundColor3=C.input dS.LayoutOrder=4 cor(dS,6) str(dS,C.border)
    local dB=Instance.new("TextBox",dS) dB.Size=UDim2.new(1,-8,1,0) dB.Position=UDim2.new(0,4,0,0) dB.BackgroundTransparency=1
    dB.Text=string.format("%.2f",b.delay) dB.TextColor3=C.text dB.TextSize=13 dB.Font=Enum.Font.Gotham dB.ClearTextOnFocus=false
    dB.FocusLost:Connect(function() local n=tonumber(dB.Text) if n and n>=0 then b.delay=n end dB.Text=string.format("%.2f",b.delay) end)
    
    -- Nút xóa block
    local dl=Instance.new("TextButton",container) dl.Size=UDim2.new(0,20,0,20) dl.Position=UDim2.new(1,-26,0,4)
    dl.BackgroundColor3=C.danger dl.Text="✕" dl.TextColor3=Color3.new(1,1,1) dl.TextSize=10 dl.Font=Enum.Font.GothamBold dl.AutoButtonColor=false cor(dl,5)
    dl.MouseButton1Click:Connect(function() table.remove(m.bl,bi) ref() end)
end

-- HEADER ROW cho labels (hiện 1 lần dưới mỗi macro mở)
local function mkBlockHeader(m,mi)
    local r=Instance.new("Frame",Scr) r.Size=UDim2.new(1,-4,0,26) r.BackgroundTransparency=1 r.LayoutOrder=mi*100-1
    local fd=Instance.new("Frame",r) fd.Size=UDim2.new(1,-16,0,26) fd.Position=UDim2.new(0,8,0,0) fd.BackgroundTransparency=1
    local gr=Instance.new("UIGridLayout",fd) gr.CellSize=UDim2.new(.24,-6,1,0) gr.CellPadding=UDim.new(0,8,0,0)
    local labels={"Vũ khí","Chiêu thức","Hold","Delay"}
    for i,txt in ipairs(labels) do
        local l=Instance.new("TextLabel",fd) l.BackgroundTransparency=1 l.Text=txt l.TextColor3=C.textDim
        l.TextSize=12 l.Font=Enum.Font.GothamMedium l.TextXAlignment=Enum.TextXAlignment.Left l.LayoutOrder=i
    end
end

-- REFRESH
ref=function()
    ov.Visible=false pp.Visible=false
    for _,c in ipairs(Scr:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    for i,m in ipairs(M) do
        mkMH(m,i)
        if m.open then
            if #m.bl>0 then mkBlockHeader(m,i) end
            for bi,b in ipairs(m.bl) do mkBR(m,b,bi,i) end
            -- Nút thêm block
            local ar=Instance.new("Frame",Scr) ar.Size=UDim2.new(1,-4,0,32) ar.BackgroundTransparency=1 ar.LayoutOrder=i*100+99
            local ab=Instance.new("TextButton",ar) ab.Size=UDim2.new(1,0,1,0) ab.BackgroundColor3=C.cardDark ab.AutoButtonColor=false
            ab.Text="+ Thêm Block" ab.TextColor3=C.textDim ab.TextSize=12 ab.Font=Enum.Font.Gotham cor(ab,8) str(ab,C.border)
            ab.MouseButton1Click:Connect(function() addB(m,"Võ","Z",0,.15) ref() end)
        end
    end
    task.wait(.05) Scr.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+10)
end

cb.MouseButton1Click:Connect(function() local m=addM("Macro "..#M) m.on=true m.open=true addB(m,"Võ","Z",0,.15) ref() end)

-- FLOATING BUTTON (bật/tắt UI)
local fb=Instance.new("TextButton",G) fb.Size=UDim2.new(0,50,0,50) fb.Position=UDim2.new(0,20,0,200) fb.AutoButtonColor=false
fb.BackgroundColor3=C.accent fb.Text="⚡" fb.TextColor3=Color3.new(1,1,1) fb.TextSize=22 fb.Font=Enum.Font.GothamBold
fb.Active=true fb.Draggable=true cor(fb,25) str(fb,Color3.fromRGB(60,85,155),2)
fb.MouseButton1Click:Connect(function() Mn.Visible=not Mn.Visible end)

-- KEYBIND
UIS.InputBegan:Connect(function(i,g) if g then return end if i.KeyCode==Enum.KeyCode.RightShift then Mn.Visible=not Mn.Visible end end)

ref()
print("✅ Dungdx Macro v13 loaded - RightShift để mở/đóng")