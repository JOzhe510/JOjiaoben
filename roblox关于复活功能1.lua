local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔥 终极功能系统",
   LoadingTitle = "自瞄+复活功能系统",
   LoadingSubtitle = "by 1_F0",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "终极功能"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

-- ==================== 自瞄功能部分 ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- 自瞄参数设置
local AimSettings = {
    FOV = 90,
    Prediction = 0.15,
    Smoothness = 0.9,
    Enabled = false,
    LockedTarget = nil,
    LockSingleTarget = false,
    ESPEnabled = true,
    WallCheck = true,
    PredictionEnabled = true,
    AimMode = "Camera",
    TeamCheck = true,
    NearestAim = false
}

local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Radius = AimSettings.FOV
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 2
Circle.Position = ScreenCenter
Circle.Transparency = 1
Circle.NumSides = 64
Circle.Filled = false

local TargetHistory = {}
local ESPHighlights = {}
local ESPLabels = {}
local ESPConnections = {}

-- 队友检测功能
local function IsEnemy(player)
    if not AimSettings.TeamCheck then
        return true
    end
    
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    
    local success, isFriend = pcall(function()
        return player:IsFriendsWith(LocalPlayer.UserId)
    end)
    
    if success and isFriend then
        return false
    end
    
    return true
end

-- 清理ESP资源
local function ClearESP()
    for _, highlight in pairs(ESPHighlights) do
        if highlight then
            pcall(function() highlight:Destroy() end)
        end
    end
    ESPHighlights = {}
    
    for _, espData in pairs(ESPLabels) do
        if espData and espData.nameLabel then
            pcall(function() espData.nameLabel:Remove() end)
        end
        if espData and espData.healthLabel then
            pcall(function() espData.healthLabel:Remove() end)
        end
    end
    ESPLabels = {}
    
    for player, connections in pairs(ESPConnections) do
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
    end
    ESPConnections = {}
end

-- 为角色创建ESP
local function CreateESPForCharacter(player, character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not head then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = CoreGui
    
    local nameLabel = Drawing.new("Text")
    nameLabel.Visible = false
    nameLabel.Color = Color3.fromRGB(255, 255, 255)
    nameLabel.Size = 14
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameLabel.ZIndex = 2
    
    local healthLabel = Drawing.new("Text")
    healthLabel.Visible = false
    healthLabel.Color = Color3.fromRGB(255, 100, 100)
    healthLabel.Size = 12
    healthLabel.Center = true
    healthLabel.Outline = true
    healthLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    healthLabel.ZIndex = 2
    
    local function updateESP()
        if not character:IsDescendantOf(workspace) or humanoid.Health <= 0 then
            highlight.Enabled = false
            nameLabel.Visible = false
            healthLabel.Visible = false
            return
        end
        
        local headPos, headVisible = Camera:WorldToViewportPoint(head.Position)
        
        if headVisible then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            highlight.FillColor = Color3.fromRGB(
                255 * (1 - healthPercent),
                255 * healthPercent,
                0
            )
            highlight.Enabled = true
            
            nameLabel.Text = player.Name
            nameLabel.Position = Vector2.new(headPos.X, headPos.Y - 40)
            
            healthLabel.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            healthLabel.Position = Vector2.new(headPos.X, headPos.Y - 25)
            
            nameLabel.Visible = true
            healthLabel.Visible = true
        else
            highlight.Enabled = false
            nameLabel.Visible = false
            healthLabel.Visible = false
        end
    end
    
    local espId = player.UserId
    ESPHighlights[espId] = highlight
    ESPLabels[espId] = {
        nameLabel = nameLabel, 
        healthLabel = healthLabel, 
        update = updateESP, 
        player = player
    }
    
    updateESP()
    
    local humanoidDiedConn = humanoid.Died:Connect(function()
        highlight.Enabled = false
        nameLabel.Visible = false
        healthLabel.Visible = false
    end)
    
    local humanoidHealthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health > 0 then
            updateESP()
        else
            highlight.Enabled = false
            nameLabel.Visible = false
            healthLabel.Visible = false
        end
    end)
    
    if not ESPConnections[player] then
        ESPConnections[player] = {}
    end
    table.insert(ESPConnections[player], humanoidDiedConn)
    table.insert(ESPConnections[player], humanoidHealthConn)
end

