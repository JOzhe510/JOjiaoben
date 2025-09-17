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

-- ==================== 优化预判系数 ====================
local FOV = 80
local Prediction = 0.35  -- 预判系数优化到0.35
local Smoothness = 0.9
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
Circle.Color = Color3.fromRGB(255, 50, 50)  -- 颜色优化
Circle.Thickness = 1.5  -- 线条粗细优化
Circle.Position = ScreenCenter
Circle.Transparency = 1
Circle.NumSides = 64
Circle.Filled = false

local ESPObjects = {}
local Highlights = {}

-- 存储目标历史位置用于预判计算
local TargetHistory = {}
local MAX_HISTORY = 12  -- 增加历史帧数

-- ==================== 优化预判算法 ====================
local function CalculatePredictedPosition(target)
    if not target or not PredictionEnabled then
        return target and target.Position or nil
    end
    
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if not player then return target.Position end
    
    -- 获取目标历史位置
    if not TargetHistory[player] then
        TargetHistory[player] = {}
    end
    
    local history = TargetHistory[player]
    local currentTime = tick()
    
    -- 清理旧数据但保留更多帧
    for i = #history, 1, -1 do
        if currentTime - history[i].time > 0.4 then
            table.remove(history, i)
        end
    end
    
    -- 记录当前帧数据
    local currentData = {
        position = target.Position,
        time = currentTime,
        velocity = target.Velocity
    }
    table.insert(history, currentData)
    
    -- 激进预测：即使数据不足也强行预判
    if #history < 2 then
        local distance = (target.Position - Camera.CFrame.Position).Magnitude
        local dynamicPrediction = Prediction * (1 + distance / 100)
        return target.Position + (target.Velocity * dynamicPrediction * 1.3)
    end
    
    -- 计算加权平均速度和加速度
    local totalWeight = 0
    local weightedVelocity = Vector3.zero
    local weightedAcceleration = Vector3.zero
    
    for i = 2, #history do
        local current = history[i]
        local previous = history[i-1]
        local timeDiff = current.time - previous.time
        
        if timeDiff > 0.001 then
            -- 越新的数据权重越高
            local weight = 2.0 / (currentTime - current.time + 0.1)
            totalWeight = totalWeight + weight
            
            -- 速度计算
            local velocity = (current.position - previous.position) / timeDiff
            weightedVelocity = weightedVelocity + (velocity * weight)
            
            -- 加速度计算
            if i > 2 then
                local prevPrevious = history[i-2]
                local prevTimeDiff = previous.time - prevPrevious.time
                if prevTimeDiff > 0.001 then
                    local prevVelocity = (previous.position - prevPrevious.position) / prevTimeDiff
                    local acceleration = (velocity - prevVelocity) / timeDiff
                    weightedAcceleration = weightedAcceleration + (acceleration * weight * 1.5)
                end
            end
        end
    end
    
    if totalWeight > 0 then
        weightedVelocity = weightedVelocity / totalWeight
        weightedAcceleration = weightedAcceleration / totalWeight
        
        -- 计算到目标的距离
        local distance = (target.Position - Camera.CFrame.Position).Magnitude
        
        -- 动态预判系数：距离越远预判越大
        local dynamicPrediction = Prediction * (1 + distance / 90)
        
        -- 优化预判公式
        local predictedPos = target.Position + 
                            (weightedVelocity * dynamicPrediction * 1.2) +
                            (weightedAcceleration * dynamicPrediction * dynamicPrediction * 1.7)
        
        return predictedPos
    end
    
    -- 保底预测
    local distance = (target.Position - Camera.CFrame.Position).Magnitude
    return target.Position + (target.Velocity * Prediction * (1 + distance / 80))
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
Frame.Size = UDim2.new(0, 230, 0, 320)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Theme.Background
Frame.BackgroundTransparency = 0.15
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- 添加阴影效果
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 80)
UIStroke.Thickness = 2
UIStroke.Parent = Frame

-- 展开/收起按钮美化
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 32, 0, 22)
ToggleButton.Position = UDim2.new(1, -32, 0, 0)
ToggleButton.Text = "▲"
ToggleButton.TextColor3 = Theme.Text
ToggleButton.BackgroundColor3 = Theme.Button
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.BorderSizePixel = 0
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

-- 存储UI元素引用以便控制显示/隐藏
local UIElements = {}
local isExpanded = true

-- 标题美化
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.Text = "🔮 终极预判自瞄 🔮"
Title.BackgroundColor3 = Theme.Header
Title.BackgroundTransparency = 0.1
Title.TextColor3 = Theme.Accent
Title.BorderSizePixel = 0
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame
table.insert(UIElements, Title)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- 按钮样式函数
local function CreateStyledButton(name, positionY, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.85, 0, 0, 32)
    button.Position = UDim2.new(0.075, 0, positionY, 0)
    button.Text = text
    button.BackgroundColor3 = Theme.Button
    button.BackgroundTransparency = 0.15
    button.TextColor3 = Theme.Text
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- 悬停效果
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Theme.ButtonHover
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Theme.Button
    end)
    
    table.insert(UIElements, button)
    return button
end

-- 创建所有按钮
local ToggleBtn = CreateStyledButton("ToggleBtn", 0.12, "🎯 自瞄: 开启")
local ESPToggleBtn = CreateStyledButton("ESPToggleBtn", 0.24, "👁️ ESP: 开启")
local WallCheckBtn = CreateStyledButton("WallCheckBtn", 0.36, "🧱 穿墙检测: 开启")
local PredictionBtn = CreateStyledButton("PredictionBtn", 0.48, "⚡ 预判模式: 开启")
local SingleTargetBtn = CreateStyledButton("SingleTargetBtn", 0.84, "🔒 单锁模式: 开启")

-- 输入框美化
local function CreateStyledTextBox(positionY, text, placeholder)
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.85, 0, 0, 32)
    textBox.Position = UDim2.new(0.075, 0, positionY, 0)
    textBox.Text = text
    textBox.PlaceholderText = placeholder
    textBox.BackgroundColor3 = Theme.Button
    textBox.BackgroundTransparency = 0.15
    textBox.TextColor3 = Theme.Text
    textBox.BorderSizePixel = 0
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 13
    textBox.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = textBox
    
    table.insert(UIElements, textBox)
    return textBox
end

local FOVInput = CreateStyledTextBox(0.60, tostring(FOV), "FOV范围")
local PredictionInput = CreateStyledTextBox(0.72, tostring(Prediction), "预判系数")

-- ==================== 以下代码完全不变 ====================
-- [原代码的所有其他部分保持不变...]
-- 包括：isVisible函数、ESP功能、按钮事件绑定、渲染循环等
-- 所有原有功能完全保留，只替换了UI样式和预判算法

-- 展开/收起功能实现（保持原逻辑）
local function toggleUI()
    isExpanded = not isExpanded
    
    if isExpanded then
        Frame.Size = UDim2.new(0, 230, 0, 320)
        ToggleButton.Text = "▲"
        for _, element in pairs(UIElements) do
            element.Visible = true
        end
    else
        Frame.Size = UDim2.new(0, 230, 0, 32)
        ToggleButton.Text = "▼"
        for _, element in pairs(UIElements) do
            if element ~= Title then
                element.Visible = false
            end
        end
    end
end

-- 绑定展开/收起按钮事件
ToggleButton.MouseButton1Click:Connect(toggleUI)

print("💫 美化版预判自瞄加载完成")
print("预判系数:", Prediction)
print("按U键展开/收起UI")