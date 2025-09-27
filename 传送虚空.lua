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
mainFrame.Size = UDim2.new(0, 320, 0, 350) -- 增加高度以容纳新按钮
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -175) -- 调整位置保持居中
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

-- 存储变量
local savedPosition = nil -- 保存的传送位置
local preVoidPosition = nil -- 传送虚空前的位置
local voidPosition = CFrame.new(-9940.13482163, -100.1116714, 85.14746118) -- 虚空位置

-- 虚空传送按钮
local teleportButton = Instance.new("TextButton")
teleportButton.Name = "TeleportButton"
teleportButton.Size = UDim2.new(0, 280, 0, 50)
teleportButton.Position = UDim2.new(0.5, -140, 0.1, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
teleportButton.BorderSizePixel = 0
teleportButton.Text = "传送到虚空"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.Font = Enum.Font.GothamBold
teleportButton.TextSize = 16
teleportButton.Parent = mainFrame

-- 传送按钮圆角
local teleportCorner = Instance.new("UICorner")
teleportCorner.CornerRadius = UDim.new(0, 8)
teleportCorner.Parent = teleportButton

-- 保存当前位置按钮
local savePositionButton = Instance.new("TextButton")
savePositionButton.Name = "SavePositionButton"
savePositionButton.Size = UDim2.new(0, 280, 0, 40)
savePositionButton.Position = UDim2.new(0.5, -140, 0.3, 0)
savePositionButton.BackgroundColor3 = Color3.fromRGB(40, 100, 180)
savePositionButton.BorderSizePixel = 0
savePositionButton.Text = "保存当前位置"
savePositionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
savePositionButton.Font = Enum.Font.GothamBold
savePositionButton.TextSize = 14
savePositionButton.Parent = mainFrame

-- 保存按钮圆角
local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 6)
saveCorner.Parent = savePositionButton

-- 传送到保存位置按钮
local teleportToSavedButton = Instance.new("TextButton")
teleportToSavedButton.Name = "TeleportToSavedButton"
teleportToSavedButton.Size = UDim2.new(0, 280, 0, 40)
teleportToSavedButton.Position = UDim2.new(0.5, -140, 0.45, 0)
teleportToSavedButton.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
teleportToSavedButton.BorderSizePixel = 0
teleportToSavedButton.Text = "传送到保存位置"
teleportToSavedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportToSavedButton.Font = Enum.Font.GothamBold
teleportToSavedButton.TextSize = 14
teleportToSavedButton.Parent = mainFrame

-- 传送保存按钮圆角
local teleportSavedCorner = Instance.new("UICorner")
teleportSavedCorner.CornerRadius = UDim.new(0, 6)
teleportSavedCorner.Parent = teleportToSavedButton

-- 高度调节框架
local heightFrame = Instance.new("Frame")
heightFrame.Name = "HeightFrame"
heightFrame.Size = UDim2.new(0, 280, 0, 60)
heightFrame.Position = UDim2.new(0.5, -140, 0.65, 0)
heightFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
heightFrame.BorderSizePixel = 0
heightFrame.Parent = mainFrame

-- 高度框架圆角
local heightFrameCorner = Instance.new("UICorner")
heightFrameCorner.CornerRadius = UDim.new(0, 6)
heightFrameCorner.Parent = heightFrame

-- 高度调节标签
local heightLabel = Instance.new("TextLabel")
heightLabel.Name = "HeightLabel"
heightLabel.Size = UDim2.new(1, 0, 0, 20)
heightLabel.Position = UDim2.new(0, 0, 0, 5)
heightLabel.BackgroundTransparency = 1
heightLabel.Text = "虚空高度调节"
heightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
heightLabel.TextXAlignment = Enum.TextXAlignment.Center
heightLabel.Font = Enum.Font.Gotham
heightLabel.TextSize = 12
heightLabel.Parent = heightFrame

-- 高度增加按钮 (+)
local heightIncreaseButton = Instance.new("TextButton")
heightIncreaseButton.Name = "HeightIncreaseButton"
heightIncreaseButton.Size = UDim2.new(0, 80, 0, 30)
heightIncreaseButton.Position = UDim2.new(0.1, 0, 0.5, 0)
heightIncreaseButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
heightIncreaseButton.BorderSizePixel = 0
heightIncreaseButton.Text = "+ 高度"
heightIncreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
heightIncreaseButton.Font = Enum.Font.GothamBold
heightIncreaseButton.TextSize = 14
heightIncreaseButton.Parent = heightFrame

