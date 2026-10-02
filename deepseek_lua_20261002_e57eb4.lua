--[[ Dungdx PvP v5.0 · Universal · Mobile + PC · PvP Only ]]
if not game:IsLoaded() then game.Loaded:Wait() end task.wait(.3)
if _G.DungdxPvP then pcall(function() _G.DungdxPvP:Destroy() end) task.wait(.15) end

local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local TW=game:GetService("TweenService")
local VIM=game:GetService("VirtualInputManager")
local Cam=WS.CurrentCamera
local LP=Players.LocalPlayer

-- ============================================================
-- UNIVERSAL FALLBACK CHAIN
-- ============================================================
local function getGUI()
    local ok,h=pcall(function() return gethui and gethui() end)
    if ok and typeof(h)=="Instance" then return h end
    ok,h=pcall(function() return game:GetService("CoreGui") end)
    if ok and h then return h end
    return LP:WaitForChild("PlayerGui",10)
end

-- key send: try every known method in order
local function sendKey(kc,down)
    local ok=pcall(function() VIM:SendKeyEvent(down,kc,false,game) end)
    if ok then return true end
    if down then
        if syn and syn.keypress then ok=pcall(syn.keypress,kc)if ok then return true end end
        if keypress then ok=pcall(keypress,kc)if ok then return true end end
    else
        if syn and syn.keyrelease then ok=pcall(syn.keyrelease,kc)if ok then return true end end
        if keyrelease then ok=pcall(keyrelease,kc)if ok then return true end end
    end
    return false
end

local function tapKey(kc,hold)
    hold=hold or 0.03
    sendKey(kc,true)
    task.wait(hold)
    sendKey(kc,false)
end

-- mouse move: rare, silent aim fallback
local function moveMouse(dx,dy)
    if mousemoverel then pcall(mousemoverel,dx,dy)return true end
    if syn and syn.mousemoverel then pcall(syn.mousemoverel,dx,dy)return true end
    local ok=pcall(function() VIM:SendMouseMoveEvent(dx,dy,false) end)
    return ok
end

local GUI_PARENT=getGUI()
if not GUI_PARENT then error("[DungdxPvP] No GUI parent") end

local AVATAR="rbxassetid://85947137194506"
local LOGO_IMG="rbxassetid://91434453184512"

local T={Bg=Color3.fromRGB(10,15,30),Sidebar=Color3.fromRGB(13,20,40),Panel=Color3.fromRGB(19,27,50),
Card=Color3.fromRGB(23,33,60),CardHi=Color3.fromRGB(30,42,76),Input=Color3.fromRGB(12,16,28),
Accent=Color3.fromRGB(59,130,246),Accent2=Color3.fromRGB(37,99,235),On=Color3.fromRGB(59,130,246),
Off=Color3.fromRGB(42,54,88),Text=Color3.fromRGB(230,240,255),Sub=Color3.fromRGB(120,140,180),
Stroke=Color3.fromRGB(38,52,92),Danger=Color3.fromRGB(239,68,68),Green=Color3.fromRGB(80,240,180),
Red=Color3.fromRGB(255,80,100),Gold=Color3.fromRGB(251,191,36)}

local function cr(p,r)local c=Instance.new("UICorner",p)c.CornerRadius=UDim.new(0,r or 8)return c end
local function sk(p,c,t,tr)local s=Instance.new("UIStroke",p)s.Color=c or T.Stroke s.Thickness=t or 1
s.Transparency=tr or 0 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border return s end
local function dg(f,h)h=h or f local on,st,sp h.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
on=true st=i.Position sp=f.Position end end)
UIS.InputChanged:Connect(function(i)if on and(i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-st
f.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)end end)
UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch then on=false end end)end

local GUI=Instance.new("ScreenGui")
GUI.Name="DungdxPvP"
GUI.ResetOnSpawn=false
GUI.IgnoreGuiInset=true
GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder=9999
GUI.Parent=GUI_PARENT

local DESIGN_W,DESIGN_H=780,540
local Main=Instance.new("Frame",GUI)
Main.AnchorPoint=Vector2.new(.5,.5)
Main.Position=UDim2.fromScale(.5,.5)
Main.Size=UDim2.fromOffset(DESIGN_W,DESIGN_H)
Main.BackgroundColor3=T.Bg
Main.BorderSizePixel=0
Main.ClipsDescendants=true
cr(Main,14)sk(Main,T.Stroke,1.5)

local R={auto=1,user=1}
local uiS=Instance.new("UIScale",Main)uiS.Scale=1
local function autoS()
    local vp=Cam.ViewportSize
    return math.clamp(math.min(math.max(vp.X-24,220)/DESIGN_W,math.max(vp.Y-48,220)/DESIGN_H),.65,1.35)
end
local applyScale=function()
    R.auto=autoS()
    uiS.Scale=R.auto*R.user
    if _G.__tgl then
        local s=R.auto*R.user
        local b=math.floor(52*math.clamp(s,.85,1.2))
        _G.__tgl.Size=UDim2.fromOffset(b,b)
    end
end
Cam:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
_G.__setUS=function(v)R.user=v/100 applyScale() end

