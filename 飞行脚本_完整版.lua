--[[
═══════════════════════════════════════════════════════════
    🚀 终极飞行控制器 v2.0
    
    功能特性：
    ✈️ 多种飞行模式（标准/快速/隐蔽/脉冲）
    🎮 WASD方向控制 + 空格上升 + Shift下降
    ⚡ 实时速度调节（1-500）
    🛡️ 反检测保护
    📊 飞行状态显示
    🎯 瞬移到鼠标位置（Ctrl+点击）
    🔄 自动恢复位置
    💨 惯性模拟
    🌈 视觉特效
═══════════════════════════════════════════════════════════
--]]

print("═══════════════════════════════════════════════")
print("🚀 正在加载终极飞行控制器...")
print("═══════════════════════════════════════════════")

-- ==================== 服务 ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== 配置 ====================
local Config = {
    -- 飞行设置
    IsFlying = false,
    FlyMode = "Standard", -- Standard, Fast, Stealth, Pulse
    Speed = 50,
    MaxSpeed = 500,
    MinSpeed = 1,
    
    -- 控制设置
    Controls = {
        Forward = false,
        Backward = false,
        Left = false,
        Right = false,
        Up = false,
        Down = false,
    },
    
    -- 高级设置
    AntiDetection = true,
    ShowTrail = true,
    Momentum = true,
    AutoSavePos = true,
    NoClip = false,
    
    -- 娱乐功能
    SpinningActive = false,
    SpinTarget = nil,
    SpinRadius = 5,
    SpinSpeed = 2,
    
    -- 脉冲模式设置
    PulseActive = false,
    PulseFlyTime = 1,
    PulseStopTime = 1,
    
    -- 内部变量
    BodyVelocity = nil,
    BodyGyro = nil,
    Connection = nil,
    SavedPosition = nil,
    CurrentVelocity = Vector3.new(0, 0, 0),
}

-- ==================== 工具函数 ====================
local function Notify(title, text, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 3;
    })
end

local function GetRoot()
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- ==================== 飞行核心 ====================
local function CreateBodyMovers()
    local root = GetRoot()
    if not root then return false end
    
    -- 清理旧的
    if Config.BodyVelocity then Config.BodyVelocity:Destroy() end
    if Config.BodyGyro then Config.BodyGyro:Destroy() end
    
    -- 创建BodyVelocity
    Config.BodyVelocity = Instance.new("BodyVelocity")
    Config.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    Config.BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Config.BodyVelocity.Parent = root
    
    -- 创建BodyGyro
    Config.BodyGyro = Instance.new("BodyGyro")
    Config.BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    Config.BodyGyro.P = 3000
    Config.BodyGyro.CFrame = root.CFrame
    Config.BodyGyro.Parent = root
    
    return true
end

local function RemoveBodyMovers()
    if Config.BodyVelocity then
        Config.BodyVelocity:Destroy()
        Config.BodyVelocity = nil
    end
    if Config.BodyGyro then
        Config.BodyGyro:Destroy()
        Config.BodyGyro = nil
    end
end

local function CalculateVelocity()
    local direction = Vector3.new(0, 0, 0)
    
    -- 前后左右
    if Config.Controls.Forward then
        direction = direction + Camera.CFrame.LookVector
    end
    if Config.Controls.Backward then
        direction = direction - Camera.CFrame.LookVector
    end
    if Config.Controls.Left then
        direction = direction - Camera.CFrame.RightVector
    end
    if Config.Controls.Right then
        direction = direction + Camera.CFrame.RightVector
    end
    
    -- 上下
    if Config.Controls.Up then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if Config.Controls.Down then
        direction = direction - Vector3.new(0, 1, 0)
    end
    
    -- 归一化并应用速度
    if direction.Magnitude > 0 then
        direction = direction.Unit
    end
    
    -- 根据模式调整速度
    local speedMultiplier = 1
    if Config.FlyMode == "Fast" then
        speedMultiplier = 2
    elseif Config.FlyMode == "Stealth" then
        speedMultiplier = 0.5
    end
    
    local targetVelocity = direction * Config.Speed * speedMultiplier
    
    -- 惯性模拟
    if Config.Momentum then
        Config.CurrentVelocity = Config.CurrentVelocity:Lerp(targetVelocity, 0.3)
        return Config.CurrentVelocity
    else
        return targetVelocity
    end
end

local function UpdateFlight()
    if not Config.IsFlying then return end
    
    local root = GetRoot()
    if not root or not Config.BodyVelocity or not Config.BodyGyro then
        StopFly()
        return
    end
    
    -- 更新速度
    local velocity = CalculateVelocity()
    Config.BodyVelocity.Velocity = velocity
    
    -- 更新朝向
    Config.BodyGyro.CFrame = Camera.CFrame
    
    -- 反检测：随机微调
    if Config.AntiDetection then
        local randomOffset = Vector3.new(
            math.random(-2, 2) / 100,
            math.random(-2, 2) / 100,
            math.random(-2, 2) / 100
        )
        Config.BodyVelocity.Velocity = Config.BodyVelocity.Velocity + randomOffset
    end
