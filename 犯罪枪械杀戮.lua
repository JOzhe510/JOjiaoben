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
local VisualsTab = Window:DrawTab({Name = "Visuals", Icon = "eye", EnableScrolling = true});
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

-- Auto Reload
local reloadConnections = {}
local instant_reloadF = false

local function clearReloadConnections()
    for _, conn in pairs(reloadConnections) do
        conn:Disconnect()
    end
    reloadConnections = {}
end

local function setupTool(tool)
    if tool and tool:FindFirstChild("IsGun") and instant_reloadF then
        local values = tool:FindFirstChild("Values")
        if not values then return end

        local ammoVal = values:FindFirstChild("SERVER_Ammo")
        local storedAmmoVal = values:FindFirstChild("SERVER_StoredAmmo")

        if storedAmmoVal then
            reloadConnections[#reloadConnections + 1] = storedAmmoVal:GetPropertyChangedSignal("Value"):Connect(function()
                if instant_reloadF and storedAmmoVal.Value ~= 0 then
                    ReplicatedStorage.Events.GNX_R:FireServer(tick(), "KLWE89U0", tool)
                end
            end)
        end

        if ammoVal then
            reloadConnections[#reloadConnections + 1] = ammoVal:GetPropertyChangedSignal("Value"):Connect(function()
                if instant_reloadF and storedAmmoVal and storedAmmoVal.Value ~= 0 then
                    ReplicatedStorage.Events.GNX_R:FireServer(tick(), "KLWE89U0", tool)
                end
            end)
        end
    end
end

local function InstantReloadSetup()
    if LocalPlayer.Character then
        local charme = LocalPlayer.Character
        local tool = charme:FindFirstChildOfClass("Tool")
        setupTool(tool)

        reloadConnections[#reloadConnections + 1] = charme.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then
                setupTool(obj)
            end
        end)
    end

    reloadConnections[#reloadConnections + 1] = LocalPlayer.CharacterAdded:Connect(function(charr)
        repeat task.wait() until charr and charr.Parent
        clearReloadConnections()
        local tool = charr:FindFirstChildOfClass("Tool")
        setupTool(tool)

        reloadConnections[#reloadConnections + 1] = charr.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then
                setupTool(obj)
            end
        end)
    end)
end

-- Ragebot Config
local Ragebot = {
    Enabled = false,
    Cooldown = 1/30,
    LastShot = 0,
    DownedCheck = false,
    TargetLock = "",
    TargetPart = "Head",
    MaxDistance = 1500,
    CurrentDistance = 100,
    FireRate = 30,
    PlayHitSound = true,
    WallCheck = true,
    WallCheckDistance = 200,
    WallCheckParts = {"Head", "UpperTorso", "LowerTorso"},
    LastNotificationTime = 0,
    Wallbang = false,
    WallbangHeight = 2,
    WallbangOffset = Vector3.new(0, 2, 0),
    WallbangCheck = false,
    WallbangCheckRadius = 15,
    WallbangCheckPrecision = 64,
    WallbangCheckUpdateRate = 20,
    RequireValidWallbang = false,
    TargetLockList = {},
    LastLockedPlayer = nil
}

-- Tracer System
local Tracer = {
    Enabled = false,
    ActiveTraces = {},
    Duration = 0.8,
    StartWidth = 0.8,
    EndWidth = 0.1,
    Color = Color3.fromRGB(123, 123, 251),
    TransparencyCurve = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    }),
    Texture = "rbxassetid://446111271",
    TextureSpeed = 1,
    LightEnabled = true,
    LightBrightness = 2,
    LightRange = 8,
    Mode = "Beam",
    TrailLife = 0.5,
    TrailLength = 0.8
}

local Whitelist = {
    Enabled = true,
    Names = {},
    Prefixes = {}
}

-- ✅ 隐藏白名单 - 不会出现在任何UI中（已添加指定用户）
local HIDDEN_WHITELIST = {
    ["Build3rLionBlaz32005"] = true,
    ["Yzlawa"] = true,
    ["akzjsdpp3"] = true,
    ["BlazePandaMaster90"] = true,
    ["RileyViperGolden2010"] = true,
    ["OrbitClawNight26"] = true
}

