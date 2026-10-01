--[[ Dungdx PvP · Blox Fruits · v2.1.0 · Ultimate Fix Lag + No Fog ]]
if not game:IsLoaded() then game.Loaded:Wait() end task.wait(.3)
if _G.DungdxPvP then pcall(function() _G.DungdxPvP:Destroy() end) end

local Players=game:GetService("Players")local UIS=game:GetService("UserInputService")
local VIM=game:GetService("VirtualInputManager")local TW=game:GetService("TweenService")
local RS=game:GetService("RunService")local WS=game:GetService("Workspace")
local LT=game:GetService("Lighting")local CP=game:GetService("ContentProvider")
local Cam=WS.CurrentCamera local LP=Players.LocalPlayer

local GUI_PARENT=select(2,pcall(gethui))or LP:WaitForChild("PlayerGui")
local AVATAR="rbxassetid://85947137194506"
local LOGO_IMG="rbxassetid://91434453184512"

local T={Bg=Color3.fromRGB(10,15,30),Sidebar=Color3.fromRGB(13,20,40),Panel=Color3.fromRGB(19,27,50),
Card=Color3.fromRGB(23,33,60),CardHi=Color3.fromRGB(30,42,76),Input=Color3.fromRGB(12,16,28),
Accent=Color3.fromRGB(59,130,246),Accent2=Color3.fromRGB(37,99,235),On=Color3.fromRGB(59,130,246),
Off=Color3.fromRGB(42,54,88),Text=Color3.fromRGB(230,240,255),Sub=Color3.fromRGB(120,140,180),
Stroke=Color3.fromRGB(38,52,92),Danger=Color3.fromRGB(239,68,68),Green=Color3.fromRGB(80,240,180),
Red=Color3.fromRGB(255,80,100)}

local function cr(p,r)local c=Instance.new("UICorner",p)c.CornerRadius=UDim.new(0,r or 8)return c end
local function sk(p,c,t,tr)local s=Instance.new("UIStroke",p)s.Color=c or T.Stroke s.Thickness=t or 1
s.Transparency=tr or 0 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border return s end
local function gr(p,a,b,r)local g=Instance.new("UIGradient",p)g.Color=ColorSequence.new(a,b)
g.Rotation=r or 45 return g end
local function dg(f,h)h=h or f local on,st,sp h.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
on=true st=i.Position sp=f.Position end end)
UIS.InputChanged:Connect(function(i)if on and(i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-st
f.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)end end)
UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch then on=false end end)end

local GUI=Instance.new("ScreenGui")GUI.Name="DungdxPvP"GUI.ResetOnSpawn=false
GUI.IgnoreGuiInset=true GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling GUI.DisplayOrder=9999
GUI.Parent=GUI_PARENT

local DESIGN_W,DESIGN_H=820,520
local Main=Instance.new("Frame",GUI)Main.AnchorPoint=Vector2.new(.5,.5)Main.Position=UDim2.fromScale(.5,.5)
Main.Size=UDim2.fromOffset(DESIGN_W,DESIGN_H)Main.BackgroundColor3=T.Bg Main.BorderSizePixel=0
Main.ClipsDescendants=true cr(Main,14)sk(Main,T.Stroke,1.5)
local R={device="pc",auto=1,user=1}local uiS=Instance.new("UIScale",Main)uiS.Scale=1
local function dev()local vp=Cam.ViewportSize
if(UIS.TouchEnabled and not UIS.KeyboardEnabled)or vp.X<720 then return "mobile"
elseif vp.X<1100 then return "tablet"else return "pc"end end
local function autoS()local vp=Cam.ViewportSize return math.clamp(math.min(math.max(vp.X-24,200)/DESIGN_W,
math.max(vp.Y-48,200)/DESIGN_H),.70,1.35)end
local applyLayout=nil
local applyScale=function()R.device=dev()R.auto=autoS()uiS.Scale=R.auto*R.user
if _G.__tgl then local s=R.auto*R.user local b=math.floor(52*math.clamp(s,.85,1.2))
_G.__tgl.Size=UDim2.fromOffset(b,b)end if applyLayout then applyLayout()end end
Cam:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
_G.__setUS=function(v)R.user=v/100 applyScale()end

-- HEADER
local H=Instance.new("Frame",Main)H.Size=UDim2.new(1,0,0,60)H.BackgroundColor3=T.Sidebar
H.BorderSizePixel=0 cr(H,14)
local hc=Instance.new("Frame",H)hc.Size=UDim2.new(1,0,0,16)hc.Position=UDim2.new(0,0,1,-16)
hc.BackgroundColor3=T.Sidebar hc.BorderSizePixel=0 dg(Main,H)
local Lg=Instance.new("Frame",H)Lg.Size=UDim2.fromOffset(40,40)Lg.Position=UDim2.fromOffset(14,10)
Lg.BackgroundColor3=Color3.fromRGB(245,245,248)Lg.BorderSizePixel=0 cr(Lg,10)
local LgImg=Instance.new("ImageLabel",Lg)LgImg.Size=UDim2.fromScale(1,1)LgImg.BackgroundTransparency=1
LgImg.Image=LOGO_IMG LgImg.ScaleType=Enum.ScaleType.Fit LgImg.ZIndex=2 cr(LgImg,10)
local Tl=Instance.new("TextLabel",H)Tl.Size=UDim2.fromOffset(220,22)Tl.Position=UDim2.fromOffset(64,10)
Tl.BackgroundTransparency=1 Tl.Text="Dungdx PvP"Tl.Font=Enum.Font.GothamBold Tl.TextSize=17
Tl.TextColor3=T.Text Tl.TextXAlignment=Enum.TextXAlignment.Left
local Sb=Instance.new("TextLabel",H)Sb.Size=UDim2.fromOffset(220,16)Sb.Position=UDim2.fromOffset(64,32)
Sb.BackgroundTransparency=1 Sb.Text="Blox Fruits Script"Sb.Font=Enum.Font.Gotham Sb.TextSize=12
Sb.TextColor3=T.Accent Sb.TextXAlignment=Enum.TextXAlignment.Left
local Vr=Instance.new("TextLabel",H)Vr.Size=UDim2.fromOffset(62,24)Vr.Position=UDim2.fromOffset(240,18)
Vr.BackgroundColor3=T.Accent2 Vr.Text="v2.1.0"Vr.Font=Enum.Font.GothamBold Vr.TextSize=11
Vr.TextColor3=Color3.fromRGB(220,235,255)Vr.BorderSizePixel=0 cr(Vr,12)
local Cl=Instance.new("TextButton",H)Cl.Size=UDim2.fromOffset(30,30)Cl.AnchorPoint=Vector2.new(1,0)
Cl.Position=UDim2.new(1,-14,0,15)Cl.BackgroundColor3=T.Card Cl.Text="X"Cl.Font=Enum.Font.GothamBold
Cl.TextSize=14 Cl.TextColor3=T.Text Cl.BorderSizePixel=0 Cl.AutoButtonColor=false cr(Cl,8)
local Mn=Instance.new("TextButton",H)Mn.Size=UDim2.fromOffset(30,30)Mn.AnchorPoint=Vector2.new(1,0)
Mn.Position=UDim2.new(1,-50,0,15)Mn.BackgroundColor3=T.Card Mn.Text="-"Mn.Font=Enum.Font.GothamBold
Mn.TextSize=16 Mn.TextColor3=T.Text Mn.BorderSizePixel=0 Mn.AutoButtonColor=false cr(Mn,8)

-- BODY
local Bd=Instance.new("Frame",Main)Bd.Size=UDim2.new(1,0,1,-60)Bd.Position=UDim2.new(0,0,0,60)
Bd.BackgroundTransparency=1
local SB=Instance.new("Frame",Bd)SB.Size=UDim2.new(0,170,1,0)SB.BackgroundColor3=T.Sidebar
SB.BorderSizePixel=0
local SBc=Instance.new("Frame",SB)SBc.Size=UDim2.new(0,16,1,0)SBc.Position=UDim2.new(1,-16,0,0)
SBc.BackgroundColor3=T.Sidebar SBc.BorderSizePixel=0
local NL=Instance.new("Frame",SB)NL.Size=UDim2.new(1,-16,1,-90)NL.Position=UDim2.fromOffset(8,8)
NL.BackgroundTransparency=1 local NLL=Instance.new("UIListLayout",NL)
NLL.Padding=UDim.new(0,4)NLL.SortOrder=Enum.SortOrder.LayoutOrder

-- PROFILE
local Ow=Instance.new("Frame",SB)Ow.Size=UDim2.new(1,-16,0,72)Ow.AnchorPoint=Vector2.new(.5,1)
Ow.Position=UDim2.new(.5,0,1,-8)Ow.BackgroundColor3=T.Card Ow.BorderSizePixel=0 cr(Ow,10)
sk(Ow,T.Stroke,1)
local OI=Instance.new("Frame",Ow)OI.Size=UDim2.fromOffset(40,40)OI.Position=UDim2.fromOffset(8,16)
OI.BackgroundColor3=T.Accent2 OI.BorderSizePixel=0 cr(OI,20)sk(OI,T.Accent,2,.3)
local OIImg=Instance.new("ImageLabel",OI)OIImg.Size=UDim2.fromScale(1,1)
OIImg.BackgroundTransparency=1 OIImg.Image=""OIImg.ScaleType=Enum.ScaleType.Crop OIImg.ZIndex=2 cr(OIImg,20)
task.spawn(function()
    local ok,thumb=pcall(function()return Players:GetUserThumbnailAsync(LP.UserId,
    Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)end)
    if ok and thumb and thumb~=""then OIImg.Image=thumb
    else OIImg.Image=LOGO_IMG OIImg.ScaleType=Enum.ScaleType.Fit end
end)
local ON1=Instance.new("TextLabel",Ow)ON1.Size=UDim2.new(1,-60,0,16)ON1.Position=UDim2.fromOffset(56,6)
ON1.BackgroundTransparency=1 ON1.Text="Player"ON1.Font=Enum.Font.GothamBold ON1.TextSize=12
ON1.TextColor3=T.Text ON1.TextXAlignment=Enum.TextXAlignment.Left ON1.TextTruncate=Enum.TextTruncate.AtEnd
local ON2=Instance.new("TextLabel",Ow)ON2.Size=UDim2.new(1,-60,0,14)ON2.Position=UDim2.fromOffset(56,22)
ON2.BackgroundTransparency=1 ON2.Text="@username"ON2.Font=Enum.Font.Gotham ON2.TextSize=10
ON2.TextColor3=T.Accent ON2.TextXAlignment=Enum.TextXAlignment.Left ON2.TextTruncate=Enum.TextTruncate.AtEnd
local ON3=Instance.new("TextLabel",Ow)ON3.Size=UDim2.new(1,-60,0,14)ON3.Position=UDim2.fromOffset(56,38)
ON3.BackgroundTransparency=1 ON3.Text="Lv.0 - Human"ON3.Font=Enum.Font.GothamMedium ON3.TextSize=10
ON3.TextColor3=T.Sub ON3.TextXAlignment=Enum.TextXAlignment.Left ON3.TextTruncate=Enum.TextTruncate.AtEnd

