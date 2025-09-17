local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 200)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔥 自瞄面板 🔥"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.BackgroundTransparency = 0.3
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 0
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleBtn.Text = "🎯 自瞄: 开启"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Font = Enum.Font.Gotham
ToggleBtn.Parent = Frame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

-- FOV控制
local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.new(0.8, 0, 0, 40)
FOVFrame.Position = UDim2.new(0.1, 0, 0.45, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.BorderSizePixel = 0
FOVFrame.Parent = Frame

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, 0, 0, 20)
FOVLabel.Text = "🔍 FOV大小: " .. FOV
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.Parent = FOVFrame

local FOVSlider = Instance.new("Frame")
FOVSlider.Size = UDim2.new(1, 0, 0, 6)
FOVSlider.Position = UDim2.new(0, 0, 0.5, 0)
FOVSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FOVSlider.BorderSizePixel = 0
FOVSlider.Parent = FOVFrame

local FOVSliderCorner = Instance.new("UICorner")
FOVSliderCorner.CornerRadius = UDim.new(0, 3)
FOVSliderCorner.Parent = FOVSlider

local FOVFill = Instance.new("Frame")
FOVFill.Size = UDim2.new((FOV - 20) / 180, 0, 1, 0)
FOVFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
FOVFill.BorderSizePixel = 0
FOVFill.Parent = FOVSlider

local FOVFillCorner = Instance.new("UICorner")
FOVFillCorner.CornerRadius = UDim.new(0, 3)
FOVFillCorner.Parent = FOVFill

local FOVHandle = Instance.new("TextButton")
FOVHandle.Size = UDim2.new(0, 16, 0, 16)
FOVHandle.Position = UDim2.new((FOV - 20) / 180, -8, 0.5, -8)
FOVHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVHandle.Text = ""
FOVHandle.BorderSizePixel = 0
FOVHandle.Parent = FOVSlider

local FOVHandleCorner = Instance.new("UICorner")
FOVHandleCorner.CornerRadius = UDim.new(1, 0)
FOVHandleCorner.Parent = FOVHandle

local SingleTargetBtn = Instance.new("TextButton")
SingleTargetBtn.Size = UDim2.new(0.8, 0, 0, 30)
SingleTargetBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
SingleTargetBtn.Text = "🔒 单锁一人: 开启"
SingleTargetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SingleTargetBtn.BackgroundTransparency = 0.2
SingleTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SingleTargetBtn.BorderSizePixel = 0
SingleTargetBtn.Font = Enum.Font.Gotham
SingleTargetBtn.Parent = Frame

local SingleCorner = Instance.new("UICorner")
SingleCorner.CornerRadius = UDim.new(0, 6)
SingleCorner.Parent = SingleTargetBtn

-- 颜色变换效果
local colorTweens = {}
local colors = {
    Color3.fromRGB(255, 50, 50),
    Color3.fromRGB(50, 255, 50),
    Color3.fromRGB(50, 50, 255),
    Color3.fromRGB(255, 255, 50),
    Color3.fromRGB(255, 50, 255),
    Color3.fromRGB(50, 255, 255)
}

local function startColorAnimation(instance, property)
    if colorTweens[instance] then
        colorTweens[instance]:Cancel()
    end
    
    local currentColorIndex = 1
    local function animate()
        local targetColor = colors[currentColorIndex]
        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(instance, tweenInfo, {[property] = targetColor})
        tween:Play()
        
        colorTweens[instance] = tween
        currentColorIndex = currentColorIndex % #colors + 1
        
        tween.Completed:Connect(function()
            if instance.Parent then
                animate()
            end
        end)
    end
    animate()
end

-- 启动颜色动画
startColorAnimation(Title, "TextColor3")
startColorAnimation(ToggleBtn, "BackgroundColor3")
startColorAnimation(SingleTargetBtn, "BackgroundColor3")
startColorAnimation(Circle, "Color")
startColorAnimation(FOVFill, "BackgroundColor3")

-- FOV滑块拖动功能
local dragging = false

