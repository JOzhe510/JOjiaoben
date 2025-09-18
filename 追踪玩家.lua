local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 创建屏幕GUI
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FollowerUI"
screenGui.Parent = playerGui

-- 添加圆角函数
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

-- 添加描边函数
local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(80, 80, 80)
    stroke.Thickness = thickness or 2
    stroke.Parent = parent
    return stroke
end

-- 主框架
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 60) -- 初始高度较小
mainFrame.Position = UDim2.new(0, 10, 0.5, -30)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
createCorner(mainFrame, 12)
createStroke(mainFrame)

-- 标题栏（可点击展开/收起）
local titleBar = Instance.new("TextButton")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.Text = ""
titleBar.AutoButtonColor = false
titleBar.Parent = mainFrame
createCorner(titleBar, 12)

-- 标题
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 150, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "玩家跟随系统"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- 展开/收起指示器
local expandIndicator = Instance.new("TextLabel")
expandIndicator.Size = UDim2.new(0, 20, 0, 20)
expandIndicator.Position = UDim2.new(1, -30, 0.5, -10)
expandIndicator.BackgroundTransparency = 1
expandIndicator.Text = "▼"
expandIndicator.TextColor3 = Color3.fromRGB(200, 200, 200)
expandIndicator.Font = Enum.Font.GothamBold
expandIndicator.TextSize = 14
expandIndicator.Parent = titleBar

-- 关闭按钮
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = titleBar
createCorner(closeButton)

-- 内容区域（可展开/收起）
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 0, 360)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Visible = false -- 初始隐藏
contentFrame.Parent = mainFrame

-- 玩家列表框架
local playersFrame = Instance.new("ScrollingFrame")
playersFrame.Size = UDim2.new(1, -20, 0, 200)
playersFrame.Position = UDim2.new(0, 10, 0, 10)
playersFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
playersFrame.BorderSizePixel = 0
playersFrame.ScrollBarThickness = 5
playersFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
playersFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playersFrame.Parent = contentFrame
createCorner(playersFrame, 8)
createStroke(playersFrame)

local playersListLayout = Instance.new("UIListLayout")
playersListLayout.Padding = UDim.new(0, 5)
playersListLayout.Parent = playersFrame

-- 控制面板
local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(1, -20, 0, 130)
controlsFrame.Position = UDim2.new(0, 10, 0, 220)
controlsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
controlsFrame.BorderSizePixel = 0
controlsFrame.Parent = contentFrame
createCorner(controlsFrame, 8)
createStroke(controlsFrame)

-- 当前跟随标签
local currentFollowLabel = Instance.new("TextLabel")
currentFollowLabel.Size = UDim2.new(1, -10, 0, 30)
currentFollowLabel.Position = UDim2.new(0, 5, 0, 10)
currentFollowLabel.BackgroundTransparency = 1
currentFollowLabel.Text = "当前跟随: 无"
currentFollowLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
currentFollowLabel.Font = Enum.Font.Gotham
currentFollowLabel.TextSize = 14
currentFollowLabel.Parent = controlsFrame

-- 模式选择
local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(1, -10, 0, 20)
modeLabel.Position = UDim2.new(0, 5, 0, 45)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "跟随模式:"
modeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
modeLabel.Font = Enum.Font.Gotham
modeLabel.TextSize = 12
modeLabel.Parent = controlsFrame

local teleportModeButton = Instance.new("TextButton")
teleportModeButton.Size = UDim2.new(0.45, 0, 0, 30)
teleportModeButton.Position = UDim2.new(0, 5, 0, 70)
teleportModeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
teleportModeButton.Text = "传送模式"
teleportModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportModeButton.Font = Enum.Font.Gotham
teleportModeButton.TextSize = 14
teleportModeButton.Parent = controlsFrame
createCorner(teleportModeButton)

local smoothModeButton = Instance.new("TextButton")
smoothModeButton.Size = UDim2.new(0.45, 0, 0, 30)
smoothModeButton.Position = UDim2.new(0.55, 0, 0, 70)
smoothModeButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
smoothModeButton.Text = "平滑模式"
smoothModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
smoothModeButton.Font = Enum.Font.Gotham
smoothModeButton.TextSize = 14
smoothModeButton.Parent = controlsFrame
createCorner(smoothModeButton)

-- 停止按钮
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(1, -10, 0, 30)
stopButton.Position = UDim2.new(0, 5, 0, 105)
stopButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
stopButton.Text = "停止跟随"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.Parent = controlsFrame
createCorner(stopButton)

-- 全局变量
local targetPlayer = nil
local isFollowing = false
local isTeleporting = false
local follower = nil
local connection = nil
local isExpanded = false

