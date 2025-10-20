---- Script ----

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/LinoriaLib/Test.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/LinoriaLib/addons/ThemeManagerCopy.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Articles-Hub/ROBLOXScript/refs/heads/main/Library/LinoriaLib/addons/SaveManagerCopy.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

function Notification(Message, Time)
if _G.ChooseNotify == "Obsidian" then
Library:Notify(Message, Time or 5)
elseif _G.ChooseNotify == "Roblox" then
game:GetService("StarterGui"):SetCore("SendNotification",{Title = "Error",Text = Message,Icon = "rbxassetid://7733658504",Duration = Time or 5})
end
if _G.NotificationSound then
        local sound = Instance.new("Sound", workspace)
            sound.SoundId = "rbxassetid://4590662766"
            sound.Volume = _G.VolumeTime or 2
            sound.PlayOnRemove = true
            sound:Destroy()
        end
    end

Library:SetDPIScale(85)

local Window = Library:CreateWindow({
    Title = "墨水游戏",
    Center = true,
    AutoShow = true,
    Resizable = true,
    Footer = "Rb脚本中心 Yungengxin",
	Icon = 105933835532108,
	AutoLock = false,
    ShowCustomCursor = true,
    NotifySide = "Right",
    TabPadding = 2,
    MenuFadeTime = 0
})

Tabs = {
	Tab = Window:AddTab("主要功能", "rbxassetid://7734053426"),
	Tab1 = Window:AddTab("辅助功能", "rbxassetid://4370318685"),
	["UI Settings"] = Window:AddTab("UI 设置", "rbxassetid://7733955511")
}

local GreenGroup = Tabs.Tab:AddLeftGroupbox("红绿灯功能")

GreenGroup:AddButton("传送到终点", function()
if workspace:FindFirstChild("RedLightGreenLight") and workspace.RedLightGreenLight:FindFirstChild("sand") and workspace.RedLightGreenLight.sand:FindFirstChild("crossedover") then
local pos = workspace.RedLightGreenLight.sand.crossedover.Position + Vector3.new(0, 5, 0)
Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos, pos + Vector3.new(0, 0, -1))
end
end)

GreenGroup:AddButton("帮助别人到终点", function()
if Loading then return end
Loading = true
for _, v in pairs(game:GetService("Players"):GetPlayers()) do
if v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("CarryPrompt") and v.Character.HumanoidRootPart.CarryPrompt.Enabled == true then
if v.Character:FindFirstChild("SafeRedLightGreenLight") == nil then
Player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
wait(0.3)
repeat task.wait(0.1)
fireproximityprompt(v.Character.HumanoidRootPart:FindFirstChild("CarryPrompt"))
until v.Character.HumanoidRootPart.CarryPrompt.Enabled == false
wait(0.5)
if workspace:FindFirstChild("RedLightGreenLight") and workspace.RedLightGreenLight:FindFirstChild("sand") and workspace.RedLightGreenLight.sand:FindFirstChild("crossedover") then
local pos = workspace.RedLightGreenLight.sand.crossedover.Position + Vector3.new(0, 5, 0)
Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos, pos + Vector3.new(0, 0, -1))
end
wait(0.4)
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClickedButton"):FireServer({tryingtoleave = true})
break
end
end
end
Loading = false
end)

GreenGroup:AddButton("绕过反作弊", function()
local Bypass
local isAntiCheat = false

local suspendedThreads = {}
for _, v in pairs(getreg()) do
    if typeof(v) == "thread" then
        local source = debug.info(v, 1, "s")
        if not source then continue end
        
        if source:match("%.Core.Anti") or source:match("%.Plugins.Anti_Cheat") then
            isAntiCheat = true
            table.insert(suspendedThreads, v)
        end
        
        if source:match("%.BAC_") then
            Bypass = "BAC"
            pcall(debug.sethook, v, function() 
                error("Thread Suspended", 0) 
            end, "crl")
            pcall(coroutine.close, v)
            for k, obj in pairs(getgc()) do
                if rawequal(obj, v) then
                    getgc()[k] = nil
                end
            end
        end
    end
end

task.spawn(function()
    task.wait(2)
    for _, thread in ipairs(suspendedThreads) do
        pcall(debug.sethook, thread, function() end, "crl")
    end
end)

if not isAntiCheat then
    local gf
    gf = hookfunction(getrenv().getfenv, function(...)
        local level = ...
        if not checkcaller() and typeof(level) == "number" then
            Bypass = "getfenv"
            local fakeEnv = {
                __index = function(t, k)
                    if k == "getfenv" then return function() return fakeEnv end end
                    if k == "coroutine" then return { running = function() return nil end } end
                    return getfenv(2)[k]
                end
            }
            return setmetatable({}, fakeEnv)
        end
        return gf(...)
    end)
    
    local gre
    gre = hookfunction(getrenv(), function()
        if not checkcaller() then
            local fakeRenv = {}
            for k, v in pairs(gre()) do
                if k ~= "getfenv" then
                    fakeRenv[k] = v
                end
            end
            return fakeRenv
        end
        return gre()
    end)
end

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local callingScript = getcallingscript()
    
    if callingScript and tostring(callingScript) == "CameraModule" then 
        return OldNamecall(self, ...) 
    end
    
    local success, result = pcall(OldNamecall, self, ...)
    
    if not checkcaller() and not success then
        Bypass = "AntiHook"
        local method = getnamecallmethod()
        if method == "Kick" then
            return nil
        elseif method == "Destroy" then
            return false
        else
            return true, "BYPASS", 1, math.random(1000)
        end
    end
    
    return result
end)

