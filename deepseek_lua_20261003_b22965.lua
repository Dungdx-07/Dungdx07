--[[ Dungdx PvP v3.8a · base + fly fix + PvP placeholder ]]
if not game:IsLoaded() then game.Loaded:Wait() end task.wait(.3)
if _G.DungdxPvP then pcall(function() _G.DungdxPvP:Destroy() end) task.wait(.15) end

local Players=game:GetService("Players")local UIS=game:GetService("UserInputService")
local VIM=game:GetService("VirtualInputManager")local TW=game:GetService("TweenService")
local RS=game:GetService("RunService")local WS=game:GetService("Workspace")
local LT=game:GetService("Lighting")local CP=game:GetService("ContentProvider")
local Cam=WS.CurrentCamera local LP=Players.LocalPlayer

local GUI_PARENT=(function()
    local ok,hui=pcall(function() return gethui and gethui() end)
    if ok and typeof(hui)=="Instance" then return hui end
    return LP:WaitForChild("PlayerGui",10) or LP:FindFirstChild("PlayerGui")
end)()
if not GUI_PARENT then error("[DungdxPvP] No GUI parent") end

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
Vr.BackgroundColor3=T.Accent2 Vr.Text="v3.8"Vr.Font=Enum.Font.GothamBold Vr.TextSize=11
Vr.TextColor3=Color3.fromRGB(220,235,255)Vr.BorderSizePixel=0 cr(Vr,12)
local Cl=Instance.new("TextButton",H)Cl.Size=UDim2.fromOffset(30,30)Cl.AnchorPoint=Vector2.new(1,0)
Cl.Position=UDim2.new(1,-14,0,15)Cl.BackgroundColor3=T.Card Cl.Text="X"Cl.Font=Enum.Font.GothamBold
Cl.TextSize=14 Cl.TextColor3=T.Text Cl.BorderSizePixel=0 Cl.AutoButtonColor=false cr(Cl,8)
local Mn=Instance.new("TextButton",H)Mn.Size=UDim2.fromOffset(30,30)Mn.AnchorPoint=Vector2.new(1,0)
Mn.Position=UDim2.new(1,-50,0,15)Mn.BackgroundColor3=T.Card Mn.Text="-"Mn.Font=Enum.Font.GothamBold
Mn.TextSize=16 Mn.TextColor3=T.Text Mn.BorderSizePixel=0 Mn.AutoButtonColor=false cr(Mn,8)

local Bd=Instance.new("Frame",Main)Bd.Size=UDim2.new(1,0,1,-60)Bd.Position=UDim2.new(0,0,0,60)
Bd.BackgroundTransparency=1
local SB=Instance.new("Frame",Bd)SB.Size=UDim2.new(0,170,1,0)SB.BackgroundColor3=T.Sidebar
SB.BorderSizePixel=0
local SBc=Instance.new("Frame",SB)SBc.Size=UDim2.new(0,16,1,0)SBc.Position=UDim2.new(1,-16,0,0)
SBc.BackgroundColor3=T.Sidebar SBc.BorderSizePixel=0
local NL=Instance.new("Frame",SB)NL.Size=UDim2.new(1,-16,1,-90)NL.Position=UDim2.fromOffset(8,8)
NL.BackgroundTransparency=1 local NLL=Instance.new("UIListLayout",NL)
NLL.Padding=UDim.new(0,4)NLL.SortOrder=Enum.SortOrder.LayoutOrder

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

local UI={Orientation="Ngang"}
local NavRefs={}
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
lb.TextColor3=a and T.Text or T.Sub end
b.MouseButton1Click:Connect(function()for k,p in pairs(Pgs)do p.Visible=(k==id)end
for k,fn in pairs(NBs)do fn(k==id)end end)NBs[id]=sA
NavRefs[id]={btn=b,icBox=icBox,ic=ic,lb=lb,ac=ac}
return pg end

local pMacro=addTab("Macro","🎯","Macro",1)
local pVisual=addTab("Visual","👁️","Visual",2)
local pMove=addTab("Move","🏃","Move",3)
local pPvP=addTab("PvP","⚔","PvP",4)
local pSet=addTab("Settings","⚙","Settings",5)
local pInfo=addTab("Info","💠","Info",6)
for k,p in pairs(Pgs)do p.Visible=(k=="Macro")end
for k,fn in pairs(NBs)do fn(k=="Macro")end

