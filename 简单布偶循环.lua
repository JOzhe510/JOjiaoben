--[[
🔄 简单布偶循环器 - 优化版
基于原始触发代码重构
--]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Remote
local __RZDONL = ReplicatedStorage.Events.__RZDONL

-- 配置
local Config = {
    Enabled = false,
    Interval = 0.05,  -- 更短的间隔
    UsePlayerPosition = false,  -- 使用固定位置
    FixedVector = Vector3.new(70, 60, -280),
    FixedCFrame = CFrame.new(-4895, 55, -68, 0, -1, -1, -0, 1, -1, 1, 0, -0)
}

-- 变量
local LocalPlayer = Players.LocalPlayer
local LoopConnection = nil
local LastTriggerTime = 0
local TriggerCount = 0

-- 直接触发布偶函数（基于原始代码）
local function TriggerRagdoll(reason)
    local Character = LocalPlayer.Character
    if not Character then return false end
    
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return false end
    
    -- 使用原始参数结构
    local success = pcall(function()
        __RZDONL:FireServer(
            "__---r",
            Config.FixedVector, -- 伪造的目标位置向量
            Config.FixedCFrame, -- 伪造的CFrame
            HumanoidRootPart -- 来源部件验证 
        )
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

-- 强力状态维持
local function ForceRagdollState()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    
    -- 如果不在布偶状态，强制切换
    if Humanoid:GetState() ~= Enum.HumanoidStateType.Ragdoll then
        pcall(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
        end)
    end
end

-- 启动循环
local function Start()
    if Config.Enabled then return end
    
    Config.Enabled = true
    print("🔄 布偶循环已启动 | 间隔: " .. Config.Interval .. " 秒")
    
    -- 初始触发
    TriggerRagdoll("启动")
    
    -- 强力循环
    LoopConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
        -- 定时触发
        if tick() - LastTriggerTime >= Config.Interval then
            TriggerRagdoll("定时循环")
        end
        
        -- 每帧强制维持状态
        ForceRagdollState()
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
    
    print("⏹️ 布偶循环已停止 | 总触发: " .. TriggerCount .. " 次")
    TriggerCount = 0
end

-- 角色重生处理
local function onCharacterAdded(Character)
    task.wait(1) -- 等待角色加载
    
    if Config.Enabled then
        print("🔄 角色重生，重新应用布偶...")
        task.wait(0.5)
        TriggerRagdoll("角色重生")
    end
end

-- 创建简单GUI
local function CreateGUI()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RagdollLoopGUI"
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
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame
    
    -- 状态显示
    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -10, 0, 20)
    Status.Position = UDim2.new(0, 5, 0, 30)
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
    CountLabel.Position = UDim2.new(0, 5, 0, 50)
    CountLabel.BackgroundTransparency = 1
    CountLabel.Text = "触发: 0 次"
    CountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    CountLabel.TextSize = 12
    CountLabel.Font = Enum.Font.Gotham
    CountLabel.TextXAlignment = Enum.TextXAlignment.Left
    CountLabel.Parent = Frame
    
    -- 控制按钮
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -20, 0, 30)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 75)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    ToggleBtn.Text = "▶ 启动"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn
    
    -- 更新UI
    local function updateUI()
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
        updateUI()
    end)
    
    -- 定期更新
    RunService.Heartbeat:Connect(updateUI)
end

-- 初始化
print("🔄 布偶循环器已加载 - 优化版")

-- 设置角色重生监听
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- 创建GUI
CreateGUI()

-- 导出控制函数
return {
    Start = Start,
    Stop = Stop,
    Trigger = TriggerRagdoll
}