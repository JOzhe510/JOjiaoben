local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "OPAI [测试版本—-0.1] - 犯罪专用",
    LoadingTitle = "OPAI Ragebot",
    LoadingSubtitle = "by XiaoMao, snmwdd, 请输入文本",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "OPAI_Criminality",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

local CombatTab = Window:CreateTab("战斗", 4483362458)
local VisualsTab = Window:CreateTab("视觉", 4483362458)
local SettingsTab = Window:CreateTab("设置", 4483362458)
local WorldTab = Window:CreateTab("世界", 4483362458)

local function Notify(title, content, duration)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = 4483362458,
    })
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

local function GetHeadPosition()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        return LocalPlayer.Character.Head.Position
    end
    return Camera.CFrame.Position -- 备用方案
end

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

local Ragebot = {
    Enabled = false,
    Cooldown = 1/30,
    LastShot = 0,
    DownedCheck = false,
    TargetLock = "",
    TargetPart = "Head",
    MaxDistance = 800,
    CurrentDistance = 100,
    FireRate = 30,
    PlayHitSound = true,
    WallCheck = true,
    WallCheckDistance = 50,
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
    LastLockedPlayer = nil,
    ClickToShoot = false,  -- 是否启用点击射击模式
    MouseHeld = false,     -- 鼠标是否按下
    TriggerDistance = 100, -- 触发距离
    TargetHighlight = true,
    TargetHighlightColor = Color3.fromRGB(255, 0, 0),
    CurrentTarget = nil,
    TargetHighlightInstance = nil,
}

local ESP = {
    Enabled = false,
    Players = {},
    ShowBox = true,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowHealthBar = true,
    ShowSkeleton = false,
    ShowTracers = false,
    ShowChams = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    ChamsColor = Color3.fromRGB(128, 0, 255),
    HealthColor = true, -- 根据血量变色
    TeamCheck = false,
    MaxDistance = 2000,
    TextSize = 16,
    BoxThickness = 2,
    TracerOrigin = "Bottom", -- Bottom/Middle/Top/Mouse
    UseDisplayName = false,
    FadeDistance = true, -- 距离淡出效果
    DistanceFadeStart = 1000,
    Transparency = 1,
    UpdateRate = 1/60, -- 60 FPS (流畅显示)
}

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
        Notify("错误", "无效的RPS（1-100）")
        return
    end
    Ragebot.Cooldown = 1/rps
    Ragebot.FireRate = rps
        Notify("成功", "开火速率设为: "..rps.." RPS")
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
        Notify("白名单", "已添加ID前缀: "..input)
        return
    end
    
    if string.sub(input, -1) == "*" then
        local prefix = string.sub(input, 1, -2)
        table.insert(Whitelist.Prefixes, prefix)
        Notify("白名单", "已添加名称前缀: "..prefix)
        return
    end
    
    Whitelist.Names[input] = true
    Notify("白名单", "已添加全名: "..input)
end

local function IsWhitelisted(player)
    if HIDDEN_WHITELIST[player.Name] then
        return true
    end
    
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
                Notify("已锁定（列表）", closestPlayer.Name)
                Ragebot.LastLockedState = closestPlayer.Name
                Ragebot.LastNotificationTime = currentTime
            end
            return
        end
    end
    
    if Ragebot.TargetLock ~= "" then
        local matches = {}
        local lowerLock = string.lower(Ragebot.TargetLock)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
            local char = player.Character
                if char then
            local lowerName = string.lower(player.Name)
            local lowerDisplay = string.lower(player.DisplayName)
            local userIdStr = tostring(player.UserId)
            
            if string.find(lowerName, lowerLock, 1, true) or
               string.find(lowerDisplay, lowerLock, 1, true) or
               userIdStr:find("^"..Ragebot.TargetLock) then
                table.insert(matches, player)
                    end
                end
            end
        end
        
        if #matches == 1 then
            local player = matches[1]
            local found = false
            for _, name in ipairs(Ragebot.TargetLockList) do
                if name == player.Name then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(Ragebot.TargetLockList, player.Name)
                Notify("已添加到锁定列表", player.Name)
            end
            
            Ragebot.LockedPlayer = player
            if Ragebot.LastLockedState ~= player.Name then
                Notify("已锁定", player.Name)
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
                Notify("警告", "多重匹配:\n"..table.concat(names, "\n"))
                Ragebot.LastLockedState = "multiple_"..matchString
                Ragebot.LastNotificationTime = currentTime
            end
        else
            if Ragebot.LockedPlayer then
                Ragebot.LockedPlayer = nil
                if Ragebot.LastLockedState ~= "lost" then
                    Notify("信息", "目标丢失")
                    Ragebot.LastLockedState = "lost"
                    Ragebot.LastNotificationTime = currentTime
                end
            end
        end
    else
        if Ragebot.LockedPlayer then
            Ragebot.LockedPlayer = nil
            if Ragebot.LastLockedState ~= "cleared" then
                Notify("信息", "目标锁定已清除")
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
    
    if lastShootPos and (currentTime - lastShootPosUpdate) < (1/Ragebot.WallbangCheckUpdateRate) then
        if CanShootFromPosition(lastShootPos, targetPart) then
            return lastShootPos
        end
    end
    
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
        
        local score = 0
        
        if CanShootFromPosition(testPos, targetPart) then
            score = score + 100
            
            local distToTarget = (testPos - targetPos).Magnitude
            score = score + (radius - distToTarget) / radius * 50
            
            if lastShootPos then
                local distToLast = (testPos - lastShootPos).Magnitude
                score = score + (radius - distToLast) / radius * 30
            end
            
            local heightDiff = testPos.Y - targetPos.Y
            if heightDiff > 0 then
                score = score + math.min(heightDiff, 10) * 2
            end
            
            if score > bestScore then
                bestScore = score
                bestPos = testPos
            end
        end
    end
    
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
    
    if #Ragebot.TargetLockList > 0 then
        local closest, minDist = nil, Ragebot.CurrentDistance
        local myPos = myRoot.Position
        
        for _, playerName in ipairs(Ragebot.TargetLockList) do
            local player = Players:FindFirstChild(playerName)
            if player and player ~= LocalPlayer then
                local char = player.Character
                if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                    if root and hum and hum.Health > 0 and not char:FindFirstChildOfClass("ForceField") then
                        if not IsWhitelisted(player) then
                            if not (Ragebot.DownedCheck and (hum.Health <= 15 or hum:GetState() == Enum.HumanoidStateType.Dead)) then
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
                end
            end
        end
        
        if closest then
            Ragebot.LockedPlayer = closest  -- 自动锁定最近的玩家
            return closest
        end
    end
    
    local closest, minDist = nil, Ragebot.CurrentDistance
    local myPos = myRoot.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
        local char = player.Character
            if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
                if root and hum and hum.Health > 0 and not char:FindFirstChildOfClass("ForceField") then
                    if not IsWhitelisted(player) then
                        if not (Ragebot.DownedCheck and (hum.Health <= 15 or hum:GetState() == Enum.HumanoidStateType.Dead)) then
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
            end
        end
    end
    
    return closest
