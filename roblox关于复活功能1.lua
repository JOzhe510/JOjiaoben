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
    NearestAim = false,
    MaxDistance = math.huge,
    -- 新增自动朝向设置
    AutoFaceTarget = false,
    FaceSpeed = 1.0, -- 朝向速度 (0.1-1.0)
    FaceMode = "Selected", -- Selected/Nearest
    ShowTargetRay = true,
    RayColor = Color3.fromRGB(255, 0, 255),
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

-- 自动朝向目标函数
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
    
    -- 快速朝向目标（使用最高速度）
    local direction = (targetPosition - localRoot.Position).Unit
    local currentLook = localRoot.CFrame.LookVector
    local newLook = (currentLook * (1 - AimSettings.FaceSpeed) + direction * AimSettings.FaceSpeed).Unit
    
    localRoot.CFrame = CFrame.new(localRoot.Position, localRoot.Position + newLook)
    
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

-- 自瞄主循环
RunService.RenderStepped:Connect(function()
    Circle.Position = ScreenCenter
    Circle.Radius = AimSettings.FOV
    
    for _, espData in pairs(ESPLabels) do
        if espData and espData.update then
            espData.update()
        end
    end
    
    -- 执行自动朝向
    AutoFaceTarget()
    
    if not AimSettings.Enabled then return end
    
    -- 改进的自瞄逻辑：减少粘黏度，增加距离检查
    if AimSettings.LockedTarget and AimSettings.LockSingleTarget then
        if not IsTargetValid(AimSettings.LockedTarget) then
            AimSettings.LockedTarget = nil
        end
    end
    
    -- 非单锁模式：改进的目标切换逻辑
    if not AimSettings.LockSingleTarget then
        -- 只有当当前目标无效或超出距离时才切换
        if AimSettings.LockedTarget and IsTargetValid(AimSettings.LockedTarget) then
            -- 检查目标是否仍然在FOV内
            local cameraDirection = Camera.CFrame.LookVector
            local targetDirection = (AimSettings.LockedTarget.Position - Camera.CFrame.Position).Unit
            local dotProduct = cameraDirection:Dot(targetDirection)
            local angle = math.acos(math.clamp(dotProduct, -1, 1))
            local fovRad = math.rad(AimSettings.FOV / 2)
            
            if angle > fovRad then
                -- 目标离开FOV，寻找新目标
                if AimSettings.NearestAim then
                    AimSettings.LockedTarget = FindNearestTarget()
                else
                    AimSettings.LockedTarget = FindTargetInView()
                end
            end
        else
            -- 当前目标无效，寻找新目标
            if AimSettings.NearestAim then
                AimSettings.LockedTarget = FindNearestTarget()
            else
                AimSettings.LockedTarget = FindTargetInView()
            end
        end
    else
        -- 单锁模式：目标无效时清除
        if not AimSettings.LockedTarget or not IsTargetValid(AimSettings.LockedTarget) then
            AimSettings.LockedTarget = nil
        end
    end
    
    -- 瞄准逻辑
    if AimSettings.LockedTarget then
        local predictedPosition = CalculatePredictedPosition(AimSettings.LockedTarget)
        AimAtPosition(predictedPosition)
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
    -- 新增：追踪时自动朝向目标（可开关）
    autoFaceWhileTracking = false,
    faceSpeedWhileTracking = 1.0,
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

-- 修改后的 ForceLookAtTarget 函数，增加速度控制
local function ForceLookAtTarget(localRoot, targetRoot)
    if localRoot and targetRoot and respawnService.autoFaceWhileTracking then
        local direction = (targetRoot.Position - localRoot.Position).Unit
        local currentLook = localRoot.CFrame.LookVector
        local newLook = (currentLook * (1 - respawnService.faceSpeedWhileTracking) + direction * respawnService.faceSpeedWhileTracking).Unit
        
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

-- 新增自动朝向设置
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
        local button = TrackingTab:CreateButton({
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
        local label = TrackingTab:CreateLabel("当前没有其他玩家在线")
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

-- 追踪功能（已修改包含自动朝向）
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
                if not respawnService.following then
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
                    respawnService.following = false
                    respawnService.followConnection:Disconnect()
                    respawnService.followConnection = nil
                    return
                end
                
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not targetRoot then return end
                
                local targetVelocity = GetTargetVelocity(targetRoot)
                local predictedPosition = PredictTargetPosition(targetRoot, targetVelocity)
                
                local followPosition = CalculateFollowPosition(
                    targetRoot, 
                    respawnService.followDistance, 
                    respawnService.currentRotationAngle, 
                    respawnService.followHeight
                )
                
                SmoothMove(localRoot, followPosition, respawnService.smoothingFactor)
                
                -- 新增：追踪时自动朝向目标
                ForceLookAtTarget(localRoot, targetRoot)
            end)
        end
   end,
})

local Toggle = TrackingTab:CreateToggle({
   Name = "传送追踪",
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
                if not respawnService.teleporting then
                    respawnService.teleportConnection:Disconnect()
                    respawnService.teleportConnection = nil
                    return
                end
                
                local localChar = LocalPlayer.Character
                if not localChar then return end
                
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                if not localRoot then return end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not targetPlayer or not targetPlayer.Character then
                    respawnService.teleporting = false
                    respawnService.teleportConnection:Disconnect()
                    respawnService.teleportConnection = nil
                    return
                end
                
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not targetRoot then return end
                
                local targetVelocity = GetTargetVelocity(targetRoot)
                local predictedPosition = PredictTargetPosition(targetRoot, targetVelocity)
                
                local followPosition = CalculateFollowPosition(
                    targetRoot, 
                    respawnService.followDistance, 
                    respawnService.currentRotationAngle, 
                    respawnService.followHeight
                )
                
                localRoot.CFrame = CFrame.new(followPosition)
                
                -- 新增：追踪时自动朝向目标
                ForceLookAtTarget(localRoot, targetRoot)
            end)
        end
   end,
})

-- 追踪设置部分
local MainSection = MainTab:CreateSection("追踪设置")

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
   Name = "平滑系数 (0.1-1.0)",
   PlaceholderText = "输入平滑系数 (默认: 0.2)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0.1 and value <= 1.0 then
            respawnService.smoothingFactor = value
        end
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "追踪预判",
   CurrentValue = true,
   Callback = function(Value)
        respawnService.predictionEnabled = Value
   end,
})

local Input = MainTab:CreateInput({
   Name = "最大预判时间",
   PlaceholderText = "输入最大预判时间 (默认: 0.3)",
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
   PlaceholderText = "输入速度乘数 (默认: 2)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.velocityMultiplier = value
        end
   end,
})

-- 初始化玩家列表
UpdatePlayerButtons()

-- 玩家加入/离开时更新列表
Players.PlayerAdded:Connect(function()
    task.wait(1)
    UpdatePlayerButtons()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(1)
    UpdatePlayerButtons()
end)

Rayfield:Notify({
    Title = "🔥 终极功能系统已加载",
    Content = "自瞄+追踪功能已准备就绪！",
    Duration = 6,
    Image = 4483362458,
    Actions = {
        Ignore = {
            Name = "好的",
            Callback = function()
            end
        },
    },
})

-- 清理函数
game:BindToClose(function()
    ClearESP()
    Circle:Remove()
    TargetRay:Remove()
end)