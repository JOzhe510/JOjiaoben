local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local platformPart = nil
local platformLoop = nil
local isPlatformActive = false
local platformHeightOffset = 3.4 -- 平台在玩家下方的固定高度差

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VoidTeleportUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 250)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -70, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "平台功能"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 50, 0, 25)
closeButton.Position = UDim2.new(1, -60, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "关闭UI"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 12
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local platformToggleButton = Instance.new("TextButton")
platformToggleButton.Name = "PlatformToggleButton"
platformToggleButton.Size = UDim2.new(0, 280, 0, 60)
platformToggleButton.Position = UDim2.new(0.5, -140, 0.1, 0)
platformToggleButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
platformToggleButton.BorderSizePixel = 0
platformToggleButton.Text = "开启平台"
platformToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
platformToggleButton.Font = Enum.Font.GothamBold
platformToggleButton.TextSize = 18
platformToggleButton.Parent = mainFrame

local platformCorner = Instance.new("UICorner")
platformCorner.CornerRadius = UDim.new(0, 10)
platformCorner.Parent = platformToggleButton

local deleteButton = Instance.new("TextButton")
deleteButton.Name = "DeleteButton"
deleteButton.Size = UDim2.new(0, 120, 0, 35)
deleteButton.Position = UDim2.new(0.5, -60, 0.75, 0)
deleteButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
deleteButton.BorderSizePixel = 0
deleteButton.Text = "删除UI"
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Font = Enum.Font.Gotham
deleteButton.TextSize = 13
deleteButton.Parent = mainFrame

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 6)
deleteCorner.Parent = deleteButton

local openUIButton = Instance.new("TextButton")
openUIButton.Name = "OpenUIButton"
openUIButton.Size = UDim2.new(0, 80, 0, 35)
openUIButton.Position = UDim2.new(0, 10, 0, 10)
openUIButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
openUIButton.BorderSizePixel = 0
openUIButton.Text = "平台功能"
openUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openUIButton.Font = Enum.Font.Gotham
openUIButton.TextSize = 12
openUIButton.Visible = false
openUIButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openUIButton

local function StartPlatform()
    if platformLoop then 
        platformLoop:Disconnect()
        platformLoop = nil
    end
    
    platformLoop = RunService.Heartbeat:Connect(function()
        local character = game.Players.LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- 持续在玩家脚底生成平台
        if platformPart then
            platformPart:Destroy()
        end
        
        platformPart = Instance.new("Part")
        platformPart.Name = "FlightPlatform"
        platformPart.Size = Vector3.new(8, 0.2, 8) 
        platformPart.Anchored = true
        platformPart.CanCollide = true
        platformPart.Material = Enum.Material.Neon
        platformPart.BrickColor = BrickColor.new("Bright violet")
        platformPart.Transparency = 0.2
        
        -- 在玩家脚底位置创建平台
        local position = humanoidRootPart.Position - Vector3.new(0, platformHeightOffset, 0)
        platformPart.CFrame = CFrame.new(position)
        platformPart.Parent = workspace
    end)
end

local function StopPlatform()
    if platformLoop then
        platformLoop:Disconnect()
        platformLoop = nil
    end
    
    if platformPart then
        platformPart:Destroy()
        platformPart = nil
    end
end

local function setupButtonHover(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = originalColor * 1.2
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
end

setupButtonHover(closeButton)
setupButtonHover(platformToggleButton)
setupButtonHover(deleteButton)
setupButtonHover(openUIButton)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openUIButton.Visible = true
end)

openUIButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openUIButton.Visible = false
end)

deleteButton.MouseButton1Click:Connect(function()
    StopPlatform()
    screenGui:Destroy()
end)

platformToggleButton.MouseButton1Click:Connect(function()
    if isPlatformActive then
        StopPlatform()
        platformToggleButton.Text = "开启平台"
        platformToggleButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
        isPlatformActive = false
    else
        StartPlatform()
        platformToggleButton.Text = "关闭平台"
        platformToggleButton.BackgroundColor3 = Color3.fromRGB(200, 120, 80)
        isPlatformActive = true
    end
end)

screenGui.Parent = playerGui