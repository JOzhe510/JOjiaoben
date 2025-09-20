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
    followSpeed = 500,
    followDistance = 3.9,
    followHeight = 0,
    followPosition = 350,
    savedPositions = {},
    followConnection = nil,
    teleportConnection = nil
}

-- 玩家列表管理
local playerList = {}
local selectedPlayer = nil
local currentPlayerLabel
local playerDropdown

-- 更新玩家列表
local function UpdatePlayerList()
    playerList = {"无"}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    
    -- 更新下拉菜单选项
    if playerDropdown then
        playerDropdown:SetOptions(playerList)
    end
end

-- 计算追踪位置
local function CalculateFollowPosition(targetRoot, distance, angle, height)
    local angleRad = math.rad(angle)
    local offset = Vector3.new(
        math.sin(angleRad) * distance,
        height,
        math.cos(angleRad) * distance
    )
    return targetRoot.Position + offset
end

-- 检查玩家是否存在
local function IsPlayerValid(playerName)
    if playerName == "无" or playerName == nil then
        return false
    end
    return Players:FindFirstChild(playerName) ~= nil
end

-- 创建主标签页
local MainTab = Window:CreateTab("🏠 复活功能", nil)

-- 复活系统部分
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
   Callback = function(Value)
        respawnService.autoRespawn = Value
   end,
})

-- 玩家选择部分
local Section = MainTab:CreateSection("选择玩家")

-- 显示当前选择的玩家
currentPlayerLabel = MainTab:CreateLabel("当前选择: 无")

-- 创建玩家选择下拉菜单
playerDropdown = MainTab:CreateDropdown({
    Name = "选择玩家",
    Options = {"加载中..."},
    CurrentOption = "无",
    Callback = function(Option)
        if Option == "无" then
            selectedPlayer = nil
            respawnService.followPlayer = nil
            currentPlayerLabel:Set("当前选择: 无")
        else
            if IsPlayerValid(Option) then
                selectedPlayer = Option
                respawnService.followPlayer = Option
                currentPlayerLabel:Set("当前选择: " .. Option)
                Rayfield:Notify({
                    Title = "玩家选择成功",
                    Content = "已选择玩家: " .. Option,
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "错误",
                    Content = "玩家不存在或已离开",
                    Duration = 3,
                })
                -- 重新更新玩家列表
                UpdatePlayerList()
            end
        end
    end,
})

-- 玩家加入/离开时自动更新
local function SetupPlayerEvents()
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            wait(0.5) -- 等待玩家完全加入
            UpdatePlayerList()
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if player ~= LocalPlayer then
            -- 如果追踪的目标玩家离开
            if respawnService.followPlayer == player.Name then
                if respawnService.following then
                    respawnService.following = false
                    if respawnService.followConnection then
                        respawnService.followConnection:Disconnect()
                        respawnService.followConnection = nil
                    end
                end
                if respawnService.teleporting then
                    respawnService.teleporting = false
                    if respawnService.teleportConnection then
                        respawnService.teleportConnection:Disconnect()
                        respawnService.teleportConnection = nil
                    end
                end
                respawnService.followPlayer = nil
                selectedPlayer = nil
                currentPlayerLabel:Set("当前选择: 无")
                if playerDropdown then
                    playerDropdown:Set("无")
                end
            end
            
            wait(0.1)
            UpdatePlayerList()
        end
    end)
end

-- 初始更新玩家列表
UpdatePlayerList()
SetupPlayerEvents()

-- 追踪功能
local Toggle = MainTab:CreateToggle({
   Name = "平滑追踪",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.following = Value
        
        if respawnService.followConnection then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
        end
        
        if respawnService.following then
            if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
                respawnService.following = false
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先选择有效玩家",
                    Duration = 3,
                })
                return
            end
            
            respawnService.followConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.following then return end
                
                if not IsPlayerValid(respawnService.followPlayer) then
                    respawnService.following = false
                    return
                end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
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
                    
                    localRoot.CFrame = CFrame.new(targetPosition)
                end
            end)
            
            Rayfield:Notify({
                Title = "追踪开始",
                Content = "正在追踪: " .. respawnService.followPlayer,
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "追踪停止",
                Content = "已停止追踪",
                Duration = 3,
            })
        end
   end,
})