local memoryGuard = task.spawn(function()
    while true do
        task.wait(30)
        pcall(function()
            for k, v in pairs(getreg()) do
                if typeof(v) == "thread" and coroutine.status(v) == "dead" then
                    getreg()[k] = nil
                end
            end
            if math.random(1, 10) == 1 then
                debug.setmemoryprotection(game, math.random(1, 255))
            end
        end)
    end
end)

local antiDetection = {
    __gc = function()
        if Bypass then
            task.spawn(function()
                task.wait(1)
                loadstring(game:HttpGet("你的脚本链接"))()
            end)
        end
    end
}
debug.setmetatable(antiDetection, antiDetection)

print("Bypass Activated: " .. tostring(Bypass or "Stealth Mode"))
end)

GreenGroup:AddToggle("Auto Help Player", {
    Text = "自动帮助别人",
    Default = false, 
    Callback = function(Value) 
_G.AutoHelpPlayer = Value
while _G.AutoHelpPlayer do
for _, v in pairs(game:GetService("Players"):GetPlayers()) do
if v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("CarryPrompt") and v.Character.HumanoidRootPart.CarryPrompt.Enabled == true then
if v.Character:FindFirstChild("SafeRedLightGreenLight") == nil then
Player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
wait(0.3)
repeat task.wait(0.1)
fireproximityprompt(v.Character.HumanoidRootPart:FindFirstChild("CarryPrompt"))
until v.Character.HumanoidRootPart.CarryPrompt.Enabled == false
wait(0.5)
if workspace:FindFirstChild("RedLightGreenLight") then
Player.Character.HumanoidRootPart.CFrame = CFrame.new(-75, 1025, 143)
end
wait(0.4)
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClickedButton"):FireServer({tryingtoleave = true})
break
end
end
end
task.wait()
end
    end
})

GreenGroup:AddButton("整蛊别人", function()
if Loading1 then return end
Loading1 = true
for _, v in pairs(game:GetService("Players"):GetPlayers()) do
if v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("CarryPrompt") and v.Character.HumanoidRootPart.CarryPrompt.Enabled == true then
if v.Character:FindFirstChild("SafeRedLightGreenLight") == nil then
Player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
wait(0.3)
repeat task.wait(0.1)
fireproximityprompt(v.Character.HumanoidRootPart:FindFirstChild("CarryPrompt"))
until v.Character.HumanoidRootPart.CarryPrompt.Enabled == false
wait(0.5)
if workspace:FindFirstChild("RedLightGreenLight") then
Player.Character.HumanoidRootPart.CFrame = CFrame.new(-84, 1023, -537)
end
wait(0.4)
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClickedButton"):FireServer({tryingtoleave = true})
break
end
end
end
Loading1 = false
end)

GreenGroup:AddToggle("Auto Troll Player", {
    Text = "自动整蛊别人",
    Default = false, 
    Callback = function(Value) 
_G.AutoTrollPlayer = Value
while _G.AutoTrollPlayer do
for _, v in pairs(game:GetService("Players"):GetPlayers()) do
if v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("CarryPrompt") and v.Character.HumanoidRootPart.CarryPrompt.Enabled == true then
if v.Character:FindFirstChild("SafeRedLightGreenLight") == nil then
Player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
wait(0.3)
repeat task.wait(0.1)
fireproximityprompt(v.Character.HumanoidRootPart:FindFirstChild("CarryPrompt"))
until v.Character.HumanoidRootPart.CarryPrompt.Enabled == false
wait(0.5)
if workspace:FindFirstChild("RedLightGreenLight") then
Player.Character.HumanoidRootPart.CFrame = CFrame.new(-84, 1023, -537)
end
wait(0.4)
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClickedButton"):FireServer({tryingtoleave = true})
break
end
end
end
task.wait()
end
    end
})


