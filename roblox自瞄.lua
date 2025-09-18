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
local TeamCheck = true   -- 队友检测默认开启

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
local ESPHighlights = {} -- 改为高亮轮廓
local ESPLabels = {}
local ESPConnections = {} -- 存储玩家连接

-- ==================== 队友检测功能 ====================
local function IsEnemy(player)
    if not TeamCheck then
        return true  -- 如果关闭队友检测，则所有玩家都是敌人
    end
    
    -- 检查是否有团队游戏机制
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    
    -- 如果没有团队机制，检查是否是朋友
    local success, isFriend = pcall(function()
        return player:IsFriendsWith(LocalPlayer.UserId)
    end)
    
    if success and isFriend then
        return false
    end
    
    -- 默认情况下，所有其他玩家都是敌人
    return true
end

-- ==================== 清理ESP资源 ====================
local function ClearESP()
    -- 清理所有高亮轮廓
    for _, highlight in pairs(ESPHighlights) do
        if highlight then
            pcall(function() highlight:Destroy() end)
        end
    end
    ESPHighlights = {}
    
    -- 清理所有标签
    for _, espData in pairs(ESPLabels) do
        if espData and espData.nameLabel then
            pcall(function() espData.nameLabel:Remove() end)
        end
        if espData and espData.healthLabel then
            pcall(function() espData.healthLabel:Remove() end)
        end
    end
    ESPLabels = {}
    
    -- 清理所有连接
    for player, connections in pairs(ESPConnections) do
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
    end
    ESPConnections = {}
end

-- ==================== 为角色创建ESP ====================
local function CreateESPForCharacter(player, character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not head then return end
    
    -- 创建高亮轮廓
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = CoreGui
    
    -- 创建名字和血量标签（分开上下排列）
    local nameLabel = Drawing.new("Text")
    nameLabel.Visible = false
    nameLabel.Color = Color3.fromRGB(255, 255, 255)
    nameLabel.Size = 14 -- 减小字体大小
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameLabel.ZIndex = 2
    
    local healthLabel = Drawing.new("Text")
    healthLabel.Visible = false
    healthLabel.Color = Color3.fromRGB(255, 100, 100)
    healthLabel.Size = 12 -- 减小字体大小
    healthLabel.Center = true
    healthLabel.Outline = true
    healthLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    healthLabel.ZIndex = 2
    
    -- 更新函数
    local function updateESP()
        if not character:IsDescendantOf(workspace) or humanoid.Health <= 0 then
            highlight.Enabled = false
            nameLabel.Visible = false
            healthLabel.Visible = false
            return
        end
        
        local headPos, headVisible = Camera:WorldToViewportPoint(head.Position)
        
        if headVisible then
            -- 更新高亮轮廓颜色（根据血量变化）
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            highlight.FillColor = Color3.fromRGB(
                255 * (1 - healthPercent),
                255 * healthPercent,
                0
            )
            highlight.Enabled = true
            
            -- 更新标签
            nameLabel.Text = player.Name
            nameLabel.Position = Vector2.new(headPos.X, headPos.Y - 30) -- 名字在上
            
            healthLabel.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            healthLabel.Position = Vector2.new(headPos.X, headPos.Y - 15) -- 血量在下
            
            nameLabel.Visible = true
            healthLabel.Visible = true
        else
            highlight.Enabled = false
            nameLabel.Visible = false
            healthLabel.Visible = false
        end
    end
    
    -- 存储ESP对象
    local espId = player.UserId
    ESPHighlights[espId] = highlight
    ESPLabels[espId] = {
        nameLabel = nameLabel, 
        healthLabel = healthLabel, 
        update = updateESP, 
        player = player
    }
    
    -- 初始更新
    updateESP()
    
    -- 监听人类状态变化
    local humanoidDiedConn = humanoid.Died:Connect(function()
        highlight.Enabled = false
        nameLabel.Visible = false
        healthLabel.Visible = false
    end)
    
    local humanoidHealthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health > 0 then
            updateESP()
        else
            highlight.Enabled = false
            nameLabel.Visible = false
            healthLabel.Visible = false
        end
    end)
    
    -- 存储连接
    if not ESPConnections[player] then
        ESPConnections[player] = {}
    end
    table.insert(ESPConnections[player], humanoidDiedConn)
    table.insert(ESPConnections[player], humanoidHealthConn)
end

