-- Dungdx PvP Panel - clean Roblox LocalScript
-- Safe utility/training UI. Does not bypass anti-cheat or server validation.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local State = {
    Open=true, Tab="Combat", Target=nil, ShowDistance=true,
    ComboRunning=false, StopCombo=false,
    Combos={Default={{name="M1",delay=.12},{name="Dash",delay=.18},{name="Skill Z",delay=.35},{name="Skill X",delay=.45}}},
    SelectedCombo="Default"
}

local function New(c,p) local x=Instance.new(c); for k,v in pairs(p or {}) do x[k]=v end; return x end
local function Corner(x,r) New("UICorner",{Parent=x,CornerRadius=UDim.new(0,r or 8)}) end
local function Stroke(x,t) New("UIStroke",{Parent=x,Color=Color3.fromRGB(55,65,85),Transparency=t or 0,Thickness=1}) end
local function Tw(x,p) TweenService:Create(x,TweenInfo.new(.14,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
local function Root(p) local c=p and p.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function Dist(p) local a,b=Root(LP),Root(p); return a and b and (a.Position-b.Position).Magnitude or math.huge end

local G=New("ScreenGui",{Name="DungdxPvP",Parent=PG,ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
local Main=New("Frame",{Parent=G,Size=UDim2.fromOffset(760,500),Position=UDim2.new(.5,-380,.5,-250),BackgroundColor3=Color3.fromRGB(13,16,23),BorderSizePixel=0}); Corner(Main,14); Stroke(Main)
local Top=New("Frame",{Parent=Main,Size=UDim2.new(1,0,0,58),BackgroundColor3=Color3.fromRGB(18,22,31),BorderSizePixel=0}); Corner(Top,14)
New("TextLabel",{Parent=Top,Position=UDim2.fromOffset(20,8),Size=UDim2.fromOffset(400,24),BackgroundTransparency=1,Text="DUNGDX  •  PvP PANEL",Font=Enum.Font.GothamBold,TextSize=17,TextColor3=Color3.fromRGB(240,243,255),TextXAlignment=Enum.TextXAlignment.Left})
New("TextLabel",{Parent=Top,Position=UDim2.fromOffset(20,31),Size=UDim2.fromOffset(400,18),BackgroundTransparency=1,Text="Combat utility / combo workspace",Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(135,145,165),TextXAlignment=Enum.TextXAlignment.Left})
local Close=New("TextButton",{Parent=Top,Size=UDim2.fromOffset(34,34),Position=UDim2.new(1,-45,0,12),BackgroundColor3=Color3.fromRGB(28,33,44),Text="×",Font=Enum.Font.GothamBold,TextSize=22,TextColor3=Color3.fromRGB(220,225,235),AutoButtonColor=false}); Corner(Close,9)
local Side=New("Frame",{Parent=Main,Position=UDim2.fromOffset(12,70),Size=UDim2.fromOffset(160,418),BackgroundColor3=Color3.fromRGB(17,21,29),BorderSizePixel=0}); Corner(Side,11); Stroke(Side,.35)
local Content=New("Frame",{Parent=Main,Position=UDim2.fromOffset(184,70),Size=UDim2.new(1,-196,1,-82),BackgroundTransparency=1})
local Pages, Tabs={},{ }
local function Page(name)
 local p=New("ScrollingFrame",{Parent=Content,Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,Visible=false,CanvasSize=UDim2.new()});
 New("UIPadding",{Parent=p,PaddingRight=UDim.new(0,5),PaddingBottom=UDim.new(0,10)}); New("UIListLayout",{Parent=p,Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder}); Pages[name]=p; return p
end
local function Tab(name,icon,i)
 local b=New("TextButton",{Parent=Side,Size=UDim2.new(1,-16,0,42),Position=UDim2.fromOffset(8,10+(i-1)*48),BackgroundColor3=Color3.fromRGB(17,21,29),Text="  "..icon.."   "..name,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Color3.fromRGB(150,158,178),TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false}); Corner(b,8); Tabs[name]=b
end
local Combat,Target,Movement,Macro,Settings=Page("Combat"),Page("Target"),Page("Movement"),Page("Macro"),Page("Settings")
Tab("Combat","⚔",1); Tab("Target","◎",2); Tab("Movement","➤",3); Tab("Macro","▣",4); Tab("Settings","⚙",5)
local function Title(p,a,b)
 local h=New("Frame",{Parent=p,Size=UDim2.new(1,0,0,54),BackgroundTransparency=1}); New("TextLabel",{Parent=h,Size=UDim2.new(1,0,0,25),BackgroundTransparency=1,Text=a,Font=Enum.Font.GothamBold,TextSize=18,TextColor3=Color3.fromRGB(240,243,255),TextXAlignment=Enum.TextXAlignment.Left}); New("TextLabel",{Parent=h,Position=UDim2.fromOffset(0,28),Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=b,Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(125,135,155),TextXAlignment=Enum.TextXAlignment.Left})
end
local function Section(p,t) local f=New("Frame",{Parent=p,Size=UDim2.new(1,0,0,42),BackgroundColor3=Color3.fromRGB(18,22,30),BorderSizePixel=0}); Corner(f,9); Stroke(f,.5); New("TextLabel",{Parent=f,Position=UDim2.fromOffset(13,0),Size=UDim2.new(1,-26,1,0),BackgroundTransparency=1,Text=t,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.fromRGB(205,212,228),TextXAlignment=Enum.TextXAlignment.Left}); return f end
local function Toggle(p,t,v,cb)
 local f=New("Frame",{Parent=p,Size=UDim2.new(1,0,0,48),BackgroundColor3=Color3.fromRGB(18,22,30),BorderSizePixel=0}); Corner(f,9); Stroke(f,.5); New("TextLabel",{Parent=f,Position=UDim2.fromOffset(13,0),Size=UDim2.new(1,-75,1,0),BackgroundTransparency=1,Text=t,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Color3.fromRGB(215,220,232),TextXAlignment=Enum.TextXAlignment.Left})
 local b=New("TextButton",{Parent=f,Size=UDim2.fromOffset(42,22),Position=UDim2.new(1,-55,.5,-11),BackgroundColor3=Color3.fromRGB(42,47,60),Text="",AutoButtonColor=false}); Corner(b,11); local d=New("Frame",{Parent=b,Size=UDim2.fromOffset(16,16),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.fromRGB(180,185,195),BorderSizePixel=0}); Corner(d,8)
 local on=v==true; local function draw() if on then Tw(b,{BackgroundColor3=Color3.fromRGB(70,110,255)}); Tw(d,{Position=UDim2.new(1,-19,0,3),BackgroundColor3=Color3.new(1,1,1)}) else Tw(b,{BackgroundColor3=Color3.fromRGB(42,47,60)}); Tw(d,{Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.fromRGB(180,185,195)}) end end
 b.MouseButton1Click:Connect(function() on=not on; draw(); if cb then cb(on) end end); draw()
end
local function Button(p,t,cb) local b=New("TextButton",{Parent=p,Size=UDim2.new(1,0,0,44),BackgroundColor3=Color3.fromRGB(28,34,46),Text=t,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Color3.fromRGB(220,225,238),AutoButtonColor=false}); Corner(b,9); Stroke(b,.5); b.MouseEnter:Connect(function()Tw(b,{BackgroundColor3=Color3.fromRGB(36,44,60)})end); b.MouseLeave:Connect(function()Tw(b,{BackgroundColor3=Color3.fromRGB(28,34,46)})end); b.MouseButton1Click:Connect(function()if cb then cb()end end); return b end
local function Box(p,ph,def,cb) local b=New("TextBox",{Parent=p,Size=UDim2.new(1,0,0,42),BackgroundColor3=Color3.fromRGB(18,22,30),Text=def or "",PlaceholderText=ph,Font=Enum.Font.Gotham,TextSize=12,TextColor3=Color3.fromRGB(220,225,238),PlaceholderColor3=Color3.fromRGB(105,115,135),ClearTextOnFocus=false}); Corner(b,9); Stroke(b,.5); b.FocusLost:Connect(function()if cb then cb(b.Text)end end); return b end

Title(Combat,"Combat","PvP utility controls."); local cs=Section(Combat,"Combat Assist"); Toggle(Combat,"Target Lock",false,function()end); Toggle(Combat,"Show Target Distance",true,function(v)State.ShowDistance=v end); Toggle(Combat,"Player ESP",false,function()end); Button(Combat,"Clear Selected Target",function()State.Target=nil end)
Title(Target,"Target","Select a player and monitor distance."); local Status=New("TextLabel",{Parent=Target,Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(18,22,30),Text="Target: None",Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Color3.fromRGB(170,180,200),TextXAlignment=Enum.TextXAlignment.Left}); Corner(Status); Stroke(Status,.5)
local List=New("ScrollingFrame",{Parent=Target,Size=UDim2.new(1,0,0,285),BackgroundColor3=Color3.fromRGB(18,22,30),BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new()}); Corner(List,9); Stroke(List,.5); local LL=New("UIListLayout",{Parent=List,Padding=UDim.new(0,5)}); New("UIPadding",{Parent=List,PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)})
local function Refresh() for _,c in ipairs(List:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end; for _,p in ipairs(Players:GetPlayers()) do if p~=LP then local b=New("TextButton",{Parent=List,Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(27,32,42),Text=p.DisplayName.."  @"..p.Name,Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(210,216,230),TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false}); Corner(b,7); b.MouseButton1Click:Connect(function()State.Target=p; Status.Text="Target: "..p.Name end) end end; List.CanvasSize=UDim2.fromOffset(0,LL.AbsoluteContentSize.Y+15) end
Button(Target,"Refresh Player List",Refresh); Refresh()
Title(Movement,"Movement","Local movement utilities."); local ms=Section(Movement,"Movement"); Toggle(Movement,"Dash Cooldown Indicator",false,function()end); local db=Box(Movement,"Dash cooldown", "0.35", function()end)
Title(Macro,"Combo Builder","Build a custom sequence with per-step delays."); local Info=New("TextLabel",{Parent=Macro,Size=UDim2.new(1,0,0,42),BackgroundColor3=Color3.fromRGB(18,22,30),Text="Preset: Default • Steps: 4",Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=Color3.fromRGB(170,180,200),TextXAlignment=Enum.TextXAlignment.Left}); Corner(Info); Stroke(Info,.5)
local CL=New("ScrollingFrame",{Parent=Macro,Size=UDim2.new(1,0,0,190),BackgroundColor3=Color3.fromRGB(18,22,30),BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new()}); Corner(CL,9); Stroke(CL,.5); local CLL=New("UIListLayout",{Parent=CL,Padding=UDim.new(0,6)}); New("UIPadding",{Parent=CL,PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)})
local function Render() for _,c in ipairs(CL:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end; local combo=State.Combos.Default; for i,s in ipairs(combo) do local r=New("Frame",{Parent=CL,Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(27,32,42),BorderSizePixel=0}); Corner(r,7); New("TextLabel",{Parent=r,Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-90,1,0),BackgroundTransparency=1,Text=string.format("%02d   %s",i,s.name),Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=Color3.fromRGB(215,220,232),TextXAlignment=Enum.TextXAlignment.Left}); New("TextLabel",{Parent=r,Position=UDim2.new(1,-75,0,0),Size=UDim2.fromOffset(65,38),BackgroundTransparency=1,Text=string.format("%.2fs",s.delay),Font=Enum.Font.Gotham,TextSize=10,TextColor3=Color3.fromRGB(135,150,175)}) end; CL.CanvasSize=UDim2.fromOffset(0,CLL.AbsoluteContentSize.Y+15); Info.Text="Preset: Default • Steps: "..#combo end
local Action=Box(Macro,"Action name, e.g. Skill Z",""); local Delay=Box(Macro,"Delay","0.25")
Button(Macro,"Add Action",function() local n=Action.Text; if n=="" then return end; local d=math.clamp(tonumber(Delay.Text) or .25,.01,5); table.insert(State.Combos.Default,{name=n,delay=d}); Action.Text=""; Render() end)
Button(Macro,"Remove Last Step",function() local c=State.Combos.Default; if #c>0 then table.remove(c) end; Render() end)
local function ExecuteAction(name) -- Hook your own supported game actions here. No synthetic input or bypassing validation. end
Button(Macro,"▶  Run Combo",function() if State.ComboRunning then return end; State.ComboRunning=true; State.StopCombo=false; task.spawn(function() for _,s in ipairs(State.Combos.Default) do if State.StopCombo then break end; ExecuteAction(s.name); task.wait(math.clamp(s.delay,.01,5)) end; State.ComboRunning=false; State.StopCombo=false end) end)
Button(Macro,"■  Stop Combo",function() State.StopCombo=true end); Render()
Title(Settings,"Settings","Interface controls."); Button(Settings,"Toggle UI  •  RightShift",function()State.Open=not State.Open; Main.Visible=State.Open end); Button(Settings,"Reset Target",function()State.Target=nil;Status.Text="Target: None" end)
local function Select(n) State.Tab=n; for k,b in pairs(Tabs) do b.BackgroundColor3=k==n and Color3.fromRGB(48,66,105) or Color3.fromRGB(17,21,29); b.TextColor3=k==n and Color3.fromRGB(240,244,255) or Color3.fromRGB(150,158,178) end; for k,p in pairs(Pages) do p.Visible=k==n end end
for n,b in pairs(Tabs) do b.MouseButton1Click:Connect(function()Select(n)end)end; Select("Combat")
RunService.RenderStepped:Connect(function() local t=State.Target; if t and t.Parent==Players then if State.ShowDistance then local d=Dist(t); Status.Text=d<math.huge and string.format("Target: %s   •   %.1f studs",t.Name,d) or "Target: "..t.Name.." • N/A" else Status.Text="Target: "..t.Name end elseif t then State.Target=nil; Status.Text="Target: None" end end)
UIS.InputBegan:Connect(function(i,p)if not p and i.KeyCode==Enum.KeyCode.RightShift then State.Open=not State.Open; Main.Visible=State.Open end end)
local drag,ds,sp=false,nil,nil; Top.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true;ds=i.Position;sp=Main.Position;i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then drag=false end end)end end); UIS.InputChanged:Connect(function(i)if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-ds; Main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)end end)
Close.MouseButton1Click:Connect(function()State.Open=false;Main.Visible=false end); Players.PlayerAdded:Connect(Refresh); Players.PlayerRemoving:Connect(function(p)if State.Target==p then State.Target=nil;Status.Text="Target: None" end;Refresh()end)
print("[DungdxPvP] Loaded")
