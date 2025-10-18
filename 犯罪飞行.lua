local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = false,
    Interval = 0.7,  
    UsePlayerPosition = true,
    FixedVector = Vector3.new(7, 6, -28),
    FixedCFrame = CFrame.new(-4895, 55, -68, 0, -1, -1, -0, 1, -1, 1, 0, -0),
   
    Flight = {
        InfiniteFly = false, 
        SwimFly = false,     
        SwimFlySpeed = 50,   
        SwimFlyVertPower = 35,
        JumpPower = 50,      
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
local flyLoadConn = nil      

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
        print(string.format("[%.2f] ✅ 触发 #%d | 原因: %s", tick(), TriggerCount, reason or "初始固定"))
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

local function ToggleInfiniteFly(isOn)
    Config.Flight.InfiniteFly = isOn
    if isOn then
        if flyLoadConn then
            pcall(function() flyLoadConn:Disconnect() end)
            flyLoadConn = nil
        end
        local success, err = pcall(function()
            local flyScript = game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true)
            loadstring(flyScript)()
            flyLoadConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Jump then
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChild("Humanoid")
                    if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end)
        if success then
            ShowNotify("无限跳跃开启", "按下空格即可无限跳跃", Color3.new(0, 0.6, 0))
        else
            ShowNotify("加载失败", "请检查网络或链接有效性", Color3.new(0.8, 0, 0))
        end
    else
        if flyLoadConn and flyLoadConn.Connected then
            flyLoadConn:Disconnect()
            flyLoadConn = nil
        end
        pcall(function()
            for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if v.Name:find("InfiniteJump") or v.Name:find("Fly") then
                    v:Destroy()
                end
            end
            for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                if v:IsA("Script") and v.Name:find("Jump") then
                    v:Destroy()
                end
            end
        end)
        ShowNotify("无限跳跃关闭", "清理所有跳跃相关实例", Color3.new(0.8, 0, 0))
    end
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

local function UpdateJumpPower(value)
    Config.Flight.JumpPower = tonumber(value) or 50
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.JumpPower = Config.Flight.JumpPower
    end
    ShowNotify("跳跃力度更新", "无限跳跃力度：" .. Config.Flight.JumpPower, Color3.new(0, 0.6, 0))
end

local function ToggleFlightGravity(isOn)
    if isOn then
        Workspace.Gravity = 0
        ShowNotify("重力关闭", "飞行时重力已禁用", Color3.new(0, 0.6, 0))
    else
        if not Config.Flight.SwimFly then
            Workspace.Gravity = Config.Flight.OriginalGravity
            ShowNotify("重力恢复", "已恢复默认重力", Color3.new(0.8, 0, 0))
        end
    end
end

local function Start()
    if Config.Enabled then return end
    
    Config.Enabled = true
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("✅ 布偶状态永久固定已启动")
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    
    local character = LocalPlayer.Character
    if not character then
        character = LocalPlayer.CharacterAdded:Wait()
    end
    LastCharacter = character
    
    local humanoid = character:WaitForChild("Humanoid")

    LastState = humanoid:GetState()
    StateStartTime = tick()
    print(string.format("[%.2f] 📌 初始状态: %s", tick(), GetStateName(LastState)))
  
    TriggerRagdoll("初始固定")

    local hookSuccess = pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        print(string.format("[%.2f] 🚫 成功禁用解除布偶相关状态", tick()))
    end)
    
    if not hookSuccess then
        print(string.format("[%.2f] ⚠️ 无法禁用状态，将强力拦截解除行为", tick()))
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
        
       
        if newState ~= Enum.HumanoidStateType.Ragdoll then
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
                print(string.format("[%.2f] 🛡️ 强制恢复布偶状态", tick()))
            end)
        end
        
        LastState = newState
        StateStartTime = tick()
    end)
    
   
    LoopConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
       
        local c = LocalPlayer.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then
                local currentState = h:GetState()
               
                if currentState ~= Enum.HumanoidStateType.Ragdoll then
                    pcall(function()
                        h:ChangeState(Enum.HumanoidStateType.Ragdoll)
                    end)
                end
            end
        end
    end)
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("✅ 固定监控已启动")
    print("  🚫 禁用状态: 解除布偶相关状态")
    print("  🛡️ 双重保险: 状态监听+每帧检查")
    print("  🔒 效果: 角色永久保持布偶状态")
    print("  ✈️ 飞行: 小仰版（飞行+无限跳跃）")
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
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            end)
        end
    end
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("⏹️ 布偶状态永久固定已停止")
    print(string.format("📊 总共触发布偶: %d 次", TriggerCount))
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    
    TriggerCount = 0
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleLoopGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 380) 
Frame.Position = UDim2.new(0.5, -160, 0.5, -190)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

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
Title.Text = "🔒 布偶状态永久固定（小仰飞行☠️）"
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
   
    if Config.Flight.SwimFly then ToggleSwimFly(false) end
    if Config.Flight.InfiniteFly then ToggleInfiniteFly(false) end
    ScreenGui:Destroy()
