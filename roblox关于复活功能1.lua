local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔥 复活功能脚本",
   LoadingTitle = "复活功能系统",
   LoadingSubtitle = "by 1_F0",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "复活功能"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local respawnService = {
    autoRespawn = false,
    followPlayer = nil,
    following = false,
    teleporting = false,
    followSpeed = 500, -- 增加默认速度
    followDistance = 0.5, -- 减少默认距离，更贴近
    followHeight = 1.5,
    followPosition = 180,
    savedPositions = {},
    followConnection = nil,
    teleportConnection = nil,
    lastPosition = Vector3.new(0, 0, 0)
}

-- 玩家列表管理
local playerList = {}
local selectedPlayer = nil

-- 更新玩家列表
local function UpdatePlayerList()
    playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
end

-- 初始化玩家列表
UpdatePlayerList()

-- 玩家加入/离开时自动更新
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        wait(0.5)
        UpdatePlayerList()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if respawnService.followPlayer == player.Name then
        if respawnService.following then
            respawnService.following = false
            if respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
            Rayfield:Notify({
                Title = "追踪停止",
                Content = "目标玩家已离开游戏",
                Duration = 3,
            })
        end
        if respawnService.teleporting then
            respawnService.teleporting = false
            if respawnService.teleportConnection then
                respawnService.teleportConnection:Disconnect()
                respawnService.teleportConnection = nil
            end
            Rayfield:Notify({
                Title = "传送停止",
                Content = "目标玩家已离开游戏",
                Duration = 3,
            })
        end
        respawnService.followPlayer = nil
        selectedPlayer = nil
    end
    UpdatePlayerList()
end)

-- 计算追踪位置
local function CalculateFollowPosition(targetRoot, distance, angle, height)
    local angleRad = math.rad(angle)
    local offset = Vector3.new(
        math.sin(angleRad) * distance,
        height,
        math.cos(angleRad) * distance
    )
    return targetRoot.Position + (targetRoot.CFrame:VectorToWorldSpace(offset))
end

-- 原地复活系统初始化
local function SetupRespawnSystem()
    respawnService.savedPositions = {}
    
    local function SetupPlayer(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            
            if respawnService.savedPositions[player] then
                wait(0.1) 
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = CFrame.new(respawnService.savedPositions[player])
                end
            end
            
            humanoid.Died:Connect(function()
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    respawnService.savedPositions[player] = rootPart.Position
                end
                
                if respawnService.autoRespawn then
                    wait(2)
                    player:LoadCharacter()
                end
            end)
        end)
        
        if player.Character then
            local humanoid = player.Character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    respawnService.savedPositions[player] = rootPart.Position
                end
                
                if respawnService.autoRespawn then
                    wait(2)
                    player:LoadCharacter()
                end
            end)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        SetupPlayer(player)
    end

    Players.PlayerAdded:Connect(SetupPlayer)
end

SetupRespawnSystem()

local MainTab = Window:CreateTab("🏠 复活功能", nil)
local MainSection = MainTab:CreateSection("复活系统")

local Button = MainTab:CreateButton({
   Name = "立即自杀",
   Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})

local Button = MainTab:CreateButton({
   Name = "原地复活",
   Callback = function()
        if LocalPlayer.Character then
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                respawnService.savedPositions[LocalPlayer] = rootPart.Position
            end
        end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})

local Toggle = MainTab:CreateToggle({
   Name = "自动复活",
   CurrentValue = false,
   Flag = "AutoRespawnToggle",
   Callback = function(Value)
        respawnService.autoRespawn = Value
   end,
})

-- 创建玩家选择按钮列表
local PlayerSelectionSection = MainTab:CreateSection("选择玩家")

-- 刷新玩家列表函数
local function RefreshPlayerButtons()
    UpdatePlayerList()
    
    -- 清除旧的按钮（如果有）
    if MainTab then
        for _, playerName in ipairs(playerList) do
            local buttonName = "选择: " .. playerName
            if MainTab[buttonName] then
                MainTab[buttonName]:Destroy()
            end
        end
    end
    
    -- 创建新的玩家选择按钮
    for _, playerName in ipairs(playerList) do
        local playerButton = MainTab:CreateButton({
            Name = "选择: " .. playerName,
            Callback = function()
                local targetPlayer = Players:FindFirstChild(playerName)
                if targetPlayer then
                    selectedPlayer = playerName
                    respawnService.followPlayer = playerName
                    Rayfield:Notify({
                        Title = "玩家选择成功",
                        Content = "已选择玩家: " .. targetPlayer.Name .. " (" .. (targetPlayer.DisplayName or targetPlayer.Name) .. ")",
                        Duration = 3,
                    })
                else
                    Rayfield:Notify({
                        Title = "错误",
                        Content = "玩家不存在: " .. playerName,
                        Duration = 3,
                    })
                end
            end,
        })
    end
