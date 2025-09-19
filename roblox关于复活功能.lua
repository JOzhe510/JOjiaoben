local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ==================== UI主题 ====================
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

-- ==================== 完整UI界面 ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "AimBotUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 520) -- 增加高度以容纳新功能
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
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 750) -- 增加画布大小
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
ScrollFrame.Parent = Frame

-- 创建一个内部容器来存放所有UI元素
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

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
Title.Text = "🔮 功能菜单 🔮"
Title.BackgroundColor3 = Theme.Header
Title.BackgroundTransparency = 0.05
Title.TextColor3 = Theme.Accent
Title.BorderSizePixel = 0
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame
table.insert(UIElements, Title)

-- 按钮创建函数
local function CreateStyledButton(name, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.9, 0, 0, 36)
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

-- 创建文本框函数
local function CreateTextBox(name, placeholder, default)
    local textBoxFrame = Instance.new("Frame")
    textBoxFrame.Size = UDim2.new(0.9, 0, 0, 36)
    textBoxFrame.BackgroundTransparency = 1
    textBoxFrame.Parent = ScrollFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Name = name
    textBox.Size = UDim2.new(1, 0, 1, 0)
    textBox.PlaceholderText = placeholder
    textBox.Text = default
    textBox.BackgroundColor3 = Theme.Button
    textBox.BackgroundTransparency = 0.1
    textBox.TextColor3 = Theme.Text
    textBox.BorderSizePixel = 0
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.Parent = textBoxFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = textBox
    
    table.insert(UIElements, textBoxFrame)
    return textBox
end

-- 创建标签函数
local function CreateLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.9, 0, 0, 20)
    label.Text = text
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.BorderSizePixel = 0
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ScrollFrame
    
    table.insert(UIElements, label)
    return label
end

-- 创建功能按钮
local SuicideBtn = CreateStyledButton("SuicideBtn", "💀 自杀")
local RespawnBtn = CreateStyledButton("RespawnBtn", "🔁 原地复活")
local FollowBtn = CreateStyledButton("FollowBtn", "👥 追踪玩家")

-- 创建追踪功能相关的UI元素
CreateLabel("追踪目标玩家名称:")
local TargetPlayerTextBox = CreateTextBox("TargetPlayerTextBox", "输入玩家名称", "")
CreateLabel("追踪速度:")
local FollowSpeedTextBox = CreateTextBox("FollowSpeedTextBox", "输入速度", "50")

-- 自杀功能
SuicideBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- 原地复活系统
local respawnService = {}
respawnService.savedPositions = {}

function respawnService:SetupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        self:OnCharacterAdded(player, character)
    end)
    
    if player.Character then
        self:OnCharacterAdded(player, player.Character)
    end
end

function respawnService:OnCharacterAdded(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    
    if self.savedPositions[player] then
        wait(0.1) 
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(self.savedPositions[player])
            print("传送 " .. player.Name .. " 到保存位置")
        end
    end
    
    humanoid.Died:Connect(function()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            self.savedPositions[player] = rootPart.Position
            print("保存 " .. player.Name .. " 的位置")
        end
        
        wait(5)
        player:LoadCharacter()
    end)
end

-- 初始化原地复活系统
for _, player in ipairs(Players:GetPlayers()) do
    respawnService:SetupPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    respawnService:SetupPlayer(player)
end)

print("原地复活系统初始化完成")

-- 原地复活按钮功能
RespawnBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            respawnService.savedPositions[LocalPlayer] = rootPart.Position
            print("保存当前位置用于复活")
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- ==================== 追踪玩家功能 ====================
local FollowService = {
    Enabled = false,
    TargetPlayer = nil,
    FollowSpeed = 50,
    Connection = nil
}

function FollowService:StartFollowing()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled or not self.TargetPlayer or not self.TargetPlayer.Character then
            return
        end
        
        local targetRoot = self.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        
        if not targetRoot or not localRoot then
            return
        end
        
        -- 计算目标背后的位置
        local targetCFrame = targetRoot.CFrame
        local behindOffset = targetCFrame.LookVector * -3 -- 在目标背后3个单位
        local targetPosition = targetCFrame.Position + behindOffset + Vector3.new(0, 1.5, 0) -- 稍微抬高一点
        
        -- 计算移动方向
        local direction = (targetPosition - localRoot.Position).Unit
        local distance = (targetPosition - localRoot.Position).Magnitude
        
        -- 如果距离较远，使用更快的速度
        local actualSpeed = self.FollowSpeed
        if distance > 20 then
            actualSpeed = actualSpeed * 2
        end
        
        -- 移动本地玩家
        localRoot.Velocity = direction * actualSpeed
        
        -- 如果距离很近，停止移动以避免过度抖动
        if distance < 2 then
            localRoot.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function FollowService:StopFollowing()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    -- 停止移动
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if localRoot then
        localRoot.Velocity = Vector3.new(0, 0, 0)
    end
end

function FollowService:ToggleFollowing()
    self.Enabled = not self.Enabled
    
    if self.Enabled then
        -- 获取目标玩家
        local targetName = TargetPlayerTextBox.Text
        if targetName == "" then
            FollowBtn.Text = "👥 追踪玩家"
            self.Enabled = false
            return
        end
        
        -- 查找玩家
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name:lower():find(targetName:lower()) or player.DisplayName:lower():find(targetName:lower()) then
                self.TargetPlayer = player
                break
            end
        end
        
        if not self.TargetPlayer then
            FollowBtn.Text = "👥 追踪玩家"
            self.Enabled = false
            print("未找到玩家: " .. targetName)
            return
        end
        
        -- 获取速度
        local speed = tonumber(FollowSpeedTextBox.Text)
        if speed then
            self.FollowSpeed = math.clamp(speed, 1, 1000)
        end
        
        FollowBtn.Text = "🛑 停止追踪"
        self:StartFollowing()
        print("开始追踪: " .. self.TargetPlayer.Name)
    else
        FollowBtn.Text = "👥 追踪玩家"
        self:StopFollowing()
        print("停止追踪")
    end
end

-- 追踪按钮功能
FollowBtn.MouseButton1Click:Connect(function()
    FollowService:ToggleFollowing()
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
    Frame.Size = isExpanded and UDim2.new(0, 280, 0, 520) or UDim2.new(0, 280, 0, 32)
    ScrollFrame.Visible = isExpanded
end)

-- ==================== 键盘快捷键 ====================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.U then
        isExpanded = not isExpanded
        for _, element in pairs(UIElements) do
            if element ~= Title then
                element.Visible = isExpanded
            end
        end
        ToggleButton.Text = isExpanded and "▲" or "▼"
        Frame.Size = isExpanded and UDim2.new(0, 280, 0, 520) or UDim2.new(0, 280, 0, 32)
        ScrollFrame.Visible = isExpanded
    end
end)

print("🔮 功能菜单加载完成！")
print("快捷键: U-隐藏/显示UI")