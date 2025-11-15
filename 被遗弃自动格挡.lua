local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local SoundBlockUI = Instance.new("ScreenGui")
SoundBlockUI.Name = "SoundBlockUI"
SoundBlockUI.Parent = game:GetService("CoreGui")
SoundBlockUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = SoundBlockUI
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 280) -- 进一步增加高度以容纳更多控件
MainFrame.Active = true
MainFrame.Draggable = true

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.Text = "SOUND BLOCK [OFF]"
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0.05, 0, 0.02, 0)
TitleLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
TitleLabel.Font = Enum.Font.Cartoon
TitleLabel.TextColor3 = Color3.fromRGB(186, 48, 255)
TitleLabel.TextScaled = true

-- 距离调节滑块
local DistanceSlider = Instance.new("Frame")
DistanceSlider.Name = "DistanceSlider"
DistanceSlider.Parent = MainFrame
DistanceSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DistanceSlider.BorderSizePixel = 0
DistanceSlider.Position = UDim2.new(0.05, 0, 0.14, 0)
DistanceSlider.Size = UDim2.new(0.9, 0, 0.06, 0)

local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Name = "DistanceLabel"
DistanceLabel.Parent = DistanceSlider
DistanceLabel.Text = "距离: 17"
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Size = UDim2.new(1, 0, 1, 0)
DistanceLabel.Font = Enum.Font.Cartoon
DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceLabel.TextScaled = true

local DistanceValue = Instance.new("TextButton")
DistanceValue.Name = "DistanceValue"
DistanceValue.Parent = DistanceSlider
DistanceValue.BackgroundColor3 = Color3.fromRGB(186, 48, 255)
DistanceValue.BorderSizePixel = 0
DistanceValue.Size = UDim2.new(0.57, 0, 1, 0) -- 初始值为17/30 ≈ 0.57
DistanceValue.Text = ""
DistanceValue.AutoButtonColor = false

-- 角度范围调节滑块
local AngleSlider = Instance.new("Frame")
AngleSlider.Name = "AngleSlider"
AngleSlider.Parent = MainFrame
AngleSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AngleSlider.BorderSizePixel = 0
AngleSlider.Position = UDim2.new(0.05, 0, 0.22, 0)
AngleSlider.Size = UDim2.new(0.9, 0, 0.06, 0)

local AngleLabel = Instance.new("TextLabel")
AngleLabel.Name = "AngleLabel"
AngleLabel.Parent = AngleSlider
AngleLabel.Text = "角度范围: 90°"
AngleLabel.BackgroundTransparency = 1
AngleLabel.Size = UDim2.new(1, 0, 1, 0)
AngleLabel.Font = Enum.Font.Cartoon
AngleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AngleLabel.TextScaled = true

local AngleValue = Instance.new("TextButton")
AngleValue.Name = "AngleValue"
AngleValue.Parent = AngleSlider
AngleValue.BackgroundColor3 = Color3.fromRGB(186, 48, 255)
AngleValue.BorderSizePixel = 0
AngleValue.Size = UDim2.new(0.5, 0, 1, 0) -- 初始值为90/180 = 0.5
AngleValue.Text = ""
AngleValue.AutoButtonColor = false

-- 预测时间调节滑块
local PredictionSlider = Instance.new("Frame")
PredictionSlider.Name = "PredictionSlider"
PredictionSlider.Parent = MainFrame
PredictionSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PredictionSlider.BorderSizePixel = 0
PredictionSlider.Position = UDim2.new(0.05, 0, 0.3, 0)
PredictionSlider.Size = UDim2.new(0.9, 0, 0.06, 0)

local PredictionLabel = Instance.new("TextLabel")
PredictionLabel.Name = "PredictionLabel"
PredictionLabel.Parent = PredictionSlider
PredictionLabel.Text = "预测时间: 0.2s"
PredictionLabel.BackgroundTransparency = 1
PredictionLabel.Size = UDim2.new(1, 0, 1, 0)
PredictionLabel.Font = Enum.Font.Cartoon
PredictionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictionLabel.TextScaled = true

