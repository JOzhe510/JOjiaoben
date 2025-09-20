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

-- ==================== 极致追踪玩家功能 ====================
local FollowService = {
    Enabled = false,
    TargetPlayer = nil,
    FollowSpeed = 100,
    FollowDistance = 3,
    Connection = nil,
    Mode = "Follow"
}

function FollowService:FindTargetPlayer(targetName)
    if targetName == "选择玩家" then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == targetName then
            return player
        end
    end
    return nil
end

function FollowService:StartFollowing()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.Enabled or not self.TargetPlayer then return end
        
        if not self.TargetPlayer.Character then
            self:StopFollowing()
            return
        end
        
        local targetRoot = self.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        
        if not targetRoot or not localRoot then return end
        
        if self.Mode == "Teleport" then
            -- 直接传送模式
            local targetCFrame = targetRoot.CFrame
            local angleRad = math.rad(180)
            
            local offsetDirection = Vector3.new(
                math.sin(angleRad) * self.FollowDistance,
                0,
                math.cos(angleRad) * self.FollowDistance
            )
            
            local rotatedOffset = targetCFrame:VectorToWorldSpace(offsetDirection)
            local targetPosition = targetRoot.Position + rotatedOffset
            
            localRoot.CFrame = CFrame.new(targetPosition, Vector3.new(targetRoot.Position.X, targetPosition.Y, targetRoot.Position.Z))
        else
            -- 平滑追踪模式
            local targetCFrame = targetRoot.CFrame
            local behindOffset = targetCFrame.LookVector * -self.FollowDistance
            local targetPosition = targetRoot.Position + behindOffset + Vector3.new(0, 1.5, 0)
            
            local direction = (targetPosition - localRoot.Position).Unit
            localRoot.Velocity = direction * self.FollowSpeed
        end
    end)
end

function FollowService:StopFollowing()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

-- 追踪Toggle功能
local FollowToggle = MainTab:CreateToggle({
   Name = "追踪玩家",
   CurrentValue = false,
   Flag = "FollowToggle",
   Callback = function(Value)
        FollowService.Enabled = Value
        
        if FollowService.Enabled then
            FollowService.TargetPlayer = FollowService:FindTargetPlayer(respawnService.followPlayer)
            FollowService.FollowSpeed = respawnService.followSpeed
            FollowService.FollowDistance = respawnService.followDistance
            FollowService.Mode = "Follow"
            
            if FollowService.TargetPlayer then
                FollowService:StartFollowing()
            else
                FollowService.Enabled = false
                FollowToggle:Set(false)
            end
        else
            FollowService:StopFollowing()
        end
   end,
})

local Button = MainTab:CreateButton({
   Name = "直接传送",
   Callback = function()
        if not respawnService.followPlayer or respawnService.followPlayer == "选择玩家" then
            return
        end
        
        local followedPlayer = Players:FindFirstChild(respawnService.followPlayer)
        if not followedPlayer or not followedPlayer.Character then
            return
        end
        
        local followedRoot = followedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local localChar = LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        
        if followedRoot and localRoot then
            local direction = (followedRoot.Position - localRoot.Position).Unit
            local targetPosition = followedRoot.Position - (direction * respawnService.followDistance)
            
            localRoot.CFrame = CFrame.new(targetPosition, followedRoot.Position)
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
        FollowService.FollowSpeed = Value
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
        FollowService.FollowDistance = Value
   end,
})

local Input = MainTab:CreateInput({
   Name = "传送高度偏移",
   PlaceholderText = "0-10",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        -- 高度偏移设置
   end,
})

local Input = MainTab:CreateInput({
   Name = "传送角度偏移",
   PlaceholderText = "0-360",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        -- 角度偏移设置
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
            FollowService.Enabled = not FollowService.Enabled
            
            if FollowService.Enabled then
                FollowService.TargetPlayer = FollowService:FindTargetPlayer(respawnService.followPlayer)
                FollowService.FollowSpeed = respawnService.followSpeed
                FollowService.FollowDistance = respawnService.followDistance
                FollowService.Mode = "Follow"
                
                if FollowService.TargetPlayer then
                    FollowService:StartFollowing()
                    FollowToggle:Set(true)
                else
                    FollowService.Enabled = false
                end
            else
                FollowService:StopFollowing()
                FollowToggle:Set(false)
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
    if FollowService.Enabled and FollowService.TargetPlayer == player then
        FollowService.Enabled = false
        FollowService:StopFollowing()
        FollowToggle:Set(false)
    end
end)

-- 初始通知
Rayfield:Notify({
   Title = "脚本加载成功",
   Content = "复活功能脚本已就绪",
   Duration = 5,
})