--[[
═══════════════════════════════════════════════════════════
    🚫 布偶拦截器 - 三层防护版
    
    防护层级：
    1. 🎣 Hook __namecall: 拦截 ChangeState 方法调用
    2. 🛡️ Hook RemoteEvent: 拦截服务器恢复指令
    3. ⚙️ Heartbeat 兜底: 强制检查状态
    
    从根源阻止 GettingUp 状态产生！
═══════════════════════════════════════════════════════════
--]]

-- ==================== 服务 ====================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ==================== 配置 ====================
local Config = {
    Enabled = false,
    BackupInterval = 1.0,  -- 兜底触发间隔（秒）
    EnableLogging = true,   -- 详细日志
}

-- ==================== 统计 ====================
local Stats = {
    Layer1Blocks = 0,  -- 第一层拦截次数
    Layer2Blocks = 0,  -- 第二层拦截次数
    Layer3Blocks = 0,  -- 第三层拦截次数
    TotalBlocks = 0,   -- 总拦截次数
}

-- ==================== 变量 ====================
local RagdollRemote = nil
local BackupLoopConnection = nil
local HeartbeatConnection = nil
local OriginalNamecall = nil

-- ==================== 获取布偶 RemoteEvent ====================
local function GetRagdollRemote()
    local success, result = pcall(function()
        return ReplicatedStorage.Events.__RZDONL
    end)
    
    if success and result then
        print("✅ 找到布偶 RemoteEvent")
        return result
    end
    
    warn("❌ 未找到布偶 RemoteEvent")
    return nil
end

-- ==================== 触发布偶 ====================
local function TriggerRagdoll(reason)
    if not RagdollRemote then return end
    
    local success = pcall(function()
        RagdollRemote:FireServer(1)
    end)
    
    if Config.EnableLogging then
        print(string.format("[%.2f] 🔄 触发布偶 | 原因: %s", tick(), reason))
    end
end

-- ==================== 第一层：Hook __namecall ====================
local function SetupLayer1()
    local success = pcall(function()
        if not hookmetamethod then
            error("Executor 不支持 hookmetamethod")
        end
        
        OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- 拦截 ChangeState 调用
            if method == "ChangeState" and self == Humanoid then
                local targetState = args[1]
                
                -- 拦截站立相关状态
                if targetState == Enum.HumanoidStateType.GettingUp or
                   targetState == Enum.HumanoidStateType.Running or
                   targetState == Enum.HumanoidStateType.Landed or
                   targetState == Enum.HumanoidStateType.Climbing or
                   targetState == Enum.HumanoidStateType.Swimming then
                    
                    Stats.Layer1Blocks = Stats.Layer1Blocks + 1
                    Stats.TotalBlocks = Stats.TotalBlocks + 1
                    
                    if Config.EnableLogging then
                        print(string.format("[%.2f] 🎣 [第1层] 拦截 ChangeState: %s → Ragdoll", 
                            tick(), 
                            tostring(targetState):gsub("Enum%.HumanoidStateType%.", "")
                        ))
                    end
                    
                    -- 强制改为 Ragdoll
                    args[1] = Enum.HumanoidStateType.Ragdoll
                    return OriginalNamecall(self, unpack(args))
                end
            end
            
            return OriginalNamecall(self, ...)
        end)
        
        print("✅ [第1层] Hook __namecall 成功")
        return true
    end)
    
    if not success then
        warn("⚠️ [第1层] Hook 失败，将依赖第2/3层")
        return false
    end
    
    return true
end

