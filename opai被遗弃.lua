--[[
    OPAIHUB - 手机优化版
    作者: OPAI团队
    版本: 2.0 Mobile
    描述: 被遗弃游戏的综合反作弊绕过系统（手机优化）
    版权所有 - OPAI团队
    QQ群: 154919631
]]

-- 加载动画
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))();
Compkiller:Loader("rbxassetid://97914301936069", 2.5).yield();

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

-- 自动检测设备类型
local function OPAIHUB_IsMobile()
    return OPAIHUB_UserInputService.TouchEnabled and not OPAIHUB_UserInputService.KeyboardEnabled
end

local OPAIHUB_IsMobileDevice = OPAIHUB_IsMobile()
local OPAIHUB_DeviceType = OPAIHUB_IsMobileDevice and "手机" or "电脑"

-- 根据设备自动配置UI
OPAIHUB_Library.ShowToggleFrameInKeybinds = not OPAIHUB_IsMobileDevice
OPAIHUB_Library.ShowCustomCursor = not OPAIHUB_IsMobileDevice
OPAIHUB_Library.NotifySide = "Right"

-- 自动适配窗口
local OPAIHUB_Window = OPAIHUB_Library:CreateWindow({
    Title = 'OPAI被遗弃 [' .. OPAIHUB_DeviceType .. ']',
    Footer = "OPAI团队 | 智能适配",
    Icon = 106397684977541,
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = not OPAIHUB_IsMobileDevice,
    NotifySide = "Right",
    TabPadding = OPAIHUB_IsMobileDevice and 4 or 8,
    MenuFadeTime = OPAIHUB_IsMobileDevice and 0.1 or 0.2,
    Size = OPAIHUB_IsMobileDevice and UDim2.new(0, 480, 0, 580) or UDim2.new(0, 580, 0, 680)
})