applyLayout=function()
    if R.device=="mobile"then
        SB.Size=UDim2.new(0,132,1,0)SBc.Size=UDim2.new(0,16,1,0)SBc.Position=UDim2.new(1,-16,0,0)
        Ct.Position=UDim2.new(0,132,0,0)Ct.Size=UDim2.new(1,-132,1,0)
        NL.Position=UDim2.fromOffset(6,6)NL.Size=UDim2.new(1,-12,1,-86)
        Ow.Size=UDim2.new(1,-12,0,68)Ow.Position=UDim2.new(.5,0,1,-6)
        Sb.Visible=false Vr.Position=UDim2.fromOffset(200,18)
    else
        SB.Size=UDim2.new(0,170,1,0)SBc.Size=UDim2.new(0,16,1,0)SBc.Position=UDim2.new(1,-16,0,0)
        Ct.Position=UDim2.new(0,170,0,0)Ct.Size=UDim2.new(1,-170,1,0)
        NL.Position=UDim2.fromOffset(8,8)NL.Size=UDim2.new(1,-16,1,-90)
        Ow.Size=UDim2.new(1,-16,0,72)Ow.Position=UDim2.new(.5,0,1,-8)
        Sb.Visible=true Vr.Position=UDim2.fromOffset(240,18)
    end
end

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

local function mDrop(par,name,desc,opts,def,ord,cb)local r=mRow(par,ord)
local tl=Instance.new("TextLabel",r)tl.Size=UDim2.new(.55,0,0,18)tl.Position=UDim2.fromOffset(12,6)
tl.BackgroundTransparency=1 tl.Text=name tl.Font=Enum.Font.GothamMedium tl.TextSize=12
tl.TextColor3=T.Text tl.TextXAlignment=Enum.TextXAlignment.Left
local dl=Instance.new("TextLabel",r)dl.Size=UDim2.new(.55,0,0,14)dl.Position=UDim2.fromOffset(12,24)
dl.BackgroundTransparency=1 dl.Text=desc or ""dl.Font=Enum.Font.Gotham dl.TextSize=10
dl.TextColor3=T.Sub dl.TextXAlignment=Enum.TextXAlignment.Left
local b=Instance.new("TextButton",r)b.Size=UDim2.fromOffset(100,28)b.AnchorPoint=Vector2.new(1,.5)
b.Position=UDim2.new(1,-12,.5,0)b.BackgroundColor3=T.Input b.Text=def.." v"
b.Font=Enum.Font.GothamBold b.TextSize=11 b.TextColor3=T.Text
b.BorderSizePixel=0 b.AutoButtonColor=false cr(b,8)sk(b,T.Stroke,1)
local cur=def
b.MouseButton1Click:Connect(function()
    local ix=table.find(opts,cur) or 1 ix=ix%#opts+1 cur=opts[ix]
    b.Text=cur.." v"if cb then cb(cur)end end)
return {Get=function()return cur end}end

-- MOVEMENT [FIXED FLY]
local Mv={
    Fly={enabled=false,bv=nil,bg=nil,conn=nil,speed=120,upHold=false,downHold=false,ui=nil,origWS=16},
    Water={enabled=false,thread=nil,plane=nil,origSize=nil},
    Noclip={enabled=false,conns={},loopConn=nil},
}
local function buildFlyUI()
    if Mv.Fly.ui then return Mv.Fly.ui end
    local wrap=Instance.new("Frame",GUI)
    wrap.Name="__FlyUI"wrap.BackgroundTransparency=1
    wrap.Size=UDim2.fromOffset(90,180)wrap.Position=UDim2.new(1,-104,.5,-90)
    wrap.ZIndex=200 wrap.Visible=false Mv.Fly.ui=wrap
    local function mkBtn(txt,y,color)local b=Instance.new("TextButton",wrap)
        b.Size=UDim2.fromOffset(80,80)b.Position=UDim2.fromOffset(0,y)
        b.BackgroundColor3=color b.BackgroundTransparency=.25
        b.Text=txt b.TextColor3=Color3.new(1,1,1)b.TextSize=22
        b.Font=Enum.Font.GothamBold b.AutoButtonColor=false b.ZIndex=201 cr(b,40)
        local s=Instance.new("UIStroke",b)s.Color=color s.Thickness=2
        s.Transparency=.4 return b end
    local upB=mkBtn("^",0,Color3.fromRGB(60,140,220))
    local dnB=mkBtn("v",90,Color3.fromRGB(80,80,100))
    local function hold(b,set)
        b.MouseButton1Down:Connect(function() set(true) b.BackgroundTransparency=0 end)
        b.MouseButton1Up:Connect(function() set(false) b.BackgroundTransparency=.25 end)
        b.MouseLeave:Connect(function() set(false) b.BackgroundTransparency=.25 end)
        b.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then set(true) b.BackgroundTransparency=0 end end)
        b.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.Touch then set(false) b.BackgroundTransparency=.25 end end)
    end
    hold(upB,function(v) Mv.Fly.upHold=v end)
    hold(dnB,function(v) Mv.Fly.downHold=v end)
    return wrap