-- ESP功能
local function UpdateESP()
    ClearESP()
    
    if not AimSettings.ESPEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) then
            local connections = {}
            
            local characterAddedConn = player.CharacterAdded:Connect(function(character)
                task.wait(0.5)
                if AimSettings.ESPEnabled and IsEnemy(player) then
                    CreateESPForCharacter(player, character)
                end
            end)
            
            table.insert(connections, characterAddedConn)
            
            local characterRemovingConn = player.CharacterRemoving:Connect(function()
                local espId = player.UserId
                if ESPHighlights[espId] then
                    pcall(function() ESPHighlights[espId]:Destroy() end)
                    ESPHighlights[espId] = nil
                end
                if ESPLabels[espId] then
                    pcall(function() 
                        ESPLabels[espId].nameLabel:Remove()
                        ESPLabels[espId].healthLabel:Remove()
                    end)
                    ESPLabels[espId] = nil
                end
            end)
            
            table.insert(connections, characterRemovingConn)
            
            ESPConnections[player] = connections
            
            if player.Character and AimSettings.ESPEnabled and IsEnemy(player) then
                CreateESPForCharacter(player, player.Character)
            end
        end
    end
end

-- 预判算法
local function CalculatePredictedPosition(target)
    if not target or not AimSettings.PredictionEnabled then
        return target and target.Position or nil
    end
    
    local head = target.Parent:FindFirstChild("Head")
    if not head then
        return target.Position
    end
    
    local distance = (head.Position - Camera.CFrame.Position).Magnitude
    local travelTime = distance / 1000
    
    local velocityOffset = target.Velocity * travelTime * AimSettings.Prediction
    
    return head.Position + velocityOffset
end

-- 双模式瞄准系统
local function AimAtPosition(position)
    if not position then return end
    
    if AimSettings.AimMode == "Camera" then
        local cameraPos = Camera.CFrame.Position
        local direction = (position - cameraPos).Unit
        local currentDirection = Camera.CFrame.LookVector
        local newDirection = (currentDirection * (1 - AimSettings.Smoothness) + direction * AimSettings.Smoothness).Unit
        
        Camera.CFrame = CFrame.new(cameraPos, cameraPos + newDirection)
    else
        local screenPos, visible = Camera:WorldToViewportPoint(position)
        if visible then
            local mousePos = UIS:GetMouseLocation()
            local targetPos = Vector2.new(screenPos.X, screenPos.Y)
            local delta = (targetPos - mousePos) * AimSettings.Smoothness * 0.5
            
            pcall(function()
                mousemoverel(delta.X, delta.Y)
            end)
        end
    end
end

-- 视角对准的目标选择
local function FindTargetInView()
    local bestTarget = nil
    local closestAngle = math.rad(AimSettings.FOV / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsEnemy(player) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                local cameraDirection = Camera.CFrame.LookVector
                local targetDirection = (head.Position - Camera.CFrame.Position).Unit
                local dotProduct = cameraDirection:Dot(targetDirection)
                local angle = math.acos(math.clamp(dotProduct, -1, 1))
                
                if angle <= closestAngle then
                    if AimSettings.WallCheck then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (head.Position - rayOrigin).Unit * (head.Position - rayOrigin).Magnitude
                        
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        raycastParams.IgnoreWater = true
                        
                        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                        if raycastResult then
                            local hitPart = raycastResult.Instance
                            if not hitPart:IsDescendantOf(player.Character) then
                                continue
                            end
                        end
                    end
                    
                    closestAngle = angle
                    bestTarget = head
                end
            end
        end
    end
    
    return bestTarget
end

-- 近距离目标选择
local function FindNearestTarget()
    local nearestTarget = nil
    local minDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsEnemy(player) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                local distance = (head.Position - Camera.CFrame.Position).Magnitude
                
                if distance < minDistance then
                    if AimSettings.WallCheck then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (head.Position - rayOrigin).Unit * (head.Position - rayOrigin).Magnitude
                        
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        raycastParams.IgnoreWater = true
                        
                        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                        if raycastResult then
                            local hitPart = raycastResult.Instance
                            if not hitPart:IsDescendantOf(player.Character) then
                                continue
                            end
                        end
                    end
                    
                    minDistance = distance
                    nearestTarget = head
                end
            end
        end
    end
    
    return nearestTarget
end

-- 名字锁定功能
local function LockTargetByName(playerName)
    for _, player in pairs(Players:GetPlayers()) do
        if (player.Name:lower():find(playerName:lower()) or player.DisplayName:lower():find(playerName:lower())) and IsEnemy(player) then
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    AimSettings.LockedTarget = head
                    AimSettings.LockSingleTarget = true
                    return true
                end
            end
        end
    end
    AimSettings.LockedTarget = nil
    return false
end

-- 检查目标是否有效
local function IsTargetValid(target)
    if not target then return false end
    
    if not target:IsDescendantOf(workspace) then
        return false
    end
    
    local humanoid = target.Parent:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    return true
end

-- 自瞄主循环
RunService.RenderStepped:Connect(function()
    Circle.Position = ScreenCenter
    Circle.Radius = AimSettings.FOV
    
    for _, espData in pairs(ESPLabels) do
        if espData and espData.update then
            espData.update()
        end
    end
    
    if not AimSettings.Enabled then return end
    
    if AimSettings.LockedTarget and AimSettings.LockSingleTarget then
        if not IsTargetValid(AimSettings.LockedTarget) then
            AimSettings.LockedTarget = nil
        end
    end
    
    if not AimSettings.LockedTarget or not AimSettings.LockSingleTarget then
        if AimSettings.NearestAim then
            AimSettings.LockedTarget = FindNearestTarget()
        else
            AimSettings.LockedTarget = FindTargetInView()
        end
    end
    
    if AimSettings.LockedTarget then
        local predictedPosition = CalculatePredictedPosition(AimSettings.LockedTarget)
        AimAtPosition(predictedPosition)
    end
end)

-- 玩家加入/离开事件
Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    UpdateESP()
end)

