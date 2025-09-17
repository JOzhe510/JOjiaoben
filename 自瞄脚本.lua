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

-- 超精准参数配置
local FOV = 60
local Prediction = 0.18
local Smoothness = 0.05
local Enabled = true
local LockedTarget = nil
local LockSingleTarget = true
local ESPEnabled = true
local WallCheck = true
local PredictionEnabled = true
local AimAtHead = true

local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- 精准FOV圆圈
local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Radius = FOV
Circle.Color = Color3.fromRGB(255, 50, 50)
Circle.Thickness = 1
Circle.Position = ScreenCenter
Circle.Transparency = 0.8
Circle.NumSides = 128
Circle.Filled = false

-- 性能优化缓存
local ESPObjects = {}
local Highlights = {}
local TargetHistory = {}
local LastTargetTime = 0
local MAX_HISTORY = 15
local TARGET_REFRESH_RATE = 0.01

-- 建筑检测优化
local function isVisible(part)
    if not WallCheck then return true end
    local origin = Camera.CFrame.Position
    local targetPos = part.Position
    local direction = (targetPos - origin).Unit * 5000
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    rayParams.IgnoreWater = true
    
    local rayResult = workspace:Raycast(origin, direction, rayParams)
    
    if not rayResult then return true end
    return rayResult.Instance:IsDescendantOf(part.Parent)
end

