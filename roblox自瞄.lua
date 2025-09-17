local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 配置参数
local FOV = 80
local Prediction = 0.15
local Smoothness = 0.8
local WallCheck = true
local Enabled = true
local LockedTarget = nil

-- 屏幕中心
local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- 画FOV圈
local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Radius = FOV
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 2
Circle.Position = ScreenCenter
Circle.Transparency = 1
Circle.NumSides = 64

-- 创建UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "AimBotUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true  -- 使UI可拖动
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AimBot Control"
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 0
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
ToggleBtn.Text = "Enabled: ON"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = Frame

local WallCheckBtn = Instance.new("TextButton")
WallCheckBtn.Size = UDim2.new(0.8, 0, 0, 30)
WallCheckBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
WallCheckBtn.Text = "WallCheck: ON"
WallCheckBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
WallCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WallCheckBtn.BorderSizePixel = 0
WallCheckBtn.Parent = Frame

-- 优化性能的变量
local lastTarget = nil
local lastTargetTime = 0
local targetCacheDuration = 0.1 -- 缓存目标0.1秒

-- 墙壁检测函数
function CheckWall(target)
    if not WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, target.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = workspace:Raycast(origin, direction * 1000, raycastParams)
    
    return raycastResult == nil or raycastResult.Instance:IsDescendantOf(target.Parent)
end

-- 获取目标头部
function GetTarget()
    -- 使用缓存的目标以减少计算量
    if lastTarget and tick() - lastTargetTime < targetCacheDuration then
        if lastTarget.Parent and lastTarget.Parent:FindFirstChild("Humanoid") and lastTarget.Parent.Humanoid.Health > 0 then
            return lastTarget
        end
    end
    
    local closest = nil
    local closestDist = FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if head and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and CheckWall(head) then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                    if dist < closestDist then
                        closest = head
                        closestDist = dist
                    end
                end
            end
        end
    end
    
    if closest then
        lastTarget = closest
        lastTargetTime = tick()
    end
    
    return closest
end

-- 强制瞄准头部
local function AimToHead(target)
    if not target then return end
    
    local targetPos = target.Position + (target.Velocity * Prediction)
    local cameraPos = Camera.CFrame.Position
    local newCFrame = CFrame.new(cameraPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Smoothness)
end

-- 使用BindToRenderStep而不是RenderStepped来优化性能
RunService:BindToRenderStep("AimBot", Enum.RenderPriority.Camera.Value, function()
    if not Enabled then return end
    
    local target = GetTarget()
    if target then
        AimToHead(target)
    end
end)

-- UI控制
ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Circle.Visible = Enabled
    ToggleBtn.Text = "Enabled: " .. (Enabled and "ON" or "OFF")
end)

WallCheckBtn.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    WallCheckBtn.Text = "WallCheck: " .. (WallCheck and "ON" or "OFF")
end)

-- 键盘开关
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        Enabled = not Enabled
        Circle.Visible = Enabled
        ToggleBtn.Text = "Enabled: " .. (Enabled and "ON" or "OFF")
    end
end)

-- 更新FOV圈位置
RunService.RenderStepped:Connect(function()
    Circle.Position = ScreenCenter
end)

-- 窗口大小改变时更新屏幕中心
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)