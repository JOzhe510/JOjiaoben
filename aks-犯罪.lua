local infa = loadstring(game:HttpGet('https://raw.githubusercontent.com/bestuserpc/test/refs/heads/main/testing.lua'))()
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

Window = Library:CreateWindow({
	Title = "Criminol",
	Center = true,
	AutoShow = true,
	TabPadding = 4,
	MenuFadeTime = 0.2
})

Tabs = {
	Main = Window:AddTab('Main'),
	Combat = Window:AddTab('Combat'),
	Visuals = Window:AddTab('Visuals'),
	Movement = Window:AddTab('Movement'),
	Infection = Window:AddTab('Infection'),
	Farm = Window:AddTab('Farm'),
	Misc = Window:AddTab('Misc'),
	Settings = Window:AddTab('Settings')
}

plrs = game:GetService("Players")
me = plrs.LocalPlayer
run = game:GetService("RunService")
input = game:GetService("UserInputService")
camera = workspace.CurrentCamera
tween = game:GetService("TweenService")
functions = {}
remotes = {}

SectionSettings = {
	SilentAim = {
		DrawSize = 50,
		TargetPart = "Head",
		CheckWhitelist = false,
		CheckWall = false,
		UseHitChance = false,
		HitChance = 80,
		CheckTeam = false,
		DrawCircle = false,
		DrawColor = Color3.fromRGB(255, 0, 0),
		HighlightEnabled = false,
		HighlightColor = Color3.fromRGB(255, 0, 0)
	},
	MeleeAura = {
		ShowAnim = true,
		Distance = 1,
		TargetPart = "Head",
		CheckWhitelist = false,
		CheckTeam = false,
		HighlightEnabled = false,
		HighlightColor = Color3.fromRGB(255, 0, 0)
	},
	Ragebot = {
		CheckWhitelist = false,
		CheckTarget = false,
		CheckTeam = false,
		DownedCheck = true,
		HighlightEnabled = false,
		HighlightColor = Color3.fromRGB(255, 0, 0)
	},
	AimBot = {
		Draw = false,
		DrawSize = 50,
		DrawColor = Color3.fromRGB(255, 0, 0),
		TargetPart = "Head",
		CheckWall = false,
		CheckTeam = false,
		CheckWhitelist = false,
		Smooth = false,
		SmoothSize = 0.5,
		Velocity = false
	},
	PepperSprayAura = {
		CheckWhitelist = false
	}
}

ValidAimbotTargetParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
ValidSilentTargetParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
ValidMeleeTargetParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
remote1 = game:GetService("ReplicatedStorage").Events["XMHH.2"]
remote2 = game:GetService("ReplicatedStorage").Events["XMHH2.2"]

MainLeft = Tabs.Main:AddLeftGroupbox('Main')

CodersButton = MainLeft:AddButton({
	Text = "Coders",
	Func = function()
		warn("Coders script: family_aks, thx hubstudioinjection for fling, esp and thx imbetter1_1 for free key system, infinite stamina, long fly and more scripts!!")
	end
})

DiscordButton = MainLeft:AddButton({
	Text = "Discord",
	Func = function()
		warn("https://discord.gg/REG77bCwJh")
		setclipboard("https://discord.gg/REG77bCwJh")
	end
})

SecretButton = MainLeft:AddButton({
	Text = "???",
	Func = function()
		warn("Кто двинется тот гей, Who moved this is gay")
	end
})

CombatLeft = Tabs.Combat:AddLeftGroupbox('Whitelist & Target')
CombatLeft1 = Tabs.Combat:AddLeftGroupbox('MeleeAura')
CombatRight = Tabs.Combat:AddRightGroupbox('Aimbot')
CombatLeft2 = Tabs.Combat:AddLeftGroupbox('Silent Aim')
CombatRight2 = Tabs.Combat:AddRightGroupbox('Ragebot')
CombatLeft5 = Tabs.Combat:AddLeftGroupbox('C4 Control')
CombatLeft3 = Tabs.Combat:AddLeftGroupbox('Rocket settings(Guns)')
CombatRight3 = Tabs.Combat:AddRightGroupbox('PepperSpray settings(Guns)')
CombatLeft4 = Tabs.Combat:AddLeftGroupbox('Others Guns (RISK FOR BAN)')

GlobalWhiteList = {}
GlobalTarget = {}
HighlightStorage = {}

function UpdateHighlight(player, isWhitelisted, isTargeted, whitelistColor, targetColor)
	if not player.Character then return end
	if HighlightStorage[player] then
		HighlightStorage[player]:Destroy()
		HighlightStorage[player] = nil
	end
	if isWhitelisted or isTargeted then
		highlight = Instance.new("Highlight")
		highlight.Adornee = player.Character
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.FillColor = isTargeted and targetColor or whitelistColor
		highlight.OutlineColor = isTargeted and targetColor or whitelistColor
		highlight.Parent = player.Character
		HighlightStorage[player] = highlight
	end
end

function UpdateAllHighlights()
	whitelistColor = (Options.WhitelistColorPicker and Options.WhitelistColorPicker.Value) or Color3.new(0, 1, 0)
	targetColor = (Options.TargetColorPicker and Options.TargetColorPicker.Value) or Color3.new(1, 0, 0)
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		isWhitelisted = false
		isTargeted = false
		for name, _ in pairs(GlobalWhiteList) do
			if name == player.Name then isWhitelisted = true end
		end
		for name, _ in pairs(GlobalTarget) do
			if name == player.Name then isTargeted = true end
		end
		UpdateHighlight(player, isWhitelisted, isTargeted, whitelistColor, targetColor)
	end
end

CombatLeft:AddDropdown('GlobalWhiteListDropdown', {
	SpecialType = 'Player',
	Multi = true,
	Text = 'Whitelist Players',
	Callback = function(Value)
		GlobalWhiteList = Value
		task.wait()
		UpdateAllHighlights()
	end
})

CombatLeft:AddDropdown('GlobalTargetDropdown', {
	SpecialType = 'Player',
	Multi = true,
	Text = 'Target Players',
	Callback = function(Value)
		GlobalTarget = Value
		task.wait()
		UpdateAllHighlights()
	end
})

CombatLeft:AddLabel('Whitelist Color'):AddColorPicker('WhitelistColorPicker', {
	Default = Color3.new(0, 1, 0),
	Title = 'Whitelist Highlight',
	Transparency = 0,
	Callback = function()
		task.wait()
		UpdateAllHighlights()
	end
})

CombatLeft:AddLabel('Target Color'):AddColorPicker('TargetColorPicker', {
	Default = Color3.new(1, 0, 0),
	Title = 'Target Highlight',
	Transparency = 0,
	Callback = function()
		task.wait()
		UpdateAllHighlights()
	end
})

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait()
		UpdateAllHighlights()
	end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	if HighlightStorage[player] then
		HighlightStorage[player]:Destroy()
		HighlightStorage[player] = nil
	end
end)

game:GetService("RunService").Heartbeat:Connect(function()
	if Options.WhitelistColorPicker and Options.TargetColorPicker then
		UpdateAllHighlights()
		return
	end
end)

HighlightMelee = Instance.new("BillboardGui")
HighlightMelee.Size = UDim2.new(4, 0, 6, 0)
HighlightMelee.AlwaysOnTop = true
HighlightMelee.Enabled = false
HighlightMelee.Parent = game.CoreGui
BoxMelee = Instance.new("Frame", HighlightMelee)
BoxMelee.Size = UDim2.new(1, 0, 1, 0)
BoxMelee.BackgroundColor3 = SectionSettings.MeleeAura.HighlightColor
BoxMelee.BackgroundTransparency = 0.7
BoxMelee.BorderSizePixel = 2

HighlightSilent = Instance.new("BillboardGui")
HighlightSilent.Size = UDim2.new(4, 0, 6, 0)
HighlightSilent.AlwaysOnTop = true
HighlightSilent.Enabled = false
HighlightSilent.Parent = game.CoreGui
BoxSilent = Instance.new("Frame", HighlightSilent)
BoxSilent.Size = UDim2.new(1, 0, 1, 0)
BoxSilent.BackgroundColor3 = SectionSettings.SilentAim.HighlightColor
BoxSilent.BackgroundTransparency = 0.7
BoxSilent.BorderSizePixel = 2

HighlightRage = Instance.new("BillboardGui")
HighlightRage.Size = UDim2.new(4, 0, 6, 0)
HighlightRage.AlwaysOnTop = true
HighlightRage.Enabled = false
HighlightRage.Parent = game.CoreGui
BoxRage = Instance.new("Frame", HighlightRage)
BoxRage.Size = UDim2.new(1, 0, 1, 0)
BoxRage.BackgroundColor3 = SectionSettings.Ragebot.HighlightColor
BoxRage.BackgroundTransparency = 0.7
BoxRage.BorderSizePixel = 2

function UpdateHighlightMelee(target)
	HighlightMelee.Adornee = target and target:FindFirstChild("HumanoidRootPart") or nil
	HighlightMelee.Enabled = functions.meleeauraF and SectionSettings.MeleeAura.HighlightEnabled and target ~= nil
	BoxMelee.BackgroundColor3 = SectionSettings.MeleeAura.HighlightColor
end

function UpdateHighlightSilent(target)
	HighlightSilent.Adornee = target and target:FindFirstChild("HumanoidRootPart") or nil
	HighlightSilent.Enabled = functions.silentaimF and SectionSettings.SilentAim.HighlightEnabled and target ~= nil
	BoxSilent.BackgroundColor3 = SectionSettings.SilentAim.HighlightColor
end

function UpdateHighlightRage(target)
	HighlightRage.Adornee = target and target:FindFirstChild("HumanoidRootPart") or nil
	HighlightRage.Enabled = RagebotF and SectionSettings.Ragebot.HighlightEnabled and target ~= nil
	BoxRage.BackgroundColor3 = SectionSettings.Ragebot.HighlightColor
end

CombatLeft1:AddToggle('MeleeAuraToggle', {
	Text = 'Melee Aura',
	Default = false,
	Callback = function(Value)
		functions.meleeauraF = Value
		if Value then
			LastTick = tick()
			AttachTick = tick()
			AttachCD = {["Fists"] = .05, ["Knuckledusters"] = .05, ["Nunchucks"] = 0.05, ["Shiv"] = .05, ["Bat"] = 1, ["Metal-Bat"] = 1, ["Chainsaw"] = 2.5, ["Balisong"] = .05, ["Rambo"] = .3, ["Shovel"] = 3, ["Sledgehammer"] = 2, ["Katana"] = .1, ["Wrench"] = .1}
			if not remotes.MeleeAuraTask then
				remotes.MeleeAuraTask = task.spawn(function()
					function Attack(target)
						if not (target and target:FindFirstChild("Head")) then return end
						if not me.Character then return end
						TOOL = me.Character:FindFirstChildOfClass("Tool")
						if not TOOL then return end
						attachcd = AttachCD[TOOL.Name] or 0.5
						if tick() - AttachTick >= attachcd then
							result = remote1:InvokeServer("🍞", tick(), TOOL, "43TRFWX", "Normal", tick(), true)
							if SectionSettings.MeleeAura.ShowAnim then
								anim = TOOL:FindFirstChild("AnimsFolder") and TOOL.AnimsFolder:FindFirstChild("Slash1")
								if anim then
									animator = me.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Animator")
									if animator then
										animator:LoadAnimation(anim):Play(0.1, 1, 1.3)
									end
								end
							end
							task.wait(0.3 + math.random() * 0.2)
							Handle = TOOL:FindFirstChild("WeaponHandle") or TOOL:FindFirstChild("Handle") or me.Character:FindFirstChild("Left Arm")
							if TOOL then
								if SectionSettings.MeleeAura.TargetPart == "Random" then
									targetPart = target:FindFirstChild(ValidMeleeTargetParts[math.random(1, #ValidMeleeTargetParts)])
								else
									targetPart = target:FindFirstChild(SectionSettings.MeleeAura.TargetPart) or target:FindFirstChild("Right Arm")
								end
								if not targetPart then return end
								arg2 = {
									"🍞",
									tick(),
									TOOL,
									"2389ZFX34",
									result,
									true,
									Handle,
									targetPart,
									target,
									me.Character.HumanoidRootPart.Position,
									targetPart.Position
								}
								if TOOL.Name == "Chainsaw" then
									for i = 1, 15 do remote2:FireServer(unpack(arg2)) end
								else
									remote2:FireServer(unpack(arg2))
								end
								AttachTick = tick()
							end
							UpdateHighlightMelee(target)
						end
					end
					while functions.meleeauraF do
						mychar = me.Character or me.CharacterAdded:Wait()
						if mychar and mychar:FindFirstChild("HumanoidRootPart") then
							myhrp = mychar.HumanoidRootPart
							for _, a in ipairs(plrs:GetPlayers()) do
								if a ~= me and a.Character and a.Character:FindFirstChild("HumanoidRootPart") then
									hrp = a.Character.HumanoidRootPart
									distance = (myhrp.Position - hrp.Position).Magnitude
									if distance < SectionSettings.MeleeAura.Distance and a.Character:FindFirstChildOfClass("Humanoid").Health > 15 and not a.Character:FindFirstChildOfClass("ForceField") then
										if SectionSettings.MeleeAura.CheckWhitelist and GlobalWhiteList[a.Name] then continue end
										if SectionSettings.MeleeAura.CheckTeam and a.Team == me.Team then continue end
										Attack(a.Character)
									end
								end
							end
						end
						run.Heartbeat:Wait()
					end
				end)
			end
		elseif not Value then
			if remotes.MeleeAuraTask then
				task.cancel(remotes.MeleeAuraTask)
				remotes.MeleeAuraTask = nil
			end
			UpdateHighlightMelee(nil)
		end
	end,
}):AddKeyPicker('MeleeAuraKey', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'Melee Aura',
	Callback = function() end,
})

CombatLeft1:AddToggle('MeleeAuraAnimToggle', {
	Text = 'Melee Aura Animation',
	Default = true,
	Callback = function(Value)
		SectionSettings.MeleeAura.ShowAnim = Value
	end,
})

CombatLeft1:AddToggle('MeleeAuraHighlightToggle', {
	Text = 'Box MeleeAuraTarget',
	Default = false,
	Callback = function(Value)
		SectionSettings.MeleeAura.HighlightEnabled = Value
		UpdateHighlightMelee(nil)
	end
}):AddColorPicker('MeleeAuraHighlightColor', {
	Default = Color3.fromRGB(255, 0, 0),
	Text = 'Box Color',
	Callback = function(Value)
		SectionSettings.MeleeAura.HighlightColor = Value
	end
})

CombatLeft1:AddToggle('MeleeAuraCheckWhitelist', {
	Text = 'Check Whitelist',
	Default = false,
	Callback = function(Value)
		SectionSettings.MeleeAura.CheckWhitelist = Value
	end
})

CombatLeft1:AddToggle('MeleeAuraCheckTeam', {
	Text = 'Check Team',
	Default = false,
	Callback = function(Value)
		SectionSettings.MeleeAura.CheckTeam = Value
	end
})

CombatLeft1:AddSlider('MeleeAuraDistance', {
	Text = 'Melee Aura Distance',
	Default = 1,
	Min = 1,
	Max = 20,
	Rounding = 0,
	Callback = function(Value)
		SectionSettings.MeleeAura.Distance = Value
	end
})

CombatLeft1:AddDropdown('MeleeAuraTargetPart', {
	Values = {'Random', 'Head', 'Torso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg'},
	Default = 2,
	Multi = false,
	Text = 'Hit Part',
	Callback = function(Value)
		SectionSettings.MeleeAura.TargetPart = Value
	end
})

AimbotEnabled = false
Pressed = false
AimTarget = nil
CanUsing = false
FirstPerson = true
Predict = 15
Part = nil
LastRandomTick = tick()
AimbotCircle = nil
AimbotCirclePos = nil
AimbotMode = "Hold"

CombatRight:AddToggle('AimbotToggle', {
	Text = 'Aimbot',
	Default = false,
	Callback = function(Value)
		AimbotEnabled = Value
		if not Value then
			if AimbotCircle then AimbotCircle:Remove(); AimbotCircle = nil end
			if AimbotCirclePos then AimbotCirclePos:Disconnect(); AimbotCirclePos = nil end
		else
			RunAimbot()
		end
	end
}):AddKeyPicker('AimbotKeyPicker', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Hold',
	Text = 'Aimbot',
	Callback = function(Value)
		AimbotEnabled = Value
	end
})

DrawToggle = CombatRight:AddToggle('DrawToggle', {
	Text = 'Draw Circle',
	Default = false,
	Callback = function(Value)
		SectionSettings.AimBot.Draw = Value
	end
})

DrawToggle:AddColorPicker('DrawColorPicker', {
	Default = Color3.fromRGB(255, 0, 0),
	Title = 'Circle Color',
	Callback = function(Value)
		SectionSettings.AimBot.DrawColor = Value
		if AimbotCircle then
			AimbotCircle.Color = Value
		end
	end
})

CombatRight:AddToggle('SmoothToggle', {
	Text = 'Smooth Aiming',
	Default = false,
	Callback = function(Value)
		SectionSettings.AimBot.Smooth = Value
	end
})

CombatRight:AddToggle('VelocityToggle', {
	Text = 'Use Velocity',
	Default = false,
	Callback = function(Value)
		SectionSettings.AimBot.Velocity = Value
	end
})

CombatRight:AddToggle('CheckWallToggle', {
	Text = 'Check Walls',
	Default = false,
	Callback = function(Value)
		SectionSettings.AimBot.CheckWall = Value
	end
})

CombatRight:AddToggle('CheckTeamToggle', {
	Text = 'Check Team',
	Default = false,
	Callback = function(Value)
		SectionSettings.AimBot.CheckTeam = Value
	end
})

CombatRight:AddToggle('CheckWhitelistToggle', {
	Text = 'Check Whitelist',
	Default = false,
	Callback = function(Value)
		SectionSettings.AimBot.CheckWhitelist = Value
	end
})

CombatRight:AddDropdown('TargetPartDropdown', {
	Values = ValidAimbotTargetParts,
	Default = 1,
	Multi = false,
	Text = 'Target Part',
	Callback = function(Value)
		SectionSettings.AimBot.TargetPart = Value
	end
})

CombatRight:AddDropdown('AimbotModeDropdown', {
	Values = {'Hold', 'Toggle'},
	Default = 1,
	Multi = false,
	Text = 'Activation Mode',
	Callback = function(Value)
		AimbotMode = Value
		Options.AimbotKeyPicker:SetValue({'V', Value})
	end
})

CombatRight:AddSlider('DrawSizeSlider', {
	Text = 'FOV Size',
	Default = 50,
	Min = 10,
	Max = 250,
	Rounding = 0,
	Callback = function(Value)
		SectionSettings.AimBot.DrawSize = Value
		if AimbotCircle then
			AimbotCircle.Radius = Value
		end
	end
})

CombatRight:AddSlider('SmoothSizeSlider', {
	Text = 'Smoothness Level',
	Default = 0.5,
	Min = 0.1,
	Max = 1,
	Rounding = 1,
	Callback = function(Value)
		SectionSettings.AimBot.SmoothSize = Value
	end
})

function GetClosestTarget()
	Closest = nil
	ClosestDist = SectionSettings.AimBot.DrawSize
	for _, Player in pairs(game.Players:GetPlayers()) do
		if Player ~= game.Players.LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
			Pos, OnScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
			if OnScreen then
				if SectionSettings.AimBot.CheckTeam and Player.Team == game.Players.LocalPlayer.Team then
					continue
				end
				if SectionSettings.AimBot.CheckWhitelist and GlobalWhiteList[Player.Name] then
					continue
				end
				if SectionSettings.AimBot.CheckWall then
					Ignore = {game.Workspace.CurrentCamera, game.Players.LocalPlayer.Character, Player.Character}
					if Player.Parent ~= game.Workspace then
						table.insert(Ignore, Player.Parent)
					end
					CheckPart = Player.Character:FindFirstChild("HumanoidRootPart")
					if not CheckPart then return nil end
					Value = #game.Workspace.CurrentCamera:GetPartsObscuringTarget({CheckPart.Position}, Ignore)
					if Value > 0 then
						continue
					end
				end
				Distance = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(game.UserInputService:GetMouseLocation().X, game.UserInputService:GetMouseLocation().Y)).Magnitude
				if Distance < ClosestDist then
					ClosestDist = Distance
					Closest = Player
				end
			end
		end
	end
	return Closest
end

function RunAimbot()
	game.UserInputService.InputBegan:Connect(function(Key)
		if not game.UserInputService:GetFocusedTextBox() then
			if Key.UserInputType == Enum.UserInputType.MouseButton2 then
				Pressed = true
				AimTarget = GetClosestTarget()
			end
		end
	end)

	game.UserInputService.InputEnded:Connect(function(Key)
		if not game.UserInputService:GetFocusedTextBox() then
			if Key.UserInputType == Enum.UserInputType.MouseButton2 then
				Pressed = false
				AimTarget = nil
			end
		end
	end)

	game:GetService("RunService").RenderStepped:Connect(function()
		if AimbotEnabled then
			Magnitude = (game.Workspace.CurrentCamera.Focus.p - game.Workspace.CurrentCamera.CFrame.p).Magnitude
			CanUsing = Magnitude <= 1.5
			if Pressed and AimTarget and AimTarget.Character then
				Humanoid = AimTarget.Character:FindFirstChild("Humanoid")
				if Humanoid and Humanoid.Health > 0 and CanUsing then
					Part = SectionSettings.AimBot.TargetPart
					TargetPosition = AimTarget.Character[Part].Position
					if SectionSettings.AimBot.Velocity then
						TargetPosition = TargetPosition + AimTarget.Character[Part].Velocity / Predict
					end
					if SectionSettings.AimBot.Smooth then
						game.Workspace.CurrentCamera.CFrame = game.Workspace.CurrentCamera.CFrame:Lerp(CFrame.new(game.Workspace.CurrentCamera.CFrame.p, TargetPosition), SectionSettings.AimBot.SmoothSize)
					else
						game.Workspace.CurrentCamera.CFrame = CFrame.new(game.Workspace.CurrentCamera.CFrame.Position, TargetPosition)
					end
				end
			end
			if SectionSettings.AimBot.Draw then
				if not AimbotCircle then
					AimbotCircle = Drawing.new("Circle")
					AimbotCircle.Color = SectionSettings.AimBot.DrawColor
					AimbotCircle.Thickness = 2
					AimbotCircle.Radius = SectionSettings.AimBot.DrawSize
					AimbotCircle.Filled = false
					AimbotCircle.Visible = true
					if not AimbotCirclePos then
						AimbotCirclePos = game:GetService("RunService").Heartbeat:Connect(function()
							AimbotCircle.Position = Vector2.new(game.UserInputService:GetMouseLocation().X, game.UserInputService:GetMouseLocation().Y)
						end)
					end
				end
			else
				if AimbotCircle then AimbotCircle:Remove(); AimbotCircle = nil end
				if AimbotCirclePos then AimbotCirclePos:Disconnect(); AimbotCirclePos = nil end
			end
		end
	end)
end

circle = Drawing.new("Circle")
circle.Visible = false
circle.Transparency = 1
circle.Thickness = 1.5
circle.Color = SectionSettings.SilentAim.DrawColor
circle.Filled = false
circle.Radius = SectionSettings.SilentAim.DrawSize

renderConnection = nil
function UpdateCircle()
	if renderConnection then renderConnection:Disconnect() end
	if functions.silentaimF and SectionSettings.SilentAim.DrawCircle then
		renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
			circle.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
			circle.Visible = true
			circle.Radius = SectionSettings.SilentAim.DrawSize
			circle.Color = SectionSettings.SilentAim.DrawColor
		end)
	else
		circle.Visible = false
	end
end