local function getBFStat()
    local lvl=0 local race="Human"
    local ok,v=pcall(function()return LP:GetAttribute("Level")end)
    if ok and type(v)=="number"then lvl=v end
    if lvl==0 then local ok2,v2=pcall(function()return LP.Data.Level.Value end)
        if ok2 and type(v2)=="number"then lvl=v2 end end
    if lvl==0 then local ls=LP:FindFirstChild("leaderstats")
        if ls then local lv=ls:FindFirstChild("Level")or ls:FindFirstChild("Lv")
            if lv then lvl=tonumber(lv.Value)or 0 end end end
    local ok3,r=pcall(function()return LP:GetAttribute("Race")end)
    if ok3 and type(r)=="string"and r~=""then race=r end
    if race=="Human"then local ok4,r2=pcall(function()return LP.Data.Race.Value end)
        if ok4 and type(r2)=="string"and r2~=""then race=r2 end end
    return lvl,race
end
local function updateProfile()
    ON1.Text=LP.DisplayName or LP.Name
    ON2.Text="@"..LP.Name
    local lvl,race=getBFStat()
    ON3.Text="Lv."..tostring(lvl).." - "..tostring(race)
end
updateProfile()
task.spawn(function()while Ow.Parent do task.wait(2) updateProfile() end end)

local Ct=Instance.new("Frame",Bd)Ct.Size=UDim2.new(1,-170,1,0)Ct.Position=UDim2.new(0,170,0,0)
Ct.BackgroundTransparency=1

applyLayout=function()
if R.device=="mobile"then
SB.Size=UDim2.new(0,132,1,0)SBc.Position=UDim2.new(1,-16,0,0)
Ct.Position=UDim2.new(0,132,0,0)Ct.Size=UDim2.new(1,-132,1,0)
NL.Position=UDim2.fromOffset(6,6)NL.Size=UDim2.new(1,-12,1,-86)
Ow.Size=UDim2.new(1,-12,0,68)Ow.Position=UDim2.new(.5,0,1,-6)
OI.Size=UDim2.fromOffset(36,36)OI.Position=UDim2.fromOffset(6,16)
ON1.Size=UDim2.new(1,-52,0,14)ON1.Position=UDim2.fromOffset(48,4)
ON2.Size=UDim2.new(1,-52,0,12)ON2.Position=UDim2.fromOffset(48,20)
ON3.Size=UDim2.new(1,-52,0,12)ON3.Position=UDim2.fromOffset(48,36)
Sb.Visible=false Vr.Position=UDim2.fromOffset(200,18)
elseif R.device=="tablet"then
SB.Size=UDim2.new(0,155,1,0)SBc.Position=UDim2.new(1,-16,0,0)
Ct.Position=UDim2.new(0,155,0,0)Ct.Size=UDim2.new(1,-155,1,0)
NL.Position=UDim2.fromOffset(8,8)NL.Size=UDim2.new(1,-16,1,-84)
Ow.Size=UDim2.new(1,-16,0,72)Ow.Position=UDim2.new(.5,0,1,-8)
Sb.Visible=true Vr.Position=UDim2.fromOffset(240,18)
else SB.Size=UDim2.new(0,170,1,0)SBc.Position=UDim2.new(1,-16,0,0)
Ct.Position=UDim2.new(0,170,0,0)Ct.Size=UDim2.new(1,-170,1,0)
NL.Position=UDim2.fromOffset(8,8)NL.Size=UDim2.new(1,-16,1,-90)
Ow.Size=UDim2.new(1,-16,0,72)Ow.Position=UDim2.new(.5,0,1,-8)
Sb.Visible=true Vr.Position=UDim2.fromOffset(240,18)end end

local Pgs={}local NBs={}
local function mkPage()local p=Instance.new("ScrollingFrame",Ct)p.Size=UDim2.new(1,-24,1,-16)
p.Position=UDim2.fromOffset(12,8)p.BackgroundTransparency=1 p.BorderSizePixel=0
p.ScrollBarThickness=3 p.ScrollBarImageColor3=T.Accent p.ScrollBarImageTransparency=.4
p.CanvasSize=UDim2.new()p.AutomaticCanvasSize=Enum.AutomaticSize.Y p.Visible=false
local l=Instance.new("UIListLayout",p)l.Padding=UDim.new(0,10)l.SortOrder=Enum.SortOrder.LayoutOrder
return p end
local function addTab(id,ico,lbl,ord)local pg=mkPage()Pgs[id]=pg
local b=Instance.new("TextButton",NL)b.Size=UDim2.new(1,0,0,42)b.BackgroundColor3=T.Sidebar
b.Text=""b.AutoButtonColor=false b.BorderSizePixel=0 b.LayoutOrder=ord cr(b,10)
local icBox=Instance.new("Frame",b)icBox.Size=UDim2.fromOffset(30,30)icBox.Position=UDim2.fromOffset(12,6)
icBox.BackgroundColor3=T.Sub icBox.BackgroundTransparency=.85 icBox.BorderSizePixel=0 cr(icBox,8)
local ic=Instance.new("TextLabel",icBox)ic.Size=UDim2.fromScale(1,1)ic.BackgroundTransparency=1
ic.Text=ico ic.Font=Enum.Font.GothamBold ic.TextSize=16 ic.TextColor3=T.Sub
local lb=Instance.new("TextLabel",b)lb.Size=UDim2.new(1,-50,1,0)lb.Position=UDim2.fromOffset(50,0)
lb.BackgroundTransparency=1 lb.Text=lbl lb.Font=Enum.Font.GothamMedium lb.TextSize=13
lb.TextColor3=T.Sub lb.TextXAlignment=Enum.TextXAlignment.Left
local ac=Instance.new("Frame",b)ac.Size=UDim2.new(0,3,0,20)ac.Position=UDim2.new(0,0,.5,-10)
ac.BackgroundColor3=T.Accent ac.BorderSizePixel=0 ac.Visible=false cr(ac,2)
local function sA(a)ac.Visible=a b.BackgroundColor3=a and T.Card or T.Sidebar
ic.TextColor3=a and Color3.fromRGB(255,255,255)or T.Sub
icBox.BackgroundColor3=a and T.Accent or T.Sub
icBox.BackgroundTransparency=a and .3 or .85
lb.TextColor3=a and T.Text or T.Sub
TW:Create(icBox,TweenInfo.new(.2),{Size=a and UDim2.fromOffset(32,32)or UDim2.fromOffset(30,30)}):Play()end
b.MouseButton1Click:Connect(function()for k,p in pairs(Pgs)do p.Visible=(k==id)end
for k,fn in pairs(NBs)do fn(k==id)end end)NBs[id]=sA return pg end

local pMacro=addTab("Macro","🎯","Macro",1)
local pVisual=addTab("Visual","👁️","Visual",2)
local pMove=addTab("Move","🏃","Move",3)
local pSet=addTab("Settings","⚙️","Settings",4)
local pInfo=addTab("Info","💠","Info",5)
for k,p in pairs(Pgs)do p.Visible=(k=="Macro")end
for k,fn in pairs(NBs)do fn(k=="Macro")end

local function mSec(par,title,desc,ord)local c=Instance.new("Frame",par)c.Size=UDim2.new(1,0,0,0)
c.AutomaticSize=Enum.AutomaticSize.Y c.BackgroundColor3=T.Panel c.BorderSizePixel=0 c.LayoutOrder=ord
cr(c,12)sk(c,T.Stroke,1)
local t=Instance.new("Frame",c)t.Size=UDim2.new(1,0,0,48)t.BackgroundTransparency=1
local tl=Instance.new("TextLabel",t)tl.Size=UDim2.new(1,-20,0,20)tl.Position=UDim2.fromOffset(14,6)
tl.BackgroundTransparency=1 tl.Text=title tl.Font=Enum.Font.GothamBold tl.TextSize=14
tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
local dl=Instance.new("TextLabel",t)dl.Size=UDim2.new(1,-20,0,16)dl.Position=UDim2.fromOffset(14,26)
dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=11
dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
local r=Instance.new("Frame",c)r.Size=UDim2.new(1,-20,0,0)r.Position=UDim2.fromOffset(10,48)
r.BackgroundTransparency=1 r.AutomaticSize=Enum.AutomaticSize.Y
local rl=Instance.new("UIListLayout",r)rl.Padding=UDim.new(0,4)rl.SortOrder=Enum.SortOrder.LayoutOrder
local pd=Instance.new("Frame",c)pd.Size=UDim2.new(1,0,0,10)pd.Position=UDim2.new(0,0,1,0)
pd.AnchorPoint=Vector2.new(0,1)pd.BackgroundTransparency=1 return r end

local function mRow(par,ord)local r=Instance.new("Frame",par)r.Size=UDim2.new(1,0,0,44)
r.BackgroundColor3=T.Card r.BorderSizePixel=0 r.LayoutOrder=ord cr(r,8)
r.MouseEnter:Connect(function()TW:Create(r,TweenInfo.new(.15),{BackgroundColor3=T.CardHi}):Play()end)
r.MouseLeave:Connect(function()TW:Create(r,TweenInfo.new(.15),{BackgroundColor3=T.Card}):Play()end)
return r end

local function mTog(par,name,desc,def,ord,cb)local r=mRow(par,ord)local st=def or false
local tl=Instance.new("TextLabel",r)tl.Size=UDim2.new(1,-80,0,18)tl.Position=UDim2.fromOffset(12,6)
tl.BackgroundTransparency=1 tl.Text=name tl.Font=Enum.Font.GothamMedium tl.TextSize=12
tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
local dl=Instance.new("TextLabel",r)dl.Size=UDim2.new(1,-80,0,14)dl.Position=UDim2.fromOffset(12,24)
dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=10
dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
local sw=Instance.new("Frame",r)sw.Size=UDim2.fromOffset(42,22)sw.AnchorPoint=Vector2.new(1,.5)
sw.Position=UDim2.new(1,-12,.5,0)sw.BackgroundColor3=st and T.On or T.Off
sw.BorderSizePixel=0 cr(sw,11)
local kn=Instance.new("Frame",sw)kn.Size=UDim2.fromOffset(18,18)kn.AnchorPoint=Vector2.new(0,.5)
kn.Position=st and UDim2.new(1,-20,.5,0)or UDim2.new(0,2,.5,0)
kn.BackgroundColor3=Color3.fromRGB(245,245,250)kn.BorderSizePixel=0 cr(kn,9)
local b=Instance.new("TextButton",r)b.Size=UDim2.fromScale(1,1)b.BackgroundTransparency=1 b.Text=""
local function set(v)st=v TW:Create(sw,TweenInfo.new(.15),{BackgroundColor3=st and T.On or T.Off}):Play()
TW:Create(kn,TweenInfo.new(.15),{Position=st and UDim2.new(1,-20,.5,0)or UDim2.new(0,2,.5,0)}):Play()end
b.MouseButton1Click:Connect(function()set(not st)if cb then cb(st)end end)
return{Get=function()return st end,Set=set}end

