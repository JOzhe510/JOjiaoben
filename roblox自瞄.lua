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
local Enabled = true
local LockedTarget = nil
local LockSingleTarget = true

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
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "自瞄面板"
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 0
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleBtn.Text = "自瞄: 开启"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = Frame

local SingleTargetBtn = Instance.new("TextButton")
SingleTargetBtn.Size = UDim2.new(0.8, 0, 0, 30)
SingleTargetBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
SingleTargetBtn.Text = "单锁一人: 开启"
SingleTargetBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SingleTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SingleTargetBtn.BorderSizePixel = 0
SingleTargetBtn.Parent = Frame

-- 检查目标是否有效
function IsTargetValid(target)
    if not target or not target.Parent then return false end
    local humanoid = target.Parent:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- 获取目标
function GetTarget()
    -- 单目标锁定模式
    if LockSingleTarget and LockedTarget then
        if IsTargetValid(LockedTarget) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
            if onScreen then
                return LockedTarget
            end
        else
            LockedTarget = nil  -- 目标死亡则清除锁定
        end
    end
    
    -- 寻找新目标
    local closest = nil
    local closestDist = FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if head and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                    if dist < closestDist then
                        closest = head
                        closestDist = dist
                    end
                end
            end
        end
    end
    
    -- 单目标模式下锁定第一个找到的目标
    if LockSingleTarget and closest and not LockedTarget then
        LockedTarget = closest
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

-- 主循环
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
    ToggleBtn.Text = "自瞄: " .. (Enabled and "开启" or "未开启")
end)

SingleTargetBtn.MouseButton1Click:Connect(function()
    LockSingleTarget = not LockSingleTarget
    SingleTargetBtn.Text = "单锁一人: " .. (LockSingleTarget and "开启" or "未开启")
    LockedTarget = nil  -- 切换模式时清除锁定
end)

-- 键盘开关
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        Enabled = not Enabled
        Circle.Visible = Enabled
        ToggleBtn.Text = "自瞄: " .. (Enabled and "开启" or "未开启")
    elseif input.KeyCode == Enum.KeyCode.T then
        LockedTarget = nil  -- T键清除锁定
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