end

-- 初始创建玩家按钮
RefreshPlayerButtons()

-- 添加刷新玩家列表按钮
local RefreshButton = MainTab:CreateButton({
   Name = "刷新玩家列表",
   Callback = function()
        RefreshPlayerButtons()
        Rayfield:Notify({
            Title = "刷新完成",
            Content = "玩家列表已更新",
            Duration = 2,
        })
   end,
})

-- 显示当前选择的玩家
local CurrentPlayerLabel = MainTab:CreateLabel("当前选择: " .. (selectedPlayer or "无"))

-- 修复平滑追踪功能
local FollowToggle = MainTab:CreateToggle({
   Name = "平滑追踪",
   CurrentValue = false,
   Flag = "FollowToggle",
   Callback = function(Value)
        respawnService.following = Value
        
        -- 停止传送功能
        if respawnService.teleporting then
            respawnService.teleporting = false
            if respawnService.teleportConnection then
                respawnService.teleportConnection:Disconnect()
                respawnService.teleportConnection = nil
            end
        end
        
        if respawnService.followConnection then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
        end
        
        if respawnService.following then
            if not respawnService.followPlayer then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先选择玩家",
                    Duration = 3,
                })
                return
            end
            
            local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
            if not targetPlayer then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "玩家不存在或已离开: " .. respawnService.followPlayer,
                    Duration = 3,
                })
                respawnService.followPlayer = nil
                selectedPlayer = nil
                CurrentPlayerLabel:Set("当前选择: 无")
                return
            end
            
            respawnService.followConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.following then return end
                if not respawnService.followPlayer then return end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not targetPlayer then
                    respawnService.following = false
                    return
                end
                
                local targetChar = targetPlayer.Character
                local localChar = LocalPlayer.Character
                if not targetChar or not localChar then return end
                
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                local localHumanoid = localChar:FindFirstChild("Humanoid")
                
                if targetRoot and localRoot and localHumanoid then
                    local targetPosition = CalculateFollowPosition(
                        targetRoot, 
                        respawnService.followDistance, 
                        respawnService.followPosition, 
                        respawnService.followHeight
                    )
                    
                    local currentPosition = localRoot.Position
                    local direction = (targetPosition - currentPosition).Unit
                    local distance = (targetPosition - currentPosition).Magnitude
                    
                    -- 使用极高的速度确保即使目标快速移动也能跟上
                    local actualSpeed = math.min(respawnService.followSpeed * 5, distance * 50) -- 大幅增加速度系数
                    
                    if distance > 0.1 then -- 减少停止距离，更贴近
                        localRoot.Velocity = direction * actualSpeed
                    else
                        localRoot.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
            
            Rayfield:Notify({
                Title = "追踪状态",
                Content = "已开始平滑追踪: " .. targetPlayer.Name,
                Duration = 3,
            })
        else
            if respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
            Rayfield:Notify({
                Title = "追踪状态",
                Content = "已停止追踪",
                Duration = 3,
            })
        end
   end,
})

-- 直接传送Toggle
local TeleportToggle = MainTab:CreateToggle({
   Name = "直接传送",
   CurrentValue = false,
   Flag = "TeleportToggle",
   Callback = function(Value)
        respawnService.teleporting = Value
        
        -- 停止追踪功能
        if respawnService.following then
            respawnService.following = false
            if respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
        end
        
        if respawnService.teleportConnection then
            respawnService.teleportConnection:Disconnect()
            respawnService.teleportConnection = nil
        end
        
        if respawnService.teleporting then
            if not respawnService.followPlayer then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先选择玩家",
                    Duration = 3,
                })
                return
            end
            
            local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
            if not targetPlayer or not targetPlayer.Character then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "玩家不存在或已离开: " .. respawnService.followPlayer,
                    Duration = 3,
                })
                respawnService.followPlayer = nil
                selectedPlayer = nil
                CurrentPlayerLabel:Set("当前选择: 无")
                return
            end
            
            respawnService.teleportConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.teleporting then return end
                if not respawnService.followPlayer then return end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not targetPlayer then
                    respawnService.teleporting = false
                    return
                end
                
                local targetChar = targetPlayer.Character
                local localChar = LocalPlayer.Character
                if not targetChar or not localChar then return end
                
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                
                if targetRoot and localRoot then
                    local targetPosition = CalculateFollowPosition(
                        targetRoot, 
                        respawnService.followDistance, 
                        respawnService.followPosition, 
                        respawnService.followHeight
                    )
                    
                    localRoot.CFrame = CFrame.new(targetPosition, targetRoot.Position)
                end
            end)
            
            Rayfield:Notify({
                Title = "传送状态",
                Content = "已开始传送: " .. targetPlayer.Name,
                Duration = 3,
            })
        else
            if respawnService.teleportConnection then
                respawnService.teleportConnection:Disconnect()
                respawnService.teleportConnection = nil
            end
            Rayfield:Notify({
                Title = "传送状态",
                Content = "已停止传送",
                Duration = 3,
            })
        end
   end,
})

