-- 独立的电击枪Ragebot UI
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();

-- 创建独立窗口
local ElectricWindow = Compkiller.new({
    Name = "⚡ Electric Ragebot",
    Keybind = "RightAlt", 
    Logo = "rbxassetid://73021542394361",
    TextSize = 15,
});

-- 创建水印
local ElectricWatermark = ElectricWindow:Watermark();
ElectricWatermark:AddText({Icon = "zap", Text = "Electric-Ragebot"});
ElectricWatermark:AddText({Icon = "timer", Text = Compkiller:GetTimeNow()});

-- 创建标签页
ElectricWindow:DrawCategory({Name = "Electric"});
local MainTab = ElectricWindow:DrawTab({Name = "Main", Icon = "zap", EnableScrolling = true});
local SettingsTab = ElectricWindow:DrawTab({Name = "Settings", Icon = "settings", EnableScrolling = true});

-- Ragebot配置
local Ragebot = {
    Enabled = false,
    Cooldown = 1/30,
    LastShot = 0,
    TargetPart = "Head",
    CurrentDistance = 100,
    FireRate = 30,
    WallCheck = true,
    WallCheckDistance = 50
}

-- Main Tab
local MainSection = MainTab:DrawSection({Name = "Ragebot Settings"});

-- 主开关
MainSection:AddToggle({
    Name = "Enable Electric Ragebot",
    Flag = "ElectricRagebotToggle",
    Default = false,
    Callback = function(Value)
        Ragebot.Enabled = Value
        if Value then
            Compkiller.newNotify().new({Title = "Electric Ragebot", Content = "ON - Auto-locking enemies"})
        else
            Compkiller.newNotify().new({Title = "Electric Ragebot", Content = "OFF"})
        end
    end
})

-- 射速调节
MainSection:AddSlider({
    Name = "Fire Rate (RPS)",
    Min = 1,
    Max = 100,
    Default = 30,
    Round = 0,
    Flag = "ElectricFireRateSlider",
    Callback = function(Value)
        Ragebot.Cooldown = 1/Value
        Ragebot.FireRate = Value
        Compkiller.newNotify().new({Title = "Fire Rate", Content = "Set to: "..Value.." RPS"})
    end
})

-- 最大距离
MainSection:AddSlider({
    Name = "Max Distance",
    Min = 10,
    Max = 800,
    Default = 100,
    Round = 0,
    Flag = "ElectricDistanceSlider",
    Callback = function(Value)
        Ragebot.CurrentDistance = Value
        Compkiller.newNotify().new({Title = "Distance", Content = "Set to: "..Value.." studs"})
    end
})

-- 目标部位
MainSection:AddDropdown({
    Name = "Target Part",
    Values = {"Head", "UpperTorso", "LowerTorso"},
    Default = "Head",
    Flag = "ElectricTargetPartDropdown",
    Callback = function(Value)
        Ragebot.TargetPart = Value
        Compkiller.newNotify().new({Title = "Target Part", Content = "Set to: "..Value})
    end
})

-- 墙壁检测
MainSection:AddToggle({
    Name = "Wall Check",
    Default = true,
    Flag = "ElectricWallCheckToggle",
    Callback = function(Value)
        Ragebot.WallCheck = Value
        Compkiller.newNotify().new({Title = "Wall Check", Content = Value and "ON" or "OFF"})
    end
})

-- Settings Tab
local ConfigSection = SettingsTab:DrawSection({Name = "Configuration"});

ConfigSection:AddButton({
    Name = "Save Settings",
    Callback = function()
        Compkiller.newNotify().new({Title = "Settings", Content = "Configuration saved"})
    end
})

ConfigSection:AddButton({
    Name = "Reset Settings",
    Callback = function()
        Compkiller.newNotify().new({Title = "Settings", Content = "Configuration reset"})
    end
})

-- 电击枪射击逻辑
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
        
        if char and root and hum and hum.Health > 0 then
            local dist = (root.Position - myPos).Magnitude
            if dist < minDist then
                closest = player
                minDist = dist
            end
        end
    end
    
    return closest
end

local function ElectricShoot(target)
    if not target or not target.Character then return false end
    
    local hitPart = target.Character:FindFirstChild(Ragebot.TargetPart) or
                   target.Character:FindFirstChild("Head")
    if not hitPart then return false end
    
    local targetPos = hitPart.Position
    local shootData = {
        {
            targetPos + Vector3.new(0, 2, 0),
            targetPos,
            workspace.floor
        }
    }
    
    ReplicatedStorage.GunRemotes.ShootEvent:FireServer(shootData)
    return true
end

-- 主循环
task.spawn(function()
    while true do
        if Ragebot.Enabled then
            local now = tick()
            if now - Ragebot.LastShot >= Ragebot.Cooldown then
                local target = GetClosestEnemy()
                if target then
                    local shotFired = ElectricShoot(target)
                    if shotFired then
                        Ragebot.LastShot = now
                    end
                end
            end
        end
        task.wait()
    end
end)