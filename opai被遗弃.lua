--[[
    OPAIHUB - 高级反作弊绕过套件
    作者: OPAI团队
    版本: 1.0.0
    描述: 被遗弃游戏的综合反作弊绕过系统
    版权所有 - OPAI团队
]]

local OPAIHUB_REPO = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'

local OPAIHUB_Library = loadstring(game:HttpGet(OPAIHUB_REPO .. 'Library.lua'))()
local OPAIHUB_ThemeManager = loadstring(game:HttpGet(OPAIHUB_REPO .. 'addons/ThemeManager.lua'))()
local OPAIHUB_SaveManager = loadstring(game:HttpGet(OPAIHUB_REPO .. 'addons/SaveManager.lua'))()

local OPAIHUB_RunService = game:GetService("RunService")
local OPAIHUB_UserInputService = game:GetService("UserInputService")
local OPAIHUB_Players = game:GetService("Players")
local OPAIHUB_Workspace = game:GetService("Workspace")
local OPAIHUB_ReplicatedStorage = game:GetService("ReplicatedStorage")
local OPAIHUB_Lighting = game:GetService("Lighting")

if not table.clone then
    table.clone = function(t)
        local nt = {}
        for k,v in pairs(t) do nt[k] = v end
        return nt
    end
end

OPAIHUB_Library.ShowToggleFrameInKeybinds = true 
OPAIHUB_Library.ShowCustomCursor = true
OPAIHUB_Library.NotifySide = "Right"

local OPAIHUB_Window = OPAIHUB_Library:CreateWindow({
    Title = 'OPAIHUB | 反作弊绕过系统',
    Footer = "OPAI团队",
    Icon = 106397684977541,
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    NotifySide = "Right",
    TabPadding = 8,
    MenuFadeTime = 0
})

local OPAIHUB_Tabs = {
    Main = OPAIHUB_Window:AddTab('主要功能','house'),
    Movement = OPAIHUB_Window:AddTab('移动功能','earth'),
    Combat = OPAIHUB_Window:AddTab('战斗功能','moon'),
    Aimbot = OPAIHUB_Window:AddTab('自瞄功能','earth'),
    ESP = OPAIHUB_Window:AddTab('透视绘制','eye'),
    Visual = OPAIHUB_Window:AddTab('视觉设置','eye'),
    Auto = OPAIHUB_Window:AddTab('自动功能','file'),
    AntiLoophole = OPAIHUB_Window:AddTab('反作弊效果','earth')
}

local OPAIHUB_Env = getgenv and getgenv() or {}
local OPAIHUB_LocalPlayer = OPAIHUB_Players.LocalPlayer

-- ============================================
-- OPAIHUB 反作弊绕过核心功能
-- ============================================

-- 1. OPAIHUB_NoStun (去除前后摇)
local OPAIHUB_NoStunEnabled = false

local function OPAIHUB_SetupNoStun()
    local function OPAIHUB_ApplyNoStun(character)
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if OPAIHUB_NoStunEnabled and humanoid.WalkSpeed < 16 then
                humanoid.WalkSpeed = 16
            end
        end)
    end
    
    if OPAIHUB_LocalPlayer.Character then
        OPAIHUB_ApplyNoStun(OPAIHUB_LocalPlayer.Character)
    end
    
    OPAIHUB_LocalPlayer.CharacterAdded:Connect(OPAIHUB_ApplyNoStun)
end

-- 2. OPAIHUB_SpeedBoost (速度增强 - CFrame方式)
local OPAIHUB_SpeedBoostEnabled = false
local OPAIHUB_SpeedBoostValue = 1
local OPAIHUB_SpeedBoostConnection = nil

local function OPAIHUB_StartSpeedBoost()
    if OPAIHUB_SpeedBoostConnection then return end
    
    OPAIHUB_SpeedBoostConnection = OPAIHUB_RunService.Heartbeat:Connect(function()
        if not OPAIHUB_LocalPlayer.Character then return end
        local hrp = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = OPAIHUB_LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and OPAIHUB_SpeedBoostEnabled then
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + moveDirection * OPAIHUB_SpeedBoostValue
                hrp.CanCollide = true
            end
        end
    end)
end

local function OPAIHUB_StopSpeedBoost()
    if OPAIHUB_SpeedBoostConnection then
        OPAIHUB_SpeedBoostConnection:Disconnect()
        OPAIHUB_SpeedBoostConnection = nil
    end
end

-- 3. OPAIHUB_VoidRushOverride (Noli冲刺优化)
local OPAIHUB_VoidRushOverrideEnabled = false
local OPAIHUB_VoidRushConnection = nil
local OPAIHUB_VoidRushMonitorTask = nil

local function OPAIHUB_StartVoidRushOverride()
    if OPAIHUB_VoidRushConnection then return end
    
    local OPAIHUB_ORIGINAL_DASH_SPEED = 60
    local OPAIHUB_DEFAULT_WALK_SPEED = 16
    
    local function OPAIHUB_SetupCharacter()
        local character = OPAIHUB_LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:WaitForChild("Humanoid", 5)
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        
        if humanoid and hrp then
            OPAIHUB_VoidRushConnection = OPAIHUB_RunService.RenderStepped:Connect(function()
                if not character or not character.Parent then return end
                
                local voidRushState = character:GetAttribute("VoidRushState")
                
                if voidRushState == "Dashing" and OPAIHUB_VoidRushOverrideEnabled then
                    humanoid.WalkSpeed = OPAIHUB_ORIGINAL_DASH_SPEED
                    humanoid.AutoRotate = false
                    
                    local direction = hrp.CFrame.LookVector
                    local horizontalDirection = Vector3.new(direction.X, 0, direction.Z).Unit
                    humanoid:Move(horizontalDirection)
                else
                    humanoid.WalkSpeed = OPAIHUB_DEFAULT_WALK_SPEED
                    humanoid.AutoRotate = true
                end
            end)
        end
    end
    
    OPAIHUB_SetupCharacter()
    OPAIHUB_LocalPlayer.CharacterAdded:Connect(OPAIHUB_SetupCharacter)
end

local function OPAIHUB_StopVoidRushOverride()
    if OPAIHUB_VoidRushConnection then
        OPAIHUB_VoidRushConnection:Disconnect()
        OPAIHUB_VoidRushConnection = nil
    end
    
    if OPAIHUB_VoidRushMonitorTask then
        task.cancel(OPAIHUB_VoidRushMonitorTask)
        OPAIHUB_VoidRushMonitorTask = nil
    end
    
    if OPAIHUB_LocalPlayer.Character then
        local humanoid = OPAIHUB_LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.AutoRotate = true
        end
    end
end

-- 4. OPAIHUB_InfiniteStamina (无限体力)
local OPAIHUB_InfiniteStaminaEnabled = false
local OPAIHUB_StaminaMonitorConnection = nil
local OPAIHUB_SprintModule = nil

local function OPAIHUB_ModifyStaminaSettings()
    pcall(function()
        if not OPAIHUB_SprintModule then
            local success, module = pcall(require, OPAIHUB_ReplicatedStorage.Systems.Character.Game.Sprinting)
            if success and module then
                OPAIHUB_SprintModule = module
            end
        end
        
        if OPAIHUB_SprintModule and OPAIHUB_SprintModule.StaminaLossDisabled ~= nil then
            OPAIHUB_SprintModule.StaminaLossDisabled = OPAIHUB_InfiniteStaminaEnabled
        end
    end)
end

local function OPAIHUB_StartInfiniteStamina()
    OPAIHUB_ModifyStaminaSettings()
    
    if OPAIHUB_StaminaMonitorConnection then
        OPAIHUB_StaminaMonitorConnection:Disconnect()
    end
    
    OPAIHUB_StaminaMonitorConnection = OPAIHUB_RunService.Heartbeat:Connect(function()
        if OPAIHUB_InfiniteStaminaEnabled then
            OPAIHUB_ModifyStaminaSettings()
        end
    end)
end

local function OPAIHUB_StopInfiniteStamina()
    if OPAIHUB_StaminaMonitorConnection then
        OPAIHUB_StaminaMonitorConnection:Disconnect()
        OPAIHUB_StaminaMonitorConnection = nil
    end
    
    if OPAIHUB_SprintModule and OPAIHUB_SprintModule.StaminaLossDisabled ~= nil then
        OPAIHUB_SprintModule.StaminaLossDisabled = false
    end
end

-- 5. OPAIHUB_AimbotAntiDetection (瞄准反检测)
local OPAIHUB_AimbotAntiDetectionEnabled = false
local OPAIHUB_OriginalAimbotState = nil

local function OPAIHUB_ApplyAimbotAntiDetection(hrp)
    if not hrp then return end
    
    if OPAIHUB_AimbotAntiDetectionEnabled then
        if not OPAIHUB_OriginalAimbotState then
            OPAIHUB_OriginalAimbotState = {
                AssemblyAngularVelocity = hrp.AssemblyAngularVelocity
            }
        end
        hrp.AssemblyAngularVelocity = Vector3.zero
    else
        if OPAIHUB_OriginalAimbotState then
            hrp.AssemblyAngularVelocity = OPAIHUB_OriginalAimbotState.AssemblyAngularVelocity
            OPAIHUB_OriginalAimbotState = nil
        end
    end
end

local OPAIHUB_AimbotAntiDetectionConnection = OPAIHUB_RunService.Heartbeat:Connect(function()
    if OPAIHUB_LocalPlayer.Character then
        local hrp = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            OPAIHUB_ApplyAimbotAntiDetection(hrp)
        end
    end
end)

-- 6. OPAIHUB_SafeTeleport (传送反检测)
local function OPAIHUB_SafeTeleport(cframe)
    pcall(function()
        if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            OPAIHUB_LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
        end
    end)
end

-- 7. OPAIHUB_AdvancedMovement (高级移动绕过)
local OPAIHUB_AdvancedMovementEnabled = false
local OPAIHUB_AdvancedMovementConnection = nil

local function OPAIHUB_StartAdvancedMovement()
    if OPAIHUB_AdvancedMovementConnection then return end
    
    OPAIHUB_AdvancedMovementConnection = OPAIHUB_RunService.Heartbeat:Connect(function()
        if not OPAIHUB_LocalPlayer.Character then return end
        local hrp = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = OPAIHUB_LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and OPAIHUB_AdvancedMovementEnabled then
            humanoid.AutoRotate = false
            
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                local newCFrame = hrp.CFrame + moveDirection * OPAIHUB_SpeedBoostValue * 0.1
                hrp.CFrame = newCFrame
            end
            
            hrp.CanCollide = true
        elseif humanoid then
            humanoid.AutoRotate = true
        end
    end)
end

local function OPAIHUB_StopAdvancedMovement()
    if OPAIHUB_AdvancedMovementConnection then
        OPAIHUB_AdvancedMovementConnection:Disconnect()
        OPAIHUB_AdvancedMovementConnection = nil
    end
    
    if OPAIHUB_LocalPlayer.Character then
        local humanoid = OPAIHUB_LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
end

-- 8. OPAIHUB_PopupBypass (弹窗绕过 - 针对1x1x1x1)
local OPAIHUB_PopupBypassEnabled = false
local OPAIHUB_PopupBypassConnection = nil
local OPAIHUB_PopupBypassTask = nil

local function OPAIHUB_StartPopupBypass()
    if OPAIHUB_PopupBypassTask then return end
    
    local OPAIHUB_RemoteEvent = OPAIHUB_ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
    
    local function OPAIHUB_DeletePopups()
        if not OPAIHUB_LocalPlayer or not OPAIHUB_LocalPlayer:FindFirstChild("PlayerGui") then
            return false
        end
        
        local tempUI = OPAIHUB_LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
        if not tempUI then
            return false
        end
        
        local deleted = false
        for _, popup in ipairs(tempUI:GetChildren()) do
            if popup.Name == "1x1x1x1Popup" then
                popup:Destroy()
                deleted = true
            end
        end
        return deleted
    end
    
    local function OPAIHUB_TriggerEntangled()
        pcall(function()
            OPAIHUB_RemoteEvent:FireServer("Entangled")
        end)
    end
    
    if OPAIHUB_LocalPlayer:FindFirstChild("PlayerGui") then
        local tempUI = OPAIHUB_LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
        if not tempUI then
            tempUI = Instance.new("Folder")
            tempUI.Name = "TemporaryUI"
            tempUI.Parent = OPAIHUB_LocalPlayer.PlayerGui
        end
        
        OPAIHUB_PopupBypassConnection = tempUI.ChildAdded:Connect(function(child)
            if OPAIHUB_PopupBypassEnabled and child.Name == "1x1x1x1Popup" then
                task.defer(function()
                    child:Destroy()
                end)
            end
        end)
    end
    
    OPAIHUB_PopupBypassTask = task.spawn(function()
        while OPAIHUB_PopupBypassEnabled do
            OPAIHUB_DeletePopups()
            OPAIHUB_TriggerEntangled()
            task.wait(0.5)
        end
    end)
end

local function OPAIHUB_StopPopupBypass()
    if OPAIHUB_PopupBypassTask then
        task.cancel(OPAIHUB_PopupBypassTask)
        OPAIHUB_PopupBypassTask = nil
    end
    
    if OPAIHUB_PopupBypassConnection then
        OPAIHUB_PopupBypassConnection:Disconnect()
        OPAIHUB_PopupBypassConnection = nil
    end
