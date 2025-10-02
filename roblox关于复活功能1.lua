local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔥 终极功能系统",
   LoadingTitle = "自瞄+复活功能系统",
   LoadingSubtitle = "作者 ufo外星人",
   ConfigurationSaving = {
      Enabled = true,
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

-- 修复：添加缺失的鼠标追踪变量
local lastMousePos = Vector2.new(0, 0)
local isManuallyAiming = false
local manualAimCooldown = 0
local lastDetectionTime = tick()

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
    NearestAim = false,
    MaxDistance = math.huge,
    -- 修复的自动朝向设置 - 只控制水平旋转
    AutoFaceTarget = false,
    FaceSpeed = 1.0,
    FaceMode = "Selected",
    ShowTargetRay = true,
    RayColor = Color3.fromRGB(255, 0, 255),
    HeightOffset = 0,
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

-- 目标射线
local TargetRay = Drawing.new("Line")
TargetRay.Visible = false
TargetRay.Color = AimSettings.RayColor
TargetRay.Thickness = 2
TargetRay.Transparency = 1

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

-- 修复距离检查的 FindTargetInView 函数
local function FindTargetInView()
    local bestTarget = nil
    local closestAngle = math.rad(AimSettings.FOV / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsEnemy(player) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- 修复距离检查（使用米为单位）
                local distance = (head.Position - Camera.CFrame.Position).Magnitude
                if distance > AimSettings.MaxDistance then
                    continue
                end
                
                local cameraDirection = Camera.CFrame.LookVector
                local targetDirection = (head.Position - Camera.CFrame.Position).Unit
                local dotProduct = cameraDirection:Dot(targetDirection)
                local angle = math.acos(math.clamp(dotProduct, -1, 1))
                
                if angle <= closestAngle then
                    if AimSettings.WallCheck then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (head.Position - rayOrigin).Unit * distance
                        
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

-- 修复距离检查的 FindNearestTarget 函数
local function FindNearestTarget()
    local nearestTarget = nil
    local minDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsEnemy(player) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- 修复距离检查（使用米为单位）
                local distance = (head.Position - Camera.CFrame.Position).Magnitude
                if distance > AimSettings.MaxDistance then
                    continue
                end
                
                if distance < minDistance then
                    if AimSettings.WallCheck then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (head.Position - rayOrigin).Unit * distance
                        
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
    
    -- 距离检查（确保目标在最大距离内）
    local distance = (target.Position - Camera.CFrame.Position).Magnitude
    if distance > AimSettings.MaxDistance then
        return false
    end
    
    return true
end

-- 修复的自动朝向目标函数 - 只控制水平旋转
local function AutoFaceTarget()
    if not AimSettings.AutoFaceTarget or not LocalPlayer.Character then
        TargetRay.Visible = false
        return
    end
    
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    local targetHead = nil
    
    -- 根据模式选择目标
    if AimSettings.FaceMode == "Selected" and AimSettings.LockedTarget then
        targetHead = AimSettings.LockedTarget
    elseif AimSettings.FaceMode == "Nearest" then
        targetHead = FindNearestTarget()
    end
    
    if not targetHead or not IsTargetValid(targetHead) then
        TargetRay.Visible = false
        return
    end
    
    -- 计算目标位置
    local targetPosition = targetHead.Position
    if AimSettings.PredictionEnabled then
        targetPosition = CalculatePredictedPosition(targetHead)
    end
    
    -- 修复：只控制水平旋转，保持垂直角度不变
    local direction = (targetPosition - localRoot.Position).Unit
    local currentCFrame = localRoot.CFrame
    
    -- 只使用X和Z分量来保持水平旋转，忽略Y分量
    local horizontalDirection = Vector3.new(direction.X, 0, direction.Z).Unit
    
    -- 保持原有的垂直位置
    local newCFrame = CFrame.new(localRoot.Position, localRoot.Position + horizontalDirection)
    localRoot.CFrame = newCFrame
    
    -- 显示目标射线
    if AimSettings.ShowTargetRay then
        local targetPos2D, targetVisible = Camera:WorldToViewportPoint(targetPosition)
        local localPos2D = Camera:WorldToViewportPoint(localRoot.Position)
        
        if targetVisible then
            TargetRay.From = Vector2.new(localPos2D.X, localPos2D.Y)
            TargetRay.To = Vector2.new(targetPos2D.X, targetPos2D.Y)
            TargetRay.Visible = true
            TargetRay.Color = AimSettings.RayColor
        else
            TargetRay.Visible = false
        end
    else
        TargetRay.Visible = false
    end
end

-- 增强智能自瞄系统
local SmartAimSettings = {
    Enabled = false,
    BodyParts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    CurrentPartIndex = 1,
    SwitchInterval = 0.3,
    LastSwitchTime = 0,
    RandomizeOrder = true,
    RealisticMode = true,
    MinAimTime = 0.1,
    MaxAimTime = 0.5,
    -- 新增设置
    PartPriorities = {
        Head = 1.0,
        UpperTorso = 0.8,
        HumanoidRootPart = 0.7,
        LowerTorso = 0.6
    }
}

-- 改进的智能瞄准位置获取
local function GetSmartAimPosition(targetHead)
    if not SmartAimSettings.Enabled or not targetHead then
        return CalculatePredictedPosition(targetHead)
    end
    
    local character = targetHead.Parent
    if not character then
        return CalculatePredictedPosition(targetHead)
    end
    
    local currentTime = tick()
    
    -- 改进的鼠标移动检测逻辑
local function UpdateMouseDetection()
    local currentMousePos = UIS:GetMouseLocation()
    local mouseDelta = (currentMousePos - lastMousePos).Magnitude
    
    -- 增加阈值并考虑时间因素
    local timeFactor = math.min(1, (tick() - lastDetectionTime) * 10)
    local adjustedThreshold = 15 * timeFactor -- 动态阈值
    
    if mouseDelta > adjustedThreshold then
        isManuallyAiming = true
        manualAimCooldown = 0.5 -- 增加冷却时间
        lastDetectionTime = tick()
    end
    
    lastMousePos = currentMousePos
end

-- 在需要的地方调用这个函数
UpdateMouseDetection()

-- 更新冷却时间
if manualAimCooldown > 0 then
    manualAimCooldown = manualAimCooldown - (1/60) -- 假设60fps
else
    isManuallyAiming = false
end
    
    -- 智能部位切换
    if currentTime - SmartAimSettings.LastSwitchTime >= SmartAimSettings.SwitchInterval then
        if SmartAimSettings.RandomizeOrder then
            -- 基于优先级的随机选择
            local totalWeight = 0
            for _, partName in ipairs(SmartAimSettings.BodyParts) do
                totalWeight = totalWeight + (SmartAimSettings.PartPriorities[partName] or 0.5)
            end
            
            local randomValue = math.random() * totalWeight
            local accumulatedWeight = 0
            
            for i, partName in ipairs(SmartAimSettings.BodyParts) do
                accumulatedWeight = accumulatedWeight + (SmartAimSettings.PartPriorities[partName] or 0.5)
                if randomValue <= accumulatedWeight then
                    SmartAimSettings.CurrentPartIndex = i
                    break
                end
            end
        else
            SmartAimSettings.CurrentPartIndex = SmartAimSettings.CurrentPartIndex % #SmartAimSettings.BodyParts + 1
        end
        
        SmartAimSettings.LastSwitchTime = currentTime
        
        -- 真实模式下的随机间隔
        if SmartAimSettings.RealisticMode then
            SmartAimSettings.SwitchInterval = math.random(15, 40) / 100 -- 0.15-0.4秒
        end
    end
    
    local targetPartName = SmartAimSettings.BodyParts[SmartAimSettings.CurrentPartIndex]
    local targetPart = character:FindFirstChild(targetPartName)
    
    -- 如果找不到指定部位，回退到可用部位
    if not targetPart then
        for _, fallbackPart in ipairs(SmartAimSettings.BodyParts) do
            local fallback = character:FindFirstChild(fallbackPart)
            if fallback then
                targetPart = fallback
                break
            end
        end
    end
    
    if targetPart then
        local basePosition = CalculatePredictedPosition(targetPart)
        
        -- 真实模式下的随机偏移
        if SmartAimSettings.RealisticMode then
            local randomOffset = Vector3.new(
                math.random(-8, 8) / 100, -- -0.08 到 0.08
                math.random(-8, 8) / 100,
                math.random(-8, 8) / 100
            )
            return basePosition + randomOffset
        end
        
        return basePosition
    end
    
    -- 最终回退到头部
    return CalculatePredictedPosition(targetHead)
end

-- 替换原有的 RenderStepped 连接
RunService.RenderStepped:Connect(function()
    Circle.Position = ScreenCenter
    Circle.Radius = AimSettings.FOV
    
    -- 更新ESP
    for _, espData in pairs(ESPLabels) do
        if espData and espData.update then
            espData.update()
        end
    end
    
    -- 更新鼠标检测
    UpdateMouseDetection()
    
    -- 执行自动朝向
    AutoFaceTarget()
    
    if not AimSettings.Enabled then return end
    
    -- 改进的自瞄逻辑
    if AimSettings.LockSingleTarget and AimSettings.LockedTarget then
        -- 单锁模式：只有目标无效时才清除
        if not IsTargetValid(AimSettings.LockedTarget) then
            AimSettings.LockedTarget = nil
        end
    else
        -- 普通模式：改进的目标获取逻辑
        local shouldFindNewTarget = not AimSettings.LockedTarget or not IsTargetValid(AimSettings.LockedTarget)
        
        -- 如果玩家没有主动瞄准，允许寻找新目标
        if shouldFindNewTarget and not isManuallyAiming then
            if AimSettings.NearestAim then
                AimSettings.LockedTarget = FindNearestTarget()
            else
                AimSettings.LockedTarget = FindTargetInView()
            end
        end
        
        -- 如果玩家主动瞄准，取消当前锁定但允许快速重新锁定
        if isManuallyAiming and AimSettings.LockedTarget then
            AimSettings.LockedTarget = nil
        end
    end
    
    -- 瞄准逻辑
    if AimSettings.LockedTarget and IsTargetValid(AimSettings.LockedTarget) then
        local predictedPosition = nil
        
        -- 使用智能自瞄或普通自瞄
        if SmartAimSettings.Enabled then
            predictedPosition = GetSmartAimPosition(AimSettings.LockedTarget)
        else
            predictedPosition = CalculatePredictedPosition(AimSettings.LockedTarget)
        end
        
        -- 添加高度偏移
        if AimSettings.HeightOffset ~= 0 then
            predictedPosition = predictedPosition + Vector3.new(0, AimSettings.HeightOffset, 0)
        end
        
        AimAtPosition(predictedPosition)
    end
end)

-- 初始更新
UpdateESP()

-- ==================== 复活功能部分 ====================

local movementService = {
    tpWalking = false,
    tpWalkConnection = nil,
    originalWalkSpeed = nil,
    normalWalkSpeed = 16,
    tpWalkSpeed = 100,
    useCustomSpeed = false,
    customNormalSpeed = 16,
    customTpSpeed = 100
}

local respawnService = {
    autoRespawn = false,
    followPlayer = nil,
    following = false,
    teleporting = false,
    rotating = false,

    -- 平滑追踪设置
    followSpeed = 500,
    followDistance = 3.9,
    followHeight = 0,
    followPosition = 0,

    -- 旋转追踪设置
    rotationSpeed = 100,
    rotationRadius = 5,
    rotationHeight = 0,
    currentRotationAngle = 0,
    
    -- 通用设置
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
    autoFaceWhileTracking = false,
    faceSpeedWhileTracking = 1.0
    }

-- ==================== 修复速度控制部分 ====================
local function UpdateSpeedSettings()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if movementService.tpWalking then
        -- TP行走模式下使用TP速度
        humanoid.WalkSpeed = movementService.useCustomSpeed and movementService.customTpSpeed or movementService.tpWalkSpeed
    else
        -- 普通模式下使用普通速度
        humanoid.WalkSpeed = movementService.useCustomSpeed and movementService.customNormalSpeed or movementService.normalWalkSpeed
    end
end

-- 角色添加时自动应用速度设置
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    UpdateSpeedSettings()
end)

-- ==================== 修复TP行走功能 ====================
local function StartTPWalk()
    if movementService.tpWalkConnection then
        movementService.tpWalkConnection:Disconnect()
        movementService.tpWalkConnection = nil
    end
    
    movementService.tpWalking = true
    
    movementService.tpWalkConnection = RunService.Heartbeat:Connect(function()
        if not movementService.tpWalking then
            movementService.tpWalkConnection:Disconnect()
            movementService.tpWalkConnection = nil
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart then return end
        
        if not movementService.originalWalkSpeed then
            movementService.originalWalkSpeed = humanoid.WalkSpeed
        end
        
        local speed = movementService.useCustomSpeed and movementService.customTpSpeed or movementService.tpWalkSpeed
        humanoid.WalkSpeed = speed
        
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            local velocity = moveDirection * speed
            rootPart.Velocity = Vector3.new(velocity.X, rootPart.Velocity.Y, velocity.Z)
        end
    end)
end

local function StopTPWalk()
    movementService.tpWalking = false
    
    if movementService.tpWalkConnection then
        movementService.tpWalkConnection:Disconnect()
        movementService.tpWalkConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if movementService.originalWalkSpeed then
                humanoid.WalkSpeed = movementService.originalWalkSpeed
                movementService.originalWalkSpeed = nil
            else
                humanoid.WalkSpeed = movementService.useCustomSpeed and movementService.customNormalSpeed or movementService.normalWalkSpeed
            end
        end
    end
end

-- 修复：添加缺失的函数
local function IsPlayerValid(playerName)
    if not playerName or playerName == "" then
        return false
    end
    return Players:FindFirstChild(playerName) ~= nil
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

local function ForceLookAtTarget(localRoot, targetRoot)
    if localRoot and targetRoot and respawnService.autoFaceWhileTracking then
        local direction = (targetRoot.Position - localRoot.Position).Unit
        local currentLook = localRoot.CFrame.LookVector
        
        local horizontalDirection = Vector3.new(direction.X, 0, direction.Z).Unit
        local newLook = (currentLook * (1 - respawnService.faceSpeedWhileTracking) + horizontalDirection * respawnService.faceSpeedWhileTracking).Unit
        
        localRoot.CFrame = CFrame.new(localRoot.Position, localRoot.Position + newLook)
    end
end

local function CalculateFollowPosition(targetRoot, distance, angle, height)
    local angleRad = math.rad(angle)
    
    local lookVector = targetRoot.CFrame.LookVector
    local rightVector = targetRoot.CFrame.RightVector
    
    local forwardOffset = -math.cos(angleRad) * distance
    local rightOffset = math.sin(angleRad) * distance
    
    local offset = (lookVector * forwardOffset) + (rightVector * rightOffset) + Vector3.new(0, height, 0)
    
    return targetRoot.Position + offset
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

-- 修复：添加缺失的变量声明
local currentPlayerLabel
local currentSelectedPlayer = nil
local playerButtons = {}

-- 修复：添加自动选择玩家函数
local function AutoSelectNearestPlayer()
    local nearestPlayer = GetNearestPlayer()
    if nearestPlayer then
        respawnService.followPlayer = nearestPlayer.Name
        currentSelectedPlayer = nearestPlayer
        if currentPlayerLabel then
            currentPlayerLabel:Set("当前选择: " .. nearestPlayer.Name .. " (自动)")
        end
        return true
    end
    return false
end

-- 修复：平滑追踪功能
local function StartSmoothTracking()
    if respawnService.followConnection then
        respawnService.followConnection:Disconnect()
        respawnService.followConnection = nil
    end
    
    respawnService.following = true
    respawnService.teleporting = false
    respawnService.rotating = false
    
    respawnService.followConnection = RunService.Heartbeat:Connect(function()
        if not respawnService.following then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
            return
        end
        
        local localChar = LocalPlayer.Character
        if not localChar then return end
        
        local localRoot = localChar:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end
        
        if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
            if not AutoSelectNearestPlayer() then
                respawnService.following = false
                return
            end
        end
        
        local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
        if not targetPlayer or not targetPlayer.Character then
            respawnService.following = false
            return
        end
        
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        local targetVelocity = GetTargetVelocity(targetRoot)
        local predictedPosition = PredictTargetPosition(targetRoot, targetVelocity)
        
        local angleRad = math.rad(respawnService.followPosition)
        local lookVector = targetRoot.CFrame.LookVector
        local rightVector = targetRoot.CFrame.RightVector
        
        local forwardOffset = -math.cos(angleRad) * respawnService.followDistance
        local rightOffset = math.sin(angleRad) * respawnService.followDistance
        
        local offset = (lookVector * forwardOffset) + (rightVector * rightOffset) + Vector3.new(0, respawnService.followHeight, 0)
        local targetFollowPosition = predictedPosition + offset
        
        local distance = (localRoot.Position - targetFollowPosition).Magnitude
        local moveSpeed = math.min(respawnService.followSpeed, distance * 10)
        
        if distance > 0.1 then
            local direction = (targetFollowPosition - localRoot.Position).Unit
            local newPosition = localRoot.Position + (direction * moveSpeed * 0.016)
            
            localRoot.CFrame = CFrame.new(newPosition)
            ForceLookAtTarget(localRoot, targetRoot)
        end
    end)
end

-- 修复：直接传送功能
local function StartDirectTeleport()
    if respawnService.teleportConnection then
        respawnService.teleportConnection:Disconnect()
        respawnService.teleportConnection = nil
    end
    
    respawnService.teleporting = true
    respawnService.following = false
    respawnService.rotating = false
    
    respawnService.teleportConnection = RunService.Heartbeat:Connect(function()
        if not respawnService.teleporting then
            respawnService.teleportConnection:Disconnect()
            respawnService.teleportConnection = nil
            return
        end
        
        local localChar = LocalPlayer.Character
        if not localChar then return end
        
        local localRoot = localChar:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end
        
        if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
            if not AutoSelectNearestPlayer() then
                respawnService.teleporting = false
                return
            end
        end
        
        local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
        if not targetPlayer or not targetPlayer.Character then
            respawnService.teleporting = false
            return
        end
        
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        
        local angleRad = math.rad(respawnService.followPosition)
        local lookVector = targetRoot.CFrame.LookVector
        local rightVector = targetRoot.CFrame.RightVector
        
        local forwardOffset = -math.cos(angleRad) * respawnService.followDistance
        local rightOffset = math.sin(angleRad) * respawnService.followDistance
        
        local offset = (lookVector * forwardOffset) + (rightVector * rightOffset) + Vector3.new(0, respawnService.followHeight, 0)
        local teleportPosition = targetRoot.Position + offset
        
        localRoot.CFrame = CFrame.new(teleportPosition)
        ForceLookAtTarget(localRoot, targetRoot)
    end)
end

local function UpdateSpeed()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if respawnService.speedMode == "normal" then
        humanoid.WalkSpeed = respawnService.useCustomSpeed and respawnService.customWalkSpeed or respawnService.walkSpeed
    else
        humanoid.WalkSpeed = respawnService.useCustomSpeed and respawnService.customTpSpeed or respawnService.tpWalkSpeed
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    UpdateSpeed()
end)