Players.PlayerRemoving:Connect(function(player)
    local espId = player.UserId
    if ESPHighlights[espId] then
        pcall(function() ESPHighlights[espId]:Destroy() end)
        ESPHighlights[espId] = nil
    end
    if ESPLabels[espId] then
        pcall(function() 
            ESPLabels[espId].nameLabel:Remove()
            ESPLabels[espId].healthLabel:Remove()
        end)
        ESPLabels[espId] = nil
    end
    
    if ESPConnections[player] then
        for _, connection in ipairs(ESPConnections[player]) do
            pcall(function() connection:Disconnect() end)
        end
        ESPConnections[player] = nil
    end
end)

-- 初始更新
UpdateESP()

-- ==================== 复活功能部分 ====================
local respawnService = {
    autoRespawn = false,
    followPlayer = nil,
    following = false,
    teleporting = false,
    -- 新增旋转追踪模式
    rotating = false,
    rotationSpeed = 500, -- 旋转速度 (度/秒)
    rotationRadius = 5, -- 旋转半径
    rotationHeight = 0, -- 旋转高度
    currentRotationAngle = 0, -- 当前旋转角度
    followSpeed = 500,
    followDistance = 3.9,
    followHeight = 0,
    followPosition = 0,
    savedPositions = {},
    followConnection = nil,
    teleportConnection = nil,
    autoFindNearest = false,
    speedMode = "normal",
    walkSpeed = 16,
    tpWalkSpeed = 100,
    predictionEnabled = true,
    smoothingFactor = 0.2,
    maxPredictionTime = 0.3,
    velocityMultiplier = 2,
    lastTargetPositions = {},
    lastUpdateTime = tick(),
}

local playerButtons = {}

local function CalculateFollowPosition(targetRoot, distance, angle, height)
    local angleRad = math.rad(angle)
    
    local lookVector = targetRoot.CFrame.LookVector
    local rightVector = targetRoot.CFrame.RightVector
    
    local forwardOffset = -math.cos(angleRad) * distance
    local rightOffset = math.sin(angleRad) * distance
    
    local offset = (lookVector * forwardOffset) + (rightVector * rightOffset) + Vector3.new(0, height, 0)
    
    return targetRoot.Position + offset
end

local function ForceLookAtTarget(localRoot, targetRoot)
    if localRoot and targetRoot then
        local direction = (targetRoot.Position - localRoot.Position).Unit
        localRoot.CFrame = CFrame.new(localRoot.Position, localRoot.Position + direction)
    end
end

local function IsPlayerValid(playerName)
    if not playerName or playerName == "" then
        return false
    end
    return Players:FindFirstChild(playerName) ~= nil
end

local function GetNearestPlayer()
    local localChar = LocalPlayer.Character
    if not localChar then return nil end
    
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end

local function AutoSelectNearestPlayer()
    local nearestPlayer = GetNearestPlayer()
    if nearestPlayer then
        respawnService.followPlayer = nearestPlayer.Name
        currentPlayerLabel:Set("当前选择: " .. nearestPlayer.Name .. " (自动)")
        return true
    end
    return false
end

local function PredictTargetPosition(targetRoot, targetVelocity)
    if not respawnService.predictionEnabled or not targetVelocity then
        return targetRoot.Position
    end
    
    local predictionTime = math.min(
        respawnService.maxPredictionTime,
        respawnService.followDistance / math.max(targetVelocity.Magnitude, 1)
    )
    
    return targetRoot.Position + (targetVelocity * predictionTime * respawnService.velocityMultiplier)