function UrTargetFunc()
	if not functions.silentaimF then return nil end
	closestPlayer = nil
	minDistance = SectionSettings.SilentAim.DrawSize
	mousePos = game:GetService("UserInputService"):GetMouseLocation()
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if player == game:GetService("Players").LocalPlayer or not player.Character or player.Character:FindFirstChildOfClass("ForceField") then continue end
		if SectionSettings.SilentAim.CheckWhitelist and GlobalWhiteList[player.Name] then continue end
		if SectionSettings.SilentAim.CheckTeam and player.Team == game:GetService("Players").LocalPlayer.Team then continue end
		targetPart = nil
		if SectionSettings.SilentAim.TargetPart == "Closest" then
			minPartDistance = math.huge
			for _, partName in ipairs(ValidSilentTargetParts) do
				part = player.Character:FindFirstChild(partName)
				if part then
					screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
					if onScreen then
						distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
						if distance < minPartDistance then
							minPartDistance = distance
							targetPart = part
						end
					end
				end
			end
		else
			targetPart = SectionSettings.SilentAim.TargetPart == "Random" and player.Character:FindFirstChild(ValidSilentTargetParts[math.random(1, #ValidSilentTargetParts)]) or player.Character:FindFirstChild(SectionSettings.SilentAim.TargetPart or "Head")
		end
		if targetPart then
			if SectionSettings.SilentAim.CheckWall and #workspace.CurrentCamera:GetPartsObscuringTarget({targetPart.Position}, {workspace.CurrentCamera, game:GetService("Players").LocalPlayer.Character, player.Character}) > 0 then continue end
			screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
			if onScreen and (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude < minDistance then
				minDistance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
				closestPlayer = player
			end
		end
	end
	if closestPlayer and SectionSettings.SilentAim.UseHitChance then
		if math.random(1, 100) > SectionSettings.SilentAim.HitChance then
			return nil
		end
	end
	UpdateHighlightSilent(closestPlayer and closestPlayer.Character or nil)
	return closestPlayer
end

CombatLeft2:AddToggle('SilentAimToggle', {
	Text = 'Silent Aim',
	Default = false,
	Callback = function(Value)
		functions.silentaimF = Value
		UpdateCircle()
		if not Value then
			currentTarget = nil
			if remotes.SilentAimTask then
				task.cancel(remotes.SilentAimTask)
				remotes.SilentAimTask = nil
			end
			if visualizeConnection then
				visualizeConnection:Disconnect()
				visualizeConnection = nil
			end
			UpdateHighlightSilent(nil)
		else
			VisualizeEvent = game:GetService("ReplicatedStorage").Events2.Visualize
			DamageEvent = game:GetService("ReplicatedStorage").Events["ZFKLF__H"]
			remotes.SilentAimTask = task.spawn(function()
				while functions.silentaimF do
					currentTarget = UrTargetFunc()
					game:GetService("RunService").Heartbeat:Wait()
				end
			end)
			visualizeConnection = VisualizeEvent.Event:Connect(function(_, ShotCode, _, Gun, _, StartPos, BulletsPerShot)
				if not functions.silentaimF or not Gun or not currentTarget or not currentTarget.Character or currentTarget.Character:FindFirstChildOfClass("ForceField") then return end
				playerTool = game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool")
				if not playerTool or Gun ~= playerTool then return end
				HitPart = nil
				if SectionSettings.SilentAim.TargetPart == "Closest" then
					minPartDistance = math.huge
					for _, partName in ipairs(ValidSilentTargetParts) do
						part = currentTarget.Character:FindFirstChild(partName)
						if part then
							screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
							if onScreen then
								distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
								if distance < minPartDistance then
									minPartDistance = distance
									HitPart = part
								end
							end
						end
					end
				else
					HitPart = SectionSettings.SilentAim.TargetPart == "Random" and currentTarget.Character:FindFirstChild(ValidSilentTargetParts[math.random(1, #ValidSilentTargetParts)]) or currentTarget.Character:FindFirstChild(SectionSettings.SilentAim.TargetPart or "Head")
				end
				if not HitPart then return end
				HitPos = HitPart.Position
				Bullets = {}
				for i = 1, math.clamp(#BulletsPerShot, 1, 100) do
					table.insert(Bullets, CFrame.new(StartPos, HitPos).LookVector)
				end
				task.wait(0.005)
				for Index, LookVector in ipairs(Bullets) do
					DamageEvent:FireServer("🧈", Gun, ShotCode, Index, HitPart, HitPos, LookVector)
				end
				if Gun:FindFirstChild("Hitmarker") then
					Gun.Hitmarker:Fire(HitPart)
					if HitPart.Name == "Head" then
						PlayHeadshotSound()
					end
				end
			end)
		end
	end
}):AddKeyPicker('SilentAimKey', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'Silent Aim'
})

CombatLeft2:AddToggle('SilentAimDrawCircle', {
	Text = 'Draw Circle',
	Default = false,
	Callback = function(Value)
		SectionSettings.SilentAim.DrawCircle = Value
		UpdateCircle()
	end
})

CombatLeft2:AddToggle('SilentAimUseHitChance', {
	Text = 'HitChance',
	Default = false,
	Callback = function(Value)
		SectionSettings.SilentAim.UseHitChance = Value
	end
})

CombatLeft2:AddToggle('SilentAimHighlightToggle', {
	Text = 'Box SilentTarget',
	Default = false,
	Callback = function(Value)
		SectionSettings.SilentAim.HighlightEnabled = Value
		UpdateHighlightSilent(nil)
	end
}):AddColorPicker('SilentAimHighlightColor', {
	Default = Color3.fromRGB(255, 0, 0),
	Text = 'Box Color',
	Callback = function(Value)
		SectionSettings.SilentAim.HighlightColor = Value
	end
})

CombatLeft2:AddToggle('SilentAimCheckWhitelist', {
	Text = 'Check Whitelist',
	Default = false,
	Callback = function(Value)
		SectionSettings.SilentAim.CheckWhitelist = Value
	end
})

CombatLeft2:AddToggle('SilentAimCheckWall', {
	Text = 'Check Wall',
	Default = false,
	Callback = function(Value)
		SectionSettings.SilentAim.CheckWall = Value
	end
})

CombatLeft2:AddToggle('SilentAimCheckTeam', {
	Text = 'Check Team',
	Default = false,
	Callback = function(Value)
		SectionSettings.SilentAim.CheckTeam = Value
	end
})

CombatLeft2:AddSlider('SilentAimFOV', {
	Text = 'FOV',
	Default = 50,
	Min = 10,
	Max = 150,
	Rounding = 0,
	Callback = function(Value)
		SectionSettings.SilentAim.DrawSize = Value
		circle.Radius = Value
	end
})

CombatLeft2:AddSlider('SilentAimHitChance', {
	Text = 'HitChance',
	Default = 80,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Callback = function(Value)
		SectionSettings.SilentAim.HitChance = Value
	end
})

CombatLeft2:AddDropdown('SilentAimTargetPart', {
	Values = {'Closest', 'Random', 'Head', 'Torso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg'},
	Default = 3,
	Multi = false,
	Text = 'Hit Part',
	Callback = function(Value)
		SectionSettings.SilentAim.TargetPart = Value
	end
})

RagebotF = false
me = game.Players.LocalPlayer
plrs = game:GetService("Players")
camera = workspace.CurrentCamera
RagebotTask = nil

CombatRight2:AddToggle('RagebotToggle', {
	Text = 'RageBot',
	Default = false,
	Callback = function(Value)
		RagebotF = Value
		if Value then
			if not RagebotTask then
				RagebotTask = task.spawn(RageBotLoop)
			end
		else
			if RagebotTask then
				task.cancel(RagebotTask)
				RagebotTask = nil
			end
			UpdateHighlightRage(nil)
		end
	end
}):AddKeyPicker('RagebotKey', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'RageBot',
	Callback = function() end
})

CombatRight2:AddToggle('DownedCheck', {
	Text = 'Downed Check',
	Default = true,
	Callback = function(Value)
		SectionSettings.Ragebot.DownedCheck = Value
	end
})

CombatRight2:AddToggle('RagebotHighlightToggle', {
	Text = 'Box RagebotTarget',
	Default = false,
	Callback = function(Value)
		SectionSettings.Ragebot.HighlightEnabled = Value
		UpdateHighlightRage(nil)
	end
}):AddColorPicker('RagebotHighlightColor', {
	Default = Color3.fromRGB(255, 0, 0),
	Text = 'Box Color',
	Callback = function(Value)
		SectionSettings.Ragebot.HighlightColor = Value
	end
})

CombatRight2:AddToggle('RagebotCheckWhitelist', {
	Text = 'Check Whitelist',
	Default = false,
	Callback = function(Value)
		SectionSettings.Ragebot.CheckWhitelist = Value
	end
})

CombatRight2:AddToggle('RagebotCheckTarget', {
	Text = 'Check Target',
	Default = false,
	Callback = function(Value)
		SectionSettings.Ragebot.CheckTarget = Value
	end
})

CombatRight2:AddToggle('RagebotCheckTeam', {
	Text = 'Check Team',
	Default = false,
	Callback = function(Value)
		SectionSettings.Ragebot.CheckTeam = Value
	end
})

function RandomString(length)
	res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

function GetClosestEnemy()
	if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then return nil end
	closestEnemy = nil
	shortestDistance = 100
	for _, player in pairs(plrs:GetPlayers()) do
		if player == me then continue end
		character = player.Character
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		rootPart = character and character:FindFirstChild("HumanoidRootPart")
		forceField = character and character:FindFirstChildOfClass("ForceField")
		if character and rootPart and humanoid and not forceField then
			if (not SectionSettings.Ragebot.DownedCheck or humanoid.Health > 15) then
				distance = (rootPart.Position - me.Character.HumanoidRootPart.Position).Magnitude
				if distance > 100 then continue end
				if SectionSettings.Ragebot.CheckWhitelist and GlobalWhiteList[player.Name] then continue end
				if SectionSettings.Ragebot.CheckTarget and not GlobalTarget[player.Name] then continue end
				if SectionSettings.Ragebot.CheckTeam and player.Team == me.Team then continue end
				if distance < shortestDistance then
					shortestDistance = distance
					closestEnemy = player
				end
			end
		end
	end
	UpdateHighlightRage(closestEnemy and closestEnemy.Character or nil)
	return closestEnemy
end

function Shoot(target)
	if not target or not target.Character then return end
	head = target.Character:FindFirstChild("Head")
	if not head then return end
	tool = me.Character and me.Character:FindFirstChildOfClass("Tool")
	if not tool then return end
	values = tool:FindFirstChild("Values")
	hitMarker = tool:FindFirstChild("Hitmarker")
	if not values or not hitMarker then return end
	ammo = values:FindFirstChild("SERVER_Ammo")
	storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")
	if not ammo or not storedAmmo or ammo.Value <= 0 then return end
	hitPosition = head.Position
	hitDirection = (hitPosition - camera.CFrame.Position).unit
	randomKey = RandomString(30) .. "0"
	game:GetService("ReplicatedStorage").Events.GNX_S:FireServer(
		tick(),
		randomKey,
		tool,
		"FDS9I83",
		camera.CFrame.Position,
		{hitDirection},
		false
	)
	game:GetService("ReplicatedStorage").Events["ZFKLF__H"]:FireServer(
		"🧈",
		tool,
		randomKey,
		1,
		head,
		hitPosition,
		hitDirection
	)
	ammo.Value = math.max(ammo.Value - 1, 0)
	hitMarker:Fire(head)
	PlayHeadshotSound()
	storedAmmo.Value = values:FindFirstChild("SERVER_StoredAmmo").Value
end

function RageBotLoop()
	while RagebotF and me.Character and me.Character:FindFirstChild("HumanoidRootPart") do
		if me.Character:FindFirstChildOfClass("Tool") then
			target = GetClosestEnemy()
			if target then
				Shoot(target)
			end
		end
		task.wait(0.2)
	end
end

Debris = workspace:WaitForChild("Debris")
VParts = Debris:WaitForChild("VParts")
Forward = 0
Sideways = 0
Break = false
plrs = game:GetService("Players")
me = plrs.LocalPlayer
tween = game:GetService("TweenService")
input = game:GetService("UserInputService")
run = game:GetService("RunService")
camera = game.Workspace.CurrentCamera

c4Enabled = false
c4Speed = 200

CombatLeft5:AddToggle("C4Toggle", {
	Text = "C4 Control",
	Default = false,
	Callback = function(value)
		c4Enabled = value
		if not value and me.Character then
			Forward = 0
			Sideways = 0
			Break = false
			if me.Character.HumanoidRootPart then
				me.Character.HumanoidRootPart.Anchored = false
			end
			camera.CameraSubject = me.Character.Humanoid
		end
	end,
}):AddKeyPicker("C4Key", {
	Default = "None",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "C4 Control",
	Callback = function() end,
})

CombatLeft5:AddSlider('C4Speed', {
	Text = 'C4 Speed',
	Default = 200,
	Min = 10,
	Max = 500,
	Rounding = 0,
	Compact = false,
	Callback = function(value)
		c4Speed = value
	end
})

VParts.ChildAdded:Connect(function(Projectile)
	if not c4Enabled then return end

	task.wait()
	if Projectile.Name == "TransIgnore" then
		if not me.Character then return end

		if not me.Character:FindFirstChild("C4") then 
			return 
		end

		camera.CameraSubject = Projectile
		if me.Character.HumanoidRootPart then
			me.Character.HumanoidRootPart.Anchored = true
		end

		pcall(function()
			if Projectile:FindFirstChild("BodyForce") then Projectile.BodyForce:Destroy() end
			if Projectile:FindFirstChild("BodyAngularVelocity") then Projectile.BodyAngularVelocity:Destroy() end
			if Projectile:FindFirstChild("Sound") then Projectile.Sound:Destroy() end
		end)

		BV = Instance.new("BodyVelocity", Projectile)
		BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		BV.Velocity = Vector3.new()

		BG = Instance.new("BodyGyro", Projectile)
		BG.P = 9e4
		BG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)

		task.spawn(function()
			while Projectile and Projectile.Parent and c4Enabled do
				run.RenderStepped:Wait()
				tween:Create(BV, TweenInfo.new(0), {Velocity = ((camera.CFrame.LookVector * Forward) + (camera.CFrame.RightVector * Sideways)) * c4Speed}):Play()
				BG.CFrame = camera.CoordinateFrame
				targetCFrame = Projectile.CFrame * CFrame.new(0, 1, 1)
				camera.CFrame = camera.CFrame:Lerp(targetCFrame + Vector3.new(0, 5, 0), 0.1)
				if Break then
					Break = false
					break
				end
			end
			if me.Character then
				camera.CameraSubject = me.Character.Humanoid
				if me.Character.HumanoidRootPart then
					me.Character.HumanoidRootPart.Anchored = false
				end
			end
		end)
	end
end)

input.InputBegan:Connect(function(Key)
	if Key.KeyCode == Enum.KeyCode.W then
		Forward = 1
	elseif Key.KeyCode == Enum.KeyCode.S then
		Forward = -1
	elseif Key.KeyCode == Enum.KeyCode.D then
		Sideways = 1
	elseif Key.KeyCode == Enum.KeyCode.A then
		Sideways = -1
	end
end)

input.InputEnded:Connect(function(Key)
	if Key.KeyCode == Enum.KeyCode.W or Key.KeyCode == Enum.KeyCode.S then
		Forward = 0
	elseif Key.KeyCode == Enum.KeyCode.D or Key.KeyCode == Enum.KeyCode.A then
		Sideways = 0
	end
end)

Debris.ChildAdded:Connect(function(Result)
	task.wait()
	if not me.Character then return end
	pcall(function()
		if me.Character:FindFirstChild("C4") and (Result.Name == "C4Explosion") then
			Break = true
			task.wait(1)
			Break = false
		end
	end)
end)

Debris = workspace:WaitForChild("Debris")
VParts = Debris:WaitForChild("VParts")
Forward = 0
Sideways = 0
Break = false
plrs = game:GetService("Players")
me = plrs.LocalPlayer
tween = game:GetService("TweenService")
input = game:GetService("UserInputService")
run = game:GetService("RunService")
camera = game.Workspace.CurrentCamera

rocketEnabled = false
rocketSpeed = 200

CombatLeft3:AddToggle("RocketToggle", {
	Text = "Rocket Control",
	Default = false,
	Callback = function(value)
		rocketEnabled = value
		if not value and me.Character then
			Forward = 0
			Sideways = 0
			Break = false
			if me.Character.HumanoidRootPart then
				me.Character.HumanoidRootPart.Anchored = false
			end
			camera.CameraSubject = me.Character.Humanoid
		end
	end,
}):AddKeyPicker("RocketKey", {
	Default = "None",
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Rocket Control",
	Callback = function() end,
})

CombatLeft3:AddSlider('RocketSpeed', {
	Text = 'Rocket Speed',
	Default = 200,
	Min = 10,
	Max = 500,
	Rounding = 0,
	Compact = false,
	Callback = function(value)
		rocketSpeed = value
	end
})

VParts.ChildAdded:Connect(function(Projectile)
	if not rocketEnabled then return end

	task.wait()
	if (Projectile.Name == "RPG_Rocket" or Projectile.Name == "GrenadeLauncherGrenade") then
		if not me.Character then return end

		if Projectile.Name == "RPG_Rocket" and not me.Character:FindFirstChild("RPG-7") then 
			return 
		end

		camera.CameraSubject = Projectile
		if me.Character.HumanoidRootPart then
			me.Character.HumanoidRootPart.Anchored = true
		end

		pcall(function()
			if Projectile.Name == "RPG_Rocket" then 
				if Projectile:FindFirstChild("BodyForce") then Projectile.BodyForce:Destroy() end
				if Projectile:FindFirstChild("RotPart") and Projectile.RotPart:FindFirstChild("BodyAngularVelocity") then 
					Projectile.RotPart.BodyAngularVelocity:Destroy() 
				end
				if Projectile:FindFirstChild("Sound") then Projectile.Sound:Destroy() end
			elseif Projectile.Name == "GrenadeLauncherGrenade" then
				if Projectile:FindFirstChild("BodyForce") then Projectile.BodyForce:Destroy() end
				if Projectile:FindFirstChild("BodyAngularVelocity") then Projectile.BodyAngularVelocity:Destroy() end
				if Projectile:FindFirstChild("Sound") then Projectile.Sound:Destroy() end
			end
		end)

		BV = Instance.new("BodyVelocity", Projectile)
		BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		BV.Velocity = Vector3.new()

		BG = Instance.new("BodyGyro", Projectile)
		BG.P = 9e4
		BG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)

		task.spawn(function()
			while Projectile and Projectile.Parent and rocketEnabled do
				run.RenderStepped:Wait()
				tween:Create(BV, TweenInfo.new(0), {Velocity = ((camera.CFrame.LookVector * Forward) + (camera.CFrame.RightVector * Sideways)) * rocketSpeed}):Play()
				BG.CFrame = camera.CoordinateFrame
				targetCFrame = Projectile.CFrame * CFrame.new(0, 1, 1)
				camera.CFrame = camera.CFrame:Lerp(targetCFrame + Vector3.new(0, 5, 0), 0.1)
				if Break then
					Break = false
					break
				end
			end
			if me.Character then
				camera.CameraSubject = me.Character.Humanoid
				if me.Character.HumanoidRootPart then
					me.Character.HumanoidRootPart.Anchored = false
				end
			end
		end)
	end
end)

input.InputBegan:Connect(function(Key)
	if Key.KeyCode == Enum.KeyCode.W then
		Forward = 1
	elseif Key.KeyCode == Enum.KeyCode.S then
		Forward = -1
	elseif Key.KeyCode == Enum.KeyCode.D then
		Sideways = 1
	elseif Key.KeyCode == Enum.KeyCode.A then
		Sideways = -1
	end
end)

input.InputEnded:Connect(function(Key)
	if Key.KeyCode == Enum.KeyCode.W or Key.KeyCode == Enum.KeyCode.S then
		Forward = 0
	elseif Key.KeyCode == Enum.KeyCode.D or Key.KeyCode == Enum.KeyCode.A then
		Sideways = 0
	end
end)

Debris.ChildAdded:Connect(function(Result)
	task.wait()
	if not me.Character then return end
	pcall(function()
		if me.Character:FindFirstChild("RPG-7") and (Result.Name == "RPG_Explosion_Long" or Result.Name == "RPG_Explosion_Short") then
			Break = true
			task.wait(1)
			Break = false
		end
		if (me.Character:FindFirstChild("M320-1") or me.Character:FindFirstChild("SCAR-H-X")) and (Result.Name == "GL_Explosion_Long" or Result.Name == "GL_Explosion_Short") then
			Break = true
			task.wait(1)
			Break = false
		end
	end)
end)

pepperEnabled = false

PepperToggle = CombatRight3:AddToggle('InfinitePepper', {
	Text = "Infinite Pepper Spray",
	Default = false,
	Callback = function(Value)
		pepperEnabled = Value
	end
})

function pepper(obj)
	if pepperEnabled then
		obj:FindFirstChild("Ammo").MinValue = 100
		obj:FindFirstChild("Ammo").Value = 100
	else
		obj:FindFirstChild("Ammo").MinValue = 0
	end
end

game:GetService("RunService").RenderStepped:Connect(function()
	Pepper = game.Players.LocalPlayer.Character:FindFirstChild("Pepper-spray")
	if Pepper then
		pepper(Pepper)
	end
end)

PepperSprayAura_Enabled = false

PepperAuraToggle = CombatRight3:AddToggle('PepperAura', {
	Text = "PepperSpray Aura",
	Default = false,
	Callback = function(State)
		PepperSprayAura_Enabled = State
		if PepperSprayAura_Enabled then
			task.spawn(function()
				while PepperSprayAura_Enabled do
					game:GetService("RunService").RenderStepped:Wait()
					player = game.Players.LocalPlayer
					char = player.Character
					if char and char:FindFirstChild("Pepper-spray") then
						for _, v in pairs(game.Players:GetPlayers()) do
							if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
								if SectionSettings.PepperSprayAura.CheckWhitelist and GlobalWhiteList[v.Name] then continue end
								dist = (char:FindFirstChild("HumanoidRootPart").Position - v.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
								if dist < 15 then
									char["Pepper-spray"].RemoteEvent:FireServer("Spray", true)
									char["Pepper-spray"].RemoteEvent:FireServer("Hit", v.Character)
								else
									char["Pepper-spray"].RemoteEvent:FireServer("Spray", false)
								end
							end
						end
					end
				end
			end)
		end
	end
}):AddKeyPicker('PepperSprayKey', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'PepperSpray Aura'
})

CombatRight3:AddToggle('PepperSprayCheckWhitelist', {
	Text = 'Check Whitelist',
	Default = false,
	Callback = function(Value)
		SectionSettings.PepperSprayAura.CheckWhitelist = Value
	end
})

Settings = {
	Enabled = false,
	Color = Color3.fromRGB(255, 0, 0),
	Transparency = 0
}

wallbangEnabled = false
functions = {}
functions.instant_reloadF = false
activeTracers = {}
maxTracers = 10
originalValues = {}
gunModulesCache = {}

safeGet = function(obj, path, default)
	current = obj
	for _, key in ipairs(path) do
		if not current or not current[key] then
			return default
		end
		current = current[key]
	end
	return current
end

CombatLeft4:AddToggle('Wallbang', {
	Text = "Wallbang",
	Default = false,
	Callback = function(State)
		wallbangEnabled = State
		workspaceService = game:GetService("Workspace")
		map = workspaceService:FindFirstChild("Map")
		if map then
			parts = map:FindFirstChild("Parts")
			if parts then
				mParts = parts:FindFirstChild("M_Parts")
				if mParts then
					if wallbangEnabled and mParts.Parent ~= workspaceService:FindFirstChild("Characters") then
						mParts.Parent = workspaceService:FindFirstChild("Characters")
					elseif not wallbangEnabled and mParts.Parent ~= parts then
						mParts.Parent = parts
					end
				end
			end
		end
	end
})

CombatLeft4:AddToggle('InstantReload', {
	Text = "Instant Reload",
	Default = false,
	Tooltip = "Reloads weapon instantly",
	Callback = function(Value)
		functions.instant_reloadF = Value
		if Value then
			spawn(instantreloadL)
		end
	end
})

instantreloadL = function()
	gunR_remote = game:GetService("ReplicatedStorage").Events["GNX_R"]
	connections = {}

	setupTool = function(tool)
		if not tool or not tool:FindFirstChild("IsGun") then return end
		values = tool:FindFirstChild("Values")
		if not values then return end
		serverAmmo = values:FindFirstChild("SERVER_Ammo")
		storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")

		if storedAmmo then
			conn1 = storedAmmo:GetPropertyChangedSignal("Value"):Connect(function()
				if functions.instant_reloadF and storedAmmo.Value ~= 0 then
					gunR_remote:FireServer(tick(), "KLWE89U0", tool)
				end
			end)
			table.insert(connections, conn1)
			if storedAmmo.Value ~= 0 and functions.instant_reloadF then
				gunR_remote:FireServer(tick(), "KLWE89U0", tool)
			end
		end

		if serverAmmo then
			conn2 = serverAmmo:GetPropertyChangedSignal("Value"):Connect(function()
				if functions.instant_reloadF and storedAmmo and storedAmmo.Value ~= 0 then
					gunR_remote:FireServer(tick(), "KLWE89U0", tool)
				end
			end)
			table.insert(connections, conn2)
		end
	end

	cleanupConnections = function()
		for _, conn in pairs(connections) do
			if conn.Connected then
				conn:Disconnect()
			end
		end
		connections = {}
	end

	setupCharacter = function(char)
		cleanupConnections()
		setupTool(char:FindFirstChildOfClass("Tool"))
		if toolConn then
			toolConn:Disconnect()
		end
		toolConn = char.ChildAdded:Connect(function(obj)
			if obj:IsA("Tool") and obj:FindFirstChild("IsGun") then
				setupTool(obj)
			end
		end)
	end

	if game:GetService("Players").LocalPlayer.Character then
		setupCharacter(game:GetService("Players").LocalPlayer.Character)
	end

	if charConn then
		charConn:Disconnect()
	end
	charConn = game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
		setupCharacter(char)
	end)

	while functions.instant_reloadF do
		wait(0.1)
	end
	cleanupConnections()
	if charConn then charConn:Disconnect() end
	if toolConn then toolConn:Disconnect() end
end

GunModules = function()
	if not gunModulesCache[tick()] then
		gunModulesCache = {}
		for i, v in pairs(GG(true)) do
			if type(v) == 'table' and RG(v, 'EquipTime') then
				if not originalValues[v] then
					originalValues[v] = {
						Recoil = v.Recoil or 0,
						AngleX_Min = v.AngleX_Min or 0,
						AngleX_Max = v.AngleX_Max or 0,
						AngleY_Min = v.AngleY_Min or 0,
						AngleY_Max = v.AngleY_Max or 0,
						AngleZ_Min = v.AngleZ_Min or 0,
						AngleZ_Max = v.AngleZ_Max or 0,
						Spread = v.Spread or 0,
						EquipTime = v.EquipTime or 0.5,
						AimSpeed = (v.AimSettings and v.AimSettings.AimSpeed) or 1,
						ChargeTime = v.ChargeTime or 0,
						SlowDown = v.SlowDown or 0,
						FireModeSettings = type(v.FireModeSettings) == 'table' and table.clone(v.FireModeSettings) or v.FireModeSettings
					}
				end
				gunModulesCache[v] = true
				if Toggles and Toggles.NoRecoil and Toggles.NoRecoil.Value then
					v.Recoil = 0
					v.AngleX_Min = 0
					v.AngleX_Max = 0
					v.AngleY_Min = 0
					v.AngleY_Max = 0
					v.AngleZ_Min = 0
					v.AngleZ_Max = 0
				else
					v.Recoil = originalValues[v].Recoil
					v.AngleX_Min = originalValues[v].AngleX_Min
					v.AngleX_Max = originalValues[v].AngleX_Max
					v.AngleY_Min = originalValues[v].AngleY_Min
					v.AngleY_Max = originalValues[v].AngleY_Max
					v.AngleZ_Min = originalValues[v].AngleZ_Min
					v.AngleZ_Max = originalValues[v].AngleZ_Max
				end
				if Toggles and Toggles.Spread and Toggles.Spread.Value then
					v.Spread = 0
				else
					v.Spread = originalValues[v].Spread
				end
				if Toggles and Toggles.EquipAnimSpeed and Toggles.EquipAnimSpeed.Value then
					equipTime = safeGet(Options, {"EquipTimeAmount", "Value"}, 0)
					v.EquipTime = equipTime
				else
					v.EquipTime = originalValues[v].EquipTime or 0.5
				end
				if Toggles and Toggles.AimAnimSpeed and Toggles.AimAnimSpeed.Value then
					if v.AimSettings and v.SniperSettings then
						aimSpeed = safeGet(Options, {"AimSpeedAmount", "Value"}, 0)
						v.AimSettings.AimSpeed = aimSpeed
						v.SniperSettings.AimSpeed = aimSpeed
					end
				else
					if v.AimSettings and v.SniperSettings then
						v.AimSettings.AimSpeed = originalValues[v].AimSpeed
						v.SniperSettings.AimSpeed = originalValues[v].AimSpeed
					end
				end
			end
		end
		spawn(function()
			wait(60)
			gunModulesCache = {}
		end)
	end
end

CombatLeft4:AddToggle('NoRecoil', {
	Text = 'No Recoil',
	Default = false,
	Tooltip = 'Removes weapon recoil',
	Callback = function(Value)
		GunModules()
	end
})

CombatLeft4:AddToggle('Spread', {
	Text = 'No Spread',
	Default = false,
	Tooltip = 'Eliminates bullet spread',
	Callback = function(Value)
		GunModules()
	end
})

CombatLeft4:AddToggle('EquipAnimSpeed', {
	Text = 'Equip Anim Speed',
	Default = false,
	Tooltip = 'Adjusts weapon equip animation speed',
	Callback = function(Value)
		GunModules()
	end
})

CombatLeft4:AddToggle('AimAnimSpeed', {
	Text = 'Aim Anim Speed',
	Default = false,
	Tooltip = 'Adjusts aiming animation speed',
	Callback = function(Value)
		GunModules()
	end
})

BulletTracer = CombatLeft4:AddToggle('BulletTracerToggle', {
	Text = 'Bullet Tracer',
	Default = false,
	Callback = function(Value)
		Settings.Enabled = Value
		if not Value then
			for _, tracerData in pairs(activeTracers) do
				if tracerData.tracer and tracerData.tracer:IsDescendantOf(game) then
					tracerData.tracer:Destroy()
				end
			end
			activeTracers = {}
		end
	end
})

BulletTracer:AddColorPicker('BulletColorPicker', {
	Default = Settings.Color,
	Title = 'BulletTracer Color',
	Callback = function(Value)
		Settings.Color = Value
	end
})

CombatLeft4:AddSlider('EquipTimeAmount', {
	Text = 'Equip Speed Amount',
	Default = 0,
	Min = 0,
	Max = 5,
	Rounding = 1,
	Callback = function(Value)
		if Toggles and Toggles.EquipAnimSpeed and Toggles.EquipAnimSpeed.Value then
			GunModules()
		end
	end
})

CombatLeft4:AddSlider('AimSpeedAmount', {
	Text = 'Aim Speed Amount',
	Default = 0,
	Min = 0,
	Max = 5,
	Rounding = 1,
	Callback = function(Value)
		if Toggles and Toggles.AimAnimSpeed and Toggles.AimAnimSpeed.Value then
			GunModules()
		end
	end
})

createTracer = function(startPos, endPos)
	if not Settings.Enabled then return end
	if not startPos or not endPos then return end
	while #activeTracers >= maxTracers do
		oldestTracer = table.remove(activeTracers, 1)
		if oldestTracer and oldestTracer.tracer:IsDescendantOf(game) then
			oldestTracer.tracer:Destroy()
		end
	end
	tracer = Instance.new("Part")
	tracer.Anchored = true
	tracer.CanCollide = false
	tracer.Material = Enum.Material.Neon
	tracer.Color = Settings.Color
	tracer.Transparency = Settings.Transparency
	tracer.Shape = Enum.PartType.Cylinder
	distance = (startPos - endPos).Magnitude
	tracer.Size = Vector3.new(distance, 0.2, 0.2)
	tracer.CFrame = CFrame.new((startPos + endPos) / 2, endPos) * CFrame.Angles(0, math.pi/2, 0)
	particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://243098098"
	particleEmitter.Color = ColorSequence.new(Settings.Color)
	particleEmitter.Size = NumberSequence.new(0.05)
	particleEmitter.Speed = NumberRange.new(1, 2)
	particleEmitter.SpreadAngle = Vector2.new(-3, 3)
	particleEmitter.Lifetime = NumberRange.new(0.1, 0.15)
	particleEmitter.Rate = 8
	particleEmitter.Drag = 5
	particleEmitter.Enabled = true
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Parent = tracer
	tracer.Parent = game:GetService("Workspace")
	tracerData = {tracer = tracer, startTime = tick()}
	table.insert(activeTracers, tracerData)
	animCoroutine = coroutine.create(function()
		wait(1)
		for t = 0, 1, 0.025 do
			if tracer and tracer.Parent then
				tracer.Transparency = t
			end
			if particleEmitter and particleEmitter.Parent then
				particleEmitter.Rate = math.max(0, 8 - t * 8)
			end
			wait(0.025)
		end
		for i, activeTracer in ipairs(activeTracers) do
			if activeTracer.tracer == tracer then
				table.remove(activeTracers, i)
				break
			end
		end
		if particleEmitter and particleEmitter.Parent then
			particleEmitter:Destroy()
		end
		if tracer and tracer.Parent then
			tracer:Destroy()
		end
	end)
	coroutine.resume(animCoroutine)
	game:GetService("Debris"):AddItem(tracer, 1.5)
end

Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
Workspace = game:GetService("Workspace")

Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
playerName = Players.LocalPlayer.Name
weaponHandle = nil
isShooting = false
lastShotTime = 0
shotCooldown = 0.05
lastRaycastTime = 0
lastBulletHoleTime = 0

findWeaponHandle = function(characterFolder)
	if not characterFolder then return nil end
	for _, weapon in pairs(characterFolder:GetChildren()) do
		if weapon:IsA("Model") and weapon:FindFirstChild("WeaponHandle") then
			return weapon.WeaponHandle
		end
	end
	return nil
end

characterFolder = Workspace.Characters:FindFirstChild(playerName)
if characterFolder then
	weaponHandle = findWeaponHandle(characterFolder)
end

if childAddedConn then
	childAddedConn:Disconnect()
end
childAddedConn = Character.ChildAdded:Connect(function(child)
	if child:IsA("Tool") and child:FindFirstChild("IsGun") then
		GunModules()
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isShooting = true
		lastShotTime = tick()
		if not Character then
			Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		end
		characterFolder = Workspace.Characters:FindFirstChild(playerName)
		if not characterFolder then return end
		weaponHandle = findWeaponHandle(characterFolder)
		if not weaponHandle then return end
		startPos = weaponHandle.Position
		mouse = Players.LocalPlayer:GetMouse()
		endPos = mouse.Hit.Position
		if wallbangEnabled then
			createTracer(startPos, endPos)
			lastRaycastTime = tick()
		else
			ray = Ray.new(startPos, (endPos - startPos).Unit * 1000)
			raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {Character}
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
			raycastResult = Workspace:Raycast(startPos, (endPos - startPos).Unit * 1000, raycastParams)
			if raycastResult and (tick() - lastRaycastTime > 0.05) then
				endPos = raycastResult.Position
				if raycastResult.Instance.Parent:FindFirstChild("Humanoid") or raycastResult.Instance.Name == "BulletHole" then
					createTracer(startPos, endPos)
					lastRaycastTime = tick()
				end
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isShooting = false
	end
end)

if debrisConn then
	debrisConn:Disconnect()
end
debrisConn = Workspace.Debris.ChildAdded:Connect(function(child)
	if not Settings.Enabled then return end
	if child.ClassName == "Part" and child.Name == "BulletHole" then
		if not isShooting and (tick() - lastShotTime > shotCooldown) then return end
		if tick() - lastBulletHoleTime < shotCooldown then return end
		if not Character then
			Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		end
		characterFolder = Workspace.Characters:FindFirstChild(playerName)
		if not characterFolder then return end
		weaponHandle = findWeaponHandle(characterFolder)
		if not weaponHandle then return end
		startPos = weaponHandle.Position
		endPos = child.Position
		if (startPos - endPos).Magnitude < 1000 then
			createTracer(startPos, endPos)
			lastBulletHoleTime = tick()
			lastShotTime = tick()
		end
	end
end)

if characterAddedConn then
	characterAddedConn:Disconnect()
end
characterAddedConn = Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
	playerName = Players.LocalPlayer.Name
	characterFolder = Workspace.Characters:FindFirstChild(playerName)
	if characterFolder then
		weaponHandle = findWeaponHandle(characterFolder)
	end
	GunModules()
	if childAddedConn then
		childAddedConn:Disconnect()
	end
	childAddedConn = newCharacter.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child:FindFirstChild("IsGun") then
			GunModules()
		end
	end)
end)

VisualsLeft = Tabs.Visuals:AddLeftGroupbox('Player esp')
VisualsRight = Tabs.Visuals:AddRightGroupbox('Extra esp')
VisualsLeft2 = Tabs.Visuals:AddLeftGroupbox('Other')

ESPEnabled = false
ShowNameDist = false
ShowHealth = false
ShowWeapon = false
ShowInventory = false
ShowWeaponImage = false
TeamCheck = false
ShowLookDirection = false
ShowHealthBar = false
ShowSkeleton = false
ShowHeadDot = false
ShowTracer = false
ShowChinaHat = false
LookDirectionColor = Color3.fromRGB(255, 203, 138)
SkeletonColor = Color3.fromRGB(255, 255, 255)
HeadDotColor = Color3.fromRGB(255, 0, 0)
TracerColor = Color3.fromRGB(0, 255, 0)
ChinaHatColor = Color3.fromRGB(255, 105, 180)
ESPObjects = {}
TextObjectPool = {}
ImageObjectPool = {}
PlayerData = {}
ESPDistance = 100
LookLines = {}
SkeletonLines = {}
HeadDots = {}
Tracers = {}
ChinaHats = {}
WeaponImageSize = 25
HealthBarObjects = {}
LastUpdateTime = 0
UpdateInterval = 0.2
LastWhiteList = {}
ChamsToggle = false
VisibleColor = Color3.fromRGB(255, 0, 0)
OccludedColor = Color3.fromRGB(255, 255, 255)
HighlightsToggle = false
FillColor = Color3.fromRGB(0, 0, 0)
OutlineColor = Color3.fromRGB(0, 0, 0)
SelfHighlightToggle = false
SelfFillColor = Color3.fromRGB(0, 255, 0)
SelfOutlineColor = Color3.fromRGB(0, 255, 0)
PlayerAdornments = {}
SelfHighlight = Instance.new("Highlight")
SelfHighlight.Parent = game:GetService("CoreGui")
SelfHighlight.Enabled = false

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Camera = workspace.CurrentCamera
LocalPlayer = Players.LocalPlayer

Arrows = {
	Radius = 150,
	Size = UDim2.new(0, 32, 0, 32),
	Image = "rbxassetid://282305485",
	Color = Color3.fromRGB(255, 255, 255),
	Enabled = false,
	TeamCheck = false,
	IgnoreSelf = true,
	UseTeamColor = false,
	Folder = "_Arrows",
	NameLabel = false,
	DistanceLabel = false,
}

_ArrowsFolder = Instance.new("Folder")
_ArrowsFolder.Name = Arrows.Folder
_ArrowsFolder.Parent = game:GetService("CoreGui")

gui = Instance.new("ScreenGui")
gui.Name = "Arrows"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = Arrows.Enabled
gui.Parent = _ArrowsFolder

arrows = {}

weaponImages = {
	["3-CBSTM"] = "rbxassetid://18760010762",
	["725"] = "rbxassetid://9102738327",
	["A-FW-L"] = "rbxassetid://13935966109",
	["A-HL-MK3"] = "rbxassetid://7814455445",
	["A-HL-MK4"] = "rbxassetid://97324964134388",
	["AJM-9"] = "rbxassetid://107851948154232",
	["AKM"] = "rbxassetid://9102820314",
	["AKS-74U"] = "rbxassetid://9102819847",
	["AKS-74U-X"] = "rbxassetid://9102819847",
	["AKS-74UN"] = "rbxassetid://13702487395",
	["AR2"] = "rbxassetid://5861388895",
	["AT4"] = "rbxassetid://15443704781",
	["AWM"] = "rbxassetid://125032277496004",
	["AWM2"] = "rbxassetid://125032277496004",
	["AccurateGoldM4A1-1"] = "rbxassetid://9102820013",
	["AdminRadio"] = "rbxassetid://4570279137",
	["Adrenaline"] = "rbxassetid://12397895006",
	["Airstrike"] = "rbxassetid://9840093037",
	["Antidote"] = "rbxassetid://8053009872",
	["B2Bomber"] = "rbxassetid://12534067603",
	["BBaton"] = "rbxassetid://6924217957",
	["BFG-1"] = "rbxassetid://9830716358",
	["BFSTM-1-X"] = "rbxassetid://18851296364",
	["Balisong"] = "rbxassetid://6964386496",
	["BanHammer"] = "rbxassetid://4813866018",
	["Bandage"] = "rbxassetid://5514211963",
	["Barrett"] = "rbxassetid://6963257084",
	["BarrettM98B"] = "rbxassetid://93157227131515",
	["Bat"] = "rbxassetid://8968282830",
	["Bayonet"] = "rbxassetid://8983371826",
	["Beretta"] = "rbxassetid://9102539745",
	["Beretta-X"] = "rbxassetid://9102539745",
	["BlackBayonet"] = "rbxassetid://99715117337681",
	["C16"] = "rbxassetid://9102351832",
	["C4"] = "rbxassetid://9102351832",
	["COLA-M4A1"] = "rbxassetid://109825110338129",
	["CS-Grenade"] = "rbxassetid://9102351695",
	["CUTE_ODEN"] = "rbxassetid://6155344967",
	["CandyCrowbar"] = "rbxassetid://15697515092",
	["Chainsaw"] = "rbxassetid://9102350595",
	["ChaosBlade"] = "rbxassetid://18591095662",
	["ChaoticBlaster"] = "rbxassetid://18591106489",
	["Chips_1"] = "rbxassetid://11257408161",
	["Chips_2"] = "rbxassetid://11257408071",
	["ChocBar_1"] = "rbxassetid://11257408219",
	["ChocBar_2"] = "rbxassetid://11257408295",
	["Clippers"] = "rbxassetid://15697249177",
	["Coal"] = "rbxassetid://6129469758",
	["Cola_1"] = "rbxassetid://11257407940",
	["Cola_2"] = "rbxassetid://11257408000",
	["CollisionStrike"] = "rbxassetid://91962789",
	["ContrabandDealerCompass"] = "rbxassetid://14657127",
	["CopeCoin"] = "rbxassetid://16942686084",
	["Corruptis"] = "rbxassetid://15679016910",
	["CoupleAirstrike"] = "rbxassetid://7791398884",
	["Crowbar"] = "rbxassetid://9102983786",
	["CursedDagger"] = "rbxassetid://7814402466",
	["DELTA-X04"] = "rbxassetid://17042483483",
	["DRam"] = "rbxassetid://4570281614",
	["DarkRage"] = "rbxassetid://66343245",
	["Deagle"] = "rbxassetid://9102540529",
	["Decimator"] = "rbxassetid://17552865871",
	["DixieGun"] = "rbxassetid://5190533956",
	["Duskbringer_Detonator"] = "rbxassetid://11522216069",
	["ERADICATOR"] = "rbxassetid://6963273879",
	["ERADICATOR-II"] = "rbxassetid://16942337080",
	["FN-FAL"] = "rbxassetid://9102820160",
	["FN-FAL-S"] = "rbxassetid://9102820160",
	["FNP-45"] = "rbxassetid://7675763870",
	["FakeC4"] = "rbxassetid://9102351832",
	["Fire-Axe"] = "rbxassetid://8968282648",
	["FireworkLauncher"] = "rbxassetid://13935966109",
	["Fists"] = "rbxassetid://1568022303",
	["FlareGun"] = "rbxassetid://17151576709",
	["Flashbang"] = "rbxassetid://9102351131",
	["Flashbang+"] = "rbxassetid://9102351131",
	["ForceChoke"] = "rbxassetid://109002724",
	["ForgeRecipeBrowser"] = "rbxassetid://17384003899",
	["FurryPotion"] = "rbxassetid://16529662289",
	["G-17"] = "rbxassetid://9102539923",
	["G-18"] = "rbxassetid://9102540084",
	["G-18-X"] = "rbxassetid://9102540084",
	["G36V"] = "rbxassetid://17700222135",
	["G36V-S"] = "rbxassetid://17700222135",
	["GALIL_ACE_11"] = "rbxassetid://18389896403",
	["GUS_GRENADE"] = "rbxassetid://11360961772",
	["GoldPrecisionStrike"] = "rbxassetid://18909851387",
	["GoldenAxe"] = "rbxassetid://56749982",
	["GoldenCoal"] = "rbxassetid://110397438647808",
	["Golfclub"] = "rbxassetid://6964427940",
	["Grenade"] = "rbxassetid://9102350734",
	["Grimace"] = "rbxassetid://11257407940",
	["HL-MK2"] = "rbxassetid://7814455445",
	["HL-MK3"] = "rbxassetid://116417854764460",
	["HallowsBlade"] = "rbxassetid://17272703938",
	["HallowsLauncher"] = "rbxassetid://7270966410",
	["Hammer"] = "rbxassetid://5455126855",
	["Handcuffs"] = "rbxassetid://4570280480",
	["Hatchet"] = "rbxassetid://18328032363",
	["Hawkeye"] = "rbxassetid://15072162118",
	["HealSerum"] = "rbxassetid://16291625893",
	["HeatVision"] = "rbxassetid://11218881806",
	["HunterPotion"] = "rbxassetid://44410267",
	["Incendiary-Grenade"] = "rbxassetid://9102351525",
	["Invis_AdminRadio"] = "rbxassetid://4570279137",
	["Ithaca-37"] = "rbxassetid://9102738529",
	["KS-23"] = "rbxassetid://17273780539",
	["Katana"] = "rbxassetid://4570280610",
	["Knuckledusters"] = "rbxassetid://8968178686",
	["LaserMusket"] = "rbxassetid://9830716358",
	["LegacyBlackBayonet"] = "rbxassetid://5861388627",
	["LegacyWitchesBrew"] = "rbxassetid://15178997701",
	["Lockpick"] = "rbxassetid://5514211600",
	["M1911"] = "rbxassetid://9102540281",
	["M1911-CONVERTION-1"] = "rbxassetid://9102540281",
	["M320-1"] = "rbxassetid://9102881853",
	["M320-2"] = "rbxassetid://9102881853",
	["M4A1-1"] = "rbxassetid://9102820013",
	["M4A1-S"] = "rbxassetid://9102820013",
	["M60"] = "rbxassetid://15433985807",
	["MAC-10"] = "rbxassetid://9102647474",
	["MAC-10-S"] = "rbxassetid://9102647474",
	["MGL"] = "rbxassetid://4570281022",
	["MP5"] = "rbxassetid://107889520195061",
	["MP7"] = "rbxassetid://9102648114",
	["MP7-S"] = "rbxassetid://9102648114",
	["MS-Grenade"] = "rbxassetid://5958375836",
	["Machete"] = "rbxassetid://8983371702",
	["Magnum"] = "rbxassetid://9102647029",
	["Mare"] = "rbxassetid://9102881727",
	["Mare-C"] = "rbxassetid://17381352933",
	["Medkit"] = "rbxassetid://5021810486",
	["Metal-Bat"] = "rbxassetid://8968283096",
	["Minigun"] = "rbxassetid://94096757996557",
	["Missilestrike"] = "rbxassetid://21501695",
	["Molotov"] = "rbxassetid://9102350984",
	["MonsterMash"] = "rbxassetid://15260887122",
	["Musket"] = "rbxassetid://18324292478",
	["MutantMagnum"] = "rbxassetid://9102647029",
	["NeckSnap"] = "rbxassetid://3116861802",
	["NevermoreDagger"] = "rbxassetid://6115281038",
	["NewBloxyCola"] = "rbxassetid://10472127",
	["NewHealingPotion"] = "rbxassetid://11418339",
	["Nunchucks"] = "rbxassetid://8968283371",
	["ODEN-1"] = "rbxassetid://6155344967",
	["ODEN-S"] = "rbxassetid://6155344967",
	["OLD_MARE"] = "rbxassetid://5190533956",
	["OldMinigun"] = "rbxassetid://15902141317",
	["P-ODEN-1"] = "rbxassetid://6155344967",
	["P-RCU_FNP-45"] = "rbxassetid://7675763870",
	["PK-500"] = "rbxassetid://18914582686",
	["Panzerfaust-3"] = "rbxassetid://6963297260",
	["Pepper-spray"] = "rbxassetid://4689462559",
	["PhotonAccelerator"] = "rbxassetid://16596788618",
	["PhotonBlades"] = "rbxassetid://15749911617",
	["Plasma-Rocket-Launcher"] = "rbxassetid://15342196794",
	["Plasma-UTS-1"] = "rbxassetid://15341643471",
	["PrecisionStrike"] = "rbxassetid://91962789",
	["ProjectileSpawner"] = "rbxassetid://18864756695",
	["PublicAirstrike"] = "rbxassetid://9840093037",
	["PublicPrecisionStrike"] = "rbxassetid://15697337306",
	["RCU_Bandage"] = "rbxassetid://6153585607",
	["RCU_FNP-45"] = "rbxassetid://7675763870",
	["RCU_RiotShield"] = "rbxassetid://6153585055",
	["RPG-18"] = "rbxassetid://14800109869",
	["RPG-29"] = "rbxassetid://120257671394968",
	["RPG-7"] = "rbxassetid://9102881989",
	["RPG-G"] = "rbxassetid://83859163267055",
	["RR_Radio"] = "rbxassetid://4763575350",
	["RSh-12"] = "rbxassetid://18836420529",
	["Radio"] = "rbxassetid://5056238850",
	["Rage-potion"] = "rbxassetid://66343245",
	["Rambo"] = "rbxassetid://8968135333",
	["RayGun"] = "rbxassetid://11601851755",
	["Redeemer"] = "rbxassetid://17538033225",
	["ReforgedKatana"] = "rbxassetid://14800098028",
	["Relic"] = "rbxassetid://16312443687",
	["Rendbreaker"] = "rbxassetid://135920281356606",
	["RiftWaker"] = "rbxassetid://17505438479",
	["RiotShield"] = "rbxassetid://6153585055",
	["RoyalBroadsword"] = "rbxassetid://92143102502281",
	["SB-Launcher"] = "rbxassetid://6128465213",
	["SB-Minigun"] = "rbxassetid://6131053699",
	["SBL-MK2"] = "rbxassetid://9240332756",
	["SBL-MK3"] = "rbxassetid://15687904518",
	["SCAR-H-1"] = "rbxassetid://13379814638",
	["SCAR-H-X"] = "rbxassetid://13379814638",
	["SKS"] = "rbxassetid://9322303767",
	["SKS-X"] = "rbxassetid://9322303767",
	["Sabre"] = "rbxassetid://18327959432",
	["Savage"] = "rbxassetid://16221658019",
	["Sawn-Off"] = "rbxassetid://9102738327",
	["ScopelessBFGWithASilencer"] = "rbxassetid://9830716358",
	["Scout"] = "rbxassetid://9830716753",
	["Scythe"] = "rbxassetid://11329574230",
	["SelfDetonator"] = "rbxassetid://11522216069",
	["Shiv"] = "rbxassetid://8983371530",
	["Shovel"] = "rbxassetid://8968283214",
	["SillyGuitar"] = "rbxassetid://55735329",
	["Skyfall T.A.G."] = "rbxassetid://17199195221",
	["SlayerSword"] = "rbxassetid://9214967819",
	["Sledgehammer"] = "rbxassetid://13379814837",
	["Smoke-Grenade"] = "rbxassetid://5002850714",
	["Snowball"] = "rbxassetid://6128391694",
	["SoulVial"] = "rbxassetid://18167588657",
	["Splint"] = "rbxassetid://7371337380",
	["SquidwardC4"] = "rbxassetid://16934136003",
	["Stun-Grenade"] = "rbxassetid://9102351313",
	["Super-Shorty"] = "rbxassetid://9102755894",
	["TEC-9"] = "rbxassetid://9102540386",
	["Taco"] = "rbxassetid://14846949",
	["Taiga"] = "rbxassetid://8983372577",
	["Taser"] = "rbxassetid://9102539923",
	["TeddyBloxpin"] = "rbxassetid://12218172",
	["Termination"] = "rbxassetid://189841509",
	["TeslaCannon"] = "rbxassetid://140296347775236",
	["TheCure"] = "rbxassetid://7814615388",
	["Thermal-Katana"] = "rbxassetid://15508052260",
	["Tomahawk"] = "rbxassetid://14800096968",
	["Tommy"] = "rbxassetid://9102647830",
	["Tommy-S"] = "rbxassetid://9102647830",
	["TripleAirstrike"] = "rbxassetid://4570279329",
	["TurkeyLeg"] = "rbxassetid://13073604",
	["UMP-45"] = "rbxassetid://9102648280",
	["UMP-45-S"] = "rbxassetid://9102648280",
	["URM_Deagle"] = "rbxassetid://4570279967",
	["URM_MGL"] = "rbxassetid://4570281022",
	["USP"] = "rbxassetid://17553427120",
	["UTS-15"] = "rbxassetid://4570282766",
	["UTS-S"] = "rbxassetid://4570282766",
	["Uzi"] = "rbxassetid://9102647258",
	["Uzi-S"] = "rbxassetid://9102647258",
	["VirusPotion"] = "rbxassetid://17561012740",
	["W-ChocBar_1"] = "rbxassetid://11257408219",
	["Whistle"] = "rbxassetid://128121687",
	["WitchesBrew"] = "rbxassetid://15178997701",
	["Wrench"] = "rbxassetid://8968178496",
	["X13"] = "rbxassetid://17108176074",
	["X24"] = "rbxassetid://13939003452",
	["X31"] = "rbxassetid://18289871778",
	["_AKM-S"] = "rbxassetid://9102820314",
	["_AKS-74UN"] = "rbxassetid://9351598417",
	["_BFists"] = "rbxassetid://17557986776",
	["_CompoundXVision"] = "rbxassetid://8600869433",
	["_CompoundXVision0.5"] = "rbxassetid://8600869433",
	["_CompoundXVision2"] = "rbxassetid://8600869433",
	["_FM1911"] = "rbxassetid://117258732953458",
	["_FallenBlade"] = "rbxassetid://15665357297",
	["_Fist"] = "rbxassetid://17297138255",
	["_G-17-S"] = "rbxassetid://9102539923",
	["_M4"] = "rbxassetid://9102820013",
	["_OLD_SlayerSword"] = "rbxassetid://6128392041",
	["_PurpleGuysAxe"] = "rbxassetid://4898859361",
	["_Sledge"] = "rbxassetid://10478994695",
	["__AKM-N"] = "rbxassetid://9102820314",
	["__InfantryRadioBlue"] = "rbxassetid://4763575350",
	["__InfantryRadioRed"] = "rbxassetid://4763575350",
	["__RiotShield"] = "rbxassetid://6153585055",
	["__Spitball"] = "rbxassetid://9789474866",
	["__TestDeagle"] = "rbxassetid://4570279967",
	["__XFists"] = "rbxassetid://12737447569",
	["__ZombieFists1"] = "rbxassetid://1568022303",
	["__ZombieFists2"] = "rbxassetid://1568022303",
	["__ZombieFists3"] = "rbxassetid://1568022303",
	["__ZombieFists4"] = "rbxassetid://1568022303",
	["___devorak_HealSerum"] = "rbxassetid://16291625893",
	["key_Blue"] = "rbxassetid://16910400691",
	["key_Red"] = "rbxassetid://16910341157",
	["legacyUTS-15"] = "rbxassetid://4570282766",
	["legacyUTS-S"] = "rbxassetid://4570282766",
	["new_oldSlayerSword"] = "rbxassetid://6128392041",
	["notmen"] = "rbxassetid://11146000563",
	["val_Battery"] = "rbxassetid://11146000563",
	["val_Blueprint"] = "rbxassetid://11146001576",
	["val_Cloth"] = "rbxassetid://11145999977",
	["val_Documents"] = "rbxassetid://11146001054",
	["val_Dogtag"] = "rbxassetid://11146001318",
	["val_FloppyDrive"] = "rbxassetid://11146002677",
	["val_Jerrycan"] = "rbxassetid://11146002055",
	["val_Keytool"] = "rbxassetid://11146002888",
	["val_Lighter"] = "rbxassetid://11147971879",
	["val_MilitaryCable"] = "rbxassetid://11146001759",
	["val_PlasmaAcid"] = "rbxassetid://14385011909",
	["val_SkullRing"] = "rbxassetid://11146003198",
	["val_VenomVial"] = "rbxassetid://17146007521",
	["val_Watch"] = "rbxassetid://11146002388",
	["val_WeaponParts"] = "rbxassetid://11145999491",
	["val_Wires"] = "rbxassetid://11146000815"
}

function CreateTextESP(parent, text, offset)
	BillboardGui = table.remove(TextObjectPool) or Instance.new("BillboardGui")
	TextLabel = BillboardGui:FindFirstChild("TextLabel") or Instance.new("TextLabel")
	BillboardGui.Parent = parent
	BillboardGui.AlwaysOnTop = true
	BillboardGui.Size = UDim2.new(0, 200, 0, 50)
	BillboardGui.StudsOffset = offset
	BillboardGui.MaxDistance = 1000
	BillboardGui.LightInfluence = 0
	TextLabel.Parent = BillboardGui
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Text = text
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextSize = 14
	TextLabel.Font = Enum.Font.SourceSans
	return BillboardGui
end

function CreateWeaponImageESP(parent, weaponName)
	BillboardGui = table.remove(ImageObjectPool) or Instance.new("BillboardGui")
	ImageLabel = BillboardGui:FindFirstChild("ImageLabel") or Instance.new("ImageLabel")
	BillboardGui.Parent = parent
	BillboardGui.AlwaysOnTop = true
	BillboardGui.Size = UDim2.new(0, WeaponImageSize, 0, WeaponImageSize)
	BillboardGui.StudsOffset = Vector3.new(0, -3, 0)
	BillboardGui.MaxDistance = 1000
	BillboardGui.LightInfluence = 0
	ImageLabel.Parent = BillboardGui
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.Size = UDim2.new(1, 0, 1, 0)
	ImageLabel.Image = weaponImages[weaponName] or ""
	return BillboardGui
end

function CreateHealthBarESP(parent, humanoid, distance)
	if HealthBarObjects[parent] then
		HealthBarObjects[parent]:Destroy()
		HealthBarObjects[parent] = nil
	end

	BillboardGui = Instance.new("BillboardGui")
	Frame = Instance.new("Frame")
	HealthFrame = Instance.new("Frame")

	BillboardGui.Parent = parent
	BillboardGui.Name = "HealthBar"
	ScaleFactor = math.clamp((ESPDistance * 0.2) / (distance + ESPDistance * 0.05), 0.5, 1.5)
	BillboardGui.Size = UDim2.new(0.5 * ScaleFactor, 0, 5 * ScaleFactor, 0)
	BillboardGui.StudsOffset = Vector3.new(-2 * ScaleFactor, 0, 0)
	BillboardGui.AlwaysOnTop = true
	BillboardGui.MaxDistance = ESPDistance
	BillboardGui.LightInfluence = 0

	Frame.Size = UDim2.new(1, 0, 1, 0)
	Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Frame.BorderSizePixel = 0
	Frame.Parent = BillboardGui

	HealthFrame.Name = "Health"
	HealthFrame.Size = UDim2.new(1, 0, 1, 0)
	HealthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	HealthFrame.BorderSizePixel = 0
	HealthFrame.AnchorPoint = Vector2.new(0, 1)
	HealthFrame.Position = UDim2.new(0, 0, 1, 0)
	HealthFrame.Parent = Frame

	UpdateHealth = function()
		HealthPercent = humanoid.Health / humanoid.MaxHealth
		HealthFrame.Size = UDim2.new(1, 0, HealthPercent, 0)
		if HealthPercent > 0.5 then
			HealthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		elseif HealthPercent > 0.3 then
			HealthFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
		else
			HealthFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		end
	end

	humanoid:GetPropertyChangedSignal("Health"):Connect(UpdateHealth)
	humanoid.Died:Connect(function()
		if HealthBarObjects[parent] then
			HealthBarObjects[parent]:Destroy()
			HealthBarObjects[parent] = nil
		end
	end)

	UpdateHealth()
	HealthBarObjects[parent] = BillboardGui
	return BillboardGui
end

function CreateChinaHat(character)
	if ChinaHats[character] then
		ChinaHats[character]:Destroy()
		ChinaHats[character] = nil
	end

	head = character:FindFirstChild("Head")
	if not head then return end

	cone = Instance.new("Part")
	cone.Size = Vector3.new(1, 1, 1)
	cone.BrickColor = BrickColor.new("White")
	cone.Transparency = 0.3
	cone.Anchored = false
	cone.CanCollide = false

	mesh = Instance.new("SpecialMesh", cone)
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://1033714"
	mesh.Scale = Vector3.new(1.7, 1.1, 1.7)

	weld = Instance.new("Weld")
	weld.Part0 = head
	weld.Part1 = cone
	weld.C0 = CFrame.new(0, 0.9, 0)

	cone.Parent = character
	weld.Parent = cone

	highlight = Instance.new("Highlight", cone)
	highlight.FillColor = ChinaHatColor
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = ChinaHatColor
	highlight.OutlineTransparency = 0

	ChinaHats[character] = cone
end

function CreateAdornments(part)
	Adornments = {}
	for vis = 1, 2 do
		if part.Name == "Head" then
			Adornments[vis] = Instance.new("CylinderHandleAdornment")
			Adornments[vis].Height = 1.2
			Adornments[vis].Radius = 0.78
			Adornments[vis].CFrame = CFrame.new(Vector3.new(), Vector3.new(0, 1, 0))
			if vis == 1 then
				Adornments[vis].Radius = Adornments[vis].Radius - 0.15
				Adornments[vis].Height = Adornments[vis].Height - 0.15
			end
		else
			Adornments[vis] = Instance.new("BoxHandleAdornment")
			Adornments[vis].Size = part.Size + Vector3.new(0.2, 0.2, 0.2)
			if vis == 1 then
				Adornments[vis].Size = Adornments[vis].Size - Vector3.new(0.15, 0.15, 0.15)
			end
		end
		Adornments[vis].Parent = game:GetService("CoreGui")
		Adornments[vis].Adornee = part
		Adornments[vis].Name = vis == 1 and "Invisible" or "Visible"
		Adornments[vis].ZIndex = vis == 1 and 2 or 1
		Adornments[vis].AlwaysOnTop = vis == 1
	end
	return Adornments
end

function GetPlayerData(player)
	if not PlayerData[player] then
		PlayerData[player] = {Weapon = "", Inventory = {}, Health = 100}
	end
	return PlayerData[player]
end

function ClearESP()
	for _, obj in pairs(ESPObjects) do
		obj.Parent = nil
		if obj:FindFirstChild("TextLabel") then
			table.insert(TextObjectPool, obj)
		elseif obj:FindFirstChild("ImageLabel") then
			table.insert(ImageObjectPool, obj)
		end
	end
	ESPObjects = {}
	for _, obj in pairs(HealthBarObjects) do
		obj:Destroy()
	end
	HealthBarObjects = {}
	for player, line in pairs(LookLines) do
		line:Remove()
	end
	LookLines = {}
	for player, lines in pairs(SkeletonLines) do
		for _, line in pairs(lines) do
			line:Remove()
		end
	end
	SkeletonLines = {}
	for player, dot in pairs(HeadDots) do
		dot:Remove()
	end
	HeadDots = {}
	for player, tracer in pairs(Tracers) do
		tracer:Remove()
	end
	Tracers = {}
	for character, hat in pairs(ChinaHats) do
		hat:Destroy()
	end
	ChinaHats = {}
	for _, player in pairs(PlayerAdornments) do
		player.Highlight.Enabled = false
		player.Highlight.Adornee = nil
		for _, adornmentsTable in pairs(player.Adornments) do
			for _, adornment in pairs(adornmentsTable) do
				adornment.Visible = false
			end
		end
	end
	SelfHighlight.Enabled = false
	SelfHighlight.Adornee = nil
end

function CountItems(items)
	Counted = {}
	for _, item in pairs(items) do
		if item:IsA("Tool") then
			Counted[item.Name] = (Counted[item.Name] or 0) + 1
		end
	end
	Result = ""
	for name, count in pairs(Counted) do
		if count > 1 then
			Result = Result .. name .. " (" .. count .. "), "
		else
			Result = Result .. name .. ", "
		end
	end
	return Result ~= "" and Result:sub(1, -3) or ""
end

function UpdateESP()
	CurrentTime = tick()
	if CurrentTime - LastUpdateTime < UpdateInterval then
		return
	end
	LastUpdateTime = CurrentTime

	if not ESPEnabled then
		ClearESP()
		return
	end

	for _, obj in pairs(ESPObjects) do
		obj.Parent = nil
		if obj:FindFirstChild("TextLabel") then
			table.insert(TextObjectPool, obj)
		elseif obj:FindFirstChild("ImageLabel") then
			table.insert(ImageObjectPool, obj)
		end
	end
	ESPObjects = {}

	LocalPlayer = game.Players.LocalPlayer
	LocalTeam = LocalPlayer.Team
	LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not LocalRoot then return end

	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
			RootPart = player.Character.HumanoidRootPart
			Humanoid = player.Character.Humanoid
			Distance = (RootPart.Position - LocalRoot.Position).Magnitude

			if Distance > ESPDistance or (TeamCheck and LocalTeam and player.Team == LocalTeam and player ~= LocalPlayer) then
				if HealthBarObjects[RootPart] then
					HealthBarObjects[RootPart]:Destroy()
					HealthBarObjects[RootPart] = nil
				end
				continue
			end

			if player ~= LocalPlayer then
				Data = GetPlayerData(player)
				Tool = player.Character:FindFirstChildOfClass("Tool")
				Backpack = player:FindFirstChild("Backpack")

				if ShowNameDist or ShowWeapon or ShowHealth then
					Text = ""
					if ShowNameDist then
						Text = player.Name .. " | " .. math.floor(Distance) .. " studs"
					end
					if ShowWeapon and Tool then
						Text = Text .. (Text ~= "" and " | " or "") .. Tool.Name
					end
					if ShowHealth then
						Text = Text .. (Text ~= "" and " | " or "") .. math.floor(Humanoid.Health)
					end
					if Text ~= "" then
						table.insert(ESPObjects, CreateTextESP(RootPart, Text, Vector3.new(0, 3, 0)))
					end
				end

				if ShowInventory and Backpack then
					Items = CountItems(Backpack:GetChildren())
					if Items ~= "" then
						table.insert(ESPObjects, CreateTextESP(RootPart, Items, Vector3.new(0, -2, 0)))
					end
				end

				if ShowWeaponImage and Tool and weaponImages[Tool.Name] then
					table.insert(ESPObjects, CreateWeaponImageESP(RootPart, Tool.Name))
				end

				if ShowHealthBar then
					table.insert(ESPObjects, CreateHealthBarESP(RootPart, Humanoid, Distance))
				elseif HealthBarObjects[RootPart] then
					HealthBarObjects[RootPart]:Destroy()
					HealthBarObjects[RootPart] = nil
				end
			end
		else
			if player.Character then
				RootPart = player.Character:FindFirstChild("HumanoidRootPart")
				if RootPart and HealthBarObjects[RootPart] then
					HealthBarObjects[RootPart]:Destroy()
					HealthBarObjects[RootPart] = nil
				end
				if player.Character and ChinaHats[player.Character] then
					ChinaHats[player.Character]:Destroy()
					ChinaHats[player.Character] = nil
				end
			end
		end
	end
end

function UpdateDynamicESP()
	if not ESPEnabled then
		for player, lines in pairs(SkeletonLines) do
			for _, line in pairs(lines) do
				line.Visible = false
			end
		end
		for player, dot in pairs(HeadDots) do
			dot.Visible = false
		end
		for player, tracer in pairs(Tracers) do
			tracer.Visible = false
		end
		return
	end

	LocalPlayer = game.Players.LocalPlayer
	LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not LocalRoot then return end

	for _, player in pairs(game.Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
			RootPart = player.Character.HumanoidRootPart
			Humanoid = player.Character.Humanoid
			Distance = (RootPart.Position - LocalRoot.Position).Magnitude
			LocalTeam = LocalPlayer.Team

			if Distance > ESPDistance or (TeamCheck and LocalTeam and player.Team == LocalTeam) then
				if SkeletonLines[player] then
					for _, line in pairs(SkeletonLines[player]) do
						line.Visible = false
					end
				end
				if HeadDots[player] then
					HeadDots[player].Visible = false
				end
				if Tracers[player] then
					Tracers[player].Visible = false
				end
				continue
			end

			if ShowSkeleton and Humanoid.Health > 0 then
				head = player.Character:FindFirstChild("Head")
				torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
				leftArm = player.Character:FindFirstChild("Left Arm") or player.Character:FindFirstChild("LeftUpperArm")
				rightArm = player.Character:FindFirstChild("Right Arm") or player.Character:FindFirstChild("RightUpperArm")
				leftLeg = player.Character:FindFirstChild("Left Leg") or player.Character:FindFirstChild("LeftUpperLeg")
				rightLeg = player.Character:FindFirstChild("Right Leg") or player.Character:FindFirstChild("RightUpperLeg")

				if head and torso and leftArm and rightArm and leftLeg and rightLeg then
					if not SkeletonLines[player] then
						SkeletonLines[player] = {
							HeadToTorso = Drawing.new("Line"),
							TorsoToLeftArm = Drawing.new("Line"),
							LeftArmToHand = Drawing.new("Line"),
							TorsoToRightArm = Drawing.new("Line"),
							RightArmToHand = Drawing.new("Line"),
							TorsoToLeftLeg = Drawing.new("Line"),
							LeftLegToFoot = Drawing.new("Line"),
							TorsoToRightLeg = Drawing.new("Line"),
							RightLegToFoot = Drawing.new("Line"),
						}
						for _, line in pairs(SkeletonLines[player]) do
							line.Color = SkeletonColor
							line.Thickness = 1
							line.Transparency = 1
						end
					end

					function updateLine(line, part1, part2)
						pos1, onScreen1 = game.Workspace.CurrentCamera:WorldToViewportPoint(part1.Position)
						pos2, onScreen2 = game.Workspace.CurrentCamera:WorldToViewportPoint(part2.Position)
						line.Visible = onScreen1 and onScreen2
						if line.Visible then
							line.From = Vector2.new(pos1.X, pos1.Y)
							line.To = Vector2.new(pos2.X, pos2.Y)
						end
					end

					updateLine(SkeletonLines[player].HeadToTorso, head, torso)
					updateLine(SkeletonLines[player].TorsoToLeftArm, torso, leftArm)
					updateLine(SkeletonLines[player].LeftArmToHand, leftArm, leftArm)
					updateLine(SkeletonLines[player].TorsoToRightArm, torso, rightArm)
					updateLine(SkeletonLines[player].RightArmToHand, rightArm, rightArm)
					updateLine(SkeletonLines[player].TorsoToLeftLeg, torso, leftLeg)
					updateLine(SkeletonLines[player].LeftLegToFoot, leftLeg, leftLeg)
					updateLine(SkeletonLines[player].TorsoToRightLeg, torso, rightLeg)
					updateLine(SkeletonLines[player].RightLegToFoot, rightLeg, rightLeg)
				else
					if SkeletonLines[player] then
						for _, line in pairs(SkeletonLines[player]) do
							line.Visible = false
						end
					end
				end
			elseif SkeletonLines[player] then
				for _, line in pairs(SkeletonLines[player]) do
					line.Visible = false
				end
			end

			if ShowHeadDot and player.Character:FindFirstChild("Head") and Humanoid.Health > 0 then
				head = player.Character:FindFirstChild("Head")
				if not HeadDots[player] then
					HeadDots[player] = Drawing.new("Circle")
					HeadDots[player].Color = HeadDotColor
					HeadDots[player].Thickness = 3
					HeadDots[player].NumSides = 12
					HeadDots[player].Radius = 1.2
					HeadDots[player].Filled = true
				end
				headScreen, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
				HeadDots[player].Visible = onScreen
				if onScreen then
					baseRadius = 1.2
					fov = 70
					scale = (game.Workspace.CurrentCamera.ViewportSize.Y / 2) / (math.tan(math.rad(fov / 2)) * Distance)
					HeadDots[player].Radius = math.clamp(baseRadius * scale * 0.3, 1, 3)
					HeadDots[player].Position = Vector2.new(headScreen.X, headScreen.Y)
				end
			elseif HeadDots[player] then
				HeadDots[player].Visible = false
			end

			if ShowTracer and Humanoid.Health > 0 then
				rootPart = player.Character:FindFirstChild("HumanoidRootPart")
				if not Tracers[player] then
					Tracers[player] = Drawing.new("Line")
					Tracers[player].Color = TracerColor
					Tracers[player].Thickness = 1
					Tracers[player].Transparency = 1
				end
				rootScreen, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
				Tracers[player].Visible = onScreen
				if onScreen then
					Tracers[player].From = Vector2.new(game.Workspace.CurrentCamera.ViewportSize.X / 2, game.Workspace.CurrentCamera.ViewportSize.Y / 2)
					Tracers[player].To = Vector2.new(rootScreen.X, rootScreen.Y)
				end
			elseif Tracers[player] then
				Tracers[player].Visible = false
			end
		else
			if SkeletonLines[player] then
				for _, line in pairs(SkeletonLines[player]) do
					line.Visible = false
				end
			end
			if HeadDots[player] then
				HeadDots[player].Visible = false
			end
			if Tracers[player] then
				Tracers[player].Visible = false
			end
		end
	end
end

function UpdateLookDirection()
	if not ESPEnabled or not ShowLookDirection then
		for player, line in pairs(LookLines) do
			line:Remove()
			LookLines[player] = nil
		end
		return
	end

	LocalPlayer = game.Players.LocalPlayer
	LocalTeam = LocalPlayer.Team
	LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not LocalRoot then return end

	for _, player in pairs(game.Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
			RootPart = player.Character.HumanoidRootPart
			Humanoid = player.Character.Humanoid
			Distance = (RootPart.Position - LocalRoot.Position).Magnitude

			if Distance > ESPDistance or (TeamCheck and LocalTeam and player.Team == LocalTeam) then
				if LookLines[player] then
					LookLines[player]:Remove()
					LookLines[player] = nil
				end
				continue
			end

			if player.Character:FindFirstChild("Head") and Humanoid.Health > 0 then
				if not LookLines[player] then
					LookLines[player] = Drawing.new("Line")
					LookLines[player].Color = LookDirectionColor
					LookLines[player].Thickness = 1
					LookLines[player].Transparency = 1
				end
				HeadPos, OnScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
				if OnScreen then
					LookVector = player.Character.Head.CFrame.LookVector
					EndPos = player.Character.Head.Position + LookVector * 15
					EndPosScreen, Visible = game.Workspace.CurrentCamera:WorldToViewportPoint(EndPos)
					LookLines[player].From = Vector2.new(HeadPos.X, HeadPos.Y)
					LookLines[player].To = Vector2.new(EndPosScreen.X, EndPosScreen.Y)
					LookLines[player].Visible = Visible
					LookLines[player].Thickness = math.clamp(1 / Distance * ESPDistance, 0.1, 3)
				else
					LookLines[player].Visible = false
				end
			elseif LookLines[player] then
				LookLines[player]:Remove()
				LookLines[player] = nil
			end
		else
			if LookLines[player] then
				LookLines[player]:Remove()
				LookLines[player] = nil
			end
		end
	end
end

function UpdateChinaHat()
	if not ShowChinaHat then
		for character, hat in pairs(ChinaHats) do
			hat:Destroy()
			ChinaHats[character] = nil
		end
		return
	end

	LocalPlayer = game.Players.LocalPlayer
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
			Humanoid = player.Character.Humanoid
			if Humanoid.Health > 0 then
				ShouldShowHat = (player == LocalPlayer) or IsWhitelisted
				if ShouldShowHat then
					if not ChinaHats[player.Character] then
						CreateChinaHat(player.Character)
					else
						highlight = ChinaHats[player.Character]:FindFirstChildOfClass("Highlight")
						if highlight then
							highlight.FillColor = ChinaHatColor
							highlight.OutlineColor = ChinaHatColor
						end
					end
				elseif ChinaHats[player.Character] then
					ChinaHats[player.Character]:Destroy()
					ChinaHats[player.Character] = nil
				end
			elseif ChinaHats[player.Character] then
				ChinaHats[player.Character]:Destroy()
				ChinaHats[player.Character] = nil
			end
		elseif player.Character and ChinaHats[player.Character] then
			ChinaHats[player.Character]:Destroy()
			ChinaHats[player.Character] = nil
		end
	end
end

function UpdateVisuals()
	if not ESPEnabled then
		for _, player in pairs(PlayerAdornments) do
			player.Highlight.Enabled = false
			player.Highlight.Adornee = nil
			for _, adornmentsTable in pairs(player.Adornments) do
				for _, adornment in pairs(adornmentsTable) do
					adornment.Visible = false
				end
			end
		end
		SelfHighlight.Enabled = false
		SelfHighlight.Adornee = nil
		return
	end

	LocalPlayer = game.Players.LocalPlayer
	LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not LocalRoot then 
		SelfHighlight.Enabled = false
		SelfHighlight.Adornee = nil
		return 
	end

	if SelfHighlightToggle and ESPEnabled and LocalPlayer.Character then
		SelfHighlight.Adornee = LocalPlayer.Character
		SelfHighlight.Enabled = true
		SelfHighlight.FillColor = SelfFillColor
		SelfHighlight.OutlineColor = SelfOutlineColor
		SelfHighlight.FillTransparency = 0
		SelfHighlight.OutlineTransparency = 0
	else
		SelfHighlight.Enabled = false
		SelfHighlight.Adornee = nil
	end

	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player == LocalPlayer then continue end

		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			if PlayerAdornments[player] then
				PlayerAdornments[player].Highlight.Enabled = false
				PlayerAdornments[player].Highlight.Adornee = nil
				for _, adornmentsTable in pairs(PlayerAdornments[player].Adornments) do
					for _, adornment in pairs(adornmentsTable) do
						adornment.Visible = false
					end
				end
			end
			continue
		end

		Distance = (player.Character.HumanoidRootPart.Position - LocalRoot.Position).Magnitude
		if Distance > ESPDistance or (TeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team) then
			if PlayerAdornments[player] then
				PlayerAdornments[player].Highlight.Enabled = false
				PlayerAdornments[player].Highlight.Adornee = nil
				for _, adornmentsTable in pairs(PlayerAdornments[player].Adornments) do
					for _, adornment in pairs(adornmentsTable) do
						adornment.Visible = false
					end
				end
			end
			continue
		end

		if not PlayerAdornments[player] then
			PlayerAdornments[player] = {
				Highlight = Instance.new("Highlight"),
				Adornments = {},
				NeedsUpdate = true,
				LastUpdate = 0
			}
			PlayerAdornments[player].Highlight.Parent = game:GetService("CoreGui")
			PlayerAdornments[player].Highlight.Enabled = false
		end

		if HighlightsToggle and ESPEnabled then
			PlayerAdornments[player].Highlight.Enabled = true
			PlayerAdornments[player].Highlight.FillColor = FillColor
			PlayerAdornments[player].Highlight.OutlineColor = OutlineColor
			PlayerAdornments[player].Highlight.FillTransparency = 0
			PlayerAdornments[player].Highlight.OutlineTransparency = 0
			PlayerAdornments[player].Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			PlayerAdornments[player].Highlight.Adornee = player.Character
		else
			PlayerAdornments[player].Highlight.Enabled = false
			PlayerAdornments[player].Highlight.Adornee = nil
		end

		if ChamsToggle then
			if PlayerAdornments[player].NeedsUpdate or (tick() - PlayerAdornments[player].LastUpdate > 30) then
				for _, part in pairs(player.Character:GetChildren()) do
					if part:IsA("BasePart") and table.find({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, part.Name) then
						if not PlayerAdornments[player].Adornments[part] then
							PlayerAdornments[player].Adornments[part] = CreateAdornments(part)
						end
						PlayerAdornments[player].Adornments[part][1].Visible = true
						PlayerAdornments[player].Adornments[part][1].Color3 = OccludedColor
						PlayerAdornments[player].Adornments[part][1].Transparency = 0
						PlayerAdornments[player].Adornments[part][2].Visible = true
						PlayerAdornments[player].Adornments[part][2].Color3 = VisibleColor
						PlayerAdornments[player].Adornments[part][2].Transparency = 0.5
						PlayerAdornments[player].Adornments[part][2].AlwaysOnTop = false
						PlayerAdornments[player].Adornments[part][2].ZIndex = 1
					end
				end
				PlayerAdornments[player].NeedsUpdate = false
				PlayerAdornments[player].LastUpdate = tick()
			end
		else
			for _, adornmentsTable in pairs(PlayerAdornments[player].Adornments) do
				for _, adornment in pairs(adornmentsTable) do
					adornment.Visible = false
				end
			end
		end
	end
end

function createArrow()
	container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(0, 100, 0, 70)
	container.Name = "ArrowContainer"
	container.ZIndex = 10
	container.Visible = Arrows.Enabled
	container.Parent = gui

	arrow = Instance.new("ImageLabel")
	arrow.Name = "Arrow"
	arrow.AnchorPoint = Vector2.new(0.5, 0)
	arrow.BackgroundTransparency = 1
	arrow.Size = Arrows.Size
	arrow.Image = Arrows.Image
	arrow.ZIndex = 10
	arrow.Position = UDim2.new(0.5, 0, 0, 0)
	arrow.Parent = container

	nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.AnchorPoint = Vector2.new(0.5, 0)
	nameLabel.Position = UDim2.new(0.5, 0, 0, Arrows.Size.Y.Offset + 2)
	nameLabel.Size = UDim2.new(1, 0, 0, 20)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Font = Enum.Font.Code
	nameLabel.TextSize = 17
	nameLabel.Text = ""
	nameLabel.Visible = Arrows.NameLabel
	nameLabel.ZIndex = 10
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.Parent = container

	distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "Distance"
	distanceLabel.AnchorPoint = Vector2.new(0.5, 0)
	distanceLabel.Position = UDim2.new(0.5, 0, 0, Arrows.Size.Y.Offset + 24)
	distanceLabel.Size = UDim2.new(1, 0, 0, 18)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.TextColor3 = Color3.new(1, 1, 1)
	distanceLabel.TextStrokeTransparency = 0.5
	distanceLabel.Font = Enum.Font.Code
	distanceLabel.TextSize = 16
	distanceLabel.Text = ""
	distanceLabel.Visible = Arrows.DistanceLabel
	distanceLabel.ZIndex = 10
	distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
	distanceLabel.Parent = container

	return container
end

ESPEnabledToggle = VisualsLeft:AddToggle('ESPEnabled', {
	Text = "Enable ESP",
	Default = false,
	Callback = function(Value)
		ESPEnabled = Value
		if Value then
			ChamsToggle = false
			SelfHighlightToggle = false
			HighlightsToggle = false
			for _, player in pairs(PlayerAdornments) do
				player.Highlight.Enabled = false
				player.Highlight.Adornee = nil
				for _, adornmentsTable in pairs(player.Adornments) do
					for _, adornment in pairs(adornmentsTable) do
						adornment.Visible = false
					end
				end
			end
			SelfHighlight.Enabled = false
			SelfHighlight.Adornee = nil
		else
			ClearESP()
			ChamsToggle = false
			SelfHighlightToggle = false
			HighlightsToggle = false
			for _, player in pairs(PlayerAdornments) do
				player.Highlight.Enabled = false
				player.Highlight.Adornee = nil
				for _, adornmentsTable in pairs(player.Adornments) do
					for _, adornment in pairs(adornmentsTable) do
						adornment.Visible = false
					end
				end
			end
			SelfHighlight.Enabled = false
			SelfHighlight.Adornee = nil
		end
		UpdateESP()
		UpdateVisuals()
	end
})

TeamCheckToggle = VisualsLeft:AddToggle('TeamCheck', {
	Text = "Team Check",
	Default = false,
	Callback = function(Value)
		TeamCheck = Value
		Arrows.TeamCheck = Value
		UpdateESP()
		UpdateVisuals()
	end
})

ShowNameDistToggle = VisualsLeft:AddToggle('ShowNameDist', {
	Text = "Show Name & Distance",
	Default = false,
	Callback = function(Value)
		ShowNameDist = Value
		UpdateESP()
	end
})

ShowHealthToggle = VisualsLeft:AddToggle('ShowHealth', {
	Text = "Show Health",
	Default = false,
	Callback = function(Value)
		ShowHealth = Value
		UpdateESP()
	end
})

ShowHealthBarToggle = VisualsLeft:AddToggle('ShowHealthBar', {
	Text = "Show HealthBar",
	Default = false,
	Callback = function(Value)
		ShowHealthBar = Value
		UpdateESP()
	end
})

ShowWeaponToggle = VisualsLeft:AddToggle('ShowWeapon', {
	Text = "Show Weapon",
	Default = false,
	Callback = function(Value)
		ShowWeapon = Value
		UpdateESP()
	end
})

ShowWeaponImageToggle = VisualsLeft:AddToggle('ShowWeaponImage', {
	Text = "Show Weapon Image",
	Default = false,
	Callback = function(Value)
		ShowWeaponImage = Value
		UpdateESP()
	end
})

ShowInventoryToggle = VisualsLeft:AddToggle('ShowInventory', {
	Text = "Show Inventory",
	Default = false,
	Callback = function(Value)
		ShowInventory = Value
		UpdateESP()
	end
})

ShowLookDirectionToggle = VisualsLeft:AddToggle('ShowLookDirection', {
	Text = "Show Look Direction",
	Default = false,
	Callback = function(Value)
		ShowLookDirection = Value
		if not Value then
			for player, line in pairs(LookLines) do
				line:Remove()
				LookLines[player] = nil
			end
		end
		UpdateLookDirection()
	end
}):AddColorPicker('LookDirectionColor', {
	Default = Color3.fromRGB(255, 203, 138),
	Title = "Look Direction Color",
	Callback = function(Value)
		LookDirectionColor = Value
		for _, line in pairs(LookLines) do
			line.Color = Value
		end
	end
})

ArrowToggle = VisualsLeft:AddToggle('ShowArrows', {
	Text = 'Show Arrows',
	Default = false,
	Callback = function(Value)
		Arrows.Enabled = Value
		gui.Enabled = Value
		for _, arrow in pairs(arrows) do
			if arrow and arrow:IsA("Frame") then
				arrow.Visible = Value
			end
		end
	end
})

ArrowToggle:AddColorPicker('ArrowColorPicker', {
	Default = Color3.new(1, 1, 1),
	Title = 'Arrow Color',
	Transparency = 0,
	Callback = function(Value)
		Arrows.Color = Value
	end
})

VisualsLeft:AddToggle('ShowNameArrow', {
	Text = 'Show Name in Arrows',
	Default = false,
	Callback = function(Value)
		Arrows.NameLabel = Value
		for _, arrow in pairs(arrows) do
			local nameLabel = arrow and arrow:IsA("Frame") and arrow:FindFirstChild("Name")
			if nameLabel then
				nameLabel.Visible = Value
			end
		end
	end
})

VisualsLeft:AddToggle('ShowDistanceArrow', {
	Text = 'Show Distance in Arrows',
	Default = false,
	Callback = function(Value)
		Arrows.DistanceLabel = Value
		for _, arrow in pairs(arrows) do
			local distanceLabel = arrow and arrow:IsA("Frame") and arrow:FindFirstChild("Distance")
			if distanceLabel then
				distanceLabel.Visible = Value
			end
		end
	end
})

ShowSkeletonToggle = VisualsLeft:AddToggle('ShowSkeleton', {
	Text = "Show Skeleton ESP",
	Default = false,
	Callback = function(Value)
		ShowSkeleton = Value
		UpdateDynamicESP()
	end
}):AddColorPicker('SkeletonColor', {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Skeleton Color",
	Callback = function(Value)
		SkeletonColor = Value
		for player, lines in pairs(SkeletonLines) do
			for _, line in pairs(lines) do
				line.Color = Value
			end
		end
	end
})

ShowHeadDotToggle = VisualsLeft:AddToggle('ShowHeadDot', {
	Text = "Show Head Dot",
	Default = false,
	Callback = function(Value)
		ShowHeadDot = Value
		UpdateDynamicESP()
	end
}):AddColorPicker('HeadDotColor', {
	Default = Color3.fromRGB(255, 0, 0),
	Title = "Head Dot Color",
	Callback = function(Value)
		HeadDotColor = Value
		for player, dot in pairs(HeadDots) do
			dot.Color = Value
		end
	end
})

ShowTracerToggle = VisualsLeft:AddToggle('ShowTracer', {
	Text = "Show Tracer",
	Default = false,
	Callback = function(Value)
		ShowTracer = Value
		UpdateDynamicESP()
	end
}):AddColorPicker('TracerColor', {
	Default = Color3.fromRGB(0, 255, 0),
	Title = "Tracer Color",
	Callback = function(Value)
		TracerColor = Value
		for player, tracer in pairs(Tracers) do
			tracer.Color = Value
		end
	end
})

ShowChinaHatToggle = VisualsLeft:AddToggle('ShowChinaHat', {
	Text = "Show China Hat",
	Default = false,
	Callback = function(Value)
		ShowChinaHat = Value
		UpdateChinaHat()
	end
}):AddColorPicker('ChinaHatColor', {
	Default = Color3.fromRGB(255, 105, 180),
	Title = "China Hat Color",
	Callback = function(Value)
		ChinaHatColor = Value
		for character, hat in pairs(ChinaHats) do
			highlight = hat:FindFirstChildOfClass("Highlight")
			if highlight then
				highlight.FillColor = Value
				highlight.OutlineColor = Value
			end
		end
	end
})

ChamsToggle = VisualsLeft:AddToggle('ChamsToggle', {
	Text = "Show Chams",
	Default = false,
	Callback = function(Value)
		ChamsToggle = Value
		for _, player in pairs(game:GetService("Players"):GetPlayers()) do
			if PlayerAdornments[player] then
				PlayerAdornments[player].NeedsUpdate = true
			end
		end
		UpdateVisuals()
	end
})

ChamsToggle:AddColorPicker('VisibleColor', {
	Default = Color3.fromRGB(255, 0, 0),
	Title = "Visible Color",
	Transparency = 0.5,
	Callback = function(Value)
		VisibleColor = Value
		for _, player in pairs(game:GetService("Players"):GetPlayers()) do
			if PlayerAdornments[player] then
				PlayerAdornments[player].NeedsUpdate = true
			end
		end
		UpdateVisuals()
	end
})

ChamsToggle:AddColorPicker('OccludedColor', {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Occluded Color",
	Transparency = 0,
	Callback = function(Value)
		OccludedColor = Value
		for _, player in pairs(game:GetService("Players"):GetPlayers()) do
			if PlayerAdornments[player] then
				PlayerAdornments[player].NeedsUpdate = true
			end
		end
		UpdateVisuals()
	end
})

HighlightsToggle = VisualsLeft:AddToggle('HighlightsToggle', {
	Text = "Show Highlights",
	Default = false,
	Callback = function(Value)
		HighlightsToggle = Value
		for _, player in pairs(PlayerAdornments) do
			player.Highlight.Enabled = false
			player.Highlight.Adornee = nil
		end
		UpdateVisuals()
	end
})

HighlightsToggle:AddColorPicker('FillColor', {
	Default = Color3.fromRGB(0, 0, 0),
	Title = "Fill Color",
	Transparency = 0,
	Callback = function(Value)
		FillColor = Value
		UpdateVisuals()
	end
})

HighlightsToggle:AddColorPicker('OutlineColor', {
	Default = Color3.fromRGB(0, 0, 0),
	Title = "Outline Color",
	Transparency = 0,
	Callback = function(Value)
		OutlineColor = Value
		UpdateVisuals()
	end
})

SelfHighlightToggle = VisualsLeft:AddToggle('SelfHighlightToggle', {
	Text = "Show Self Highlight",
	Default = false,
	Callback = function(Value)
		SelfHighlightToggle = Value
		SelfHighlight.Enabled = false
		SelfHighlight.Adornee = nil
		UpdateVisuals()
	end
})

SelfHighlightToggle:AddColorPicker('SelfFillColor', {
	Default = Color3.fromRGB(0, 255, 0),
	Title = "Self Fill Color",
	Transparency = 0,
	Callback = function(Value)
		SelfFillColor = Value
		SelfHighlight.FillColor = Value
		SelfHighlight.FillTransparency = 0
		UpdateVisuals()
	end
})

SelfHighlightToggle:AddColorPicker('SelfOutlineColor', {
	Default = Color3.fromRGB(0, 255, 0),
	Title = "Self Outline Color",
	Transparency = 0,
	Callback = function(Value)
		SelfOutlineColor = Value
		SelfHighlight.OutlineColor = Value
		SelfHighlight.OutlineTransparency = 0
		UpdateVisuals()
	end
})

ESPDistanceSlider = VisualsLeft:AddSlider('ESPDistance', {
	Text = "ESP Distance (Studs)",
	Default = 100,
	Min = 1,
	Max = 1000,
	Rounding = 0,
	Callback = function(Value)
		ESPDistance = Value
		for _, player in pairs(game:GetService("Players"):GetPlayers()) do
			if PlayerAdornments[player] then
				PlayerAdornments[player].NeedsUpdate = true
			end
		end
		UpdateESP()
		UpdateLookDirection()
		UpdateDynamicESP()
		UpdateVisuals()
	end
})

WeaponImageSizeSlider = VisualsLeft:AddSlider('WeaponImageSize', {
	Text = "Weapon Image Size",
	Default = 25,
	Min = 10,
	Max = 100,
	Rounding = 0,
	Callback = function(Value)
		WeaponImageSize = Value
		UpdateESP()
	end
})

RunService.RenderStepped:Connect(function()
	UpdateLookDirection()
	UpdateDynamicESP()
	if ESPEnabled then
		UpdateESP()
	end
	UpdateChinaHat()
	UpdateVisuals()
	screenSize = Camera.ViewportSize
	center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if Arrows.IgnoreSelf and player == LocalPlayer then
			if arrows[player] then arrows[player].Visible = false end
			continue
		end
		if Arrows.TeamCheck and player.Team == LocalPlayer.Team then
			if arrows[player] then arrows[player].Visible = false end
			continue
		end
		character = player.Character
		hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			if arrows[player] then arrows[player].Visible = false end
			continue
		end
		if not arrows[player] then
			arrows[player] = createArrow()
			if not arrows[player] then continue end
		end
		container = arrows[player]
		if not container:IsA("Frame") then continue end
		arrow = container:FindFirstChild("Arrow")
		nameLabel = container:FindFirstChild("Name")
		distanceLabel = container:FindFirstChild("Distance")

		if not arrow then continue end

		hrpPos = hrp.Position
		cameraPos = Camera.CFrame.Position
		cameraLookVector = Camera.CFrame.LookVector
		toPlayerVec = (hrpPos - cameraPos)
		toPlayerDir = toPlayerVec.Unit
		dot = cameraLookVector:Dot(toPlayerDir)

		screenPos, onScreen = Camera:WorldToViewportPoint(hrpPos)
		dir = Vector2.new(screenPos.X - center.X, screenPos.Y - center.Y)
		if dir.Magnitude == 0 then
			dir = Vector2.new(0, 1)
		end
		dirNorm = dir.Unit

		if dot >= 0 then
			arrowPos = center + dirNorm * Arrows.Radius
		else
			arrowPos = center - dirNorm * Arrows.Radius
		end

		arrowPos = Vector2.new(
			math.clamp(arrowPos.X, 0, screenSize.X),
			math.clamp(arrowPos.Y, 0, screenSize.Y)
		)

		angle = math.atan2(dirNorm.Y, dirNorm.X)
		if dot < 0 then
			arrow.Rotation = math.deg(angle) + 90 + 180
		else
			arrow.Rotation = math.deg(angle) + 90 + 180
		end

		container.Position = UDim2.new(0, arrowPos.X - container.Size.X.Offset/2, 0, arrowPos.Y - Arrows.Size.Y.Offset)

		if Arrows.UseTeamColor and player.Team then
			arrow.ImageColor3 = player.TeamColor.Color
			nameLabel.TextColor3 = player.TeamColor.Color
			distanceLabel.TextColor3 = player.TeamColor.Color
		else
			arrow.ImageColor3 = Arrows.Color
			nameLabel.TextColor3 = Color3.new(1,1,1)
			distanceLabel.TextColor3 = Color3.new(1,1,1)
		end

		nameLabel.Text = player.Name
		distanceLabel.Text = tostring(math.floor(toPlayerVec.Magnitude)) .. " studs"

		container.Visible = Arrows.Enabled
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if LookLines[player] then
		LookLines[player]:Remove()
		LookLines[player] = nil
	end
	if SkeletonLines[player] then
		for _, line in pairs(SkeletonLines[player]) do
			line:Remove()
		end
		SkeletonLines[player] = nil
	end
	if HeadDots[player] then
		HeadDots[player]:Remove()
		HeadDots[player] = nil
	end
	if Tracers[player] then
		Tracers[player]:Remove()
		Tracers[player] = nil
	end
	if PlayerAdornments[player] then
		PlayerAdornments[player].Highlight:Destroy()
		for _, adornmentsTable in pairs(PlayerAdornments[player].Adornments) do
			for _, adornment in pairs(adornmentsTable) do
				adornment:Destroy()
			end
		end
		PlayerAdornments[player] = nil
	end
	if arrows[player] then
		arrows[player]:Destroy()
		arrows[player] = nil
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		if PlayerAdornments[player] then
			PlayerAdornments[player].NeedsUpdate = true
		end
		UpdateESP()
		UpdateVisuals()
	end)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
	UpdateESP()
	UpdateVisuals()
end)

Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer

ESP_Settings = {CashDrop = false, PilesGift = false, Tools = false, ATM = false, Dealer = false, Safe = false}
MaxDistance = 50
ActiveESP = {}
TextSize = 8
CheckLimit = 10
CheckCounter = 0

CreateESP = function(obj, text)
	if not ActiveESP[obj] then
		gui = Instance.new("BillboardGui")
		gui.Name = "ESP"
		gui.Adornee = obj
		gui.Size = UDim2.new(0, 70, 0, 25)
		gui.StudsOffset = Vector3.new(0, 2, 0)
		gui.AlwaysOnTop = true

		label = Instance.new("TextLabel", gui)
		label.Size = UDim2.new(1, 0, 1, 0)
		label.Text = text
		label.TextColor3 = Color3.new(1, 1, 1)
		label.BackgroundTransparency = 1
		label.TextScaled = false
		label.TextSize = TextSize

		gui.Parent = obj
		ActiveESP[obj] = gui
	else
		ActiveESP[obj].TextLabel.Text = text
	end
end

IsInRange = function(position)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return (LocalPlayer.Character.HumanoidRootPart.Position - position).Magnitude <= MaxDistance
	end
	return false
end

ScanForESP = function()
	for obj, esp in pairs(ActiveESP) do
		part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
		shouldRemove = true

		if part and part.Parent then
			if ESP_Settings.CashDrop and obj.Name == "CashDrop1" and obj.Parent == workspace.Filter:FindFirstChild("SpawnedBread") then
				shouldRemove = not IsInRange(part.Position)
			elseif ESP_Settings.PilesGift and obj.Parent == workspace.Filter:FindFirstChild("SpawnedPiles") and (obj.Name == "P" or obj.Name == "S1" or obj.Name == "S2") then
				shouldRemove = not IsInRange(part.Position)
			elseif ESP_Settings.Tools and obj.Parent == workspace.Filter:FindFirstChild("SpawnedTools") then
				shouldRemove = not IsInRange(part.Position)
			elseif ESP_Settings.ATM and obj.Name == "ATM" and obj.Parent == workspace.Map:FindFirstChild("ATMz") then
				shouldRemove = not IsInRange(part.Position)
			elseif ESP_Settings.Dealer and obj.Parent == workspace.Map:FindFirstChild("Shopz") and (obj.Name == "Dealer" or obj.Name == "ArmoryDealer") then
				shouldRemove = not IsInRange(part.Position)
			elseif ESP_Settings.Safe and obj.Parent == workspace.Map:FindFirstChild("BredMakurz") then
				broken = obj:FindFirstChild("Values") and obj.Values:FindFirstChild("Broken")
				if (obj.Name:match("SmallSafe") or obj.Name:match("MediumSafe") or obj.Name:match("Register")) and broken and not broken.Value then
					shouldRemove = not IsInRange(part.Position)
				end
			end
		end

		if shouldRemove then
			esp:Destroy()
			ActiveESP[obj] = nil
		end
	end

	CheckCounter = 0

	if ESP_Settings.CashDrop then
		folder = workspace.Filter:FindFirstChild("SpawnedBread")
		if folder then
			for _, v in pairs(folder:GetChildren()) do
				if CheckCounter >= CheckLimit then break end
				if v:IsA("MeshPart") and v.Name == "CashDrop1" and not ActiveESP[v] then
					part = v
					if IsInRange(part.Position) then CreateESP(part, "CashDrop") end
					CheckCounter = CheckCounter + 1
				end
			end
		end
	end

	if ESP_Settings.PilesGift then
		folder = workspace.Filter:FindFirstChild("SpawnedPiles")
		if folder then
			for _, v in pairs(folder:GetChildren()) do
				if CheckCounter >= CheckLimit then break end
				if v:IsA("Model") and (v.Name == "P" or v.Name == "S1" or v.Name == "S2") and not ActiveESP[v] then
					part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
					if part and IsInRange(part.Position) then CreateESP(v, v.Name == "P" and "Gift" or "Piles") end
					CheckCounter = CheckCounter + 1
				end
			end
		end
	end

	if ESP_Settings.Tools then
		folder = workspace.Filter:FindFirstChild("SpawnedTools")
		if folder then
			for _, v in pairs(folder:GetChildren()) do
				if CheckCounter >= CheckLimit then break end
				if v:IsA("Model") and not ActiveESP[v] then
					part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
					if part and IsInRange(part.Position) then CreateESP(v, "Tool") end
					CheckCounter = CheckCounter + 1
				end
			end
		end
	end

	if ESP_Settings.ATM then
		folder = workspace.Map:FindFirstChild("ATMz")
		if folder then
			for _, v in pairs(folder:GetChildren()) do
				if CheckCounter >= CheckLimit then break end
				if v:IsA("Model") and v.Name == "ATM" and not ActiveESP[v] then
					part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
					if part and IsInRange(part.Position) then CreateESP(v, "ATM") end
					CheckCounter = CheckCounter + 1
				end
			end
		end
	end

	if ESP_Settings.Dealer then
		folder = workspace.Map:FindFirstChild("Shopz")
		if folder then
			for _, v in pairs(folder:GetChildren()) do
				if CheckCounter >= CheckLimit then break end
				if v:IsA("Model") and (v.Name == "Dealer" or v.Name == "ArmoryDealer") and not ActiveESP[v] then
					part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
					if part and IsInRange(part.Position) then CreateESP(v, v.Name == "Dealer" and "Dealer" or "Armory Dealer") end
					CheckCounter = CheckCounter + 1
				end
			end
		end
	end

	if ESP_Settings.Safe then
		folder = workspace.Map:FindFirstChild("BredMakurz")
		if folder then
			for _, v in pairs(folder:GetChildren()) do
				if CheckCounter >= CheckLimit then break end
				if not ActiveESP[v] then
					part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
					broken = v:FindFirstChild("Values") and v.Values:FindFirstChild("Broken")
					if part and (v.Name:match("SmallSafe") or v.Name:match("MediumSafe") or v.Name:match("Register")) and broken and not broken.Value and IsInRange(part.Position) then
						CreateESP(v, v.Name:match("Register") and "Register" or (v.Name:match("SmallSafe") and "Small Safe" or "Medium Safe"))
						CheckCounter = CheckCounter + 1
					end
				end
			end
		end
	end
end

spawn(function()
	while true do
		ScanForESP()
		wait(1)
	end
end)

CashDropToggle = VisualsRight:AddToggle('CashDropESP', {
	Text = "CashDrop ESP",
	Default = false,
	Callback = function(Value)
		ESP_Settings.CashDrop = Value
	end
})

PilesGiftToggle = VisualsRight:AddToggle('PilesGiftESP', {
	Text = "Piles & Gift ESP",
	Default = false,
	Callback = function(Value)
		ESP_Settings.PilesGift = Value
	end
})

ToolsToggle = VisualsRight:AddToggle('ToolsESP', {
	Text = "Tools ESP",
	Default = false,
	Callback = function(Value)
		ESP_Settings.Tools = Value
	end
})

ATMToggle = VisualsRight:AddToggle('ATMESP', {
	Text = "ATM ESP",
	Default = false,
	Callback = function(Value)
		ESP_Settings.ATM = Value
	end
})

DealerToggle = VisualsRight:AddToggle('DealerESP', {
	Text = "Dealer ESP",
	Default = false,
	Callback = function(Value)
		ESP_Settings.Dealer = Value
	end
})

SafeToggle = VisualsRight:AddToggle('SafeESP', {
	Text = "Safes and Registers ESP",
	Default = false,
	Callback = function(Value)
		ESP_Settings.Safe = Value
	end
})

ESPDistanceSliderExtra = VisualsRight:AddSlider('ESPDistanceExtra', {
	Text = "ESP Distance",
	Default = 50,
	Min = 10,
	Max = 1000,
	Rounding = 0,
	Callback = function(Value)
		MaxDistance = Value
	end
})

ESPTextSizeSlider = VisualsRight:AddSlider('ESPTextSize', {
	Text = "ESP Text Size",
	Default = 8,
	Min = 8,
	Max = 50,
	Rounding = 0,
	Callback = function(Value)
		TextSize = Value
		for _, esp in pairs(ActiveESP) do
			if esp and esp:FindFirstChild("TextLabel") then
				esp.TextLabel.TextSize = TextSize
			end
		end
	end
})

TrailDuration = 2

TrailTransparency = NumberSequence.new(0.5)

TrailColor = Color3.fromRGB(255, 0, 0)

function CreateTrail(attachment0, attachment1)
	if Trail and typeof(Trail) == "Instance" then Trail:Destroy() end
	Trail = Instance.new("Trail")
	Trail.Attachment0 = attachment0
	Trail.Attachment1 = attachment1
	Trail.Lifetime = TrailDuration
	Trail.Color = ColorSequence.new(TrailColor)
	Trail.Transparency = TrailTransparency
	Trail.WidthScale = NumberSequence.new(1.5)
	Trail.Parent = game.Workspace
end

game:GetService("RunService").Heartbeat:Connect(function()
	if TrailEnabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		rootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
		if not Attach0 then
			Attach0 = Instance.new("Attachment")
			Attach0.Parent = rootPart
			Attach1 = Instance.new("Attachment")
			Attach1.Position = Vector3.new(0, -0.5, 0)
			Attach1.Parent = rootPart
			CreateTrail(Attach0, Attach1)
		end
		Attach0.Position = Vector3.new(0, 0, 0)
		Attach1.Position = Vector3.new(0, -0.5, 0)
	end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	game.Players.LocalPlayer.Character = newCharacter
	if Trail and typeof(Trail) == "Instance" then Trail:Destroy() end
	if Attach0 then Attach0:Destroy() end
	if Attach1 then Attach1:Destroy() end
	Attach0 = nil
	Attach1 = nil
	Trail = nil
end)

Players = game:GetService('Players')
LocalPlayer = Players.LocalPlayer
Camera = workspace.CurrentCamera

HUD = {
	Enabled = false,
	Style = 'Compact',
	Color = Color3.fromRGB(255, 0, 0),
	Font = Enum.Font.Gotham,
	Target = nil,
	GUI = nil,
	Frame = nil,
	NameLabel = nil,
	HealthBar = nil,
	HealthBarFill = nil,
	HealthLabel = nil,
	DistanceLabel = nil,
	LastUpdate = 0,
	MousePos = nil,
	Ray = nil,
	RaycastParams = nil,
	RaycastResult = nil,
	HitPart = nil,
	Character = nil,
	Player = nil,
	OnScreen = false,
	CameraCFrame = nil,
	CameraPos = nil,
	CameraForward = nil,
	TargetPos = nil,
	VectorToTarget = nil,
	Distance = nil,
	Angle = nil,
	ClosestPlayer = nil,
	MinDistance = math.huge,
	ViewModel = nil,
	Tool = nil,
	Hitmarker = nil,
	HitmarkerConnection = nil,
	HitPlayer = nil,
	Sound = nil,
	CenterX = nil,
	CenterY = nil,
	Horizontal = nil,
	Vertical = nil,
	Cam = nil,
	CurrentLookVector = nil,
	LastLookVector = nil,
	RotationSpeed = nil,
	BlurConnection = nil,
	IsFirstPerson = false,
	FOVAngle = math.rad(35 / 2),
	OnScreenRoot = false,
	OnScreenHead = false,
	OnScreenTorso = false,
	OnScreenUpperTorso = false,
	OnScreenLowerTorso = false,
	RigType = nil,
	BoundingBoxPoints = {}
}

ViewmodelSettings = {Enabled = false, Color = Color3.new(1, 1, 1), ClockTime = 12}
CrosshairParts = {}
HeadshotSettings = {Enabled = false, SoundId = 5650646664, Volume = 1}
CustomFOV = Camera.FieldOfView

HitmarkerSounds = {
	Boink = 5451260445,
	TF2 = 5650646664,
	Rust = 5043539486,
	CSGO = 8679627751,
	Hitmarker = 160432334,
	Fortnite = 296102734
}

function ClearHUD()
	if HUD.GUI and HUD.GUI:IsA('ScreenGui') then
		HUD.GUI:Destroy()
	end
	HUD.GUI = nil
	HUD.Frame = nil
	HUD.NameLabel = nil
	HUD.HealthBar = nil
	HUD.HealthBarFill = nil
	HUD.HealthLabel = nil
	HUD.DistanceLabel = nil
end

function CreateCompactHUD(player)
	ClearHUD()
	if not HUD.Enabled or not player or not player.Character or not player.Character:FindFirstChild('Humanoid') then return end

	HUD.GUI = Instance.new('ScreenGui')
	HUD.GUI.Name = 'TargetHUD_' .. math.random(1000, 9999)
	HUD.GUI.IgnoreGuiInset = true
	HUD.GUI.Parent = LocalPlayer.PlayerGui
	for i = 1, 10 do
		if HUD.GUI then break end
		task.wait(0.05)
	end
	if not HUD.GUI then return end

	HUD.Frame = Instance.new('Frame', HUD.GUI)
	for i = 1, 10 do
		if HUD.Frame then break end
		task.wait(0.05)
	end
	if not HUD.Frame then return end
	HUD.Frame.Size = UDim2.new(0, 200, 0, 100)
	HUD.Frame.Position = UDim2.new(0.5, -100, 0.75, -50)
	HUD.Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	HUD.Frame.BackgroundTransparency = 0.2
	HUD.Frame.Rotation = 0
	Instance.new('UICorner', HUD.Frame).CornerRadius = UDim.new(0, 14)
	Instance.new('UIGradient', HUD.Frame).Color = ColorSequence.new(HUD.Color, Color3.fromRGB(50, 50, 50))
	Instance.new('UIGradient', HUD.Frame).Rotation = 45
	Instance.new('UIStroke', HUD.Frame).Color = HUD.Color
	Instance.new('UIStroke', HUD.Frame).Thickness = 3
	game:GetService('TweenService'):Create(Instance.new('UIStroke', HUD.Frame), TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.4}):Play()

	HUD.NameLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.NameLabel then break end
		task.wait(0.05)
	end
	if not HUD.NameLabel then return end
	HUD.NameLabel.Size = UDim2.new(0.85, 0, 0.25, 0)
	HUD.NameLabel.Position = UDim2.new(0.075, 0, 0.05, 0)
	HUD.NameLabel.Text = player.Name
	HUD.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	HUD.NameLabel.BackgroundTransparency = 1
	HUD.NameLabel.TextScaled = true
	HUD.NameLabel.TextXAlignment = Enum.TextXAlignment.Center
	HUD.NameLabel.Font = HUD.Font

	HUD.HealthBar = Instance.new('Frame', HUD.Frame)
	for i = 1, 10 do
		if HUD.HealthBar then break end
		task.wait(0.05)
	end
	if not HUD.HealthBar then return end
	HUD.HealthBar.Size = UDim2.new(0.85, 0, 0.3, 0)
	HUD.HealthBar.Position = UDim2.new(0.075, 0, 0.35, 0)
	HUD.HealthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	HUD.HealthBar.ClipsDescendants = true
	HUD.HealthBar.Rotation = 0
	Instance.new('UICorner', HUD.HealthBar).CornerRadius = UDim.new(0, 10)

	HUD.HealthBarFill = Instance.new('Frame', HUD.HealthBar)
	for i = 1, 10 do
		if HUD.HealthBarFill then break end
		task.wait(0.05)
	end
	if not HUD.HealthBarFill then return end
	HUD.HealthBarFill.Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)
	HUD.HealthBarFill.BackgroundColor3 = HUD.Color:Lerp(Color3.fromRGB(0, 255, 0), player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth)
	HUD.HealthBarFill.BorderSizePixel = 0
	HUD.HealthBarFill.Rotation = 0
	Instance.new('UICorner', HUD.HealthBarFill).CornerRadius = UDim.new(0, 10)
	game:GetService('TweenService'):Create(HUD.HealthBarFill, TweenInfo.new(0.2), {Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)}):Play()

	HUD.HealthLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.HealthLabel then break end
		task.wait(0.05)
	end
	if not HUD.HealthLabel then return end
	HUD.HealthLabel.Size = UDim2.new(0.85, 0, 0.2, 0)
	HUD.HealthLabel.Position = UDim2.new(0.075, 0, 0.7, 0)
	HUD.HealthLabel.Text = string.format('HP: %.1f', player.Character.Humanoid.Health)
	HUD.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	HUD.HealthLabel.BackgroundTransparency = 1
	HUD.HealthLabel.TextScaled = true
	HUD.HealthLabel.TextXAlignment = Enum.TextXAlignment.Center
	HUD.HealthLabel.Font = HUD.Font

	HUD.DistanceLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.DistanceLabel then break end
		task.wait(0.05)
	end
	if not HUD.DistanceLabel then return end
	HUD.DistanceLabel.Size = UDim2.new(0.85, 0, 0.15, 0)
	HUD.DistanceLabel.Position = UDim2.new(0.075, 0, 0.85, 0)
	HUD.DistanceLabel.Text = string.format('Dist: %.1f', (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0)
	HUD.DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	HUD.DistanceLabel.BackgroundTransparency = 1
	HUD.DistanceLabel.TextScaled = true
	HUD.DistanceLabel.TextXAlignment = Enum.TextXAlignment.Center
	HUD.DistanceLabel.Font = HUD.Font
end

function CreateModernHUD(player)
	ClearHUD()
	if not HUD.Enabled or not player or not player.Character or not player.Character:FindFirstChild('Humanoid') then return end

	HUD.GUI = Instance.new('ScreenGui')
	HUD.GUI.Name = 'TargetHUD_' .. math.random(1000, 9999)
	HUD.GUI.IgnoreGuiInset = true
	HUD.GUI.Parent = LocalPlayer.PlayerGui
	for i = 1, 10 do
		if HUD.GUI then break end
		task.wait(0.05)
	end
	if not HUD.GUI then return end

	HUD.Frame = Instance.new('Frame', HUD.GUI)
	for i = 1, 10 do
		if HUD.Frame then break end
		task.wait(0.05)
	end
	if not HUD.Frame then return end
	HUD.Frame.Size = UDim2.new(0, 220, 0, 110)
	HUD.Frame.Position = UDim2.new(0.5, -110, 0.75, -55)
	HUD.Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	HUD.Frame.BackgroundTransparency = 0.3
	HUD.Frame.Rotation = 0
	Instance.new('UIGradient', HUD.Frame).Color = ColorSequence.new(HUD.Color, Color3.fromRGB(50, 100, 255))
	Instance.new('UIGradient', HUD.Frame).Rotation = 135
	Instance.new('UICorner', HUD.Frame).CornerRadius = UDim.new(0, 50)
	Instance.new('UIStroke', HUD.Frame).Color = HUD.Color
	Instance.new('UIStroke', HUD.Frame).Thickness = 4
	game:GetService('TweenService'):Create(Instance.new('UIStroke', HUD.Frame), TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.3}):Play()

	HUD.NameLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.NameLabel then break end
		task.wait(0.05)
	end
	if not HUD.NameLabel then return end
	HUD.NameLabel.Size = UDim2.new(0.6, 0, 0.2, 0)
	HUD.NameLabel.Position = UDim2.new(0.2, 0, 0.05, 0)
	HUD.NameLabel.Text = player.Name
	HUD.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	HUD.NameLabel.BackgroundTransparency = 1
	HUD.NameLabel.TextScaled = true
	HUD.NameLabel.TextXAlignment = Enum.TextXAlignment.Center
	HUD.NameLabel.Font = HUD.Font

	HUD.HealthBar = Instance.new('Frame', HUD.Frame)
	for i = 1, 10 do
		if HUD.HealthBar then break end
		task.wait(0.05)
	end
	if not HUD.HealthBar then return end
	HUD.HealthBar.Size = UDim2.new(0.35, 0, 0.35, 0)
	HUD.HealthBar.Position = UDim2.new(0.325, 0, 0.3, 0)
	HUD.HealthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	HUD.HealthBar.ClipsDescendants = true
	HUD.HealthBar.Rotation = 0
	Instance.new('UICorner', HUD.HealthBar).CornerRadius = UDim.new(1, 0)

	HUD.HealthBarFill = Instance.new('Frame', HUD.HealthBar)
	for i = 1, 10 do
		if HUD.HealthBarFill then break end
		task.wait(0.05)
	end
	if not HUD.HealthBarFill then return end
	HUD.HealthBarFill.Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)
	HUD.HealthBarFill.BackgroundColor3 = HUD.Color:Lerp(Color3.fromRGB(0, 255, 0), player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth)
	HUD.HealthBarFill.BorderSizePixel = 0
	HUD.HealthBarFill.Rotation = 0
	Instance.new('UICorner', HUD.HealthBarFill).CornerRadius = UDim.new(1, 0)
	game:GetService('TweenService'):Create(HUD.HealthBarFill, TweenInfo.new(0.2), {Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)}):Play()

	HUD.HealthLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.HealthLabel then break end
		task.wait(0.05)
	end
	if not HUD.HealthLabel then return end
	HUD.HealthLabel.Size = UDim2.new(0.6, 0, 0.2, 0)
	HUD.HealthLabel.Position = UDim2.new(0.2, 0, 0.7, 0)
	HUD.HealthLabel.Text = string.format('HP: %.1f%%', (player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth) * 100)
	HUD.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	HUD.HealthLabel.BackgroundTransparency = 1
	HUD.HealthLabel.TextScaled = true
	HUD.HealthLabel.TextXAlignment = Enum.TextXAlignment.Center
	HUD.NameLabel.Font = HUD.Font

	HUD.DistanceLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.DistanceLabel then break end
		task.wait(0.05)
	end
	if not HUD.DistanceLabel then return end
	HUD.DistanceLabel.Size = UDim2.new(0.6, 0, 0.15, 0)
	HUD.DistanceLabel.Position = UDim2.new(0.2, 0, 0.85, 0)
	HUD.DistanceLabel.Text = string.format('Dist: %.1f', (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0)
	HUD.DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	HUD.DistanceLabel.BackgroundTransparency = 1
	HUD.DistanceLabel.TextScaled = true
	HUD.DistanceLabel.TextXAlignment = Enum.TextXAlignment.Center
	HUD.DistanceLabel.Font = HUD.Font
end

function CreateMinimalHUD(player)
	ClearHUD()
	if not HUD.Enabled or not player or not player.Character or not player.Character:FindFirstChild('Humanoid') then return end

	HUD.GUI = Instance.new('ScreenGui')
	HUD.GUI.Name = 'TargetHUD_' .. math.random(1000, 9999)
	HUD.GUI.IgnoreGuiInset = true
	HUD.GUI.Parent = LocalPlayer.PlayerGui
	for i = 1, 10 do
		if HUD.GUI then break end
		task.wait(0.05)
	end
	if not HUD.GUI then return end

	HUD.Frame = Instance.new('Frame', HUD.GUI)
	for i = 1, 10 do
		if HUD.Frame then break end
		task.wait(0.05)
	end
	if not HUD.Frame then return end
	HUD.Frame.Size = UDim2.new(0, 240, 0, 90)
	HUD.Frame.Position = UDim2.new(0.5, -120, 0.75, -45)
	HUD.Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	HUD.Frame.BackgroundTransparency = 0.7
	HUD.Frame.Rotation = 0
	Instance.new('UICorner', HUD.Frame).CornerRadius = UDim.new(0, 14)
	Instance.new('UIStroke', HUD.Frame).Color = HUD.Color
	Instance.new('UIStroke', HUD.Frame).Thickness = 3
	Instance.new('UIStroke', HUD.Frame).Transparency = 0.5
	game:GetService('TweenService'):Create(HUD.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.7}):Play()

	HUD.NameLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.NameLabel then break end
		task.wait(0.05)
	end
	if not HUD.NameLabel then return end
	HUD.NameLabel.Size = UDim2.new(0.5, 0, 0.25, 0)
	HUD.NameLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
	HUD.NameLabel.Text = player.Name
	HUD.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	HUD.NameLabel.BackgroundTransparency = 1
	HUD.NameLabel.TextScaled = true
	HUD.NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	HUD.NameLabel.Font = HUD.Font

	HUD.HealthBar = Instance.new('Frame', HUD.Frame)
	for i = 1, 10 do
		if HUD.HealthBar then break end
		task.wait(0.05)
	end
	if not HUD.HealthBar then return end
	HUD.HealthBar.Size = UDim2.new(0.85, 0, 0.3, 0)
	HUD.HealthBar.Position = UDim2.new(0.075, 0, 0.35, 0)
	HUD.HealthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	HUD.HealthBar.ClipsDescendants = true
	HUD.HealthBar.Rotation = 0
	Instance.new('UICorner', HUD.HealthBar).CornerRadius = UDim.new(0, 10)

	HUD.HealthBarFill = Instance.new('Frame', HUD.HealthBar)
	for i = 1, 10 do
		if HUD.HealthBarFill then break end
		task.wait(0.05)
	end
	if not HUD.HealthBarFill then return end
	HUD.HealthBarFill.Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)
	HUD.HealthBarFill.BackgroundColor3 = HUD.Color:Lerp(Color3.fromRGB(0, 255, 0), player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth)
	HUD.HealthBarFill.BorderSizePixel = 0
	HUD.HealthBarFill.Rotation = 0
	Instance.new('UICorner', HUD.HealthBarFill).CornerRadius = UDim.new(0, 10)
	game:GetService('TweenService'):Create(HUD.HealthBarFill, TweenInfo.new(0.2), {Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)}):Play()

	HUD.HealthLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.HealthLabel then break end
		task.wait(0.05)
	end
	if not HUD.HealthLabel then return end
	HUD.HealthLabel.Size = UDim2.new(0.45, 0, 0.25, 0)
	HUD.HealthLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
	HUD.HealthLabel.Text = string.format('HP: %.1f', player.Character.Humanoid.Health)
	HUD.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	HUD.HealthLabel.BackgroundTransparency = 1
	HUD.HealthLabel.TextScaled = true
	HUD.HealthLabel.TextXAlignment = Enum.TextXAlignment.Left
	HUD.HealthLabel.Font = HUD.Font

	HUD.DistanceLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.DistanceLabel then break end
		task.wait(0.05)
	end
	if not HUD.DistanceLabel then return end
	HUD.DistanceLabel.Size = UDim2.new(0.45, 0, 0.25, 0)
	HUD.DistanceLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
	HUD.DistanceLabel.Text = string.format('Dist: %.1f', (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0)
	HUD.DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	HUD.DistanceLabel.BackgroundTransparency = 1
	HUD.DistanceLabel.TextScaled = true
	HUD.DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	HUD.DistanceLabel.Font = HUD.Font
end

function CreateHolographicHUD(player)
	ClearHUD()
	if not HUD.Enabled or not player or not player.Character or not player.Character:FindFirstChild('Humanoid') then return end

	HUD.GUI = Instance.new('ScreenGui')
	HUD.GUI.Name = 'TargetHUD_' .. math.random(1000, 9999)
	HUD.GUI.IgnoreGuiInset = true
	HUD.GUI.Parent = LocalPlayer.PlayerGui
	for i = 1, 10 do
		if HUD.GUI then break end
		task.wait(0.05)
	end
	if not HUD.GUI then return end

	HUD.Frame = Instance.new('Frame', HUD.GUI)
	for i = 1, 10 do
		if HUD.Frame then break end
		task.wait(0.05)
	end
	if not HUD.Frame then return end
	HUD.Frame.Size = UDim2.new(0, 230, 0, 110)
	HUD.Frame.Position = UDim2.new(0.5, -115, 0.75, -55)
	HUD.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	HUD.Frame.BackgroundTransparency = 0.8
	HUD.Frame.Rotation = 0
	Instance.new('UIGradient', HUD.Frame).Color = ColorSequence.new(HUD.Color, Color3.fromRGB(0, 200, 255))
	Instance.new('UIGradient', HUD.Frame).Rotation = 90
	Instance.new('UICorner', HUD.Frame).CornerRadius = UDim.new(0, 14)
	Instance.new('UIStroke', HUD.Frame).Color = HUD.Color
	Instance.new('UIStroke', HUD.Frame).Thickness = 4
	Instance.new('UIStroke', HUD.Frame).Transparency = 0.3
	game:GetService('TweenService'):Create(Instance.new('UIStroke', HUD.Frame), TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.6}):Play()

	HUD.NameLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.NameLabel then break end
		task.wait(0.05)
	end
	if not HUD.NameLabel then return end
	HUD.NameLabel.Size = UDim2.new(0.85, 0, 0.25, 0)
	HUD.NameLabel.Position = UDim2.new(0.075, 0, 0.05, 0)
	HUD.NameLabel.Text = player.Name
	HUD.NameLabel.TextColor3 = Color3.fromRGB(200, 255, 255)
	HUD.NameLabel.BackgroundTransparency = 1
	HUD.NameLabel.TextScaled = true
	HUD.NameLabel.TextXAlignment = Enum.TextXAlignment.Center
	HUD.NameLabel.Font = HUD.Font

	HUD.HealthBar = Instance.new('Frame', HUD.Frame)
	for i = 1, 10 do
		if HUD.HealthBar then break end
		task.wait(0.05)
	end
	if not HUD.HealthBar then return end
	HUD.HealthBar.Size = UDim2.new(0.85, 0, 0.3, 0)
	HUD.HealthBar.Position = UDim2.new(0.075, 0, 0.35, 0)
	HUD.HealthBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	HUD.HealthBar.BackgroundTransparency = 0.8
	HUD.HealthBar.ClipsDescendants = true
	HUD.HealthBar.Rotation = 0
	Instance.new('UICorner', HUD.HealthBar).CornerRadius = UDim.new(0, 10)

	HUD.HealthBarFill = Instance.new('Frame', HUD.HealthBar)
	for i = 1, 10 do
		if HUD.HealthBarFill then break end
		task.wait(0.05)
	end
	if not HUD.HealthBarFill then return end
	HUD.HealthBarFill.Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)
	HUD.HealthBarFill.BackgroundColor3 = HUD.Color:Lerp(Color3.fromRGB(0, 255, 255), player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth)
	HUD.HealthBarFill.BorderSizePixel = 0
	HUD.HealthBarFill.Rotation = 0
	Instance.new('UICorner', HUD.HealthBarFill).CornerRadius = UDim.new(0, 10)
	game:GetService('TweenService'):Create(HUD.HealthBarFill, TweenInfo.new(0.2), {Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)}):Play()

	HUD.HealthLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.HealthLabel then break end
		task.wait(0.05)
	end
	if not HUD.HealthLabel then return end
	HUD.HealthLabel.Size = UDim2.new(0.85, 0, 0.2, 0)
	HUD.HealthLabel.Position = UDim2.new(0.075, 0, 0.7, 0)
	HUD.HealthLabel.Text = string.format('HP: %.1f%%', (player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth) * 100)
	HUD.HealthLabel.TextColor3 = Color3.fromRGB(200, 255, 255)
	HUD.HealthLabel.BackgroundTransparency = 1
	HUD.HealthLabel.TextScaled = true
	HUD.HealthLabel.TextXAlignment = Enum.TextXAlignment.Center
	HUD.HealthLabel.Font = HUD.Font

	HUD.DistanceLabel = Instance.new('TextLabel', HUD.Frame)
	for i = 1, 10 do
		if HUD.DistanceLabel then break end
		task.wait(0.05)
	end
	if not HUD.DistanceLabel then return end
	HUD.DistanceLabel.Size = UDim2.new(0.85, 0, 0.15, 0)
	HUD.DistanceLabel.Position = UDim2.new(0.075, 0, 0.85, 0)
	HUD.DistanceLabel.Text = string.format('Dist: %.1f', (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0)
	HUD.DistanceLabel.TextColor3 = Color3.fromRGB(200, 255, 255)
	HUD.DistanceLabel.BackgroundTransparency = 1
	HUD.DistanceLabel.TextScaled = true
	HUD.DistanceLabel.TextXAlignment = Enum.TextXAlignment.Center
	HUD.DistanceLabel.Font = HUD.Font
end

function UpdateHUD(player)
	if not player then
		ClearHUD()
		return
	end
	if HUD.Style == 'Compact' then
		CreateCompactHUD(player)
	elseif HUD.Style == 'Modern' then
		CreateModernHUD(player)
	elseif HUD.Style == 'Minimal' then
		CreateMinimalHUD(player)
	elseif HUD.Style == 'Holographic' then
		CreateHolographicHUD(player)
	end
end

function GetTargetPlayer()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then return nil end

	HUD.IsFirstPerson = (Camera.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 2
	HUD.MousePos = game:GetService('UserInputService'):GetMouseLocation()
	HUD.Ray = Camera:ScreenPointToRay(HUD.MousePos.X, HUD.MousePos.Y)
	HUD.RayOrigin = Camera.CFrame.Position
	HUD.RayDirection = HUD.Ray.Direction * 10000

	HUD.RaycastParams = RaycastParams.new()
	HUD.RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	HUD.RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	HUD.RaycastParams.IgnoreWater = true
	HUD.RaycastResult = workspace:Raycast(HUD.RayOrigin, HUD.RayDirection, HUD.RaycastParams)

	if HUD.RaycastResult then
		HUD.HitPart = HUD.RaycastResult.Instance
		if HUD.HitPart and (HUD.HitPart.CanCollide or HUD.HitPart.Transparency < 0.5) then
			HUD.Character = HUD.HitPart:FindFirstAncestorOfClass('Model')
			if HUD.Character and HUD.Character:FindFirstChild('Humanoid') and HUD.Character:FindFirstChild('HumanoidRootPart') and HUD.Character.Humanoid.Health > 0 then
				HUD.Player = Players:GetPlayerFromCharacter(HUD.Character)
				if HUD.Player and HUD.Player ~= LocalPlayer then
					HUD.RigType = HUD.Character.Humanoid.RigType
					HUD.OnScreenRoot, _ = Camera:WorldToViewportPoint(HUD.Character.HumanoidRootPart.Position)
					HUD.OnScreenHead = HUD.Character:FindFirstChild('Head') and select(1, Camera:WorldToViewportPoint(HUD.Character.Head.Position)) or false
					if HUD.RigType == Enum.HumanoidRigType.R15 then
						HUD.OnScreenUpperTorso = HUD.Character:FindFirstChild('UpperTorso') and select(1, Camera:WorldToViewportPoint(HUD.Character.UpperTorso.Position)) or false
						HUD.OnScreenLowerTorso = HUD.Character:FindFirstChild('LowerTorso') and select(1, Camera:WorldToViewportPoint(HUD.Character.LowerTorso.Position)) or false
						HUD.OnScreenTorso = false
					else
						HUD.OnScreenTorso = HUD.Character:FindFirstChild('Torso') and select(1, Camera:WorldToViewportPoint(HUD.Character.Torso.Position)) or false
						HUD.OnScreenUpperTorso = false
						HUD.OnScreenLowerTorso = false
					end
					HUD.BoundingBoxPoints = {
						HUD.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0),
						HUD.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0),
						HUD.Character.HumanoidRootPart.Position + Vector3.new(1, 0, 0),
						HUD.Character.HumanoidRootPart.Position + Vector3.new(-1, 0, 0)
					}
					HUD.OnScreen = false
					for _, point in ipairs(HUD.BoundingBoxPoints) do
						if select(1, Camera:WorldToViewportPoint(point)) then
							HUD.OnScreen = true
							break
						end
					end
					if HUD.OnScreen or HUD.OnScreenRoot or HUD.OnScreenHead or HUD.OnScreenTorso or HUD.OnScreenUpperTorso or HUD.OnScreenLowerTorso then
						return HUD.Player
					end
				end
			end
		end
	end

	HUD.CameraCFrame = Camera.CFrame
	HUD.CameraPos = HUD.CameraCFrame.Position
	HUD.CameraForward = HUD.CameraCFrame.LookVector
	HUD.ClosestPlayer = nil
	HUD.MinDistance = math.huge

	for _, player in pairs(Players:GetPlayers()) do
		if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild('HumanoidRootPart') or not player.Character:FindFirstChild('Humanoid') or player.Character.Humanoid.Health <= 0 then
			continue
		end

		HUD.TargetPos = player.Character.HumanoidRootPart.Position
		HUD.VectorToTarget = HUD.TargetPos - HUD.CameraPos
		HUD.Distance = HUD.VectorToTarget.Magnitude
		HUD.Angle = math.acos(HUD.VectorToTarget.Unit:Dot(HUD.CameraForward))

		if HUD.Angle <= HUD.FOVAngle then
			HUD.RigType = player.Character.Humanoid.RigType
			HUD.OnScreenRoot, _ = Camera:WorldToViewportPoint(HUD.TargetPos)
			HUD.OnScreenHead = player.Character:FindFirstChild('Head') and select(1, Camera:WorldToViewportPoint(player.Character.Head.Position)) or false
			if HUD.RigType == Enum.HumanoidRigType.R15 then
				HUD.OnScreenUpperTorso = player.Character:FindFirstChild('UpperTorso') and select(1, Camera:WorldToViewportPoint(player.Character.UpperTorso.Position)) or false
				HUD.OnScreenLowerTorso = player.Character:FindFirstChild('LowerTorso') and select(1, Camera:WorldToViewportPoint(player.Character.LowerTorso.Position)) or false
				HUD.OnScreenTorso = false
			else
				HUD.OnScreenTorso = player.Character:FindFirstChild('Torso') and select(1, Camera:WorldToViewportPoint(player.Character.Torso.Position)) or false
				HUD.OnScreenUpperTorso = false
				HUD.OnScreenLowerTorso = false
			end
			HUD.BoundingBoxPoints = {
				HUD.TargetPos + Vector3.new(0, 2, 0),
				HUD.TargetPos + Vector3.new(0, -2, 0),
				HUD.TargetPos + Vector3.new(1, 0, 0),
				HUD.TargetPos + Vector3.new(-1, 0, 0)
			}
			HUD.OnScreen = false
			for _, point in ipairs(HUD.BoundingBoxPoints) do
				if select(1, Camera:WorldToViewportPoint(point)) then
					HUD.OnScreen = true
					break
				end
			end
			if (HUD.OnScreen or HUD.OnScreenRoot or HUD.OnScreenHead or HUD.OnScreenTorso or HUD.OnScreenUpperTorso or HUD.OnScreenLowerTorso) and HUD.Distance < HUD.MinDistance then
				HUD.MinDistance = HUD.Distance
				HUD.ClosestPlayer = player
			end
		end
	end

	return HUD.ClosestPlayer
