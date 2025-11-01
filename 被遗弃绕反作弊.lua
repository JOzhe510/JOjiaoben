--[[
    OPAI Hub - Advanced Anti-Cheat Bypass Suite
    Author: OPAI Team
    Version: 1.0.0
    Description: Comprehensive anti-cheat bypass system for Forsaken
]]

local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not table.clone then
    table.clone = function(t)
        local nt = {}
        for k,v in pairs(t) do nt[k] = v end
        return nt
    end
end

Library.ShowToggleFrameInKeybinds = true 
Library.ShowCustomCursor = true
Library.NotifySide = "Right"

local Window = Library:CreateWindow({
    Title = 'OPAI Hub | Anti-Cheat Bypass',
    Footer = "OPAI Team",
    Icon = 106397684977541,
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    NotifySide = "Right",
    TabPadding = 8,
    MenuFadeTime = 0
})

local Tabs = {
    Main = Window:AddTab('Main[主要]','house'),
    Movement = Window:AddTab('Movement[移动]','earth'),
    Combat = Window:AddTab('Combat[战斗]','moon'),
    Visual = Window:AddTab('Visual[视觉]','eye')
}

local _env = getgenv and getgenv() or {}
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- 反作弊绕过核心功能
-- ============================================

-- 1. NoStun (去除前后摇)
local NoStunEnabled = false
local function SetupNoStun()
    local function applyNoStun(character)
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if NoStunEnabled and humanoid.WalkSpeed < 16 then
                humanoid.WalkSpeed = 16
            end
        end)
    end
    
    if LocalPlayer.Character then
        applyNoStun(LocalPlayer.Character)
    end
    
    LocalPlayer.CharacterAdded:Connect(applyNoStun)
end

-- 2. SpeedBoost (速度增强 - CFrame方式)
local SpeedBoostEnabled = false
local SpeedBoostValue = 1
local SpeedBoostConnection = nil

local function StartSpeedBoost()
    if SpeedBoostConnection then return end
    
    SpeedBoostConnection = RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character then return end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and SpeedBoostEnabled then
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + moveDirection * SpeedBoostValue
                hrp.CanCollide = true
            end
        end
    end)
end

local function StopSpeedBoost()
    if SpeedBoostConnection then
        SpeedBoostConnection:Disconnect()
        SpeedBoostConnection = nil
    end
end

-- 3. VoidRush Override (Noli冲刺优化)
local VoidRushOverrideEnabled = false
local VoidRushConnection = nil
local VoidRushMonitorTask = nil

local function StartVoidRushOverride()
    if VoidRushConnection then return end
    
    local ORIGINAL_DASH_SPEED = 60
    local DEFAULT_WALK_SPEED = 16
    
    local function setupCharacter()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:WaitForChild("Humanoid", 5)
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        
        if humanoid and hrp then
            VoidRushConnection = RunService.RenderStepped:Connect(function()
                if not character or not character.Parent then return end
                
                local voidRushState = character:GetAttribute("VoidRushState")
                
                if voidRushState == "Dashing" and VoidRushOverrideEnabled then
                    humanoid.WalkSpeed = ORIGINAL_DASH_SPEED
                    humanoid.AutoRotate = false
                    
                    local direction = hrp.CFrame.LookVector
                    local horizontalDirection = Vector3.new(direction.X, 0, direction.Z).Unit
                    humanoid:Move(horizontalDirection)
                else
                    humanoid.WalkSpeed = DEFAULT_WALK_SPEED
                    humanoid.AutoRotate = true
                end
            end)
        end
    end
    
    setupCharacter()
    LocalPlayer.CharacterAdded:Connect(setupCharacter)
end

local function StopVoidRushOverride()
    if VoidRushConnection then
        VoidRushConnection:Disconnect()
        VoidRushConnection = nil
    end
    
    if VoidRushMonitorTask then
        task.cancel(VoidRushMonitorTask)
        VoidRushMonitorTask = nil
    end
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.AutoRotate = true
        end
    end
end

-- 4. Infinite Stamina (无限体力)
local InfiniteStaminaEnabled = false
local StaminaMonitorConnection = nil
local SprintModule = nil

local function ModifyStaminaSettings()
    pcall(function()
        if not SprintModule then
            local success, module = pcall(require, ReplicatedStorage.Systems.Character.Game.Sprinting)
            if success and module then
                SprintModule = module
            end
        end
        
        if SprintModule and SprintModule.StaminaLossDisabled ~= nil then
            SprintModule.StaminaLossDisabled = InfiniteStaminaEnabled
        end
    end)