-- ==================== ESP功能 ====================
local function UpdateESP()
    -- 先清理现有的ESP
    ClearESP()
    
    if not ESPEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            -- 为每个玩家创建连接来监听角色变化
            local connections = {}
            
            -- 监听玩家角色添加
            local characterAddedConn = player.CharacterAdded:Connect(function(character)
                task.wait(0.5) -- 等待角色完全加载
                if ESPEnabled and IsEnemy(player) then
                    CreateESPForCharacter(player, character)
                end
            end)
            
            table.insert(connections, characterAddedConn)
            
            -- 监听玩家角色移除
            local characterRemovingConn = player.CharacterRemoving:Connect(function()
                -- 只移除该玩家的ESP，而不是全部
                local espId = player.UserId
                if ESPHighlights[espId] then
                    pcall(function() ESPHighlights[espId]:Destroy() end)
                    ESPHighlights[espId] = nil
                end
                if ESPLabels[espId] then
                    pcall(function() 
                        ESPLabels[espId].nameLabel:Remove()
                        ESPLabels[espId].healthLabel:Remove()
                    end)
                    ESPLabels[espId] = nil
                end
            end)
            
            table.insert(connections, characterRemovingConn)
            
            -- 存储连接
            ESPConnections[player] = connections
            
            -- 如果玩家已经有角色，立即创建ESP
            if player.Character and ESPEnabled and IsEnemy(player) then
                CreateESPForCharacter(player, player.Character)
            end
        end
    end
end

-- ==================== 改进预判算法 ====================
local function CalculatePredictedPosition(target)
    if not target or not PredictionEnabled then
        return target and target.Position or nil
    end
    
    -- 获取目标头部
    local head = target.Parent:FindFirstChild("Head")
    if not head then
        return target.Position
    end
    
    -- 计算距离和飞行时间
    local distance = (head.Position - Camera.CFrame.Position).Magnitude
    local travelTime = distance / 1000
    
    -- 核心修改：预判系数直接控制偏移量
    -- Prediction=0: 无预判（瞄准当前位置）
    -- Prediction>0: 正向预判（瞄准移动方向前方）
    -- Prediction<0: 反向预判（瞄准移动方向后方）
    local velocityOffset = target.Velocity * travelTime * Prediction
    
    -- 返回预判位置（头部位置 + 速度方向偏移）
    return head.Position + velocityOffset
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

-- ==================== 改为视角对准的目标选择 ====================
local function FindTargetInView()
    local bestTarget = nil
    local closestAngle = math.rad(FOV / 2) -- FOV范围内的角度
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsEnemy(player) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- 计算视角角度
                local cameraDirection = Camera.CFrame.LookVector
                local targetDirection = (head.Position - Camera.CFrame.Position).Unit
                local dotProduct = cameraDirection:Dot(targetDirection)
                local angle = math.acos(math.clamp(dotProduct, -1, 1))
                
                -- 检查是否在FOV范围内
                if angle <= closestAngle then
                    -- 穿墙检测
                    if WallCheck then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (head.Position - rayOrigin).Unit * (head.Position - rayOrigin).Magnitude
                        
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
                    
                    closestAngle = angle
                    bestTarget = head -- 瞄准头部
                end
            end
        end
    end
    
    return bestTarget
end

-- ==================== 名字锁定功能 ====================
local function LockTargetByName(playerName)
    for _, player in pairs(Players:GetPlayers()) do
        if (player.Name:lower():find(playerName:lower()) or player.DisplayName:lower():find(playerName:lower())) and IsEnemy(player) then
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    LockedTarget = head
                    return true
                end
            end
        end
    end
    LockedTarget = nil
    return false
end

-- ==================== 检查目标是否有效 ====================
local function IsTargetValid(target)
    if not target then return false end
    
    -- 检查目标是否仍然存在
    if not target:IsDescendantOf(workspace) then
        return false
    end
    
    -- 检查目标的生命值
    local humanoid = target.Parent:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    return true
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

-- 添加滚动功能
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -42)
ScrollFrame.Position = UDim2.new(0, 5, 0, 37)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 550)
ScrollFrame.Parent = Frame

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
    button.Parent = ScrollFrame
    
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
    textBox.Parent = ScrollFrame
    
    table.insert(UIElements, textBox)
    return textBox
end

