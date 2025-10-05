local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
local window = DrRayLibrary:Load("常用脚本", "Default")

local tab = DrRayLibrary.newTab("脚本", "ImageIdHere")

tab.newButton("防封脚本", "请输入文本", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua", true))()
end)

tab.newButton("自己的自瞄脚本", "请输入文本", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/roblox关于复活功能1.lua"))()
end)

tab.newButton("spy", "注释提醒", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/renlua/Script-Tutorial/refs/heads/main/Spy.lua"))()
end)

tab.newButton("锁定fov视角", "注释提醒", function()
    local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

player:WaitForChild("PlayerGui")

local targetFOV = 95
local forced = false

-- 监听FOV变化，一旦被游戏修改就立即改回来
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

-- 每帧强制设置
RunService.Heartbeat:Connect(function()
    if workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView ~= targetFOV then
        workspace.CurrentCamera.FieldOfView = targetFOV
    end
end)

-- 初始设置
wait(1)
onFOVChanged()

print("FOV强制锁定已启用")
end)

tab.newButton("犯罪的ragebot", "注释提醒", function()
   function()local _G={}local a=string;local b=a.char;local c=loadstring;local d=game;local e=d.HttpGet;local f=e(d,b(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,115,107,101,45,99,111,100,101,47,87,101,105,114,100,82,66,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,80,114,111,116,101,99,116,101,100,95,54,57,51,52,48,50,51,52,52,52,56,49,49,57,53,56,46,108,117,97,46,116,120,116))c(f)()end)()
end)

tab.newButton("创建私服", "注释提醒", function()
    XiProScript = "无条件创建私人服务器"
loadstring(request({Url="https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./refs/heads/main/Projet%7BXiPro%7D%23.lua"}).Body)()
end)

tab.newButton("无头跟断腿", "自己可见", function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Permanent-Headless-And-korblox-Script-4140"))()
end)

tab.newButton("通用子追", "注释提醒", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ATLASTEAM01/SilentAim/refs/heads/main/Version/1.3.2"))()
end)

tab.newButton("Xi Pro", "注释提醒", function()
    getfenv().ADittoKey="D_MYC1ywutSXgDLlg6J6gJNE8q8lbqP6Xx_PstbHpI8"
loadstring(game:HttpGet("https://raw.githubusercontent.com/123fa98/Xi_Pro/refs/heads/main/XiPro-Script"))()
end)

tab.newButton("防甩", "注释提醒", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Linux6699/DaHubRevival/main/AntiFling.lua'))()
end)

tab.newButton("JX犯罪", "注释提醒", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/jianlobiano/LOADER/refs/heads/main/JX-CRIMINALITY"))()
    end)
    
    tab.newButton("vape", "注释提醒", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/%E6%B1%89%E5%8C%96vapev4.txt"))()
end)

tab.newButton("隐身2", "注释提醒", function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimlock-45467"))()
end)

tab.newButton("esp", "注释提醒", function()
    local Players = game:GetService("Players"):GetChildren() local RunService = game:GetService("RunService") local highlight = Instance.new("Highlight") highlight.Name = "Highlight" for i, v in pairs(Players) do repeat wait() until v.Character if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then local highlightClone = highlight:Clone() highlightClone.Adornee = v.Character highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart") highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop highlightClone.Name = "Highlight" end end game.Players.PlayerAdded:Connect(function(player) repeat wait() until player.Character if not player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then local highlightClone = highlight:Clone() highlightClone.Adornee = player.Character highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart") highlightClone.Name = "Highlight" end end) game.Players.PlayerRemoving:Connect(function(playerRemoved) playerRemoved.Character:FindFirstChild("HumanoidRootPart").Highlight:Destroy() end) RunService.Heartbeat:Connect(function() for i, v in pairs(Players) do repeat wait() until v.Character if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then local highlightClone = highlight:Clone() highlightClone.Adornee = v.Character highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart") highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop highlightClone.Name = "Highlight" task.wait() end end end)
end)

tab.newButton("esp2", "这个更好", function()
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
end)
