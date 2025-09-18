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

-- ==================== 参数设置 ====================
local FOV = 90
local Prediction = 0.15
local Smoothness = 0.7
local Enabled = true
local LockedTarget = nil
local LockSingleTarget = false
local ESPEnabled = true  -- ESP默认开启
local WallCheck = true   -- 穿墙检测默认开启
local PredictionEnabled = true
local AimMode = "Camera"

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

local TargetHistory = {}
local ESPBoxes = {}

-- ==================== ESP功能 ====================
local function UpdateESP()
    for _, box in pairs(ESPBoxes) do
        if box then
            box:Remove()
        end
    end
    ESPBoxes = {}

    if not ESPEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESP_" .. player.Name
                box.Adornee = rootPart
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Size = Vector3.new(4, 6, 4)
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.Transparency = 0.3
                box.Parent = rootPart
                
                table.insert(ESPBoxes, box)
            end
        end
    end
end

-- ==================== 修复预判算法 ====================
local function CalculatePredictedPosition(target)
    if not target or not PredictionEnabled then
        return target and target.Position or nil
    end
    
    local distance = (target.Position - Camera.CFrame.Position).Magnitude
    local travelTime = distance / 1000
    
    return target.Position + (target.Velocity * travelTime * Prediction * 2)
end

-- ==================== 双模式瞄准系统 ====================
local function AimAtPosition(position)
    if not position then return end
    
    if AimMode == "Camera" then
        local cameraPos = Camera.CFrame.Position
        local direction = (position - cameraPos).Unit
        local currentDirection = Camera.CFrame.LookVector
        local newDirection = (currentDirection * (1 - Smoothness) + direction * Smoothness).Unit
        
        Camera.CFrame = CFrame.new(cameraPos, cameraPos + newDirection)
    else
        -- 视角锁定模式
        local screenPos, visible = Camera:WorldToViewportPoint(position)
        if visible then
            local mousePos = UIS:GetMouseLocation()
            local targetPos = Vector2.new(screenPos.X, screenPos.Y)
            local delta = (targetPos - mousePos) * Smoothness * 0.5
            
            pcall(function()
                mousemoverel(delta.X, delta.Y)
            end)
        end
    end
end

-- ==================== 修复穿墙检测 ====================
local function FindBestTarget()
    local bestTarget = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local rayOrigin = Camera.CFrame.Position
                local rayDirection = (rootPart.Position - rayOrigin).Unit * 200
                
                -- 修复穿墙检测
                if WallCheck then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    raycastParams.IgnoreWater = true
                    
                    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    if raycastResult then
                        local hitPart = raycastResult.Instance
                        if not hitPart:IsDescendantOf(player.Character) then
                            continue  -- 被墙壁阻挡，跳过
                        end
                    end
                end
                
                local screenPosition, visible = Camera:WorldToViewportPoint(rootPart.Position)
                
                if visible then
                    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        bestTarget = rootPart
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- ==================== 名字锁定功能 ====================
local function LockTargetByName(playerName)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(playerName:lower()) or player.DisplayName:lower():find(playerName:lower()) then
            if player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    LockedTarget = rootPart
                    return true
                end
            end
        end
    end
    LockedTarget = nil
    return false
end

-- ==================== 完整UI界面 ====================
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
Frame.Size = UDim2.new(0, 280, 0, 420)
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

local UIElements = {}
local isExpanded = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.Text = "🔮 终极自瞄系统 🔮"
Title.BackgroundColor3 = Theme.Header
Title.BackgroundTransparency = 0.05
Title.TextColor3 = Theme.Accent
Title.BorderSizePixel = 0
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame
table.insert(UIElements, Title)

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
    
    table.insert(UIElements, textBox)
    return textBox
end