end

function StartFly()
    if Config.IsFlying then
        Notify("⚠️ 提示", "飞行已经启动", 2)
        return
    end
    
    local root = GetRoot()
    local hum = GetHumanoid()
    if not root or not hum then
        Notify("❌ 错误", "角色未找到", 3)
        return
    end
    
    -- 保存位置
    if Config.AutoSavePos then
        Config.SavedPosition = root.CFrame
    end
    
    -- 创建控制器
    if not CreateBodyMovers() then
        Notify("❌ 错误", "无法创建飞行控制器", 3)
        return
    end
    
    Config.IsFlying = true
    
    -- 设置人物状态
    if Config.AntiDetection then
        hum.PlatformStand = true
    end
    
    -- 启动更新循环
    Config.Connection = RunService.Heartbeat:Connect(UpdateFlight)
    
    Notify("🚀 飞行启动", "模式: " .. Config.FlyMode, 3)
    print("✈️ 飞行已启动 | 速度:", Config.Speed, "| 模式:", Config.FlyMode)
end

function StopFly()
    if not Config.IsFlying then return end
    
    Config.IsFlying = false
    
    -- 停止更新
    if Config.Connection then
        Config.Connection:Disconnect()
        Config.Connection = nil
    end
    
    -- 移除控制器
    RemoveBodyMovers()
    
    -- 恢复人物状态
    local hum = GetHumanoid()
    if hum then
        hum.PlatformStand = false
    end
    
    -- 重置速度
    Config.CurrentVelocity = Vector3.new(0, 0, 0)
    
    Notify("⏹️ 飞行停止", "已着陆", 2)
    print("⏹️ 飞行已停止")
end

function ToggleFly()
    if Config.IsFlying then
        StopFly()
    else
        StartFly()
    end
end

-- ==================== 穿墙功能 ====================
local NoClipConnection = nil

