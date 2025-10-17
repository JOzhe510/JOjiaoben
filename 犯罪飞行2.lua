local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 连接管理
local connections = {}
local isRunning = false

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RagdollUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = " 布娃娃控制"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -25, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Parent = frame
closeButton.MouseButton1Click:Connect(function()
    cleanup()
end)

local ragdollButton = Instance.new("TextButton")
ragdollButton.Size = UDim2.new(0, 180, 0, 50)
ragdollButton.Position = UDim2.new(0, 10, 0, 35)
ragdollButton.Text = "开启布娃娃"
ragdollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ragdollButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
ragdollButton.Parent = frame

local ragdollEnabled = false
local originalStates = {}
local ragdollParts = {}
local bodyVelocities = {}

-- 清理函数
local function cleanup()
    ragdollEnabled = false
    ragdollButton.Text = "开启布娃娃"
    
    -- 断开所有连接
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}
    
    -- 恢复物理状态
    local character = LocalPlayer.Character
    if character then
        restoreOriginalPhysics(character)
    end
    
    -- 清理UI
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end

-- 获取玩家框架结构
local function getCharacterRig(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    
    local rigType = humanoid.RigType.Name
    return rigType
end

-- 创建布娃娃物理
local function createRagdollPhysics(character)
    -- 先清理可能存在的旧实例
    restoreOriginalPhysics(character)
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    -- 等待角色完全加载
    if not character:FindFirstChild("HumanoidRootPart") then
        character:WaitForChild("HumanoidRootPart")
    end
    
    -- 重置状态
    originalStates = {}
    ragdollParts = {}
    bodyVelocities = {}
    
    -- 保存原始状态
    originalStates.humanoid = {
        PlatformStand = humanoid.PlatformStand,
        AutoRotate = humanoid.AutoRotate
    }
    
    -- 设置人类状态
    humanoid.PlatformStand = true
    humanoid.AutoRotate = false
    
    -- 处理所有身体部件
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            -- 跳过HumanoidRootPart的特殊处理
            if part.Name == "HumanoidRootPart" then
                originalStates[part] = {
                    CanCollide = part.CanCollide
                }
                part.CanCollide = true
                continue
            end
            
            -- 保存原始状态
            originalStates[part] = {
                CanCollide = part.CanCollide,
                Anchored = part.Anchored
            }
            
            -- 启用物理
            part.CanCollide = true
            part.Anchored = false
            
            -- 为除HRP外的部件创建BodyVelocity
            if part.Name ~= "HumanoidRootPart" then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new()
                bodyVelocity.MaxForce = Vector3.new(1000, 1000, 1000) -- 减少力的大小
                bodyVelocity.P = 500
                bodyVelocity.Parent = part
                
                table.insert(ragdollParts, part)
                bodyVelocities[part] = bodyVelocity
            end
        elseif part:IsA("Motor6D") then
            originalStates[part] = {
                Enabled = part.Enabled
            }
            part.Enabled = false
        end
    end
    
    return true
end

-- 恢复原始状态
local function restoreOriginalPhysics(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    -- 恢复人类状态
    if humanoid and originalStates.humanoid then
        humanoid.PlatformStand = originalStates.humanoid.PlatformStand
        humanoid.AutoRotate = originalStates.humanoid.AutoRotate
    end
    
    -- 恢复部件状态
    for part, state in pairs(originalStates) do
        if part:IsA("BasePart") and part.Parent then
            part.CanCollide = state.CanCollide
            part.Anchored = state.Anchored
        elseif part:IsA("Motor6D") and part.Parent then
            part.Enabled = state.Enabled
        end
    end
    
    -- 清理创建的实例
    for _, bodyVelocity in pairs(bodyVelocities) do
        if bodyVelocity and bodyVelocity.Parent then
            bodyVelocity:Destroy()
        end
    end
    
    ragdollParts = {}
    bodyVelocities = {}
    originalStates = {}
end

-- 布娃娃移动控制
local function updateRagdollMovement(character, moveDirection, jump)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not humanoid then return end
    
    -- 更温和的移动控制
    local speed = humanoid.WalkSpeed * 0.7 -- 降低速度
    
    if moveDirection.Magnitude > 0 then
        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        local moveVector = cameraCFrame:VectorToWorldSpace(moveDirection)
        moveVector = Vector3.new(moveVector.X, 0, moveVector.Z).Unit
        
        local moveForce = moveVector * speed
        hrp.Velocity = Vector3.new(moveForce.X, hrp.Velocity.Y, moveForce.Z)
    else
        -- 更温和的减速
        hrp.Velocity = Vector3.new(hrp.Velocity.X * 0.8, hrp.Velocity.Y, hrp.Velocity.Z * 0.8)
    end
    
    -- 跳跃控制
    if jump and hrp.Velocity.Y > -5 then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
    end
    
    -- 更温和的身体部件跟随
    for part, bodyVelocity in pairs(bodyVelocities) do
        if part and part.Parent and part ~= hrp then
            local offset = part.Position - hrp.Position
            if offset.Magnitude > 3 then
                offset = offset.Unit * 3
            end
            
            local targetVelocity = hrp.Velocity + (offset * -1.5) -- 减少弹性系数
            bodyVelocity.Velocity = targetVelocity
        end
    end
end

-- 主控制逻辑
ragdollButton.MouseButton1Click:Connect(function()
    ragdollEnabled = not ragdollEnabled
    local character = LocalPlayer.Character
    
    if character then
        if ragdollEnabled then
            ragdollButton.Text = "关闭布娃娃"
            createRagdollPhysics(character)
        else
            ragdollButton.Text = "开启布娃娃"
            restoreOriginalPhysics(character)
        end
    end
end)

-- 输入处理
local currentMoveDirection = Vector3.new()
local jumpRequested = false

-- 跳跃请求
local jumpConnection = UserInputService.JumpRequest:Connect(function()
    jumpRequested = true
end)
table.insert(connections, jumpConnection)

-- 移动输入处理
local function onInputChanged(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Gamepad1 then
        -- 手柄输入
        currentMoveDirection = Vector3.new(input.Position.X, 0, -input.Position.Y)
    else
        -- 键盘输入通过Humanoid获取
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                currentMoveDirection = humanoid.MoveDirection
            end
        end
    end
end

local inputConnection = UserInputService.InputChanged:Connect(onInputChanged)
table.insert(connections, inputConnection)

-- 主循环
local heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
    local character = LocalPlayer.Character
    if not character or not ragdollEnabled then return end
    
    -- 安全检查
    if not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChildOfClass("Humanoid") then
        return
    end
    
    updateRagdollMovement(character, currentMoveDirection, jumpRequested)
    jumpRequested = false
end)
table.insert(connections, heartbeatConnection)

-- 角色重生处理
local characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    -- 等待角色完全加载
    repeat 
        wait(0.1) 
    until character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid")
    
    if ragdollEnabled then
        wait(1) -- 给更多加载时间
        createRagdollPhysics(character)
    end
end)
table.insert(connections, characterAddedConnection)

-- 角色移除时清理
local characterRemovingConnection = LocalPlayer.CharacterRemoving:Connect(function()
    ragdollParts = {}
    bodyVelocities = {}
    originalStates = {}
end)
table.insert(connections, characterRemovingConnection)

-- 玩家离开时清理
local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end)
table.insert(connections, playerRemovingConnection)