end

local function SmoothMove(localRoot, targetPosition, alpha)
    local currentPosition = localRoot.Position
    local smoothedPosition = currentPosition:Lerp(targetPosition, alpha)
    localRoot.CFrame = CFrame.new(smoothedPosition)
end

local function GetTargetVelocity(targetRoot)
    local currentTime = tick()
    local elapsedTime = currentTime - respawnService.lastUpdateTime
    
    if elapsedTime <= 0 then
        return Vector3.new(0, 0, 0)
    end
    
    if not respawnService.lastTargetPositions[targetRoot] then
        respawnService.lastTargetPositions[targetRoot] = targetRoot.Position
        respawnService.lastUpdateTime = currentTime
        return Vector3.new(0, 0, 0)
    end
    
    local lastPosition = respawnService.lastTargetPositions[targetRoot]
    local velocity = (targetRoot.Position - lastPosition) / elapsedTime
    
    respawnService.lastTargetPositions[targetRoot] = targetRoot.Position
    respawnService.lastUpdateTime = currentTime
    
    return velocity
end

-- 创建主标签页
local MainTab = Window:CreateTab("🏠 主要功能", nil)

-- 自瞄系统部分
local MainSection = MainTab:CreateSection("自瞄系统")

local Toggle = MainTab:CreateToggle({
   Name = "开启自瞄",
   CurrentValue = false,
   Callback = function(Value)
        AimSettings.Enabled = Value
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "瞄准模式: 相机",
   CurrentValue = true,
   Callback = function(Value)
        AimSettings.AimMode = Value and "Camera" or "Viewport"
        AimModeToggle:Set("瞄准模式: " .. (Value and "相机" or "视角"))
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "开启ESP",
   CurrentValue = true,
   Callback = function(Value)
        AimSettings.ESPEnabled = Value
        UpdateESP()
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "穿墙检测",
   CurrentValue = true,
   Callback = function(Value)
        AimSettings.WallCheck = Value
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "队友检测",
   CurrentValue = true,
   Callback = function(Value)
        AimSettings.TeamCheck = Value
        UpdateESP()
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "预判模式",
   CurrentValue = true,
   Callback = function(Value)
        AimSettings.PredictionEnabled = Value
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "单锁模式",
   CurrentValue = false,
   Callback = function(Value)
        AimSettings.LockSingleTarget = Value
        if not Value then
            AimSettings.LockedTarget = nil
        end
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "FOV圆圈",
   CurrentValue = true,
   Callback = function(Value)
        Circle.Visible = Value
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "近距离自瞄",
   CurrentValue = false,
   Callback = function(Value)
        AimSettings.NearestAim = Value
        if Value then
            AimSettings.LockSingleTarget = false
            SingleTargetToggle:Set(false)
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "FOV范围",
   PlaceholderText = "输入FOV范围 (默认: 90)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            AimSettings.FOV = value
            Circle.Radius = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "预判系数",
   PlaceholderText = "输入预判系数 (默认: 0.15)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0 then
            AimSettings.Prediction = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "名字锁定",
   PlaceholderText = "输入玩家名字锁定",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        if Text ~= "" then
            if LockTargetByName(Text) then
                AimSettings.LockSingleTarget = true
                SingleTargetToggle:Set(true)
            end
        end
   end,
})

local Button = MainTab:CreateButton({
   Name = "取消名字锁定",
   Callback = function()
        AimSettings.LockedTarget = nil
        AimSettings.LockSingleTarget = false
        SingleTargetToggle:Set(false)
   end,
})

-- 复活系统部分
local MainTab = Window:CreateTab("😱追踪功能", nil)

local MainSection = MainTab:CreateSection("复活系统")

local Button = MainTab:CreateButton({
   Name = "立即自杀",
   Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "原地复活",
   CurrentValue = false,
   Callback = function()
        local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

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

-- 原地复活按钮功能（如果需要按钮触发）
local function RespawnAtSavedPosition()
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
end

-- 如果需要键盘快捷键触发复活
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then -- 按R键触发原地复活
        RespawnAtSavedPosition()
    end
end)

-- 导出函数供其他脚本使用
return {
    RespawnAtSavedPosition = RespawnAtSavedPosition,
    respawnService = respawnService
}
   end,
})

-- 玩家选择部分
local MainSection = MainTab:CreateSection("选择玩家")

local currentPlayerLabel = MainTab:CreateLabel("当前选择: 无")