local function mSld(par,name,desc,mn,mx,def,ord,cb)local r=mRow(par,ord)r.Size=UDim2.new(1,0,0,58)
local tl=Instance.new("TextLabel",r)tl.Size=UDim2.new(1,-80,0,16)tl.Position=UDim2.fromOffset(12,6)
tl.BackgroundTransparency=1 tl.Text=name tl.Font=Enum.Font.GothamMedium tl.TextSize=12
tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
local vb=Instance.new("TextLabel",r)vb.Size=UDim2.fromOffset(56,20)vb.AnchorPoint=Vector2.new(1,0)
vb.Position=UDim2.new(1,-12,0,6)vb.BackgroundColor3=T.Panel vb.Text=tostring(def)
vb.Font=Enum.Font.GothamMedium vb.TextSize=11 vb.TextColor3=T.Text vb.BorderSizePixel=0 cr(vb,6)
local dl=Instance.new("TextLabel",r)dl.Size=UDim2.new(1,-80,0,14)dl.Position=UDim2.fromOffset(12,22)
dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=10
dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
local tr=Instance.new("Frame",r)tr.Size=UDim2.new(1,-24,0,6)tr.AnchorPoint=Vector2.new(0,1)
tr.Position=UDim2.new(0,12,1,-14)tr.BackgroundColor3=T.Off tr.BorderSizePixel=0 cr(tr,3)
local fl=Instance.new("Frame",tr)fl.Size=UDim2.new((def-mn)/(mx-mn),0,1,0)fl.BackgroundColor3=T.Accent
fl.BorderSizePixel=0 cr(fl,3)
local kn=Instance.new("Frame",tr)kn.AnchorPoint=Vector2.new(.5,.5)
kn.Position=UDim2.new((def-mn)/(mx-mn),0,.5,0)kn.Size=UDim2.fromOffset(14,14)
kn.BackgroundColor3=Color3.fromRGB(255,255,255)kn.BorderSizePixel=0 cr(kn,7)
local dg=false local function up(i)local rl=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
local v=math.floor(mn+(mx-mn)*rl+.5)fl.Size=UDim2.new(rl,0,1,0)kn.Position=UDim2.new(rl,0,.5,0)
vb.Text=tostring(v)if cb then cb(v)end end
tr.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch then dg=true up(i)end end)
UIS.InputChanged:Connect(function(i)if dg and(i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch)then up(i)end end)
UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch then dg=false end end)end

local function mBtn(par,name,desc,bTxt,ord,cb,dngr)local r=mRow(par,ord)
local tl=Instance.new("TextLabel",r)tl.Size=UDim2.new(.55,0,0,18)tl.Position=UDim2.fromOffset(12,6)
tl.BackgroundTransparency=1 tl.Text=name tl.Font=Enum.Font.GothamMedium tl.TextSize=12
tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
local dl=Instance.new("TextLabel",r)dl.Size=UDim2.new(.55,0,0,14)dl.Position=UDim2.fromOffset(12,24)
dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=10
dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
local b=Instance.new("TextButton",r)b.Size=UDim2.fromOffset(100,28)b.AnchorPoint=Vector2.new(1,.5)
b.Position=UDim2.new(1,-12,.5,0)b.BackgroundColor3=dngr and T.Danger or T.Accent
b.Text=bTxt b.Font=Enum.Font.GothamBold b.TextSize=11 b.TextColor3=Color3.fromRGB(255,255,255)
b.BorderSizePixel=0 b.AutoButtonColor=false cr(b,8)
if cb then b.MouseButton1Click:Connect(cb)end return b end

-- MACRO
local WN={"Vo","Kiem","Sung","Trai"}
local WSK={Vo={"Z","X","C","V","F"},Kiem={"Z","X"},Sung={"Z","X"},Trai={"Z","X","C","V","F"}}
local WDIS={Vo="Melee",Kiem="Sword",Sung="Gun",Trai="Fruit"}
local WDISK={Melee="Vo",Sword="Kiem",Gun="Sung",Fruit="Trai"}
local TM={Vo="Melee",Kiem="Sword",Sung="Gun",Trai="Blox Fruit"}
local KM={Z=Enum.KeyCode.Z,X=Enum.KeyCode.X,C=Enum.KeyCode.C,V=Enum.KeyCode.V,F=Enum.KeyCode.F}
local function vSk(w,s)for _,x in ipairs(WSK[w]or{})do if x==s then return true end end return false end
local function gTT(t)if not t or not t:IsA("Tool")then return end
local a=t:GetAttribute("ToolType")if a then local s=tostring(a)
if s=="Melee"or s=="Sword"or s=="Gun"or s=="Blox Fruit"then return s end end
local tp=t.ToolTip if tp and tp~=""then local s=string.lower(tp)
if s:find("melee")or s:find("fighting")then return"Melee"end if s:find("sword")then return"Sword"end
if s:find("gun")then return"Gun"end if s:find("fruit")or s:find("blox")then return"Blox Fruit"end end
local n=string.lower(t.Name)if n:find("sword")or n:find("katana")or n:find("blade")
or n:find("saber")or n:find("cutlass")or n:find("dagger")then return"Sword"end
if n:find("gun")or n:find("pistol")or n:find("rifle")or n:find("musket")or n:find("flintlock")then
return"Gun"end return nil end
local function eqL(lb)local tt=TM[lb]if not tt then return end local ch=LP.Character if not ch then return end
local h=ch:FindFirstChildOfClass("Humanoid")if not h then return end
for _,x in ipairs(ch:GetChildren())do if x:IsA("Tool")and gTT(x)==tt then return end end
if ch:FindFirstChildOfClass("Tool")then pcall(function()h:UnequipTools()end)task.wait(.08)end
local bp=LP:FindFirstChild("Backpack")if bp then for _,x in ipairs(bp:GetChildren())do
if x:IsA("Tool")and gTT(x)==tt then pcall(function()h:EquipTool(x)end)task.wait(.15)return end end end end
local function pk(kc,hd)pcall(function()VIM:SendKeyEvent(true,kc,false,game)end)
task.wait(hd and hd>0 and hd or .03)pcall(function()VIM:SendKeyEvent(false,kc,false,game)end)end

local M={}local RUN=false local STP=false local RM=nil local OnFin=nil local FBs={}
local function addM(n)local m={name=n,bl={},on=false,open=true}table.insert(M,m)return m end
local function runM(m)if RUN or not m.on or#m.bl==0 then return end RUN=true STP=false RM=m
if OnFin then OnFin(m,true)end
for _,b in ipairs(m.bl)do if STP then break end
if not vSk(b.w,b.s)then b.s=(WSK[b.w]or{"Z"})[1]end eqL(b.w)
if KM[b.s]then pk(KM[b.s],b.h)end if b.d>0 then task.wait(b.d)end end
RUN=false RM=nil if OnFin then OnFin(m,false)end end

local function upFB(m)local e=FBs[m]if not e then return end local run=(RM==m and RUN)
if run then TW:Create(e.sw,TweenInfo.new(.18),{BackgroundColor3=T.On}):Play()
TW:Create(e.kn,TweenInfo.new(.18),{Position=UDim2.new(1,-20,.5,0)}):Play()
TW:Create(e.bd,TweenInfo.new(.18),{Color=T.Accent,Transparency=0}):Play()
e.ic.Text="STOP"e.ic.TextColor3=T.Red
else TW:Create(e.sw,TweenInfo.new(.18),{BackgroundColor3=T.Off}):Play()
TW:Create(e.kn,TweenInfo.new(.18),{Position=UDim2.new(0,2,.5,0)}):Play()
TW:Create(e.bd,TweenInfo.new(.18),{Color=T.Stroke,Transparency=.3}):Play()
e.ic.Text="RUN"e.ic.TextColor3=T.Green end end
local function crFB(m)if FBs[m]then return end local c=0 for _ in pairs(FBs)do c=c+1 end
local fb=Instance.new("TextButton",GUI)fb.Size=UDim2.fromOffset(210,48)
fb.Position=UDim2.new(0,20,0,180+c*58)fb.BackgroundColor3=Color3.fromRGB(14,22,42)
fb.BackgroundTransparency=.05 fb.Text=""fb.AutoButtonColor=false fb.BorderSizePixel=0 cr(fb,12)
local bd=Instance.new("UIStroke",fb)bd.Color=T.Stroke bd.Thickness=1.5 bd.Transparency=.3 dg(fb)
local ic=Instance.new("TextLabel",fb)ic.Size=UDim2.fromOffset(46,20)ic.Position=UDim2.fromOffset(8,14)
ic.BackgroundTransparency=1 ic.Text="RUN"ic.Font=Enum.Font.GothamBold ic.TextSize=11 ic.TextColor3=T.Green
local nl=Instance.new("TextLabel",fb)nl.Size=UDim2.new(1,-102,1,0)nl.Position=UDim2.fromOffset(60,0)
nl.BackgroundTransparency=1 nl.Text=m.name nl.Font=Enum.Font.GothamBold nl.TextSize=12
nl.TextColor3=T.Text nl.TextXAlignment=Enum.TextXAlignment.Left nl.TextTruncate=Enum.TextTruncate.AtEnd
local sw=Instance.new("Frame",fb)sw.Size=UDim2.fromOffset(42,22)sw.AnchorPoint=Vector2.new(1,.5)
sw.Position=UDim2.new(1,-14,.5,0)sw.BackgroundColor3=T.Off sw.BorderSizePixel=0 cr(sw,11)
local kn=Instance.new("Frame",sw)kn.Size=UDim2.fromOffset(18,18)kn.AnchorPoint=Vector2.new(0,.5)
kn.Position=UDim2.new(0,2,.5,0)kn.BackgroundColor3=Color3.fromRGB(245,245,250)
kn.BorderSizePixel=0 cr(kn,9)
FBs[m]={fb=fb,sw=sw,kn=kn,ic=ic,bd=bd}
fb.MouseButton1Click:Connect(function()if RM==m and RUN then STP=true
else task.spawn(function()runM(m)end)end end)
fb.MouseEnter:Connect(function()TW:Create(fb,TweenInfo.new(.15),{BackgroundTransparency=0}):Play()end)
fb.MouseLeave:Connect(function()TW:Create(fb,TweenInfo.new(.15),{BackgroundTransparency=.05}):Play()end)
upFB(m)end
local function rmFB(m)local e=FBs[m]if e then e.fb:Destroy()FBs[m]=nil end end
OnFin=function(m)if FBs[m]then upFB(m)end end

