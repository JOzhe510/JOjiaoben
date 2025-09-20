local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({
   Name = "🎖️ 动作脚本",
   LoadingTitle = "动作系统加载中",
   LoadingSubtitle = "by 开发者",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "动作功能"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

local Tab = Window:CreateTab("🎖️ 敬礼动作", 4483362458)
local MainSection = Tab:CreateSection("敬礼动作设置")

local saluteService = {
    isSaluting = false,
    saluteTrack = nil
}

-- 更可靠的敬礼动画函数
local function CreateSalutePose()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return nil end
    
    -- 检查是R6还是R15
    local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
    
    if isR15 then
        -- R15角色：使用Tween方法创建敬礼姿势
        return "R15"
    else
        -- R6角色：使用CFrame调整
        return "R6"
    end
end

-- R15敬礼姿势
local function ApplyR15Salute()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local rightArm = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    local head = character:FindFirstChild("Head")
    
    if not rightArm or not head then return false end
    
    -- 保存原始CFrame
    saluteService.originalCFrames = saluteService.originalCFrames or {}
    saluteService.originalCFrames[rightArm] = rightArm.CFrame
    
    -- 创建敬礼姿势：手举到额头旁边
    local saluteCFrame = head.CFrame * CFrame.new(0.5, 0, 0) * CFrame.Angles(0, 0, math.rad(90))
    rightArm.CFrame = saluteCFrame
    
    return true
end

-- R6敬礼姿势
local function ApplyR6Salute()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local rightArm = character:FindFirstChild("Right Arm")
    local torso = character:FindFirstChild("Torso")
    
    if not rightArm or not torso then return false end
    
    -- 保存原始CFrame
    saluteService.originalCFrames = saluteService.originalCFrames or {}
    saluteService.originalCFrames[rightArm] = rightArm.CFrame
    
    -- 创建敬礼姿势
    local saluteCFrame = torso.CFrame * CFrame.new(1.5, 0.5, 0) * CFrame.Angles(0, 0, math.rad(90))
    rightArm.CFrame = saluteCFrame
    
    return true
end

-- 开始敬礼
local function StartSalute()
    if saluteService.isSaluting then 
        Rayfield:Notify({
            Title = "提示",
            Content = "已经在敬礼中",
            Duration = 2,
        })
        return 
    end
    
    local character = LocalPlayer.Character
    if not character then
        Rayfield:Notify({
            Title = "错误",
            Content = "角色不存在",
            Duration = 2,
        })
        return 
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        Rayfield:Notify({
            Title = "错误",
            Content = "找不到Humanoid",
            Duration = 2,
        })
        return 
    end
    
    if not character:FindFirstChild("HumanoidRootPart") then
        Rayfield:Notify({
            Title = "错误",
            Content = "角色尚未完全加载",
            Duration = 2,
        })
        return
    end
    
    -- 检测角色类型并应用相应的敬礼姿势
    local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
    local success = false
    
    if isR15 then
        success = ApplyR15Salute()
        Rayfield:Notify({
            Title = "R15角色",
            Content = "使用R15敬礼姿势",
            Duration = 2,
        })
    else
        success = ApplyR6Salute()
        Rayfield:Notify({
            Title = "R6角色",
            Content = "使用R6敬礼姿势",
            Duration = 2,
        })
    end
    
    if success then
        saluteService.isSaluting = true
        Rayfield:Notify({
            Title = "敬礼开始",
            Content = "角色正在敬礼",
            Duration = 2,
        })
    else
        Rayfield:Notify({
            Title = "错误",
            Content = "无法应用敬礼姿势",
            Duration = 2,
        })
    end
end

-- 停止敬礼
local function StopSalute()
    if not saluteService.isSaluting then 
        Rayfield:Notify({
            Title = "提示",
            Content = "当前没有在敬礼",
            Duration = 2,
        })
        return 
    end
    
    -- 恢复原始姿势
    if saluteService.originalCFrames then
        for part, cframe in pairs(saluteService.originalCFrames) do
            if part and part.Parent then
                part.CFrame = cframe
            end
        end
        saluteService.originalCFrames = nil
    end
    
    saluteService.isSaluting = false
    
    Rayfield:Notify({
        Title = "敬礼结束",
        Content = "敬礼动作已停止",
        Duration = 2,
    })
end

-- 调试按钮：检查角色状态
local Button = Tab:CreateButton({
    Name = "调试：检查角色状态",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then
            Rayfield:Notify({
                Title = "调试信息",
                Content = "角色不存在",
                Duration = 3,
            })
            return
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        
        local rigType = humanoid and humanoid.RigType.Name or "未知"
        
        local message = string.format(
            "角色状态:\n类型: %s\nHumanoid: %s\nRootPart: %s\n右手: %s\nHealth: %s",
            rigType,
            tostring(humanoid ~= nil),
            tostring(rootPart ~= nil),
            tostring(rightArm ~= nil),
            humanoid and tostring(math.floor(humanoid.Health)) or "N/A"
        )
        
        Rayfield:Notify({
            Title = "调试信息",
            Content = message,
            Duration = 6,
        })
    end,
})

-- 敬礼按钮
local Button = Tab:CreateButton({
    Name = "执行敬礼动作",
    Callback = function()
        if saluteService.isSaluting then
            StopSalute()
        else
            StartSalute()
        end
    end,
})

-- 敬礼快捷键
local Keybind = Tab:CreateKeybind({
    Name = "敬礼快捷键",
    CurrentKeybind = "T",
    HoldToInteract = false,
    Callback = function()
        if saluteService.isSaluting then
            StopSalute()
        else
            StartSalute()
        end
    end,
})

-- 测试不同的姿势
local Button = Tab:CreateButton({
    Name = "测试简单挥手",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
        if not rightArm then return end
        
        -- 简单的挥手测试
        for i = 1, 3 do
            rightArm.CFrame = rightArm.CFrame * CFrame.Angles(0, math.rad(30), 0)
            wait(0.1)
            rightArm.CFrame = rightArm.CFrame * CFrame.Angles(0, math.rad(-30), 0)
            wait(0.1)
        end
    end,
})

local Section = Tab:CreateSection("使用说明")
local Label = Tab:CreateLabel("1. 先点击「调试」按钮检查角色状态")
local Label = Tab:CreateLabel("2. 确保角色完全加载后再使用敬礼")
local Label = Tab:CreateLabel("3. 按T键或点击按钮执行敬礼")
local Label = Tab:CreateLabel("4. 其他玩家可以看到你的姿势")

Rayfield:Notify({
    Title = "动作功能已加载",
    Content = "请先使用「调试」按钮检查角色状态",
    Duration = 6,
})