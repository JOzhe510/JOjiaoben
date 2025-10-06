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

Tab:Button({
    Title = "防封2",
    Description = "加载脚本",
    Callback = function()
    -----bypass Anti Cheat  by yuxingchen   NOL TEAM-Neo-Utopia

print("绕过反作弊 1秒后加载。")

wait(1)

if not shared.AntiBanLoop then
    shared.AntiBanLoop = {running = false, hooked = false}
end
local loopData = shared.AntiBanLoop

local function AntiChatLogger()
    local StarterGui = game:GetService("StarterGui")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local PlayerScripts = Player:WaitForChild("PlayerScripts")

    local ChatMain = PlayerScripts:FindFirstChild("ChatMain", true)
    if ChatMain then
        local PostMessage = require(ChatMain).MessagePosted
        if PostMessage then
            local OldHook
            OldHook = hookfunction(PostMessage.fire, function(self, Message)
                if not checkcaller() and self == PostMessage then
                    return
                end
                return OldHook(self, Message)
            end)
        end
    end
    if setfflag then
        setfflag("AbuseReportScreenshot", "False")
        setfflag("AbuseReportScreenshotPercentage", "0")
    end
end

local function hookOnce()
    if not loopData.hookedFind then
        local oldFind = workspace.FindFirstChild
        if typeof(oldFind) == "function" and hookfunction then
            hookfunction(oldFind, function(self, ...)
                local args = {...}
                if tostring(args[1]):lower():find("screenshot") then
                    return nil
                end
                return oldFind(self, unpack(args))
            end)
            loopData.hookedFind = true
        end
    end

    if not loopData.hookedRequest then
        local oldRequest = (syn and syn.request) or request or http_request
        if hookfunction and typeof(oldRequest) == "function" then
            hookfunction(oldRequest, function(req)
                if req and req.Url and tostring(req.Url):lower():find("abuse") then
                    return {StatusCode = 200, Body = "Blocked"}
                end
                return oldRequest(req)
            end)
            loopData.hookedRequest = true
        end
    end
end

local function setFlagsOff()
    local flags = {
        "AbuseReportScreenshot",
        "AbuseReportScreenshotPercentage",
        "AbuseReportEnabled",
        "ReportAbuseMenu",
        "EnableAbuseReportScreenshot"
    }
    for _, flag in ipairs(flags) do
        if typeof(setfflag) == "function" then
            pcall(function()
                setfflag(flag, "False")
            end)
        end
    end
    if typeof(setfflag) == "function" then
        setfflag("AbuseReportScreenshotPercentage", "0")
    end
end

local function setFlagsOn()
    if typeof(setfflag) == "function" then
        setfflag("AbuseReportScreenshot", "True")
        setfflag("AbuseReportScreenshotPercentage", "100")
    end
end

hookOnce()
AntiChatLogger()
setFlagsOff()
loopData.running = true
task.spawn(function()
    while loopData.running do
        setFlagsOff()
        task.wait(0.05)
    end
end)
   end
})

Tab:Button({
    Title = "动画提取器",
    Description = "加载脚本",
    Callback = function()
    local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local idLabel = Instance.new("TextLabel")
idLabel.Size = UDim2.new(0, 300, 0, 60)
idLabel.Position = UDim2.new(0.5, -150, 0, 20)
idLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
idLabel.BackgroundTransparency = 0.5
idLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
idLabel.TextSize = 18
idLabel.Text = "当前动画ID: 无"
idLabel.Parent = screenGui

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 120, 0, 40)
copyButton.Position = UDim2.new(0.5, -60, 0, 90)
copyButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.TextSize = 16
copyButton.Text = "复制当前ID"
copyButton.Parent = screenGui

local currentAnimationId = ""

local function copyToClipboard(text)
    local clipboard = setclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if clipboard and text ~= "" then
        clipboard(text)
        idLabel.Text = "已复制ID: " .. text
        wait(2)
        idLabel.Text = "当前动画ID: " .. text
    end
end

local function updateAnimationDisplay(animationId)
    local id = string.match(animationId, "%d+")
    if id then
        currentAnimationId = id
        idLabel.Text = "当前动画ID: " .. id
        copyToClipboard(id)
    end
end

copyButton.MouseButton1Click:Connect(function()
    copyToClipboard(currentAnimationId)
end)

humanoid.AnimationPlayed:Connect(function(animationTrack)
    updateAnimationDisplay(animationTrack.Animation.AnimationId)
end)

for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
    updateAnimationDisplay(track.Animation.AnimationId)
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    currentAnimationId = ""
    idLabel.Text = "当前动画ID: 无"
    
    humanoid.AnimationPlayed:Connect(function(animationTrack)
        updateAnimationDisplay(animationTrack.Animation.AnimationId)
    end)
end)=
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

-- 创建私服
Tab:Button({
    Title = "创建私服",
    Description = "无条件创建私人服务器",
    Callback = function()
        XiProScript = "无条件创建私人服务器"
        loadstring(request({Url="https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/Projet%7BXiPro%7D%23.lua"}).Body)()
    end
})

Tab:Button({
    Title = "esp",
    Description = "加载脚本",
    Callback = function()
    --//Toggle\\--
getgenv().Toggle = true -- This toggles the esp, turning it to false will turn it off
getgenv().TC = false -- This toggles team check, turning it on will turn on team check
local PlayerName = "Name" -- You can decide if you want the Player's name to be a display name which is "DisplayName", or username which is "Name"

--//Variables\\--
local P = game:GetService("Players")
local LP = P.LocalPlayer

--//Debounce\\--
local DB = false

--//Notification\\--
game.StarterGui:SetCore("SendNotification", {
	Title = "Notification",
	Text = "Best ESP by.ExluZive" ,
	Button1 = "Shut Up",
	Duration = math.huge
})

--//Loop\\--
while task.wait() do
	if not getgenv().Toggle then
		break
	end
	if DB then 
		return 
	end
	DB = true

	pcall(function()
		for i,v in pairs(P:GetChildren()) do
			if v:IsA("Player") then
				if v ~= LP then
					if v.Character then

						local pos = math.floor(((LP.Character:FindFirstChild("HumanoidRootPart")).Position - (v.Character:FindFirstChild("HumanoidRootPart")).Position).magnitude)
						-- Credits to Infinite Yield for this part (pos) ^^^^^^

						if v.Character:FindFirstChild("Totally NOT Esp") == nil and v.Character:FindFirstChild("Icon") == nil and getgenv().TC == false then
							--//ESP-Highlight\\--
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

							--//ESP-Text\\--
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
								--//ESP-Highlight\\--
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

								--//ESP-Text\\--
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
								if not v.Character:FindFirstChild("Totally NOT Esp").FillColor == v.TeamColor.Color and not v.Character:FindFirstChild("Icon").TextColor3 == v.TeamColor.Color then
									v.Character:FindFirstChild("Totally NOT Esp").FillColor = v.TeamColor.Color
									v.Character:FindFirstChild("Icon").TextColor3 = v.TeamColor.Color
								else
									if v.Character:FindFirstChild("Totally NOT Esp").Enabled == false and v.Character:FindFirstChild("Icon").Enabled == false then
										v.Character:FindFirstChild("Totally NOT Esp").Enabled = true
										v.Character:FindFirstChild("Icon").Enabled = true
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
			end
		end
	end)

	wait()

	DB = false
end
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

Tab:Button({
    Title = "锁定视角",
    Description = "加载脚本",
    Callback = function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Shiftlock-script-42373"))()
    end
})

Tab:Button({
    Title = "控制玩家",
    Description = "加载脚本",
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/玩家控制 汉化.txt"))()
    end
})