local Button = MainTab:CreateButton({
   Name = "刷新选择的玩家",
   Callback = function()
        if respawnService.following then
            respawnService.following = false
            if respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
        end
        
        if respawnService.teleporting then
            respawnService.teleporting = false
            if respawnService.teleportConnection then
                respawnService.teleportConnection:Disconnect()
                respawnService.teleportConnection = nil
            end
        end
        
        respawnService.followPlayer = nil
        currentPlayerLabel:Set("当前选择: 无")
   end,
})

function UpdatePlayerButtons()
    for _, button in ipairs(playerButtons) do
        button:Destroy()
    end
    playerButtons = {}
    
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    
    if respawnService.followPlayer and not IsPlayerValid(respawnService.followPlayer) then
        respawnService.followPlayer = nil
        currentPlayerLabel:Set("当前选择: 无")
        
        if respawnService.following then
            respawnService.following = false
            if respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
        end
        
        if respawnService.teleporting then
            respawnService.teleporting = false
            if respawnService.teleportConnection then
                respawnService.teleportConnection:Disconnect()
                respawnService.teleportConnection = nil
            end
        end
    end
    
    for _, playerName in ipairs(players) do
        local button = MainTab:CreateButton({
            Name = "选择: " .. playerName,
            Callback = function()
                if IsPlayerValid(playerName) then
                    respawnService.followPlayer = playerName
                    currentPlayerLabel:Set("当前选择: " .. playerName)
                else
                    UpdatePlayerButtons()
                end
            end,
        })
        table.insert(playerButtons, button)
    end
    
    if #players == 0 then
        local label = MainTab:CreateLabel("当前没有其他玩家在线")
        table.insert(playerButtons, label)
    end
end

local Button = MainTab:CreateButton({
   Name = "刷新玩家列表",
   Callback = function()
        UpdatePlayerButtons()
   end,
})

local Button = MainTab:CreateButton({
   Name = "自动选择最近玩家",
   Callback = function()
        if AutoSelectNearestPlayer() then
        else
        end
   end,
})

-- 追踪功能
local Toggle = MainTab:CreateToggle({
   Name = "平滑追踪",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.following = Value
        
        if respawnService.followConnection then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
        end
        
        if respawnService.following then
            if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
                if not AutoSelectNearestPlayer() then
                    respawnService.following = false
                    return
                end
            end
            
            respawnService.followConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.following then return end
                
                if not IsPlayerValid(respawnService.followPlayer) then
                    if not AutoSelectNearestPlayer() then
                        respawnService.following = false
                        return
                    end
                end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not targetPlayer then return end
                
                local targetChar = targetPlayer.Character
                local localChar = LocalPlayer.Character
                
                if not targetChar or not localChar then return end
                
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                
                if targetRoot and localRoot then
                    local targetVelocity = GetTargetVelocity(targetRoot)
                    local predictedPosition = PredictTargetPosition(targetRoot, targetVelocity)
                    
                    local targetPosition = CalculateFollowPosition(
                        targetRoot, 
                        respawnService.followDistance, 
                        respawnService.followPosition, 
                        respawnService.followHeight
                    )
                    
                    SmoothMove(localRoot, targetPosition, respawnService.smoothingFactor)
                    ForceLookAtTarget(localRoot, targetRoot)
                end
            end)
        end
   end,
})

-- 旋转追踪功能
local Toggle = MainTab:CreateToggle({
   Name = "旋转追踪模式",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.rotating = Value
        
        if respawnService.rotationConnection then
            respawnService.rotationConnection:Disconnect()
            respawnService.rotationConnection = nil
        end
        
        -- 如果开启旋转追踪，关闭其他追踪模式
        if respawnService.rotating then
            respawnService.following = false
            respawnService.teleporting = false
            
            if respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
            
            if respawnService.teleportConnection then
                respawnService.teleportConnection:Disconnect()
                respawnService.teleportConnection = nil
            end
            
            if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
                if not AutoSelectNearestPlayer() then
                    respawnService.rotating = false
                    return
                end
            end
            
            respawnService.rotationConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.rotating then return end
                
                if not IsPlayerValid(respawnService.followPlayer) then
                    if not AutoSelectNearestPlayer() then
                        respawnService.rotating = false
                        return
                    end
                end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not targetPlayer then return end
                local targetChar = targetPlayer.Character
                local localChar = LocalPlayer.Character
                
                if not targetChar or not localChar then return end
                
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                
                if targetRoot and localRoot then
                    -- 更新旋转角度
                    respawnService.currentRotationAngle = (respawnService.currentRotationAngle + respawnService.rotationSpeed * 0.016) % 360
                    
                    -- 计算旋转位置
                    local angleRad = math.rad(respawnService.currentRotationAngle)
                    local offsetX = math.cos(angleRad) * respawnService.rotationRadius
                    local offsetZ = math.sin(angleRad) * respawnService.rotationRadius
                    
                    local targetPosition = targetRoot.Position + Vector3.new(
                        offsetX,
                        respawnService.rotationHeight,
                        offsetZ
                    )
                    
                    -- 平滑移动到旋转位置
                    SmoothMove(localRoot, targetPosition, respawnService.smoothingFactor)
                    
                    -- 始终面向目标
                    ForceLookAtTarget(localRoot, targetRoot)
                end
            end)
        end
   end,
})

