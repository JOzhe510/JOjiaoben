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
local HttpService = game:GetService("HttpService")

-- 创建标签页
Window:DrawCategory({Name = "Main"});
local CombatTab = Window:DrawTab({Name = "Ragebot", Icon = "swords", EnableScrolling = true});

-- Ragebot Config
local Ragebot = {
    Enabled = false,
    Cooldown = 1/30,
    LastShot = 0,
    TargetPart = "Head",
    MaxDistance = 800,
    CurrentDistance = 100,
    FireRate = 30,
    WallCheck = false,
}

-- 生成随机数据
local function GenerateRandomData()
    return {
        Timestamp = tick(),
        RandomID = HttpService:GenerateGUID(false),
        Seed = math.random(1, 1000000),
        ClientTick = os.time(),
        SessionID = math.random(1000, 9999)
    }
end

-- 生成伪装子弹数据
local function GenerateFakeBulletData(origin, hit, direction)
    local randomData = GenerateRandomData()
    
    return {
        -- 真实数据
        Origin = origin,
        Hit = hit,
        Direction = direction,
        
        -- 伪装数据
        ClientTime = randomData.Timestamp,
        RandomSeed = randomData.Seed,
        SessionID = randomData.SessionID,
        BulletID = randomData.RandomID,
        
        -- 物理参数
        Velocity = direction * math.random(800, 1200),
        Spread = Vector3.new(
            (math.random() - 0.5) * 0.01,
            (math.random() - 0.5) * 0.01,
            (math.random() - 0.5) * 0.01
        ),
        
        -- 武器数据
        WeaponType = "Rifle",
        Damage = math.random(25, 35),
        Penetration = math.random(1, 3),
        
        -- 网络数据
        NetworkTimestamp = os.time(),
        ClientID = LocalPlayer.UserId,
        Sequence = math.random(1, 1000)
    }
end

-- 生成伪装射击参数
local function GenerateFakeShootParams()
    local randomData = GenerateRandomData()
    
    return {
        -- 基础参数
        ShootTime = randomData.Timestamp,
        WeaponState = "Firing",
        AmmoCount = math.random(15, 30),
        
        -- 随机偏移
        Recoil = Vector3.new(
            (math.random() - 0.5) * 0.05,
            (math.random() - 0.5) * 0.05,
            0
        ),
        
        -- 网络验证
        Checksum = math.random(100000, 999999),
        AuthToken = randomData.RandomID:sub(1, 8),
        
        -- 客户端信息
        ClientVersion = "1.0.0",
        Platform = "Windows"
    }
end

-- 搜索 ViewModel.Gun 下的 Fire 和 DryFire 事件
local function FindGunEvents()
    local viewModel = workspace:FindFirstChild("ViewModel")
    if not viewModel then 
        return nil, nil 
    end
    
    local gun = viewModel:FindFirstChild("Gun")
    if not gun then 
        return nil, nil 
    end
    
    local fireEvent = gun:FindFirstChild("Fire")
    local dryFireEvent = gun:FindFirstChild("DryFire")
    
    return fireEvent, dryFireEvent
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

-- 新的射击函数 - 使用伪装数据包
local function Shoot()
    local target = GetClosestEnemy()
    if not target or not target.Character then 
        return false 
    end
    
    local hitPart = target.Character:FindFirstChild(Ragebot.TargetPart)
    if not hitPart then
        return false
    end
    
    -- 搜索 gun 事件
    local fireEvent, dryFireEvent = FindGunEvents()
    
    local hitPos = hitPart.Position
    local shootPos = Camera.CFrame.Position
    local direction = (hitPos - shootPos).Unit
    
    -- 生成伪装数据
    local fakeBulletData = GenerateFakeBulletData(shootPos, hitPos, direction)
    local fakeShootParams = GenerateFakeShootParams()
    
    -- 尝试不同的参数格式（包含伪装数据）
    local function tryFire(event)
        if not event or not event:IsA("RemoteEvent") then
            return false
        end
        
        -- 格式1: 完整伪装数据包
        local success1 = pcall(function()
            event:FireServer(fakeBulletData)
        end)
        
        -- 格式2: 基础参数 + 伪装参数
        local success2 = pcall(function()
            event:FireServer(
                shootPos,
                hitPos,
                direction,
                fakeShootParams
            )
        end)
        
        -- 格式3: 伪装射击参数
        local success3 = pcall(function()
            event:FireServer(fakeShootParams)
        end)
        
        -- 格式4: 混合参数
        local success4 = pcall(function()
            event:FireServer({
                Position = shootPos,
                Target = hitPos,
                Data = fakeBulletData,
                Params = fakeShootParams
            })
        end)
        
        -- 格式5: 简单参数（备用）
        local success5 = pcall(function()
            event:FireServer(shootPos, hitPos)
        end)
        
        return success1 or success2 or success3 or success4 or success5
    end
    
    -- 优先使用 Fire 事件
    if fireEvent then
        if tryFire(fireEvent) then
            return true
        end
    end
    
    -- 如果没有 Fire 事件或失败，尝试 DryFire
    if dryFireEvent then
        if tryFire(dryFireEvent) then
            return true
        end
    end
    
    return false
end

-- Ragebot 主循环
task.spawn(function()
    while true do
        if Ragebot.Enabled then
            local now = tick()
            if now - Ragebot.LastShot >= Ragebot.Cooldown then
                local success = Shoot()
                if success then
                    Ragebot.LastShot = now
                end
            end
        end
        task.wait()
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

print("Ragebot 脚本加载完成! 按左Alt打开菜单")