end

local function flyStart()
    local F=Mv.Fly if F.enabled then return end
    local ch=LP.Character if not ch then return end
    local hrp=ch:FindFirstChild("HumanoidRootPart")
    local hum=ch:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    F.enabled=true F.origWS=hum.WalkSpeed
    F.bv=Instance.new("BodyVelocity")F.bv.Name="__DungdxFlyBV"
    F.bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
    F.bv.P=125000 F.bv.Velocity=Vector3.zero F.bv.Parent=hrp
    F.bg=Instance.new("BodyGyro")F.bg.Name="__DungdxFlyBG"
    F.bg.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
    F.bg.P=30000 F.bg.D=1000 F.bg.CFrame=hrp.CFrame F.bg.Parent=hrp
    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
    end)
    hum.PlatformStand=false
    buildFlyUI().Visible=true
    local function getInput()
        local md=hum.MoveDirection
        if md.Magnitude>0.05 then return md end
        local x,z=0,0
        if UIS:IsKeyDown(Enum.KeyCode.W) then z=z-1 end
        if UIS:IsKeyDown(Enum.KeyCode.S) then z=z+1 end
        if UIS:IsKeyDown(Enum.KeyCode.A) then x=x-1 end
        if UIS:IsKeyDown(Enum.KeyCode.D) then x=x+1 end
        if x~=0 or z~=0 then return Vector3.new(x,0,z).Unit end
        return Vector3.zero
    end
    F.conn=RS.Heartbeat:Connect(function()
        local F=Mv.Fly if not F.enabled then return end
        local ch=LP.Character if not ch then return end
        local hrp=ch:FindFirstChild("HumanoidRootPart")
        local hum=ch:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if not F.bv or not F.bv.Parent then
            F.bv=Instance.new("BodyVelocity")F.bv.Name="__DungdxFlyBV"
            F.bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
            F.bv.P=125000 F.bv.Velocity=Vector3.zero F.bv.Parent=hrp
        end
        if not F.bg or not F.bg.Parent then
            F.bg=Instance.new("BodyGyro")F.bg.Name="__DungdxFlyBG"
            F.bg.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
            F.bg.P=30000 F.bg.D=1000 F.bg.CFrame=hrp.CFrame F.bg.Parent=hrp
        end
        if hum.PlatformStand then hum.PlatformStand=false end
        local st=hum:GetState()
        if st==Enum.HumanoidStateType.FallingDown
        or st==Enum.HumanoidStateType.Ragdoll
        or st==Enum.HumanoidStateType.PlatformStanding then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end
        local camCF=Cam.CFrame
        local look=camCF.LookVector
        local flat=Vector3.new(look.X,0,look.Z)
        if flat.Magnitude<0.01 then flat=Vector3.new(0,0,-1) end
        flat=flat.Unit
        local right=Vector3.new(camCF.RightVector.X,0,camCF.RightVector.Z).Unit
        F.bg.CFrame=CFrame.lookAt(hrp.Position,hrp.Position+flat)
        local md=getInput()local vel=Vector3.zero
        if md.Magnitude>0.05 then
            local fb=md:Dot(flat)local lr=md:Dot(right)
            vel=flat*fb+right*lr
            if vel.Magnitude>0.01 then vel=vel.Unit*F.speed end
        end
        if F.upHold then vel=vel+Vector3.new(0,F.speed,0) end
        if F.downHold then vel=vel-Vector3.new(0,F.speed,0) end
        F.bv.Velocity=vel
    end)
    print("[Fly] Started")
