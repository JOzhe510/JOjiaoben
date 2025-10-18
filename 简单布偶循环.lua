--[[
🔄 简单布偶循环器 + PlatformStand 拦截 - 增强版
基于 Sigma Spy 生成的代码原理
--]]

-- 服务
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 配置
local Config = {
    Enabled = false,
    Interval = 0.08,  -- 优化后的间隔（更稳定）
    UsePlayerPosition = true,
    FixedVector = Vector3.new(70, 60, -280),  -- 使用你提供的向量
    FixedCFrame = CFrame.new(-4895, 55, -68, 0, -1, -1, -0, 1, -1, 1, 0, -0),  -- 使用你提供的CFrame
    AggressiveMode = true  -- 激进模式，更强力维持
}

-- 变量
local RagdollRemote = ReplicatedStorage.Events.__RZDONL
local LoopConnection = nil
local LastTriggerTime = 0
local TriggerCount = 0

-- 触发布偶函数
local function TriggerRagdoll(reason)
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    local vectorArg = Config.FixedVector
    local cframeArg = Config.FixedCFrame
    
    -- 如果使用玩家位置，则用玩家当前位置
    if Config.UsePlayerPosition and humanoidRootPart then
        cframeArg = humanoidRootPart.CFrame
    end
    
    -- 触发RemoteEvent（与你提供的代码完全一致）
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

-- 禁用所有可能导致站立的状态
local function DisableStandingStates(humanoid)
    pcall(function()
        -- 禁用所有可能导致站立的状态
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Strafing, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        print("🚫 已禁用所有可能导致站立的状态")
    end)
end

-- 重新启用所有状态
local function EnableAllStates(humanoid)
    pcall(function()
        -- 重新启用所有状态
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Strafing, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    end)
end

-- 启动循环
local function Start()
    if Config.Enabled then return end
    
    Config.Enabled = true
    print("🔄 布偶循环已启动 | 间隔: " .. Config.Interval .. " 秒")
    
    -- 初始触发
    TriggerRagdoll("启动")
    
    -- 增强状态禁用
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            DisableStandingStates(humanoid)
        end
    end
    
    -- 强力循环触发
    LoopConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
        -- 定时触发
        if tick() - LastTriggerTime >= Config.Interval then
            TriggerRagdoll("定时循环")
        end
        
        -- 强力状态维持
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local state = humanoid:GetState()
                -- 如果检测到任何非布偶状态，立即强制切回布偶
                if state ~= Enum.HumanoidStateType.Ragdoll then
                    humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
                    print("🔄 强制维持布偶状态 | 检测到状态: " .. tostring(state))
                end
            end
        end
    end)
end

-- 停止循环
local function Stop()
    if not Config.Enabled then return end
    
    Config.Enabled = false
    
    if LoopConnection then
        LoopConnection:Disconnect()
        LoopConnection = nil
    end
    
    -- 重新启用状态
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            EnableAllStates(humanoid)
        end
    end
    
    print("⏹️ 布偶循环已停止 | 总触发: " .. TriggerCount .. " 次")
    TriggerCount = 0
end

-- 角色重生处理
local function onCharacterAdded(character)
    wait(1) -- 等待角色完全加载
    
    if Config.Enabled then
        print("🔄 检测到角色重生，重新应用布偶设置...")
        
        -- 重新应用状态禁用
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            DisableStandingStates(humanoid)
        end
        
        -- 重新触发布偶
        wait(0.5)
        TriggerRagdoll("角色重生")
    end
end

-- 创建简单GUI
local function CreateGUI()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleRagdollGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 220, 0, 140)
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    -- 标题
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🔄 布偶循环 - 增强版"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame
    
    -- 状态显示
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -10, 0, 20)
    Status.Position = UDim2.new(0, 5, 0, 35)
    Status.BackgroundTransparency = 1
    Status.Text = "状态: 未启动"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 12
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Frame
    
    -- 触发计数
    local CountLabel = Instance.new("TextLabel")
    CountLabel.Size = UDim2.new(1, -10, 0, 20)
    CountLabel.Position = UDim2.new(0, 5, 0, 55)
    CountLabel.BackgroundTransparency = 1
    CountLabel.Text = "触发: 0 次"
    CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    CountLabel.TextSize = 12
    CountLabel.Font = Enum.Font.Gotham
    CountLabel.TextXAlignment = Enum.TextXAlignment.Left
    CountLabel.Parent = Frame
    
    -- 控制按钮
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -20, 0, 40)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 85)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    ToggleBtn.Text = "▶ 启动"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 14
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn
    
    -- 更新计数显示的函数
    local function updateCount()
        CountLabel.Text = "触发: " .. TriggerCount .. " 次"
    end
    
    ToggleBtn.MouseButton1Click:Connect(function()
        if Config.Enabled then
            Stop()
            ToggleBtn.Text = "▶ 启动"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            Status.Text = "状态: 未启动"
        else
            Start()
            ToggleBtn.Text = "⏹ 停止"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            Status.Text = "状态: 运行中"
        end
        updateCount()
    end)
    
    -- 定期更新计数
    game:GetService("RunService").Heartbeat:Connect(updateCount)
    
    return ScreenGui
end

-- 初始化
print("🔄 简单布偶循环器已加载 - 增强版")
print("📋 功能: 定时触发布偶 + 全状态禁用 + 强力维持 + 重生处理")

-- 预加载角色和重生监听
local character = LocalPlayer.Character
if character then
    -- 已有角色，等待一下确保加载完成
    wait(1)
else
    LocalPlayer.CharacterAdded:Wait()
end

-- 设置角色重生监听
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- 创建GUI
CreateGUI()

-- 手动控制（可选）
return {
    Start = Start,
    Stop = Stop,
    Trigger = TriggerRagdoll
}