-- HEADER
local H=Instance.new("Frame",Main)H.Size=UDim2.new(1,0,0,58)H.BackgroundColor3=T.Sidebar
H.BorderSizePixel=0 cr(H,14)
local hc=Instance.new("Frame",H)hc.Size=UDim2.new(1,0,0,16)hc.Position=UDim2.new(0,0,1,-16)
hc.BackgroundColor3=T.Sidebar hc.BorderSizePixel=0 dg(Main,H)
local Lg=Instance.new("Frame",H)Lg.Size=UDim2.fromOffset(38,38)Lg.Position=UDim2.fromOffset(14,10)
Lg.BackgroundColor3=Color3.fromRGB(245,245,248)Lg.BorderSizePixel=0 cr(Lg,10)
local LgImg=Instance.new("ImageLabel",Lg)LgImg.Size=UDim2.fromScale(1,1)
LgImg.BackgroundTransparency=1 LgImg.Image=LOGO_IMG LgImg.ScaleType=Enum.ScaleType.Fit LgImg.ZIndex=2 cr(LgImg,10)
local Tl=Instance.new("TextLabel",H)Tl.Size=UDim2.fromOffset(220,22)Tl.Position=UDim2.fromOffset(60,8)
Tl.BackgroundTransparency=1 Tl.Text="Dungdx PvP"Tl.Font=Enum.Font.GothamBold Tl.TextSize=17
Tl.TextColor3=T.Text Tl.TextXAlignment=Enum.TextXAlignment.Left
local Sb=Instance.new("TextLabel",H)Sb.Size=UDim2.fromOffset(220,16)Sb.Position=UDim2.fromOffset(60,30)
Sb.BackgroundTransparency=1 Sb.Text="v5.0 · Universal"Sb.Font=Enum.Font.Gotham Sb.TextSize=11
Sb.TextColor3=T.Accent Sb.TextXAlignment=Enum.TextXAlignment.Left
local Cl=Instance.new("TextButton",H)Cl.Size=UDim2.fromOffset(34,34)Cl.AnchorPoint=Vector2.new(1,0)
Cl.Position=UDim2.new(1,-12,0,12)Cl.BackgroundColor3=T.Card Cl.Text="X"
Cl.Font=Enum.Font.GothamBold Cl.TextSize=15 Cl.TextColor3=T.Text Cl.BorderSizePixel=0
Cl.AutoButtonColor=false cr(Cl,8)
local Mn=Instance.new("TextButton",H)Mn.Size=UDim2.fromOffset(34,34)Mn.AnchorPoint=Vector2.new(1,0)
Mn.Position=UDim2.new(1,-52,0,12)Mn.BackgroundColor3=T.Card Mn.Text="-"
Mn.Font=Enum.Font.GothamBold Mn.TextSize=18 Mn.TextColor3=T.Text Mn.BorderSizePixel=0
Mn.AutoButtonColor=false cr(Mn,8)

-- BODY
local Bd=Instance.new("Frame",Main)Bd.Size=UDim2.new(1,0,1,-58)Bd.Position=UDim2.new(0,0,0,58)
Bd.BackgroundTransparency=1
local SB=Instance.new("Frame",Bd)SB.Size=UDim2.new(0,160,1,0)SB.BackgroundColor3=T.Sidebar
SB.BorderSizePixel=0
local NL=Instance.new("Frame",SB)NL.Size=UDim2.new(1,-12,1,-12)NL.Position=UDim2.fromOffset(6,6)
NL.BackgroundTransparency=1
local NLL=Instance.new("UIListLayout",NL)NLL.Padding=UDim.new(0,4)NLL.SortOrder=Enum.SortOrder.LayoutOrder
local Ct=Instance.new("Frame",Bd)Ct.Size=UDim2.new(1,-160,1,0)Ct.Position=UDim2.new(0,160,0,0)
Ct.BackgroundTransparency=1

local Pgs={}local NBs={}
local function mkPage()
    local p=Instance.new("ScrollingFrame",Ct)
    p.Size=UDim2.new(1,-20,1,-12)p.Position=UDim2.fromOffset(10,6)
    p.BackgroundTransparency=1 p.BorderSizePixel=0
    p.ScrollBarThickness=3 p.ScrollBarImageColor3=T.Accent p.ScrollBarImageTransparency=.4
    p.CanvasSize=UDim2.new()p.AutomaticCanvasSize=Enum.AutomaticSize.Y p.Visible=false
    local l=Instance.new("UIListLayout",p)l.Padding=UDim.new(0,8)l.SortOrder=Enum.SortOrder.LayoutOrder
    return p
end
local function addTab(id,ico,lbl,ord)
    local pg=mkPage()Pgs[id]=pg
    local b=Instance.new("TextButton",NL)
    b.Size=UDim2.new(1,0,0,44)b.BackgroundColor3=T.Sidebar
    b.Text=""b.AutoButtonColor=false b.BorderSizePixel=0 b.LayoutOrder=ord cr(b,10)
    local icBox=Instance.new("Frame",b)icBox.Size=UDim2.fromOffset(30,30)
    icBox.Position=UDim2.fromOffset(10,7)
    icBox.BackgroundColor3=T.Sub icBox.BackgroundTransparency=.85 icBox.BorderSizePixel=0 cr(icBox,8)
    local ic=Instance.new("TextLabel",icBox)ic.Size=UDim2.fromScale(1,1)ic.BackgroundTransparency=1
    ic.Text=ico ic.Font=Enum.Font.GothamBold ic.TextSize=16 ic.TextColor3=T.Sub
    local lb=Instance.new("TextLabel",b)lb.Size=UDim2.new(1,-48,1,0)lb.Position=UDim2.fromOffset(48,0)
    lb.BackgroundTransparency=1 lb.Text=lbl lb.Font=Enum.Font.GothamMedium lb.TextSize=13
    lb.TextColor3=T.Sub lb.TextXAlignment=Enum.TextXAlignment.Left
    local ac=Instance.new("Frame",b)ac.Size=UDim2.new(0,3,0,22)ac.Position=UDim2.new(0,0,.5,-11)
    ac.BackgroundColor3=T.Accent ac.BorderSizePixel=0 ac.Visible=false cr(ac,2)
    local function sA(a)
        ac.Visible=a b.BackgroundColor3=a and T.Card or T.Sidebar
        ic.TextColor3=a and Color3.fromRGB(255,255,255) or T.Sub
        icBox.BackgroundColor3=a and T.Accent or T.Sub
        icBox.BackgroundTransparency=a and .3 or .85
        lb.TextColor3=a and T.Text or T.Sub
    end
    b.MouseButton1Click:Connect(function()
        for k,p in pairs(Pgs)do p.Visible=(k==id) end
        for k,fn in pairs(NBs)do fn(k==id) end
    end)
    NBs[id]=sA
    return pg
end

local pAim=addTab("Aim","🎯","Aim",1)
local pCombat=addTab("Combat","⚔️","Combat",2)
local pESP=addTab("ESP","👁️","ESP",3)
local pMove=addTab("Move","🏃","Move",4)
local pSet=addTab("Set","⚙️","Settings",5)
for k,p in pairs(Pgs)do p.Visible=(k=="Aim") end
for k,fn in pairs(NBs)do fn(k=="Aim") end

