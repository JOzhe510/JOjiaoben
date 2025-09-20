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
    teleportConnection = nil,
    autoFindNearest = false
}

-- 存储玩家按钮的表格
local playerButtons = {}

-- 计算追踪位置 (优化版本)
local function CalculateFollowPosition(targetRoot, distance, angle, height)
    local angleRad = math.rad(angle)
    
    -- 获取目标的朝向向量
    local lookVector = targetRoot.CFrame.LookVector
    local rightVector = targetRoot.CFrame.RightVector
    
    -- 计算相对于目标朝向的偏移
    local forwardOffset = -math.cos(angleRad) * distance  -- 负号是因为LookVector是向前
    local rightOffset = math.sin(angleRad) * distance
    
    local offset = (lookVector * forwardOffset) + (rightVector * rightOffset) + Vector3.new(0, height, 0)
    
    return targetRoot.Position + offset
end

-- 强制角色朝向目标
local function ForceLookAtTarget(localRoot, targetRoot)
    if localRoot and targetRoot then
        -- 计算朝向目标的向量
        local direction = (targetRoot.Position - localRoot.Position).Unit
        -- 设置角色的朝向
        localRoot.CFrame = CFrame.new(localRoot.Position, localRoot.Position + direction)
    end
end

-- 检查玩家是否存在
local function IsPlayerValid(playerName)
    if not playerName or playerName == "" then
        return false
    end
    return Players:FindFirstChild(playerName) ~= nil
end

-- 获取最近的玩家
local function GetNearestPlayer()
    local localChar = LocalPlayer.Character
    if not localChar then return nil end
    
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end

-- 自动选择最近的玩家
local function AutoSelectNearestPlayer()
    local nearestPlayer = GetNearestPlayer()
    if nearestPlayer then
        respawnService.followPlayer = nearestPlayer.Name
        currentPlayerLabel:Set("当前选择: " .. nearestPlayer.Name .. " (自动)")
        return true
    end
    return false
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
local currentPlayerLabel = MainTab:CreateLabel("当前选择: 无")

-- 创建玩家列表容器
local playerListContainer = MainTab:CreateSection("玩家列表")

-- 更新玩家按钮函数
function UpdatePlayerButtons()
    -- 清除旧的玩家按钮
    for _, button in ipairs(playerButtons) do
        button:Destroy()
    end
    playerButtons = {}
    
    -- 获取当前玩家列表
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    
    -- 检查当前选择的玩家是否仍然有效
    if respawnService.followPlayer and not IsPlayerValid(respawnService.followPlayer) then
        respawnService.followPlayer = nil
        currentPlayerLabel:Set("当前选择: 无")
        
        -- 如果正在追踪或传送，则停止
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
    end
    
    -- 创建新的玩家按钮
    for _, playerName in ipairs(players) do
        local button = MainTab:CreateButton({
            Name = "选择: " .. playerName,
            Callback = function()
                if IsPlayerValid(playerName) then
                    respawnService.followPlayer = playerName
                    currentPlayerLabel:Set("当前选择: " .. playerName)
                    Rayfield:Notify({
                        Title = "玩家选择成功",
                        Content = "已选择玩家: " .. playerName,
                        Duration = 3,
                    })
                else
                    Rayfield:Notify({
                        Title = "错误",
                        Content = "玩家不存在或已离开",
                        Duration = 3,
                    })
                    -- 刷新玩家列表
                    UpdatePlayerButtons()
                end
            end,
        })
        table.insert(playerButtons, button)
    end
    
    -- 如果没有其他玩家
    if #players == 0 then
        local label = MainTab:CreateLabel("当前没有其他玩家在线")
        table.insert(playerButtons, label)
    end
end

-- 创建刷新玩家按钮
local refreshButton = MainTab:CreateButton({
   Name = "刷新玩家列表",
   Callback = function()
        UpdatePlayerButtons()
        Rayfield:Notify({
            Title = "刷新完成",
            Content = "玩家列表已刷新",
            Duration = 2,
        })
   end,
})

-- 自动选择最近玩家按钮
local autoSelectButton = MainTab:CreateButton({
   Name = "自动选择最近玩家",
   Callback = function()
        if AutoSelectNearestPlayer() then
            Rayfield:Notify({
                Title = "自动选择成功",
                Content = "已自动选择最近的玩家",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "自动选择失败",
                Content = "没有找到其他玩家",
                Duration = 3,
            })
        end
   end,
})

-- 初始更新玩家按钮
UpdatePlayerButtons()

