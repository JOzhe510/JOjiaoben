local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local teleportLoop = nil
local isTeleportingAll = false
local teleportDistance = 2.7 -- 传送距离（身后）

-- 新增变量
local isTeleportingToLowest = false
local teleportLowestLoop = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportAllUI"
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
titleLabel.Text = "玩家传送功能"
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

-- 传送所有玩家按钮
local teleportAllToggleButton = Instance.new("TextButton")
teleportAllToggleButton.Name = "TeleportAllToggleButton"
teleportAllToggleButton.Size = UDim2.new(0, 280, 0, 50)
teleportAllToggleButton.Position = UDim2.new(0.5, -140, 0.15, 0)
teleportAllToggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
teleportAllToggleButton.BorderSizePixel = 0
teleportAllToggleButton.Text = "开启传送所有玩家"
teleportAllToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportAllToggleButton.Font = Enum.Font.GothamBold
teleportAllToggleButton.TextSize = 16
teleportAllToggleButton.Parent = mainFrame

local teleportAllCorner = Instance.new("UICorner")
teleportAllCorner.CornerRadius = UDim.new(0, 8)
teleportAllCorner.Parent = teleportAllToggleButton

-- 传送至血量最低玩家按钮
local teleportToLowestHealthButton = Instance.new("TextButton")
teleportToLowestHealthButton.Name = "TeleportToLowestHealthButton"
teleportToLowestHealthButton.Size = UDim2.new(0, 280, 0, 50)
teleportToLowestHealthButton.Position = UDim2.new(0.5, -140, 0.35, 0)
teleportToLowestHealthButton.BackgroundColor3 = Color3.fromRGB(200, 100, 80)
teleportToLowestHealthButton.BorderSizePixel = 0
teleportToLowestHealthButton.Text = "循环传送至血量最低玩家"
teleportToLowestHealthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportToLowestHealthButton.Font = Enum.Font.GothamBold
teleportToLowestHealthButton.TextSize = 16
teleportToLowestHealthButton.Parent = mainFrame

local teleportHealthCorner = Instance.new("UICorner")
teleportHealthCorner.CornerRadius = UDim.new(0, 8)
teleportHealthCorner.Parent = teleportToLowestHealthButton

-- 传送指定玩家部分
local playerSelectionFrame = Instance.new("Frame")
playerSelectionFrame.Name = "PlayerSelectionFrame"
playerSelectionFrame.Size = UDim2.new(0, 280, 0, 80)
playerSelectionFrame.Position = UDim2.new(0.5, -140, 0.55, 0)
playerSelectionFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
playerSelectionFrame.BorderSizePixel = 0
playerSelectionFrame.Parent = mainFrame

local selectionCorner = Instance.new("UICorner")
selectionCorner.CornerRadius = UDim.new(0, 8)
selectionCorner.Parent = playerSelectionFrame

local playerDropdown = Instance.new("TextBox")
playerDropdown.Name = "PlayerDropdown"
playerDropdown.Size = UDim2.new(0.7, 0, 0.4, 0)
playerDropdown.Position = UDim2.new(0.05, 0, 0.1, 0)
playerDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
playerDropdown.BorderSizePixel = 0
playerDropdown.Text = ""
playerDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
playerDropdown.Font = Enum.Font.Gotham
playerDropdown.TextSize = 12
playerDropdown.PlaceholderText = "输入玩家名称"
playerDropdown.Parent = playerSelectionFrame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 6)
dropdownCorner.Parent = playerDropdown

local teleportPlayerButton = Instance.new("TextButton")
teleportPlayerButton.Name = "TeleportPlayerButton"
teleportPlayerButton.Size = UDim2.new(0.25, 0, 0.4, 0)
teleportPlayerButton.Position = UDim2.new(0.75, 0, 0.1, 0)
teleportPlayerButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
teleportPlayerButton.BorderSizePixel = 0
teleportPlayerButton.Text = "传送该玩家"
teleportPlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportPlayerButton.Font = Enum.Font.Gotham
teleportPlayerButton.TextSize = 12
teleportPlayerButton.Parent = playerSelectionFrame

local teleportPlayerCorner = Instance.new("UICorner")
teleportPlayerCorner.CornerRadius = UDim.new(0, 6)
teleportPlayerCorner.Parent = teleportPlayerButton

local playersListLabel = Instance.new("TextLabel")
playersListLabel.Name = "PlayersListLabel"
playersListLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
playersListLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
playersListLabel.BackgroundTransparency = 1
playersListLabel.Text = "在线玩家: "
playersListLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
playersListLabel.TextXAlignment = Enum.TextXAlignment.Left
playersListLabel.Font = Enum.Font.Gotham
playersListLabel.TextSize = 10
playersListLabel.Parent = playerSelectionFrame

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
openUIButton.Text = "传送功能"
openUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openUIButton.Font = Enum.Font.Gotham
openUIButton.TextSize = 12
openUIButton.Visible = false
openUIButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openUIButton

-- 更新在线玩家列表
local function UpdatePlayersList()
    local playerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(playerNames, p.Name)
        end
    end
    playersListLabel.Text = "在线玩家: " .. table.concat(playerNames, ", ")
end

-- 初始化玩家列表
UpdatePlayersList()
Players.PlayerAdded:Connect(UpdatePlayersList)
Players.PlayerRemoving:Connect(UpdatePlayersList)