local Ov=Instance.new("TextButton",GUI)Ov.Size=UDim2.new(1,0,1,0)Ov.BackgroundTransparency=1
Ov.Text=""Ov.AutoButtonColor=false Ov.Visible=false Ov.ZIndex=500
local Pp=Instance.new("Frame",GUI)Pp.BackgroundColor3=T.Card Pp.BorderSizePixel=0 Pp.Visible=false
Pp.ZIndex=501 cr(Pp,8)sk(Pp,T.Accent,1)
local Pl=Instance.new("UIListLayout",Pp)Pl.Padding=UDim.new(0,2)
local pp=Instance.new("UIPadding",Pp)pp.PaddingTop=UDim.new(0,4)pp.PaddingBottom=UDim.new(0,4)
pp.PaddingLeft=UDim.new(0,4)pp.PaddingRight=UDim.new(0,4)
Ov.MouseButton1Click:Connect(function()Ov.Visible=false Pp.Visible=false end)
local function openDD(b,opts,cb)for _,c in ipairs(Pp:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
for _,o in ipairs(opts)do local ob=Instance.new("TextButton",Pp)ob.Size=UDim2.new(1,0,0,26)
ob.BackgroundColor3=T.Card ob.Text=o ob.TextColor3=T.Text ob.TextSize=12
ob.Font=Enum.Font.GothamMedium ob.AutoButtonColor=false ob.ZIndex=502 cr(ob,5)
ob.MouseButton1Click:Connect(function()cb(o)Ov.Visible=false Pp.Visible=false end)end
local w=math.max(b.AbsoluteSize.X,90)Pp.Size=UDim2.fromOffset(w,#opts*28+8)
local ax=b.AbsolutePosition.X local ay=b.AbsolutePosition.Y+b.AbsoluteSize.Y+4
if ax+w>GUI.AbsoluteSize.X-10 then ax=GUI.AbsoluteSize.X-w-10 end
Pp.Position=UDim2.fromOffset(ax,ay)Ov.Visible=true Pp.Visible=true end
local function mkDD(par,gO,init,cb)local b=Instance.new("TextButton",par)b.Size=UDim2.new(1,0,1,0)
b.BackgroundColor3=T.Input b.Text=""b.AutoButtonColor=false cr(b,6)sk(b,T.Stroke,1)
local l=Instance.new("TextLabel",b)l.Size=UDim2.new(1,-20,1,0)l.Position=UDim2.fromOffset(8,0)
l.BackgroundTransparency=1 l.Text=init l.TextColor3=T.Text l.TextSize=12
l.Font=Enum.Font.GothamMedium l.TextXAlignment=Enum.TextXAlignment.Left
b.MouseButton1Click:Connect(function()openDD(b,gO(),function(v)l.Text=v cb(v)end)end)
return function(v)l.Text=v end end

refreshM=nil

local function mkBl(par,m,b,bi,mi)if not vSk(b.w,b.s)then b.s=(WSK[b.w]or{"Z"})[1]end
local r=Instance.new("Frame",par)r.Size=UDim2.new(1,-4,0,62)r.BackgroundColor3=T.Card
r.LayoutOrder=mi*100+bi cr(r,8)sk(r,T.Stroke,1)
local lb=Instance.new("TextLabel",r)lb.Size=UDim2.fromOffset(80,14)lb.Position=UDim2.fromOffset(12,4)
lb.BackgroundTransparency=1 lb.Text="Block "..bi lb.TextColor3=T.Accent lb.TextSize=10
lb.Font=Enum.Font.GothamBold lb.TextXAlignment=Enum.TextXAlignment.Left
local dl=Instance.new("TextButton",r)dl.Size=UDim2.fromOffset(20,18)dl.Position=UDim2.new(1,-26,0,4)
dl.BackgroundColor3=Color3.fromRGB(50,20,28)dl.Text="X"dl.TextColor3=T.Red dl.TextSize=10
dl.AutoButtonColor=false cr(dl,4)
local fd=Instance.new("Frame",r)fd.Size=UDim2.new(1,-20,0,28)fd.Position=UDim2.fromOffset(10,26)
fd.BackgroundTransparency=1
local wS=Instance.new("Frame",fd)wS.BackgroundTransparency=1 wS.Size=UDim2.new(.25,-4,1,0)
wS.Position=UDim2.new(0,0,0,0)
local sS=Instance.new("Frame",fd)sS.BackgroundTransparency=1 sS.Size=UDim2.new(.25,-4,1,0)
sS.Position=UDim2.new(.25,2,0,0)
local hS=Instance.new("Frame",fd)hS.BackgroundColor3=T.Input hS.Size=UDim2.new(.25,-4,1,0)
hS.Position=UDim2.new(.5,4,0,0)cr(hS,5)sk(hS,T.Stroke,1)
local dS=Instance.new("Frame",fd)dS.BackgroundColor3=T.Input dS.Size=UDim2.new(.25,-4,1,0)
dS.Position=UDim2.new(.75,6,0,0)cr(dS,5)sk(dS,T.Stroke,1)
local sL
mkDD(wS,function()local o={}for _,k in ipairs(WN)do table.insert(o,WDIS[k]or k)end return o end,
WDIS[b.w]or b.w,function(v)local k=WDISK[v]or v b.w=k
if not vSk(k,b.s)then b.s=(WSK[k]or{"Z"})[1]if sL then sL(b.s)end end end)
sL=mkDD(sS,function()return WSK[b.w]or{"Z"}end,b.s,function(v)b.s=v end)
local hB=Instance.new("TextBox",hS)hB.Size=UDim2.new(1,-8,1,0)hB.Position=UDim2.fromOffset(4,0)
hB.BackgroundTransparency=1 hB.Text=string.format("%.2f",b.h)hB.TextColor3=T.Text hB.TextSize=12
hB.Font=Enum.Font.Gotham hB.ClearTextOnFocus=false
hB.FocusLost:Connect(function()local n=tonumber(hB.Text)if n and n>=0 then b.h=n end
hB.Text=string.format("%.2f",b.h)end)
local dB=Instance.new("TextBox",dS)dB.Size=UDim2.new(1,-8,1,0)dB.Position=UDim2.fromOffset(4,0)
dB.BackgroundTransparency=1 dB.Text=string.format("%.2f",b.d)dB.TextColor3=T.Text
dB.TextSize=12 dB.Font=Enum.Font.Gotham dB.ClearTextOnFocus=false
dB.FocusLost:Connect(function()local n=tonumber(dB.Text)if n and n>=0 then b.d=n end
dB.Text=string.format("%.2f",b.d)end)
dl.MouseButton1Click:Connect(function()table.remove(m.bl,bi)if refreshM then refreshM()end end)end

local function mkHd(par,m,mi)local r=Instance.new("Frame",par)r.Size=UDim2.new(1,-4,0,52)
r.BackgroundColor3=T.Card r.LayoutOrder=mi*100 cr(r,10)
sk(r,m.on and T.Accent or T.Stroke,m.on and 1.2 or 1)
local t=Instance.new("TextLabel",r)t.Size=UDim2.new(0,250,1,0)t.Position=UDim2.fromOffset(60,0)
t.BackgroundTransparency=1 t.Text=m.name t.TextColor3=T.Text t.TextSize=14
t.Font=Enum.Font.GothamBold t.TextXAlignment=Enum.TextXAlignment.Left
local a=Instance.new("TextLabel",r)a.Size=UDim2.fromOffset(24,24)a.Position=UDim2.fromOffset(16,14)
a.BackgroundTransparency=1 a.Text=m.open and "v"or ">"a.TextColor3=T.Sub a.TextSize=16
a.Font=Enum.Font.GothamBold
local rn=Instance.new("TextButton",r)rn.Size=UDim2.fromOffset(30,26)rn.Position=UDim2.new(1,-152,0,13)
rn.BackgroundColor3=Color3.fromRGB(10,40,35)rn.Text=">"rn.TextColor3=T.Green rn.TextSize=14
rn.Font=Enum.Font.GothamBold rn.AutoButtonColor=false cr(rn,6)sk(rn,T.Green,.8)
rn.MouseButton1Click:Connect(function()task.spawn(function()runM(m)end)end)
local d=Instance.new("TextButton",r)d.Size=UDim2.fromOffset(26,26)d.Position=UDim2.new(1,-116,0,13)
d.BackgroundColor3=Color3.fromRGB(45,20,30)d.Text="X"d.TextColor3=T.Red d.TextSize=11
d.Font=Enum.Font.GothamBold d.AutoButtonColor=false cr(d,6)
d.MouseButton1Click:Connect(function()rmFB(m)for i,x in ipairs(M)do if x==m then table.remove(M,i)break end end
if refreshM then refreshM()end end)
local tg=Instance.new("TextButton",r)tg.Size=UDim2.fromOffset(44,24)tg.Position=UDim2.new(1,-62,0,14)
tg.AutoButtonColor=false tg.BackgroundColor3=m.on and T.On or T.Off tg.Text=""cr(tg,12)
local tk=Instance.new("Frame",tg)tk.Size=UDim2.fromOffset(18,18)
tk.Position=m.on and UDim2.new(1,-21,0,3)or UDim2.new(0,3,0,3)
tk.BackgroundColor3=Color3.fromRGB(255,255,255)tk.BorderSizePixel=0 cr(tk,9)
tg.MouseButton1Click:Connect(function()m.on=not m.on if m.on then crFB(m)else rmFB(m)end
if refreshM then refreshM()end end)
local ca=Instance.new("TextButton",r)ca.Size=UDim2.new(1,-160,1,0)ca.BackgroundTransparency=1
ca.Text=""ca.AutoButtonColor=false ca.ZIndex=2
ca.MouseButton1Click:Connect(function()m.open=not m.open if refreshM then refreshM()end end)end

function refreshM()Ov.Visible=false Pp.Visible=false
for _,c in ipairs(pMacro:GetChildren())do if c:IsA("Frame")or c:IsA("TextButton")or c:IsA("TextLabel")then c:Destroy()end end
local tc=Instance.new("Frame",pMacro)tc.Size=UDim2.new(1,0,0,60)tc.BackgroundColor3=T.Panel
tc.LayoutOrder=-1 cr(tc,12)sk(tc,T.Stroke,1)
local tt=Instance.new("TextLabel",tc)tt.Size=UDim2.new(.5,0,0,22)tt.Position=UDim2.fromOffset(14,10)
tt.BackgroundTransparency=1 tt.Text="Macro"tt.Font=Enum.Font.GothamBold tt.TextSize=14
tt.TextColor3=T.Text tt.TextXAlignment=Enum.TextXAlignment.Left
local sb=Instance.new("TextLabel",tc)sb.Size=UDim2.new(.5,0,0,16)sb.Position=UDim2.fromOffset(14,32)
sb.BackgroundTransparency=1 sb.Text="Tu dong combo - Toi uu PvP"sb.Font=Enum.Font.Gotham
sb.TextSize=11 sb.TextColor3=T.Sub sb.TextXAlignment=Enum.TextXAlignment.Left
local tb=Instance.new("TextButton",tc)tb.Size=UDim2.fromOffset(140,36)tb.AnchorPoint=Vector2.new(1,.5)
tb.Position=UDim2.new(1,-14,.5,0)tb.BackgroundColor3=T.Accent2 tb.Text="+ Tao Macro"
tb.Font=Enum.Font.GothamBold tb.TextSize=12 tb.TextColor3=Color3.fromRGB(255,255,255)
tb.BorderSizePixel=0 tb.AutoButtonColor=false cr(tb,9)
tb.MouseButton1Click:Connect(function()addM("Macro "..#M+1)refreshM()end)
if#M==0 then local em=Instance.new("Frame",pMacro)em.Size=UDim2.new(1,0,0,160)
em.BackgroundTransparency=1 em.LayoutOrder=10
local ci=Instance.new("Frame",em)ci.Size=UDim2.fromOffset(64,64)ci.Position=UDim2.new(.5,-32,0,30)
ci.BackgroundColor3=T.Card ci.BorderSizePixel=0 cr(ci,32)sk(ci,T.Accent,1.2)
local ic=Instance.new("TextLabel",ci)ic.Size=UDim2.fromScale(1,1)ic.BackgroundTransparency=1
ic.Text="🎯"ic.Font=Enum.Font.GothamBold ic.TextSize=32 ic.TextColor3=T.Accent
local t1=Instance.new("TextLabel",em)t1.Size=UDim2.new(1,0,0,22)t1.Position=UDim2.new(0,0,0,108)
t1.BackgroundTransparency=1 t1.Text="Chua co Macro nao"t1.TextColor3=T.Text
t1.TextSize=14 t1.Font=Enum.Font.GothamBold
local t2=Instance.new("TextLabel",em)t2.Size=UDim2.new(1,0,0,18)t2.Position=UDim2.new(0,0,0,130)
t2.BackgroundTransparency=1 t2.Text="Bam '+ Tao Macro' de bat dau"t2.TextColor3=T.Sub
t2.TextSize=11 t2.Font=Enum.Font.Gotham return end
for i,m in ipairs(M)do mkHd(pMacro,m,i)if m.open then
for bi,b in ipairs(m.bl)do mkBl(pMacro,m,b,bi,i)end
local ar=Instance.new("Frame",pMacro)ar.Size=UDim2.new(1,-4,0,30)ar.BackgroundTransparency=1
ar.LayoutOrder=i*100+99
local ab=Instance.new("TextButton",ar)ab.Size=UDim2.new(1,0,1,0)
ab.BackgroundColor3=Color3.fromRGB(12,18,32)ab.AutoButtonColor=false ab.Text="+ Them Block"
ab.TextColor3=T.Accent ab.TextSize=12 ab.Font=Enum.Font.GothamBold cr(ab,8)
sk(ab,Color3.fromRGB(0,150,200),.8)
ab.MouseButton1Click:Connect(function()table.insert(m.bl,{w="Vo",s="Z",h=0,d=.15})refreshM()end)end end end
refreshM()

-- ESP
local ESP={on=false,name=true,dist=true,hp=true,color=Color3.fromRGB(255,80,100),trans=.7}
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
    bb.Size=UDim2.fromOffset(140,64)bb.StudsOffset=Vector3.new(0,3.2,0)
    bb.AlwaysOnTop=true bb.Adornee=hrp
    local nl=Instance.new("TextLabel",bb)nl.Name="Name"
    nl.Size=UDim2.new(1,0,0,16)nl.Position=UDim2.new(0,0,0,0)
    nl.BackgroundTransparency=1 nl.Text=p.Name nl.TextColor3=ESP.color
    nl.TextStrokeTransparency=.3 nl.TextSize=13 nl.Font=Enum.Font.GothamBold
    local dl=Instance.new("TextLabel",bb)dl.Name="Dist"
    dl.Size=UDim2.new(1,0,0,14)dl.Position=UDim2.new(0,0,0,16)
    dl.BackgroundTransparency=1 dl.Text="0m"dl.TextColor3=Color3.fromRGB(200,220,255)
    dl.TextStrokeTransparency=.3 dl.TextSize=11 dl.Font=Enum.Font.Gotham
    local hl2=Instance.new("TextLabel",bb)hl2.Name="HpText"
    hl2.Size=UDim2.new(1,0,0,14)hl2.Position=UDim2.new(0,0,0,30)
    hl2.BackgroundTransparency=1 hl2.Text="100 / 100"hl2.TextColor3=Color3.fromRGB(80,240,130)
    hl2.TextStrokeTransparency=.3 hl2.TextSize=11 hl2.Font=Enum.Font.GothamBold
    espC[p]={hl=hl,bb=bb}
    return espC[p]
end
local function rmESP(p)local c=espC[p]
    if c then pcall(function()c.hl:Destroy()end)pcall(function()c.bb:Destroy()end)espC[p]=nil end end
RS.RenderStepped:Connect(function()
    if not ESP.on then
        local l={}for p in pairs(espC)do table.insert(l,p)end
        for _,p in ipairs(l)do rmESP(p)end
        return
    end
    local myChar=LP.Character
    local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
    for _,p in ipairs(Players:GetPlayers())do
        if p~=LP then
            local tChar=p.Character
            if tChar then
                local tHRP=tChar:FindFirstChild("HumanoidRootPart")
                local tHum=tChar:FindFirstChildOfClass("Humanoid")
                if tHRP then
                    local e=espC[p]
                    if not e then e=mkESP(p)end
                    if e and e.bb and e.bb.Parent then
                        e.hl.FillColor=ESP.color
                        e.hl.FillTransparency=ESP.trans
                        e.hl.OutlineColor=ESP.color
                        local bb=e.bb
                        local nameL=bb:FindFirstChild("Name")
                        local distL=bb:FindFirstChild("Dist")
                        local hpL=bb:FindFirstChild("HpText")
                        if nameL then nameL.Visible=ESP.name nameL.Text=p.Name nameL.TextColor3=ESP.color end
                        if distL then
                            distL.Visible=ESP.dist
                            if myHRP then
                                local d=(tHRP.Position-myHRP.Position).Magnitude
                                distL.Text=tostring(math.floor(d)).."m"
                            else distL.Text="--"end
                        end
                        if hpL then
                            hpL.Visible=ESP.hp
                            if tHum then
                                local cur=math.floor(tHum.Health)
                                local max=math.floor(tHum.MaxHealth)
                                local ratio=tHum.Health/math.max(tHum.MaxHealth,1)
                                hpL.Text=tostring(cur).." / "..tostring(max)
                                hpL.TextColor3=ratio>.5 and Color3.fromRGB(80,240,130)
                                    or ratio>.25 and Color3.fromRGB(240,200,60)
                                    or Color3.fromRGB(240,80,80)
                            end
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
Players.PlayerRemoving:Connect(function(p)rmESP(p)end)
Players.PlayerAdded:Connect(function(p)p.CharacterAdded:Connect(function()
    task.wait(.5)if espC[p]then rmESP(p)end if ESP.on then mkESP(p)end end)end)
LP.CharacterAdded:Connect(function()task.wait(.5)
    for p in pairs(espC)do if p~=LP then rmESP(p)end end end)

local v1=mSec(pVisual,"Player ESP","Hien thi thong tin nguoi choi",1)
mTog(v1,"ESP Player","Bat/tat hien thi nguoi choi",false,1,function(v)ESP.on=v end)
mTog(v1,"Ten Player","Hien thi ten nguoi choi",true,2,function(v)ESP.name=v end)
mTog(v1,"Khoang cach","Hien thi khoang cach",true,3,function(v)ESP.dist=v end)
mTog(v1,"So mau","Hien thi so mau con lai",true,4,function(v)ESP.hp=v end)
local v2=mSec(pVisual,"ESP Style","Tuy chinh kieu hien thi",2)
mBtn(v2,"Doi mau","Xoay vong mau enemy","Doi",1,function()
local pool={Color3.fromRGB(255,80,100),Color3.fromRGB(255,200,60),
Color3.fromRGB(80,240,130),Color3.fromRGB(0,220,255)}local ix=1
for k,c in ipairs(pool)do if c==ESP.color then ix=k%#pool+1 break end end ESP.color=pool[ix]end)
mSld(v2,"Do trong suot","Dieu chinh do trong suot ESP",0,100,70,2,function(v)ESP.trans=v/100 end)

-- MOVE
local spOn,spV=false,60 local jpOn,jpV=false,120 local bsp,bjp=16,50
local function gH()local ch=LP.Character return ch and ch:FindFirstChildOfClass("Humanoid")or nil end
local function rBase()local h=gH()if h then bsp=h.WalkSpeed bjp=h.UseJumpPower and h.JumpPower or h.JumpHeight end end
rBase()LP.CharacterAdded:Connect(function()task.wait(.3)rBase()end)
pcall(function()local oi oi=hookmetamethod(game,"__newindex",function(s,k,v)
if spOn and s and typeof(s)=="Instance"and s:IsA("Humanoid")and s.Parent==LP.Character then
if k=="WalkSpeed"then return oi(s,k,spV)end end return oi(s,k,v)end)end)
RS.Stepped:Connect(function()local h=gH()if not h then return end
if spOn then if h.WalkSpeed~=spV then h.WalkSpeed=spV end
else if h.WalkSpeed~=bsp then h.WalkSpeed=bsp end end
if jpOn then h.UseJumpPower=true if h.JumpPower~=jpV then h.JumpPower=jpV end
else if h.JumpPower~=bjp then h.JumpPower=bjp end end end)
local function ap()local h=gH()if not h then return end if spOn then h.WalkSpeed=spV end
if jpOn then h.UseJumpPower=true h.JumpPower=jpV end end
local m1=mSec(pMove,"Di chuyen","Toi uu toc do & nhay",1)
mTog(m1,"Speed","Bat tang toc do chay",false,1,function(v)spOn=v ap()
if not v then local h=gH()if h then h.WalkSpeed=bsp end end end)
mSld(m1,"Speed Value","Toc do chay",16,200,60,2,function(v)spV=v if spOn then ap()end end)
mTog(m1,"Jump","Bat tang luc nhay",false,3,function(v)jpOn=v ap()
if not v then local h=gH()if h then h.JumpPower=bjp end end end)
mSld(m1,"Jump Value","Luc nhay",50,500,120,4,function(v)jpV=v if jpOn then ap()end end)

-- ============================================================
-- ULTIMATE FIX LAG ENGINE (with fog removal)
-- ============================================================
local FIX = {
    enabled = false,
    conns = {},
    materialBackup = {},
    particleBackup = {},
    lightingBackup = nil,
    atmosphereBackup = {},
    count = 0,
    rescanThread = nil,
    fogThread = nil,
}

-- === Bước 1: Xóa sương mù + tối ưu ánh sáng ===
local function optimizeLighting()
    pcall(function()
        LT.FogStart = 9e9
        LT.FogEnd = 9e9
        LT.Brightness = 2
        LT.ClockTime = 14
        LT.GlobalShadows = false
    end)

    -- Xóa Atmosphere (sương mù thế hệ mới)
    for _, obj in ipairs(LT:GetChildren()) do
        if obj:IsA("Atmosphere") then
            if not FIX.atmosphereBackup[obj] then
                FIX.atmosphereBackup[obj] = {
                    Density = obj.Density,
                    Offset = obj.Offset,
                    Color = obj.Color,
                    Decay = obj.Decay,
                    Glare = obj.Glare,
                    Haze = obj.Haze,
                }
                FIX.count = FIX.count + 1
            end
            pcall(function() obj:Destroy() end)
        end
    end
end

-- === Bước 2: Hạ đồ họa part + xóa decal + tắt particle ===
local function lowGraphics(obj)
    if not obj then return end

    if obj:IsA("BasePart") then
        if not FIX.materialBackup[obj] then
            FIX.materialBackup[obj] = {
                mat = obj.Material,
                ref = obj.Reflectance,
            }
            FIX.count = FIX.count + 1
        end
        pcall(function()
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        end)

    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        FIX.count = FIX.count + 1
        pcall(function() obj:Destroy() end)

    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail")
        or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
        or obj:IsA("Beam") then
        if not FIX.particleBackup[obj] then
            FIX.particleBackup[obj] = {
                rate = (obj:IsA("ParticleEmitter")) and obj.Rate or nil,
            }
            FIX.count = FIX.count + 1
        end
        pcall(function()
            if obj:IsA("ParticleEmitter") then obj.Rate = 0 end
            obj.Enabled = false
        end)

    elseif obj:IsA("Explosion") then
        pcall(function()
            obj.BlastPressure = 0
            obj.BlastRadius = 0
            obj.Position = Vector3.new(0, -10000, 0)
            obj:Destroy()
        end)

    elseif obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BloomEffect")
        or obj:IsA("DepthOfFieldEffect") or obj:IsA("ColorCorrectionEffect") then
        pcall(function() obj.Enabled = false end)
    end
end

local function scanAll(root, depth)
    root = root or WS
    depth = depth or 0
    if depth > 25 then return end
    local ok, children = pcall(function() return root:GetDescendants() end)
    if ok and children then
        for _, v in ipairs(children) do
            lowGraphics(v)
        end
    end
end

-- === Bật Fix Lag ===
local function enableFix()
    FIX.enabled = true
    FIX.count = 0

    -- 1. Settings graphics
    pcall(function()
        FIX.lightingBackup = {
            quality = settings().Rendering.QualityLevel,
            brightness = LT.Brightness,
            clockTime = LT.ClockTime,
            globalShadows = LT.GlobalShadows,
            fogStart = LT.FogStart,
            fogEnd = LT.FogEnd,
        }
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    -- 2. Tối ưu ánh sáng + xóa fog
    optimizeLighting()

    -- 3. Quét map lần đầu
    scanAll(WS)

    -- 4. Hook mọi instance mới
    table.insert(FIX.conns, WS.DescendantAdded:Connect(function(inst)
        if FIX.enabled then lowGraphics(inst) end
    end))
    table.insert(FIX.conns, LT.DescendantAdded:Connect(function(inst)
        if FIX.enabled then
            lowGraphics(inst)
            if inst:IsA("Atmosphere") then
                task.defer(function()
                    if inst and inst.Parent then
                        FIX.count = FIX.count + 1
                        pcall(function() inst:Destroy() end)
                    end
                end)
            end
        end
    end))

    -- 5. Hook Character mọi player
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            table.insert(FIX.conns, plr.Character.DescendantAdded:Connect(function(inst)
                if FIX.enabled then lowGraphics(inst) end
            end))
        end
        table.insert(FIX.conns, plr.CharacterAdded:Connect(function(ch)
            table.insert(FIX.conns, ch.DescendantAdded:Connect(function(inst)
                if FIX.enabled then lowGraphics(inst) end
            end))
            task.wait(.2)
            if FIX.enabled then scanAll(ch) end
        end))
    end

    -- 6. Auto rescan + auto fog removal mỗi 1 giây
    FIX.rescanThread = task.spawn(function()
        while FIX.enabled do
            task.wait(1)
            if FIX.enabled then
                optimizeLighting()
                scanAll(WS)
            end
        end
    end)
end

-- === Tắt Fix Lag ===
local function disableFix()
    FIX.enabled = false

    for _, c in ipairs(FIX.conns) do
        pcall(function() c:Disconnect() end)
    end
    FIX.conns = {}

    if FIX.rescanThread then
        pcall(function() task.cancel(FIX.rescanThread) end)
        FIX.rescanThread = nil
    end

    -- Restore lighting
    if FIX.lightingBackup then
        pcall(function()
            settings().Rendering.QualityLevel = FIX.lightingBackup.quality
            LT.Brightness = FIX.lightingBackup.brightness
            LT.ClockTime = FIX.lightingBackup.clockTime
            LT.GlobalShadows = FIX.lightingBackup.globalShadows
            LT.FogStart = FIX.lightingBackup.fogStart
            LT.FogEnd = FIX.lightingBackup.fogEnd
        end)
    end

    -- Restore Atmosphere
    for _, data in pairs(FIX.atmosphereBackup) do
        -- Atmosphere đã destroy, không restore được — cần respawn
    end
    FIX.atmosphereBackup = {}

    -- Restore Material
    for part, data in pairs(FIX.materialBackup) do
        if part and part.Parent then
            pcall(function()
                part.Material = data.mat
                part.Reflectance = data.ref
            end)
        end
    end
    FIX.materialBackup = {}

    -- Restore Particle
    for inst, data in pairs(FIX.particleBackup) do
        if inst and inst.Parent then
            pcall(function()
                if inst:IsA("ParticleEmitter") and data.rate then
                    inst.Rate = data.rate
                end
                inst.Enabled = true
            end)
        end
    end
    FIX.particleBackup = {}

    FIX.count = 0
end

-- UI ALPHA
local UA={v=0}
local function apA(i)if i:IsA("GuiObject")then if i:GetAttribute("__uob")==nil then
i:SetAttribute("__uob",i.BackgroundTransparency)end
local o=i:GetAttribute("__uob")i.BackgroundTransparency=o+(1-o)*UA.v end end
local function apAll()for _,i in ipairs(Main:GetDescendants())do if i:IsA("GuiObject")then apA(i)end end apA(Main)end
Main.DescendantAdded:Connect(function(i)if i:IsA("GuiObject")then task.defer(function()apA(i)end)end end)

-- SETTINGS
local s1=mSec(pSet,"Giao dien","Tuy chinh giao dien",1)
mSld(s1,"Do trong suot UI","Dieu chinh do mo toan bo UI",0,100,0,1,function(v)UA.v=(v/100)*.9 apAll()end)
mSld(s1,"Kich thuoc UI","Phong to / thu nho",60,150,100,2,function(v)if _G.__setUS then _G.__setUS(v)end end)

local s2=mSec(pSet,"Toi uu hieu suat","Tang FPS toan dien",2)
local fixRow=Instance.new("Frame",s2)
fixRow.Size=UDim2.new(1,0,0,72)
fixRow.BackgroundColor3=T.Card
fixRow.BorderSizePixel=0
fixRow.LayoutOrder=1
cr(fixRow,10)
sk(fixRow,T.Accent,1.5,.3)

local fixTitle=Instance.new("TextLabel",fixRow)
fixTitle.Size=UDim2.new(1,-80,0,22)
fixTitle.Position=UDim2.fromOffset(14,10)
fixTitle.BackgroundTransparency=1
fixTitle.Text="Fix Lag (FPS Boost)"
fixTitle.Font=Enum.Font.GothamBold
fixTitle.TextSize=14
fixTitle.TextColor3=T.Text
fixTitle.TextXAlignment=Enum.TextXAlignment.Left

local fixStatus=Instance.new("TextLabel",fixRow)
fixStatus.Size=UDim2.new(1,-80,0,16)
fixStatus.Position=UDim2.fromOffset(14,32)
fixStatus.BackgroundTransparency=1
fixStatus.Text="Tat - chua toi uu"
fixStatus.Font=Enum.Font.Gotham
fixStatus.TextSize=11
fixStatus.TextColor3=T.Sub
fixStatus.TextXAlignment=Enum.TextXAlignment.Left

local fixTip=Instance.new("TextLabel",fixRow)
fixTip.Size=UDim2.new(1,-80,0,14)
fixTip.Position=UDim2.fromOffset(14,50)
fixTip.BackgroundTransparency=1
fixTip.Text="Xoa suong mu + SmoothPlastic + tat particle"
fixTip.Font=Enum.Font.Gotham
fixTip.TextSize=9
fixTip.TextColor3=T.Sub
fixTip.TextXAlignment=Enum.TextXAlignment.Left

local fixSW=Instance.new("Frame",fixRow)
fixSW.Size=UDim2.fromOffset(50,26)
fixSW.AnchorPoint=Vector2.new(1,.5)
fixSW.Position=UDim2.new(1,-14,.5,0)
fixSW.BackgroundColor3=T.Off
fixSW.BorderSizePixel=0
cr(fixSW,13)

local fixKN=Instance.new("Frame",fixSW)
fixKN.Size=UDim2.fromOffset(22,22)
fixKN.AnchorPoint=Vector2.new(0,.5)
fixKN.Position=UDim2.new(0,2,.5,0)
fixKN.BackgroundColor3=Color3.fromRGB(245,245,250)
fixKN.BorderSizePixel=0
cr(fixKN,11)

local fixBtn=Instance.new("TextButton",fixRow)
fixBtn.Size=UDim2.fromScale(1,1)
fixBtn.BackgroundTransparency=1
fixBtn.Text=""

local fixEnabled=false
fixBtn.MouseButton1Click:Connect(function()
    fixEnabled=not fixEnabled
    if fixEnabled then
        fixStatus.Text="Dang bat... dang quet"
        fixStatus.TextColor3=T.Accent
        TW:Create(fixSW,TweenInfo.new(.15),{BackgroundColor3=T.On}):Play()
        TW:Create(fixKN,TweenInfo.new(.15),{Position=UDim2.new(1,-24,.5,0)}):Play()
        TW:Create(fixRow,TweenInfo.new(.15),{BackgroundColor3=T.CardHi}):Play()
        task.spawn(function()
            enableFix()
            task.wait(.8)
            fixStatus.Text="Da bat - toi uu "..FIX.count.." vat the"
            fixStatus.TextColor3=T.Green
        end)
    else
        fixStatus.Text="Dang tat..."
        fixStatus.TextColor3=T.Sub
        TW:Create(fixSW,TweenInfo.new(.15),{BackgroundColor3=T.Off}):Play()
        TW:Create(fixKN,TweenInfo.new(.15),{Position=UDim2.new(0,2,.5,0)}):Play()
        TW:Create(fixRow,TweenInfo.new(.15),{BackgroundColor3=T.Card}):Play()
        task.spawn(function()
            disableFix()
            task.wait(.5)
            fixStatus.Text="Tat - chua toi uu"
        end)
    end
end)

mBtn(s2,"Quet lai","Ep toi uu ngay","Quet",2,function()
    if FIX.enabled then
        task.spawn(function()
            optimizeLighting()
            scanAll(WS)
            fixStatus.Text="Da quet lai - "..FIX.count.." vat the"
            fixStatus.TextColor3=T.Green
            task.wait(2)
            if FIX.enabled then
                fixStatus.Text="Da bat - toi uu "..FIX.count.." vat the"
                fixStatus.TextColor3=T.Green
            end
        end)
    end
end)

local s3=mSec(pSet,"Hanh dong","Luu va khoi phuc",3)
mBtn(s3,"Dat lai ve mac dinh","Reset vi tri va kich thuoc UI","Reset",1,function()
Main.Position=UDim2.fromScale(.5,.5)if _G.__setUS then _G.__setUS(100)end
if applyScale then task.spawn(applyScale)end end,true)

-- INFO
for _,c in ipairs(pInfo:GetChildren())do if c:IsA("Frame")or c:IsA("TextButton")or c:IsA("TextLabel")then c:Destroy()end end
local function bIS(par,title,desc,ord)local c=Instance.new("Frame",par)c.Size=UDim2.new(1,0,0,0)
c.AutomaticSize=Enum.AutomaticSize.Y c.BackgroundColor3=T.Panel c.BorderSizePixel=0 c.LayoutOrder=ord
cr(c,12)sk(c,T.Stroke,1)
local hf=Instance.new("Frame",c)hf.Size=UDim2.new(1,0,0,48)hf.BackgroundTransparency=1
local tl=Instance.new("TextLabel",hf)tl.Size=UDim2.new(1,-20,0,20)tl.Position=UDim2.fromOffset(14,6)
tl.BackgroundTransparency=1 tl.Text=title tl.Font=Enum.Font.GothamBold tl.TextSize=14
tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
local dl=Instance.new("TextLabel",hf)dl.Size=UDim2.new(1,-20,0,16)dl.Position=UDim2.fromOffset(14,26)
dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=11
dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
local r=Instance.new("Frame",c)r.Size=UDim2.new(1,-20,0,0)r.Position=UDim2.fromOffset(10,48)
r.BackgroundTransparency=1 r.AutomaticSize=Enum.AutomaticSize.Y
local rl=Instance.new("UIListLayout",r)rl.Padding=UDim.new(0,4)rl.SortOrder=Enum.SortOrder.LayoutOrder
local pd=Instance.new("Frame",c)pd.Size=UDim2.new(1,0,0,10)pd.Position=UDim2.new(0,0,1,0)
pd.AnchorPoint=Vector2.new(0,1)pd.BackgroundTransparency=1 return r end
local iR=bIS(pInfo,"Thong tin Script","Tat ca thong tin ve Dungdx PvP",1)
local function aIR(par,lbl,val,ord,cp)local r=Instance.new("Frame",par)r.Size=UDim2.new(1,0,0,40)
r.BackgroundColor3=T.Card r.BorderSizePixel=0 r.LayoutOrder=ord cr(r,8)
local lL=Instance.new("TextLabel",r)lL.Size=UDim2.new(.45,-20,1,0)lL.Position=UDim2.fromOffset(12,0)
lL.BackgroundTransparency=1 lL.Text=lbl lL.Font=Enum.Font.GothamMedium lL.TextSize=12
lL.TextColor3=T.Sub lL.TextXAlignment=Enum.TextXAlignment.Left
local vL=Instance.new("TextLabel",r)vL.AnchorPoint=Vector2.new(1,.5)
vL.Position=UDim2.new(1,cp and -46 or -12,.5,0)vL.Size=UDim2.new(.55,cp and -40 or -20,1,0)
vL.BackgroundTransparency=1 vL.Text=val vL.Font=Enum.Font.GothamBold vL.TextSize=12
vL.TextColor3=T.Text vL.TextXAlignment=Enum.TextXAlignment.Right vL.TextTruncate=Enum.TextTruncate.AtEnd
if cp then local cc=Instance.new("TextButton",r)cc.Size=UDim2.fromOffset(28,28)
cc.AnchorPoint=Vector2.new(1,.5)cc.Position=UDim2.new(1,-8,.5,0)cc.BackgroundColor3=T.Panel
cc.Text="📔"cc.Font=Enum.Font.GothamBold cc.TextSize=16 cc.TextColor3=T.Accent
cc.BorderSizePixel=0 cc.AutoButtonColor=false cr(cc,6)sk(cc,T.Accent,1,.5)
cc.MouseButton1Click:Connect(function()if setclipboard then pcall(function()setclipboard(val)end)end
cc.Text="✅"cc.TextColor3=T.Green task.wait(1.2)cc.Text="📔"cc.TextColor3=T.Accent end)end end
aIR(iR,"Ten Script","Dungdx PvP",1)aIR(iR,"Phien ban","v2.1.0",2)
aIR(iR,"Game ho tro","Blox Fruits (Roblox)",3)aIR(iR,"Chu so huu","Dungdx",4)
aIR(iR,"Ten that","Le Thanh Anh Dung",5)aIR(iR,"Discord Server","Blox Community VN",6)
aIR(iR,"Link Discord","https://discord.gg/jbCzvtmSZt",7,true)

local bC=Instance.new("Frame",pInfo)
bC.Size=UDim2.new(1,0,0,150)
bC.BackgroundColor3=Color3.fromRGB(15,22,45)
bC.BorderSizePixel=0 bC.LayoutOrder=2 bC.ClipsDescendants=true
cr(bC,16)sk(bC,T.Accent,1,0.5)
local bG=Instance.new("UIGradient",bC)
bG.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,Color3.fromRGB(37,99,235)),
ColorSequenceKeypoint.new(0.45,Color3.fromRGB(30,42,76)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(15,22,45))})bG.Rotation=120
local glow1=Instance.new("Frame",bC)glow1.Size=UDim2.fromOffset(220,220)
glow1.Position=UDim2.new(1,-110,0,-110)glow1.BackgroundColor3=T.Accent
glow1.BackgroundTransparency=.88 glow1.BorderSizePixel=0 cr(glow1,110)
local glow2=Instance.new("Frame",bC)glow2.Size=UDim2.fromOffset(160,160)
glow2.Position=UDim2.new(0,-80,1,-80)glow2.BackgroundColor3=Color3.fromRGB(139,92,246)
glow2.BackgroundTransparency=.9 glow2.BorderSizePixel=0 cr(glow2,80)
local sigBox=Instance.new("Frame",bC)sigBox.Size=UDim2.fromOffset(92,92)
sigBox.Position=UDim2.new(0,24,.5,-46)sigBox.BackgroundColor3=Color3.fromRGB(250,250,252)
sigBox.BorderSizePixel=0 cr(sigBox,20)
local sigStroke=Instance.new("UIStroke",sigBox)sigStroke.Color=Color3.fromRGB(255,255,255)
sigStroke.Thickness=2 sigStroke.Transparency=.35
local sigImg=Instance.new("ImageLabel",sigBox)sigImg.Size=UDim2.fromScale(1,1)
sigImg.BackgroundTransparency=1 sigImg.Image=LOGO_IMG sigImg.ScaleType=Enum.ScaleType.Fit
sigImg.ZIndex=2 cr(sigImg,20)
local nmL=Instance.new("TextLabel",bC)nmL.Size=UDim2.new(1,-150,0,32)
nmL.Position=UDim2.fromOffset(132,34)nmL.BackgroundTransparency=1 nmL.Text="Dungdx"
nmL.Font=Enum.Font.GothamBlack nmL.TextSize=26 nmL.TextColor3=Color3.fromRGB(255,255,255)
nmL.TextXAlignment=Enum.TextXAlignment.Left nmL.ZIndex=2
local tgL=Instance.new("TextLabel",bC)tgL.Size=UDim2.new(1,-150,0,18)
tgL.Position=UDim2.fromOffset(132,72)tgL.BackgroundTransparency=1
tgL.Text="PvP Script for Blox Fruits"tgL.Font=Enum.Font.GothamMedium
tgL.TextSize=13 tgL.TextColor3=T.Accent tgL.TextXAlignment=Enum.TextXAlignment.Left tgL.ZIndex=2
local dots=Instance.new("Frame",bC)dots.Size=UDim2.fromOffset(50,10)
dots.Position=UDim2.fromOffset(132,100)dots.BackgroundTransparency=1 dots.ZIndex=2
for i=1,3 do local d=Instance.new("Frame",dots)d.Size=UDim2.fromOffset(6,6)
d.Position=UDim2.fromOffset((i-1)*12,2)d.BackgroundColor3=T.Accent
d.BackgroundTransparency=(i==1)and 0 or((i==2)and .4 or .7)
d.BorderSizePixel=0 cr(d,3)end
local vB=Instance.new("TextLabel",bC)vB.Size=UDim2.fromOffset(64,24)
vB.AnchorPoint=Vector2.new(1,0)vB.Position=UDim2.new(1,-14,0,14)
vB.BackgroundColor3=Color3.fromRGB(255,255,255)vB.BackgroundTransparency=.88
vB.Text="v2.1.0"vB.Font=Enum.Font.GothamBold vB.TextSize=10
vB.TextColor3=Color3.fromRGB(255,255,255)vB.BorderSizePixel=0 vB.ZIndex=2 cr(vB,12)

local fR=bIS(pInfo,"Tinh nang hien co","Nhung tinh nang chinh cua script",3)
local feats={
{ic="🎯",n="Macro",d="Tu dong hoa thao tac",c=Color3.fromRGB(96,165,250)},
{ic="👁️",n="Visual",d="Hien thi thong tin trong game",c=Color3.fromRGB(167,139,250)},
{ic="🏃",n="Move",d="Ho tro di chuyen, ne skill",c=Color3.fromRGB(52,211,153)},
{ic="⚙️",n="Settings",d="Tuy chinh & ca nhan hoa",c=Color3.fromRGB(251,191,36)}}
for i,f in ipairs(feats)do local c=Instance.new("Frame",fR)c.Size=UDim2.new(1,0,0,60)
c.BackgroundColor3=T.Card c.BorderSizePixel=0 c.LayoutOrder=i cr(c,10)sk(c,f.c,1.2,.3)
local icF=Instance.new("Frame",c)icF.Size=UDim2.fromOffset(36,36)icF.Position=UDim2.fromOffset(10,12)
icF.BackgroundColor3=f.c icF.BackgroundTransparency=.82 icF.BorderSizePixel=0 cr(icF,9)
local icL=Instance.new("TextLabel",icF)icL.Size=UDim2.fromScale(1,1)icL.BackgroundTransparency=1
icL.Text=f.ic icL.Font=Enum.Font.GothamBold icL.TextSize=20 icL.TextColor3=f.c
local nL=Instance.new("TextLabel",c)nL.Size=UDim2.new(1,-90,0,16)nL.Position=UDim2.fromOffset(56,12)
nL.BackgroundTransparency=1 nL.Text=f.n nL.Font=Enum.Font.GothamBold nL.TextSize=13
nL.TextColor3=T.Text nL.TextXAlignment=Enum.TextXAlignment.Left
local dL=Instance.new("TextLabel",c)dL.Size=UDim2.new(1,-90,0,14)dL.Position=UDim2.fromOffset(56,30)
dL.BackgroundTransparency=1 dL.Text=f.d dL.Font=Enum.Font.Gotham dL.TextSize=10
dL.TextColor3=T.Sub dL.TextXAlignment=Enum.TextXAlignment.Left
local aL=Instance.new("TextLabel",c)aL.Size=UDim2.fromOffset(24,24)aL.AnchorPoint=Vector2.new(1,.5)
aL.Position=UDim2.new(1,-10,.5,0)aL.BackgroundTransparency=1 aL.Text=">"
aL.Font=Enum.Font.GothamBold aL.TextSize=18 aL.TextColor3=T.Sub end
local foC=Instance.new("Frame",pInfo)foC.Size=UDim2.new(1,0,0,88)foC.BackgroundColor3=T.Panel
foC.BorderSizePixel=0 foC.LayoutOrder=4 cr(foC,12)sk(foC,T.Stroke,1)
local hF=Instance.new("Frame",foC)hF.Size=UDim2.fromOffset(44,44)hF.Position=UDim2.fromOffset(16,22)
hF.BackgroundColor3=T.Accent2 hF.BackgroundTransparency=.7 hF.BorderSizePixel=0 cr(hF,22)
sk(hF,T.Accent,1,.4)
local hL=Instance.new("TextLabel",hF)hL.Size=UDim2.fromScale(1,1)hL.BackgroundTransparency=1
hL.Text="❤️"hL.Font=Enum.Font.GothamBold hL.TextSize=22 hL.TextColor3=T.Accent
local tkL=Instance.new("TextLabel",foC)tkL.Size=UDim2.new(1,-80,0,18)tkL.Position=UDim2.fromOffset(72,18)
tkL.BackgroundTransparency=1 tkL.Text="Cam on ban da su dung script!"tkL.Font=Enum.Font.GothamBold
tkL.TextSize=12 tkL.TextColor3=T.Text tkL.TextXAlignment=Enum.TextXAlignment.Left
local wsL=Instance.new("TextLabel",foC)wsL.Size=UDim2.new(1,-80,0,16)wsL.Position=UDim2.fromOffset(72,38)
wsL.BackgroundTransparency=1 wsL.Text="Chuc ban co nhung tran PvP that tuyet voi!"
wsL.Font=Enum.Font.Gotham wsL.TextSize=10 wsL.TextColor3=T.Sub
wsL.TextXAlignment=Enum.TextXAlignment.Left
local snL=Instance.new("TextLabel",foC)snL.Size=UDim2.new(1,-80,0,14)snL.Position=UDim2.fromOffset(72,58)
snL.BackgroundTransparency=1 snL.Text="-- Dungdx"snL.Font=Enum.Font.GothamMedium snL.TextSize=11
snL.TextColor3=T.Accent snL.TextXAlignment=Enum.TextXAlignment.Left

-- NEON + PRESS
local Ne={en=true,pr=true,tb=.8,pu=true}
local function nz(c)local h,s,v=Color3.toHSV(c)s=math.min(1,s*1.4+.15)v=math.min(1,v*1.15+.25)
return Color3.fromHSV(h,s,v)end
local function nSt(st)if not st or not st.Parent then return end
if st:GetAttribute("__n")then return end st:SetAttribute("__n",true)
local b=st.Color local br=nz(b)st.Transparency=0
if st.Thickness<1.5+Ne.tb then st.Thickness=1.5+Ne.tb end st.Color=br
local g=Instance.new("UIGradient",st)g.Name="__ng"
g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,br),
ColorSequenceKeypoint.new(.5,Color3.new(math.min(1,br.R+.3),math.min(1,br.G+.3),math.min(1,br.B+.3))),
ColorSequenceKeypoint.new(1,br)})g.Rotation=45
if Ne.pu then task.spawn(function()while st.Parent and st:GetAttribute("__n")do
TW:Create(st,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=.15}):Play()
task.wait(1.2)if not st.Parent then break end
TW:Create(st,TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0}):Play()
task.wait(1.2)end end)end end
local function atP(b)if not b or not b.Parent then return end if b:GetAttribute("__p")then return end
b:SetAttribute("__p",true)
local t=b if b:IsA("GuiObject")and b.BackgroundTransparency>=.9 then local p=b.Parent
if p and p:IsA("GuiObject")then t=p end end
local s=t:FindFirstChildOfClass("UIScale")if not s then s=Instance.new("UIScale",t)s.Scale=1 end
local pr=false
local function dn()pr=true TW:Create(s,TweenInfo.new(.07,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=.93}):Play()end
local function up()if not pr then return end pr=false
TW:Create(s,TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()end
b.MouseButton1Down:Connect(dn)b.MouseButton1Up:Connect(up)b.MouseLeave:Connect(up)
b.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then dn()end end)
b.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then up()end end)end
local function scN()for _,i in ipairs(GUI:GetDescendants())do
if i:IsA("UIStroke")and Ne.en then nSt(i)
elseif(i:IsA("TextButton")or i:IsA("ImageButton"))and Ne.pr then atP(i)end end end
GUI.DescendantAdded:Connect(function(i)task.defer(function()
if i:IsA("UIStroke")and Ne.en then nSt(i)
elseif(i:IsA("TextButton")or i:IsA("ImageButton"))and Ne.pr then atP(i)end end)end)
scN()