end

function UpdateViewmodel()
	if ViewmodelSettings.Enabled then
		HUD.ViewModel = Camera:FindFirstChild("ViewModel")
		if HUD.ViewModel then
			if HUD.ViewModel:FindFirstChild("Left Arm") then
				HUD.ViewModel["Left Arm"].Material = Enum.Material.ForceField
				HUD.ViewModel["Left Arm"].Color = ViewmodelSettings.Color
			end
			if HUD.ViewModel:FindFirstChild("Right Arm") then
				HUD.ViewModel["Right Arm"].Material = Enum.Material.ForceField
				HUD.ViewModel["Right Arm"].Color = ViewmodelSettings.Color
			end
		end
	else
		HUD.ViewModel = Camera:FindFirstChild("ViewModel")
		if HUD.ViewModel then
			if HUD.ViewModel:FindFirstChild("Left Arm") then
				HUD.ViewModel["Left Arm"].Material = Enum.Material.Plastic
			end
			if HUD.ViewModel:FindFirstChild("Right Arm") then
				HUD.ViewModel["Right Arm"].Material = Enum.Material.Plastic
			end
		end
	end
	game:GetService("Lighting").ClockTime = ViewmodelSettings.ClockTime
end

function EnableCrosshair()
	if next(CrosshairParts) == nil then
		HUD.CenterX = Camera.ViewportSize.X / 2
		HUD.CenterY = Camera.ViewportSize.Y / 2
		HUD.Horizontal = Drawing.new("Line")
		HUD.Horizontal.Visible = true
		HUD.Horizontal.Color = Options.CrosshairColor.Value
		HUD.Horizontal.Thickness = 2
		HUD.Horizontal.Transparency = 1
		HUD.Horizontal.From = Vector2.new(HUD.CenterX - 10, HUD.CenterY)
		HUD.Horizontal.To = Vector2.new(HUD.CenterX + 10, HUD.CenterY)
		CrosshairParts.Horizontal = HUD.Horizontal
		HUD.Vertical = Drawing.new("Line")
		HUD.Vertical.Visible = true
		HUD.Vertical.Color = Options.CrosshairColor.Value
		HUD.Vertical.Thickness = 2
		HUD.Vertical.Transparency = 1
		HUD.Vertical.From = Vector2.new(HUD.CenterX, HUD.CenterY - 10)
		HUD.Vertical.To = Vector2.new(HUD.CenterX, HUD.CenterY + 10)
		CrosshairParts.Vertical = HUD.Vertical
	end
