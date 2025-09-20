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
    followSpeed = 100,
    followDistance = 3,
    savedPositions = {},
    followConnection = nil
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
local Toggle = MainTab:CreateToggle({
   Name = "追踪玩家",
   CurrentValue = false,
   Flag = "FollowToggle",
   Callback = function(Value)
        respawnService.following = Value
        
        if respawnService.followConnection then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
        end
        
        if respawnService.following then
            respawnService.followConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.following or not respawnService.followPlayer or respawnService.followPlayer == "选择玩家" then return end
                
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
        end
   end,
})

local Button = MainTab:CreateButton({
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
    Name = "快速传送快捷键",
    CurrentKeybind = "T",
    HoldToInteract = false,
    Flag = "TeleportKeybind",
    Callback = function(Keybind)
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

local Keybind = MainTab:CreateKeybind({
    Name = "切换追踪快捷键",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "ToggleFollowKeybind",
    Callback = function(Keybind)
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

Players.PlayerAdded:Connect(function()
    Dropdown:SetOptions(updatePlayerList())
end)

Players.PlayerRemoving:Connect(function()
    Dropdown:SetOptions(updatePlayerList())
end)

-- 玩家离开时自动停止追踪
Players.PlayerRemoving:Connect(function(player)
    if respawnService.following and respawnService.followPlayer == player.Name then
        respawnService.following = false
        if respawnService.followConnection then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
        end
    end
end)

-- 初始通知
Rayfield:Notify({
   Title = "脚本加载成功",
   Content = "复活功能脚本已就绪",
   Duration = 5,
})