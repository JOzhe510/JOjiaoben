```lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

local FOV = 80
local Prediction = 0.15
local Smoothness = 0.8
local Enabled = true
local LockedTarget = nil
local LockSingleTarget = true
local ESPEnabled = true

local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Radius = FOV
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 2
Circle.Position = ScreenCenter
Circle.Transparency = 1
Circle.NumSides = 64
Circle.Filled = false

local ESPObjects = {}

local function createESP(player)
    if ESPObjects[player] then return ESPObjects[player] end
    
    local esp = {
        player = player,
        nameText = Drawing.new("Text"),
        healthText = Drawing.new("Text"),
        box = Drawing.new("Square"),
        visible = false
    }
    
    esp.nameText.Text = player.Name
    esp.nameText.Size = 16
    esp.nameText.Center = true
    esp.nameText.Outline = true
    esp.nameText.Color = Color3.fromRGB(255, 255, 255)
    esp.nameText.Visible = false
    
    esp.healthText.Size = 14
    esp.healthText.Center = true
    esp.healthText.Outline = true
    esp.healthText.Color = Color3.fromRGB(255, 255, 255)
    esp.healthText.Visible = false
    
    esp.box.Thickness = 1
    esp.box.Filled = false
    esp.box.Color = Color3.fromRGB(255, 255, 255)
    esp.box.Visible = false
    
    ESPObjects[player] = esp
    return esp
end

local function removeESP(player)
    local esp = ESPObjects[player]
    if esp then
        pcall(function()
            esp.nameText:Remove()
            esp.healthText:Remove()
            esp.box:Remove()
        end)
        ESPObjects[player] = nil
    end
end

local function updateESP()
    if not ESPEnabled then 
        for _, esp in pairs(ESPObjects) do
            esp.nameText.Visible = false
            esp.healthText.Visible = false
            esp.box.Visible = false
        end
        return 
    end
    
    for player, esp in pairs(ESPObjects) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and head and humanoid.Health > 0 then
                local success, screenPosition = pcall(function()
                    return Camera:WorldToViewportPoint(head.Position)
                end)
                
                if success and screenPosition and screenPosition.Z > 0 then
                    local characterSize = player.Character:GetExtentsSize()
                    local scale = 100 / screenPosition.Z
                    local width = scale * 2
                    local height = characterSize.Y / screenPosition.Z * 2.5
                    
                    esp.box.Size = Vector2.new(width, height)
                    esp.box.Position = Vector2.new(screenPosition.X - width/2, screenPosition.Y - height/2)
                    esp.box.Visible = true
                    
                    esp.nameText.Position = Vector2.new(screenPosition.X, screenPosition.Y - height/2 - 20)
                    esp.nameText.Visible = true
                    
                    esp.healthText.Text = "HP: " .. math.floor(humanoid.Health)
                    esp.healthText.Position = Vector2.new(screenPosition.X, screenPosition.Y - height/2 - 40)
                    esp.healthText.Visible = true
                    
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    esp.healthText.Color = color
                    esp.box.Color = color
                    esp.nameText.Color = color
                    
                    esp.visible = true
                else
                    esp.visible = false
                    esp.nameText.Visible = false
                    esp.healthText.Visible = false
                    esp.box.Visible = false
                end
            else
                esp.visible = false
                esp.nameText.Visible = false
                esp.healthText.Visible = false
                esp.box.Visible = false
            end
        else
            esp.visible = false
            esp.nameText.Visible = false
            esp.healthText.Visible = false
            esp.box.Visible = false
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "AimBotUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 280)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔥 自瞄面板 🔥"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.BackgroundTransparency = 0.3
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 0
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
ToggleBtn.Text = "🎯 自瞄: 开启"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

local ESPToggleBtn = Instance.new("TextButton")
ESPToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ESPToggleBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
ESPToggleBtn.Text = "👁 ESP: 开启"
ESPToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ESPToggleBtn.BackgroundTransparency = 0.2
ESPToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggleBtn.BorderSizePixel = 0
ESPToggleBtn.Font = Enum.Font.Gotham
ESPToggleBtn.Parent = Frame

local ESPToggleCorner = Instance.new("UICorner")
ESPToggleCorner.CornerRadius = UDim.new(0, 6)
ESPToggleCorner.Parent = ESPToggleBtn

local FOVInput = Instance.new("TextBox")
FOVInput.Size = UDim2.new(0.8, 0, 0, 30)
FOVInput.Position = UDim2.new(0.1, 0, 0.45, 0)
FOVInput.Text = tostring(FOV)
FOVInput.PlaceholderText = "输入FOV值"
FOVInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FOVInput.BackgroundTransparency = 0.2
FOVInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVInput.BorderSizePixel = 0
FOVInput.Font = Enum.Font.Gotham
FOVInput.Parent = Frame

local FOVInputCorner = Instance.new("UICorner")
FOVInputCorner.CornerRadius = UDim.new(0, 6)
FOVInputCorner.Parent = FOVInput

local SingleTargetBtn = Instance.new("TextButton")
SingleTargetBtn.Size = UDim2.new(0.8, 0, 0, 30)
SingleTargetBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
SingleTargetBtn.Text = "🔒 单锁一人: 开启"
SingleTargetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SingleTargetBtn.BackgroundTransparency = 0.2
SingleTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SingleTargetBtn.BorderSizePixel = 0
SingleTargetBtn.Font = Enum.Font.Gotham
SingleTargetBtn.Parent = Frame

local SingleCorner = Instance.new("UICorner")
SingleCorner.CornerRadius = UDim.new(0, 6)
SingleCorner.Parent = SingleTargetBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.8, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.1, 0, 0.75, 0)
StatusLabel.Text = "状态: 等待目标"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextWrapped = true
StatusLabel.Parent = Frame

FOVInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newFOV = tonumber(FOVInput.Text)
        if newFOV and newFOV >= 20 and newFOV <= 200 then
            FOV = newFOV
            Circle.Radius = FOV
            FOVInput.Text = tostring(FOV)
        else
            FOVInput.Text = tostring(FOV)
        end
    end
end)

function IsTargetValid(target)
    if not target or not target.Parent then return false end
    if not target:IsA("BasePart") then return false end
    
    local humanoid = target.Parent:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local success, health = pcall(function()
        return humanoid.Health
    end)
    
    return success and health > 0
end

function GetTarget()
    if LockSingleTarget and LockedTarget then
        if IsTargetValid(LockedTarget) then
            local success, screenPos = pcall(function()
                return Camera:WorldToViewportPoint(LockedTarget.Position)
            end)
            if success and screenPos and screenPos.Z > 0 then
                StatusLabel.Text = "状态: 锁定目标中"
                return LockedTarget
            end
        else
            LockedTarget = nil
            StatusLabel.Text = "状态: 目标失效"
        end
    end
    
    local closest = nil
    local closestDist = FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head and IsTargetValid(head) then
                local success, screenPos = pcall(function()
                    return Camera:WorldToViewportPoint(head.Position)
                end)
                if success and screenPos and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                    if dist < closestDist then
                        closest = head
                        closestDist = dist
                    end
                end
            end
        end
    end
    
    if LockSingleTarget and closest and not LockedTarget then
        LockedTarget = closest
    end
    
    StatusLabel.Text = closest and "状态: 发现目标" or "状态: 无目标"
    return closest
end

local function AimToTarget(target)
    if not target or not target:IsA("BasePart") then return false end
    
    local success, targetPos = pcall(function()
        return target.Position + (target.Velocity * Prediction)
    end)
    if not success then return false end
    
    local success, cameraPos = pcall(function()
        return Camera.CFrame.Position
    end)
    if not success then return false end
    
    local newCFrame = CFrame.new(cameraPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Smoothness)
    return true
end

RunService:BindToRenderStep("AimBot", Enum.RenderPriority.Camera.Value, function()
    if not Enabled then return end
    if not LocalPlayer or not LocalPlayer.Character then return end
    
    local target = GetTarget()
    if target then
        AimToTarget(target)
    end
end)

RunService:BindToRenderStep("ESP", Enum.RenderPriority.Last.Value, function()
    updateESP()
end)

ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Circle.Visible = Enabled
    ToggleBtn.Text = "🎯 自瞄: " .. (Enabled and "开启" or "关闭")
end)

ESPToggleBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggleBtn.Text = "👁 ESP: " .. (ESPEnabled and "开启" or "关闭")
end)

SingleTargetBtn.MouseButton1Click:Connect(function()
    LockSingleTarget = not LockSingleTarget
    SingleTargetBtn.Text = "🔒 单锁一人: " .. (LockSingleTarget and "开启" or "关闭")
    LockedTarget = nil
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        Enabled = not Enabled
        Circle.Visible = Enabled
        ToggleBtn.Text = "🎯 自瞄: " .. (Enabled and "开启" or "关闭")
    elseif input.KeyCode == Enum.KeyCode.T then
        LockedTarget = nil
        StatusLabel.Text = "状态: 取消锁定"
    elseif input.KeyCode == Enum.KeyCode.F then
        local target = GetTarget()
        if target then
            LockedTarget = target
            StatusLabel.Text = "状态: 手动锁定目标"
        end
    elseif input.KeyCode == Enum.KeyCode.V then
        ESPEnabled = not ESPEnabled
        ESPToggleBtn.Text = "👁 ESP: " .. (ESPEnabled and "开启" or "关闭")
    end
end)

Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    if player == LocalPlayer then
        pcall(function() Circle:Remove() end)
        pcall(function() ScreenGui:Destroy() end)
        
        for _, esp in pairs(ESPObjects) do
            pcall(function()
                esp.nameText:Remove()
                esp.healthText:Remove()
                esp.box:Remove()
            end)
        end
        ESPObjects = {}
    else
        if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:IsDescendantOf(workspace) then
            local targetPlayer = Players:GetPlayerFromCharacter(LockedTarget.Parent)
            if targetPlayer == player then
                LockedTarget = nil
                StatusLabel.Text = "状态: 目标退出"
            end
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

RunService.RenderStepped:Connect(function()
    if Circle then
        Circle.Position = ScreenCenter
    end
end)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if Camera and Camera.ViewportSize then
        ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        if Circle then
            Circle.Position = ScreenCenter
        end
    end
end)

game:BindToClose(function()
    pcall(function() Circle:Remove() end)
    pcall(function() ScreenGui:Destroy() end)
    
    for _, esp in pairs(ESPObjects) do
        pcall(function()
            esp.nameText:Remove()
            esp.healthText:Remove()
            esp.box:Remove()
        end)
    end
end)

print("自瞄脚本加载完成")
print("FOV:", FOV)
print("单锁模式:", LockSingleTarget)
print("自瞄状态:", Enabled)
print("ESP状态:", ESPEnabled)
```