end

function DisableCrosshair()
	for _, line in pairs(CrosshairParts) do
		line:Remove()
	end
	CrosshairParts = {}
end

function UpdateCrosshairColor(color)
	for _, line in pairs(CrosshairParts) do
		line.Color = color
	end
end

function PlayHeadshotSound()
	if HeadshotSettings.Enabled then
		HUD.Sound = Instance.new("Sound")
		HUD.Sound.SoundId = "rbxassetid://" .. HeadshotSettings.SoundId
		HUD.Sound.Volume = HeadshotSettings.Volume
		HUD.Sound.Parent = workspace
		HUD.Sound:Play()
		game:GetService("Debris"):AddItem(HUD.Sound, 2)
	end
end

function SetupHitmarkerForTool(tool)
	if HUD.HitmarkerConnection then
		HUD.HitmarkerConnection:Disconnect()
		HUD.HitmarkerConnection = nil
	end
	HUD.Hitmarker = tool:FindFirstChild("Hitmarker")
	if HUD.Hitmarker then
		HUD.HitmarkerConnection = HUD.Hitmarker.Event:Connect(function(hitPart)
			if hitPart and hitPart.Parent and hitPart.Parent:FindFirstChild("Humanoid") then
				HUD.HitPlayer = Players:GetPlayerFromCharacter(hitPart.Parent)
				if HUD.HitPlayer and HUD.HitPlayer ~= LocalPlayer and hitPart.Name == "Head" then
					PlayHeadshotSound()
				end
			end
		end)
	end