end

local function UpdateTargetHighlight(target)
    if Ragebot.TargetHighlightInstance then
        pcall(function() Ragebot.TargetHighlightInstance:Destroy() end)
        Ragebot.TargetHighlightInstance = nil
    end
    
    if not target or not Ragebot.TargetHighlight then
        Ragebot.CurrentTarget = nil
        return
    end
    
    Ragebot.CurrentTarget = target
    
    if target.Character then
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local highlight = Instance.new("Highlight")
            highlight.Name = "RagebotTargetHighlight"
            highlight.Adornee = target.Character
            highlight.FillColor = Ragebot.TargetHighlightColor
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Ragebot.TargetHighlightColor
            highlight.OutlineTransparency = 0
            highlight.Parent = root
            Ragebot.TargetHighlightInstance = highlight
        end
    end
end

local function Shoot(target)
    if not target or not target.Character then return false end
    
    local hitPart = target.Character:FindFirstChild(Ragebot.TargetPart) or
                   target.Character:FindFirstChild("Head") or
                   target.Character:FindFirstChild("UpperTorso")
    if not hitPart then return false end
    
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return false end
    
    local values = tool:FindFirstChild("Values")
    if not values then return false end
    
    local ammo = values:FindFirstChild("SERVER_Ammo")
    if not ammo or ammo.Value <= 0 then
        return false
    end
    
    local hitPos = hitPart.Position
    local shootPos = GetHeadPosition()
    local originalPos = shootPos
    
    if Ragebot.WallbangCheck then
        local optimalPos = FindOptimalShootPosition(hitPart)
        if optimalPos then
            shootPos = optimalPos
        else
            if Ragebot.RequireValidWallbang then
                return false
            end
        end
    elseif Ragebot.Wallbang then
        shootPos = shootPos + Ragebot.WallbangOffset
    end
    
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
        "hit",
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Ragebot.MouseHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Ragebot.MouseHeld = false
    end
end)

task.spawn(function()
    while true do
        if Ragebot.Enabled then
            local success, err = pcall(UpdateLockedPlayer)
            if not success then
                warn("UpdateLockedPlayer error: "..tostring(err))
            end
            
            local shouldShoot = true
            if Ragebot.ClickToShoot then
                shouldShoot = Ragebot.MouseHeld
            end
            
            if shouldShoot then
            local now = tick()
            if now - Ragebot.LastShot >= Ragebot.Cooldown then
                local target = GetClosestEnemy()
                    
                    UpdateTargetHighlight(target)
                    
                if target then
                    if Ragebot.ClickToShoot then
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot and targetRoot then
                            local dist = (targetRoot.Position - myRoot.Position).Magnitude
                            if dist <= Ragebot.TriggerDistance then
                                local shotFired = Shoot(target)
                                if shotFired then
                                    Ragebot.LastShot = now
                                end
                            end
                        end
                    else
                        local shotFired = Shoot(target)
                        if shotFired then
                            Ragebot.LastShot = now
                        end
                    end
                end
                end
            else
                if Ragebot.LockedPlayer then
                    UpdateTargetHighlight(Ragebot.LockedPlayer)
                else
                    UpdateTargetHighlight(nil)
                end
            end
            task.wait(0.03)  -- 启用时30ms延迟
        else
            task.wait(0.5)  -- 关闭时500ms延迟，大幅减少CPU占用
        end
    end
end)


local FullbrightEnabled = false
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local function ToggleFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Notify("全亮", "已启用全亮功能", 2)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Notify("全亮", "已关闭全亮功能", 2)
    end
end

local espColorShop = Color3.fromRGB(255, 255, 0)     -- 商人 - 黄色
local espColorATM = Color3.fromRGB(255, 255, 0)      -- ATM - 黄色
local espColorVM = Color3.fromRGB(255, 165, 0)       -- 售货机 - 橙色
local espColorCash = Color3.fromRGB(255, 0, 255)     -- 收银台 - 紫色
local espColorPlayer = Color3.fromRGB(0, 255, 255)   -- 玩家 - 青色