-- UI builders
local function mSec(par,title,desc,ord)
    local c=Instance.new("Frame",par)
    c.Size=UDim2.new(1,0,0,0)c.AutomaticSize=Enum.AutomaticSize.Y
    c.BackgroundColor3=T.Panel c.BorderSizePixel=0 c.LayoutOrder=ord
    cr(c,12)sk(c,T.Stroke,1)
    local t=Instance.new("Frame",c)t.Size=UDim2.new(1,0,0,46)t.BackgroundTransparency=1
    local tl=Instance.new("TextLabel",t)tl.Size=UDim2.new(1,-20,0,20)tl.Position=UDim2.fromOffset(14,6)
    tl.BackgroundTransparency=1 tl.Text=title tl.Font=Enum.Font.GothamBold tl.TextSize=14
    tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
    local dl=Instance.new("TextLabel",t)dl.Size=UDim2.new(1,-20,0,16)dl.Position=UDim2.fromOffset(14,26)
    dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=11
    dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
    local r=Instance.new("Frame",c)r.Size=UDim2.new(1,-20,0,0)r.Position=UDim2.fromOffset(10,46)
    r.BackgroundTransparency=1 r.AutomaticSize=Enum.AutomaticSize.Y
    local rl=Instance.new("UIListLayout",r)rl.Padding=UDim.new(0,4)rl.SortOrder=Enum.SortOrder.LayoutOrder
    local pd=Instance.new("Frame",c)pd.Size=UDim2.new(1,0,0,10)pd.Position=UDim2.new(0,0,1,0)
    pd.AnchorPoint=Vector2.new(0,1)pd.BackgroundTransparency=1
    return r
end
local function mRow(par,ord,h)
    local r=Instance.new("Frame",par)
    r.Size=UDim2.new(1,0,0,h or 46)
    r.BackgroundColor3=T.Card r.BorderSizePixel=0 r.LayoutOrder=ord cr(r,8)
    r.MouseEnter:Connect(function()TW:Create(r,TweenInfo.new(.15),{BackgroundColor3=T.CardHi}):Play()end)
    r.MouseLeave:Connect(function()TW:Create(r,TweenInfo.new(.15),{BackgroundColor3=T.Card}):Play()end)
    return r
end
local function mTog(par,name,desc,def,ord,cb)
    local r=mRow(par,ord)local st=def or false
    local tl=Instance.new("TextLabel",r)tl.Size=UDim2.new(1,-84,0,18)tl.Position=UDim2.fromOffset(14,6)
    tl.BackgroundTransparency=1 tl.Text=name tl.Font=Enum.Font.GothamMedium tl.TextSize=13
    tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
    local dl=Instance.new("TextLabel",r)dl.Size=UDim2.new(1,-84,0,14)dl.Position=UDim2.fromOffset(14,25)
    dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=10
    dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
    local sw=Instance.new("Frame",r)sw.Size=UDim2.fromOffset(48,26)sw.AnchorPoint=Vector2.new(1,.5)
    sw.Position=UDim2.new(1,-14,.5,0)sw.BackgroundColor3=st and T.On or T.Off
    sw.BorderSizePixel=0 cr(sw,13)
    local kn=Instance.new("Frame",sw)kn.Size=UDim2.fromOffset(22,22)kn.AnchorPoint=Vector2.new(0,.5)
    kn.Position=st and UDim2.new(1,-24,.5,0) or UDim2.new(0,2,.5,0)
    kn.BackgroundColor3=Color3.fromRGB(245,245,250)kn.BorderSizePixel=0 cr(kn,11)
    local b=Instance.new("TextButton",r)b.Size=UDim2.fromScale(1,1)b.BackgroundTransparency=1 b.Text=""
    local function set(v)
        st=v
        TW:Create(sw,TweenInfo.new(.15),{BackgroundColor3=st and T.On or T.Off}):Play()
        TW:Create(kn,TweenInfo.new(.15),{Position=st and UDim2.new(1,-24,.5,0) or UDim2.new(0,2,.5,0)}):Play()
    end
    b.MouseButton1Click:Connect(function()set(not st)if cb then cb(st)end end)
    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then set(not st)if cb then cb(st)end end
    end)
    return{Get=function()return st end,Set=set}
end
local function mSld(par,name,desc,mn,mx,def,ord,cb)
    local r=mRow(par,ord,58)
    local tl=Instance.new("TextLabel",r)tl.Size=UDim2.new(1,-84,0,16)tl.Position=UDim2.fromOffset(14,6)
    tl.BackgroundTransparency=1 tl.Text=name tl.Font=Enum.Font.GothamMedium tl.TextSize=13
    tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
    local vb=Instance.new("TextLabel",r)vb.Size=UDim2.fromOffset(60,22)vb.AnchorPoint=Vector2.new(1,0)
    vb.Position=UDim2.new(1,-12,0,6)vb.BackgroundColor3=T.Panel vb.Text=tostring(def)
    vb.Font=Enum.Font.GothamMedium vb.TextSize=11 vb.TextColor3=T.Text vb.BorderSizePixel=0 cr(vb,6)
    local dl=Instance.new("TextLabel",r)dl.Size=UDim2.new(1,-84,0,14)dl.Position=UDim2.fromOffset(14,22)
    dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=10
    dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
    local tr=Instance.new("Frame",r)tr.Size=UDim2.new(1,-24,0,8)tr.AnchorPoint=Vector2.new(0,1)
    tr.Position=UDim2.new(0,12,1,-12)tr.BackgroundColor3=T.Off tr.BorderSizePixel=0 cr(tr,4)
    local fl=Instance.new("Frame",tr)fl.Size=UDim2.new((def-mn)/(mx-mn),0,1,0)fl.BackgroundColor3=T.Accent
    fl.BorderSizePixel=0 cr(fl,4)
    local kn=Instance.new("Frame",tr)kn.AnchorPoint=Vector2.new(.5,.5)
    kn.Position=UDim2.new((def-mn)/(mx-mn),0,.5,0)kn.Size=UDim2.fromOffset(18,18)
    kn.BackgroundColor3=Color3.fromRGB(255,255,255)kn.BorderSizePixel=0 cr(kn,9)
    local drag=false
    local function up(i)
        local rl=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local v=math.floor(mn+(mx-mn)*rl+.5)
        fl.Size=UDim2.new(rl,0,1,0)kn.Position=UDim2.new(rl,0,.5,0)
        vb.Text=tostring(v)if cb then cb(v)end
    end
    tr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true up(i)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then up(i)end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=false
        end
    end)
    return {Set=function(v)
        local rl=(v-mn)/(mx-mn)
        fl.Size=UDim2.new(rl,0,1,0)kn.Position=UDim2.new(rl,0,.5,0)
        vb.Text=tostring(v)if cb then cb(v)end
    end}
