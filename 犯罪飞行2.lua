local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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
    screenGui:Destroy()
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

-- 获取玩家框架结构
local function getCharacterRig(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    
    local rigType = humanoid.RigType.Name
    return rigType
end

-- 创建布娃娃物理
local function createRagdollPhysics(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- 保存原始状态
    originalStates = {
        humanoid = {
            PlatformStand = humanoid.PlatformStand,
            AutoRotate = humanoid.AutoRotate
        }
    }
    
    -- 设置人类状态
    humanoid.PlatformStand = true
    humanoid.AutoRotate = false
    
    -- 处理所有身体部件
    ragdollParts = {}
    bodyVelocities = {}
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            -- 保存原始状态
            originalStates[part] = {
                CanCollide = part.CanCollide,
                Anchored = part.Anchored,
                Massless = part.Massless
            }
            
            -- 启用物理
            part.CanCollide = true
            part.Anchored = false
            part.Massless = false
            
            -- 创建BodyVelocity用于控制
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new()
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.P = 1000
            bodyVelocity.Parent = part
            
            table.insert(ragdollParts, part)
            bodyVelocities[part] = bodyVelocity
        end
    end
    
    -- 禁用Motor6D关节但保持连接
    for _, motor in pairs(character:GetDescendants()) do
        if motor:IsA("Motor6D") then
            originalStates[motor] = {
                Enabled = motor.Enabled,
                DesiredAngle = motor.CurrentAngle
            }
            motor.Enabled = false
        end
    end
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
            part.Massless = state.Massless
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
    
    local speed = humanoid.WalkSpeed
    
    -- 控制HumanoidRootPart移动
    if moveDirection.Magnitude > 0 then
        local moveForce = moveDirection * speed
        hrp.Velocity = Vector3.new(moveForce.X, hrp.Velocity.Y, moveForce.Z)
    else
        -- 减速
        hrp.Velocity = Vector3.new(hrp.Velocity.X * 0.9, hrp.Velocity.Y, hrp.Velocity.Z * 0.9)
    end
    
    -- 跳跃
    if jump then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
    end
    
    -- 控制身体部件跟随（柔和的物理跟随）
    for part, bodyVelocity in pairs(bodyVelocities) do
        if part and part.Parent then
            -- 计算部件相对于HRP的目标位置
            local targetPosition = hrp.Position
            local offset = part.Position - hrp.Position
            
            -- 限制最大偏移距离
            if offset.Magnitude > 5 then
                offset = offset.Unit * 5
            end
            
            -- 计算目标速度
            local targetVelocity = hrp.Velocity + (offset * -2) -- 弹性回归
            
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

UserInputService.JumpRequest:Connect(function()
    jumpRequested = true
end)

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

UserInputService.InputChanged:Connect(onInputChanged)

-- 主循环
RunService.Heartbeat:Connect(function(deltaTime)
    local character = LocalPlayer.Character
    if not character then return end
    
    if ragdollEnabled then
        updateRagdollMovement(character, currentMoveDirection, jumpRequested)
        jumpRequested = false
    end
end)

-- 角色重生处理
LocalPlayer.CharacterAdded:Connect(function(character)
    -- 等待角色完全加载
    character:WaitForChild("HumanoidRootPart")
    character:WaitForChild("Humanoid")
    
    if ragdollEnabled then
        wait(0.5) -- 给角色加载一些时间
        createRagdollPhysics(character)
    end
end)

-- 角色移除时清理
LocalPlayer.CharacterRemoving:Connect(function()
    ragdollParts = {}
    bodyVelocities = {}
    originalStates = {}
end)