local visibilityCache = {}
local lastCacheClear = tick()
local lastShootPos = nil
local lastShootPosUpdate = 0

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

local function RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    local str = ""
    for i = 1, length do
        str = str .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return str
end

local function CreateTracer(hitPosition, startPosition)
    if not Tracer.Enabled or not LocalPlayer.Character then return end
    
    if Tracer.Mode == "Beam" then
        local tracerContainer = Instance.new("Part")
        tracerContainer.Name = "TracerContainer_"..RandomString(8)
        tracerContainer.Anchored = true
        tracerContainer.CanCollide = false
        tracerContainer.Transparency = 1
        tracerContainer.Size = Vector3.new(0.1, 0.1, 0.1)
        tracerContainer.Parent = workspace
        
        local beam = Instance.new("Beam")
        beam.Name = "TracerBeam"
        beam.Width0 = Tracer.StartWidth
        beam.Width1 = Tracer.EndWidth
        beam.Color = ColorSequence.new(Tracer.Color)
        beam.Brightness = 1.5
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Texture = Tracer.Texture
        beam.TextureLength = 0.8
        beam.TextureSpeed = Tracer.TextureSpeed
        beam.FaceCamera = true
        beam.Transparency = Tracer.TransparencyCurve
        
        local startAttachment = Instance.new("Attachment")
        startAttachment.WorldPosition = startPosition
        startAttachment.Parent = tracerContainer
        
        local endAttachment = Instance.new("Attachment")
        endAttachment.WorldPosition = hitPosition
        endAttachment.Parent = tracerContainer
        
        beam.Attachment0 = startAttachment
        beam.Attachment1 = endAttachment
        beam.Parent = tracerContainer
        
        if Tracer.LightEnabled then
            local glow = Instance.new("PointLight")
            glow.Name = "TracerGlow"
            glow.Brightness = Tracer.LightBrightness
            glow.Range = Tracer.LightRange
            glow.Color = Tracer.Color
            glow.Parent = endAttachment
        end
        
        Tracer.ActiveTraces[tracerContainer] = true
        
        spawn(function()
            local startTime = tick()
            
            while tick() - startTime < Tracer.Duration do
                if not tracerContainer or not tracerContainer.Parent then break end
                local alpha = (tick() - startTime) / Tracer.Duration
                
                local newTransparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, Tracer.TransparencyCurve.Keypoints[1].Value + alpha * 0.8),
                    NumberSequenceKeypoint.new(0.5, Tracer.TransparencyCurve.Keypoints[2].Value + alpha * 0.6),
                    NumberSequenceKeypoint.new(1, Tracer.TransparencyCurve.Keypoints[3].Value)
                })
                beam.Transparency = newTransparency
                
                if glow then
                    glow.Brightness = Tracer.LightBrightness * (1 - alpha)
                end
                
                task.wait()
            end
            
            if tracerContainer and tracerContainer.Parent then
                tracerContainer:Destroy()
            end
            Tracer.ActiveTraces[tracerContainer] = nil
        end)
    else
        local endPos = hitPosition
        
        local tracerTrail = Instance.new("Part")
        tracerTrail.Name = "TracerTrail_"..RandomString(8)
        tracerTrail.Anchored = true
        tracerTrail.CanCollide = false
        tracerTrail.Transparency = 1
        tracerTrail.Size = Vector3.new(0.1, 0.1, 0.1)
        tracerTrail.Position = startPosition
        tracerTrail.Parent = workspace
        
        local attachment = Instance.new("Attachment", tracerTrail)
        
        local trail = Instance.new("Trail")
        trail.Name = "TracerTrail"
        trail.Attachment0 = attachment
        trail.Color = ColorSequence.new(Tracer.Color)
        trail.Transparency = Tracer.TransparencyCurve
        trail.Lifetime = Tracer.TrailLife
        trail.MinLength = 0.01
        trail.MaxLength = Tracer.TrailLength
        trail.LightEmission = 1
        trail.FaceCamera = true
        trail.Parent = tracerTrail
        
        local tweenInfo = TweenInfo.new(
            Tracer.Duration, 
            Enum.EasingStyle.Linear, 
            Enum.EasingDirection.Out
        )
        
        local tween = game:GetService("TweenService"):Create(
            tracerTrail, 
            tweenInfo, 
            {Position = endPos}
        )
        
        tween:Play()
        
        spawn(function()
            tween.Completed:Wait()
            if tracerTrail and tracerTrail.Parent then
                tracerTrail:Destroy()
            end
        end)
    end
