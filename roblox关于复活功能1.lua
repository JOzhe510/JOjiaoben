local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔥 复活功能脚本 | Roblox 🔫",
   LoadingTitle = "🔫 复活功能系统 💥",
   LoadingSubtitle = "by 1_F0",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "Respawn Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

-- 获取必要的服务
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 创建复活服务表
local respawnService = {
    autoRespawn = false,
    followPlayer = nil,
    following = false,
    followSpeed = 100,
    followDistance = 3,
    savedPositions = {},
    followConnection = nil
}

-- 获取玩家列表
local function updatePlayerList()
    local playerList = {"选择玩家"}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

local MainTab = Window:CreateTab("🏠 复活功能", nil)
local MainSection = MainTab:CreateSection("复活系统")

-- 立即自杀按钮
local SuicideBtn = MainTab:CreateButton({
   Name = "立即自杀",
   Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
   end,
})

-- 原地复活按钮
local RespawnBtn = MainTab:CreateButton({
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

-- 自动复活开关
local AutoRespawnToggle = MainTab:CreateToggle({
   Name = "自动复活",
   CurrentValue = false,
   Flag = "AutoRespawnToggle",
   Callback = function(Value)
        respawnService.autoRespawn = Value
   end,
})

-- 玩家选择下拉菜单
local playerDropdown = MainTab:CreateDropdown({
   Name = "选择玩家",
   Options = updatePlayerList(),
   CurrentOption = {"选择玩家"},
   MultipleOptions = false,
   Flag = "PlayerDropdown",
   Callback = function(Option)
        respawnService.followPlayer = Option
   end,
})

-- 平滑追踪按钮
local FollowBtn = MainTab:CreateButton({
   Name = "平滑追踪",
   Callback = function()
        if not respawnService.followPlayer or respawnService.followPlayer == "选择玩家" then
            Rayfield:Notify({
                Title = "错误",
                Content = "请先选择一个玩家",
                Duration = 3,
            })
            return
        end
        
        respawnService.following = not respawnService.following
        
        if respawnService.followConnection then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
        end
        
        if respawnService.following then
            respawnService.followConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.following or not respawnService.followPlayer then return end
                
                local followedPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not followedPlayer or not followedPlayer.Character then return end
                
                local followedRoot = followedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local localChar = LocalPlayer.Character
                local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
                local localHumanoid = localChar and localChar:FindFirstChild("Humanoid")
                
                if followedRoot and localRoot and localHumanoid then
                    local distance = (followedRoot.Position - localRoot.Position).Magnitude
                    
                    if distance > respawnService.followDistance then
                        local direction = (followedRoot.Position - localRoot.Position).Unit
                        local targetPosition = followedRoot.Position - (direction * respawnService.followDistance)
                        
                        localHumanoid:MoveTo(targetPosition)
                    else
                        localHumanoid:MoveTo(localRoot.Position)
                    end
                end
            end)
            
            Rayfield:Notify({
                Title = "追踪状态",
                Content = "已开始追踪: " .. respawnService.followPlayer,
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "追踪状态",
                Content = "已停止追踪",
                Duration = 3,
            })
        end
   end,
})

-- 直接传送按钮
local TeleportBtn = MainTab:CreateButton({
   Name = "直接传送",
   Callback = function()
        if not respawnService.followPlayer or respawnService.followPlayer == "选择玩家" then
            Rayfield:Notify({
                Title = "错误",
                Content = "请先选择一个玩家",
                Duration = 3,
            })
            return
        end
        
        local followedPlayer = Players:FindFirstChild(respawnService.followPlayer)
        if not followedPlayer or not followedPlayer.Character then
            Rayfield:Notify({
                Title = "错误",
                Content = "目标玩家不存在",
                Duration = 3,
            })
            return
        end
        
        local followedRoot = followedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        
        if followedRoot and localRoot then
            local direction = (followedRoot.Position - localRoot.Position).Unit
            local targetPosition = followedRoot.Position - (direction * respawnService.followDistance)
            
            localRoot.CFrame = CFrame.new(targetPosition, followedRoot.Position)
            
            Rayfield:Notify({
                Title = "传送成功",
                Content = "已传送到: " .. respawnService.followPlayer,
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "错误",
                Content = "传送失败，请检查角色状态",
                Duration = 3,
            })
        end
   end,
})

-- 设置区域
local SettingsSection = MainTab:CreateSection("设置")

-- 追踪速度滑块
local SpeedSlider = MainTab:CreateSlider({
   Name = "追踪速度",
   Range = {10, 200},
   Increment = 1,
   Suffix = "速度",
   CurrentValue = 100,
   Flag = "FollowSpeedSlider",
   Callback = function(Value)
        respawnService.followSpeed = Value
   end,
})

-- 追踪距离滑块
local DistanceSlider = MainTab:CreateSlider({
   Name = "追踪距离",
   Range = {1, 10},
   Increment = 1,
   Suffix = "距离",
   CurrentValue = 3,
   Flag = "FollowDistanceSlider",
   Callback = function(Value)
        respawnService.followDistance = Value
   end,
})

-- 快捷键区域
local KeybindSection = MainTab:CreateSection("快捷键")

-- 快速复活快捷键
local RespawnKeybind = MainTab:CreateKeybind({
    Name = "快速复活快捷键",
    CurrentKeybind = "R",
    HoldToInteract = false,
    Flag = "RespawnKeybind",
    Callback = function(Keybind)
        -- 快速复活功能
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

-- 快速传送快捷键
local TeleportKeybind = MainTab:CreateKeybind({
    Name = "快速传送快捷键",
    CurrentKeybind = "T",
    HoldToInteract = false,
    Flag = "TeleportKeybind",
    Callback = function(Keybind)
        -- 快速传送功能
        if respawnService.followPlayer and respawnService.followPlayer ~= "选择玩家" then
            local followedPlayer = Players:FindFirstChild(respawnService.followPlayer)
            if followedPlayer and followedPlayer.Character then
                local followedRoot = followedPlayer.Character:FindFirstChild("HumanoidRootPart")
                local localChar = LocalPlayer.Character
                local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
                
                if followedRoot and localRoot then
                    local direction = (followedRoot.Position - localRoot.Position).Unit
                    local targetPosition = followedRoot.Position - (direction * respawnService.followDistance)
                    
                    localRoot.CFrame = CFrame.new(targetPosition, followedRoot.Position)
                    
                    Rayfield:Notify({
                        Title = "传送成功",
                        Content = "已传送到: " .. respawnService.followPlayer,
                        Duration = 3,
                    })
                end
            end
        end
    end,
})

-- 切换追踪快捷键
local ToggleFollowKeybind = MainTab:CreateKeybind({
    Name = "切换追踪快捷键",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "ToggleFollowKeybind",
    Callback = function(Keybind)
        -- 切换追踪功能
        if respawnService.followPlayer and respawnService.followPlayer ~= "选择玩家" then
            respawnService.following = not respawnService.following
            
            if respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
            
            if respawnService.following then
                respawnService.followConnection = RunService.Heartbeat:Connect(function()
                    if not respawnService.following or not respawnService.followPlayer then return end
                    
                    local followedPlayer = Players:FindFirstChild(respawnService.followPlayer)
                    if not followedPlayer or not followedPlayer.Character then return end
                    
                    local followedRoot = followedPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local localChar = LocalPlayer.Character
                    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
                    local localHumanoid = localChar and localChar:FindFirstChild("Humanoid")
                    
                    if followedRoot and localRoot and localHumanoid then
                        local distance = (followedRoot.Position - localRoot.Position).Magnitude
                        
                        if distance > respawnService.followDistance then
                            local direction = (followedRoot.Position - localRoot.Position).Unit
                            local targetPosition = followedRoot.Position - (direction * respawnService.followDistance)
                            
                            localHumanoid:MoveTo(targetPosition)
                        else
                            localHumanoid:MoveTo(localRoot.Position)
                        end
                    end
                end)
                
                Rayfield:Notify({
                    Title = "追踪状态",
                    Content = "已开始追踪: " .. respawnService.followPlayer,
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "追踪状态",
                    Content = "已停止追踪",
                    Duration = 3,
                })
            end
        end
    end,
})

-- 玩家列表更新
Players.PlayerAdded:Connect(function()
    playerDropdown:SetOptions(updatePlayerList())
end)

Players.PlayerRemoving:Connect(function()
    playerDropdown:SetOptions(updatePlayerList())
end)

-- 初始通知
Rayfield:Notify({
   Title = "脚本加载成功",
   Content = "复活功能脚本已就绪",
   Duration = 5,
})