end
local function mBtn(par,name,desc,bTxt,ord,cb,dngr)
    local r=mRow(par,ord)
    local tl=Instance.new("TextLabel",r)tl.Size=UDim2.new(.55,0,0,18)tl.Position=UDim2.fromOffset(14,6)
    tl.BackgroundTransparency=1 tl.Text=name tl.Font=Enum.Font.GothamMedium tl.TextSize=13
    tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
    local dl=Instance.new("TextLabel",r)dl.Size=UDim2.new(.55,0,0,14)dl.Position=UDim2.fromOffset(14,25)
    dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=10
    dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
    local b=Instance.new("TextButton",r)b.Size=UDim2.fromOffset(110,32)b.AnchorPoint=Vector2.new(1,.5)
    b.Position=UDim2.new(1,-12,.5,0)b.BackgroundColor3=dngr and T.Danger or T.Accent
    b.Text=bTxt b.Font=Enum.Font.GothamBold b.TextSize=11 b.TextColor3=Color3.fromRGB(255,255,255)
    b.BorderSizePixel=0 b.AutoButtonColor=false cr(b,8)
    if cb then b.MouseButton1Click:Connect(cb)end
    return b
end
local function mInp(par,name,desc,def,ord,cb)
    local r=mRow(par,ord)
    local tl=Instance.new("TextLabel",r)tl.Size=UDim2.new(.5,0,0,18)tl.Position=UDim2.fromOffset(14,6)
    tl.BackgroundTransparency=1 tl.Text=name tl.Font=Enum.Font.GothamMedium tl.TextSize=13
    tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
    local dl=Instance.new("TextLabel",r)dl.Size=UDim2.new(.5,0,0,14)dl.Position=UDim2.fromOffset(14,25)
    dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=10
    dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
    local bx=Instance.new("Frame",r)bx.Size=UDim2.fromOffset(120,32)bx.AnchorPoint=Vector2.new(1,.5)
    bx.Position=UDim2.new(1,-12,.5,0)bx.BackgroundColor3=T.Input bx.BorderSizePixel=0 cr(bx,8)sk(bx,T.Stroke,1)
    local tb=Instance.new("TextBox",bx)tb.Size=UDim2.new(1,-12,1,0)tb.Position=UDim2.fromOffset(6,0)
    tb.BackgroundTransparency=1 tb.Text=def or ""tb.TextColor3=T.Text tb.TextSize=12
    tb.Font=Enum.Font.Gotham tb.ClearTextOnFocus=false tb.TextXAlignment=Enum.TextXAlignment.Left
    tb.FocusLost:Connect(function()if cb then cb(tb.Text)end end)
    return tb
end

-- ============================================================
-- ESP
-- ============================================================
local ESP={on=false,name=true,dist=true,hp=false,color=Color3.fromRGB(255,80,100),trans=.55}
local espC={}
local function mkESP(p)
    if espC[p]then return espC[p]end
    local ch=p.Character if not ch then return end
    local hrp=ch:FindFirstChild("HumanoidRootPart")if not hrp then return end
    local hl=Instance.new("Highlight",ch)
    hl.FillColor=ESP.color hl.FillTransparency=ESP.trans
    hl.OutlineColor=ESP.color hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    local bb=Instance.new("BillboardGui",ch)
    bb.Size=UDim2.fromOffset(160,50)bb.StudsOffset=Vector3.new(0,3.2,0)
    bb.AlwaysOnTop=true bb.Adornee=hrp
    local nl=Instance.new("TextLabel",bb)nl.Name="Name"
    nl.Size=UDim2.new(1,0,0,18)nl.BackgroundTransparency=1
    nl.Text=p.Name nl.TextColor3=ESP.color
    nl.TextStrokeTransparency=.3 nl.TextSize=14 nl.Font=Enum.Font.GothamBold
    local dl=Instance.new("TextLabel",bb)dl.Name="Dist"
    dl.Size=UDim2.new(1,0,0,14)dl.Position=UDim2.new(0,0,0,20)
    dl.BackgroundTransparency=1 dl.Text="0m"dl.TextColor3=Color3.fromRGB(220,230,255)
    dl.TextStrokeTransparency=.3 dl.TextSize=12 dl.Font=Enum.Font.Gotham
    local hp=Instance.new("TextLabel",bb)hp.Name="HpText"
    hp.Size=UDim2.new(1,0,0,14)hp.Position=UDim2.new(0,0,0,34)
    hp.BackgroundTransparency=1 hp.Text=""hp.TextColor3=Color3.fromRGB(80,240,130)
    hp.TextStrokeTransparency=.3 hp.TextSize=12 hp.Font=Enum.Font.GothamBold
    espC[p]={hl=hl,bb=bb}
    return espC[p]
end
local function rmESP(p)
    local c=espC[p]
    if c then pcall(function()c.hl:Destroy()end)pcall(function()c.bb:Destroy()end)espC[p]=nil end
end
local espAcc=0
RS.RenderStepped:Connect(function(dt)
    if not ESP.on then return end
    espAcc=espAcc+dt
    if espAcc<0.08 then return end
    espAcc=0
    local myCh=LP.Character
    local myHRP=myCh and myCh:FindFirstChild("HumanoidRootPart")
    for _,p in ipairs(Players:GetPlayers())do
        if p~=LP then
            local tCh=p.Character
            if tCh then
                local tHRP=tCh:FindFirstChild("HumanoidRootPart")
                local tHum=tCh:FindFirstChildOfClass("Humanoid")
                if tHRP then
                    local e=espC[p]
                    if not e then e=mkESP(p)end
                    if e and e.bb and e.bb.Parent then
                        e.hl.FillColor=ESP.color e.hl.FillTransparency=ESP.trans e.hl.OutlineColor=ESP.color
                        local nameL=e.bb:FindFirstChild("Name")
                        local distL=e.bb:FindFirstChild("Dist")
                        local hpL=e.bb:FindFirstChild("HpText")
                        if nameL then nameL.Visible=ESP.name nameL.Text=p.Name nameL.TextColor3=ESP.color end
                        if distL and myHRP then
                            distL.Visible=ESP.dist
                            local d=(tHRP.Position-myHRP.Position).Magnitude
                            distL.Text=string.format("%dm",math.floor(d))
                        end
                        if hpL and tHum then
                            hpL.Visible=ESP.hp
                            hpL.Text=string.format("%d/%d",math.floor(tHum.Health),math.floor(tHum.MaxHealth))
                        end
                    end
                end
            end
        end
    end
    for p in pairs(espC)do
        if not p.Parent or not p.Character or not p.Character.Parent then rmESP(p)end
    end
end)
Players.PlayerRemoving:Connect(rmESP)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(.5)
        if espC[p]then rmESP(p)end
        if ESP.on then mkESP(p)end
    end)
