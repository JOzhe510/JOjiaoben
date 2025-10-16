local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CFSpeed = 50
local RagdollDuration = 5  -- 默认布偶状态持续时间
local CFLoop = nil
local isFlying = false
local ChangeState = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ChangeState")
local stateLoop = nil

-- 添加安全检查
local function SafeDisconnect(connection)
    if connection and typeof(connection) == "RBXScriptConnection" then
        connection:Disconnect()
    end
    return nil
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VoidTeleportUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 320) -- 增加高度以容纳新控件
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -160)
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

-- 布偶状态持续时间设置
local ragdollLabel = Instance.new("TextLabel")
ragdollLabel.Name = "RagdollLabel"
ragdollLabel.Size = UDim2.new(0, 280, 0, 25)
ragdollLabel.Position = UDim2.new(0.5, -140, 0.35, 0)
ragdollLabel.BackgroundTransparency = 1
ragdollLabel.Text = "布偶状态持续时间: 5"
ragdollLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
ragdollLabel.Font = Enum.Font.Gotham
ragdollLabel.TextSize = 14
ragdollLabel.Parent = mainFrame

local ragdollInputFrame = Instance.new("Frame")
ragdollInputFrame.Name = "RagdollInputFrame"
ragdollInputFrame.Size = UDim2.new(0, 280, 0, 35)
ragdollInputFrame.Position = UDim2.new(0.5, -140, 0.42, 0)
ragdollInputFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ragdollInputFrame.BorderSizePixel = 0
ragdollInputFrame.Parent = mainFrame

local ragdollInputCorner = Instance.new("UICorner")
ragdollInputCorner.CornerRadius = UDim.new(0, 8)
ragdollInputCorner.Parent = ragdollInputFrame

local ragdollTextBox = Instance.new("TextBox")
ragdollTextBox.Name = "RagdollTextBox"
ragdollTextBox.Size = UDim2.new(0.6, 0, 0.7, 0)
ragdollTextBox.Position = UDim2.new(0.05, 0, 0.15, 0)
ragdollTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ragdollTextBox.BorderSizePixel = 0
ragdollTextBox.Text = "5"
ragdollTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ragdollTextBox.Font = Enum.Font.Gotham
ragdollTextBox.TextSize = 14
ragdollTextBox.PlaceholderText = "输入持续时间 (1-1000)"
ragdollTextBox.Parent = ragdollInputFrame

local ragdollTextBoxCorner = Instance.new("UICorner")
ragdollTextBoxCorner.CornerRadius = UDim.new(0, 6)
ragdollTextBoxCorner.Parent = ragdollTextBox

local applyRagdollButton = Instance.new("TextButton")
applyRagdollButton.Name = "ApplyRagdollButton"
applyRagdollButton.Size = UDim2.new(0.3, 0, 0.7, 0)
applyRagdollButton.Position = UDim2.new(0.67, 0, 0.15, 0)
applyRagdollButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
applyRagdollButton.BorderSizePixel = 0
applyRagdollButton.Text = "应用持续时间"
applyRagdollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyRagdollButton.Font = Enum.Font.Gotham
applyRagdollButton.TextSize = 13
applyRagdollButton.Parent = ragdollInputFrame

local applyRagdollCorner = Instance.new("UICorner")
applyRagdollCorner.CornerRadius = UDim.new(0, 6)
applyRagdollCorner.Parent = applyRagdollButton