-- 玩家加入/离开时自动更新
local function SetupPlayerEvents()
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            wait(0.5) -- 等待玩家完全加入
            UpdatePlayerButtons()
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
                currentPlayerLabel:Set("当前选择: 无")
            end
            
            wait(0.1)
            UpdatePlayerButtons()
        end
    end)
end

SetupPlayerEvents()

-- 追踪功能
local followToggle = MainTab:CreateToggle({
   Name = "平滑追踪",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.following = Value
        
        if respawnService.followConnection then
            respawnService.followConnection:Disconnect()
            respawnService.followConnection = nil
        end
        
        if respawnService.following then
            -- 如果没有选择玩家，自动选择最近的玩家
            if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
                if not AutoSelectNearestPlayer() then
                    respawnService.following = false
                    Rayfield:Notify({
                        Title = "错误",
                        Content = "没有找到可追踪的玩家",
                        Duration = 3,
                    })
                    return
                else
                    Rayfield:Notify({
                        Title = "自动选择",
                        Content = "已自动选择最近的玩家进行追踪",
                        Duration = 3,
                    })
                end
            end
            
            respawnService.followConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.following then return end
                
                -- 如果目标玩家无效，尝试重新选择最近的玩家
                if not IsPlayerValid(respawnService.followPlayer) then
                    if not AutoSelectNearestPlayer() then
                        respawnService.following = false
                        Rayfield:Notify({
                            Title = "追踪停止",
                            Content = "目标玩家已离开且没有其他玩家",
                            Duration = 3,
                        })
                        return
                    end
                end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not targetPlayer then return end
                
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
                    
                    -- 移动到目标位置
                    localRoot.CFrame = CFrame.new(targetPosition)
                    
                    -- 强制角色朝向目标玩家
                    ForceLookAtTarget(localRoot, targetRoot)
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
local teleportToggle = MainTab:CreateToggle({
   Name = "直接传送",
   CurrentValue = false,
   Callback = function(Value)
        respawnService.teleporting = Value
        
        if respawnService.teleportConnection then
            respawnService.teleportConnection:Disconnect()
            respawnService.teleportConnection = nil
        end
        
        if respawnService.teleporting then
            -- 如果没有选择玩家，自动选择最近的玩家
            if not respawnService.followPlayer or not IsPlayerValid(respawnService.followPlayer) then
                if not AutoSelectNearestPlayer() then
                    respawnService.teleporting = false
                    Rayfield:Notify({
                        Title = "错误",
                        Content = "没有找到可传送的玩家",
                        Duration = 3,
                    })
                    return
                else
                    Rayfield:Notify({
                        Title = "自动选择",
                        Content = "已自动选择最近的玩家进行传送",
                        Duration = 3,
                    })
                end
            end
            
            respawnService.teleportConnection = RunService.Heartbeat:Connect(function()
                if not respawnService.teleporting then return end
                
                -- 如果目标玩家无效，尝试重新选择最近的玩家
                if not IsPlayerValid(respawnService.followPlayer) then
                    if not AutoSelectNearestPlayer() then
                        respawnService.teleporting = false
                        Rayfield:Notify({
                            Title = "传送停止",
                            Content = "目标玩家已离开且没有其他玩家",
                            Duration = 3,
                        })
                        return
                    end
                end
                
                local targetPlayer = Players:FindFirstChild(respawnService.followPlayer)
                if not targetPlayer then return end
                
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
                    
                    -- 移动到目标位置
                    localRoot.CFrame = CFrame.new(targetPosition)
                    
                    -- 强制角色朝向目标玩家
                    ForceLookAtTarget(localRoot, targetRoot)
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
            -- 如果没有选择玩家，自动选择最近的玩家
            if AutoSelectNearestPlayer() then
                respawnService.following = true
                Rayfield:Notify({
                    Title = "自动选择",
                    Content = "已自动选择最近的玩家并开始追踪",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先选择有效玩家或确保有其他玩家在线",
                    Duration = 3,
                })
            end
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
            -- 如果没有选择玩家，自动选择最近的玩家
            if AutoSelectNearestPlayer() then
                respawnService.teleporting = true
                Rayfield:Notify({
                    Title = "自动选择",
                    Content = "已自动选择最近的玩家并开始传送",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "错误",
                    Content = "请先选择有效玩家或确保有其他玩家在线",
                    Duration = 3,
                })
            end
        end
    end,
})

-- 初始通知
Rayfield:Notify({
   Title = "脚本加载成功",
   Content = "复活功能脚本已就绪！\n自动检测玩家功能已启用\n追踪时角色会自动朝向目标\n未选择玩家时会自动追踪最近玩家",
   Duration = 6,
})