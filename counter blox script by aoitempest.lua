local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- setting --
local AimbotEnabled = true
local AimbotFOV = 120
local AimbotSmoothness = 0.2
local AimPart = "Head"
local ESPEnabled = true
local AntiFlashEnabled = true
local AntiSmokeEnabled = true
local AutoWallbangEnabled = true
local WallbangDamageThreshold = 20


local function updateHighlight(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("ESPHighlight")
        local isEnemy = player ~= LocalPlayer and player.Team ~= LocalPlayer.Team

        if isEnemy then
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
            end
        else
            if highlight then
                highlight:Destroy()
            end
        end
    end
end


local function getClosestEnemy()
    local closest = nil
    local shortestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local part = player.Character:FindFirstChild(AimPart)

            if humanoid and humanoid.Health > 0 and part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize / 2).Magnitude
                    if dist < AimbotFOV and dist < shortestDist then
                        shortestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end


Lighting.ChildAdded:Connect(function(effect)
    if AntiFlashEnabled and (effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect")) then
        effect:Destroy()
    end
end)


Workspace.ChildAdded:Connect(function(obj)
    if not AntiSmokeEnabled then return end
    if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("MeshPart") then
        if tostring(obj.Name):lower():find("smoke") or tostring(obj.Name):lower():find("cloud") then
            wait(0.1)
            obj:Destroy()
        end
    end
end)


local function estimateWallbangDamage(material)
    local baseDamage = 100
    local reduction = 0

    if material == Enum.Material.Concrete then reduction = 0.7
    elseif material == Enum.Material.Wood then reduction = 0.4
    elseif material == Enum.Material.Metal then reduction = 0.85
    elseif material == Enum.Material.Plastic then reduction = 0.3
    else reduction = 0.5
    end

    return math.floor(baseDamage * (1 - reduction))
end


local function autoWallbang()
    if not AutoWallbangEnabled then return end

    local origin = Camera.CFrame.Position
    local direction = Mouse.Hit.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true

    local result = workspace:Raycast(origin, direction.Unit * 500, rayParams)
    if result and result.Instance then
        local hitPart = result.Instance
        local hitParent = hitPart:FindFirstAncestorOfClass("Model")
        local material = result.Material

        if hitParent and hitParent:FindFirstChild("Humanoid") then
            local plr = Players:GetPlayerFromCharacter(hitParent)
            local humanoid = hitParent:FindFirstChildOfClass("Humanoid")
            if plr and plr.Team ~= LocalPlayer.Team and humanoid and humanoid.Health > 0 then
                local predictedDamage = estimateWallbangDamage(material)
                if predictedDamage >= WallbangDamageThreshold then
                    print("[Wallbang] Có thể xuyên! Sát thương dự kiến:", predictedDamage)
                end
            end
        end
    end
end


Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        RunService.RenderStepped:Wait()
        updateHighlight(player)
    end)
end)


RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            updateHighlight(player)
        end
    end

    if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestEnemy()
        if target then
            local desiredCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(desiredCF, AimbotSmoothness)
        end
    end

    autoWallbang()
end)