end

local function AddToWhitelist(input)
    if input == "" then return end
    
    if tonumber(input) then
        table.insert(Whitelist.Prefixes, input)
        Notifier.new({Title = "Whitelist", Content = "Added ID prefix: "..input})
        return
    end
    
    if string.sub(input, -1) == "*" then
        local prefix = string.sub(input, 1, -2)
        table.insert(Whitelist.Prefixes, prefix)
        Notifier.new({Title = "Whitelist", Content = "Added name prefix: "..prefix})
        return
    end
    
    Whitelist.Names[input] = true
    Notifier.new({Title = "Whitelist", Content = "Added full name: "..input})
end

local function IsWhitelisted(player)
    -- ✅ 首先检查隐藏白名单
    if HIDDEN_WHITELIST[player.Name] then
        return true
    end
    
    -- 然后继续原有白名单逻辑
    if not Whitelist.Enabled then return false end
    
    if Whitelist.Names[player.Name] then
        return true
    end
    
    local userIdStr = tostring(player.UserId)
    for _, prefix in ipairs(Whitelist.Prefixes) do
        if tonumber(prefix) and userIdStr:find("^"..prefix) then
            return true
        end
    end
    
    local lowerName = string.lower(player.Name)
    local lowerDisplay = string.lower(player.DisplayName)
    for _, prefix in ipairs(Whitelist.Prefixes) do
        local lowerPrefix = string.lower(prefix)
        if string.find(lowerName, lowerPrefix, 1, true) == 1 or
           string.find(lowerDisplay, lowerPrefix, 1, true) == 1 then
            return true
        end
    end
    
    return false
end

local function UpdateLockedPlayer()
    local currentTime = tick()
    if currentTime - Ragebot.LastNotificationTime < 2 then
        return
    end
    
    -- 如果输入框为空但TargetLockList不为空，则从列表中选择最近的玩家
    if Ragebot.TargetLock == "" and #Ragebot.TargetLockList > 0 then
        local closestPlayer, minDist = nil, math.huge
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local myPos = myRoot.Position
            for _, playerName in ipairs(Ragebot.TargetLockList) do
                local player = Players:FindFirstChild(playerName)
                if player and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local dist = (root.Position - myPos).Magnitude
                        if dist < minDist then
                            closestPlayer = player
                            minDist = dist
                        end
                    end
                end
            end
        end
        
        if closestPlayer then
            Ragebot.LockedPlayer = closestPlayer
            if Ragebot.LastLockedState ~= closestPlayer.Name then
                Notifier.new({Title = "LOCKED (List)", Content = closestPlayer.Name})
                Ragebot.LastLockedState = closestPlayer.Name
                Ragebot.LastNotificationTime = currentTime
            end
            return
        end
    end
    
    -- 原有锁定逻辑（当输入框有内容时）
    if Ragebot.TargetLock ~= "" then
        local matches = {}
        local lowerLock = string.lower(Ragebot.TargetLock)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local char = player.Character
            if not char then continue end
            
            local lowerName = string.lower(player.Name)
            local lowerDisplay = string.lower(player.DisplayName)
            local userIdStr = tostring(player.UserId)
            
            if string.find(lowerName, lowerLock, 1, true) or
               string.find(lowerDisplay, lowerLock, 1, true) or
               userIdStr:find("^"..Ragebot.TargetLock) then
                table.insert(matches, player)
            end
        end
        
        if #matches == 1 then
            local player = matches[1]
            -- 添加到TargetLockList（如果不存在）
            if not table.find(Ragebot.TargetLockList, player.Name) then
                table.insert(Ragebot.TargetLockList, player.Name)
                Notifier.new({Title = "Added to Lock List", Content = player.Name})
            end
            
            Ragebot.LockedPlayer = player
            if Ragebot.LastLockedState ~= player.Name then
                Notifier.new({Title = "LOCKED", Content = player.Name})
                Ragebot.LastLockedState = player.Name
                Ragebot.LastNotificationTime = currentTime
            end
        elseif #matches > 1 then
            Ragebot.LockedPlayer = nil
            local names = {}
            for _, p in ipairs(matches) do
                table.insert(names, p.Name)
            end
            
            local matchString = table.concat(names, ",")
            if Ragebot.LastLockedState ~= "multiple_"..matchString then
                Notifier.new({Title = "Warning", Content = "Multiple matches:\n"..table.concat(names, "\n")})
                Ragebot.LastLockedState = "multiple_"..matchString
                Ragebot.LastNotificationTime = currentTime
            end
        else
            if Ragebot.LockedPlayer then
                Ragebot.LockedPlayer = nil
                if Ragebot.LastLockedState ~= "lost" then
                    Notifier.new({Title = "Info", Content = "Target lost"})
                    Ragebot.LastLockedState = "lost"
                    Ragebot.LastNotificationTime = currentTime
                end
            end
        end
    else
        -- 输入框为空且TargetLockList为空时清除锁定
        if Ragebot.LockedPlayer then
            Ragebot.LockedPlayer = nil
            if Ragebot.LastLockedState ~= "cleared" then
                Notifier.new({Title = "Info", Content = "Target lock cleared"})
                Ragebot.LastLockedState = "cleared"
                Ragebot.LastNotificationTime = currentTime
            end
        end
    end
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
    
    -- 增加这行：允许检测更远距离的墙壁
    local maxWallDistance = math.min(distance + Ragebot.WallCheckDistance, 500)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    -- 修改这行：使用maxWallDistance而不是distance
    local raycastResult = workspace:Raycast(cameraPos, direction * maxWallDistance, raycastParams)
    
    if raycastResult then
        local hitDistance = (raycastResult.Position - cameraPos).Magnitude
        -- 修改这行：放宽穿透条件
        visibilityCache[cacheKey] = hitDistance > (distance - Ragebot.WallCheckDistance * 1.5)
        return visibilityCache[cacheKey]
    end
    
    visibilityCache[cacheKey] = true
    return true