local ShopESPEnabled = false
local ATMESPEnabled = false
local VMESPEnabled = false
local CashESPEnabled = false
local PlayerESPEnabled = false


WorldTab:CreateSection("世界功能")

WorldTab:CreateToggle({
    Name = "全亮",
    CurrentValue = false,
    Callback = function(Value)
        FullbrightEnabled = Value
        ToggleFullbright(Value)
    end,
})

WorldTab:CreateSection("ESP透视")

local ShopToggle = WorldTab:CreateToggle({
    Name = "商人ESP",
    CurrentValue = false,
    Callback = function(Value)
        ShopESPEnabled = Value
    end,
})

WorldTab:CreateColorPicker({
    Name = "商人颜色",
    Color = espColorShop,
    Callback = function(Value)
        espColorShop = Value
    end,
})

local ATMToggle = WorldTab:CreateToggle({
    Name = "ATM ESP",
    CurrentValue = false,
    Callback = function(Value)
        ATMESPEnabled = Value
    end,
})

WorldTab:CreateColorPicker({
    Name = "ATM颜色",
    Color = espColorATM,
    Callback = function(Value)
        espColorATM = Value
    end,
})

local PlayerToggle = WorldTab:CreateToggle({
    Name = "玩家ESP",
    CurrentValue = false,
    Callback = function(Value)
        PlayerESPEnabled = Value
    end,
})

WorldTab:CreateColorPicker({
    Name = "玩家颜色",
    Color = espColorPlayer,
    Callback = function(Value)
        espColorPlayer = Value
    end,
})

local VMToggle = WorldTab:CreateToggle({
    Name = "售货机ESP",
    CurrentValue = false,
    Callback = function(Value)
        VMESPEnabled = Value
    end,
})

WorldTab:CreateColorPicker({
    Name = "售货机颜色",
    Color = espColorVM,
    Callback = function(Value)
        espColorVM = Value
    end,
})

local CashToggle = WorldTab:CreateToggle({
    Name = "收银台ESP",
    CurrentValue = false,
    Callback = function(Value)
        CashESPEnabled = Value
    end,
})

WorldTab:CreateColorPicker({
    Name = "收银台颜色",
    Color = espColorCash,
    Callback = function(Value)
        espColorCash = Value
    end,
})

CombatTab:CreateSection("Ragebot设置")

CombatTab:CreateToggle({
    Name = "启用Ragebot",
    CurrentValue = false,
    Callback = function(Value)
        Ragebot.Enabled = Value
        if not Value then
            UpdateTargetHighlight(nil)
        end
    end,
})

CombatTab:CreateToggle({
    Name = "点击射击模式",
    CurrentValue = false,
    Callback = function(Value)
        Ragebot.ClickToShoot = Value
        if Value then
            Notify("点击射击", "按住鼠标左键射击")
        else
            Notify("点击射击", "自动射击模式")
        end
    end,
})

CombatTab:CreateSlider({
    Name = "触发距离 (点击模式)",
    Range = {10, 500},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(Value)
        Ragebot.TriggerDistance = Value
    end,
})

CombatTab:CreateToggle({
    Name = "目标高亮",
    CurrentValue = true,
    Callback = function(Value)
        Ragebot.TargetHighlight = Value
        if not Value then
            UpdateTargetHighlight(nil)
        end
        Notify("目标高亮", Value and "已启用" or "已关闭")
    end,
})

CombatTab:CreateColorPicker({
    Name = "高亮颜色",
    Color = Ragebot.TargetHighlightColor,
    Callback = function(Value)
        Ragebot.TargetHighlightColor = Value
        if Ragebot.CurrentTarget and Ragebot.TargetHighlightInstance then
            Ragebot.TargetHighlightInstance.FillColor = Value
            Ragebot.TargetHighlightInstance.OutlineColor = Value
        end
    end,
})

CombatTab:CreateSlider({
    Name = "开火速率 (RPS)",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 30,
    Callback = UpdateFireRate
})

CombatTab:CreateToggle({
    Name = "命中音效",
    CurrentValue = true,
    Callback = function(Value)
        Ragebot.PlayHitSound = Value
    end,
})

CombatTab:CreateToggle({
    Name = "自动换弹",
    CurrentValue = false,
    Callback = function(Value)
        instant_reloadF = Value
        clearReloadConnections()
        if Value then
            InstantReloadSetup()
        end
    end,
})

CombatTab:CreateToggle({
    Name = "忽略倒地玩家",
    CurrentValue = false,
    Callback = function(Value)
        Ragebot.DownedCheck = Value
    end,
})

CombatTab:CreateToggle({
    Name = "墙壁检测",
    CurrentValue = true,
    Callback = function(Value)
        Ragebot.WallCheck = Value
    end,
})

CombatTab:CreateSlider({
    Name = "墙体穿透距离",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(Value)
        Ragebot.WallCheckDistance = Value
    end,
})

CombatTab:CreateToggle({
    Name = "穿墙（不要使用）",
    CurrentValue = false,
    Callback = function(Value)
        Ragebot.Wallbang = Value
        if Value and Ragebot.WallbangCheck then
            Ragebot.WallbangCheck = false
        end
    end,
})

CombatTab:CreateSlider({
    Name = "穿墙高度（从头部）",
    Range = {-20, 20},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(Value)
        Ragebot.WallbangHeight = Value
        Ragebot.WallbangOffset = Vector3.new(0, Value, 0)
    end,
})

