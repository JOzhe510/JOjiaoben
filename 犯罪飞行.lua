local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local flyLoop
local lastExecute = 0
local mainUIVisible = true
local isFlying = false
local flightStartTime = 0
local lastPosition = nil
local isMoving = false
local moveCheckLoop

-- 创建主UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "飞行控制"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.Gotham
TitleLabel.TextSize = 12
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 1, 0)
CloseButton.Position = UDim2.new(1, -25, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.Gotham
CloseButton.TextSize = 12
CloseButton.Parent = TitleBar

-- 飞行开关按钮
local FlyToggle = Instance.new("TextButton")
FlyToggle.Size = UDim2.new(0, 120, 0, 30)
FlyToggle.Position = UDim2.new(0.5, -60, 0.3, -15)
FlyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlyToggle.Text = "开启飞行"
FlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyToggle.Font = Enum.Font.Gotham
FlyToggle.TextSize = 14
FlyToggle.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = FlyToggle

-- 循环开关按钮
local LoopToggle = Instance.new("TextButton")
LoopToggle.Size = UDim2.new(0, 120, 0, 30)
LoopToggle.Position = UDim2.new(0.5, -60, 0.7, -15)
LoopToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
LoopToggle.Text = "开启循环"
LoopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoopToggle.Font = Enum.Font.Gotham
LoopToggle.TextSize = 14
LoopToggle.Parent = MainFrame

local LoopCorner = Instance.new("UICorner")
LoopCorner.CornerRadius = UDim.new(0, 6)
LoopCorner.Parent = LoopToggle

-- 创建小悬浮按钮
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 40, 0, 40)
FloatButton.Position = UDim2.new(0, 10, 0, 10)
FloatButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
FloatButton.Text = "⚡"
FloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatButton.Font = Enum.Font.Gotham
FloatButton.TextSize = 18
FloatButton.Visible = false
FloatButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 20)
FloatCorner.Parent = FloatButton

-- 飞行功能
local function executeFlightCode()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local __RZDONL = ReplicatedStorage.Events.__RZDONL
    __RZDONL:FireServer(
        "__---r",
        Vector3.new(7, 6, -28),
        CFrame.new(-4895, 55, -68, 0, -1, -1, -0, 1, -1, 1, 0, -0)
    )
end

-- 检测玩家是否在移动
local function startMoveDetection()
    if moveCheckLoop then return end
    
    moveCheckLoop = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local currentPosition = LocalPlayer.Character.HumanoidRootPart.Position
            
            if lastPosition then
                -- 计算移动距离
                local distance = (currentPosition - lastPosition).Magnitude
                -- 如果移动距离大于0.5，则认为玩家在移动
                isMoving = distance > 0.5
            else
                lastPosition = currentPosition
                isMoving = false
            end
        else
            lastPosition = nil
            isMoving = false
        end
    end)
end

local function stopMoveDetection()
    if moveCheckLoop then
        moveCheckLoop:Disconnect()
        moveCheckLoop = nil
    end
    lastPosition = nil
    isMoving = false
end

local function startLoop()
    if flyLoop then return end
    
    flightStartTime = tick()  -- 记录飞行开始时间
    executeFlightCode()  -- 立即执行一次
    
    flyLoop = RunService.Heartbeat:Connect(function(deltaTime)
        lastExecute = lastExecute + deltaTime
        
        -- 延长间隔到3秒，避免频繁重置
        if lastExecute >= 3.0 then
            -- 只有在飞行状态下才继续执行，但根据移动状态调整
            if isFlying then
                if not isMoving then
                    -- 玩家没有移动时执行飞行代码
                    executeFlightCode()
                end
                -- 玩家在移动时不执行飞行代码，避免干扰
            end
            lastExecute = 0
        end
    end)
    
    LoopToggle.Text = "关闭循环"
    LoopToggle.BackgroundColor3 = Color3.fromRGB(215, 60, 60)
end

local function stopLoop()
    if flyLoop then
        flyLoop:Disconnect()
        flyLoop = nil
    end
    lastExecute = 0
    
    LoopToggle.Text = "开启循环"
    LoopToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end

-- 玩家飞行功能
local function togglePlayerFlight()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        
        if not isFlying then
            -- 开启飞行
            humanoid.PlatformStand = true
            isFlying = true
            
            -- 开始移动检测
            startMoveDetection()
            
            -- 立即执行飞行代码来启动飞行
            executeFlightCode()
            
            -- 如果循环已开启，确保循环运行
            if flyLoop then
                executeFlightCode()
            end
            
            FlyToggle.Text = "关闭飞行"
            FlyToggle.BackgroundColor3 = Color3.fromRGB(215, 60, 60)
        else
            -- 关闭飞行
            humanoid.PlatformStand = false
            isFlying = false
            
            -- 停止移动检测
            stopMoveDetection()
            
            FlyToggle.Text = "开启飞行"
            FlyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
end

-- 按钮事件
FlyToggle.MouseButton1Click:Connect(togglePlayerFlight)

LoopToggle.MouseButton1Click:Connect(function()
    if flyLoop then
        stopLoop()
    else
        startLoop()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    mainUIVisible = false
    MainFrame.Visible = false
    FloatButton.Visible = true
end)

FloatButton.MouseButton1Click:Connect(function()
    mainUIVisible = true
    MainFrame.Visible = true
    FloatButton.Visible = false
end)

-- 防内存泄漏
LocalPlayer.CharacterRemoving:Connect(function()
    stopLoop()
    stopMoveDetection()
    isFlying = false
    if FlyToggle then
        FlyToggle.Text = "开启飞行"
        FlyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

-- 角色添加时重新初始化
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    if isFlying then
        -- 如果之前是飞行状态，重新启用飞行
        local humanoid = character.Humanoid
        humanoid.PlatformStand = true
        startMoveDetection()
        executeFlightCode()
    end
end)