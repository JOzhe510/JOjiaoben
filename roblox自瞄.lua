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

local FOV = 80
local Prediction = 0.15
local Smoothness = 0.8
local Enabled = true
local LockedTarget = nil
local LockSingleTarget = true
local ESPEnabled = true
local WallCheck = true
local PredictionEnabled = true -- 新增：预判开关

local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Radius = FOV
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 2
Circle.Position = ScreenCenter
Circle.Transparency = 1
Circle.NumSides = 64
Circle.Filled = false

local ESPObjects = {}
local Highlights = {}

-- 存储目标历史位置用于预判计算
local TargetHistory = {}
local MAX_HISTORY = 10 -- 存储最近10帧的位置数据

-- 建筑检测函数
local function isVisible(part)
    if not WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local rayResult = workspace:Raycast(origin, direction, rayParams)
    return not rayResult or rayResult.Instance:IsDescendantOf(part.Parent)
end

-- 创建高亮轮廓
local function createHighlight(player)
    if Highlights[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = nil
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = game.CoreGui
    
    Highlights[player] = highlight
end

-- 移除高亮
local function removeHighlight(player)
    local highlight = Highlights[player]
    if highlight then
        highlight:Destroy()
        Highlights[player] = nil
    end
end

local function createESP(player)
    if ESPObjects[player] then return ESPObjects[player] end
    
    local esp = {
        player = player,
        nameText = Drawing.new("Text"),
        healthText = Drawing.new("Text"),
        visible = false
    }
    
    esp.nameText.Text = player.Name
    esp.nameText.Size = 16
    esp.nameText.Center = true
    esp.nameText.Outline = true
    esp.nameText.Color = Color3.fromRGB(255, 255, 255)
    esp.nameText.Visible = false
    
    esp.healthText.Size = 14
    esp.healthText.Center = true
    esp.healthText.Outline = true
    esp.healthText.Color = Color3.fromRGB(255, 255, 255)
    esp.healthText.Visible = false
    
    ESPObjects[player] = esp
    return esp
end

local function removeESP(player)
    local esp = ESPObjects[player]
    if esp then
        pcall(function()
            esp.nameText:Remove()
            esp.healthText:Remove()
        end)
        ESPObjects[player] = nil
    end
    removeHighlight(player)
end

local function updateESP()
    if not ESPEnabled then 
        for _, esp in pairs(ESPObjects) do
            esp.nameText.Visible = false
            esp.healthText.Visible = false
        end
        for _, highlight in pairs(Highlights) do
            highlight.Enabled = false
        end
        return 
    end
    
    for player, esp in pairs(ESPObjects) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            
            if humanoid and head and humanoid.Health > 0 then
                local success, screenPosition = pcall(function()
                    return Camera:WorldToViewportPoint(head.Position)
                end)
                
                if success and screenPosition and screenPosition.Z > 0 then
                    -- 名字和血量文本
                    esp.nameText.Position = Vector2.new(screenPosition.X, screenPosition.Y - 40)
                    esp.nameText.Visible = true
                    
                    esp.healthText.Text = "HP: " .. math.floor(humanoid.Health)
                    esp.healthText.Position = Vector2.new(screenPosition.X, screenPosition.Y - 60)
                    esp.healthText.Visible = true
                    
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    esp.healthText.Color = color
                    esp.nameText.Color = color
                    
                    -- 高亮轮廓（与ESP同步启用）
                    if ESPEnabled then
                        if not Highlights[player] then
                            createHighlight(player)
                        end
                        local highlight = Highlights[player]
                        highlight.Adornee = player.Character
                        highlight.Enabled = true
                        highlight.OutlineColor = color
                    else
                        removeHighlight(player)
                    end
                    
                    esp.visible = true
                else
                    esp.visible = false
                    esp.nameText.Visible = false
                    esp.healthText.Visible = false
                    removeHighlight(player)
                end
            else
                esp.visible = false
                esp.nameText.Visible = false
                esp.healthText.Visible = false
                removeHighlight(player)
            end
        else
            esp.visible = false
            esp.nameText.Visible = false
            esp.healthText.Visible = false
            removeHighlight(player)
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "AimBotUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 310) -- 增加高度以容纳新按钮
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- 添加展开/收起按钮
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 30, 0, 20)
ToggleButton.Position = UDim2.new(1, -30, 0, 0)
ToggleButton.Text = "▲"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.BackgroundTransparency = 0.3
ToggleButton.BorderSizePixel = 0
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 4)
ToggleCorner.Parent = ToggleButton