-- 创建所有功能按钮
local ToggleBtn = CreateStyledButton("ToggleBtn", 0.10, "🎯 自瞄: 开启")
local AimModeBtn = CreateStyledButton("AimModeBtn", 0.20, "🔧 瞄准模式: 相机")
local ESPToggleBtn = CreateStyledButton("ESPToggleBtn", 0.30, "👁️ ESP: 开启")
local WallCheckBtn = CreateStyledButton("WallCheckBtn", 0.40, "🧱 穿墙检测: 开启")
local TeamCheckBtn = CreateStyledButton("TeamCheckBtn", 0.50, "🎯 队友检测: 开启")
local PredictionBtn = CreateStyledButton("PredictionBtn", 0.60, "⚡ 预判模式: 开启")
local SingleTargetBtn = CreateStyledButton("SingleTargetBtn", 0.70, "🔒 单锁模式: 关闭")
local FOVCircleBtn = CreateStyledButton("FOVCircleBtn", 0.80, "⭕ FOV圆圈: 开启")

local FOVInput = CreateStyledTextBox(0.90, tostring(FOV), "FOV范围")
local PredictionInput = CreateStyledTextBox(1.00, tostring(Prediction), "预判系数")
local TargetNameInput = CreateStyledTextBox(1.10, "", "输入玩家名字锁定")

-- 更新按钮状态
local function UpdateButtonText(button, text, state)
    button.Text = text .. (state and "开启" or "关闭")
    button.BackgroundColor3 = state and Theme.Success or Theme.Warning
end

UpdateButtonText(ToggleBtn, "🎯 自瞄: ", Enabled)
UpdateButtonText(ESPToggleBtn, "👁️ ESP: ", ESPEnabled)
UpdateButtonText(WallCheckBtn, "🧱 穿墙检测: ", WallCheck)
UpdateButtonText(TeamCheckBtn, "🎯 队友检测: ", TeamCheck)
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
    UpdateESP() -- 立即更新ESP状态
end)

WallCheckBtn.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    UpdateButtonText(WallCheckBtn, "🧱 穿墙检测: ", WallCheck)
end)

TeamCheckBtn.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    UpdateButtonText(TeamCheckBtn, "🎯 队友检测: ", TeamCheck)
    UpdateESP() -- 更新ESP显示
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

-- 修复展开/收起功能
ToggleButton.MouseButton1Click:Connect(function()
    isExpanded = not isExpanded
    for _, element in pairs(UIElements) do
        if element ~= Title then
            element.Visible = isExpanded
        end
    end
    ToggleButton.Text = isExpanded and "▲" or "▼"
    Frame.Size = isExpanded and UDim2.new(0, 280, 0, 420) or UDim2.new(0, 280, 0, 32)
    ScrollFrame.Visible = isExpanded
end)

-- ==================== 主循环 ====================
RunService.RenderStepped:Connect(function()
    Circle.Position = ScreenCenter
    Circle.Radius = FOV
    
    -- 更新ESP
    for _, espData in pairs(ESPLabels) do
        if espData and espData.update then
            espData.update()
        end
    end
    
    -- 自瞄逻辑
    if not Enabled then return end
    
    -- 检查当前锁定目标是否有效（生命值>0）
    if LockedTarget and LockSingleTarget then
        if not IsTargetValid(LockedTarget) then
            LockedTarget = nil  -- 目标无效，解除锁定
        end
    end
    
    if not LockedTarget or not LockSingleTarget then
        LockedTarget = FindTargetInView() -- 改为使用视角对准的目标选择
    end
    
    if LockedTarget then
        local predictedPosition = CalculatePredictedPosition(LockedTarget)
        AimAtPosition(predictedPosition)
    end
end)

-- 玩家加入/离开事件
Players.PlayerAdded:Connect(function(player)
    task.wait(1) -- 等待玩家完全加入
    UpdateESP()
end)

Players.PlayerRemoving:Connect(function(player)
    -- 清理该玩家的ESP资源
    local espId = player.UserId
    if ESPHighlights[espId] then
        pcall(function() ESPHighlights[espId]:Destroy() end)
        ESPHighlights[espId] = nil
    end
    if ESPLabels[espId] then
        pcall(function() 
            ESPLabels[espId].nameLabel:Remove()
            ESPLabels[espId].healthLabel:Remove()
        end)
        ESPLabels[espId] = nil
    end
    
    -- 清理连接
    if ESPConnections[player] then
        for _, connection in ipairs(ESPConnections[player]) do
            pcall(function() connection:Disconnect() end)
        end
        ESPConnections[player] = nil
    end
end)

-- 初始更新
UpdateESP()

print("🔥 终极自瞄系统加载完成！")
print("快捷键: F-开关自瞄, T-锁定目标, V-开关ESP, U-隐藏/显示UI")
print("ESP和穿墙检测已默认开启")