end

-- 9. OPAIHUB_NoliVoidRushBypass (Noli VoidRush无视碰撞)
local OPAIHUB_NoliVoidRushBypassEnabled = false
local OPAIHUB_NoliVoidRushConnection = nil

local function OPAIHUB_StartNoliVoidRushBypass()
    if OPAIHUB_NoliVoidRushConnection then return end
    
    OPAIHUB_NoliVoidRushConnection = OPAIHUB_RunService.RenderStepped:Connect(function()
        if not OPAIHUB_LocalPlayer.Character then return end
        
        local character = OPAIHUB_LocalPlayer.Character
        local voidRushState = character:GetAttribute("VoidRushState")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        
        if voidRushState == "Dashing" and OPAIHUB_NoliVoidRushBypassEnabled and humanoid and hrp then
            humanoid.WalkSpeed = 60
            humanoid.AutoRotate = false
            
            local direction = hrp.CFrame.LookVector
            local horizontalDirection = Vector3.new(direction.X, 0, direction.Z).Unit
            humanoid:Move(horizontalDirection)
            
            -- 无视碰撞
            for _, part in pairs(character:GetDescendants()) do
                if typeof(part) == "Instance" and part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        elseif humanoid then
            humanoid.WalkSpeed = 16
            humanoid.AutoRotate = true
            
            for _, part in pairs(character:GetDescendants()) do
                if typeof(part) == "Instance" and part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end)
end

local function OPAIHUB_StopNoliVoidRushBypass()
    if OPAIHUB_NoliVoidRushConnection then
        OPAIHUB_NoliVoidRushConnection:Disconnect()
        OPAIHUB_NoliVoidRushConnection = nil
    end
    
    if OPAIHUB_LocalPlayer.Character then
        local humanoid = OPAIHUB_LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.AutoRotate = true
        end
    end
end

-- ============================================
-- OPAIHUB UI 界面
-- ============================================

-- Main Tab
local OPAIHUB_MainGroup = OPAIHUB_Tabs.Main:AddLeftGroupbox("OPAIHUB 反作弊绕过核心")

OPAIHUB_MainGroup:AddLabel("OPAI团队 - 高级绕过系统")
OPAIHUB_MainGroup:AddDivider()

OPAIHUB_MainGroup:AddToggle("OPAIHUB_NoStun", {
    Text = "去除前后摇",
    Default = false,
    Tooltip = "防止被击晕，自动恢复移动速度",
    Callback = function(v)
        OPAIHUB_NoStunEnabled = v
        if v then
            OPAIHUB_SetupNoStun()
            OPAIHUB_Library:Notify("去除前后摇已启用", "防眩晕保护已激活", 3)
        else
            OPAIHUB_Library:Notify("去除前后摇已关闭", "防眩晕保护已停用", 3)
        end
    end
})

OPAIHUB_MainGroup:AddDivider()

OPAIHUB_MainGroup:AddToggle("OPAIHUB_AimbotAntiDetection", {
    Text = "瞄准反检测",
    Default = false,
    Tooltip = "禁用角速度检测，防止瞄准被检测",
    Callback = function(v)
        OPAIHUB_AimbotAntiDetectionEnabled = v
        if v then
            OPAIHUB_Library:Notify("反检测已启用", "自瞄检测绕过已激活", 3)
        else
            OPAIHUB_Library:Notify("反检测已关闭", "检测绕过已停用", 3)
        end
    end
})

OPAIHUB_MainGroup:AddDivider()

OPAIHUB_MainGroup:AddToggle("OPAIHUB_InfiniteStamina", {
    Text = "无限体力",
    Default = false,
    Tooltip = "禁用体力消耗",
    Callback = function(v)
        OPAIHUB_InfiniteStaminaEnabled = v
        if v then
            OPAIHUB_StartInfiniteStamina()
            OPAIHUB_Library:Notify("无限体力已启用", "体力消耗已禁用", 3)
        else
            OPAIHUB_StopInfiniteStamina()
            OPAIHUB_Library:Notify("无限体力已关闭", "体力消耗已恢复", 3)
        end
    end
})

OPAIHUB_MainGroup:AddDivider()

OPAIHUB_MainGroup:AddButton("OPAIHUB_RestoreStamina", {
    Text = "恢复体力",
    Func = function()
        pcall(function()
            local SprintingModule = OPAIHUB_ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
            local sprintModule = require(SprintingModule)
            
            if sprintModule and sprintModule.SetStamina then
                sprintModule.SetStamina(sprintModule.MaxStamina or 100)
                OPAIHUB_Library:Notify("体力已恢复", "体力已设置为最大值", 3)
            end
        end)
    end
})

-- Movement Tab
local OPAIHUB_MovementGroup = OPAIHUB_Tabs.Movement:AddLeftGroupbox("OPAIHUB 移动绕过")

OPAIHUB_MovementGroup:AddSlider("OPAIHUB_SpeedBoostValue", {
    Text = "速度倍率",
    Min = 0,
    Max = 5,
    Default = 1,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        OPAIHUB_SpeedBoostValue = v
    end
})

OPAIHUB_MovementGroup:AddToggle("OPAIHUB_SpeedBoost", {
    Text = "速度增强",
    Default = false,
    Tooltip = "使用CFrame方式移动，绕过速度检测",
    Callback = function(v)
        OPAIHUB_SpeedBoostEnabled = v
        if v then
            OPAIHUB_StartSpeedBoost()
            OPAIHUB_Library:Notify("速度增强已启用", string.format("速度倍率: %.1f倍", OPAIHUB_SpeedBoostValue), 3)
        else
            OPAIHUB_StopSpeedBoost()
            OPAIHUB_Library:Notify("速度增强已关闭", "正常移动已恢复", 3)
        end
    end
})

OPAIHUB_MovementGroup:AddDivider()

OPAIHUB_MovementGroup:AddToggle("OPAIHUB_VoidRushOverride", {
    Text = "Noli冲刺优化",
    Default = false,
    Tooltip = "优化Noli角色的冲刺能力",
    Callback = function(v)
        OPAIHUB_VoidRushOverrideEnabled = v
        if v then
            OPAIHUB_StartVoidRushOverride()
            OPAIHUB_Library:Notify("Noli冲刺优化已启用", "Noli冲刺已优化", 3)
        else
            OPAIHUB_StopVoidRushOverride()
            OPAIHUB_Library:Notify("Noli冲刺优化已关闭", "冲刺优化已禁用", 3)
        end
    end
})

OPAIHUB_MovementGroup:AddDivider()

OPAIHUB_MovementGroup:AddToggle("OPAIHUB_NoliVoidRushBypass", {
    Text = "Noli冲刺无视碰撞",
    Default = false,
    Tooltip = "Noli冲刺时无视碰撞",
    Callback = function(v)
        OPAIHUB_NoliVoidRushBypassEnabled = v
        if v then
            OPAIHUB_StartNoliVoidRushBypass()
            OPAIHUB_Library:Notify("Noli冲刺无视碰撞已启用", "碰撞绕过已激活", 3)
        else
            OPAIHUB_StopNoliVoidRushBypass()
            OPAIHUB_Library:Notify("Noli冲刺无视碰撞已关闭", "碰撞绕过已禁用", 3)
        end
    end
})

-- Combat Tab
local OPAIHUB_CombatGroup = OPAIHUB_Tabs.Combat:AddLeftGroupbox("OPAIHUB 战斗绕过")

OPAIHUB_CombatGroup:AddLabel("OPAIHUB 战斗绕过功能")
OPAIHUB_CombatGroup:AddDivider()

OPAIHUB_CombatGroup:AddToggle("OPAIHUB_AdvancedMovement", {
    Text = "高级移动",
    Default = false,
    Tooltip = "使用高级移动绕过，禁用自动旋转",
    Callback = function(v)
        OPAIHUB_AdvancedMovementEnabled = v
        if v then
            OPAIHUB_StartAdvancedMovement()
            OPAIHUB_Library:Notify("高级移动已启用", "高级移动绕过已激活", 3)
        else
            OPAIHUB_StopAdvancedMovement()
            OPAIHUB_Library:Notify("高级移动已关闭", "正常移动已恢复", 3)
        end
    end
})

OPAIHUB_CombatGroup:AddDivider()

OPAIHUB_CombatGroup:AddToggle("OPAIHUB_PopupBypass", {
    Text = "弹窗绕过",
    Default = false,
    Tooltip = "自动删除1x1x1x1弹窗并触发Entangled",
    Callback = function(v)
        OPAIHUB_PopupBypassEnabled = v
        if v then
            OPAIHUB_StartPopupBypass()
            OPAIHUB_Library:Notify("弹窗绕过已启用", "自动弹窗删除已激活", 3)
        else
            OPAIHUB_StopPopupBypass()
            OPAIHUB_Library:Notify("弹窗绕过已关闭", "弹窗绕过已停用", 3)
        end
    end
})

OPAIHUB_CombatGroup:AddDivider()

OPAIHUB_CombatGroup:AddButton("OPAIHUB_SafeTeleportTest", {
    Text = "测试安全传送",
    Func = function()
        if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = OPAIHUB_LocalPlayer.Character.HumanoidRootPart
            OPAIHUB_SafeTeleport(hrp.CFrame + hrp.CFrame.LookVector * 10)
            OPAIHUB_Library:Notify("传送测试", "已向前传送10格", 3)
        end
    end
})

-- Visual Tab
local OPAIHUB_VisualGroup = OPAIHUB_Tabs.Visual:AddLeftGroupbox("OPAIHUB 视觉设置")

OPAIHUB_VisualGroup:AddSlider("OPAIHUB_Brightness", {
    Text = "亮度",
    Min = 0,
    Max = 3,
    Default = 0,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        OPAIHUB_Env.Brightness = v
    end
})

OPAIHUB_VisualGroup:AddToggle("OPAIHUB_Fullbright", {
    Text = "全亮",
    Default = false,
    Callback = function(v)
        OPAIHUB_Env.Fullbright = v
        if v then
            OPAIHUB_RunService.RenderStepped:Connect(function()
                if OPAIHUB_Env.Fullbright then
                    OPAIHUB_Lighting.OutdoorAmbient = Color3.new(1,1,1)
                    OPAIHUB_Lighting.Brightness = OPAIHUB_Env.Brightness or 0
                else
                    OPAIHUB_Lighting.OutdoorAmbient = Color3.fromRGB(55,55,55)
                    OPAIHUB_Lighting.Brightness = 0
                end
            end)
        end
    end
})

OPAIHUB_VisualGroup:AddToggle("OPAIHUB_NoFog", {
    Text = "除雾",
    Default = false,
    Callback = function(v)
        OPAIHUB_Env.NoFog = v
        if v then
            if not OPAIHUB_Lighting:GetAttribute("FogStart") then 
                OPAIHUB_Lighting:SetAttribute("FogStart", OPAIHUB_Lighting.FogStart) 
            end
            if not OPAIHUB_Lighting:GetAttribute("FogEnd") then 
                OPAIHUB_Lighting:SetAttribute("FogEnd", OPAIHUB_Lighting.FogEnd) 
            end
            OPAIHUB_Lighting.FogStart = 0
            OPAIHUB_Lighting.FogEnd = math.huge
            
            local fog = OPAIHUB_Lighting:FindFirstChildOfClass("Atmosphere")
            if fog then
                if not fog:GetAttribute("Density") then 
                    fog:SetAttribute("Density", fog.Density) 
                end
                fog.Density = 0
            end
        else
            OPAIHUB_Lighting.FogStart = OPAIHUB_Lighting:GetAttribute("FogStart") or 0
            OPAIHUB_Lighting.FogEnd = OPAIHUB_Lighting:GetAttribute("FogEnd") or 500
            local fog = OPAIHUB_Lighting:FindFirstChildOfClass("Atmosphere")
            if fog then
                fog.Density = fog:GetAttribute("Density") or 0.5
            end
        end
    end
})

OPAIHUB_VisualGroup:AddToggle("OPAIHUB_NoShadows", {
    Text = "无阴影",
    Default = false,
    Callback = function(v)
        OPAIHUB_Env.GlobalShadows = v
        if v then
            OPAIHUB_Lighting.GlobalShadows = false
        else
            OPAIHUB_Lighting.GlobalShadows = true
        end
    end
})

-- ESP Tab - Generator ESP Functions
local OPAIHUB_ESPGroup = OPAIHUB_Tabs.ESP:AddLeftGroupbox("OPAIHUB 发电机透视")

