local function GetNil(Name, DebugId)
	for _, Object in getnilinstances() do
		if Object.Name == Name and Object:GetDebugId() == DebugId then
			return Object
		end
	end
end

local Players = game:GetService("Players")
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

local function GetToolParts(tool)
    if not tool then return nil, nil end
    
    local hold = tool:FindFirstChild("Hold")
    local sounds = hold and hold:FindFirstChild("Sounds")
    
    return hold, sounds
end

local function IsPlayerAlive(player)
    if not player then return false end
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function FireReloadEvent()
    local Event = game:GetService("ReplicatedStorage").ServerEvents.Reload
    if not Event then return end
    
    local tool = GetCurrentTool()
    if not tool then
        return
    end
    
    if not IsPlayerAlive(LocalPlayer) then
        return
    end
    
    if not LocalPlayer.Character then
        return
    end
    
    local hold, sounds = GetToolParts(tool)
    if not hold then
        return
    end
    
    Event:InvokeServer(
        {
            resetBool = {
                shootHoldRepeat = false
            },
            LoadedAnimations = true,
            hapticLeftTrigger = false,
            animationList = {
                equipAnimation = GetNil("equip", "0_287184"),
                aimAnimation = GetNil("aim", "0_287185"),
                aimFireAnimation = GetNil("aimFire", "0_287186"),
                hipFireAnimation = GetNil("hipFire", "0_287187"),
                runAnimation = GetNil("run", "0_287188"),
                reloadAnimation = GetNil("reload", "0_287189")
            },
            Sounds = sounds,
            Character = LocalPlayer.Character,
            clientCanFire = true,
            hapticSmall = true,
            LoadedEvents = true,
            Tool = tool,
            isVibrationSupported = true,
            RepeatCount = 1,
            actionBinds = {
                Shoot = {
                    true,
                    Enum.UserInputType.MouseButton1,
                    Enum.KeyCode.ButtonR2
                },
                Reload = {
                    true,
                    Enum.KeyCode.R,
                    Enum.KeyCode.ButtonX
                },
                Perspective = {
                    true,
                    Enum.KeyCode.E,
                    Enum.KeyCode.ButtonR3
                },
                Aim = {
                    true,
                    Enum.UserInputType.MouseButton2,
                    Enum.KeyCode.Q,
                    Enum.KeyCode.ButtonL2
                }
            },
            currentShots = 3,
            hapticRightHand = false,
            Repeats = 0,
            Player = LocalPlayer,
            RecoilPattern = {
                {
                    1,
                    1.8,
                    -1,
                    0.77,
                    -0.1
                },
                {
                    6,
                    0.9,
                    -1,
                    0.77,
                    -0.12
                },
                {
                    11,
                    0.9,
                    -1,
                    0.77,
                    0.12
                }
            },
            hapticLeftHand = false,
            hapticRightTrigger = false,
            hapticLarge = true,
            Camera = workspace.Camera,
            lastClick = tick(),
            handleAction = function(arg1, arg2, arg3)
                return
            end
        }
    )
end

while wait(0.1) do
    pcall(function()
        FireReloadEvent()
    end)
end