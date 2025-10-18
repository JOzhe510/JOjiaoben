local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = false,
    Interval = 2,
    UsePlayerPosition = true,
    FixedVector = Vector3.new(7, 6, -28),
    FixedCFrame = CFrame.new(-4895, 55, -68, 0, -1, -1, -0, 1, -1, 1, 0, -0),
    Flight = {
        SwimFly = false,
        SwimFlySpeed = 50,
        SwimFlyVertPower = 10,
        OriginalGravity = Workspace.Gravity
    }
}

local RagdollRemote = nil
local LoopConnection = nil
local StateListener = nil
local LastTriggerTime = 0
local TriggerCount = 0
local LastState = nil
local StateStartTime = 0
local LastCharacter = LocalPlayer.Character
local swimFlyHeartbeat = nil

local function GetRemoteEvent()
    local success, result = pcall(function()
        return ReplicatedStorage.Events.__RZDONL
    end)
    if success and result and result:IsA("RemoteEvent") then
        return result
    end
    return nil
end

local StateNames = {
    [Enum.HumanoidStateType.FallingDown] = "FallingDown",
    [Enum.HumanoidStateType.Freefall] = "Freefall",
    [Enum.HumanoidStateType.Flying] = "Flying",
    [Enum.HumanoidStateType.GettingUp] = "GettingUp",
    [Enum.HumanoidStateType.Jumping] = "Jumping",
    [Enum.HumanoidStateType.Landed] = "Landed",
    [Enum.HumanoidStateType.Physics] = "Physics",
    [Enum.HumanoidStateType.PlatformStanding] = "PlatformStanding",
    [Enum.HumanoidStateType.Ragdoll] = "Ragdoll",
    [Enum.HumanoidStateType.Running] = "Running",
    [Enum.HumanoidStateType.RunningNoPhysics] = "RunningNoPhysics",
    [Enum.HumanoidStateType.Seated] = "Seated",
    [Enum.HumanoidStateType.StrafingNoPhysics] = "StrafingNoPhysics",
    [Enum.HumanoidStateType.Swimming] = "Swimming",
    [Enum.HumanoidStateType.Climbing] = "Climbing",
    [Enum.HumanoidStateType.Dead] = "Dead",
}
local function GetStateName(state)
    return StateNames[state] or "Unknown"
end

local function TriggerRagdoll(reason)
    if not RagdollRemote then
        RagdollRemote = GetRemoteEvent()
        if not RagdollRemote then
            warn("❌ 未找到布偶 RemoteEvent")
            return false
        end
    end
    
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    local vectorArg = Config.FixedVector
    local cframeArg = Config.FixedCFrame
    
    if Config.UsePlayerPosition and humanoidRootPart then
        cframeArg = humanoidRootPart.CFrame
    end
    
    local success = pcall(function()
        RagdollRemote:FireServer("__---r", vectorArg, cframeArg)
    end)
    
    TriggerCount = TriggerCount + 1
    LastTriggerTime = tick()
    
    if success then
        print(string.format("[%.2f] ✅ 触发 #%d | 原因: %s", tick(), TriggerCount, reason or "定时"))
        return true
    else
        print(string.format("[%.2f] ❌ 触发失败 #%d", tick(), TriggerCount))
        return false
    end
end

local function ShowNotify(title, content, bgColor)
    local notify = Instance.new("ScreenGui")
    notify.Name = "FlightNotify"
    notify.Parent = LocalPlayer.PlayerGui
    local frame = Instance.new("Frame", notify)
    frame.Size = UDim2.new(0, 280, 0, 40)
    frame.Position = UDim2.new(0.5, -140, 0.9, -40)
    frame.BackgroundColor3 = bgColor or Color3.new(0, 0.6, 0)
    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1,1,1)
    text.Text = title .. "｜" .. content
    task.wait(2)
    notify:Destroy()
end