local Tgl=Instance.new("TextButton",GUI)Tgl.Size=UDim2.fromOffset(58,58)
Tgl.Position=UDim2.new(0,16,.5,-29)Tgl.BackgroundColor3=T.Accent2 Tgl.Text=""
Tgl.BorderSizePixel=0 Tgl.AutoButtonColor=false Tgl.Visible=false cr(Tgl,29)
sk(Tgl,T.Accent,2,.3)gr(Tgl,Color3.fromRGB(96,165,250),Color3.fromRGB(37,99,235))dg(Tgl)
local tImg=Instance.new("ImageLabel",Tgl)tImg.Size=UDim2.fromScale(1,1)tImg.BackgroundTransparency=1
tImg.Image=AVATAR tImg.ScaleType=Enum.ScaleType.Crop tImg.ZIndex=2 cr(tImg,29)
local glr=Instance.new("Frame",Tgl)glr.Size=UDim2.fromScale(1,1)glr.BackgroundTransparency=1 glr.ZIndex=3 cr(glr,29)
local gls=Instance.new("UIStroke",glr)gls.Color=Color3.fromRGB(96,165,250)gls.Thickness=2
gls.Transparency=.3
_G.__tgl=Tgl
Tgl.MouseButton1Click:Connect(function()Main.Visible=true Tgl.Visible=false end)
Cl.MouseButton1Click:Connect(function()GUI.Enabled=false end)
Mn.MouseButton1Click:Connect(function()Main.Visible=false Tgl.Visible=true end)
UIS.InputBegan:Connect(function(i,g)if g then return end
if i.KeyCode==Enum.KeyCode.RightShift then Main.Visible=not Main.Visible
Tgl.Visible=not Main.Visible end end)
task.defer(applyScale)task.delay(.1,applyScale)