-- OPAIHUB Fake Generator ESP
OPAIHUB_ESPGroup:AddToggle("OPAIHUB_FakeGeneratorESP", {
    Text = "绘制假电机",
    Default = false,
    Callback = function(enabled)
        if not _G.OPAIHUB_FakeGeneratorESP then
            _G.OPAIHUB_FakeGeneratorESP = {
                Active = false,
                Data = {},
                Connections = {}
            }
        end
        
        if not enabled then
            if _G.OPAIHUB_FakeGeneratorESP.Active then
                for _, connection in _G.OPAIHUB_FakeGeneratorESP.Connections do
                    if connection and connection.Connected then
                        connection:Disconnect()
                    end
                end
                
                for gen, data in _G.OPAIHUB_FakeGeneratorESP.Data do
                    if type(data) == "table" then
                        if data.Highlight and data.Highlight.Parent then
                            data.Highlight:Destroy()
                        end
                        if data.NameLabel and data.NameLabel.Parent then
                            data.NameLabel:Destroy()
                        end
                        if data.NameBillboard and data.NameBillboard.Parent then
                            data.NameBillboard:Destroy()
                        end
                    end
                end
                
                _G.OPAIHUB_FakeGeneratorESP.Data = {}
                _G.OPAIHUB_FakeGeneratorESP.Connections = {}
                _G.OPAIHUB_FakeGeneratorESP.Active = false
            end
            return
        end
        
        if _G.OPAIHUB_FakeGeneratorESP.Active then
            return
        end
        
        _G.OPAIHUB_FakeGeneratorESP.Active = true
        
        local scanInterval = 0.5
        local lastScanTime = 0
        
        local function OPAIHUB_CreateFakeGeneratorESP(gen)
            if not gen or not gen.Parent or not gen:FindFirstChild("Main") then 
                return 
            end
            
            -- 如果数据已存在，检查ESP对象是否完整
            if _G.OPAIHUB_FakeGeneratorESP.Data[gen] then
                local data = _G.OPAIHUB_FakeGeneratorESP.Data[gen]
                -- 如果ESP对象都存在且有效，则不需要重新创建
                if data.Highlight and data.Highlight.Parent and
                   data.NameBillboard and data.NameBillboard.Parent then
                    return
                end
                -- 否则清理旧数据，准备重新创建
                if data.Highlight then data.Highlight:Destroy() end
                if data.NameLabel then data.NameLabel:Destroy() end
                if data.NameBillboard then data.NameBillboard:Destroy() end
                _G.OPAIHUB_FakeGeneratorESP.Data[gen] = nil
            end
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "OPAIHUB_FakeGeneratorHighlight"
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = true
            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.9
            highlight.OutlineTransparency = 0
            highlight.Parent = gen
            
            local nameBillboard = Instance.new("BillboardGui")
            nameBillboard.Name = "OPAIHUB_FakeGeneratorNameESP"
            nameBillboard.Size = UDim2.new(4, 0, 1, 0)
            nameBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
            nameBillboard.Adornee = gen.Main
            nameBillboard.Parent = gen.Main
            nameBillboard.AlwaysOnTop = true
            nameBillboard.Enabled = true
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextScaled = false
            nameLabel.Text = "假电机"
            nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            nameLabel.Font = Enum.Font.Arcade
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.TextSize = 12
            nameLabel.Parent = nameBillboard
            
            _G.OPAIHUB_FakeGeneratorESP.Data[gen] = {
                Highlight = highlight,
                NameLabel = nameLabel,
                NameBillboard = nameBillboard
            }
            
            local destroyConnection = gen.Destroying:Connect(function()
                if _G.OPAIHUB_FakeGeneratorESP.Data[gen] then
                    if _G.OPAIHUB_FakeGeneratorESP.Data[gen].Highlight then 
                        _G.OPAIHUB_FakeGeneratorESP.Data[gen].Highlight:Destroy() 
                    end
                    if _G.OPAIHUB_FakeGeneratorESP.Data[gen].NameLabel then 
                        _G.OPAIHUB_FakeGeneratorESP.Data[gen].NameLabel:Destroy() 
                    end
                    if _G.OPAIHUB_FakeGeneratorESP.Data[gen].NameBillboard then 
                        _G.OPAIHUB_FakeGeneratorESP.Data[gen].NameBillboard:Destroy() 
                    end
                    _G.OPAIHUB_FakeGeneratorESP.Data[gen] = nil
                end
                if destroyConnection then
                    destroyConnection:Disconnect()
                end
            end)
            
            table.insert(_G.OPAIHUB_FakeGeneratorESP.Connections, destroyConnection)
        end
        
        local function OPAIHUB_ScanFakeGenerators()
            local mapFolder = OPAIHUB_Workspace:FindFirstChild("Map")
            if mapFolder then
                local ingameFolder = mapFolder:FindFirstChild("Ingame")
                if ingameFolder then
                    local mapSubFolder = ingameFolder:FindFirstChild("Map")
                    if mapSubFolder then
                        for _, gen in pairs(mapSubFolder:GetDescendants()) do
                            if typeof(gen) == "Instance" and gen:IsA("Model") and gen:FindFirstChild("Main") and gen.Name == "FakeGenerator" then
                                OPAIHUB_CreateFakeGeneratorESP(gen)
                            end
                        end
                    end
                end
            end
        end
        
        local mainConnection
        local mapFolder = OPAIHUB_Workspace:FindFirstChild("Map")
        if mapFolder then
            local ingameFolder = mapFolder:FindFirstChild("Ingame")
            if ingameFolder then
                local mapSubFolder = ingameFolder:FindFirstChild("Map")
                if mapSubFolder then
                    mainConnection = mapSubFolder.DescendantAdded:Connect(function(v)
                        if typeof(v) == "Instance" and v:IsA("Model") and v:FindFirstChild("Main") and v.Name == "FakeGenerator" then
                            OPAIHUB_CreateFakeGeneratorESP(v)
                        end
                    end)
                end
            end
        end
        
        if mainConnection then
            table.insert(_G.OPAIHUB_FakeGeneratorESP.Connections, mainConnection)
        end
        
        local heartbeatConnection = OPAIHUB_RunService.Heartbeat:Connect(function(deltaTime)
            lastScanTime = lastScanTime + deltaTime
            if lastScanTime >= scanInterval then
                lastScanTime = 0
                OPAIHUB_ScanFakeGenerators()
            end
            
            local gensToRemove = {}
            for gen, data in _G.OPAIHUB_FakeGeneratorESP.Data do
                if not gen or not gen.Parent then
                    table.insert(gensToRemove, gen)
                else
                    -- 检查ESP对象是否丢失，如果丢失则重新创建
                    if not data.Highlight or not data.Highlight.Parent or
                       not data.NameBillboard or not data.NameBillboard.Parent then
                        -- ESP对象丢失，重新创建
                        if data.Highlight then data.Highlight:Destroy() end
                        if data.NameLabel then data.NameLabel:Destroy() end
                        if data.NameBillboard then data.NameBillboard:Destroy() end
                        _G.OPAIHUB_FakeGeneratorESP.Data[gen] = nil
                        OPAIHUB_CreateFakeGeneratorESP(gen)
                    end
                end
            end
            
            for _, gen in gensToRemove do
                if _G.OPAIHUB_FakeGeneratorESP.Data[gen] then
                    if _G.OPAIHUB_FakeGeneratorESP.Data[gen].Highlight then 
                        _G.OPAIHUB_FakeGeneratorESP.Data[gen].Highlight:Destroy() 
                    end
                    if _G.OPAIHUB_FakeGeneratorESP.Data[gen].NameLabel then 
                        _G.OPAIHUB_FakeGeneratorESP.Data[gen].NameLabel:Destroy() 
                    end
                    if _G.OPAIHUB_FakeGeneratorESP.Data[gen].NameBillboard then 
                        _G.OPAIHUB_FakeGeneratorESP.Data[gen].NameBillboard:Destroy() 
                    end
                    _G.OPAIHUB_FakeGeneratorESP.Data[gen] = nil
                end
            end
        end)
        
        table.insert(_G.OPAIHUB_FakeGeneratorESP.Connections, heartbeatConnection)
        OPAIHUB_ScanFakeGenerators()
    end
})

OPAIHUB_ESPGroup:AddDivider()

-- OPAIHUB Real Generator ESP
OPAIHUB_ESPGroup:AddToggle("OPAIHUB_RealGeneratorESP", {
    Text = "绘制真电机",
    Default = false,
    Callback = function(enabled)
        if not _G.OPAIHUB_RealGeneratorESP then
            _G.OPAIHUB_RealGeneratorESP = {
                Active = false,
                Data = {},
                Connections = {}
            }
        end
        
        if not enabled then
            if _G.OPAIHUB_RealGeneratorESP.Active then
                for _, connection in _G.OPAIHUB_RealGeneratorESP.Connections do
                    if connection and connection.Connected then
                        connection:Disconnect()
                    end
                end
                
                for gen, data in _G.OPAIHUB_RealGeneratorESP.Data do
                    if type(data) == "table" then
                        if data.Billboard and data.Billboard.Parent then
                            data.Billboard:Destroy()
                        end
                        if data.DistanceBillboard and data.DistanceBillboard.Parent then
                            data.DistanceBillboard:Destroy()
                        end
                        if data.Highlight and data.Highlight.Parent then
                            data.Highlight:Destroy()
                        end
                    end
                end
                
                _G.OPAIHUB_RealGeneratorESP.Data = {}
                _G.OPAIHUB_RealGeneratorESP.Connections = {}
                _G.OPAIHUB_RealGeneratorESP.Active = false
            end
            return
        end
        
        if _G.OPAIHUB_RealGeneratorESP.Active then
            return
        end
        
        _G.OPAIHUB_RealGeneratorESP.Active = true
        
        local scanInterval = 0.5
        local lastScanTime = 0
        local maxGenerators = 20
        
        local function OPAIHUB_UpdateGeneratorESP(gen, data)
            if not gen or not gen.Parent or not gen:FindFirstChild("Main") then
                return false
            end
            
            -- 检查ESP对象是否还存在，如果不存在则重新创建
            if not data.Billboard or not data.Billboard.Parent or
               not data.DistanceBillboard or not data.DistanceBillboard.Parent or
               not data.Highlight or not data.Highlight.Parent then
                -- ESP对象丢失，重新创建
                _G.OPAIHUB_RealGeneratorESP.Data[gen] = nil
                OPAIHUB_CreateGeneratorESP(gen)
                return true
            end
            
            if gen:FindFirstChild("Progress") then
                local progress = gen.Progress.Value
                -- 只有完成度达到100%才移除
                if progress >= 100 then
                    return false
                end
                
                if data.TextLabel and data.TextLabel.Parent then
                    data.TextLabel.Text = string.format("真电机: %d%%", progress)
                end
                
                local character = OPAIHUB_LocalPlayer.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart and data.DistanceLabel and data.DistanceLabel.Parent then
                    local distance = (gen.Main.Position - humanoidRootPart.Position).Magnitude
                    data.DistanceLabel.Text = string.format("距离: %d米", math.floor(distance))
                end
            end
            
            return true
        end
        
        local function OPAIHUB_CreateGeneratorESP(gen)
            if not gen or not gen.Parent or not gen:FindFirstChild("Main") then 
                return 
            end
            
            -- 如果数据已存在，检查ESP对象是否完整
            if _G.OPAIHUB_RealGeneratorESP.Data[gen] then
                local data = _G.OPAIHUB_RealGeneratorESP.Data[gen]
                -- 如果ESP对象都存在且有效，则不需要重新创建
                if data.Billboard and data.Billboard.Parent and
                   data.DistanceBillboard and data.DistanceBillboard.Parent and
                   data.Highlight and data.Highlight.Parent then
                    return
                end
                -- 否则清理旧数据，准备重新创建
                if data.Billboard then data.Billboard:Destroy() end
                if data.DistanceBillboard then data.DistanceBillboard:Destroy() end
                if data.Highlight then data.Highlight:Destroy() end
                _G.OPAIHUB_RealGeneratorESP.Data[gen] = nil
            end
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "OPAIHUB_RealGeneratorESP"
            billboard.Size = UDim2.new(4, 0, 1, 0)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.Adornee = gen.Main
            billboard.Parent = gen.Main
            billboard.AlwaysOnTop = true
            billboard.Enabled = true
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 0.5, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextScaled = false
            textLabel.Text = "真电机加载中..."
            textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            textLabel.Font = Enum.Font.Arcade
            textLabel.TextStrokeTransparency = 0
            textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            textLabel.TextSize = 8
            textLabel.Parent = billboard
            
            local distanceBillboard = Instance.new("BillboardGui")
            distanceBillboard.Name = "OPAIHUB_RealGeneratorDistanceESP"
            distanceBillboard.Size = UDim2.new(4, 0, 1, 0)
            distanceBillboard.StudsOffset = Vector3.new(0, 3.5, 0)
            distanceBillboard.Adornee = gen.Main
            distanceBillboard.Parent = gen.Main
            distanceBillboard.AlwaysOnTop = true
            distanceBillboard.Enabled = true
            
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextScaled = false
            distanceLabel.Text = "计算距离中..."
            distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            distanceLabel.Font = Enum.Font.Arcade
            distanceLabel.TextStrokeTransparency = 0
            distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            distanceLabel.TextSize = 8
            distanceLabel.Parent = distanceBillboard
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "OPAIHUB_RealGeneratorHighlight"
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = true
            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.FillTransparency = 0.9
            highlight.OutlineTransparency = 0
            highlight.Parent = gen
            
            _G.OPAIHUB_RealGeneratorESP.Data[gen] = {
                Billboard = billboard,
                DistanceBillboard = distanceBillboard,
                TextLabel = textLabel,
                DistanceLabel = distanceLabel,
                Highlight = highlight
            }
            
            local destroyConnection = gen.Destroying:Connect(function()
                if _G.OPAIHUB_RealGeneratorESP.Data[gen] then
                    if _G.OPAIHUB_RealGeneratorESP.Data[gen].Billboard then 
                        _G.OPAIHUB_RealGeneratorESP.Data[gen].Billboard:Destroy() 
                    end
                    if _G.OPAIHUB_RealGeneratorESP.Data[gen].DistanceBillboard then 
                        _G.OPAIHUB_RealGeneratorESP.Data[gen].DistanceBillboard:Destroy() 
                    end
                    if _G.OPAIHUB_RealGeneratorESP.Data[gen].Highlight then 
                        _G.OPAIHUB_RealGeneratorESP.Data[gen].Highlight:Destroy() 
                    end
                    _G.OPAIHUB_RealGeneratorESP.Data[gen] = nil
                end
                if destroyConnection then
                    destroyConnection:Disconnect()
                end
            end)
            
            table.insert(_G.OPAIHUB_RealGeneratorESP.Connections, destroyConnection)
        end
        
        local function OPAIHUB_ScanGenerators()
            local mapFolder = OPAIHUB_Workspace:FindFirstChild("Map")
            if mapFolder then
                local ingameFolder = mapFolder:FindFirstChild("Ingame")
                if ingameFolder then
                    local mapSubFolder = ingameFolder:FindFirstChild("Map")
                    if mapSubFolder then
                        for _, gen in pairs(mapSubFolder:GetDescendants()) do
                            if typeof(gen) == "Instance" and gen:IsA("Model") and gen:FindFirstChild("Main") and gen.Name == "Generator" then
                                OPAIHUB_CreateGeneratorESP(gen)
                            end
                        end
                    end
                end
            end
        end
        
        local mainConnection
        local mapFolder = OPAIHUB_Workspace:FindFirstChild("Map")
        if mapFolder then
            local ingameFolder = mapFolder:FindFirstChild("Ingame")
            if ingameFolder then
                local mapSubFolder = ingameFolder:FindFirstChild("Map")
                if mapSubFolder then
                    mainConnection = mapSubFolder.DescendantAdded:Connect(function(v)
                        if typeof(v) == "Instance" and v:IsA("Model") and v:FindFirstChild("Main") and v.Name == "Generator" then
                            OPAIHUB_CreateGeneratorESP(v)
                        end
                    end)
                end
            end
        end
        
        if mainConnection then
            table.insert(_G.OPAIHUB_RealGeneratorESP.Connections, mainConnection)
        end
        
        local heartbeatConnection = OPAIHUB_RunService.Heartbeat:Connect(function(deltaTime)
            lastScanTime = lastScanTime + deltaTime
            if lastScanTime >= scanInterval then
                lastScanTime = 0
                OPAIHUB_ScanGenerators()
            end
            
            local gensToRemove = {}
            for gen, data in _G.OPAIHUB_RealGeneratorESP.Data do
                if not gen or not gen.Parent then
                    table.insert(gensToRemove, gen)
                else
                    if not OPAIHUB_UpdateGeneratorESP(gen, data) then
                        table.insert(gensToRemove, gen)
                    end
                end
            end
            
            for _, gen in gensToRemove do
                if _G.OPAIHUB_RealGeneratorESP.Data[gen] then
                    if _G.OPAIHUB_RealGeneratorESP.Data[gen].Billboard then 
                        _G.OPAIHUB_RealGeneratorESP.Data[gen].Billboard:Destroy() 
                    end
                    if _G.OPAIHUB_RealGeneratorESP.Data[gen].DistanceBillboard then 
                        _G.OPAIHUB_RealGeneratorESP.Data[gen].DistanceBillboard:Destroy() 
                    end
                    if _G.OPAIHUB_RealGeneratorESP.Data[gen].Highlight then 
                        _G.OPAIHUB_RealGeneratorESP.Data[gen].Highlight:Destroy() 
                    end
                    _G.OPAIHUB_RealGeneratorESP.Data[gen] = nil
                end
            end
        end)
        
        table.insert(_G.OPAIHUB_RealGeneratorESP.Connections, heartbeatConnection)
        OPAIHUB_ScanGenerators()
    end
})