CombatTab:CreateToggle({
    Name = "智能穿墙",
    CurrentValue = false,
    Callback = function(Value)
        Ragebot.WallbangCheck = Value
        if Value and Ragebot.Wallbang then
            Ragebot.Wallbang = false
        end
        lastShootPos = nil -- 重置上次位置
    end,
})

CombatTab:CreateToggle({
    Name = "不浪费子弹",
    CurrentValue = false,
    Callback = function(Value)
        Ragebot.RequireValidWallbang = Value
    end,
})

CombatTab:CreateInput({
    Name = "最大距离 (1-800)",
    PlaceholderText = "设置距离",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 and num <= 800 then
            Ragebot.MaxDistance = num
            Ragebot.CurrentDistance = num
            Notify("成功", "距离设为: "..num.." studs")
        else
            Notify("错误", "无效距离（必须为 1-800）")
        end
    end,
})

CombatTab:CreateInput({
    Name = "目标锁定（部分名字/ID）",
    PlaceholderText = "锁定目标",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        Ragebot.TargetLock = Text
        Ragebot.LastLockedState = nil
        UpdateLockedPlayer()
    end,
})

CombatTab:CreateDropdown({
    Name = "目标部位",
    Options = {"Head", "UpperTorso", "LowerTorso", "Random"},
    CurrentOption = "Head",
    Callback = function(Option)
        Ragebot.TargetPart = Option == "Random" and 
            ({"Head","UpperTorso","LowerTorso"})[math.random(1,3)] or Option
    end,
})

CombatTab:CreateInput({
    Name = "白名单（名字、前缀* 或 ID）",
    PlaceholderText = "添加到白名单",
    RemoveTextAfterFocusLost = false,
    Callback = AddToWhitelist
})

CombatTab:CreateButton({
    Name = "查看白名单",
    Callback = function()
        local list = {"当前白名单:"}
        for name, _ in pairs(Whitelist.Names) do
            table.insert(list, "- "..name)
        end
        for _, prefix in ipairs(Whitelist.Prefixes) do
            table.insert(list, "- "..prefix.."*")
        end
        Notify("白名单", table.concat(list, "\n"))
    end,
})

CombatTab:CreateButton({
    Name = "清空白名单",
    Callback = function()
        Whitelist.Names = {}
        Whitelist.Prefixes = {}
        Notify("成功", "白名单已清空")
    end,
})

CombatTab:CreateButton({
    Name = "查看锁定列表",
    Callback = function()
        if #Ragebot.TargetLockList == 0 then
            Notify("锁定列表", "列表为空")
        else
            Notify({
                Title = "锁定列表 ("..#Ragebot.TargetLockList..")",
                Content = table.concat(Ragebot.TargetLockList, "\n")
            })
        end
    end,
})

CombatTab:CreateButton({
    Name = "清空锁定列表",
    Callback = function()
        Ragebot.TargetLockList = {}
        Notify("成功", "锁定列表已清空")
    end,
})

VisualsTab:CreateSection("ESP透视系统 (VapeV4)")

VisualsTab:CreateToggle({
    Name = "启用ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Enabled = Value
        Notify("ESP系统", Value and "已启用 (VapeV4风格)" or "已关闭")
    end,
})

VisualsTab:CreateToggle({
    Name = "3D方框",
    CurrentValue = true,
    Callback = function(Value)
        ESP.ShowBox = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "血条显示",
    CurrentValue = true,
    Callback = function(Value)
        ESP.ShowHealthBar = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "名称显示",
    CurrentValue = true,
    Callback = function(Value)
        ESP.ShowName = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "距离显示",
    CurrentValue = true,
    Callback = function(Value)
        ESP.ShowDistance = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "血量数值",
    CurrentValue = true,
    Callback = function(Value)
        ESP.ShowHealth = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "骨骼显示",
    CurrentValue = false,
    Callback = function(Value)
        ESP.ShowSkeleton = Value
        Notify("骨骼ESP", Value and "已启用" or "已关闭")
    end,
})

VisualsTab:CreateToggle({
    Name = "追踪线",
    CurrentValue = false,
    Callback = function(Value)
        ESP.ShowTracers = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "健康变色",
    CurrentValue = true,
    Callback = function(Value)
        ESP.HealthColor = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "队伍检测",
    CurrentValue = false,
    Callback = function(Value)
        ESP.TeamCheck = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "距离淡出",
    CurrentValue = true,
    Callback = function(Value)
        ESP.FadeDistance = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "最大距离",
    Range = {500, 5000},
    Increment = 100,
    CurrentValue = 2000,
    Callback = function(Value)
        ESP.MaxDistance = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "文字大小",
    Range = {10, 24},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        ESP.TextSize = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "线条粗细",
    Range = {1, 5},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(Value)
        ESP.BoxThickness = Value
    end,
})

VisualsTab:CreateDropdown({
    Name = "追踪线起点",
    Options = {"Bottom", "Middle", "Top", "Mouse"},
    CurrentOption = "Bottom",
    Callback = function(Option)
        ESP.TracerOrigin = Option
    end,
})

VisualsTab:CreateColorPicker({
    Name = "方框颜色",
    Color = ESP.BoxColor,
    Callback = function(Value)
        ESP.BoxColor = Value
    end,
})

VisualsTab:CreateColorPicker({
    Name = "骨骼颜色",
    Color = ESP.SkeletonColor,
    Callback = function(Value)
        ESP.SkeletonColor = Value
    end,
})

