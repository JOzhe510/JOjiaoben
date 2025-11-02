local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = '被遗弃访客自动格挡',
    Center = true,
    AutoShow = true,
    Resizable = true
})

local SpeedGroup = Window:AddTab('通用加速'):AddLeftGroupbox('高速')

local SpeedMultiplier = {
    default = 1,
    boosted = 20 
}
local isBoostEnabled = false
local moveConnection = nil
local jumpConnection = nil
local LocalPlayer = game:GetService("Players").LocalPlayer

SpeedGroup:AddSlider("SpeedMulti", {
    Text = "加速速度",
    Min = 0,
    Max = 50,
    Default = SpeedMultiplier.boosted,
    Rounding = 1,
    Callback = function(value)
        SpeedMultiplier.boosted = value
    end
})

SpeedGroup:AddToggle("SpeedBoostToggle", {
    Text = "开启通用高速加速",
    Default = false,
    Callback = function(enabled)
        isBoostEnabled = enabled
        local RunService = game:GetService("RunService")

        if moveConnection then moveConnection:Disconnect() end
        if jumpConnection then jumpConnection:Disconnect() end

        if enabled then
     
            moveConnection = RunService.RenderStepped:Connect(function(deltaTime)
                local Character = LocalPlayer.Character
                if not Character then return end
                local Humanoid = Character:FindFirstChild("Humanoid")
                local RootPart = Character:FindFirstChild("HumanoidRootPart")
                if not Humanoid or not RootPart then return end

                local MoveDir = Humanoid.MoveDirection
                if MoveDir.Magnitude > 0 then
                    local MoveDistance = SpeedMultiplier.boosted * deltaTime * 10
                    RootPart.CFrame += MoveDir * MoveDistance
                    RootPart.CanCollide = true
                end
            end)

            local function onCharacterAdded(Character)
                local Humanoid = Character:WaitForChild("Humanoid")
                jumpConnection = Humanoid.Jumping:Connect(function(isJumping)
                    if isJumping and isBoostEnabled then
                        isBoostEnabled = false
                        if moveConnection then moveConnection:Disconnect() end
                        if jumpConnection then jumpConnection:Disconnect() end
                        SpeedGroup:SetValue("SpeedBoostToggle", false)
                    end
                end)
            end

            if LocalPlayer.Character then
                onCharacterAdded(LocalPlayer.Character)
            end
            LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

        else
        
            if moveConnection then moveConnection:Disconnect() end
            if jumpConnection then jumpConnection:Disconnect() end
        end
    end
})

SpeedGroup:AddButton("EmergencyStop", {
    Text = "紧急停止加速",
    Func = function()
        isBoostEnabled = false
        if moveConnection then moveConnection:Disconnect() end
        if jumpConnection then jumpConnection:Disconnect() end
        SpeedGroup:SetValue("SpeedBoostToggle", false)
    end
})

local BlockConfig = {
    Enabled = false,
    BaseDistance = 16,         
    ScanInterval = 0.001,      
    BlockCooldown = 0.08,      
    TargetAngle = 50,          
    ShowVisualization = false,  
    EnablePrediction = false,   
    
    TargetSoundIds = {
        "102228729296384", "140242176732868", "112809109188560", "136323728355613",
        "115026634746636", "84116622032112", "108907358619313", "127793641088496",
        "86174610237192", "95079963655241", "101199185291628", "119942598489800",
        "84307400688050", "113037804008732", "105200830849301", "75330693422988",
        "82221759983649", "81702359653578", "108610718831698", "112395455254818",
        "109431876587852", "109348678063422", "85853080745515", "12222216"
    }
}

local combatConnection = nil    
local lastBlockTime = 0         
local lastScanTime = 0          
local visualizationParts = {}   
local soundCache = {}           
local lastSoundCheck = 0        
local lastPingCheck = 0         
local currentPing = 0           
local soundLookup = {}          
for _, id in ipairs(BlockConfig.TargetSoundIds) do
    soundLookup[id] = true
    soundLookup["rbxassetid://" .. id] = true
end

local function GetPing()
    local currentTime = os.clock()
    if currentTime - lastPingCheck < 0.5 then return currentPing end
    lastPingCheck = currentTime
    local Stats = game:GetService("Stats")
    local serverStats = Stats and Stats.Network and Stats.Network:FindFirstChild("ServerStatsItem")
    if serverStats then
        local pingStat = serverStats:FindFirstChild("Data Ping")
        if pingStat then currentPing = pingStat.Value end
    end
    return currentPing
end

local function GetPingCompensation()
    return math.min(0.3, GetPing() / 1000 * 0.1 * 10)