-- 高亮优化
local function createHighlight(player)
    if Highlights[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = nil
    highlight.FillTransparency = 0.9
    highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineTransparency = 0
    highlight.Parent = CoreGui
    
    Highlights[player] = highlight
end

-- ESP优化
local function createESP(player)
    if ESPObjects[player] then return ESPObjects[player] end
    
    local esp = {
        player = player,
        nameText = Drawing.new("Text"),
        healthText = Drawing.new("Text"),
        distanceText = Drawing.new("Text"),
        box = Drawing.new("Square"),
        visible = false
    }
    
    esp.nameText.Text = player.Name
    esp.nameText.Size = 14
    esp.nameText.Center = true
    esp.nameText.Outline = true
    esp.nameText.Color = Color3.fromRGB(255, 255, 255)
    esp.nameText.Visible = false
    
    esp.healthText.Size = 12
    esp.healthText.Center = true
    esp.healthText.Outline = true
    esp.healthText.Color = Color3.fromRGB(255, 255, 255)
    esp.healthText.Visible = false
    
    esp.distanceText.Size = 12
    esp.distanceText.Center = true
    esp.distanceText.Outline = true
    esp.distanceText.Color = Color3.fromRGB(200, 200, 200)
    esp.distanceText.Visible = false
    
    esp.box.Thickness = 1
    esp.box.Filled = false
    esp.box.Visible = false
    
    ESPObjects[player] = esp
    return esp
end

-- 超精准预判计算
local function CalculatePredictedPosition(target)
    if not target or not PredictionEnabled then
        return target and target.Position or nil
    end
    
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if not player then return target.Position end
    
    if not TargetHistory[player] then
        TargetHistory[player] = {}
    end
    
    local history = TargetHistory[player]
    local currentTime = tick()
    
    table.insert(history, {
        position = target.Position,
        velocity = target.Velocity,
        time = currentTime
    })
    
    while #history > 0 and currentTime - history[1].time > 0.5 do
        table.remove(history, 1)
    end
    
    if #history < 2 then
        return target.Position + (target.Velocity * Prediction)
    end
    
    local totalVelocity = Vector3.new(0, 0, 0)
    local totalAcceleration = Vector3.new(0, 0, 0)
    
    for i = 2, #history do
        local current = history[i]
        local previous = history[i-1]
        local timeDiff = current.time - previous.time
        
        if timeDiff > 0 then
            local velocity = (current.position - previous.position) / timeDiff
            totalVelocity = totalVelocity + velocity
            
            if i > 2 then
                local prevVelocity = (previous.position - history[i-2].position) / (previous.time - history[i-2].time)
                local acceleration = (velocity - prevVelocity) / timeDiff
                totalAcceleration = totalAcceleration + acceleration
            end
        end
    end
    
    local avgVelocity = totalVelocity / (#history - 1)
    local avgAcceleration = #history > 2 and totalAcceleration / (#history - 2) or Vector3.new(0, 0, 0)
    
    local distance = (target.Position - Camera.CFrame.Position).Magnitude
    local predictionTime = Prediction * (distance / 100)
    
    local predictedPosition = target.Position + 
                             (avgVelocity * predictionTime) + 
                             (0.5 * avgAcceleration * predictionTime * predictionTime)
    
    return predictedPosition
end

-- 目标有效性检查
function IsTargetValid(target)
    if not target or not target.Parent then return false end
    if not target:IsA("BasePart") then return false end
    
    local humanoid = target.Parent:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local success, health = pcall(function()
        return humanoid.Health
    end)
    
    return success and health > 0 and isVisible(target)
end

-- 终极目标获取
function GetTarget()
    local currentTime = tick()
    if currentTime - LastTargetTime < TARGET_REFRESH_RATE and LockedTarget and IsTargetValid(LockedTarget) then
        return LockedTarget
    end
    
    LastTargetTime = currentTime
    
    if LockSingleTarget and LockedTarget and IsTargetValid(LockedTarget) then
        return LockedTarget
    end
    
    local closest = nil
    local closestDist = FOV
    local closestPriority = 0
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetPart = nil
                local priority = 0
                
                if AimAtHead then
                    local head = player.Character:FindFirstChild("Head")
                    if head and IsTargetValid(head) then
                        targetPart = head
                        priority = 3
                    end
                end
                
                if not targetPart then
                    local upperTorso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
                    if upperTorso and IsTargetValid(upperTorso) then
                        targetPart = upperTorso
                        priority = 2
                    end
                end
                
                if not targetPart then
                    for _, part in ipairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and IsTargetValid(part) then
                            targetPart = part
                            priority = 1
                            break
                        end
                    end
                end
                
                if targetPart then
                    local success, screenPos = pcall(function()
                        return Camera:WorldToViewportPoint(targetPart.Position)
                    end)
                    
                    if success and screenPos and screenPos.Z > 0 then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                        
                        if priority > closestPriority or (priority == closestPriority and dist < closestDist) then
                            closest = targetPart
                            closestDist = dist
                            closestPriority = priority
                        end
                    end
                end
            end
        end
    end
    
    if LockSingleTarget and closest and not LockedTarget then
        LockedTarget = closest
    end
    
    return closest
end

-- 神级瞄准算法
local function AimToTarget(target)
    if not target or not target:IsA("BasePart") then return false end
    
    local predictedPosition = CalculatePredictedPosition(target)
    
    local success, targetPos = pcall(function()
        return predictedPosition
    end)
    if not success then return false end
    
    local success, cameraPos = pcall(function()
        return Camera.CFrame.Position
    end)
    if not success then return false end
    
    local aimDirection = (targetPos - cameraPos).Unit
    local currentLook = Camera.CFrame.LookVector
    local dotProduct = currentLook:Dot(aimDirection)
    local angle = math.acos(math.clamp(dotProduct, -1, 1))
    
    local dynamicSmoothness = Smoothness * (1 + angle * 2)
    dynamicSmoothness = math.clamp(dynamicSmoothness, 0.01, 0.2)
    
    local newLook = currentLook:Lerp(aimDirection, dynamicSmoothness)
    local newCFrame = CFrame.new(cameraPos, cameraPos + newLook)
    
    Camera.CFrame = newCFrame
    return true
end

-- 创建终极UI面板
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "GodAimUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- 标题
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "🔥 神级自瞄控制台 🔥"
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- 控制按钮
local buttons = {
    {name = "AimToggle", text = "🎯 自瞄: 开启", ypos = 0.15, key = "Q"},
    {name = "ESPToggle", text = "👁 ESP: 开启", ypos = 0.25, key = "V"},
    {name = "WallToggle", text = "🧱 穿墙检测: 开启", ypos = 0.35, key = "B"},
    {name = "PredToggle", text = "🚀 预判模式: 开启", ypos = 0.45, key = "P"},
    {name = "HeadToggle", text = "💀 头部瞄准: 开启", ypos = 0.55, key = "H"},
    {name = "LockToggle", text = "🔒 单锁模式: 开启", ypos = 0.65, key = "L"},
    {name = "ModeToggle", text = "⚡ 预判系数: 0.18", ypos = 0.75, key = "M"},
    {name = "UnlockBtn", text = "🔄 解除锁定", ypos = 0.85, key = "T"}
}

local UIButtons = {}

for _, btnInfo in ipairs(buttons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, btnInfo.ypos, 0)
    btn.Text = btnInfo.text
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0, 30, 0, 20)
    keyLabel.Position = UDim2.new(0.85, 0, btnInfo.ypos + 0.02, 0)
    keyLabel.Text = "["..btnInfo.key.."]"
    keyLabel.BackgroundTransparency = 1
    keyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.TextSize = 10
    keyLabel.Parent = MainFrame
    
    UIButtons[btnInfo.name] = btn
end

-- 状态显示
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 0.92, 0)
StatusLabel.Text = "状态: 等待目标..."
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