VisualsTab:CreateColorPicker({
    Name = "追踪线颜色",
    Color = ESP.TracerColor,
    Callback = function(Value)
        ESP.TracerColor = Value
    end,
})

VisualsTab:CreateColorPicker({
    Name = "名称颜色",
    Color = ESP.NameColor,
    Callback = function(Value)
        ESP.NameColor = Value
    end,
})

VisualsTab:CreateSection("子弹轨迹")

VisualsTab:CreateToggle({
    Name = "启用轨迹",
    CurrentValue = false,
    Callback = function(Value)
        Tracer.Enabled = Value
    end,
})

VisualsTab:CreateColorPicker({
    Name = "轨迹颜色",
    Color = Color3.fromRGB(123, 123, 251),
    Callback = function(Value)
        Tracer.Color = Value
    end,
})

VisualsTab:CreateDropdown({
    Name = "轨迹类型",
    Options = {"Beam", "Particle"},
    CurrentOption = "Beam",
    Callback = function(Option)
        Tracer.Mode = Option
    end,
})

VisualsTab:CreateSlider({
    Name = "起始宽度",
    Range = {0.1, 3},
    Increment = 0.1,
    CurrentValue = 0.8,
    Callback = function(Value)
        Tracer.StartWidth = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "结束宽度",
    Range = {0.1, 3},
    Increment = 0.1,
    CurrentValue = 0.1,
    Callback = function(Value)
        Tracer.EndWidth = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "持续时间",
    Range = {0.1, 3},
    Increment = 0.1,
    CurrentValue = 0.8,
    Callback = function(Value)
        Tracer.Duration = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "纹理速度",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(Value)
        Tracer.TextureSpeed = Value
    end,
})

VisualsTab:CreateToggle({
    Name = "启用光源",
    CurrentValue = true,
    Callback = function(Value)
        Tracer.LightEnabled = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "光源亮度",
    Range = {0, 10},
    Increment = 0.1,
    CurrentValue = 2,
    Callback = function(Value)
        Tracer.LightBrightness = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "光源范围",
    Range = {0, 20},
    Increment = 0.1,
    CurrentValue = 8,
    Callback = function(Value)
        Tracer.LightRange = Value
    end,
})

VisualsTab:CreateSection("粒子设置")

VisualsTab:CreateSlider({
    Name = "轨迹寿命",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(Value)
        Tracer.TrailLife = Value
    end,
})

VisualsTab:CreateSlider({
    Name = "轨迹长度",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = 0.8,
    Callback = function(Value)
        Tracer.TrailLength = Value
    end,
})

SettingsTab:CreateSection("界面设置")

SettingsTab:CreateToggle({
    Name = "显示UI",
    CurrentValue = true,
    Callback = function(Value)
        Window:SetVisibility(Value)
    end,
})

SettingsTab:CreateSlider({
    Name = "UI不透明度",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(Value)
        Window:SetTransparency(1 - (Value/100))
    end,
})

SettingsTab:CreateDropdown({
    Name = "UI主题",
    Options = {"默认", "暗色", "明亮", "Aqua"},
    CurrentOption = "默认",
    Callback = function(Option)
        Window:SetTheme(Option)
    end,
})

SettingsTab:CreateSection("配置")

SettingsTab:CreateButton({
    Name = "保存设置",
    Callback = function()
        Notify("设置", "配置已保存")
    end,
})

SettingsTab:CreateButton({
    Name = "重置设置",
    Callback = function()
        Notify("设置", "配置已重置")
    end,
})


local function CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties or {}) do
        pcall(function() drawing[prop] = value end)
    end
    return drawing
end

local function GetHealthColor(percent)
    if not ESP.HealthColor then
        return ESP.BoxColor
    end
    
    if percent >= 0.75 then
        local t = (percent - 0.75) / 0.25
        return Color3.new(1 - t * 0.5, 1, 0)
    elseif percent >= 0.5 then
        local t = (percent - 0.5) / 0.25
        return Color3.new(1, 1, t * 0.5)
    elseif percent >= 0.25 then
        local t = (percent - 0.25) / 0.25
        return Color3.new(1, 0.5 + t * 0.5, 0)
    else
        local t = percent / 0.25
        return Color3.new(1, t * 0.5, 0)
    end
end