end

local function StartInfiniteStamina()
    ModifyStaminaSettings()
    
    if StaminaMonitorConnection then
        StaminaMonitorConnection:Disconnect()
    end
    
    StaminaMonitorConnection = RunService.Heartbeat:Connect(function()
        if InfiniteStaminaEnabled then
            ModifyStaminaSettings()
        end
    end)
end

local function StopInfiniteStamina()
    if StaminaMonitorConnection then
        StaminaMonitorConnection:Disconnect()
        StaminaMonitorConnection = nil
    end
    
    if SprintModule and SprintModule.StaminaLossDisabled ~= nil then
        SprintModule.StaminaLossDisabled = false
    end
end

-- 5. Aimbot Anti-Detection (瞄准反检测)
local AimbotAntiDetectionEnabled = false
local OriginalAimbotState = nil

local function ApplyAimbotAntiDetection(hrp)
    if not hrp then return end
    
    if AimbotAntiDetectionEnabled then
        if not OriginalAimbotState then
            OriginalAimbotState = {
                AssemblyAngularVelocity = hrp.AssemblyAngularVelocity
            }
        end
        hrp.AssemblyAngularVelocity = Vector3.zero
    else
        if OriginalAimbotState then
            hrp.AssemblyAngularVelocity = OriginalAimbotState.AssemblyAngularVelocity
            OriginalAimbotState = nil
        end
    end
end

local AimbotAntiDetectionConnection = RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            ApplyAimbotAntiDetection(hrp)
        end
    end
end)

-- 6. CFrame Teleport (传送反检测)
local function SafeTeleport(cframe)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
        end
    end)
end

-- 7. Advanced Movement Bypass (高级移动绕过)
local AdvancedMovementEnabled = false
local AdvancedMovementConnection = nil

local function StartAdvancedMovement()
    if AdvancedMovementConnection then return end
    
    AdvancedMovementConnection = RunService.Heartbeat:Connect(function()
        if not LocalPlayer.Character then return end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and humanoid and AdvancedMovementEnabled then
            -- 禁用自动旋转以防止检测
            humanoid.AutoRotate = false
            
            -- 使用CFrame平滑移动
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                local newCFrame = hrp.CFrame + moveDirection * SpeedBoostValue * 0.1
                hrp.CFrame = newCFrame
            end
            
            -- 保持碰撞检测
            hrp.CanCollide = true
        elseif humanoid then
            humanoid.AutoRotate = true
        end
    end)
end

local function StopAdvancedMovement()
    if AdvancedMovementConnection then
        AdvancedMovementConnection:Disconnect()
        AdvancedMovementConnection = nil
    end
    
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
end

-- 8. Popup Bypass (弹窗绕过 - 针对1x1x1x1)
local PopupBypassEnabled = false
local PopupBypassConnection = nil
local PopupBypassTask = nil

local function StartPopupBypass()
    if PopupBypassTask then return end
    
    local RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
    
    local function deletePopups()
        if not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") then
            return false
        end
        
        local tempUI = LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
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
    
    local function triggerEntangled()
        pcall(function()
            RemoteEvent:FireServer("Entangled")
        end)
    end
    
    if LocalPlayer:FindFirstChild("PlayerGui") then
        local tempUI = LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
        if not tempUI then
            tempUI = Instance.new("Folder")
            tempUI.Name = "TemporaryUI"
            tempUI.Parent = LocalPlayer.PlayerGui
        end
        
        PopupBypassConnection = tempUI.ChildAdded:Connect(function(child)
            if PopupBypassEnabled and child.Name == "1x1x1x1Popup" then
                task.defer(function()
                    child:Destroy()
                end)
            end
        end)
    end
    
    PopupBypassTask = task.spawn(function()
        while PopupBypassEnabled do
            deletePopups()
            triggerEntangled()
            task.wait(0.5)
        end
    end)
end

local function StopPopupBypass()
    if PopupBypassTask then
        task.cancel(PopupBypassTask)
        PopupBypassTask = nil
    end
    
    if PopupBypassConnection then
        PopupBypassConnection:Disconnect()
        PopupBypassConnection = nil
    end
end

-- ============================================
-- UI 界面
-- ============================================

-- Main Tab
local MainGroup = Tabs.Main:AddLeftGroupbox("Anti-Cheat Bypass Core")

