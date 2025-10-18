--[[
🔄 简单布偶循环器 + PlatformStand 拦截
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
    Interval = 0.016,  -- 循环间隔（秒）
    UsePlayerPosition = true,
    FixedVector = Vector3.new(70, 60, -280),  -- 使用你提供的向量
    FixedCFrame = CFrame.new(-4895, 55, -68, 0, -1, -1, -0, 1, -1, 1, 0, -0)  -- 使用你提供的CFrame
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

-- 启动循环
local function Start()
    if Config.Enabled then return end
    
    Config.Enabled = true
    print("🔄 布偶循环已启动 | 间隔: " .. Config.Interval .. " 秒")
    
    -- 初始触发
    TriggerRagdoll("启动")
    
    -- 禁用站立相关状态
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false) -- 拦截 PlatformStand
                print("🚫 已禁用 GettingUp & Running & PlatformStanding 状态")
            end)
        end
    end
    
    -- 循环触发
    LoopConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
        -- 定时触发
        if tick() - LastTriggerTime >= Config.Interval then
            TriggerRagdoll("定时循环")
        end
        
        -- 强制维持布偶状态
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local state = humanoid:GetState()
                if state == Enum.HumanoidStateType.GettingUp or 
                   state == Enum.HumanoidStateType.Running or 
                   state == Enum.HumanoidStateType.PlatformStanding then  -- 拦截 PlatformStand
                    humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
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
            pcall(function()
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true) -- 恢复 PlatformStand
            end)
        end
    end
    
    print("⏹️ 布偶循环已停止 | 总触发: " .. TriggerCount .. " 次")
    TriggerCount = 0
end

-- 创建简单GUI
local function CreateGUI()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleRagdollGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 120)
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
    Title.Text = "🔄 布偶循环"
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
    
    -- 控制按钮
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -20, 0, 40)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 70)
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
    end)
    
    return ScreenGui
end

-- 初始化
print("🔄 简单布偶循环器已加载")
print("📋 功能: 定时触发布偶 + 状态禁用 + 强制维持 + PlatformStand拦截")

-- 预加载角色
local character = LocalPlayer.Character
if not character then
    LocalPlayer.CharacterAdded:Wait()
end

-- 创建GUI
CreateGUI()

-- 手动控制（可选）
return {
    Start = Start,
    Stop = Stop,
    Trigger = TriggerRagdoll
}