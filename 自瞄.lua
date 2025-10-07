local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Syndromehsh/Lua/refs/heads/main/AlienX/AlienX%20Wind%203.0%20UI.txt"))()

task.wait(2)

WindUI:Notify({
    Title = "jo自瞄",
    Content = "jo自瞄系统已加载",
    Duration = 4
})

task.wait(0.5)

local player = game.Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "AlienX<font color='#00FF00'>自瞄系统</font>",
    Icon = "rbxassetid://4483362748",
    IconTransparency = 1,
    Author = "AlienX",
    Folder = "AlienX",
    Size = UDim2.fromOffset(100, 150),
    Transparent = true,
    Theme = "Dark",
    UserEnabled = true,
    SideBarWidth = 200,
    HasOutline = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Username = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        Thumbnail = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png",
        Callback = function()
            WindUI:Notify({
                Title = "用户信息",
                Content = "玩家: " .. player.Name .. " (" .. player.DisplayName .. ")",
                Duration = 3
            })
        end
    }
})

task.wait(0.3)

Window:EditOpenButton({
    Title = "jo自瞄",
    Icon = "target",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("0000FF"))
    }),
    Draggable = true,
})

task.wait(0.2)

local Tab = Window:Tab({
    Title = "jo自瞄功能",
    Icon = "target",
    Locked = false,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

local AimSettings = {
    Enabled = false,
    FOV = 90,
    Prediction = 0.15,
    Smoothness = 0.9,
    LockedTarget = nil,
    LockSingleTarget = false,
    ESPEnabled = true,
    WallCheck = true,
    PredictionEnabled = true,
    AimMode = "Camera",
    TeamCheck = true,
    NearestAim = false,
    MaxDistance = math.huge,
    AutoFaceTarget = false,
    FaceSpeed = 1.0,
    FaceMode = "Selected",
    ShowTargetRay = true,
    RayColor = Color3.fromRGB(255, 0, 255),
    HeightOffset = 0,
    AimPart = "Head"
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

local TargetRay = Drawing.new("Line")
TargetRay.Visible = false
TargetRay.Color = AimSettings.RayColor
TargetRay.Thickness = 2
TargetRay.Transparency = 1

local ESPHighlights = {}
local ESPLabels = {}
local ESPConnections = {}

local isManuallyAiming = false
local SingleTargetToggle, AimModeToggle = nil, nil

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
    highlight.Parent = game:GetService("CoreGui")
    
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

local function GetAimPart(character)
    if AimSettings.AimPart == "Head" then
        return character:FindFirstChild("Head")
    elseif AimSettings.AimPart == "HumanoidRootPart" then
        return character:FindFirstChild("HumanoidRootPart")
    elseif AimSettings.AimPart == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
    return character:FindFirstChild("Head")
end

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

local function FindTargetInView()
    local bestTarget = nil
    local closestAngle = math.rad(AimSettings.FOV / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsEnemy(player) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local aimPart = GetAimPart(player.Character)
            
            if humanoid and humanoid.Health > 0 and aimPart then
                local distance = (aimPart.Position - Camera.CFrame.Position).Magnitude
                if distance > AimSettings.MaxDistance then
                    continue
                end
                
                local cameraDirection = Camera.CFrame.LookVector
                local targetDirection = (aimPart.Position - Camera.CFrame.Position).Unit
                local dotProduct = cameraDirection:Dot(targetDirection)
                local angle = math.acos(math.clamp(dotProduct, -1, 1))
                
                if angle <= closestAngle then
                    if AimSettings.WallCheck then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (aimPart.Position - rayOrigin).Unit * distance
                        
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
                    bestTarget = aimPart
                end
            end
        end
    end
    
    return bestTarget
end

local function FindNearestTarget()
    local nearestTarget = nil
    local minDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and IsEnemy(player) then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local aimPart = GetAimPart(player.Character)
            
            if humanoid and humanoid.Health > 0 and aimPart then
                local distance = (aimPart.Position - Camera.CFrame.Position).Magnitude
                if distance > AimSettings.MaxDistance then
                    continue
                end
                
                if distance < minDistance then
                    if AimSettings.WallCheck then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (aimPart.Position - rayOrigin).Unit * distance
                        
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
                    nearestTarget = aimPart
                end
            end
        end
    end
    
    return nearestTarget
end

local function LockTargetByName(playerName)
    for _, player in pairs(Players:GetPlayers()) do
        if (player.Name:lower():find(playerName:lower()) or player.DisplayName:lower():find(playerName:lower())) and IsEnemy(player) then
            if player.Character then
                local aimPart = GetAimPart(player.Character)
                if aimPart then
                    AimSettings.LockedTarget = aimPart
                    AimSettings.LockSingleTarget = true
                    return true
                end
            end
        end
    end
    AimSettings.LockedTarget = nil
    return false
end

local function IsTargetValid(target)
    if not target then return false end
    
    if not target:IsDescendantOf(workspace) then
        return false
    end
    
    local humanoid = target.Parent:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    local distance = (target.Position - Camera.CFrame.Position).Magnitude
    if distance > AimSettings.MaxDistance then
        return false
    end
    
    return true
end

local function AutoFaceTarget()
    if not AimSettings.AutoFaceTarget or not LocalPlayer.Character then
        TargetRay.Visible = false
        return
    end
    
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    local targetHead = nil
    
    if AimSettings.FaceMode == "Selected" and AimSettings.LockedTarget then
        targetHead = AimSettings.LockedTarget
    elseif AimSettings.FaceMode == "Nearest" then
        targetHead = FindNearestTarget()
    else
        targetHead = AimSettings.LockedTarget
    end
    
    if not targetHead or not IsTargetValid(targetHead) then
        TargetRay.Visible = false
        return
    end
    
    local targetPosition = targetHead.Position
    if AimSettings.PredictionEnabled then
        targetPosition = CalculatePredictedPosition(targetHead)
    end
    
    local direction = (targetPosition - localRoot.Position).Unit
    local currentCFrame = localRoot.CFrame
    
    local horizontalDirection = Vector3.new(direction.X, 0, direction.Z).Unit
    
    if horizontalDirection.Magnitude > 0 then
        local currentLook = currentCFrame.LookVector
        local horizontalCurrentLook = Vector3.new(currentLook.X, 0, currentLook.Z).Unit
        
        local newLook = (horizontalCurrentLook * (1 - AimSettings.FaceSpeed) + horizontalDirection * AimSettings.FaceSpeed).Unit
        localRoot.CFrame = CFrame.new(localRoot.Position, localRoot.Position + newLook)
    end
    
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

RunService.RenderStepped:Connect(function()
    Circle.Position = ScreenCenter
    Circle.Radius = AimSettings.FOV
    
    for _, espData in pairs(ESPLabels) do
        if espData and espData.update then
            espData.update()
        end
    end
    
    AutoFaceTarget()
    
    if not AimSettings.Enabled then 
        AimSettings.LockedTarget = nil
        return 
    end
    
    if AimSettings.LockedTarget then
        local isValid = IsTargetValid(AimSettings.LockedTarget)
        
        if not isValid and AimSettings.LockSingleTarget then
        else
            AimSettings.LockedTarget = isValid and AimSettings.LockedTarget or nil
        end
    end
    
    if AimSettings.LockSingleTarget then
        if not AimSettings.LockedTarget then
            if AimSettings.NearestAim then
                AimSettings.LockedTarget = FindNearestTarget()
            else
                AimSettings.LockedTarget = FindTargetInView()
            end
            
            if AimSettings.LockedTarget then
                local player = Players:GetPlayerFromCharacter(AimSettings.LockedTarget.Parent)
                if player then
                    WindUI:Notify({
                        Title = "目标锁定",
                        Content = "已锁定: " .. player.Name,
                        Duration = 2,
                    })
                end
            end
        end
    else
        local newTarget = nil
        if AimSettings.NearestAim then
            newTarget = FindNearestTarget()
        else
            newTarget = FindTargetInView()
        end
        
        if newTarget and newTarget ~= AimSettings.LockedTarget then
            if not AimSettings.LockedTarget then
                AimSettings.LockedTarget = newTarget
            else
                local currentDistance = (AimSettings.LockedTarget.Position - Camera.CFrame.Position).Magnitude
                local newDistance = (newTarget.Position - Camera.CFrame.Position).Magnitude
                
                if newDistance < currentDistance * 0.8 then
                    AimSettings.LockedTarget = newTarget
                end
            end
        end
        
        if not newTarget then
            AimSettings.LockedTarget = nil
        end
    end
    
    if AimSettings.LockedTarget and IsTargetValid(AimSettings.LockedTarget) then
        local predictedPosition = CalculatePredictedPosition(AimSettings.LockedTarget)
        
        if AimSettings.HeightOffset ~= 0 then
            predictedPosition = predictedPosition + Vector3.new(0, AimSettings.HeightOffset, 0)
        end
        
        AimAtPosition(predictedPosition)
    end
end)

UpdateESP()

Tab:Toggle({
    Title = "开启自瞄",
    Description = "启用自瞄功能",
    Default = false,
    Callback = function(Value)
        AimSettings.Enabled = Value
    end
})

Tab:Toggle({
    Title = "单锁模式",
    Description = "锁定单一目标",
    Default = false,
    Callback = function(Value)
        AimSettings.LockSingleTarget = Value
        if not Value then
            AimSettings.LockedTarget = nil
        end
    end
})

Tab:Toggle({
    Title = "近距离自瞄",
    Description = "优先瞄准最近目标",
    Default = false,
    Callback = function(Value)
        AimSettings.NearestAim = Value
    end
})

Tab:Toggle({
    Title = "开启ESP",
    Description = "显示玩家信息",
    Default = true,
    Callback = function(Value)
        AimSettings.ESPEnabled = Value
        UpdateESP()
    end
})

Tab:Toggle({
    Title = "穿墙检测",
    Description = "检测墙壁遮挡",
    Default = true,
    Callback = function(Value)
        AimSettings.WallCheck = Value
    end
})

Tab:Toggle({
    Title = "队友检测",
    Description = "忽略队友目标",
    Default = true,
    Callback = function(Value)
        AimSettings.TeamCheck = Value
        UpdateESP()
    end
})

Tab:Toggle({
    Title = "预判模式",
    Description = "启用移动预判",
    Default = true,
    Callback = function(Value)
        AimSettings.PredictionEnabled = Value
    end
})

Tab:Toggle({
    Title = "FOV圆圈",
    Description = "显示瞄准范围",
    Default = true,
    Callback = function(Value)
        Circle.Visible = Value
    end
})

Tab:Toggle({
    Title = "自动朝向目标",
    Description = "自动面向目标",
    Default = false,
    Callback = function(Value)
        AimSettings.AutoFaceTarget = Value
    end
})

Tab:Toggle({
    Title = "显示目标射线",
    Description = "显示目标射线",
    Default = true,
    Callback = function(Value)
        AimSettings.ShowTargetRay = Value
    end
})

Tab:Dropdown({
    Title = "自瞄部位",
    Description = "选择瞄准部位",
    Default = "Head",
    Items = {"Head", "HumanoidRootPart", "Torso"},
    Callback = function(Value)
        AimSettings.AimPart = Value
    end
})

Tab:Dropdown({
    Title = "瞄准模式",
    Description = "选择瞄准方式",
    Default = "Camera",
    Items = {"Camera", "Viewport"},
    Callback = function(Value)
        AimSettings.AimMode = Value
    end
})

Tab:Dropdown({
    Title = "朝向目标模式",
    Description = "选择朝向目标",
    Default = "选定目标",
    Items = {"选定目标", "最近目标"},
    Callback = function(Option)
        AimSettings.FaceMode = Option == "选定目标" and "Selected" or "Nearest"
    end
})

Tab:Textbox({
    Title = "FOV范围",
    Description = "调整瞄准范围",
    Default = 90,
    Minimum = 10,
    Maximum = 360,
    Callback = function(Value)
        AimSettings.FOV = Value
    end
})

Tab:Textbox({
    Title = "预判系数",
    Description = "调整预判强度",
    Default = 15,
    Minimum = 0,
    Maximum = 50,
    Callback = function(Value)
        AimSettings.Prediction = Value / 100
    end
})

Tab:Textbox({
    Title = "平滑度",
    Description = "调整瞄准平滑",
    Default = 90,
    Minimum = 10,
    Maximum = 100,
    Callback = function(Value)
        AimSettings.Smoothness = Value / 100
    end
})

Tab:Textbox({
    Title = "高度偏移",
    Description = "调整瞄准高度",
    Default = 0,
    Minimum = -10,
    Maximum = 10,
    Callback = function(Value)
        AimSettings.HeightOffset = Value
    end
})

Tab:Textbox({
    Title = "自瞄距离限制",
    Description = "设置最大距离",
    Default = "",
    Placeholder = "输入距离（默认无限）",
    Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            AimSettings.MaxDistance = value
            WindUI:Notify({
                Title = "自瞄距离设置成功",
                Content = "最大自瞄距离: " .. value .. " 米",
                Duration = 3,
            })
        else
            AimSettings.MaxDistance = math.huge
            WindUI:Notify({
                Title = "自瞄距离重置",
                Content = "自瞄距离限制已取消",
                Duration = 3,
            })
        end
    end
})

Tab:Textbox({
    Title = "名字锁定",
    Description = "输入玩家名字锁定",
    Default = "",
    Placeholder = "输入玩家名字...",
    Callback = function(Text)
        if Text ~= "" then
            if LockTargetByName(Text) then
                AimSettings.LockSingleTarget = true
                WindUI:Notify({
                    Title = "目标锁定",
                    Content = "已锁定玩家: " .. Text,
                    Duration = 3,
                })
            else
                WindUI:Notify({
                    Title = "锁定失败",
                    Content = "未找到目标玩家",
                    Duration = 3,
                })
            end
        end
    end
})

Tab:Button({
    Title = "取消名字锁定",
    Description = "取消当前目标锁定",
    Callback = function()
        AimSettings.LockedTarget = nil
        AimSettings.LockSingleTarget = false
        WindUI:Notify({
            Title = "锁定取消",
            Content = "目标锁定已取消",
            Duration = 2
        })
    end
})

Tab:Textbox({
    Title = "射线颜色",
    Description = "输入RGB颜色",
    Default = "",
    Placeholder = "格式: 255,0,255",
    Callback = function(Text)
        local r, g, b = Text:match("(%d+),(%d+),(%d+)")
        if r and g and b then
            AimSettings.RayColor = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
            WindUI:Notify({
                Title = "颜色设置成功",
                Content = "射线颜色已更新",
                Duration = 2,
            })
        end
    end
})

Tab:Textbox({
    Title = "朝向速度",
    Description = "输入朝向速度",
    Default = "",
    Placeholder = "范围: 0.1-1.0",
    Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0.1 and value <= 1.0 then
            AimSettings.FaceSpeed = value
            WindUI:Notify({
                Title = "速度设置成功",
                Content = "朝向速度: " .. value,
                Duration = 2,
            })
        end
    end
})

local Window = nil

Tab:Button({
    Title = "开启快捷UI",
    Description = "打开快捷自瞄界面",
    Callback = function()
        if QuickAimWindow then
            QuickAimWindow:Close()
        end
        
        Window = WindUI:CreateWindow({
            Title = "快捷自瞄",
            Icon = "zap",
            Size = UDim2.fromOffset(150, 200),
            Position = UDim2.new(0.8, 0, 0.5, 0),
            Theme = "Dark"
        })
        
        local Tab = Window:Tab({
            Title = "快捷设置",
            Icon = "zap"
        })
        
        Tab:Button({
            Title = "开关自瞄",
            Callback = function()
                AimSettings.Enabled = not AimSettings.Enabled
                WindUI:Notify({
                    Title = "自瞄状态",
                    Content = AimSettings.Enabled and "自瞄已开启" or "自瞄已关闭",
                    Duration = 2
                })
            end
        })
        
        Tab:Toggle({
            Title = "单锁模式",
            Default = false,
            Callback = function(Value)
                AimSettings.LockSingleTarget = Value
            end
        })
        
        Tab:Toggle({
            Title = "近距离自瞄",
            Default = false,
            Callback = function(Value)
                AimSettings.NearestAim = Value
            end
        })
        
        Tab:Dropdown({
            Title = "自瞄部位",
            Default = "Head",
            Items = {"Head", "HumanoidRootPart", "Torso"},
            Callback = function(Value)
                AimSettings.AimPart = Value
            end
        })
        
        Tab:Button({
            Title = "关闭本界面",
            Callback = function()
                if QuickAimWindow then
                    QuickAimWindow:Close()
                    QuickAimWindow = nil
                end
            end
        })
        
        WindUI:Notify({
            Title = "快捷UI",
            Content = "快捷自瞄界面已开启",
            Duration = 2
        })
    end
})

Tab:Button({
    Title = "关闭快捷UI",
    Description = "关闭快捷自瞄界面",
    Callback = function()
        if QuickAimWindow then
            QuickAimWindow:Close()
            QuickAimWindow = nil
            WindUI:Notify({
                Title = "快捷UI",
                Content = "快捷自瞄界面已关闭",
                Duration = 2
            })
        end
    end
})

WindUI:Notify({
    Title = "自瞄系统",
    Content = "自瞄功能加载完成！",
    Duration = 5
})