end

LocalPlayer.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid")
	HUD.Tool = character:FindFirstChildOfClass("Tool")
	if HUD.Tool then
		SetupHitmarkerForTool(HUD.Tool)
	end
	UpdateViewmodel()
end)

LocalPlayer.Character.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		SetupHitmarkerForTool(child)
	end
end)

LocalPlayer.Character.ChildRemoved:Connect(function(child)
	if child:IsA("Tool") and HUD.HitmarkerConnection then
		HUD.HitmarkerConnection:Disconnect()
		HUD.HitmarkerConnection = nil
	end
end)

game:GetService('RunService').RenderStepped:Connect(function()
	HUD.Player = LocalPlayer
	if HUD.Player.Character and HUD.Player.Character:FindFirstChild("Humanoid") and HUD.Player.Character.Humanoid.Health > 0 then
		UpdateViewmodel()
		Camera.FieldOfView = CustomFOV
	end
end)

local connection
function StartUpdateLoop()
	if connection then connection:Disconnect() end
	connection = game:GetService('RunService').Heartbeat:Connect(function()
		if not HUD.Enabled then
			ClearHUD()
			return
		end
		if tick() - HUD.LastUpdate < 0.2 then return end
		HUD.LastUpdate = tick()

		HUD.NewTarget = GetTargetPlayer()
		if HUD.NewTarget then
			HUD.Target = HUD.NewTarget
			UpdateHUD(HUD.Target)
		else
			HUD.Target = nil
			UpdateHUD(nil)
		end
	end)
end

VisualsLeft2:AddButton({
	Text = "FullBright",
	Func = function()
		game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
		game:GetService("Lighting").ColorShift_Bottom = Color3.new(1, 1, 1)
		game:GetService("Lighting").ColorShift_Top = Color3.new(1, 1, 1)
		if game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere") then
			game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere"):Destroy()
		end
		game:GetService("Lighting").LightingChanged:Connect(function()
			game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
			game:GetService("Lighting").ColorShift_Bottom = Color3.new(1, 1, 1)
			game:GetService("Lighting").ColorShift_Top = Color3.new(1, 1, 1)
		end)
		LocalPlayer.CharacterAdded:Connect(function(character)
			character:WaitForChild("HumanoidRootPart")
			game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
			game:GetService("Lighting").ColorShift_Bottom = Color3.new(1, 1, 1)
			game:GetService("Lighting").ColorShift_Top = Color3.new(1, 1, 1)
			if game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere") then
				game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere"):Destroy()
			end
		end)
		game:GetService("Lighting").ChildAdded:Connect(function(child)
			if child:IsA("Atmosphere") then
				task.wait(0.1)
				child:Destroy()
			end
		end)
	end
})

VisualsLeft2:AddButton({
	Text = "Noclip Camera",
	Func = function()
		LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
	end
})

HUDToggle = VisualsLeft2:AddToggle('HUDToggle', {
	Text = 'Target HUD',
	Default = false,
	Callback = function(Value)
		HUD.Enabled = Value
		if Value then
			StartUpdateLoop()
		else
			ClearHUD()
			if connection then connection:Disconnect() end
		end
	end
})

HUDToggle:AddColorPicker('HUDColorPicker', {
	Default = Color3.fromRGB(255, 0, 0),
	Title = 'HUD Color',
	Transparency = 0,
	Callback = function(Value)
		HUD.Color = Value
		if HUD.Target then
			UpdateHUD(HUD.Target)
		end
	end
})

freecamEnabled = false
freecamSpeed = 50
cam = workspace.CurrentCamera
UIS = game:GetService("UserInputService")
RS = game:GetService("RunService")
onMobile = not UIS.KeyboardEnabled
keysDown = {}
rotating = false

freecamToggle = VisualsLeft2:AddToggle("FreecamToggle", {
	Text = "Freecam",
	Default = false,
	Callback = function(value)
		freecamEnabled = value
		if value then
			cam.CameraType = Enum.CameraType.Scriptable
			if game.Players.LocalPlayer.Character then
				game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
			end
		else
			RS:UnbindFromRenderStep("Freecam")
			cam.CameraType = Enum.CameraType.Custom
			if game.Players.LocalPlayer.Character then
				game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
			end
		end
	end,
}):AddKeyPicker("FreecamKey", {
	Default = "None", 
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Freecam",
	Callback = function() end,
})

blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 0

VisualsLeft2:AddToggle('BlurToggle', {
	Text = 'Blur',
	Default = false,
	Callback = function(value)
		if value then
			HUD.BlurConnection = game:GetService('RunService').RenderStepped:Connect(function()
				HUD.Cam = Camera
				HUD.CurrentLookVector = HUD.Cam.CFrame.LookVector
				HUD.RotationSpeed = (HUD.CurrentLookVector - (HUD.LastLookVector or HUD.CurrentLookVector)).Magnitude * 130
				blur.Size = math.clamp(HUD.RotationSpeed, 0, 20)
				HUD.LastLookVector = HUD.CurrentLookVector
			end)
		else
			if HUD.BlurConnection then
				HUD.BlurConnection:Disconnect()
				HUD.BlurConnection = nil
			end
			blur.Size = 0
		end
	end
})

Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
Humanoid = Character:WaitForChild("Humanoid")
IsEnabled = false
SelectedEffect = "Explosion"
JumpConnection = nil

function createExplosion(position)
	local explosion = Instance.new("Explosion")
	explosion.Position = position
	explosion.BlastRadius = 10
	explosion.BlastPressure = 50
	explosion.DestroyJointRadiusPercent = 0
	explosion.Parent = game.Workspace
end

function createParticleEffect(position)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://243728913"
	particleEmitter.Size = NumberSequence.new(1, 0)
	particleEmitter.Transparency = NumberSequence.new(0, 1)
	particleEmitter.Lifetime = NumberRange.new(0.5, 1)
	particleEmitter.Rate = 100
	particleEmitter.Speed = NumberRange.new(10)
	local part = Instance.new("Part")
	particleEmitter.Parent = part
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Parent = game.Workspace
	wait(1)
	if part.Parent then
		part:Destroy()
	end
end

function createShockwave(position)
	local part = Instance.new("Part")
	part.Position = position
	part.Size = Vector3.new(0.5, 0.5, 0.5)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.4
	part.BrickColor = BrickColor.new("Cyan")
	part.Material = Enum.Material.Neon
	part.Parent = game.Workspace
	for i = 1, 30 do
		part.Size = part.Size + Vector3.new(0.5, 0.1, 0.5)
		part.Transparency = part.Transparency + 0.02
		wait(0.02)
	end
	if part.Parent then
		part:Destroy()
	end
end

function createFireBurst(position)
	local fire = Instance.new("Fire")
	fire.Size = 8
	fire.Heat = 15
	local part = Instance.new("Part")
	fire.Parent = part
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Parent = game.Workspace
	wait(0.6)
	for i = 1, 5 do
		fire.Size = fire.Size - 1.6
		fire.Heat = fire.Heat - 3
		wait(0.02)
	end
	if part.Parent then
		part:Destroy()
	end
end

function createMeteorTrail(position)
	local part = Instance.new("Part")
	part.Position = position + Vector3.new(0, 5, 0)
	part.Size = Vector3.new(1, 1, 1)
	part.Anchored = false
	part.CanCollide = false
	part.BrickColor = BrickColor.new("Really red")
	part.Material = Enum.Material.Neon
	part.Parent = game.Workspace
	local fire = Instance.new("Fire")
	fire.Size = 5
	fire.Parent = part
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
	bv.Velocity = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
	bv.Parent = part
	wait(0.8)
	if part.Parent then
		part:Destroy()
	end
end

function createGravityPulse(position)
	local part = Instance.new("Part")
	part.Position = position
	part.Size = Vector3.new(4, 4, 4)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.5
	part.BrickColor = BrickColor.new("Deep blue")
	part.Material = Enum.Material.Neon
	part.Parent = game.Workspace
	for i = 1, 15 do
		part.Size = part.Size - Vector3.new(0.2, 0.2, 0.2)
		part.Transparency = part.Transparency + 0.03
		wait(0.03)
	end
	if part.Parent then
		part:Destroy()
	end
end

function onJump()
	if not IsEnabled then return end
	rootPart = Character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		position = rootPart.Position - Vector3.new(0, 3, 0)
		if SelectedEffect == "Explosion" then
			createExplosion(position)
			createParticleEffect(position)
		elseif SelectedEffect == "Shockwave" then
			createShockwave(position)
		elseif SelectedEffect == "FireBurst" then
			createFireBurst(position)
		elseif SelectedEffect == "MeteorTrail" then
			createMeteorTrail(position)
		elseif SelectedEffect == "GravityPulse" then
			createGravityPulse(position)
		end
	end
end

function setupJumpConnection()
	if JumpConnection then
		JumpConnection:Disconnect()
	end
	JumpConnection = Humanoid.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.Jumping then
			onJump()
		end
	end)
end

setupJumpConnection()

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
	Humanoid = Character:WaitForChild("Humanoid")
	setupJumpConnection()
end)

VisualsLeft2:AddToggle('JumpEffectToggle', {
	Text = 'JumpCircle',
	Default = false,
	Callback = function(Value)
		IsEnabled = Value
	end
})

player = game.Players.LocalPlayer
TESPcolor = Color3.fromRGB(255, 255, 255)
rotation = 0
outerRadius = 70
outerSize = 24
innerRadius = 30
cubeSize = 30
outerArrows = {}
for i = 1, 3 do
	outerArrows[i] = {}
	for j = 1, 3 do
		line = Drawing.new("Line")
		line.Color = TESPcolor
		line.Thickness = j == 1 and 2 or (j == 2 and 4 or 6)
		line.Transparency = j == 1 and 1 or (j == 2 and 0.3 or 0.1)
		line.Visible = false
		outerArrows[i][j] = line
	end
end

centerTriangle = {}
for i = 1, 3 do
	line = Drawing.new("Line")
	line.Color = TESPcolor
	line.Thickness = 2
	line.Transparency = 0.9
	line.Visible = false
	centerTriangle[i] = line
end

cubeLines = {}
for i = 1, 8 do
	line = Drawing.new("Line")
	line.Color = TESPcolor
	line.Thickness = 2
	line.Transparency = 1
	line.Visible = false
	cubeLines[i] = line
end

VisualsLeft2:AddToggle('TESPEnabled', {
	Text = 'Target ESP',
	Default = false,
	Callback = function(Value)
		isEnabled = Value
	end
}):AddColorPicker('TESPESPColor', {
	Default = Color3.fromRGB(255, 255, 255),
	Title = 'ESP Color',
	Callback = function(Value)
		TESPcolor = Value
		for _, group in ipairs(outerArrows) do
			for _, line in ipairs(group) do
				line.Color = TESPcolor
			end
		end
		for _, line in ipairs(centerTriangle) do
			line.Color = TESPcolor
		end
		for _, line in ipairs(cubeLines) do
			line.Color = TESPcolor
		end
	end
})

game:GetService("RunService").RenderStepped:Connect(function(dt)
	if not isEnabled then
		for _, group in ipairs(outerArrows) do
			for _, line in ipairs(group) do line.Visible = false end
		end
		for _, line in ipairs(centerTriangle) do line.Visible = false end
		for _, line in ipairs(cubeLines) do line.Visible = false end
		return
	end
	if player:GetMouse().Target then
		targetChar = player:GetMouse().Target:FindFirstAncestorOfClass("Model")
		if targetChar and game.Players:GetPlayerFromCharacter(targetChar) and targetChar:FindFirstChild("HumanoidRootPart") then
			screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetChar.HumanoidRootPart.Position)
			if onScreen then
				center = Vector2.new(screenPos.X, screenPos.Y)
				rotation = (rotation + 25 * dt) % 360
				if mode == "Spinning" then
					for i, base in ipairs({0, 120, 240}) do
						angle = base + rotation
						fromPoint = center + Vector2.new(math.cos(math.rad(angle)), math.sin(math.rad(angle))) * outerRadius
						toPoint = center + Vector2.new(math.cos(math.rad(angle)), math.sin(math.rad(angle))) * (outerRadius + outerSize)
						for _, line in ipairs(outerArrows[i]) do
							line.From = fromPoint
							line.To = toPoint
							line.Visible = true
						end
					end
				else
					for _, group in ipairs(outerArrows) do
						for _, line in ipairs(group) do line.Visible = false end
					end
				end
				if mode == "Triangle" then
					points = {}
					for i = 1, 3 do
						table.insert(points, center + Vector2.new(math.cos(math.rad(120 * (i - 1) + rotation)), math.sin(math.rad(120 * (i - 1) + rotation))) * innerRadius)
					end
					for i = 1, 3 do
						centerTriangle[i].From = points[i]
						centerTriangle[i].To = points[(i % 3) + 1]
						centerTriangle[i].Visible = true
					end
				else
					for _, line in ipairs(centerTriangle) do line.Visible = false end
				end
				if mode == "Cube" then
					t = tick()
					cos = math.cos(t)
					sin = math.sin(t)
					topLeft = Vector2.new(-cubeSize * cos + cubeSize * sin, -cubeSize * sin - cubeSize * cos)
					topRight = Vector2.new(cubeSize * cos + cubeSize * sin, cubeSize * sin - cubeSize * cos)
					bottomLeft = Vector2.new(-cubeSize * cos - cubeSize * sin, -cubeSize * sin + cubeSize * cos)
					bottomRight = Vector2.new(cubeSize * cos - cubeSize * sin, cubeSize * sin + cubeSize * cos)
					cubeLines[1].From = center + topLeft
					cubeLines[1].To = center + topLeft + Vector2.new(12 * cos, 12 * sin)
					cubeLines[2].From = center + topLeft
					cubeLines[2].To = center + topLeft + Vector2.new(-12 * sin, 12 * cos)
					cubeLines[3].From = center + topRight
					cubeLines[3].To = center + topRight + Vector2.new(-12 * cos, -12 * sin)
					cubeLines[4].From = center + topRight
					cubeLines[4].To = center + topRight + Vector2.new(12 * sin, 12 * cos)
					cubeLines[5].From = center + bottomLeft
					cubeLines[5].To = center + bottomLeft + Vector2.new(12 * cos, 12 * sin)
					cubeLines[6].From = center + bottomLeft
					cubeLines[6].To = center + bottomLeft + Vector2.new(12 * sin, -12 * cos)
					cubeLines[7].From = center + bottomRight
					cubeLines[7].To = center + bottomRight + Vector2.new(-12 * cos, -12 * sin)
					cubeLines[8].From = center + bottomRight
					cubeLines[8].To = center + bottomRight + Vector2.new(-12 * sin, -12 * cos)
					for i = 1, 8 do cubeLines[i].Visible = true end
				else
					for i = 1, 8 do cubeLines[i].Visible = false end
				end
				return
			end
		end
	end
	for _, group in ipairs(outerArrows) do
		for _, line in ipairs(group) do line.Visible = false end
	end
	for _, line in ipairs(centerTriangle) do line.Visible = false end
	for _, line in ipairs(cubeLines) do line.Visible = false end
end)

VisualsLeft2:AddToggle('ViewmodelEnabled', {
	Text = "ForceField Viewmodel",
	Default = false,
	Callback = function(Value)
		ViewmodelSettings.Enabled = Value
		UpdateViewmodel()
	end
})

Trail = VisualsLeft2:AddToggle('TrailToggle', {
	Text = 'Trail',
	Default = false,
	Callback = function(Value)
		TrailEnabled = Value
		if not Value then
			if Trail and typeof(Trail) == "Instance" then Trail:Destroy() end
			if Attach0 then Attach0:Destroy() end
			if Attach1 then Attach1:Destroy() end
			Attach0 = nil
			Attach1 = nil
			Trail = nil
		end
	end
})

Trail:AddColorPicker('TrailColorPicker', {
	Default = Color3.fromRGB(255, 0, 0),
	Callback = function(Value)
		TrailColor = Value
		if Trail and typeof(Trail) == "Instance" then
			Trail.Color = ColorSequence.new(Value)
		end
	end
})

CrosshairToggle = VisualsLeft2:AddToggle('CrosshairEnabled', {
	Text = 'Custom Crosshair',
	Default = false,
	Tooltip = 'Shows custom crosshair',
	Callback = function(Value)
		if Value then EnableCrosshair() else DisableCrosshair() end
	end
})

CrosshairToggle:AddColorPicker('CrosshairColor', {
	Default = Color3.fromRGB(0, 255, 0),
	Title = 'Crosshair Color',
	Transparency = 0,
	Callback = UpdateCrosshairColor
})

VisualsLeft2:AddToggle('HeadshotEnabled', {
	Text = 'Headshot Sound',
	Default = false,
	Tooltip = 'Plays sound on headshot',
	Callback = function(Value)
		HeadshotSettings.Enabled = Value
	end
})

VisualsLeft2:AddDropdown('HeadshotType', {
	Values = {"Boink", "TF2", "Rust", "CSGO", "Hitmarker", "Fortnite"},
	Default = "TF2",
	Multi = false,
	Text = 'Headshot Type',
	Tooltip = 'Select headshot sound type',
	Callback = function(Value)
		HeadshotSettings.SoundId = HitmarkerSounds[Value]
	end
})

VisualsLeft2:AddDropdown('HUDStyleDropdown', {
	Values = {'Compact', 'Modern', 'Minimal', 'Holographic'},
	Default = 1,
	Multi = false,
	Text = 'HUD Style',
	Callback = function(Value)
		HUD.Style = Value
		if HUD.Target then
			UpdateHUD(HUD.Target)
		end
	end
})

VisualsLeft2:AddDropdown('HUDFontDropdown', {
	Values = {'Arial', 'Bangers', 'Gotham'},
	Default = 3,
	Multi = false,
	Text = 'HUD Font',
	Callback = function(Value)
		HUD.Font = Enum.Font[Value]
		if HUD.Target then
			UpdateHUD(HUD.Target)
		end
	end
})

VisualsLeft2:AddDropdown('TESPmode', {
	Values = {'Cube', 'Triangle', 'Spinning'},
	Default = 1,
	Multi = false,
	Text = 'ESP Mode',
	Callback = function(Value)
		mode = Value
	end
})

VisualsLeft2:AddDropdown('EffectDropdown', {
	Values = { 'Explosion', 'Shockwave', 'FireBurst', 'MeteorTrail', 'GravityPulse' },
	Default = 1,
	Multi = false,
	Text = 'Select Effect JumpCircle',
	Callback = function(Value)
		SelectedEffect = Value
	end
})

VisualsLeft2:AddSlider('HeadshotVolume', {
	Text = 'Headshot Volume',
	Default = HeadshotSettings.Volume,
	Min = 0,
	Max = 10,
	Rounding = 1,
	Callback = function(Value)
		HeadshotSettings.Volume = Value
	end
})

VisualsLeft2:AddSlider("SpeedSlider", {
	Text = "Freecam Speed",
	Default = 50,
	Min = 50,
	Max = 500,
	Rounding = 1,
	Callback = function(value)
		freecamSpeed = value
	end
})

RS.RenderStepped:Connect(function()
	if not freecamEnabled or not game.Players.LocalPlayer.Character or not game.Players.LocalPlayer.Character.Humanoid or game.Players.LocalPlayer.Character.Humanoid.Health <= 0 then 
		if freecamEnabled then
			freecamEnabled = false
			freecamToggle:SetValue(false)
			cam.CameraType = Enum.CameraType.Custom
			if game.Players.LocalPlayer.Character then
				game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
			end
		end
		return 
	end
	if rotating then
		delta = UIS:GetMouseDelta()
		cf = cam.CFrame
		yAngle = cf:ToEulerAngles(Enum.RotationOrder.YZX)
		newAmount = math.deg(yAngle)+delta.Y
		if newAmount > 65 or newAmount < -65 then
			if not (yAngle<0 and delta.Y<0) and not (yAngle>0 and delta.Y>0) then
				delta = Vector2.new(delta.X,0)
			end 
		end
		cf *= CFrame.Angles(-math.rad(delta.Y),0,0)
		cf = CFrame.Angles(0,-math.rad(delta.X),0) * (cf - cf.Position) + cf.Position
		cf = CFrame.lookAt(cf.Position, cf.Position + cf.LookVector)
		if delta ~= Vector2.new(0,0) then cam.CFrame = cam.CFrame:Lerp(cf,freecamSpeed/1000) end
		UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	else
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end
	if keysDown["Enum.KeyCode.W"] then
		cam.CFrame *= CFrame.new(Vector3.new(0,0,-freecamSpeed/100))
	end
	if keysDown["Enum.KeyCode.A"] then
		cam.CFrame *= CFrame.new(Vector3.new(-freecamSpeed/100,0,0))
	end
	if keysDown["Enum.KeyCode.S"] then
		cam.CFrame *= CFrame.new(Vector3.new(0,0,freecamSpeed/100))
	end
	if keysDown["Enum.KeyCode.D"] then
		cam.CFrame *= CFrame.new(Vector3.new(freecamSpeed/100,0,0))
	end
end)

validKeys = {"Enum.KeyCode.W","Enum.KeyCode.A","Enum.KeyCode.S","Enum.KeyCode.D"}

UIS.InputBegan:Connect(function(Input)
	for i, key in pairs(validKeys) do
		if key == tostring(Input.KeyCode) then
			keysDown[key] = true
		end
	end
	if Input.UserInputType == Enum.UserInputType.MouseButton2 or (Input.UserInputType == Enum.UserInputType.Touch and UIS:GetMouseLocation().X>(cam.ViewportSize.X/2)) then
		rotating = true
	end
	if Input.UserInputType == Enum.UserInputType.Touch then
		if Input.Position.X < cam.ViewportSize.X/2 then
			touchPos = Input.Position
		end
	end
end)

UIS.InputEnded:Connect(function(Input)
	for key, v in pairs(keysDown) do
		if key == tostring(Input.KeyCode) then
			keysDown[key] = false
		end
	end
	if Input.UserInputType == Enum.UserInputType.MouseButton2 or (Input.UserInputType == Enum.UserInputType.Touch and UIS:GetMouseLocation().X>(cam.ViewportSize.X/2)) then
		rotating = false
	end
	if Input.UserInputType == Enum.UserInputType.Touch and touchPos then
		if Input.Position.X < cam.ViewportSize.X/2 then
			touchPos = nil
			keysDown["Enum.KeyCode.W"] = false
			keysDown["Enum.KeyCode.A"] = false
			keysDown["Enum.KeyCode.S"] = false
			keysDown["Enum.KeyCode.D"] = false
		end
	end
end)

UIS.TouchMoved:Connect(function(input)
	if touchPos then
		if input.Position.X < cam.ViewportSize.X/2 then
			if input.Position.Y < touchPos.Y then
				keysDown["Enum.KeyCode.W"] = true
				keysDown["Enum.KeyCode.S"] = false
			else
				keysDown["Enum.KeyCode.W"] = false
				keysDown["Enum.KeyCode.S"] = true
			end
			if input.Position.X < (touchPos.X-15) then
				keysDown["Enum.KeyCode.A"] = true
				keysDown["Enum.KeyCode.D"] = false
			elseif input.Position.X > (touchPos.X+15) then
				keysDown["Enum.KeyCode.A"] = false
				keysDown["Enum.KeyCode.D"] = true
			else
				keysDown["Enum.KeyCode.A"] = false
				keysDown["Enum.KeyCode.D"] = false
			end
		end
	end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
	if freecamEnabled and game.Players.LocalPlayer.Character then
		game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
	end
end)

VisualsLeft2:AddSlider('CameraDistanceSlider', {
	Text = "Camera Distance",
	Default = LocalPlayer.CameraMaxZoomDistance,
	Min = 100,
	Max = 1000,
	Rounding = 0,
	Callback = function(Value)
		LocalPlayer.CameraMaxZoomDistance = Value
	end
})

VisualsLeft2:AddSlider('GameTime', {
	Text = "ClockTime",
	Default = 12,
	Min = 0,
	Max = 24,
	Rounding = 1,
	Callback = function(Value)
		ViewmodelSettings.ClockTime = Value
		UpdateViewmodel()
	end
})

VisualsLeft2:AddSlider('FOVSlider', {
	Text = "Field of View",
	Default = Camera.FieldOfView,
	Min = 30,
	Max = 120,
	Rounding = 0,
	Callback = function(Value)
		CustomFOV = Value
		Camera.FieldOfView = Value
	end
})

player = game.Players.LocalPlayer

VisualsLeft2:AddSlider('RightArmLength', {
	Text = 'Right Arm Length',
	Default = 2,
	Min = 0,
	Max = 10,
	Rounding = 1,
	Callback = function(Value)
		local viewModel = workspace.Camera:FindFirstChild("ViewModel")
		if viewModel and viewModel:FindFirstChild("Right Arm") then
			viewModel["Right Arm"].Size = Vector3.new(1, Value, 1)
		end
	end
})

VisualsLeft2:AddSlider('LeftArmLength', {
	Text = 'Left Arm Length',
	Default = 2,
	Min = 0,
	Max = 10,
	Rounding = 1,
	Callback = function(Value)
		local viewModel = workspace.Camera:FindFirstChild("ViewModel")
		if viewModel and viewModel:FindFirstChild("Left Arm") then
			viewModel["Left Arm"].Size = Vector3.new(1, Value, 1)
		end
	end
})

player.CharacterAdded:Connect(function(char)
	local viewModel = workspace.Camera:WaitForChild("ViewModel", 5)
	if viewModel then
		if viewModel:FindFirstChild("Right Arm") then
			viewModel["Right Arm"].Size = Vector3.new(1, Options.RightArmLength.Value, 1)
		else
			viewModel:WaitForChild("Right Arm", 5)
			if viewModel:FindFirstChild("Right Arm") then
				viewModel["Right Arm"].Size = Vector3.new(1, Options.RightArmLength.Value, 1)
			end
		end
		if viewModel:FindFirstChild("Left Arm") then
			viewModel["Left Arm"].Size = Vector3.new(1, Options.LeftArmLength.Value, 1)
		else
			viewModel:WaitForChild("Left Arm", 5)
			if viewModel:FindFirstChild("Left Arm") then
				viewModel["Left Arm"].Size = Vector3.new(1, Options.LeftArmLength.Value, 1)
			end
		end
	end
end)

MovementLeft = Tabs.Movement:AddLeftGroupbox('Speed and JumpPower')
MovementRight = Tabs.Movement:AddRightGroupbox('Fly')
MovementLeft2 = Tabs.Movement:AddLeftGroupbox('Noclips')
MovementRight2 = Tabs.Movement:AddRightGroupbox('Other')

Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
Camera = workspace.CurrentCamera
ReplicatedStorage = game:GetService("ReplicatedStorage")

player = Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
humanoidRootPart = character:WaitForChild("HumanoidRootPart")

flyEnabled = false
flySpeed = 40
fly2Enabled = false
fly2Speed = 60
moveDirection = Vector3.zero
remotes = {}

function getEvent()
	local evt = ReplicatedStorage:FindFirstChild("Events")
	if evt then 
		local event = evt:FindFirstChild("__RZDONL")
		if event and event:IsA("RemoteEvent") then
			return event
		end
	end
	return nil
end

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid")
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
	if flyEnabled then 
		humanoidRootPart.Anchored = true 
	else 
		humanoidRootPart.Anchored = false 
	end
end)

MovementLeft:AddToggle('IncreaseSpeed', {
	Text = 'Speedhack',
	Default = false,
	Callback = function(Value)
		if Value then
			if not _G.SpeedConnection then
				_G.SpeedConnection = game:GetService("RunService").Heartbeat:Connect(function()
					p = game.Players.LocalPlayer
					c = p.Character
					if c and c:FindFirstChild("Humanoid") and c:FindFirstChild("HumanoidRootPart") then
						h = c.Humanoid
						r = c.HumanoidRootPart
						d = h.MoveDirection
						if h:GetState() ~= Enum.HumanoidStateType.Climbing then
							r.CFrame = r.CFrame + Vector3.new(d.X * Options.SpeedValue.Value, 0, d.Z * Options.SpeedValue.Value)
						end
					end
				end)
			end
		else
			if _G.SpeedConnection then
				_G.SpeedConnection:Disconnect()
				_G.SpeedConnection = nil
			end
		end
	end
}):AddKeyPicker('SpeedKey', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'Speedhack',
	Callback = function() end
})

MovementLeft:AddSlider('SpeedValue', {
	Text = 'Speed',
	Default = 0.16,
	Min = 0,
	Max = 2,
	Rounding = 2,
	Callback = function(Value) end
})

MovementLeft:AddToggle('JumpPowerToggle', {
	Text = 'JumpPower',
	Default = false,
	Callback = function(Value)
		if Value then
			if not _G.JumpHeightConnection then
				_G.JumpHeightConnection = game:GetService("RunService").RenderStepped:Connect(function()
					if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
						game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = false
						game.Players.LocalPlayer.Character.Humanoid.JumpHeight = Options.JumpPowerSlider.Value
					end
				end)
			end
		else
			if _G.JumpHeightConnection then
				_G.JumpHeightConnection:Disconnect()
				_G.JumpHeightConnection = nil
			end
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = false
				game.Players.LocalPlayer.Character.Humanoid.JumpHeight = 7.1
			end
		end
	end
}):AddKeyPicker('JumpPowerKey', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'JumpPower',
	Callback = function() end
})

MovementLeft:AddSlider('JumpPowerSlider', {
	Text = 'Jump Height',
	Default = 5,
	Min = 5,
	Max = 30,
	Rounding = 1,
	Compact = false,
	Callback = function(Value)
		if Toggles.JumpPowerToggle.Value then
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = false
				game.Players.LocalPlayer.Character.Humanoid.JumpHeight = Value
			end
		end
	end
})

FlyToggle = MovementRight:AddToggle("FlyEnabled", {
	Text = "Fly",
	Default = false,
	Callback = function(Value)
		flyEnabled = Value
		if humanoidRootPart then
			humanoidRootPart.Anchored = Value
			if not Value then 
				humanoidRootPart.Velocity = Vector3.zero 
			end
		end
	end
})

FlyToggle:AddKeyPicker("FlyKey", {
	Default = "None", 
	SyncToggleState = true, 
	Mode = "Toggle", 
	Text = "Fly"
})

FlySpeedSlider = MovementRight:AddSlider("FlySpeed", {
	Text = "Fly Speed",
	Default = 40, 
	Min = 10, 
	Max = 150, 
	Rounding = 0,
	Callback = function(Value) 
		flySpeed = Value 
	end
})

function fly2(hrp, state)
	fly2Enabled = state
	if state then
		remotes.Fly_RUN = RunService.RenderStepped:Connect(function()
			if not fly2Enabled then return end
			moveVector = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + (Camera.CFrame.LookVector * fly2Speed) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - (Camera.CFrame.LookVector * fly2Speed) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - (Camera.CFrame.RightVector * fly2Speed) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + (Camera.CFrame.RightVector * fly2Speed) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + (Camera.CFrame.UpVector * fly2Speed) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - (Camera.CFrame.UpVector * fly2Speed) end
			hrp.Velocity = moveVector
			event = getEvent()
			if event then
				event:FireServer("__---r", Vector3.zero, hrp.CFrame)
			end
		end)
	else
		if remotes.Fly_RUN then 
			remotes.Fly_RUN:Disconnect()
			remotes.Fly_RUN = nil 
		end
		hrp.Velocity = Vector3.zero
	end
end

Fly2Toggle = MovementRight:AddToggle("Fly2Toggle", { 
	Text = "Long Fly",  
	Default = false,
	Callback = function(v)
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			fly2(player.Character.HumanoidRootPart, v)
		end
	end
})

Fly2Toggle:AddKeyPicker("Fly2Key", {
	Default = "None", 
	SyncToggleState = true, 
	Mode = "Toggle", 
	Text = "Long Fly"
})

Fly2SpeedSlider = MovementRight:AddSlider("Fly2Speed", {
	Text = "Long-Fly Speed",
	Default = 60, 
	Min = 10, 
	Max = 150, 
	Rounding = 0,
	Callback = function(Value) 
		fly2Speed = Value 
	end
})

RunService.RenderStepped:Connect(function(deltaTime)
	if flyEnabled and humanoidRootPart then
		moveDirection = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Camera.CFrame.UpVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Camera.CFrame.UpVector end
		if moveDirection.Magnitude > 0 then
			humanoidRootPart.CFrame = humanoidRootPart.CFrame + moveDirection.Unit * (flySpeed * deltaTime)
		end
	end
end)

NoclipDoorsToggle = MovementLeft2:AddToggle('NoclipDoors', {
	Text = "Noclip Doors",
	Default = false,
	Callback = function(State)
		for _, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
			if v:FindFirstChild("DoorBase") then
				v.DoorBase.CanCollide = not State
			end
			if v:FindFirstChild("DoorA") then
				v.DoorA.CanCollide = not State
			end
			if v:FindFirstChild("DoorB") then
				v.DoorB.CanCollide = not State
			end
			if v:FindFirstChild("DoorC") then
				v.DoorC.CanCollide = not State
			end
			if v:FindFirstChild("DoorD") then
				v.DoorD.CanCollide = not State
			end
		end
	end
})

_G.Noclip = false

function Noclip()
	if game.Players.LocalPlayer.Character and _G.Noclip then
		for _, selfChar in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
			if selfChar:IsA("BasePart") and selfChar.CanCollide == true then
				selfChar.CanCollide = false
			end
		end
	end
end

game:GetService("RunService").Stepped:Connect(Noclip)

NoclipToggle = MovementLeft2:AddToggle('NoclipToggle', {
	Text = "Noclip",
	Default = false,
	Callback = function(Value)
		_G.Noclip = Value
	end
}):AddKeyPicker('NoclipKey', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'Noclip'
})

_G.Backwards = false

MovementRight2:AddToggle('BackwardsToggle', {
	Text = "Walk Backwards",
	Default = false,
	Callback = function(Value)
		_G.Backwards = Value
	end
})

