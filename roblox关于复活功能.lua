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
Frame.Size = UDim2.new(0, 280, 0, 650) -- 增加高度以容纳传送功能
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
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1000) -- 增加画布大小
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
local FollowBtn = CreateStyledButton("FollowBtn", "👥 平滑追踪")
local TeleportBtn = CreateStyledButton("TeleportBtn", "🔮 直接传送") -- 新增传送按钮
local BulletTrackBtn = CreateStyledButton("BulletTrackBtn", "🎯 子弹追踪")

-- 创建追踪功能相关的UI元素
CreateLabel("追踪目标玩家名称:")
local TargetPlayerTextBox = CreateTextBox("TargetPlayerTextBox", "输入玩家名称", "")
CreateLabel("追踪速度 (1-9999):")
local FollowSpeedTextBox = CreateTextBox("FollowSpeedTextBox", "输入速度", "100")
CreateLabel("追踪距离 (1-50):")
local FollowDistanceTextBox = CreateTextBox("FollowDistanceTextBox", "输入距离", "3")

-- 创建传送功能相关的UI元素
CreateLabel("传送高度偏移 (0-10):")
local TeleportHeightTextBox = CreateTextBox("TeleportHeightTextBox", "输入高度偏移", "1.5")
CreateLabel("传送角度偏移 (0-360):")
local TeleportAngleTextBox = CreateTextBox("TeleportAngleTextBox", "输入角度偏移", "180")

-- 创建子弹追踪相关的UI元素
CreateLabel("子弹追踪目标:")
local BulletTargetTextBox = CreateTextBox("BulletTargetTextBox", "输入玩家名称", "")
CreateLabel("追踪强度 (1-100):")
local TrackStrengthTextBox = CreateTextBox("TrackStrengthTextBox", "输入强度", "50")
CreateLabel("预测时间 (0.1-2):")
local PredictionTimeTextBox = CreateTextBox("PredictionTimeTextBox", "输入时间", "0.3")

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

-- ==================== 极致追踪玩家功能 ====================
local FollowService = {
    Enabled = false,
    TargetPlayer = nil,
    FollowSpeed = 100,
    FollowDistance = 3,
    Connection = nil,
    LastPosition = Vector3.new(0, 0, 0),
    PredictionTime = 0.1,
    SmoothingFactor = 0.8,
    Mode = "Follow", -- 新增模式: "Follow" 或 "Teleport"
    TeleportHeight = 1.5,
    TeleportAngle = 180
}

function FollowService:FindTargetPlayer(targetName)
    if targetName == "" or targetName == "自己" or targetName:lower() == "me" then
        return LocalPlayer
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) or 
           player.DisplayName:lower():find(targetName:lower()) or
           tostring(player.UserId) == targetName then
            return player
        end
    end
    return nil
end

function FollowService:PredictPosition(targetRoot, deltaTime)
    if not targetRoot then return Vector3.new(0, 0, 0) end
    
    local currentPosition = targetRoot.Position
    local velocity = targetRoot.Velocity
    local acceleration = (currentPosition - self.LastPosition - velocity * deltaTime) / (deltaTime * deltaTime)
    
    local predictedPosition = currentPosition + velocity * self.PredictionTime + 0.5 * acceleration * self.PredictionTime * self.PredictionTime
    
    self.LastPosition = currentPosition
    
    return predictedPosition
end

