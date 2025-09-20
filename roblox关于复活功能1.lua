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

local Dropdown = MainTab:CreateDropdown({
   Name = "选择玩家",
   Options = updatePlayerList(),
   CurrentOption = {"选择玩家"},
   MultipleOptions = false,
   Flag = "PlayerDropdown",
   Callback = function(Option)
        respawnService.followPlayer = Option
   end,
})

-- 修复追踪功能
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
            if not respawnService.followPlayer or respawnService.followPlayer == "选择玩家" then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先选择一个玩家",
                    Duration = 3,
                })
                FollowToggle:Set(false)
                return
            end
            
            local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
            if not targetPlayer then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "目标玩家不存在",
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
                    local distance = (targetRoot.Position - localRoot.Position).Magnitude
                    
                    if distance > respawnService.followDistance then
                        local direction = (targetRoot.Position - localRoot.Position).Unit
                        local targetPosition = targetRoot.Position - (direction * respawnService.followDistance)
                        
                        localHumanoid:MoveTo(targetPosition)
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

-- 直接传送改为Toggle
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
            if not respawnService.followPlayer or respawnService.followPlayer == "选择玩家" then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先选择一个玩家",
                    Duration = 3,
                })
                TeleportToggle:Set(false)
                return
            end
            
            local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
            if not targetPlayer or not targetPlayer.Character then
                Rayfield:Notify({
                    Title = "错误",
                    Content = "目标玩家不存在",
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
                    local direction = (targetRoot.Position - localRoot.Position).Unit
                    local targetPosition = targetRoot.Position - (direction * respawnService.followDistance)
                    
                    localRoot.CFrame = CFrame.new(targetPosition, targetRoot.Position)
                end
            end)
            
            Rayfield:Notify({
                Title = "传送状态",
                Content = "已开始传送: " .. respawnService.followPlayer,
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
   Range = {10, 1000},
   Increment = 1,
   Suffix = "速度",
   CurrentValue = 100,
   Flag = "FollowSpeedSlider",
   Callback = function(Value)
        respawnService.followSpeed = Value
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "追踪距离",
   Range = {1, 50},
   Increment = 1,
   Suffix = "距离",
   CurrentValue = 3,
   Flag = "FollowDistanceSlider",
   Callback = function(Value)
        respawnService.followDistance = Value
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
        if respawnService.followPlayer and respawnService.followPlayer ~= "选择玩家" then
            respawnService.following = not respawnService.following
            FollowToggle:Set(respawnService.following)
        end
    end,
})

local Keybind = MainTab:CreateKeybind({
    Name = "切换传送快捷键",
    CurrentKeybind = "G",
    HoldToInteract = false,
    Flag = "ToggleTeleportKeybind",
    Callback = function(Keybind)
        if respawnService.followPlayer and respawnService.followPlayer ~= "选择玩家" then
            respawnService.teleporting = not respawnService.teleporting
            TeleportToggle:Set(respawnService.teleporting)
        end
    end,
})

Players.PlayerAdded:Connect(function()
    Dropdown:SetOptions(updatePlayerList())
end)

Players.PlayerRemoving:Connect(function()
    Dropdown:SetOptions(updatePlayerList())
end)

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
        end
        if respawnService.teleporting then
            respawnService.teleporting = false
            if respawnService.teleportConnection then
                respawnService.teleportConnection:Disconnect()
                respawnService.teleportConnection = nil
            end
            TeleportToggle:Set(false)
        end
    end
end)

-- 初始通知
Rayfield:Notify({
   Title = "脚本加载成功",
   Content = "复活功能脚本已就绪",
   Duration = 5,
})