local function ToggleSwimFly(isOn)
    Config.Flight.SwimFly = isOn
    if isOn then
        Config.Flight.OriginalGravity = Workspace.Gravity
        if not swimFlyHeartbeat or not swimFlyHeartbeat.Connected then
            swimFlyHeartbeat = RunService.Heartbeat:Connect(function()
                if not LocalPlayer.Character then return end
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local camera = Workspace.CurrentCamera
                if not humanoid or not rootPart or not camera then return end
                
                Workspace.Gravity = 0
                rootPart.CanCollide = false
                
                local cameraLookVec = camera.CFrame.LookVector
                local verticalAngle = math.asin(cameraLookVec.Y)
                local moveDir = humanoid.MoveDirection
                
                if moveDir.Magnitude > 0 then
                    local verticalForce = Vector3.new(0, 0, 0)
                    if verticalAngle > math.rad(10) then
                        verticalForce = Vector3.new(0, Config.Flight.SwimFlyVertPower, 0)
                    elseif verticalAngle < math.rad(-10) then
                        verticalForce = Vector3.new(0, -Config.Flight.SwimFlyVertPower, 0)
                    end
                    rootPart.Velocity = (moveDir * Config.Flight.SwimFlySpeed) + verticalForce
                else
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        end
        ShowNotify("游泳飞行开启", "往上看+走路上升，往下看+走路下降", Color3.new(0, 0.6, 0))
    else
        if swimFlyHeartbeat and swimFlyHeartbeat.Connected then
            swimFlyHeartbeat:Disconnect()
            swimFlyHeartbeat = nil
        end
        Workspace.Gravity = Config.Flight.OriginalGravity
        local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CanCollide = true
        end
        ShowNotify("游泳飞行关闭", "恢复重力与碰撞状态", Color3.new(0.8, 0, 0))
    end
end

local function Start()
    if Config.Enabled then return end
    
    Config.Enabled = true
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("✅ 飞行与布偶循环已启动")
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("⏱️ 循环间隔: " .. Config.Interval .. " 秒")
    
    local character = LocalPlayer.Character
    if not character then
        character = LocalPlayer.CharacterAdded:Wait()
    end
    LastCharacter = character
    
    local humanoid = character:WaitForChild("Humanoid")
    
    LastState = humanoid:GetState()
    StateStartTime = tick()
    print(string.format("[%.2f] 📌 初始状态: %s", tick(), GetStateName(LastState)))
    
    TriggerRagdoll("初始")
    
    local hookSuccess = pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        print(string.format("[%.2f] 🚫 成功禁用 GettingUp & Running 状态", tick()))
    end)
    
    if not hookSuccess then
        print(string.format("[%.2f] ⚠️ 无法禁用状态，将使用 Heartbeat 强制拦截", tick()))
    end
    
    StateListener = humanoid.StateChanged:Connect(function(oldState, newState)
        if not Config.Enabled then return end
        
        local duration = tick() - StateStartTime
        print(string.format(
            "[%.2f] 🔄 %s → %s | 持续: %.2f秒",
            tick(),
            GetStateName(oldState),
            GetStateName(newState),
            duration
        ))
        
        LastState = newState
        StateStartTime = tick()
    end)
    
    LoopConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
        local now = tick()
        local canTrigger = now - LastTriggerTime >= Config.Interval
        local triggeredThisFrame = false
        
        if canTrigger and not triggeredThisFrame then
            TriggerRagdoll("定时循环")
            triggeredThisFrame = true
        end
        
        local c = LocalPlayer.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then
                local currentState = h:GetState()
                if currentState == Enum.HumanoidStateType.GettingUp or
                   currentState == Enum.HumanoidStateType.Running then
                    pcall(function()
                        h:ChangeState(Enum.HumanoidStateType.Ragdoll)
                    end)
                end
            end
        end
    end)
    
    -- 开启飞行
    ToggleSwimFly(true)
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("✅ 监控已启动")
    print("  🚫 状态禁用: GettingUp & Running")
    print("  🔄 定时触发: 每 " .. Config.Interval .. " 秒")
    print("  🛡️ Heartbeat: 每帧强制检查")
    print("  ✈️ 飞行: 游泳飞行（WASD+视角控制）")
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
end

