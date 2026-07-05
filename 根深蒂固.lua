local function GetNil(Name, DebugId)
	for _, Object in getnilinstances() do
		if Object.Name == Name and Object:GetDebugId() == DebugId then
			return Object
		end
	end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")


local function GetCurrentTool()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    return nil
end


local function GetToolStats(tool)
    if not tool then return nil, nil end
    
    local ammoCapacity = tool:FindFirstChild("AmmoCapacity")
    local fireDelay = tool:FindFirstChild("FireDelay")
    
    local ammoValue = ammoCapacity and ammoCapacity.Value or 5
    local fireValue = fireDelay and fireDelay.Value or 0.1 
    
    return ammoValue, fireValue
end


local function GetToolParts(tool)
    if not tool then return nil, nil, nil end
    
    local hold = tool:FindFirstChild("Hold")
    local sounds = hold and hold:FindFirstChild("Sounds")
    local meleeTrail = hold and hold:FindFirstChild("MeleeTrail")
    
    return hold, sounds, meleeTrail
end


local function IsPlayerAlive(player)
    if not player then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end


local function HasCover(startPos, endPos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.IgnoreWater = true
    
    local rayResult = Workspace:Raycast(startPos, (endPos - startPos), params)
    
    if rayResult then
        local hit = rayResult.Instance
        if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
            return false
        end
        return true
    end
    return false
end


local function GetBestEnemy()
    local character = LocalPlayer.Character
    if not character then return nil, nil, nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil, nil, nil end
    
    local currentPos = rootPart.Position
    local bestTarget = nil
    local bestDistance = 150
    local bestPos = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not IsPlayerAlive(player) then
                continue
            end
            
            local team1 = LocalPlayer.Team
            local team2 = player.Team
            if team1 and team2 and team1 == team2 then
                continue
            end
            
            local targetChar = player.Character
            if not targetChar then continue end
            
            local head = targetChar:FindFirstChild("Head")
            if not head then continue end
            
            local distance = (currentPos - head.Position).Magnitude
            if distance > 150 then
                continue
            end
            
            
            if HasCover(currentPos, head.Position) then
                
                if distance > 50 then
                    continue
                end
            end
            
            if distance < bestDistance then
                bestDistance = distance
                bestTarget = player
                bestPos = head.Position
            end
        end
    end
    
    return bestTarget, bestPos, bestDistance
end

local function GetTargetPositions()
    local target, targetPos, distance = GetBestEnemy()
    
    if target and targetPos then
        
        local pos1 = targetPos + Vector3.new(
            math.random(-1, 1) * 0.1,
            math.random(-1, 1) * 0.1,
            math.random(-1, 1) * 0.1
        )
        local pos2 = targetPos + Vector3.new(0, 0.3, 0)
        return pos1, pos2, true
    end
    
    return nil, nil, false
end


local function FireShootEvent()
    local Event = game:GetService("ReplicatedStorage").ServerEvents.Shoot
    if not Event then return end
    
    local tool = GetCurrentTool()
    if not tool then
        return
    end
    
    local pos1, pos2, hasTarget = GetTargetPositions()
    
    if not hasTarget then
        return
    end
    
    if not IsPlayerAlive(LocalPlayer) then
        return
    end
    
    if not LocalPlayer.Character then
        return
    end
    
    local hold, sounds, meleeTrail = GetToolParts(tool)
    if not hold then
        return
    end
    
    
    local ammoCapacity, fireDelay = GetToolStats(tool)
    
    Event:FireServer(
        {
            currentShots = 1,
            LoadedAnimations = true,
            hapticLeftTrigger = false,
            animationList = {
                boltCycleAnimation = GetNil("boltCycle", "0_2701986"),
                runAnimation = GetNil("run", "0_2701989"),
                aimAnimation = GetNil("aim", "0_2701983"),
                aimFireAnimation = GetNil("aimFire", "0_2701985"),
                meleeAnimation = GetNil("melee", "0_2701988"),
                hipFireAnimation = GetNil("hipFire", "0_2701987"),
                reloadAnimation = GetNil("reload", "0_2701984"),
                equipAnimation = GetNil("equip", "0_2701982")
            },
            Sounds = sounds,
            Character = LocalPlayer.Character,
            clientCanFire = true,
            handleAction = function(arg1, arg2, arg3)
                return
            end,
            LoadedEvents = true,
            Tool = tool,
            hapticRightTrigger = false,
            actionBinds = {
                Shoot = {
                    true,
                    Enum.UserInputType.MouseButton1,
                    Enum.KeyCode.ButtonR2
                },
                Melee = {
                    true,
                    Enum.UserInputType.MouseButton3,
                    Enum.KeyCode.V,
                    Enum.KeyCode.ButtonB
                },
                Aim = {
                    true,
                    Enum.UserInputType.MouseButton2,
                    Enum.KeyCode.Q,
                    Enum.KeyCode.ButtonL2
                },
                Perspective = {
                    true,
                    Enum.KeyCode.E,
                    Enum.KeyCode.ButtonR3
                },
                Reload = {
                    true,
                    Enum.KeyCode.R,
                    Enum.KeyCode.ButtonX
                }
            },
            isVibrationSupported = true,
            meleeTrail = meleeTrail,
            Player = LocalPlayer,
            hapticLeftHand = false,
            RecoilPattern = {
                {
                    ammoCapacity,
                    fireDelay,
                    -1,
                    0.77,
                    -0.1
                },
                {
                    ammoCapacity,
                    fireDelay,
                    -1,
                    0.77,
                    -0.66666666666667
                },
                {
                    ammoCapacity,
                    fireDelay,
                    0.77,
                    0.66666666666667
                }
            },
            Cycle = true,
            resetBool = {
                meleeHoldRepeat = false,
                shootHoldRepeat = false
            },
            hapticLarge = true,
            Camera = workspace.Camera,
            lastClick = tick(),
            hapticRightHand = false,
            hapticSmall = true
        },
        pos1,
        true,
        1,
        {},
        pos2
    )
end

while wait(0.1) do
    pcall(function()
        FireShootEvent()
    end)
end