-- 存储UI元素引用以便控制显示/隐藏
local UIElements = {}
local isExpanded = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔥 预判自瞄面板 🔥"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.BackgroundTransparency = 0.3
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 0
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame
table.insert(UIElements, Title)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.12, 0)
ToggleBtn.Text = "🎯 自瞄: 开启"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.Parent = Frame
table.insert(UIElements, ToggleBtn)

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

local ESPToggleBtn = Instance.new("TextButton")
ESPToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ESPToggleBtn.Position = UDim2.new(0.1, 0, 0.24, 0)
ESPToggleBtn.Text = "👁 ESP: 开启"
ESPToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ESPToggleBtn.BackgroundTransparency = 0.2
ESPToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggleBtn.BorderSizePixel = 0
ESPToggleBtn.Font = Enum.Font.Gotham
ESPToggleBtn.Parent = Frame
table.insert(UIElements, ESPToggleBtn)

local ESPToggleCorner = Instance.new("UICorner")
ESPToggleCorner.CornerRadius = UDim.new(0, 6)
ESPToggleCorner.Parent = ESPToggleBtn

local WallCheckBtn = Instance.new("TextButton")
WallCheckBtn.Size = UDim2.new(0.8, 0, 0, 30)
WallCheckBtn.Position = UDim2.new(0.1, 0, 0.36, 0)
WallCheckBtn.Text = "🧱 建筑检测: 开启"
WallCheckBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
WallCheckBtn.BackgroundTransparency = 0.2
WallCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WallCheckBtn.BorderSizePixel = 0
WallCheckBtn.Font = Enum.Font.Gotham
WallCheckBtn.Parent = Frame
table.insert(UIElements, WallCheckBtn)

local WallCheckCorner = Instance.new("UICorner")
WallCheckCorner.CornerRadius = UDim.new(0, 6)
WallCheckCorner.Parent = WallCheckBtn

-- 新增预判开关按钮
local PredictionBtn = Instance.new("TextButton")
PredictionBtn.Size = UDim2.new(0.8, 0, 0, 30)
PredictionBtn.Position = UDim2.new(0.1, 0, 0.48, 0)
PredictionBtn.Text = "🚀 预判模式: 开启"
PredictionBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PredictionBtn.BackgroundTransparency = 0.2
PredictionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictionBtn.BorderSizePixel = 0
PredictionBtn.Font = Enum.Font.Gotham
PredictionBtn.Parent = Frame
table.insert(UIElements, PredictionBtn)

local PredictionCorner = Instance.new("UICorner")
PredictionCorner.CornerRadius = UDim.new(0, 6)
PredictionCorner.Parent = PredictionBtn

local FOVInput = Instance.new("TextBox")
FOVInput.Size = UDim2.new(0.8, 0, 0, 30)
FOVInput.Position = UDim2.new(0.1, 0, 0.6, 0)
FOVInput.Text = tostring(FOV)
FOVInput.PlaceholderText = "输入FOV值"
FOVInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FOVInput.BackgroundTransparency = 0.2
FOVInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVInput.BorderSizePixel = 0
FOVInput.Font = Enum.Font.Gotham
FOVInput.Parent = Frame
table.insert(UIElements, FOVInput)

local FOVInputCorner = Instance.new("UICorner")
FOVInputCorner.CornerRadius = UDim.new(0, 6)
FOVInputCorner.Parent = FOVInput

local PredictionInput = Instance.new("TextBox")
PredictionInput.Size = UDim2.new(0.8, 0, 0, 30)
PredictionInput.Position = UDim2.new(0.1, 0, 0.72, 0)
PredictionInput.Text = tostring(Prediction)
PredictionInput.PlaceholderText = "预判系数 (0.1-0.5)"
PredictionInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PredictionInput.BackgroundTransparency = 0.2
PredictionInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictionInput.BorderSizePixel = 0
PredictionInput.Font = Enum.Font.Gotham
PredictionInput.Parent = Frame
table.insert(UIElements, PredictionInput)

local PredictionInputCorner = Instance.new("UICorner")
PredictionInputCorner.CornerRadius = UDim.new(0, 6)
PredictionInputCorner.Parent = PredictionInput

local SingleTargetBtn = Instance.new("TextButton")
SingleTargetBtn.Size = UDim2.new(0.8, 0, 0, 30)
SingleTargetBtn.Position = UDim2.new(0.1, 0, 0.84, 0)
SingleTargetBtn.Text = "🔒 单锁一人: 开启"
SingleTargetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SingleTargetBtn.BackgroundTransparency = 0.2
SingleTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SingleTargetBtn.BorderSizePixel = 0
SingleTargetBtn.Font = Enum.Font.Gotham
SingleTargetBtn.Parent = Frame
table.insert(UIElements, SingleTargetBtn)