local PredictionValue = Instance.new("TextButton")
PredictionValue.Name = "PredictionValue"
PredictionValue.Parent = PredictionSlider
PredictionValue.BackgroundColor3 = Color3.fromRGB(186, 48, 255)
PredictionValue.BorderSizePixel = 0
PredictionValue.Size = UDim2.new(0.4, 0, 1, 0) -- 初始值为0.2/0.5 = 0.4
PredictionValue.Text = ""
PredictionValue.AutoButtonColor = false

-- 冷却时间调节滑块
local CooldownSlider = Instance.new("Frame")
CooldownSlider.Name = "CooldownSlider"
CooldownSlider.Parent = MainFrame
CooldownSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CooldownSlider.BorderSizePixel = 0
CooldownSlider.Position = UDim2.new(0.05, 0, 0.38, 0)
CooldownSlider.Size = UDim2.new(0.9, 0, 0.06, 0)

local CooldownLabel = Instance.new("TextLabel")
CooldownLabel.Name = "CooldownLabel"
CooldownLabel.Parent = CooldownSlider
CooldownLabel.Text = "冷却时间: 0.3s"
CooldownLabel.BackgroundTransparency = 1
CooldownLabel.Size = UDim2.new(1, 0, 1, 0)
CooldownLabel.Font = Enum.Font.Cartoon
CooldownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CooldownLabel.TextScaled = true

local CooldownValue = Instance.new("TextButton")
CooldownValue.Name = "CooldownValue"
CooldownValue.Parent = CooldownSlider
CooldownValue.BackgroundColor3 = Color3.fromRGB(186, 48, 255)
CooldownValue.BorderSizePixel = 0
CooldownValue.Size = UDim2.new(0.3, 0, 1, 0) -- 初始值为0.3/1.0 = 0.3
CooldownValue.Text = ""
CooldownValue.AutoButtonColor = false

-- 角度检测开关
local AngleToggle = Instance.new("TextButton")
AngleToggle.Name = "AngleToggle"
AngleToggle.Parent = MainFrame
AngleToggle.Text = "角度检测: OFF"
AngleToggle.Position = UDim2.new(0.05, 0, 0.48, 0)
AngleToggle.Size = UDim2.new(0.9, 0, 0.08, 0)
AngleToggle.Font = Enum.Font.Cartoon
AngleToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AngleToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AngleToggle.BorderSizePixel = 0

-- 预测格挡开关
local PredictionToggle = Instance.new("TextButton")
PredictionToggle.Name = "PredictionToggle"
PredictionToggle.Parent = MainFrame
PredictionToggle.Text = "预测格挡: OFF"
PredictionToggle.Position = UDim2.new(0.05, 0, 0.58, 0)
PredictionToggle.Size = UDim2.new(0.9, 0, 0.08, 0)
PredictionToggle.Font = Enum.Font.Cartoon
PredictionToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
PredictionToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
PredictionToggle.BorderSizePixel = 0

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = MainFrame
ToggleBtn.Text = "TOGGLE"
ToggleBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0.12, 0)
ToggleBtn.Font = Enum.Font.Cartoon
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local TARGET_SOUND_IDS = {
    "rbxassetid://119583605486352",
    "rbxassetid://112809109188560",
    "rbxassetid://102228729296384",
    "rbxassetid://84307400688050",
    "rbxassetid://86174610237192",
    "rbxassetid://140242176732868",
    "rbxassetid://136323728355613",
    "rbxassetid://115026634746636",
    "rbxassetid://108907358619313",
    "rbxassetid://127793641088496",
    "rbxassetid://79980897195554"
}

local soundLookup = {}
for _, id in ipairs(TARGET_SOUND_IDS) do
    soundLookup[id] = true
end

local isEnabled = false
local isAlive = true
local DETECTION_RADIUS = 17
local MAX_DETECTION_RADIUS = 30
local ANGLE_RANGE = 90
local MAX_ANGLE_RANGE = 180
local PREDICTION_TIME = 0.2
local MAX_PREDICTION_TIME = 0.5
local COOLDOWN = 0.3
local MAX_COOLDOWN = 1.0
local lastTriggerTime = 0
local useAngleDetection = false
local usePrediction = false