-- 按钮功能
UIButtons.AimToggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Circle.Visible = Enabled
    UIButtons.AimToggle.Text = "🎯 自瞄: " .. (Enabled and "开启" or "关闭")
    StatusLabel.Text = "自瞄 " .. (Enabled and "已启用" or "已禁用")
end)

UIButtons.ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    UIButtons.ESPToggle.Text = "👁 ESP: " .. (ESPEnabled and "开启" or "关闭")
    StatusLabel.Text = "ESP " .. (ESPEnabled and "已启用" or "已禁用")
end)

UIButtons.WallToggle.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    UIButtons.WallToggle.Text = "🧱 穿墙检测: " .. (WallCheck and "开启" or "关闭")
    StatusLabel.Text = "穿墙检测 " .. (WallCheck and "已启用" or "已禁用")
end)

UIButtons.PredToggle.MouseButton1Click:Connect(function()
    PredictionEnabled = not PredictionEnabled
    UIButtons.PredToggle.Text = "🚀 预判模式: " .. (PredictionEnabled and "开启" or "关闭")
    StatusLabel.Text = "预判模式 " .. (PredictionEnabled and "已启用" or "已禁用")
end)

UIButtons.HeadToggle.MouseButton1Click:Connect(function()
    AimAtHead = not AimAtHead
    UIButtons.HeadToggle.Text = "💀 头部瞄准: " .. (AimAtHead and "开启" or "关闭")
    StatusLabel.Text = "头部瞄准 " .. (AimAtHead and "已启用" or "已禁用")
end)

UIButtons.LockToggle.MouseButton1Click:Connect(function()
    LockSingleTarget = not LockSingleTarget
    UIButtons.LockToggle.Text = "🔒 单锁模式: " .. (LockSingleTarget and "开启" or "关闭")
    StatusLabel.Text = "单锁模式 " .. (LockSingleTarget and "已启用" or "已禁用")
end)

UIButtons.ModeToggle.MouseButton1Click:Connect(function()
    Prediction = Prediction == 0.18 and 0.12 or 0.18
    UIButtons.ModeToggle.Text = "⚡ 预判系数: " .. Prediction
    StatusLabel.Text = "预判系数设置为: " .. Prediction
end)

UIButtons.UnlockBtn.MouseButton1Click:Connect(function()
    LockedTarget = nil
    StatusLabel.Text = "目标锁定已解除"
end)

-- 键盘控制
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    local key = input.KeyCode
    if key == Enum.KeyCode.Q then
        UIButtons.AimToggle:MouseButton1Click()
    elseif key == Enum.KeyCode.V then
        UIButtons.ESPToggle:MouseButton1Click()
    elseif key == Enum.KeyCode.B then
        UIButtons.WallToggle:MouseButton1Click()
    elseif key == Enum.KeyCode.P then
        UIButtons.PredToggle:MouseButton1Click()
    elseif key == Enum.KeyCode.H then
        UIButtons.HeadToggle:MouseButton1Click()
    elseif key == Enum.KeyCode.L then
        UIButtons.LockToggle:MouseButton1Click()
    elseif key == Enum.KeyCode.M then
        UIButtons.ModeToggle:MouseButton1Click()
    elseif key == Enum.KeyCode.T then
        UIButtons.UnlockBtn:MouseButton1Click()
    elseif key == Enum.KeyCode.F then
        local target = GetTarget()
        if target then
            LockedTarget = target
            StatusLabel.Text = "已锁定目标: " .. Players:GetPlayerFromCharacter(target.Parent).Name
        end
    elseif key == Enum.KeyCode.U then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 渲染循环
RunService:BindToRenderStep("AimBot", Enum.RenderPriority.Camera.Value, function()
    if not Enabled then return end
    if not LocalPlayer or not LocalPlayer.Character then return end
    
    local target = GetTarget()
    if target then
        AimToTarget(target)
        local player = Players:GetPlayerFromCharacter(target.Parent)
        if player then
            StatusLabel.Text = "锁定: " .. player.Name
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    else
        StatusLabel.Text = "状态: 等待目标..."
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

print("神级自瞄UI已加载 - 按U键隐藏/显示界面")
print("快捷键: Q-自瞄 V-ESP B-穿墙 P-预判 H-头部 L-单锁 M-模式 T-解锁 F-锁定")