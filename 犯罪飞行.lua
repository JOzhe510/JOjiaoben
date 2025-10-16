--[[
═══════════════════════════════════════════════════════════
    🎭 Ragdoll 伪装飞行系统
    
    核心思路：
    1. 使用 BodyGyro + BodyPosition（和游戏 Ragdoll 相同）
    2. 伪装成"持续的 Ragdoll 状态"
    3. 低频率 firesignal（防止崩溃）
    4. 服务器会认为这是正常的摔倒物理
═══════════════════════════════════════════════════════════
--]]

-- ==================== 服务和变量 ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ==================== 飞行配置 ====================
local Config = {
    Speed = 50,              -- 飞行速度
    IsFlying = false,        -- 飞行状态
    
    -- 防崩溃配置
    StateUpdateInterval = 0.15,  -- firesignal 调用间隔（秒）
    LastStateUpdate = 0,
    
    -- BodyMovers
    BodyGyro = nil,
    BodyPosition = nil,
    
    -- 循环
    FlyLoop = nil,
    StateLoop = nil,
}

-- ==================== 查找 ChangeState 事件 ====================
local function findChangeStateEvent()
    local searchPaths = {
        {"ReplicatedStorage", "Events", "ChangeState"},
        {"ReplicatedStorage", "ChangeState"},
        {"ReplicatedStorage", "Remotes", "ChangeState"},
        {"ReplicatedStorage", "Remote", "ChangeState"},
    }
    
    for _, path in ipairs(searchPaths) do
        local success, result = pcall(function()
            local obj = game:GetService(path[1])
            for i = 2, #path do
                local child = obj:FindFirstChild(path[i])
                if not child then return nil end
                obj = child
            end
            return obj
        end)
        
        if success and result and result:IsA("RemoteEvent") then
            return result, table.concat(path, ".")
        end
    end
    
    return nil, "未找到"
end

-- ==================== 启动飞行 ====================
local function StartFly()
    if Config.IsFlying then return end
    Config.IsFlying = true
    
    print("🚀 启动 Ragdoll 伪装飞行...")
    
    -- 获取角色组件
    Character = LocalPlayer.Character
    if not Character then 
        print("❌ 未找到角色")
        Config.IsFlying = false
        return 
    end
    
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
    
    if not Humanoid or not HumanoidRootPart then 
        print("❌ 缺少必要组件")
        Config.IsFlying = false
        return 
    end
    
    -- 清理旧的 BodyMovers
    for _, v in pairs(HumanoidRootPart:GetChildren()) do
        if v:IsA("BodyGyro") or v:IsA("BodyPosition") then
            v:Destroy()
        end
    end
    
    -- 创建 BodyGyro（稳定旋转）
    Config.BodyGyro = Instance.new("BodyGyro")
    Config.BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    Config.BodyGyro.P = 3000
    Config.BodyGyro.D = 500
    Config.BodyGyro.Parent = HumanoidRootPart
    
    -- 创建 BodyPosition（控制位置）
    Config.BodyPosition = Instance.new("BodyPosition")
    Config.BodyPosition.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Config.BodyPosition.P = 5000
    Config.BodyPosition.D = 200
    Config.BodyPosition.Parent = HumanoidRootPart
    
    -- 设置 PlatformStand（让角色失去行走能力）
    Humanoid.PlatformStand = true
    
    print("✅ BodyGyro + BodyPosition 已创建（伪装 Ragdoll）")
    
    -- 查找 ChangeState 事件
    local changeStateEvent, eventPath = findChangeStateEvent()
    local hasFireSignal = changeStateEvent ~= nil
    
    if hasFireSignal then
        print("✅ 找到 ChangeState: " .. eventPath)
        print("🛡️ 将使用低频 firesignal 欺骗（" .. Config.StateUpdateInterval .. "s 间隔）")
    else
        print("⚠️ 未找到 ChangeState，仅使用物理控制")
    end
    
    -- 飞行移动循环
    Config.FlyLoop = RunService.Heartbeat:Connect(function(deltaTime)
        if not Config.IsFlying then return end
        
        -- 检查角色有效性
        Character = LocalPlayer.Character
        if not Character then
            StopFly()
            return
        end
        
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")
        
        if not Humanoid or not HumanoidRootPart or not Config.BodyPosition or not Config.BodyGyro then
            StopFly()
            return
        end
        
        -- 获取摄像机方向
        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        
        -- 获取移动输入
        local moveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + (cameraCFrame.LookVector * Config.Speed * deltaTime)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - (cameraCFrame.LookVector * Config.Speed * deltaTime)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - (cameraCFrame.RightVector * Config.Speed * deltaTime)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + (cameraCFrame.RightVector * Config.Speed * deltaTime)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + (Vector3.new(0, 1, 0) * Config.Speed * deltaTime)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - (Vector3.new(0, 1, 0) * Config.Speed * deltaTime)
        end
        
        -- 更新目标位置
        local targetPosition = HumanoidRootPart.Position + moveVector
        Config.BodyPosition.Position = targetPosition
        
        -- 更新旋转（面向摄像机方向）
        Config.BodyGyro.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + cameraCFrame.LookVector)
    end)
    
    -- 状态欺骗循环（低频）
    if hasFireSignal then
        Config.StateLoop = RunService.Heartbeat:Connect(function()
            if not Config.IsFlying then return end
            
            local currentTime = tick()
            
            -- 限制调用频率（防止崩溃）
            if currentTime - Config.LastStateUpdate >= Config.StateUpdateInterval then
                Config.LastStateUpdate = currentTime
                
                pcall(function()
                    -- 使用 Ragdoll 状态（最像摔倒）
                    firesignal(changeStateEvent.OnClientEvent,
                        Enum.HumanoidStateType.Ragdoll,  -- 或 FallingDown
                        5
                    )
                end)
            end
        end)
    end
    
    print("🎭 Ragdoll 伪装飞行已启动！")
    print("📌 操作: WASD移动 | 空格上升 | Shift下降")
