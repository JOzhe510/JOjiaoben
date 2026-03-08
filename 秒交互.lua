--[[
    秒交互脚本 - 瞬间完成所有交互动作
    功能：拾取、开门、复活、使用工具等全部瞬间完成
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ========== 创建UI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FastInteractGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 开关按钮
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Position = UDim2.new(0.5, -50, 0.8, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
toggleButton.Text = "秒交互 ON"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Draggable = true
toggleButton.Parent = screenGui

-- 圆角
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = toggleButton

-- ========== 秒交互核心 ==========
local fastInteractEnabled = true

-- 1. 秒拾取/秒开门（修改交互提示）
local function onPromptTriggered(prompt)
    if not fastInteractEnabled then return end
    
    -- 如果是ProximityPrompt（靠近交互）
    if prompt:IsA("ProximityPrompt") then
        -- 设置超时时间为0（瞬间触发）
        prompt.HoldDuration = 0
        
        -- 设置其他属性加速
        prompt.MaxActivationDistance = 50  -- 增加距离
        prompt.RequiresLineOfSight = false  -- 不需要视线
        
        -- 如果有对象，直接触发
        if prompt.ObjectText then
            prompt:InputHoldBegin()  -- 模拟按住
            task.wait(0.01)
            prompt:InputHoldEnd()    -- 瞬间释放
        end
    end
end

-- 2. 监听所有新添加的Prompt
local function onDescendantAdded(descendant)
    if not fastInteractEnabled then return end
    
    task.wait(0.1)  -- 等待加载
    
    if descendant:IsA("ProximityPrompt") then
        descendant.HoldDuration = 0
        descendant.MaxActivationDistance = 50
        descendant.RequiresLineOfSight = false
    end
end

-- 3. 自动交互（靠近自动触发）
local function autoInteract()
    if not fastInteractEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- 查找附近的Prompt
    local workspace = game:GetService("Workspace")
    local prompts = workspace:GetDescendants()
    
    for _, obj in ipairs(prompts) do
        if obj:IsA("ProximityPrompt") then
            -- 检查距离
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                local distance = (rootPart.Position - part.Position).Magnitude
                if distance < 30 then  -- 30格内自动触发
                    obj:InputHoldBegin()
                    task.wait(0.01)
                    obj:InputHoldEnd()
                end
            end
        end
    end
end

-- ========== 连接到事件 ==========
-- 监听新Prompt
game:GetService("Workspace").DescendantAdded:Connect(onDescendantAdded)

-- 监听玩家角色
player.CharacterAdded:Connect(function(character)
    task.wait(1)
    -- 定期自动交互
    while fastInteractEnabled and character.Parent do
        autoInteract()
        task.wait(0.5)  -- 每0.5秒检测一次
    end
end)

-- ========== 开关控制 ==========
toggleButton.MouseButton1Click:Connect(function()
    fastInteractEnabled = not fastInteractEnabled
    
    if fastInteractEnabled then
        toggleButton.Text = "秒交互 ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        toggleButton.Text = "秒交互 OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

-- ========== 快捷键F开启/关闭 ==========
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        toggleButton.MouseButton1Click:Fire()
    end
end)

-- ========== 额外功能：秒复活 ==========
local function fastRespawn()
    if not fastInteractEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health <= 0 then
        -- 如果死了，立即复活
        humanoid.Health = 0  -- 确保死亡
        task.wait(0.1)
        player:LoadCharacter()  -- 重生
    end
end

-- 检测死亡
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").Died:Connect(function()
        if fastInteractEnabled then
            task.wait(0.1)
            fastRespawn()
        end
    end)
end)

-- ========== 初始化：修改所有现有Prompt ==========
task.wait(1)
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
        obj.MaxActivationDistance = 50
        obj.RequiresLineOfSight = false
    end
end