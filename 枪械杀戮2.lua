-- 电击枪专用Ragebot - 诊断版
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
    WallCheck = true
}

-- 诊断函数：找出正确的远程事件
local function FindShootEvents()
    print("🔍 开始查找射击相关事件...")
    
    -- 检查ReplicatedStorage中的所有远程事件
    for _, child in pairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            local name = child.Name:lower()
            if name:find("shoot") or name:find("fire") or name:find("taser") or name:find("gun") then
                print("🎯 找到可能的事件:", child:GetFullName(), "类型:", child.ClassName)
            end
        end
    end
    
    -- 检查玩家背包中的工具
    if LocalPlayer.Backpack then
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                print("🛠️ 找到工具:", tool.Name)
                -- 检查工具内部的事件
                for _, child in pairs(tool:GetDescendants()) do
                    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                        print("   🔧 工具内事件:", child.Name, "类型:", child.ClassName)
                    end
                end
            end
        end
    end
end

-- 监听其他玩家的射击来学习参数
local function SetupEventSpy()
    -- 监听所有远程事件
    for _, event in pairs(ReplicatedStorage:GetDescendants()) do
        if event:IsA("RemoteEvent") then
            pcall(function()
                event.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local eventName = event.Name
                    if eventName:lower():find("shoot") or eventName:lower():find("hit") then
                        print("📡 监听到射击事件:", eventName)
                        print("   参数:", ...)
                    end
                end)
            end)
        end
    end
end

-- 获取当前武器
local function GetCurrentWeapon()
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            return tool
        end
    end
    return nil
end

-- 装备电击枪
local function EquipTaser()
    if not LocalPlayer.Backpack then return nil end
    
    -- 尝试常见名称
    local weaponNames = {"Taser", "TaserGun", "StunGun", "ElectricGun", "Gun"}
    
    for _, name in pairs(weaponNames) do
        local weapon = LocalPlayer.Backpack:FindFirstChild(name)
        if weapon and weapon:IsA("Tool") then
            LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(weapon)
            print("🔫 装备武器:", name)
            return weapon
        end
    end
    
    -- 尝试名称包含关键词的工具
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local lowerName = tool.Name:lower()
            if lowerName:find("taser") or lowerName:find("stun") or lowerName:find("electric") or lowerName:find("gun") then
                LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(tool)
                print("🔫 装备武器:", tool.Name)
                return tool
            end
        end
    end
    
    print("❌ 未找到合适的武器")
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

-- 尝试所有可能的射击方法
local function TryAllShootMethods(targetPos)
    local weapon = GetCurrentWeapon() or EquipTaser()
    if not weapon then
        print("❌ 没有武器可用")
        return false
    end
    
    local success = false
    local methods = {
        {"GunRemotes", "ShootEvent"},
        {"WeaponRemotes", "Fire"},
        {"CombatRemotes", "Shoot"},
        {"TaserRemotes", "Shoot"},
        {"GunSystem", "Shoot"},
        {"WeaponSystem", "Fire"}
    }
    
    for _, method in pairs(methods) do
        local folder = ReplicatedStorage:FindFirstChild(method[1])
        if folder then
            local event = folder:FindFirstChild(method[2])
            if event and (event:IsA("RemoteEvent") or event:IsA("RemoteFunction")) then
                print("🎯 尝试方法:", method[1] .. "." .. method[2])
                
                -- 尝试不同参数组合
                local paramCombinations = {
                    {weapon, targetPos},
                    {targetPos, weapon},
                    {
                        Start = LocalPlayer.Character.Head.Position,
                        End = targetPos,
                        Weapon = weapon
                    },
                    {
                        weapon = weapon,
                        target = targetPos,
                        player = LocalPlayer
                    }
                }
                
                for i, params in ipairs(paramCombinations) do
                    pcall(function()
                        if event:IsA("RemoteEvent") then
                            event:FireServer(unpack(params))
                        else
                            event:InvokeServer(unpack(params))
                        end
                        success = true
                        print("✅ 成功使用:", method[1] .. "." .. method[2], "参数组合", i)
                        return true
                    end)
                    if success then break end
                end
            end
        end
        if success then break end
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
                        
                        local shotSuccess = TryAllShootMethods(targetPos)
                        
                        if shotSuccess then
                            Ragebot.LastShot = now
                            print("⚡ 成功射击:", target.Name)
                        else
                            print("❌ 所有射击方法都失败了")
                        end
                    end
                end
            end
        end
        task.wait()
    end
end)

-- 创建UI
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();

local ElectricWindow = Compkiller.new({
    Name = "⚡ Electric Ragebot - 诊断版",
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
            -- 自动装备武器
            task.wait(0.5)
            EquipTaser()
        else
            Compkiller.newNotify().new({Title = "Electric Ragebot", Content = "OFF"})
        end
    end
})

-- 诊断按钮
MainSection:AddButton({
    Name = "🔍 诊断射击事件",
    Callback = function()
        FindShootEvents()
        Compkiller.newNotify().new({Title = "诊断", Content = "检查输出窗口查看结果"})
    end
})

-- 监听按钮
MainSection:AddButton({
    Name = "📡 开始监听事件",
    Callback = function()
        SetupEventSpy()
        Compkiller.newNotify().new({Title = "监听", Content = "开始监听射击事件"})
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

print("⚡ Electric Ragebot 诊断版加载完成!")
print("📝 使用方法:")
print("1. 点击'诊断射击事件'查看可用事件")
print("2. 点击'开始监听事件'学习参数")
print("3. 开启主开关测试射击")

-- 自动开始诊断
task.wait(2)
FindShootEvents()