-- ==================== 第二层：拦截服务器指令 ====================
local function SetupLayer2()
    local success = pcall(function()
        -- 监听所有可能触发恢复的 RemoteEvent
        for _, remote in pairs(ReplicatedStorage.Events:GetChildren()) do
            if remote:IsA("RemoteEvent") and remote.Name ~= "__RZDONL" then
                -- 监听服务器发来的事件
                remote.OnClientEvent:Connect(function(...)
                    local args = {...}
                    
                    -- 检查是否是恢复指令
                    for _, arg in pairs(args) do
                        if type(arg) == "EnumItem" then
                            if arg == Enum.HumanoidStateType.GettingUp or
                               arg == Enum.HumanoidStateType.Running then
                                
                                Stats.Layer2Blocks = Stats.Layer2Blocks + 1
                                Stats.TotalBlocks = Stats.TotalBlocks + 1
                                
                                if Config.EnableLogging then
                                    print(string.format("[%.2f] 🛡️ [第2层] 拦截服务器指令: %s", 
                                        tick(), 
                                        tostring(arg):gsub("Enum%.HumanoidStateType%.", "")
                                    ))
                                end
                                
                                -- 立即触发布偶对抗
                                TriggerRagdoll("第2层拦截")
                                
                                -- 强制设置状态
                                task.spawn(function()
                                    Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
                                end)
                                
                                return  -- 阻止事件处理
                            end
                        end
                    end
                end)
            end
        end
        
        print("✅ [第2层] RemoteEvent 监听已设置")
        return true
    end)
    
    if not success then
        warn("⚠️ [第2层] 设置失败")
        return false
    end
    
    return true
end

-- ==================== 第三层：Heartbeat 兜底 ====================
local function SetupLayer3()
    -- 禁用状态（如果支持）
    pcall(function()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        print("✅ [第3层] 已禁用站立状态")
    end)
    
    -- Heartbeat 强制检查
    HeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
        local currentState = Humanoid:GetState()
        
        -- 检测到危险状态，立即修正
        if currentState == Enum.HumanoidStateType.GettingUp or
           currentState == Enum.HumanoidStateType.Running or
           currentState == Enum.HumanoidStateType.Landed then
            
            Stats.Layer3Blocks = Stats.Layer3Blocks + 1
            Stats.TotalBlocks = Stats.TotalBlocks + 1
            
            if Config.EnableLogging then
                print(string.format("[%.2f] ⚙️ [第3层] Heartbeat 兜底: %s → Ragdoll", 
                    tick(), 
                    tostring(currentState):gsub("Enum%.HumanoidStateType%.", "")
                ))
            end
            
            -- 立即修正
            pcall(function()
                Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
            end)
            
            -- 触发布偶
            TriggerRagdoll("第3层兜底")
        end
    end)
    
    print("✅ [第3层] Heartbeat 监控已启动")
end

-- ==================== 兜底定时触发 ====================
local function SetupBackupLoop()
    local lastTrigger = 0
    
    BackupLoopConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
        local now = tick()
        if now - lastTrigger >= Config.BackupInterval then
            TriggerRagdoll("定时兜底")
            lastTrigger = now
        end
    end)
    
    print(string.format("✅ [兜底] 定时触发已启动 (间隔: %.1f秒)", Config.BackupInterval))
end

-- ==================== 启动 ====================
local function Start()
    if Config.Enabled then return end
    Config.Enabled = true
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🚫 布偶拦截器启动中...")
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    
    -- 初始触发
    TriggerRagdoll("初始")
    
    -- 设置三层防护
    local layer1OK = SetupLayer1()
    local layer2OK = SetupLayer2()
    SetupLayer3()
    SetupBackupLoop()
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("✅ 拦截器已启动")
    print(string.format("  🎣 第1层 (Hook): %s", layer1OK and "✅" or "❌"))
    print(string.format("  🛡️ 第2层 (RemoteEvent): %s", layer2OK and "✅" or "❌"))
    print("  ⚙️ 第3层 (Heartbeat): ✅")
    print("  🔄 兜底触发: ✅")
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
end

