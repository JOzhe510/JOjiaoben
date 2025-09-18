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

-- ==================== 极致预判参数 ====================
local FOV = 120  -- 扩大FOV范围
local Prediction = 0.42  -- 激进预判系数
local Smoothness = 0.85  -- 更平滑的瞄准
local Enabled = true
local LockedTarget = nil
local LockSingleTarget = true
local ESPEnabled = true
local WallCheck = true
local PredictionEnabled = true

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
local Highlights = {}
local TargetHistory = {}
local MAX_HISTORY = 16

-- ==================== 极致预判算法 ====================
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
    
    -- 清理历史数据
    for i = #history, 1, -1 do
        if currentTime - history[i].time > 0.5 then
            table.remove(history, i)
        end
    end
    
    -- 记录当前帧
    local currentData = {
        position = target.Position,
        time = currentTime,
        velocity = target.Velocity
    }
    table.insert(history, currentData)
    
    -- 激进预判：即使数据不足也强制预判
    if #history < 2 then
        local distance = (target.Position - Camera.CFrame.Position).Magnitude
        local dynamicPrediction = Prediction * (1.3 + distance / 80)
        return target.Position + (target.Velocity * dynamicPrediction)
    end
    
    -- 计算加权速度和加速度
    local totalWeight = 0
    local weightedVelocity = Vector3.zero
    local weightedAcceleration = Vector3.zero
    
    for i = 2, #history do
        local current = history[i]
        local previous = history[i-1]
        local timeDiff = current.time - previous.time
        
        if timeDiff > 0.001 then
            local weight = 3.0 / (currentTime - current.time + 0.05)
            totalWeight = totalWeight + weight
            
            local velocity = (current.position - previous.position) / timeDiff
            weightedVelocity = weightedVelocity + (velocity * weight)
            
            if i > 2 then
                local prevPrevious = history[i-2]
                local prevTimeDiff = previous.time - prevPrevious.time
                if prevTimeDiff > 0.001 then
                    local prevVelocity = (previous.position - prevPrevious.position) / prevTimeDiff
                    local acceleration = (velocity - prevVelocity) / timeDiff
                    weightedAcceleration = weightedAcceleration + (acceleration * weight * 2.0)
                end
            end
        end
    end
    
    if totalWeight > 0 then
        weightedVelocity = weightedVelocity / totalWeight
        weightedAcceleration = weightedAcceleration / totalWeight
        
        local distance = (target.Position - Camera.CFrame.Position).Magnitude
        local dynamicPrediction = Prediction * (1.4 + distance / 70)
        
        -- 极致预判公式
        local predictedPos = target.Position + 
                            (weightedVelocity * dynamicPrediction * 1.4) +
                            (weightedAcceleration * dynamicPrediction * dynamicPrediction * 2.0)
        
        return predictedPos
    end
    
    local distance = (target.Position - Camera.CFrame.Position).Magnitude
    return target.Position + (target.Velocity * Prediction * (1.5 + distance / 60))
end

-- ==================== 死锁瞄准函数 ====================
local function AimAtPosition(position)
    if not position then return end
    
    local cameraPos = Camera.CFrame.Position
    local direction = (position - cameraPos).Unit
    
    -- 死锁级别的平滑瞄准
    local currentDirection = Camera.CFrame.LookVector
    local newDirection = (currentDirection * (1 - Smoothness) + direction * Smoothness).Unit
    
    Camera.CFrame = CFrame.new(cameraPos, cameraPos + newDirection)
end

-- ==================== 目标选择逻辑 ====================
local function FindBestTarget()
    local bestTarget = nil
    local closestAngle = math.rad(FOV)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                -- 穿墙检测
                if WallCheck then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                    raycastParams.IgnoreWater = true
                    
                    local raycastResult = workspace:Raycast(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * 1000, raycastParams)
                    
                    if raycastResult and raycastResult.Instance:IsDescendantOf(player.Character) == false then
                        continue
                    end
                end
                
                local predictedPosition = CalculatePredictedPosition(rootPart)
                local screenPosition, visible = Camera:WorldToViewportPoint(predictedPosition)
                
                if visible then
                    local angle = math.atan2(
                        screenPosition.X - ScreenCenter.X,
                        screenPosition.Y - ScreenCenter.Y
                    )
                    
                    if math.abs(angle) < closestAngle then
                        closestAngle = math.abs(angle)
                        bestTarget = rootPart
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- ==================== UI美化 ====================
local Theme = {
    Background = Color3.fromRGB(28, 28, 38),
    Header = Color3.fromRGB(45, 45, 60),
    Button = Color3.fromRGB(50, 50, 75),
    ButtonHover = Color3.fromRGB(65, 65, 90),
    Text = Color3.fromRGB(240, 240, 240),
    Accent = Color3.fromRGB(0, 180, 255),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 170, 60)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "AimBotUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 350)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Theme.Background
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 80)
UIStroke.Thickness = 2
UIStroke.Parent = Frame

-- 展开/收起按钮
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 32, 0, 22)
ToggleButton.Position = UDim2.new(1, -32, 0, 0)
ToggleButton.Text = "▲"
ToggleButton.TextColor3 = Theme.Text
ToggleButton.BackgroundColor3 = Theme.Button
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.BorderSizePixel = 0
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

local UIElements = {}
local isExpanded = true