function FollowService:StartFollowing()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    local lastTime = tick()
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled or not self.TargetPlayer then
            return
        end
        
        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        lastTime = currentTime
        
        if not self.TargetPlayer or not self.TargetPlayer.Character then
            self:StopFollowing()
            FollowBtn.Text = "👥 平滑追踪"
            TeleportBtn.Text = "🔮 直接传送"
            self.Enabled = false
            print("目标玩家不存在或已离开游戏")
            return
        end
        
        local targetRoot = self.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        
        if not targetRoot or not localRoot then
            return
        end
        
        if self.Mode == "Teleport" then
            -- 直接传送模式 - 无抖动
            local targetCFrame = targetRoot.CFrame
            local angleRad = math.rad(self.TeleportAngle)
            
            -- 计算偏移方向
            local offsetDirection = Vector3.new(
                math.sin(angleRad) * self.FollowDistance,
                self.TeleportHeight,
                math.cos(angleRad) * self.FollowDistance
            )
            
            -- 应用旋转到偏移方向
            local rotatedOffset = targetCFrame:VectorToWorldSpace(offsetDirection)
            local targetPosition = targetRoot.Position + rotatedOffset
            
            -- 直接传送到目标位置
            localRoot.CFrame = CFrame.new(targetPosition, Vector3.new(targetRoot.Position.X, targetPosition.Y, targetRoot.Position.Z))
            
            -- 保持零速度避免物理引擎干扰
            localRoot.Velocity = Vector3.new(0, 0, 0)
            localRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            localRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        else
            -- 平滑追踪模式 (优化版)
            local predictedPosition = self:PredictPosition(targetRoot, deltaTime)
            local targetCFrame = targetRoot.CFrame
            local behindOffset = targetCFrame.LookVector * -self.FollowDistance
            local targetPosition = predictedPosition + behindOffset + Vector3.new(0, 1.5, 0)
            
            local direction = (targetPosition - localRoot.Position).Unit
            local distance = (targetPosition - localRoot.Position).Magnitude
            
            local actualSpeed = self.FollowSpeed
            if distance > 10 then
                actualSpeed = actualSpeed * 2
            elseif distance > 5 then
                actualSpeed = actualSpeed * 1.5
            end
            
            actualSpeed = math.min(actualSpeed, 9999)
            
            -- 使用更平滑的速度计算
            local smoothVelocity = self.SmoothingFactor * localRoot.Velocity + (1 - self.SmoothingFactor) * direction * actualSpeed
            
            -- 应用速度
            localRoot.Velocity = smoothVelocity
            
            -- 当距离较近时停止移动
            if distance < 1 then
                localRoot.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- 保持面向目标
            if distance > 2 then
                localRoot.CFrame = CFrame.new(localRoot.Position, Vector3.new(targetPosition.X, localRoot.Position.Y, targetPosition.Z))
            end
        end
    end)
end

function FollowService:StopFollowing()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if localRoot then
        localRoot.Velocity = Vector3.new(0, 0, 0)
        localRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        localRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    
    self.LastPosition = Vector3.new(0, 0, 0)
end

function FollowService:ToggleFollowing(mode)
    if mode then
        self.Mode = mode
    end
    
    self.Enabled = not self.Enabled
    
    if self.Enabled then
        local targetName = TargetPlayerTextBox.Text
        if targetName == "" then
            FollowBtn.Text = "👥 平滑追踪"
            TeleportBtn.Text = "🔮 直接传送"
            self.Enabled = false
            return
        end
        
        self.TargetPlayer = self:FindTargetPlayer(targetName)
        
        if not self.TargetPlayer then
            FollowBtn.Text = "👥 平滑追踪"
            TeleportBtn.Text = "🔮 直接传送"
            self.Enabled = false
            print("未找到玩家: " .. targetName)
            return
        end
        
        local speed = tonumber(FollowSpeedTextBox.Text)
        if speed then
            self.FollowSpeed = math.clamp(speed, 1, 9999)
        end
        
        local distance = tonumber(FollowDistanceTextBox.Text)
        if distance then
            self.FollowDistance = math.clamp(distance, 1, 50)
        end
        
        -- 获取传送参数
        local height = tonumber(TeleportHeightTextBox.Text)
        if height then
            self.TeleportHeight = math.clamp(height, 0, 10)
        end
        
        local angle = tonumber(TeleportAngleTextBox.Text)
        if angle then
            self.TeleportAngle = math.clamp(angle, 0, 360)
        end
        
        if self.Mode == "Teleport" then
            TeleportBtn.Text = "🛑 停止传送"
            FollowBtn.Text = "👥 平滑追踪"
        else
            FollowBtn.Text = "🛑 停止追踪"
            TeleportBtn.Text = "🔮 直接传送"
        end
        
        self:StartFollowing()
        print("开始" .. (self.Mode == "Teleport" and "传送" or "追踪") .. ": " .. self.TargetPlayer.Name)
    else
        FollowBtn.Text = "👥 平滑追踪"
        TeleportBtn.Text = "🔮 直接传送"
        self:StopFollowing()
        print("停止" .. (self.Mode == "Teleport" and "传送" or "追踪"))
    end