-- 角色添加时自动应用速度设置
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5) -- 等待角色完全加载
    UpdateSpeed()
end)

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

-- 修改后的 ForceLookAtTarget 函数，增加速度控制
local function ForceLookAtTarget(localRoot, targetRoot)
    if localRoot and targetRoot and respawnService.autoFaceWhileTracking then
        local direction = (targetRoot.Position - localRoot.Position).Unit
        local currentLook = localRoot.CFrame.LookVector
        
        -- 只控制水平旋转，保持垂直角度不变
        local horizontalDirection = Vector3.new(direction.X, 0, direction.Z).Unit
        local newLook = (currentLook * (1 - respawnService.faceSpeedWhileTracking) + horizontalDirection * respawnService.faceSpeedWhileTracking).Unit
        
        localRoot.CFrame = CFrame.new(localRoot.Position, localRoot.Position + newLook)
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
   Name = "单锁模式",
   CurrentValue = false,
   Callback = function(Value)
        AimSettings.LockSingleTarget = Value
        if not Value then
            AimSettings.LockedTarget = nil
        end
   end,
})

-- 在自瞄设置部分添加更详细的智能自瞄控制
local Toggle = MainTab:CreateToggle({
   Name = "智能自瞄演戏模式",
   CurrentValue = false,
   Callback = function(Value)
        SmartAimSettings.Enabled = Value
        if Value then
            Rayfield:Notify({
                Title = "智能自瞄已开启",
                Content = "将在多个身体部位间智能切换瞄准",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "智能自瞄已关闭",
                Content = "切换回头部锁定模式",
                Duration = 2,
            })
        end
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

-- 修复的自动朝向设置
local Toggle = MainTab:CreateToggle({
   Name = "自动朝向目标",
   CurrentValue = false,
   Callback = function(Value)
        AimSettings.AutoFaceTarget = Value
   end,
})

local Dropdown = MainTab:CreateDropdown({
   Name = "朝向目标模式",
   Options = {"选定目标", "最近目标"},
   CurrentOption = "选定目标",
   Callback = function(Option)
        AimSettings.FaceMode = Option == "选定目标" and "Selected" or "Nearest"
   end,
})

local Dropdown = MainTab:CreateDropdown({
   Name = "自瞄模式",
   Options = {"头部锁定", "全身演戏", "随机部位", "顺序切换"},  -- 修复了字符串格式
   CurrentOption = "头部锁定",
   Callback = function(Option)
        if Option == "头部锁定" then
            SmartAimSettings.Enabled = false
        else
            SmartAimSettings.Enabled = true
            SmartAimSettings.RandomizeOrder = (Option == "随机部位")
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "部位切换速度 (0.1-2.0)",
   PlaceholderText = "输入切换速度 (默认: 0.3)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0.1 and value <= 2.0 then
            SmartAimSettings.SwitchInterval = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "朝向速度 (0.1-1.0)",
   PlaceholderText = "输入朝向速度 (默认: 1.0)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0.1 and value <= 1.0 then
            AimSettings.FaceSpeed = value
        end
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "显示目标射线",
   CurrentValue = true,
   Callback = function(Value)
        AimSettings.ShowTargetRay = Value
   end,
})

local Input = MainTab:CreateInput({
   Name = "射线颜色 (R,G,B)",
   PlaceholderText = "输入RGB颜色 如: 255,0,255",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local r, g, b = Text:match("(%d+),(%d+),(%d+)")
        if r and g and b then
            AimSettings.RayColor = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "自瞄距离限制 (米)",
   PlaceholderText = "输入最大自瞄距离 (默认: 无限)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            AimSettings.MaxDistance = value
            Rayfield:Notify({
                Title = "自瞄距离设置成功",
                Content = "最大自瞄距离: " .. value .. " 米",
                Duration = 3,
            })
        else
            AimSettings.MaxDistance = math.huge
            Rayfield:Notify({
                Title = "自瞄距离重置",
                Content = "自瞄距离限制已取消 (无限距离)",
                Duration = 3,
            })
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "自瞄高度偏移 (-10 到 10)",
   PlaceholderText = "输入高度偏移 (默认: 0)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= -10 and value <= 10 then
            AimSettings.HeightOffset = value
            Rayfield:Notify({
                Title = "自瞄高度设置成功",
                Content = "高度偏移: " .. value,
                Duration = 3,
            })
        else
            AimSettings.HeightOffset = 0
            Rayfield:Notify({
                Title = "自瞄高度重置",
                Content = "高度偏移已重置为 0",
                Duration = 3,
            })
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

local MainSection = MainTab:CreateSection("追踪系统")

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

local PlayerData = {
    savedPosition = nil,
    enableTeleport = false
}

local Button = MainTab:CreateButton({
   Name = "保存当前位置",
   Callback = function()
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                PlayerData.savedPosition = rootPart.Position
                Rayfield:Notify({
                    Title = "位置已保存",
                    Content = "当前位置已保存",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "保存失败",
                    Content = "找不到角色根部件",
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "保存失败",
                Content = "角色不存在",
                Duration = 3,
            })
        end
   end,
})

local Button = MainTab:CreateButton({
   Name = "取消保存位置",
   Callback = function()
        if PlayerData.savedPosition then
            PlayerData.savedPosition = nil
            Rayfield:Notify({
                Title = "位置已清除",
                Content = "已清除保存的位置数据",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "无保存位置",
                Content = "没有找到保存的位置数据",
                Duration = 3,
            })
        end
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "自动传送保持位置",
   CurrentValue = false,
   Callback = function(Value)
        PlayerData.enableTeleport = Value
        if Value then
            Rayfield:Notify({
                Title = "自动传送已开启",
                Content = "复活后将自动传送到保存位置",
                Duration = 3,
            })
            
            -- 设置复活监听
            LocalPlayer.CharacterAdded:Connect(function(character)
                task.wait(0.5) -- 等待角色加载
                if PlayerData.enableTeleport and PlayerData.savedPosition then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rootPart.CFrame = CFrame.new(PlayerData.savedPosition)
                        Rayfield:Notify({
                            Title = "自动传送",
                            Content = "已传送到保存位置",
                            Duration = 3,
                        })
                    end
                end
            end)
        else
            Rayfield:Notify({
                Title = "自动传送已关闭",
                Content = "复活时将不再自动传送",
                Duration = 3,
            })
        end
   end,
})

local Button = MainTab:CreateButton({
   Name = "传送虚空",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/传送虚空.lua"))()
   end,
})

-- 平滑追踪按钮
local Toggle = MainTab:CreateToggle({
   Name = "平滑追踪",
   CurrentValue = false,
   Callback = function(Value)
        if Value then
            StartSmoothTracking()
        else
            respawnService.following = false
            if respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
        end
   end,
})

-- 直接传送按钮
local Toggle = MainTab:CreateToggle({
   Name = "直接传送",
   CurrentValue = false,
   Callback = function(Value)
        if Value then
            StartDirectTeleport()
        else
            respawnService.teleporting = false
            if respawnService.teleportConnection then
                respawnService.teleportConnection:Disconnect()
                respawnService.teleportConnection = nil
            end
        end
   end,
})

-- 新增旋转追踪功能
local Toggle = MainTab:CreateToggle({
   Name = "旋转追踪",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.rotating = Value
        
        if respawnService.followConnection then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
        end
        
        if respawnService.rotating then
            if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
                if not AutoSelectNearestPlayer() then
                    respawnService.rotating = false
                    return
                end
            end
            
            respawnService.followConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.rotating then
                    respawnService.followConnection:Disconnect()
                    respawnService.followConnection = nil
                    return
                end
                
                local localChar = LocalPlayer.Character
                if not localChar then return end
                
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                if not localRoot then return end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not targetPlayer or not targetPlayer.Character then
                    respawnService.rotating = false
                    respawnService.followConnection:Disconnect()
                    respawnService.followConnection = nil
                    return
                end
                
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not targetRoot then return end
                
                -- 更新旋转角度
                respawnService.currentRotationAngle = respawnService.currentRotationAngle + respawnService.rotationSpeed * 0.01
                if respawnService.currentRotationAngle >= 360 then
                    respawnService.currentRotationAngle = 0
                end
                
                local followPosition = CalculateFollowPosition(
                    targetRoot, 
                    respawnService.rotationRadius, 
                    respawnService.currentRotationAngle, 
                    respawnService.rotationHeight
                )
                
                localRoot.CFrame = CFrame.new(followPosition)
                
                -- 追踪时自动朝向目标
                ForceLookAtTarget(localRoot, targetRoot)
            end)
        end
   end,
})


-- 修改追踪功能，增加自动朝向选项
local Toggle = MainTab:CreateToggle({
   Name = "追踪时自动朝向",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.autoFaceWhileTracking = Value
   end,
})

local Input = MainTab:CreateInput({
   Name = "追踪朝向速度 (0.1-1.0)",
   PlaceholderText = "输入追踪朝向速度 (默认: 1.0)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0.1 and value <= 1.0 then
            respawnService.faceSpeedWhileTracking = value
        end
   end,
})

-- 玩家选择部分
local MainSection = MainTab:CreateSection("在线玩家列表")

-- 只创建一个当前选择标签
local currentPlayerLabel = MainTab:CreateLabel("当前选择: 无")

-- 修复：玩家列表显示
local function UpdatePlayerList()
    -- 清除旧的玩家按钮
    for _, button in pairs(playerButtons) do
        button:Destroy()
    end
    playerButtons = {}
    
    local players = Players:GetPlayers()
    table.sort(players, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    
    for i, player in ipairs(players) do
        if player ~= LocalPlayer then
            local button = MainTab:CreateButton({  -- 修复：使用正确的tab引用
                Name = player.Name .. (player == currentSelectedPlayer and " (已选择)" or ""),
                Callback = function()
                    respawnService.followPlayer = player.Name
                    currentSelectedPlayer = player
                    
                    if currentPlayerLabel then
                        currentPlayerLabel:Set("当前选择: " .. player.Name)
                    end
                    
                    Rayfield:Notify({
                        Title = "玩家选择成功",
                        Content = "已选择玩家: " .. player.Name,
                        Duration = 3,
                    })
                    
                    UpdatePlayerList()  -- 刷新列表显示选中状态
                end,
            })
            table.insert(playerButtons, button)
        end
    end
end

local Button = MainTab:CreateButton({
   Name = "刷新玩家列表",
   Callback = function()
        UpdatePlayerList()
        Rayfield:Notify({
            Title = "玩家列表已刷新",
            Content = "已更新在线玩家列表",
            Duration = 3,
        })
   end,
})

local Button = MainTab:CreateButton({
   Name = "自动选择最近玩家",
   Callback = function()
        if AutoSelectNearestPlayer() then
            Rayfield:Notify({
                Title = "自动选择成功",
                Content = "已选择最近玩家: " .. respawnService.followPlayer,
                Duration = 3,
            })
            UpdatePlayerList()
        else
            Rayfield:Notify({
                Title = "自动选择失败",
                Content = "没有找到可选择的玩家",
                Duration = 3,
            })
        end
   end,
})

local Button = MainTab:CreateButton({
   Name = "清除选择",
   Callback = function()
        respawnService.followPlayer = nil
        currentSelectedPlayer = nil
        if currentPlayerLabel then
            currentPlayerLabel:Set("当前选择: 无")
        end
        Rayfield:Notify({
            Title = "选择已清除",
            Content = "已清除玩家选择",
            Duration = 3,
        })
        UpdatePlayerList()
   end,
})

-- 初始化玩家列表
UpdatePlayerList()

-- 玩家加入/离开事件
Players.PlayerAdded:Connect(function()
    task.wait(1)
    UpdatePlayerList()
end)

Players.PlayerRemoving:Connect(function(player)
    if player == currentSelectedPlayer then
        respawnService.followPlayer = nil
        currentSelectedPlayer = nil
        if currentPlayerLabel then
            currentPlayerLabel:Set("当前选择: 无")
        end
    end
    task.wait(0.5)
    UpdatePlayerList()
end)

-- 追踪设置部分
local MainSection = MainTab:CreateSection("追踪设置")

-- 追踪速度（用于平滑追踪）
local Input = MainTab:CreateInput({
   Name = "追踪速度 (1-2000)",
   PlaceholderText = "输入追踪速度 (默认: 500)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 1 and value <= 2000 then
            respawnService.followSpeed = value
            Rayfield:Notify({
                Title = "追踪速度已更新",
                Content = "新速度: " .. value,
                Duration = 2,
            })
        end
   end,
})

-- 追踪高度（用于所有追踪模式）
local Input = MainTab:CreateInput({
   Name = "追踪高度 (-10 到 500)",
   PlaceholderText = "输入追踪高度 (默认: 0)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= -10 and value <= 500 then
            respawnService.followHeight = value
            Rayfield:Notify({
                Title = "追踪高度已更新",
                Content = "新高度: " .. value,
                Duration = 2,
            })
        end
   end,
})

-- 追踪角度（用于所有追踪模式）
local Input = MainTab:CreateInput({
   Name = "追踪角度 (0-360)",
   PlaceholderText = "输入追踪角度 (默认: 0)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0 and value <= 360 then
            respawnService.followPosition = value
            Rayfield:Notify({
                Title = "追踪角度已更新",
                Content = "新角度: " .. value .. "°",
                Duration = 2,
            })
        end
   end,
})

-- 追踪距离（用于所有追踪模式）
local Input = MainTab:CreateInput({
   Name = "追踪距离 (1-50)",
   PlaceholderText = "输入追踪距离 (默认: 3.9)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 1 and value <= 50 then
            respawnService.followDistance = value
            Rayfield:Notify({
                Title = "追踪距离已更新",
                Content = "新距离: " .. value,
                Duration = 2,
            })
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "旋转速度 (1-2000)",
   PlaceholderText = "输入旋转速度 (默认: 100)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 1 and value <= 2000 then
            respawnService.rotationSpeed = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "旋转半径 (1-20)",
   PlaceholderText = "输入旋转半径 (默认: 5)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 1 and value <= 20 then
            respawnService.rotationRadius = value
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "旋转高度 (-10 到 500)",
   PlaceholderText = "输入旋转高度 (默认: 0)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= -10 and value <= 500 then
            respawnService.rotationHeight = value
        end
   end,
})

-- 创建主标签页
local MainTab = Window:CreateTab("速度修改", nil)

-- 自瞄系统部分
local MainSection = MainTab:CreateSection("速度系统")

-- 速度模式切换
local Toggle = MainTab:CreateToggle({
   Name = "TP行走模式",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.speedMode = Value and "tp" or "normal"
        UpdateSpeed()
        Rayfield:Notify({
            Title = "速度模式已切换",
            Content = "当前模式: " .. (respawnService.speedMode == "normal" and "普通" or "TP"),
            Duration = 2,
        })
   end,
})

-- 使用自定义速度开关
local Toggle = MainTab:CreateToggle({
   Name = "使用普通速度",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.useCustomSpeed = Value
        UpdateSpeed()
        Rayfield:Notify({
            Title = "自定义速度设置",
            Content = Value and "已启用自定义速度" or "已使用默认速度",
            Duration = 2,
        })
   end,
})

-- 普通速度输入
local Input = MainTab:CreateInput({
   Name = "普通行走速度",
   PlaceholderText = "输入普通速度 (默认: 16)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.customWalkSpeed = value
            if respawnService.useCustomSpeed and respawnService.speedMode == "normal" then
                UpdateSpeed()
                Rayfield:Notify({
                    Title = "普通速度已更新",
                    Content = "新速度: " .. value,
                    Duration = 2,
                })
            end
        end
   end,
})

-- 修改速度控制部分
local function UpdateSpeed()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if respawnService.speedMode == "normal" then
        humanoid.WalkSpeed = respawnService.useCustomSpeed and respawnService.customWalkSpeed or respawnService.walkSpeed
    else -- tp模式
        humanoid.WalkSpeed = respawnService.useCustomSpeed and respawnService.customTpSpeed or respawnService.tpWalkSpeed
    end
end

-- 添加TP行走指令功能
local Input = MainTab:CreateInput({
   Name = "TP行走速度指令",
   PlaceholderText = "输入 tpwalk 数字 设置TP速度",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local command, value = Text:match("^(%S+)%s+(%d+)$")
        if command and value then
            if command:lower() == "tpwalk" then
                local speed = tonumber(value)
                if speed and speed > 0 then
                    respawnService.customTpSpeed = speed
                    respawnService.useCustomSpeed = true
                    respawnService.speedMode = "tp"
                    UpdateSpeed()
                    
                    Rayfield:Notify({
                        Title = "TP行走速度设置成功",
                        Content = "TP速度: " .. speed,
                        Duration = 3,
                    })
                end
            end
        else
            -- 直接输入数字也支持
            local speed = tonumber(Text)
            if speed and speed > 0 then
                respawnService.customTpSpeed = speed
                respawnService.useCustomSpeed = true
                respawnService.speedMode = "tp"
                UpdateSpeed()
                
                Rayfield:Notify({
                    Title = "TP行走速度设置成功",
                    Content = "TP速度: " .. speed,
                    Duration = 3,
                })
            end
        end
   end,
})

local MainSection = MainTab:CreateSection("甩飞系统")

local Button = MainTab:CreateButton({
   Name = "碰到就飞",
   Callback = function()
   loadstring(game:HttpGet(('https://raw.githubusercontent.com/0Ben1/fe/main/obf_5wpM7bBcOPspmX7lQ3m75SrYNWqxZ858ai3tJdEAId6jSI05IOUB224FQ0VSAswH.lua.txt'),true))()
  end,
})

local Button = MainTab:CreateButton({
   Name = "单甩",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/甩飞.lua"))()
   end,
})

local Button = MainTab:CreateButton({
   Name = "防甩飞",
   Callback = function()
   loadstring(game:HttpGet('https://raw.githubusercontent.com/Linux6699/DaHubRevival/main/AntiFling.lua'))()
   end,
})

Rayfield:Notify({
    Title = "系统加载成功",
    Content = "自瞄和追踪功能已加载完成",
    Duration = 5,
})