end

-- ==================== 停止飞行 ====================
function StopFly()
    if not Config.IsFlying then return end
    Config.IsFlying = false
    
    print("🛑 停止飞行...")
    
    -- 断开循环
    if Config.FlyLoop then
        Config.FlyLoop:Disconnect()
        Config.FlyLoop = nil
    end
    
    if Config.StateLoop then
        Config.StateLoop:Disconnect()
        Config.StateLoop = nil
    end
    
    -- 清理 BodyMovers
    if Config.BodyGyro then
        Config.BodyGyro:Destroy()
        Config.BodyGyro = nil
    end
    
    if Config.BodyPosition then
        Config.BodyPosition:Destroy()
        Config.BodyPosition = nil
    end
    
    -- 恢复角色
    Character = LocalPlayer.Character
    if Character then
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
    
    print("✅ 飞行已停止，角色已恢复")
end

-- ==================== 创建 UI ====================
local function CreateUI()
    -- 检查是否已存在
    local existingUI = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("RagdollFlyUI")
    if existingUI then
        existingUI:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RagdollFlyUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui")
    
    -- 主框架
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 380, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- 圆角
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- 标题
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Title.BorderSizePixel = 0
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎭 Ragdoll 伪装飞行"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- 副标题
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -20, 0, 40)
    Subtitle.Position = UDim2.new(0, 10, 0, 55)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "🛡️ 伪装策略: BodyGyro + BodyPosition"
    Subtitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    Subtitle.TextSize = 13
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = MainFrame
    
    -- 状态标签
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -20, 0, 50)
    StatusLabel.Position = UDim2.new(0, 10, 0, 95)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    StatusLabel.BorderSizePixel = 0
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.Text = "⏸️ 状态: 未启动\n💡 检测风险: 极低（伪装 Ragdoll）"
    StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    StatusLabel.TextSize = 14
    StatusLabel.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusLabel
    
    -- 速度滑块标签
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
    SpeedLabel.Position = UDim2.new(0, 10, 0, 155)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Font = Enum.Font.GothamMedium
    SpeedLabel.Text = "⚡ 飞行速度: 50"
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.TextSize = 14
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = MainFrame
    
    -- 速度滑块
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Size = UDim2.new(1, -20, 0, 30)
    SpeedSlider.Position = UDim2.new(0, 10, 0, 180)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Parent = MainFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SpeedSlider
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 30, 1, 0)
    SliderButton.Position = UDim2.new((Config.Speed - 10) / 190, -15, 0, 0)
    SliderButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    SliderButton.BorderSizePixel = 0
    SliderButton.Text = ""
    SliderButton.Parent = SpeedSlider
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = SliderButton
    
    -- 滑块逻辑
    local dragging = false
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = SpeedSlider.AbsolutePosition.X
            local sliderSize = SpeedSlider.AbsoluteSize.X
            local relativePos = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            
            Config.Speed = math.floor(10 + (relativePos * 190))
            SpeedLabel.Text = "⚡ 飞行速度: " .. Config.Speed
            SliderButton.Position = UDim2.new(relativePos, -15, 0, 0)
        end
    end)
    
    -- 开关按钮
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(1, -20, 0, 40)
    ToggleButton.Position = UDim2.new(0, 10, 0, 225)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "🚀 启动飞行"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    ToggleButton.Parent = MainFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleButton
    
    -- 按钮点击
    ToggleButton.MouseButton1Click:Connect(function()
        if Config.IsFlying then
            StopFly()
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            ToggleButton.Text = "🚀 启动飞行"
            StatusLabel.Text = "⏸️ 状态: 未启动\n💡 检测风险: 极低（伪装 Ragdoll）"
        else
            StartFly()
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            ToggleButton.Text = "🛑 停止飞行"
            StatusLabel.Text = "✅ 状态: 飞行中\n🎭 伪装: Ragdoll 物理状态"
        end
    end)
    
    -- 拖动功能
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
    
    print("✅ UI 已创建")
end

-- ==================== 角色重生处理 ====================
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    if Config.IsFlying then
        StopFly()
        print("🔄 角色重生，飞行已停止")
    end
end)

-- ==================== 初始化 ====================
print("═══════════════════════════════════════════════")
print("🎭 Ragdoll 伪装飞行系统已加载")
print("📌 特点:")
print("   • 使用 BodyGyro + BodyPosition（和游戏 Ragdoll 相同）")
print("   • 低频 firesignal（防崩溃）")
print("   • 伪装成持续摔倒状态")
print("═══════════════════════════════════════════════")

CreateUI()