end

-- 追踪按钮功能
FollowBtn.MouseButton1Click:Connect(function()
    if FollowService.Enabled and FollowService.Mode == "Follow" then
        FollowService:ToggleFollowing()
    else
        FollowService:ToggleFollowing("Follow")
    end
end)

-- 传送按钮功能
TeleportBtn.MouseButton1Click:Connect(function()
    if FollowService.Enabled and FollowService.Mode == "Teleport" then
        FollowService:ToggleFollowing()
    else
        FollowService:ToggleFollowing("Teleport")
    end
end)

-- ==================== 极致子弹追踪功能 ====================
local BulletTrackService = {
    Enabled = false,
    TargetPlayer = nil,
    TrackStrength = 50,
    PredictionTime = 0.3,
    Connection = nil,
    BulletConnections = {},
    DetectedGuns = {},
    LastFireTime = 0
}

-- 自动检测武器系统
function BulletTrackService:DetectWeaponSystems()
    self.DetectedGuns = {}
    
    -- 检测常见的武器类型
    local weaponTypes = {
        "Gun", "Weapon", "Firearm", "Rifle", "Pistol", "Shotgun", 
        "SMG", "Sniper", "Revolver", "Launcher", "Blaster"
    }
    
    -- 检测本地玩家手中的武器
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                for _, weaponType in ipairs(weaponTypes) do
                    if tool.Name:lower():find(weaponType:lower()) then
                        table.insert(self.DetectedGuns, tool)
                        print("检测到武器: " .. tool.Name)
                        break
                    end
                end
            end
        end
    end
    
    -- 检测工作区中的武器
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            for _, weaponType in ipairs(weaponTypes) do
                if obj.Name:lower():find(weaponType:lower()) then
                    table.insert(self.DetectedGuns, obj)
                    break
                end
            end
        end
    end
    
    return #self.DetectedGuns > 0
end

-- 查找子弹发射函数
function BulletTrackService:FindFireFunction(tool)
    if not tool then return nil end
    
    -- 检查工具中的脚本
    for _, script in ipairs(tool:GetDescendants()) do
        if script:IsA("Script") or script:IsA("LocalScript") then
            local source = script.Source
            if source then
                -- 查找常见的发射函数
                local firePatterns = {
                    "fire", "shoot", "Fire", "Shoot", "FireBullet", "ShootBullet",
                    "RemoteEvent", "FireServer", "InvokeServer"
                }
                
                for _, pattern in ipairs(firePatterns) do
                    if source:find(pattern) then
                        return script
                    end
                end
            end
        end
    end
    
    return nil
end

-- 拦截子弹发射
function BulletTrackService:InterceptBullets()
    for _, gun in ipairs(self.DetectedGuns) do
        local fireScript = self:FindFireFunction(gun)
        if fireScript then
            -- 保存原始函数
            local originalSource = fireScript.Source
            
            -- 修改脚本以添加追踪
            local modifiedSource = originalSource:gsub("function%s+([%w_]+)%s*%(", function(funcName)
                return "function " .. funcName .. "("
            end)
            
            -- 这里需要更复杂的脚本修改逻辑，实际应用中需要根据具体游戏定制
            print("找到武器脚本: " .. gun.Name)
        end
    end
end

