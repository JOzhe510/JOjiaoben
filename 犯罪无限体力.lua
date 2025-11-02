local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

task.wait(8)

local TARGET = 100
local enabled = true
local staminaObjects = {}
local hookCount = 0
local scanCount = 0

local function scanStamina()
    scanCount = scanCount + 1
    staminaObjects = {}
    local newHookCount = 0
    
    for i, v in pairs(getgc(true)) do
        if type(v) == "table" then
            local sValue = rawget(v, "S")
            
            if sValue ~= nil and type(sValue) == "number" and sValue >= 0 and sValue <= 150 then
                local originalS = v.S
                v.S = TARGET
                
                local methods = {
                    "setS", "getS", "updateS",
                    "set", "get", "update",
                    "drain", "consume", "deplete",
                    "setStamina", "getStamina"
                }
                
                local hookedMethods = {}
                
                for _, methodName in ipairs(methods) do
                    if rawget(v, methodName) and type(v[methodName]) == "function" then
                        local oldMethod = v[methodName]
                        
                        if methodName:lower():find("get") then
                            v[methodName] = function(...)
                                if enabled then return TARGET end
                                return oldMethod(...)
                            end
                        elseif methodName:lower():find("set") then
                            v[methodName] = function(self, value, ...)
                                if enabled then
                                    return oldMethod(self, TARGET, ...)
                                end
                                return oldMethod(self, value, ...)
                            end
                        else
                            v[methodName] = function(...)
                                if not enabled then return oldMethod(...) end
                                return
                            end
                        end
                        
                        table.insert(hookedMethods, methodName)
                        newHookCount = newHookCount + 1
                    end
                end
                
                table.insert(staminaObjects, {
                    obj = v,
                    original = originalS
                })
            end
        end
    end
    
    hookCount = newHookCount
    return #staminaObjects > 0
end

scanStamina()

if #staminaObjects > 0 then
    local frameCount = 0
    local corrections = 0
    
    RunService.Heartbeat:Connect(function()
        if not enabled then return end
        
        frameCount = frameCount + 1
        
        if frameCount >= 30 then
            frameCount = 0
            
            for _, cache in pairs(staminaObjects) do
                local v = cache.obj
                
                if type(v) == "table" and rawget(v, "S") then
                    local currentS = v.S
                    
                    if type(currentS) == "number" then
                        if currentS < 95 then
                            v.S = TARGET
                            corrections = corrections + 1
                        end
                    end
                end
            end
        end
    end)
end

player.CharacterAdded:Connect(function(char)
    task.wait(3)
    
    if enabled then
        scanStamina()
        
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Respawn",
                Text = string.format("Found %d objects", #staminaObjects),
                Duration = 3
            })
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        
        if enabled then
            local validCount = 0
            for _, cache in pairs(staminaObjects) do
                if type(cache.obj) == "table" and rawget(cache.obj, "S") then
                    validCount = validCount + 1
                end
            end
            
            if validCount < #staminaObjects * 0.5 then
                scanStamina()
            end
        end
    end
end)

local function showStatus()
    if #staminaObjects > 0 then
        for i, cache in ipairs(staminaObjects) do
            if i <= 5 then
                local v = cache.obj
                if type(v) == "table" and rawget(v, "S") then
                    local currentS = v.S
                end
            end
        end
    end
end

local function cleanup()
    enabled = false
    
    local restored = 0
    for _, cache in pairs(staminaObjects) do
        local v = cache.obj
        if type(v) == "table" and rawget(v, "S") then
            pcall(function()
                v.S = cache.original
                restored = restored + 1
            end)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.L then
        enabled = not enabled
        
        if enabled then
            for _, cache in pairs(staminaObjects) do
                if type(cache.obj) == "table" and rawget(cache.obj, "S") then
                    cache.obj.S = TARGET
                end
            end
        end
        
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Stamina",
                Text = enabled and "ON" or "OFF",
                Duration = 2
            })
        end)
        
    elseif input.KeyCode == Enum.KeyCode.K then
        cleanup()
        
    elseif input.KeyCode == Enum.KeyCode.P then
        showStatus()
        
    elseif input.KeyCode == Enum.KeyCode.R then
        scanStamina()
        
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "Rescan",
                Text = string.format("Found %d | Hook %d", 
                    #staminaObjects, hookCount),
                Duration = 3
            })
        end)
    end
end)

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Loaded",
        Text = string.format("%d obj | %d hook", 
            #staminaObjects, hookCount),
        Duration = 6
    })
end)