-- 传送功能
local Toggle = MainTab:CreateToggle({
   Name = "直接传送",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.teleporting = Value
        
        if respawnService.teleportConnection then
            respawnService.teleportConnection:Disconnect()
            respawnService.teleportConnection = nil
        end
        
        if respawnService.teleporting then
            if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
                respawnService.teleporting = false
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先选择有效玩家",
                    Duration = 3,
                })
                return
            end
            
            respawnService.teleportConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.teleporting then return end
                
                if not IsPlayerValid(respawnService.followPlayer) then
                    respawnService.teleporting = false
                    return
                end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
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
                    
                    localRoot.CFrame = CFrame.new(targetPosition)
                end
            end)
            
            Rayfield:Notify({
                Title = "传送开始",
                Content = "正在传送到: " .. respawnService.followPlayer,
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "传送停止",
                Content = "已停止传送",
                Duration = 3,
            })
        end
   end,
})

-- 追踪设置
local Section = MainTab:CreateSection("追踪设置")

local Input = MainTab:CreateInput({
   Name = "追踪速度",
   PlaceholderText = "输入追踪速度 (默认: 500)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.followSpeed = value
            Rayfield:Notify({
                Title = "设置更新",
                Content = "追踪速度设置为: " .. value,
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

local Input = MainTab:CreateInput({
   Name = "追踪距离",
   PlaceholderText = "输入追踪距离 (默认: 3.9)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value > 0 then
            respawnService.followDistance = value
            Rayfield:Notify({
                Title = "设置更新",
                Content = "追踪距离设置为: " .. value,
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

local Input = MainTab:CreateInput({
   Name = "追踪位置",
   PlaceholderText = "输入追踪角度 (0-360度, 默认: 350)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0 and value <= 360 then
            respawnService.followPosition = value
            local positionText = ""
            if value == 0 then positionText = "前方"
            elseif value == 90 then positionText = "右侧"
            elseif value == 180 then positionText = "后方"
            elseif value == 270 then positionText = "左侧"
            else positionText = value .. "度" end
            
            Rayfield:Notify({
                Title = "位置设置",
                Content = "追踪位置: " .. positionText,
                Duration = 2,
            })
        else
            Rayfield:Notify({
                Title = "输入错误",
                Content = "请输入0-360之间的数字",
                Duration = 2,
            })
        end
   end,
})

local Input = MainTab:CreateInput({
   Name = "追踪高度",
   PlaceholderText = "输入追踪高度 (默认: 0)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value then
            respawnService.followHeight = value
            Rayfield:Notify({
                Title = "高度设置",
                Content = "追踪高度设置为: " .. value,
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

-- 快捷键
local Section = MainTab:CreateSection("快捷键")

local Keybind = MainTab:CreateKeybind({
    Name = "快速复活快捷键",
    CurrentKeybind = "R",
    HoldToInteract = false,
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

local Keybind = MainTab:CreateKeybind({
    Name = "切换追踪快捷键",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Callback = function()
        if respawnService.followPlayer and IsPlayerValid(respawnService.followPlayer) then
            respawnService.following = not respawnService.following
        else
            Rayfield:Notify({
                Title = "错误",
                Content = "请先选择有效玩家",
                Duration = 3,
            })
        end
    end,
})

local Keybind = MainTab:CreateKeybind({
    Name = "切换传送快捷键",
    CurrentKeybind = "G",
    HoldToInteract = false,
    Callback = function()
        if respawnService.followPlayer and IsPlayerValid(respawnService.followPlayer) then
            respawnService.teleporting = not respawnService.teleporting
        else
            Rayfield:Notify({
                Title = "错误",
                Content = "请先选择有效玩家",
                Duration = 3,
            })
        end
    end,
})

-- 初始通知
Rayfield:Notify({
   Title = "脚本加载成功",
   Content = "复活功能脚本已就绪！\n自动检测玩家功能已启用",
   Duration = 6,
})