end
local function flyStop()
    local F=Mv.Fly if not F.enabled then return end
    F.enabled=false
    if F.conn then pcall(function() F.conn:Disconnect() end)F.conn=nil end
    if F.bv then pcall(function() F.bv:Destroy() end)F.bv=nil end
    if F.bg then pcall(function() F.bg:Destroy() end)F.bg=nil end
    F.upHold=false F.downHold=false
    if F.ui then F.ui.Visible=false end
    local ch=LP.Character
    if ch then
        local hum=ch:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
                hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
            end)
            hum.PlatformStand=false
        end
    end
    print("[Fly] Stopped")
end
local function findWaterPlane()
    local map=WS:FindFirstChild("Map")if not map then return nil end
    return map:FindFirstChild("WaterBase-Plane")
end
local function waterStart()
    local W=Mv.Water if W.enabled then return end
    W.enabled=true
    local ch=LP.Character
    if ch then local hum=ch:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,false) end) end end
    W.thread=task.spawn(function()
        local plane=findWaterPlane()local tries=0
        while not plane and tries<30 and W.enabled do task.wait(0.5)plane=findWaterPlane()tries=tries+1 end
        if not plane then W.enabled=false return end
        W.plane=plane W.origSize=plane.Size
        while W.enabled do
            if plane and plane.Parent then pcall(function() plane.Size=Vector3.new(plane.Size.X,113,plane.Size.Z) end)
            else plane=findWaterPlane()if plane then W.plane=plane W.origSize=plane.Size end end
            task.wait(0.3)
        end
        if plane and plane.Parent and W.origSize then pcall(function() plane.Size=W.origSize end)end
    end)
end
local function waterStop()
    local W=Mv.Water if not W.enabled then return end
    W.enabled=false task.wait(0.4)
    local ch=LP.Character
    if ch then local hum=ch:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,true) end) end end
end
local function noclipApply(ch)
    for _,p in ipairs(ch:GetDescendants())do
        if p:IsA("BasePart")then
            if p:GetAttribute("__nc_orig")==nil then p:SetAttribute("__nc_orig",p.CanCollide)end
            p.CanCollide=false
        end
    end
end
local function noclipRestore(ch)
    for _,p in ipairs(ch:GetDescendants())do
        if p:IsA("BasePart")then
            local o=p:GetAttribute("__nc_orig")
            if o~=nil then p.CanCollide=o p:SetAttribute("__nc_orig",nil)end
        end
    end
end
local function noclipStart()
    local N=Mv.Noclip if N.enabled then return end
    N.enabled=true N.conns={}
    local function hook(ch)
        noclipApply(ch)
        table.insert(N.conns,ch.DescendantAdded:Connect(function(p)
            if N.enabled and p:IsA("BasePart")then
                if p:GetAttribute("__nc_orig")==nil then p:SetAttribute("__nc_orig",p.CanCollide)end
                p.CanCollide=false
            end
        end))
    end
    if LP.Character then hook(LP.Character)end
    table.insert(N.conns,LP.CharacterAdded:Connect(function(ch)
        task.wait(0.3)if N.enabled then hook(ch)end end))
    local acc=0
    N.loopConn=RS.Heartbeat:Connect(function(dt)
        if not N.enabled then return end
        acc=acc+dt if acc<0.2 then return end acc=0
        local ch=LP.Character if not ch then return end
        for _,p in ipairs(ch:GetDescendants())do
            if p:IsA("BasePart")and p.CanCollide then p.CanCollide=false end
        end
    end)
end
local function noclipStop()
    local N=Mv.Noclip if not N.enabled then return end
    N.enabled=false
    for _,c in ipairs(N.conns)do pcall(function() c:Disconnect() end)end
    N.conns={}
    if N.loopConn then pcall(function() N.loopConn:Disconnect() end)N.loopConn=nil end
    if LP.Character then noclipRestore(LP.Character)end
end
LP.CharacterAdded:Connect(function()
    task.wait(0.4)
    if Mv.Fly.enabled then flyStop()end
    if Mv.Water.enabled then
        local ch=LP.Character
        if ch then local hum=ch:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Swimming,false) end) end end
    end
