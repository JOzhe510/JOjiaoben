local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 飞行相关变量
local flySpeed = 50
local flyConnection = nil
local isFlying = false
local flyBodyVelocity = nil
local flyBodyGyro = nil

-- 平台相关变量
local platformPart = nil
local platformConnection = nil
local isPlatformActive = false
local platformHeightOffset = 4

-- UI部分保持不变（只修改功能部分）
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VoidTeleportUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 350)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -70, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "飞行功能"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 50, 0, 25)
closeButton.Position = UDim2.new(1, -60, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "关闭UI"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 12
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local flyToggleButton = Instance.new("TextButton")
flyToggleButton.Name = "FlyToggleButton"
flyToggleButton.Size = UDim2.new(0, 280, 0, 60)
flyToggleButton.Position = UDim2.new(0.5, -140, 0.1, 0)
flyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
flyToggleButton.BorderSizePixel = 0
flyToggleButton.Text = "开启飞行"
flyToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyToggleButton.Font = Enum.Font.GothamBold
flyToggleButton.TextSize = 18
flyToggleButton.Parent = mainFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 10)
flyCorner.Parent = flyToggleButton

local platformToggleButton = Instance.new("TextButton")
platformToggleButton.Name = "PlatformToggleButton"
platformToggleButton.Size = UDim2.new(0, 280, 0, 40)
platformToggleButton.Position = UDim2.new(0.5, -140, 0.3, 0)
platformToggleButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
platformToggleButton.BorderSizePixel = 0
platformToggleButton.Text = "开启平台"
platformToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
platformToggleButton.Font = Enum.Font.GothamBold
platformToggleButton.TextSize = 16
platformToggleButton.Parent = mainFrame

local platformCorner = Instance.new("UICorner")
platformCorner.CornerRadius = UDim.new(0, 8)
platformCorner.Parent = platformToggleButton

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(0, 280, 0, 25)
speedLabel.Position = UDim2.new(0.5, -140, 0.45, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "飞行速度: 50"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.Parent = mainFrame

local speedInputFrame = Instance.new("Frame")
speedInputFrame.Name = "SpeedInputFrame"
speedInputFrame.Size = UDim2.new(0, 280, 0, 35)
speedInputFrame.Position = UDim2.new(0.5, -140, 0.55, 0)
speedInputFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
speedInputFrame.BorderSizePixel = 0
speedInputFrame.Parent = mainFrame

local speedInputCorner = Instance.new("UICorner")
speedInputCorner.CornerRadius = UDim.new(0, 8)
speedInputCorner.Parent = speedInputFrame

local speedTextBox = Instance.new("TextBox")
speedTextBox.Name = "SpeedTextBox"
speedTextBox.Size = UDim2.new(0.6, 0, 0.7, 0)
speedTextBox.Position = UDim2.new(0.05, 0, 0.15, 0)
speedTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedTextBox.BorderSizePixel = 0
speedTextBox.Text = "50"
speedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedTextBox.Font = Enum.Font.Gotham
speedTextBox.TextSize = 14
speedTextBox.PlaceholderText = "输入速度 (1-200)"
speedTextBox.Parent = speedInputFrame

local textBoxCorner = Instance.new("UICorner")
textBoxCorner.CornerRadius = UDim.new(0, 6)
textBoxCorner.Parent = speedTextBox

local applySpeedButton = Instance.new("TextButton")
applySpeedButton.Name = "ApplySpeedButton"
applySpeedButton.Size = UDim2.new(0.3, 0, 0.7, 0)
applySpeedButton.Position = UDim2.new(0.67, 0, 0.15, 0)
applySpeedButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
applySpeedButton.BorderSizePixel = 0
applySpeedButton.Text = "应用"
applySpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applySpeedButton.Font = Enum.Font.Gotham
applySpeedButton.TextSize = 13
applySpeedButton.Parent = speedInputFrame

local applyCorner = Instance.new("UICorner")
applyCorner.CornerRadius = UDim.new(0, 6)
applyCorner.Parent = applySpeedButton

local deleteButton = Instance.new("TextButton")
deleteButton.Name = "DeleteButton"
deleteButton.Size = UDim2.new(0, 120, 0, 35)
deleteButton.Position = UDim2.new(0.5, -60, 0.85, 0)
deleteButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
deleteButton.BorderSizePixel = 0
deleteButton.Text = "删除UI"
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Font = Enum.Font.Gotham
deleteButton.TextSize = 13
deleteButton.Parent = mainFrame

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 6)
deleteCorner.Parent = deleteButton

local openUIButton = Instance.new("TextButton")
openUIButton.Name = "OpenUIButton"
openUIButton.Size = UDim2.new(0, 80, 0, 35)
openUIButton.Position = UDim2.new(0, 10, 0, 10)
openUIButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
openUIButton.BorderSizePixel = 0
openUIButton.Text = "飞行功能"
openUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openUIButton.Font = Enum.Font.Gotham
openUIButton.TextSize = 12
openUIButton.Visible = false
openUIButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openUIButton

-- ==================== 真正的飞行功能 ====================

local function CleanupFlight()
    -- 清理飞行相关的所有东西
    if flyBodyVelocity and flyBodyVelocity.Parent then
        flyBodyVelocity:Destroy()
    end
    if flyBodyGyro and flyBodyGyro.Parent then
        flyBodyGyro:Destroy()
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    flyBodyVelocity = nil
    flyBodyGyro = nil
end

