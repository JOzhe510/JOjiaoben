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

-- 创建小型开启UI按钮（初始隐藏）
local openUIButton = Instance.new("TextButton")
openUIButton.Name = "OpenUIButton"
openUIButton.Size = UDim2.new(0, 80, 0, 30)
openUIButton.Position = UDim2.new(0, 10, 0, 10)
openUIButton.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
openUIButton.BorderSizePixel = 0
openUIButton.Text = "打开菜单"
openUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openUIButton.Font = Enum.Font.Gotham
openUIButton.TextSize = 12
openUIButton.Visible = false -- 初始隐藏
openUIButton.Parent = screenGui

-- 开启按钮圆角
local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 6)
openCorner.Parent = openUIButton

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
setupButtonHover(openUIButton)

-- 关闭按钮功能
closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false -- 隐藏主界面
    openUIButton.Visible = true -- 显示开启按钮
end)

-- 开启按钮功能
openUIButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true -- 显示主界面
    openUIButton.Visible = false -- 隐藏开启按钮
end)

-- 删除按钮功能（永久删除）
deleteButton.MouseButton1Click:Connect(function()
    screenGui:Destroy() -- 完全删除UI，无法恢复
end)

-- 修正的传送功能
teleportButton.MouseButton1Click:Connect(function()
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- 确保角色存在且可以传送
            if character:FindFirstChild("Humanoid") then
                -- 使用更可靠的传送方法
                local success, errorMessage = pcall(function()
                    -- 先禁用物理特性避免拉回
                    humanoidRootPart.Anchored = true
                    
                    -- 传送到虚空位置
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-99400.13482163, -1000.1116714, 85.14746118)
                    
                    -- 等待一小会儿再取消锚定
                    wait(0.1)
                    humanoidRootPart.Anchored = false
                end)
                
                if success then
                    -- 显示传送成功提示
                    local message = Instance.new("Message")
                    message.Text = "已传送到虚空！"
                    message.Parent = workspace
                    wait(2)
                    message:Destroy()
                else
                    warn("传送失败: " .. tostring(errorMessage))
                end
            end
        else
            warn("找不到HumanoidRootPart")
        end
    else
        warn("角色不存在")
    end
end)

-- 将GUI添加到玩家界面
screenGui.Parent = playerGui

print("虚空传送UI已加载！")