-- OPAIHUB Noli Warning ESP
OPAIHUB_ESPGroup:AddDivider()
OPAIHUB_ESPGroup:AddToggle("OPAIHUB_NoliWarningESP", {
    Text = "绘制Noli传送警告",
    Default = false,
    Callback = function(enabled)
        if not _G.OPAIHUB_NoliWarningESP then
            _G.OPAIHUB_NoliWarningESP = {
                Active = false,
                Data = {},
                Connections = {}
            }
        end
        
        if not enabled then
            if _G.OPAIHUB_NoliWarningESP.Active then
                for _, connection in _G.OPAIHUB_NoliWarningESP.Connections do
                    if connection and connection.Connected then
                        connection:Disconnect()
                    end
                end
                
                for gen, data in _G.OPAIHUB_NoliWarningESP.Data do
                    if type(data) == "table" then
                        if data.Highlight and data.Highlight.Parent then
                            data.Highlight:Destroy()
                        end
                        if data.Label and data.Label.Parent then
                            data.Label:Destroy()
                        end
                        if data.Billboard and data.Billboard.Parent then
                            data.Billboard:Destroy()
                        end
                    end
                end
                
                _G.OPAIHUB_NoliWarningESP.Data = {}
                _G.OPAIHUB_NoliWarningESP.Connections = {}
                _G.OPAIHUB_NoliWarningESP.Active = false
            end
            return
        end
        
        if _G.OPAIHUB_NoliWarningESP.Active then
            return
        end
        
        _G.OPAIHUB_NoliWarningESP.Active = true
        
        local scanInterval = 0.5
        local lastScanTime = 0
        
        local function OPAIHUB_HasNoliWarning(gen)
            if string.find(gen.Name, "NoliWarningIncoming") then
                return true
            end
            
            for _, child in pairs(gen:GetDescendants()) do
                if typeof(child) == "Instance" then
                    if (child:IsA("StringValue") or child:IsA("ObjectValue")) and 
                       string.find(tostring(child.Value), "NoliWarningIncoming") then
                        return true
                    elseif child:IsA("BasePart") and string.find(child.Name, "NoliWarningIncoming") then
                        return true
                    end
                end
            end
            
            return false
        end
        
        local function OPAIHUB_CreateNoliWarningESP(gen)
            if not gen or not gen.Parent or not gen:FindFirstChild("Main") then 
                return 
            end
            
            if not OPAIHUB_HasNoliWarning(gen) then
                return
            end
            
            -- 如果数据已存在，检查ESP对象是否完整
            if _G.OPAIHUB_NoliWarningESP.Data[gen] then
                local data = _G.OPAIHUB_NoliWarningESP.Data[gen]
                -- 如果ESP对象都存在且有效，则不需要重新创建
                if data.Highlight and data.Highlight.Parent and
                   data.Billboard and data.Billboard.Parent then
                    return
                end
                -- 否则清理旧数据，准备重新创建
                if data.Highlight then data.Highlight:Destroy() end
                if data.Label then data.Label:Destroy() end
                if data.Billboard then data.Billboard:Destroy() end
                _G.OPAIHUB_NoliWarningESP.Data[gen] = nil
            end
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "OPAIHUB_NoliWarningHighlight"
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = true
            highlight.OutlineColor = Color3.fromRGB(255, 0, 255)
            highlight.FillColor = Color3.fromRGB(255, 0, 255)
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.Parent = gen
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "OPAIHUB_NoliWarningBillboard"
            billboard.Size = UDim2.new(6, 0, 2, 0)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Adornee = gen.Main
            billboard.Parent = gen.Main
            billboard.AlwaysOnTop = true
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "[Noli即将传送]"
            label.TextColor3 = Color3.fromRGB(255, 0, 255)
            label.Font = Enum.Font.Arcade
            label.TextSize = 14
            label.TextStrokeTransparency = 0
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.Parent = billboard
            
            _G.OPAIHUB_NoliWarningESP.Data[gen] = {
                Highlight = highlight,
                Label = label,
                Billboard = billboard,
                LastCheck = os.time()
            }
            
            local destroyConnection = gen.Destroying:Connect(function()
                if _G.OPAIHUB_NoliWarningESP.Data[gen] then
                    if _G.OPAIHUB_NoliWarningESP.Data[gen].Highlight then 
                        _G.OPAIHUB_NoliWarningESP.Data[gen].Highlight:Destroy() 
                    end
                    if _G.OPAIHUB_NoliWarningESP.Data[gen].Label then 
                        _G.OPAIHUB_NoliWarningESP.Data[gen].Label:Destroy() 
                    end
                    if _G.OPAIHUB_NoliWarningESP.Data[gen].Billboard then 
                        _G.OPAIHUB_NoliWarningESP.Data[gen].Billboard:Destroy() 
                    end
                    _G.OPAIHUB_NoliWarningESP.Data[gen] = nil
                end
                if destroyConnection then
                    destroyConnection:Disconnect()
                end
            end)
            
            table.insert(_G.OPAIHUB_NoliWarningESP.Connections, destroyConnection)
        end
        
        local function OPAIHUB_ScanNoliWarnings()
            for _, gen in pairs(OPAIHUB_Workspace:GetDescendants()) do
                if typeof(gen) == "Instance" and gen:IsA("Model") and gen:FindFirstChild("Main") and 
                   (gen.Name == "Generator" or gen.Name == "FakeGenerator") then
                    OPAIHUB_CreateNoliWarningESP(gen)
                end
            end
        end
        
        local function OPAIHUB_UpdateExistingGenerators()
            local gensToRemove = {}
            for gen, data in _G.OPAIHUB_NoliWarningESP.Data do
                if not gen or not gen.Parent then
                    table.insert(gensToRemove, gen)
                else
                    -- 检查ESP对象是否丢失，如果丢失则重新创建
                    if not data.Highlight or not data.Highlight.Parent or
                       not data.Billboard or not data.Billboard.Parent then
                        -- ESP对象丢失，重新创建
                        if data.Highlight then data.Highlight:Destroy() end
                        if data.Label then data.Label:Destroy() end
                        if data.Billboard then data.Billboard:Destroy() end
                        _G.OPAIHUB_NoliWarningESP.Data[gen] = nil
                        OPAIHUB_CreateNoliWarningESP(gen)
                    elseif os.time() - data.LastCheck > 5 then
                        if not OPAIHUB_HasNoliWarning(gen) then
                            table.insert(gensToRemove, gen)
                        else
                            data.LastCheck = os.time()
                        end
                    end
                end
            end
            
            for _, gen in gensToRemove do
                if _G.OPAIHUB_NoliWarningESP.Data[gen] then
                    if _G.OPAIHUB_NoliWarningESP.Data[gen].Highlight then 
                        _G.OPAIHUB_NoliWarningESP.Data[gen].Highlight:Destroy() 
                    end
                    if _G.OPAIHUB_NoliWarningESP.Data[gen].Label then 
                        _G.OPAIHUB_NoliWarningESP.Data[gen].Label:Destroy() 
                    end
                    if _G.OPAIHUB_NoliWarningESP.Data[gen].Billboard then 
                        _G.OPAIHUB_NoliWarningESP.Data[gen].Billboard:Destroy() 
                    end
                    _G.OPAIHUB_NoliWarningESP.Data[gen] = nil
                end
            end
        end
        
        local mainConnection = OPAIHUB_Workspace.DescendantAdded:Connect(function(v)
            if typeof(v) == "Instance" and v:IsA("Model") and v:FindFirstChild("Main") and 
               (v.Name == "Generator" or v.Name == "FakeGenerator") then
                OPAIHUB_CreateNoliWarningESP(v)
            end
        end)
        
        table.insert(_G.OPAIHUB_NoliWarningESP.Connections, mainConnection)
        
        local heartbeatConnection = OPAIHUB_RunService.Heartbeat:Connect(function(deltaTime)
            lastScanTime = lastScanTime + deltaTime
            if lastScanTime >= scanInterval then
                lastScanTime = 0
                OPAIHUB_ScanNoliWarnings()
                OPAIHUB_UpdateExistingGenerators()
            end
        end)
        
        table.insert(_G.OPAIHUB_NoliWarningESP.Connections, heartbeatConnection)
        OPAIHUB_ScanNoliWarnings()
    end
})

-- 传送到最近发电机功能
OPAIHUB_ESPGroup:AddDivider()

