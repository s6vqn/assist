local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local AimEnabled = false
local Smoothness = 0.15
local FOV = 15

-- T Key Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.T then
        AimEnabled = not AimEnabled
        print("Aimbot:", AimEnabled and "ON" or "OFF")
    end
end)

-- Right Click Detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimEnabled then
        return
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
    end
end)

-- Function to get head, neck, or humanoid root part for aiming
local function getTargetPart(character)
    local head = character:FindFirstChild("Head")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local torso = character:FindFirstChild("Torso")

    if head then
        return head.Position
    elseif torso then
        return torso.Position
    elseif humanoidRootPart then
        return humanoidRootPart.Position
    end
    return nil
end

-- Function to find the closest player's head or neck with distance and FOV check
local function getClosestPlayer()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetPos = getTargetPart(character)
                if targetPos then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPos).Magnitude

                    local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        local toTarget = (targetPos - Camera.CFrame.Position).unit
                        local cameraForward = Camera.CFrame.LookVector
                        local angle = math.acos(cameraForward:Dot(toTarget)) * (180 / math.pi)

                        if angle <= FOV and distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = targetPos
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- Aimbot Function (Soft/Smooth)
local function aimAtTarget()
    local target = getClosestPlayer()
    if target then
        -- Smooth aim - like dragging your aim towards enemy
        local TargetCF = CFrame.new(Camera.CFrame.Position, target)
        Camera.CFrame = Camera.CFrame:Lerp(TargetCF, Smoothness)
    end
end

-- Run Aimbot every frame
RunService.RenderStepped:Connect(function()
    if AimEnabled then
        aimAtTarget()
    end
end)

print("Soft Aimbot Loaded!")
print("Press T to toggle")
print("Aim at enemy with smooth aim")