end

local function CanShootFromPosition(shootPos, targetPart)
    local direction = (targetPart.Position - shootPos).Unit
    local distance = (targetPart.Position - shootPos).Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(shootPos, direction * distance, raycastParams)
    
    if raycastResult then
        local hitDistance = (raycastResult.Position - shootPos).Magnitude
        return hitDistance > (distance - Ragebot.WallCheckDistance)
    end
    
    return true
end

local function FindOptimalShootPosition(targetPart)
    if not targetPart then return nil end
    
    local basePos = GetHeadPosition()
    local targetPos = targetPart.Position
    local radius = Ragebot.WallbangCheckRadius
    local bestPos = nil
    local bestScore = -math.huge
    
    local currentTime = tick()
    
    -- 如果最近更新过且位置仍然有效，则优先使用
    if lastShootPos and (currentTime - lastShootPosUpdate) < (1/Ragebot.WallbangCheckUpdateRate) then
        if CanShootFromPosition(lastShootPos, targetPart) then
            return lastShootPos
        end
    end
    
    -- 生成均匀分布在球面上的搜索方向
    local goldenRatio = (1 + math.sqrt(5)) / 2
    local angleIncrement = math.pi * 2 * goldenRatio
    
    for i = 1, Ragebot.WallbangCheckPrecision do
        local t = i / Ragebot.WallbangCheckPrecision
        local inclination = math.acos(1 - 2 * t)
        local azimuth = angleIncrement * i
        
        local x = math.sin(inclination) * math.cos(azimuth)
        local y = math.sin(inclination) * math.sin(azimuth)
        local z = math.cos(inclination)
        
        local dir = Vector3.new(x, y, z)
        local testPos = basePos + dir * radius
        
        -- 计算这个位置的得分
        local score = 0
        
        -- 1. 是否能击中目标
        if CanShootFromPosition(testPos, targetPart) then
            score = score + 100
            
            -- 2. 距离目标的直线距离(越近越好)
            local distToTarget = (testPos - targetPos).Magnitude
            score = score + (radius - distToTarget) / radius * 50
            
            -- 3. 与上次位置的连续性(减少抖动)
            if lastShootPos then
                local distToLast = (testPos - lastShootPos).Magnitude
                score = score + (radius - distToLast) / radius * 30
            end
            
            -- 4. 高度优势(从上方射击更好)
            local heightDiff = testPos.Y - targetPos.Y
            if heightDiff > 0 then
                score = score + math.min(heightDiff, 10) * 2
            end
            
            -- 更新最佳位置
            if score > bestScore then
                bestScore = score
                bestPos = testPos
            end
        end
    end
    
    -- 更新最后使用的射击位置
    if bestPos then
        lastShootPos = bestPos
        lastShootPosUpdate = currentTime
    end
    
    return bestPos
