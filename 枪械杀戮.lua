local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
local Notifier = Compkiller.newNotify();
local ConfigManager = Compkiller:ConfigManager({
	Directory = "Compkiller-UI",
	Config = "XXTI-Free"
});

-- 显示加载界面
Compkiller:Loader("rbxassetid://73021542394361", 2.5).yield();

-- 创建主窗口
local Window = Compkiller.new({
	Name = "XXTI [FREE]",
	Keybind = "LeftAlt",
	Logo = "rbxassetid://73021542394361",
	TextSize = 15,
});

-- 创建水印
local Watermark = Window:Watermark();
Watermark:AddText({Icon = "user", Text = "XXTI-Free"});
Watermark:AddText({Icon = "clock", Text = Compkiller:GetDate()});
local Time = Watermark:AddText({Icon = "timer", Text = "TIME"});
task.spawn(function() while task.wait() do Time:SetText(Compkiller:GetTimeNow()) end end)
Watermark:AddText({Icon = "server", Text = Compkiller.Version});

-- 创建标签页
Window:DrawCategory({Name = "Main"});
local CombatTab = Window:DrawTab({Name = "Combat", Icon = "swords", EnableScrolling = true});
local SettingsTab = Window:DrawTab({Name = "Settings", Icon = "settings-3", EnableScrolling = true});

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 获取头顶位置
local function GetHeadPosition()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        return LocalPlayer.Character.Head.Position
    end
    return Camera.CFrame.Position -- 备用方案
end

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
    PlayHitSound = true,
    WallCheck = true,
    WallCheckDistance = 50,
    WallCheckParts = {"Head", "UpperTorso", "LowerTorso"}
}

local visibilityCache = {}
local lastCacheClear = tick()

-- Functions
local function PlayHitSound()
    if not Ragebot.PlayHitSound then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://4817809188"
    sound.Volume = 1
    sound.Parent = workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

local function UpdateFireRate(rps)
    if type(rps) ~= "number" or rps < 1 or rps > 100 then
        Notifier.new({Title = "Error", Content = "Invalid RPS (1-100)"})
        return
    end
    Ragebot.Cooldown = 1/rps
    Ragebot.FireRate = rps
    Notifier.new({Title = "Success", Content = "Fire rate set to: "..rps.." RPS"})
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

local function RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    local str = ""
    for i = 1, length do
        str = str .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return str
end

local function Shoot(target)
    if not target or not target.Character then return false end
    
    local hitPart = target.Character:FindFirstChild(Ragebot.TargetPart) or
                   target.Character:FindFirstChild("Head") or
                   target.Character:FindFirstChild("UpperTorso")
    if not hitPart then return false end
    
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return false end
    
    -- 弹药检查 - 使用Ammo而不是SERVER_Ammo
    local values = tool:FindFirstChild("Values")
    if not values then return false end
    
    local ammo = values:FindFirstChild("Ammo")
    if not ammo or ammo.Value <= 0 then
        return false
    end
    
    local hitPos = hitPart.Position
    local shootPos = GetHeadPosition()
    
    local dir = (hitPos - shootPos).Unit
    local key = RandomString(30) .. "0"
    
    ReplicatedStorage.Events.GNX_S:FireServer(
        tick(),
        key,
        tool,
        "FDS9I83",
        shootPos,
        { dir },
        false
    )
    
    ReplicatedStorage.Events["ZFKLF__H"]:FireServer(
        "🧈",
        tool,
        key,
        1,
        hitPart,
        hitPos,
        dir
    )
    
    if tool:FindFirstChild("Hitmarker") then
        tool.Hitmarker:Fire(hitPart)
        PlayHitSound()
    end
    
    return true
end

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
local RagebotToggle = CombatSection:AddToggle({
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

-- 音效开关
CombatSection:AddToggle({
    Name = "Hit Sound",
    Default = true,
    Tooltip = "Play hit sound effect",
    Flag = "HitSoundToggle",
    Callback = function(Value)
        Ragebot.PlayHitSound = Value
    end
})

-- 忽略倒地玩家
CombatSection:AddToggle({
    Name = "Ignore Downed Players",
    Default = false,
    Tooltip = "Don't shoot downed players",
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

-- Settings Tab
local UISettings = SettingsTab:DrawSection({Name = "UI Settings"});

-- UI可见性
UISettings:AddToggle({
    Name = "Show UI",
    Default = true,
    Tooltip = "Toggle UI visibility",
    Flag = "UI_Toggle",
    Callback = function(Value)
        Window:SetVisibility(Value)
    end
})

-- UI透明度
UISettings:AddSlider({
    Name = "UI Opacity",
    Min = 0,
    Max = 100,
    Default = 100,
    Round = 0,
    Tooltip = "Adjust UI transparency",
    Flag = "UI_Opacity",
    Callback = function(Value)
        Window:SetTransparency(1 - (Value/100))
    end
})

-- UI主题
UISettings:AddDropdown({
    Name = "UI Theme",
    Values = {"Default", "Dark", "Light", "Aqua"},
    Default = "Default",
    Tooltip = "Change UI color scheme",
    Flag = "UI_Theme",
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

print("XXTI Script fully loaded! Press Left Alt to toggle UI.")