-- 创建所有功能按钮
local ToggleBtn = CreateStyledButton("ToggleBtn", 0.10, "🎯 自瞄: 开启")
local AimModeBtn = CreateStyledButton("AimModeBtn", 0.20, "🔧 瞄准模式: 相机")
local ESPToggleBtn = CreateStyledButton("ESPToggleBtn", 0.30, "👁️ ESP: 开启")
local WallCheckBtn = CreateStyledButton("WallCheckBtn", 0.40, "🧱 穿墙检测: 开启")
local PredictionBtn = CreateStyledButton("PredictionBtn", 0.50, "⚡ 预判模式: 开启")
local SingleTargetBtn = CreateStyledButton("SingleTargetBtn", 0.60, "🔒 单锁模式: 关闭")
local FOVCircleBtn = CreateStyledButton("FOVCircleBtn", 0.70, "⭕ FOV圆圈: 开启")

local FOVInput = CreateStyledTextBox(0.80, tostring(FOV), "FOV范围")
local PredictionInput = CreateStyledTextBox(0.90, tostring(Prediction), "预判系数")
local TargetNameInput = CreateStyledTextBox(1.00, "", "输入玩家名字锁定")

-- 更新按钮状态
local function UpdateButtonText(button, text, state)
    button.Text = text .. (state and "开启" or "关闭")
    button.BackgroundColor3 = state and Theme.Success or Theme.Warning
end

UpdateButtonText(ToggleBtn, "🎯 自瞄: ", Enabled)
UpdateButtonText(ESPToggleBtn, "👁️ ESP: ", ESPEnabled)
UpdateButtonText(WallCheckBtn, "🧱 穿墙检测: ", WallCheck)
UpdateButtonText(PredictionBtn, "⚡ 预判模式: ", PredictionEnabled)
UpdateButtonText(SingleTargetBtn, "🔒 单锁模式: ", LockSingleTarget)
UpdateButtonText(FOVCircleBtn, "⭕ FOV圆圈: ", Circle.Visible)

-- 按钮事件
ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    UpdateButtonText(ToggleBtn, "🎯 自瞄: ", Enabled)
end)

AimModeBtn.MouseButton1Click:Connect(function()
    AimMode = AimMode == "Camera" and "Viewport" or "Camera"
    AimModeBtn.Text = "🔧 瞄准模式: " .. (AimMode == "Camera" and "相机" or "视角")
end)

ESPToggleBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    UpdateButtonText(ESPToggleBtn, "👁️ ESP: ", ESPEnabled)
    UpdateESP()
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

FOVCircleBtn.MouseButton1Click:Connect(function()
    Circle.Visible = not Circle.Visible
    UpdateButtonText(FOVCircleBtn, "⭕ FOV圆圈: ", Circle.Visible)
end)

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

TargetNameInput.FocusLost:Connect(function()
    if TargetNameInput.Text ~= "" then
        if LockTargetByName(TargetNameInput.Text) then
            TargetNameInput.BackgroundColor3 = Theme.Success
        else
            TargetNameInput.BackgroundColor3 = Theme.Warning
        end
    end
end)

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
        isExpanded = not isExpanded
        Frame.Visible = isExpanded
        ToggleButton.Text = isExpanded and "▲" or "▼"
    elseif input.KeyCode == Enum.KeyCode.F then
        Enabled = not Enabled
        UpdateButtonText(ToggleBtn, "🎯 自瞄: ", Enabled)
    elseif input.KeyCode == Enum.KeyCode.T and TargetNameInput.Text ~= "" then
        LockTargetByName(TargetNameInput.Text)
    elseif input.KeyCode == Enum.KeyCode.V then
        ESPEnabled = not ESPEnabled
        UpdateButtonText(ESPToggleBtn, "👁️ ESP: ", ESPEnabled)
        UpdateESP()
    end
end)

-- 初始化ESP
UpdateESP()

print("🔥 终极自瞄系统加载完成！")
print("快捷键: F-开关自瞄, T-锁定目标, V-开关ESP, U-隐藏/显示UI")
print("ESP和穿墙检测已默认开启")