-- 传送功能
local Toggle = MainTab:CreateToggle({
   Name = "直接传送",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.teleporting = Value
        
        if respawnService.teleportConnection then
            respawnService.teleportConnection:Disconnect()
            respawnService.teleportConnection = nil
        end
        
        if respawnService.teleporting then
            if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
                if not AutoSelectNearestPlayer() then
                    respawnService.teleporting = false
                    return
                end
            end
            
            respawnService.teleportConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.teleporting then return end
                
                if not IsPlayerValid(respawnService.followPlayer) then
                    if not AutoSelectNearestPlayer() then
                        respawnService.teleporting = false
                        return
                    end
                end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not targetPlayer then return end
                
                local targetChar = targetPlayer.Character
                local localChar = LocalPlayer.Character
                
                if not targetChar or not localChar then return end
                
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                
                if targetRoot and localRoot then
                    local targetVelocity = GetTargetVelocity(targetRoot)
                    local predictedPosition = PredictTargetPosition(targetRoot, targetVelocity)
                    
                    local targetPosition = CalculateFollowPosition(
                        targetRoot, 
                        respawnService.followDistance, 
                        respawnService.followPosition, 
                        respawnService.followHeight
                    )
                    
                    localRoot.CFrame = CFrame.new(targetPosition)
                    ForceLookAtTarget(localRoot, targetRoot)
                end
            end)
        end
   end,
})

-- 追踪设置
local MainSettings = MainTab:CreateSection("追踪设置")

local Input = MainTab:CreateInput({
   Name = "追踪速度",
   PlaceholderText = "输入追踪速度 (默认: 500)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.followSpeed = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "追踪距离",
   PlaceholderText = "输入追踪距离 (默认: 3.9)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.followDistance = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "追踪位置",
   PlaceholderText = "输入追踪角度 (0-360度, 默认: 350)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0 and value <= 360 then
            respawnService.followPosition = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "追踪高度",
   PlaceholderText = "输入追踪高度 (默认: 0)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value then
            respawnService.followHeight = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "旋转速度",
   PlaceholderText = "输入旋转速度 (默认: 1)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.rotationSpeed = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "旋转半径",
   PlaceholderText = "输入旋转半径 (默认: 5)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.rotationRadius = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "旋转高度",
   PlaceholderText = "输入旋转高度 (默认: 3)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value then
            respawnService.rotationHeight = value
        end
   end,
})

-- 高级追踪设置
local MainSettings = MainTab:CreateSection("高级追踪设置")

local Toggle = MainTab:CreateToggle({
   Name = "启用位置预测",
   CurrentValue = true,
   Callback = function(Value)
        respawnService.predictionEnabled = Value
   end,
})

local Input = MainTab:CreateInput({
   Name = "平滑系数",
   PlaceholderText = "输入平滑系数 (0.1-1.0, 默认: 0.2)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0.1 and value <= 1.0 then
            respawnService.smoothingFactor = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "最大预测时间",
   PlaceholderText = "输入最大预测时间(秒) (默认: 0.3)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.maxPredictionTime = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "速度乘数",
   PlaceholderText = "输入速度乘数 (默认: 1.1)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.velocityMultiplier = value
        end
   end,
})

-- 速度模式选择
local Dropdown = MainTab:CreateDropdown({
   Name = "速度模式",
   Options = {"正常", "快速", "极速"},
   CurrentOption = "正常",
   Callback = function(Option)
        respawnService.speedMode = Option
        if Option == "正常" then
            respawnService.walkSpeed = 16
            respawnService.tpWalkSpeed = 100
        elseif Option == "快速" then
            respawnService.walkSpeed = 32
            respawnService.tpWalkSpeed = 200
        elseif Option == "极速" then
            respawnService.walkSpeed = 64
            respawnService.tpWalkSpeed = 400
        end
   end,
})

-- 初始化玩家列表
UpdatePlayerButtons()

-- 玩家变化监听
Players.PlayerAdded:Connect(function()
    wait(1)
    UpdatePlayerButtons()
end)

Players.PlayerRemoving:Connect(function()
    wait(1)
    UpdatePlayerButtons()
end)