-- 查找并保存窗口的ScreenGui引用
task.spawn(function()
    task.wait(0.5)
    local coreGui = game:GetService("CoreGui")
    -- 方法1: 查找最新的ScreenGui（通常是最后创建的）
    local allGuis = {}
    for _, gui in ipairs(coreGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            table.insert(allGuis, gui)
        end
    end
    -- 使用最新的GUI（通常是我们的窗口）
    if #allGuis > 0 then
        _G.OPAIHUB_WindowGui = allGuis[#allGuis]
    end
    
    -- 方法2: 通过内容查找
    if not _G.OPAIHUB_WindowGui then
        for _, gui in ipairs(coreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc.Name:find("OPAI") or desc.Name:find("被遗弃") or desc.Name:find("Obsidian") or desc.Text == "OPAI被遗弃" then
                        _G.OPAIHUB_WindowGui = gui
                        break
                    end
                end
                if _G.OPAIHUB_WindowGui then break end
            end
        end
    end
end)

-- 精简分区（6个标签）
local OPAIHUB_Tabs = {
    -- 核心（3个）
    Main = OPAIHUB_Window:AddTab('主页','house'),
    AntiLoophole = OPAIHUB_Window:AddTab('反作弊','shield'),
    Teleport = OPAIHUB_Window:AddTab('传送','move'),
    
    -- 功能（1个）
    Auto = OPAIHUB_Window:AddTab('自动功能','repeat'),
    
    -- 其他（2个）
    ESP = OPAIHUB_Window:AddTab('透视','eye'),
    Visual = OPAIHUB_Window:AddTab('辅助','settings'),
    
    -- 兼容性映射（全部删除的标签）
    Survivor = nil,     -- 已删除
    Killer = nil,       -- 已删除
    Killing = nil,      -- 已删除
    Aimbot = nil,
    KillerAimbot = nil,
    Action = nil,
    Test = nil,
    SurvivorESP = nil,
    Movement = nil,
    Combat = nil,
    Notify = nil,
    Pizza = nil,
    Skin = nil
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

OPAIHUB_MainGroup:AddToggle("OPAIHUB_ShowChat", {
    Text = "显示聊天框",
    Default = false,
    Tooltip = "显示聊天框（需要每局开一次）",
    Callback = function(v)
        if v then
            game:GetService("TextChatService").ChatWindowConfiguration.Enabled = true
            OPAIHUB_Library:Notify("聊天框已启用", "聊天框已显示", 3)
        else
            game:GetService("TextChatService").ChatWindowConfiguration.Enabled = false
            OPAIHUB_Library:Notify("聊天框已关闭", "聊天框已隐藏", 3)
        end
    end
})

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
local OPAIHUB_MovementGroup = OPAIHUB_Tabs.AntiLoophole:AddLeftGroupbox("OPAIHUB 移动绕过")

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
local OPAIHUB_CombatGroup = OPAIHUB_Tabs.AntiLoophole:AddRightGroupbox("OPAIHUB 战斗绕过")

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

-- 吸附杀戮光环设置
local OPAIHUB_HitboxDistance = 3  -- 吸附距离（米）
local OPAIHUB_HitboxTrackingEnabled = false

OPAIHUB_CombatGroup:AddSlider("OPAIHUB_HitboxDistanceSlider", {
    Text = "吸附距离",
    Min = 1,
    Max = 10,
    Default = 3,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_HitboxDistance = value
    end
})

OPAIHUB_CombatGroup:AddDivider()

-- 吸附杀戮光环（杀手攻击时自动吸附）
if not _G.OPAIHUB_HitboxTracking then
    _G.OPAIHUB_HitboxTracking = {
        Connection = nil,
        Active = false
    }
end

local OPAIHUB_AttackAnimations = {
    'rbxassetid://131430497821198', -- MassInfection, 1x1x1x1
    'rbxassetid://83829782357897', -- Slash, 1x1x1x1
    'rbxassetid://126830014841198', -- Slash, Jason
    'rbxassetid://126355327951215', -- Behead, Jason
    'rbxassetid://121086746534252', -- GashingWoundStart, Jason
    'rbxassetid://105458270463374', -- Slash, JohnDoe
    'rbxassetid://127172483138092', -- CorruptEnergy, JohnDoe
    'rbxassetid://18885919947', -- CorruptNature, c00lkidd
    'rbxassetid://18885909645', -- Attack, c00lkidd
    'rbxassetid://87259391926321', -- ParryPunch, Guest1337
    'rbxassetid://106014898528300', -- Charge, Guest1337
    'rbxassetid://86545133269813', -- Stab, TwoTime
    'rbxassetid://89448354637442', -- LungeStart, TwoTime
    'rbxassetid://90499469533503', -- GunFire, Chance
    'rbxassetid://116618003477002', -- Slash, Shedletsky
    'rbxassetid://106086955212611', -- Stab, TwoTime, Skin: PhilosopherTwotime
    'rbxassetid://107640065977686', -- LungeStart, TwoTime, Skin: PhilosopherTwotime
    'rbxassetid://77124578197357', -- GunFire, Chance, Skin: OutlawChance
    'rbxassetid://101771617803133', -- GunFire, Chance, Skin: #CassidyChance
    'rbxassetid://134958187822107', -- GunFire, Chance, Skin: RetroChance
    'rbxassetid://111313169447787', -- GunFire, Chance, Skin: MLGChance
    'rbxassetid://71685573690338', -- GunFire, Chance, Skin: Milestone100Chance
    'rbxassetid://129843313690921', -- ParryPunch, Guest1337, Skin: #NerfedDemomanGuest
    'rbxassetid://97623143664485', -- Charge, Guest1337, Skin: #NerfedDemomanGuest
    'rbxassetid://136007065400978', -- ParryPunch, Guest1337, Skin: LittleBrotherGuest
    'rbxassetid://86096387000557', -- ParryPunch, Guest1337, Skin: Milestone100Guest
    'rbxassetid://108807732150251', -- ParryPunch, Guest1337, Skin: GreenbeltGuest
    'rbxassetid://138040001965654', -- Punch, Guest1337, Skin: GreenbeltGuest
    'rbxassetid://73502073176819', -- Charge, Guest1337, Skin: GreenbeltGuest
    'rbxassetid://86709774283672', -- ParryPunch, Guest1337, Skin: SorcererGuest
    'rbxassetid://140703210927645', -- ParryPunch, Guest1337, Skin: DragonGuest
    'rbxassetid://96173857867228', -- Charge, Guest1337, Skin: AllyGuest
    'rbxassetid://121255898612475', -- Slash, Shedletsky, Skin: RetroShedletsky
    'rbxassetid://98031287364865', -- Slash, Shedletsky, Skin: BrightEyesShedletsky
    'rbxassetid://119462383658044', -- Slash, Shedletsky, Skin: NessShedletsky
    'rbxassetid://77448521277146', -- Slash, Shedletsky, Skin: Milestone100Shedletsky
    'rbxassetid://103741352379819', -- Slash, Shedletsky, Skin: #RolandShedletsky
    'rbxassetid://131696603025265', -- Slash, Shedletsky, Skin: JamesSunderlandShedletsky
    'rbxassetid://122503338277352', -- Slash, Shedletsky, Skin: SkiesShedletsky
    'rbxassetid://97648548303678', -- Slash, Shedletsky, Skin: #JohnWardShedletsky
    'rbxassetid://94162446513587', -- Slash, JohnDoe, Skin: !Joner
    'rbxassetid://84426150435898' -- CorruptEnergy, JohnDoe, Skin: !Joner
}

OPAIHUB_CombatGroup:AddToggle("OPAIHUB_HitboxTracking", {
    Text = "吸附杀戮光环",
    Tooltip = "攻击时全图追踪幸存者碰撞箱，持续对准确保准星准确（杀手专用）",
    Default = false,
    Callback = function(state)
        if not state then
            if _G.OPAIHUB_HitboxTracking.Connection then
                _G.OPAIHUB_HitboxTracking.Connection:Disconnect()
                _G.OPAIHUB_HitboxTracking.Connection = nil
            end
            _G.OPAIHUB_HitboxTracking.Active = false
            OPAIHUB_Library:Notify("吸附杀戮光环已关闭", "停止碰撞箱追踪", 3)
            return
        end

        repeat task.wait() until game:IsLoaded()

        local Character = OPAIHUB_LocalPlayer.Character or OPAIHUB_LocalPlayer.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

        OPAIHUB_LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
            Character = NewCharacter
            Humanoid = Character:WaitForChild("Humanoid")
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        end)

        local function OPAIHUB_IsAttackAnimation(animationId)
            for _, attackAnim in ipairs(OPAIHUB_AttackAnimations) do
                if animationId == attackAnim then
                    return true
                end
            end
            return false
        end

        local function OPAIHUB_GetNearestPlayer()
            local nearestPlayer = nil
            local shortestDistance = math.huge

            local survivorsFolder = OPAIHUB_Workspace:FindFirstChild("Players") and OPAIHUB_Workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return nil end

            for _, survivor in ipairs(survivorsFolder:GetChildren()) do
                if typeof(survivor) == "Instance" and survivor:IsA("Model") and survivor ~= Character then
                    local targetHRP = survivor:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = survivor:FindFirstChildOfClass("Humanoid")

                    if targetHRP and targetHumanoid and targetHumanoid.Health > 0 then
                        local distance = (HumanoidRootPart.Position - targetHRP.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            nearestPlayer = survivor
                        end
                    end
                end
            end

            return nearestPlayer, shortestDistance
        end

        _G.OPAIHUB_HitboxTracking.Active = true
        _G.OPAIHUB_HitboxTracking.Connection = OPAIHUB_RunService.Heartbeat:Connect(function()
            if not _G.OPAIHUB_HitboxTracking.Active then return end
            if not Humanoid or not HumanoidRootPart then return end

            local isPlayingAttackAnim = false
            for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
                if OPAIHUB_IsAttackAnimation(track.Animation.AnimationId) then
                    isPlayingAttackAnim = true
                    break
                end
            end

            if isPlayingAttackAnim then
                local nearestPlayer, distance = OPAIHUB_GetNearestPlayer()
                
                -- 全图范围，无距离限制
                if nearestPlayer then
                    local targetHRP = nearestPlayer:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        -- 吸附到幸存者身边（可调节距离）
                        local direction = (targetHRP.Position - HumanoidRootPart.Position).Unit
                        local targetPosition = targetHRP.Position - (direction * OPAIHUB_HitboxDistance)
                        
                        -- 持续追踪：位置和视角都对准幸存者
                        HumanoidRootPart.CFrame = CFrame.new(targetPosition, targetHRP.Position)
                        
                        -- 同时调整相机视角对准幸存者（确保准星对准）
                        if OPAIHUB_Workspace.CurrentCamera then
                            OPAIHUB_Workspace.CurrentCamera.CFrame = CFrame.new(
                                OPAIHUB_Workspace.CurrentCamera.CFrame.Position,
                                targetHRP.Position
                            )
                        end
                    end
                end
            end
        end)

        OPAIHUB_Library:Notify("吸附杀戮光环已启用", "攻击时全图追踪幸存者（持续对准）", 3)
    end
})

OPAIHUB_CombatGroup:AddLabel("提示: 杀戮光环在攻击动画播放时生效，全图范围持续追踪")

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
        
        -- 先定义创建函数（被更新函数引用）
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
        
        -- 定义更新函数（更新进度和距离）
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
                local currentTime = tick()
                if currentTime - OPAIHUB_LastBlockTime >= OPAIHUB_BlockCooldown then
                    OPAIHUB_RemoteEvent:FireServer("UseActorAbility", "Block")
                    OPAIHUB_LastBlockTime = currentTime
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
-- ============================================
-- OPAIHUB 高级ESP功能
-- ============================================

-- 2D方框ESP
local OPAIHUB_ESP2DBoxGroup = OPAIHUB_Tabs.ESP:AddRightGroupbox("OPAIHUB 2D方框ESP")

local OPAIHUB_SurvivorESPConnection = nil
local OPAIHUB_SurvivorAddedConnection = nil
local OPAIHUB_KillerESPConnection = nil
local OPAIHUB_KillerAddedConnection = nil

OPAIHUB_ESP2DBoxGroup:AddToggle("OPAIHUB_Survivor2DBox", {
    Text = "绘制幸存者方框",
    Default = false,
    Callback = function(v)
        if v then
            local survivorsFolder = OPAIHUB_Workspace:WaitForChild("Players"):WaitForChild("Survivors")
            
            local function OPAIHUB_CreateSurvivorESP(model, color)
                if not model:IsA("Model") then return end
                if model == OPAIHUB_LocalPlayer.Character then return end
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                if hrp:FindFirstChild("OPAIHUB_playeresp") then return end
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "OPAIHUB_playeresp"
                billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                billboard.Active = true
                billboard.AlwaysOnTop = true
                billboard.LightInfluence = 1.000
                billboard.Size = UDim2.new(3, 0, 5, 0)
                billboard.Adornee = hrp
                billboard.Parent = hrp
                
                local frame = Instance.new("Frame")
                frame.Name = "playershow"
                frame.BackgroundColor3 = Color3.fromRGB(255, 25, 25)
                frame.BackgroundTransparency = 1
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.Parent = billboard
                
                local stroke = Instance.new("UIStroke")
                stroke.Color = color
                stroke.Thickness = 2
                stroke.Transparency = 0.2
                stroke.Parent = frame
            end
            
            OPAIHUB_SurvivorESPConnection = OPAIHUB_RunService.RenderStepped:Connect(function()
                for _, survivor in ipairs(survivorsFolder:GetChildren()) do
                    OPAIHUB_CreateSurvivorESP(survivor, Color3.fromRGB(0, 255, 0))
                end
            end)
            
            OPAIHUB_SurvivorAddedConnection = survivorsFolder.ChildAdded:Connect(function(survivor)
                OPAIHUB_CreateSurvivorESP(survivor, Color3.fromRGB(0, 255, 0))
            end)
        else
            if OPAIHUB_SurvivorESPConnection then
                OPAIHUB_SurvivorESPConnection:Disconnect()
                OPAIHUB_SurvivorESPConnection = nil
            end
            if OPAIHUB_SurvivorAddedConnection then
                OPAIHUB_SurvivorAddedConnection:Disconnect()
                OPAIHUB_SurvivorAddedConnection = nil
            end
            
            local survivorsFolder = OPAIHUB_Workspace:WaitForChild("Players"):WaitForChild("Survivors")
            for _, survivor in ipairs(survivorsFolder:GetChildren()) do
                if survivor:IsA("Model") then
                    local hrp = survivor:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:FindFirstChild("OPAIHUB_playeresp") then
                        hrp.OPAIHUB_playeresp:Destroy()
                    end
                end
            end
        end
    end
})

OPAIHUB_ESP2DBoxGroup:AddToggle("OPAIHUB_Killer2DBox", {
    Text = "绘制杀手方框",
    Default = false,
    Callback = function(v)
        if v then
            local killersFolder = OPAIHUB_Workspace:WaitForChild("Players"):WaitForChild("Killers")
            
            local function OPAIHUB_CreateKillerESP(model, color)
                if not model:IsA("Model") then return end
                if model == OPAIHUB_LocalPlayer.Character then return end
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                if hrp:FindFirstChild("OPAIHUB_playeresp") then return end
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "OPAIHUB_playeresp"
                billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                billboard.Active = true
                billboard.AlwaysOnTop = true
                billboard.LightInfluence = 1.000
                billboard.Size = UDim2.new(3, 0, 5, 0)
                billboard.Adornee = hrp
                billboard.Parent = hrp
                
                local frame = Instance.new("Frame")
                frame.Name = "playershow"
                frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                frame.BackgroundTransparency = 1
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.Parent = billboard
                
                local stroke = Instance.new("UIStroke")
                stroke.Color = color
                stroke.Thickness = 2
                stroke.Transparency = 0.2
                stroke.Parent = frame
            end
            
            OPAIHUB_KillerESPConnection = OPAIHUB_RunService.RenderStepped:Connect(function()
                for _, killer in ipairs(killersFolder:GetChildren()) do
                    OPAIHUB_CreateKillerESP(killer, Color3.fromRGB(255, 0, 0))
                end
            end)
            
            OPAIHUB_KillerAddedConnection = killersFolder.ChildAdded:Connect(function(killer)
                OPAIHUB_CreateKillerESP(killer, Color3.fromRGB(255, 0, 0))
            end)
        else
            if OPAIHUB_KillerESPConnection then
                OPAIHUB_KillerESPConnection:Disconnect()
                OPAIHUB_KillerESPConnection = nil
            end
            if OPAIHUB_KillerAddedConnection then
                OPAIHUB_KillerAddedConnection:Disconnect()
                OPAIHUB_KillerAddedConnection = nil
            end
            
            local killersFolder = OPAIHUB_Workspace:WaitForChild("Players"):WaitForChild("Killers")
            for _, killer in ipairs(killersFolder:GetChildren()) do
                if killer:IsA("Model") then
                    local hrp = killer:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp:FindFirstChild("OPAIHUB_playeresp") then
                        hrp.OPAIHUB_playeresp:Destroy()
                    end
                end
            end
        end
    end
})

-- ============================================
-- OPAIHUB 披萨功能
-- ============================================

local OPAIHUB_PizzaGroup = OPAIHUB_Tabs.Visual:AddLeftGroupbox("OPAIHUB 自动吃披萨")

local OPAIHUB_PizzaConnection = nil
local OPAIHUB_PizzaTPConnection = nil
local OPAIHUB_PizzaEffects = {}
local OPAIHUB_HealthEatPizza = 50

local function OPAIHUB_CreatePizzaEffect(pizza, effectName)
    if not pizza:FindFirstChild(effectName) then
        local effect = Instance.new("ParticleEmitter")
        effect.Name = effectName
        effect.Texture = "rbxassetid://242487987"
        effect.LightEmission = 0.8
        effect.Size = NumberSequence.new(0.5)
        if effectName == "TeleportEffect" then
            effect.Lifetime = NumberRange.new(0.5)
        end
        effect.Parent = pizza
        OPAIHUB_PizzaEffects[pizza] = effect
        return effect
    end
    return OPAIHUB_PizzaEffects[pizza]
end

local function OPAIHUB_CleanUpPizzaEffects()
    for pizza, effect in pairs(OPAIHUB_PizzaEffects) do
        if not pizza or not pizza.Parent then
            effect:Destroy()
            OPAIHUB_PizzaEffects[pizza] = nil
        end
    end
end

local function OPAIHUB_FindClosestPizza(rootPart)
    local pizzaFolder = OPAIHUB_Workspace:FindFirstChild("Pizzas") or OPAIHUB_Workspace:FindFirstChild("Map")
    if not pizzaFolder then return nil end
    
    local closestPizza, closestDistance = nil, math.huge
    for _, pizza in ipairs(pizzaFolder:GetDescendants()) do
        if typeof(pizza) == "Instance" and pizza:IsA("BasePart") and pizza.Name == "Pizza" then
            local distance = (rootPart.Position - pizza.Position).Magnitude
            if distance < closestDistance then
                closestPizza = pizza
                closestDistance = distance
            end
        end
    end
    return closestPizza
end

OPAIHUB_PizzaGroup:AddToggle("OPAIHUB_AutoEatPizza", {
    Text = "自动吃披萨(追踪传送)",
    Default = false,
    Tooltip = "当生命值低于设定值时自动吸引附近的披萨",
    Callback = function(enabled)
        if OPAIHUB_PizzaConnection then
            OPAIHUB_PizzaConnection:Disconnect()
            OPAIHUB_PizzaConnection = nil
        end
        
        if enabled then
            OPAIHUB_PizzaConnection = OPAIHUB_RunService.Heartbeat:Connect(function()
                local character = OPAIHUB_LocalPlayer.Character
                if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local humanoid = character.Humanoid
                local rootPart = character.HumanoidRootPart
                
                if OPAIHUB_HealthEatPizza and humanoid.Health >= OPAIHUB_HealthEatPizza then
                    return
                end
                
                local closestPizza = OPAIHUB_FindClosestPizza(rootPart)
                if closestPizza then
                    closestPizza.CFrame = closestPizza.CFrame:Lerp(
                        rootPart.CFrame * CFrame.new(0, 0, -2),
                        0.5
                    )
                    OPAIHUB_CreatePizzaEffect(closestPizza, "AttractEffect")
                end
                OPAIHUB_CleanUpPizzaEffects()
            end)
        end
    end
})

OPAIHUB_PizzaGroup:AddToggle("OPAIHUB_AutoTeleportPizza", {
    Text = "自动吃披萨(TP)",
    Default = false,
    Tooltip = "当生命值低于设定值时自动将最近的披萨传送到玩家",
    Callback = function(enabled)
        if OPAIHUB_PizzaTPConnection then
            OPAIHUB_PizzaTPConnection:Disconnect()
            OPAIHUB_PizzaTPConnection = nil
        end
        
        if enabled then
            OPAIHUB_PizzaTPConnection = OPAIHUB_RunService.Heartbeat:Connect(function()
                local character = OPAIHUB_LocalPlayer.Character
                if not character or not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                
                local humanoid = character.Humanoid
                local rootPart = character.HumanoidRootPart
                
                if OPAIHUB_HealthEatPizza and humanoid.Health >= OPAIHUB_HealthEatPizza then
                    return
                end
                
                local closestPizza = OPAIHUB_FindClosestPizza(rootPart)
                if closestPizza then
                    closestPizza.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2)
                    local effect = OPAIHUB_CreatePizzaEffect(closestPizza, "TeleportEffect")
                    task.delay(1, function()
                        if effect and effect.Parent then
                            effect:Destroy()
                            OPAIHUB_PizzaEffects[closestPizza] = nil
                        end
                    end)
                end
                OPAIHUB_CleanUpPizzaEffects()
            end)
        end
    end
})

OPAIHUB_PizzaGroup:AddDivider()

OPAIHUB_PizzaGroup:AddSlider("OPAIHUB_HealthEatPizza", {
    Text = "生命阈值",
    Default = 50,
    Min = 10,
    Max = 130,
    Rounding = 0,
    Tooltip = "当生命值低于设置生命值吃披萨",
    Callback = function(value)
        OPAIHUB_HealthEatPizza = value
    end
})

OPAIHUB_PizzaGroup:AddDivider()

OPAIHUB_PizzaGroup:AddButton("OPAIHUB_TPPizzaToFeet", {
    Text = "TP Pizza到脚下",
    Func = function()
        local character = OPAIHUB_LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            for _, pizza in ipairs(OPAIHUB_Workspace:GetDescendants()) do
                if typeof(pizza) == "Instance" and pizza:IsA("BasePart") and pizza.Name == "Pizza" then
                    pizza.CFrame = rootPart.CFrame
                    break
                end
            end
            OPAIHUB_Library:Notify("传送成功", "已将披萨传送到脚下", 3)
        end
    end
})

-- ============================================
-- OPAIHUB 高级ESP功能（续）
-- ============================================

-- 血量条绘制
local OPAIHUB_HealthBarGroup = OPAIHUB_Tabs.ESP:AddLeftGroupbox("OPAIHUB 血量条绘制")

local OPAIHUB_HealthBarSettings = {
    ShowSurvivorBars = true,
    ShowKillerBars = true,
    BarWidth = 100,
    BarHeight = 5,
    TextSize = 14,
    BarOffset = Vector2.new(0, -50),
    TextOffset = Vector2.new(0, -60),
    connection = nil,
    removedConnection = nil
}

local OPAIHUB_HealthBarColorPresets = {
    Survivor = {
        FullHealth = Color3.fromRGB(0, 255, 255),
        HalfHealth = Color3.fromRGB(0, 255, 0),
        LowHealth = Color3.fromRGB(255, 165, 0)
    },
    Killer = {
        FullHealth = Color3.fromRGB(255, 0, 0),
        HalfHealth = Color3.fromRGB(255, 165, 0),
        LowHealth = Color3.fromRGB(255, 255, 0)
    },
    Common = {
        Background = Color3.fromRGB(50, 50, 50),
        Outline = Color3.fromRGB(0, 0, 0),
        Text = Color3.fromRGB(255, 255, 255)
    }
}

local OPAIHUB_HealthBarDrawings = {}

local function OPAIHUB_CreateHealthBarDrawing()
    local drawing = {
        background = Drawing.new("Square"),
        bar = Drawing.new("Square"),
        outline = Drawing.new("Square"),
        text = Drawing.new("Text")
    }
    
    drawing.background.Thickness = 1
    drawing.background.Filled = true
    drawing.background.Color = OPAIHUB_HealthBarColorPresets.Common.Background
    
    drawing.bar.Thickness = 1
    drawing.bar.Filled = true
    
    drawing.outline.Thickness = 2
    drawing.outline.Filled = false
    drawing.outline.Color = OPAIHUB_HealthBarColorPresets.Common.Outline
    
    drawing.text.Center = true
    drawing.text.Outline = true
    drawing.text.Font = 2
    drawing.text.Color = OPAIHUB_HealthBarColorPresets.Common.Text
    
    return drawing
end

local function OPAIHUB_GetHealthColor(humanoid, isKiller)
    local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
    
    if isKiller then
        if healthPercent > 50 then
            return OPAIHUB_HealthBarColorPresets.Killer.FullHealth
        elseif healthPercent > 25 then
            return OPAIHUB_HealthBarColorPresets.Killer.HalfHealth
        else
            return OPAIHUB_HealthBarColorPresets.Killer.LowHealth
        end
    else
        if healthPercent > 75 then
            return OPAIHUB_HealthBarColorPresets.Survivor.FullHealth
        elseif healthPercent > 35 then
            return OPAIHUB_HealthBarColorPresets.Survivor.HalfHealth
        else
            return OPAIHUB_HealthBarColorPresets.Survivor.LowHealth
        end
    end
end

local function OPAIHUB_GetHeadPosition(character)
    local head = character:FindFirstChild("Head")
    if head then
        return head.Position + Vector3.new(0, 1.5, 0)
    end
    return character:GetPivot().Position
end

local function OPAIHUB_UpdateHealthBars()
    local camera = OPAIHUB_Workspace.CurrentCamera
    
    if OPAIHUB_HealthBarSettings.ShowSurvivorBars then
        local survivors = OPAIHUB_Workspace.Players:FindFirstChild("Survivors")
        if survivors then
            for _, survivor in ipairs(survivors:GetChildren()) do
                if typeof(survivor) == "Instance" and survivor:IsA("Model") and survivor ~= OPAIHUB_LocalPlayer.Character then
                    local humanoid = survivor:FindFirstChildOfClass("Humanoid")
                    
                    if humanoid then
                        if not OPAIHUB_HealthBarDrawings[survivor] then
                            OPAIHUB_HealthBarDrawings[survivor] = OPAIHUB_CreateHealthBarDrawing()
                        end
                        
                        local drawing = OPAIHUB_HealthBarDrawings[survivor]
                        local headPos = OPAIHUB_GetHeadPosition(survivor)
                        local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                        
                        if onScreen then
                            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                            local healthBarWidth = OPAIHUB_HealthBarSettings.BarWidth * (healthPercent / 100)
                            
                            local barPos = Vector2.new(
                                screenPos.X + OPAIHUB_HealthBarSettings.BarOffset.X - (OPAIHUB_HealthBarSettings.BarWidth / 2),
                                screenPos.Y + OPAIHUB_HealthBarSettings.BarOffset.Y
                            )
                            
                            drawing.background.Size = Vector2.new(OPAIHUB_HealthBarSettings.BarWidth, OPAIHUB_HealthBarSettings.BarHeight)
                            drawing.background.Position = barPos
                            drawing.background.Visible = true
                            
                            drawing.outline.Size = Vector2.new(OPAIHUB_HealthBarSettings.BarWidth, OPAIHUB_HealthBarSettings.BarHeight)
                            drawing.outline.Position = barPos
                            drawing.outline.Visible = true
                            
                            drawing.bar.Color = OPAIHUB_GetHealthColor(humanoid, false)
                            drawing.bar.Size = Vector2.new(healthBarWidth, OPAIHUB_HealthBarSettings.BarHeight)
                            drawing.bar.Position = barPos
                            drawing.bar.Visible = true
                            
                            drawing.text.Text = tostring(healthPercent) .. "%"
                            drawing.text.Size = OPAIHUB_HealthBarSettings.TextSize
                            drawing.text.Position = Vector2.new(
                                screenPos.X + OPAIHUB_HealthBarSettings.TextOffset.X,
                                screenPos.Y + OPAIHUB_HealthBarSettings.TextOffset.Y
                            )
                            drawing.text.Visible = true
                        else
                            for _, obj in pairs(drawing) do
                                obj.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
    
    if OPAIHUB_HealthBarSettings.ShowKillerBars then
        local killers = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
        if killers then
            for _, killer in ipairs(killers:GetChildren()) do
                if typeof(killer) == "Instance" and killer:IsA("Model") and killer ~= OPAIHUB_LocalPlayer.Character then
                    local humanoid = killer:FindFirstChildOfClass("Humanoid")
                    
                    if humanoid then
                        if not OPAIHUB_HealthBarDrawings[killer] then
                            OPAIHUB_HealthBarDrawings[killer] = OPAIHUB_CreateHealthBarDrawing()
                        end
                        
                        local drawing = OPAIHUB_HealthBarDrawings[killer]
                        local headPos = OPAIHUB_GetHeadPosition(killer)
                        local screenPos, onScreen = camera:WorldToViewportPoint(headPos)
                        
                        if onScreen then
                            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                            local healthBarWidth = OPAIHUB_HealthBarSettings.BarWidth * (healthPercent / 100)
                            
                            local barPos = Vector2.new(
                                screenPos.X + OPAIHUB_HealthBarSettings.BarOffset.X - (OPAIHUB_HealthBarSettings.BarWidth / 2),
                                screenPos.Y + OPAIHUB_HealthBarSettings.BarOffset.Y
                            )
                            
                            drawing.background.Size = Vector2.new(OPAIHUB_HealthBarSettings.BarWidth, OPAIHUB_HealthBarSettings.BarHeight)
                            drawing.background.Position = barPos
                            drawing.background.Visible = true
                            
                            drawing.outline.Size = Vector2.new(OPAIHUB_HealthBarSettings.BarWidth, OPAIHUB_HealthBarSettings.BarHeight)
                            drawing.outline.Position = barPos
                            drawing.outline.Visible = true
                            
                            drawing.bar.Color = OPAIHUB_GetHealthColor(humanoid, true)
                            drawing.bar.Size = Vector2.new(healthBarWidth, OPAIHUB_HealthBarSettings.BarHeight)
                            drawing.bar.Position = barPos
                            drawing.bar.Visible = true
                            
                            drawing.text.Text = tostring(healthPercent) .. "%"
                            drawing.text.Size = OPAIHUB_HealthBarSettings.TextSize
                            drawing.text.Position = Vector2.new(
                                screenPos.X + OPAIHUB_HealthBarSettings.TextOffset.X,
                                screenPos.Y + OPAIHUB_HealthBarSettings.TextOffset.Y
                            )
                            drawing.text.Visible = true
                        else
                            for _, obj in pairs(drawing) do
                                obj.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
end

local function OPAIHUB_CleanupHealthBars()
    for _, drawing in pairs(OPAIHUB_HealthBarDrawings) do
        for _, obj in pairs(drawing) do
            if obj then
                obj:Remove()
            end
        end
    end
    OPAIHUB_HealthBarDrawings = {}
end

OPAIHUB_HealthBarGroup:AddToggle("OPAIHUB_HealthBars", {
    Text = "启用血量条",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not OPAIHUB_HealthBarSettings.connection then
                OPAIHUB_HealthBarSettings.connection = OPAIHUB_RunService.RenderStepped:Connect(OPAIHUB_UpdateHealthBars)
            end
            
            if not OPAIHUB_HealthBarSettings.removedConnection then
                OPAIHUB_HealthBarSettings.removedConnection = OPAIHUB_Workspace.DescendantRemoving:Connect(function(descendant)
                    if OPAIHUB_HealthBarDrawings[descendant] then
                        for _, obj in pairs(OPAIHUB_HealthBarDrawings[descendant]) do
                            obj:Remove()
                        end
                        OPAIHUB_HealthBarDrawings[descendant] = nil
                    end
                end)
            end
        else
            if OPAIHUB_HealthBarSettings.connection then
                OPAIHUB_HealthBarSettings.connection:Disconnect()
                OPAIHUB_HealthBarSettings.connection = nil
            end
            
            if OPAIHUB_HealthBarSettings.removedConnection then
                OPAIHUB_HealthBarSettings.removedConnection:Disconnect()
                OPAIHUB_HealthBarSettings.removedConnection = nil
            end
            
            OPAIHUB_CleanupHealthBars()
        end
    end
})

OPAIHUB_HealthBarGroup:AddToggle("OPAIHUB_ShowSurvivorBars", {
    Text = "显示幸存者血量条",
    Default = true,
    Callback = function(enabled)
        OPAIHUB_HealthBarSettings.ShowSurvivorBars = enabled
    end
})

OPAIHUB_HealthBarGroup:AddToggle("OPAIHUB_ShowKillerBars", {
    Text = "显示杀手血量条",
    Default = true,
    Callback = function(enabled)
        OPAIHUB_HealthBarSettings.ShowKillerBars = enabled
    end
})

-- 角色名称绘制
local OPAIHUB_NameTagGroup = OPAIHUB_Tabs.ESP:AddRightGroupbox("OPAIHUB 角色名称绘制")

local OPAIHUB_NameTagSettings = {
    ShowSurvivorNames = true,
    ShowKillerNames = true,
    BaseTextSize = 14,
    MinTextSize = 10,
    MaxTextSize = 20,
    TextOffset = Vector3.new(0, 3, 0),
    DistanceScale = {
        MinDistance = 10,
        MaxDistance = 50
    },
    SurvivorColor = Color3.fromRGB(0, 191, 255),
    KillerColor = Color3.fromRGB(255, 0, 0),
    OutlineColor = Color3.fromRGB(0, 0, 0),
    ShowDistance = true,
    connection = nil,
    removedConnection = nil
}

local OPAIHUB_NameTagDrawings = {}

local function OPAIHUB_CreateNameTagDrawing()
    local drawing = Drawing.new("Text")
    drawing.Size = OPAIHUB_NameTagSettings.BaseTextSize
    drawing.Center = true
    drawing.Outline = true
    drawing.OutlineColor = OPAIHUB_NameTagSettings.OutlineColor
    drawing.Font = 2
    return drawing
end

local function OPAIHUB_GetHeadPositionForNameTag(character)
    local head = character:FindFirstChild("Head")
    if head then
        local headHeight = head.Size.Y
        return head.Position + Vector3.new(0, headHeight + 0.5, 0)
    end
    return character:GetPivot().Position
end

local function OPAIHUB_CleanupInvalidNameTags()
    local survivors = OPAIHUB_Workspace.Players:FindFirstChild("Survivors")
    local killers = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
    
    local validCharacters = {}
    if survivors then
        for _, survivor in ipairs(survivors:GetChildren()) do
            if typeof(survivor) == "Instance" and survivor:IsA("Model") then
                validCharacters[survivor] = true
            end
        end
    end
    if killers then
        for _, killer in ipairs(killers:GetChildren()) do
            if typeof(killer) == "Instance" and killer:IsA("Model") then
                validCharacters[killer] = true
            end
        end
    end
    
    for model, drawing in pairs(OPAIHUB_NameTagDrawings) do
        if not validCharacters[model] then
            drawing:Remove()
            OPAIHUB_NameTagDrawings[model] = nil
        end
    end
end

local function OPAIHUB_UpdateNameTags()
    local camera = OPAIHUB_Workspace.CurrentCamera
    local localCharacter = OPAIHUB_LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

    if not localRoot then return end
    
    OPAIHUB_CleanupInvalidNameTags()

    if OPAIHUB_NameTagSettings.ShowSurvivorNames then
        local survivors = OPAIHUB_Workspace.Players:FindFirstChild("Survivors")
        if survivors then
            for _, survivor in ipairs(survivors:GetChildren()) do
                if typeof(survivor) == "Instance" and survivor:IsA("Model") and survivor ~= localCharacter then
                    local humanoid = survivor:FindFirstChildOfClass("Humanoid")
                    
                    if not OPAIHUB_NameTagDrawings[survivor] then
                        OPAIHUB_NameTagDrawings[survivor] = OPAIHUB_CreateNameTagDrawing()
                    end
                    
                    local drawing = OPAIHUB_NameTagDrawings[survivor]
                    
                    if not humanoid or humanoid.Health <= 0 then
                        drawing.Visible = false
                    else
                        local headPos = OPAIHUB_GetHeadPositionForNameTag(survivor)
                        local screenPos, onScreen = camera:WorldToViewportPoint(headPos + OPAIHUB_NameTagSettings.TextOffset)
                        
                        if onScreen then
                            local distance = (headPos - localRoot.Position).Magnitude
                            local scale = math.clamp(
                                1 - (distance - OPAIHUB_NameTagSettings.DistanceScale.MinDistance) / 
                                (OPAIHUB_NameTagSettings.DistanceScale.MaxDistance - OPAIHUB_NameTagSettings.DistanceScale.MinDistance), 
                                0.3, 1
                            )
                            
                            local textSize = math.floor(OPAIHUB_NameTagSettings.BaseTextSize * scale)
                            textSize = math.clamp(textSize, OPAIHUB_NameTagSettings.MinTextSize, OPAIHUB_NameTagSettings.MaxTextSize)
                            
                            local displayText = survivor.Name
                            if OPAIHUB_NameTagSettings.ShowDistance then
                                displayText = string.format("%s [%d]", survivor.Name, math.floor(distance))
                            end
                            
                            drawing.Text = displayText
                            drawing.Color = OPAIHUB_NameTagSettings.SurvivorColor
                            drawing.Size = textSize
                            drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                            drawing.Visible = true
                        else
                            drawing.Visible = false
                        end
                    end
                end
            end
        end
    end

    if OPAIHUB_NameTagSettings.ShowKillerNames then
        local killers = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
        if killers then
            for _, killer in ipairs(killers:GetChildren()) do
                if typeof(killer) == "Instance" and killer:IsA("Model") then
                    local humanoid = killer:FindFirstChildOfClass("Humanoid")
                    
                    if not OPAIHUB_NameTagDrawings[killer] then
                        OPAIHUB_NameTagDrawings[killer] = OPAIHUB_CreateNameTagDrawing()
                    end
                    
                    local drawing = OPAIHUB_NameTagDrawings[killer]
                    
                    if not humanoid or humanoid.Health <= 0 then
                        drawing.Visible = false
                    else
                        local headPos = OPAIHUB_GetHeadPositionForNameTag(killer)
                        local screenPos, onScreen = camera:WorldToViewportPoint(headPos + OPAIHUB_NameTagSettings.TextOffset)
                        
                        if onScreen then
                            local distance = (headPos - localRoot.Position).Magnitude
                            local scale = math.clamp(
                                1 - (distance - OPAIHUB_NameTagSettings.DistanceScale.MinDistance) / 
                                (OPAIHUB_NameTagSettings.DistanceScale.MaxDistance - OPAIHUB_NameTagSettings.DistanceScale.MinDistance), 
                                0.3, 1
                            )
                            
                            local textSize = math.floor(OPAIHUB_NameTagSettings.BaseTextSize * scale)
                            textSize = math.clamp(textSize, OPAIHUB_NameTagSettings.MinTextSize, OPAIHUB_NameTagSettings.MaxTextSize)
                            
                            local displayText = killer.Name
                            if OPAIHUB_NameTagSettings.ShowDistance then
                                displayText = string.format("%s [%dm]", killer.Name, math.floor(distance))
                            end
                            
                            drawing.Text = displayText
                            drawing.Color = OPAIHUB_NameTagSettings.KillerColor
                            drawing.Size = textSize
                            drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                            drawing.Visible = true
                        else
                            drawing.Visible = false
                        end
                    end
                end
            end
        end
    end
end

local function OPAIHUB_CleanupNameTags()
    for _, drawing in pairs(OPAIHUB_NameTagDrawings) do
        if drawing then
            drawing:Remove()
        end
    end
    OPAIHUB_NameTagDrawings = {}
end

OPAIHUB_NameTagGroup:AddToggle("OPAIHUB_NameTags", {
    Text = "启用名称绘制",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not OPAIHUB_NameTagSettings.connection then
                OPAIHUB_NameTagSettings.connection = OPAIHUB_RunService.RenderStepped:Connect(OPAIHUB_UpdateNameTags)
            end
            
            if not OPAIHUB_NameTagSettings.removedConnection then
                OPAIHUB_NameTagSettings.removedConnection = OPAIHUB_Players.PlayerRemoving:Connect(function(player)
                    for model, drawing in pairs(OPAIHUB_NameTagDrawings) do
                        if model.Name == player.Name then
                            drawing:Remove()
                            OPAIHUB_NameTagDrawings[model] = nil
                        end
                    end
                end)
            end
        else
            if OPAIHUB_NameTagSettings.connection then
                OPAIHUB_NameTagSettings.connection:Disconnect()
                OPAIHUB_NameTagSettings.connection = nil
            end
            
            if OPAIHUB_NameTagSettings.removedConnection then
                OPAIHUB_NameTagSettings.removedConnection:Disconnect()
                OPAIHUB_NameTagSettings.removedConnection = nil
            end
            
            OPAIHUB_CleanupNameTags()
        end
    end
})

OPAIHUB_NameTagGroup:AddToggle("OPAIHUB_ShowSurvivorNames", {
    Text = "显示幸存者名称",
    Default = true,
    Callback = function(enabled)
        OPAIHUB_NameTagSettings.ShowSurvivorNames = enabled
    end
})

OPAIHUB_NameTagGroup:AddToggle("OPAIHUB_ShowKillerNames", {
    Text = "显示杀手名称",
    Default = true,
    Callback = function(enabled)
        OPAIHUB_NameTagSettings.ShowKillerNames = enabled
    end
})

OPAIHUB_NameTagGroup:AddToggle("OPAIHUB_ShowDistance", {
    Text = "显示距离",
    Default = true,
    Callback = function(enabled)
        OPAIHUB_NameTagSettings.ShowDistance = enabled
    end
})

-- 高亮绘制
local OPAIHUB_HighlightGroup = OPAIHUB_Tabs.ESP:AddLeftGroupbox("OPAIHUB 高亮绘制")

local OPAIHUB_HighlightSettings = {
    ShowSurvivorHighlights = true,
    ShowKillerHighlights = true,
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    connection = nil,
    highlights = {}
}

OPAIHUB_HighlightSettings.SurvivorColors = {
    ["绿色"] = Color3.fromRGB(0, 255, 0),
    ["白色"] = Color3.fromRGB(255, 255, 255),
    ["紫色"] = Color3.fromRGB(128, 0, 128),
    ["青色"] = Color3.fromRGB(0, 255, 255),
    ["橙色"] = Color3.fromRGB(255, 165, 0),
    ["柠檬绿"] = Color3.fromRGB(173, 255, 47)
}

OPAIHUB_HighlightSettings.KillerColors = {
    ["红色"] = Color3.fromRGB(255, 0, 0),
    ["粉色"] = Color3.fromRGB(255, 105, 180),
    ["黑色"] = Color3.fromRGB(0, 0, 0),
    ["蓝色"] = Color3.fromRGB(0, 0, 255),
    ["猩红色"] = Color3.fromRGB(220, 20, 60),
    ["杏色"] = Color3.fromRGB(251, 206, 177)
}

OPAIHUB_HighlightSettings.SurvivorOutlineColors = table.clone(OPAIHUB_HighlightSettings.SurvivorColors)
OPAIHUB_HighlightSettings.KillerOutlineColors = table.clone(OPAIHUB_HighlightSettings.KillerColors)

OPAIHUB_HighlightSettings.SelectedSurvivorColor = "青色"
OPAIHUB_HighlightSettings.SelectedKillerColor = "红色"
OPAIHUB_HighlightSettings.SelectedSurvivorOutlineColor = "青色"
OPAIHUB_HighlightSettings.SelectedKillerOutlineColor = "红色"

local function OPAIHUB_CleanupHighlights()
    for _, highlight in pairs(OPAIHUB_HighlightSettings.highlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    OPAIHUB_HighlightSettings.highlights = {}
end

local function OPAIHUB_UpdateHighlights()
    local survivorsFolder = OPAIHUB_Workspace:FindFirstChild("Players") and OPAIHUB_Workspace.Players:FindFirstChild("Survivors")
    local killersFolder = OPAIHUB_Workspace:FindFirstChild("Players") and OPAIHUB_Workspace.Players:FindFirstChild("Killers")
    
    local function OPAIHUB_ProcessFolder(folder, isKiller)
        if not folder then return end
        
        for _, model in ipairs(folder:GetChildren()) do
            if typeof(model) == "Instance" and model:IsA("Model") then
                local fillColor = isKiller and OPAIHUB_HighlightSettings.KillerColors[OPAIHUB_HighlightSettings.SelectedKillerColor] 
                                          or OPAIHUB_HighlightSettings.SurvivorColors[OPAIHUB_HighlightSettings.SelectedSurvivorColor]
                
                local outlineColor = isKiller and OPAIHUB_HighlightSettings.KillerOutlineColors[OPAIHUB_HighlightSettings.SelectedKillerOutlineColor] 
                                              or OPAIHUB_HighlightSettings.SurvivorOutlineColors[OPAIHUB_HighlightSettings.SelectedSurvivorOutlineColor]
                
                if (isKiller and OPAIHUB_HighlightSettings.ShowKillerHighlights) or 
                   (not isKiller and OPAIHUB_HighlightSettings.ShowSurvivorHighlights) then
                    
                    if not OPAIHUB_HighlightSettings.highlights[model] then
                        local highlight = Instance.new("Highlight")
                        highlight.Parent = game:GetService("CoreGui")
                        OPAIHUB_HighlightSettings.highlights[model] = highlight
                    end
                    
                    local highlight = OPAIHUB_HighlightSettings.highlights[model]
                    highlight.Adornee = model
                    highlight.FillColor = fillColor
                    highlight.OutlineColor = outlineColor
                    highlight.FillTransparency = OPAIHUB_HighlightSettings.FillTransparency
                    highlight.OutlineTransparency = OPAIHUB_HighlightSettings.OutlineTransparency
                elseif OPAIHUB_HighlightSettings.highlights[model] then
                    OPAIHUB_HighlightSettings.highlights[model].Adornee = nil
                end
            end
        end
    end
    
    OPAIHUB_ProcessFolder(survivorsFolder, false)
    OPAIHUB_ProcessFolder(killersFolder, true)
    
    for model, highlight in pairs(OPAIHUB_HighlightSettings.highlights) do
        if not model or not model.Parent then
            highlight:Destroy()
            OPAIHUB_HighlightSettings.highlights[model] = nil
        end
    end
end

OPAIHUB_HighlightGroup:AddToggle("OPAIHUB_Highlight", {
    Text = "启用高亮绘制",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not OPAIHUB_HighlightSettings.connection then
                OPAIHUB_HighlightSettings.connection = OPAIHUB_RunService.RenderStepped:Connect(OPAIHUB_UpdateHighlights)
            end
        else
            if OPAIHUB_HighlightSettings.connection then
                OPAIHUB_HighlightSettings.connection:Disconnect()
                OPAIHUB_HighlightSettings.connection = nil
            end
            OPAIHUB_CleanupHighlights()
        end
    end
})

OPAIHUB_HighlightGroup:AddToggle("OPAIHUB_ShowSurvivorHighlights", {
    Text = "绘制幸存者高亮",
    Default = true,
    Callback = function(enabled)
        OPAIHUB_HighlightSettings.ShowSurvivorHighlights = enabled
    end
})

OPAIHUB_HighlightGroup:AddToggle("OPAIHUB_ShowKillerHighlights", {
    Text = "绘制杀手高亮",
    Default = true,
    Callback = function(enabled)
        OPAIHUB_HighlightSettings.ShowKillerHighlights = enabled
    end
})

OPAIHUB_HighlightGroup:AddDropdown("OPAIHUB_SurvivorFillColor", {
    Values = {"绿色", "白色", "紫色", "青色", "橙色", "柠檬绿"},
    Default = "青色",
    Text = "幸存者填充颜色",
    Callback = function(value)
        OPAIHUB_HighlightSettings.SelectedSurvivorColor = value
    end
})

OPAIHUB_HighlightGroup:AddDropdown("OPAIHUB_KillerFillColor", {
    Values = {"红色", "粉色", "黑色", "蓝色", "猩红色", "杏色"},
    Default = "红色",
    Text = "杀手填充颜色",
    Callback = function(value)
        OPAIHUB_HighlightSettings.SelectedKillerColor = value
    end
})

OPAIHUB_HighlightGroup:AddSlider("OPAIHUB_FillTransparency", {
    Text = "填充透明度",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_HighlightSettings.FillTransparency = value
    end
})

OPAIHUB_HighlightGroup:AddSlider("OPAIHUB_OutlineTransparency", {
    Text = "边缘透明度",
    Min = 0,
    Max = 1,
    Default = 0,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_HighlightSettings.OutlineTransparency = value
    end
})

-- 物品绘制（使用LibESP库）
local OPAIHUB_ItemESPGroup = OPAIHUB_Tabs.ESP:AddRightGroupbox("OPAIHUB 物品绘制")

local OPAIHUB_LibESP = nil
local OPAIHUB_OtherESPConnection = nil
local OPAIHUB_TripWireESPConnection = nil
local OPAIHUB_SubspaceTripmineESPConnection = nil
local OPAIHUB_MedkitESPConnection = nil
local OPAIHUB_ColaESPConnection = nil

-- 加载LibESP库
task.spawn(function()
    local success, result = pcall(function()
        OPAIHUB_LibESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImamGV/Script/main/ESP"))()
    end)
    if not success then
        warn("[OPAIHUB] 无法加载LibESP库: " .. tostring(result))
    end
end)

OPAIHUB_ItemESPGroup:AddToggle("OPAIHUB_RobotESP", {
    Text = "杀手机器人绘制",
    Default = false,
    Callback = function(v)
        if not OPAIHUB_LibESP then
            OPAIHUB_Library:Notify("错误", "LibESP库未加载", 3)
            return
        end
        
        if v then
            for _, obj in ipairs(OPAIHUB_Workspace:GetDescendants()) do
                if typeof(obj) == "Instance" and obj:IsA("Model") then
                    if obj.Name == "PizzaDeliveryRig" or obj.Name == "Bunny" or obj.Name == "Mafiaso1" or obj.Name == "Mafiaso2" or obj.Name == "Mafiaso3" then
                        OPAIHUB_LibESP:AddESP(obj, "披萨送货员", Color3.fromRGB(255, 52, 179), 14, "OPAIHUB_Other_ESP")
                    elseif obj.Name == "1x1x1x1Zombie" then
                        OPAIHUB_LibESP:AddESP(obj, "1x1x1x1 (僵尸)", Color3.fromRGB(224, 102, 255), 14, "OPAIHUB_Other_ESP")
                    end
                end
            end
            OPAIHUB_OtherESPConnection = OPAIHUB_Workspace.DescendantAdded:Connect(function(obj)
                if typeof(obj) == "Instance" and obj:IsA("Model") then
                    if obj.Name == "PizzaDeliveryRig" or obj.Name == "Bunny" or obj.Name == "Mafiaso1" or obj.Name == "Mafiaso2" or obj.Name == "Mafiaso3" then
                        OPAIHUB_LibESP:AddESP(obj, "披萨送货员", Color3.fromRGB(255, 52, 179), 14, "OPAIHUB_Other_ESP")
                    elseif obj.Name == "1x1x1x1Zombie" then
                        OPAIHUB_LibESP:AddESP(obj, "1x1x1x1 (僵尸)", Color3.fromRGB(224, 102, 255), 14, "OPAIHUB_Other_ESP")
                    end
                end
            end)
        else
            if OPAIHUB_OtherESPConnection then
                OPAIHUB_OtherESPConnection:Disconnect()
                OPAIHUB_OtherESPConnection = nil
            end
            if OPAIHUB_LibESP then
                OPAIHUB_LibESP:Delete("OPAIHUB_Other_ESP")
            end
        end
    end
})

OPAIHUB_ItemESPGroup:AddToggle("OPAIHUB_TripWireESP", {
    Text = "塔夫绊线绘制",
    Default = false,
    Callback = function(v)
        if not OPAIHUB_LibESP then
            OPAIHUB_Library:Notify("错误", "LibESP库未加载", 3)
            return
        end
        
        if v then
            local mapFolder = OPAIHUB_Workspace:FindFirstChild("Map")
            if mapFolder then
                local ingameFolder = mapFolder:FindFirstChild("Ingame")
                if ingameFolder then
                    for _, obj in ipairs(ingameFolder:GetDescendants()) do
                        if typeof(obj) == "Instance" and string.find(obj.Name, "TaphTripwire") and not obj:FindFirstChild("OPAIHUB_TripWire_ESP") then
                            OPAIHUB_LibESP:AddESP(obj, "Trip Wire", Color3.new(0,1,0), 14, "OPAIHUB_TripWire_ESP")
                        end
                    end
                    OPAIHUB_TripWireESPConnection = ingameFolder.DescendantAdded:Connect(function(obj)
                        task.wait(1)
                        if typeof(obj) == "Instance" and string.find(obj.Name, "TaphTripwire") and not obj:FindFirstChild("OPAIHUB_TripWire_ESP") then
                            OPAIHUB_LibESP:AddESP(obj, "Trip Wire", Color3.new(0,1,0), 14, "OPAIHUB_TripWire_ESP")
                        end
                    end)
                end
            end
        else
            if OPAIHUB_TripWireESPConnection then
                OPAIHUB_TripWireESPConnection:Disconnect()
                OPAIHUB_TripWireESPConnection = nil
            end
            if OPAIHUB_LibESP then
                OPAIHUB_LibESP:Delete("OPAIHUB_TripWire_ESP")
            end
        end
    end
})

OPAIHUB_ItemESPGroup:AddToggle("OPAIHUB_SubspaceTripmineESP", {
    Text = "空间炸弹绘制",
    Default = false,
    Callback = function(v)
        if not OPAIHUB_LibESP then
            OPAIHUB_Library:Notify("错误", "LibESP库未加载", 3)
            return
        end
        
        if v then
            for _, obj in ipairs(OPAIHUB_Workspace:GetDescendants()) do
                if typeof(obj) == "Instance" and obj:IsA("Model") and obj.Name == "SubspaceTripmine" and not obj:FindFirstChild("OPAIHUB_SubspaceTripmine_ESP") then
                    OPAIHUB_LibESP:AddESP(obj, "", Color3.fromRGB(255, 0, 255), 14, "OPAIHUB_SubspaceTripmine_ESP")
                end
            end
            OPAIHUB_SubspaceTripmineESPConnection = OPAIHUB_Workspace.DescendantAdded:Connect(function(obj)
                if typeof(obj) == "Instance" and obj:IsA("Model") and obj.Name == "SubspaceTripmine" and not obj:FindFirstChild("OPAIHUB_SubspaceTripmine_ESP") then
                    OPAIHUB_LibESP:AddESP(obj, "", Color3.fromRGB(255, 0, 255), 14, "OPAIHUB_SubspaceTripmine_ESP")
                end
            end)
        else
            if OPAIHUB_SubspaceTripmineESPConnection then
                OPAIHUB_SubspaceTripmineESPConnection:Disconnect()
                OPAIHUB_SubspaceTripmineESPConnection = nil
            end
            if OPAIHUB_LibESP then
                OPAIHUB_LibESP:Delete("OPAIHUB_SubspaceTripmine_ESP")
            end
        end
    end
})

OPAIHUB_ItemESPGroup:AddToggle("OPAIHUB_MedkitESP", {
    Text = "医疗箱绘制",
    Default = false,
    Callback = function(v)
        if not OPAIHUB_LibESP then
            OPAIHUB_Library:Notify("错误", "LibESP库未加载", 3)
            return
        end
        
        if v then
            for _, obj in ipairs(OPAIHUB_Workspace:GetDescendants()) do
                if typeof(obj) == "Instance" and obj:IsA("Model") and obj.Name == "Medkit" and not obj:FindFirstChild("OPAIHUB_Medkit_ESP") then
                    OPAIHUB_LibESP:AddESP(obj, "Medkit", Color3.fromRGB(187, 255, 255), 14, "OPAIHUB_Medkit_ESP")
                end
            end
            OPAIHUB_MedkitESPConnection = OPAIHUB_Workspace.DescendantAdded:Connect(function(obj)
                if typeof(obj) == "Instance" and obj:IsA("Model") and obj.Name == "Medkit" and not obj:FindFirstChild("OPAIHUB_Medkit_ESP") then
                    OPAIHUB_LibESP:AddESP(obj, "Medkit", Color3.fromRGB(187, 255, 255), 14, "OPAIHUB_Medkit_ESP")
                end
            end)
        else
            if OPAIHUB_MedkitESPConnection then
                OPAIHUB_MedkitESPConnection:Disconnect()
                OPAIHUB_MedkitESPConnection = nil
            end
            if OPAIHUB_LibESP then
                OPAIHUB_LibESP:Delete("OPAIHUB_Medkit_ESP")
            end
        end
    end
})

OPAIHUB_ItemESPGroup:AddToggle("OPAIHUB_ColaESP", {
    Text = "可乐绘制",
    Default = false,
    Callback = function(v)
        if not OPAIHUB_LibESP then
            OPAIHUB_Library:Notify("错误", "LibESP库未加载", 3)
            return
        end
        
        if v then
            for _, obj in ipairs(OPAIHUB_Workspace:GetDescendants()) do
                if typeof(obj) == "Instance" and obj:IsA("Model") and obj.Name == "BloxyCola" and not obj:FindFirstChild("OPAIHUB_BloxyCola_ESP") then
                    OPAIHUB_LibESP:AddESP(obj, "Bloxy Cola", Color3.fromRGB(131, 111, 255), 14, "OPAIHUB_BloxyCola_ESP")
                end
            end
            OPAIHUB_ColaESPConnection = OPAIHUB_Workspace.DescendantAdded:Connect(function(obj)
                if typeof(obj) == "Instance" and obj:IsA("Model") and obj.Name == "BloxyCola" and not obj:FindFirstChild("OPAIHUB_BloxyCola_ESP") then
                    OPAIHUB_LibESP:AddESP(obj, "Bloxy Cola", Color3.fromRGB(131, 111, 255), 14, "OPAIHUB_BloxyCola_ESP")
                end
            end)
        else
            if OPAIHUB_ColaESPConnection then
                OPAIHUB_ColaESPConnection:Disconnect()
                OPAIHUB_ColaESPConnection = nil
            end
            if OPAIHUB_LibESP then
                OPAIHUB_LibESP:Delete("OPAIHUB_BloxyCola_ESP")
            end
        end
    end
})

-- 陷阱绘制
local OPAIHUB_TrapESPGroup = OPAIHUB_Tabs.ESP:AddLeftGroupbox("OPAIHUB 陷阱绘制")

local OPAIHUB_JohnDoeTrapConnection = nil
local OPAIHUB_TaphTripwireConnection = nil
local OPAIHUB_NoliVoidstarConnection = nil

OPAIHUB_TrapESPGroup:AddToggle("OPAIHUB_JohnDoeTrap", {
    Text = "John Doe陷阱绘制",
    Default = false,
    Callback = function(v)
        if v then
            local function OPAIHUB_FindShadowInFolder(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child.Name == "Shadow" then
                        return child
                    elseif child:IsA("Folder") or child:IsA("Model") then
                        local found = OPAIHUB_FindShadowInFolder(child)
                        if found then return found end
                    end
                end
                return nil
            end
            
            local function OPAIHUB_SetupJohnDoeTrap(shadow)
                if not shadow or not shadow.Parent then return end
                
                local character = OPAIHUB_LocalPlayer.Character
                if not character then return end
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then return end
                
                local function OPAIHUB_GetObjectSize(obj)
                    if obj:IsA("BasePart") then
                        return obj.Size
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        local cf = obj:GetBoundingBox()
                        return (cf[2] - cf[1]).Magnitude
                    else
                        return Vector3.new(5, 5, 5)
                    end
                end
                
                local objectSize = OPAIHUB_GetObjectSize(shadow)
                
                if not shadow:FindFirstChild("OPAIHUB_ShadowRangeIndicator") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "OPAIHUB_ShadowRangeIndicator"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.8
                    highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
                    highlight.OutlineTransparency = 0.5
                    highlight.Parent = shadow
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "OPAIHUB_ShadowNameDisplay"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 180, 0, 60)
                    billboard.StudsOffset = Vector3.new(0, objectSize.Y/2 + 2, 0)
                    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Name = "OPAIHUB_TrapLabel"
                    textLabel.Text = "TRAP"
                    textLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    textLabel.Position = UDim2.new(0, 0, 0, 0)
                    textLabel.Font = Enum.Font.Arcade
                    textLabel.TextSize = 18
                    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.TextXAlignment = Enum.TextXAlignment.Center
                    textLabel.TextYAlignment = Enum.TextYAlignment.Center
                    textLabel.Parent = billboard
                    
                    local distanceLabel = Instance.new("TextLabel")
                    distanceLabel.Name = "OPAIHUB_DistanceLabel"
                    distanceLabel.Text = "Distance: Calculating..."
                    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    distanceLabel.Font = Enum.Font.Arcade
                    distanceLabel.TextSize = 14
                    distanceLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                    distanceLabel.BackgroundTransparency = 1
                    distanceLabel.TextStrokeTransparency = 0
                    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
                    distanceLabel.TextYAlignment = Enum.TextYAlignment.Center
                    distanceLabel.Parent = billboard
                    
                    textLabel.Parent = billboard
                    distanceLabel.Parent = billboard
                    billboard.Parent = shadow
                    
                    if shadow:IsA("BasePart") then
                        local boxHandleAdornment = Instance.new("BoxHandleAdornment")
                        boxHandleAdornment.Name = "OPAIHUB_SizeIndicator"
                        boxHandleAdornment.Adornee = shadow
                        boxHandleAdornment.AlwaysOnTop = true
                        boxHandleAdornment.Size = shadow.Size
                        boxHandleAdornment.Transparency = 0.7
                        boxHandleAdornment.Color3 = Color3.fromRGB(255, 50, 50)
                        boxHandleAdornment.ZIndex = 10
                        boxHandleAdornment.Parent = shadow
                    end
                    
                    OPAIHUB_JohnDoeTrapConnection = OPAIHUB_RunService.Heartbeat:Connect(function()
                        if not shadow or not shadow.Parent then return end
                        if not humanoidRootPart or not humanoidRootPart.Parent then return end
                        
                        local distance = (humanoidRootPart.Position - shadow.Position).Magnitude
                        if distanceLabel and distanceLabel.Parent then
                            distanceLabel.Text = string.format("Distance: %.1f m", distance)
                        end
                        
                        local baseScale = math.clamp(40 / math.max(1, distance), 0.4, 1.8)
                        if textLabel and textLabel.Parent then
                            textLabel.TextSize = 18 * baseScale
                        end
                        if distanceLabel and distanceLabel.Parent then
                            distanceLabel.TextSize = 14 * baseScale
                        end
                        
                        local overallTransparency = math.clamp(distance / 80, 0.1, 0.4)
                        local strokeTransparency = overallTransparency * 0.1
                        if textLabel and textLabel.Parent then
                            textLabel.TextStrokeTransparency = strokeTransparency
                        end
                        if distanceLabel and distanceLabel.Parent then
                            distanceLabel.TextStrokeTransparency = strokeTransparency
                        end
                        
                        if highlight and highlight.Parent then
                            highlight.FillTransparency = math.clamp(distance/70, 0.3, 0.8)
                        end
                    end)
                end
            end
            
            local mapFolder = OPAIHUB_Workspace:FindFirstChild("Map")
            if mapFolder then
                local ingameFolder = mapFolder:FindFirstChild("Ingame")
                if ingameFolder then
                    local shadow = OPAIHUB_FindShadowInFolder(ingameFolder)
                    if shadow then
                        OPAIHUB_SetupJohnDoeTrap(shadow)
                    end
                end
            end
        else
            if OPAIHUB_JohnDoeTrapConnection then
                OPAIHUB_JohnDoeTrapConnection:Disconnect()
                OPAIHUB_JohnDoeTrapConnection = nil
            end
        end
    end
})

OPAIHUB_TrapESPGroup:AddToggle("OPAIHUB_TaphTripwire", {
    Text = "Taph绊线绘制",
    Default = false,
    Callback = function(v)
        if v then
            local DEEP_PURPLE = Color3.fromRGB(102, 0, 153)
            
            local HIGHLIGHT_SETTINGS = {
                FillColor = DEEP_PURPLE,
                OutlineColor = DEEP_PURPLE,
                FillTransparency = 0.2,
                OutlineTransparency = 0,
                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                OutlineThickness = 2,
            }
            
            local function OPAIHUB_ClearExistingHighlights()
                for _, obj in pairs(OPAIHUB_Workspace:GetDescendants()) do
                    if typeof(obj) == "Instance" and obj:IsA("Highlight") and obj.Name == "OPAIHUB_TaphTripwire_DeepPurpleHighlight" then
                        obj:Destroy()
                    end
                end
            end
            
            local function OPAIHUB_GetTargetFolder()
                local map = OPAIHUB_Workspace:FindFirstChild("Map")
                if not map then return nil end
                local ingame = map:FindFirstChild("Ingame")
                if not ingame then return nil end
                return ingame
            end
            
            local function OPAIHUB_ApplyDeepPurpleHighlight(obj)
                local highlight = Instance.new("Highlight")
                highlight.Name = "OPAIHUB_TaphTripwire_DeepPurpleHighlight"
                highlight.Parent = obj
                for setting, value in pairs(HIGHLIGHT_SETTINGS) do
                    highlight[setting] = value
                end
                
                if obj:IsA("BasePart") then
                    local glow = Instance.new("SurfaceAppearance")
                    glow.ColorMap = DEEP_PURPLE
                    glow.Parent = obj
                end
            end
            
            local function OPAIHUB_HighlightTaphTripwireObjects()
                OPAIHUB_ClearExistingHighlights()
                local targetFolder = OPAIHUB_GetTargetFolder()
                if not targetFolder then return end
                
                local count = 0
                for _, obj in pairs(targetFolder:GetDescendants()) do
                    if typeof(obj) == "Instance" and string.find(obj.Name, "TaphTripwire") then
                        OPAIHUB_ApplyDeepPurpleHighlight(obj)
                        count = count + 1
                    end
                end
                
                print("[OPAIHUB] 高亮完成 数量: " .. count)
                
                OPAIHUB_TaphTripwireConnection = targetFolder.DescendantAdded:Connect(function(newObj)
                    if typeof(newObj) == "Instance" and string.find(newObj.Name, "TaphTripwire") then
                        OPAIHUB_ApplyDeepPurpleHighlight(newObj)
                    end
                end)
            end
            
            OPAIHUB_HighlightTaphTripwireObjects()
            
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = "输入 /highlighttaph 重新执行高亮",
                Color = DEEP_PURPLE,
                Font = Enum.Font.SourceSansBold
            })
            
            OPAIHUB_Players.PlayerAdded:Connect(function(player)
                player.Chatted:Connect(function(msg)
                    if msg:lower() == "/highlighttaph" then
                        OPAIHUB_HighlightTaphTripwireObjects()
                    end
                end)
            end)
        else
            if OPAIHUB_TaphTripwireConnection then
                OPAIHUB_TaphTripwireConnection:Disconnect()
                OPAIHUB_TaphTripwireConnection = nil
            end
        end
    end
})

OPAIHUB_TrapESPGroup:AddToggle("OPAIHUB_NoliVoidstar", {
    Text = "Noli星星绘制",
    Default = false,
    Callback = function(v)
        if v then
            local HIGHLIGHT_COLOR = Color3.fromRGB(255, 0, 255)
            local voidstar = OPAIHUB_Workspace:FindFirstChild("Voidstar", true)
            
            if voidstar then
                if not voidstar:FindFirstChild("OPAIHUB_VoidstarHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "OPAIHUB_VoidstarHighlight"
                    highlight.FillColor = HIGHLIGHT_COLOR
                    highlight.OutlineColor = HIGHLIGHT_COLOR
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    highlight.Parent = voidstar
                end
            end
        else
            local voidstar = OPAIHUB_Workspace:FindFirstChild("Voidstar", true)
            if voidstar then
                local highlight = voidstar:FindFirstChild("OPAIHUB_VoidstarHighlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
})

-- ============================================
-- ============================================
-- ============================================
-- OPAIHUB 传送功能页面（新版）
-- ============================================

-- 悬浮窗控制
local OPAIHUB_FloatingButton = nil
local OPAIHUB_FloatingButtonVisible = true
local OPAIHUB_WindowOpenState = true -- 跟踪窗口状态

local function OPAIHUB_CreateFloatingButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OPAIHUB_FloatingControl"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999 -- 确保在最上层
    
    local button = Instance.new("ImageButton")
    button.Name = "FloatingButton"
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Position = UDim2.new(1, -80, 0.5, -30)
    button.BackgroundTransparency = 0.3
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.Image = "rbxassetid://97914301936069"
    button.ImageTransparency = 0
    button.Visible = true
    button.Active = true
    button.Parent = screenGui
    
    -- 圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = button
    
    -- 边框
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 2
    stroke.Parent = button
    
    -- 拖拽功能
    local dragging = false
    local dragInput, mousePos, framePos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = button.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                                end
                            end)
                        end
                    end)
                    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
                    end
                end)
    
    OPAIHUB_UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            button.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- 点击切换窗口
    button.MouseButton1Click:Connect(function()
        OPAIHUB_WindowOpenState = not OPAIHUB_WindowOpenState
        
        -- 尝试多种方法隐藏/显示窗口
        pcall(function()
            -- 方法1: 使用SetOpen（如果存在）
            if OPAIHUB_Window and OPAIHUB_Window.SetOpen then
                OPAIHUB_Window:SetOpen(OPAIHUB_WindowOpenState)
            end
            
            -- 方法2: 使用全局存储的窗口GUI引用
            if _G.OPAIHUB_WindowGui and _G.OPAIHUB_WindowGui.Parent then
                _G.OPAIHUB_WindowGui.Enabled = OPAIHUB_WindowOpenState
            else
                -- 重新查找窗口GUI
                local coreGui = game:GetService("CoreGui")
                for _, gui in ipairs(coreGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, desc in ipairs(gui:GetDescendants()) do
                            if desc.Name:find("OPAI") or desc.Name:find("被遗弃") or desc.Name:find("Obsidian") then
                                _G.OPAIHUB_WindowGui = gui
                                gui.Enabled = OPAIHUB_WindowOpenState
                    break
                end
            end
                        if _G.OPAIHUB_WindowGui then break end
                    end
                end
            end
        end)
    end)
    
    screenGui.Parent = game:GetService("CoreGui")
    
    -- 确保按钮可见
                task.spawn(function()
        task.wait(0.1)
        if button and button.Parent then
            button.Visible = true
        end
        if screenGui and screenGui.Parent then
            screenGui.Enabled = true
                        end
                    end)
                    
    return screenGui
end

-- 主页添加悬浮窗控制
local OPAIHUB_MainWindowGroup = OPAIHUB_Tabs.Main:AddRightGroupbox("OPAIHUB 窗口控制")

OPAIHUB_MainWindowGroup:AddToggle("OPAIHUB_FloatingButton", {
    Text = "悬浮窗按钮",
    Default = true,
    Tooltip = "显示/隐藏悬浮窗按钮，用于快速打开/关闭主界面",
    Callback = function(v)
        OPAIHUB_FloatingButtonVisible = v
        if v then
            if not OPAIHUB_FloatingButton or not OPAIHUB_FloatingButton.Parent then
                if OPAIHUB_FloatingButton then
                    OPAIHUB_FloatingButton:Destroy()
                end
                OPAIHUB_FloatingButton = OPAIHUB_CreateFloatingButton()
            end
            -- 确保按钮可见
            if OPAIHUB_FloatingButton then
                local button = OPAIHUB_FloatingButton:FindFirstChild("FloatingButton")
                if button then
                    button.Visible = true
                end
            end
        else
            if OPAIHUB_FloatingButton then
                local button = OPAIHUB_FloatingButton:FindFirstChild("FloatingButton")
                if button then
                    button.Visible = false
                            end
                        end
        end
    end
})

OPAIHUB_MainWindowGroup:AddButton({
    Text = "关闭主界面",
    Func = function()
        OPAIHUB_WindowOpenState = false
        
        -- 尝试多种方法隐藏窗口
        pcall(function()
            -- 方法1: 使用SetOpen（如果存在）
            if OPAIHUB_Window and OPAIHUB_Window.SetOpen then
                OPAIHUB_Window:SetOpen(false)
            end
            
            -- 方法2: 使用全局存储的窗口GUI引用
            if _G.OPAIHUB_WindowGui and _G.OPAIHUB_WindowGui.Parent then
                _G.OPAIHUB_WindowGui.Enabled = false
            else
                -- 重新查找窗口GUI
                local coreGui = game:GetService("CoreGui")
                for _, gui in ipairs(coreGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, desc in ipairs(gui:GetDescendants()) do
                            if desc.Name:find("OPAI") or desc.Name:find("被遗弃") or desc.Name:find("Obsidian") then
                                _G.OPAIHUB_WindowGui = gui
                                gui.Enabled = false
                    break
                end
            end
                        if _G.OPAIHUB_WindowGui then break end
        end
            end
        end
        end)
        
        OPAIHUB_Library:Notify("提示", "使用悬浮窗按钮或按 RightShift 重新打开", 5)
    end,
    DoubleClick = false,
    Tooltip = "关闭主界面，使用悬浮窗按钮或快捷键重新打开"
})

-- 创建传送功能组
local OPAIHUB_TeleportKillerGroup = OPAIHUB_Tabs.Teleport:AddLeftGroupbox("OPAIHUB 传送到杀手")

OPAIHUB_TeleportKillerGroup:AddButton({
    Text = "传送到最近的杀手（全图）",
    Func = function()
        local character = OPAIHUB_LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            OPAIHUB_Library:Notify("错误", "找不到你的角色", 3)
            return
        end
        
        local myPosition = character.HumanoidRootPart.Position
        local killersFolder = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
        
        if not killersFolder then
            OPAIHUB_Library:Notify("错误", "找不到杀手文件夹", 3)
            return
        end
        
        local closestKiller = nil
        local shortestDistance = math.huge
        
        -- 搜索全图所有杀手（无距离限制）
        for _, killer in ipairs(killersFolder:GetChildren()) do
            if typeof(killer) == "Instance" and killer:IsA("Model") and killer ~= character then
                local killerHRP = killer:FindFirstChild("HumanoidRootPart")
                if killerHRP then
                    local distance = (killerHRP.Position - myPosition).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestKiller = killer
                    end
                end
            end
        end

        if closestKiller then
            local killerHRP = closestKiller:FindFirstChild("HumanoidRootPart")
            if killerHRP then
                -- 传送到杀手前面3米，面向杀手
                local killerPos = killerHRP.Position
                local newPos = killerHRP.CFrame * CFrame.new(0, 0, -3)
                
                -- 先设置角色位置
                character.HumanoidRootPart.CFrame = CFrame.new(newPos.Position, killerPos)
                
                -- 立即调整相机视角对准杀手（确保准星准确）
                if OPAIHUB_Workspace.CurrentCamera then
                    local camera = OPAIHUB_Workspace.CurrentCamera
                    local cameraPos = camera.CFrame.Position
                    camera.CFrame = CFrame.new(cameraPos, killerPos)
                end
                
                -- 延迟多次更新确保视角锁定（后台执行）
                task.spawn(function()
                    local targetKiller = closestKiller -- 保存引用
                    local targetPos = killerPos -- 保存位置
                    for i = 1, 5 do
                        task.wait(0.02)
                        if OPAIHUB_Workspace.CurrentCamera and targetKiller and targetKiller.Parent then
                            local camera = OPAIHUB_Workspace.CurrentCamera
                            local killerHRP = targetKiller:FindFirstChild("HumanoidRootPart")
                            if killerHRP then
                                local cameraPos = camera.CFrame.Position
                                camera.CFrame = CFrame.new(cameraPos, killerHRP.Position)
            end
        end
                    end
                end)
                
                -- 显示距离信息
                local distanceText = math.floor(shortestDistance) .. "米"
                OPAIHUB_Library:Notify("传送成功", "已传送到 " .. closestKiller.Name .. " 附近 (原距离: " .. distanceText .. ")", 3)
            end
        else
            OPAIHUB_Library:Notify("提示", "没有找到杀手", 3)
        end
    end,
    DoubleClick = false,
    Tooltip = "搜索全图范围，传送到最近的杀手前面3米处（无距离限制）"
})

-- 循环绕圈飞行（在杀手附近20米绕圈）
local OPAIHUB_CircleTeleportEnabled = false
local OPAIHUB_CircleTeleportConnection = nil
local OPAIHUB_CircleTeleportAngle = 0
local OPAIHUB_CircleTeleportRadius = 20

OPAIHUB_TeleportKillerGroup:AddSlider("OPAIHUB_CircleRadius", {
    Text = "绕圈半径",
    Min = 5,
    Max = 50,
    Default = 20,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        OPAIHUB_CircleTeleportRadius = value
    end
})

OPAIHUB_TeleportKillerGroup:AddToggle("OPAIHUB_CircleTeleport", {
    Text = "循环绕圈飞行（杀手附近）",
    Default = false,
    Tooltip = "在最近的杀手附近平滑飞行绕圈（隐蔽模式）",
    Callback = function(state)
        OPAIHUB_CircleTeleportEnabled = state
        if state then
            if OPAIHUB_CircleTeleportConnection then
                OPAIHUB_CircleTeleportConnection:Disconnect()
                OPAIHUB_CircleTeleportConnection = nil
            end
            
            OPAIHUB_CircleTeleportAngle = 0
            local lastTime = tick()
            
            OPAIHUB_CircleTeleportConnection = OPAIHUB_RunService.Heartbeat:Connect(function()
                if not OPAIHUB_CircleTeleportEnabled then return end
                
                local character = OPAIHUB_LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local hrp = character.HumanoidRootPart
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                -- 计算deltaTime
                local currentTime = tick()
                local deltaTime = math.min(currentTime - lastTime, 0.02) -- 限制最大deltaTime
                lastTime = currentTime
                
        local killersFolder = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
                if not killersFolder then return end
                
                -- 找到最近的杀手
                local closestKiller = nil
                local shortestDistance = math.huge
                local myPos = hrp.Position
        
        for _, killer in ipairs(killersFolder:GetChildren()) do
            if typeof(killer) == "Instance" and killer:IsA("Model") and killer ~= character then
                local killerHRP = killer:FindFirstChild("HumanoidRootPart")
                if killerHRP then
                            local distance = (killerHRP.Position - myPos).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestKiller = killer
                end
            end
        end
                end
                
                if closestKiller then
                    local killerHRP = closestKiller:FindFirstChild("HumanoidRootPart")
                    if killerHRP then
                        -- 计算目标位置（绕圈）
                        local offsetX = math.cos(OPAIHUB_CircleTeleportAngle) * OPAIHUB_CircleTeleportRadius
                        local offsetZ = math.sin(OPAIHUB_CircleTeleportAngle) * OPAIHUB_CircleTeleportRadius
                        local targetPosition = killerHRP.Position + Vector3.new(offsetX, 0, offsetZ)
                        
                        -- 计算飞行方向（平滑移动）
                        local direction = (targetPosition - hrp.Position)
                        local distance = direction.Magnitude
                        
                        if distance > 0.3 then
                            -- 使用平滑插值移动（更隐蔽）
                            local moveSpeed = math.min(distance * 6, 35) -- 降低最大速度，更自然
                            local lerpAlpha = math.min((moveSpeed * deltaTime) / distance, 0.3) -- 限制lerp速度，避免跳跃
                            
                            -- 手动实现位置插值（避免使用可能不存在的Lerp方法）
                            local newPosition = hrp.Position + (direction.Unit * moveSpeed * deltaTime)
                            local newCFrame = CFrame.new(newPosition, killerHRP.Position)
                            
                            -- 使用CFrame方式移动（模拟正常移动）
                            hrp.CFrame = newCFrame
                            
                            -- 调整相机视角对准杀手（确保准星准确，持续更新）
                            if OPAIHUB_Workspace.CurrentCamera then
                                local camera = OPAIHUB_Workspace.CurrentCamera
                                local cameraPos = camera.CFrame.Position
                                -- 平滑更新相机视角
                                camera.CFrame = CFrame.new(cameraPos, killerHRP.Position)
                            end
                            
                            -- 保持正常物理状态（不使用PlatformStand，避免检测）
                            if humanoid then
                                humanoid.PlatformStand = false
                                -- 模拟正常移动速度，避免被检测
                                if humanoid.WalkSpeed < 20 then
                                    humanoid.WalkSpeed = 20
            end
        end
        
                            -- 轻微抵消重力，但不完全禁用（更隐蔽）
                            local currentVelocity = hrp.AssemblyLinearVelocity
                            local targetVelocity = Vector3.new(0, math.min(currentVelocity.Y + 0.5, 5), 0) -- 轻微上浮，限制最大速度
                            hrp.AssemblyLinearVelocity = Vector3.new(
                                currentVelocity.X * 0.9 + targetVelocity.X * 0.1,
                                currentVelocity.Y * 0.9 + targetVelocity.Y * 0.1,
                                currentVelocity.Z * 0.9 + targetVelocity.Z * 0.1
                            )
                        else
                            -- 接近目标，直接设置位置
                            hrp.CFrame = CFrame.new(targetPosition, killerHRP.Position)
                        end
                        
                        -- 增加角度（每帧增加，控制绕圈速度）
                        OPAIHUB_CircleTeleportAngle = OPAIHUB_CircleTeleportAngle + (0.015 * math.min(deltaTime / (1/60), 2))
                        if OPAIHUB_CircleTeleportAngle > math.pi * 2 then
                            OPAIHUB_CircleTeleportAngle = 0
                        end
                    end
                end
            end)
            
            OPAIHUB_Library:Notify("循环绕圈飞行已启用", "在杀手附近" .. OPAIHUB_CircleTeleportRadius .. "米平滑飞行绕圈（隐蔽模式）", 3)
        else
            if OPAIHUB_CircleTeleportConnection then
                OPAIHUB_CircleTeleportConnection:Disconnect()
                OPAIHUB_CircleTeleportConnection = nil
            end
            
            -- 恢复正常状态
            local character = OPAIHUB_LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                -- 恢复重力
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                -- 恢复Humanoid状态
                if humanoid then
                    humanoid.PlatformStand = false
            end
        end
        
            OPAIHUB_Library:Notify("循环绕圈飞行已关闭", "停止飞行绕圈", 3)
        end
    end
})

local OPAIHUB_TeleportSurvivorGroup = OPAIHUB_Tabs.Teleport:AddRightGroupbox("OPAIHUB 传送到幸存者")

OPAIHUB_TeleportSurvivorGroup:AddButton({
    Text = "传送到最近的幸存者（全图）",
    Func = function()
        local character = OPAIHUB_LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            OPAIHUB_Library:Notify("错误", "找不到你的角色", 3)
            return
        end
        
        local myPosition = character.HumanoidRootPart.Position
        local survivorsFolder = OPAIHUB_Workspace.Players:FindFirstChild("Survivors")
        
        if not survivorsFolder then
            OPAIHUB_Library:Notify("错误", "找不到幸存者文件夹", 3)
            return
        end
        
        local closestSurvivor = nil
        local shortestDistance = math.huge
        
        -- 搜索全图所有幸存者（无距离限制）
        for _, survivor in ipairs(survivorsFolder:GetChildren()) do
            if typeof(survivor) == "Instance" and survivor:IsA("Model") and survivor ~= character then
                local survivorHRP = survivor:FindFirstChild("HumanoidRootPart")
                if survivorHRP then
                    local distance = (survivorHRP.Position - myPosition).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestSurvivor = survivor
                    end
                end
            end
        end
        
        if closestSurvivor then
            local survivorHRP = closestSurvivor:FindFirstChild("HumanoidRootPart")
            if survivorHRP then
                -- 传送到幸存者前面3米，面向幸存者
                local survivorPos = survivorHRP.Position
                local newPos = survivorHRP.CFrame * CFrame.new(0, 0, -3)
                
                -- 先设置角色位置
                character.HumanoidRootPart.CFrame = CFrame.new(newPos.Position, survivorPos)
                
                -- 立即调整相机视角对准幸存者（确保准星准确）
                if OPAIHUB_Workspace.CurrentCamera then
                    local camera = OPAIHUB_Workspace.CurrentCamera
                    local cameraPos = camera.CFrame.Position
                    camera.CFrame = CFrame.new(cameraPos, survivorPos)
                end
                
                -- 延迟多次更新确保视角锁定（后台执行）
                task.spawn(function()
                    local targetSurvivor = closestSurvivor -- 保存引用
                    local targetPos = survivorPos -- 保存位置
                    for i = 1, 5 do
                        task.wait(0.02)
                        if OPAIHUB_Workspace.CurrentCamera and targetSurvivor and targetSurvivor.Parent then
                            local camera = OPAIHUB_Workspace.CurrentCamera
                            local survivorHRP = targetSurvivor:FindFirstChild("HumanoidRootPart")
                            if survivorHRP then
                                local cameraPos = camera.CFrame.Position
                                camera.CFrame = CFrame.new(cameraPos, survivorHRP.Position)
                            end
                        end
                    end
                end)
                
                -- 显示距离信息
                local distanceText = math.floor(shortestDistance) .. "米"
                OPAIHUB_Library:Notify("传送成功", "已传送到 " .. closestSurvivor.Name .. " 附近 (原距离: " .. distanceText .. ")", 3)
            end
        else
            OPAIHUB_Library:Notify("提示", "没有找到其他幸存者", 3)
        end
    end,
    DoubleClick = false,
    Tooltip = "搜索全图范围，传送到最近的幸存者前面3米处（无距离限制）"
})

local OPAIHUB_TeleportInfoGroup = OPAIHUB_Tabs.Teleport:AddLeftGroupbox("OPAIHUB 信息查询")

OPAIHUB_TeleportInfoGroup:AddButton({
    Text = "获取我的团队信息",
    Func = function()
        local character = OPAIHUB_LocalPlayer.Character
        if not character then
            OPAIHUB_Library:Notify("错误", "找不到你的角色", 3)
            return
        end
        
        local killersFolder = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
        local survivorsFolder = OPAIHUB_Workspace.Players:FindFirstChild("Survivors")
        
        local isKiller = killersFolder and table.find(killersFolder:GetChildren(), character)
        local isSurvivor = survivorsFolder and table.find(survivorsFolder:GetChildren(), character)
        
        if isKiller then
            OPAIHUB_Library:Notify("团队信息", "你是杀手！", 5)
        elseif isSurvivor then
            OPAIHUB_Library:Notify("团队信息", "你是幸存者！", 5)
        else
            OPAIHUB_Library:Notify("团队信息", "无法确定你的团队", 3)
        end
    end,
    DoubleClick = false,
    Tooltip = "显示你当前是杀手还是幸存者"
})

OPAIHUB_TeleportInfoGroup:AddButton({
    Text = "显示所有玩家列表",
    Func = function()
        local killersFolder = OPAIHUB_Workspace.Players:FindFirstChild("Killers")
        local survivorsFolder = OPAIHUB_Workspace.Players:FindFirstChild("Survivors")
        
        local killersList = "杀手: "
        local survivorsList = "幸存者: "
        
        if killersFolder then
            local killerCount = 0
            for _, killer in ipairs(killersFolder:GetChildren()) do
                if typeof(killer) == "Instance" and killer:IsA("Model") then
                    killersList = killersList .. killer.Name .. ", "
                    killerCount = killerCount + 1
                end
            end
            killersList = killersList .. " (共" .. killerCount .. "个)"
        else
            killersList = killersList .. "无"
        end
        
        if survivorsFolder then
            local survivorCount = 0
            for _, survivor in ipairs(survivorsFolder:GetChildren()) do
                if typeof(survivor) == "Instance" and survivor:IsA("Model") then
                    survivorsList = survivorsList .. survivor.Name .. ", "
                    survivorCount = survivorCount + 1
                end
            end
            survivorsList = survivorsList .. " (共" .. survivorCount .. "个)"
        else
            survivorsList = survivorsList .. "无"
        end
        
        OPAIHUB_Library:Notify("玩家列表", killersList .. "\n" .. survivorsList, 7)
    end,
    DoubleClick = false,
    Tooltip = "显示当前游戏中所有的杀手和幸存者"
})

-- 初始化悬浮窗按钮
task.spawn(function()
    task.wait(1) -- 等待UI完全加载
    if OPAIHUB_FloatingButtonVisible then
        OPAIHUB_FloatingButton = OPAIHUB_CreateFloatingButton()
        if OPAIHUB_FloatingButton then
            local button = OPAIHUB_FloatingButton:FindFirstChild("FloatingButton")
            if button then
                button.Visible = true
            end
        end
    end
end)


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
            "rbxassetid://99820161736138",
            "rbxassetid://72457886454761"
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
            "rbxassetid://99820161736138",
            "rbxassetid://72457886454761"
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
            "rbxassetid://99820161736138",
            "rbxassetid://72457886454761"
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
            "rbxassetid://99820161736138",
            "rbxassetid://72457886454761"
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
            "rbxassetid://99820161736138",
            "rbxassetid://72457886454761"
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
        
        if OPAIHUB_CircleTeleportConnection then
            OPAIHUB_CircleTeleportConnection:Disconnect()
            OPAIHUB_CircleTeleportConnection = nil
        end
        
        if _G.OPAIHUB_HitboxTracking and _G.OPAIHUB_HitboxTracking.Connection then
            _G.OPAIHUB_HitboxTracking.Connection:Disconnect()
            _G.OPAIHUB_HitboxTracking.Connection = nil
            _G.OPAIHUB_HitboxTracking.Active = false
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

