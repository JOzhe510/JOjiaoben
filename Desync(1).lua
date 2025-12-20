-- Ultimate Hybrid Desync 2025
-- 模式1: 你的Flag方法 | 模式2: 特殊游戏方法

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 使用你的Flag开关逻辑
if not getgenv then
    getgenv = function() return _G end
end

if getgenv().enabled == nil then 
    getgenv().enabled = false 
end

-- 状态变量
local desyncEnabled = false
local frozenPosition = Vector3.new(0, 0, 0)
local currentMode = "Flag" -- "Flag" 或 "Special"
local realPosUpdate = nil
local physicsHook = nil
local syncAttempts = 0

-- ==================== 你的Flag核心逻辑 ====================
local function toggleFlagState()
    -- 你的核心代码
    if getgenv().enabled == nil then getgenv().enabled = false end
    getgenv().enabled = not getgenv().enabled
    setfflag("NextGenReplicatorEnabledWrite4", tostring(getgenv().enabled))
    return getgenv().enabled
end

-- ==================== 模式1: 你的Flag方法 ====================
local function enableFlagDesync()
    if desyncEnabled then return end
    
    print("启用 Flag Desync...")
    
    -- 使用你的逻辑
    getgenv().enabled = true
    pcall(function()
        if setfflag then 
            setfflag("NextGenReplicatorEnabledWrite4", tostring(getgenv().enabled))
            print("✓ Flag 设置为: " .. tostring(getgenv().enabled))
        end
    end)
    
    -- 记录冻结位置
    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        frozenPosition = Character.HumanoidRootPart.Position
        frozenPosLabel.Text = string.format("❄ 冻结位置: %.1f, %.1f, %.1f", 
            frozenPosition.X, frozenPosition.Y, frozenPosition.Z)
    end
    
    desyncEnabled = true
    createTracer()
    startRealPosUpdate()
    
    -- 更新UI
    updateUIEnabled()
    
    print("Flag Desync Activated!")
end

local function disableFlagDesync()
    if not desyncEnabled then return end
    
    print("禁用 Flag Desync...")
    statusLabel.Text = "状态: 同步中..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    
    -- 使用你的逻辑关闭
    getgenv().enabled = false
    pcall(function()
        if setfflag then 
            setfflag("NextGenReplicatorEnabledWrite4", tostring(getgenv().enabled))
            print("✓ Flag 设置为: " .. tostring(getgenv().enabled))
        end
    end)
    
    -- 强制同步（提高成功率）
    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local HRP = Character.HumanoidRootPart
        local currentPos = HRP.Position
        
        -- 多重同步
        for i = 1, 2 do
            HRP.CFrame = CFrame.new(currentPos + Vector3.new(0, 0.02 * i, 0))
            task.wait(0.05)
            HRP.CFrame = CFrame.new(currentPos)
            task.wait(0.05)
        end
        
        -- 重置物理
        HRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        HRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    
    syncAttempts = syncAttempts + 1
    
    desyncEnabled = false
    removeTracer()
    stopRealPosUpdate()
    
    frozenPosLabel.Text = "❄ 冻结位置: ---"
    realPosLabel.Text = "📍 真实位置: ---"
    distanceLabel.Text = "📏 移动距离: ---"
    
    -- 更新UI
    updateUIDisabled()
    
    print("Flag Desync Deactivated")
end

-- ==================== 模式2: 特殊游戏方法 ====================
local function enableSpecialDesync()
    if desyncEnabled then return end
    
    print("启用特殊游戏 Desync...")
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    -- 记录冻结位置
    frozenPosition = HRP.Position
    frozenPosLabel.Text = string.format("❄ 冻结位置: %.1f, %.1f, %.1f", 
        frozenPosition.X, frozenPosition.Y, frozenPosition.Z)
    
    -- 方法1: 高网络延迟
    pcall(function()
        if setfflag then
            setfflag("NetworkOutgoingReplicationLag", "2500")  -- 2.5秒延迟
            setfflag("NetworkIncomingReplicationLag", "100")
            setfflag("PhysicsSenderHeartbeatRateMs", "1500")
            print("✓ 网络延迟已设置")
        end
    end)
    
    -- 方法2: 物理属性欺骗
    physicsHook = RunService.Stepped:Connect(function()
        if not desyncEnabled or currentMode ~= "Special" then return end
        
        pcall(function()
            local Char = LocalPlayer.Character
            if Char and Char:FindFirstChild("HumanoidRootPart") then
                local hrp = Char.HumanoidRootPart
                -- 定期发送冻结位置
                if tick() % 0.5 < 0.05 then
                    hrp:SetAttribute("LastBroadcastPosition", frozenPosition)
                    hrp:SetAttribute("NetworkTimestamp", tick() - 2)
                end
            end
        end)
    end)
    
    -- 方法3: 设置角色属性
    Character:SetAttribute("SpecialDesync", true)
    Character:SetAttribute("FrozenPosition", frozenPosition)
    
    desyncEnabled = true
    createSpecialTracer()
    startRealPosUpdate()
    
    -- 更新UI
    updateUIEnabled()
    
    print("Special Desync Activated!")