local SettingsSection = MainTab:CreateSection("追踪设置")

local Slider = MainTab:CreateSlider({
   Name = "追踪速度",
   Range = {100, 2000}, -- 增加最大速度范围
   Increment = 50,
   Suffix = "速度",
   CurrentValue = 500, -- 设置默认值为500
   Flag = "FollowSpeedSlider",
   Callback = function(Value)
        respawnService.followSpeed = Value
        Rayfield:Notify({
            Title = "设置更新",
            Content = "追踪速度设置为: " .. Value,
            Duration = 2,
        })
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "追踪距离",
   Range = {0.1, 10}, -- 允许更小的距离
   Increment = 0.1,
   Suffix = "距离",
   CurrentValue = 3, -- 设置默认值为0.5
   Flag = "FollowDistanceSlider",
   Callback = function(Value)
        respawnService.followDistance = Value
        Rayfield:Notify({
            Title = "设置更新",
            Content = "追踪距离设置为: " .. Value,
            Duration = 2,
        })
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "追踪位置",
   Range = {0, 360},
   Increment = 5,
   Suffix = "度 (0=前,90=右,180=后,270=左)",
   CurrentValue = 360,
   Flag = "FollowPositionSlider",
   Callback = function(Value)
        respawnService.followPosition = Value
        local positionText = ""
        if Value == 0 then positionText = "前方"
        elseif Value == 90 then positionText = "右侧"
        elseif Value == 180 then positionText = "后方"
        elseif Value == 270 then positionText = "左侧"
        else positionText = Value .. "度" end
        
        Rayfield:Notify({
            Title = "位置设置",
            Content = "追踪位置: " .. positionText,
            Duration = 2,
        })
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "追踪高度",
   Range = {-5, 10},
   Increment = 0.5,
   Suffix = "高度",
   CurrentValue = 3,
   Flag = "FollowHeightSlider",
   Callback = function(Value)
        respawnService.followHeight = Value
        Rayfield:Notify({
            Title = "高度设置",
            Content = "追踪高度设置为: " .. Value,
            Duration = 2,
        })
   end,
})

local KeybindSection = MainTab:CreateSection("快捷键")

local Keybind = MainTab:CreateKeybind({
    Name = "快速复活快捷键",
    CurrentKeybind = "R",
    HoldToInteract = false,
    Flag = "RespawnKeybind",
    Callback = function(Keybind)
        if LocalPlayer.Character then
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                respawnService.savedPositions[LocalPlayer] = rootPart.Position
            end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end,
})

local Keybind = MainTab:CreateKeybind({
    Name = "切换追踪快捷键",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "ToggleFollowKeybind",
    Callback = function(Keybind)
        if respawnService.followPlayer then
            respawnService.following = not respawnService.following
            FollowToggle:Set(respawnService.following)
        else
            Rayfield:Notify({
                Title = "错误",
                Content = "请先选择有效的玩家",
                Duration = 3,
            })
        end
    end,
})

local Keybind = MainTab:CreateKeybind({
    Name = "切换传送快捷键",
    CurrentKeybind = "G",
    HoldToInteract = false,
    Flag = "ToggleTeleportKeybind",
    Callback = function(Keybind)
        if respawnService.followPlayer then
            respawnService.teleporting = not respawnService.teleporting
            TeleportToggle:Set(respawnService.teleporting)
        else
            Rayfield:Notify({
                Title = "错误",
                Content = "请先选择有效的玩家",
                Duration = 3,
            })
        end
    end,
})

-- 初始通知
Rayfield:Notify({
   Title = "脚本加载成功",
   Content = "复活功能脚本已就绪\n请先点击玩家名字选择目标，再使用追踪或传送功能\n追踪速度已大幅提升，可以跟上快速移动的目标",
   Duration = 5,
})