MainGroup:AddLabel("OPAI Team - Advanced Bypass System")
MainGroup:AddDivider()

MainGroup:AddToggle("NoStun", {
    Text = "NoStun [去除前后摇]",
    Default = false,
    Tooltip = "防止被击晕，自动恢复移动速度",
    Callback = function(v)
        NoStunEnabled = v
        if v then
            SetupNoStun()
            Library:Notify("NoStun Enabled", "Anti-stun protection activated", 3)
        else
            Library:Notify("NoStun Disabled", "Anti-stun protection deactivated", 3)
        end
    end
})

MainGroup:AddDivider()

MainGroup:AddToggle("AimbotAntiDetection", {
    Text = "Aimbot Anti-Detection [瞄准反检测]",
    Default = false,
    Tooltip = "禁用角速度检测，防止瞄准被检测",
    Callback = function(v)
        AimbotAntiDetectionEnabled = v
        if v then
            Library:Notify("Anti-Detection Enabled", "Aimbot detection bypass activated", 3)
        else
            Library:Notify("Anti-Detection Disabled", "Detection bypass deactivated", 3)
        end
    end
})

MainGroup:AddDivider()

MainGroup:AddToggle("InfiniteStamina", {
    Text = "Infinite Stamina [无限体力]",
    Default = false,
    Tooltip = "禁用体力消耗",
    Callback = function(v)
        InfiniteStaminaEnabled = v
        if v then
            StartInfiniteStamina()
            Library:Notify("Infinite Stamina Enabled", "Stamina drain disabled", 3)
        else
            StopInfiniteStamina()
            Library:Notify("Infinite Stamina Disabled", "Stamina drain restored", 3)
        end
    end
})

MainGroup:AddDivider()

MainGroup:AddButton("Restore Stamina", {
    Text = "Restore Stamina [恢复体力]",
    Func = function()
        pcall(function()
            local SprintingModule = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
            local sprintModule = require(SprintingModule)
            
            if sprintModule and sprintModule.SetStamina then
                sprintModule.SetStamina(sprintModule.MaxStamina or 100)
                Library:Notify("Stamina Restored", "Stamina set to maximum", 3)
            end
        end)
    end
})

-- Movement Tab
local MovementGroup = Tabs.Movement:AddLeftGroupbox("Movement Bypass")

MovementGroup:AddSlider("SpeedBoostValue", {
    Text = "Speed Boost Value [速度倍率]",
    Min = 0,
    Max = 5,
    Default = 1,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        SpeedBoostValue = v
    end
})

MovementGroup:AddToggle("SpeedBoost", {
    Text = "Speed Boost [速度增强]",
    Default = false,
    Tooltip = "使用CFrame方式移动，绕过速度检测",
    Callback = function(v)
        SpeedBoostEnabled = v
        if v then
            StartSpeedBoost()
            Library:Notify("Speed Boost Enabled", string.format("Speed multiplier: %.1fx", SpeedBoostValue), 3)
        else
            StopSpeedBoost()
            Library:Notify("Speed Boost Disabled", "Normal movement restored", 3)
        end
    end
})

MovementGroup:AddDivider()

MovementGroup:AddToggle("VoidRushOverride", {
    Text = "VoidRush Override [Noli冲刺优化]",
    Default = false,
    Tooltip = "优化Noli角色的冲刺能力",
    Callback = function(v)
        VoidRushOverrideEnabled = v
        if v then
            StartVoidRushOverride()
            Library:Notify("VoidRush Override Enabled", "Noli dash optimized", 3)
        else
            StopVoidRushOverride()
            Library:Notify("VoidRush Override Disabled", "Dash optimization disabled", 3)
        end
    end
})

-- Combat Tab
local CombatGroup = Tabs.Combat:AddLeftGroupbox("Combat Bypass")

CombatGroup:AddLabel("Combat bypass features")
CombatGroup:AddDivider()

CombatGroup:AddToggle("AdvancedMovement", {
    Text = "Advanced Movement [高级移动]",
    Default = false,
    Tooltip = "使用高级移动绕过，禁用自动旋转",
    Callback = function(v)
        AdvancedMovementEnabled = v
        if v then
            StartAdvancedMovement()
            Library:Notify("Advanced Movement Enabled", "Advanced movement bypass activated", 3)
        else
            StopAdvancedMovement()
            Library:Notify("Advanced Movement Disabled", "Normal movement restored", 3)
        end
    end
})