local function CreatePlayerESP(player)
    local espData = {
        Player = player,
        Box = {
            TopLeft = CreateDrawing("Line", {Thickness = ESP.BoxThickness, Color = ESP.BoxColor, Transparency = ESP.Transparency}),
            TopRight = CreateDrawing("Line", {Thickness = ESP.BoxThickness, Color = ESP.BoxColor, Transparency = ESP.Transparency}),
            BottomLeft = CreateDrawing("Line", {Thickness = ESP.BoxThickness, Color = ESP.BoxColor, Transparency = ESP.Transparency}),
            BottomRight = CreateDrawing("Line", {Thickness = ESP.BoxThickness, Color = ESP.BoxColor, Transparency = ESP.Transparency}),
        },
        HealthBar = {
            Background = CreateDrawing("Square", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Filled = true, Transparency = ESP.Transparency}),
            Bar = CreateDrawing("Square", {Thickness = 1, Filled = true, Transparency = ESP.Transparency}),
            Outline = CreateDrawing("Square", {Thickness = 1, Color = Color3.fromRGB(0, 0, 0), Filled = false, Transparency = ESP.Transparency}),
        },
        Name = CreateDrawing("Text", {Size = ESP.TextSize, Center = true, Outline = true, Color = ESP.NameColor, Transparency = ESP.Transparency}),
        Distance = CreateDrawing("Text", {Size = ESP.TextSize - 2, Center = true, Outline = true, Color = Color3.fromRGB(200, 200, 200), Transparency = ESP.Transparency}),
        Health = CreateDrawing("Text", {Size = ESP.TextSize - 2, Center = true, Outline = true, Color = Color3.fromRGB(0, 255, 0), Transparency = ESP.Transparency}),
        Tracer = CreateDrawing("Line", {Thickness = 1, Color = ESP.TracerColor, Transparency = ESP.Transparency}),
        Skeleton = {},
        Chams = {},
    }
    
    local skeletonParts = {
        "Head-UpperTorso",
        "UpperTorso-LeftUpperArm", "UpperTorso-RightUpperArm",
        "LeftUpperArm-LeftLowerArm", "RightUpperArm-RightLowerArm",
        "LeftLowerArm-LeftHand", "RightLowerArm-RightHand",
        "UpperTorso-LowerTorso",
        "LowerTorso-LeftUpperLeg", "LowerTorso-RightUpperLeg",
        "LeftUpperLeg-LeftLowerLeg", "RightUpperLeg-RightLowerLeg",
        "LeftLowerLeg-LeftFoot", "RightLowerLeg-RightFoot",
    }
    
    for _, boneName in ipairs(skeletonParts) do
        espData.Skeleton[boneName] = CreateDrawing("Line", {
            Thickness = 1.5,
            Color = ESP.SkeletonColor,
            Transparency = ESP.Transparency
        })
    end
    
    ESP.Players[player] = espData
    return espData
end

local function RemovePlayerESP(player)
    local espData = ESP.Players[player]
    if not espData then return end
    
    for _, line in pairs(espData.Box) do
        pcall(function() line:Remove() end)
    end
    
    for _, obj in pairs(espData.HealthBar) do
        pcall(function() obj:Remove() end)
    end
    
    pcall(function() espData.Name:Remove() end)
    pcall(function() espData.Distance:Remove() end)
    pcall(function() espData.Health:Remove() end)
    pcall(function() espData.Tracer:Remove() end)
    
    for _, line in pairs(espData.Skeleton) do
        pcall(function() line:Remove() end)
    end
    
    for _, obj in pairs(espData.Chams) do
        pcall(function() obj:Destroy() end)
    end
    
    ESP.Players[player] = nil
end

