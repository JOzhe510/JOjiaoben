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

-- ==================== 玩家选择下拉菜单 ====================
local function CreatePlayerDropdown()
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0.9, 0, 0, 30)
    dropdownFrame.BackgroundColor3 = Theme.Button
    dropdownFrame.BackgroundTransparency = 0.1
    dropdownFrame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = dropdownFrame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(1, 0, 1, 0)
    dropdown.Text = "选择玩家"
    dropdown.TextColor3 = Theme.Text
    dropdown.BackgroundTransparency = 1
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 14
    dropdown.Parent = dropdownFrame
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(1, 0, 0, 150)
    dropdownList.Position = UDim2.new(0, 0, 1, 2)
    dropdownList.BackgroundColor3 = Theme.Background
    dropdownList.BorderSizePixel = 0
    dropdownList.ScrollBarThickness = 4
    dropdownList.Visible = false
    dropdownList.Parent = dropdownFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = dropdownList
    
    -- 更新玩家列表
    local function UpdatePlayerList()
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local playerBtn = Instance.new("TextButton")
                playerBtn.Size = UDim2.new(1, 0, 0, 30)
                playerBtn.Text = player.Name
                playerBtn.TextColor3 = Theme.Text
                playerBtn.BackgroundColor3 = Theme.Button
                playerBtn.BorderSizePixel = 0
                playerBtn.Font = Enum.Font.Gotham
                playerBtn.TextSize = 12
                playerBtn.Parent = dropdownList
                
                playerBtn.MouseButton1Click:Connect(function()
                    dropdown.Text = player.Name
                    dropdownList.Visible = false
                end)
            end
        end
        
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        if dropdownList.Visible then
            UpdatePlayerList()
        end
    end)
    
    -- 玩家加入/离开时更新列表
    Players.PlayerAdded:Connect(UpdatePlayerList)
    Players.PlayerRemoving:Connect(UpdatePlayerList)
    
    return dropdownFrame, dropdown
end

-- ==================== 简化UI界面 ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "SimpleMenuUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 40)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Text = "🔮 功能菜单"
Title.BackgroundTransparency = 1
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(1, -30, 0, 0)
ToggleButton.Text = "▼"
ToggleButton.TextColor3 = Theme.Text
ToggleButton.BackgroundColor3 = Theme.Button
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.BorderSizePixel = 0
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = MainFrame

-- 内容框架
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 0, 400)
ContentFrame.Position = UDim2.new(0, 0, 1, 5)
ContentFrame.BackgroundColor3 = Theme.Background
ContentFrame.BackgroundTransparency = 0.1
ContentFrame.BorderSizePixel = 0
ContentFrame.Visible = false
ContentFrame.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

-- 按钮创建函数
local function CreateButton(text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 35)
    button.Text = text
    button.BackgroundColor3 = Theme.Button
    button.BackgroundTransparency = 0.1
    button.TextColor3 = Theme.Text
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.Parent = ScrollFrame
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Theme.ButtonHover
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Theme.Button
    end)
    
    return button
end

-- 创建折叠面板函数
local function CreateCollapsibleSection(title)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(0.9, 0, 0, 30)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Parent = ScrollFrame
    
    local sectionButton = Instance.new("TextButton")
    sectionButton.Size = UDim2.new(1, 0, 1, 0)
    sectionButton.Text = "▶ " .. title
    sectionButton.TextColor3 = Theme.Text
    sectionButton.BackgroundColor3 = Theme.Header
    sectionButton.BackgroundTransparency = 0.2
    sectionButton.BorderSizePixel = 0
    sectionButton.Font = Enum.Font.Gotham
    sectionButton.TextSize = 12
    sectionButton.TextXAlignment = Enum.TextXAlignment.Left
    sectionButton.Parent = sectionFrame
    
    local sectionContent = Instance.new("Frame")
    sectionContent.Size = UDim2.new(1, 0, 0, 0)
    sectionContent.BackgroundTransparency = 1
    sectionContent.Visible = false
    sectionContent.Parent = sectionFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = sectionContent
    
    sectionButton.MouseButton1Click:Connect(function()
        sectionContent.Visible = not sectionContent.Visible
        sectionButton.Text = (sectionContent.Visible and "▼ " or "▶ ") .. title
        
        if sectionContent.Visible then
            sectionContent.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y)
        else
            sectionContent.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
    
    return sectionContent
end

-- 创建滑块控件
local function CreateSlider(label, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = ScrollFrame
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, 0, 0, 20)
    labelText.Text = label .. ": " .. default
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Theme.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = sliderFrame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Theme.Button
    slider.BorderSizePixel = 0
    slider.Parent = sliderFrame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = slider
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 1, 0)
    sliderButton.Text = ""
    sliderButton.BackgroundColor3 = Theme.Text
    sliderButton.BorderSizePixel = 0
    sliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0, 0)
    sliderButton.Parent = slider
    
    local dragging = false
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    sliderButton.MouseMoved:Connect(function()
        if dragging then
            local mousePos = UIS:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition
            local sliderSize = slider.AbsoluteSize
            
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relativeX)
            
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderButton.Position = UDim2.new(relativeX, -10, 0, 0)
            labelText.Text = label .. ": " .. value
            
            if callback then
                callback(value)
            end
        end
    end)
    
    return {Value = default, SetValue = function(value)
        local relativeX = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderButton.Position = UDim2.new(relativeX, -10, 0, 0)
        labelText.Text = label .. ": " .. value
    end}