local Character
local HumanoidRootPart

local RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")

-- 更新距离滑块显示
local function UpdateDistanceDisplay()
    DistanceLabel.Text = "距离: " .. tostring(DETECTION_RADIUS)
    DistanceValue.Size = UDim2.new(DETECTION_RADIUS / MAX_DETECTION_RADIUS, 0, 1, 0)
end

-- 更新角度滑块显示
local function UpdateAngleDisplay()
    AngleLabel.Text = "角度范围: " .. tostring(ANGLE_RANGE) .. "°"
    AngleValue.Size = UDim2.new(ANGLE_RANGE / MAX_ANGLE_RANGE, 0, 1, 0)
end

-- 更新预测时间显示
local function UpdatePredictionDisplay()
    PredictionLabel.Text = "预测时间: " .. string.format("%.2fs", PREDICTION_TIME)
    PredictionValue.Size = UDim2.new(PREDICTION_TIME / MAX_PREDICTION_TIME, 0, 1, 0)
end

-- 更新冷却时间显示
local function UpdateCooldownDisplay()
    CooldownLabel.Text = "冷却时间: " .. string.format("%.2fs", COOLDOWN)
    CooldownValue.Size = UDim2.new(COOLDOWN / MAX_COOLDOWN, 0, 1, 0)
end

-- 计算两点之间的角度（以玩家前方为基准）
local function CalculateAngle(playerPos, playerLookVector, targetPos)
    local directionToTarget = (targetPos - playerPos).Unit
    local dotProduct = playerLookVector:Dot(directionToTarget)
    return math.acos(dotProduct) * (180 / math.pi)
end

local function ResetSystem()
    Character = Player.Character
    if not Character then return end
    
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    isAlive = true
    isEnabled = false
    
    TitleLabel.Text = "SOUND BLOCK [OFF]"
    ToggleBtn.Text = "TOGGLE"
end

local soundDetectionTimes = {}

task.spawn(function()
    while true do
        if not isEnabled or not isAlive then
            task.wait(0.1)
            continue
        end
        
        if not Character or not HumanoidRootPart then
            task.wait(0.1)
            continue
        end
        
        local currentTime = tick()
        local playerPos = HumanoidRootPart.Position
        local playerLookVector = HumanoidRootPart.CFrame.LookVector
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player then
                local char = player.Character
                if char and HumanoidRootPart then
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    
                    if rootPart then
                        local distance = (playerPos - rootPart.Position).Magnitude
                        
                        -- 距离检查
                        if distance <= DETECTION_RADIUS then
                            -- 角度检查（如果启用）
                            local shouldCheckAngle = useAngleDetection
                            local angle = 0
                            
                            if shouldCheckAngle then
                                angle = CalculateAngle(playerPos, playerLookVector, rootPart.Position)
                                shouldCheckAngle = (angle <= ANGLE_RANGE) -- 使用可调节的角度范围
                            end
                            
                            if not useAngleDetection or shouldCheckAngle then
                                for _, sound in ipairs(char:GetDescendants()) do
                                    if sound:IsA("Sound") and sound.IsPlaying and soundLookup[sound.SoundId] then
                                        -- 预测逻辑（如果启用）
                                        local detectionTime = currentTime
                                        if usePrediction then
                                            -- 根据距离调整预测时间
                                            local adjustedPredictionTime = PREDICTION_TIME * (distance / DETECTION_RADIUS)
                                            detectionTime = currentTime + adjustedPredictionTime
                                        end
                                        
                                        soundDetectionTimes[sound] = {
                                            detectionTime = detectionTime,
                                            soundStartTime = sound.TimePosition,
                                            predicted = usePrediction
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        task.wait()
    end
end)

task.spawn(function()
    while true do
        if not isEnabled or not isAlive then
            task.wait(0)
            continue
        end
        
        local currentTime = tick()
        
        for sound, detectionInfo in pairs(soundDetectionTimes) do
            local shouldTrigger = false
            
            if detectionInfo.predicted then
                -- 预测模式：在预测时间到达时触发
                shouldTrigger = currentTime >= detectionInfo.detectionTime
            else
                -- 普通模式：在声音刚开始时触发
                shouldTrigger = sound.IsPlaying and sound.TimePosition <= 0.05
            end
            
            if shouldTrigger then
                if currentTime - lastTriggerTime > COOLDOWN then
                    lastTriggerTime = currentTime
                    
                    local args = {
                        [1] = "UseActorAbility",
                        [2] = {
                            [1] = buffer.fromstring("\"Block\"")
                        }
                    }
                    
                    local success, err = pcall(function()
                        RemoteEvent:FireServer(unpack(args))
                    end)
                    
                    soundDetectionTimes[sound] = nil
                    break
                end
            elseif not sound.IsPlaying or (not detectionInfo.predicted and sound.TimePosition > 0.1) then
                soundDetectionTimes[sound] = nil
            end
        end
        
        task.wait()
    end
end)

-- 通用的滑块处理函数
local function CreateSliderHandler(sliderFrame, valueButton, minValue, maxValue, updateFunction, formatFunction)
    local isDragging = false
    
    valueButton.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local sliderAbsPos = sliderFrame.AbsolutePosition
            local sliderAbsSize = sliderFrame.AbsoluteSize
            
            local relativeX = (mousePos.X - sliderAbsPos.X) / sliderAbsSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            local value = minValue + relativeX * (maxValue - minValue)
            if formatFunction then
                value = formatFunction(value)
            end
            
            updateFunction(value)
        end
    end)