local MainTab = Window:CreateTab("🚀 速度调节", nil)
local MainSection = MainTab:CreateSection("速度设置")

-- TP行走模式的连接变量
local tpWalkConnection = nil

-- 应用速度设置的函数
local function ApplySpeedSettings()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if respawnService.speedMode == "normal" then
        humanoid.WalkSpeed = respawnService.walkSpeed or 16
    else
        humanoid.WalkSpeed = 16 -- 重置为默认速度，TP行走模式不使用WalkSpeed
    end
end

-- TP行走模式的实现
local function StartTPWalk()
    if tpWalkConnection then
        tpWalkConnection:Disconnect()
        tpWalkConnection = nil
    end
    
    tpWalkConnection = RunService.Heartbeat:Connect(function()
        if respawnService.speedMode ~= "tpwalk" or not LocalPlayer.Character then
            if tpWalkConnection then
                tpWalkConnection:Disconnect()
                tpWalkConnection = nil
            end
            return
        end
        
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
            -- 获取移动方向
            local moveDirection = humanoid.MoveDirection
            -- 计算移动距离
            local moveDistance = (respawnService.tpWalkSpeed or 100) * 0.016 -- 每帧移动距离
            -- 移动角色
            rootPart.CFrame = rootPart.CFrame + moveDirection * moveDistance
        end
    end)
end

-- 速度模式切换函数
local function ToggleSpeedMode()
    if respawnService.speedMode == "normal" then
        respawnService.speedMode = "tpwalk"
        Rayfield:Notify({
            Title = "速度模式已切换",
            Content = "当前模式: TP行走模式",
            Duration = 2,
        })
        StartTPWalk()
    else
        respawnService.speedMode = "normal"
        Rayfield:Notify({
            Title = "速度模式已切换",
            Content = "当前模式: 普通模式",
            Duration = 2,
        })
        if tpWalkConnection then
            tpWalkConnection:Disconnect()
            tpWalkConnection = nil
        end
    end
    ApplySpeedSettings()
end

-- 添加速度模式切换按钮
local Button = MainTab:CreateButton({
   Name = "切换速度模式: 普通",
   Callback = ToggleSpeedMode
})

-- 普通速度调节
local Input = MainTab:CreateInput({
   Name = "普通移动速度",
   PlaceholderText = "输入移动速度 (默认: 16)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0 then
            respawnService.walkSpeed = value
            
            -- 如果当前是普通模式，立即应用速度
            if respawnService.speedMode == "normal" and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = value
                end
            end
            
            Rayfield:Notify({
                Title = "设置更新",
                Content = "普通移动速度设置为: " .. value,
                Duration = 2,
            })
        else
            Rayfield:Notify({
                Title = "输入错误",
                Content = "请输入有效的数字",
                Duration = 2,
            })
        end
   end,
})

-- TP行走速度调节
local Input = MainTab:CreateInput({
   Name = "TP行走速度",
   PlaceholderText = "输入TP行走速度 (默认: 100)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0 then
            respawnService.tpWalkSpeed = value
            Rayfield:Notify({
                Title = "设置更新",
                Content = "TP行走速度设置为: " .. value,
                Duration = 2,
            })
        else
            Rayfield:Notify({
                Title = "输入错误",
                Content = "请输入有效的数字",
                Duration = 2,
            })
        end
   end,
})

-- 监听角色变化
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5) -- 等待角色完全加载
    ApplySpeedSettings()
    if respawnService.speedMode == "tpwalk" then
        StartTPWalk()
    end
end)

-- 如果已经有角色，立即应用设置
if LocalPlayer.Character then
    ApplySpeedSettings()
    if respawnService.speedMode == "tpwalk" then
        StartTPWalk()
    end
end

-- ==================== 甩飞功能部分 ====================
local MainSection = MainTab:CreateSection("甩飞功能")

local Button = MainTab:CreateButton({
   Name = "甩飞功能1",
   Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/甩飞.lua"))()
   end,
})

local Button = MainTab:CreateButton({
   Name = "甩飞功能2 (碰到就飞)",
   Callback = function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/0Ben1/fe/main/obf_5wpM7bBcOPspmX7lQ3m75SrYNWqxZ858ai3tJdEAId6jSI05IOUB224FQ0VSAswH.lua.txt'),true))()
   end,
})

-- ==================== 防甩飞功能 ====================
local MainSection = MainTab:CreateSection("防甩飞保护")

local antiFlingEnabled = false
local antiFlingConnection = nil

