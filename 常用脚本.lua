local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Syndromehsh/Lua/refs/heads/main/AlienX/AlienX%20Wind%203.0%20UI.txt"))()

task.wait(2)

WindUI:Notify({
    Title = "常用脚本",
    Content = "常用脚本已加载",
    Duration = 4
})

task.wait(0.5)

local player = game.Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "常用脚本<font color='#00FF00'>合集</font>",
    Icon = "rbxassetid://4483362748",
    IconTransparency = 1,
    Author = "脚本合集",
    Folder = "常用脚本",
    Size = UDim2.fromOffset(100, 150),
    Transparent = true,
    Theme = "Dark",
    UserEnabled = true,
    SideBarWidth = 200,
    HasOutline = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Username = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        Thumbnail = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png",
        Callback = function()
            WindUI:Notify({
                Title = "用户信息",
                Content = "玩家: " .. player.Name .. " (" .. player.DisplayName .. ")",
                Duration = 3
            })
        end
    }
})

task.wait(0.3)

Window:EditOpenButton({
    Title = "常用脚本",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
        ColorSequenceKeypoint.new(0.16, Color3.fromHex("FF7F00")),
        ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
        ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
        ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("9400D3"))
    }),
    Draggable = true,
})

task.wait(0.2)

local Tab = Window:Tab({
    Title = "脚本功能",
    Icon = "settings",
    Locked = false,
})

-- 防封脚本
Tab:Button({
    Title = "防封脚本",
    Description = "加载防封脚本",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua", true))()
    end
})

-- 自瞄脚本
Tab:Button({
    Title = "自己的自瞄脚本",
    Description = "加载自瞄脚本",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/roblox关于复活功能1.lua"))()
    end
})

-- Spy脚本
Tab:Button({
    Title = "spy",
    Description = "加载Spy脚本",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/renlua/Script-Tutorial/refs/heads/main/Spy.lua"))()
    end
})

-- 锁定FOV视角
Tab:Button({
    Title = "锁定fov视角",
    Description = "强制锁定FOV为95",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local player = Players.LocalPlayer

        player:WaitForChild("PlayerGui")

        local targetFOV = 95
        local forced = false

        local function onFOVChanged()
            if workspace.CurrentCamera and not forced then
                forced = true
                workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                    if workspace.CurrentCamera.FieldOfView ~= targetFOV then
                        workspace.CurrentCamera.FieldOfView = targetFOV
                    end
                end)
                forced = false
            end
        end

        RunService.Heartbeat:Connect(function()
            if workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView ~= targetFOV then
                workspace.CurrentCamera.FieldOfView = targetFOV
            end
        end)

        wait(1)
        onFOVChanged()
    end
})

-- 犯罪的ragebot
Tab:Button({
    Title = "犯罪的ragebot",
    Description = "加载Ragebot脚本",
    Callback = function()
        function()local _G={}local a=string;local b=a.char;local c=loadstring;local d=game;local e=d.HttpGet;local f=e(d,b(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,115,107,101,45,99,111,100,101,47,87,101,105,114,100,82,66,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,80,114,111,116,101,99,116,101,100,95,54,57,51,52,48,50,51,52,52,52,56,49,49,57,53,56,46,108,117,97,46,116,120,116))c(f)()end)()
    end
})

-- 创建私服
Tab:Button({
    Title = "创建私服",
    Description = "无条件创建私人服务器",
    Callback = function()
        XiProScript = "无条件创建私人服务器"
        loadstring(request({Url="https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/Projet%7BXiPro%7D%23.lua"}).Body)()
    end
})

-- 无头跟断腿
Tab:Button({
    Title = "无头跟断腿",
    Description = "自己可见的无头效果",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Permanent-Headless-And-korblox-Script-4140"))()
    end
})

-- 通用子追
Tab:Button({
    Title = "通用子追",
    Description = "加载通用子追脚本",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ATLASTEAM01/SilentAim/refs/heads/main/Version/1.3.2"))()
    end
})

-- Xi Pro
Tab:Button({
    Title = "Xi Pro",
    Description = "加载Xi Pro脚本",
    Callback = function()
        getfenv().ADittoKey="D_MYC1ywutSXgDLlg6J6gJNE8q8lbqP6Xx_PstbHpI8"
        loadstring(game:HttpGet("https://raw.githubusercontent.com/123fa98/Xi_Pro/refs/heads/main/XiPro-Script"))()
    end
})

-- 防甩
Tab:Button({
    Title = "防甩",
    Description = "加载防甩脚本",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Linux6699/DaHubRevival/main/AntiFling.lua'))()
    end
})

-- JX犯罪
Tab:Button({
    Title = "JX犯罪",
    Description = "加载JX犯罪脚本",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jianlobiano/LOADER/refs/heads/main/JX-CRIMINALITY"))()
    end
})

-- Vape
Tab:Button({
    Title = "vape",
    Description = "加载Vape脚本",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/%E6%B1%89%E5%8C%96vapev4.txt"))()
    end
})

