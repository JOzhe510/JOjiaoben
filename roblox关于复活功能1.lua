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

local Toggle = MainTab:CreateToggle({
   Name = "原地复活",
   Callback = function()
        local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- 原地复活系统
local respawnService = {}
respawnService.savedPositions = {}

function respawnService:SetupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        self:OnCharacterAdded(player, character)
    end)
    
    if player.Character then
        self:OnCharacterAdded(player, player.Character)
    end
end

function respawnService:OnCharacterAdded(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    
    if self.savedPositions[player] then
        wait(0.1) 
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(self.savedPositions[player])
            print("传送 " .. player.Name .. " 到保存位置")
        end
    end
    
    humanoid.Died:Connect(function()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            self.savedPositions[player] = rootPart.Position
            print("保存 " .. player.Name .. " 的位置")
        end
        
        wait(5)
        player:LoadCharacter()
    end)
end

-- 初始化原地复活系统
for _, player in ipairs(Players:GetPlayers()) do
    respawnService:SetupPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    respawnService:SetupPlayer(player)
end)

print("原地复活系统初始化完成")

-- 原地复活按钮功能（如果需要按钮触发）
local function RespawnAtSavedPosition()
    if LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            respawnService.savedPositions[LocalPlayer] = rootPart.Position
            print("保存当前位置用于复活")
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end

-- 如果需要键盘快捷键触发复活
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then -- 按R键触发原地复活
        RespawnAtSavedPosition()
    end
end)

-- 导出函数供其他脚本使用
return {
    RespawnAtSavedPosition = RespawnAtSavedPosition,
    respawnService = respawnService
}
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

-- 创建刷新选择按钮
local clearSelectionButton = MainTab:CreateButton({
   Name = "刷新选择的玩家",
   Callback = function()
        -- 停止追踪和传送
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
        
        -- 清空选择的玩家
        respawnService.followPlayer = nil
        currentPlayerLabel:Set("当前选择: 无")
        
        Rayfield:Notify({
            Title = "选择已刷新",
            Content = "已清空当前选择的玩家，可以重新选择",
            Duration = 3,
        })
   end,
})

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

local MainTab = Window:CreateTab("速度调节", nil)

-- 在追踪设置部分添加速度模式切换功能
local MainSection = MainTab:CreateSection("速度设置")

-- 添加速度模式切换
local Button = MainTab:CreateButton({
   Name = "切换速度模式: 普通",
   Callback = function()
        if respawnService.speedMode == "normal" then
            respawnService.speedMode = "tpwalk"
            Rayfield:Notify({
                Title = "速度模式已切换",
                Content = "当前模式: TP行走模式",
                Duration = 2,
            })
        else
            respawnService.speedMode = "normal"
            Rayfield:Notify({
                Title = "速度模式已切换",
                Content = "当前模式: 普通模式",
                Duration = 2,
            })
        end
   end,
})