local SingleCorner = Instance.new("UICorner")
SingleCorner.CornerRadius = UDim.new(0, 6)
SingleCorner.Parent = SingleTargetBtn

-- 展开/收起功能实现
local function toggleUI()
    isExpanded = not isExpanded
    
    if isExpanded then
        -- 展开UI
        Frame.Size = UDim2.new(0, 220, 0, 310)
        ToggleButton.Text = "▲"
        
        for _, element in pairs(UIElements) do
            element.Visible = true
        end
    else
        -- 收起UI
        Frame.Size = UDim2.new(0, 220, 0, 30)
        ToggleButton.Text = "▼"
        
        for _, element in pairs(UIElements) do
            if element ~= Title then
                element.Visible = false
            end
        end
    end
end

-- 绑定展开/收起按钮事件
ToggleButton.MouseButton1Click:Connect(toggleUI)

FOVInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newFOV = tonumber(FOVInput.Text)
        if newFOV and newFOV >= 20 and newFOV <= 200 then
            FOV = newFOV
            Circle.Radius = FOV
            FOVInput.Text = tostring(FOV)
        else
            FOVInput.Text = tostring(FOV)
        end
    end
end)

PredictionInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newPrediction = tonumber(PredictionInput.Text)
        if newPrediction and newPrediction >= 0.1 and newPrediction <= 0.5 then
            Prediction = newPrediction
            PredictionInput.Text = tostring(Prediction)
        else
            PredictionInput.Text = tostring(Prediction)
        end
    end
end)

function IsTargetValid(target)
    if not target or not target.Parent then return false end
    if not target:IsA("BasePart") then return false end
    
    local humanoid = target.Parent:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local success, health = pcall(function()
        return humanoid.Health
    end)
    
    return success and health > 0 and isVisible(target)
end

-- 计算预判位置
local function CalculatePredictedPosition(target)
    if not target or not PredictionEnabled then
        return target and target.Position or nil
    end
    
    local player = Players:GetPlayerFromCharacter(target.Parent)
    if not player then return target.Position end
    
    -- 获取目标历史位置
    if not TargetHistory[player] then
        TargetHistory[player] = {}
    end
    
    local history = TargetHistory[player]
    table.insert(history, {
        position = target.Position,
        time = tick()
    })
    
    -- 保持历史记录长度
    while #history > MAX_HISTORY do
        table.remove(history, 1)
    end
    
    -- 如果有足够的历史数据来计算速度
    if #history >= 2 then
        local latest = history[#history]
        local previous = history[#history - 1]
        
        local timeDiff = latest.time - previous.time
        if timeDiff > 0 then
            -- 计算速度向量
            local velocity = (latest.position - previous.position) / timeDiff
            
            -- 计算到目标的距离
            local distance = (target.Position - Camera.CFrame.Position).Magnitude
            
            -- 根据距离和预判系数计算预判位置
            local predictedPosition = target.Position + (velocity * Prediction * distance)
            
            return predictedPosition
        end
    end
    
    -- 如果没有足够的历史数据，使用简单的速度预测
    if target.Velocity.Magnitude > 0 then
        local distance = (target.Position - Camera.CFrame.Position).Magnitude
        return target.Position + (target.Velocity * Prediction * distance)
    end
    
    return target.Position
end

function GetTarget()
    if LockSingleTarget and LockedTarget then
        if IsTargetValid(LockedTarget) then
            local success, screenPos = pcall(function()
                return Camera:WorldToViewportPoint(LockedTarget.Position)
            end)
            if success and screenPos and screenPos.Z > 0 then
                return LockedTarget
            end
        else
            LockedTarget = nil
        end
    end
    
    local closest = nil
    local closestDist = FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head and IsTargetValid(head) then
                local success, screenPos = pcall(function()
                    return Camera:WorldToViewportPoint(head.Position)
                end)
                if success and screenPos and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                    if dist < closestDist then
                        closest = head
                        closestDist = dist
                    end
                end
            end
        end
    end
    
    if LockSingleTarget and closest and not LockedTarget then
        LockedTarget = closest
    end
    
    return closest
end

local function AimToTarget(target)
    if not target or not target:IsA("BasePart") then return false end
    
    -- 计算预判位置
    local predictedPosition = CalculatePredictedPosition(target)
    
    local success, targetPos = pcall(function()
        return predictedPosition
    end)
    if not success then return false end
    
    local success, cameraPos = pcall(function()
        return Camera.CFrame.Position
    end)
    if not success then return false end
    
    local newCFrame = CFrame.new(cameraPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Smoothness)
    return true
end

RunService:BindToRenderStep("AimBot", Enum.RenderPriority.Camera.Value, function()
    if not Enabled then return end
    if not LocalPlayer or not LocalPlayer.Character then return end
    
    local target = GetTarget()
    if target then
        AimToTarget(target)
    end
end)

RunService:BindToRenderStep("ESP", Enum.RenderPriority.Last.Value, function()
    updateESP()
end)

ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Circle.Visible = Enabled
    ToggleBtn.Text = "🎯 自瞄: " .. (Enabled and "开启" or "关闭")
end)

ESPToggleBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggleBtn.Text = "👁 ESP: " .. (ESPEnabled and "开启" or "关闭")
end)