-- 物理子弹追踪
function BulletTrackService:TrackPhysicalBullets()
    -- 监听新创建的子弹
    workspace.DescendantAdded:Connect(function(descendant)
        if not self.Enabled or not self.TargetPlayer then return end
        
        -- 检测常见的子弹类型
        local bulletNames = {"Bullet", "Projectile", "Shot", "Shell", "Missile", "Rocket"}
        local isBullet = false
        
        for _, name in ipairs(bulletNames) do
            if descendant.Name:lower():find(name:lower()) then
                isBullet = true
                break
            end
        end
        
        if isBullet and descendant:IsA("BasePart") then
            -- 追踪这个子弹
            self:TrackSingleBullet(descendant)
        end
    end)
end

-- 追踪单个子弹
function BulletTrackService:TrackSingleBullet(bullet)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled or not self.TargetPlayer or not bullet or not bullet.Parent then
            if connection then
                connection:Disconnect()
            end
            return
        end
        
        if not self.TargetPlayer.Character then
            if connection then
                connection:Disconnect()
            end
            return
        end
        
        local targetRoot = self.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            if connection then
                connection:Disconnect()
            end
            return
        end
        
        -- 计算预测位置
        local bulletPosition = bullet.Position
        local targetPosition = targetRoot.Position + Vector3.new(0, 1.5, 0) -- 瞄准胸部高度
        local targetVelocity = targetRoot.Velocity
        
        -- 计算子弹到目标的向量
        local toTarget = targetPosition - bulletPosition
        local distance = toTarget.Magnitude
        
        -- 预测目标移动
        local timeToHit = distance / (bullet.Velocity.Magnitude + 0.001)
        local predictedPosition = targetPosition + targetVelocity * timeToHit
        
        -- 计算追踪方向
        local trackDirection = (predictedPosition - bulletPosition).Unit
        
        -- 应用追踪（根据强度调整）
        local strengthFactor = self.TrackStrength / 100
        local newVelocity = bullet.Velocity:Lerp(trackDirection * bullet.Velocity.Magnitude, strengthFactor)
        
        -- 应用新的速度
        bullet.Velocity = newVelocity
        
        -- 如果子弹距离目标很近，停止追踪
        if distance < 2 then
            if connection then
                connection:Disconnect()
            end
        end
    end)
    
    table.insert(self.BulletConnections, connection)
end

-- 光线投射武器追踪
function BulletTrackService:TrackRaycastWeapons()
    -- 监听远程事件（常见的射击游戏通信方式）
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:lower():find("fire") or obj.Name:lower():find("shoot") then
                local originalFire = obj.FireServer
                obj.FireServer = function(self, ...)
                    if BulletTrackService.Enabled and BulletTrackService.TargetPlayer then
                        local args = {...}
                        -- 这里可以修改射击参数来实现追踪
                        print("拦截到射击事件")
                    end
                    return originalFire(self, ...)
                end
            end
        end
    end
end

function BulletTrackService:FindTargetPlayer(targetName)
    if targetName == "" or targetName == "自己" or targetName:lower() == "me" then
        return LocalPlayer
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) or 
           player.DisplayName:lower():find(targetName:lower()) or
           tostring(player.UserId) == targetName then
            return player
        end
    end
    return nil
end

function BulletTrackService:StartTracking()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    -- 清空之前的连接
    for _, conn in ipairs(self.BulletConnections) do
        conn:Disconnect()
    end
    self.BulletConnections = {}
    
    -- 自动检测武器系统
    local hasWeapons = self:DetectWeaponSystems()
    if not hasWeapons then
        print("未检测到武器系统，使用通用追踪方法")
    end
    
    -- 启动多种追踪方式
    self:TrackPhysicalBullets()
    self:TrackRaycastWeapons()
    self:InterceptBullets()
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled or not self.TargetPlayer then return end
        
        -- 主循环用于处理各种追踪逻辑
    end)
end

function BulletTrackService:StopTracking()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    for _, conn in ipairs(self.BulletConnections) do
        conn:Disconnect()
    end
    self.BulletConnections = {}
end