end)
LP.CharacterAdded:Connect(function()
    task.wait(.5)
    for p in pairs(espC)do if p~=LP then rmESP(p)end end
end)

-- ============================================================
-- AIMBOT
-- ============================================================
local Aim={on=false,fov=250,smooth=.22,sort="Distance",wall=false,target=nil,conn=nil}
local AIM_KEY=Enum.KeyCode.E

local function isEnemy(p)
    return p~=LP
end
local function getHRP(p)
    if not p or not p.Character then return nil end
    local hum=p.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return nil end
    return p.Character:FindFirstChild("HumanoidRootPart"),hum
end
local function wallClear(from,to,ignore)
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances=ignore
    local r=WS:Raycast(from,to-from,params)
    return r==nil
end
local function getAimTarget()
    local myCh=LP.Character if not myCh then return nil end
    local myHRP=myCh:FindFirstChild("HumanoidRootPart")if not myHRP then return nil end
    local vp=Cam.ViewportSize local center=Vector2.new(vp.X/2,vp.Y/2)
    local best,bestScore=nil,math.huge
    for _,p in ipairs(Players:GetPlayers())do
        if isEnemy(p)then
            local hrp,hum=getHRP(p)
            if hrp then
                local sp,onScreen,depth=Cam:WorldToViewportPoint(hrp.Position)
                if onScreen and depth>0 then
                    local fovD=(Vector2.new(sp.X,sp.Y)-center).Magnitude
                    if fovD<=Aim.fov then
                        if not Aim.wall or wallClear(Cam.CFrame.Position,hrp.Position,{myCh,Cam})then
                            local dist=(hrp.Position-myHRP.Position).Magnitude
                            local score
                            if Aim.sort=="Distance"then score=dist
                            elseif Aim.sort=="Health"then score=hum.Health
                            else score=fovD end
                            if score<bestScore then best,bestScore=p,score end
                        end
                    end
                end
            end
        end
    end
    return best
end
local function startAim()
    if Aim.conn then return end
    Aim.conn=RS.RenderStepped:Connect(function()
        if not Aim.on then Aim.target=nil return end
        local t=getAimTarget()Aim.target=t
        if not t then return end
        local hrp=getHRP(t)if not hrp then return end
        local goal=CFrame.new(Cam.CFrame.Position,hrp.Position+Vector3.new(0,1,0))
        Cam.CFrame=Cam.CFrame:Lerp(goal,Aim.smooth)
    end)
end
local function stopAim()
    if Aim.conn then pcall(function()Aim.conn:Disconnect()end)Aim.conn=nil end
    Aim.target=nil
end

-- ============================================================
-- COMBAT
-- ============================================================
local Combat={
    combo={on=false,keys={"Z","X","C","V","F"},delays={.12,.12,.12,.12,.12},hold=0.03,loop=false,thread=nil,hotkey="Q"},
    autoKen={on=false,delay=.15,thread=nil},
    autoObs={on=false,delay=.2,thread=nil},
    autoMelee={on=false,delay=.12,thread=nil,range=20},
    antiFling={on=false,thread=nil},
    antiStun={on=false,thread=nil},
}

local function comboLoop()
    if Combat.combo.thread then return end
    Combat.combo.thread=task.spawn(function()
        while Combat.combo.on do
            for i,k in ipairs(Combat.combo.keys)do
                if not Combat.combo.on then break end
                local kc=Enum.KeyCode[k]
                if kc then
                    tapKey(kc,Combat.combo.hold)
                    task.wait(Combat.combo.delays[i] or .12)
                end
            end
            if not Combat.combo.loop then
                Combat.combo.on=false
                Combat.combo.thread=nil
                return
            end
            task.wait(.05)
        end
        Combat.combo.thread=nil
    end)
end

local function autoKenLoop()
    if Combat.autoKen.thread then return end
    Combat.autoKen.thread=task.spawn(function()
        while Combat.autoKen.on do
            tapKey(Enum.KeyCode.K,0.03)
            task.wait(Combat.autoKen.delay)
        end
        Combat.autoKen.thread=nil
    end)
end

local function autoObsLoop()
    if Combat.autoObs.thread then return end
    Combat.autoObs.thread=task.spawn(function()
        while Combat.autoObs.on do
            tapKey(Enum.KeyCode.H,0.03)
            task.wait(Combat.autoObs.delay)
        end
        Combat.autoObs.thread=nil
    end)
end

local function autoMeleeLoop()
    if Combat.autoMelee.thread then return end
    Combat.autoMelee.thread=task.spawn(function()
        while Combat.autoMelee.on do
            local ch=LP.Character
            if ch then
                local hrp=ch:FindFirstChild("HumanoidRootPart")
                local tool=ch:FindFirstChildOfClass("Tool")
                if hrp and tool then
                    -- only activate if enemy nearby
                    local near=false
                    for _,p in ipairs(Players:GetPlayers())do
                        if isEnemy(p)then
                            local ehrp=getHRP(p)
                            if ehrp then
                                local d=(ehrp.Position-hrp.Position).Magnitude
                                if d<=Combat.autoMelee.range then near=true break end
                            end
                        end
                    end
                    if near then pcall(function()tool:Activate()end)end
                end
            end
            task.wait(Combat.autoMelee.delay)
        end
        Combat.autoMelee.thread=nil
    end)
end

