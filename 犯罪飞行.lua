local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CFSpeed = 50
local CFLoop = nil
local isFlying = false
local ChangeState = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ChangeState") -- RemoteEvent
local stateLoop = nil -- 用于控制状态事件的循环

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

local function StartCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local head = character:WaitForChild("Head")
    
    if not humanoid or not head then return end
    
    humanoid.PlatformStand = true
    head.Anchored = true
    
    if CFLoop then 
        CFLoop:Disconnect() 
        CFLoop = nil
    end
    
    -- 开始状态事件循环
    if stateLoop then
        stateLoop:Disconnect()
        stateLoop = nil
    end
    
    stateLoop = RunService.Heartbeat:Connect(function()
        firesignal(ChangeState.OnClientEvent, 
            Enum.HumanoidStateType.FallingDown, -- 改为落地状态
            5
        )
    end)
    
    CFLoop = RunService.Heartbeat:Connect(function(deltaTime)
        if not character or not humanoid or not head then 
            if CFLoop then 
                CFLoop:Disconnect() 
                CFLoop = nil
            end
            return 
        end
        
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
end

local function StopCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    
    if CFLoop then
        CFLoop:Disconnect()
        CFLoop = nil
    end
    
    -- 停止状态事件循环
    if stateLoop then
        stateLoop:Disconnect()
        stateLoop = nil
    end
    
    if character then
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        local head = character:FindFirstChild("Head")
        
        if humanoid then
            humanoid.PlatformStand = false
        end
        if head then
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

screenGui.Parent = playerGui

print("飞行控制面板已加载！")