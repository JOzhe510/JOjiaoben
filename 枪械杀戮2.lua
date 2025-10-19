-- 电击枪专用Ragebot
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ragebot配置
local Ragebot = {
    Enabled = false,
    Cooldown = 1/30,
    LastShot = 0,
    TargetPart = "Head",
    CurrentDistance = 100,
    FireRate = 30,
    WallCheck = true,
    MouseHit = true, -- 添加鼠标目标支持
    EquipWeapon = true -- 自动装备武器
}

-- 获取当前武器
local function GetCurrentWeapon()
    if LocalPlayer.Character then
        return LocalPlayer.Character:FindFirstChildOfClass("Tool")
    end
    return nil
end

-- 装备电击枪
local function EquipTaser()
    if not LocalPlayer.Backpack then return nil end
    
    local taser = LocalPlayer.Backpack:FindFirstChild("Taser") or 
                  LocalPlayer.Backpack:FindFirstChild("TaserGun") or
                  LocalPlayer.Backpack:FindFirstChild("StunGun") or
                  LocalPlayer.Backpack:FindFirstChild("ElectricGun")
    
    if taser then
        LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(taser)
        return taser
    end
    
    -- 尝试通过名称匹配
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (string.lower(tool.Name):find("taser") or 
           string.lower(tool.Name):find("stun") or 
           string.lower(tool.Name):find("electric")) then
            LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(tool)
            return tool
        end
    end
    
    return nil
end

-- 获取最近敌人
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

-- 获取鼠标目标（备用方法）
local function GetMouseTarget()
    if not LocalPlayer:GetMouse() then return nil end
    return LocalPlayer:GetMouse().Hit
end

-- 模拟鼠标点击
local function SimulateMouseClick()
    if Ragebot.MouseHit then
        -- 尝试模拟真实点击
        mouse1click()
        task.wait(0.05)
        mouse1release()
    end
end

-- 发送射击事件（改进版）
local function SendShootEvent(targetPos, weapon)
    local currentWeapon = weapon or GetCurrentWeapon()
    
    if not currentWeapon then
        if Ragebot.EquipWeapon then
            currentWeapon = EquipTaser()
            task.wait(0.1) -- 等待武器装备
        end
        if not currentWeapon then
            print("❌ 未找到武器")
            return false
        end
    end
    
    -- 尝试多种射击参数格式
    local success = false
    
    -- 方法1: 带武器引用的射击
    pcall(function()
        ReplicatedStorage.GunRemotes.ShootEvent:FireServer(currentWeapon, targetPos)
        success = true
        print("✅ 射击方法1成功")
    end)
    
    if not success then
        -- 方法2: 带时间戳的射击
        pcall(function()
            ReplicatedStorage.GunRemotes.ShootEvent:FireServer({
                weapon = currentWeapon,
                position = targetPos,
                timestamp = tick(),
                origin = LocalPlayer.Character.Head.Position
            })
            success = true
            print("✅ 射击方法2成功")
        end)
    end
    
    if not success then
        -- 方法3: 原始方法但带更多参数
        pcall(function()
            ReplicatedStorage.GunRemotes.ShootEvent:FireServer(
                currentWeapon,
                targetPos,
                tick(),
                LocalPlayer.Character.Head.Position
            )
            success = true
            print("✅ 射击方法3成功")
        end)
    end
    
    if not success then
        -- 方法4: 尝试鼠标点击方式
        pcall(function()
            SimulateMouseClick()
            success = true
            print("✅ 使用鼠标点击方式")
        end)
    end
    
    return success
end

-- 自动射击循环
task.spawn(function()
    while true do
        if Ragebot.Enabled then
            local now = tick()
            if now - Ragebot.LastShot >= Ragebot.Cooldown then
                local target = GetClosestEnemy()
                if target and target.Character then
                    local hitPart = target.Character:FindFirstChild(Ragebot.TargetPart) or
                                   target.Character:FindFirstChild("Head") or
                                   target.Character:FindFirstChild("HumanoidRootPart")
                    
                    if hitPart then
                        local targetPos = hitPart.Position
                        
                        -- 添加随机偏移避免检测
                        local offset = Vector3.new(
                            math.random(-0.1, 0.1),
                            math.random(-0.1, 0.1), 
                            math.random(-0.1, 0.1)
                        )
                        targetPos = targetPos + offset
                        
                        local shotSuccess = SendShootEvent(targetPos)
                        
                        if shotSuccess then
                            Ragebot.LastShot = now
                            print("⚡ Electric Shot at:", target.Name)
                        else
                            print("❌ 射击失败")
                        end
                    end
                end
            end
        end
        task.wait()
    end
end)

-- 创建简单UI
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();

local ElectricWindow = Compkiller.new({
    Name = "⚡ Electric Ragebot",
    Keybind = "RightAlt",
    Logo = "rbxassetid://73021542394361",
    TextSize = 15,
});

ElectricWindow:DrawCategory({Name = "Electric"});
local MainTab = ElectricWindow:DrawTab({Name = "Main", Icon = "zap", EnableScrolling = true});

local MainSection = MainTab:DrawSection({Name = "Ragebot Settings"});

-- 主开关
MainSection:AddToggle({
    Name = "Enable Electric Ragebot",
    Flag = "ElectricRagebotToggle",
    Default = false,
    Callback = function(Value)
        Ragebot.Enabled = Value
        if Value then
            Compkiller.newNotify().new({Title = "Electric Ragebot", Content = "ON - Auto-shooting enemies"})
            -- 自动尝试装备武器
            if Ragebot.EquipWeapon then
                task.wait(0.5)
                EquipTaser()
            end
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
    Values = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    Default = "Head",
    Flag = "ElectricTargetPartDropdown",
    Callback = function(Value)
        Ragebot.TargetPart = Value
        Compkiller.newNotify().new({Title = "Target Part", Content = "Set to: "..Value})
    end
})

-- 自动装备武器
MainSection:AddToggle({
    Name = "Auto Equip Weapon",
    Flag = "AutoEquipToggle",
    Default = true,
    Callback = function(Value)
        Ragebot.EquipWeapon = Value
        Compkiller.newNotify().new({Title = "Auto Equip", Content = Value and "ON" or "OFF"})
    end
})

-- 鼠标点击模式
MainSection:AddToggle({
    Name = "Use Mouse Click",
    Flag = "MouseClickToggle",
    Default = false,
    Callback = function(Value)
        Ragebot.MouseHit = Value
        Compkiller.newNotify().new({Title = "Mouse Mode", Content = Value and "ON" or "OFF"})
    end
})

print("⚡ Electric Ragebot loaded! Press RightAlt to toggle UI.")
print("🔫 Features: Auto equip, Multiple shoot methods, Anti-detection")