CombatGroup:AddDivider()

CombatGroup:AddToggle("PopupBypass", {
    Text = "Popup Bypass [弹窗绕过]",
    Default = false,
    Tooltip = "自动删除1x1x1x1弹窗并触发Entangled",
    Callback = function(v)
        PopupBypassEnabled = v
        if v then
            StartPopupBypass()
            Library:Notify("Popup Bypass Enabled", "Auto popup removal activated", 3)
        else
            StopPopupBypass()
            Library:Notify("Popup Bypass Disabled", "Popup bypass deactivated", 3)
        end
    end
})

CombatGroup:AddDivider()

CombatGroup:AddButton("Safe Teleport Test", {
    Text = "Test Safe Teleport [测试安全传送]",
    Func = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            SafeTeleport(hrp.CFrame + hrp.CFrame.LookVector * 10)
            Library:Notify("Teleport Test", "Teleported 10 studs forward", 3)
        end
    end
})

-- Visual Tab
local VisualGroup = Tabs.Visual:AddLeftGroupbox("Visual Settings")

VisualGroup:AddSlider("Brightness", {
    Text = "Brightness [亮度]",
    Min = 0,
    Max = 3,
    Default = 0,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        _env.Brightness = v
    end
})

VisualGroup:AddToggle("Fullbright", {
    Text = "Fullbright [全亮]",
    Default = false,
    Callback = function(v)
        _env.Fullbright = v
        if v then
            RunService.RenderStepped:Connect(function()
                if _env.Fullbright then
                    game.Lighting.OutdoorAmbient = Color3.new(1,1,1)
                    game.Lighting.Brightness = _env.Brightness or 0
                else
                    game.Lighting.OutdoorAmbient = Color3.fromRGB(55,55,55)
                    game.Lighting.Brightness = 0
                end
            end)
        end
    end
})

VisualGroup:AddToggle("NoFog", {
    Text = "Remove Fog [除雾]",
    Default = false,
    Callback = function(v)
        _env.NoFog = v
        if v then
            if not game.Lighting:GetAttribute("FogStart") then 
                game.Lighting:SetAttribute("FogStart", game.Lighting.FogStart) 
            end
            if not game.Lighting:GetAttribute("FogEnd") then 
                game.Lighting:SetAttribute("FogEnd", game.Lighting.FogEnd) 
            end
            game.Lighting.FogStart = 0
            game.Lighting.FogEnd = math.huge
            
            local fog = game.Lighting:FindFirstChildOfClass("Atmosphere")
            if fog then
                if not fog:GetAttribute("Density") then 
                    fog:SetAttribute("Density", fog.Density) 
                end
                fog.Density = 0
            end
        else
            game.Lighting.FogStart = game.Lighting:GetAttribute("FogStart") or 0
            game.Lighting.FogEnd = game.Lighting:GetAttribute("FogEnd") or 500
            local fog = game.Lighting:FindFirstChildOfClass("Atmosphere")
            if fog then
                fog.Density = fog:GetAttribute("Density") or 0.5
            end
        end
    end
})

-- ============================================
-- 清理和初始化
-- ============================================

-- 初始化NoStun
SetupNoStun()

-- 角色重生时重置
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    
    if SpeedBoostEnabled then
        StartSpeedBoost()
    end
    
    if VoidRushOverrideEnabled then
        StartVoidRushOverride()
    end
    
    if InfiniteStaminaEnabled then
        StartInfiniteStamina()
    end
    
    if AdvancedMovementEnabled then
        StartAdvancedMovement()
    end
    
    if AimbotAntiDetectionEnabled then
        ApplyAimbotAntiDetection(LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    end
end)

-- 玩家离开时清理
LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        StopSpeedBoost()
        StopVoidRushOverride()
        StopInfiniteStamina()
        StopAdvancedMovement()
        StopPopupBypass()
    end
end)

-- 清理函数
game:GetService("UserInputService").WindowFocused:Connect(function()
    -- 窗口聚焦时重新应用设置
    if InfiniteStaminaEnabled then
        ModifyStaminaSettings()
    end
end)

Library:Notify("OPAI Hub Loaded", "Anti-Cheat Bypass System Ready", 5)

-- 保存配置
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("OPAIHub")
SaveManager:SetFolder("OPAIHub/specific-game")
ThemeManager:ApplyTheme()
SaveManager:LoadAutosave()