FOVHandle.MouseButton1Down:Connect(function()
    dragging = true
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UIS:GetMouseLocation()
        local sliderAbsolutePos = FOVSlider.AbsolutePosition
        local sliderAbsoluteSize = FOVSlider.AbsoluteSize
        
        local relativeX = math.clamp((mousePos.X - sliderAbsolutePos.X) / sliderAbsoluteSize.X, 0, 1)
        local newFOV = math.floor(20 + relativeX * 180)
        
        FOV = newFOV
        Circle.Radius = FOV
        FOVLabel.Text = "🔍 FOV大小: " .. FOV
        FOVFill.Size = UDim2.new(relativeX, 0, 1, 0)
        FOVHandle.Position = UDim2.new(relativeX, -8, 0.5, -8)
    end
end)

-- 安全检查函数
function SafeWorldToViewportPoint(position)
    local success, result = pcall(function()
        return Camera:WorldToViewportPoint(position)
    end)
    return success, result
end

-- 检查目标是否有效
function IsTargetValid(target)
    if not target or not target.Parent then return false end
    if not target:IsA("BasePart") then return false end
    
    local humanoid = target.Parent:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

-- 获取目标
function GetTarget()
    -- 单目标锁定模式：只检测锁定目标
    if LockSingleTarget and LockedTarget then
        if IsTargetValid(LockedTarget) then
            local success, screenPos = SafeWorldToViewportPoint(LockedTarget.Position)
            if success and screenPos then
                return LockedTarget
            end
        else
            LockedTarget = nil
        end
    end
    
    -- 非锁定模式：寻找最近有效目标
    local closest = nil
    local closestDist = FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head and IsTargetValid(head) then
                local success, screenPos = SafeWorldToViewportPoint(head.Position)
                if success and screenPos and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                    if dist < closestDist then
                        closest = head
                        closestDist = dist
                    end
                end
            end
        end
    end
    
    return closest
end

-- 安全瞄准函数
local function SafeAimToHead(target)
    if not target or not target:IsA("BasePart") then return false end
    
    local success, targetPos = pcall(function()
        return target.Position + (target.Velocity * Prediction)
    end)
    if not success then return false end
    
    local success, cameraPos = pcall(function()
        return Camera.CFrame.Position
    end)
    if not success then return false end
    
    local newCFrame = CFrame.new(cameraPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Smoothness)
    return true
end

-- 主循环
RunService:BindToRenderStep("AimBot", Enum.RenderPriority.Camera.Value, function()
    if not Enabled then return end
    if not LocalPlayer or not LocalPlayer.Character then return end
    
    local target = GetTarget()
    if target then
        SafeAimToHead(target)
    end
end)

-- UI控制
ToggleBtn.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Circle.Visible = Enabled
    ToggleBtn.Text = "🎯 自瞄: " .. (Enabled and "开启" or "关闭")
end)

SingleTargetBtn.MouseButton1Click:Connect(function()
    LockSingleTarget = not LockSingleTarget
    SingleTargetBtn.Text = "🔒 单锁一人: " .. (LockSingleTarget and "开启" or "关闭")
    LockedTarget = nil
end)

-- 键盘控制
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not LocalPlayer or not LocalPlayer.Character then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        Enabled = not Enabled
        Circle.Visible = Enabled
        ToggleBtn.Text = "🎯 自瞄: " .. (Enabled and "开启" or "关闭")
    elseif input.KeyCode == Enum.KeyCode.T then
        LockedTarget = nil
    elseif input.KeyCode == Enum.KeyCode.F then
        local target = GetTarget()
        if target then
            LockedTarget = target
        end
    end
end)

-- 玩家离开游戏时清理
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for _, tween in pairs(colorTweens) do
            pcall(function() tween:Cancel() end)
        end
        pcall(function() Circle:Remove() end)
        pcall(function() ScreenGui:Destroy() end)
    end
end)

-- 更新FOV圈位置
RunService.RenderStepped:Connect(function()
    if Circle then
        Circle.Position = ScreenCenter
    end
end)

-- 窗口大小改变时更新
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if Camera and Camera.ViewportSize then
        ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        if Circle then
            Circle.Position = ScreenCenter
        end
    end
end)

-- 游戏关闭时清理
game:BindToClose(function()
    pcall(function() Circle:Remove() end)
    pcall(function() ScreenGui:Destroy() end)
end)