local function antiFlingLoop()
    if Combat.antiFling.thread then return end
    Combat.antiFling.thread=task.spawn(function()
        while Combat.antiFling.on do
            local ch=LP.Character
            if ch then
                local hrp=ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,c in ipairs(hrp:GetChildren())do
                        if c:IsA("BodyMover")then pcall(function()c:Destroy()end)end
                    end
                    if hrp.AssemblyLinearVelocity.Magnitude>300 then
                        hrp.AssemblyLinearVelocity=Vector3.zero
                    end
                    if hrp.AssemblyAngularVelocity.Magnitude>50 then
                        hrp.AssemblyAngularVelocity=Vector3.zero
                    end
                end
                local hum=ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.PlatformStand then hum.PlatformStand=false end
            end
            task.wait(.06)
        end
        Combat.antiFling.thread=nil
    end)
end

local function antiStunLoop()
    if Combat.antiStun.thread then return end
    Combat.antiStun.thread=task.spawn(function()
        while Combat.antiStun.on do
            local ch=LP.Character
            if ch then
                local hum=ch:FindFirstChildOfClass("Humanoid")
                if hum then
                    for _,s in ipairs({
                        Enum.HumanoidStateType.FallingDown,
                        Enum.HumanoidStateType.Ragdoll,
                        Enum.HumanoidStateType.PlatformStanding,
                        Enum.HumanoidStateType.Frozen,
                    })do
                        pcall(function()hum:SetStateEnabled(s,false)end)
                    end
                end
            end
            task.wait(.4)
        end
        Combat.antiStun.thread=nil
    end)
end

-- ============================================================
-- MOVEMENT
-- ============================================================
local Mv={
    Speed={on=false,val=90},
    Jump={on=false,val=120},
    Fly={on=false,bv=nil,bg=nil,conn=nil,speed=90,upH=false,downH=false,ui=nil},
    Noclip={on=false,conns={},loop=nil},
}
local baseWS=16 baseJP=50
local function gH()
    local ch=LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid") or nil
end
task.spawn(function()
    while Main.Parent do
        local h=gH()
        if h and not Mv.Speed.on then baseWS=h.WalkSpeed end
        if h and not Mv.Jump.on then baseJP=h.UseJumpPower and h.JumpPower or h.JumpHeight end
        task.wait(2)
    end
end)
RS.Heartbeat:Connect(function()
    if Mv.Fly.on then return end
    local h=gH()if not h then return end
    if Mv.Speed.on then
        if h.WalkSpeed~=Mv.Speed.val then h.WalkSpeed=Mv.Speed.val end
    end
    if Mv.Jump.on then
        h.UseJumpPower=true
        if h.JumpPower~=Mv.Jump.val then h.JumpPower=Mv.Jump.val end
    end
end)

local function buildFlyUI()
    if Mv.Fly.ui then return Mv.Fly.ui end
    local wrap=Instance.new("Frame",GUI)
    wrap.Name="__FlyUI"wrap.BackgroundTransparency=1
    wrap.Size=UDim2.fromOffset(100,200)wrap.Position=UDim2.new(1,-120,.5,-100)
    wrap.ZIndex=200 wrap.Visible=false
    local function mkBtn(txt,y,color)
        local b=Instance.new("TextButton",wrap)
        b.Size=UDim2.fromOffset(88,88)b.Position=UDim2.fromOffset(0,y)
        b.BackgroundColor3=color b.BackgroundTransparency=.25
        b.Text=txt b.TextColor3=Color3.new(1,1,1)b.TextSize=24
        b.Font=Enum.Font.GothamBold b.AutoButtonColor=false b.ZIndex=201 cr(b,44)
        local s=Instance.new("UIStroke",b)s.Color=color s.Thickness=2 s.Transparency=.4
        return b
    end
    local upB=mkBtn("▲",0,Color3.fromRGB(60,140,220))
    local dnB=mkBtn("▼",100,Color3.fromRGB(80,80,100))
    local function hold(b,set)
        b.MouseButton1Down:Connect(function()set(true)b.BackgroundTransparency=0 end)
        b.MouseButton1Up:Connect(function()set(false)b.BackgroundTransparency=.25 end)
        b.MouseLeave:Connect(function()set(false)b.BackgroundTransparency=.25 end)
        b.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then set(true)b.BackgroundTransparency=0 end end)
        b.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then set(false)b.BackgroundTransparency=.25 end end)
    end
    hold(upB,function(v)Mv.Fly.upH=v end)
    hold(dnB,function(v)Mv.Fly.downH=v end)
    Mv.Fly.ui=wrap
    return wrap
end

local function flyStart()
    if Mv.Fly.on then return end
    local ch=LP.Character if not ch then return end
    local hrp=ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    Mv.Fly.on=true
    Mv.Fly.bv=Instance.new("BodyVelocity")
    Mv.Fly.bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    Mv.Fly.bv.P=125000
    Mv.Fly.bv.Velocity=Vector3.zero
    Mv.Fly.bv.Parent=hrp
    Mv.Fly.bg=Instance.new("BodyGyro")
    Mv.Fly.bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
    Mv.Fly.bg.P=20000 Mv.Fly.bg.D=500
    Mv.Fly.bg.CFrame=hrp.CFrame
    Mv.Fly.bg.Parent=hrp
    buildFlyUI().Visible=true
    Mv.Fly.conn=RS.Heartbeat:Connect(function()
        if not Mv.Fly.on then return end
        local ch=LP.Character if not ch then return end
        local hrp=ch:FindFirstChild("HumanoidRootPart")
        if not hrp or not Mv.Fly.bv or not Mv.Fly.bg then return end
        local camCF=Cam.CFrame
        local look=camCF.LookVector
        local flat=Vector3.new(look.X,0,look.Z)
        if flat.Magnitude<.01 then flat=Vector3.new(0,0,-1)end
        flat=flat.Unit
        local right=Vector3.new(camCF.RightVector.X,0,camCF.RightVector.Z).Unit
        Mv.Fly.bg.CFrame=CFrame.lookAt(hrp.Position,hrp.Position+flat)
        local md=gH()and gH().MoveDirection or Vector3.zero
        local vel=Vector3.zero
        if md.Magnitude>.05 then
            local fb=md:Dot(flat)local lr=md:Dot(right)
            vel=flat*fb+right*lr
            if vel.Magnitude>.01 then vel=vel.Unit*Mv.Fly.speed end
        end
        if Mv.Fly.upH then vel=vel+Vector3.new(0,Mv.Fly.speed,0)end
        if Mv.Fly.downH then vel=vel-Vector3.new(0,Mv.Fly.speed,0)end
        Mv.Fly.bv.Velocity=vel
    end)