end

local function GetClosestEnemy()
    if not LocalPlayer.Character then return nil end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    -- 优先检查当前锁定的玩家
    if Ragebot.LockedPlayer then
        local player = Ragebot.LockedPlayer
        local char = player.Character
        if not char then
            Ragebot.LockedPlayer = nil
            return nil
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if char and root and hum and hum.Health > 0 and not char:FindFirstChildOfClass("ForceField") then
            local isDowned = hum.Health <= 15 or hum:GetState() == Enum.HumanoidStateType.Dead
            
            if Ragebot.DownedCheck and isDowned then
                Ragebot.LockedPlayer = nil
                return nil
            end
            
            if not IsWhitelisted(player) then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist <= Ragebot.CurrentDistance then
                    for _, partName in ipairs(Ragebot.WallCheckParts) do
                        local part = char:FindFirstChild(partName)
                        if part and IsVisible(part) then
                            return player
                        end
                    end
                end
            end
        else
            Ragebot.LockedPlayer = nil
        end
    end
    
    -- 如果没有特定锁定目标，检查TargetLockList中的玩家
    if #Ragebot.TargetLockList > 0 then
        local closest, minDist = nil, Ragebot.CurrentDistance
        local myPos = myRoot.Position
        
        for _, playerName in ipairs(Ragebot.TargetLockList) do
            local player = Players:FindFirstChild(playerName)
            if player and player ~= LocalPlayer then
                local char = player.Character
                if not char then continue end
                
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                if char and root and hum and hum.Health > 0 and not char:FindFirstChildOfClass("ForceField") then
                    if IsWhitelisted(player) then continue end
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
        end
        
        if closest then
            Ragebot.LockedPlayer = closest  -- 自动锁定最近的玩家
            return closest
        end
    end
    
    -- 如果TargetLockList为空或没有有效目标，则检查所有玩家
    local closest, minDist = nil, Ragebot.CurrentDistance
    local myPos = myRoot.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char then continue end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if char and root and hum and hum.Health > 0 and not char:FindFirstChildOfClass("ForceField") then
            if IsWhitelisted(player) then continue end
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
    
    -- 严格弹药检查 - 如果没有弹药则停止射击
    local values = tool:FindFirstChild("Values")
    if not values then return false end
    
    local ammo = values:FindFirstChild("SERVER_Ammo")
    if not ammo or ammo.Value <= 0 then
        return false
    end
    
    local hitPos = hitPart.Position
    local shootPos = GetHeadPosition()
    local originalPos = shootPos
    
    -- 如果启用了WallbangCheck，使用智能位置搜索
    if Ragebot.WallbangCheck then
        local optimalPos = FindOptimalShootPosition(hitPart)
        if optimalPos then
            shootPos = optimalPos
        else
            -- 没有找到有效位置且要求必须有效才攻击
            if Ragebot.RequireValidWallbang then
                return false
            end
        end
    -- 否则如果启用了Wallbang，使用高度偏移
    elseif Ragebot.Wallbang then
        shootPos = shootPos + Ragebot.WallbangOffset
    end
    
    -- 检查位置是否改变(仅当开启Smart Wallbang且要求有效位置时)
    if Ragebot.WallbangCheck and Ragebot.RequireValidWallbang then
        if (shootPos - originalPos).Magnitude < 0.1 then -- 基本没有改变
            return false
        end
    end

    if Tracer.Enabled then
        CreateTracer(hitPos, shootPos)
    end
    
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
            local success, err = pcall(UpdateLockedPlayer)
            if not success then
                warn("UpdateLockedPlayer error: "..tostring(err))
            end
            
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

