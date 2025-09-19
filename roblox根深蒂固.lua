local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- 配置参数
local TRACKING_ENABLED = true  -- 是否启用追踪
local WALL_PENETRATION = true  -- 是否启用穿墙
local MAX_PENETRATION_DEPTH = 3  -- 最大穿墙深度（可穿透的墙壁数量）
local FOV = 60  -- 追踪视野范围（角度）

-- 获取鼠标指向的玩家
function getTargetPlayer()
    if not TRACKING_ENABLED then return nil end
    
    local camera = workspace.CurrentCamera
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local bestTarget = nil
    local bestAngle = math.rad(FOV)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPos, visible = camera:WorldToViewportPoint(humanoidRootPart.Position)
                if visible then
                    local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                    local angle = (mousePos - screenPoint).Magnitude
                    
                    if angle < bestAngle then
                        bestAngle = angle
                        bestTarget = player
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- 射线投射检测穿墙
function rayCastWithPenetration(startPos, direction, maxDistance, penetrationDepth)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {localPlayer.Character}
    raycastParams.IgnoreWater = true
    
    local currentPos = startPos
    local currentDir = direction.Unit
    local penetratedWalls = 0
    
    while penetratedWalls <= penetrationDepth do
        local raycastResult = workspace:Raycast(currentPos, currentDir * maxDistance, raycastParams)
        
        if not raycastResult then
            -- 没有命中任何物体，返回最终位置
            return currentPos + currentDir * maxDistance
        end
        
        local hitPart = raycastResult.Instance
        local hitPos = raycastResult.Position
        local hitNormal = raycastResult.Normal
        
        -- 检查是否命中玩家
        if hitPart and hitPart.Parent then
            local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- 命中玩家，返回命中位置
                return hitPos, hitPart, humanoid
            end
        end
        
        -- 如果是墙壁且允许穿墙
        if WALL_PENETRATION and penetratedWalls < MAX_PENETRATION_DEPTH then
            -- 计算折射方向（简单穿透，继续原方向）
            currentPos = hitPos + currentDir * 0.1  -- 稍微穿过墙壁
            penetratedWalls = penetratedWalls + 1
        else
            -- 不允许穿墙或达到最大穿透深度，返回命中位置
            return hitPos, hitPart
        end
    end
    
    return currentPos + currentDir * maxDistance
end

-- 武器开火时调用此函数
function onFire(weaponTool)
    local targetPlayer = getTargetPlayer()
    
    if targetPlayer and targetPlayer.Character then
        local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- 计算子弹方向
            local camera = workspace.CurrentCamera
            local startPos = camera.CFrame.Position
            local targetPos = humanoidRootPart.Position + Vector3.new(0, 1.5, 0)  -- 瞄准胸部高度
            local direction = (targetPos - startPos).Unit
            
            -- 执行射线投射（带穿墙）
            local hitPos, hitPart, humanoid = rayCastWithPenetration(
                startPos, 
                direction, 
                1000,  -- 最大距离
                MAX_PENETRATION_DEPTH
            )
            
            -- 如果命中玩家，造成伤害
            if humanoid and hitPart then
                -- 这里需要根据游戏机制实现伤害逻辑
                -- 注意：直接修改其他玩家的生命值可能违反游戏规则
                print("命中目标:", targetPlayer.Name)
            end
        end
    end
end

-- 绑定到武器开火事件
local function setupWeaponTracking()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.Died:Connect(function()
        -- 角色死亡时清除绑定
        for _, connection in ipairs(getconnections(mouse.Button1Down)) do
            connection:Disconnect()
        end
    end)
    
    -- 监听鼠标点击事件（开火）
    mouse.Button1Down:Connect(function()
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            onFire(tool)
        end
    end)
end

-- 初始设置
localPlayer.CharacterAdded:Connect(setupWeaponTracking)
if localPlayer.Character then
    setupWeaponTracking()
end

-- 可选：添加视觉指示器显示追踪目标
if TRACKING_ENABLED then
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineTransparency = 0
    
    RunService.RenderStepped:Connect(function()
        local target = getTargetPlayer()
        if target and target.Character then
            highlight.Adornee = target.Character
            highlight.Parent = target.Character
        else
            highlight.Adornee = nil
            highlight.Parent = nil
        end
    end)
end

print("穿墙子弹追踪脚本已加载")