-- 高度减少按钮 (-)
local heightDecreaseButton = Instance.new("TextButton")
heightDecreaseButton.Name = "HeightDecreaseButton"
heightDecreaseButton.Size = UDim2.new(0, 80, 0, 30)
heightDecreaseButton.Position = UDim2.new(0.7, 0, 0.5, 0)
heightDecreaseButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
heightDecreaseButton.BorderSizePixel = 0
heightDecreaseButton.Text = "- 高度"
heightDecreaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
heightDecreaseButton.Font = Enum.Font.GothamBold
heightDecreaseButton.TextSize = 14
heightDecreaseButton.Parent = heightFrame

-- 按钮圆角
local heightButtonCorner = Instance.new("UICorner")
heightButtonCorner.CornerRadius = UDim.new(0, 4)
heightButtonCorner.Parent = heightIncreaseButton
heightButtonCorner:Clone().Parent = heightDecreaseButton

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
setupButtonHover(savePositionButton)
setupButtonHover(teleportToSavedButton)
setupButtonHover(heightIncreaseButton)
setupButtonHover(heightDecreaseButton)
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

-- 保存当前位置功能
savePositionButton.MouseButton1Click:Connect(function()
    local success, errorMessage = pcall(function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            savedPosition = character.HumanoidRootPart.CFrame
            print("位置已保存: " .. tostring(savedPosition))
        else
            error("角色或HumanoidRootPart不存在")
        end
    end)
    
    if not success then
        warn("保存位置失败: " .. tostring(errorMessage))
    else
        -- 显示保存成功的反馈
        local originalText = savePositionButton.Text
        savePositionButton.Text = "✓ 已保存"
        wait(1)
        savePositionButton.Text = originalText
    end
end)

-- 传送到保存位置功能
teleportToSavedButton.MouseButton1Click:Connect(function()
    if savedPosition then
        local success, errorMessage = pcall(function()
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = savedPosition
            else
                error("角色或HumanoidRootPart不存在")
            end
        end)
        
        if not success then
            warn("传送到保存位置失败: " .. tostring(errorMessage))
        end
    else
        warn("没有保存的位置")
    end
end)

-- 虚空传送功能（先保存当前位置）
teleportButton.MouseButton1Click:Connect(function()
    local success, errorMessage = pcall(function()
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- 保存传送前的位置
            preVoidPosition = character.HumanoidRootPart.CFrame
            -- 传送到虚空
            character.HumanoidRootPart.CFrame = voidPosition
        else
            error("角色或HumanoidRootPart不存在")
        end
    end)
    
    if not success then
        warn("传送失败: " .. tostring(errorMessage))
    end
end)

-- 高度调节功能
heightIncreaseButton.MouseButton1Click:Connect(function()
    voidPosition = voidPosition + Vector3.new(0, 10, 0) -- 增加高度
    print("虚空高度增加10单位，当前高度: " .. voidPosition.Y)
end)

heightDecreaseButton.MouseButton1Click:Connect(function()
    voidPosition = voidPosition + Vector3.new(0, -10, 0) -- 减少高度
    print("虚空高度减少10单位，当前高度: " .. voidPosition.Y)
end)

-- 死亡时自动传送回之前位置的功能
local function onCharacterAdded(character)
    -- 等待角色完全加载
    character:WaitForChild("Humanoid")
    
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if preVoidPosition then
            wait(2) -- 等待复活
            local newCharacter = game.Players.LocalPlayer.Character
            if newCharacter and newCharacter:FindFirstChild("HumanoidRootPart") then
                newCharacter.HumanoidRootPart.CFrame = preVoidPosition
                print("死亡后自动传送回之前位置")
            end
        end
    end)
end

-- 监听角色添加事件
game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- 如果角色已经存在，也设置监听
if game.Players.LocalPlayer.Character then
    onCharacterAdded(game.Players.LocalPlayer.Character)
end

-- 将GUI添加到玩家界面
screenGui.Parent = playerGui

print("虚空传送UI已加载！")