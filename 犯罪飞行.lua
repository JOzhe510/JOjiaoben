local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
local window = DrRayLibrary:Load("飞行脚本", "Default")

local tab = DrRayLibrary.newTab("犯罪飞行功能", "ImageIdHere")

local CFSpeed = 50
local CFLoop = nil

local function StartCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local head = character:WaitForChild("Head")
    
    if not humanoid or not head then return end
    
    humanoid.PlatformStand = true
    head.Anchored = true
    
    if CFLoop then 
        CFLoop:Disconnect() 
        CFLoop = nil
    end
    
    CFLoop = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if not character or not humanoid or not head then 
            if CFLoop then 
                CFLoop:Disconnect() 
                CFLoop = nil
            end
            return 
        end
        
        local moveDirection = humanoid.MoveDirection * (CFSpeed * deltaTime)
        local headCFrame = head.CFrame
        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
        cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
        local cameraPosition = cameraCFrame.Position
        local headPosition = headCFrame.Position

        local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
        head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
    end)
end

local function StopCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    
    if CFLoop then
        CFLoop:Disconnect()
        CFLoop = nil
    end
    
    if character then
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        local head = character:FindFirstChild("Head")
        
        if humanoid then
            humanoid.PlatformStand = false
        end
        if head then
            head.Anchored = false
        end
    end
end

tab.newToggle("飞行开关", "开启或关闭飞行功能", false, function(toggleState)
    if toggleState then
        StartCFly()
        print('飞行已开启')
    else
        StopCFly()
        print('飞行已关闭')
    end
end)

tab.newSlider("飞行速度", "调节飞行速度", 200, false, function(value)
    CFSpeed = value
    print('飞行速度已设置为: ' .. value)
end)

tab.newButton("布偶25持续时间", "提醒先开这个再用飞行", function()
    -- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote
local ChangeState = ReplicatedStorage.Events.ChangeState -- RemoteEvent 

-- This data was received from the server
firesignal(ChangeState.OnClientEvent, 
    Enum.HumanoidStateType.FallingDown, -- 改为落地状态
    25
)
end)

tab.newButton("布偶50持续时间", "提醒先开这个再用飞行", function()
    -- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote
local ChangeState = ReplicatedStorage.Events.ChangeState -- RemoteEvent 

-- This data was received from the server
firesignal(ChangeState.OnClientEvent, 
    Enum.HumanoidStateType.FallingDown, -- 改为落地状态
    50
)
end)

tab.newButton("布偶100持续时间", "提醒先开这个再用飞行", function()
    -- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote
local ChangeState = ReplicatedStorage.Events.ChangeState -- RemoteEvent 

-- This data was received from the server
firesignal(ChangeState.OnClientEvent, 
    Enum.HumanoidStateType.FallingDown, -- 改为落地状态
    100
)
end)

tab.newButton("布偶250持续时间", "提醒先开这个再用飞行", function()
    -- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote
local ChangeState = ReplicatedStorage.Events.ChangeState -- RemoteEvent 

-- This data was received from the server
firesignal(ChangeState.OnClientEvent, 
    Enum.HumanoidStateType.FallingDown, -- 改为落地状态
    250
)
end)

tab.newButton("布偶500持续时间", "提醒先开这个再用飞行", function()
    -- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote
local ChangeState = ReplicatedStorage.Events.ChangeState -- RemoteEvent 

-- This data was received from the server
firesignal(ChangeState.OnClientEvent, 
    Enum.HumanoidStateType.FallingDown, -- 改为落地状态
    500
)
end)