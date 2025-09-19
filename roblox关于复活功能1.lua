local library = loadstring(game:HttpGet(('https://github.com/DevSloPo/Auto/raw/main/Ware-obfuscated.lua'))()

local window = library:new("复活功能脚本")
local XKHub = window:Tab("复活功能", "7733774602")
local XK = XKHub:section("复活系统", true)

-- 创建UI界面
XK:Label("复活功能控制")

-- 立即自杀按钮
XK:Button("立即自杀", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- 原地复活按钮
XK:Button("原地复活", function()
    if LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            respawnService.savedPositions[LocalPlayer] = rootPart.Position
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- 自动复活开关
XK:Toggle("自动复活", "", false, function(state)
    respawnService.autoRespawn = state
end)

-- 玩家选择下拉菜单
XK:Dropdown("选择玩家", "", playerOptions, function(playerName)
    respawnService.followPlayer = playerName
end)

-- 平滑追踪按钮
XK:Button("平滑追踪", function()
    if not respawnService.followPlayer or respawnService.followPlayer == "选择玩家" then
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
    end
end)

-- 直接传送按钮
XK:Button("直接传送", function()
    if not respawnService.followPlayer or respawnService.followPlayer == "选择玩家" then
        return
    end
    
    local followedPlayer = Players:FindFirstChild(respawnService.followPlayer)
    if not followedPlayer or not followedPlayer.Character then return end
    
    local followedRoot = followedPlayer.Character:FindFirstChild("HumanoidRootPart")
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    if followedRoot and localRoot then
        local direction = (followedRoot.Position - localRoot.Position).Unit
        local targetPosition = followedRoot.Position - (direction * respawnService.followDistance)
        
        localRoot.CFrame = CFrame.new(targetPosition, followedRoot.Position)
    end
end)

-- 设置区域
local XKSettings = XKHub:section("设置", true)

-- 追踪速度滑块
XKSettings:Slider("追踪速度", "", 100, 10, 200, false, function(value)
    respawnService.followSpeed = value
end)

-- 追踪距离滑块
XKSettings:Slider("追踪距离", "", 3, 1, 10, false, function(value)
    respawnService.followDistance = value
end)

-- 键盘快捷键
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        -- 快速复活
        if LocalPlayer.Character then
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                respawnService.savedPositions[LocalPlayer] = rootPart.Position
            end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    elseif input.KeyCode == Enum.KeyCode.T then
        -- 快速传送
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
    elseif input.KeyCode == Enum.KeyCode.F then
        -- 切换追踪
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
            end
        end
    end
end)