end

local function disableSpecialDesync()
    if not desyncEnabled then return end
    
    print("禁用特殊游戏 Desync...")
    
    -- 停止物理钩子
    if physicsHook then
        physicsHook:Disconnect()
        physicsHook = nil
    end
    
    -- 重置网络设置
    pcall(function()
        if setfflag then
            setfflag("NetworkOutgoingReplicationLag", "0")
            setfflag("NetworkIncomingReplicationLag", "0")
            setfflag("PhysicsSenderHeartbeatRateMs", "60")
            print("✓ 网络延迟已重置")
        end
    end)
    
    -- 强制同步
    local Character = LocalPlayer.Character
    if Character then
        Character:SetAttribute("SpecialDesync", nil)
        Character:SetAttribute("FrozenPosition", nil)
        
        local HRP = Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            -- 多重同步确保生效
            local currentPos = HRP.Position
            for i = 1, 3 do
                HRP.CFrame = CFrame.new(currentPos + Vector3.new(0, 0.03 * i, 0))
                task.wait(0.05)
                HRP.CFrame = CFrame.new(currentPos)
                task.wait(0.05)
            end
            
            -- 清除属性
            HRP:SetAttribute("LastBroadcastPosition", nil)
            HRP:SetAttribute("NetworkTimestamp", nil)
        end
    end
    
    desyncEnabled = false
    removeTracer()
    stopRealPosUpdate()
    
    frozenPosLabel.Text = "❄ 冻结位置: ---"
    realPosLabel.Text = "📍 真实位置: ---"
    distanceLabel.Text = "📏 移动距离: ---"
    
    -- 更新UI
    updateUIDisabled()
    
    print("Special Desync Deactivated")
end

-- ==================== 主开关函数 ====================
local function enableDesync()
    if desyncEnabled then return end
    
    if currentMode == "Flag" then
        enableFlagDesync()
    else
        enableSpecialDesync()
    end
end

local function disableDesync()
    if not desyncEnabled then return end
    
    if currentMode == "Flag" then
        disableFlagDesync()
    else
        disableSpecialDesync()
    end
end

local function toggleDesync()
    if desyncEnabled then
        disableDesync()
    else
        enableDesync()
    end
end

-- 切换模式
local function switchMode()
    -- 如果正在启用，先禁用
    if desyncEnabled then
        disableDesync()
        task.wait(0.5)
    end
    
    if currentMode == "Flag" then
        currentMode = "Special"
        modeBtn.Text = "切换到Flag模式"
        modeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        infoLabel.Text = "特殊游戏方法\n网络延迟 + 物理欺骗"
    else
        currentMode = "Flag"
        modeBtn.Text = "切换到特殊模式"
        modeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        infoLabel.Text = "你的Flag方法\nenabled = not enabled"
    end
    
    -- 更新UI
    modeLabel.Text = "模式: " .. (currentMode == "Flag" and "Flag方法" or "特殊方法")
    updateUIDisabled()
    
    print("切换到模式: " .. currentMode)
end

-- ==================== UI更新函数 ====================
local function updateUIEnabled()
    if currentMode == "Flag" then
        toggleBtn.Text = "Desync ON (Flag)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        statusLabel.Text = "状态: Flag模式已启用"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
        infoLabel.Text = "Flag方法已启用\n别人看你卡在冻结位置"
    else
        toggleBtn.Text = "Desync ON (Special)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        statusLabel.Text = "状态: 特殊模式已启用"
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        infoLabel.Text = "特殊方法已启用\n网络延迟 + 物理欺骗"
    end
    
    flagStatusLabel.Text = "Flag状态: " .. tostring(getgenv().enabled)
    flagStatusLabel.TextColor3 = getgenv().enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
end

local function updateUIDisabled()
    toggleBtn.Text = "启用 Desync"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    statusLabel.Text = "状态: 已禁用"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    flagStatusLabel.Text = "Flag状态: " .. tostring(getgenv().enabled)
    flagStatusLabel.TextColor3 = getgenv().enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
    
    if syncAttempts >= 2 and currentMode == "Flag" then
        infoLabel.Text = "⚠️ Flag模式可能需要重进\n建议切换到特殊模式"
    end
