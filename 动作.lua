local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 之前的代码保持不变...

-- 创建敬礼功能部分
local SaluteTab = Window:CreateTab("🎖️ 敬礼动作", 4483362458)

local SaluteSection = SaluteTab:CreateSection("敬礼动作设置")

-- 敬礼动作服务
local saluteService = {
    isSaluting = false,
    saluteAnimation = nil,
    saluteTrack = nil
}

-- 创建敬礼动画函数
local function CreateSaluteAnimation()
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://188881735" -- 标准的敬礼动画ID
    return animation
end

-- 开始敬礼
local function StartSalute()
    if saluteService.isSaluting then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- 停止所有现有动画
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    
    -- 创建并播放敬礼动画
    if not saluteService.saluteAnimation then
        saluteService.saluteAnimation = CreateSaluteAnimation()
    end
    
    saluteService.saluteTrack = humanoid:LoadAnimation(saluteService.saluteAnimation)
    saluteService.saluteTrack:Play()
    saluteService.saluteTrack:AdjustSpeed(1.0)
    
    saluteService.isSaluting = true
end

-- 停止敬礼
local function StopSalute()
    if not saluteService.isSaluting then return end
    
    if saluteService.saluteTrack then
        saluteService.saluteTrack:Stop()
        saluteService.saluteTrack = nil
    end
    
    saluteService.isSaluting = false
end

-- 敬礼按钮
local Button = SaluteTab:CreateButton({
    Name = "执行敬礼动作",
    Callback = function()
        if saluteService.isSaluting then
            StopSalute()
            Rayfield:Notify({
                Title = "敬礼结束",
                Content = "敬礼动作已停止",
                Duration = 2,
            })
        else
            StartSalute()
            Rayfield:Notify({
                Title = "敬礼开始",
                Content = "角色正在敬礼",
                Duration = 2,
            })
        end
    end,
})

-- 自动敬礼选项
local Toggle = SaluteTab:CreateToggle({
    Name = "自动敬礼（复活时）",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            Rayfield:Notify({
                Title = "自动敬礼已启用",
                Content = "角色复活时将自动敬礼",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "自动敬礼已禁用",
                Content = "关闭了自动敬礼功能",
                Duration = 3,
            })
        end
    end,
})

-- 敬礼持续时间设置
local Input = SaluteTab:CreateInput({
    Name = "敬礼持续时间（秒）",
    PlaceholderText = "输入敬礼持续时间（0=持续）",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local duration = tonumber(Text)
        if duration and duration >= 0 then
            Rayfield:Notify({
                Title = "持续时间设置",
                Content = "敬礼持续时间设置为: " .. duration .. " 秒",
                Duration = 2,
            })
        else
            Rayfield:Notify({
                Title = "输入错误",
                Content = "请输入有效的数字",
                Duration = 2,
            })
        end
    end,
})

-- 敬礼快捷键
local Keybind = SaluteTab:CreateKeybind({
    Name = "敬礼快捷键",
    CurrentKeybind = "T",
    HoldToInteract = false,
    Callback = function(Keybind)
        if saluteService.isSaluting then
            StopSalute()
            Rayfield:Notify({
                Title = "敬礼结束",
                Content = "已停止敬礼",
                Duration = 2,
            })
        else
            StartSalute()
            Rayfield:Notify({
                Title = "敬礼开始",
                Content = "开始敬礼",
                Duration = 2,
            })
        end
    end,
})

-- 高级敬礼选项
local Section = SaluteTab:CreateSection("高级选项")

-- 敬礼样式选择
local Dropdown = SaluteTab:CreateDropdown({
    Name = "敬礼样式",
    Options = {"标准军礼", "美式军礼", "英式军礼", "法式军礼"},
    CurrentOption = "标准军礼",
    Callback = function(Option)
        Rayfield:Notify({
            Title = "敬礼样式更改",
            Content = "已选择: " .. Option,
            Duration = 2,
        })
    end,
})

-- 敬礼速度调整
local Slider = SaluteTab:CreateSlider({
    Name = "敬礼速度",
    Range = {0.5, 2.0},
    Increment = 0.1,
    Suffix = "倍速",
    CurrentValue = 1.0,
    Callback = function(Value)
        if saluteService.saluteTrack then
            saluteService.saluteTrack:AdjustSpeed(Value)
        end
        Rayfield:Notify({
            Title = "速度调整",
            Content = "敬礼速度设置为: " .. Value .. " 倍",
            Duration = 2,
        })
    end,
})

-- 敬礼说明部分
local Section = SaluteTab:CreateSection("使用说明")

local Label = SaluteTab:CreateLabel("• 点击「执行敬礼动作」或按T键开始敬礼")
local Label = SaluteTab:CreateLabel("• 再次点击或按T键停止敬礼")
local Label = SaluteTab:CreateLabel("• 其他玩家可以看到你的敬礼动作")
local Label = SaluteTab:CreateLabel("• 可以在设置中调整敬礼样式和速度")

-- 连接到角色变化事件
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- 等待角色完全加载
    if autoSaluteToggle and autoSaluteToggle.CurrentValue then
        StartSalute()
    end
end)

-- 在角色移除时清理
LocalPlayer.CharacterRemoving:Connect(function()
    StopSalute()
end)

-- 添加到主标签页的敬礼快捷按钮
local Button = MainTab:CreateButton({
    Name = "快速敬礼",
    Callback = function()
        if saluteService.isSaluting then
            StopSalute()
            Rayfield:Notify({
                Title = "敬礼结束",
                Content = "敬礼动作已停止",
                Duration = 2,
            })
        else
            StartSalute()
            Rayfield:Notify({
                Title = "敬礼开始",
                Content = "角色正在敬礼",
                Duration = 2,
            })
        end
    end,
})

Rayfield:Notify({
    Title = "敬礼功能已加载",
    Content = "使用T键或按钮来执行敬礼动作\n其他玩家可以看到你的敬礼姿势",
    Duration = 5,
})