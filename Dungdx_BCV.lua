--[[
    ██████╗ ██╗   ██╗███╗   ██╗ ██████╗ ██████╗ ██╗  ██╗
    ██╔══██╗██║   ██║████╗  ██║██╔════╝ ██╔══██╗╚██╗██╔╝
    ██║  ██║██║   ██║██╔██╗ ██║██║  ███╗██║  ██║ ╚███╔╝
    ██║  ██║██║   ██║██║╚██╗██║██║   ██║██║  ██║ ██╔██╗
    ██████╔╝╚██████╔╝██║ ╚████║╚██████╔╝██████╔╝██╔╝ ██╗
    ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝
    
    Dungdx Hub  |  Blox Fruits Script
    Discord: https://discord.gg/AJBT8F79yf
    Version: 1.0.0
]]--

--==================================================================
-- [1/6] ENVIRONMENT CHECK
--==================================================================
local RunService = not game and game.GetService and game:GetService("RunService") or game.ClassName ~= "DataModel" or typeof and typeof(game.Players) ~= "Instance"
if not RunService then
    RunService = not (getmetatable and setmetatable and type and pcall and rawget and rawset)
end

if not RunService then
    local fn = cloneref or function(arg) return arg end

    while true do
        task.wait()
        if not (game:IsLoaded() and game.Players.LocalPlayer:FindFirstChild("DataLoaded")) then
            continue
        end
        break
    end

    local Players = fn(game:GetService("Players"))

    if Players.LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)") then
        if not getgenv().Team or getgenv().Team == "" then
            getgenv().Team = "Pirates"
        end

        local container = Players.LocalPlayer.PlayerGui["Main (minimal)"]:WaitForChild("ChooseTeam"):WaitForChild("Container")
        local textButton = nil

        if getgenv().Team == "Pirates" then
            textButton = container:WaitForChild("Pirates"):WaitForChild("Frame"):WaitForChild("TextButton")
        elseif getgenv().Team == "Marines" then
            textButton = container:WaitForChild("Marines"):WaitForChild("Frame"):WaitForChild("TextButton")
        end

        if textButton then
            repeat
                task.wait()
                pcall(function() firesignal(textButton.Activated) end)
            until not Players.LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)")
        end
    end

    repeat task.wait() until Players.LocalPlayer.PlayerGui:FindFirstChild("Main")

    if getgenv().DungdxActive then return print("[Dungdx] Already running") end
    getgenv().DungdxActive = true

    --==================================================================
    -- [2/6] EMBEDDED UI LIBRARY
    --==================================================================
    local DungdxUI = (function()
        local UI = {}
        UI.__index = UI
        local Players = game:GetService("Players")
        local UIS = game:GetService("UserInputService")
        local TweenService = game:GetService("TweenService")
        local CoreGui = game:GetService("CoreGui")
        local LP = Players.LocalPlayer

        local T = {
            Accent    = Color3.fromRGB(139, 92, 246),
            BgMain    = Color3.fromRGB(18, 18, 22),
            BgTabBar  = Color3.fromRGB(24, 24, 30),
            BgSection = Color3.fromRGB(28, 28, 35),
            BgControl = Color3.fromRGB(38, 38, 46),
            BgHover   = Color3.fromRGB(48, 48, 58),
            Text      = Color3.fromRGB(240, 240, 245),
            TextMuted = Color3.fromRGB(150, 150, 160),
            Stroke    = Color3.fromRGB(55, 55, 65),
        }

        local function new(c, p)
            local i = Instance.new(c)
            for k, v in pairs(p or {}) do if k ~= "Parent" then i[k] = v end end
            if p and p.Parent then i.Parent = p.Parent end
            return i
        end
        local function corner(p, r) return new("UICorner", {CornerRadius = UDim.new(0, r or 6), Parent = p}) end
        local function stroke(p, c, t) return new("UIStroke", {Color = c or T.Stroke, Thickness = t or 1, Parent = p}) end
        local function pad(p, a)
            return new("UIPadding", {
                PaddingTop = UDim.new(0, a or 0), PaddingBottom = UDim.new(0, a or 0),
                PaddingLeft = UDim.new(0, a or 0), PaddingRight = UDim.new(0, a or 0), Parent = p,
            })
        end

        -- Notify
        local holder
        local function getHolder()
            if holder and holder.Parent then return holder end
            local gui = new("ScreenGui", {Name = "DungdxNotify", ResetOnSpawn = false, Parent = CoreGui})
            holder = new("Frame", {
                BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 1),
                Position = UDim2.new(1, -20, 1, -20), Size = UDim2.new(0, 320, 1, -40), Parent = gui,
            })
            new("UIListLayout", {
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = holder,
            })
            return holder
        end

        local Notify = {}
        function Notify:Notify(data, opts)
            data, opts = data or {}, opts or {}
            local h = getHolder()
            local f = new("Frame", {
                BackgroundColor3 = T.BgSection, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Parent = h, BackgroundTransparency = 1,
            })
            corner(f, 10); stroke(f)
            local accent = new("Frame", {
                BackgroundColor3 = T.Accent, BorderSizePixel = 0,
                Size = UDim2.new(0, 4, 0, 0), Position = UDim2.new(0, 8, 0, 10),
                Parent = f, BackgroundTransparency = 1,
            })
            corner(accent, 2)
            local inner = new("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -28, 1, 0),
                Position = UDim2.new(0, 20, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = f,
            })
            pad(inner, 10)
            new("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
                Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left, Text = data.Title or "Dungdx", Parent = inner,
            })
            new("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(0, 0, 0, 22),
                Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.TextMuted,
                TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
                Text = data.Description or "", Parent = inner,
            })
            TweenService:Create(f, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
            TweenService:Create(accent, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
            task.delay(opts.Time or 5, function()
                TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(accent, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                task.wait(0.35); f:Destroy()
            end)
        end

        -- Toggle
        local function makeToggle(parent, name, default, cb)
            local row = new("Frame", {
                BackgroundColor3 = T.BgControl, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36), Parent = parent,
            })
            corner(row, 8)
            new("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 12, 0, 0), Font = Enum.Font.GothamMedium,
                TextSize = 13, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Text = name, Parent = row,
            })
            local state = default and true or false
            local track = new("Frame", {
                BackgroundColor3 = state and T.Accent or T.BgHover, BorderSizePixel = 0,
                Size = UDim2.new(0, 40, 0, 22), Position = UDim2.new(1, -50, 0.5, -11), Parent = row,
            })
            corner(track, 11)
            local knob = new("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                Parent = track,
            })
            corner(knob, 8)
            local btn = new("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = row})
            local api = {}
            local function setState(v)
                state = v
                TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = state and T.Accent or T.BgHover}):Play()
                TweenService:Create(knob, TweenInfo.new(0.15), {
                    Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                }):Play()
            end
            btn.MouseButton1Click:Connect(function()
                setState(not state)
                if cb then task.spawn(cb, state) end
            end)
            api.Update = setState
            api.Set = setState
            return api
        end

        -- Button
        local function makeButton(parent, name, cb)
            local btn = new("TextButton", {
                BackgroundColor3 = T.BgControl, BorderSizePixel = 0, AutoButtonColor = false,
                Size = UDim2.new(1, 0, 0, 32), Font = Enum.Font.GothamMedium,
                TextSize = 13, TextColor3 = T.Text, Text = name, Parent = parent,
            })
            corner(btn, 8)
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgHover}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgControl}):Play()
            end)
            btn.MouseButton1Click:Connect(function() if cb then task.spawn(cb) end end)
            return btn
        end

        -- Slider
        local function makeSlider(parent, name, mn, mx, def, cb, step)
            local row = new("Frame", {
                BackgroundColor3 = T.BgControl, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 44), Parent = parent,
            })
            corner(row, 8)
            new("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -80, 0, 20),
                Position = UDim2.new(0, 12, 0, 4), Font = Enum.Font.GothamMedium,
                TextSize = 13, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Text = name, Parent = row,
            })
            local val = new("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 70, 0, 20),
                Position = UDim2.new(1, -82, 0, 4), Font = Enum.Font.GothamBold,
                TextSize = 12, TextColor3 = T.Accent, TextXAlignment = Enum.TextXAlignment.Right,
                Text = tostring(def), Parent = row,
            })
            local bar = new("Frame", {
                BackgroundColor3 = T.BgMain, BorderSizePixel = 0,
                Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 30), Parent = row,
            })
            corner(bar, 3)
            local fill = new("Frame", {BackgroundColor3 = T.Accent, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0), Parent = bar})
            corner(fill, 3)
            local knob = new("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
                Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0), Parent = bar,
            })
            corner(knob, 7)
            local dragging = false
            local function update(x)
                local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local raw = mn + (mx - mn) * rel
                if step then raw = math.floor(raw / step) * step end
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                val.Text = tostring(math.floor(raw * 100) / 100)
                if cb then task.spawn(cb, raw) end
            end
            bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; update(i.Position.X)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i.Position.X)
                end
            end)
            UIS.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        -- Dropdown
        local function makeDropdown(parent, name, default, options, cb)
            options = options or {}
            local row = new("Frame", {
                BackgroundColor3 = T.BgControl, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36), Parent = parent, ClipsDescendants = false,
            })
            corner(row, 8)
            new("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0),
                Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left, Text = name, Parent = row,
            })
            local current = (type(default) == "table" and default[1]) or default or options[1] or "—"
            local val = new("TextButton", {
                BackgroundTransparency = 1, Size = UDim2.new(0.5, -50, 1, 0),
                Position = UDim2.new(0.5, 20, 0, 0), Font = Enum.Font.Gotham,
                TextSize = 12, TextColor3 = T.TextMuted, TextXAlignment = Enum.TextXAlignment.Right,
                Text = tostring(current) .. " ▾", Parent = row,
            })
            local list
            local function closeList() if list then list:Destroy(); list = nil end end
            val.MouseButton1Click:Connect(function()
                if list then closeList(); return end
                list = new("Frame", {
                    BackgroundColor3 = T.BgSection, BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, math.min(200, #options * 26 + 8)),
                    Position = UDim2.new(0, 0, 1, 4), Parent = row, ZIndex = 10,
                })
                corner(list, 8); stroke(list)
                local sc = new("ScrollingFrame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4),
                    CanvasSize = UDim2.new(0, 0, 0, #options * 26), BorderSizePixel = 0,
                    ScrollBarThickness = 3, Parent = list,
                })
                new("UIListLayout", {Padding = UDim.new(0, 2), Parent = sc})
                for _, opt in ipairs(options) do
                    local o = new("TextButton", {
                        BackgroundColor3 = T.BgControl, BorderSizePixel = 0,
                        Size = UDim2.new(1, -4, 0, 24), Font = Enum.Font.Gotham,
                        TextSize = 12, TextColor3 = T.Text, Text = tostring(opt), Parent = sc,
                    })
                    corner(o, 6)
                    o.MouseButton1Click:Connect(function()
                        current = opt
                        val.Text = tostring(opt) .. " ▾"
                        if cb then task.spawn(cb, opt) end
                        closeList()
                    end)
                end
            end)
            return {Refresh = function(self, newOpts)
                options = newOpts
            end}
        end

        -- Textbox
        local function makeTextbox(parent, name, cb, default)
            local row = new("Frame", {
                BackgroundColor3 = T.BgControl, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 34), Parent = parent,
            })
            corner(row, 8)
            local tb = new("TextBox", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 12, 0, 0), Font = Enum.Font.Gotham,
                TextSize = 13, TextColor3 = T.Text, PlaceholderText = name,
                PlaceholderColor3 = T.TextMuted, TextXAlignment = Enum.TextXAlignment.Left,
                Text = default or "", ClearTextOnFocus = false, Parent = row,
            })
            tb.FocusLost:Connect(function()
                if cb then task.spawn(cb, tb.Text) end
            end)
            return tb
        end

        -- Window
        function UI:CreateWindow(cfg)
            cfg = cfg or {}
            local gui = new("ScreenGui", {Name = "DungdxUI", ResetOnSpawn = false, Parent = CoreGui})
            local win = new("Frame", {
                Name = "Window", BackgroundColor3 = T.BgMain, BorderSizePixel = 0,
                Size = UDim2.new(0, 620, 0, 420), Position = UDim2.new(0.5, -310, 0.5, -210),
                Parent = gui, Active = true, Draggable = true,
            })
            corner(win, 12); stroke(win, Color3.fromRGB(60, 60, 70), 1.2)

            local top = new("Frame", {
                BackgroundColor3 = T.BgTabBar, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 52), Parent = win,
            })
            corner(top, 12)
            new("Frame", {
                BackgroundColor3 = T.BgTabBar, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), Parent = top,
            })
            new("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 300, 0, 20),
                Position = UDim2.new(0, 16, 0, 8), Font = Enum.Font.GothamBold,
                TextSize = 15, TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                Text = cfg.Title or "Dungdx Hub", Parent = top,
            })
            new("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 400, 0, 14),
                Position = UDim2.new(0, 16, 0, 28), Font = Enum.Font.Gotham,
                TextSize = 11, TextColor3 = T.TextMuted, TextXAlignment = Enum.TextXAlignment.Left,
                Text = cfg.Subtitle or "Blox Fruit | discord.gg/AJBT8F79yf", Parent = top,
            })
            local close = new("TextButton", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(1, -40, 0, 10), Text = "✕", Font = Enum.Font.GothamBold,
                TextSize = 14, TextColor3 = T.TextMuted, Parent = top,
            })
            close.MouseButton1Click:Connect(function() gui.Enabled = false end)
            local mini = new("TextButton", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(1, -76, 0, 10), Text = "—", Font = Enum.Font.GothamBold,
                TextSize = 14, TextColor3 = T.TextMuted, Parent = top,
            })
            local minimized = false
            mini.MouseButton1Click:Connect(function()
                minimized = not minimized
                TweenService:Create(win, TweenInfo.new(0.2), {
                    Size = minimized and UDim2.new(0, 620, 0, 52) or UDim2.new(0, 620, 0, 420),
                }):Play()
            end)

            local tabBar = new("Frame", {
                BackgroundColor3 = T.BgTabBar, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38), Position = UDim2.new(0, 0, 0, 52), Parent = win,
            })
            local tabScroll = new("ScrollingFrame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0,
                ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X, Parent = tabBar,
            })
            local tabList = new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4),
                VerticalAlignment = Enum.VerticalAlignment.Center, Parent = tabScroll,
            })
            tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tabScroll.CanvasSize = UDim2.new(0, tabList.AbsoluteContentSize.X + 8, 0, 0)
            end)

            local content = new("Frame", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -24, 1, -108),
                Position = UDim2.new(0, 12, 0, 100), Parent = win,
            })
            local pages, tabs = {}, {}
            local function select(name)
                for n, p in pairs(pages) do p.Visible = (n == name) end
                for n, b in pairs(tabs) do
                    TweenService:Create(b, TweenInfo.new(0.15), {
                        BackgroundColor3 = (n == name) and T.Accent or T.BgControl,
                    }):Play()
                    b.TextColor3 = (n == name) and Color3.new(1, 1, 1) or T.TextMuted
                end
            end

            local windowApi = {}
            function windowApi:AddTab(name, icon)
                local btn = new("TextButton", {
                    BackgroundColor3 = T.BgControl, BorderSizePixel = 0,
                    Size = UDim2.new(0, 110, 0, 26), Font = Enum.Font.GothamMedium,
                    TextSize = 12, TextColor3 = T.TextMuted, Text = name, Parent = tabScroll,
                })
                corner(btn, 6)
                local page = new("ScrollingFrame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0,
                    ScrollBarThickness = 3, Visible = false, Parent = content,
                })
                local pl = new("UIListLayout", {Padding = UDim.new(0, 8), Parent = page})
                pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    page.CanvasSize = UDim2.new(0, 0, 0, pl.AbsoluteContentSize.Y + 10)
                end)
                pages[name] = page
                tabs[name] = btn
                btn.MouseButton1Click:Connect(function() select(name) end)

                local tabApi = {}
                function tabApi:addSection()
                    local sec = new("Frame", {
                        BackgroundColor3 = T.BgSection, BorderSizePixel = 0,
                        Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = page,
                    })
                    corner(sec, 10); stroke(sec)
                    local sList = new("UIListLayout", {Padding = UDim.new(0, 6), Parent = sec})
                    pad(sec, 12)
                    sList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        sec.Size = UDim2.new(1, -6, 0, sList.AbsoluteContentSize.Y + 24)
                    end)

                    local secApi = {}
                    function secApi:addMenu(title)
                        local menu = new("Frame", {
                            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y, Parent = sec,
                        })
                        local mList = new("UIListLayout", {Padding = UDim.new(0, 6), Parent = menu})
                        if title and title ~= "" then
                            new("TextLabel", {
                                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
                                Font = Enum.Font.GothamBold, TextSize = 13,
                                TextColor3 = T.Text, TextXAlignment = Enum.TextXAlignment.Left,
                                Text = title, Parent = menu,
                            })
                        end
                        mList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                            menu.Size = UDim2.new(1, 0, 0, mList.AbsoluteContentSize.Y)
                        end)

                        local menuApi = {}
                        function menuApi:addLabel(title, desc)
                            local lbl = new("TextLabel", {
                                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24),
                                AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham,
                                TextSize = 12, TextColor3 = T.TextMuted, TextWrapped = true,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = (title or "") .. (desc and ("\n" .. desc) or ""), Parent = menu,
                            })
                            function lbl:RefreshDesc(newDesc)
                                lbl.Text = (title or "") .. (newDesc and ("\n" .. newDesc) or "")
                            end
                            return lbl
                        end
                        function menuApi:addButton(name, cb) return makeButton(menu, name, cb) end
                        function menuApi:addToggle(name, default, cb) return makeToggle(menu, name, default, cb) end
                        function menuApi:addSlider(name, mn, mx, def, cb, locked, step)
                            return makeSlider(menu, name, mn, mx, def, cb, step)
                        end
                        function menuApi:addDropdown(name, default, options, cb)
                            return makeDropdown(menu, name, default, options, cb)
                        end
                        function menuApi:addTextbox(name, cb) return makeTextbox(menu, name, cb) end
                        function menuApi:addButtonGrid(name, list)
                            local grid = new("Frame", {
                                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                                AutomaticSize = Enum.AutomaticSize.Y, Parent = menu,
                            })
                            new("UIGridLayout", {
                                CellSize = UDim2.new(0.33, -4, 0, 30),
                                CellPadding = UDim2.new(0, 6, 0, 6), Parent = grid,
                            })
                            for _, item in ipairs(list or {}) do
                                makeButton(grid, item.Label or "Btn", item.Callback)
                            end
                            return grid
                        end
                        return menuApi
                    end
                    return secApi
                end
                return tabApi
            end

            select(nil)
            return windowApi
        end
        UI.Notification = Notify
        UI.Theme = T
        return UI
    end)()

    local lua4 = DungdxUI

    --==================================================================
    -- [3/6] CORE SETUP (từ script gốc, đã rebrand)
    --==================================================================
    local request_ = nil
    if syn and syn.request then request_ = syn.request
    elseif http_request then request_ = http_request
    elseif http and http.request then request_ = http.request
    else request_ = request or httprequest end

    local function fn2(arg)
        if not request_ then return nil end
        return request_(arg)
    end

    local tbl = {
        AutoAttack = true,
        FastSettings = "Fast Attack",
        FastAttackDelay = 0,
        attackmobs = true,
        attackplayers = true,
        BringMonster = true,
        BringMonsterRadius = 350,
        MasteryFarm = false,
        HealthMob = 50,
        HopDelay = 10,
        TeamSelectLoad = "Pirates",
        PosMethod = "Above",
        PosY = 18,
        TweenSpeed = 250,
        AutoFarmWeapon = "Melee",
    }

    local tbl2 = {
        Services = {}, Player = {}, Environment = {}, Remotes = {},
        Modules = {}, Cache = {}, Runtime = {}, Performance = {}, Webhook = {},
    }

    setmetatable(tbl2.Services, {__index = function(arg, arg2)
        local ok, result = pcall(game.GetService, game, arg2)
        if ok and result then
            local v2 = cloneref and cloneref(result) or result
            rawset(arg, arg2, v2)
            return v2
        end
        return nil
    end})

    local v2 = game:GetService("Workspace")
    local v3 = game:GetService("Players")
    local v4 = game:GetService("ReplicatedStorage")
    local v5 = game:GetService("CollectionService")
    local v6 = game:GetService("RunService")
    local v7 = game:GetService("Lighting")
    local v8 = game:GetService("VirtualInputManager")
    local v9 = game:GetService("HttpService")
    local v10 = game:GetService("UserInputService")
    local v13 = game:GetService("StarterGui")
    local v14 = game:GetService("Stats")
    local v15 = game:GetService("TeleportService")
    local v16 = game:GetService("GuiService")
    local v17 = game:GetService("VirtualUser")

    tbl2.Services.Workspace = v2
    tbl2.Services.Players = v3
    tbl2.Services.ReplicatedStorage = v4
    tbl2.Services.CollectionService = v5
    tbl2.Services.RunService = v6
    tbl2.Services.Lighting = v7
    tbl2.Services.VirtualInputManager = v8
    tbl2.Services.HttpService = v9
    tbl2.Services.UserInputService = v10

    local localPlayer = v3.LocalPlayer
    local v18 = localPlayer
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
    local data = localPlayer:WaitForChild("Data")
    local level = data:WaitForChild("Level")
    local fragments = data:WaitForChild("Fragments")
    local beli = data:WaitForChild("Beli")

    tbl2.Player = {
        LocalPlayer = localPlayer, Character = character, Humanoid = humanoid,
        HumanoidRootPart = humanoidRootPart, Data = data, Level = level,
        Fragments = fragments, Beli = beli, Money = beli,
    }

    localPlayer.CharacterAdded:Connect(function(c)
        if not c then return end
        character = c
        humanoid = c:WaitForChild("Humanoid", 10)
        humanoidRootPart = c:WaitForChild("HumanoidRootPart", 10)
        tbl2.Player.Character = c
        tbl2.Player.Humanoid = humanoid
        tbl2.Player.HumanoidRootPart = humanoidRootPart
    end)

    local enemies = v2:WaitForChild("Enemies")
    local seaBeasts = v2:WaitForChild("SeaBeasts")
    local boats = v2:WaitForChild("Boats")
    local map = v2:WaitForChild("Map")
    local worldOrigin = v2:WaitForChild("_WorldOrigin")
    local attribute = v2:GetAttribute("MAP")
    local flag = attribute == "Sea1"
    local flag2 = attribute == "Sea2"
    local flag3 = attribute == "Sea3"

    tbl2.Environment = {
        Workspace = v2, Enemies = enemies, SeaBeasts = seaBeasts,
        Boats = boats, Map = map, WorldOrigin = worldOrigin, MAPA = attribute,
        Sea_1 = flag, Sea_2 = flag2, Sea_3 = flag3,
    }

    local remotes = v4:WaitForChild("Remotes")
    local commF = remotes:WaitForChild("CommF_")
    local commE = v4.Remotes.CommE
    local modules = v4:WaitForChild("Modules")
    local net = modules:WaitForChild("Net")
    tbl2.Remotes = {Remotes = remotes, CommF_ = commF, CommE = commE, Modules = modules, Net = net}

    local GuideModule = require(v4:WaitForChild("GuideModule"))
    local GetWaterHeightAtLocation = require(v4.Util.GetWaterHeightAtLocation)
    local DangerDistance = require(v4.DangerDistance)
    local Net = require(game.ReplicatedStorage.Modules.Net)
    local ItemConfig = require(game.ReplicatedStorage.ItemConfig)

    pcall(function()
        local CombatUtil = require(v4:WaitForChild("Modules"):WaitForChild("CombatUtil"))
        if CombatUtil and CombatUtil.CanAttack and hookfunction then
            hookfunction(CombatUtil.CanAttack, function() return true end)
        end
    end)

    --==================================================================
    -- [4/6] HELPERS + CORE MODULES
    --==================================================================
    local function fn15(arg)
        local v22, v23, v24 = string.match(tostring(arg), "^([^%d]*%d)(%d*)(.-)$")
        if not v22 then return tostring(arg) end
        return v22 .. v23:reverse():gsub("(%d%d%d)", "%1,"):reverse() .. v24
    end

    local function fn16(arg)
        local n2 = math.floor(arg % 60)
        local n3 = math.floor(arg / 60 % 60)
        return string.format("%02d:%02d:%02d", math.floor(arg / 3600), n3, n2)
    end

    tbl6 = tbl6 or {}
    tbl6.SendNotify = function(arg, arg2, arg3, arg4, arg5, arg6)
        pcall(function()
            DungdxUI.Notification:Notify({
                Title = arg2 or "Dungdx Hub",
                Description = arg3 or "",
                Buttons = arg5,
                Id = arg6,
            }, {Time = arg4 or 5})
        end)
    end

    tbl6.FireInvoke = function(...)
        return commF:InvokeServer(select(2, ...))
    end

    -- Tween Manager (rút gọn)
    local function fn7()
        local tbl8 = {
            ActiveTween = nil, ActiveTweenTarget = nil, ActiveBoatTween = nil,
            PlayerSpawns = worldOrigin.PlayerSpawns.Pirates,
            Locations = worldOrigin.Locations,
            StopBoatFlag = false, StopCurrentTween = nil,
        }
        local n = 0
        local tbl9 = {
            Sea_1 = {
                Vector3.new(-7894.62, 5545.49, -380.25),
                Vector3.new(-4607.82, 872.54, -1667.56),
                Vector3.new(61163.85, 11.76, 1819.78),
                Vector3.new(3876.28, 35.11, -1939.32),
            },
            Sea_2 = {
                Vector3.new(-288.46, 306.13, 598),
                Vector3.new(2284.91, 15.15, 905.48),
                Vector3.new(923.21, 126.98, 32852.83),
                Vector3.new(-6508.56, 89.03, -132.84),
            },
            Sea_3 = {
                Vector3.new(-5058, 314, -3170),
                Vector3.new(-12463, 374, -7550),
                Vector3.new(5670, 1020, -340),
                Vector3.new(28286, 14897, 103),
            },
        }
        local flag4, flag5 = false, false
        local n2, n3 = 0, 5
        local bodyVelocity

        local function fn9()
            if not v18.Character then return end
            for _, v21 in ipairs(v18.Character:GetChildren()) do
                if v21:IsA("BasePart") and v21.CanCollide then v21.CanCollide = false end
            end
        end

        local function fn10()
            if not humanoidRootPart then return end
            if not humanoidRootPart:FindFirstChild("PartVelocuty") then
                if bodyVelocity then bodyVelocity:Destroy() end
                bodyVelocity = Instance.new("BodyVelocity", humanoidRootPart)
                bodyVelocity.Name = "PartVelocuty"
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = Vector3.zero
                bodyVelocity.P = 1000
            end
        end

        local function fn11()
            local v19 = humanoidRootPart
            if not v19 or not v19.Parent then return false end
            local h = v19.Parent:FindFirstChildOfClass("Humanoid")
            return h and h.Parent and h.Health > 0
        end

        local function fn12(arg)
            local pos = arg.Position
            for _, v21 in ipairs(tbl8.Locations:GetChildren()) do
                if (pos - v21.Position).Magnitude <= v21.Mesh.Scale.X then
                    return v21
                end
            end
            return {Name = ""}
        end

        local function fn13(arg)
            local pos = arg.Position
            local sea1 = flag and tbl9.Sea_1 or flag2 and tbl9.Sea_2 or flag3 and tbl9.Sea_3 or {}
            local huge = math.huge
            local v19
            for _, v20 in ipairs(sea1) do
                local mag = (v20 - pos).Magnitude
                if mag < huge then huge = mag; v19 = v20 end
            end
            return huge <= (pos - humanoidRootPart.Position).Magnitude and v19 or nil
        end

        local function fn14(arg)
            if (humanoidRootPart.Position - arg).Magnitude > 300 then
                tbl6:FireInvoke("requestEntrance", arg)
                task.wait(0.1)
                fn10()
                humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 20)
                task.wait(0.5)
            end
        end

        local function fn15(arg)
            local pos = arg.Position
            for _, v21 in ipairs(tbl8.PlayerSpawns:GetChildren()) do
                if (v21.Part.Position - pos).Magnitude <= 2500 then return v21 end
            end
        end

        local function fn16(arg)
            local name = fn12(arg).Name
            if name == "" then return false end
            if name:find("Dimension") or name:find("Cursed") or name:find("Submerged") or name == "Sealed Cavern" or name:lower():find("under") or data.LastSpawnPoint.Value == "SubmergedIsland" then
                return false
            end
            return (arg.Position - humanoidRootPart.Position).Magnitude > 3500
        end

        local function fn17(arg)
            local v19 = fn15(humanoidRootPart)
            local mag = (arg.Position - humanoidRootPart.Position).Magnitude
            local pos = humanoidRootPart.Position
            local pos2 = arg.Position
            local huge = math.huge
            local v22
            for _, v23 in ipairs(tbl8.PlayerSpawns:GetChildren()) do
                local pos3 = v23.Part.Position
                local mag2 = (pos3 - pos2).Magnitude
                local mag3 = (pos3 - pos).Magnitude
                if mag >= 3000 and fn15(v23.Part) ~= v19 and mag3 <= 10200 and mag2 <= huge then
                    huge = mag2
                    v22 = v23
                end
            end
            return v22
        end

        local function fn18(arg)
            if not fn12(humanoidRootPart).Name:find("Submerged") or fn12(arg).Name:find("Submerged") then return end
            while true do
                tbl8:topos(CFrame.new(11426, -2155, 9732))
                task.wait(2)
                net:WaitForChild("RF/SubmarineTransportation"):InvokeServer("InitiateTeleport", "Tiki Outpost")
                task.wait(2)
                if not (not fn12(humanoidRootPart).Name:find("Submerged") or not fn11()) then continue end
                break
            end
        end

        local function fn19(arg)
            while true do
                local v19 = fn17(arg)
                if not v19 then break end
                for i = 1, 3 do
                    tbl6:FireInvoke("SetLastSpawnPoint", v19.Name)
                    tbl6:FireInvoke("SetSpawnPoint")
                    v18.Character:PivotTo(v19.Part.CFrame)
                    local h = v18.Character:FindFirstChild("Humanoid")
                    if h then h.Health = 0 end
                end
                task.wait(0.1)
                while true do
                    task.wait(0.1)
                    if not (v18.Character and v18.Character:FindFirstChild("HumanoidRootPart") and v18.Character:FindFirstChild("Humanoid") and v18.Character:FindFirstChild("Humanoid").Health > 0) then continue end
                    break
                end
                if not (not fn16(arg) or not fn17(arg)) then continue end
                break
            end
        end

        local function fn20(arg)
            local v19 = fn13(arg)
            if v19 and tick() - n2 >= n3 then
                fn14(v19)
                n2 = tick()
                task.wait(1)
            end
        end

        local function fn21(arg)
            if typeof(arg) == "Vector3" then return CFrame.new(arg) end
            if typeof(arg) == "CFrame" then return arg end
            if typeof(arg) == "Instance" and arg:IsA("BasePart") then return arg.CFrame end
        end

        local function fn22(cFrame, arg)
            if flag5 then return end
            n += 1
            local v19 = n
            flag4 = false
            flag5 = true
            if not humanoidRootPart or not humanoid then flag5 = false; return end

            task.spawn(function()
                local cFrame2 = humanoidRootPart.CFrame
                local mag = (cFrame.Position - cFrame2.Position).Magnitude
                if mag <= 5 then flag5 = false; return end
                local now = tick()
                local n4 = 0
                while not (v19 ~= n or flag4) do
                    if not humanoid or humanoid.Health <= 0 then break end
                    if not humanoidRootPart or not humanoidRootPart.Parent then break end
                    local now2 = tick()
                    local n5 = now2 - now
                    n4 += math.max((tonumber(tbl.TweenSpeed) or 250) * (arg or 1), 0.1) * n5
                    local n6 = math.clamp(n4 / mag, 0, 1)
                    humanoidRootPart.CFrame = cFrame2:Lerp(cFrame, n6)
                    if n6 >= 1 or (cFrame.Position - humanoidRootPart.Position).Magnitude <= 10 then
                        humanoidRootPart.CFrame = cFrame
                        break
                    end
                    task.wait()
                    now = now2
                end
                flag5 = false
            end)
        end

        tbl8.StopTween = function()
            flag4 = true
            n += 1
            flag5 = false
            if bodyVelocity then
                pcall(function() if bodyVelocity.Parent then bodyVelocity:Destroy() end end)
                bodyVelocity = nil
            end
            if humanoidRootPart then
                local pv = humanoidRootPart:FindFirstChild("PartVelocuty")
                if pv then pv:Destroy() end
            end
        end

        tbl8.topos = function(arg, arg2, arg3, arg4, arg5)
            if flag5 then return end
            if not fn11() then return end
            local v19 = fn21(arg2)
            if not v19 then return end
            fn18(v19)
            if not fn11() then return end
            local pos = flag3 and fn12(humanoidRootPart).Name:find("Temple of Time") or fn12(v19).Name:find("Temple of Time")
            if tbl.BypassTP and fn16(v19) and not pos then
                fn19(v19)
                if not fn11() then return end
            else
                fn20(v19)
            end
            if tbl.ForceAnchoredY and not pos then
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.CFrame.X, v19.Y, humanoidRootPart.CFrame.Z)
            end
            fn9()
            fn22(v19, arg5)
            if flag4 then arg:StopTween(); return end
            if arg3 then fn10()
            elseif not arg4 and humanoidRootPart then
                local pv = humanoidRootPart:FindFirstChild("PartVelocuty")
                if pv then pv:Destroy() end
            end
        end

        GetAllBoats = function()
            local tbl10 = {"My Boat"}
            local boats2 = v2:FindFirstChild("Boats")
            if boats2 then
                for _, child in ipairs(boats2:GetChildren()) do
                    local owner = child:FindFirstChild("Owner")
                    if owner and owner.Value then
                        local value = owner.Value
                        local name = typeof(value) == "Instance" and value.Name or tostring(value)
                        if name ~= v18.Name and value ~= v18 and value ~= v18.Character then
                            tbl10[#tbl10 + 1] = child.Name .. " [" .. name .. "]"
                        end
                    end
                end
            end
            return tbl10
        end

        GetSelectedBoat = function()
            local sailTargetBoat = tbl.SailTargetBoat
            for _, v21 in ipairs(v2.Boats:GetChildren()) do
                local owner = v21:FindFirstChild("Owner")
                if owner then
                    if not sailTargetBoat or sailTargetBoat == "My Boat" then
                        if tostring(owner.Value) == v18.Name then return v21 end
                    elseif v21.Name .. " [" .. tostring(owner.Value) .. "]" == sailTargetBoat then
                        return v21
                    end
                end
            end
            return nil
        end

        tbl8.StopBoatTween = function()
            tbl8.StopBoatFlag = true
            tbl8.ActiveBoatTween = nil
        end

        tbl8.toposboat = function(arg, arg2)
            if tbl8.ActiveBoatTween then return end
            local v19 = GetSelectedBoat()
            local vehicleSeat = v19 and v19:FindFirstChild("VehicleSeat")
            local cframe = typeof(arg2) == "Vector3" and CFrame.new(arg2) or arg2
            if not (v19 and vehicleSeat and humanoid and humanoid.Sit and cframe) then return end
            local n4 = tonumber(tbl.BoatPosY) or 31
            local cframe2 = CFrame.new(cframe.X, n4, cframe.Z)
            local cframe3 = CFrame.new(vehicleSeat.CFrame.X, n4, vehicleSeat.CFrame.Z)
            local mag = (cframe2.Position - cframe3.Position).Magnitude
            if mag <= 25 then return end
            tbl8.ActiveBoatTween = true
            tbl8.StopBoatFlag = false
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.P = 1e9
            bv.Parent = vehicleSeat

            task.spawn(function()
                local now = tick()
                local n5 = 0
                while not tbl8.StopBoatFlag and humanoid.Health > 0 and humanoid.Sit do
                    local now2 = tick()
                    local n6 = now2 - now
                    local n7 = math.max(tonumber(tbl.SpeedBoat) or 250, 0.1)
                    n5 += n7 * n6
                    local n8 = math.clamp(n5 / mag, 0, 1)
                    local v20 = cframe3:Lerp(cframe2, n8)
                    bv.Velocity = (v20.Position - vehicleSeat.CFrame.Position).Magnitude > 0.1 and (v20.Position - vehicleSeat.CFrame.Position).Unit * n7 or Vector3.zero
                    vehicleSeat.CFrame = v20
                    if n8 >= 1 or (cframe2.Position - vehicleSeat.CFrame.Position).Magnitude <= 25 then
                        vehicleSeat.CFrame = cframe2
                        break
                    end
                    task.wait()
                    now = now2
                end
                if tbl8.StopBoatFlag then
                    bv.Velocity = Vector3.zero
                    bv:Destroy()
                end
                tbl8.ActiveBoatTween = nil
                tbl8.StopBoatFlag = false
            end)
        end
        return tbl8
    end

    tbl6.TweenManager = fn7()
    local tweenManager = tbl6.TweenManager

    --==================================================================
    -- [5/6] UTILITIES + FAST ATTACK (rút gọn)
    --==================================================================
    tbl6.IsReady = function(arg, arg2)
        if not arg2 or not arg2.Parent or not arg2:IsDescendantOf(v2) then return false end
        if arg2.Parent == boats or arg2:GetAttribute("IsBoat") or arg2.Name:find("Brigade") or arg2.Name:find("Boat") or arg2.Name:find("Ship") then
            local health = arg2:FindFirstChild("Health")
            if health then
                local f = health:IsA("ValueBase") and health.Value <= 0 or type(health.Value) == "number" and health.Value <= 0
                if f then return false end
            end
            local h = arg2:FindFirstChildOfClass("Humanoid") or arg2:FindFirstChild("Humanoid")
            if h then
                local f = h:IsA("Humanoid") and h.Health <= 0 or h:IsA("ValueBase") and h.Value <= 0
                if f then return false end
            end
            if arg2:GetAttribute("Dead") == true or arg2:GetAttribute("Sunk") == true then return false end
            local engine = arg2:FindFirstChild("Engine") or arg2.PrimaryPart or arg2:FindFirstChildWhichIsA("BasePart")
            if not engine or engine.Position.Y < -15 then return false end
            return true
        end
        if arg2.Parent == seaBeasts then
            local health = arg2:FindFirstChild("Health")
            return health and health.Value > 0
        end
        local h = arg2:FindFirstChildOfClass("Humanoid")
        local root = arg2:FindFirstChild("HumanoidRootPart") or arg2.PrimaryPart
        return h and h.Health > 0 and root ~= nil
    end

    -- Fast Attack rút gọn (vẫn hoạt động cho Melee / Sword / Gun cơ bản)
    local function fn9()
        local obj4 = {
            BodyParts = {"RightLowerArm","RightUpperArm","LeftLowerArm","LeftUpperArm","RightHand","LeftHand"},
            LastCombo = 0, ComboTime = 0, GunDebounce = 0, MaxHits = 2,
            IgnoredTools = {},
            ShootsPerTarget = {["Dual Flintlock"] = 2},
            ShootStyles = {["Skull Guitar"] = "TAP", Bazooka = "Position", Cannon = "Position", Dragonstorm = "Overheat"},
        }
        local CombatUtil = require(v4.Modules.CombatUtil)
        local CombatController = require(v4.Controllers.CombatController)
        local validator2 = remotes:WaitForChild("Validator2")
        local reRegisterAttack = net:WaitForChild("RE/RegisterAttack")
        local reShootGunEvent = net:FindFirstChild("RE/ShootGunEvent")
        local RegisterHit = require(v4.Modules.Net):RemoteEvent("RegisterHit", true)

        local ok, result = pcall(function() return getupvalue(CombatController.Attack, 9) end)

        local function fn10()
            if not result then
                pcall(function() result = getupvalue(CombatController.Attack, 9) end)
            end
            if not result then return 0, 0 end
            local v19 = getupvalue(result, 15)
            local v20 = getupvalue(result, 13)
            local v21 = getupvalue(result, 16)
            local v22 = getupvalue(result, 17)
            local v23 = getupvalue(result, 14)
            local v24 = getupvalue(result, 18)
            local v25 = getupvalue(result, 19)
            if not v19 or not v20 or not v21 or not v22 or not v23 or not v24 or not v25 then
                return 0, 0
            end
            local n = ((v19 * v23 + v20 * v21) % v22 * v22 + v20 * v23) % v24
            local n2 = math.floor(n / v22)
            local n3 = n - n2 * v22
            local n4 = v25 + 1
            pcall(function()
                setupvalue(result, 15, n2)
                setupvalue(result, 13, n3)
                setupvalue(result, 19, n4)
            end)
            return math.floor(n / v24 * 16777215), n4
        end

        local function fn13(arg, arg2)
            local tbl9 = {}
            local v19 = obj4.BodyParts[math.random(#obj4.BodyParts)]
            arg2 = arg2 or 50
            local root = humanoidRootPart or (v18.Character and (v18.Character:FindFirstChild("HumanoidRootPart") or v18.Character.PrimaryPart))
            if not root then return tbl9 end
            local v20 = obj4.MaxHits
            local tbl10 = {}
            if tbl.attackmobs then
                for _, v21 in ipairs(enemies:GetChildren()) do
                    if not v21:GetAttribute("IsBoat") and tbl6:IsReady(v21) then
                        local r3 = v21:FindFirstChild("HumanoidRootPart") or v21.PrimaryPart
                        if r3 then
                            local mag = (r3.Position - root.Position).Magnitude
                            if mag <= arg2 then
                                table.insert(tbl10, {v21, r3, mag})
                            end
                        end
                    end
                end
            end
            if tbl.attackplayers and not v18:GetAttribute("PvpDisabled") then
                for _, child in pairs(v2.Characters:GetChildren()) do
                    if child ~= v18.Character then
                        local p = v3:GetPlayerFromCharacter(child)
                        local isEnemy = p and (tbl.AutoKillPlayerinTrial or (p.Team ~= v18.Team or not p.Team))
                        if isEnemy then
                            local r3 = child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart
                            if r3 then
                                local mag = (r3.Position - root.Position).Magnitude
                                if mag <= arg2 then table.insert(tbl10, {child, r3, mag}) end
                            end
                        end
                    end
                end
            end
            table.sort(tbl10, function(a, b) return a[3] < b[3] end)
            for i = 1, math.min(#tbl10, v20) do
                table.insert(tbl9, {tbl10[i][1], tbl10[i][2]})
            end
            return tbl9
        end

        local function fn21()
            local tool = character:FindFirstChildOfClass("Tool")
            local toolTip = tool and tool.ToolTip or nil
            if not tool then
                if not tbl.AutoAttack then return end
                for _, child in ipairs(v18.Backpack:GetChildren()) do
                    if child:IsA("Tool") and child.ToolTip == "Melee" then
                        humanoid:EquipTool(child)
                        task.wait(0.05)
                        tool = child
                        toolTip = "Melee"
                        break
                    end
                end
            end
            if not tool then return end
            if not table.find({"Melee", "Blox Fruit", "Sword", "Gun"}, toolTip) then return end

            if toolTip == "Gun" then
                if reShootGunEvent and tool:FindFirstChild("RemoteEvent") then
                    local v19 = fn13(false, 500)[1]
                    if v19 then
                        local v21, v22 = fn10()
                        pcall(function()
                            validator2:FireServer(v21, v22)
                            if obj4.ShootStyles[tool.Name] == "TAP" then
                                tool.RemoteEvent:FireServer("TAP", v19[2].Position)
                            else
                                for i = 1, (obj4.ShootsPerTarget[tool.Name] or 1) do
                                    reShootGunEvent:FireServer(v19[2].Position, {v19[2]})
                                end
                            end
                        end)
                    end
                end
                return
            end

            local v19 = fn13(toolTip == "Blox Fruit")
            reRegisterAttack:FireServer(tbl.FastAttackDelay or 0)
            local tbl9 = {}
            local v20 = nil
            for _, v21 in ipairs(v19) do
                if v21[1] and v21[2] then
                    table.insert(tbl9, v21)
                    v20 = v20 or v21[2]
                end
            end
            if v20 and RegisterHit then
                pcall(function()
                    RegisterHit:FireServer(v20, tbl9, nil, nil, tostring(v18.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15))
                end)
            end
        end
        return {Attack = fn21, GetHits = fn13, AttackManager = obj4}
    end

    tbl6.FastAttack = fn9()

    -- Utilities tối giản
    local utilities = {}
    function utilities:GetFarmCFrame(root, extra)
        if not root then return nil end
        local posMethod = tbl.PosMethod or "Above"
        local position = root.Position
        local tool = character and character:FindFirstChildOfClass("Tool")
        local isFruit = tool and tool.ToolTip == "Blox Fruit"
        local n = tonumber(tbl.PosY) or (isFruit and 6 or 18)
        local y = isFruit and math.clamp(n, 3, 8) or math.clamp(n, 5, 25)
        if posMethod == "Orbit" then
            local angle = (tick() * 3) % (math.pi * 2)
            local r = tonumber(tbl.CircleRadius) or (isFruit and 6 or y)
            return CFrame.new(position + Vector3.new(math.cos(angle) * r, y, math.sin(angle) * r))
        end
        return CFrame.new(position + Vector3.new(0, y, 0.5))
    end

    function utilities:GetDistance(target)
        local root = v18.Character and v18.Character:FindFirstChild("HumanoidRootPart")
        if not root or not target then return math.huge end
        if typeof(target) == "CFrame" then target = target.Position end
        if typeof(target) == "Instance" then
            target = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head") or target.PrimaryPart
            target = target and target.Position
        end
        if typeof(target) ~= "Vector3" then return math.huge end
        return (root.Position - target).Magnitude
    end

    function utilities:AutoHaki()
        pcall(function()
            if not v18.Character:HasTag("Buso") and beli.Value >= 25000 then
                tbl6:FireInvoke("BuyHaki", "Buso")
            elseif v18.Character:HasTag("Buso") and not v18.Character:FindFirstChild("HasBuso") then
                tbl6:FireInvoke("Buso")
            end
        end)
    end

    function utilities:EquipWeapon(kind)
        kind = kind or tbl.AutoFarmWeapon or tbl.SelectWeapon or "Melee"
        for _, child in ipairs(v18.Backpack:GetChildren()) do
            if child:IsA("Tool") and child.ToolTip == kind then
                humanoid:EquipTool(child)
                return true
            end
        end
        return false
    end

    function utilities:CheckMon(name)
        for _, child in ipairs(enemies:GetChildren()) do
            if (child.Name == name or child.Name:lower() == name:lower()) and tbl6:IsReady(child) then
                return true
            end
        end
        return false
    end

    function utilities:GetEnemies(name)
        local list = type(name) == "table" and name or {name}
        for _, child in ipairs(enemies:GetChildren()) do
            if tbl6:IsReady(child) then
                for _, n in ipairs(list) do
                    if child.Name == n or child.Name:lower() == n:lower() then
                        return child
                    end
                end
            end
        end
        return nil
    end

    tbl6.Utilities = utilities

    --==================================================================
    -- [6/6] UI + MAIN LOOP
    --==================================================================
    tbl6.Functions = {}
    tbl6.ActiveFunction = nil

    local function runLoop(name, interval, fn, noCheck)
        task.spawn(function()
            while true do
                if (noCheck or tbl[name]) and tbl.DungdxEnabled ~= false then
                    pcall(fn)
                end
                task.wait(interval or 0.1)
            end
        end)
    end

    -- Auto Attack Loop
    runLoop("AutoAttack", 0.05, function()
        if tbl.AutoAttack ~= false then
            tbl6.FastAttack.Attack()
        end
    end, true)

    -- Auto Farm (đơn giản hoá)
    runLoop("AutoFarm", 0.5, function()
        local root = v18.Character and v18.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local mob = utilities:GetEnemies({"Bandit", "Trainee", "Reborn Skeleton", "Living Zombie", "Demonic Soul", "Pirate", "Monkey"})
        if mob then
            utilities:AutoHaki()
            utilities:EquipWeapon()
            local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
            if mobRoot then
                tweenManager:topos(utilities:GetFarmCFrame(mobRoot))
            end
        end
    end, true)

    -- ESP Players
    runLoop("ESPPlayer", 0.5, function()
        if not tbl.ESPPlayer then return end
        for _, p in ipairs(v3:GetPlayers()) do
            if p ~= v18 and p.Character then
                local head = p.Character:FindFirstChild("Head")
                if head and not head:FindFirstChild("ESP_dungdx") then
                    local f = Instance.new("Folder", head)
                    f.Name = "ESP_dungdx"
                    local bb = Instance.new("BillboardGui", f)
                    bb.Adornee = head
                    bb.Size = UDim2.new(0, 200, 0, 40)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    local t = Instance.new("TextLabel", bb)
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.TextColor3 = Color3.new(1, 1, 1)
                    t.TextStrokeTransparency = 0.3
                    t.Font = Enum.Font.GothamBold
                    t.TextSize = 12
                    t.Text = p.Name
                end
            end
        end
        if not tbl.ESPPlayer then
            for _, p in ipairs(v3:GetPlayers()) do
                local head = p.Character and p.Character:FindFirstChild("Head")
                if head then
                    local f = head:FindFirstChild("ESP_dungdx")
                    if f then f:Destroy() end
                end
            end
        end
    end, true)

    --==================================================================
    -- LOAD UI
    --==================================================================
    local function loadLibrary()
        local v22 = lua4:CreateWindow({
            Title = "Dungdx Hub",
            Subtitle = "Blox Fruit | discord.gg/AJBT8F79yf",
            Version = "v1.0",
        })

        local tbl15 = {
            Home = v22:AddTab("Trang Chủ"),
            Farm = v22:AddTab("Nông Trại"),
            Weapon = v22:AddTab("Vũ Khí"),
            Player = v22:AddTab("Người Chơi"),
            Misc = v22:AddTab("Khác"),
        }

        -- Home
        do
            local sec = tbl15.Home:addSection()
            local menu = sec:addMenu("Dungdx Hub")
            menu:addLabel("🎮 Dungdx Hub v1.0", "Chào mừng " .. v18.Name .. "!")
            menu:addLabel("🔗 Discord", "discord.gg/AJBT8F79yf")
            menu:addButton("Copy Discord Link", function()
                setclipboard("https://discord.gg/AJBT8F79yf")
                tbl6:SendNotify(nil, "Discord", "Đã copy link Discord!", 3)
            end)
            menu:addButton("Rejoin Server", function()
                v4.__ServerBrowser:InvokeServer("teleport", game.JobId)
            end)
        end

        -- Farm Tab
        do
            local sec = tbl15.Farm:addSection()
            local m1 = sec:addMenu("Cài Đặt Farm")
            m1:addToggle("Auto Farm", false, function(v)
                tbl.AutoFarm = v
            end)
            m1:addToggle("Auto Attack", true, function(v)
                tbl.AutoAttack = v
            end)
            m1:addToggle("Attack Mobs", true, function(v)
                tbl.attackmobs = v
            end)
            m1:addToggle("Attack Players", true, function(v)
                tbl.attackplayers = v
            end)
            m1:addSlider("Farm Distance", 0, 30, 18, function(v)
                tbl.PosY = v
            end)
            m1:addSlider("Tween Speed", 10, 500, 250, function(v)
                tbl.TweenSpeed = v
            end)
            m1:addDropdown("Pos Method", "Above", {"Above", "Orbit"}, function(v)
                tbl.PosMethod = v
            end)
            m1:addToggle("Bring Monster", true, function(v)
                tbl.BringMonster = v
            end)
            m1:addSlider("Bring Radius", 100, 500, 350, function(v)
                tbl.BringMonsterRadius = v
            end)
        end

        -- Weapon Tab
        do
            local sec = tbl15.Weapon:addSection()
            local m = sec:addMenu("Vũ Khí")
            m:addDropdown("Chọn Vũ Khí", "Melee", {"Melee", "Sword", "Blox Fruit", "Gun"}, function(v)
                tbl.SelectWeapon = v
                tbl.AutoFarmWeapon = v
            end)
            m:addToggle("Auto Haki", true, function(v)
                tbl.AutoHaki = v
            end)
        end

        -- Player Tab
        do
            local sec = tbl15.Player:addSection()
            local m = sec:addMenu("ESP")
            m:addToggle("ESP Players", false, function(v)
                tbl.ESPPlayer = v
            end)
            local sec2 = tbl15.Player:addSection()
            local m2 = sec2:addMenu("Server")
            local statusLabel = m2:addLabel("Trạng thái", "Đang tải...")
            task.spawn(function()
                while task.wait(3) do
                    local fps = math.floor(v2:GetRealPhysicsFPS())
                    statusLabel:RefreshDesc(("FPS: %d\nSea: %s\nLevel: %s"):format(
                        fps,
                        attribute or "?",
                        tostring(level.Value)
                    ))
                end
            end)
            m2:addButton("Server Hop", function()
                v4.__ServerBrowser:InvokeServer("teleport", game.JobId)
            end)
        end

        -- Misc Tab
        do
            local sec = tbl15.Misc:addSection()
            local m = sec:addMenu("Tiện Ích")
            m:addButton("Full Bright", function()
                v7.Ambient = Color3.fromRGB(178, 178, 178)
                v7.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
                v7.Brightness = 3
                v7.ClockTime = 14
                tbl6:SendNotify(nil, "Misc", "Full Bright bật!", 3)
            end)
            m:addButton("Remove Fog", function()
                v7.FogEnd = 9e9
                tbl6:SendNotify(nil, "Misc", "Đã xoá sương mù!", 3)
            end)
            m:addButton("Clean Memory", function()
                pcall(function() collectgarbage("step", 200) end)
                tbl6:SendNotify(nil, "Misc", "Đã dọn RAM!", 3)
            end)
            m:addButton("Anti AFK", function()
                task.spawn(function()
                    while true do
                        task.wait(300)
                        pcall(function()
                            v17:CaptureController()
                            v17:ClickButton1(Vector2.new(0, 0))
                        end)
                    end
                end)
                tbl6:SendNotify(nil, "Misc", "Anti AFK đang chạy!", 3)
            end)
        end

        task.wait(1)
        tbl6:SendNotify(nil, "🎉 Dungdx Hub", "Script đã load thành công!", 5)
        task.wait(0.5)
        tbl6:SendNotify(nil, "💬 Discord", "discord.gg/AJBT8F79yf", 8)
    end

    task.spawn(loadLibrary)

    print("========================================")
    print("[Dungdx Hub] Loaded successfully!")
    print("[Discord] https://discord.gg/AJBT8F79yf")
    print("========================================")
end

while true do
    task.wait()
    warn("[Dungdx Hub] Waiting for executor...")
end