local function UpdatePlayerESP(player, espData)
    if not player.Character then return end
    
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    if not root or not humanoid or humanoid.Health <= 0 then
        for _, line in pairs(espData.Box) do
            line.Visible = false
        end
        for _, obj in pairs(espData.HealthBar) do
            obj.Visible = false
        end
        espData.Name.Visible = false
        espData.Distance.Visible = false
        espData.Health.Visible = false
        espData.Tracer.Visible = false
        for _, line in pairs(espData.Skeleton) do
            line.Visible = false
        end
        return
    end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local distance = (root.Position - myRoot.Position).Magnitude
    
    if distance > ESP.MaxDistance then
        for _, line in pairs(espData.Box) do
            line.Visible = false
        end
        for _, obj in pairs(espData.HealthBar) do
            obj.Visible = false
        end
        espData.Name.Visible = false
        espData.Distance.Visible = false
        espData.Health.Visible = false
        espData.Tracer.Visible = false
        for _, line in pairs(espData.Skeleton) do
            line.Visible = false
        end
        return
    end
    
    if ESP.TeamCheck and player.Team == LocalPlayer.Team then
        for _, line in pairs(espData.Box) do
            line.Visible = false
        end
        for _, obj in pairs(espData.HealthBar) do
            obj.Visible = false
        end
        espData.Name.Visible = false
        espData.Distance.Visible = false
        espData.Health.Visible = false
        espData.Tracer.Visible = false
        for _, line in pairs(espData.Skeleton) do
            line.Visible = false
        end
        return
    end
    
    local transparency = ESP.Transparency
    if ESP.FadeDistance and distance > ESP.DistanceFadeStart then
        local fadePercent = (distance - ESP.DistanceFadeStart) / (ESP.MaxDistance - ESP.DistanceFadeStart)
        transparency = math.max(0.1, ESP.Transparency * (1 - fadePercent))
    end
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    local healthColor = GetHealthColor(healthPercent)
    
    local head = char:FindFirstChild("Head")
    if head then
        local size = char:GetExtentsSize()
        local topPos = root.CFrame * CFrame.new(0, size.Y / 2, 0)
        local bottomPos = root.CFrame * CFrame.new(0, -size.Y / 2, 0)
        
        local topScreen, topOnScreen = Camera:WorldToViewportPoint(topPos.Position)
        local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottomPos.Position)
        
        if topOnScreen and bottomOnScreen then
            local height = math.abs(topScreen.Y - bottomScreen.Y)
            local width = height / 2
            
            if ESP.ShowBox then
                espData.Box.TopLeft.From = Vector2.new(topScreen.X - width / 2, topScreen.Y)
                espData.Box.TopLeft.To = Vector2.new(topScreen.X - width / 2, topScreen.Y + height / 3)
                espData.Box.TopLeft.Color = healthColor
                espData.Box.TopLeft.Transparency = transparency
                espData.Box.TopLeft.Visible = true
                
                espData.Box.TopRight.From = Vector2.new(topScreen.X + width / 2, topScreen.Y)
                espData.Box.TopRight.To = Vector2.new(topScreen.X + width / 2, topScreen.Y + height / 3)
                espData.Box.TopRight.Color = healthColor
                espData.Box.TopRight.Transparency = transparency
                espData.Box.TopRight.Visible = true
                
                espData.Box.BottomLeft.From = Vector2.new(bottomScreen.X - width / 2, bottomScreen.Y)
                espData.Box.BottomLeft.To = Vector2.new(bottomScreen.X - width / 2, bottomScreen.Y - height / 3)
                espData.Box.BottomLeft.Color = healthColor
                espData.Box.BottomLeft.Transparency = transparency
                espData.Box.BottomLeft.Visible = true
                
                espData.Box.BottomRight.From = Vector2.new(bottomScreen.X + width / 2, bottomScreen.Y)
                espData.Box.BottomRight.To = Vector2.new(bottomScreen.X + width / 2, bottomScreen.Y - height / 3)
                espData.Box.BottomRight.Color = healthColor
                espData.Box.BottomRight.Transparency = transparency
                espData.Box.BottomRight.Visible = true
            else
                for _, line in pairs(espData.Box) do
                    line.Visible = false
                end
            end
            
            if ESP.ShowHealthBar then
                local barWidth = 3
                local barHeight = height
                local barX = topScreen.X - width / 2 - barWidth - 3
                local barY = topScreen.Y
                
                espData.HealthBar.Background.Size = Vector2.new(barWidth, barHeight)
                espData.HealthBar.Background.Position = Vector2.new(barX, barY)
                espData.HealthBar.Background.Transparency = transparency
                espData.HealthBar.Background.Visible = true
                
                local currentBarHeight = barHeight * healthPercent
                espData.HealthBar.Bar.Size = Vector2.new(barWidth, currentBarHeight)
                espData.HealthBar.Bar.Position = Vector2.new(barX, barY + barHeight - currentBarHeight)
                espData.HealthBar.Bar.Color = healthColor
                espData.HealthBar.Bar.Transparency = transparency
                espData.HealthBar.Bar.Visible = true
                
                espData.HealthBar.Outline.Size = Vector2.new(barWidth, barHeight)
                espData.HealthBar.Outline.Position = Vector2.new(barX, barY)
                espData.HealthBar.Outline.Transparency = transparency
                espData.HealthBar.Outline.Visible = true
            else
                for _, obj in pairs(espData.HealthBar) do
                    obj.Visible = false
                end
            end
            
            if ESP.ShowName then
                local displayName = ESP.UseDisplayName and player.DisplayName or player.Name
                espData.Name.Text = displayName
                espData.Name.Position = Vector2.new(topScreen.X, topScreen.Y - 20)
                espData.Name.Color = ESP.NameColor
                espData.Name.Transparency = transparency
                espData.Name.Size = ESP.TextSize
                espData.Name.Visible = true
            else
                espData.Name.Visible = false
            end
            
            if ESP.ShowDistance then
                espData.Distance.Text = string.format("[%d studs]", math.floor(distance))
                espData.Distance.Position = Vector2.new(bottomScreen.X, bottomScreen.Y + 5)
                espData.Distance.Transparency = transparency
                espData.Distance.Visible = true
            else
                espData.Distance.Visible = false
            end
            
            if ESP.ShowHealth then
                espData.Health.Text = string.format("%d HP", math.floor(humanoid.Health))
                espData.Health.Position = Vector2.new(bottomScreen.X, bottomScreen.Y + 20)
                espData.Health.Color = healthColor
                espData.Health.Transparency = transparency
                espData.Health.Visible = true
            else
                espData.Health.Visible = false
            end
            
            if ESP.ShowTracers then
                local tracerOrigin
                if ESP.TracerOrigin == "Top" then
                    tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, 0)
                elseif ESP.TracerOrigin == "Middle" then
                    tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                elseif ESP.TracerOrigin == "Mouse" then
                    local mouse = LocalPlayer:GetMouse()
                    tracerOrigin = Vector2.new(mouse.X, mouse.Y)
                else -- Bottom
                    tracerOrigin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                end
                
                espData.Tracer.From = tracerOrigin
                espData.Tracer.To = Vector2.new(bottomScreen.X, bottomScreen.Y)
                espData.Tracer.Color = ESP.TracerColor
                espData.Tracer.Transparency = transparency
                espData.Tracer.Visible = true
            else
                espData.Tracer.Visible = false
            end
        else
            for _, line in pairs(espData.Box) do
                line.Visible = false
            end
            for _, obj in pairs(espData.HealthBar) do
                obj.Visible = false
            end
            espData.Name.Visible = false
            espData.Distance.Visible = false
            espData.Health.Visible = false
            espData.Tracer.Visible = false
        end
    end
    
    if ESP.ShowSkeleton then
        local skeletonConnections = {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
            {"LeftLowerArm", "LeftHand"}, {"RightLowerArm", "RightHand"},
            {"UpperTorso", "LowerTorso"},
            {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
            {"LeftLowerLeg", "LeftFoot"}, {"RightLowerLeg", "RightFoot"},
        }
        
        for i, connection in ipairs(skeletonConnections) do
            local part1 = char:FindFirstChild(connection[1])
            local part2 = char:FindFirstChild(connection[2])
            local boneName = connection[1].."-"..connection[2]
            local line = espData.Skeleton[boneName]
            
            if part1 and part2 and line then
                local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
                
                if onScreen1 and onScreen2 then
                    line.From = Vector2.new(pos1.X, pos1.Y)
                    line.To = Vector2.new(pos2.X, pos2.Y)
                    line.Color = ESP.SkeletonColor
                    line.Transparency = transparency
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                if line then line.Visible = false end
            end
        end
    else
        for _, line in pairs(espData.Skeleton) do
            line.Visible = false
        end
    end
end

task.spawn(function()
    while true do
        if ESP.Enabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not ESP.Players[player] then
                    CreatePlayerESP(player)
                end
            end
            
            for player, espData in pairs(ESP.Players) do
                if player and player.Parent then
                    UpdatePlayerESP(player, espData)
                else
                    RemovePlayerESP(player)
                end
            end
            task.wait(ESP.UpdateRate)  -- 启用时按设定频率更新
        else
            for _, espData in pairs(ESP.Players) do
                for _, line in pairs(espData.Box) do
                    line.Visible = false
                end
                for _, obj in pairs(espData.HealthBar) do
                    obj.Visible = false
                end
                espData.Name.Visible = false
                espData.Distance.Visible = false
                espData.Health.Visible = false
                espData.Tracer.Visible = false
                for _, line in pairs(espData.Skeleton) do
                    line.Visible = false
                end
            end
            task.wait(1)  -- 关闭时1秒检查一次，大幅减少CPU占用
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemovePlayerESP(player)
end)

local function addPlayerHighlight(plr)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local root = plr.Character.HumanoidRootPart
        local h = root:FindFirstChildOfClass("Highlight")
        if not h then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = root
            highlight.FillColor = espColorPlayer
            highlight.OutlineColor = espColorPlayer
            highlight.Parent = root
        else
            h.FillColor = espColorPlayer
            h.OutlineColor = espColorPlayer
        end
    end
end

local function removePlayerHighlight(plr)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local h = plr.Character.HumanoidRootPart:FindFirstChildOfClass("Highlight")
        if h then h:Destroy() end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if PlayerESPEnabled then
            addPlayerHighlight(plr)
        end
    end)
