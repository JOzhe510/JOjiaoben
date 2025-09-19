local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ==================== 现代玻璃态UI主题 ====================
local Theme = {
    Background = Color3.fromRGB(25, 25, 35),
    Header = Color3.fromRGB(40, 40, 55),
    Button = Color3.fromRGB(45, 45, 65),
    ButtonHover = Color3.fromRGB(60, 60, 85),
    Accent = Color3.fromRGB(0, 180, 255),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 100, 100),
    Text = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Glass = Color3.fromRGB(30, 30, 40)
}

-- ==================== 极简悬浮UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "ModernRespawnUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 主悬浮按钮
local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(0, 50, 0, 50)
MainButton.Position = UDim2.new(0, 20, 0.5, -25)
MainButton.BackgroundColor3 = Theme.Accent
MainButton.Text = "⚡"
MainButton.TextColor3 = Theme.Text
MainButton.TextSize = 20
MainButton.Font = Enum.Font.GothamBold
MainButton.Parent = ScreenGui

local MainButtonCorner = Instance.new("UICorner")
MainButtonCorner.CornerRadius = UDim.new(1, 0)
MainButtonCorner.Parent = MainButton

local MainButtonStroke = Instance.new("UIStroke")
MainButtonStroke.Color = Color3.fromRGB(255, 255, 255)
MainButtonStroke.Thickness = 2
MainButtonStroke.Transparency = 0.8
MainButtonStroke.Parent = MainButton

-- 主面板
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 300, 0, 400)
MainPanel.Position = UDim2.new(0, 80, 0.5, -200)
MainPanel.BackgroundColor3 = Theme.Glass
MainPanel.BackgroundTransparency = 0.1
MainPanel.Visible = false
MainPanel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = MainPanel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(255, 255, 255)
PanelStroke.Thickness = 1
PanelStroke.Transparency = 0.9
PanelStroke.Parent = MainPanel

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Theme.Header
TitleBar.BackgroundTransparency = 0.1
TitleBar.Parent = MainPanel

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Text = "🌟 终极功能面板"
Title.TextColor3 = Theme.Text
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.Text = "×"
CloseButton.TextColor3 = Theme.Text
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.Parent = TitleBar

-- 内容区域
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -50)
ContentFrame.Position = UDim2.new(0, 5, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Theme.TextSecondary
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ContentFrame.Parent = MainPanel

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = ContentFrame

-- ==================== UI组件创建函数 ====================
local function CreateSection(title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundTransparency = 1
    section.Parent = ContentFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.Text = "🔹 " .. title
    titleLabel.TextColor3 = Theme.Accent
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = section
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = content
    
    return content
end

local function CreateButton(text, icon)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Text = icon .. " " .. text
    button.TextColor3 = Theme.Text
    button.BackgroundColor3 = Theme.Button
    button.BackgroundTransparency = 0.1
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.TextXAlignment = Enum.TextXAlignment.Left
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Theme.ButtonHover
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Theme.Button
    end)
    
    return button
end

local function CreateToggle(text, icon, default)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, 0, 0, 40)
    toggle.Text = icon .. " " .. text .. (default and ": 开启" or ": 关闭")
    toggle.TextColor3 = default and Theme.Success or Theme.Warning
    toggle.BackgroundColor3 = Theme.Button
    toggle.BackgroundTransparency = 0.1
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 13
    toggle.TextXAlignment = Enum.TextXAlignment.Left
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggle
    
    toggle.MouseEnter:Connect(function()
        toggle.BackgroundColor3 = Theme.ButtonHover
    end)
    
    toggle.MouseLeave:Connect(function()
        toggle.BackgroundColor3 = Theme.Button
    end)
    
    return toggle
end