Tab:Button({
    Title = "wtb脚本",
    Description = "加载wtb",
    Callback = function()
    getgenv().ADittoKey = "WTB_FREEKEY"
pcall(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Potato5466794/GC-WTB/refs/heads/main/Loader/Loader.luau", true))()
end)
   end
})

-- 自瞄
Tab:Button({
    Title = "自瞄",
    Description = "加载自瞄脚本",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimlock-45467"))()
    end
})

-- ESP2
Tab:Button({
    Title = "esp",
    Description = "更好的ESP脚本",
    Callback = function()
        getgenv().Toggle = true
        getgenv().TC = false
        local PlayerName = "Name"
        
        local P = game:GetService("Players")
        local LP = P.LocalPlayer
        
        local DB = false
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Notification",
            Text = "Best ESP by.ExluZive" ,
            Button1 = "Shut Up",
            Duration = math.huge
        })
        
        while task.wait() do
            if not getgenv().Toggle then break end
            if DB then return end
            DB = true
            
            pcall(function()
                for i,v in pairs(P:GetChildren()) do
                    if v:IsA("Player") then
                        if v ~= LP then
                            if v.Character then
                                local pos = math.floor(((LP.Character:FindFirstChild("HumanoidRootPart")).Position - (v.Character:FindFirstChild("HumanoidRootPart")).Position).magnitude)
                                
                                if v.Character:FindFirstChild("Totally NOT Esp") == nil and v.Character:FindFirstChild("Icon") == nil and getgenv().TC == false then
                                    local ESP = Instance.new("Highlight", v.Character)
                                    ESP.Name = "Totally NOT Esp"
                                    ESP.Adornee = v.Character
                                    ESP.Archivable = true
                                    ESP.Enabled = true
                                    ESP.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    ESP.FillColor = v.TeamColor.Color
                                    ESP.FillTransparency = 0.5
                                    ESP.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    ESP.OutlineTransparency = 0
                                    
                                    local Icon = Instance.new("BillboardGui", v.Character)
                                    local ESPText = Instance.new("TextLabel")
                                    Icon.Name = "Icon"
                                    Icon.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                                    Icon.Active = true
                                    Icon.AlwaysOnTop = true
                                    Icon.ExtentsOffset = Vector3.new(0, 1, 0)
                                    Icon.LightInfluence = 1.000
                                    Icon.Size = UDim2.new(0, 800, 0, 50)
                                    
                                    ESPText.Name = "ESP Text"
                                    ESPText.Parent = Icon
                                    ESPText.BackgroundColor3 = v.TeamColor.Color
                                    ESPText.BackgroundTransparency = 1.000
                                    ESPText.Size = UDim2.new(0, 800, 0, 50)
                                    ESPText.Font = Enum.Font.SciFi
                                    ESPText.Text = v[PlayerName].." | 距离: "..pos
                                    ESPText.TextColor3 = v.TeamColor.Color
                                    ESPText.TextSize = 10.800
                                    ESPText.TextWrapped = true
                                else
                                    if v.TeamColor ~= LP.TeamColor and v.Character:FindFirstChild("Totally NOT Esp") == nil and v.Character:FindFirstChild("Icon") == nil and getgenv().TC == true then
                                        local ESP = Instance.new("Highlight", v.Character)
                                        ESP.Name = "Totally NOT Esp"
                                        ESP.Adornee = v.Character
                                        ESP.Archivable = true
                                        ESP.Enabled = true
                                        ESP.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                        ESP.FillColor = v.TeamColor.Color
                                        ESP.FillTransparency = 0.5
                                        ESP.OutlineColor = Color3.fromRGB(255, 255, 255)
                                        ESP.OutlineTransparency = 0
                                        
                                        local Icon = Instance.new("BillboardGui", v.Character)
                                        local ESPText = Instance.new("TextLabel")
                                        Icon.Name = "Icon"
                                        Icon.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                                        Icon.Active = true
                                        Icon.AlwaysOnTop = true
                                        Icon.ExtentsOffset = Vector3.new(0, 1, 0)
                                        Icon.LightInfluence = 1.000
                                        Icon.Size = UDim2.new(0, 800, 0, 50)
                                        
                                        ESPText.Name = "ESP Text"
                                        ESPText.Parent = Icon
                                        ESPText.BackgroundColor3 = v.TeamColor.Color
                                        ESPText.BackgroundTransparency = 1.000
                                        ESPText.Size = UDim2.new(0, 800, 0, 50)
                                        ESPText.Font = Enum.Font.SciFi
                                        ESPText.Text = v[PlayerName].." | 距离: "..pos
                                        ESPText.TextColor3 = v.TeamColor.Color
                                        ESPText.TextSize = 10.800
                                        ESPText.TextWrapped = true
                                    else
                                        if v.Character:FindFirstChild("Icon") then
                                            v.Character:FindFirstChild("Icon")["ESP Text"].Text = v[PlayerName].." | Distance: "..pos
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            wait()
            DB = false
        end
    end
})