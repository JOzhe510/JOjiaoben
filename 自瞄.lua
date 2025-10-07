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

-- 自瞄系统变量
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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
    AimPart = "Head" -- 新增：自瞄部位切换
}

local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Radius = AimSettings.FOV
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 2
Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
Circle.Transparency = 1
Circle.NumSides = 64
Circle.Filled = false

-- 快捷UI开关变量
local QuickAimUI = {
    Enabled = false,
    Position = UDim2.new(0.8, 0, 0.5, 0),
    Size = UDim2.new(0, 150, 0, 200)
}

-- 自瞄功能函数
local function IsEnemy(player)
    if not AimSettings.TeamCheck then return true end
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    return true
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
    local distance = (target.Position - Camera.CFrame.Position).Magnitude
    local travelTime = distance / 1000
    local velocityOffset = target.Velocity * travelTime * AimSettings.Prediction
    return target.Position + velocityOffset
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
                if distance > AimSettings.MaxDistance then continue end
                
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
                        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                        if raycastResult and not raycastResult.Instance:IsDescendantOf(player.Character) then
                            continue
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
                if distance > AimSettings.MaxDistance then continue end
                
                if distance < minDistance then
                    if AimSettings.WallCheck then
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (aimPart.Position - rayOrigin).Unit * distance
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                        if raycastResult and not raycastResult.Instance:IsDescendantOf(player.Character) then
                            continue
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
            pcall(function() mousemoverel(delta.X, delta.Y) end)
        end
    end
end

RunService.RenderStepped:Connect(function()
    Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    Circle.Radius = AimSettings.FOV
    
    if not AimSettings.Enabled then 
        AimSettings.LockedTarget = nil
        return 
    end
    
    if AimSettings.LockSingleTarget then
        if not AimSettings.LockedTarget then
            if AimSettings.NearestAim then
                AimSettings.LockedTarget = FindNearestTarget()
            else
                AimSettings.LockedTarget = FindTargetInView()
            end
        end
    else
        local newTarget = AimSettings.NearestAim and FindNearestTarget() or FindTargetInView()
        AimSettings.LockedTarget = newTarget
    end
    
    if AimSettings.LockedTarget then
        local predictedPosition = CalculatePredictedPosition(AimSettings.LockedTarget)
        if AimSettings.HeightOffset ~= 0 then
            predictedPosition = predictedPosition + Vector3.new(0, AimSettings.HeightOffset, 0)
        end
        AimAtPosition(predictedPosition)
    end
end)

-- 创建快捷UI
local function CreateQuickAimUI()
    if QuickAimUI.Enabled then return end
    
    local Tab = Window:Tab({
        Title = "快捷设置",
        Icon = "zap"
    })
    
    Tab:Toggle({
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
    
    QuickAimUI.Enabled = true
    QuickAimUI.Window = QuickWindow
end

-- 自瞄功能按键
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
    Title = "自动朝向",
    Description = "自动面向目标",
    Default = false,
    Callback = function(Value)
        AimSettings.AutoFaceTarget = Value
    end
})

Tab:Toggle({
    Title = "显示射线",
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
    Title = "自瞄距离",
    Description = "设置最大距离",
    Default = "",
    Placeholder = "输入距离（默认无限）",
    Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            AimSettings.MaxDistance = value
            WindUI:Notify({
                Title = "距离设置",
                Content = "最大距离: " .. value .. " 米",
                Duration = 3
            })
        else
            AimSettings.MaxDistance = math.huge
            WindUI:Notify({
                Title = "距离重置",
                Content = "距离限制已取消",
                Duration = 3
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
            for _, player in pairs(Players:GetPlayers()) do
                if (player.Name:lower():find(Text:lower()) or player.DisplayName:lower():find(Text:lower())) and IsEnemy(player) then
                    if player.Character then
                        local aimPart = GetAimPart(player.Character)
                        if aimPart then
                            AimSettings.LockedTarget = aimPart
                            AimSettings.LockSingleTarget = true
                            WindUI:Notify({
                                Title = "目标锁定",
                                Content = "已锁定: " .. player.Name,
                                Duration = 3
                            })
                            return
                        end
                    end
                end
            end
            WindUI:Notify({
                Title = "锁定失败",
                Content = "未找到目标玩家",
                Duration = 3
            })
        end
    end
})

Tab:Button({
    Title = "取消锁定",
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

Tab:Button({
    Title = "开启快捷UI",
    Description = "打开快捷自瞄界面",
    Callback = function()
        CreateQuickAimUI()
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
        if QuickAimUI.Enabled and QuickAimUI.Window then
            QuickAimUI.Window:Close()
            QuickAimUI.Enabled = false
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