end

local function CreateVisualization()
    if not LocalPlayer.Character then return end
    local RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end

    for _, part in ipairs(visualizationParts) do part:Destroy() end
    visualizationParts = {}
    local center = RootPart.Position + Vector3.new(0, 0.1, 0)
    local segments = 36

    local centerPart = Instance.new("Part")
    centerPart.Size = Vector3.new(0.1, 0.1, 0.1)
    centerPart.Position = center
    centerPart.Anchored = true
    centerPart.CanCollide = false
    centerPart.Transparency = 1
    centerPart.Parent = workspace
    table.insert(visualizationParts, centerPart)

    for i = 1, segments do
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.5, 0.1, 0.5)
        part.BrickColor = BrickColor.new("Bright green")
        part.Material = Enum.Material.Neon
        part.Transparency = 0.7
        part.Anchored = true
        part.CanCollide = false
        part.Parent = workspace
        table.insert(visualizationParts, part)
    end

    local RunService = game:GetService("RunService")
    local visConnection = RunService.Heartbeat:Connect(function()
        if not BlockConfig.ShowVisualization then
            for _, part in ipairs(visualizationParts) do part:Destroy() end
            visualizationParts = {}
            visConnection:Disconnect()
            return
        end
        if not LocalPlayer.Character then return end
        local Root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not Root then return end
        center = Root.Position + Vector3.new(0, 0.1, 0)
        centerPart.Position = center
        local lookVector = Root.CFrame.LookVector
        local angle = math.rad(BlockConfig.TargetAngle)
        for i = 1, #visualizationParts - 1 do
            local part = visualizationParts[i + 1]
            local segAngle = (i - 1) * (2 * angle) / (#visualizationParts - 2) - angle
            local rotCFrame = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), segAngle)
            local dir = rotCFrame:VectorToWorldSpace(lookVector)
            part.Position = center + dir * BlockConfig.BaseDistance
        end
    end)
end

local function HasTargetSound(character)
    if not character then return false end
    local RootPart = character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return false end
    local currentTime = os.clock()
    if currentTime - lastSoundCheck < 0.0005 then return soundCache[character] or false end
    lastSoundCheck = currentTime
    local found = false
    for _, child in ipairs(RootPart:GetChildren()) do
        if child:IsA("Sound") then
            local numericId = string.match(tostring(child.SoundId), "(%d+)$")
            if numericId and soundLookup[numericId] then
                found = true
                break
            end
        end
    end
    soundCache[character] = found
    return found
end

local function GetMoveCompensation()
    if not LocalPlayer.Character then return 0 end
    local RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return 0 end
    local vel = RootPart.Velocity
    local speed = math.sqrt(vel.X^2 + vel.Y^2 + vel.Z^2)
    return 1.5 + (speed * 0.25)
end

local function GetTotalDetectionRange(killer)
    local base = BlockConfig.BaseDistance
    local moveBonus = GetMoveCompensation()
    local predictBonus = 0
    local pingBonus = GetPingCompensation() * 5

    if BlockConfig.EnablePrediction and killer and killer:FindFirstChild("HumanoidRootPart") then
        local vel = killer.HumanoidRootPart.Velocity
        local speed = math.sqrt(vel.X^2 + vel.Y^2 + vel.Z^2)
        if speed > 8 then
            predictBonus = math.min(12, 4 + (speed * 0.35))
            if speed > 12 then predictBonus = predictBonus * 1.3 end
        end
    end
    return base + moveBonus + predictBonus + pingBonus
end

local function IsTargetingMe(killer)
    if not LocalPlayer.Character or not killer then return false end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local killerRoot = killer:FindFirstChild("HumanoidRootPart")
    if not myRoot or not killerRoot then return false end
    local dirToMe = (myRoot.Position - killerRoot.Position).Unit
    local killerLook = killerRoot.CFrame.LookVector
    local dot = dirToMe:Dot(killerLook)
    local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
    return angle <= BlockConfig.TargetAngle
end

local function GetThreateningKillers()
    local killers = {}
    local killersFolder = workspace:FindFirstChild("Killers") or (workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers"))
    if not killersFolder then return killers end
    if not LocalPlayer.Character then return killers end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return killers end

    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:IsA("Model") and killer:FindFirstChild("HumanoidRootPart") then
            local killerRoot = killer.HumanoidRootPart
            local distance = (myRoot.Position - killerRoot.Position).Magnitude
            local detRange = GetTotalDetectionRange(killer)
            if distance <= detRange and HasTargetSound(killer) and IsTargetingMe(killer) then
                table.insert(killers, killer)
            end
        end
    end
    return killers
end

local function PerformBlock()
    local now = os.clock()
    local cooldown = math.max(0.05, BlockConfig.BlockCooldown - (GetPing() / 1000 * 0.5))
    if now - lastBlockTime >= cooldown then
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local networkRemote = ReplicatedStorage:WaitForChild("Modules", 5)
                and ReplicatedStorage.Modules:WaitForChild("Network", 5)
                and ReplicatedStorage.Modules.Network:WaitForChild("RemoteEvent", 5)
            if networkRemote then
                networkRemote:FireServer("UseActorAbility", { ["Block"] = true })
                lastBlockTime = now
            end
        end)
    end