local DalgonaGroup = Tabs.Tab:AddRightGroupbox("糖饼功能")

DalgonaGroup:AddButton("完成糖饼游戏", function()
local DalgonaClientModule = game.ReplicatedStorage.Modules.Games.DalgonaClient
for i, v in pairs(getreg()) do
    if typeof(v) == "function" and islclosure(v) then
        if getfenv(v).script == DalgonaClientModule then
            if getinfo(v).nups == 73 then
                setupvalue(v, 31, 9e9)
            end
        end
    end
end
end)

local TugwarGroup = Tabs.Tab:AddLeftGroupbox("拔河/躲猫猫功能")

TugwarGroup:AddToggle("AutoTug of War", {
    Text = "自动拔河",
    Default = false, 
    Callback = function(Value) 
_G.TugOfWar = Value
while _G.TugOfWar do
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable"):FireServer({GameQTE = true})
task.wait()
end
    end
})

TugwarGroup:AddDivider()

TugwarGroup:AddToggle("Esp DoorExit", {
    Text = "出口 Esp",
    Default = false, 
    Callback = function(Value) 
_G.DoorExit = Value
if _G.DoorExit == false then
if workspace:FindFirstChild("HideAndSeekMap") then
	for i, v in pairs(workspace:FindFirstChild("HideAndSeekMap"):GetChildren()) do
		if v.Name == "NEWFIXEDDOORS" then
			for k, m in pairs(v:GetChildren()) do
				if m.Name:find("Floor") and m:FindFirstChild("EXITDOORS") then
					for _, a in pairs(m:FindFirstChild("EXITDOORS"):GetChildren()) do
						if a:IsA("Model") and a:FindFirstChild("DoorRoot") then
							for _, z in pairs(a:FindFirstChild("DoorRoot"):GetChildren()) do
								if z.Name:find("Esp_") then
									z:Destroy()
								end
							end
						end
					end
				end
			end
		end
	end
end
end
while _G.DoorExit do
if workspace:FindFirstChild("HideAndSeekMap") then
for i, v in pairs(workspace:FindFirstChild("HideAndSeekMap"):GetChildren()) do
if v.Name == "NEWFIXEDDOORS" then
for k, m in pairs(v:GetChildren()) do
if m.Name:find("Floor") and m:FindFirstChild("EXITDOORS") then
for _, a in pairs(m:FindFirstChild("EXITDOORS"):GetChildren()) do
if a:IsA("Model") and a:FindFirstChild("DoorRoot") then
if a.DoorRoot:FindFirstChild("Esp_Highlight") then
	a.DoorRoot:FindFirstChild("Esp_Highlight").FillColor = Colorlight or Color3.fromRGB(255, 255, 255)
	a.DoorRoot:FindFirstChild("Esp_Highlight").OutlineColor = Colorlight or Color3.fromRGB(255, 255, 255)
end
if _G.EspHighlight == true and a.DoorRoot:FindFirstChild("Esp_Highlight") == nil then
	local Highlight = Instance.new("Highlight")
	Highlight.Name = "Esp_Highlight"
	Highlight.FillColor = Color3.fromRGB(255, 255, 255) 
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
	Highlight.FillTransparency = 0.5
	Highlight.OutlineTransparency = 0
	Highlight.Adornee = a
	Highlight.Parent = a.DoorRoot
	elseif _G.EspHighlight == false and a.DoorRoot:FindFirstChild("Esp_Highlight") then
	a.DoorRoot:FindFirstChild("Esp_Highlight"):Destroy()
end
if a.DoorRoot:FindFirstChild("Esp_Gui") and a.DoorRoot["Esp_Gui"]:FindFirstChild("TextLabel") then
	a.DoorRoot["Esp_Gui"]:FindFirstChild("TextLabel").Text = 
	        (_G.EspName == true and "出口" or "")..
            (_G.EspDistance == true and "\n距离 ("..string.format("%.1f", (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - a.DoorRoot.Position).Magnitude).."m)" or "")
    a.DoorRoot["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
    a.DoorRoot["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
end
if _G.EspGui == true and a.DoorRoot:FindFirstChild("Esp_Gui") == nil then
	GuiPlayerEsp = Instance.new("BillboardGui", a.DoorRoot)
	GuiPlayerEsp.Adornee = a.DoorRoot
	GuiPlayerEsp.Name = "Esp_Gui"
	GuiPlayerEsp.Size = UDim2.new(0, 100, 0, 150)
	GuiPlayerEsp.AlwaysOnTop = true
	GuiPlayerEsp.StudsOffset = Vector3.new(0, 3, 0)
	GuiPlayerEspText = Instance.new("TextLabel", GuiPlayerEsp)
	GuiPlayerEspText.BackgroundTransparency = 1
	GuiPlayerEspText.Font = Enum.Font.Code
	GuiPlayerEspText.Size = UDim2.new(0, 100, 0, 100)
	GuiPlayerEspText.TextSize = 15
	GuiPlayerEspText.TextColor3 = Color3.new(0,0,0) 
	GuiPlayerEspText.TextStrokeTransparency = 0.5
	GuiPlayerEspText.Text = ""
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.new(0, 0, 0)
	UIStroke.Thickness = 1.5
	UIStroke.Parent = GuiPlayerEspText
	elseif _G.EspGui == false and a.DoorRoot:FindFirstChild("Esp_Gui") then
	a.DoorRoot:FindFirstChild("Esp_Gui"):Destroy()
end
end
end
end
end
end
end
end
task.wait()
end
    end
})

TugwarGroup:AddToggle("Esp Key", {
    Text = "钥匙 Esp",
    Default = false, 
    Callback = function(Value) 
_G.DoorKey = Value
if _G.DoorKey == false then
for _, a in pairs(workspace.Effects:GetChildren()) do
if a.Name:find("DroppedKey") and a:FindFirstChild("Handle") then
for _, v in pairs(a:FindFirstChild("Handle"):GetChildren()) do
if v.Name:find("Esp_") then
v:Destroy()
end
end
end
end
end
while _G.DoorKey do
for _, a in pairs(workspace.Effects:GetChildren()) do
if a.Name:find("DroppedKey") and a:FindFirstChild("Handle") then 
if a.Handle:FindFirstChild("Esp_Highlight") then
	a.Handle:FindFirstChild("Esp_Highlight").FillColor = Colorlight or Color3.fromRGB(255, 255, 255)
	a.Handle:FindFirstChild("Esp_Highlight").OutlineColor = Colorlight or Color3.fromRGB(255, 255, 255)
end
if _G.EspHighlight == true and a.Handle:FindFirstChild("Esp_Highlight") == nil then
	local Highlight = Instance.new("Highlight")
	Highlight.Name = "Esp_Highlight"
	Highlight.FillColor = Color3.fromRGB(255, 255, 255) 
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
	Highlight.FillTransparency = 0.5
	Highlight.OutlineTransparency = 0
	Highlight.Adornee = a
	Highlight.Parent = a.Handle
	elseif _G.EspHighlight == false and a.Handle:FindFirstChild("Esp_Highlight") then
	a.Handle:FindFirstChild("Esp_Highlight"):Destroy()
end
if a.Handle:FindFirstChild("Esp_Gui") and a.Handle["Esp_Gui"]:FindFirstChild("TextLabel") then
	a.Handle["Esp_Gui"]:FindFirstChild("TextLabel").Text = 
	        (_G.EspName == true and "钥匙" or "")..
            (_G.EspDistance == true and "\n距离 ("..string.format("%.1f", (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - a.Handle.Position).Magnitude).."m)" or "")
    a.Handle["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
    a.Handle["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
end
if _G.EspGui == true and a.Handle:FindFirstChild("Esp_Gui") == nil then
	GuiPlayerEsp = Instance.new("BillboardGui", a.Handle)
	GuiPlayerEsp.Adornee = a.Handle
	GuiPlayerEsp.Name = "Esp_Gui"
	GuiPlayerEsp.Size = UDim2.new(0, 100, 0, 150)
	GuiPlayerEsp.AlwaysOnTop = true
	GuiPlayerEsp.StudsOffset = Vector3.new(0, 3, 0)
	GuiPlayerEspText = Instance.new("TextLabel", GuiPlayerEsp)
	GuiPlayerEspText.BackgroundTransparency = 1
	GuiPlayerEspText.Font = Enum.Font.Code
	GuiPlayerEspText.Size = UDim2.new(0, 100, 0, 100)
	GuiPlayerEspText.TextSize = 15
	GuiPlayerEspText.TextColor3 = Color3.new(0,0,0) 
	GuiPlayerEspText.TextStrokeTransparency = 0.5
	GuiPlayerEspText.Text = ""
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.new(0, 0, 0)
	UIStroke.Thickness = 1.5
	UIStroke.Parent = GuiPlayerEspText
	elseif _G.EspGui == false and a.Handle:FindFirstChild("Esp_Gui") then
	a.Handle:FindFirstChild("Esp_Gui"):Destroy()
end
end
end
task.wait()
end
    end
})

TugwarGroup:AddToggle("Hide", {
    Text = "躲藏方 Esp",
    Default = false, 
    Callback = function(Value) 
_G.HidePlayer = Value
if _G.HidePlayer == false then
	for i, v in pairs(game:GetService("Players"):GetChildren()) do
		if v ~= game:GetService("Players").LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
			for i, n in pairs(v.Character:FindFirstChild("Head"):GetChildren()) do
				if n.Name:find("Esp_") then
					n:Destroy()
				end
			end
		end
	end
end
while _G.HidePlayer do
for i, v in pairs(game:GetService("Players"):GetChildren()) do
if v ~= game:GetService("Players").LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
if not v:GetAttribute("IsHider") then
	for i, n in pairs(v.Character:FindFirstChild("Head"):GetChildren()) do
		if n.Name:find("Esp_") then
			n:Destroy()
		end
	end
end
if v:GetAttribute("IsHider") then
if v.Character.Head:FindFirstChild("Esp_Highlight") then
	v.Character.Head:FindFirstChild("Esp_Highlight").FillColor = Colorlight or Color3.fromRGB(255, 255, 255)
	v.Character.Head:FindFirstChild("Esp_Highlight").OutlineColor = Colorlight or Color3.fromRGB(255, 255, 255)
end
if _G.EspHighlight == true and v.Character.Head:FindFirstChild("Esp_Highlight") == nil then
	local Highlight = Instance.new("Highlight")
	Highlight.Name = "Esp_Highlight"
	Highlight.FillColor = Color3.fromRGB(255, 255, 255) 
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
	Highlight.FillTransparency = 0.5
	Highlight.OutlineTransparency = 0
	Highlight.Adornee = v.Character
	Highlight.Parent = v.Character.Head
	elseif _G.EspHighlight == false and v.Character.Head:FindFirstChild("Esp_Highlight") then
	v.Character.Head:FindFirstChild("Esp_Highlight"):Destroy()
end
if v.Character.Head:FindFirstChild("Esp_Gui") and v.Character.Head["Esp_Gui"]:FindFirstChild("TextLabel") then
	v.Character.Head["Esp_Gui"]:FindFirstChild("TextLabel").Text = 
	        v.Name.." (躲藏方)"..
            (_G.EspDistance == true and "\n距离 ("..string.format("%.1f", (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude).."m)" or "")..
            (_G.EspHealth == true and "\nHealth ("..string.format("%.0f", v.Humanoid.Health)..")" or "")
    v.Character.Head["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
    v.Character.Head["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
end
if _G.EspGui == true and v.Character.Head:FindFirstChild("Esp_Gui") == nil then
	GuiPlayerEsp = Instance.new("BillboardGui", v.Character.Head)
	GuiPlayerEsp.Adornee = v.Character.Head
	GuiPlayerEsp.Name = "Esp_Gui"
	GuiPlayerEsp.Size = UDim2.new(0, 100, 0, 150)
	GuiPlayerEsp.AlwaysOnTop = true
	GuiPlayerEsp.StudsOffset = Vector3.new(0, 3, 0)
	GuiPlayerEspText = Instance.new("TextLabel", GuiPlayerEsp)
	GuiPlayerEspText.BackgroundTransparency = 1
	GuiPlayerEspText.Font = Enum.Font.Code
	GuiPlayerEspText.Size = UDim2.new(0, 100, 0, 100)
	GuiPlayerEspText.TextSize = 15
	GuiPlayerEspText.TextColor3 = Color3.new(0,0,0) 
	GuiPlayerEspText.TextStrokeTransparency = 0.5
	GuiPlayerEspText.Text = ""
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.new(0, 0, 0)
	UIStroke.Thickness = 1.5
	UIStroke.Parent = GuiPlayerEspText
	elseif _G.EspGui == false and v.Character.Head:FindFirstChild("Esp_Gui") then
	v.Character.Head:FindFirstChild("Esp_Gui"):Destroy()
end
end
end
end
task.wait()
end
    end
})

TugwarGroup:AddToggle("Hide", {
    Text = "追逐方 Esp",
    Default = false, 
    Callback = function(Value) 
_G.SeekPlayer = Value
if _G.SeekPlayer == false then
	for i, v in pairs(game:GetService("Players"):GetChildren()) do
		if v ~= game:GetService("Players").LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
			for i, n in pairs(v.Character:FindFirstChild("Head"):GetChildren()) do
				if n.Name:find("Esp_") then
					n:Destroy()
				end
			end
		end
	end
end
while _G.SeekPlayer do
for i, v in pairs(game:GetService("Players"):GetChildren()) do
if v ~= game:GetService("Players").LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
if not v:GetAttribute("IsHunter") then
for i, n in pairs(v.Character:FindFirstChild("Head"):GetChildren()) do
	if n.Name:find("Esp_") then
		n:Destroy()
	end
end
end
if v:GetAttribute("IsHunter") then
if v.Character:FindFirstChild("Esp_Highlight1") then
	v.Character:FindFirstChild("Esp_Highlight1").FillColor = Colorlight or Color3.fromRGB(255, 255, 255)
	v.Character:FindFirstChild("Esp_Highlight1").OutlineColor = Colorlight or Color3.fromRGB(255, 255, 255)
end
if _G.EspHighlight == true and v.Character:FindFirstChild("Esp_Highlight1") == nil then
	local Highlight = Instance.new("Highlight")
	Highlight.Name = "Esp_Highlight1"
	Highlight.FillColor = Color3.fromRGB(255, 255, 255) 
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
	Highlight.FillTransparency = 0.5
	Highlight.OutlineTransparency = 0
	Highlight.Adornee = v.Character
	Highlight.Parent = v.Character.Head
	elseif _G.EspHighlight == false and v.Character:FindFirstChild("Esp_Highlight1") then
	v.Character:FindFirstChild("Esp_Highlight1"):Destroy()
end
if v.Character.Head:FindFirstChild("Esp_Gui1") and v.Character.Head["Esp_Gui1"]:FindFirstChild("TextLabel") then
	v.Character.Head["Esp_Gui1"]:FindFirstChild("TextLabel").Text = 
	        v.Name.." (追逐方)"..
            (_G.EspDistance == true and "\n距离 ("..string.format("%.1f", (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude).."m)" or "")
    v.Character.Head["Esp_Gui1"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
    v.Character.Head["Esp_Gui1"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
end
if _G.EspGui == true and v.Character.Head:FindFirstChild("Esp_Gui1") == nil then
	local GuiPlayerEsp = Instance.new("BillboardGui", v.Character.Head)
	GuiPlayerEsp.Adornee = v.Character.Head
	GuiPlayerEsp.Name = "Esp_Gui1"
	GuiPlayerEsp.Size = UDim2.new(0, 100, 0, 150)
	GuiPlayerEsp.AlwaysOnTop = true
	GuiPlayerEsp.StudsOffset = Vector3.new(0, 3, 0)
	local GuiPlayerEspText = Instance.new("TextLabel", GuiPlayerEsp)
	GuiPlayerEspText.BackgroundTransparency = 1
	GuiPlayerEspText.Font = Enum.Font.Code
	GuiPlayerEspText.Size = UDim2.new(0, 100, 0, 100)
	GuiPlayerEspText.TextSize = 15
	GuiPlayerEspText.TextColor3 = Color3.new(0,0,0) 
	GuiPlayerEspText.TextStrokeTransparency = 0.5
	GuiPlayerEspText.Text = ""
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.new(0, 0, 0)
	UIStroke.Thickness = 1.5
	UIStroke.Parent = GuiPlayerEspText
	elseif _G.EspGui == false and v.Character.Head:FindFirstChild("Esp_Gui1") then
	v.Character.Head:FindFirstChild("Esp_Gui1"):Destroy()
end
end
end
end
task.wait()
end
    end
})

TugwarGroup:AddDivider()

TugwarGroup:AddToggle("Auto Teleport Hide", {
    Text = "自动传送躲藏者",
    Default = false, 
    Callback = function(Value) 
_G.AutoTeleportHide = Value
while _G.AutoTeleportHide do
for i, v in pairs(game:GetService("Players"):GetChildren()) do
if v ~= game:GetService("Players").LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
if v:GetAttribute("IsHider") and v.Character.Humanoid.Health > 0 then
if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.MoveDirection.Magnitude > 0 then
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0, 0, -7)
else
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character:FindFirstChild("HumanoidRootPart").CFrame
end
break
end
end
end
task.wait()
end
    end
})

TugwarGroup:AddButton("传送躲藏者", function()
for i, v in pairs(game:GetService("Players"):GetChildren()) do
if v ~= game:GetService("Players").LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
if v:GetAttribute("IsHider") and v.Character.Humanoid.Health > 0 then
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
break
end
end
end
end)

TugwarGroup:AddButton("传送全部钥匙", function()
local OldCFrame = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
for _, a in pairs(workspace.Effects:GetChildren()) do
if a.Name:find("DroppedKey") and a:FindFirstChild("Handle") then
if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Head") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") then
if game:GetService("Players").LocalPlayer:GetAttribute("IsHider") and game:GetService("Players").LocalPlayer.Character.Humanoid.Health > 0 then
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = a:FindFirstChild("Handle").CFrame
wait(0.5)
end
end
end
end
if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Head") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = OldCFrame
end
end)

local JumpropeGroup = Tabs.Tab:AddLeftGroupbox("跳绳功能")

JumpropeGroup:AddButton("完成跳绳", function()
if workspace:WaitForChild("JumpRope") then
local pos = workspace.JumpRope.Important.Model.LEGS.Position
Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos, pos + Vector3.new(0, 0, -1))
end
end)

local GlassBridgeGroup = Tabs.Tab:AddRightGroupbox("玻璃桥功能")

GlassBridgeGroup:AddButton("真假玻璃识别", function()
local GlassHolder = workspace:WaitForChild("GlassBridge"):WaitForChild("GlassHolder")
for i, v in pairs(GlassHolder:GetChildren()) do
    for k, j in pairs(v:GetChildren()) do
        if j:IsA("Model") and j.PrimaryPart then
            local Color = j.PrimaryPart:GetAttribute("exploitingisevil") and Color3.fromRGB(248, 87, 87) or Color3.fromRGB(28, 235, 87)
            j.PrimaryPart.Color = Color
            j.PrimaryPart.Transparency = 0
            j.PrimaryPart.Material = Enum.Material.Neon
        end
    end
end
end)

GlassBridgeGroup:AddButton("完成玻璃桥", function()
if workspace:WaitForChild("GlassBridge") then
local pos = workspace.GlassBridge.End.PrimaryPart.Position + Vector3.new(0, 8, 0)
Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos, pos + Vector3.new(0, 0, -1))
end
end)

local MingleGroup = Tabs.Tab:AddLeftGroupbox("旋转木马")

MingleGroup:AddToggle("AutoMingle", {
    Text = "自动扭脖子",
    Default = false, 
    Callback = function(Value) 
_G.AutoMingle = Value
while _G.AutoMingle do
for i, v in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
	if v.Name == "RemoteForQTE" then
        v:FireServer()
    end
end
task.wait()
end
    end
})

local RebelGroup = Tabs.Tab:AddRightGroupbox("反叛功能")


RebelGroup:AddToggle("WallCheck", {
    Text = "墙壁检测",
    Default = false, 
    Callback = function(Value) 
_G.WallCheck = Value
    end
})

RebelGroup:AddToggle("Aimbot Guard", {
    Text = "自瞄守卫",
    Default = false, 
    Callback = function(Value) 
_G.Aimbot = Value
while _G.Aimbot do
local DistanceMath, TargetNpc = math.huge, nil
for i,v in pairs(workspace.Live:GetChildren()) do
	if v.Name:find("Guard") or v.Name:find("Third") then
		if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			if _G.WallCheck == true and not CheckWall(v:FindFirstChild("Head")) then 
				continue
			end
			local Distance = (game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.HumanoidRootPart.Position).Magnitude
			if Distance < DistanceMath then
				TargetNpc, DistanceMath = v, Distance
			end
		end
	end
end
if TargetNpc then
if game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and TargetNpc:FindFirstChild("Head") and TargetNpc:FindFirstChild("Humanoid") then
game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.CurrentCamera.CFrame.Position, game.Workspace.CurrentCamera.CFrame.Position + (TargetNpc["Head"].Position - game.Workspace.CurrentCamera.CFrame.Position).unit)
end
end
task.wait()
end
    end
})

RebelGroup:AddToggle("Bring Guard", {
    Text = "带来守卫",
    Default = false, 
    Callback = function(Value) 
_G.Bring = Value
while _G.Bring do
for i,v in pairs(workspace.Live:GetChildren()) do
	if v.Name:find("Guard") or v.Name:find("Third") then
		if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			v.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -6)
		end
	end
end
task.wait()
end
    end
})

RebelGroup:AddToggle("Inf Ammo", {
    Text = "无限子弹",
    Default = false, 
    Callback = function(Value) 
_G.InfAmmo = Value
while _G.InfAmmo do
for i, v in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
if v.Name == "InfoMP5Client" and v:FindFirstChild("Bullets") then
v.Bullets.Value = 999999999
end
end
task.wait()
end
    end
})

local EmotesGroup = Tabs.Tab:AddRightGroupbox("表情功能")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local EmotesFolder = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Emotes")
local LocalPlayer = Players.LocalPlayer

local emoteNames = {}
local emoteIdMap = {}
local currentSpeed = 1.2 -- Default emote speed
local currentTrack = nil -- Track reference to stop or adjust speed

-- Populate emote list
for _, emote in ipairs(EmotesFolder:GetChildren()) do
    if emote:IsA("Animation") then
        table.insert(emoteNames, emote.Name)
        emoteIdMap[emote.Name] = emote.AnimationId
    end
end

-- Dropdown to select and play an emote
EmotesGroup:AddDropdown("NotifySide", {
    Text = "使用表情",
    Values = emoteNames,
    Default = emoteNames[1],
    Multi = false,
    Callback = function(selected)
        print("Selected emote:", selected)

        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Stop any currently playing animations
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end

            -- Play selected emote
            local anim = Instance.new("Animation")
            anim.AnimationId = emoteIdMap[selected]
            currentTrack = humanoid:LoadAnimation(anim)
            currentTrack:Play()
            currentTrack:AdjustSpeed(currentSpeed)
        end
    end
})

-- Button to stop emotes
EmotesGroup:AddButton("暂停此表情", function()
    print("Stop Emote clicked")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        currentTrack = nil
    end
end)

-- Slider to adjust emote speed
EmotesGroup:AddSlider("Emote Speed", {
    Text = "设置表情播放速度",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Compact = true,
    Callback = function(value)
        print("Speed set to", value)
        currentSpeed = value
        if currentTrack then
            currentTrack:AdjustSpeed(currentSpeed)
        end
    end
})


local MiscTab = "Misc"
local Misc1Group = Tabs.Tab1:AddLeftGroupbox("辅助功能")


------------------------------------------------------------------------
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
local Info = Tabs["UI Settings"]:AddRightGroupbox("Info")

MenuGroup:AddDropdown("NotifySide", {
    Text = "Notification Side",
    Values = {"Left", "Right"},
    Default = "Right",
    Multi = false,
    Callback = function(Value)
Library:SetNotifySide(Value)
    end
})

_G.ChooseNotify = "Obsidian"
MenuGroup:AddDropdown("NotifyChoose", {
    Text = "Notification Choose",
    Values = {"Obsidian", "Roblox"},
    Default = "",
    Multi = false,
    Callback = function(Value)
_G.ChooseNotify = Value
    end
})

_G.NotificationSound = true
MenuGroup:AddToggle("NotifySound", {
    Text = "Notification Sound",
    Default = true, 
    Callback = function(Value) 
_G.NotificationSound = Value 
    end
})

MenuGroup:AddSlider("Volume Notification", {
    Text = "Volume Notification",
    Default = 2,
    Min = 2,
    Max = 10,
    Rounding = 1,
    Compact = true,
    Callback = function(Value)
_G.VolumeTime = Value
    end
})

MenuGroup:AddToggle("KeybindMenuOpen", {Default = false, Text = "Open Keybind Menu", Callback = function(Value) Library.KeybindFrame.Visible = Value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {Default = "RightShift", NoUI = true, Text = "Menu keybind"})
_G.LinkJoin = loadstring(game:HttpGet("https://pastefy.app/2LKQlhQM/raw"))()
MenuGroup:AddButton("Copy Link Discord", function()
    if setclipboard then
        setclipboard(_G.LinkJoin["Discord"])
        Library:Notify("Copied discord link to clipboard!")
    else
        Library:Notify("Discord link: ".._G.LinkJoin["Discord"], 10)
    end
end):AddButton("Copy Link Zalo", function()
    if setclipboard then
        setclipboard(_G.LinkJoin["Zalo"])
        Library:Notify("Copied Zalo link to clipboard!")
    else
        Library:Notify("Zalo link: ".._G.LinkJoin["Zalo"], 10)
    end
end)
MenuGroup:AddButton("Unload", function() Library:Unload() end)

Info:AddLabel("Counter [ "..game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game.Players.LocalPlayer).." ]", true)
Info:AddLabel("Executor [ "..identifyexecutor().." ]", true)
Info:AddLabel("Job Id [ "..game.JobId.." ]", true)
Info:AddDivider()
Info:AddButton("Copy JobId", function()
    if setclipboard then
        setclipboard(tostring(game.JobId))
        Library:Notify("Copied Success")
    else
        Library:Notify(tostring(game.JobId), 10)
    end
end)

Info:AddInput("Join Job", {
    Default = "Nah",
    Numeric = false,
    Text = "Join Job",
    Placeholder = "UserJobId",
    Callback = function(Value)
_G.JobIdJoin = Value
    end
})

Info:AddButton("Join JobId", function()
game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, _G.JobIdJoin, game.Players.LocalPlayer)
end)

Info:AddButton("Copy Join JobId", function()
    if setclipboard then
        setclipboard('game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, '..game.JobId..", game.Players.LocalPlayer)")
        Library:Notify("Copied Success") 
    else
        Library:Notify(tostring(game.JobId), 10)
    end
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()