local function EnableNoClip()
    if NoClipConnection then return end
    
    Config.NoClip = true
    NoClipConnection = RunService.Stepped:Connect(function()
        if not Config.NoClip then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    
    Notify("🚫 穿墙", "已启用", 2)
    print("✅ 穿墙已启用")
end

local function DisableNoClip()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    
    Config.NoClip = false
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
    
    Notify("🚫 穿墙", "已禁用", 2)
    print("⏹️ 穿墙已禁用")
end

function ToggleNoClip()
    if Config.NoClip then
        DisableNoClip()
    else
        EnableNoClip()
    end
end

-- ==================== 娱乐功能：转圈圈 ====================
local SpinConnection = nil
local SpinAngle = 0

local function GetPlayerByName(name)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(name:lower()) or player.DisplayName:lower():find(name:lower()) then
            return player
        end
    end
    return nil
end

local function StartSpinning(targetPlayer)
    if SpinConnection then
        StopSpinning()
    end
    
    if not targetPlayer or not targetPlayer.Character then
        Notify("❌ 错误", "未找到目标玩家", 3)
        return
    end
    
    Config.SpinTarget = targetPlayer
    Config.SpinningActive = true
    SpinAngle = 0
    
    -- 启动飞行（如果未启动）
    if not Config.IsFlying then
        StartFly()
    end
    
    SpinConnection = RunService.Heartbeat:Connect(function()
        if not Config.SpinningActive then return end
        
        local targetChar = Config.SpinTarget and Config.SpinTarget.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local myRoot = GetRoot()
        
        if not targetRoot or not myRoot then
            StopSpinning()
            return
        end
        
        -- 计算转圈位置
        SpinAngle = SpinAngle + (Config.SpinSpeed * 0.05)
        if SpinAngle > math.pi * 2 then
            SpinAngle = SpinAngle - math.pi * 2
        end
        
        local targetPos = targetRoot.Position
        local offsetX = math.cos(SpinAngle) * Config.SpinRadius
        local offsetZ = math.sin(SpinAngle) * Config.SpinRadius
        
        local newPos = Vector3.new(
            targetPos.X + offsetX,
            targetPos.Y,
            targetPos.Z + offsetZ
        )
        
        -- 朝向目标
        local lookAtPos = targetPos
        local direction = (lookAtPos - newPos).Unit
        
        myRoot.CFrame = CFrame.new(newPos, lookAtPos)
        
        -- 同时更新飞行速度为0（停在原地转）
        if Config.BodyVelocity then
            Config.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    Notify("🌀 转圈模式", "正在围绕 " .. targetPlayer.DisplayName .. " 转圈", 3)
    print("🌀 开始转圈:", targetPlayer.DisplayName)
end

local function StopSpinning()
    if SpinConnection then
        SpinConnection:Disconnect()
        SpinConnection = nil
    end
    
    Config.SpinningActive = false
    Config.SpinTarget = nil
    
    Notify("🌀 转圈模式", "已停止", 2)
    print("⏹️ 停止转圈")
end

function ToggleSpinning(targetPlayerName)
    if Config.SpinningActive then
        StopSpinning()
    else
        local targetPlayer = GetPlayerByName(targetPlayerName)
        if targetPlayer then
            StartSpinning(targetPlayer)
        else
            Notify("❌ 错误", "未找到玩家: " .. targetPlayerName, 3)
        end
    end
end

-- ==================== 脉冲模式 ====================
local function StartPulseMode()
    if Config.PulseActive then return end
    Config.PulseActive = true
    
    spawn(function()
        while Config.PulseActive do
            -- 开启飞行
            if not Config.IsFlying then
                StartFly()
            end
            wait(Config.PulseFlyTime)
            
            if not Config.PulseActive then break end
            
            -- 关闭飞行
            if Config.IsFlying then
                StopFly()
            end
            wait(Config.PulseStopTime)
        end
    end)
    
    Notify("⚡ 脉冲模式", "已启动", 2)
end

local function StopPulseMode()
    Config.PulseActive = false
    if Config.IsFlying then
        StopFly()
    end
    Notify("⏹️ 脉冲模式", "已停止", 2)
end

-- ==================== 输入控制 ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode
    
    -- 方向控制
    if key == Enum.KeyCode.W then
        Config.Controls.Forward = true
    elseif key == Enum.KeyCode.S then
        Config.Controls.Backward = true
    elseif key == Enum.KeyCode.A then
        Config.Controls.Left = true
    elseif key == Enum.KeyCode.D then
        Config.Controls.Right = true
    elseif key == Enum.KeyCode.Space then
        Config.Controls.Up = true
    elseif key == Enum.KeyCode.LeftShift then
        Config.Controls.Down = true
    
    -- 功能控制
    elseif key == Enum.KeyCode.F then
        ToggleFly()
    elseif key == Enum.KeyCode.R then
        -- 回到保存的位置
        if Config.SavedPosition then
            local root = GetRoot()
            if root then
                root.CFrame = Config.SavedPosition
                Notify("📍 位置恢复", "已返回保存点", 2)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    local key = input.KeyCode
    
    if key == Enum.KeyCode.W then
        Config.Controls.Forward = false
    elseif key == Enum.KeyCode.S then
        Config.Controls.Backward = false
    elseif key == Enum.KeyCode.A then
        Config.Controls.Left = false
    elseif key == Enum.KeyCode.D then
        Config.Controls.Right = false
    elseif key == Enum.KeyCode.Space then
        Config.Controls.Up = false
    elseif key == Enum.KeyCode.LeftShift then
        Config.Controls.Down = false
    end
end)

-- Ctrl+点击瞬移
local Mouse = LocalPlayer:GetMouse()
Mouse.Button1Down:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and Mouse.Target then
        local root = GetRoot()
        if root then
            root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            Notify("⚡ 瞬移", "已传送", 1)
        end
    end
end)