end

-- ==================== 追踪器系统 ====================
local tracerPart, att0, att1, beam

local function createTracer()
    removeTracer()
    
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")

    tracerPart = Instance.new("Part")
    tracerPart.Name = "FlagDesyncTracer"
    tracerPart.Size = Vector3.new(3, 3, 3)
    tracerPart.Anchored = true
    tracerPart.CanCollide = false
    tracerPart.Transparency = 0.4
    tracerPart.Material = Enum.Material.Neon
    tracerPart.Color = Color3.fromRGB(0, 200, 255)
    tracerPart.Shape = Enum.PartType.Ball
    tracerPart.Parent = workspace

    att0 = Instance.new("Attachment", HRP)
    att1 = Instance.new("Attachment", tracerPart)

    beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255))
    beam.Width0 = 2.5
    beam.Width1 = 2.5
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.Transparency = NumberSequence.new(0.2)
    beam.Parent = tracerPart

    RunService.Heartbeat:Connect(function()
        if tracerPart and tracerPart.Parent and HRP and HRP.Parent then
            tracerPart.CFrame = HRP.CFrame
        else
            removeTracer()
        end
    end)
end

local function createSpecialTracer()
    removeTracer()
    
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")

    tracerPart = Instance.new("Part")
    tracerPart.Name = "SpecialDesyncTracer"
    tracerPart.Size = Vector3.new(3, 3, 3)
    tracerPart.Anchored = true
    tracerPart.CanCollide = false
    tracerPart.Transparency = 0.4
    tracerPart.Material = Enum.Material.Neon
    tracerPart.Color = Color3.fromRGB(255, 150, 0)
    tracerPart.Shape = Enum.PartType.Ball
    tracerPart.Parent = workspace

    -- 添加发光
    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 15
    light.Color = Color3.fromRGB(255, 150, 0)
    light.Parent = tracerPart

    att0 = Instance.new("Attachment", HRP)
    att1 = Instance.new("Attachment", tracerPart)

    beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 150, 0))
    beam.Width0 = 2.5
    beam.Width1 = 2.5
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.Transparency = NumberSequence.new(0.2)
    beam.Parent = tracerPart

    RunService.Heartbeat:Connect(function()
        if tracerPart and tracerPart.Parent and HRP and HRP.Parent then
            tracerPart.CFrame = HRP.CFrame
        else
            removeTracer()
        end
    end)
end

local function removeTracer()
    if tracerPart then tracerPart:Destroy() end
    if att0 then att0:Destroy() end
    if att1 then att1:Destroy() end
    if beam then beam:Destroy() end
    tracerPart, att0, att1, beam = nil, nil, nil, nil
end

-- ==================== 实时位置更新 ====================
local function startRealPosUpdate()
    if realPosUpdate then 
        realPosUpdate:Disconnect() 
    end
    
    realPosUpdate = RunService.Heartbeat:Connect(function()
        if not desyncEnabled then return end
        
        local Character = LocalPlayer.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local realPos = Character.HumanoidRootPart.Position
            realPosLabel.Text = string.format("📍 真实位置: %.1f, %.1f, %.1f", 
                realPos.X, realPos.Y, realPos.Z)
            
            -- 计算距离
            local distance = (realPos - frozenPosition).Magnitude
            distanceLabel.Text = string.format("📏 移动距离: %.1f 米", distance)
        end
    end)
end

local function stopRealPosUpdate()
    if realPosUpdate then
        realPosUpdate:Disconnect()
        realPosUpdate = nil
    end
    realPosLabel.Text = "📍 真实位置: ---"
    distanceLabel.Text = "📏 移动距离: ---"
end

-- ==================== 可拖动 UI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HybridDesync_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 360)
frame.Position = UDim2.new(0.5, -190, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 15)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 255)
stroke.Thickness = 3

-- 标题
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 50)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🔥 Hybrid Desync 2025"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- 模式显示
local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(1, -20, 0, 25)
modeLabel.Position = UDim2.new(0, 10, 0, 65)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "模式: Flag方法"
modeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextSize = 16
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.Parent = frame

-- Flag状态显示
local flagStatusLabel = Instance.new("TextLabel")
flagStatusLabel.Size = UDim2.new(1, -20, 0, 25)
flagStatusLabel.Position = UDim2.new(0, 10, 0, 95)
flagStatusLabel.BackgroundTransparency = 1
flagStatusLabel.Text = "Flag状态: " .. tostring(getgenv().enabled)
flagStatusLabel.TextColor3 = getgenv().enabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
flagStatusLabel.Font = Enum.Font.Gotham
flagStatusLabel.TextSize = 14
flagStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
flagStatusLabel.Parent = frame

