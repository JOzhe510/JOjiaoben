local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

local Window = Library:CreateWindow({
    Title = '被遗弃自动防御',
    Center = true,
    AutoShow = true,
    Resizable = true
})

local SpeedGroup = Window:AddTab('通用加速'):AddLeftGroupbox('高速设置')
local SpeedMultiplier = { default = 1, boosted = 20 }
local isBoostEnabled = false
local moveConnection = nil
local jumpConnection = nil
local LocalPlayer = game:GetService("Players").LocalPlayer

SpeedGroup:AddSlider("SpeedMulti", {
    Text = "加速倍率",
    Min = 0,
    Max = 50,
    Default = SpeedMultiplier.boosted,
    Rounding = 1,
    Callback = function(value)
        SpeedMultiplier.boosted = value
    end
})

SpeedGroup:AddToggle("SpeedBoostToggle", {
    Text = "开启通用加速",
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
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
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

            if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
            LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:FindFirstChild("Modules") 
    and ReplicatedStorage.Modules:FindFirstChild("Network") 
    and ReplicatedStorage.Modules.Network:FindFirstChildOfClass("RemoteEvent") or nil

local CombatConfig = {
    EnableCombat = false,
    EnableBlock = true,
    EnableSlash = true,
    BaseDistance = 20,
    TargetAngle = 90,
    ScanInterval = 0.01,
    BlockCooldown = 0.1,
    SlashCooldown = 0.2,
    ShowVisualization = true,
    EnablePrediction = true,
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
local lastSlashTime = 0
local lastScanTime = 0
local visualizationParts = {}
local soundCache = {}
local lastSoundCheck = 0
local lastPingCheck = 0
local currentPing = 0
local soundLookup = {}

for _, id in ipairs(CombatConfig.TargetSoundIds) do
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
    local ping = GetPing()
    return math.min(0.5, ping / 1000 * 0.2 * 10)
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
        part.Size = Vector3.new(0.8, 0.2, 0.8)
        part.BrickColor = BrickColor.new("Bright green")
        part.Material = Enum.Material.Neon
        part.Transparency = 0.5
        part.Anchored = true
        part.CanCollide = false
        part.Parent = workspace
        table.insert(visualizationParts, part)
    end

    local RunService = game:GetService("RunService")
    local visConnection = RunService.Heartbeat:Connect(function()
        if not CombatConfig.ShowVisualization then
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
        local angle = math.rad(CombatConfig.TargetAngle)

        for i = 1, #visualizationParts - 1 do
            local part = visualizationParts[i + 1]
            local segAngle = (i - 1) * (2 * angle) / (#visualizationParts - 2) - angle
            local rotCFrame = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), segAngle)
            local dir = rotCFrame:VectorToWorldSpace(lookVector)
            part.Position = center + dir * CombatConfig.BaseDistance
        end
    end)
end

local function GetThreateningKillers()
    local killers = {}
    local possibleFolders = {
        workspace:FindFirstChild("Killers"),
        workspace:FindFirstChild("Enemies"),
        workspace:FindFirstChild("Monsters"),
        workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers"),
        workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Hostile")
    }

    local targetFolder = nil
    for _, folder in ipairs(possibleFolders) do
        if folder then
            targetFolder = folder
            break
        end
    end
    if not targetFolder then return killers end

    if not LocalPlayer.Character then return killers end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return killers end

    for _, killer in ipairs(targetFolder:GetChildren()) do
        if killer:IsA("Model") and killer:FindFirstChildOfClass("Humanoid") and killer:FindFirstChild("HumanoidRootPart") then
            local killerRoot = killer.HumanoidRootPart
            local distance = (myRoot.Position - killerRoot.Position).Magnitude
            local detectionRange = CombatConfig.BaseDistance + GetPingCompensation() * 5

            if distance <= detectionRange then
                table.insert(killers, killer)
            end
        end
    end

    return killers
end

local function PerformBlock()
    local now = os.clock()
    local adjustedCooldown = math.max(0.08, CombatConfig.BlockCooldown - (GetPing() / 1000 * 0.5))
    
    if CombatConfig.EnableBlock and now - lastBlockTime >= adjustedCooldown and RemoteEvent then
        pcall(function()
            local blockArgs1 = { "UseActorAbility", { buffer.fromstring("\"Block\"") } }
            local blockArgs2 = { "UseActorAbility", { Block = true } }
            
            RemoteEvent:FireServer(unpack(blockArgs1))
            task.delay(0.01, function()
                RemoteEvent:FireServer(unpack(blockArgs2))
            end)
            
            lastBlockTime = now
        end)
    end
end

local function PerformSlash()
    local now = os.clock()
    local adjustedCooldown = math.max(0.15, CombatConfig.SlashCooldown - (GetPing() / 1000 * 0.3))
    
    if CombatConfig.EnableSlash and now - lastSlashTime >= adjustedCooldown and RemoteEvent then
        pcall(function()
            local slashArgs1 = { "UseActorAbility", { buffer.fromstring("\"Slash\"") } }
            local slashArgs2 = { "UseActorAbility", { Slash = true } }
            
            RemoteEvent:FireServer(unpack(slashArgs1))
            task.delay(0.01, function()
                RemoteEvent:FireServer(unpack(slashArgs2))
            end)
            
            lastSlashTime = now
        end)
    end
end

local function CombatLoop()
    local currentTime = os.clock()
    if currentTime - lastScanTime >= CombatConfig.ScanInterval then
        lastScanTime = currentTime
        local threateningKillers = GetThreateningKillers()
        
        if #threateningKillers > 0 then
            PerformBlock()
            PerformSlash()
        end
    end
end

local CombatTab = Window:AddTab('自动攻防')
local CombatBaseGroup = CombatTab:AddLeftGroupbox('基础控制')
local CombatCooldownGroup = CombatTab:AddRightGroupbox('冷却调节')

CombatBaseGroup:AddToggle("CombatMainToggle", {
    Text = "开启自动攻防（格挡+挥砍）",
    Default = CombatConfig.EnableCombat,
    Callback = function(enabled)
        CombatConfig.EnableCombat = enabled
        local RunService = game:GetService("RunService")

        if combatConnection then combatConnection:Disconnect() end

        if enabled then
            combatConnection = RunService.Stepped:Connect(function()
                pcall(CombatLoop)
            end)
            if CombatConfig.ShowVisualization then
                CreateVisualization()
            end
        else
            for _, part in ipairs(visualizationParts) do part:Destroy() end
            visualizationParts = {}
        end

        local function onCharacterAdded(Character)
            if CombatConfig.EnableCombat then
                if combatConnection then combatConnection:Disconnect() end
                combatConnection = RunService.Stepped:Connect(function()
                    pcall(CombatLoop)
                end)
                if CombatConfig.ShowVisualization then
                    CreateVisualization()
                end
            end
        end
        if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
        LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    end
})

CombatBaseGroup:AddToggle("CombatBlockToggle", {
    Text = "启用自动格挡",
    Default = CombatConfig.EnableBlock,
    Callback = function(enabled)
        CombatConfig.EnableBlock = enabled
    end
})

CombatBaseGroup:AddToggle("CombatSlashToggle", {
    Text = "启用自动挥砍",
    Default = CombatConfig.EnableSlash,
    Callback = function(enabled)
        CombatConfig.EnableSlash = enabled
    end
})

CombatBaseGroup:AddSlider("CombatDistanceSlider", {
    Text = "检测距离（ studs）",
    Min = 5,
    Max = 40,
    Default = CombatConfig.BaseDistance,
    Rounding = 1,
    Callback = function(value)
        CombatConfig.BaseDistance = value
    end
})

CombatBaseGroup:AddSlider("CombatAngleSlider", {
    Text = "朝向检测角度（度）",
    Min = 10,
    Max = 180,
    Default = CombatConfig.TargetAngle,
    Rounding = 1,
    Callback = function(value)
        CombatConfig.TargetAngle = value
    end
})

CombatBaseGroup:AddToggle("CombatVisToggle", {
    Text = "显示检测范围（绿色）",
    Default = CombatConfig.ShowVisualization,
    Callback = function(enabled)
        CombatConfig.ShowVisualization = enabled
        if enabled then
            CreateVisualization()
        else
            for _, part in ipairs(visualizationParts) do part:Destroy() end
            visualizationParts = {}
        end
    end
})

CombatCooldownGroup:AddSlider("CombatBlockCooldownSlider", {
    Text = "格挡冷却时间（秒）",
    Min = 0.05,
    Max = 0.5,
    Default = CombatConfig.BlockCooldown,
    Rounding = 0.01,
    Callback = function(value)
        CombatConfig.BlockCooldown = value
    end
})

CombatCooldownGroup:AddSlider("CombatSlashCooldownSlider", {
    Text = "挥砍冷却时间（秒）",
    Min = 0.1,
    Max = 1,
    Default = CombatConfig.SlashCooldown,
    Rounding = 0.01,
    Callback = function(value)
        CombatConfig.SlashCooldown = value
    end
})

CombatCooldownGroup:AddButton("CombatEmergencyStop", {
    Text = "紧急停止自动攻防",
    Func = function()
        CombatConfig.EnableCombat = false
        CombatConfig.ShowVisualization = false
        if combatConnection then combatConnection:Disconnect() end
        for _, part in ipairs(visualizationParts) do part:Destroy() end
        visualizationParts = {}
        CombatBaseGroup:SetValue("CombatMainToggle", false)
        CombatBaseGroup:SetValue("CombatVisToggle", false)
    end
})

CombatBaseGroup:SetValue("CombatDistanceSlider", CombatConfig.BaseDistance)
CombatBaseGroup:SetValue("CombatAngleSlider", CombatConfig.TargetAngle)
CombatCooldownGroup:SetValue("CombatBlockCooldownSlider", CombatConfig.BlockCooldown)
CombatCooldownGroup:SetValue("CombatSlashCooldownSlider", CombatConfig.SlashCooldown)