end
local function flyStop()
    if not Mv.Fly.on then return end
    Mv.Fly.on=false
    if Mv.Fly.conn then pcall(function()Mv.Fly.conn:Disconnect()end)Mv.Fly.conn=nil end
    if Mv.Fly.bv then pcall(function()Mv.Fly.bv:Destroy()end)Mv.Fly.bv=nil end
    if Mv.Fly.bg then pcall(function()Mv.Fly.bg:Destroy()end)Mv.Fly.bg=nil end
    Mv.Fly.upH=false Mv.Fly.downH=false
    if Mv.Fly.ui then Mv.Fly.ui.Visible=false end
end

local function noclipApply(ch)
    for _,p in ipairs(ch:GetDescendants())do
        if p:IsA("BasePart")then
            if p:GetAttribute("__nc")==nil then p:SetAttribute("__nc",p.CanCollide)end
            p.CanCollide=false
        end
    end
end
local function noclipRestore(ch)
    for _,p in ipairs(ch:GetDescendants())do
        if p:IsA("BasePart")then
            local o=p:GetAttribute("__nc")
            if o~=nil then p.CanCollide=o p:SetAttribute("__nc",nil)end
        end
    end
end
local function noclipStart()
    if Mv.Noclip.on then return end
    Mv.Noclip.on=true Mv.Noclip.conns={}
    local function hook(ch)
        noclipApply(ch)
        table.insert(Mv.Noclip.conns,ch.DescendantAdded:Connect(function(p)
            if Mv.Noclip.on and p:IsA("BasePart")then
                if p:GetAttribute("__nc")==nil then p:SetAttribute("__nc",p.CanCollide)end
                p.CanCollide=false
            end
        end))
    end
    if LP.Character then hook(LP.Character)end
    table.insert(Mv.Noclip.conns,LP.CharacterAdded:Connect(function(ch)
        task.wait(.3)if Mv.Noclip.on then hook(ch)end end))
    Mv.Noclip.loop=RS.Heartbeat:Connect(function()
        if not Mv.Noclip.on then return end
        local ch=LP.Character if not ch then return end
        for _,p in ipairs(ch:GetDescendants())do
            if p:IsA("BasePart")and p.CanCollide then p.CanCollide=false end
        end
    end)
end
local function noclipStop()
    if not Mv.Noclip.on then return end
    Mv.Noclip.on=false
    for _,c in ipairs(Mv.Noclip.conns)do pcall(function()c:Disconnect()end)end
    Mv.Noclip.conns={}
    if Mv.Noclip.loop then pcall(function()Mv.Noclip.loop:Disconnect()end)Mv.Noclip.loop=nil end
    if LP.Character then noclipRestore(LP.Character)end
end

-- ============================================================
-- UI: AIM
-- ============================================================
local a1=mSec(pAim,"Aimbot","Tu dong khoa camera vao dich gan nhat trong FOV",1)
mTog(a1,"Bat Aimbot","Camera tu dong xoay ve muc tieu",false,1,function(v)
    Aim.on=v
    if v then startAim()else stopAim()end
end)
mSld(a1,"FOV","Ban kinh vong FOV (pixel)",50,700,250,2,function(v)Aim.fov=v end)
mSld(a1,"Smooth","Do muot (cao = xoay cham tu nhien hon)",5,60,22,3,function(v)Aim.smooth=v/100 end)
mBtn(a1,"Doi uu tien","Gan / Mau / FOV","Gan",4,function(b)
    if Aim.sort=="Distance"then Aim.sort="Health"b.Text="Mau"
    elseif Aim.sort=="Health"then Aim.sort="FOV"b.Text="FOV"
    else Aim.sort="Distance"b.Text="Gan"end
end)
mTog(a1,"Wall Check","Chi aim khi khong co vat can",false,5,function(v)Aim.wall=v end)

-- ============================================================
-- UI: COMBAT
-- ============================================================
local c1=mSec(pCombat,"Auto Combo","Tu dong bam Z X C V F theo thu tu",1)
mTog(c1,"Bat Auto Combo","Chay combo khi bat",false,1,function(v)
    Combat.combo.on=v
    if v then comboLoop()end
end)
mTog(c1,"Loop","Combo lap lai lien tuc",false,2,function(v)Combat.combo.loop=v end)
mInp(c1,"Thu tu phim","Vi du: Z,X,C,V,F", "Z,X,C,V,F",3,function(v)
    local keys={}
    for k in v:gmatch("[^,]+")do
        k=k:gsub("%s",""):upper()
        if #k>=1 then table.insert(keys,k)end
    end
    if #keys>0 then Combat.combo.keys=keys end
end)
mSld(c1,"Delay (ms)","Khoang nghi giua cac phim",50,800,120,4,function(v)
    for i=1,#Combat.combo.delays do Combat.combo.delays[i]=v/1000 end
end)

local c2=mSec(pCombat,"Auto Haki","Spam Ken / Observation",2)
mTog(c2,"Auto Ken (K)","Spam Ken Haki lien tuc",false,1,function(v)
    Combat.autoKen.on=v
    if v then autoKenLoop()end
end)
mSld(c2,"Ken Delay (ms)","Khoang nghi giua cac lan spam",50,600,150,2,function(v)
    Combat.autoKen.delay=v/1000
end)
mTog(c2,"Auto Observation (H)","Spam Observation Haki lien tuc",false,3,function(v)
    Combat.autoObs.on=v
    if v then autoObsLoop()end
end)
mSld(c2,"Obs Delay (ms)","Khoang nghi giua cac lan spam",50,600,200,4,function(v)
    Combat.autoObs.delay=v/1000
end)

local c3=mSec(pCombat,"Auto Melee","Tu dong danh khi dich trong tam",3)
mTog(c3,"Bat Auto Melee","Kich hoat tool khi dich trong tam",false,1,function(v)
    Combat.autoMelee.on=v
    if v then autoMeleeLoop()end
end)
mSld(c3,"Tam danh","Ban kinh kich hoat (studs)",8,60,20,2,function(v)
    Combat.autoMelee.range=v
end)
mSld(c3,"Delay (ms)","Khoang nghi giua cac cu danh",50,600,120,3,function(v)
    Combat.autoMelee.delay=v/1000
end)

