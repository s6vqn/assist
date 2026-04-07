local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Smoothness = 0.08

-- Get target part
local function getTargetPart()
    local target = Mouse.Target
    
    if target then
        for i = 1, 10 do
            if target and target:FindFirstChildOfClass("Humanoid") then
                local head = target:FindFirstChild("Head")
                local torso = target:FindFirstChild("Torso") or target:FindFirstChild("HumanoidRootPart")
                
                if target == head then
                    return head
                elseif target.Name == "Torso" or target.Name == "HumanoidRootPart" then
                    return torso
                end
            end
            if target then
                target = target.Parent
            end
        end
    end
    
    return nil
end

-- Find closest enemy
local function getClosestEnemy()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team ~= LocalPlayer.Team then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = getTargetPart()
                if part and part:IsDescendantOf(character) then
                    local targetPos = part.Position
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPos).Magnitude
                    
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPos)
                    if onScreen then
                        if distance < shortestDistance then
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

-- Soft Aim Assist (ALWAYS ON)
RunService.RenderStepped:Connect(function()
    local targetPos = getClosestEnemy()
    if targetPos then
        local TargetCF = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(TargetCF, Smoothness)
    end
end)

print("=================================")
print("Soft Aim Assist - ALWAYS ON")
print("Just play normally!")
print("- Smooth follow")
print("- Targets Torso/Head")
print("- No teammates")
print("- NO TOGGLE, NO HOLD")
print("=================================")
