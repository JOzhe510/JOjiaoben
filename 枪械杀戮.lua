local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
local Notifier = Compkiller.newNotify();

-- 显示加载界面
Compkiller:Loader("rbxassetid://73021542394361", 2.5).yield();

-- 创建主窗口
local Window = Compkiller.new({
    Name = "XXTI [Ragebot Only]",
    Keybind = "LeftAlt",
    Logo = "rbxassetid://73021542394361",
    TextSize = 15,
});

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 创建标签页
Window:DrawCategory({Name = "Main"});
local CombatTab = Window:DrawTab({Name = "Ragebot", Icon = "swords", EnableScrolling = true});

-- Ragebot Config
local Ragebot = {
    Enabled = false,
    Cooldown = 1/30,
    LastShot = 0,
    DownedCheck = false,
    TargetPart = "Head",
    MaxDistance = 800,
    CurrentDistance = 100,
    FireRate = 30,
    WallCheck = true,
    WallCheckDistance = 50,
    WallCheckParts = {"Head", "UpperTorso", "LowerTorso"},
    LastNotificationTime = 0
}

local visibilityCache = {}
local lastCacheClear = tick()

-- Functions
local function UpdateFireRate(rps)
    if type(rps) ~= "number" or rps < 1 or rps > 100 then
        Notifier.new({Title = "Error", Content = "Invalid RPS (1-100)"})
        return
    end
    Ragebot.Cooldown = 1/rps
    Ragebot.FireRate = rps
    Notifier.new({Title = "Success", Content = "Fire rate set to: "..rps.." RPS"})
end

local function RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    local str = ""
    for i = 1, length do
        str = str .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return str
end

local function IsVisible(targetPart)
    if not Ragebot.WallCheck then return true end
    
    if tick() - lastCacheClear > 5 then
        visibilityCache = {}
        lastCacheClear = tick()
    end
    
    local cacheKey = targetPart:GetFullName()..tostring(math.floor(tick()*10)/10)
    if visibilityCache[cacheKey] ~= nil then
        return visibilityCache[cacheKey]
    end
    
    local cameraPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local direction = (targetPos - cameraPos).Unit
    local distance = (targetPos - cameraPos).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(cameraPos, direction * distance, raycastParams)
    
    if raycastResult then
        local hitDistance = (raycastResult.Position - cameraPos).Magnitude
        visibilityCache[cacheKey] = hitDistance > (distance - Ragebot.WallCheckDistance)
        return visibilityCache[cacheKey]
    end
    
    visibilityCache[cacheKey] = true
    return true
end

local function GetClosestEnemy()
    if not LocalPlayer.Character then return nil end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local closest, minDist = nil, Ragebot.CurrentDistance
    local myPos = myRoot.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char then continue end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if char and root and hum and hum.Health > 0 and not char:FindFirstChildOfClass("ForceField") then
            if Ragebot.DownedCheck and (hum.Health <= 15 or hum:GetState() == Enum.HumanoidStateType.Dead) then continue end
            
            local dist = (root.Position - myPos).Magnitude
            if dist < minDist and dist <= Ragebot.CurrentDistance then
                for _, partName in ipairs(Ragebot.WallCheckParts) do
                    local part = char:FindFirstChild(partName)
                    if part and IsVisible(part) then
                        closest = player
                        minDist = dist
                        break
                    end
                end
            end
        end
    end
    
    return closest
end

local function Shoot(target)
    if not target or not target.Character then return false end
    
    local hitPart = target.Character:FindFirstChild(Ragebot.TargetPart) or
                   target.Character:FindFirstChild("Head") or
                   target.Character:FindFirstChild("UpperTorso")
    if not hitPart then return false end
    
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return false end
    
    -- 弹药检查 - 使用 Ammo 而不是 SERVER_Ammo
    local ammo = tool:FindFirstChild("Ammo")
    if not ammo or ammo.Value <= 0 then
        return false
    end
    
    local hitPos = hitPart.Position
    local shootPos = Camera.CFrame.Position
    
    local dir = (hitPos - shootPos).Unit
    
    -- 使用 fire 事件而不是 GNX_S
    ReplicatedStorage.Events.fire:FireServer(
        tool,
        shootPos,
        hitPos,
        dir
    )
    
    return true
end

-- Ragebot 主循环
task.spawn(function()
    while true do
        if Ragebot.Enabled then
            local now = tick()
            if now - Ragebot.LastShot >= Ragebot.Cooldown then
                local target = GetClosestEnemy()
                if target then
                    local shotFired = Shoot(target)
                    if shotFired then
                        Ragebot.LastShot = now
                    end
                end
            end
        end
        task.wait()
    end
end)

-- ========== UI SETUP ========== --

-- Combat Tab
local CombatSection = CombatTab:DrawSection({Name = "Ragebot Settings"});

-- 主开关
CombatSection:AddToggle({
    Name = "Enable Ragebot",
    Flag = "RagebotToggle",
    Default = false,
    Callback = function(Value)
        Ragebot.Enabled = Value
    end
})

-- 射速调节
CombatSection:AddSlider({
    Name = "Fire Rate (RPS)",
    Min = 1,
    Max = 100,
    Default = 30,
    Round = 0,
    Flag = "FireRateSlider",
    Callback = UpdateFireRate
})

-- 忽略倒地玩家
CombatSection:AddToggle({
    Name = "Ignore Downed Players",
    Default = false,
    Tooltip = "Skip players with low health",
    Flag = "DownedCheck",
    Callback = function(Value)
        Ragebot.DownedCheck = Value
    end
})

-- 墙壁检测
CombatSection:AddToggle({
    Name = "Wall Check",
    Default = true,
    Tooltip = "Don't shoot through walls",
    Flag = "WallCheckToggle",
    Callback = function(Value)
        Ragebot.WallCheck = Value
    end
})

-- 墙壁穿透距离
CombatSection:AddSlider({
    Name = "Wall Penetration",
    Min = 0,
    Max = 100,
    Default = 20,
    Round = 0,
    Tooltip = "How much wall penetration to allow",
    Flag = "WallCheckDistance",
    Callback = function(Value)
        Ragebot.WallCheckDistance = Value
    end
})

-- 最大距离
CombatSection:AddTextBox({
    Name = "Max Distance (1-800)",
    Placeholder = "Set Distance",
    Default = "100",
    Flag = "DistanceInput",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 1 and num <= 800 then
            Ragebot.MaxDistance = num
            Ragebot.CurrentDistance = num
            Notifier.new({Title = "Success", Content = "Distance set to: "..num.." studs"})
        else
            Notifier.new({Title = "Error", Content = "Invalid distance (must be 1-800)"})
        end
    end
})

-- 目标部位
CombatSection:AddDropdown({
    Name = "Target Part",
    Values = {"Head", "UpperTorso", "LowerTorso", "Random"},
    Default = "Head",
    Flag = "TargetPartDropdown",
    Callback = function(Value)
        Ragebot.TargetPart = Value == "Random" and 
            ({"Head","UpperTorso","LowerTorso"})[math.random(1,3)] or Value
    end
})

print("Ragebot Script loaded! Press Left Alt to toggle UI.")