game:GetService("RunService").RenderStepped:Connect(function()
	if _G.Backwards then
		camera = workspace.CurrentCamera
		lookDir = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
		targetCFrame = CFrame.new(Vector3.new(0, 0, 0), lookDir) * CFrame.Angles(0, math.pi, 0)
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position) * targetCFrame
	end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
	if _G.Backwards then
		camera = workspace.CurrentCamera
		lookDir = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
		targetCFrame = CFrame.new(Vector3.new(0, 0, 0), lookDir) * CFrame.Angles(0, math.pi, 0)
		newChar.HumanoidRootPart.CFrame = CFrame.new(newChar.HumanoidRootPart.Position) * targetCFrame
	end
end)

NoJumpDelay = false

MovementRight2:AddToggle('NoJumpDelay', {
	Text = 'No Jump Delay',
	Default = false,
	Callback = function(Value)
		NoJumpDelay = Value
	end
})

UserInputService = game:GetService("UserInputService")
Players = game:GetService("Players")

player = Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")

jumpHeld = false
canJump = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Space then
		jumpHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		jumpHeld = false
	end
end)

task.spawn(function()
	while true do
		task.wait(0.01)
		if NoJumpDelay then
			if jumpHeld and humanoid.FloorMaterial ~= Enum.Material.Air and canJump then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				canJump = false
				task.delay(0.35, function()
					canJump = true
				end)
			end
		end
	end
end)

p = game:GetService("Players").LocalPlayer

AlwaysSprintToggle = MovementRight2:AddToggle('AlwaysSprint', {
	Text = "Always Sprint",
	Default = false,
	Callback = function(State)
		if State then
			RunService:BindToRenderStep("AlwaysSprint", Enum.RenderPriority.Character.Value, function()
				if Toggles.AlwaysSprint.Value then
					game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
				end
			end)
		else
			RunService:UnbindFromRenderStep("AlwaysSprint")
			game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
		end
	end
})

AlwaysCrouchToggle = MovementRight2:AddToggle('AlwaysCrouch', {
	Text = "Always Crouch",
	Default = false,
	Callback = function(State)
		if State then
			RunService:BindToRenderStep("AlwaysCrouch", Enum.RenderPriority.Character.Value, function()
				if Toggles.AlwaysCrouch.Value then
					game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.C, false, game)
				end
			end)
		else
			RunService:UnbindFromRenderStep("AlwaysCrouch")
			game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.C, false, game)
		end
	end
})

functions = functions or {}
functions.infstaminaF = false
remotes = remotes or {}
me = game.Players.LocalPlayer

InfStaminaToggle = MovementRight2:AddToggle('InfStaminaToggle', {
	Text = "Infinite Stamina",
	Default = false,
	Callback = function(Value)
		functions.infstaminaF = Value

		if functions.infstaminaF then
			succes, no = pcall(function()
				oldStamina = HF(getupvalue(getrenv()._G.S_Take, 2), function(v1, ...)
					if functions.infstaminaF then v1 = 0 end
					return oldStamina(v1, ...)
				end)
			end)
			if not succes then
				stamina = {}
				get = function()
					for index, value in pairs(GG(true)) do
						if type(value) == "table" and RG(value, "S") then stamina[#stamina + 1] = value end
					end
				end
				ss, nn = pcall(get)
				if ss then
					remotes.infstamina = game:GetService("RunService").RenderStepped:Connect(function()
						get()
						if functions.infstaminaF then for _, a in pairs(stamina) do a.S = 100 end end
					end)
				else
					remotes.infstamina = game:GetService("RunService").RenderStepped:Connect(function()
						if functions.infstaminaF then
							char = me.Character
							if not char then return end
							hum = char:FindFirstChildOfClass("Humanoid")
							if not hum then return end
							check = hum:GetAttribute("ZSPRN_M")
							if not check then hum:SetAttribute("ZSPRN_M", true) end
						end
					end)
				end
			end
		else
			if remotes.infstamina then remotes.infstamina:Disconnect() end
			remotes.infstamina = nil
			if me.Character then me.Character:FindFirstChildOfClass("Humanoid"):SetAttribute("ZSPRN_M", nil) end
		end
	end
})

player = game.Players.LocalPlayer
charStats = game:GetService("ReplicatedStorage").CharStats

MovementRight2:AddToggle('FastAccel', {
	Text = 'Fast Acceleration',
	Default = false,
	Callback = function(Value)
		charStats[player.Name].AccelerationModifier.Value = Value and 1e100 or 1
		charStats[player.Name].AccelerationModifier2.Value = Value and 1e100 or 1
	end
})

charStats[player.Name].Changed:Connect(function()
	if not charStats:FindFirstChild(player.Name) then
		charStats.ChildAdded:Wait()
	end
	Toggles.FastAccel:SetValue(Toggles.FastAccel.Value)
end)

player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid").Died:Connect(function()
		charStats.ChildAdded:Wait()
		Toggles.FastAccel:SetValue(Toggles.FastAccel.Value)
	end)
end)

player = game:GetService("Players").LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
runService = game:GetService("RunService")
replicatedStorage = game:GetService("ReplicatedStorage")

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
end)

fallDamageModule = replicatedStorage:FindFirstChild("FallDamageModule")
if fallDamageModule then
	fallDamage = require(fallDamageModule)
	if type(fallDamage) == "table" and fallDamage.FallDamage then
		fallDamage.FallDamage = function() return 0 end
	end
end

MovementRight2:AddToggle('NofallDamage1', {
	Text = 'No fall Damage1',
	Default = false,
	Callback = function(Value)
		if Value then
			connection = runService.RenderStepped:Connect(function()
				if humanoid and humanoid.Health > 0 then
					humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
					humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end
			end)
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
	end
})

DisableFallDamage = false
DisableRagdoll = false
DisableDrown = false

EventFallRagdoll = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("__RZDONL")
EventDrown = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("TK_DGM")

originalFallRagdollParent = EventFallRagdoll and EventFallRagdoll.Parent
originalDrownParent = EventDrown and EventDrown.Parent

function updateEvents()
	if EventFallRagdoll then
		if DisableRagdoll or DisableFallDamage then
			EventFallRagdoll.Parent = nil
		else
			EventFallRagdoll.Parent = originalFallRagdollParent
		end
	end

	if EventDrown then
		if DisableDrown then
			EventDrown.Parent = nil
		else
			EventDrown.Parent = originalDrownParent
		end
	end
end

NoFallDamageToggle = MovementRight2:AddToggle('NoFallDamage2', {
	Text = "No Fall Damage2",
	Default = false,
	Callback = function(Value)
		DisableFallDamage = Value
		updateEvents()
	end
})

DisableRagdollToggle = MovementRight2:AddToggle('DisableRagdoll', {
	Text = "Disable Ragdoll",
	Default = false,
	Callback = function(Value)
		DisableRagdoll = Value
		updateEvents()
	end
})

DisableDrownToggle = MovementRight2:AddToggle('DisableDrown', {
	Text = "Disable Drown",
	Default = false,
	Callback = function(Value)
		DisableDrown = Value
		updateEvents()
	end
})

game:GetService("RunService").Heartbeat:Connect(function()
	if not EventFallRagdoll then
		EventFallRagdoll = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("__RZDONL")
		if EventFallRagdoll then
			originalFallRagdollParent = EventFallRagdoll.Parent
			updateEvents()
		end
	end
	if not EventDrown then
		EventDrown = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("TK_DGM")
		if EventDrown then
			originalDrownParent = EventDrown.Parent
			updateEvents()
		end
	end

	if EventFallRagdoll and EventFallRagdoll.Parent and (DisableRagdoll or DisableFallDamage) then
		EventFallRagdoll.Parent = nil
	end
	if EventDrown and EventDrown.Parent and DisableDrown then
		EventDrown.Parent = nil
	end
end)

UserInputService = game:GetService("UserInputService")
Players = game:GetService("Players")
RunService = game:GetService("RunService")

player = Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
HRP = character:WaitForChild("HumanoidRootPart")

jumpHeld = false
BunnyHopEnabled = false
_G.BhopSpeed = 25

MovementRight2:AddToggle('BunnyHopToggle', {
	Text = 'BunnyHop',
	Default = false,
	Callback = function(Value)
		BunnyHopEnabled = Value
	end
}):AddKeyPicker('BunnyHopKeyPicker', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'BunnyHop',
	Callback = function(Value)
		BunnyHopEnabled = Value
	end
})

MovementRight2:AddSlider('BhopSpeed', {
	Text = 'Bhop Speed',
	Default = 25,
	Min = 10,
	Max = 70,
	Rounding = 0,
	Callback = function(value)
		_G.BhopSpeed = value
	end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Space then
		jumpHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		jumpHeld = false
	end
end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	HRP = character:WaitForChild("HumanoidRootPart")
end)

RunService.RenderStepped:Connect(function()
	if not BunnyHopEnabled then return end
	if humanoid.FloorMaterial ~= Enum.Material.Air then return end
	if jumpHeld then
		local boost = (_G.BhopSpeed / 10)
		HRP.Velocity += HRP.CFrame.LookVector * boost
	end
end)

GravitySlider = MovementRight2:AddSlider('GravitySlider', {
	Text = "Gravity",
	Default = game.Workspace.Gravity,
	Min = 75,
	Max = 196,
	Rounding = 0,
	Callback = function(Value)
		game.Workspace.Gravity = Value
	end
})

InfectionLeft = Tabs.Infection:AddLeftGroupbox('Player')

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Workspace = game.Workspace

playerBlockersPath = nil
blockersTask = nil
blockersConnection = nil

function CheckBlockersPath()
	filter = Workspace:FindFirstChild("Filter")
	if not filter then
		Workspace.ChildAdded:Connect(function(child)
			if child.Name == "Filter" then
				parts = child:FindFirstChild("Parts")
				if parts then
					playerBlockersPath = parts:FindFirstChild("PlayerBlockers")
				end
			end
		end)
		return
	end

	parts = filter:FindFirstChild("Parts")
	if not parts then
		filter.ChildAdded:Connect(function(child)
			if child.Name == "Parts" then
				playerBlockersPath = child:FindFirstChild("PlayerBlockers")
			end
		end)
		return
	end

	playerBlockersPath = parts:FindFirstChild("PlayerBlockers")
	if not playerBlockersPath then
		parts.ChildAdded:Connect(function(child)
			if child.Name == "PlayerBlockers" then
				playerBlockersPath = child
			end
		end)
	end
end

function RemoveBlockers(Value)
	if blockersTask then
		task.cancel(blockersTask)
		blockersTask = nil
	end
	if blockersConnection then
		blockersConnection:Disconnect()
		blockersConnection = nil
	end
	if Value then
		if playerBlockersPath then
			blockersTask = task.spawn(function()
				while Value and playerBlockersPath do
					for _, part in pairs(playerBlockersPath:GetChildren()) do
						part:Destroy()
					end
					task.wait(0.1)
				end
			end)
		else
			blockersConnection = Workspace.DescendantAdded:Connect(function(descendant)
				if descendant.Name == "PlayerBlockers" and descendant:IsDescendantOf(Workspace) then
					playerBlockersPath = descendant
					blockersTask = task.spawn(function()
						while Value and playerBlockersPath do
							for _, part in pairs(playerBlockersPath:GetChildren()) do
								part:Destroy()
							end
							task.wait(0.1)
						end
					end)
				end
			end)
		end
	end
end

CheckBlockersPath()

InfectionLeft:AddToggle("RemoveSewersBlockers", {
	Text = "Remove SewersBlockers",
	Default = false,
	Callback = function(Value)
		RemoveBlockers(Value)
	end
})

humanoid = nil

function ResetCharacter()
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

function SetupHumanoid()
	character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")

	humanoid.HealthChanged:Connect(function()
		if humanoid.Health <= 0 then
			task.wait(0.5)
			SetupHumanoid()
		end
	end)
end

SetupHumanoid()

InfectionLeft:AddButton({
	Text = "Reset Character",
	Func = function()
		ResetCharacter()
	end
})

Players.LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	SetupHumanoid()
end)

FarmLeft = Tabs.Farm:AddLeftGroupbox('With Alt farm')
FarmRight = Tabs.Farm:AddRightGroupbox('Other')

RunService = game:GetService("RunService")
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
DeathRespawn_Event = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn")
ragdoll = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("__RZDONL")

TPFarm_Enabled = false
TPFarm_TargetName = "selimkarakutuk296"
TPFarm_SteppedConnection = nil
TPFarm_RenderConnection = nil
TPFarm_CharConnection = nil
TPFarm_RagdollConnection = nil

function TPFarm_OnCharacterAdded(char)
	task.wait(0.4)
	hrp = char:FindFirstChild("HumanoidRootPart")
	hum = char:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then return end

	originalPosition = hrp.CFrame

	head = char:FindFirstChild("Head")
	leftArm = char:FindFirstChild("Left Arm")
	rightArm = char:FindFirstChild("Right Arm")
	leftLeg = char:FindFirstChild("Left Leg")
	rightLeg = char:FindFirstChild("Right Leg")

	if head then head.CanCollide = false end
	if leftArm then leftArm.CanCollide = false end
	if rightArm then rightArm.CanCollide = false end
	if leftLeg then leftLeg.CanCollide = false end
	if rightLeg then rightLeg.CanCollide = false end

	if TPFarm_SteppedConnection then
		TPFarm_SteppedConnection:Disconnect()
		TPFarm_SteppedConnection = nil
	end

	if TPFarm_RagdollConnection then
		TPFarm_RagdollConnection:Disconnect()
		TPFarm_RagdollConnection = nil
	end

	TPFarm_SteppedConnection = RunService.Stepped:Connect(function()
		if not TPFarm_Enabled then return end
		mainPlayer = Players:FindFirstChild(TPFarm_TargetName)
		if not mainPlayer then return end
		mainChar = mainPlayer.Character
		if not mainChar then return end
		mainHRP = mainChar:FindFirstChild("HumanoidRootPart")
		if not mainHRP then return end

		targetCFrame = mainHRP.CFrame * CFrame.new(0, 0, -2)
		if head then head.CFrame = targetCFrame end
		if leftArm then leftArm.CFrame = targetCFrame end
		if rightArm then rightArm.CFrame = targetCFrame end
		if leftLeg then leftLeg.CFrame = targetCFrame end
		if rightLeg then rightLeg.CFrame = targetCFrame end

		hrp.CFrame = originalPosition
	end)

	if ragdoll then
		TPFarm_RagdollConnection = RunService.Heartbeat:Connect(function()
			if not TPFarm_Enabled or not ragdoll or not hrp then return end
			ragdoll:FireServer("__---r", Vector3.zero, hrp.CFrame)
			task.wait(0.001)
		end)
	end

	healthConnection = hum:GetPropertyChangedSignal("Health"):Connect(function()
		if TPFarm_Enabled then
			hum.Health = 0
		end
		if hum.Health <= 0 then
			if healthConnection then
				healthConnection:Disconnect()
				healthConnection = nil
			end
			if TPFarm_SteppedConnection then
				TPFarm_SteppedConnection:Disconnect()
				TPFarm_SteppedConnection = nil
			end
			if TPFarm_RagdollConnection then
				TPFarm_RagdollConnection:Disconnect()
				TPFarm_RagdollConnection = nil
			end
		end
	end)
end

function TPFarm_Enable()
	if TPFarm_Enabled then return end
	TPFarm_Enabled = true
	if LocalPlayer.Character then TPFarm_OnCharacterAdded(LocalPlayer.Character) end

	if TPFarm_CharConnection then
		TPFarm_CharConnection:Disconnect()
	end
	TPFarm_CharConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
		if not TPFarm_Enabled then return end
		TPFarm_OnCharacterAdded(newChar)
		tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
		if tool and newChar then tool.Parent = newChar end
	end)

	if TPFarm_RenderConnection then
		TPFarm_RenderConnection:Disconnect()
	end
	TPFarm_RenderConnection = RunService.RenderStepped:Connect(function()
		if not TPFarm_Enabled then return end
		char = LocalPlayer.Character
		if char then
			humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health <= 0 then
				DeathRespawn_Event:InvokeServer("KMG4R904")
			end
		end
	end)
end

function TPFarm_Disable()
	if not TPFarm_Enabled then return end
	TPFarm_Enabled = false
	if TPFarm_SteppedConnection then TPFarm_SteppedConnection:Disconnect() TPFarm_SteppedConnection = nil end
	if TPFarm_RenderConnection then TPFarm_RenderConnection:Disconnect() TPFarm_RenderConnection = nil end
	if TPFarm_CharConnection then TPFarm_CharConnection:Disconnect() TPFarm_CharConnection = nil end
	if TPFarm_RagdollConnection then TPFarm_RagdollConnection:Disconnect() TPFarm_RagdollConnection = nil end
	if LocalPlayer.Character then
		head = LocalPlayer.Character:FindFirstChild("Head")
		leftArm = LocalPlayer.Character:FindFirstChild("Left Arm")
		rightArm = LocalPlayer.Character:FindFirstChild("Right Arm")
		leftLeg = LocalPlayer.Character:FindFirstChild("Left Leg")
		rightLeg = LocalPlayer.Character:FindFirstChild("Right Leg")
		if head then head.CanCollide = true end
		if leftArm then leftArm.CanCollide = true end
		if rightArm then rightArm.CanCollide = true end
		if leftLeg then leftLeg.CanCollide = true end
		if rightLeg then rightLeg.CanCollide = true end
	end
end

FarmLeft:AddToggle('TPFarmToggle', {
	Text = "TP Farm",
	Default = false,
	Callback = function(Value)
		if Value then TPFarm_Enable() else TPFarm_Disable() end
	end
})

FarmLeft:AddInput('TPFarmTarget', {
	Text = "Main acc",
	Default = "selimkarakutuk296",
	Placeholder = "Write your main account",
	Callback = function(Value)
		TPFarm_TargetName = Value
	end
})

RunService = game:GetService("RunService")
Players = game:GetService("Players")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
DeathRespawn_Event = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn")

AutoFarmEnabled = false
AutoClaimAllowanceCoolDown = false
Teleporting = false
ATMUsage = {}

function WaitForCharacter()
	while not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
		task.wait(0.1)
	end
	return LocalPlayer.Character, LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

function GetATM()
	character, hrp = WaitForCharacter()
	if not hrp then return nil, math.huge end

	closestATM = nil
	minDistance = math.huge
	for _, v in ipairs(Workspace.Map.ATMz:GetChildren()) do
		mainPart = v:FindFirstChild("MainPart")
		if mainPart then
			usageCount = ATMUsage[mainPart] or 0
			if usageCount < 2 then
				atmDistance = (hrp.Position - mainPart.Position).Magnitude
				if atmDistance < minDistance then
					minDistance = atmDistance
					closestATM = mainPart
				end
			end
		end
	end
	return closestATM, minDistance
end

function teleportSmoothly(targetPosition)
	character, hrp = WaitForCharacter()
	if not hrp then return end

	Teleporting = true
	stepSize = 3
	currentPos = hrp.Position
	direction = (targetPosition - currentPos).Unit
	while (targetPosition - currentPos).Magnitude > stepSize and AutoFarmEnabled do
		character, hrp = WaitForCharacter()
		if not hrp then
			Teleporting = false
			return
		end
		hrp.CFrame = CFrame.new(currentPos + direction * stepSize)
		currentPos = currentPos + direction * stepSize
		task.wait(0.1)
	end
	character, hrp = WaitForCharacter()
	if hrp then
		hrp.CFrame = CFrame.new(targetPosition)
	end
	task.wait(0.5)
	Teleporting = false
end

function teleportToNearestATM()
	closestATM, _ = GetATM()
	if closestATM then
		teleportSmoothly(closestATM.Position)
		ATMUsage[closestATM] = (ATMUsage[closestATM] or 0) + 1
	end
end

function AutoFarm()
	while AutoFarmEnabled do
		character, hrp = WaitForCharacter()
		if not hrp then
			task.wait(1)
			continue
		end

		nextAllowance = game:GetService("ReplicatedStorage").PlayerbaseData2[LocalPlayer.Name]:FindFirstChild("NextAllowance")
		if nextAllowance and nextAllowance.Value == 0 and not AutoClaimAllowanceCoolDown then
			ATM, distance = GetATM()
			if ATM then
				AutoClaimAllowanceCoolDown = true
				teleportToNearestATM()
				task.wait(0.5)
				game:GetService("ReplicatedStorage").Events.CLMZALOW:InvokeServer(ATM)
				task.wait(0.5)
				AutoClaimAllowanceCoolDown = false
			end
		end

		task.wait(0.1)
	end
end

function AutoRespawn()
	while AutoFarmEnabled do
		character = LocalPlayer.Character
		if character then
			humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health <= 0 and not humanoid:GetAttribute("Respawning") then
				humanoid:SetAttribute("Respawning", true)
				DeathRespawn_Event:InvokeServer("KMG4R904")
				task.wait(1)
				if character then
					humanoid:SetAttribute("Respawning", false)
				end
			end
		end
		task.wait(1)
	end
end

LocalPlayer.CharacterAdded:Connect(function(character)
	hrp = character:WaitForChild("HumanoidRootPart")
	humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:SetAttribute("Respawning", false)
	end
	if AutoFarmEnabled then
		spawn(AutoFarm)
		spawn(AutoRespawn)
	end
end)

aatmToggle = FarmRight:AddToggle('AutoFarmToggle', {
	Text = "AutoFarm ATM",
	Default = false,
	Callback = function(Value)
		AutoFarmEnabled = Value
		if AutoFarmEnabled then
			spawn(AutoFarm)
			spawn(AutoRespawn)
		end
	end
})

run = game:GetService("RunService")
me = game.Players.LocalPlayer
_G.LockpickEnabled = false

function lockpick(gui)
	for _, a in pairs(gui:GetDescendants()) do
		if a:IsA("ImageLabel") and a.Name == "Bar" and a.Parent.Name ~= "Attempts" then
			oldsize = a.Size
			run.RenderStepped:Connect(function()
				if _G.LockpickEnabled then
					a.Size = UDim2.new(0, 280, 0, 280)
				else
					a.Size = oldsize
				end
			end)
		end
	end
end

me.PlayerGui.ChildAdded:Connect(function(gui)
	if gui:IsA("ScreenGui") and gui.Name == "LockpickGUI" then
		lockpick(gui)
	end
end)

hbeToggle = FarmRight:AddToggle('LockpickToggle', {
	Text = "No Fail Lockpick",
	Default = false,
	Callback = function(Value)
		_G.LockpickEnabled = Value
	end
})

MiscLeft = Tabs.Misc:AddLeftGroupbox('Hiddens')
MiscRight = Tabs.Misc:AddRightGroupbox('Auto\'s')
MiscLeft2 = Tabs.Misc:AddLeftGroupbox('Anti-effect')
MiscLeft3 = Tabs.Misc:AddLeftGroupbox('Teleports')
MiscLeft4 = Tabs.Misc:AddLeftGroupbox('Anti-Aim')
MiscRight2 = Tabs.Misc:AddRightGroupbox('Animations')
MiscRight4 = Tabs.Misc:AddRightGroupbox('ChatBot')
MiscRight3 = Tabs.Misc:AddRightGroupbox('Others')

Players = game:GetService("Players")
Workspace = game:GetService("Workspace")
RunService = game:GetService("RunService")

player = Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoidRootPart = character:WaitForChild("HumanoidRootPart")
humanoid = character:WaitForChild("Humanoid")

enabled = false
animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://282574440"
danceTrack = nil
dysenc = {}
temp = 1
animpos = 1.755
underground = -2.6

function onCharacterAdded(char)
	humanoid = char:WaitForChild("Humanoid")
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")
	character = char
	if Toggles.hiddenbodyToggle and Toggles.hiddenbodyToggle.Value then
		enableSpoofMethod()
	end
end

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

player.CharacterRemoving:Connect(function()
	if danceTrack then
		pcall(function()
			danceTrack:Stop()
			danceTrack:Destroy()
		end)
		danceTrack = nil
		enabled = false
	end
end)

function enableSpoofMethod()
	enabled = true
	danceTrack = humanoid:LoadAnimation(animation)
	danceTrack.Looped = true
	danceTrack.Priority = Enum.AnimationPriority.Action4
	danceTrack:Play(0.1, 1, 0)
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		temp = temp + 1
		if enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if danceTrack then
				danceTrack.TimePosition = animpos
			end
			hrp = player.Character.HumanoidRootPart
			dysenc[1] = hrp.CFrame
			dysenc[2] = hrp.AssemblyLinearVelocity
			spoofed = hrp.CFrame + Vector3.new(0, underground, 0)
			hrp.CFrame = spoofed
			RunService.RenderStepped:Wait()
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				hrp.CFrame = dysenc[1]
				hrp.AssemblyLinearVelocity = dysenc[2]
			end
		end
	end)
end

function disableSpoofMethod()
	enabled = false
	if danceTrack then
		danceTrack:Stop()
		danceTrack:Destroy()
		danceTrack = nil
	end
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

MiscLeft:AddToggle('hiddenbodyToggle', {
	Text = 'Hidden Body',
	Default = false,
	Callback = function(Value)
		if Value then
			enableSpoofMethod()
		else
			disableSpoofMethod()
		end
	end
}):AddKeyPicker('HiddenBodyKey', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'Hidden Body',
	Callback = function()
	end
})

humanoid.Died:Connect(function()
	disableSpoofMethod()
end)

GameFramework = GameFramework or {}
GameFramework.HeadGlitch = false
Client = game:GetService("Players").LocalPlayer
Camera = workspace.CurrentCamera

MiscLeft:AddButton({
	Text = 'Hide Head',
	Func = function()
		GameFramework.HeadGlitch = true
		Character = Client.Character
		if Character then
			NeckJoint = Character.HumanoidRootPart.CTs.RGCT_Neck
			Character.Torso.Neck:Destroy()
			Character.Torso.NeckAttachment:Destroy()
			NeckJoint.TwistLowerAngle = 0
			NeckJoint.TwistUpperAngle = 0
			NeckJoint.Restitution = 0
			NeckJoint.UpperAngle = 0
			NeckJoint.MaxFrictionTorque = 0
			Character.Head.HeadCollider:Destroy()
		end
	end
})

Client.CharacterAdded:Connect(function(newCharacter)
	if GameFramework.HeadGlitch then
		GameFramework.HeadGlitch = false
	end
end)

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	if GameFramework.HeadGlitch and Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") and Client.Character:FindFirstChild("Head") then
		Character = Client.Character
		Character.Head.CanCollide = false
		Character.Head.CFrame = Client.Character.HumanoidRootPart.CFrame * CFrame.new(0, -4, 0)
	end
end)

MiscLeft:AddButton({
	Text = "Hide Arms",
	Func = function()
		character = game:GetService("Players").LocalPlayer.Character
		if character then
			leftArm = character:FindFirstChild("Left Arm")
			rightArm = character:FindFirstChild("Right Arm")
			if leftArm then leftArm:Destroy() end
			if rightArm then rightArm:Destroy() end
		end
	end
})

MiscLeft:AddButton({
	Text = "Hide Legs",
	Func = function()
		character = game:GetService("Players").LocalPlayer.Character
		if character then
			leftLeg = character:FindFirstChild("Left Leg")
			rightLeg = character:FindFirstChild("Right Leg")
			if leftLeg then leftLeg:Destroy() end
			if rightLeg then rightLeg:Destroy() end
		end
	end
})

function GetSafe(Studs, Type)
	if Type then
		Part = nil
		for _, v in ipairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
			if v:FindFirstChild("MainPart") and string.find(v.Name, "Safe") then
				Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("MainPart").Position).Magnitude
				if Distance < Studs then
					Studs = Distance
					Part = v:FindFirstChild("MainPart")
				end
			end
		end
		return Part
	else
		Part = nil
		for _, v in ipairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
			if v:FindFirstChild("MainPart") and string.find(v.Name, "Safe") and v:FindFirstChild("Values").Broken.Value == false then
				Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("MainPart").Position).Magnitude
				if Distance < Studs then
					Studs = Distance
					Part = v:FindFirstChild("MainPart")
				end
			end
		end
		return Part
	end
end

function GetRegister(Studs)
	Part = nil
	for _, v in ipairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
		if v:FindFirstChild("MainPart") and string.find(v.Name, "Register") and v:FindFirstChild("Values").Broken.Value == false then
			Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("MainPart").Position).Magnitude
			if Distance < Studs then
				Studs = Distance
				Part = v:FindFirstChild("MainPart")
			end
		end
	end
	return Part
end

function Getloor(Studs, Type)
	if Type then
		Part = nil
		for _, v in ipairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
			if v:FindFirstChild("DoorBase") then
				Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("DoorBase").Position).Magnitude
				if Distance < Studs then
					Studs = Distance
					Part = v:FindFirstChild("DoorBase")
				end
			end
		end
		return Part
	else
		Part = nil
		for _, v in ipairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
			if v:FindFirstChild("DoorBase") and v:FindFirstChild("Values").Locked.Value == true and v:FindFirstChild("Values").Broken.Value == false then
				Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("DoorBase").Position).Magnitude
				if Distance < Studs then
					Studs = Distance
					Part = v:FindFirstChild("DoorBase")
				end
			end
		end
		return Part
	end
end

MiscRight:AddToggle('AutoBreakDoor', {
	Text = 'Auto Break Door',
	Default = false,
	Callback = function(State)
		if State then
			AutoBreakDoorConnection = game:GetService('RunService').RenderStepped:Connect(function()
				if Toggles.AutoBreakDoor.Value and (game:GetService("Players").LocalPlayer.Character:FindFirstChild("Crowbar") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Fists")) then
					ClosestDoor = Getloor(AutoBreakDoorRangeValue, false)
					if ClosestDoor and not AutoBreakDoorCoolDown then
						AutoBreakDoorCoolDown = true
						AutoBreakDoorValue = game:GetService("ReplicatedStorage").Events["XMHH.2"]:InvokeServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "DZDRRRKI", ClosestDoor.Parent, "Door")
						game:GetService("ReplicatedStorage").Events["XMHH2.2"]:FireServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "2389ZFX34", AutoBreakDoorValue, false, game:GetService("Players").LocalPlayer.Character["Right Leg"], ClosestDoor, ClosestDoor.Parent, ClosestDoor.Position, ClosestDoor.Position)
						wait(0.5)
						AutoBreakDoorCoolDown = false
					end
				end
			end)
		else
			if AutoBreakDoorConnection then AutoBreakDoorConnection:Disconnect() end
		end
	end
})

MiscRight:AddToggle('AutoBreakSafe', {
	Text = 'Auto Break Safe',
	Default = false,
	Callback = function(State)
		if State then
			AutoBreakSafeConnection = game:GetService('RunService').RenderStepped:Connect(function()
				if Toggles.AutoBreakSafe.Value and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Crowbar") then
					ClosestSafe = GetSafe(AutoBreakSafeRangeValue, false)
					if ClosestSafe and not AutoBreakSafeCoolDown then
						AutoBreakSafeCoolDown = true
						AutoBreakSafeValue = game:GetService("ReplicatedStorage").Events["XMHH.2"]:InvokeServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "DZDRRRKI", ClosestSafe.Parent, "Register")
						game:GetService("ReplicatedStorage").Events["XMHH2.2"]:FireServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "2389ZFX34", AutoBreakSafeValue, false, game:GetService("Players").LocalPlayer.Character["Right Arm"], ClosestSafe, ClosestSafe.Parent, ClosestSafe.Position, ClosestSafe.Position)
						wait(0.5)
						AutoBreakSafeCoolDown = false
					end
				end
			end)
		else
			if AutoBreakSafeConnection then AutoBreakSafeConnection:Disconnect() end
		end
	end
})

MiscRight:AddToggle('AutoBreakRegister', {
	Text = 'Auto Break Register',
	Default = false,
	Callback = function(State)
		if State then
			AutoBreakRegisterConnection = game:GetService('RunService').RenderStepped:Connect(function()
				if Toggles.AutoBreakRegister.Value and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Fists") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Crowbar") then
					ClosestRegister = GetRegister(AutoBreakRegisterRangeValue)
					if ClosestRegister and not AutoBreakRegisterCoolDown then
						AutoBreakRegisterCoolDown = true
						AutoBreakRegisterValue = game:GetService("ReplicatedStorage").Events["XMHH.2"]:InvokeServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "DZDRRRKI", ClosestRegister.Parent, "Register")
						game:GetService("ReplicatedStorage").Events["XMHH2.2"]:FireServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "2389ZFX34", AutoBreakRegisterValue, false, game:GetService("Players").LocalPlayer.Character["Right Arm"], ClosestRegister, ClosestRegister.Parent, ClosestRegister.Position, ClosestRegister.Position)
						wait(0.5)
						AutoBreakRegisterCoolDown = false
					end
				end
			end)
		else
			if AutoBreakRegisterConnection then AutoBreakRegisterConnection:Disconnect() end
		end
	end
})

me = game.Players.LocalPlayer
run = game:GetService("RunService")
AutoOpenDoorsF = false
AutoUnlockDoorsF = false
AutoLockDoorsF = false
AutoCloseDoorsF = false
AutoKnockDoorsF = false
OpenDoorsDistance = 1
UnlockDoorsDistance = 1
LockDoorsDistance = 1
CloseDoorsDistance = 1
AutoKnockDoorsDistance = 1

MiscRight:AddToggle('AutoOpenDoorsToggle', {
	Text = "Auto Open Doors",
	Default = false,
	Callback = function(Value)
		AutoOpenDoorsF = Value
		if Value then
			spawn(OpenDoorsL)
		end
	end
})

MiscRight:AddToggle('AutoUnlockDoorsToggle', {
	Text = "Auto Unlock Doors",
	Default = false,
	Callback = function(Value)
		AutoUnlockDoorsF = Value
		if Value then
			spawn(UnlockDoorsL)
		end
	end
})

MiscRight:AddToggle('AutoLockDoorsToggle', {
	Text = "Auto Lock Doors",
	Default = false,
	Callback = function(Value)
		AutoLockDoorsF = Value
		if Value then
			spawn(LockDoorsL)
		end
	end
})

MiscRight:AddToggle('AutoCloseDoorsToggle', {
	Text = "Auto Close Doors",
	Default = false,
	Callback = function(Value)
		AutoCloseDoorsF = Value
		if Value then
			spawn(CloseDoorsL)
		end
	end
})

MiscRight:AddToggle('AutoKnockDoorsToggle', {
	Text = "Auto Knock Doors",
	Default = false,
	Callback = function(Value)
		AutoKnockDoorsF = Value
		if Value then
			spawn(KnockDoorsL)
		end
	end
})

GetDoor = function(dist)
	mapFolder = workspace:FindFirstChild("Map")
	if not mapFolder then return nil end
	folderDoors = mapFolder:FindFirstChild("Doors")
	if not folderDoors then return nil end
	closestDoor = nil
	closestDist = dist
	for _, d in pairs(folderDoors:GetChildren()) do
		doorBase = d:FindFirstChild("DoorBase")
		if doorBase then
			distance = (me.Character.HumanoidRootPart.Position - doorBase.Position).Magnitude
			if distance < closestDist then
				closestDist = distance
				closestDoor = d
			end
		end
	end
	return closestDoor
end

OpenDoorsL = function()
	while AutoOpenDoorsF do
		if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
			me.Character = me.Character or me.CharacterAdded:Wait()
			me.Character:WaitForChild("HumanoidRootPart")
		end
		hrp = me.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			run.RenderStepped:Wait()
			continue
		end
		door = GetDoor(OpenDoorsDistance)
		if door then
			values = door:FindFirstChild("Values")
			events = door:FindFirstChild("Events")
			if values and events then
				locked = values:FindFirstChild("Locked")
				openValue = values:FindFirstChild("Open")
				toggleEvent = events:FindFirstChild("Toggle")
				if locked and openValue and toggleEvent and not locked.Value and not openValue.Value then
					knob1 = door:FindFirstChild("Knob1")
					knob2 = door:FindFirstChild("Knob2")
					if knob1 and knob2 then
						knob1pos = (hrp.Position - knob1.Position).Magnitude
						knob2pos = (hrp.Position - knob2.Position).Magnitude
						chosenKnob = knob1pos < knob2pos and knob1 or knob2
						toggleEvent:FireServer("Open", chosenKnob)
					end
				end
			end
		end
		run.RenderStepped:Wait()
	end
end

UnlockDoorsL = function()
	while AutoUnlockDoorsF do
		if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
			me.Character = me.Character or me.CharacterAdded:Wait()
			me.Character:WaitForChild("HumanoidRootPart")
		end
		hrp = me.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			run.RenderStepped:Wait()
			continue
		end
		door = GetDoor(UnlockDoorsDistance)
		if door then
			values = door:FindFirstChild("Values")
			events = door:FindFirstChild("Events")
			if values and events then
				locked = values:FindFirstChild("Locked")
				toggleEvent = events:FindFirstChild("Toggle")
				if locked and toggleEvent and locked.Value then
					toggleEvent:FireServer("Unlock", door.Lock)
				end
			end
		end
		run.RenderStepped:Wait()
	end
end

LockDoorsL = function()
	while AutoLockDoorsF do
		if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
			me.Character = me.Character or me.CharacterAdded:Wait()
			me.Character:WaitForChild("HumanoidRootPart")
		end
		hrp = me.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			run.RenderStepped:Wait()
			continue
		end
		door = GetDoor(LockDoorsDistance)
		if door then
			values = door:FindFirstChild("Values")
			events = door:FindFirstChild("Events")
			if values and events then
				locked = values:FindFirstChild("Locked")
				toggleEvent = events:FindFirstChild("Toggle")
				if locked and toggleEvent and not locked.Value then
					toggleEvent:FireServer("Lock", door.Lock)
				end
			end
		end
		run.RenderStepped:Wait()
	end
end

CloseDoorsL = function()
	while AutoCloseDoorsF do
		if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
			me.Character = me.Character or me.CharacterAdded:Wait()
			me.Character:WaitForChild("HumanoidRootPart")
		end
		hrp = me.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			run.RenderStepped:Wait()
			continue
		end
		door = GetDoor(CloseDoorsDistance)
		if door then
			values = door:FindFirstChild("Values")
			events = door:FindFirstChild("Events")
			if values and events then
				openValue = values:FindFirstChild("Open")
				toggleEvent = events:FindFirstChild("Toggle")
				if openValue and toggleEvent and openValue.Value then
					knob1 = door:FindFirstChild("Knob1")
					knob2 = door:FindFirstChild("Knob2")
					if knob1 and knob2 then
						knob1pos = (hrp.Position - knob1.Position).Magnitude
						knob2pos = (hrp.Position - knob2.Position).Magnitude
						chosenKnob = knob1pos < knob2pos and knob1 or knob2
						toggleEvent:FireServer("Close", chosenKnob)
					end
				end
			end
		end
		run.RenderStepped:Wait()
	end
end

KnockDoorsL = function()
	while AutoKnockDoorsF do
		if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
			me.Character = me.Character or me.CharacterAdded:Wait()
			me.Character:WaitForChild("HumanoidRootPart")
		end
		hrp = me.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then
			run.RenderStepped:Wait()
			continue
		end
		door = GetDoor(AutoKnockDoorsDistance)
		if door then
			events = door:FindFirstChild("Events")
			if events then
				toggleEvent = events:FindFirstChild("Toggle")
				if toggleEvent then
					knob1 = door:FindFirstChild("Knob1")
					knob2 = door:FindFirstChild("Knob2")
					if knob1 and knob2 then
						knob1pos = (hrp.Position - knob1.Position).Magnitude
						knob2pos = (hrp.Position - knob2.Position).Magnitude
						chosenKnob = knob1pos < knob2pos and knob1 or knob2
						toggleEvent:FireServer("Knock", chosenKnob)
					end
				end
			end
		end
		run.RenderStepped:Wait()
	end
end

AutoClaimEnabled = false
AutoClaimAllowanceCoolDown = false