-- 防甩飞功能
local function setupAntiFling()
    -- 如果已存在连接，先断开
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- 配置参数
    local MAX_ALLOWED_VELOCITY = 100 -- 最大允许速度
    local MAX_ANGULAR_VELOCITY = 5 -- 最大允许角速度
    local ENABLE_DEBUG = false -- 启用调试信息

    -- 存储上一帧的位置和速度
    local lastPosition = rootPart.Position
    local lastVelocity = Vector3.new(0, 0, 0)
    local lastTime = tick()

    -- 防甩飞主循环
    antiFlingConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not antiFlingEnabled or not character or not rootPart then
            return
        end

        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        lastTime = currentTime

        -- 计算当前速度和加速度
        local currentVelocity = (rootPart.Position - lastPosition) / deltaTime
        local acceleration = (currentVelocity - lastVelocity) / deltaTime

        lastPosition = rootPart.Position
        lastVelocity = currentVelocity

        -- 计算角速度
        local angularVelocity = rootPart.AssemblyAngularVelocity.Magnitude

        -- 检测异常速度或加速度
        if currentVelocity.Magnitude > MAX_ALLOWED_VELOCITY or 
           acceleration.Magnitude > 500 or 
           angularVelocity > MAX_ANGULAR_VELOCITY then

            if ENABLE_DEBUG then
                print(string.format("检测到异常移动: 速度=%.2f, 加速度=%.2f, 角速度=%.2f", 
                    currentVelocity.Magnitude, acceleration.Magnitude, angularVelocity))
            end

            -- 重置角色位置到安全位置
            local success = pcall(function()
                -- 尝试找到安全位置
                local safePosition = workspace:FindPartOnRay(Ray.new(rootPart.Position + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0)), character)
                
                if safePosition then
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                    rootPart.RotVelocity = Vector3.new(0, 0, 0)
                    rootPart.CFrame = CFrame.new(safePosition.Position + Vector3.new(0, 3, 0))
                    
                    if ENABLE_DEBUG then
                        print("已重置角色位置到安全位置")
                    end
                end
            end)

            if not success and ENABLE_DEBUG then
                warn("重置位置时出错")
            end
        end
    end)

    -- 监听角色变化
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = newCharacter:WaitForChild("Humanoid")
        rootPart = newCharacter:WaitForChild("HumanoidRootPart")
        lastPosition = rootPart.Position
        lastVelocity = Vector3.new(0, 0, 0)
        lastTime = tick()
    end)
end

-- 创建防甩飞开关
local Toggle = MainTab:CreateToggle({
   Name = "防甩飞保护",
   CurrentValue = false,
   Callback = function(Value)
        antiFlingEnabled = Value
        if Value then
            setupAntiFling()
            Rayfield:Notify({
                Title = "防甩飞已启用",
                Content = "已开启防甩飞保护功能",
                Duration = 2,
            })
        else
            if antiFlingConnection then
                antiFlingConnection:Disconnect()
                antiFlingConnection = nil
            end
            Rayfield:Notify({
                Title = "防甩飞已禁用",
                Content = "已关闭防甩飞保护功能",
                Duration = 2,
            })
        end
   end,
})

-- 初始化防甩飞系统
setupAntiFling()

local MainSettings = MainTab:CreateSection("按键设置")

local Keybind = MainTab:CreateKeybind({
   Name = "自瞄按键",
   CurrentKeybind = "Q",
   HoldToInteract = false,
   Callback = function(Keybind)
        AimSettings.Enabled = not AimSettings.Enabled
        AimToggle:Set(AimSettings.Enabled)
   end,
})

local Keybind = MainTab:CreateKeybind({
   Name = "ESP按键",
   CurrentKeybind = "E",
   HoldToInteract = false,
   Callback = function(Keybind)
        AimSettings.ESPEnabled = not AimSettings.ESPEnabled
        ESPToggle:Set(AimSettings.ESPEnabled)
        UpdateESP()
   end,
})

local Keybind = MainTab:CreateKeybind({
   Name = "追踪按键",
   CurrentKeybind = "F",
   HoldToInteract = false,
   Callback = function(Keybind)
        respawnService.following = not respawnService.following
        FollowToggle:Set(respawnService.following)
   end,
})

local Keybind = MainTab:CreateKeybind({
   Name = "传送按键",
   CurrentKeybind = "T",
   HoldToInteract = false,
   Callback = function(Keybind)
        respawnService.teleporting = not respawnService.teleporting
        TeleportToggle:Set(respawnService.teleporting)
   end,
})

Rayfield:Notify({
    Title = "脚本加载成功",
    Content = "🔥 终极功能系统已加载完成！",
    Duration = 6.5,
    Image = nil,
})