function BulletTrackService:ToggleTracking()
    self.Enabled = not self.Enabled
    
    if self.Enabled then
        local targetName = BulletTargetTextBox.Text
        if targetName == "" then
            BulletTrackBtn.Text = "🎯 子弹追踪"
            self.Enabled = false
            return
        end
        
        self.TargetPlayer = self:FindTargetPlayer(targetName)
        
        if not self.TargetPlayer then
            BulletTrackBtn.Text = "🎯 子弹追踪"
            self.Enabled = false
            print("未找到玩家: " .. targetName)
            return
        end
        
        local strength = tonumber(TrackStrengthTextBox.Text)
        if strength then
            self.TrackStrength = math.clamp(strength, 1, 100)
        end
        
        local prediction = tonumber(PredictionTimeTextBox.Text)
        if prediction then
            self.PredictionTime = math.clamp(prediction, 0.1, 2)
        end
        
        BulletTrackBtn.Text = "🛑 停止追踪"
        self:StartTracking()
        print("开始子弹追踪: " .. self.TargetPlayer.Name)
        print("追踪强度: " .. self.TrackStrength)
        print("预测时间: " .. self.PredictionTime)
    else
        BulletTrackBtn.Text = "🎯 子弹追踪"
        self:StopTracking()
        print("停止子弹追踪")
    end
end

-- 子弹追踪按钮功能
BulletTrackBtn.MouseButton1Click:Connect(function()
    BulletTrackService:ToggleTracking()
end)

-- 玩家离开时自动停止追踪
Players.PlayerRemoving:Connect(function(player)
    if FollowService.Enabled and FollowService.TargetPlayer == player then
        FollowService.Enabled = false
        FollowService:StopFollowing()
        FollowBtn.Text = "👥 平滑追踪"
        TeleportBtn.Text = "🔮 直接传送"
        print("目标玩家已离开游戏，停止追踪")
    end
    
    if BulletTrackService.Enabled and BulletTrackService.TargetPlayer == player then
        BulletTrackService.Enabled = false
        BulletTrackService:StopTracking()
        BulletTrackBtn.Text = "🎯 子弹追踪"
        print("目标玩家已离开游戏，停止子弹追踪")
    end
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
    Frame.Size = isExpanded and UDim2.new(0, 280, 0, 650) or UDim2.new(0, 280, 0, 32)
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
        Frame.Size = isExpanded and UDim2.new(0, 280, 0, 650) or UDim2.new(0, 280, 0, 32)
        ScrollFrame.Visible = isExpanded
    elseif input.KeyCode == Enum.KeyCode.F and FollowService.Enabled and FollowService.Mode == "Follow" then
        FollowService.Enabled = false
        FollowService:StopFollowing()
        FollowBtn.Text = "👥 平滑追踪"
        print("快捷键停止追踪")
    elseif input.KeyCode == Enum.KeyCode.T and FollowService.Enabled and FollowService.Mode == "Teleport" then
        FollowService.Enabled = false
        FollowService:StopFollowing()
        TeleportBtn.Text = "🔮 直接传送"
        print("快捷键停止传送")
    elseif input.KeyCode == Enum.KeyCode.B and BulletTrackService.Enabled then
        BulletTrackService.Enabled = false
        BulletTrackService:StopTracking()
        BulletTrackBtn.Text = "🎯 子弹追踪"
        print("快捷键停止子弹追踪")
    end
end)

-- 角色死亡时自动停止追踪
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if FollowService.Enabled then
            FollowService.Enabled = false
            FollowService:StopFollowing()
            FollowBtn.Text = "👥 平滑追踪"
            TeleportBtn.Text = "🔮 直接传送"
            print("角色死亡，停止追踪")
        end
        
        if BulletTrackService.Enabled then
            BulletTrackService.Enabled = false
            BulletTrackService:StopTracking()
            BulletTrackBtn.Text = "🎯 子弹追踪"
            print("角色死亡，停止子弹追踪")
        end
    end)
end)

print("🔮 功能菜单加载完成！")
print("快捷键: U-隐藏/显示UI, F-停止追踪, T-停止传送, B-停止子弹追踪")
print("追踪功能已改进：新增直接传送模式，无抖动")