end)

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 60)
Info.Position = UDim2.new(0, 10, 0, 50)
Info.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Info.Text = "🚫 禁用解除布偶相关状态\n🔒 启动后永久保持布偶状态\n✈️ 飞行: 游泳飞行（WASD）+ 无限跳跃（空格）"
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

local IntervalLabel = Instance.new("TextLabel")
IntervalLabel.Size = UDim2.new(1, -20, 0, 20)
IntervalLabel.Position = UDim2.new(0, 10, 0, 120)
IntervalLabel.BackgroundTransparency = 1
IntervalLabel.Text = "⏱️ 原间隔（已失效）: 0.7 秒"
IntervalLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
IntervalLabel.TextSize = 11
IntervalLabel.Font = Enum.Font.GothamMedium
IntervalLabel.TextXAlignment = Enum.TextXAlignment.Left
IntervalLabel.Parent = Frame

local Slider = Instance.new("Frame")
Slider.Size = UDim2.new(1, -20, 0, 20)
Slider.Position = UDim2.new(0, 10, 0, 140)
Slider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Slider.BorderSizePixel = 0
Slider.Parent = Frame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 6)
SliderCorner.Parent = Slider

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new((0.7 - 0.5) / 1.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = Slider

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(0, 6)
SliderFillCorner.Parent = SliderFill

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(0, 18, 0, 18)
SliderBtn.Position = UDim2.new((0.7 - 0.5) / 1.5, -9, 0.5, -9)
SliderBtn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
SliderBtn.Text = ""
SliderBtn.BorderSizePixel = 0
SliderBtn.Active = false
SliderBtn.Parent = Slider

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

local FlightTitle = Instance.new("TextLabel")
FlightTitle.Size = UDim2.new(1, -20, 0, 20)
FlightTitle.Position = UDim2.new(0, 10, 0, 180)
FlightTitle.BackgroundTransparency = 1
FlightTitle.Text = "✈️ 小仰飞行控制"
FlightTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
FlightTitle.TextSize = 13
FlightTitle.Font = Enum.Font.GothamBold
FlightTitle.TextXAlignment = Enum.TextXAlignment.Left
FlightTitle.Parent = Frame

local InfiniteFlyToggle = Instance.new("TextButton")
InfiniteFlyToggle.Size = UDim2.new(1, -20, 0, 30)
InfiniteFlyToggle.Position = UDim2.new(0, 10, 0, 210)
InfiniteFlyToggle.BackgroundColor3 = Color3.fromRGB(70, 150, 200)
InfiniteFlyToggle.Text = "无限跳跃：关闭（空格触发）"
InfiniteFlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfiniteFlyToggle.TextSize = 12
InfiniteFlyToggle.Font = Enum.Font.GothamMedium
InfiniteFlyToggle.BorderSizePixel = 0
InfiniteFlyToggle.Parent = Frame

local InfiniteFlyCorner = Instance.new("UICorner")
InfiniteFlyCorner.CornerRadius = UDim.new(0, 6)
InfiniteFlyCorner.Parent = InfiniteFlyToggle

InfiniteFlyToggle.MouseButton1Click:Connect(function()
    local newState = not Config.Flight.InfiniteFly
    ToggleInfiniteFly(newState)
    InfiniteFlyToggle.Text = newState and "无限跳跃：开启（空格触发）" or "无限跳跃：关闭（空格触发）"
    InfiniteFlyToggle.BackgroundColor3 = newState and Color3.fromRGB(70, 200, 255) or Color3.fromRGB(70, 150, 200)
end)

local SwimFlyToggle = Instance.new("TextButton")
SwimFlyToggle.Size = UDim2.new(1, -20, 0, 30)
SwimFlyToggle.Position = UDim2.new(0, 10, 0, 250)
SwimFlyToggle.BackgroundColor3 = Color3.fromRGB(70, 150, 200)
SwimFlyToggle.Text = "游泳飞行：关闭（WASD+视角）"
SwimFlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SwimFlyToggle.TextSize = 12
SwimFlyToggle.Font = Enum.Font.GothamMedium
SwimFlyToggle.BorderSizePixel = 0
SwimFlyToggle.Parent = Frame

local SwimFlyCorner = Instance.new("UICorner")
SwimFlyCorner.CornerRadius = UDim.new(0, 6)
SwimFlyCorner.Parent = SwimFlyToggle

SwimFlyToggle.MouseButton1Click:Connect(function()
    local newState = not Config.Flight.SwimFly
    ToggleSwimFly(newState)
    SwimFlyToggle.Text = newState and "游泳飞行：开启（WASD+视角）" or "游泳飞行：关闭（WASD+视角）"
    SwimFlyToggle.BackgroundColor3 = newState and Color3.fromRGB(70, 200, 255) or Color3.fromRGB(70, 150, 200)
end)

local GravityToggle = Instance.new("TextButton")
GravityToggle.Size = UDim2.new(1, -20, 0, 30)
GravityToggle.Position = UDim2.new(0, 10, 0, 290)
GravityToggle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
GravityToggle.Text = "飞行强制关重力：关闭"
GravityToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
GravityToggle.TextSize = 12
GravityToggle.Font = Enum.Font.GothamMedium
GravityToggle.BorderSizePixel = 0
GravityToggle.Parent = Frame

local GravityCorner = Instance.new("UICorner")
GravityCorner.CornerRadius = UDim.new(0, 6)
GravityCorner.Parent = GravityToggle

local gravityEnabled = false
GravityToggle.MouseButton1Click:Connect(function()
    gravityEnabled = not gravityEnabled
    ToggleFlightGravity(gravityEnabled)
    GravityToggle.Text = gravityEnabled and "飞行强制关重力：开启" or "飞行强制关重力：关闭"
    GravityToggle.BackgroundColor3 = gravityEnabled and Color3.fromRGB(70, 200, 150) or Color3.fromRGB(150, 150, 150)
end)

local JumpPowerLabel = Instance.new("TextLabel")
JumpPowerLabel.Size = UDim2.new(1, -20, 0, 20)
JumpPowerLabel.Position = UDim2.new(0, 10, 0, 330)
JumpPowerLabel.BackgroundTransparency = 1
JumpPowerLabel.Text = "无限跳跃力度：50"
JumpPowerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpPowerLabel.TextSize = 11
JumpPowerLabel.Font = Enum.Font.GothamMedium
JumpPowerLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpPowerLabel.Parent = Frame

local JumpPowerSlider = Instance.new("Frame")
JumpPowerSlider.Size = UDim2.new(1, -20, 0, 15)
JumpPowerSlider.Position = UDim2.new(0, 10, 0, 350)
JumpPowerSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
JumpPowerSlider.BorderSizePixel = 0
JumpPowerSlider.Parent = Frame

local JumpPowerSliderCorner = Instance.new("UICorner")
JumpPowerSliderCorner.CornerRadius = UDim.new(0, 4)
JumpPowerSliderCorner.Parent = JumpPowerSlider

local JumpPowerSliderFill = Instance.new("Frame")
JumpPowerSliderFill.Size = UDim2.new((Config.Flight.JumpPower - 50) / 450, 0, 1, 0)
JumpPowerSliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 150)
JumpPowerSliderFill.BorderSizePixel = 0
JumpPowerSliderFill.Parent = JumpPowerSlider

