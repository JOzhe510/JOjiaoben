local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 必须先创建主窗口
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

-- 创建敬礼功能部分
local Tab = Window:CreateTab("🎖️ 敬礼动作", 4483362458)

local MainSection = Tab:CreateSection("敬礼动作设置")  -- 修正变量名

-- 敬礼动作服务
local saluteService = {
    isSaluting = false,
    saluteAnimation = nil,
    saluteTrack = nil
}

-- 测试多个可能的敬礼动画ID
local saluteAnimations = {
    "rbxassetid://188881735",  -- 标准敬礼
    "rbxassetid://313762630",  -- 敬礼动画2
    "rbxassetid://5915788520", -- 现代敬礼
    "rbxassetid://5915719362", -- 军事敬礼
    "rbxassetid://5915688522"  -- 正式敬礼
}

-- 创建敬礼动画函数
local function CreateSaluteAnimation()
    -- 尝试加载不同的动画，直到找到有效的
    for _, animId in ipairs(saluteAnimations) do
        local success, animation = pcall(function()
            local anim = Instance.new("Animation")
            anim.AnimationId = animId
            return anim
        end)
        
        if success and animation then
            Rayfield:Notify({
                Title = "动画加载成功",
                Content = "使用动画ID: " .. animId,
                Duration = 3,
            })
            return animation
        end
    end
    
    -- 如果所有预设动画都失败，创建一个简单的自定义动画
    Rayfield:Notify({
        Title = "警告",
        Content = "使用备用敬礼动画",
        Duration = 3,
    })
    
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://188881735" -- 默认
    return animation
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
    
    -- 确保角色已经加载完成
    if not character:FindFirstChild("HumanoidRootPart") then
        Rayfield:Notify({
            Title = "错误",
            Content = "角色尚未完全加载",
            Duration = 2,
        })
        return
    end
    
    -- 停止所有现有动画
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    
    -- 创建并播放敬礼动画
    if not saluteService.saluteAnimation then
        saluteService.saluteAnimation = CreateSaluteAnimation()
    end
    
    local success, track = pcall(function()
        return humanoid:LoadAnimation(saluteService.saluteAnimation)
    end)
    
    if not success or not track then
        Rayfield:Notify({
            Title = "错误",
            Content = "动画加载失败",
            Duration = 3,
        })
        return
    end
    
    saluteService.saluteTrack = track
    saluteService.saluteTrack:Play()
    saluteService.saluteTrack:AdjustSpeed(1.0)
    
    saluteService.isSaluting = true
    
    Rayfield:Notify({
        Title = "敬礼开始",
        Content = "角色正在敬礼",
        Duration = 2,
    })
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
    
    if saluteService.saluteTrack then
        pcall(function()
            saluteService.saluteTrack:Stop()
        end)
        saluteService.saluteTrack = nil
    end
    
    saluteService.isSaluting = false
    
    Rayfield:Notify({
        Title = "敬礼结束",
        Content = "敬礼动作已停止",
        Duration = 2,
    })
end

-- 敬礼按钮
local Button = Tab:CreateButton({  -- 修正为 Tab
    Name = "执行敬礼动作",
    Callback = function()
        if saluteService.isSaluting then
            StopSalute()
        else
            StartSalute()
        end
    end,
})

-- 调试按钮：检查角色状态
local Button = Tab:CreateButton({  -- 修正为 Tab
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
        
        local message = string.format(
            "角色状态:\nHumanoid: %s\nHumanoidRootPart: %s\nHealth: %s",
            tostring(humanoid ~= nil),
            tostring(rootPart ~= nil),
            humanoid and tostring(humanoid.Health) or "N/A"
        )
        
        Rayfield:Notify({
            Title = "调试信息",
            Content = message,
            Duration = 5,
        })
    end,
})

-- 敬礼快捷键
local Keybind = Tab:CreateKeybind({  -- 修正为 Tab
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

-- 测试不同的动画
local Button = Tab:CreateButton({  -- 修正为 Tab
    Name = "测试不同动画",
    Callback = function()
        saluteService.saluteAnimation = nil -- 重置动画
        saluteService.isSaluting = false
        
        Rayfield:Notify({
            Title = "动画重置",
            Content = "将尝试使用不同的动画ID",
            Duration = 3,
        })
    end,
})

-- 使用说明
local Section = Tab:CreateSection("故障排除")  -- 修正为 Tab
local Label = Tab:CreateLabel("如果敬礼不工作，请尝试：")  -- 修正为 Tab
local Label = Tab:CreateLabel("1. 点击「调试：检查角色状态」")  -- 修正为 Tab
local Label = Tab:CreateLabel("2. 点击「测试不同动画」")  -- 修正为 Tab
local Label = Tab:CreateLabel("3. 确保角色已完全加载")  -- 修正为 Tab

Rayfield:Notify({
    Title = "敬礼功能已加载",
    Content = "点击「调试：检查角色状态」来诊断问题",
    Duration = 6,
})