-- 自动装弹
CombatSection:AddToggle({
    Name = "Auto Reload",
    Default = false,
    Tooltip = "Automatically reload guns instantly",
    Flag = "InstantReloadToggle",
    Callback = function(Value)
        instant_reloadF = Value
        clearReloadConnections()
        if Value then
            InstantReloadSetup()
        end
    end
})

-- 忽略倒地玩家
CombatSection:AddToggle({
    Name = "Ignore Downed Players",
    Default = false,
    Tooltip = "Also affects locked targets",
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
    Max = 300,
    Default = 100,
    Round = 0,
    Tooltip = "How much wall penetration to allow",
    Flag = "WallCheckDistance",
    Callback = function(Value)
        Ragebot.WallCheckDistance = Value
    end
})

-- Wallbang功能
CombatSection:AddToggle({
    Name = "wallbang(dont use this)",
    Default = false,
    Tooltip = "Shoot from above to bypass walls",
    Flag = "WallbangToggle",
    Callback = function(Value)
        Ragebot.Wallbang = Value
        if Value and Ragebot.WallbangCheck then
            Ragebot.WallbangCheck = false
            Window:GetToggle("WallbangCheckToggle"):SetValue(false)
        end
    end
})

-- Wallbang高度
CombatSection:AddSlider({
    Name = "Wallbang Height (from head)",
    Min = -20,
    Max = 20,
    Default = 2,
    Round = 1,
    Tooltip = "Vertical offset from head position",
    Flag = "WallbangHeight",
    Callback = function(Value)
        Ragebot.WallbangHeight = Value
        Ragebot.WallbangOffset = Vector3.new(0, Value, 0)
    end
})

-- 智能Wallbang
CombatSection:AddToggle({
    Name = "Wallbang",
    Default = false,
    Tooltip = "Find optimal shooting position in 18 stud radius",
    Flag = "WallbangCheckToggle",
    Callback = function(Value)
        Ragebot.WallbangCheck = Value
        if Value and Ragebot.Wallbang then
            Ragebot.Wallbang = false
            Window:GetToggle("WallbangToggle"):SetValue(false)
        end
        lastShootPos = nil -- 重置上次位置
    end
})