WallCheckBtn.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    WallCheckBtn.Text = "🧱 建筑检测: " .. (WallCheck and "开启" or "关闭")
end)

PredictionBtn.MouseButton1Click:Connect(function()
    PredictionEnabled = not PredictionEnabled
    PredictionBtn.Text = "🚀 预判模式: " .. (PredictionEnabled and "开启" or "关闭")
end)

SingleTargetBtn.MouseButton1Click:Connect(function()
    LockSingleTarget = not LockSingleTarget
    SingleTargetBtn.Text = "🔒 单锁一人: " .. (LockSingleTarget and "开启" or "关闭")
    LockedTarget = nil
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        Enabled = not Enabled
        Circle.Visible = Enabled
        ToggleBtn.Text = "🎯 自瞄: " .. (Enabled and "开启" or "关闭")
    elseif input.KeyCode == Enum.KeyCode.T then
        LockedTarget = nil
    elseif input.KeyCode == Enum.KeyCode.F then
        local target = GetTarget()
        if target then
            LockedTarget = target
        end
    elseif input.KeyCode == Enum.KeyCode.V then
        ESPEnabled = not ESPEnabled
        ESPToggleBtn.Text = "👁 ESP: " .. (ESPEnabled and "开启" or "关闭")
    elseif input.KeyCode == Enum.KeyCode.B then
        WallCheck = not WallCheck
        WallCheckBtn.Text = "🧱 建筑检测: " .. (WallCheck and "开启" or "关闭")
    elseif input.KeyCode == Enum.KeyCode.P then
        PredictionEnabled = not PredictionEnabled
        PredictionBtn.Text = "🚀 预判模式: " .. (PredictionEnabled and "开启" or "关闭")
    elseif input.KeyCode == Enum.KeyCode.U then
        toggleUI()
    end
end)

Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    if player == LocalPlayer then
        pcall(function() Circle:Remove() end)
        pcall(function() ScreenGui:Destroy() end)
        
        for _, esp in pairs(ESPObjects) do
            pcall(function()
                esp.nameText:Remove()
                esp.healthText:Remove()
            end)
        end
        ESPObjects = {}
        
        for _, highlight in pairs(Highlights) do
            pcall(function() highlight:Destroy() end)
        end
        Highlights = {}
    else
        if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:IsDescendantOf(workspace) then
            local targetPlayer = Players:GetPlayerFromCharacter(LockedTarget.Parent)
            if targetPlayer == player then
                LockedTarget = nil
            end
        end
        -- 移除历史数据
        TargetHistory[player] = nil
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

RunService.RenderStepped:Connect(function()
    if Circle then
        Circle.Position = ScreenCenter
    end
end)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if Camera and Camera.ViewportSize then
        ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        if Circle then
            Circle.Position = ScreenCenter
        end
    end
end)

game:BindToClose(function()
    pcall(function() Circle:Remove() end)
    pcall(function() ScreenGui:Destroy() end)
    
    for _, esp in pairs(ESPObjects) do
        pcall(function()
            esp.nameText:Remove()
            esp.healthText:Remove()
        end)
    end
    
    for _, highlight in pairs(Highlights) do
        pcall(function() highlight:Destroy() end)
    end
end)

print("预判自瞄脚本加载完成")
print("FOV:", FOV)
print("预判系数:", Prediction)
print("预判模式:", PredictionEnabled)
print("单锁模式:", LockSingleTarget)
print("自瞄状态:", Enabled)
print("ESP状态:", ESPEnabled)
print("建筑检测:", WallCheck)
print("按P键切换预判模式")
print("按U键展开/收起UI")