local JumpPowerSliderBtn = Instance.new("TextButton")
JumpPowerSliderBtn.Size = UDim2.new(0, 12, 0, 12)
JumpPowerSliderBtn.Position = UDim2.new((Config.Flight.JumpPower - 50) / 450, -6, 0.5, -6)
JumpPowerSliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
JumpPowerSliderBtn.Text = ""
JumpPowerSliderBtn.BorderSizePixel = 0
JumpPowerSliderBtn.Parent = JumpPowerSlider

local JumpPowerSliderBtnCorner = Instance.new("UICorner")
JumpPowerSliderBtnCorner.CornerRadius = UDim.new(1, 0)
JumpPowerSliderBtnCorner.Parent = JumpPowerSliderBtn

local jumpPowerDragging = false
JumpPowerSliderBtn.MouseButton1Down:Connect(function()
    jumpPowerDragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        jumpPowerDragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if jumpPowerDragging then
        local mouse = LocalPlayer:GetMouse()
        local relativePos = mouse.X - JumpPowerSlider.AbsolutePosition.X
        local percentage = math.clamp(relativePos / JumpPowerSlider.AbsoluteSize.X, 0, 1)
        local newPower = 50 + (percentage * 450) -- 范围50-500
        Config.Flight.JumpPower = newPower
        UpdateJumpPower(newPower)
        JumpPowerSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        JumpPowerSliderBtn.Position = UDim2.new(percentage, -6, 0.5, -6)
        JumpPowerLabel.Text = string.format("无限跳跃力度：%.0f", newPower)
    end
end)

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 370)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
ToggleBtn.Text = "▶ 启动布偶永久固定"
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
        ToggleBtn.Text = "▶ 启动布偶永久固定"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    else
        Start()
        ToggleBtn.Text = "⏹ 停止布偶永久固定"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    LastCharacter = newChar
    
    local humanoid = newChar:WaitForChild("Humanoid")
    humanoid.JumpPower = Config.Flight.JumpPower
 
    if Config.Enabled then
        task.wait(0.1)

        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        end)
       
        TriggerRagdoll("角色重生重新固定")
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
        end)
    end
   
    if Config.Flight.SwimFly then
        local rootPart = newChar:WaitForChild("HumanoidRootPart")
        rootPart.CanCollide = false
        Workspace.Gravity = 0
    end
end)

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔒 布偶状态永久固定器已加载")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("功能:")
print("  🚫 禁用状态: 解除布偶相关状态（GettingUp/Running等）")
print("  🔒 核心效果: 启动后角色永久保持布偶状态")
print("  🛡️ 双重保险: 状态监听+每帧检查，防止脱离布偶")
print("  ✈️ 飞行功能（小仰版）:")
print("    - 无限跳跃：空格触发，力度50-500可调")
print("    - 游泳飞行：WASD控制，视角控上下飞")
print("    - 支持飞行时强制关闭重力")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

task.spawn(function()
    task.wait(1)
    RagdollRemote = GetRemoteEvent()
    if RagdollRemote then
        print("✅ 成功找到布偶 RemoteEvent")
    else
        warn("⚠️ 未找到布偶 RemoteEvent，可能无法正常触发布偶")
    end
end)

 
        