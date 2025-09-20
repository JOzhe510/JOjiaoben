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
    followSpeed = 100,
    followDistance = 3,
    savedPositions = {},
    followConnection = nil,
    teleportConnection = nil
}

-- 查找玩家函数（支持部分匹配）
local function FindPlayerByName(name)
    if not name or name == "" then return nil end
    
    name = name:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local displayName = player.DisplayName:lower()
            local userName = player.Name:lower()
            
            if userName:find(name) or displayName:find(name) then
                return player
            end
        end
    end
    return nil
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

-- 输入玩家名字（支持部分匹配）
local PlayerInput = MainTab:CreateInput({
   Name = "输入玩家名字",
   PlaceholderText = "输入用户名或显示名（支持部分匹配）",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        if Text and Text ~= "" then
            local targetPlayer = FindPlayerByName(Text)
            if targetPlayer then
                respawnService.followPlayer = targetPlayer.Name
                Rayfield:Notify({
                    Title = "玩家设置成功",
                    Content = "已设置目标玩家: " .. targetPlayer.Name .. " (" .. targetPlayer.DisplayName .. ")",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "错误",
                    Content = "找不到玩家: " .. Text,
                    Duration = 3,
                })
            end
        end
   end,
})

-- 修复追踪功能（使用速度参数）
local FollowToggle = MainTab:CreateToggle({
   Name = "追踪玩家",
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
            TeleportToggle:Set(false)
        end
        
        if respawnService.followConnection then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
        end
        
        if respawnService.following then
            if not respawnService.followPlayer then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先输入玩家名字",
                    Duration = 3,
                })
                FollowToggle:Set(false)
                return
            end
            
            local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
            if not targetPlayer then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "玩家不存在: " .. respawnService.followPlayer,
                    Duration = 3,
                })
                FollowToggle:Set(false)
                return
            end
            
            respawnService.followConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.following then return end
                
                local targetChar = targetPlayer.Character
                local localChar = LocalPlayer.Character
                if not targetChar or not localChar then return end
                
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                local localHumanoid = localChar:FindFirstChild("Humanoid")
                
                if targetRoot and localRoot and localHumanoid then
                    -- 计算目标位置（玩家后方）
                    local targetCFrame = targetRoot.CFrame
                    local behindOffset = targetCFrame.LookVector * -respawnService.followDistance
                    local targetPosition = targetRoot.Position + behindOffset + Vector3.new(0, 1.5, 0)
                    
                    -- 使用速度参数移动
                    local direction = (targetPosition - localRoot.Position).Unit
                    localRoot.Velocity = direction * respawnService.followSpeed
                end
            end)
            
            Rayfield:Notify({
                Title = "追踪状态",
                Content = "已开始追踪: " .. targetPlayer.Name,
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

-- 直接传送Toggle（传送到玩家后方）
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
            FollowToggle:Set(false)
        end
        
        if respawnService.teleportConnection then
            respawnService.teleportConnection:Disconnect()
            respawnService.teleportConnection = nil
        end
        
        if respawnService.teleporting then
            if not respawnService.followPlayer then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先输入玩家名字",
                    Duration = 3,
                })
                TeleportToggle:Set(false)
                return
            end
            
            local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
            if not targetPlayer or not targetPlayer.Character then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "玩家不存在: " .. respawnService.followPlayer,
                    Duration = 3,
                })
                TeleportToggle:Set(false)
                return
            end
            
            respawnService.teleportConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.teleporting then return end
                
                local targetChar = targetPlayer.Character
                local localChar = LocalPlayer.Character
                if not targetChar or not localChar then return end
                
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                
                if targetRoot and localRoot then
                    -- 传送到玩家后方
                    local targetCFrame = targetRoot.CFrame
                    local behindOffset = targetCFrame.LookVector * -respawnService.followDistance
                    local targetPosition = targetRoot.Position + behindOffset + Vector3.new(0, 1.5, 0)
                    
                    localRoot.CFrame = CFrame.new(targetPosition, targetRoot.Position)
                end
            end)
            
            Rayfield:Notify({
                Title = "传送状态",
                Content = "已开始传送: " .. targetPlayer.Name,
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "传送状态",
                Content = "已停止传送",
                Duration = 3,
            })
        end
   end,
})

local SettingsSection = MainTab:CreateSection("设置")

local Slider = MainTab:CreateSlider({
   Name = "追踪速度",
   Range = {10, 500},
   Increment = 10,
   Suffix = "速度",
   CurrentValue = 100,
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
   Range = {1, 20},
   Increment = 1,
   Suffix = "距离",
   CurrentValue = 3,
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
                Content = "请先输入玩家名字",
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
                Content = "请先输入玩家名字",
                Duration = 3,
            })
        end
    end,
})

-- 玩家离开时自动停止功能
Players.PlayerRemoving:Connect(function(player)
    if respawnService.followPlayer == player.Name then
        if respawnService.following then
            respawnService.following = false
            if respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
            FollowToggle:Set(false)
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
            TeleportToggle:Set(false)
            Rayfield:Notify({
                Title = "传送停止",
                Content = "目标玩家已离开游戏",
                Duration = 3,
            })
        end
    end
end)

-- 初始通知
Rayfield:Notify({
   Title = "脚本加载成功",
   Content = "复活功能脚本已就绪\n输入玩家用户名或显示名即可开始追踪",
   Duration = 5,
})