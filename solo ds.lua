-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Character refs
local Character, Humanoid, Root, Backpack
local function bindChar(c)
    Character = c
    Humanoid = c:WaitForChild("Humanoid", 10)
    Root = c:WaitForChild("HumanoidRootPart", 10)
end
if LP.Character then bindChar(LP.Character) end
LP.CharacterAdded:Connect(bindChar)
Backpack = LP:WaitForChild("Backpack")

-- Game remotes
local Net = ReplicatedStorage:WaitForChild("Modules", 30)
local reRegisterAttack, reShootGunEvent
pcall(function()
    if Net then
        Net = Net:WaitForChild("Net", 10)
        reRegisterAttack = Net:WaitForChild("RE/RegisterAttack", 5)
        reShootGunEvent = Net:FindFirstChild("RE/ShootGunEvent")
    end
end)