-- 展开/收起动画
local function toggleExpand()
    isExpanded = not isExpanded
    
    if isExpanded then
        -- 展开
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 320, 0, 400)
        expandIndicator.Text = "▲"
        
        -- 更新玩家列表
        updatePlayersList()
    else
        -- 收起
        local tween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 320, 0, 40)}
        )
        tween:Play()
        
        tween.Completed:Connect(function()
            if not isExpanded then
                contentFrame.Visible = false
            end
        end)
        
        expandIndicator.Text = "▼"
    end
end

-- 创建跟随部件
function createFollower()
    if follower and follower.Parent then
        follower:Destroy()
    end
    
    follower = Instance.new("Part")
    follower.Name = "PlayerFollower"
    follower.Size = Vector3.new(3, 3, 3)
    follower.Anchored = true
    follower.CanCollide = false
    follower.Transparency = 0.3
    follower.BrickColor = BrickColor.new("Bright blue")
    follower.Material = Enum.Material.Neon
    follower.Parent = workspace
    
    -- 添加特效
    local light = Instance.new("PointLight")
    light.Brightness = 8
    light.Range = 12
    light.Color = Color3.new(0, 0.5, 1)
    light.Parent = follower
    
    local particle = Instance.new("ParticleEmitter")
    particle.Color = ColorSequence.new(Color3.new(0, 0.5, 1))
    particle.Size = NumberSequence.new(0.5)
    particle.Acceleration = Vector3.new(0, -5, 0)
    particle.Lifetime = NumberRange.new(0.5, 1)
    particle.Rate = 20
    particle.Parent = follower
    
    return follower
end

-- 更新玩家列表
function updatePlayersList()
    for _, child in ipairs(playersFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local playerCount = 0
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            playerCount = playerCount + 1
            
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(1, -10, 0, 40)
            playerButton.Position = UDim2.new(0, 5, 0, (playerCount - 1) * 45)
            playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            playerButton.Text = player.Name
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.Font = Enum.Font.Gotham
            playerButton.TextSize = 14
            playerButton.Parent = playersFrame
            createCorner(playerButton)
            
            playerButton.MouseButton1Click:Connect(function()
                startFollowing(player)
            end)
            
            -- 添加鼠标悬停效果
            playerButton.MouseEnter:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end)
            
            playerButton.MouseLeave:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end)
        end
    end
    
    playersFrame.CanvasSize = UDim2.new(0, 0, 0, playerCount * 45)
end

-- 开始跟随
function startFollowing(player)
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    targetPlayer = player
    isFollowing = true
    
    local character = targetPlayer.Character
    if not character then
        warn("玩家没有角色")
        return
    end
    
    currentFollowLabel.Text = "当前跟随: " .. targetPlayer.Name
    
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    follower = createFollower()
    
    local lastPosition = humanoidRootPart.Position
    
    connection = RunService.RenderStepped:Connect(function(deltaTime)
        if not isFollowing or not targetPlayer or not targetPlayer.Character then
            return
        end
        
        character = targetPlayer.Character
        humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoidRootPart then
            return
        end
        
        local currentPosition = humanoidRootPart.Position
        local velocity = (currentPosition - lastPosition) / deltaTime
        
        -- 计算目标位置
        local offset = humanoidRootPart.CFrame.LookVector * -0.1
        local targetPosition = currentPosition + offset
        
        if isTeleporting then
            -- 传送模式
            follower.Position = targetPosition
            follower.CFrame = CFrame.lookAt(targetPosition, currentPosition)
        else
            -- 平滑跟随模式
            local tweenInfo = TweenInfo.new(
                0.05,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out
            )
            
            local goal = {}
            goal.Position = targetPosition
            goal.CFrame = CFrame.lookAt(targetPosition, currentPosition)
            
            local tween = TweenService:Create(follower, tweenInfo, goal)
            tween:Play()
        end
        
        lastPosition = currentPosition
    end)
end

-- 停止跟随
function stopFollowing()
    isFollowing = false
    targetPlayer = nil
    currentFollowLabel.Text = "当前跟随: 无"
    
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    if follower then
        follower:Destroy()
        follower = nil
    end
end

-- 切换模式
function setTeleportMode(enabled)
    isTeleporting = enabled
    if enabled then
        teleportModeButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
        smoothModeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    else
        teleportModeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        smoothModeButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
    end
end

-- 按钮事件
closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
end)

titleBar.MouseButton1Click:Connect(function()
    toggleExpand()
end)

teleportModeButton.MouseButton1Click:Connect(function()
    setTeleportMode(true)
end)

smoothModeButton.MouseButton1Click:Connect(function()
    setTeleportMode(false)
end)

stopButton.MouseButton1Click:Connect(function()
    stopFollowing()
end)

-- 初始化
updatePlayersList()
setTeleportMode(false)

-- 监听玩家加入/离开
Players.PlayerAdded:Connect(updatePlayersList)
Players.PlayerRemoving:Connect(updatePlayersList)

-- 每10秒更新一次玩家列表（防止漏掉）
while true do
    wait(10)
    if isExpanded then
        updatePlayersList()
    end
end