end

-- ==================== 创建UI元素 ====================
-- 玩家选择下拉菜单
local playerDropdown, selectedPlayer = CreatePlayerDropdown()
playerDropdown.Parent = ScrollFrame

-- 基础功能按钮
local SuicideBtn = CreateButton("💀 自杀")
local RespawnBtn = CreateButton("🔁 原地复活")

-- 追踪功能折叠面板
local followSection = CreateCollapsibleSection("追踪设置")
local followSpeedSlider = CreateSlider("追踪速度", 1, 9999, 100, function(value) end)
local followDistanceSlider = CreateSlider("追踪距离", 1, 50, 3, function(value) end)
local FollowBtn = CreateButton("👥 平滑追踪")
FollowBtn.Parent = followSection

-- 传送功能折叠面板
local teleportSection = CreateCollapsibleSection("传送设置")
local teleportHeightSlider = CreateSlider("高度偏移", 0, 10, 0, function(value) end)
local teleportAngleSlider = CreateSlider("角度偏移", 0, 360, 180, function(value) end)
local TeleportBtn = CreateButton("🔮 直接传送")
TeleportBtn.Parent = teleportSection

-- 子弹追踪折叠面板
local bulletSection = CreateCollapsibleSection("子弹追踪")
local trackStrengthSlider = CreateSlider("追踪强度", 1, 100, 50, function(value) end)
local predictionTimeSlider = CreateSlider("预测时间", 1, 20, 3, function(value) end)
local BulletTrackBtn = CreateButton("🎯 子弹追踪")
BulletTrackBtn.Parent = bulletSection

-- ==================== 功能实现 ====================
-- 原地复活系统
local respawnService = {savedPositions = {}}

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
        end
    end
    
    humanoid.Died:Connect(function()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            self.savedPositions[player] = rootPart.Position
        end
        wait(5)
        player:LoadCharacter()
    end)
end

-- 初始化复活系统
for _, player in ipairs(Players:GetPlayers()) do
    respawnService:SetupPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    respawnService:SetupPlayer(player)
end)

-- 自杀功能
SuicideBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- 原地复活功能
RespawnBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            respawnService.savedPositions[LocalPlayer] = rootPart.Position
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- ==================== 追踪功能 ====================
local FollowService = {
    Enabled = false,
    TargetPlayer = nil,
    FollowSpeed = 100,
    FollowDistance = 3,
    Connection = nil
}

function FollowService:FindTargetPlayer(targetName)
    if targetName == "选择玩家" or targetName == "" then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == targetName then
            return player
        end
    end
    return nil
end

function FollowService:StartFollowing()
    if self.Connection then self.Connection:Disconnect() end
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled or not self.TargetPlayer then return end
        
        if not self.TargetPlayer.Character then
            self:StopFollowing()
            return
        end
        
        local targetRoot = self.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        
        if not targetRoot or not localRoot then return end
        
        local targetPosition = targetRoot.Position
        local behindOffset = targetRoot.CFrame.LookVector * -self.FollowDistance
        local finalPosition = targetPosition + behindOffset + Vector3.new(0, 1.5, 0)
        
        local direction = (finalPosition - localRoot.Position).Unit
        localRoot.Velocity = direction * self.FollowSpeed
    end)
end

function FollowService:StopFollowing()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

FollowBtn.MouseButton1Click:Connect(function()
    FollowService.Enabled = not FollowService.Enabled
    
    if FollowService.Enabled then
        FollowService.TargetPlayer = FollowService:FindTargetPlayer(selectedPlayer.Text)
        FollowService.FollowSpeed = followSpeedSlider.Value
        FollowService.FollowDistance = followDistanceSlider.Value
        
        if FollowService.TargetPlayer then
            FollowBtn.Text = "🛑 停止追踪"
            FollowService:StartFollowing()
        else
            FollowService.Enabled = false
        end
    else
        FollowBtn.Text = "👥 平滑追踪"
        FollowService:StopFollowing()
    end
end)

-- ==================== UI控制 ====================
ToggleButton.MouseButton1Click:Connect(function()
    ContentFrame.Visible = not ContentFrame.Visible
    ToggleButton.Text = ContentFrame.Visible and "▲" or "▼"
    MainFrame.Size = ContentFrame.Visible and UDim2.new(0, 250, 0, 450) or UDim2.new(0, 250, 0, 40)
end)

-- ==================== 键盘快捷键 ====================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.U then
        ContentFrame.Visible = not ContentFrame.Visible
        ToggleButton.Text = ContentFrame.Visible and "▲" or "▼"
        MainFrame.Size = ContentFrame.Visible and UDim2.new(0, 250, 0, 450) or UDim2.new(0, 250, 0, 40)
    end
end)

print("🔮 简化功能菜单加载完成！")
print("快捷键: U-显示/隐藏菜单")