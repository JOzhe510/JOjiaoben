-- 创建一个可移动的屏幕GUI
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 创建主屏幕GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VoidTeleportUI"
screenGui.ResetOnSpawn = false

-- 创建主框架
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100) -- 屏幕中央
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true -- 允许交互
mainFrame.Draggable = true -- 允许拖动
mainFrame.Parent = screenGui

-- 添加圆角
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- 创建标题栏
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

-- 标题栏圆角（只圆顶部的角）
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- 标题文字
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "虚空传送器"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = titleBar

-- 关闭按钮（文字形式）
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 50, 0, 25)
closeButton.Position = UDim2.new(1, -55, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "关闭"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 12
closeButton.Parent = titleBar

-- 关闭按钮圆角
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- 传送按钮
local teleportButton = Instance.new("TextButton")
teleportButton.Name = "TeleportButton"
teleportButton.Size = UDim2.new(0, 200, 0, 60)
teleportButton.Position = UDim2.new(0.5, -100, 0.5, -30)
teleportButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
teleportButton.BorderSizePixel = 0
teleportButton.Text = "传送到虚空"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.Font = Enum.Font.GothamBold
teleportButton.TextSize = 18
teleportButton.Parent = mainFrame

-- 传送按钮圆角
local teleportCorner = Instance.new("UICorner")
teleportCorner.CornerRadius = UDim.new(0, 8)
teleportCorner.Parent = teleportButton

-- 删除UI按钮（文字形式）
local deleteButton = Instance.new("TextButton")
deleteButton.Name = "DeleteButton"
deleteButton.Size = UDim2.new(0, 120, 0, 30)
deleteButton.Position = UDim2.new(0.5, -60, 1, -40)
deleteButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
deleteButton.BorderSizePixel = 0
deleteButton.Text = "删除界面"
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Font = Enum.Font.Gotham
deleteButton.TextSize = 12
deleteButton.Parent = mainFrame

-- 删除按钮圆角
local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 4)
deleteCorner.Parent = deleteButton

-- 按钮悬停效果
local function setupButtonHover(button)
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = originalColor * 1.2 -- 变亮
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
end

-- 应用悬停效果
setupButtonHover(closeButton)
setupButtonHover(teleportButton)
setupButtonHover(deleteButton)

-- 关闭按钮功能
closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled -- 切换显示/隐藏
end)

-- 删除按钮功能
deleteButton.MouseButton1Click:Connect(function()
    screenGui:Destroy() -- 完全删除UI
end)

-- 传送功能
teleportButton.MouseButton1Click:Connect(function()
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- 传送到虚空位置（Y坐标设为-500，确保低于地图）
            humanoidRootPart.CFrame = CFrame.new(0, -500, 0)
            
            -- 显示传送成功提示
            local message = Instance.new("Message")
            message.Text = "已传送到虚空！"
            message.Parent = workspace
            wait(2)
            message:Destroy()
        end
    end
end)

-- 将GUI添加到玩家界面
screenGui.Parent = playerGui

-- 可选：添加一个重新打开UI的命令（如果UI被关闭但没有删除）
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.U then -- 按U键重新打开UI
        if screenGui and not screenGui.Parent then
            screenGui.Parent = playerGui
        elseif screenGui then
            screenGui.Enabled = not screenGui.Enabled
        end
    end
end)

print("虚空传送UI已加载！按U键可以显示/隐藏界面")