local function CreateDropdown(options, defaultText)
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(1, 0, 0, 40)
    dropdown.Text = "👤 " .. defaultText
    dropdown.TextColor3 = Theme.Text
    dropdown.BackgroundColor3 = Theme.Button
    dropdown.BackgroundTransparency = 0.1
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 13
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dropdown
    
    local dropdownMenu = Instance.new("Frame")
    dropdownMenu.Size = UDim2.new(1, 0, 0, 120)
    dropdownMenu.Position = UDim2.new(0, 0, 1, 5)
    dropdownMenu.BackgroundColor3 = Theme.Background
    dropdownMenu.BackgroundTransparency = 0.1
    dropdownMenu.Visible = false
    dropdownMenu.Parent = dropdown
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 8)
    menuCorner.Parent = dropdownMenu
    
    local menuLayout = Instance.new("UIListLayout")
    menuLayout.Parent = dropdownMenu
    
    dropdown.MouseButton1Click:Connect(function()
        dropdownMenu.Visible = not dropdownMenu.Visible
    end)
    
    local function UpdateOptions()
        for _, child in ipairs(dropdownMenu:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, option in ipairs(options) do
            local optionBtn = Instance.new("TextButton")
            optionBtn.Size = UDim2.new(1, 0, 0, 30)
            optionBtn.Text = option
            optionBtn.TextColor3 = Theme.Text
            optionBtn.BackgroundColor3 = Theme.Button
            optionBtn.Font = Enum.Font.Gotham
            optionBtn.TextSize = 12
            optionBtn.Parent = dropdownMenu
            
            optionBtn.MouseButton1Click:Connect(function()
                dropdown.Text = "👤 " .. option
                dropdownMenu.Visible = false
            end)
        end
    end
    
    UpdateOptions()
    
    return dropdown, UpdateOptions
end

-- ==================== 创建UI界面 ====================
-- 复活功能区域
local respawnSection = CreateSection("复活功能")
local suicideBtn = CreateButton("立即自杀", "💀")
suicideBtn.Parent = respawnSection

local respawnBtn = CreateButton("原地复活", "🔁")
respawnBtn.Parent = respawnSection

local autoRespawnToggle = CreateToggle("自动复活", "⚡", false)
autoRespawnToggle.Parent = respawnSection

-- 玩家选择区域
local playerSection = CreateSection("玩家选择")
local playerOptions = {}
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerOptions, player.Name)
    end
end

local playerDropdown, updatePlayerDropdown = CreateDropdown(playerOptions, "选择玩家")
playerDropdown.Parent = playerSection

-- 追踪功能区域
local followSection = CreateSection("追踪功能")
local followBtn = CreateButton("平滑追踪", "👥")
followBtn.Parent = followSection

local teleportBtn = CreateButton("直接传送", "🔮")
teleportBtn.Parent = followSection

-- 设置区域
local settingsSection = CreateSection("设置")
local speedSetting = CreateButton("追踪速度: 100", "🏃")
speedSetting.Parent = settingsSection

local distanceSetting = CreateButton("追踪距离: 3", "📏")
distanceSetting.Parent = settingsSection

-- ==================== 功能实现 ====================
-- 原地复活系统
local respawnService = {
    savedPositions = {},
    autoRespawn = false
}

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
        
        if self.autoRespawn then
            wait(2)
            player:LoadCharacter()
        end
    end)
end

-- 初始化复活系统
for _, player in ipairs(Players:GetPlayers()) do
    respawnService:SetupPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    respawnService:SetupPlayer(player)
    table.insert(playerOptions, player.Name)
    updatePlayerDropdown()
end)

Players.PlayerRemoving:Connect(function(player)
    for i, name in ipairs(playerOptions) do
        if name == player.Name then
            table.remove(playerOptions, i)
            break
        end
    end
    updatePlayerDropdown()
end)

-- 按钮功能
suicideBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

respawnBtn.MouseButton1Click:Connect(function()
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

autoRespawnToggle.MouseButton1Click:Connect(function()
    respawnService.autoRespawn = not respawnService.autoRespawn
    autoRespawnToggle.Text = "⚡ 自动复活: " .. (respawnService.autoRespawn and "开启" or "关闭")
    autoRespawnToggle.TextColor3 = respawnService.autoRespawn and Theme.Success or Theme.Warning
end)

-- ==================== UI控制 ====================
MainButton.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    MainPanel.Visible = false
end)

-- 拖动功能
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainPanel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==================== 键盘快捷键 ====================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainPanel.Visible = not MainPanel.Visible
    elseif input.KeyCode == Enum.KeyCode.R then
        -- 快速复活
        if LocalPlayer.Character then
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                respawnService.savedPositions[LocalPlayer] = rootPart.Position
            end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end
end)

print("🎮 现代功能面板加载完成！")
print("快捷键: RightShift-打开/关闭面板, R-快速复活")