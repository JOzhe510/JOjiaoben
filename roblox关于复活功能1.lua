local library = loadstring(game:HttpGet(('https://github.com/DevSloPo/Auto/raw/main/Ware-obfuscated.lua')))()

local window = library:new("复活功能脚本")
local XKHub = window:Tab("复活功能", "7733774602")
local XK = XKHub:section("复活系统", true)

-- 复活系统变量
local respawnService = {
    savedPositions = {},
    autoRespawn = false,
    following = false,
    followPlayer = nil,
    followSpeed = 100,
    followDistance = 3,
    followConnection = nil
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- 初始化玩家列表
local playerOptions = {}
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerOptions, player.Name)
    end
end

-- 复活系统功能
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
        end
    end
    
    humanoid.Died:Connect(function()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            self.savedPositions[player] = rootPart.Position
        end
        
        if self.autoRespawn then
            wait(2)
            player:LoadCharacter()
        end
    end)
end

-- 初始化复活系统
for _, player in ipairs(Players:GetPlayers()) do
    respawnService:SetupPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    respawnService:SetupPlayer(player)
    table.insert(playerOptions, player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
    for i, name in ipairs(playerOptions) do
        if name == player.Name then
            table.remove(playerOptions, i)
            break
        end
    end
end)

-- 追踪功能
local function startFollowing()
    if respawnService.followConnection then
        respawnService.followConnection:Disconnect()
        respawnService.followConnection = nil
    end
    
    if not respawnService.following or not respawnService.followPlayer then return end
    
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
                
                localRoot.CFrame = CFrame.new(targetPosition, followedRoot.Position)
                
                -- 移动角色
                localHumanoid:MoveTo(targetPosition)
            else
                localHumanoid:MoveTo(localRoot.Position) -- 停止移动
            end
        end
    end)
end

-- 直接传送功能
local function teleportToPlayer()
    if not respawnService.followPlayer then return end
    
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
end

-- 立即自杀功能
local function suicide()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end

-- 原地复活功能
local function respawn()
    if LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            respawnService.savedPositions[LocalPlayer] = rootPart.Position
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end

-- 创建UI界面
XK:Label("复活功能控制")

XK:Button(
    "立即自杀",
    function()
        suicide()
    end
)

XK:Button(
    "原地复活",
    function()
        respawn()
    end
)

XK:Toggle("自动复活", "", false, function(state)
    respawnService.autoRespawn = state
end)

-- 玩家选择区域
local selectedPlayer = "选择玩家"
XK:Dropdown("选择玩家", "", playerOptions, function(playerName)
    respawnService.followPlayer = playerName
    selectedPlayer = playerName
end)

-- 追踪功能区域
XK:Button(
    "平滑追踪",
    function()
        if respawnService.followPlayer and respawnService.followPlayer ~= "选择玩家" then
            respawnService.following = not respawnService.following
            
            if respawnService.following then
                startFollowing()
            elseif respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
        end
    end
)

XK:Button(
    "直接传送",
    function()
        if respawnService.followPlayer and respawnService.followPlayer ~= "选择玩家" then
            teleportToPlayer()
        end
    end
)

-- 设置区域
local XKSettings = XKHub:section("设置", true)

XKSettings:Slider("追踪速度", "", 100, 10, 200, false, function(value)
    respawnService.followSpeed = value
end)

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
            teleportToPlayer()
        end
    elseif input.KeyCode == Enum.KeyCode.F then
        -- 切换追踪
        if respawnService.followPlayer and respawnService.followPlayer ~= "选择玩家" then
            respawnService.following = not respawnService.following
            
            if respawnService.following then
                startFollowing()
            elseif respawnService.followConnection then
                respawnService.followConnection:Disconnect()
                respawnService.followConnection = nil
            end
        end
    end
end)

-- 添加说明标签
local XKInfo = XKHub:section("快捷键说明", true)
XKInfo:Label("R键: 快速复活")
XKInfo:Label("T键: 快速传送")
XKInfo:Label("F键: 切换追踪")

print("🎮 复活功能脚本加载完成！")
print("快捷键: R-快速复活, T-快速传送, F-切换追踪")