-- ==================== GUI ====================
local function CreateUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- 清理旧UI
    if playerGui:FindFirstChild("UltimateFlyUI") then
        playerGui:FindFirstChild("UltimateFlyUI"):Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltimateFlyUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = playerGui
    
    -- ========== 主框架 ==========
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 620)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -310)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame
    
    -- 渐变效果
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
    }
    Gradient.Rotation = 45
    Gradient.Parent = MainFrame
    
    -- ========== 标题栏 ==========
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = TitleBar
    
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 140, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 200))
    }
    TitleGradient.Rotation = 90
    TitleGradient.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🚀 终极飞行控制器"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- 关闭按钮
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -42, 0, 7.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 20
    CloseBtn.Parent = TitleBar
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 10)
    CloseBtnCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        if Config.IsFlying then StopFly() end
        if Config.PulseActive then StopPulseMode() end
        if Config.SpinningActive then StopSpinning() end
        if Config.NoClip then DisableNoClip() end
        ScreenGui:Destroy()
    end)
    
    -- ========== 状态显示 ==========
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 60)
    StatusFrame.Position = UDim2.new(0, 10, 0, 60)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = StatusFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 1, -20)
    StatusLabel.Position = UDim2.new(0, 10, 0, 10)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.Code
    StatusLabel.Text = "⏸️ 状态: 待机\n⚡ 速度: 50\n🎯 模式: Standard"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    StatusLabel.TextSize = 13
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = StatusFrame
    
    -- 更新状态
    spawn(function()
        while ScreenGui.Parent do
            wait(0.1)
            local status = Config.IsFlying and "✈️ 飞行中" or "⏸️ 待机"
            local mode = Config.PulseActive and "⚡ 脉冲" or Config.FlyMode
            local extras = ""
            if Config.NoClip then extras = extras .. " | 🚫穿墙" end
            if Config.SpinningActive then extras = extras .. " | 🌀转圈" end
            StatusLabel.Text = status .. "\n⚡ 速度: " .. Config.Speed .. "\n🎯 模式: " .. mode .. extras
        end
    end)
    
    -- ========== 飞行模式选择 ==========
    local ModeFrame = Instance.new("Frame")
    ModeFrame.Size = UDim2.new(1, -20, 0, 90)
    ModeFrame.Position = UDim2.new(0, 10, 0, 130)
    ModeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    ModeFrame.BorderSizePixel = 0
    ModeFrame.Parent = MainFrame
    
    local ModeCorner = Instance.new("UICorner")
    ModeCorner.CornerRadius = UDim.new(0, 10)
    ModeCorner.Parent = ModeFrame
    
    local ModeTitle = Instance.new("TextLabel")
    ModeTitle.Size = UDim2.new(1, -20, 0, 20)
    ModeTitle.Position = UDim2.new(0, 10, 0, 5)
    ModeTitle.BackgroundTransparency = 1
    ModeTitle.Font = Enum.Font.GothamBold
    ModeTitle.Text = "飞行模式"
    ModeTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    ModeTitle.TextSize = 13
    ModeTitle.TextXAlignment = Enum.TextXAlignment.Left
    ModeTitle.Parent = ModeFrame
    
    local modes = {
        {name = "Standard", icon = "✈️", desc = "标准"},
        {name = "Fast", icon = "⚡", desc = "快速"},
        {name = "Stealth", icon = "🥷", desc = "隐蔽"},
        {name = "Pulse", icon = "💫", desc = "脉冲"}
    }
    
    for i, mode in ipairs(modes) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.23, 0, 0, 50)
        btn.Position = UDim2.new((i-1) * 0.25 + 0.01, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.Font = Enum.Font.GothamBold
        btn.Text = mode.icon .. "\n" .. mode.desc
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Parent = ModeFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if mode.name == "Pulse" then
                if Config.PulseActive then
                    StopPulseMode()
                    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                else
                    Config.FlyMode = "Standard"
                    StartPulseMode()
                    btn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                end
            else
                Config.FlyMode = mode.name
                StopPulseMode()
                -- 重置所有按钮
                for _, child in ipairs(ModeFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                Notify("🎯 模式切换", mode.desc .. "模式", 2)
            end
        end)
    end
    
    -- ========== 速度控制 ==========
    local SpeedFrame = Instance.new("Frame")
    SpeedFrame.Size = UDim2.new(1, -20, 0, 80)
    SpeedFrame.Position = UDim2.new(0, 10, 0, 230)
    SpeedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SpeedFrame.BorderSizePixel = 0
    SpeedFrame.Parent = MainFrame
    
    local SpeedCorner = Instance.new("UICorner")
    SpeedCorner.CornerRadius = UDim.new(0, 10)
    SpeedCorner.Parent = SpeedFrame
    
    local SpeedTitle = Instance.new("TextLabel")
    SpeedTitle.Size = UDim2.new(1, -20, 0, 20)
    SpeedTitle.Position = UDim2.new(0, 10, 0, 5)
    SpeedTitle.BackgroundTransparency = 1
    SpeedTitle.Font = Enum.Font.GothamBold
    SpeedTitle.Text = "速度控制: 50"
    SpeedTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    SpeedTitle.TextSize = 13
    SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
    SpeedTitle.Parent = SpeedFrame
    
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Size = UDim2.new(1, -20, 0, 8)
    SpeedSlider.Position = UDim2.new(0, 10, 0, 35)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Parent = SpeedFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SpeedSlider
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Config.Speed - Config.MinSpeed) / (Config.MaxSpeed - Config.MinSpeed), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SpeedSlider
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.Parent = SpeedSlider
    
    local dragging = false
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation()
            local relativePos = (mouse.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X
            relativePos = math.clamp(relativePos, 0, 1)
            
            Config.Speed = math.floor(Config.MinSpeed + (Config.MaxSpeed - Config.MinSpeed) * relativePos)
            SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            SpeedTitle.Text = "速度控制: " .. Config.Speed
        end
    end)
    
    -- 速度预设
    local presets = {
        {text = "慢", speed = 20},
        {text = "中", speed = 50},
        {text = "快", speed = 100},
        {text = "极速", speed = 250}
    }
    
    for i, preset in ipairs(presets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.23, 0, 0, 25)
        btn.Position = UDim2.new((i-1) * 0.25 + 0.01, 0, 0, 50)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.Font = Enum.Font.GothamMedium
        btn.Text = preset.text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Parent = SpeedFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            Config.Speed = preset.speed
            SliderFill.Size = UDim2.new((Config.Speed - Config.MinSpeed) / (Config.MaxSpeed - Config.MinSpeed), 0, 1, 0)
            SpeedTitle.Text = "速度控制: " .. Config.Speed
        end)
    end
    
    -- ========== 主控制按钮 ==========
    local ControlFrame = Instance.new("Frame")
    ControlFrame.Size = UDim2.new(1, -20, 0, 60)
    ControlFrame.Position = UDim2.new(0, 10, 0, 320)
    ControlFrame.BackgroundTransparency = 1
    ControlFrame.Parent = MainFrame
    
    local FlyBtn = Instance.new("TextButton")
    FlyBtn.Size = UDim2.new(0.48, 0, 1, 0)
    FlyBtn.Position = UDim2.new(0, 0, 0, 0)
    FlyBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
    FlyBtn.Font = Enum.Font.GothamBold
    FlyBtn.Text = "🚀 启动飞行 (F)"
    FlyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyBtn.TextSize = 14
    FlyBtn.Parent = ControlFrame
    
    local FlyBtnCorner = Instance.new("UICorner")
    FlyBtnCorner.CornerRadius = UDim.new(0, 10)
    FlyBtnCorner.Parent = FlyBtn
    
    FlyBtn.MouseButton1Click:Connect(function()
        ToggleFly()
        if Config.IsFlying then
            FlyBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            FlyBtn.Text = "⏹️ 停止飞行 (F)"
        else
            FlyBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
            FlyBtn.Text = "🚀 启动飞行 (F)"
        end
    end)
    
    local SavePosBtn = Instance.new("TextButton")
    SavePosBtn.Size = UDim2.new(0.48, 0, 1, 0)
    SavePosBtn.Position = UDim2.new(0.52, 0, 0, 0)
    SavePosBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    SavePosBtn.Font = Enum.Font.GothamBold
    SavePosBtn.Text = "📍 返回位置 (R)"
    SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SavePosBtn.TextSize = 14
    SavePosBtn.Parent = ControlFrame
    
    local SaveBtnCorner = Instance.new("UICorner")
    SaveBtnCorner.CornerRadius = UDim.new(0, 10)
    SaveBtnCorner.Parent = SavePosBtn
    
    SavePosBtn.MouseButton1Click:Connect(function()
        if Config.SavedPosition then
            local root = GetRoot()
            if root then
                root.CFrame = Config.SavedPosition
                Notify("📍 位置恢复", "已返回保存点", 2)
            end
        else
            Notify("⚠️ 提示", "没有保存的位置", 2)
        end
    end)
    
    -- ========== 高级设置 ==========
    local AdvFrame = Instance.new("Frame")
    AdvFrame.Size = UDim2.new(1, -20, 0, 80)
    AdvFrame.Position = UDim2.new(0, 10, 0, 390)
    AdvFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    AdvFrame.BorderSizePixel = 0
    AdvFrame.Parent = MainFrame
    
    local AdvCorner = Instance.new("UICorner")
    AdvCorner.CornerRadius = UDim.new(0, 10)
    AdvCorner.Parent = AdvFrame
    
    local AdvTitle = Instance.new("TextLabel")
    AdvTitle.Size = UDim2.new(1, -20, 0, 20)
    AdvTitle.Position = UDim2.new(0, 10, 0, 5)
    AdvTitle.BackgroundTransparency = 1
    AdvTitle.Font = Enum.Font.GothamBold
    AdvTitle.Text = "高级设置"
    AdvTitle.TextColor3 = Color3.fromRGB(200, 255, 200)
    AdvTitle.TextSize = 13
    AdvTitle.TextXAlignment = Enum.TextXAlignment.Left
    AdvTitle.Parent = AdvFrame
    
    local settings = {
        {name = "反检测", var = "AntiDetection"},
        {name = "惯性", var = "Momentum"},
        {name = "自动保存", var = "AutoSavePos"},
        {name = "穿墙", var = "NoClip", special = true}
    }
    
    for i, setting in ipairs(settings) do
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.23, 0, 0, 45)
        toggle.Position = UDim2.new((i-1) * 0.25 + 0.01, 0, 0, 30)
        toggle.BackgroundColor3 = Config[setting.var] and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
        toggle.Font = Enum.Font.GothamMedium
        toggle.Text = setting.name .. "\n" .. (Config[setting.var] and "✓" or "✗")
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 11
        toggle.Parent = AdvFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggle
        
        toggle.MouseButton1Click:Connect(function()
            if setting.special and setting.var == "NoClip" then
                -- 穿墙特殊处理
                ToggleNoClip()
                toggle.BackgroundColor3 = Config[setting.var] and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
                toggle.Text = setting.name .. "\n" .. (Config[setting.var] and "✓" or "✗")
            else
                Config[setting.var] = not Config[setting.var]
                toggle.BackgroundColor3 = Config[setting.var] and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
                toggle.Text = setting.name .. "\n" .. (Config[setting.var] and "✓" or "✗")
            end
        end)
    end
    
    -- ========== 娱乐功能 ==========
    local FunFrame = Instance.new("Frame")
    FunFrame.Size = UDim2.new(1, -20, 0, 130)
    FunFrame.Position = UDim2.new(0, 10, 0, 480)
    FunFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    FunFrame.BorderSizePixel = 0
    FunFrame.Parent = MainFrame
    
    local FunCorner = Instance.new("UICorner")
    FunCorner.CornerRadius = UDim.new(0, 10)
    FunCorner.Parent = FunFrame
    
    local FunTitle = Instance.new("TextLabel")
    FunTitle.Size = UDim2.new(1, -20, 0, 20)
    FunTitle.Position = UDim2.new(0, 10, 0, 5)
    FunTitle.BackgroundTransparency = 1
    FunTitle.Font = Enum.Font.GothamBold
    FunTitle.Text = "🎪 娱乐功能"
    FunTitle.TextColor3 = Color3.fromRGB(255, 150, 255)
    FunTitle.TextSize = 13
    FunTitle.TextXAlignment = Enum.TextXAlignment.Left
    FunTitle.Parent = FunFrame
    
    -- 玩家列表下拉框
    local PlayerDropdown = Instance.new("Frame")
    PlayerDropdown.Size = UDim2.new(1, -20, 0, 35)
    PlayerDropdown.Position = UDim2.new(0, 10, 0, 30)
    PlayerDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    PlayerDropdown.BorderSizePixel = 0
    PlayerDropdown.Parent = FunFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = PlayerDropdown
    
    local SelectedPlayerLabel = Instance.new("TextLabel")
    SelectedPlayerLabel.Size = UDim2.new(1, -40, 1, 0)
    SelectedPlayerLabel.Position = UDim2.new(0, 10, 0, 0)
    SelectedPlayerLabel.BackgroundTransparency = 1
    SelectedPlayerLabel.Font = Enum.Font.GothamMedium
    SelectedPlayerLabel.Text = "选择玩家..."
    SelectedPlayerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SelectedPlayerLabel.TextSize = 12
    SelectedPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectedPlayerLabel.Parent = PlayerDropdown
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(0, 30, 1, 0)
    DropdownButton.Position = UDim2.new(1, -30, 0, 0)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Font = Enum.Font.GothamBold
    DropdownButton.Text = "▼"
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 12
    DropdownButton.Parent = PlayerDropdown
    
    -- 玩家列表滚动框
    local PlayerList = Instance.new("ScrollingFrame")
    PlayerList.Size = UDim2.new(1, -20, 0, 0)
    PlayerList.Position = UDim2.new(0, 10, 0, 70)
    PlayerList.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    PlayerList.BorderSizePixel = 0
    PlayerList.ScrollBarThickness = 4
    PlayerList.Visible = false
    PlayerList.Parent = FunFrame
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 8)
    ListCorner.Parent = PlayerList
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.Name
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = PlayerList
    
    local selectedPlayer = nil
    
    -- 更新玩家列表
    local function UpdatePlayerList()
        for _, child in pairs(PlayerList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local playerBtn = Instance.new("TextButton")
                playerBtn.Size = UDim2.new(1, -8, 0, 25)
                playerBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
                playerBtn.Font = Enum.Font.Gotham
                playerBtn.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerBtn.TextSize = 10
                playerBtn.TextXAlignment = Enum.TextXAlignment.Left
                playerBtn.Parent = PlayerList
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 6)
                btnCorner.Parent = playerBtn
                
                local padding = Instance.new("UIPadding")
                padding.PaddingLeft = UDim.new(0, 8)
                padding.Parent = playerBtn
                
                playerBtn.MouseButton1Click:Connect(function()
                    selectedPlayer = player
                    SelectedPlayerLabel.Text = player.DisplayName
                    PlayerList.Visible = false
                    DropdownButton.Text = "▼"
                end)
            end
        end
        
        PlayerList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        PlayerList.Visible = not PlayerList.Visible
        if PlayerList.Visible then
            PlayerList.Size = UDim2.new(1, -20, 0, math.min(150, ListLayout.AbsoluteContentSize.Y + 10))
            DropdownButton.Text = "▲"
            UpdatePlayerList()
        else
            PlayerList.Size = UDim2.new(1, -20, 0, 0)
            DropdownButton.Text = "▼"
        end
    end)
    
    -- 转圈控制按钮
    local SpinBtn = Instance.new("TextButton")
    SpinBtn.Size = UDim2.new(0.48, 0, 0, 40)
    SpinBtn.Position = UDim2.new(0, 10, 1, -50)
    SpinBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 200)
    SpinBtn.Font = Enum.Font.GothamBold
    SpinBtn.Text = "🌀 开始转圈"
    SpinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpinBtn.TextSize = 13
    SpinBtn.Parent = FunFrame
    
    local SpinBtnCorner = Instance.new("UICorner")
    SpinBtnCorner.CornerRadius = UDim.new(0, 8)
    SpinBtnCorner.Parent = SpinBtn
    
    SpinBtn.MouseButton1Click:Connect(function()
        if Config.SpinningActive then
            StopSpinning()
            SpinBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 200)
            SpinBtn.Text = "🌀 开始转圈"
        else
            if selectedPlayer then
                StartSpinning(selectedPlayer)
                SpinBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
                SpinBtn.Text = "⏹️ 停止转圈"
            else
                Notify("⚠️ 提示", "请先选择玩家", 2)
            end
        end
    end)
    
    -- 设置按钮
    local SettingsBtn = Instance.new("TextButton")
    SettingsBtn.Size = UDim2.new(0.48, 0, 0, 40)
    SettingsBtn.Position = UDim2.new(0.52, 0, 1, -50)
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    SettingsBtn.Font = Enum.Font.GothamBold
    SettingsBtn.Text = "⚙️ 转圈设置"
    SettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingsBtn.TextSize = 13
    SettingsBtn.Parent = FunFrame
    
    local SettingsBtnCorner = Instance.new("UICorner")
    SettingsBtnCorner.CornerRadius = UDim.new(0, 8)
    SettingsBtnCorner.Parent = SettingsBtn
    
    -- 创建设置窗口
    local SettingsWindow = Instance.new("Frame")
    SettingsWindow.Size = UDim2.new(0, 300, 0, 150)
    SettingsWindow.Position = UDim2.new(0.5, -150, 0.5, -75)
    SettingsWindow.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SettingsWindow.BorderSizePixel = 0
    SettingsWindow.Visible = false
    SettingsWindow.Parent = ScreenGui
    
    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 12)
    SettingsCorner.Parent = SettingsWindow
    
    local SettingsTitle = Instance.new("TextLabel")
    SettingsTitle.Size = UDim2.new(1, -40, 0, 30)
    SettingsTitle.Position = UDim2.new(0, 10, 0, 5)
    SettingsTitle.BackgroundTransparency = 1
    SettingsTitle.Font = Enum.Font.GothamBold
    SettingsTitle.Text = "⚙️ 转圈设置"
    SettingsTitle.TextColor3 = Color3.fromRGB(255, 200, 255)
    SettingsTitle.TextSize = 14
    SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    SettingsTitle.Parent = SettingsWindow
    
    local CloseSettings = Instance.new("TextButton")
    CloseSettings.Size = UDim2.new(0, 25, 0, 25)
    CloseSettings.Position = UDim2.new(1, -30, 0, 5)
    CloseSettings.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseSettings.Font = Enum.Font.GothamBold
    CloseSettings.Text = "×"
    CloseSettings.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseSettings.TextSize = 16
    CloseSettings.Parent = SettingsWindow
    
    local CloseSettingsCorner = Instance.new("UICorner")
    CloseSettingsCorner.CornerRadius = UDim.new(0, 6)
    CloseSettingsCorner.Parent = CloseSettings
    
    CloseSettings.MouseButton1Click:Connect(function()
        SettingsWindow.Visible = false
    end)
    
    -- 半径设置
    local RadiusLabel = Instance.new("TextLabel")
    RadiusLabel.Size = UDim2.new(0.4, 0, 0, 25)
    RadiusLabel.Position = UDim2.new(0, 10, 0, 45)
    RadiusLabel.BackgroundTransparency = 1
    RadiusLabel.Font = Enum.Font.Gotham
    RadiusLabel.Text = "转圈半径: " .. Config.SpinRadius
    RadiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    RadiusLabel.TextSize = 11
    RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
    RadiusLabel.Parent = SettingsWindow
    
    local RadiusSlider = Instance.new("Frame")
    RadiusSlider.Size = UDim2.new(0.5, 0, 0, 6)
    RadiusSlider.Position = UDim2.new(0.45, 0, 0, 55)
    RadiusSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    RadiusSlider.BorderSizePixel = 0
    RadiusSlider.Parent = SettingsWindow
    
    local RadiusSliderCorner = Instance.new("UICorner")
    RadiusSliderCorner.CornerRadius = UDim.new(0, 3)
    RadiusSliderCorner.Parent = RadiusSlider
    
    local RadiusFill = Instance.new("Frame")
    RadiusFill.Size = UDim2.new(Config.SpinRadius / 20, 0, 1, 0)
    RadiusFill.BackgroundColor3 = Color3.fromRGB(255, 150, 200)
    RadiusFill.BorderSizePixel = 0
    RadiusFill.Parent = RadiusSlider
    
    local RadiusFillCorner = Instance.new("UICorner")
    RadiusFillCorner.CornerRadius = UDim.new(0, 3)
    RadiusFillCorner.Parent = RadiusFill
    
    local RadiusBtn = Instance.new("TextButton")
    RadiusBtn.Size = UDim2.new(1, 0, 1, 0)
    RadiusBtn.BackgroundTransparency = 1
    RadiusBtn.Text = ""
    RadiusBtn.Parent = RadiusSlider
    
    local radiusDragging = false
    RadiusBtn.MouseButton1Down:Connect(function()
        radiusDragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            radiusDragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if radiusDragging then
            local mouse = UserInputService:GetMouseLocation()
            local relativePos = (mouse.X - RadiusSlider.AbsolutePosition.X) / RadiusSlider.AbsoluteSize.X
            relativePos = math.clamp(relativePos, 0, 1)
            
            Config.SpinRadius = math.floor(relativePos * 20) + 1
            RadiusFill.Size = UDim2.new(relativePos, 0, 1, 0)
            RadiusLabel.Text = "转圈半径: " .. Config.SpinRadius
        end
    end)
    
    -- 速度设置
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(0.4, 0, 0, 25)
    SpeedLabel.Position = UDim2.new(0, 10, 0, 85)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.Text = "转圈速度: " .. Config.SpinSpeed
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.TextSize = 11
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = SettingsWindow
    
    local SpeedSlider2 = Instance.new("Frame")
    SpeedSlider2.Size = UDim2.new(0.5, 0, 0, 6)
    SpeedSlider2.Position = UDim2.new(0.45, 0, 0, 95)
    SpeedSlider2.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SpeedSlider2.BorderSizePixel = 0
    SpeedSlider2.Parent = SettingsWindow
    
    local SpeedSlider2Corner = Instance.new("UICorner")
    SpeedSlider2Corner.CornerRadius = UDim.new(0, 3)
    SpeedSlider2Corner.Parent = SpeedSlider2
    
    local SpeedFill = Instance.new("Frame")
    SpeedFill.Size = UDim2.new(Config.SpinSpeed / 10, 0, 1, 0)
    SpeedFill.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
    SpeedFill.BorderSizePixel = 0
    SpeedFill.Parent = SpeedSlider2
    
    local SpeedFillCorner = Instance.new("UICorner")
    SpeedFillCorner.CornerRadius = UDim.new(0, 3)
    SpeedFillCorner.Parent = SpeedFill
    
    local SpeedBtn2 = Instance.new("TextButton")
    SpeedBtn2.Size = UDim2.new(1, 0, 1, 0)
    SpeedBtn2.BackgroundTransparency = 1
    SpeedBtn2.Text = ""
    SpeedBtn2.Parent = SpeedSlider2
    
    local speedDragging = false
    SpeedBtn2.MouseButton1Down:Connect(function()
        speedDragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            speedDragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if speedDragging then
            local mouse = UserInputService:GetMouseLocation()
            local relativePos = (mouse.X - SpeedSlider2.AbsolutePosition.X) / SpeedSlider2.AbsoluteSize.X
            relativePos = math.clamp(relativePos, 0, 1)
            
            Config.SpinSpeed = math.floor(relativePos * 10 * 10) / 10 + 0.1
            SpeedFill.Size = UDim2.new(relativePos, 0, 1, 0)
            SpeedLabel.Text = "转圈速度: " .. string.format("%.1f", Config.SpinSpeed)
        end
    end)
    
    SettingsBtn.MouseButton1Click:Connect(function()
        SettingsWindow.Visible = not SettingsWindow.Visible
    end)
    
    -- 定期更新玩家列表
    spawn(function()
        while ScreenGui.Parent do
            wait(5)
            if PlayerList.Visible then
                UpdatePlayerList()
            end
        end
    end)
    
    print("✅ UI已创建")
end

-- ==================== 初始化 ====================
task.spawn(function()
    task.wait(1)
    CreateUI()
    Notify("🚀 飞行控制器", "已加载完成", 3)
end)

print("═══════════════════════════════════════════════")
print("✅ 终极飞行控制器已加载")
print("═══════════════════════════════════════════════")
print("功能特性:")
print("  ✈️ 4种飞行模式（标准/快速/隐蔽/脉冲）")
print("  🚫 穿墙功能")
print("  🌀 娱乐转圈功能")
print("  🎮 完整UI控制")
print("")
print("快捷键:")
print("  F - 开启/关闭飞行")
print("  R - 返回保存位置")
print("  WASD - 方向控制")
print("  Space - 上升")
print("  Shift - 下降")
print("  Ctrl+点击 - 瞬移")
print("")
print("娱乐功能:")
print("  🌀 选择玩家并开始转圈圈")
print("  ⚙️ 可调节转圈半径和速度")
print("═══════════════════════════════════════════════")