end

local function CombatLoop()
    local currentTime = os.clock()
    if currentTime - lastScanTime >= BlockConfig.ScanInterval then
        lastScanTime = currentTime
        local threats = GetThreateningKillers()
        if #threats > 0 then PerformBlock() end
    end
end

local BlockTab = Window:AddTab('自动格挡')
local BlockBaseGroup = BlockTab:AddLeftGroupbox('基础设置')
local BlockAdvGroup = BlockTab:AddRightGroupbox('高级设置')

BlockBaseGroup:AddToggle("BlockMainToggle", {
    Text = "开启自动格挡",
    Default = BlockConfig.Enabled,
    Callback = function(enabled)
        BlockConfig.Enabled = enabled
        local RunService = game:GetService("RunService")

        if combatConnection then combatConnection:Disconnect() end

        if enabled then
            combatConnection = RunService.Stepped:Connect(function()
                pcall(CombatLoop)
            end)
           
            if BlockConfig.ShowVisualization then
                CreateVisualization()
            end
        else
           
            for _, part in ipairs(visualizationParts) do part:Destroy() end
            visualizationParts = {}
        end

        local function onCharacterAdded(Character)
            if BlockConfig.Enabled then
                if combatConnection then combatConnection:Disconnect() end
                combatConnection = RunService.Stepped:Connect(function()
                    pcall(CombatLoop)
                end)
                if BlockConfig.ShowVisualization then
                    CreateVisualization()
                end
            end
        end
        if LocalPlayer.Character then
            onCharacterAdded(LocalPlayer.Character)
        end
        LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    end
})

BlockBaseGroup:AddSlider("BlockDistanceSlider", {
    Text = "检测距离（ studs）",
    Min = 5,
    Max = 30,
    Default = BlockConfig.BaseDistance,
    Rounding = 1,
    Callback = function(value)
        BlockConfig.BaseDistance = value
    end
})

BlockBaseGroup:AddSlider("BlockAngleSlider", {
    Text = "朝向检测角度（度）",
    Min = 10,
    Max = 180,
    Default = BlockConfig.TargetAngle,
    Rounding = 1,
    Callback = function(value)
        BlockConfig.TargetAngle = value
    end
})

BlockBaseGroup:AddToggle("BlockVisToggle", {
    Text = "显示检测范围（绿色）",
    Default = BlockConfig.ShowVisualization,
    Callback = function(enabled)
        BlockConfig.ShowVisualization = enabled
        if enabled then
            CreateVisualization()
        else
           
            for _, part in ipairs(visualizationParts) do part:Destroy() end
            visualizationParts = {}
        end
    end
})

BlockAdvGroup:AddSlider("BlockCooldownSlider", {
    Text = "格挡冷却时间（秒）",
    Min = 0.01,
    Max = 0.5,
    Default = BlockConfig.BlockCooldown,
    Rounding = 0.01,
    Callback = function(value)
        BlockConfig.BlockCooldown = value
    end
})

BlockAdvGroup:AddToggle("BlockPredictionToggle", {
    Text = "开启敌人位置预测",
    Default = BlockConfig.EnablePrediction,
    Callback = function(enabled)
        BlockConfig.EnablePrediction = enabled
    end
})

BlockAdvGroup:AddButton("BlockEmergencyStop", {
    Text = "紧急停止格挡",
    Func = function()
        BlockConfig.Enabled = false
        if combatConnection then combatConnection:Disconnect() end
        for _, part in ipairs(visualizationParts) do part:Destroy() end
        visualizationParts = {}
        BlockBaseGroup:SetValue("BlockMainToggle", false)
        BlockBaseGroup:SetValue("BlockVisToggle", false)
    end
})

BlockBaseGroup:SetValue("BlockDistanceSlider", BlockConfig.BaseDistance)
BlockBaseGroup:SetValue("BlockAngleSlider", BlockConfig.TargetAngle)
BlockAdvGroup:SetValue("BlockCooldownSlider", BlockConfig.BlockCooldown)