end)

-- SPEED/JUMP
local spOn,spV=false,60 local jpOn,jpV=false,120 local bsp,bjp=16,50
local function gH()local ch=LP.Character return ch and ch:FindFirstChildOfClass("Humanoid")or nil end
local function rBase()local h=gH()if h then bsp=h.WalkSpeed bjp=h.UseJumpPower and h.JumpPower or h.JumpHeight end end
rBase()LP.CharacterAdded:Connect(function()task.wait(.3)rBase()end)
pcall(function()
    local oi
    oi=hookmetamethod(game,"__newindex",function(s,k,v)
        if Mv.Fly.enabled then return oi(s,k,v) end
        if spOn and s and typeof(s)=="Instance" and s:IsA("Humanoid") and s.Parent==LP.Character then
            if k=="WalkSpeed" then return oi(s,k,spV) end
        end
        return oi(s,k,v)
    end)
end)
RS.Stepped:Connect(function()
    if not (spOn or jpOn) then return end
    if Mv.Fly.enabled then return end
    local h=gH()if not h then return end
    if spOn then if h.WalkSpeed~=spV then h.WalkSpeed=spV end
    else if h.WalkSpeed~=bsp then h.WalkSpeed=bsp end end
    if jpOn then h.UseJumpPower=true if h.JumpPower~=jpV then h.JumpPower=jpV end
    else if h.JumpPower~=bjp then h.JumpPower=bjp end end
end)
local function ap()local h=gH()if not h then return end
if spOn then h.WalkSpeed=spV end
if jpOn then h.UseJumpPower=true h.JumpPower=jpV end end
local m1=mSec(pMove,"Di chuyen","Toi uu toc do & nhay",1)
mTog(m1,"Speed","Bat tang toc do chay",false,1,function(v)spOn=v ap()
if not v then local h=gH()if h then h.WalkSpeed=bsp end end end)
mSld(m1,"Speed Value","Toc do chay",16,200,60,2,function(v)spV=v if spOn then ap()end end)
mTog(m1,"Jump","Bat tang luc nhay",false,3,function(v)jpOn=v ap()
if not v then local h=gH()if h then h.JumpPower=bjp end end end)
mSld(m1,"Jump Value","Luc nhay",50,500,120,4,function(v)jpV=v if jpOn then ap()end end)
local sMove=mSec(pMove,"Di chuyen nang cao","Fly (fixed), Water, Noclip",2)
mTog(sMove,"Fly","Bay tu do (da fix anti-stun)",false,1,function(v)
    if v then flyStart()else flyStop()end
end)
mSld(sMove,"Fly Speed","Toc do bay",20,400,120,2,function(v)Mv.Fly.speed=v end)
mTog(sMove,"Di tren nuoc","Di bo tren mat nuoc",false,3,function(v)
    if v then waterStart()else waterStop()end
end)
mTog(sMove,"Noclip","Xuyen qua vat the",false,4,function(v)
    if v then noclipStart()else noclipStop()end
end)

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
local espAccum=0
RS.RenderStepped:Connect(function(dt)
    if not ESP.on then return end
    espAccum=espAccum+dt if espAccum<0.05 then return end espAccum=0
    local myChar=LP.Character
    local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
    for _,p in ipairs(Players:GetPlayers())do
        if p~=LP then
            local tChar=p.Character
            if tChar then
                local tHRP=tChar:FindFirstChild("HumanoidRootPart")
                local tHum=tChar:FindFirstChildOfClass("Humanoid")
                if tHRP then
                    local e=espC[p]if not e then e=mkESP(p)end
                    if e and e.bb and e.bb.Parent then
                        e.hl.FillColor=ESP.color e.hl.FillTransparency=ESP.trans e.hl.OutlineColor=ESP.color
                        local bb=e.bb
                        local nameL=bb:FindFirstChild("Name")local distL=bb:FindFirstChild("Dist")local hpL=bb:FindFirstChild("HpText")
                        if nameL then nameL.Visible=ESP.name nameL.Text=p.Name nameL.TextColor3=ESP.color end
                        if distL then distL.Visible=ESP.dist
                            if myHRP then local d=(tHRP.Position-myHRP.Position).Magnitude
                                distL.Text=tostring(math.floor(d)).."m" else distL.Text="--"end end
                        if hpL then hpL.Visible=ESP.hp
                            if tHum then
                                local cur=math.floor(tHum.Health)local max=math.floor(tHum.MaxHealth)
                                local ratio=tHum.Health/math.max(tHum.MaxHealth,1)
                                hpL.Text=tostring(cur).." / "..tostring(max)
                                hpL.TextColor3=ratio>.5 and Color3.fromRGB(80,240,130)
                                    or ratio>.25 and Color3.fromRGB(240,200,60)
                                    or Color3.fromRGB(240,80,80)
                            end end
                    end end end end end
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

-- SETTINGS
local UA={v=0}
local function apA(i)if i:IsA("GuiObject")then if i:GetAttribute("__uob")==nil then
i:SetAttribute("__uob",i.BackgroundTransparency)end
local o=i:GetAttribute("__uob")i.BackgroundTransparency=o+(1-o)*UA.v end end
local function apAll()for _,i in ipairs(Main:GetDescendants())do if i:IsA("GuiObject")then apA(i)end end apA(Main)end
Main.DescendantAdded:Connect(function(i)if i:IsA("GuiObject")then task.defer(function()apA(i)end)end end)
local s1=mSec(pSet,"Giao dien","Tuy chinh giao dien",1)
mSld(s1,"Do trong suot UI","Dieu chinh do mo toan bo UI",0,100,0,1,function(v)UA.v=(v/100)*.9 apAll()end)
mSld(s1,"Kich thuoc UI","Phong to / thu nho",60,150,100,2,function(v)if _G.__setUS then _G.__setUS(v)end end)
mDrop(s1,"Bo cuc UI","Huong hien thi giao dien",{"Ngang","Doc"},"Ngang",3,function(v)
    UI.Orientation=v if applyLayout then applyLayout() end end)

-- Toggle
local Tgl=Instance.new("TextButton",GUI)Tgl.Size=UDim2.fromOffset(58,58)
Tgl.Position=UDim2.new(0,16,.5,-29)Tgl.BackgroundColor3=T.Accent2 Tgl.Text=""
Tgl.BorderSizePixel=0 Tgl.AutoButtonColor=false Tgl.Visible=false cr(Tgl,29)
sk(Tgl,T.Accent,2,.3)dg(Tgl)
local tImg=Instance.new("ImageLabel",Tgl)tImg.Size=UDim2.fromScale(1,1)tImg.BackgroundTransparency=1
tImg.Image=AVATAR tImg.ScaleType=Enum.ScaleType.Crop tImg.ZIndex=2 cr(tImg,29)
_G.__tgl=Tgl
Tgl.MouseButton1Click:Connect(function()Main.Visible=true Tgl.Visible=false end)
Cl.MouseButton1Click:Connect(function()GUI.Enabled=false end)
Mn.MouseButton1Click:Connect(function()Main.Visible=false Tgl.Visible=true end)
UIS.InputBegan:Connect(function(i,g)if g then return end
if i.KeyCode==Enum.KeyCode.RightShift then Main.Visible=not Main.Visible
Tgl.Visible=not Main.Visible end end)
task.defer(applyScale)task.delay(.1,applyScale)

-- EXPORT helpers để lần 2 dùng
_G.DungdxPvP={
    GUI=GUI,Main=Main,Theme=T,
    Pages=Pgs,
    Helpers={mSec=mSec,mRow=mRow,mTog=mTog,mSld=mSld,mBtn=mBtn,mDrop=mDrop},
    Movement=Mv,ESP=ESP,
    _getH=gH,_flyStart=flyStart,_flyStop=flyStop,
    _waterStart=waterStart,_waterStop=waterStop,
    _noclipStart=noclipStart,_noclipStop=noclipStop,
    Destroy=function()
        for _,p in ipairs(Players:GetPlayers())do rmESP(p)end
        pcall(function()if Mv.Fly.enabled then flyStop()end end)
        pcall(function()if Mv.Water.enabled then waterStop()end end)
        pcall(function()if Mv.Noclip.enabled then noclipStop()end end)
        pcall(function()GUI:Destroy()end)
        _G.DungdxPvP=nil _G.__tgl=nil
    end}
print("[DungdxPvP v3.8a] Base loaded - run part 2 for PvP tab")