-- 传送所有玩家的循环函数
local function StartTeleportAll()
    if teleportLoop then 
        teleportLoop:Disconnect()
        teleportLoop = nil
    end

    teleportLoop = RunService.Heartbeat:Connect(function()
        local myCharacter = player.Character
        if not myCharacter then return end
        local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local otherCharacter = otherPlayer.Character
                if otherCharacter then
                    local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
                    if otherRoot then
                        -- 计算我身后的位置
                        local behindPos = myRoot.Position - myRoot.CFrame.LookVector * teleportDistance
                        otherRoot.CFrame = CFrame.new(behindPos)
                    end
                end
            end
        end
    end)
end

local function StopTeleportAll()
    if teleportLoop then
        teleportLoop:Disconnect()
        teleportLoop = nil
    end
end

-- 新增：停止传送血量最低的函数
local function StopTeleportToLowestHealth()
    if teleportLowestLoop then
        teleportLowestLoop:Disconnect()
        teleportLowestLoop = nil
    end
    isTeleportingToLowest = false
end

-- 传送指定玩家函数
local function TeleportSpecificPlayer(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    if not targetPlayer or targetPlayer == player then
        return false
    end
    
    local myCharacter = player.Character
    local targetCharacter = targetPlayer.Character
    if not myCharacter or not targetCharacter then
        return false
    end
    
    local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then
        return false
    end
    
    -- 计算我身后的位置
    local behindPos = myRoot.Position - myRoot.CFrame.LookVector * teleportDistance
    targetRoot.CFrame = CFrame.new(behindPos)
    return true
end

-- 查找血量最低的玩家
local function FindLowestHealthPlayer()
    local lowestHealth = math.huge
    local lowestHealthPlayer = nil
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local character = otherPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then -- 只考虑活着的玩家
                    if humanoid.Health < lowestHealth then
                        lowestHealth = humanoid.Health
                        lowestHealthPlayer = otherPlayer
                    end
                end
            end
        end
    end
    
    return lowestHealthPlayer
end

-- 新增：循环传送至血量最低玩家
local function StartTeleportToLowestHealth()
    if teleportLowestLoop then 
        teleportLowestLoop:Disconnect()
        teleportLowestLoop = nil
    end

    teleportLowestLoop = RunService.Heartbeat:Connect(function()
        local targetPlayer = FindLowestHealthPlayer()
        if not targetPlayer then return end
        
        local myCharacter = player.Character
        local targetCharacter = targetPlayer.Character
        if not myCharacter or not targetCharacter then return end
        
        local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not myRoot or not targetRoot then return end
        
        -- 传送到目标玩家身后
        local behindPos = targetRoot.Position - targetRoot.CFrame.LookVector * teleportDistance
        myRoot.CFrame = CFrame.new(behindPos)
    end)
end

-- 按钮悬停效果
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
setupButtonHover(teleportAllToggleButton)
setupButtonHover(teleportToLowestHealthButton)
setupButtonHover(teleportPlayerButton)
setupButtonHover(deleteButton)
setupButtonHover(openUIButton)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openUIButton.Visible = true
    StopTeleportToLowestHealth() -- 关闭时停止循环
end)

openUIButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openUIButton.Visible = false
    UpdatePlayersList() -- 刷新玩家列表
end)

deleteButton.MouseButton1Click:Connect(function()
    StopTeleportAll()
    StopTeleportToLowestHealth() -- 删除时停止循环
    screenGui:Destroy()
end)

-- 传送所有玩家切换
teleportAllToggleButton.MouseButton1Click:Connect(function()
    if isTeleportingAll then
        StopTeleportAll()
        teleportAllToggleButton.Text = "开启传送所有玩家"
        teleportAllToggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        isTeleportingAll = false
    else
        StartTeleportAll()
        teleportAllToggleButton.Text = "关闭传送所有玩家"
        teleportAllToggleButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        isTeleportingAll = true
    end
end)

-- 传送至血量最低玩家（改为循环开关）
teleportToLowestHealthButton.MouseButton1Click:Connect(function()
    if isTeleportingToLowest then
        StopTeleportToLowestHealth()
        teleportToLowestHealthButton.Text = "循环传送至血量最低玩家"
        teleportToLowestHealthButton.BackgroundColor3 = Color3.fromRGB(200, 100, 80)
    else
        StartTeleportToLowestHealth()
        teleportToLowestHealthButton.Text = "停止循环传送"
        teleportToLowestHealthButton.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
        isTeleportingToLowest = true
    end
end)

-- 传送指定玩家
teleportPlayerButton.MouseButton1Click:Connect(function()
    local playerName = playerDropdown.Text
    if playerName and playerName ~= "" then
        if TeleportSpecificPlayer(playerName) then
            playerDropdown.Text = ""
            playerDropdown.PlaceholderText = "已传送: " .. playerName
        else
            playerDropdown.PlaceholderText = "玩家不存在或无效"
        end
    end
end)

-- 输入框失去焦点时也传送
playerDropdown.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local playerName = playerDropdown.Text
        if playerName and playerName ~= "" then
            if TeleportSpecificPlayer(playerName) then
                playerDropdown.Text = ""
                playerDropdown.PlaceholderText = "已传送: " .. playerName
            else
                playerDropdown.PlaceholderText = "玩家不存在或无效"
            end
        end
    end
end)

screenGui.Parent = playerGui

print("玩家传送功能UI已加载！")