local function Stop()
    if not Config.Enabled then return end
    
    Config.Enabled = false
    
    if LoopConnection then
        LoopConnection:Disconnect()
        LoopConnection = nil
    end
    
    if StateListener then
        StateListener:Disconnect()
        StateListener = nil
    end
    
    -- 关闭飞行
    ToggleSwimFly(false)
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            end)
        end
    end
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("⏹️ 飞行已停止")
    print(string.format("📊 总共触发: %d 次", TriggerCount))
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    
    TriggerCount = 0
end

-- 创建小UI（关闭主UI后显示）
local MiniGui = Instance.new("ScreenGui")
MiniGui.Name = "MiniFlightGui"
MiniGui.ResetOnSpawn = false

local MiniButton = Instance.new("TextButton")
MiniButton.Size = UDim2.new(0, 50, 0, 50)
MiniButton.Position = UDim2.new(0, 10, 0.5, -25)
MiniButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
MiniButton.Text = "✈️"
MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniButton.TextSize = 18
MiniButton.Font = Enum.Font.GothamBold
MiniButton.BorderSizePixel = 0
MiniButton.Parent = MiniGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 8)
MiniCorner.Parent = MiniButton

-- 创建主UI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MainFlightGui"
MainGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 200)
Frame.Position = UDim2.new(0.5, -140, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = MainGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 150, 255)
Stroke.Thickness = 2
Stroke.Transparency = 0.3
Stroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "🔄 犯罪飞行"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Frame

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    if Config.Enabled then Stop() end
    MainGui.Enabled = false
    MiniGui.Parent = PlayerGui -- 显示小UI
    MainGui.Enabled = true
end)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 60)
Info.Position = UDim2.new(0, 10, 0, 50)
Info.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Info.Text = "🚫 禁用 GettingUp & Running\n🔄 间隔: 0.7秒/次\n✈️ 飞行: 游泳飞行（WASD+视角控制）"
Info.TextColor3 = Color3.fromRGB(200, 255, 200)
Info.TextSize = 12
Info.Font = Enum.Font.Code
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.BorderSizePixel = 0
Info.Parent = Frame

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = Info

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 120)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
ToggleBtn.Text = "▶ 启动飞行"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = Frame

local ToggleBtnCorner = Instance.new("UICorner")
ToggleBtnCorner.CornerRadius = UDim.new(0, 8)
ToggleBtnCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    if Config.Enabled then
        Stop()
        ToggleBtn.Text = "▶ 启动飞行"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    else
        Start()
        ToggleBtn.Text = "⏹ 停止飞行"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- 小UI按钮点击事件
MiniButton.MouseButton1Click:Connect(function()
    MiniGui.Enabled = false
    MainGui.Enabled = true
    MainGui.Parent = PlayerGui
end)

-- 初始设置
MainGui.Parent = PlayerGui
MiniGui.Enabled = false

LocalPlayer.CharacterAdded:Connect(function(newChar)
    LastCharacter = newChar
    if Config.Enabled then
        task.wait(0.1)
        local humanoid = newChar:WaitForChild("Humanoid")
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
        end)
        TriggerRagdoll("角色重生重新固定")
        
        -- 重新开启飞行
        if Config.Flight.SwimFly then
            local rootPart = newChar:WaitForChild("HumanoidRootPart")
            rootPart.CanCollide = false
            Workspace.Gravity = 0
        end
    end
end)

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔄 犯罪飞行已加载")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("功能:")
print("  🚫 状态禁用: 彻底禁用 GettingUp & Running")
print("  🔄 布偶循环: 定时触发 RemoteEvent（0.7秒）")
print("  🛡️ Heartbeat: 每帧强制维持布偶状态")
print("  ✈️ 飞行功能: 游泳飞行（WASD控制，视角控上下飞）")
print("  🔗 联动: 开启飞行同时开启布偶循环，关闭同时关闭")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

task.spawn(function()
    task.wait(1)
    RagdollRemote = GetRemoteEvent()
    if RagdollRemote then
        print("✅ 成功找到布偶 RemoteEvent")
    else
        warn("⚠️ 未找到布偶 RemoteEvent")
    end
end)