-- 飞行速度设置
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(0, 280, 0, 25)
speedLabel.Position = UDim2.new(0.5, -140, 0.58, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "飞行速度: 50"
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.Parent = mainFrame

local speedInputFrame = Instance.new("Frame")
speedInputFrame.Name = "SpeedInputFrame"
speedInputFrame.Size = UDim2.new(0, 280, 0, 35)
speedInputFrame.Position = UDim2.new(0.5, -140, 0.65, 0)
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
applySpeedButton.Text = "应用飞行速度"
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

-- 优化的飞行函数，避免卡顿
local function StartCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    if not character or not character.Parent then return end
    
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not head then return end
    
    -- 安全检查
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
    
    -- 先设置布偶状态
    pcall(function()
        firesignal(ChangeState.OnClientEvent, 
            Enum.HumanoidStateType.FallingDown,
            RagdollDuration
        )
    end)
    
    humanoid.PlatformStand = true
    head.Anchored = true
    
    -- 安全断开连接
    CFLoop = SafeDisconnect(CFLoop)
    
    -- 使用Stepped而不是RenderStepped，更稳定
    CFLoop = RunService.Stepped:Connect(function(_, deltaTime)
        -- 多重安全检查
        if not character or not character.Parent then 
            CFLoop = SafeDisconnect(CFLoop)
            return 
        end
        
        if not humanoid or not humanoid.Parent or not head or not head.Parent then
            CFLoop = SafeDisconnect(CFLoop)
            return
        end
        
        -- 检查角色是否死亡
        if humanoid:GetState() == Enum.HumanoidStateType.Dead then
            StopCFly()
            return
        end
        
        -- 使用pcall包装飞行逻辑，防止错误传播
        local success, errorMsg = pcall(function()
            local moveDirection = humanoid.MoveDirection * (CFSpeed * deltaTime)
            local headCFrame = head.CFrame
            local camera = workspace.CurrentCamera
            local cameraCFrame = camera.CFrame
            local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
            cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
            local cameraPosition = cameraCFrame.Position
            local headPosition = headCFrame.Position

            local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
            head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
        end)
        
        if not success then
            warn("飞行错误: " .. tostring(errorMsg))
            StopCFly()
        end
    end)
end

local function StopCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    
    -- 安全断开连接
    CFLoop = SafeDisconnect(CFLoop)
    
    if character and character.Parent then
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        local head = character:FindFirstChild("Head")
        
        if humanoid and humanoid.Parent then
            humanoid.PlatformStand = false
        end
        if head and head.Parent then
            head.Anchored = false
        end
    end
end

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
setupButtonHover(deleteButton)
setupButtonHover(openUIButton)
setupButtonHover(applySpeedButton)
setupButtonHover(applyRagdollButton)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openUIButton.Visible = true
end)

openUIButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openUIButton.Visible = false
end)

deleteButton.MouseButton1Click:Connect(function()
    StopCFly()
    screenGui:Destroy()
end)

-- 应用飞行速度
applySpeedButton.MouseButton1Click:Connect(function()
    local inputSpeed = tonumber(speedTextBox.Text)
    if inputSpeed and inputSpeed >= 1 and inputSpeed <= 200 then
        CFSpeed = inputSpeed
        speedLabel.Text = "飞行速度: " .. CFSpeed
        speedTextBox.Text = tostring(CFSpeed)
    else
        speedTextBox.Text = tostring(CFSpeed)
    end
end)

speedTextBox.FocusLost:Connect(function(enterPressed)
    local inputSpeed = tonumber(speedTextBox.Text)
    if inputSpeed and inputSpeed >= 1 and inputSpeed <= 200 then
        CFSpeed = inputSpeed
        speedLabel.Text = "飞行速度: " .. CFSpeed
    else
        speedTextBox.Text = tostring(CFSpeed)
    end
end)

-- 应用布偶状态持续时间
applyRagdollButton.MouseButton1Click:Connect(function()
    local inputDuration = tonumber(ragdollTextBox.Text)
    if inputDuration and inputDuration >= 1 and inputDuration <= 1000 then
        RagdollDuration = inputDuration
        ragdollLabel.Text = "布偶状态持续时间: " .. RagdollDuration
        ragdollTextBox.Text = tostring(RagdollDuration)
    else
        ragdollTextBox.Text = tostring(RagdollDuration)
    end
end)

ragdollTextBox.FocusLost:Connect(function(enterPressed)
    local inputDuration = tonumber(ragdollTextBox.Text)
    if inputDuration and inputDuration >= 1 and inputDuration <= 1000 then
        RagdollDuration = inputDuration
        ragdollLabel.Text = "布偶状态持续时间: " .. RagdollDuration
    else
        ragdollTextBox.Text = tostring(RagdollDuration)
    end
end)

flyToggleButton.MouseButton1Click:Connect(function()
    if isFlying then
        StopCFly()
        flyToggleButton.Text = "开启飞行"
        flyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        isFlying = false
    else
        StartCFly()
        flyToggleButton.Text = "关闭飞行"
        flyToggleButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        isFlying = true
    end
end)

-- 角色死亡时自动停止飞行
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").Died:Connect(function()
        if isFlying then
            StopCFly()
            flyToggleButton.Text = "开启飞行"
            flyToggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            isFlying = false
        end
    end)
end)

screenGui.Parent = playerGui

print("飞行控制面板已加载！")