end

-- 距离滑块
CreateSliderHandler(DistanceSlider, DistanceValue, 5, MAX_DETECTION_RADIUS, function(value)
    DETECTION_RADIUS = math.floor(value)
    UpdateDistanceDisplay()
end, math.floor)

-- 角度滑块
CreateSliderHandler(AngleSlider, AngleValue, 30, MAX_ANGLE_RANGE, function(value)
    ANGLE_RANGE = math.floor(value)
    UpdateAngleDisplay()
end, math.floor)

-- 预测时间滑块
CreateSliderHandler(PredictionSlider, PredictionValue, 0.05, MAX_PREDICTION_TIME, function(value)
    PREDICTION_TIME = value
    UpdatePredictionDisplay()
end)

-- 冷却时间滑块
CreateSliderHandler(CooldownSlider, CooldownValue, 0.1, MAX_COOLDOWN, function(value)
    COOLDOWN = value
    UpdateCooldownDisplay()
end)

-- 角度检测开关
AngleToggle.MouseButton1Click:Connect(function()
    useAngleDetection = not useAngleDetection
    AngleToggle.Text = "角度检测: " .. (useAngleDetection and "ON" or "OFF")
    AngleToggle.BackgroundColor3 = useAngleDetection and Color3.fromRGB(186, 48, 255) or Color3.fromRGB(80, 80, 80)
end)

-- 预测格挡开关
PredictionToggle.MouseButton1Click:Connect(function()
    usePrediction = not usePrediction
    PredictionToggle.Text = "预测格挡: " .. (usePrediction and "ON" or "OFF")
    PredictionToggle.BackgroundColor3 = usePrediction and Color3.fromRGB(186, 48, 255) or Color3.fromRGB(80, 80, 80)
end)

ResetSystem()
UpdateDistanceDisplay()
UpdateAngleDisplay()
UpdatePredictionDisplay()
UpdateCooldownDisplay()

Player.CharacterAdded:Connect(function()
    ResetSystem()
end)

Player.CharacterRemoving:Connect(function()
    isAlive = false
    isEnabled = false
    TitleLabel.Text = "音频自动格挡 [OFF]"
    ToggleBtn.Text = "TOGGLE"
end)

ToggleBtn.MouseButton1Click:Connect(function()
    if isAlive then
        isEnabled = not isEnabled
        TitleLabel.Text = "音频自动格挡 ["..(isEnabled and "ON" or "OFF").."]"
        ToggleBtn.Text = isEnabled and " STOP" or "TOGGLE"
    end
end)