local c4=mSec(pCombat,"Defense","Chong bi nem / khong che",4)
mTog(c4,"Anti Fling","Chan bi nem ra khoi map",false,1,function(v)
    Combat.antiFling.on=v
    if v then antiFlingLoop()end
end)
mTog(c4,"Anti Stun","Chong FallingDown / Ragdoll / Frozen",false,2,function(v)
    Combat.antiStun.on=v
    if v then antiStunLoop()end
end)

-- ============================================================
-- UI: ESP
-- ============================================================
local e1=mSec(pESP,"Player ESP","Highlight + ten + khoang cach",1)
mTog(e1,"Bat ESP","Hien thi tat ca player khac",false,1,function(v)ESP.on=v end)
mTog(e1,"Ten","Hien thi ten",true,2,function(v)ESP.name=v end)
mTog(e1,"Khoang cach","Hien thi khoang cach",true,3,function(v)ESP.dist=v end)
mTog(e1,"Mau","Hien thi so mau",false,4,function(v)ESP.hp=v end)
mSld(e1,"Do trong suot","Highlight opacity %",0,100,55,5,function(v)ESP.trans=v/100 end)
mBtn(e1,"Doi mau","Xoay vong mau ESP","Doi",6,function()
    local pool={
        Color3.fromRGB(255,80,100),
        Color3.fromRGB(255,200,60),
        Color3.fromRGB(80,240,130),
        Color3.fromRGB(0,220,255),
        Color3.fromRGB(200,120,255),
    }
    local ix=1
    for k,c in ipairs(pool)do if c==ESP.color then ix=k%#pool+1 break end end
    ESP.color=pool[ix]
end)

-- ============================================================
-- UI: MOVE
-- ============================================================
local m1=mSec(pMove,"Toc do","Override WalkSpeed moi frame",1)
mTog(m1,"Speed","Bat tang toc do chay",false,1,function(v)Mv.Speed.on=v end)
mSld(m1,"Gia tri","Toc do chay",16,200,90,2,function(v)Mv.Speed.val=v end)
mTog(m1,"Jump","Bat tang luc nhay",false,3,function(v)Mv.Jump.on=v end)
mSld(m1,"Jump Value","Luc nhay",50,500,120,4,function(v)Mv.Jump.val=v end)

local m2=mSec(pMove,"Fly","Bay theo huong camera + nut ▲▼ cho mobile",2)
mTog(m2,"Bat Fly","BodyVelocity + BodyGyro",false,1,function(v)
    if v then flyStart()else flyStop()end
end)
mSld(m2,"Toc do Fly","Toc do bay (studs/s)",30,400,90,2,function(v)Mv.Fly.speed=v end)

local m3=mSec(pMove,"Noclip","Xuyen qua vat the",3)
mTog(m3,"Noclip","Tat CanCollide tren character",false,1,function(v)
    if v then noclipStart()else noclipStop()end
end)

-- ============================================================
-- UI: SETTINGS
-- ============================================================
local s1=mSec(pSet,"Giao dien","",1)
mSld(s1,"Trong suot UI","Do mo toan bo UI",0,80,0,1,function(v)
    local a=v/100
    for _,i in ipairs(Main:GetDescendants())do
        if i:IsA("GuiObject")and i.BackgroundTransparency<1 then
            if i:GetAttribute("__bt")==nil then i:SetAttribute("__bt",i.BackgroundTransparency)end
            local o=i:GetAttribute("__bt")
            i.BackgroundTransparency=o+(1-o)*a
        end
    end
end)
mSld(s1,"Kich thuoc UI","Phong to / thu nho",65,150,100,2,function(v)
    if _G.__setUS then _G.__setUS(v)end
end)

local s2=mSec(pSet,"Test","Kiem tra chuc nang",2)
mBtn(s2,"Test Key Send","Bam phim Z mot lan, xem game co nhan khong","Test Z",1,function()
    tapKey(Enum.KeyCode.Z,0.1)
    print("[Dungdx] Sent Z key event")
end)
mBtn(s2,"Reset UI","Dat lai vi tri goc","Reset",2,function()
    Main.Position=UDim2.fromScale(.5,.5)
    if _G.__setUS then _G.__setUS(100)end
    task.spawn(applyScale)
end,true)

-- ============================================================
-- TOGGLE FLOAT BUTTON
-- ============================================================
local Tgl=Instance.new("TextButton",GUI)
Tgl.Size=UDim2.fromOffset(58,58)
Tgl.Position=UDim2.new(0,16,.5,-29)
Tgl.BackgroundColor3=T.Accent2
Tgl.Text=""Tgl.BorderSizePixel=0
Tgl.AutoButtonColor=false Tgl.Visible=false
cr(Tgl,29)sk(Tgl,T.Accent,2,.3)dg(Tgl)
local tImg=Instance.new("ImageLabel",Tgl)
tImg.Size=UDim2.fromScale(1,1)tImg.BackgroundTransparency=1
tImg.Image=AVATAR tImg.ScaleType=Enum.ScaleType.Crop tImg.ZIndex=2 cr(tImg,29)
_G.__tgl=Tgl

Tgl.MouseButton1Click:Connect(function()Main.Visible=true Tgl.Visible=false end)
Cl.MouseButton1Click:Connect(function()GUI.Enabled=false end)
Mn.MouseButton1Click:Connect(function()Main.Visible=false Tgl.Visible=true end)

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        Main.Visible=not Main.Visible
        Tgl.Visible=not Main.Visible
    end
end)

task.defer(applyScale)

-- ============================================================
-- GLOBAL EXPORT
-- ============================================================
_G.DungdxPvP={
    GUI=GUI,Main=Main,
    ESP=ESP,Combat=Combat,Aim=Aim,Movement=Mv,
    Destroy=function()
        pcall(stopAim)
        pcall(flyStop)
        pcall(noclipStop)
        for _,p in ipairs(Players:GetPlayers())do rmESP(p)end
        Combat.combo.on=false
        Combat.autoKen.on=false
        Combat.autoObs.on=false
        Combat.autoMelee.on=false
        Combat.antiFling.on=false
        Combat.antiStun.on=false
        Mv.Speed.on=false
        Mv.Jump.on=false
        pcall(function()GUI:Destroy()end)
        _G.DungdxPvP=nil
        _G.__tgl=nil
    end,
}

print("[Dungdx PvP v5] Loaded · universal · mobile+PC · PvP only")