-- 标题
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.Text = "🔮 死锁预判自瞄 🔮"
Title.BackgroundColor3 = Theme.Header
Title.BackgroundTransparency = 0.05
Title.TextColor3 = Theme.Accent
Title.BorderSizePixel = 0
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame
table.insert(UIElements, Title)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- 按钮创建函数
local function CreateStyledButton(name, positionY, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.9, 0, 0, 36)
    button.Position = UDim2.new(0.05, 0, positionY, 0)
    button.Text = text
    button.BackgroundColor3 = Theme.Button
    button.BackgroundTransparency = 0.1
    button.TextColor3 = Theme.Text
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Theme.ButtonHover
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Theme.Button
    end)
    
    table.insert(UIElements, button)
    return button
end

-- 输入框创建函数
local function CreateStyledTextBox(positionY, text, placeholder)
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.9, 0, 0, 36)
    textBox.Position = UDim2.new(0.05, 0, positionY, 0)
    textBox.Text = text
    textBox.PlaceholderText = placeholder
    textBox.BackgroundColor3 = Theme.Button
    textBox.BackgroundTransparency = 0.1
    textBox.TextColor3 = Theme.Text
    textBox.BorderSizePixel = 0
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = textBox
    
    table.insert(UIElements, textBox)
    return textBox
end

-- 创建UI元素
local ToggleBtn = CreateStyledButton("ToggleBtn", 0.12, "🎯 自瞄: 开启")
local ESPToggleBtn = CreateStyledButton("ESPToggleBtn", 0.24, "👁️ ESP: 开启")
local WallCheckBtn = CreateStyledButton("WallCheckBtn", 0.36, "🧱 穿墙检测: 开启")
local PredictionBtn = CreateStyledButton("PredictionBtn", 0.48, "⚡ 预判模式: 开启")
local SingleTargetBtn = CreateStyledButton("SingleTargetBtn", 0.84, "🔒 单锁模式: 开启")

local FOVInput = CreateStyledTextBox(0.60, tostring(FOV), "FOV范围")
local PredictionInput = CreateStyledTextBox(0.72, tostring(Prediction), "预判系数")

-- ==================== UI功能实现 ====================
local function UpdateButtonText(button, text, state)
    button.Text = text .. (state and "开启" or "关闭")
    button.BackgroundColor3 = state and Theme.Success or Theme.Warning
end

-- 初始化按钮状态
UpdateButtonText(ToggleBtn, "🎯 自瞄: ", Enabled)
UpdateButtonText(ESPToggleBtn, "👁️ ESP: ", ESPEnabled)
UpdateButtonText(WallCheckBtn, "🧱 穿墙检测: ", WallCheck)
UpdateButtonText(PredictionBtn, "⚡ 预判模式: ", PredictionEnabled)
UpdateButtonText(SingleTargetBtn, "🔒 单锁模式: ", LockSingleTarget)

-- 按钮事件绑定
ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    UpdateButtonText(ToggleBtn, "🎯 自瞄: ", Enabled)
end)

ESPToggleBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    UpdateButtonText(ESPToggleBtn, "👁️ ESP: ", ESPEnabled)
end)

WallCheckBtn.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    UpdateButtonText(WallCheckBtn, "🧱 穿墙检测: ", WallCheck)
end)

PredictionBtn.MouseButton1Click:Connect(function()
    PredictionEnabled = not PredictionEnabled
    UpdateButtonText(PredictionBtn, "⚡ 预判模式: ", PredictionEnabled)
end)

SingleTargetBtn.MouseButton1Click:Connect(function()
    LockSingleTarget = not LockSingleTarget
    UpdateButtonText(SingleTargetBtn, "🔒 单锁模式: ", LockSingleTarget)
    if not LockSingleTarget then
        LockedTarget = nil
    end
end)

-- 输入框事件
FOVInput.FocusLost:Connect(function()
    local newFOV = tonumber(FOVInput.Text)
    if newFOV and newFOV > 0 then
        FOV = newFOV
        Circle.Radius = FOV
    else
        FOVInput.Text = tostring(FOV)
    end
end)

PredictionInput.FocusLost:Connect(function()
    local newPrediction = tonumber(PredictionInput.Text)
    if newPrediction and newPrediction >= 0 then
        Prediction = newPrediction
    else
        PredictionInput.Text = tostring(Prediction)
    end
end)

-- 展开/收起功能
local function toggleUI()
    isExpanded = not isExpanded
    
    if isExpanded then
        Frame.Size = UDim2.new(0, 250, 0, 350)
        ToggleButton.Text = "▲"
        for _, element in pairs(UIElements) do
            element.Visible = true
        end
    else
        Frame.Size = UDim2.new(0, 250, 0, 32)
        ToggleButton.Text = "▼"
        for _, element in pairs(UIElements) do
            if element ~= Title then
                element.Visible = false
            end
        end
    end
end

ToggleButton.MouseButton1Click:Connect(toggleUI)

-- ==================== 主循环 ====================
RunService.RenderStepped:Connect(function()
    Circle.Position = ScreenCenter
    Circle.Radius = FOV
    
    if not Enabled then return end
    
    if LockSingleTarget and LockedTarget and LockedTarget.Parent then
        local humanoid = LockedTarget.Parent:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local predictedPosition = CalculatePredictedPosition(LockedTarget)
            AimAtPosition(predictedPosition)
            return
        else
            LockedTarget = nil
        end
    end
    
    local target = FindBestTarget()
    if target then
        LockedTarget = target
        local predictedPosition = CalculatePredictedPosition(target)
        AimAtPosition(predictedPosition)
    end
end)

-- 按键绑定
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.U then
        toggleUI()
    elseif input.KeyCode == Enum.KeyCode.F then
        Enabled = not Enabled
        UpdateButtonText(ToggleBtn, "🎯 自瞄: ", Enabled)
    end
end)

print("💀 死锁预判自瞄加载完成 - 按F键切换自瞄，U键控制UI")
print("当前预判系数:", Prediction)
print("死锁模式已启用")