local function StartRealFly()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- 先清理旧的
    CleanupFlight()
    
    -- 设置角色状态
    humanoid.PlatformStand = true
    humanoid.AutoRotate = false
    
    -- 创建BodyVelocity用于移动
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    flyBodyVelocity.P = 1250
    flyBodyVelocity.Parent = rootPart
    
    -- 创建BodyGyro用于控制朝向
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
    flyBodyGyro.P = 2000
    flyBodyGyro.D = 500
    flyBodyGyro.CFrame = rootPart.CFrame
    flyBodyGyro.Parent = rootPart
    
    -- 飞行循环
    flyConnection = RunService.Heartbeat:Connect(function()
        if not character or not rootPart or not humanoid then
            CleanupFlight()
            return
        end
        
        -- 获取移动方向和相机朝向
        local moveDirection = humanoid.MoveDirection
        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        
        -- 计算飞行速度向量
        if moveDirection.Magnitude > 0 then
            -- 根据相机方向移动
            local velocity = (cameraCFrame:VectorToObjectSpace(moveDirection) * flySpeed)
            flyBodyVelocity.Velocity = velocity
        else
            -- 不移动时停止
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- 控制朝向（看向相机方向）
        local lookVector = cameraCFrame.LookVector
        flyBodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
    end)
end

local function StopRealFly()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
        end
    end
    
    CleanupFlight()
end

-- ==================== 平台功能优化 ====================

local function StartPlatform()
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- 清理旧的平台
    if platformPart then
        platformPart:Destroy()
    end
    
    if platformConnection then
        platformConnection:Disconnect()
        platformConnection = nil
    end
    
    -- 创建初始平台
    platformPart = Instance.new("Part")
    platformPart.Name = "FlightPlatform"
    platformPart.Size = Vector3.new(8, 0.5, 8)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.Material = Enum.Material.Neon
    platformPart.BrickColor = BrickColor.new("Bright violet")
    platformPart.Transparency = 0.3
    platformPart.Parent = workspace
    
    -- 平台跟随循环
    platformConnection = RunService.Heartbeat:Connect(function()
        if not character or not rootPart then
            StopPlatform()
            return
        end
        
        -- 更新平台位置（保持在玩家脚下）
        local targetPosition = rootPart.Position - Vector3.new(0, 3, 0)
        platformPart.CFrame = CFrame.new(targetPosition)
        
        -- 添加向上的力让玩家浮在平台上
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        -- 轻推玩家向上防止掉下去
        rootPart.Velocity = Vector3.new(rootPart.Velocity.X, 5, rootPart.Velocity.Z)
    end)
end

local function StopPlatform()
    if platformConnection then
        platformConnection:Disconnect()
        platformConnection = nil
    end
    
    if platformPart then
        platformPart:Destroy()
        platformPart = nil
    end
    
    -- 恢复角色状态
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and not isFlying then
            humanoid.PlatformStand = false
        end
    end
end

-- ==================== UI事件绑定 ====================

local function setupButtonHover(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = originalColor * 1.2
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
end

setupButtonHover(closeButton)
setupButtonHover(flyToggleButton)
setupButtonHover(platformToggleButton)
setupButtonHover(deleteButton)
setupButtonHover(openUIButton)
setupButtonHover(applySpeedButton)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openUIButton.Visible = true
end)

openUIButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openUIButton.Visible = false
end)

deleteButton.MouseButton1Click:Connect(function()
    if isFlying then
        StopRealFly()
    end
    if isPlatformActive then
        StopPlatform()
    end
    screenGui:Destroy()
end)

applySpeedButton.MouseButton1Click:Connect(function()
    local inputSpeed = tonumber(speedTextBox.Text)
    if inputSpeed and inputSpeed >= 1 and inputSpeed <= 200 then
        flySpeed = inputSpeed
        speedLabel.Text = "飞行速度: " .. flySpeed
        speedTextBox.Text = tostring(flySpeed)
    else
        speedTextBox.Text = tostring(flySpeed)
    end
end)

speedTextBox.FocusLost:Connect(function(enterPressed)
    local inputSpeed = tonumber(speedTextBox.Text)
    if inputSpeed and inputSpeed >= 1 and inputSpeed <= 200 then
        flySpeed = inputSpeed
        speedLabel.Text = "飞行速度: " .. flySpeed
    else
        speedTextBox.Text = tostring(flySpeed)
    end
end)

-- 飞行按钮
flyToggleButton.MouseButton1Click:Connect(function()
    if isFlying then
        StopRealFly()
        flyToggleButton.Text = "开启飞行"
        flyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        isFlying = false
    else
        -- 如果平台开着，先关掉
        if isPlatformActive then
            StopPlatform()
            platformToggleButton.Text = "开启平台"
            platformToggleButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
            isPlatformActive = false
        end
        
        StartRealFly()
        flyToggleButton.Text = "关闭飞行"
        flyToggleButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        isFlying = true
    end
end)

-- 平台按钮
platformToggleButton.MouseButton1Click:Connect(function()
    if isPlatformActive then
        StopPlatform()
        platformToggleButton.Text = "开启平台"
        platformToggleButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
        isPlatformActive = false
    else
        -- 如果飞行开着，先关掉
        if isFlying then
            StopRealFly()
            flyToggleButton.Text = "开启飞行"
            flyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            isFlying = false
        end
        
        StartPlatform()
        platformToggleButton.Text = "关闭平台"
        platformToggleButton.BackgroundColor3 = Color3.fromRGB(200, 120, 80)
        isPlatformActive = true
    end
end)

-- 角色重生时自动停止功能
player.CharacterAdded:Connect(function()
    if isFlying then
        isFlying = false
        flyToggleButton.Text = "开启飞行"
        flyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    end
    
    if isPlatformActive then
        isPlatformActive = false
        platformToggleButton.Text = "开启平台"
        platformToggleButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
    end
    
    CleanupFlight()
    StopPlatform()
end)

screenGui.Parent = playerGui

print("真正的飞行控制面板已加载！")
print("现在飞行是真实的，其他玩家也能看到！")