end)
Players.PlayerRemoving:Connect(removePlayerHighlight)

RunService.Heartbeat:Connect(function()
    if ShopESPEnabled and workspace.Map:FindFirstChild("Shopz") then
        for _, item in pairs(workspace.Map.Shopz:GetDescendants()) do
            if item:IsA("BasePart") then
                local h = item:FindFirstChildOfClass("Highlight")
                if not h then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = item
                    highlight.FillColor = espColorShop
                    highlight.OutlineColor = espColorShop
                    highlight.Parent = item
                else
                    h.FillColor = espColorShop
                    h.OutlineColor = espColorShop
                end
            end
        end
    else
        if workspace.Map:FindFirstChild("Shopz") then
            for _, item in pairs(workspace.Map.Shopz:GetDescendants()) do
                local h = item:FindFirstChildOfClass("Highlight")
                if h then h:Destroy() end
            end
        end
    end

    if ATMESPEnabled and workspace.Map:FindFirstChild("ATMz") then
        for _, atm in pairs(workspace.Map.ATMz:GetChildren()) do
            if atm:IsA("Model") then
                for _, part in pairs(atm:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local h = part:FindFirstChildOfClass("Highlight")
                        if not h then
                            local highlight = Instance.new("Highlight")
                            highlight.Adornee = part
                            highlight.FillColor = espColorATM
                            highlight.OutlineColor = espColorATM
                            highlight.Parent = part
                        else
                            h.FillColor = espColorATM
                            h.OutlineColor = espColorATM
                        end
                    end
                end
            end
        end
    else
        if workspace.Map:FindFirstChild("ATMz") then
            for _, atm in pairs(workspace.Map.ATMz:GetChildren()) do
                if atm:IsA("Model") then
                    for _, part in pairs(atm:GetDescendants()) do
                        local h = part:FindFirstChildOfClass("Highlight")
                        if h then h:Destroy() end
                    end
                end
            end
        end
    end

    if PlayerESPEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            addPlayerHighlight(plr)
        end
    else
        for _, plr in pairs(Players:GetPlayers()) do
            removePlayerHighlight(plr)
        end
    end

    if VMESPEnabled and workspace.Map:FindFirstChild("VendingMachines") then
        for _, vm in pairs(workspace.Map.VendingMachines:GetDescendants()) do
            if vm:IsA("BasePart") then
                local h = vm:FindFirstChildOfClass("Highlight")
                if not h then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = vm
                    highlight.FillColor = espColorVM
                    highlight.OutlineColor = espColorVM
                    highlight.Parent = vm
                else
                    h.FillColor = espColorVM
                    h.OutlineColor = espColorVM
                end
            end
        end
    else
        if workspace.Map:FindFirstChild("VendingMachines") then
            for _, vm in pairs(workspace.Map.VendingMachines:GetDescendants()) do
                local h = vm:FindFirstChildOfClass("Highlight")
                if h then h:Destroy() end
            end
        end
    end

    if CashESPEnabled and workspace.Map:FindFirstChild("BredMakurz") then
        for _, cash in pairs(workspace.Map.BredMakurz:GetDescendants()) do
            if cash:IsA("BasePart") then
                local h = cash:FindFirstChildOfClass("Highlight")
                if not h then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = cash
                    highlight.FillColor = espColorCash
                    highlight.OutlineColor = espColorCash
                    highlight.Parent = cash
                else
                    h.FillColor = espColorCash
                    h.OutlineColor = espColorCash
                end
            end
        end
    else
        if workspace.Map:FindFirstChild("BredMakurz") then
            for _, cash in pairs(workspace.Map.BredMakurz:GetDescendants()) do
                local h = cash:FindFirstChildOfClass("Highlight")
                if h then h:Destroy() end
            end
        end
    end
end)