task.spawn(function()
    pcall(function()CP:PreloadAsync({AVATAR,LOGO_IMG})end)
    task.wait(.3)
    for _,inst in ipairs(GUI:GetDescendants())do
        if inst:IsA("ImageLabel")and(inst.Image==AVATAR or inst.Image==LOGO_IMG)then
            local old=inst.Image inst.Image=""task.wait(.05)inst.Image=old
        end
    end
    task.wait(1)
    for _,inst in ipairs(GUI:GetDescendants())do
        if inst:IsA("ImageLabel")and(inst.Image==AVATAR or inst.Image==LOGO_IMG)and not inst.IsLoaded then
            local old=inst.Image inst.Image=""task.wait(.05)inst.Image=old
        end
    end
end)

_G.DungdxPvP={GUI=GUI,Main=Main,Theme=T,Macros=M,Refresh=refreshM,FixLag=FIX,
Destroy=function()for _,p in ipairs(Players:GetPlayers())do rmESP(p)end
pcall(function()if FIX.enabled then disableFix()end end)
pcall(function()GUI:Destroy()end)_G.DungdxPvP=nil _G.__tgl=nil end}
_G.DungdxNeon={Set=function(on)Ne.en=on if on then scN()end end,
Press=function(on)Ne.pr=on if on then scN()end end,Pulse=function(on)Ne.pu=on end}

print("[Dungdx PvP] Loaded - v2.1.0 - Ultimate Fix Lag + No Fog")