-- 普通速度调节
local Input = MainTab:CreateInput({
   Name = "普通移动速度",
   PlaceholderText = "输入移动速度 (默认: 16)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0 then
            respawnService.walkSpeed = value
            
            -- 如果当前是普通模式，立即应用速度
            if respawnService.speedMode == "normal" and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = value
                end
            end
            
            Rayfield:Notify({
                Title = "设置更新",
                Content = "普通移动速度设置为: " .. value,
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

-- TP行走速度调节
local Input = MainTab:CreateInput({
   Name = "TP行走速度",
   PlaceholderText = "输入TP行走速度 (默认: 100)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local value = tonumber(Text)
        if value and value >= 0 then
            respawnService.tpWalkSpeed = value
            Rayfield:Notify({
                Title = "设置更新",
                Content = "TP行走速度设置为: " .. value,
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

-- 应用速度设置的函数
local function ApplySpeedSettings()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if respawnService.speedMode == "normal" then
        humanoid.WalkSpeed = respawnService.walkSpeed or 16
    else
        humanoid.WalkSpeed = 16 -- 重置为默认速度，TP行走模式不使用WalkSpeed
    end
end

-- 监听角色变化
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5) -- 等待角色完全加载
    ApplySpeedSettings()
end)

-- 如果已经有角色，立即应用设置
if LocalPlayer.Character then
    ApplySpeedSettings()
end

-- TP行走模式的实现
local tpWalkConnection = nil

local function StartTPWalk()
    if tpWalkConnection then
        tpWalkConnection:Disconnect()
        tpWalkConnection = nil
    end
    
    tpWalkConnection = RunService.Heartbeat:Connect(function()
        if respawnService.speedMode ~= "tpwalk" or not LocalPlayer.Character then
            if tpWalkConnection then
                tpWalkConnection:Disconnect()
                tpWalkConnection = nil
            end
            return
        end
        
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart and humanoid.MoveDirection.Magnitude > 0 then
            -- 获取移动方向
            local moveDirection = humanoid.MoveDirection
            -- 计算移动距离
            local moveDistance = (respawnService.tpWalkSpeed or 100) * 0.016 -- 每帧移动距离
            -- 移动角色
            rootPart.CFrame = rootPart.CFrame + moveDirection * moveDistance
        end
    end)
end

-- 监听速度模式变化
local lastSpeedMode = respawnService.speedMode
while true do
    wait(0.1)
    if respawnService.speedMode ~= lastSpeedMode then
        lastSpeedMode = respawnService.speedMode
        ApplySpeedSettings()
        
        if respawnService.speedMode == "tpwalk" then
            StartTPWalk()
        elseif tpWalkConnection then
            tpWalkConnection:Disconnect()
            tpWalkConnection = nil
        end
    end
end

local Button = MainTab:CreateButton({
   Name = "过速度检测",
   Callback = function()
   local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- 定义合理的最大瞬移距离阈值和速度范围
local MAX_DISTANCE_THRESHOLD = 9999999 -- 单位为 studs
local MIN_FLYING_SPEED = 9999999 -- 最小飞行速度，单位为 studs/秒
local MAX_FLYING_SPEED = 9999999999 -- 最大飞行速度，单位为 studs/秒

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local isFlying = false -- 飞行状态标志
        local lastValidPosition = humanoidRootPart.Position -- 记录最后有效的飞行位置
        local lastPositionUpdateTime = tick() -- 上次更新位置的时间戳
        local smoothFactor = 0.5 -- 平滑因子，用于稳定飞行

        local function updatePosition(currentPosition, targetPosition)
            return Vector3.new(
                currentPosition.X + (targetPosition.X - currentPosition.X) * smoothFactor,
                currentPosition.Y + (targetPosition.Y - currentPosition.Y) * smoothFactor,
                currentPosition.Z + (targetPosition.Z - currentPosition.Z) * smoothFactor
            )
        end

        local function onHeartbeat()
            if isFlying then
                local currentTime = tick()
                local timeElapsed = currentTime - lastPositionUpdateTime
                if timeElapsed > 0 then
                    local currentPosition = humanoidRootPart.Position
                    local velocity = (currentPosition - lastValidPosition).magnitude / timeElapsed
                    lastValidPosition = currentPosition
                    lastPositionUpdateTime = currentTime

                    -- 检查是否处于指定的速度范围内
                    if velocity >= MIN_FLYING_SPEED and velocity <= MAX_FLYING_SPEED then
                        -- 更新最后已知有效位置，假设飞行中的位置变化是合理的
                        lastValidPosition = currentPosition
                    else
                        -- 如果速度不在指定范围内，检查是否有异常传送
                        local distanceMoved = (currentPosition - lastValidPosition).magnitude
                        if distanceMoved > MAX_DISTANCE_THRESHOLD then
                            -- 如果移动距离超过了阈值，可能是异常传送，恢复到上一个有效位置
                            humanoidRootPart.CFrame = CFrame.new(lastValidPosition)
                        end
                    end

                    -- 应用平滑处理以稳定飞行
                    humanoidRootPart.Position = updatePosition(humanoidRootPart.Position, currentPosition)
                end
            else
                -- 当不是飞行状态时，直接更新最后有效位置
                lastValidPosition = humanoidRootPart.Position
                lastPositionUpdateTime = tick()
            end
        end

        RunService.Heartbeat:Connect(onHeartbeat)

        -- 设置飞行状态的方法
        function setFlyingState(state)
            isFlying = state
            if not state then
                -- 当停止飞行时，更新最后一次的有效位置
                lastValidPosition = humanoidRootPart.Position
                lastPositionUpdateTime = tick()
            end
        end

        -- 提供给其他脚本调用的接口，例如当玩家开始或停止飞行时
        player:SetAttribute("SetFlying", setFlyingState)
        
        -- 监听角色重生事件，重置飞行状态和位置
        player.CharacterRemoving:Connect(function()
            isFlying = false
            lastValidPosition = nil
            lastPositionUpdateTime = nil
        end)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)>
   end,
})

-- 初始通知
Rayfield:Notify({
   Title = "脚本加载成功",
   Content = "复活功能脚本已就绪！\n自动检测玩家功能已启用\n追踪时角色会自动朝向目标\n未选择玩家时会自动追踪最近玩家",
   Duration = 6,
})