-- ==================== 停止 ====================
local function Stop()
    if not Config.Enabled then return end
    Config.Enabled = false
    
    if BackupLoopConnection then
        BackupLoopConnection:Disconnect()
        BackupLoopConnection = nil
    end
    
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
        HeartbeatConnection = nil
    end
    
    -- 恢复状态
    pcall(function()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end)
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
    print("⏹️ 拦截器已停止")
    print("📊 拦截统计:")
    print(string.format("  🎣 第1层: %d 次", Stats.Layer1Blocks))
    print(string.format("  🛡️ 第2层: %d 次", Stats.Layer2Blocks))
    print(string.format("  ⚙️ 第3层: %d 次", Stats.Layer3Blocks))
    print(string.format("  📈 总计: %d 次", Stats.TotalBlocks))
    print("━━━━━━━━━━━━━━━━━━━━━━━━")
end

-- ==================== GUI ====================
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RagdollInterceptorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 280)
Frame.Position = UDim2.new(0.5, -160, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BorderSizePixel = 0
Frame.Draggable = true
Frame.Active = true
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(100, 100, 255)
FrameStroke.Thickness = 2
FrameStroke.Parent = Frame

-- 标题
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "🚫 布偶拦截器 - 三层防护"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- 关闭按钮
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Frame

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    if Config.Enabled then Stop() end
    ScreenGui:Destroy()
end)

-- 说明
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 85)
Info.Position = UDim2.new(0, 10, 0, 50)
Info.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Info.Text = "🎣 第1层: Hook拦截 ChangeState\n🛡️ 第2层: 拦截服务器恢复指令\n⚙️ 第3层: Heartbeat 强制检查\n🔄 兜底: 定时触发布偶事件\n✅ 从根源阻止站立！"
Info.TextColor3 = Color3.fromRGB(200, 255, 200)
Info.TextSize = 11
Info.Font = Enum.Font.Code
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.BorderSizePixel = 0
Info.Parent = Frame

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = Info

local InfoPadding = Instance.new("UIPadding")
InfoPadding.PaddingLeft = UDim.new(0, 8)
InfoPadding.PaddingTop = UDim.new(0, 5)
InfoPadding.Parent = Info

-- 统计显示
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -20, 0, 60)
StatsLabel.Position = UDim2.new(0, 10, 0, 145)
StatsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StatsLabel.Text = "📊 拦截统计\n第1层: 0 | 第2层: 0 | 第3层: 0\n总计: 0 次"
StatsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
StatsLabel.TextSize = 12
StatsLabel.Font = Enum.Font.Code
StatsLabel.BorderSizePixel = 0
StatsLabel.Parent = Frame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsLabel

-- 更新统计显示
local function UpdateStats()
    StatsLabel.Text = string.format(
        "📊 拦截统计\n🎣 第1层: %d | 🛡️ 第2层: %d | ⚙️ 第3层: %d\n📈 总计: %d 次",
        Stats.Layer1Blocks,
        Stats.Layer2Blocks,
        Stats.Layer3Blocks,
        Stats.TotalBlocks
    )
end

-- 定时更新统计
task.spawn(function()
    while task.wait(0.5) do
        if Config.Enabled then
            UpdateStats()
        end
    end
end)

-- 开关按钮
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0, 215)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
ToggleBtn.Text = "▶ 启动拦截器"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = Frame

local ToggleBtnCorner = Instance.new("UICorner")
ToggleBtnCorner.CornerRadius = UDim.new(0, 10)
ToggleBtnCorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    if Config.Enabled then
        Stop()
        ToggleBtn.Text = "▶ 启动拦截器"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    else
        Start()
        ToggleBtn.Text = "⏹ 停止拦截器"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- ==================== 初始化 ====================
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🚫 布偶拦截器已加载 - 三层防护")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("防护机制:")
print("  🎣 第1层: Hook __namecall 拦截")
print("  🛡️ 第2层: RemoteEvent 拦截")
print("  ⚙️ 第3层: Heartbeat 强制检查")
print("  🔄 兜底: 定时触发布偶")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

-- 预加载 RemoteEvent
task.spawn(function()
    task.wait(1)
    RagdollRemote = GetRagdollRemote()
end)

