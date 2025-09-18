local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- 创建主界面
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuicideRespawnUI"
ScreenGui.Parent = player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 40)
MainFrame.Position = UDim2.new(0.5, -100, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- 标题栏（可拖动）
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 20)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "自杀复活系统"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = TitleBar

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 20, 0, 20)
ToggleButton.Position = UDim2.new(1, -20, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "-"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = TitleBar

-- 内容区域
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 0, 120)
ContentFrame.Position = UDim2.new(0, 0, 0, 20)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- 自杀按钮
local SuicideButton = Instance.new("TextButton")
SuicideButton.Name = "SuicideButton"
SuicideButton.Size = UDim2.new(0.9, 0, 0, 30)
SuicideButton.Position = UDim2.new(0.05, 0, 0, 10)
SuicideButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
SuicideButton.BorderSizePixel = 0
SuicideButton.Text = "自杀"
SuicideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SuicideButton.TextSize = 14
SuicideButton.Font = Enum.Font.SourceSansBold
SuicideButton.Parent = ContentFrame

-- 复活按钮
local RespawnButton = Instance.new("TextButton")
RespawnButton.Name = "RespawnButton"
RespawnButton.Size = UDim2.new(0.9, 0, 0, 30)
RespawnButton.Position = UDim2.new(0.05, 0, 0, 50)
RespawnButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
RespawnButton.BorderSizePixel = 0
RespawnButton.Text = "原地复活"
RespawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RespawnButton.TextSize = 14
RespawnButton.Font = Enum.Font.SourceSansBold
RespawnButton.Parent = ContentFrame

-- 复活时间调节
local RespawnTimeLabel = Instance.new("TextLabel")
RespawnTimeLabel.Name = "RespawnTimeLabel"
RespawnTimeLabel.Size = UDim2.new(0.9, 0, 0, 20)
RespawnTimeLabel.Position = UDim2.new(0.05, 0, 0, 90)
RespawnTimeLabel.BackgroundTransparency = 1
RespawnTimeLabel.Text = "复活时间: 1.0 秒"
RespawnTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RespawnTimeLabel.TextSize = 14
RespawnTimeLabel.TextXAlignment = Enum.TextXAlignment.Left
RespawnTimeLabel.Font = Enum.Font.SourceSans
RespawnTimeLabel.Parent = ContentFrame

local RespawnTimeSlider = Instance.new("TextButton")
RespawnTimeSlider.Name = "RespawnTimeSlider"
RespawnTimeSlider.Size = UDim2.new(0.9, 0, 0, 10)
RespawnTimeSlider.Position = UDim2.new(0.05, 0, 0, 110)
RespawnTimeSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
RespawnTimeSlider.BorderSizePixel = 0
RespawnTimeSlider.Text = ""
RespawnTimeSlider.Parent = ContentFrame

local RespawnTimeFill = Instance.new("Frame")
RespawnTimeFill.Name = "RespawnTimeFill"
RespawnTimeFill.Size = UDim2.new(0.5, 0, 1, 0)
RespawnTimeFill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
RespawnTimeFill.BorderSizePixel = 0
RespawnTimeFill.Parent = RespawnTimeSlider

-- 变量
local isExpanded = true
local isDragging = false
local dragStartPos
local frameStartPos
local respawnTime = 1.0
local deathPosition = nil

-- 拖动功能
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStartPos = input.Position
        frameStartPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartPos
        MainFrame.Position = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X, 
                                      frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y)
    end
end)

-- 展开/收起功能
ToggleButton.MouseButton1Click:Connect(function()
    isExpanded = not isExpanded
    
    if isExpanded then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 160)}):Play()
        ToggleButton.Text = "-"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 40)}):Play()
        ToggleButton.Text = "+"
    end
end)

-- 自杀功能
SuicideButton.MouseButton1Click:Connect(function()
    if humanoid and humanoid.Health > 0 then
        -- 记录死亡位置
        deathPosition = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
        humanoid.Health = 0
    end
end)

-- 复活功能
RespawnButton.MouseButton1Click:Connect(function()
    if player then
        -- 延迟复活
        task.delay(respawnTime, function()
            if deathPosition then
                -- 先重生角色
                player:LoadCharacter()
                
                -- 等待角色加载完成
                local newCharacter = player.Character or player.CharacterAdded:Wait()
                local newHumanoid = newCharacter:WaitForChild("Humanoid")
                
                -- 传送到死亡位置
                local rootPart = newCharacter:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(deathPosition)
                end
            else
                player:LoadCharacter()
            end
        end)
    end
end)

-- 复活时间调节功能
RespawnTimeSlider.MouseButton1Down:Connect(function()
    local connection
    connection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local xPos = math.clamp(input.Position.X - RespawnTimeSlider.AbsolutePosition.X, 0, RespawnTimeSlider.AbsoluteSize.X)
            local ratio = xPos / RespawnTimeSlider.AbsoluteSize.X
            
            -- 设置复活时间 (0.1秒到3秒之间)
            respawnTime = 0.1 + ratio * 2.9
            RespawnTimeFill.Size = UDim2.new(ratio, 0, 1, 0)
            RespawnTimeLabel.Text = string.format("复活时间: %.1f 秒", respawnTime)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            connection:Disconnect()
        end
    end)
end)

-- 监听角色死亡事件
humanoid.Died:Connect(function()
    deathPosition = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
end)

-- 角色重新加载时更新引用
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    
    -- 再次监听死亡事件
    humanoid.Died:Connect(function()
        deathPosition = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
    end)
end)