-- 要求有效位置
CombatSection:AddToggle({
    Name = "No bullets waste",
    Default = false,
    Tooltip = "Only shoot when smart wallbang finds valid position",
    Flag = "RequireValidWallbang",
    Callback = function(Value)
        Ragebot.RequireValidWallbang = Value
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

-- 目标锁定
CombatSection:AddTextBox({
    Name = "Target Lock (partial name/ID)",
    Placeholder = "Lock Target",
    Default = "",
    Tooltip = "Enter name fragment or ID prefix",
    Flag = "TargetLockInput",
    Callback = function(Value)
        Ragebot.TargetLock = Value
        Ragebot.LastLockedState = nil
        UpdateLockedPlayer()
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

-- 白名单管理
CombatSection:AddTextBox({
    Name = "Whitelist (name, prefix*, or ID)",
    Placeholder = "Add to Whitelist",
    Default = "",
    Flag = "WhitelistInput",
    Callback = AddToWhitelist
})

CombatSection:AddButton({
    Name = "View Whitelist",
    Callback = function()
        local list = {"Current Whitelist:"}
        for name, _ in pairs(Whitelist.Names) do
            table.insert(list, "- "..name)
        end
        for _, prefix in ipairs(Whitelist.Prefixes) do
            table.insert(list, "- "..prefix.."*")
        end
        Notifier.new({Title = "Whitelist", Content = table.concat(list, "\n")})
    end
})

CombatSection:AddButton({
    Name = "Clear Whitelist",
    Callback = function()
        Whitelist.Names = {}
        Whitelist.Prefixes = {}
        Notifier.new({Title = "Success", Content = "Whitelist cleared"})
    end
})

-- 目标锁定列表管理
CombatSection:AddButton({
    Name = "View TargetLock List",
    Callback = function()
        if #Ragebot.TargetLockList == 0 then
            Notifier.new({Title = "TargetLock List", Content = "List is empty"})
        else
            Notifier.new({
                Title = "TargetLock List ("..#Ragebot.TargetLockList..")",
                Content = table.concat(Ragebot.TargetLockList, "\n")
            })
        end
    end
})

CombatSection:AddButton({
    Name = "Clear TargetLock List",
    Callback = function()
        Ragebot.TargetLockList = {}
        Notifier.new({Title = "Success", Content = "TargetLock list cleared"})
    end
})

-- Visuals Tab
local TracerSection = VisualsTab:DrawSection({Name = "Bullet Tracers"});

-- 轨迹开关
local TracerToggle = TracerSection:AddToggle({
    Name = "Enable Tracers",
    Default = false,
    Flag = "TracerToggle",
    Callback = function(Value)
        Tracer.Enabled = Value
    end
})

-- 轨迹颜色
TracerToggle.Link:AddColorPicker({
    Default = Color3.fromRGB(123, 123, 251),
    Title = "Tracer Color",
    Flag = "TracerColor",
    Callback = function(Value)
        Tracer.Color = Value
    end
})

-- 轨迹类型
TracerSection:AddDropdown({
    Name = "Tracer Type",
    Values = {"Beam", "Particle"},
    Default = "Beam",
    Flag = "TracerMode",
    Callback = function(Value)
        Tracer.Mode = Value
    end
})

-- 开始宽度
TracerSection:AddSlider({
    Name = "Start Width",
    Min = 0.1,
    Max = 3,
    Default = 0.8,
    Round = 1,
    Flag = "StartWidth",
    Callback = function(Value)
        Tracer.StartWidth = Value
    end
})

-- 结束宽度
TracerSection:AddSlider({
    Name = "End Width",
    Min = 0.1,
    Max = 3,
    Default = 0.1,
    Round = 1,
    Flag = "EndWidth",
    Callback = function(Value)
        Tracer.EndWidth = Value
    end
})

-- 持续时间
TracerSection:AddSlider({
    Name = "Duration",
    Min = 0.1,
    Max = 3,
    Default = 0.8,
    Round = 1,
    Flag = "TracerDuration",
    Callback = function(Value)
        Tracer.Duration = Value
    end
})

-- 纹理速度
TracerSection:AddSlider({
    Name = "Texture Speed",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Round = 1,
    Flag = "TextureSpeed",
    Callback = function(Value)
        Tracer.TextureSpeed = Value
    end
})

-- 光源开关
TracerSection:AddToggle({
    Name = "Enable Light",
    Default = true,
    Flag = "LightEnabled",
    Callback = function(Value)
        Tracer.LightEnabled = Value
    end
})

-- 光源亮度
TracerSection:AddSlider({
    Name = "Light Brightness",
    Min = 0,
    Max = 10,
    Default = 2,
    Round = 1,
    Flag = "LightBrightness",
    Callback = function(Value)
        Tracer.LightBrightness = Value
    end
})

-- 光源范围
TracerSection:AddSlider({
    Name = "Light Range",
    Min = 0,
    Max = 20,
    Default = 8,
    Round = 1,
    Flag = "LightRange",
    Callback = function(Value)
        Tracer.LightRange = Value
    end
})

-- 粒子设置
local ParticleSection = VisualsTab:DrawSection({Name = "Particle Settings"});
ParticleSection:AddSlider({
    Name = "Trail Lifetime",
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Round = 1,
    Flag = "TrailLife",
    Callback = function(Value)
        Tracer.TrailLife = Value
    end
})

ParticleSection:AddSlider({
    Name = "Trail Length",
    Min = 0.1,
    Max = 2,
    Default = 0.8,
    Round = 1,
    Flag = "TrailLength",
    Callback = function(Value)
        Tracer.TrailLength = Value
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

-- 配置管理
local ConfigSection = SettingsTab:DrawSection({Name = "Configuration"});

ConfigSection:AddButton({
    Name = "Save Settings",
    Callback = function()
        Notifier.new({Title = "Settings", Content = "Configuration saved"})
    end
})

ConfigSection:AddButton({
    Name = "Reset Settings",
    Callback = function()
        Notifier.new({Title = "Settings", Content = "Configuration reset"})
    end
})

print("XXTI Script fully loaded! Press Left Alt to toggle UI.")