local function OPAIHUB_FindNearestGenerator()
    local character = OPAIHUB_LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerHRP = character.HumanoidRootPart
    local playerPos = playerHRP.Position
    
    local mapFolder = OPAIHUB_Workspace:FindFirstChild("Map")
    if not mapFolder then return nil end
    
    local ingameFolder = mapFolder:FindFirstChild("Ingame")
    if not ingameFolder then return nil end
    
    local mapSubFolder = ingameFolder:FindFirstChild("Map")
    if not mapSubFolder then return nil end
    
    local nearestGenerator = nil
    local shortestDistance = math.huge
    
    for _, gen in pairs(mapSubFolder:GetDescendants()) do
        if typeof(gen) == "Instance" and gen:IsA("Model") and gen.Name == "Generator" then
            local mainPart = gen:FindFirstChild("Main")
            if mainPart then
                -- 检查发电机是否已完成
                local progress = gen:FindFirstChild("Progress")
                if not progress or progress.Value < 100 then
                    -- 只选择未完成的发电机
                    local distance = (mainPart.Position - playerPos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestGenerator = gen
                    end
                end
            end
        end
    end
    
    return nearestGenerator, shortestDistance
end

OPAIHUB_ESPGroup:AddButton("OPAIHUB_TeleportToGenerator", {
    Text = "传送到最近发电机",
    Func = function()
        local character = OPAIHUB_LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            OPAIHUB_Library:Notify("错误", "角色不存在", 3)
            return
        end
        
        local nearestGen, distance = OPAIHUB_FindNearestGenerator()
        
        if not nearestGen then
            OPAIHUB_Library:Notify("错误", "未找到发电机", 3)
            return
        end
        
        local mainPart = nearestGen:FindFirstChild("Main")
        if not mainPart then
            OPAIHUB_Library:Notify("错误", "发电机结构异常", 3)
            return
        end
        
        -- 传送到发电机位置（稍微偏移一点，避免卡在发电机内部）
        local offset = (mainPart.Position - OPAIHUB_LocalPlayer.Character.HumanoidRootPart.Position).Unit
        local targetCFrame = CFrame.new(mainPart.Position + offset * 3, mainPart.Position)
        
        OPAIHUB_SafeTeleport(targetCFrame)
        OPAIHUB_Library:Notify("传送成功", string.format("已传送到最近发电机 (距离: %.1f米)", distance), 3)
    end
})

OPAIHUB_ESPGroup:AddDivider()

OPAIHUB_ESPGroup:AddButton("OPAIHUB_TeleportToCompletedGenerator", {
    Text = "传送到最近已完成发电机",
    Func = function()
        local character = OPAIHUB_LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            OPAIHUB_Library:Notify("错误", "角色不存在", 3)
            return
        end
        
        local playerHRP = character.HumanoidRootPart
        local playerPos = playerHRP.Position
        
        local mapFolder = OPAIHUB_Workspace:FindFirstChild("Map")
        if not mapFolder then
            OPAIHUB_Library:Notify("错误", "未找到地图", 3)
            return
        end
        
        local ingameFolder = mapFolder:FindFirstChild("Ingame")
        if not ingameFolder then
            OPAIHUB_Library:Notify("错误", "未找到Ingame文件夹", 3)
            return
        end
        
        local mapSubFolder = ingameFolder:FindFirstChild("Map")
        if not mapSubFolder then
            OPAIHUB_Library:Notify("错误", "未找到Map文件夹", 3)
            return
        end
        
        local nearestGenerator = nil
        local shortestDistance = math.huge
        
        for _, gen in pairs(mapSubFolder:GetDescendants()) do
            if typeof(gen) == "Instance" and gen:IsA("Model") and gen.Name == "Generator" then
                local mainPart = gen:FindFirstChild("Main")
                local progress = gen:FindFirstChild("Progress")
                
                if mainPart and progress and progress.Value >= 100 then
                    local distance = (mainPart.Position - playerPos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestGenerator = gen
                    end
                end
            end
        end
        
        if not nearestGenerator then
            OPAIHUB_Library:Notify("错误", "未找到已完成的发电机", 3)
            return
        end
        
        local mainPart = nearestGenerator:FindFirstChild("Main")
        local offset = (mainPart.Position - playerPos).Unit
        local targetCFrame = CFrame.new(mainPart.Position + offset * 3, mainPart.Position)
        
        OPAIHUB_SafeTeleport(targetCFrame)
        OPAIHUB_Library:Notify("传送成功", string.format("已传送到已完成的发电机 (距离: %.1f米)", shortestDistance), 3)
    end
})

-- Auto Tab - Auto Pickup and Repair
local OPAIHUB_AutoGroup = OPAIHUB_Tabs.Auto:AddLeftGroupbox("OPAIHUB 自动功能")

-- OPAIHUB Auto Block (Guest 1337)
local OPAIHUB_AutoBlockEnabled = false
local OPAIHUB_AutoBlockConnection = nil

OPAIHUB_AutoGroup:AddToggle("OPAIHUB_AutoBlock", {
    Text = "自动格挡",
    Default = false,
    Tooltip = "自动格挡攻击",
    Callback = function(v)
        OPAIHUB_AutoBlockEnabled = v
        if v then
            local OPAIHUB_BlockDistance = 15
            local OPAIHUB_BlockCooldown = 0.5
            local OPAIHUB_LastBlockTime = 0
            local OPAIHUB_TargetSoundIds = {
                "rbxassetid://102228729296384",
                "rbxassetid://140242176732868",
                "rbxassetid://12222216",
                "rbxassetid://86174610237192",
                "rbxassetid://101199185291628",
                "rbxassetid://95079963655241",
                "rbxassetid://112809109188560",
                "rbxassetid://84307400688050",
                "rbxassetid://136323728355613",
                "rbxassetid://115026634746636"
            }
            
            local OPAIHUB_RemoteEvent = OPAIHUB_ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
            
            local function OPAIHUB_HasTargetSound(character)
                if not character then return false end
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    for _, child in pairs(humanoidRootPart:GetDescendants()) do
                        if typeof(child) == "Instance" and child:IsA("Sound") then
                            for _, targetId in ipairs(OPAIHUB_TargetSoundIds) do
                                if child.SoundId == targetId then
                                    return true
                                end
                            end
                        end
                    end
                end
                return false
            end
            
            local function OPAIHUB_GetKillersInRange()
                local killers = {}
                local killersFolder = OPAIHUB_Workspace:FindFirstChild("Killers") or OPAIHUB_Workspace:FindFirstChild("Players"):FindFirstChild("Killers")
                if not killersFolder then return killers end
                
                local myCharacter = OPAIHUB_LocalPlayer.Character
                if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return killers end
                
                local myPos = myCharacter.HumanoidRootPart.Position
                
                for _, killer in ipairs(killersFolder:GetChildren()) do
                    if killer:FindFirstChild("HumanoidRootPart") then
                        local distance = (killer.HumanoidRootPart.Position - myPos).Magnitude
                        if distance <= OPAIHUB_BlockDistance then
                            table.insert(killers, killer)
                        end
                    end
                end
                
                return killers
            end
            
            local function OPAIHUB_PerformBlock()
                if os.clock() - OPAIHUB_LastBlockTime >= OPAIHUB_BlockCooldown then
                    OPAIHUB_RemoteEvent:FireServer("UseActorAbility", "Block")
                    OPAIHUB_LastBlockTime = os.clock()
                end
            end
            
            local function OPAIHUB_CheckConditions()
                local killers = OPAIHUB_GetKillersInRange()
                for _, killer in ipairs(killers) do
                    if OPAIHUB_HasTargetSound(killer) then
                        OPAIHUB_PerformBlock()
                        break
                    end
                end
            end
            
            OPAIHUB_AutoBlockConnection = OPAIHUB_RunService.Stepped:Connect(function()
                pcall(OPAIHUB_CheckConditions)
            end)
            
            OPAIHUB_Library:Notify("自动格挡已启用", "自动格挡系统已激活", 3)
        else
            if OPAIHUB_AutoBlockConnection then
                OPAIHUB_AutoBlockConnection:Disconnect()
                OPAIHUB_AutoBlockConnection = nil
            end
            OPAIHUB_Library:Notify("自动格挡已关闭", "自动格挡系统已停用", 3)
        end
    end
})

-- OPAIHUB Auto Repair Generator
local OPAIHUB_AutoRepairEnabled = false
local OPAIHUB_AutoRepairTask = nil
local OPAIHUB_RepairInterval = 1.8

OPAIHUB_AutoGroup:AddSlider("OPAIHUB_RepairInterval", {
    Text = "修机间隔",
    Min = 0.5,
    Max = 10,
    Default = 1.8,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        OPAIHUB_RepairInterval = v
    end
})

OPAIHUB_AutoGroup:AddToggle("OPAIHUB_AutoRepair", {
    Text = "自动修机",
    Default = false,
    Tooltip = "自动修理发电机",
    Callback = function(v)
        OPAIHUB_AutoRepairEnabled = v
        if v then
            OPAIHUB_AutoRepairTask = task.spawn(function()
                while OPAIHUB_AutoRepairEnabled do
                    local map = OPAIHUB_Workspace:FindFirstChild("Map")
                    local ingame = map and map:FindFirstChild("Ingame")
                    local currentMap = ingame and ingame:FindFirstChild("Map")
                    
                    if currentMap then
                        for _, obj in ipairs(currentMap:GetChildren()) do
                            if obj.Name == "Generator" and obj:FindFirstChild("Progress") and obj.Progress.Value < 100 then
                                local remote = obj:FindFirstChild("Remotes") and obj.Remotes:FindFirstChild("RE")
                                if remote then
                                    remote:FireServer()
                                end
                            end
                        end
                    end
                    task.wait(OPAIHUB_RepairInterval)
                end
            end)
            OPAIHUB_Library:Notify("自动修机已启用", "自动修机系统已激活", 3)
        else
            if OPAIHUB_AutoRepairTask then
                task.cancel(OPAIHUB_AutoRepairTask)
                OPAIHUB_AutoRepairTask = nil
            end
            OPAIHUB_Library:Notify("自动修机已关闭", "自动修机系统已停用", 3)
        end
    end
})

-- OPAIHUB Auto Pickup Items
OPAIHUB_AutoGroup:AddDivider()

local OPAIHUB_AutoTeleportMedkitEnabled = false
local OPAIHUB_TeleportMedkitThread = nil

OPAIHUB_AutoGroup:AddToggle("OPAIHUB_AutoTeleportMedkit", {
    Text = "医疗包传送拾取",
    Default = false,
    Tooltip = "自动将医疗包传送到自己位置并互动",
    Callback = function(v)
        OPAIHUB_AutoTeleportMedkitEnabled = v
        if v then
            OPAIHUB_TeleportMedkitThread = task.spawn(function()
                while OPAIHUB_AutoTeleportMedkitEnabled and task.wait(0.5) do
                    local character = OPAIHUB_LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        local medkit = OPAIHUB_Workspace:FindFirstChild("Map", true)
                        if medkit then
                            medkit = medkit:FindFirstChild("Ingame", true)
                            if medkit then
                                medkit = medkit:FindFirstChild("Medkit", true)
                                if medkit then
                                    local itemRoot = medkit:FindFirstChild("ItemRoot", true)
                                    if itemRoot then
                                        itemRoot.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 3
                                        local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("医疗包传送拾取已启用", "医疗包传送已激活", 3)
        else
            if OPAIHUB_TeleportMedkitThread then
                task.cancel(OPAIHUB_TeleportMedkitThread)
                OPAIHUB_TeleportMedkitThread = nil
            end
            OPAIHUB_Library:Notify("医疗包传送拾取已关闭", "医疗包传送已停用", 3)
        end
    end
})

local OPAIHUB_AutoTeleportColaEnabled = false
local OPAIHUB_TeleportColaThread = nil

OPAIHUB_AutoGroup:AddToggle("OPAIHUB_AutoTeleportCola", {
    Text = "可乐传送拾取",
    Default = false,
    Tooltip = "自动将可乐传送到自己位置并互动",
    Callback = function(v)
        OPAIHUB_AutoTeleportColaEnabled = v
        if v then
            OPAIHUB_TeleportColaThread = task.spawn(function()
                while OPAIHUB_AutoTeleportColaEnabled and task.wait(0.5) do
                    local character = OPAIHUB_LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        local cola = OPAIHUB_Workspace:FindFirstChild("Map", true)
                        if cola then
                            cola = cola:FindFirstChild("Ingame", true)
                            if cola then
                                cola = cola:FindFirstChild("BloxyCola", true)
                                if cola then
                                    local itemRoot = cola:FindFirstChild("ItemRoot", true)
                                    if itemRoot then
                                        itemRoot.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 3
                                        local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("可乐传送拾取已启用", "可乐传送已激活", 3)
        else
            if OPAIHUB_TeleportColaThread then
                task.cancel(OPAIHUB_TeleportColaThread)
                OPAIHUB_TeleportColaThread = nil
            end
            OPAIHUB_Library:Notify("可乐传送拾取已关闭", "可乐传送已停用", 3)
        end
    end
})

-- OPAIHUB Auto Flip Coins
local OPAIHUB_AutoFlipCoinsEnabled = false
local OPAIHUB_FlipCoinsThread = nil

OPAIHUB_AutoGroup:AddDivider()
OPAIHUB_AutoGroup:AddToggle("OPAIHUB_AutoFlipCoins", {
    Text = "自动投币",
    Default = false,
    Tooltip = "自动投掷硬币",
    Callback = function(v)
        OPAIHUB_AutoFlipCoinsEnabled = v
        if v then
            OPAIHUB_FlipCoinsThread = task.spawn(function()
                while OPAIHUB_AutoFlipCoinsEnabled and task.wait() do
                    OPAIHUB_ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer("UseActorAbility", "CoinFlip")
                end
            end)
            OPAIHUB_Library:Notify("自动投币已启用", "自动投币已激活", 3)
        else
            if OPAIHUB_FlipCoinsThread then
                task.cancel(OPAIHUB_FlipCoinsThread)
                OPAIHUB_FlipCoinsThread = nil
            end
            OPAIHUB_Library:Notify("自动投币已关闭", "自动投币已停用", 3)
        end
    end
})

-- Aimbot Tab - Survivor Aimbots
local OPAIHUB_SurvivorAimbotGroup = OPAIHUB_Tabs.Aimbot:AddLeftGroupbox("OPAIHUB 幸存者自瞄")

-- Distance Sliders
local OPAIHUB_ChanceMaxDistance = 50
local OPAIHUB_TwoTimeMaxDistance = 50
local OPAIHUB_ShedletskyMaxDistance = 50

OPAIHUB_SurvivorAimbotGroup:AddSlider("OPAIHUB_ChanceDistance", {
    Text = "机会自瞄距离",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_ChanceMaxDistance = value
    end
})

OPAIHUB_SurvivorAimbotGroup:AddSlider("OPAIHUB_TwoTimeDistance", {
    Text = "TwoTime自瞄距离",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_TwoTimeMaxDistance = value
    end
})

OPAIHUB_SurvivorAimbotGroup:AddSlider("OPAIHUB_ShedletskyDistance", {
    Text = "Shedletsky自瞄距离",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_ShedletskyMaxDistance = value
    end
})

-- Chance Aimbot
local OPAIHUB_ChanceAimbotEnabled = false
local OPAIHUB_ChanceAimbotConnection = nil

OPAIHUB_SurvivorAimbotGroup:AddDivider()
OPAIHUB_SurvivorAimbotGroup:AddToggle("OPAIHUB_ChanceAimbot", {
    Text = "机会自瞄",
    Default = false,
    Callback = function(state)
        OPAIHUB_ChanceAimbotEnabled = state
        if state then
            if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name ~= "Chance" then
                OPAIHUB_Library:Notify("错误", "你用的角色不是Chance，无法生效", 3)
                return
            end
            
            local OPAIHUB_RemoteEvent = OPAIHUB_ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
            
            OPAIHUB_ChanceAimbotConnection = OPAIHUB_RemoteEvent.OnClientEvent:Connect(function(...)
                local args = {...}
                if args[1] == "UseActorAbility" and args[2] == "Shoot" then 
                    local killerContainer = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
                    if killerContainer then 
                        local killer = killerContainer:FindFirstChildOfClass("Model")
                        if killer and killer:FindFirstChild("HumanoidRootPart") then 
                            local killerHRP = killer.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if playerHRP then 
                                local distance = (killerHRP.Position - playerHRP.Position).Magnitude
                                if distance <= OPAIHUB_ChanceMaxDistance then
                                    local TMP = 0.35
                                    local AMD = 2
                                    local endTime = tick() + AMD
                                    while tick() < endTime do
                                        OPAIHUB_RunService.RenderStepped:Wait()
                                        OPAIHUB_LocalPlayer.Character.HumanoidRootPart.CFrame = killerHRP.CFrame + Vector3.new(0, 0, -2)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("机会自瞄已启用", "机会自瞄已激活", 3)
        else
            if OPAIHUB_ChanceAimbotConnection then
                OPAIHUB_ChanceAimbotConnection:Disconnect()
                OPAIHUB_ChanceAimbotConnection = nil
            end
            OPAIHUB_Library:Notify("机会自瞄已关闭", "机会自瞄已停用", 3)
        end
    end
})

-- TwoTime Aimbot
local OPAIHUB_TwoTimeAimbotEnabled = false
local OPAIHUB_TwoTimeAimbotConnection = nil

OPAIHUB_SurvivorAimbotGroup:AddToggle("OPAIHUB_TwoTimeAimbot", {
    Text = "TwoTime自瞄",
    Default = false,
    Callback = function(state)
        OPAIHUB_TwoTimeAimbotEnabled = state
        if state then
            if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name ~= "TwoTime" then
                OPAIHUB_Library:Notify("错误", "你的角色不是TwoTime，无法生效", 3)
                return 
            end
            
            local OPAIHUB_TWOsounds = {
                "rbxassetid://86710781315432",
                "rbxassetid://99820161736138"
            }
            
            OPAIHUB_TwoTimeAimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not OPAIHUB_TwoTimeAimbotEnabled then return end
                for _, v in pairs(OPAIHUB_TWOsounds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                            if player ~= OPAIHUB_LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance and distance <= OPAIHUB_TwoTimeMaxDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local num = 1
                                local maxIterations = 100
                                
                                if child.Name == "rbxassetid://79782181585087" then
                                    maxIterations = 220
                                end
                                
                                while num <= maxIterations do
                                    task.wait(0.01)
                                    num = num + 1
                                    OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("TwoTime自瞄已启用", "TwoTime自瞄已激活", 3)
        else
            if OPAIHUB_TwoTimeAimbotConnection then
                OPAIHUB_TwoTimeAimbotConnection:Disconnect()
                OPAIHUB_TwoTimeAimbotConnection = nil
            end
            OPAIHUB_Library:Notify("TwoTime自瞄已关闭", "TwoTime自瞄已停用", 3)
        end
    end
})

-- Shedletsky Aimbot
local OPAIHUB_ShedletskyAimbotEnabled = false
local OPAIHUB_ShedletskyAimbotConnection = nil

OPAIHUB_SurvivorAimbotGroup:AddToggle("OPAIHUB_ShedletskyAimbot", {
    Text = "Shedletsky自瞄",
    Default = false,
    Callback = function(state)
        OPAIHUB_ShedletskyAimbotEnabled = state
        if state then
            if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name ~= "Shedletsky" then
                OPAIHUB_Library:Notify("错误", "你的角色不是Shedletsky，无法生效", 3)
                return
            end
            
            OPAIHUB_ShedletskyAimbotConnection = OPAIHUB_LocalPlayer.Character.Sword.ChildAdded:Connect(function(child)
                if not OPAIHUB_ShedletskyAimbotEnabled then return end
                if child:IsA("Sound") then 
                    local FAN = child.Name
                    if FAN == "rbxassetid://12222225" or FAN == "83851356262523" then 
                        local killersFolder = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
                        if killersFolder then 
                            local killer = killersFolder:FindFirstChildOfClass("Model")
                            if killer and killer:FindFirstChild("HumanoidRootPart") then 
                                local killerHRP = killer.HumanoidRootPart
                                local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if playerHRP then 
                                    local distance = (killerHRP.Position - playerHRP.Position).Magnitude
                                    if distance <= OPAIHUB_ShedletskyMaxDistance then
                                        local num = 1
                                        local maxIterations = 100
                                        while num <= maxIterations do
                                            task.wait(0.01)
                                            num = num + 1
                                            OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, killerHRP.Position)
                                            playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, killerHRP.Position)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("Shedletsky自瞄已启用", "Shedletsky自瞄已激活", 3)
        else
            if OPAIHUB_ShedletskyAimbotConnection then
                OPAIHUB_ShedletskyAimbotConnection:Disconnect()
                OPAIHUB_ShedletskyAimbotConnection = nil
            end
            OPAIHUB_Library:Notify("Shedletsky自瞄已关闭", "Shedletsky自瞄已停用", 3)
        end
    end
})

-- Killer Aimbot Group
local OPAIHUB_KillerAimbotGroup = OPAIHUB_Tabs.Aimbot:AddRightGroupbox("OPAIHUB 杀手自瞄")

local OPAIHUB_X1X4MaxDistance = 50
local OPAIHUB_CoolMaxDistance = 50
local OPAIHUB_JohnMaxDistance = 50
local OPAIHUB_JasonMaxDistance = 50

OPAIHUB_KillerAimbotGroup:AddSlider("OPAIHUB_X1X4Distance", {
    Text = "1x4自瞄距离",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_X1X4MaxDistance = value
    end
})

OPAIHUB_KillerAimbotGroup:AddSlider("OPAIHUB_CoolDistance", {
    Text = "酷小孩自瞄距离",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_CoolMaxDistance = value
    end
})

OPAIHUB_KillerAimbotGroup:AddSlider("OPAIHUB_JohnDistance", {
    Text = "John自瞄距离",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_JohnMaxDistance = value
    end
})

OPAIHUB_KillerAimbotGroup:AddSlider("OPAIHUB_JasonDistance", {
    Text = "Jason自瞄距离",
    Default = 50,
    Min = 10,
    Max = 150,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_JasonMaxDistance = value
    end
})

-- 1x4 Aimbot
local OPAIHUB_X1X4AimbotEnabled = false
local OPAIHUB_X1X4AimbotConnection = nil

OPAIHUB_KillerAimbotGroup:AddDivider()
OPAIHUB_KillerAimbotGroup:AddToggle("OPAIHUB_X1X4Aimbot", {
    Text = "1x4自瞄",
    Default = false,
    Callback = function(state)
        OPAIHUB_X1X4AimbotEnabled = state
        if state then
            if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name ~= "1x1x1x1" then
                OPAIHUB_Library:Notify("错误", "你的角色不是1x1x1x1，无法生效", 3)
                return
            end
            
            local OPAIHUB_X1X4Sounds = {
                "rbxassetid://86710781315432",
                "rbxassetid://99820161736138"
            }
            
            OPAIHUB_X1X4AimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not OPAIHUB_X1X4AimbotEnabled then return end
                for _, v in pairs(OPAIHUB_X1X4Sounds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                            if player ~= OPAIHUB_LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance and distance <= OPAIHUB_X1X4MaxDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local num = 1
                                local maxIterations = 100
                                
                                while num <= maxIterations do
                                    task.wait(0.01)
                                    num = num + 1
                                    OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("1x4自瞄已启用", "1x4自瞄已激活", 3)
        else
            if OPAIHUB_X1X4AimbotConnection then
                OPAIHUB_X1X4AimbotConnection:Disconnect()
                OPAIHUB_X1X4AimbotConnection = nil
            end
            OPAIHUB_Library:Notify("1x4自瞄已关闭", "1x4自瞄已停用", 3)
        end
    end
})

-- Cool Aimbot
local OPAIHUB_CoolAimbotEnabled = false
local OPAIHUB_CoolAimbotConnection = nil

OPAIHUB_KillerAimbotGroup:AddToggle("OPAIHUB_CoolAimbot", {
    Text = "酷小孩自瞄",
    Default = false,
    Callback = function(state)
        OPAIHUB_CoolAimbotEnabled = state
        if state then
            if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name ~= "c00lkidd" then
                OPAIHUB_Library:Notify("错误", "你的角色不是c00lkidd，无法生效", 3)
                return
            end
            
            local OPAIHUB_CoolSounds = {
                "rbxassetid://86710781315432",
                "rbxassetid://99820161736138"
            }
            
            OPAIHUB_CoolAimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not OPAIHUB_CoolAimbotEnabled then return end
                for _, v in pairs(OPAIHUB_CoolSounds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                            if player ~= OPAIHUB_LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance and distance <= OPAIHUB_CoolMaxDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local num = 1
                                local maxIterations = 100
                                
                                while num <= maxIterations do
                                    task.wait(0.01)
                                    num = num + 1
                                    OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("酷小孩自瞄已启用", "酷小孩自瞄已激活", 3)
        else
            if OPAIHUB_CoolAimbotConnection then
                OPAIHUB_CoolAimbotConnection:Disconnect()
                OPAIHUB_CoolAimbotConnection = nil
            end
            OPAIHUB_Library:Notify("酷小孩自瞄已关闭", "酷小孩自瞄已停用", 3)
        end
    end
})

-- John Aimbot
local OPAIHUB_JohnAimbotEnabled = false
local OPAIHUB_JohnAimbotConnection = nil

OPAIHUB_KillerAimbotGroup:AddToggle("OPAIHUB_JohnAimbot", {
    Text = "John自瞄",
    Default = false,
    Callback = function(state)
        OPAIHUB_JohnAimbotEnabled = state
        if state then
            if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name ~= "JohnDoe" then
                OPAIHUB_Library:Notify("错误", "你的角色不是JohnDoe，无法生效", 3)
                return
            end
            
            local OPAIHUB_JohnSounds = {
                "rbxassetid://86710781315432",
                "rbxassetid://99820161736138"
            }
            
            OPAIHUB_JohnAimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not OPAIHUB_JohnAimbotEnabled then return end
                for _, v in pairs(OPAIHUB_JohnSounds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                            if player ~= OPAIHUB_LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance and distance <= OPAIHUB_JohnMaxDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local num = 1
                                local maxIterations = 100
                                
                                while num <= maxIterations do
                                    task.wait(0.01)
                                    num = num + 1
                                    OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("John自瞄已启用", "John自瞄已激活", 3)
        else
            if OPAIHUB_JohnAimbotConnection then
                OPAIHUB_JohnAimbotConnection:Disconnect()
                OPAIHUB_JohnAimbotConnection = nil
            end
            OPAIHUB_Library:Notify("John自瞄已关闭", "John自瞄已停用", 3)
        end
    end
})

-- Jason Aimbot
local OPAIHUB_JasonAimbotEnabled = false
local OPAIHUB_JasonAimbotConnection = nil

OPAIHUB_KillerAimbotGroup:AddToggle("OPAIHUB_JasonAimbot", {
    Text = "Jason自瞄",
    Default = false,
    Callback = function(state)
        OPAIHUB_JasonAimbotEnabled = state
        if state then
            if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name ~= "Jason" then
                OPAIHUB_Library:Notify("错误", "你的角色不是Jason，无法生效", 3)
                return
            end
            
            local OPAIHUB_JasonSounds = {
                "rbxassetid://86710781315432",
                "rbxassetid://99820161736138"
            }
            
            OPAIHUB_JasonAimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                if not OPAIHUB_JasonAimbotEnabled then return end
                for _, v in pairs(OPAIHUB_JasonSounds) do
                    if child.Name == v then
                        local survivors = {}
                        for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                            if player ~= OPAIHUB_LocalPlayer then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    table.insert(survivors, character)
                                end
                            end
                        end
                        
                        local nearestSurvivor = nil
                        local shortestDistance = math.huge
                        
                        for _, survivor in pairs(survivors) do
                            local survivorHRP = survivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                                if distance < shortestDistance and distance <= OPAIHUB_JasonMaxDistance then
                                    shortestDistance = distance
                                    nearestSurvivor = survivor
                                end
                            end
                        end
                        
                        if nearestSurvivor then
                            local nearestHRP = nearestSurvivor.HumanoidRootPart
                            local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if playerHRP then
                                local num = 1
                                local maxIterations = 100
                                
                                while num <= maxIterations do
                                    task.wait(0.01)
                                    num = num + 1
                                    OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                    playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("Jason自瞄已启用", "Jason自瞄已激活", 3)
        else
            if OPAIHUB_JasonAimbotConnection then
                OPAIHUB_JasonAimbotConnection:Disconnect()
                OPAIHUB_JasonAimbotConnection = nil
            end
            OPAIHUB_Library:Notify("Jason自瞄已关闭", "Jason自瞄已停用", 3)
        end
    end
})

-- John Doe Auto 404
local OPAIHUB_JohnDoeAuto404Enabled = false
local OPAIHUB_JohnDoeAuto404Connection = nil

OPAIHUB_CombatGroup:AddDivider()
OPAIHUB_CombatGroup:AddToggle("OPAIHUB_JohnDoeAuto404", {
    Text = "John自动404",
    Default = false,
    Tooltip = "检测动画自动触发404错误技能",
    Callback = function(v)
        OPAIHUB_JohnDoeAuto404Enabled = v
        if v then
            local OPAIHUB_RANGE = 19
            local OPAIHUB_SPAM_DURATION = 3
            local OPAIHUB_COOLDOWN_TIME = 5
            local OPAIHUB_ActiveCooldowns = {}
            
            local OPAIHUB_AnimsToDetect = {
                ["116618003477002"] = true,
                ["119462383658044"] = true,
                ["131696603025265"] = true,
                ["121255898612475"] = true,
                ["133491532453922"] = true,
                ["103601716322988"] = true,
                ["86371356500204"] = true,
                ["72722244508749"] = false,
                ["87259391926321"] = true,
                ["96959123077498"] = false,
                ["86709774283672"] = true,
                ["77448521277146"] = true,
            }
            
            local function OPAIHUB_Fire404Error()
                local args = { "UseActorAbility", "404Error" }
                OPAIHUB_ReplicatedStorage:WaitForChild("Modules")
                    :WaitForChild("Network")
                    :WaitForChild("RemoteEvent")
                    :FireServer(unpack(args))
            end
            
            local function OPAIHUB_IsAnimationMatching(anim)
                local id = tostring(anim.Animation and anim.Animation.AnimationId or "")
                local numId = id:match("%d+")
                return OPAIHUB_AnimsToDetect[numId] or false
            end
            
            OPAIHUB_JohnDoeAuto404Connection = OPAIHUB_RunService.Heartbeat:Connect(function()
                for _, player in ipairs(OPAIHUB_Players:GetPlayers()) do
                    if player ~= OPAIHUB_LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = player.Character.HumanoidRootPart
                        local myChar = OPAIHUB_LocalPlayer.Character
                        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                            local dist = (targetHRP.Position - myChar.HumanoidRootPart.Position).Magnitude
                            if dist <= OPAIHUB_RANGE and (not OPAIHUB_ActiveCooldowns[player] or tick() - OPAIHUB_ActiveCooldowns[player] >= OPAIHUB_COOLDOWN_TIME) then
                                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                                if humanoid then
                                    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                        if OPAIHUB_IsAnimationMatching(track) then
                                            OPAIHUB_ActiveCooldowns[player] = tick()
                                            task.spawn(function()
                                                local startTime = tick()
                                                while tick() - startTime < OPAIHUB_SPAM_DURATION do
                                                    OPAIHUB_Fire404Error()
                                                    task.wait(0.05)
                                                end
                                            end)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            OPAIHUB_Library:Notify("John自动404已启用", "自动404系统已激活", 3)
        else
            if OPAIHUB_JohnDoeAuto404Connection then
                OPAIHUB_JohnDoeAuto404Connection:Disconnect()
                OPAIHUB_JohnDoeAuto404Connection = nil
            end
            OPAIHUB_Library:Notify("John自动404已关闭", "自动404系统已停用", 3)
        end
    end
})

-- FOV Settings
local OPAIHUB_FOVGroup = OPAIHUB_Tabs.Visual:AddRightGroupbox("OPAIHUB 视野设置")

local OPAIHUB_FOVValue = 70
local OPAIHUB_FOVEnabled = false

OPAIHUB_FOVGroup:AddSlider("OPAIHUB_FOVValue", {
    Text = "视野范围",
    Min = 70,
    Default = 70,
    Max = 120,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        OPAIHUB_FOVValue = v
    end
})

OPAIHUB_FOVGroup:AddToggle("OPAIHUB_FOV", {
    Text = "应用视野范围",
    Default = false,
    Callback = function(v)
        OPAIHUB_FOVEnabled = v
        if v then
            OPAIHUB_RunService.RenderStepped:Connect(function()
                if OPAIHUB_FOVEnabled then
                    OPAIHUB_Workspace.Camera.FieldOfView = OPAIHUB_FOVValue
                end
            end)
        end
    end
})

-- Anti-Loophole Tab
local OPAIHUB_AntiLoopholeGroup = OPAIHUB_Tabs.AntiLoophole:AddLeftGroupbox("OPAIHUB 反作弊效果")

OPAIHUB_AntiLoopholeGroup:AddLabel("OPAIHUB 反作弊效果功能")
OPAIHUB_AntiLoopholeGroup:AddDivider()

OPAIHUB_AntiLoopholeGroup:AddLabel("这些功能帮助绕过游戏漏洞")
OPAIHUB_AntiLoopholeGroup:AddLabel("并防止不必要的效果")

-- 调试功能组
local OPAIHUB_DebugGroup = OPAIHUB_Tabs.Aimbot:AddRightGroupbox("OPAIHUB 自瞄调试")

local OPAIHUB_DebugModeEnabled = false
local OPAIHUB_DebugConnection = nil

OPAIHUB_DebugGroup:AddToggle("OPAIHUB_DebugMode", {
    Text = "调试模式",
    Default = false,
    Tooltip = "显示自瞄触发信息和检测到的声音ID",
    Callback = function(v)
        OPAIHUB_DebugModeEnabled = v
        if v then
            if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                OPAIHUB_DebugConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                    if typeof(child) == "Instance" then
                        local childType = child.ClassName
                        local childName = child.Name
                        local childId = ""
                        
                        if child:IsA("Sound") then
                            childId = child.SoundId
                        end
                        
                        OPAIHUB_Library:Notify("调试", string.format("检测到: %s | 名称: %s | ID: %s", childType, childName, childId ~= "" and childId or "无"), 5)
                        print(string.format("[OPAIHUB调试] 类型: %s | 名称: %s | ID: %s", childType, childName, childId ~= "" and childId or "无"))
                    end
                end)
                OPAIHUB_Library:Notify("调试模式已启用", "开始监听角色身上的对象", 3)
            else
                OPAIHUB_Library:Notify("错误", "角色不存在，等待角色生成", 3)
                OPAIHUB_LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(1)
                    if OPAIHUB_DebugModeEnabled then
                        if OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            OPAIHUB_DebugConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
                                if typeof(child) == "Instance" then
                                    local childType = child.ClassName
                                    local childName = child.Name
                                    local childId = ""
                                    
                                    if child:IsA("Sound") then
                                        childId = child.SoundId
                                    end
                                    
                                    OPAIHUB_Library:Notify("调试", string.format("检测到: %s | 名称: %s | ID: %s", childType, childName, childId ~= "" and childId or "无"), 5)
                                    print(string.format("[OPAIHUB调试] 类型: %s | 名称: %s | ID: %s", childType, childName, childId ~= "" and childId or "无"))
                                end
                            end)
                        end
                    end
                end)
            end
        else
            if OPAIHUB_DebugConnection then
                OPAIHUB_DebugConnection:Disconnect()
                OPAIHUB_DebugConnection = nil
            end
            OPAIHUB_Library:Notify("调试模式已关闭", "停止监听", 3)
        end
    end
})

OPAIHUB_DebugGroup:AddDivider()

OPAIHUB_DebugGroup:AddButton("OPAIHUB_TestAimbot", {
    Text = "测试自瞄功能",
    Func = function()
        local character = OPAIHUB_LocalPlayer.Character
        if not character then
            OPAIHUB_Library:Notify("错误", "角色不存在", 3)
            return
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            OPAIHUB_Library:Notify("错误", "找不到HumanoidRootPart", 3)
            return
        end
        
        -- 检查HRP上的所有子对象
        local children = hrp:GetChildren()
        OPAIHUB_Library:Notify("调试", string.format("HRP子对象数量: %d", #children), 3)
        print(string.format("[OPAIHUB调试] HRP子对象数量: %d", #children))
        
        for _, child in pairs(children) do
            if typeof(child) == "Instance" then
                local info = string.format("类型: %s | 名称: %s", child.ClassName, child.Name)
                if child:IsA("Sound") then
                    info = info .. string.format(" | SoundId: %s", child.SoundId)
                end
                print("[OPAIHUB调试] " .. info)
            end
        end
        
        -- 检查是否有自瞄相关的声音
        local aimbotSounds = {
            "rbxassetid://86710781315432",
            "rbxassetid://99820161736138",
            "rbxassetid://79782181585087"
        }
        
        local foundSounds = {}
        for _, child in pairs(children) do
            if typeof(child) == "Instance" and child:IsA("Sound") then
                for _, soundId in pairs(aimbotSounds) do
                    if child.SoundId == soundId or child.Name == soundId then
                        table.insert(foundSounds, soundId)
                    end
                end
            end
        end
        
        if #foundSounds > 0 then
            OPAIHUB_Library:Notify("成功", string.format("找到 %d 个自瞄相关声音", #foundSounds), 5)
            print(string.format("[OPAIHUB调试] 找到自瞄声音: %s", table.concat(foundSounds, ", ")))
        else
            OPAIHUB_Library:Notify("警告", "未找到自瞄相关声音，可能需要更新ID", 5)
            print("[OPAIHUB调试] 未找到自瞄相关声音")
        end
    end
})

OPAIHUB_DebugGroup:AddDivider()

OPAIHUB_DebugGroup:AddButton("OPAIHUB_CheckSword", {
    Text = "检查Shedletsky的剑",
    Func = function()
        local character = OPAIHUB_LocalPlayer.Character
        if not character then
            OPAIHUB_Library:Notify("错误", "角色不存在", 3)
            return
        end
        
        if character.Name ~= "Shedletsky" then
            OPAIHUB_Library:Notify("警告", "当前角色不是Shedletsky", 3)
        end
        
        local sword = character:FindFirstChild("Sword")
        if not sword then
            OPAIHUB_Library:Notify("错误", "找不到Sword对象", 3)
            return
        end
        
        local children = sword:GetChildren()
        OPAIHUB_Library:Notify("调试", string.format("Sword子对象数量: %d", #children), 3)
        print(string.format("[OPAIHUB调试] Sword子对象数量: %d", #children))
        
        for _, child in pairs(children) do
            if typeof(child) == "Instance" then
                local info = string.format("类型: %s | 名称: %s", child.ClassName, child.Name)
                if child:IsA("Sound") then
                    info = info .. string.format(" | SoundId: %s", child.SoundId)
                end
                print("[OPAIHUB调试] " .. info)
            end
        end
    end
})

-- ============================================
-- OPAIHUB 清理和初始化
-- ============================================

-- 初始化OPAIHUB_NoStun
OPAIHUB_SetupNoStun()

-- 角色重生时重置
OPAIHUB_LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    
    if OPAIHUB_SpeedBoostEnabled then
        OPAIHUB_StartSpeedBoost()
    end
    
    if OPAIHUB_VoidRushOverrideEnabled then
        OPAIHUB_StartVoidRushOverride()
    end
    
    if OPAIHUB_InfiniteStaminaEnabled then
        OPAIHUB_StartInfiniteStamina()
    end
    
    if OPAIHUB_AdvancedMovementEnabled then
        OPAIHUB_StartAdvancedMovement()
    end
    
    if OPAIHUB_NoliVoidRushBypassEnabled then
        OPAIHUB_StartNoliVoidRushBypass()
    end
    
    if OPAIHUB_AimbotAntiDetectionEnabled then
        OPAIHUB_ApplyAimbotAntiDetection(OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    end
    
    -- 重新设置自瞄连接
    if OPAIHUB_ChanceAimbotEnabled and OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name == "Chance" then
        local OPAIHUB_RemoteEvent = OPAIHUB_ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
        if OPAIHUB_ChanceAimbotConnection then
            OPAIHUB_ChanceAimbotConnection:Disconnect()
        end
        OPAIHUB_ChanceAimbotConnection = OPAIHUB_RemoteEvent.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] == "UseActorAbility" and args[2] == "Shoot" then 
                local killerContainer = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
                if killerContainer then 
                    local killer = killerContainer:FindFirstChildOfClass("Model")
                    if killer and killer:FindFirstChild("HumanoidRootPart") then 
                        local killerHRP = killer.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if playerHRP then 
                            local distance = (killerHRP.Position - playerHRP.Position).Magnitude
                            if distance <= OPAIHUB_ChanceMaxDistance then
                                local TMP = 0.35
                                local AMD = 2
                                local endTime = tick() + AMD
                                while tick() < endTime do
                                    OPAIHUB_RunService.RenderStepped:Wait()
                                    OPAIHUB_LocalPlayer.Character.HumanoidRootPart.CFrame = killerHRP.CFrame + Vector3.new(0, 0, -2)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    
    if OPAIHUB_TwoTimeAimbotEnabled and OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name == "TwoTime" then
        if OPAIHUB_TwoTimeAimbotConnection then
            OPAIHUB_TwoTimeAimbotConnection:Disconnect()
        end
        local OPAIHUB_TWOsounds = {
            "rbxassetid://86710781315432",
            "rbxassetid://99820161736138"
        }
        OPAIHUB_TwoTimeAimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
            if not OPAIHUB_TwoTimeAimbotEnabled then return end
            for _, v in pairs(OPAIHUB_TWOsounds) do
                if child.Name == v then
                    local survivors = {}
                    for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                        if player ~= OPAIHUB_LocalPlayer then
                            local character = player.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                table.insert(survivors, character)
                            end
                        end
                    end
                    
                    local nearestSurvivor = nil
                    local shortestDistance = math.huge
                    
                    for _, survivor in pairs(survivors) do
                        local survivorHRP = survivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                            if distance < shortestDistance and distance <= OPAIHUB_TwoTimeMaxDistance then
                                shortestDistance = distance
                                nearestSurvivor = survivor
                            end
                        end
                    end
                    
                    if nearestSurvivor then
                        local nearestHRP = nearestSurvivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local num = 1
                            local maxIterations = 100
                            
                            if child.Name == "rbxassetid://79782181585087" then
                                maxIterations = 220
                            end
                            
                            while num <= maxIterations do
                                task.wait(0.01)
                                num = num + 1
                                OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                            end
                        end
                    end
                end
            end
        end)
    end
    
    if OPAIHUB_ShedletskyAimbotEnabled and OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name == "Shedletsky" then
        if OPAIHUB_ShedletskyAimbotConnection then
            OPAIHUB_ShedletskyAimbotConnection:Disconnect()
        end
        if OPAIHUB_LocalPlayer.Character:FindFirstChild("Sword") then
            OPAIHUB_ShedletskyAimbotConnection = OPAIHUB_LocalPlayer.Character.Sword.ChildAdded:Connect(function(child)
                if not OPAIHUB_ShedletskyAimbotEnabled then return end
                if child:IsA("Sound") then 
                    local FAN = child.Name
                    if FAN == "rbxassetid://12222225" or FAN == "83851356262523" then 
                        local killersFolder = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
                        if killersFolder then 
                            local killer = killersFolder:FindFirstChildOfClass("Model")
                            if killer and killer:FindFirstChild("HumanoidRootPart") then 
                                local killerHRP = killer.HumanoidRootPart
                                local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if playerHRP then 
                                    local distance = (killerHRP.Position - playerHRP.Position).Magnitude
                                    if distance <= OPAIHUB_ShedletskyMaxDistance then
                                        local num = 1
                                        local maxIterations = 100
                                        while num <= maxIterations do
                                            task.wait(0.01)
                                            num = num + 1
                                            OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, killerHRP.Position)
                                            playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, killerHRP.Position)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    
    if OPAIHUB_X1X4AimbotEnabled and OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name == "1x1x1x1" then
        if OPAIHUB_X1X4AimbotConnection then
            OPAIHUB_X1X4AimbotConnection:Disconnect()
        end
        local OPAIHUB_X1X4Sounds = {
            "rbxassetid://86710781315432",
            "rbxassetid://99820161736138"
        }
        OPAIHUB_X1X4AimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
            if not OPAIHUB_X1X4AimbotEnabled then return end
            for _, v in pairs(OPAIHUB_X1X4Sounds) do
                if child.Name == v then
                    local survivors = {}
                    for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                        if player ~= OPAIHUB_LocalPlayer then
                            local character = player.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                table.insert(survivors, character)
                            end
                        end
                    end
                    
                    local nearestSurvivor = nil
                    local shortestDistance = math.huge
                    
                    for _, survivor in pairs(survivors) do
                        local survivorHRP = survivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                            if distance < shortestDistance and distance <= OPAIHUB_X1X4MaxDistance then
                                shortestDistance = distance
                                nearestSurvivor = survivor
                            end
                        end
                    end
                    
                    if nearestSurvivor then
                        local nearestHRP = nearestSurvivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local num = 1
                            local maxIterations = 100
                            
                            while num <= maxIterations do
                                task.wait(0.01)
                                num = num + 1
                                OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                            end
                        end
                    end
                end
            end
        end)
    end
    
    if OPAIHUB_CoolAimbotEnabled and OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name == "c00lkidd" then
        if OPAIHUB_CoolAimbotConnection then
            OPAIHUB_CoolAimbotConnection:Disconnect()
        end
        local OPAIHUB_CoolSounds = {
            "rbxassetid://86710781315432",
            "rbxassetid://99820161736138"
        }
        OPAIHUB_CoolAimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
            if not OPAIHUB_CoolAimbotEnabled then return end
            for _, v in pairs(OPAIHUB_CoolSounds) do
                if child.Name == v then
                    local survivors = {}
                    for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                        if player ~= OPAIHUB_LocalPlayer then
                            local character = player.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                table.insert(survivors, character)
                            end
                        end
                    end
                    
                    local nearestSurvivor = nil
                    local shortestDistance = math.huge
                    
                    for _, survivor in pairs(survivors) do
                        local survivorHRP = survivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                            if distance < shortestDistance and distance <= OPAIHUB_CoolMaxDistance then
                                shortestDistance = distance
                                nearestSurvivor = survivor
                            end
                        end
                    end
                    
                    if nearestSurvivor then
                        local nearestHRP = nearestSurvivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local num = 1
                            local maxIterations = 100
                            
                            while num <= maxIterations do
                                task.wait(0.01)
                                num = num + 1
                                OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                            end
                        end
                    end
                end
            end
        end)
    end
    
    if OPAIHUB_JohnAimbotEnabled and OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name == "JohnDoe" then
        if OPAIHUB_JohnAimbotConnection then
            OPAIHUB_JohnAimbotConnection:Disconnect()
        end
        local OPAIHUB_JohnSounds = {
            "rbxassetid://86710781315432",
            "rbxassetid://99820161736138"
        }
        OPAIHUB_JohnAimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
            if not OPAIHUB_JohnAimbotEnabled then return end
            for _, v in pairs(OPAIHUB_JohnSounds) do
                if child.Name == v then
                    local survivors = {}
                    for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                        if player ~= OPAIHUB_LocalPlayer then
                            local character = player.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                table.insert(survivors, character)
                            end
                        end
                    end
                    
                    local nearestSurvivor = nil
                    local shortestDistance = math.huge
                    
                    for _, survivor in pairs(survivors) do
                        local survivorHRP = survivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                            if distance < shortestDistance and distance <= OPAIHUB_JohnMaxDistance then
                                shortestDistance = distance
                                nearestSurvivor = survivor
                            end
                        end
                    end
                    
                    if nearestSurvivor then
                        local nearestHRP = nearestSurvivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local num = 1
                            local maxIterations = 100
                            
                            while num <= maxIterations do
                                task.wait(0.01)
                                num = num + 1
                                OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                            end
                        end
                    end
                end
            end
        end)
    end
    
    if OPAIHUB_JasonAimbotEnabled and OPAIHUB_LocalPlayer.Character and OPAIHUB_LocalPlayer.Character.Name == "Jason" then
        if OPAIHUB_JasonAimbotConnection then
            OPAIHUB_JasonAimbotConnection:Disconnect()
        end
        local OPAIHUB_JasonSounds = {
            "rbxassetid://86710781315432",
            "rbxassetid://99820161736138"
        }
        OPAIHUB_JasonAimbotConnection = OPAIHUB_LocalPlayer.Character.HumanoidRootPart.ChildAdded:Connect(function(child)
            if not OPAIHUB_JasonAimbotEnabled then return end
            for _, v in pairs(OPAIHUB_JasonSounds) do
                if child.Name == v then
                    local survivors = {}
                    for _, player in pairs(OPAIHUB_Players:GetPlayers()) do
                        if player ~= OPAIHUB_LocalPlayer then
                            local character = player.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                table.insert(survivors, character)
                            end
                        end
                    end
                    
                    local nearestSurvivor = nil
                    local shortestDistance = math.huge
                    
                    for _, survivor in pairs(survivors) do
                        local survivorHRP = survivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local distance = (survivorHRP.Position - playerHRP.Position).Magnitude
                            if distance < shortestDistance and distance <= OPAIHUB_JasonMaxDistance then
                                shortestDistance = distance
                                nearestSurvivor = survivor
                            end
                        end
                    end
                    
                    if nearestSurvivor then
                        local nearestHRP = nearestSurvivor.HumanoidRootPart
                        local playerHRP = OPAIHUB_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if playerHRP then
                            local num = 1
                            local maxIterations = 100
                            
                            while num <= maxIterations do
                                task.wait(0.01)
                                num = num + 1
                                OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(OPAIHUB_Workspace.CurrentCamera.CFrame.Position, nearestHRP.Position)
                                playerHRP.CFrame = CFrame.lookAt(playerHRP.Position, Vector3.new(nearestHRP.Position.X, nearestHRP.Position.Y, nearestHRP.Position.Z))
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- 玩家离开时清理
OPAIHUB_LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not OPAIHUB_LocalPlayer.Parent then
        OPAIHUB_StopSpeedBoost()
        OPAIHUB_StopVoidRushOverride()
        OPAIHUB_StopInfiniteStamina()
        OPAIHUB_StopAdvancedMovement()
        OPAIHUB_StopPopupBypass()
        OPAIHUB_StopNoliVoidRushBypass()
        
        if OPAIHUB_AutoBlockConnection then
            OPAIHUB_AutoBlockConnection:Disconnect()
            OPAIHUB_AutoBlockConnection = nil
        end
        
        if OPAIHUB_AutoRepairTask then
            task.cancel(OPAIHUB_AutoRepairTask)
            OPAIHUB_AutoRepairTask = nil
        end
        
        if OPAIHUB_TeleportMedkitThread then
            task.cancel(OPAIHUB_TeleportMedkitThread)
            OPAIHUB_TeleportMedkitThread = nil
        end
        
        if OPAIHUB_TeleportColaThread then
            task.cancel(OPAIHUB_TeleportColaThread)
            OPAIHUB_TeleportColaThread = nil
        end
        
        if OPAIHUB_FlipCoinsThread then
            task.cancel(OPAIHUB_FlipCoinsThread)
            OPAIHUB_FlipCoinsThread = nil
        end
        
        if OPAIHUB_ChanceAimbotConnection then
            OPAIHUB_ChanceAimbotConnection:Disconnect()
            OPAIHUB_ChanceAimbotConnection = nil
        end
        
        if OPAIHUB_TwoTimeAimbotConnection then
            OPAIHUB_TwoTimeAimbotConnection:Disconnect()
            OPAIHUB_TwoTimeAimbotConnection = nil
        end
        
        if OPAIHUB_ShedletskyAimbotConnection then
            OPAIHUB_ShedletskyAimbotConnection:Disconnect()
            OPAIHUB_ShedletskyAimbotConnection = nil
        end
        
        if OPAIHUB_X1X4AimbotConnection then
            OPAIHUB_X1X4AimbotConnection:Disconnect()
            OPAIHUB_X1X4AimbotConnection = nil
        end
        
        if OPAIHUB_CoolAimbotConnection then
            OPAIHUB_CoolAimbotConnection:Disconnect()
            OPAIHUB_CoolAimbotConnection = nil
        end
        
        if OPAIHUB_JohnAimbotConnection then
            OPAIHUB_JohnAimbotConnection:Disconnect()
            OPAIHUB_JohnAimbotConnection = nil
        end
        
        if OPAIHUB_JasonAimbotConnection then
            OPAIHUB_JasonAimbotConnection:Disconnect()
            OPAIHUB_JasonAimbotConnection = nil
        end
        
        if OPAIHUB_JohnDoeAuto404Connection then
            OPAIHUB_JohnDoeAuto404Connection:Disconnect()
            OPAIHUB_JohnDoeAuto404Connection = nil
        end
    end
end)

-- 窗口聚焦时重新应用设置
OPAIHUB_UserInputService.WindowFocused:Connect(function()
    if OPAIHUB_InfiniteStaminaEnabled then
        OPAIHUB_ModifyStaminaSettings()
    end
end)

OPAIHUB_Library:Notify("OPAIHUB已加载", "OPAI团队反作弊绕过系统已就绪", 5)

-- 保存配置
OPAIHUB_ThemeManager:SetLibrary(OPAIHUB_Library)
OPAIHUB_SaveManager:SetLibrary(OPAIHUB_Library)
OPAIHUB_SaveManager:IgnoreThemeSettings()
OPAIHUB_SaveManager:SetIgnoreIndexes({})
OPAIHUB_ThemeManager:SetFolder("OPAIHUB")
OPAIHUB_SaveManager:SetFolder("OPAIHUB/specific-game")
OPAIHUB_ThemeManager:ApplyTheme()
OPAIHUB_SaveManager:LoadAutosave()