p = game:GetService("Players").LocalPlayer
ws = game:GetService("Workspace")
run = game:GetService("RunService")
hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") or nil

function updateHRP()
	if p.Character then
		hrp = p.Character:FindFirstChild("HumanoidRootPart")
	end
end

function GetATM()
	updateHRP()
	if not hrp then return nil end
	closestATM, minDistance = nil, math.huge
	for _, v in ipairs(ws.Map.ATMz:GetChildren()) do
		mainPart = v:FindFirstChild("MainPart")
		if mainPart then
			distance = (hrp.Position - mainPart.Position).Magnitude
			if distance < minDistance then
				minDistance, closestATM = distance, mainPart
			end
		end
	end
	return closestATM
end

function AutoClaimAllowance()
	while AutoClaimEnabled do
		updateHRP()
		nextAllowance = game:GetService("ReplicatedStorage").PlayerbaseData2[p.Name]:FindFirstChild("NextAllowance")
		if nextAllowance and nextAllowance.Value == 0 then
			ATM = GetATM()
			if ATM and not AutoClaimAllowanceCoolDown then
				AutoClaimAllowanceCoolDown = true
				game:GetService("ReplicatedStorage").Events.CLMZALOW:InvokeServer(ATM)
				wait(0.5)
				AutoClaimAllowanceCoolDown = false
			end
		end
		wait(1)
	end
end

p.CharacterAdded:Connect(function(character)
	hrp = character:WaitForChild("HumanoidRootPart")
	if AutoClaimEnabled then
		spawn(AutoClaimAllowance)
	end
end)

MiscRight:AddToggle('AutoClaimAllowance', {
	Text = "AutoClaim Allowance",
	Default = false,
	Callback = function(Value)
		AutoClaimEnabled = Value
		if AutoClaimEnabled then
			spawn(AutoClaimAllowance)
		end
	end
})

RespToggleState = false

MiscRight:AddToggle('AutoRespawn', {
	Text = "Auto Respawn",
	Default = false,
	Callback = function(Value)
		RespToggleState = Value
	end
})

deathssevent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn")

run.RenderStepped:Connect(function()
	if RespToggleState then
		char = me.Character
		if char then
			humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health <= 0 then
				deathssevent:InvokeServer("KMG4R904")
			end
		end
	end
end)

function GetDealer(Studs, Type)
	Part = nil
	Studs = Studs or math.huge
	for _, v in ipairs(game:GetService("Workspace").Map.Shopz:GetChildren()) do
		if v.Name == Type and v:FindFirstChild("MainPart") then
			Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v.MainPart.Position).Magnitude
			if Distance < Studs then
				Studs = Distance
				Part = v.MainPart
			end
		end
	end
	return Part
end

function GetArmor()
	for _, v in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
		if v:FindFirstChild("BrokenM") then
			return v.Name
		end
	end
	return "None"
end

MiscRight:AddToggle('AutoBuyToggle', {
	Text = 'AutoBuy',
	Default = false,
	Callback = function(Value)
		AutoBuyEnabled = Value
		if Value then
			task.spawn(function()
				while Toggles.AutoBuyToggle.Value do
					Dealer = GetDealer(math.huge, "Dealer")
					if Dealer then
						for item, enabled in pairs(Options.AutoBuyDropdown.Value) do
							if enabled then
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Melees", item, Dealer)
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item, Dealer)
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item, Dealer)
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item, Dealer)
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Melees", item, Dealer)
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Guns", item, Dealer)
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Throwables", item, Dealer)
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Misc", item, Dealer)
							end
						end
					end
					task.wait()
				end
			end)
		end
	end
}):AddKeyPicker('AutoBuyKeyPicker', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'Auto Buy',
	Callback = function(Value)
		AutoBuyEnabled = Value
	end
})

MiscRight:AddToggle('AutoSellToggle', {
	Text = 'AutoSell',
	Default = false,
	Callback = function(Value)
		AutoSellEnabled = Value
		if Value then
			task.spawn(function()
				while Toggles.AutoSellToggle.Value do
					Dealer = GetDealer(math.huge, "Dealer")
					if Dealer then
						for category, enabled in pairs(Options.AutoSellDropdown.Value) do
							if enabled then
								for _, item in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
									if item:IsA("Tool") and item.Name ~= GetArmor() and item.Name ~= game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name then
										game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
										if category == "All" then
											game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
											game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
											game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
										end
									end
								end
								for _, item in ipairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
									if item:IsA("Tool") then
										game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
										if category == "All" then
											game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
											game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
											game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
										end
									end
								end
							end
						end
					end
					task.wait()
				end
			end)
		end
	end
}):AddKeyPicker('AutoSellKeyPicker', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'Auto Sell',
	Callback = function(Value)
		AutoSellEnabled = Value
	end
})

MiscRight:AddToggle('AutoRepairToggle', {
	Text = 'AutoRepair and Refill',
	Default = false,
	Callback = function(Value)
		if Value then
			task.spawn(function()
				while Toggles.AutoRepairToggle.Value do
					if not AutoRePairAndReFillCoolDown then
						AutoRePairAndReFillCoolDown = true
						Dealer = GetDealer(AutoRepairRange, "Dealer") or GetDealer(AutoRepairRange, "ArmoryDealer")
						if Dealer and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool") then
							if Dealer.Parent.Name == "Dealer" then
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name, Dealer, "ResupplyAmmo")
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Armour", GetArmor(), Dealer, "ResupplyAmmo")
							elseif Dealer.Parent.Name == "ArmoryDealer" then
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Guns", game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name, Dealer, "ResupplyAmmo")
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Armour", GetArmor(), Dealer, "ResupplyAmmo")
							end
						end
						task.wait(0.5)
						AutoRePairAndReFillCoolDown = false
					end
					task.wait()
				end
			end)
		end
	end
})

pickupMethod = "Without Remote Event"

toolsFolder = game:GetService("Workspace"):WaitForChild("Filter"):WaitForChild("SpawnedTools")
cashFolder = game:GetService("Workspace"):WaitForChild("Filter"):WaitForChild("SpawnedBread")
pilesFolder = game:GetService("Workspace"):WaitForChild("Filter"):WaitForChild("SpawnedPiles")

toolsEnabled = false
cashEnabled = false
scrapsEnabled = false
cratesEnabled = false

scrapsConnection = nil
toolsConnection = nil
cratesConnection = nil
moneyConnection = nil
canPickup = true
lastPickupTime = 0
cooldown = 0.8

function interactWithPrompt(v)
	if v:IsA("ProximityPrompt") and canPickup then
		v.HoldDuration = 0
		fireproximityprompt(v)
		canPickup = false
		lastPickupTime = tick()
	end
end

function pickupWithoutRemote(v)
	if toolsEnabled and v:IsA("Model") and toolsFolder:FindFirstChild(v.Name) then
		for _, p in pairs(v:GetDescendants()) do interactWithPrompt(p) end
	elseif cashEnabled and v:IsA("BasePart") and v.Name == "CashDrop1" then
		for _, p in pairs(v:GetChildren()) do interactWithPrompt(p) end
	elseif scrapsEnabled and v:IsA("Model") and (v.Name == "S1" or v.Name == "S2") then
		for _, p in pairs(v:GetDescendants()) do interactWithPrompt(p) end
	elseif cratesEnabled and v:IsA("Model") and (v.Name == "C1" or v.Name == "C2" or v.Name == "C3") then
		for _, p in pairs(v:GetDescendants()) do interactWithPrompt(p) end
	end
end

function scanItems()
	while toolsEnabled or cashEnabled or scrapsEnabled or cratesEnabled do
		if not canPickup and tick() - lastPickupTime >= cooldown then
			canPickup = true
		end
		for _, v in ipairs(toolsFolder:GetChildren()) do pickupWithoutRemote(v) end
		for _, v in ipairs(cashFolder:GetChildren()) do pickupWithoutRemote(v) end
		for _, v in ipairs(pilesFolder:GetChildren()) do pickupWithoutRemote(v) end
		task.wait(0.1)
	end
end

function pickupWithRemoteScraps()
	rpScraps = game:GetService("ReplicatedStorage")
	remoteScraps = rpScraps:WaitForChild("Events"):WaitForChild("PIC_PU")
	scrapsFolderScraps = pilesFolder
	canPickupRemoteScraps = true
	startTickScraps = tick()
	scrapsConnection = run.RenderStepped:Connect(function()
		maxdistScraps = 15
		closestScraps = nil
		for _, a in pairs(scrapsFolderScraps:GetChildren()) do
			if a and (a.Name == "S1" or a.Name == "S2") and me.Character and me.Character.HumanoidRootPart then
				getdistScraps = (me.Character.HumanoidRootPart.Position - a.MeshPart.Position).Magnitude
				if getdistScraps < maxdistScraps then
					maxdistScraps = getdistScraps
					closestScraps = a
				end
			end
		end
		if closestScraps and canPickupRemoteScraps then
			remoteScraps:FireServer(string.reverse(closestScraps:GetAttribute("jzu")))
			canPickupRemoteScraps = false
		elseif closestScraps and tick() - startTickScraps >= 4.5 then
			canPickupRemoteScraps = true
			startTickScraps = tick()
		end
	end)
end

function pickupWithRemoteTools()
	rpTools = game:GetService("ReplicatedStorage")
	remoteTools = rpTools:WaitForChild("Events"):WaitForChild("PIC_TLO")
	toolsFolderTools = toolsFolder
	canPickupRemoteTools = true
	startTickTools = tick()
	toolsConnection = run.RenderStepped:Connect(function()
		maxdistTools = 15
		closestTools = nil
		for _, a in pairs(toolsFolderTools:GetChildren()) do
			if a and me.Character and me.Character.HumanoidRootPart then
				handleTools = a:FindFirstChild("Handle") or a:FindFirstChild("WeaponHandle")
				if handleTools and (handleTools:IsA("Part") or handleTools:IsA("MeshPart")) then
					getdistTools = (me.Character.HumanoidRootPart.Position - handleTools.Position).Magnitude
					if getdistTools < maxdistTools then
						maxdistTools = getdistTools
						closestTools = a
					end
				end
			end
		end
		if closestTools then
			HandleTools = closestTools:FindFirstChild("Handle") or closestTools:FindFirstChild("WeaponHandle")
			if HandleTools and canPickupRemoteTools then
				remoteTools:FireServer(HandleTools)
				canPickupRemoteTools = false
			elseif HandleTools and tick() - startTickTools >= 1.5 then
				canPickupRemoteTools = true
				startTickTools = tick()
			end
		end
	end)
end

function pickupWithRemoteCrates()
	rpCrates = game:GetService("ReplicatedStorage")
	remoteCrates = rpCrates:WaitForChild("Events"):WaitForChild("PIC_PU")
	scrapsFolderCrates = pilesFolder
	canPickupRemoteCrates = true
	startTickCrates = tick()
	cratesConnection = run.RenderStepped:Connect(function()
		maxdistCrates = 15
		closestCrates = nil
		for _, a in pairs(scrapsFolderCrates:GetChildren()) do
			if a and (a.Name == "C1" or a.Name == "C2" or a.Name == "C3") and me.Character and me.Character.HumanoidRootPart then
				getdistCrates = (me.Character.HumanoidRootPart.Position - a.MeshPart.Position).Magnitude
				if getdistCrates < maxdistCrates then
					maxdistCrates = getdistCrates
					closestCrates = a
				end
			end
		end
		if closestCrates and canPickupRemoteCrates then
			remoteCrates:FireServer(string.reverse(closestCrates:GetAttribute("jzu")))
			canPickupRemoteCrates = false
		elseif closestCrates and tick() - startTickCrates >= 7 then
			canPickupRemoteCrates = true
			startTickCrates = tick()
		end
	end)
end

function pickupWithRemoteMoney()
	rpMoney = game:GetService("ReplicatedStorage")
	remoteMoney = rpMoney:WaitForChild("Events"):WaitForChild("CZDPZUS")
	moneyFolderMoney = cashFolder
	canPickupRemoteMoney = true
	startTickMoney = tick()
	moneyConnection = run.RenderStepped:Connect(function()
		maxdistMoney = 15
		closestMoney = nil
		for _, a in pairs(moneyFolderMoney:GetChildren()) do
			if a and me.Character and me.Character.HumanoidRootPart then
				getdistMoney = (me.Character.HumanoidRootPart.Position - a.Position).Magnitude
				if getdistMoney < maxdistMoney then
					maxdistMoney = getdistMoney
					closestMoney = a
				end
			end
		end
		if closestMoney and canPickupRemoteMoney then
			remoteMoney:FireServer(closestMoney)
			canPickupRemoteMoney = false
		elseif closestMoney and tick() - startTickMoney >= 0.7 then
			canPickupRemoteMoney = true
			startTickMoney = tick()
		end
	end)
end

toolsFolder.ChildAdded:Connect(pickupWithoutRemote)
cashFolder.ChildAdded:Connect(pickupWithoutRemote)
pilesFolder.ChildAdded:Connect(pickupWithoutRemote)
workspace.DescendantAdded:Connect(interactWithPrompt)

MiscRight:AddToggle('ToggleScraps', {
	Text = "AutoPickup Scraps",
	Default = false,
	Callback = function(Value)
		scrapsEnabled = Value
		if scrapsConnection then
			scrapsConnection:Disconnect()
			scrapsConnection = nil
		end
		if scrapsEnabled then
			if pickupMethod == "Without Remote Event" then
				task.spawn(scanItems)
			else
				pickupWithRemoteScraps()
			end
		end
	end
})

MiscRight:AddToggle('ToggleTools', {
	Text = "AutoPickup Tools",
	Default = false,
	Callback = function(Value)
		toolsEnabled = Value
		if toolsConnection then
			toolsConnection:Disconnect()
			toolsConnection = nil
		end
		if toolsEnabled then
			if pickupMethod == "Without Remote Event" then
				task.spawn(scanItems)
			else
				pickupWithRemoteTools()
			end
		end
	end
})

MiscRight:AddToggle('ToggleCrates', {
	Text = "AutoPickup Crates",
	Default = false,
	Callback = function(Value)
		cratesEnabled = Value
		if cratesConnection then
			cratesConnection:Disconnect()
			cratesConnection = nil
		end
		if cratesEnabled then
			if pickupMethod == "Without Remote Event" then
				task.spawn(scanItems)
			else
				pickupWithRemoteCrates()
			end
		end
	end
})

MiscRight:AddToggle('ToggleCash', {
	Text = "AutoPickup Money",
	Default = false,
	Callback = function(Value)
		cashEnabled = Value
		if moneyConnection then
			moneyConnection:Disconnect()
			moneyConnection = nil
		end
		if cashEnabled then
			if pickupMethod == "Without Remote Event" then
				task.spawn(scanItems)
			else
				pickupWithRemoteMoney()
			end
		end
	end
})

MiscRight:AddDropdown('PickupMethod', {
	Text = "Pickup Method",
	Default = "Without Remote Event",
	Values = {"Without Remote Event", "With Remote Event"},
	Callback = function(Value)
		pickupMethod = Value
		if scrapsConnection then
			scrapsConnection:Disconnect()
			scrapsConnection = nil
		end
		if toolsConnection then
			toolsConnection:Disconnect()
			toolsConnection = nil
		end
		if cratesConnection then
			cratesConnection:Disconnect()
			cratesConnection = nil
		end
		if moneyConnection then
			moneyConnection:Disconnect()
			moneyConnection = nil
		end
		if scrapsEnabled then
			if pickupMethod == "Without Remote Event" then
				task.spawn(scanItems)
			else
				pickupWithRemoteScraps()
			end
		end
		if toolsEnabled then
			if pickupMethod == "Without Remote Event" then
				task.spawn(scanItems)
			else
				pickupWithRemoteTools()
			end
		end
		if cratesEnabled then
			if pickupMethod == "Without Remote Event" then
				task.spawn(scanItems)
			else
				pickupWithRemoteCrates()
			end
		end
		if cashEnabled then
			if pickupMethod == "Without Remote Event" then
				task.spawn(scanItems)
			else
				pickupWithRemoteMoney()
			end
		end
	end
})

MiscRight:AddDropdown('AutoBuyDropdown', {
	Values = (function()
		t = {}
		Shopz = game:GetService("Workspace").Map.Shopz
		if Shopz:FindFirstChild("Dealer") and Shopz.Dealer:FindFirstChild("CurrentStocks") then
			for _, v in ipairs(Shopz.Dealer.CurrentStocks:GetChildren()) do
				if v ~= game:GetService("Players").LocalPlayer and v.Name then
					table.insert(t, v.Name)
				end
			end
		end
		return #t > 0 and t or {"None"}
	end)(),
	Default = {},
	Multi = true,
	Text = 'Select AutoBuy Items',
	Callback = function(Value)
		if Toggles.AutoBuyToggle.Value then
			Dealer = GetDealer(math.huge, "Dealer")
			if Dealer then
				for item, enabled in pairs(Value) do
					if enabled then
						game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Melees", item, Dealer)
						game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item, Dealer)
						game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item, Dealer)
						game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item, Dealer)
						game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Melees", item, Dealer)
						game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Guns", item, Dealer)
						game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Throwables", item, Dealer)
						game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Misc", item, Dealer)
					end
				end
			end
		end
	end
})

Options.AutoBuyDropdown:OnChanged(function()
	if Toggles.AutoBuyToggle.Value then
		Dealer = GetDealer(math.huge, "Dealer")
		if Dealer then
			for item, enabled in pairs(Options.AutoBuyDropdown.Value) do
				if enabled then
					game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Melees", item, Dealer)
					game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item, Dealer)
					game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item, Dealer)
					game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item, Dealer)
					game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Melees", item, Dealer)
					game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Guns", item, Dealer)
					game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Throwables", item, Dealer)
					game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Misc", item, Dealer)
				end
			end
		end
	end
end)

MiscRight:AddDropdown('AutoSellDropdown', {
	Values = {"All", "Melees", "Guns", "Throwables", "Misc"},
	Default = {},
	Multi = true,
	Text = 'Select Categories to Sell',
	Callback = function(Value)
		if Toggles.AutoSellToggle.Value then
			Dealer = GetDealer(math.huge, "Dealer")
			if Dealer then
				for category, enabled in pairs(Value) do
					if enabled then
						for _, item in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
							if item:IsA("Tool") and item.Name ~= GetArmor() and item.Name ~= game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name then
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
								if category == "All" then
									game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
									game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
									game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
								end
							end
						end
						for _, item in ipairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
							if item:IsA("Tool") then
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
								if category == "All" then
									game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
									game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
									game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
								end
							end
						end
					end
				end
			end
		end
	end
})

Options.AutoSellDropdown:OnChanged(function()
	if Toggles.AutoSellToggle.Value then
		Dealer = GetDealer(math.huge, "Dealer")
		if Dealer then
			for category, enabled in pairs(Options.AutoSellDropdown.Value) do
				if enabled then
					for _, item in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
						if item:IsA("Tool") and item.Name ~= GetArmor() and item.Name ~= game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name then
							game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
							if category == "All" then
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
							end
						end
					end
					for _, item in ipairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
						if item:IsA("Tool") then
							game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
							if category == "All" then
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
								game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
							end
						end
					end
				end
			end
		end
	end
end)

MiscRight:AddSlider('AutoBreakDoorRange', {
	Text = 'Auto Break Door Range',
	Default = 0,
	Min = 0,
	Max = 15,
	Rounding = 0,
	Callback = function(Value)
		AutoBreakDoorRangeValue = Value
	end
})

MiscRight:AddSlider('AutoBreakSafeRange', {
	Text = 'Auto Break Safe Range',
	Default = 0,
	Min = 0,
	Max = 15,
	Rounding = 0,
	Callback = function(Value)
		AutoBreakSafeRangeValue = Value
	end
})

MiscRight:AddSlider('AutoBreakRegisterRange', {
	Text = 'Auto Break Register Range',
	Default = 0,
	Min = 0,
	Max = 15,
	Rounding = 0,
	Callback = function(Value)
		AutoBreakRegisterRangeValue = Value
	end
})

MiscRight:AddSlider('OpenDoorsDistance', {
	Text = "Open Doors Distance",
	Default = 1,
	Min = 1,
	Max = 15,
	Rounding = 0,
	Callback = function(Value)
		OpenDoorsDistance = Value
	end
})

MiscRight:AddSlider('UnlockDoorsDistance', {
	Text = "Unlock Doors Distance",
	Default = 1,
	Min = 1,
	Max = 15,
	Rounding = 0,
	Callback = function(Value)
		UnlockDoorsDistance = Value
	end
})

MiscRight:AddSlider('LockDoorsDistance', {
	Text = "Lock Doors Distance",
	Default = 1,
	Min = 1,
	Max = 15,
	Rounding = 0,
	Callback = function(Value)
		LockDoorsDistance = Value
	end
})

MiscRight:AddSlider('CloseDoorsDistance', {
	Text = "Close Doors Distance",
	Default = 1,
	Min = 1,
	Max = 15,
	Rounding = 0,
	Callback = function(Value)
		CloseDoorsDistance = Value
	end
})

MiscRight:AddSlider('AutoKnockDoorsDistance', {
	Text = "Knock Doors Distance",
	Default = 1,
	Min = 1,
	Max = 15,
	Rounding = 0,
	Callback = function(Value)
		AutoKnockDoorsDistance = Value
	end
})

MiscRight:AddSlider('AutoRepairSlider', {
	Text = 'Repair Range',
	Default = 0,
	Min = 0,
	Max = 10,
	Rounding = 1,
	Callback = function(Value)
		AutoRepairRange = Value
	end
})

MiscLeft2:AddButton({
	Text = "Anti-blur",
	Func = function()
		cameraFolder = workspace:FindFirstChild("Camera")
		if cameraFolder then
			for _, obj in pairs(cameraFolder:GetChildren()) do
				obj:Destroy()
			end
		end
	end
})

MiscLeft2:AddToggle('AntiSmokeToggle', {
	Text = "Anti-Smoke",
	Default = false,
	Callback = function(Value)
		_G.NoSmoke = Value

		game.Workspace.Debris.ChildAdded:Connect(function(Item)
			if Item.Name == "SmokeExplosion" and _G.NoSmoke then
				wait(0.1)
				if Item:FindFirstChild("Particle1") then
					Item.Particle1:Destroy()
				end
				if Item:FindFirstChild("Particle2") then
					Item.Particle2:Destroy()
				end
			end
		end)

		game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
			if Item.Name == "SmokeScreenGUI" and _G.NoSmoke then
				Item.Enabled = false
			end
		end)
	end
})

MiscLeft2:AddToggle('AntiFlashBangToggle', {
	Text = "Anti-Flash",
	Default = false,
	Callback = function(Value)
		_G.NoFlashBang = Value

		game.Workspace.Camera.ChildAdded:Connect(function(Item)
			if _G.NoFlashBang and Item.Name == "BlindEffect" then
				Item.Enabled = false
			end
		end)

		game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
			if _G.NoFlashBang and Item.Name == "FlashedGUI" then
				Item.Enabled = false
			end
		end)
	end
})

MiscLeft2:AddToggle('AntiOverlayToggle', {
	Text = "Anti-Overlay",
	Default = false,
	Callback = function(Value)
		_G.NoOverlay = Value
		game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
			if Item.Name == "OverlayGUI" then
				Item.Enabled = not _G.NoOverlay
			end
		end)
		if game.Players.LocalPlayer.PlayerGui:FindFirstChild("OverlayGUI") then
			game.Players.LocalPlayer.PlayerGui.OverlayGUI.Enabled = not _G.NoOverlay
		end
	end
})

Client = Players.LocalPlayer

MiscLeft2:AddToggle('NoVisorToggle', {
	Text = 'Anti Visor / Helmet',
	Default = false,
	Callback = function(Value)
		for _, GUI in pairs(Client.PlayerGui:GetDescendants()) do
			if GUI.Name == "HelmetOverlayGUI" then
				GUI.Enabled = not Value
				GUI:GetPropertyChangedSignal("Enabled"):Connect(function()
					if Value then
						GUI.Enabled = false
					end
				end)
			end
		end
	end
})

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Workspace = game:GetService("Workspace")
ReplicatedStorage = game:GetService("ReplicatedStorage")
UserInputService = game:GetService("UserInputService")
me = Players.LocalPlayer
event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("__RZDONL")
loopConnections = {}
tpActive = false
selectedPlayer = nil
targetPos = nil
customPos = nil

TeleportTargets = {
	Motel = Vector3.new(-4618.79932, 3.29673815, -903.594055),
	Cafe = Vector3.new(-4622.74414, 6.00001335, -259.846344),
	Tower = Vector3.new(-4460.875, 149.4496, -845.541138),
	Pizza = Vector3.new(-4404.69189, 5.19999599, -128.68782),
	Junkyard = Vector3.new(-3889.20801, 3.89897966, -507.586273),
	Subway = Vector3.new(-4719.51807, -32.2998962, -704.136169),
	VibeCheck = Vector3.new(-4777.06055, -200.964722, -965.857422),
	Mountain1 = Vector3.new(-4722.73145, 190.600052, -36.4695663),
	Mountain2 = Vector3.new(-4237.23779, 212.485321, -835.784119),
	Mountain3 = Vector3.new(-4145.39209, 200.522568, 160.654404),
	SaveCube = Vector3.new(-4184.4, 102.7, 276.9),
	SaveVibe = Vector3.new(-4857.5, -161.5, -918.3),
	SaveMount = Vector3.new(-5169.8, 102.6, -515.5)
}

function FindNearestTarget(targetType)
	hrp = me.Character and me.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	nearestTarget = nil
	minDistance = math.huge

	if targetType == "ATM" then
		for _, atm in pairs(Workspace.Map.ATMz:GetChildren()) do
			if atm:FindFirstChild("MainPart") then
				distance = (hrp.Position - atm.MainPart.Position).Magnitude
				if distance < minDistance then
					minDistance = distance
					nearestTarget = atm.MainPart
				end
			end
		end
	elseif targetType == "Dealer" then
		for _, shop in pairs(Workspace.Map.Shopz:GetChildren()) do
			if shop.Name ~= "ArmoryDealer" and shop:FindFirstChild("MainPart") then
				distance = (hrp.Position - shop.MainPart.Position).Magnitude
				if distance < minDistance then
					minDistance = distance
					nearestTarget = shop.MainPart
				end
			end
		end
	elseif targetType == "ArmoryDealer" then
		for _, shop in pairs(Workspace.Map.Shopz:GetChildren()) do
			if shop.Name == "ArmoryDealer" and shop:FindFirstChild("MainPart") then
				distance = (hrp.Position - shop.MainPart.Position).Magnitude
				if distance < minDistance then
					minDistance = distance
					nearestTarget = shop.MainPart
				end
			end
		end
	end
	return nearestTarget
end

function teleportToLocation(targetPosition, offsetDistance, targetType)
	hrp = me.Character and me.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		targetPart = FindNearestTarget(targetType)
		if targetPart and offsetDistance > 0 then
			forwardVector = targetPart.CFrame.LookVector
			hrp.CFrame = CFrame.new(targetPosition) + (forwardVector * offsetDistance)
		else
			hrp.CFrame = CFrame.new(targetPosition)
		end
		event:FireServer("__---r", Vector3.new(0, 0, 0), hrp.CFrame)
		hrp.CanCollide = false
		task.wait(0.001)
		hrp.CanCollide = true
	end
end

function CreateTeleportToggle(name, flag, targetType)
	MiscLeft3:AddToggle(flag, {
		Text = name,
		Default = false,
		Callback = function(Value)
			if Value then
				targetPos = nil
				offsetDistance = 0
				if targetType == "ATM" then
					target = FindNearestTarget("ATM")
					offsetDistance = 4
					targetPos = target and target.Position
				elseif targetType == "CreateXYZ" then
					targetPos = customPos
				elseif targetType == "Dealer" then
					target = FindNearestTarget("Dealer")
					offsetDistance = 3
					targetPos = target and target.Position
				elseif targetType == "ArmoryDealer" then
					target = FindNearestTarget("ArmoryDealer")
					offsetDistance = 8
					targetPos = target and target.Position
				else
					targetPos = TeleportTargets[targetType]
				end
				if targetPos then
					if loopConnections[flag] then
						loopConnections[flag]:Disconnect()
					end
					loopConnections[flag] = RunService.RenderStepped:Connect(function()
						if Toggles[flag].Value and targetPos then
							teleportToLocation(targetPos, offsetDistance, targetType)
						else
							loopConnections[flag]:Disconnect()
							loopConnections[flag] = nil
						end
					end)
				end
			end
		end
	})
end

CreateTeleportToggle("Teleport to ATM", "TP_ATM", "ATM")
CreateTeleportToggle("Teleport to Dealer", "TP_Dealer", "Dealer")
CreateTeleportToggle("Teleport to Armory Dealer", "TP_ArmoryDealer", "ArmoryDealer")
CreateTeleportToggle("Teleport to Motel", "TP_Motel", "Motel")
CreateTeleportToggle("Teleport to Cafe", "TP_Cafe", "Cafe")
CreateTeleportToggle("Teleport to Tower", "TP_Tower", "Tower")
CreateTeleportToggle("Teleport to Pizza", "TP_Pizza", "Pizza")
CreateTeleportToggle("Teleport to Junkyard", "TP_Junkyard", "Junkyard")
CreateTeleportToggle("Teleport to Subway", "TP_Subway", "Subway")
CreateTeleportToggle("Teleport to Vibe Check", "TP_VibeCheck", "VibeCheck")
CreateTeleportToggle("Teleport to Mountain 1", "TP_Mountain1", "Mountain1")
CreateTeleportToggle("Teleport to Mountain 2", "TP_Mountain2", "Mountain2")
CreateTeleportToggle("Teleport to Mountain 3", "TP_Mountain3", "Mountain3")
CreateTeleportToggle("Teleport to Save Cube", "TP_SaveCube", "SaveCube")
CreateTeleportToggle("Teleport to Save Vibe", "TP_SaveVibe", "SaveVibe")
CreateTeleportToggle("Teleport to Save Mount", "TP_SaveMount", "SaveMount")
CreateTeleportToggle("Teleport to Custom XYZ", "TP_CustomXYZ", "CreateXYZ")
MiscLeft3:AddInput("CustomXYZ", {
	Text = "Custom XYZ",
	Default = "0, 0, 0",
	Placeholder = "x, y, z",
	Callback = function(Value)
		x, y, z = Value:match("(%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)")
		if x and y and z then
			customPos = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
		end
	end
})

antiAimEnabled = false
antiAimSpeed = 1
headTiltEnabled = false
headTiltDirection = "Up"
yawOffset = 0
spinDirection = 1

MiscLeft4:AddToggle('EnableAntiAim', {
	Text = 'Anti-Aim',
	Default = false,
	Callback = function(Value) 
		antiAimEnabled = Value 
		if not Value and head and head:FindFirstChild("HeadWeld") then
			head.HeadWeld:Destroy()
		end
	end
})

MiscLeft4:AddToggle('EnableHeadTilt', {
	Text = 'Head Tilt',
	Default = false,
	Callback = function(Value) 
		headTiltEnabled = Value 
		if not Value and head and head:FindFirstChild("HeadWeld") then
			head.HeadWeld.C1 = CFrame.new(0, 0.5, 0)
		end
	end
})

MiscLeft4:AddDropdown('HeadTiltDirection', {
	Values = {'Up', 'Down'},
	Default = 1,
	Multi = false,
	Text = 'Head Tilt Direction',
	Callback = function(Value) headTiltDirection = Value end
})

MiscLeft4:AddSlider('AntiAimSpeed', {
	Text = 'Anti-Aim Speed',
	Default = 1,
	Min = 0.1,
	Max = 5,
	Rounding = 1,
	Compact = false,
	Callback = function(Value) antiAimSpeed = Value end
})

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	if not antiAimEnabled or not game:GetService("Players").LocalPlayer.Character or not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return
	end
	hrp = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
	head = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Head")

	yawOffset = yawOffset + (antiAimSpeed * deltaTime * 360 * spinDirection)
	if math.abs(yawOffset) >= 180 then
		spinDirection = -spinDirection
		yawOffset = math.clamp(yawOffset, -180, 180)
	end
	hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(yawOffset + math.sin(os.clock() * antiAimSpeed * 5) * 45), 0)

	if head and headTiltEnabled and not head:FindFirstChild("HeadWeld") then
		weld = Instance.new("Weld")
		weld.Name = "HeadWeld"
		weld.Part0 = hrp
		weld.Part1 = head
		weld.C0 = CFrame.new(0, 1.5, 0)
		weld.Parent = head
	end

	if head and head:FindFirstChild("HeadWeld") then
		if headTiltEnabled then
			if headTiltDirection == "Up" then
				head.HeadWeld.C1 = CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
			elseif headTiltDirection == "Down" then
				head.HeadWeld.C1 = CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
			end
		else
			head.HeadWeld.C1 = CFrame.new(0, 0.5, 0)
		end
	end
end)

MiscRight3:AddButton({
	Text = 'Toggle Vibecheck Elevator',
	Func = function()
		Knob = Workspace.Map.Doors.Elevator_28.Knob1
		Client = game:GetService("Players").LocalPlayer
		if Client.Character then
			Client.Character.HumanoidRootPart.CFrame = Knob.CFrame
			Prompt = Knob:WaitForChild("ProximityPrompt")
			task.wait(0.05)
			for Index = 1, 10 do 
				fireproximityprompt(Prompt)
			end
		end
	end
})

function createBendoverTool()
	SleepTool = Instance.new("Tool")
	SleepTool.Name = "Bend Over\nOff"
	SleepTool.RequiresHandle = false
	SleepTool.ToolTip = "Bend Over"

	b = {}
	c = {}
	_ = {
		ID = 0;
		Type = "Animation";
		Properties = {
			Name = "Sleep";
			AnimationId = "http://www.roblox.com/asset/?id=4686925579"
		};
		Children = {
			{ID = 1; Type = "NumberValue"; Properties = {Name = "ThumbnailBundleId"; Value = 515}; Children = {}};
			{ID = 2; Type = "NumberValue"; Properties = {Name = "ThumbnailKeyframe"; Value = 13}; Children = {}};
			{ID = 3; Type = "NumberValue"; Properties = {Name = "ThumbnailZoom"; Value = 1.1576576576577}; Children = {}};
			{ID = 4; Type = "NumberValue"; Properties = {Name = "ThumbnailHorizontalOffset"; Value = -0.0025025025025025}; Children = {}};
			{ID = 5; Type = "NumberValue"; Properties = {Name = "ThumbnailVerticalOffset"; Value = -0.0025025025025025}; Children = {}};
			{ID = 6; Type = "NumberValue"; Properties = {Name = "ThumbnailCharacterRotation"}; Children = {}}
		}
	}

	function a(d, parent)
		e = Instance.new(d.Type)
		if d.ID then
			temp = c[d.ID]
			if temp then
				temp[1][temp[2]] = e
				c[d.ID] = nil
			else
				b[d.ID] = e
			end
		end
		for prop, val in pairs(d.Properties) do
			if type(val) == "string" then
				id = tonumber(val:match("^_R:(%w+)_$"))
				if id then
					if b[id] then
						val = b[id]
					else
						c[id] = {e, prop}
						val = nil
					end
				end
			end
			e[prop] = val
		end
		for _, child in pairs(d.Children) do
			a(child, e)
		end
		e.Parent = parent
		return e
	end

	create = a

	savedAnimate = nil
	activeTrack = nil
	isPlaying = false

	function getCharacterAndHumanoid()
		player = game:GetService("Players").LocalPlayer
		character = player.Character
		if not character then return nil, nil end
		humanoid = character:FindFirstChildOfClass("Humanoid")
		return character, humanoid
	end

	function playBendOverAnimation()
		character, humanoid = getCharacterAndHumanoid()
		if not character or not humanoid then return end
		SleepTool.Name = "Bend Over\nOn"
		if character:FindFirstChild("Animate") then
			savedAnimate = character.Animate:Clone()
		end
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			animation = create(_, nil)
			animate = character:WaitForChild("Animate")
			bindable = animate:WaitForChild("PlayEmote")
			bindable:Invoke(animation)
			task.spawn(function()
				task.wait(0.1)
				for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do 
					if track.Animation.AnimationId:match("4686925579") then 
						track:AdjustSpeed(0)
						activeTrack = track
						break 
					end
				end
			end)
			task.wait(0.3)
			if character:FindFirstChild("Animate") then
				character.Animate:Destroy()
			end
		else
			animation = Instance.new("Animation")
			animation.AnimationId = "rbxassetid://189854234"
			activeTrack = humanoid:LoadAnimation(animation)
			activeTrack:Play()
			task.wait(0.3)
			activeTrack:AdjustSpeed(0)
		end
		isPlaying = true
	end

	function restoreOriginalAnimation()
		character, humanoid = getCharacterAndHumanoid()
		if not character then return end
		SleepTool.Name = "Bend Over\nOff"
		if activeTrack then
			activeTrack:Stop()
			activeTrack = nil
		end
		if savedAnimate and character then
			oldAnimate = character:FindFirstChild("Animate")
			if oldAnimate then
				oldAnimate:Destroy()
			end
			newAnimate = savedAnimate:Clone()
			newAnimate.Parent = character
			savedAnimate = nil
		end
		isPlaying = false
	end

	SleepTool.Equipped:Connect(function()
		if not isPlaying then
			pcall(playBendOverAnimation)
		end
	end)

	SleepTool.Unequipped:Connect(function()
		if isPlaying then
			pcall(restoreOriginalAnimation)
		end
	end)

	game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
		savedAnimate = nil
		activeTrack = nil
		isPlaying = false
		SleepTool.Name = "Bend Over\nOff"
	end)

	return SleepTool
end

function createHugTool()
	HugTool = Instance.new("Tool")
	HugTool.Name = "Hug Tool\nOff"
	HugTool.RequiresHandle = false
	HugTool.ToolTip = "Hug Tool R6"

	HugTool.Equipped:Connect(function()
		HugTool.Name = "Hug Tool\nOn"
		Anim_1 = Instance.new("Animation")
		Anim_1.AnimationId = "rbxassetid://283545583"
		Play_1 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim_1)
		Anim_2 = Instance.new("Animation")
		Anim_2.AnimationId = "rbxassetid://225975820"
		Play_2 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim_2)
		Play_1:Play()
		Play_2:Play()
	end)

	HugTool.Unequipped:Connect(function()
		HugTool.Name = "Hug Tool\nOff"
		if Play_1 then Play_1:Stop() end
		if Play_2 then Play_2:Stop() end
	end)

	return HugTool
end

function createJerkTool()
	speaker = game.Players.LocalPlayer
	humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
	backpack = speaker:FindFirstChildWhichIsA("Backpack")
	if not humanoid or not backpack then return end

	tool = Instance.new("Tool")
	tool.Name = "Jerk Off"
	tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's just say. My peanits."
	tool.RequiresHandle = false

	jorkin = false
	track = nil

	function r15()
		return speaker.Character.Humanoid.RigType == Enum.HumanoidRigType.R15
	end

	function stopTomfoolery()
		jorkin = false
		if track then
			track:Stop()
			track = nil
		end
	end

	tool.Equipped:Connect(function() jorkin = true end)
	tool.Unequipped:Connect(stopTomfoolery)
	humanoid.Died:Connect(stopTomfoolery)

	task.spawn(function()
		while true do
			task.wait()
			if not jorkin then continue end
			isR15 = r15()
			if not track then
				anim = Instance.new("Animation")
				anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
				track = humanoid:LoadAnimation(anim)
			end
			track:Play()
			track:AdjustSpeed(isR15 and 0.7 or 0.65)
			track.TimePosition = 0.6
			task.wait(0.1)
			while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
			if track then
				track:Stop()
				track = nil
			end
		end
	end)

	return tool