-- 状态显示
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 125)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "状态: 已禁用"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

-- 冻结位置显示
local frozenPosLabel = Instance.new("TextLabel")
frozenPosLabel.Size = UDim2.new(1, -20, 0, 25)
frozenPosLabel.Position = UDim2.new(0, 10, 0, 155)
frozenPosLabel.BackgroundTransparency = 1
frozenPosLabel.Text = "❄ 冻结位置: ---"
frozenPosLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
frozenPosLabel.Font = Enum.Font.Gotham
frozenPosLabel.TextSize = 14
frozenPosLabel.TextXAlignment = Enum.TextXAlignment.Left
frozenPosLabel.Parent = frame

-- 真实位置显示
local realPosLabel = Instance.new("TextLabel")
realPosLabel.Size = UDim2.new(1, -20, 0, 25)
realPosLabel.Position = UDim2.new(0, 10, 0, 180)
realPosLabel.BackgroundTransparency = 1
realPosLabel.Text = "📍 真实位置: ---"
realPosLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
realPosLabel.Font = Enum.Font.Gotham
realPosLabel.TextSize = 14
realPosLabel.TextXAlignment = Enum.TextXAlignment.Left
realPosLabel.Parent = frame

-- 距离显示
local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(1, -20, 0, 25)
distanceLabel.Position = UDim2.new(0, 10, 0, 205)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Text = "📏 移动距离: ---"
distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 14
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = frame

-- 分割线
local line = Instance.new("Frame")
line.Size = UDim2.new(1, -20, 0, 2)
line.Position = UDim2.new(0, 10, 0, 235)
line.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
line.BorderSizePixel = 0
line.Parent = frame

-- 说明
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 70)
infoLabel.Position = UDim2.new(0, 10, 0, 245)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "你的Flag方法\nenabled = not enabled"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 16
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = frame

-- 模式切换按钮
local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.45, 0, 0, 40)
modeBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
modeBtn.Text = "切换到特殊模式"
modeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
modeBtn.TextColor3 = Color3.new(1,1,1)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 14
modeBtn.Parent = frame

local modeCorner = Instance.new("UICorner", modeBtn)
modeCorner.CornerRadius = UDim.new(0, 8)

-- 开关按钮
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.45, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.5, 0, 0.85, 0)
toggleBtn.Text = "启用 Desync"
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 10)

-- 按钮事件
toggleBtn.MouseButton1Click:Connect(function()
    toggleDesync()
end)

modeBtn.MouseButton1Click:Connect(function()
    switchMode()
end)

-- 鼠标效果
toggleBtn.MouseEnter:Connect(function()
    if desyncEnabled then
        toggleBtn.BackgroundColor3 = currentMode == "Flag" and 
            Color3.fromRGB(0, 180, 230) or Color3.fromRGB(255, 130, 0)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

toggleBtn.MouseLeave:Connect(function()
    if desyncEnabled then
        toggleBtn.BackgroundColor3 = currentMode == "Flag" and 
            Color3.fromRGB(0, 200, 255) or Color3.fromRGB(255, 150, 0)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

modeBtn.MouseEnter:Connect(function()
    modeBtn.BackgroundColor3 = currentMode == "Flag" and 
        Color3.fromRGB(120, 120, 255) or Color3.fromRGB(255, 170, 70)
end)

modeBtn.MouseLeave:Connect(function()
    modeBtn.BackgroundColor3 = currentMode == "Flag" and 
        Color3.fromRGB(100, 100, 255) or Color3.fromRGB(255, 150, 50)
end)

-- 键盘快捷键
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        if input.KeyCode == Enum.KeyCode.F then
            toggleBtn:Activate()
        elseif input.KeyCode == Enum.KeyCode.G then
            modeBtn:Activate()
        end
    end
end)

-- 角色事件
LocalPlayer.CharacterAdded:Connect(function()
    if desyncEnabled then
        task.wait(0.5)
        enableDesync()
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    removeTracer()
end)

-- 初始UI状态
updateUIDisabled()

print("🔥 Hybrid Desync 2025 已加载!")
print("📌 F键: 开关Desync")
print("📌 G键: 切换模式")
print("🎮 模式1: 你的Flag方法 (蓝色)")
print("🎮 模式2: 特殊游戏方法 (橙色)")
print("💡 当前Flag状态: " .. tostring(getgenv().enabled))