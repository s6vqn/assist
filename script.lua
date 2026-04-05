local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local ToggleEnabled = false
local RightClickHeld = false
local Smoothness = 0.25
local FOV = 20

-- T Key Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.T then
        ToggleEnabled = not ToggleEnabled
        print("Aimbot:", ToggleEnabled and "ON" or "OFF")
    end
end)

-- Right Click Detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = false
    end
end)

-- Wall Check
local function canSeeTarget(targetPos)
    local origin = Camera.CFrame.Position
    local direction = (targetPos - origin).Unit * 1000
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character}, true, false)
    
    if hit then
        -- Check if hit is the target
        local hitModel = hit.Parent
        for i = 1, 5 do
            if hitModel and hitModel:FindFirstChildOfClass("Humanoid") then
                return true
            end
            if hitModel then
                hitModel = hitModel.Parent
            end
        end
        return false
    end
    
    return true
end

-- Get any part
local function getAimedPart()
    local target = Mouse.Target
    
    if target then
        for i = 1, 10 do
            if target and target:FindFirstChildOfClass("Humanoid") then
                return target
            end
            if target then
                target = target.Parent
            end
        end
    end
    
    return nil
end

-- Find closest
local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local aimedPart = getAimedPart()
                if aimedPart and aimedPart:IsDescendantOf(character) then
                    local targetPos = aimedPart.Position
                    
                    -- Wall check - only aim if can see target
                    if not canSeeTarget(targetPos) then
                        continue
                    end
                    
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

-- Aimbot
local function aimAtTarget()
    local targetPos = getClosestTarget()
    if targetPos then
        local TargetCF = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(TargetCF, Smoothness)
    end
end

-- Run
RunService.RenderStepped:Connect(function()
    if ToggleEnabled and RightClickHeld then
        aimAtTarget()
    end
end)

print("Aimbot Loaded!")
print("Press T to toggle")
print("Hold RIGHT CLICK to aim")
print("- Wall check added (won't aim through walls)")