end

tools = {}

MiscRight3:AddToggle('BendoverToggle', {
	Text = 'Bendover Tool',
	Default = false,
	Callback = function(Value)
		if Value then
			tools.Bendover = createBendoverTool()
			tools.Bendover.Parent = game.Players.LocalPlayer.Backpack
		else
			if tools.Bendover then
				tools.Bendover:Destroy()
				tools.Bendover = nil
			end
		end
	end
})

MiscRight3:AddToggle('HugToggle', {
	Text = 'Hug Tool',
	Default = false,
	Callback = function(Value)
		if Value then
			tools.Hug = createHugTool()
			tools.Hug.Parent = game.Players.LocalPlayer.Backpack
		else
			if tools.Hug then
				tools.Hug:Destroy()
				tools.Hug = nil
			end
		end
	end
})

MiscRight3:AddToggle('JerkToggle', {
	Text = 'Jerk Tool',
	Default = false,
	Callback = function(Value)
		if Value then
			tools.Jerk = createJerkTool()
			if tools.Jerk then
				tools.Jerk.Parent = game.Players.LocalPlayer.Backpack
			end
		else
			if tools.Jerk then
				tools.Jerk:Destroy()
				tools.Jerk = nil
			end
		end
	end
})

Animations = {
	["Fake-BlindAnim"] = "14694544863",
	["Fake-Crounch"] = "14694501365",
	["Fake-OpenLoop"] = "14694544925",
	["Fake-PSlide"] = "12323412326",
	["TorzoFreeze"] = "13084367111",
	["Carpet"] = "282574440",
	["Fake-DoorHit"] = "14894406295",
	["Fake-Finish"] = "14894394657",
	["Dance4"] = "14849677565",
	["Dance5"] = "14849684060",
	["Dance6"] = "14849689388",
	["Sit"] = "14849671564"
}

Tracks = {}

function PlayAnimation(animationId)
	plr = game.Players.LocalPlayer
	char = plr.Character or plr.CharacterAdded:Wait()
	hum = char and char:FindFirstChildOfClass("Humanoid")

	if hum then
		animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
		animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. animationId
		track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
		track:Play()
		return track
	end
end

for name, id in pairs(Animations) do
	Tracks[id] = nil
	MiscRight2:AddToggle('Anim' .. name, {
		Text = name,
		Default = false,
		Callback = function(Value)
			if Value then
				if not Tracks[id] then
					Tracks[id] = PlayAnimation(id)
				end
			else
				if Tracks[id] then
					Tracks[id]:Stop()
					Tracks[id] = nil
				end
			end
		end
	})
end

player = game.Players.LocalPlayer
charStats = game:GetService("ReplicatedStorage").CharStats

MiscRight2:AddToggle('FakeDowned', {
	Text = 'Fake-Downed',
	Default = false,
	Callback = function(Value)
		charStats[player.Name].Downed.Value = Value
	end
})

charStats[player.Name].Changed:Connect(function()
	if not charStats:FindFirstChild(player.Name) then
		charStats.ChildAdded:Wait()
	end
	Toggles.FakeDowned:SetValue(Toggles.FakeDowned.Value)
end)

player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid").Died:Connect(function()
		charStats.ChildAdded:Wait()
		Toggles.FakeDowned:SetValue(Toggles.FakeDowned.Value)
	end)
end)

Messages = {
	SteelHub = {
		"SteelHub vibes! Dominate with style!",
		"Unleash chaos with SteelHub power!",
		"Top-tier gameplay? SteelHub way!",
		"Crush it with SteelHub magic!",
		"SteelHub hype! Rule the game!",
		"Stay ahead with SteelHub elite!",
		"Game just got better! SteelHub zone!",
		"SteelHub flow! Outplay everyone!",
		"Be a legend with SteelHub rise!",
		"Own the game with SteelHub energy!",
		"SteelHub squad! Lead the pack!",
		"Pros choose SteelHub glory!",
		"Level up your game! SteelHub fire!",
		"SteelHub rush! Make every moment count!",
		"Master the game with SteelHub skill!",
		"No one stops SteelHub!",
		"Game’s finest? That’s SteelHub!",
		"SteelHub spark! Ignite your run!",
		"Play smarter with SteelHub edge!",
		"Domination starts with SteelHub!"
	},
	Russian = {
		"Я в игре, и это уже победа!",
		"Кто тут главный? Очевидно я!",
		"Играю так, что все в шоке!",
		"Это мой момент, не мешайте!",
		"Смотрите и учитесь, новички!",
		"Я в деле, и это чувствуется!",
		"Геймплей на миллион, как всегда!",
		"Кто хочет попробовать? Го!",
		"Я тут, чтобы всех удивить!",
		"Игра идет, а я на волне!",
		"Мой вайб в игре непобедим!",
		"Кто следующий? Я готов!",
		"Играю, как будто это финал!",
		"Все смотрят на меня, и не зря!",
		"Я в игре, и это шоу!",
		"Кто может лучше? Никто!",
		"Мой стиль в игре? Безупречно!",
		"Игра кипит, а я на вершине!",
		"Я тут, чтобы зажечь!",
		"Геймплей? Я его определяю!",
		"Я рулю в этой игре, попробуй догони!",
		"Мои скиллы просто огонь, держись!",
		"В игре я король, без вопросов!",
		"Мой вайб — это чистый взрыв!",
		"Я здесь, чтобы доминировать!",
		"Играю так, что все завидуют!",
		"Мой стиль не повторить, учись!",
		"Я в игре, и это эпик!",
		"Кто хочет бросить вызов? Я жду!",
		"Мои мувы — это чистое золото!",
		"Я задаю тон в этой игре!",
		"Играю, как профи, без шансов!",
		"Мой геймплей — это легенда!",
		"Я в игре, и это мой трон!",
		"Кто может тягаться? Никто!",
		"Мои скиллы сияют ярче всех!",
		"Я здесь, чтобы всех порвать!",
		"Игра кипит, а я на пике!",
		"Мой вайб — это чистый адреналин!",
		"Я играю, как будто это кино!",
		"Мои мувы — это чистый класс!",
		"Я в игре, и это мой мир!",
		"Кто следующий? Я уже готов!",
		"Мой стиль в игре — это шедевр!",
		"Играю так, что все в агонии!",
		"Я здесь, чтобы всех удивить!",
		"Мой геймплей — это чистый флекс!",
		"Я рулю, а вы лишь смотрите!",
		"Мои скиллы — это чистый взрыв!",
		"Я в игре, и это мой спектакль!",
		"Кто хочет попробовать? Вперед!",
		"Мой стиль — это чистая магия!",
		"Я играю, как будто я босс!",
		"Мои мувы — это чистый вайб!",
		"Я здесь, чтобы всех затмить!",
		"Играю так, что все в восторге!",
		"Мой геймплей — это чистый шик!",
		"Я в игре, и это мой момент!",
		"Кто может лучше? Да никто!",
		"Мои скиллы — это чистый огонь!",
		"Я здесь, чтобы всех разнести!",
		"Игра кипит, а я на волне!",
		"Мой вайб — это чистый триумф!",
		"Я играю, как будто я звезда!",
		"Мои мувы — это чистый фокус!",
		"Я в игре, и это мой путь!",
		"Кто следующий? Я наготове!",
		"Мой стиль — это чистый блеск!",
		"Играю так, что все в шоке!",
		"Мой геймплей — это чистый хайп!",
		"Я рулю, а вы лишь мечтаете!",
		"Мои скиллы — это чистый класс!",
		"Я в игре, и это мой пик!",
		"Кто хочет вызов? Я здесь!",
		"Мой стиль — это чистый вайб!",
		"Я играю, как будто я легенда!",
		"Мои мувы — это чистый триумф!",
		"Я здесь, чтобы всех покорить!",
		"Играю так, что все в ауте!",
		"Мой геймплей — это чистый фейерверк!",
		"Я в игре, и это мой трон!",
		"Кто может тягаться? Никто!",
		"Мои скиллы — это чистый космос!",
		"Я здесь, чтобы всех взорвать!"
	},
	English = {
		"I’m in the game, and it’s already a win!",
		"Who’s the boss? Yeah, that’s me!",
		"Playing so good, everyone’s stunned!",
		"This is my time, don’t interrupt!",
		"Watch and learn, newbies!",
		"I’m here, and it’s a vibe!",
		"Gameplay’s on point, as usual!",
		"Who wants a challenge? Let’s go!",
		"I’m here to steal the show!",
		"Game’s on, and I’m riding the wave!",
		"My vibe in game? Unbeatable!",
		"Who’s next? I’m ready!",
		"Playing like it’s the grand final!",
		"All eyes on me, and for good reason!",
		"I’m in, and it’s a spectacle!",
		"Who can top this? No one!",
		"My game style? Flawless!",
		"Game’s heating up, and I’m on top!",
		"I’m here to light it up!",
		"Gameplay? I’m setting the standard!",
		"I’m running this game, catch up!",
		"My skills are pure fire, watch out!",
		"I’m the king of this game, no doubt!",
		"My vibe’s a total explosion!",
		"I’m here to dominate, step up!",
		"Playing so good, they’re jealous!",
		"My style’s untouchable, learn it!",
		"I’m in the game, and it’s epic!",
		"Who wants to test me? I’m ready!",
		"My moves are straight gold!",
		"I’m setting the pace in this game!",
		"Playing like a pro, no contest!",
		"My gameplay’s a legend already!",
		"I’m in, and this is my throne!",
		"Who can match me? Nobody!",
		"My skills shine brighter than all!",
		"I’m here to crush it, watch me!",
		"Game’s on fire, and I’m the spark!",
		"My vibe’s pure adrenaline rush!",
		"I’m playing like it’s a movie!",
		"My moves are pure class, see it!",
		"I’m in the game, and it’s my world!",
		"Who’s next? I’m locked and loaded!",
		"My style’s a masterpiece, study it!",
		"Playing so good, they’re shook!",
		"My gameplay’s pure hype, feel it!",
		"I’m running the show, just watch!",
		"My skills are a total blast!",
		"I’m in, and it’s my stage!",
		"Who wants a shot? I’m waiting!",
		"My style’s pure magic, behold!",
		"I’m playing like I’m the boss!",
		"My moves are pure vibe, catch it!",
		"I’m here to outshine everyone!",
		"Playing so good, they’re stunned!",
		"My gameplay’s pure flair, see it!",
		"I’m in the game, and it’s my time!",
		"Who can do better? No one!",
		"My skills are pure heat, feel it!",
		"I’m here to wreck it, let’s go!",
		"Game’s alive, and I’m the pulse!",
		"My vibe’s a total triumph!",
		"I’m playing like a superstar!",
		"My moves are pure focus, watch!",
		"I’m in, and it’s my journey!",
		"Who’s up next? I’m prepped!",
		"My style’s pure shine, check it!",
		"Playing so good, it’s unreal!",
		"My gameplay’s a total banger!",
		"I’m ruling, and you’re just dreaming!",
		"My skills are pure class, own it!",
		"I’m in the game, and it’s my peak!",
		"Who wants a challenge? I’m here!",
		"My style’s pure vibe, feel it!",
		"I’m playing like I’m a legend!",
		"My moves are pure victory!",
		"I’m here to conquer it all!",
		"Playing so good, they’re out!",
		"My gameplay’s a pure fireworks show!",
		"I’m in, and it’s my crown!",
		"Who can compete? Nobody!",
		"My skills are pure cosmos!",
		"I’m here to blow it up!"
	},
	TrashTalk = {
		English = {
			"GET GOOD HOLY",
			"WOW LOL YOURE ACTUALLY SO TRASH",
			"I CANT BELIEVE THATS YOUR AIM",
			"AINT A WAY YOU AIM LIKE THAT LOOOOOOL",
			"MY GRANDMA CAN AIM BETTER THAN THAT LOOOOOOOOOOOOOL",
			"WOW, I STARTED TO FALL ASLEEP YOURE SO BAD",
			"Bro, your aim’s so lame it hurts to watch!",
			"Your moves are so weak I’m falling asleep!",
			"You’re playing like a noob who just spawned!",
			"Did you even try to aim or just give up?",
			"Your skills are so boring I’m zoning out!",
			"Bro, my pet fish could dodge better!",
			"You’re moving like a sleepy turtle!",
			"That was your best move? I’m laughing!",
			"Your gameplay’s so weak it’s painful!",
			"Bro, you’re playing like a lost newbie!",
			"Your aim’s so off it’s a total joke!",
			"You’re out here flopping every second!",
			"Did you aim at the clouds for fun?",
			"Your moves are so lame I’m yawning!",
			"Bro, my cat could play better than you!",
			"You’re so weak it’s almost funny!",
			"Your skills are napping on the job!",
			"You’re playing like you forgot the keys!",
			"Bro, that move was pure nonsense!",
			"Your aim’s so bad it’s a world record!",
			"You’re moving like a stuck robot!",
			"Did you learn to play from a brick?",
			"Your gameplay’s so dull I’m nodding off!",
			"Bro, you’re the king of weak plays!",
			"You’re out here missing every shot!",
			"Your aim’s like a broken compass!",
			"You’re playing like a confused bot!",
			"Bro, my lamp could aim better!",
			"Your moves are a total snooze!",
			"You’re so slow I forgot you’re here!",
			"Did you aim at the floor or what?",
			"Your gameplay’s a complete mess!",
			"Bro, you’re the champ of lame moves!",
			"You’re playing like you’re half asleep!",
			"Your skills are lost in the dark!",
			"You’re out here failing every chance!",
			"Bro, my chair could dodge better!",
			"Your aim’s so weak it’s a comedy!",
			"You’re moving like a frozen snail!",
			"Did you trip over your own skills?",
			"Your gameplay’s a total flop show!",
			"Bro, you’re playing like a rookie!",
			"Your moves are pure chaos, not good!",
			"You’re so bad it’s kinda hilarious!",
			"Bro, my toaster could play better!",
			"Your aim’s so off it’s a mystery!",
			"You’re playing like a lagging noob!",
			"Did you forget how to move or what?",
			"Your gameplay’s a walking disaster!",
			"Bro, you’re the master of weak plays!",
			"You’re out here fumbling every move!",
			"Your aim’s so lame it’s iconic!",
			"You’re moving like a tired sloth!",
			"Bro, that was a legendary flop!",
			"Your skills are hiding in a void!",
			"You’re playing like you just started!",
			"Did you aim at the sky for laughs?",
			"Your gameplay’s a pure trainwreck!",
			"Bro, my pillow could aim better!",
			"You’re so weak it’s almost epic!",
			"Your moves are a big facepalm!",
			"You’re out here losing with flair!",
			"Bro, you’re playing like a sleepy bot!",
			"Your aim’s so bad it’s historic!",
			"Did you learn to play from a rock?",
			"Your gameplay’s making me dizzy!",
			"Bro, you’re the emperor of flops!",
			"You’re moving like a broken toy!",
			"Your aim’s so weak it’s a myth!",
			"You’re playing like a total newbie!",
			"Bro, my fridge could dodge better!",
			"Your moves are a complete oof!",
			"You’re so bad it’s almost art!",
			"Did you aim at the moon for fun?",
			"Your gameplay’s a total wipeout!",
			"Bro, you’re the king of noob plays!",
			"You’re out here missing with style!",
			"Your aim’s so off it’s unreal!",
			"You’re playing like a confused noob!",
			"Bro, that move was pure chaos!",
			"Your skills are stuck in a loop!",
			"You’re moving like a lazy zombie!",
			"Did you forget the game controls?",
			"Your gameplay’s a total yawn!",
			"Bro, my table could play better!",
			"You’re so weak it’s a spectacle!",
			"Your aim’s like a wild guess!",
			"You’re playing like you’re lost!",
			"Bro, you’re the champ of fails!",
			"Your moves are a total blur!",
			"You’re out here flopping hard!",
			"Did you aim at nothing or what?",
			"Your gameplay’s a pure meltdown!",
			"Bro, my shoe could aim better!",
			"You’re so bad it’s a legend!",
			"Your aim’s so weak it’s a farce!",
			"You’re playing like a sleepy rookie!",
			"Bro, that was a massive whiff!",
			"Your skills are nowhere to be found!",
			"You’re out here failing with gusto!",
			"Did you trip on your own moves?",
			"Your gameplay’s a complete bust!",
			"Bro, my rug could dodge better!",
			"You’re moving like a stuck wheel!",
			"Your aim’s so bad it’s a saga!",
			"You’re playing like a dazed bot!",
			"Bro, you’re the lord of weak plays!",
			"Your moves are a total letdown!",
			"You’re so bad it’s almost cool!",
			"Did you aim at the stars or what?",
			"Your gameplay’s a pure fiasco!",
			"Bro, my cup could play better!",
			"You’re out here losing every round!",
			"Your aim’s so lame it’s a tale!",
			"You’re playing like a noob in panic!",
			"Bro, that move was a total dud!",
			"Your skills are asleep at the wheel!",
			"You’re moving like a rusty gear!",
			"Did you forget how to aim or what?",
			"Your gameplay’s a complete haze!",
			"Bro, my sock could aim better!",
			"You’re so weak it’s a masterpiece!",
			"Your aim’s like a broken radar!",
			"You’re playing like a baffled noob!",
			"Bro, you’re the prince of flops!",
			"Your moves are a total washout!",
			"You’re out here failing in style!",
			"Did you aim at the void for kicks?",
			"Your gameplay’s a pure calamity!",
			"Bro, my hat could dodge better!",
			"You’re so bad it’s a phenomenon!",
			"Your aim’s so weak it’s a story!",
			"You’re playing like a zoned-out bot!",
			"Bro, that was a colossal miss!",
			"Your skills are lost in the mist!",
			"You’re out here flopping with flair!",
			"Did you trip over your own aim?",
			"Your gameplay’s a total shambles!",
			"Bro, my pen could play better!",
			"You’re moving like a sleepy ghost!",
			"Your aim’s so bad it’s a chronicle!",
			"You’re playing like a rookie in shock!",
			"Bro, you’re the duke of weak plays!",
			"Your moves are a complete flop!",
			"You’re so bad it’s almost mythic!",
			"Did you aim at the ground for fun?",
			"Your gameplay’s a pure disaster!",
			"Bro, my spoon could aim better!",
			"You’re out here losing with gusto!",
			"Your aim’s so lame it’s a legend!",
			"You’re playing like a clueless bot!",
			"Bro, that move was a total bust!",
			"Your skills are stuck in the mud!",
			"You’re moving like a tired bot!",
			"Did you forget the game or what?",
			"Your gameplay’s a complete blur!",
			"Bro, my book could dodge better!"
		},
		Russian = {
			"Серьезно, это твой прицел? Ха!",
			"Бро, мой хомяк быстрее бегает!",
			"Ты забыл, как играть, или что?",
			"Твои скиллы где-то в отпуске!",
			"Боты и то лучше играют!",
			"Ты вообще стараешься или троллишь?",
			"Мой младший брат тебя уделает!",
			"Это твой лучший выстрел? Скука!",
			"Твой геймплей? Спящий режим!",
			"Твой прицел как у штурмовика!",
			"Сказал бы 'хорошая попытка', но нет!",
			"Твои движения такие предсказуемые!",
			"Бро, удали игру, спаси нас!",
			"Даже мой вайфай играет лучше!",
			"Ты играешь, будто без пальцев!",
			"Мой пёс лучше уклоняется!",
			"Это твой план? Я ржу!",
			"Ты движешься, как статуя!",
			"Ты с закрытыми глазами целишься?",
			"Твой геймплей — это кринж!",
			"Бро, ты делаешь это слишком легко!",
			"Какая отмазка теперь? Лаги?",
			"Ты так слаб, я устал смотреть!",
			"Ты играешь, как сломанный джойстик!",
			"Моя рыбка лучше целится!",
			"Твой мув — это просто зевота!",
			"Ты тонешь в игре, как в болоте!",
			"Ты учишься промахиваться или как?",
			"Твои скиллы застряли на старте!",
			"Я ржу с твоего прицела!",
			"Бро, ты как мем с фейлами!",
			"Это игра? Нет, это твой сон!",
			"Твой прицел — это комедия!",
			"Даже картошка лучше играет!",
			"Ты как в клею застрял!",
			"Бро, это мастер-класс по промахам!",
			"Твой геймплей — сплошная скука!",
			"Ты учишься играть у тостера?",
			"Ты так медленный, я тебя забыл!",
			"Твой прицел — это головная боль!",
			"Бро, ты король плохих мувов!",
			"Твои скиллы в вечном отпуске!",
			"Мне скучно смотреть на твой фейл!",
			"Ты играешь, как в первый раз!",
			"Бро, твой прицел — это анекдот!",
			"Ты спотыкаешься на пустом месте!",
			"Ты в небо целишься специально?",
			"Твой геймплей — это катастрофа!",
			"Мой кот тебя переиграет!",
			"Ты так слаб, это почти искусство!",
			"Бро, твой фейл войдет в историю!",
			"Ты играешь, как полусонный!",
			"Твой прицел — это легенда!",
			"Твой прицел как в тумане!",
			"Бро, ты играешь, как ржавый бот!",
			"Твои мувы — полный краш!",
			"Ты вообще читал управление?",
			"Твой прицел такой слабый, я в шоке!",
			"Бро, ты чемпион по промахам!",
			"Это твой план? Сплошной провал!",
			"Ты движешься, как сонная черепаха!",
			"Твой геймплей — это тоска, проснись!",
			"Бро, ты аллергик на победы!",
			"Твой прицел — это просто рандом!",
			"Ты играешь, как потерянный нуб!",
			"Ты споткнулся о свои скиллы?",
			"Твои мувы — это сплошной ржач!",
			"Бро, ты застрял в режиме фейла!",
			"Твой прицел такой плохой, это классика!",
			"Ты играешь, будто наобум!",
			"Твой геймплей — это хаос, ооф!",
			"Бро, мой улитка тебя обгонит!",
			"Ты так слаб, это даже смешно!",
			"Твой прицел уже сдался!",
			"Ты забыл, для чего кнопки?",
			"Ты играешь, как лагающий бот!",
			"Бро, это был курс по фейлам!",
			"Твои мувы — хаос, но не крутой!",
			"Ты фейлишь с особым шиком!",
			"Твой прицел не знает, куда целиться!",
			"Бро, ты мастер задыхаться на старте!",
			"Ты играешь, как с завязанными глазами!",
			"Твои скиллы улетели в космос!",
			"Бро, моя лампа лучше играет!",
			"Ты движешься, как замороженный сок!",
			"Твой прицел — это мировой рекорд фейлов!",
			"Бро, ты играешь, как сонный зомби!",
			"Твои мувы — это поездка в никуда!",
			"Ты фейлишь каждую секунду!",
			"Ты целишься в пол для прикола?",
			"Твой геймплей — это шоу клоунов!",
			"Бро, мой стул лучше уклоняется!",
			"Ты так слаб, это почти круто!",
			"Твой прицел — как сломанный компас!",
			"Ты играешь, как растерянный бот!",
			"Бро, этот мув был просто бред!",
			"Твои скиллы спят на работе!",
			"Ты промахиваешься каждую минуту!",
			"Ты учишься играть у камня?",
			"Твой геймплей кружит голову!",
			"Бро, ты император фейлов!",
			"Ты движешься, как робот без батареек!",
			"Твой прицел — это сплошная загадка!",
			"Ты играешь, как новичок в панике!",
			"Бро, мой холодильник лучше целится!",
			"Твои мувы — это сплошной фейспалм!",
			"Ты проигрываешь с особым стилем!",
			"Ты целишься в луну или как?",
			"Твой геймплей — это ходячий ооф!",
			"Бро, ты мастер эпичных провалов!",
			"Ты играешь, как в странном сне!",
			"Твой прицел — это исторический фейл!",
			"Ты движешься, как уставшая улитка!",
			"Бро, это был легендарный промах!",
			"Твои скиллы прячутся во тьме!",
			"Ты играешь, как нуб наобум!",
			"Ты забыл, как двигаться, или что?",
			"Твой геймплей — это полный вынос!",
			"Бро, моя подушка лучше играет!",
			"Ты играешь, как на автопилоте!",
			"Твой прицел — это просто миф!",
			"Бро, ты застрял в прошлом веке!",
			"Твои мувы — это сплошной лол!",
			"Ты фейлишь, как настоящий профи!",
			"Твой прицел тонет в болоте!",
			"Бро, ты играешь, как в замедленке!",
			"Твои скиллы ушли в спячку!",
			"Ты промахнулся в миллионный раз!",
			"Ты учишься у чайника играть?",
			"Твой геймплей — это сплошной ржач!",
			"Бро, ты король эпичных фейлов!",
			"Ты движешься, как ленивый кот!",
			"Твой прицел — это чистый анриал!",
			"Ты играешь, как в параллельной реальности!",
			"Бро, мой кактус лучше целится!",
			"Твои мувы — это полный абсурд!",
			"Ты проигрываешь с особым шармом!",
			"Ты целишься в другую игру или что?",
			"Твой геймплей — это мемный фейл!",
			"Бро, ты чемпион по лузам!",
			"Ты играешь, как в полусне!",
			"Твой прицел — это сплошной трэш!",
			"Ты движешься, как сонный мишка!",
			"Бро, это был фейл века!",
			"Твои скиллы утонули в луже!",
			"Ты играешь, как заблудший нуб!",
			"Ты забыл, где кнопки, или как?",
			"Твой геймплей — это чистый краш!",
			"Бро, мой тапок лучше играет!"
		}
	}
}

IsSpamming = false
SelectedMode = "SteelHub"
TrashTalkLanguage = "English"
LastMessageTime = 0
Cooldown = 2.6

MiscRight4:AddToggle('SpamToggle', {
	Text = 'Chat Spam',
	Default = false,
	Callback = function(Value)
		IsSpamming = Value
	end
})

MiscRight4:AddDropdown('ModeDropdown', {
	Values = { 'SteelHub', 'Russian', 'English', 'TrashTalk' },
	Default = 1,
	Text = 'Message Type',
	Callback = function(Value)
		SelectedMode = Value
	end
})

MiscRight4:AddDropdown('TrashTalkLanguageDropdown', {
	Values = { 'English', 'Russian' },
	Default = 1,
	Text = 'TrashTalk Language',
	Callback = function(Value)
		TrashTalkLanguage = Value
	end
})

task.spawn(function()
	while true do
		if IsSpamming and (tick() - LastMessageTime >= Cooldown) then
			if SelectedMode == "TrashTalk" then
				game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(Messages.TrashTalk[TrashTalkLanguage][math.random(1, #Messages.TrashTalk[TrashTalkLanguage])])
			else
				game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(Messages[SelectedMode][math.random(1, #Messages[SelectedMode])])
			end
			LastMessageTime = tick()
		end
		wait(0.1)
	end
end)

p = game:GetService("Players").LocalPlayer
enabled = false

function f()
	pcall(function()
		game:GetService("VirtualUser"):CaptureController()
		game:GetService("VirtualUser"):SetKeyDown('0x20')
		task.wait(0.1)
		game:GetService("VirtualUser"):SetKeyUp('0x20')
	end)
	pcall(function()
		w = workspace.CurrentCamera
		w.CFrame = w.CFrame * CFrame.Angles(math.rad(0.5),0,0)
		task.wait(0.1)
		w.CFrame = w.CFrame * CFrame.Angles(math.rad(-0.5),0,0)
	end)
end

function enable()
	if enabled then return end
	enabled = true
	c1 = p.Idled:Connect(function() if enabled then f() end end)
	coroutine.resume(coroutine.create(function()
		while enabled do f() task.wait(30) end
	end))
	c2 = p.CharacterAdded:Connect(function()
		task.wait(1)
		if enabled then f() end
	end)
end

function disable()
	if not enabled then return end
	enabled = false
	if c1 then c1:Disconnect() c1 = nil end
	if c2 then c2:Disconnect() c2 = nil end
end

MiscRight3:AddToggle('AntiAFKToggle', {
	Text = "Anti AFK",
	Default = false,
	Callback = function(v)
		if v then enable() else disable() end
	end
})

AdminCheck_Enabled = false
AdminCheck_Connection = nil
AdminCheck_Coroutine = nil

AdminList = {
	["tabootvcat"] = true, ["Revenantic"] = true, ["Saabor"] = true, ["MoIitor"] = true, ["IAmUnderAMask"] = true,
	["SheriffGorji"] = true, ["xXFireyScorpionXx"] = true, ["LoChips"] = true, ["DeliverCreations"] = true,
	["TDXiswinning"] = true, ["TZZV"] = true, ["FelixVenue"] = true, ["SIEGFRlED"] = true, ["ARRYvvv"] = true,
	["z_papermoon"] = true, ["Malpheasance"] = true, ["ModHandIer"] = true, ["valphex"] = true, ["J_anday"] = true,
	["tvdisko"] = true, ["yIlehs"] = true, ["COLOSSUSBUILTOFSTEEL"] = true, ["SeizedHolder"] = true, ["r3shape"] = true,
	["RVVZ"] = true, ["adurize"] = true, ["codedcosmetics"] = true, ["QuantumCaterpillar"] = true,
	["FractalHarmonics"] = true, ["GalacticSculptor"] = true, ["oTheSilver"] = true, ["Kretacaous"] = true,
	["icarus_xs1goliath"] = true, ["GlamorousDradon"] = true, ["rainjeremy"] = true, ["parachuter2000"] = true,
	["faintermercury"] = true, ["harht"] = true, ["Sansek1252"] = true, ["Snorpuwu"] = true, ["BenAzoten"] = true,
	["Cand1ebox"] = true, ["KeenlyAware"] = true, ["mrzued"] = true, ["BruhmanVIII"] = true, ["Nystesia"] = true,
	["fausties"] = true, ["zateopp"] = true, ["Iordnabi"] = true, ["ReviveTheDevil"] = true, ["jake_jpeg"] = true,
	["UncrossedMeat3888"] = true, ["realpenyy"] = true, ["karateeeh"] = true, ["JayyMlg"] = true, ["Lo_Chips"] = true,
	["Avelosky"] = true, ["king_ab09"] = true, ["TigerLe123"] = true, ["Dalvanuis"] = true, ["iSonMillions"] = true,
	["DieYouOder"] = true, ["whosframed"] = true
}

CheckAdmins = function()
	for _, plr in ipairs(Players:GetPlayers()) do
		if AdminList[plr.Name] then
			LocalPlayer:Kick("Admin")
			task.wait(2)
			game:Shutdown()
			return
		end
	end
end

AdminCheck_Enable = function()
	if AdminCheck_Enabled then return end
	AdminCheck_Enabled = true
	CheckAdmins()
	AdminCheck_Connection = Players.PlayerAdded:Connect(function(plr)
		if not AdminCheck_Enabled then return end
		if AdminList[plr.Name] then
			LocalPlayer:Kick("Detected Admin")
			task.wait(2)
			game:Shutdown()
		end
	end)
	AdminCheck_Coroutine = coroutine.create(function()
		while AdminCheck_Enabled do
			CheckAdmins()
			task.wait(4)
		end
	end)
	coroutine.resume(AdminCheck_Coroutine)
end

AdminCheck_Disable = function()
	if not AdminCheck_Enabled then return end
	AdminCheck_Enabled = false
	if AdminCheck_Connection then
		AdminCheck_Connection:Disconnect()
		AdminCheck_Connection = nil
	end
	AdminCheck_Coroutine = nil
end

MiscRight3:AddToggle('AdminCheckToggle', {
	Text = "Admin Check",
	Default = false,
	Callback = function(Value)
		if Value then
			AdminCheck_Enable()
		else
			AdminCheck_Disable()
		end
	end
})

fastPickupEnabled = false

function bypassProximityPrompts()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v.HoldDuration = 0
		end
	end
end

function enableBypass()
	fastPickupEnabled = true
	bypassProximityPrompts()
	game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(v)
		if fastPickupEnabled then
			v.HoldDuration = 0
		end
	end)
end

function disableBypass()
	fastPickupEnabled = false
end

MiscRight3:AddToggle('FastInteract_Toggle', {
	Text = "Fast Interact",
	Default = false,
	Callback = function(Value)
		if Value then
			enableBypass()
		else
			disableBypass()
		end
	end
})

MiscRight3:AddToggle('ChatToggle', {
	Text = "Chat Enabler",
	Default = false,
	Callback = function(Value)
		game:GetService("TextChatService").ChatWindowConfiguration.Enabled = Value
	end
})

MiscRight3:AddToggle('DisableParts', {
	Text = "NoBarries",
	Default = false,
	Callback = function(State)
		findAndDisableParts(not State)
		findAndDisableParts2(not State)
	end
})

function disableTouchAndQuery(part, value)
	if part:IsA("BasePart") then
		part.CanTouch = value
		part.CanQuery = value
	end
end

function findAndDisableParts(value)
	partNames = {"BarbedWire", "RG_Part", "Spike"}
	for _, partName in ipairs(partNames) do
		for _, part in pairs(game.Workspace:GetDescendants()) do
			if part.Name == partName then
				disableTouchAndQuery(part, value)
			end
		end
	end
end

function findAndDisableParts2(value)
	partNames2 = {"FirePart", "Grinder"}
	for _, partName in ipairs(partNames2) do
		for _, part in pairs(game.Workspace:GetDescendants()) do
			if part.Name == partName then
				disableTouchAndQuery(part, value)
			end
		end
	end
end

player = game.Players.LocalPlayer
charStats = game:GetService("ReplicatedStorage").CharStats
parts = {"Head", "Left Arm", "Left Leg", "Right Arm", "Right Leg"}

MiscRight3:AddToggle('BreakParts', {
	Text = 'Break Limbs',
	Default = false,
	Callback = function(Value)
		for _, part in ipairs(parts) do
			if charStats[player.Name].HealthValues[part] then
				charStats[player.Name].HealthValues[part].Broken.Value = Value
			end
		end
	end
})

MiscRight3:AddToggle('UnbreakParts', {
	Text = 'Unbreak Limbs',
	Default = false,
	Callback = function(Value)
		for _, part in ipairs(parts) do
			if charStats[player.Name].HealthValues[part] then
				charStats[player.Name].HealthValues[part].Broken.Value = false
			end
		end
	end
})

game:GetService("RunService").RenderStepped:Connect(function()
	if Toggles.UnbreakParts.Value then
		for _, part in ipairs(parts) do
			if charStats[player.Name].HealthValues[part] then
				charStats[player.Name].HealthValues[part].Broken.Value = false
			end
		end
	end
end)

spinEnabled = false
spinSpeed = 1000
player = game.Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoidRootPart = character:WaitForChild("HumanoidRootPart")

spinToggle = MiscRight3:AddToggle("SpinToggle", {
	Text = "Spin",
	Default = false,
	Callback = function(value)
		spinEnabled = value
	end,
}):AddKeyPicker("SpinKey", {
	Default = "None", 
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Spin",
	Callback = function()
	end,
})

hiddenfling, movel = false, 0.1

function fling()
	while hiddenfling do
		game:GetService("RunService").Heartbeat:Wait()
		char = game:GetService("Players").LocalPlayer.Character
		hrp = char and char:FindFirstChild("HumanoidRootPart")

		if hrp then
			vel = hrp.Velocity
			hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
			game:GetService("RunService").RenderStepped:Wait()
			hrp.Velocity = vel
			game:GetService("RunService").Stepped:Wait()
			hrp.Velocity = vel + Vector3.new(0, movel, 0)
			movel = -movel
		end
	end
end

MiscRight3:AddToggle('FlingToggle', {
	Text = "Fling",
	Default = false,
	Callback = function(Value)
		hiddenfling = Value
		if Value then
			if not flingTask then
				flingTask = task.spawn(fling)
			end
		else
			if flingTask then
				task.cancel(flingTask)
				flingTask = nil
			end
		end
	end,
}):AddKeyPicker("FlingKey", {
	Default = "None", 
	SyncToggleState = true,
	Mode = "Toggle",
	Text = "Fling",
	Callback = function()
	end,
})

work = false

MiscRight3:AddToggle('VelocityToggle', {
	Text = 'Anti-Fling',
	Default = false,
	Callback = function(Value)
		work = Value
	end
})

RunService.RenderStepped:Connect(function()
	if not work then return end
	char = LocalPlayer.Character
	if not char then return end
	hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	oldVelocity = hrp.Velocity

	for _, part in pairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			part.CanTouch = false
			if part.Velocity.Magnitude > oldVelocity.Magnitude * 3 then
				part.Velocity = Vector3.zero
			end
		end
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			plrChar = player.Character
			if plrChar then
				for _, part in pairs(plrChar:GetChildren()) do
					if part:IsA("BasePart") then
						if part.Velocity.Magnitude > oldVelocity.Magnitude * 1.3 then
							part.Velocity = Vector3.zero
							part.CanTouch = false
						end
					end
				end
			end
		end
	end
end)

FinishSpeedMulti = game:GetService("ReplicatedStorage").Values.FinishSpeedMulti

MiscRight3:AddToggle('FinishSpeedToggle', {
	Text = 'Finish Speed',
	Default = false,
	Callback = function(Value)
		if Value then
			FinishSpeedMulti.Value = Options.FinishSpeedSlider.Value
		else
			FinishSpeedMulti.Value = 1
		end
	end
})

MiscRight3:AddSlider("SpeedSlider", {
	Text = "Spin Speed",
	Default = 1000,
	Min = 1000,
	Max = 10000,
	Rounding = 1,
	Callback = function(value)
		spinSpeed = value
	end
})

game:GetService("RunService").Heartbeat:Connect(function()
	if spinEnabled and humanoidRootPart then
		humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed / 10), 0)
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

MiscRight3:AddSlider('FinishSpeedSlider', {
	Text = 'Finish Speed',
	Default = 1,
	Min = 1,
	Max = 2,
	Rounding = 1,
	Compact = false,
	Callback = function(Value)
		if Toggles.FinishSpeedToggle.Value then
			FinishSpeedMulti.Value = Value
		end
	end
})

Options.FinishSpeedSlider:OnChanged(function()
	if Toggles.FinishSpeedToggle.Value then
		FinishSpeedMulti.Value = Options.FinishSpeedSlider.Value
	end
end)

MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')

--MouseEnabled = true
--game:GetService("RunService").RenderStepped:Connect(function()
--    game:GetService("UserInputService").MouseIconEnabled = MouseEnabled
--end)

--MenuGroup:AddToggle('MouseVisibilityToggle', {
--    Text = 'Show Mouse',
--    Default = true,
--    Callback = function(Value)
--        MouseEnabled = Value
--    end
--})

MenuGroup:AddToggle('KeybindFrameToggle', {
	Text = 'Show Keybinds gui',
	Default = false,
	Callback = function(Value)
		Library.KeybindFrame.Visible = Value
	end
})

UnloadButton = MenuGroup:AddButton({
	Text = 'Unload',
	Func = function()
		Library:Unload()
	end
})

MenuKeybind = MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
	Default = 'RightShift',
	Mode = 'Toggle',
	Text = 'Menu keybind',
	NoUI = true,
	Callback = function(Value) end
})

coroutine.wrap(function()
	shared.canwrite = true
	repeat wait() until shared.canwrite == true
	Library.ToggleKeybind = Options.MenuKeybind

	Library.ToggleKeybind = Options.MenuKeybind

	ThemeManager:SetLibrary(Library)
	SaveManager:SetLibrary(Library)

	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({'MenuKeybind'})

	ThemeManager:SetFolder('Criminol')
	SaveManager:SetFolder('Criminol/configs')

	SaveManager:BuildConfigSection(Tabs.Settings)
	ThemeManager:ApplyToTab(Tabs.Settings)

	SaveManager:LoadAutoloadConfig()

	Library:Notify("Join in discord - discord.gg/REG77bCwJh", 20)
	shared.canwrite = false
end)()
