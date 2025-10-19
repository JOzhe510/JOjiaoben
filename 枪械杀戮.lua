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
    WallCheck = false,
}

local originalFireEvent
local isHooked = false

-- 获取当前武器的Fire事件
local function GetCurrentWeaponFireEvent()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    
    local weaponData = ReplicatedStorage.Weapons:FindFirstChild(tool.Name)
    if weaponData then
        local sync = weaponData:FindFirstChild("Sync")
        if sync then
            return sync:FindFirstChild("Fire")
        end
    end
    return nil
end

-- 钩住Fire事件
local function HookFireEvent()
    if isHooked then return end
    
    local fireEvent = GetCurrentWeaponFireEvent()
    if not fireEvent then return end
    
    -- 保存原事件
    originalFireEvent = fireEvent.FireServer
    isHooked = true
    
    -- 重写FireServer方法
    fireEvent.FireServer = function(self, bulletData)
        if Ragebot.Enabled and bulletData then
            local target = GetClosestEnemy()
            if target and target.Character then
                local hitPart = target.Character:FindFirstChild(Ragebot.TargetPart)
                if hitPart then
                    -- 修改子弹数据中的命中位置
                    bulletData.Hit = hitPart.Position
                    bulletData.Direction = (hitPart.Position - bulletData.Origin).Unit
                end
            end
        end
        -- 调用原事件
        return originalFireEvent(self, bulletData)
    end
end

-- 简单的目标获取
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
        
        if root and hum and hum.Health > 0 then
            local dist = (root.Position - myPos).Magnitude
            if dist < minDist then
                closest = player
                minDist = dist
            end
        end
    end
    
    return closest
end

-- 自动钩住事件
task.spawn(function()
    while true do
        if not isHooked then
            HookFireEvent()
        end
        task.wait(1)
    end
end)

-- ========== UI SETUP ========== --
local CombatSection = CombatTab:DrawSection({Name = "Ragebot Settings"});

CombatSection:AddToggle({
    Name = "启用自动瞄准",
    Flag = "RagebotToggle",
    Default = false,
    Callback = function(Value)
        Ragebot.Enabled = Value
    end
})

CombatSection:AddSlider({
    Name = "射速 (RPS)",
    Min = 1,
    Max = 100,
    Default = 30,
    Round = 0,
    Flag = "FireRateSlider",
    Callback = function(Value)
        Ragebot.Cooldown = 1/Value
        Ragebot.FireRate = Value
    end
})

CombatSection:AddTextBox({
    Name = "最大距离",
    Placeholder = "100",
    Default = "100",
    Flag = "DistanceInput",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            Ragebot.CurrentDistance = num
        end
    end
})

CombatSection:AddDropdown({
    Name = "目标部位",
    Values = {"Head", "UpperTorso", "LowerTorso"},
    Default = "Head",
    Flag = "TargetPartDropdown",
    Callback = function(Value)
        Ragebot.TargetPart = Value
    end
})

print("自动瞄准脚本加载完成! 按左Alt打开菜单")