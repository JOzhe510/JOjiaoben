--[[
	ZenAim Pro v7.0 - ESP优化版
	更新内容：
	1. 添加队伍检测开关
	2. 新增"胸口"部位选择（4个部位：Head/UpperTorso/LowerTorso/HumanoidRootPart）
	3. ESP全面优化：方框/血条/距离/名字/背敌指示器
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 设备检测
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ViewportSize = Camera.ViewportSize

-- 设置系统
local Settings = {
	CameraSens = 1.0,
	Aimbot = true,
	FOV = 120,
	AimStrength = 0.5,
	LockMode = "磁吸锁定",
	TargetPart = "Head",
	Prediction = true,
	PredictionStrength = 0.7,
	VisibilityCheck = true,
	DynamicFOV = true,
	TeamCheck = false,
	MaxDistance = 1000,
	StickyLock = true,
	ESP = true,
	ESP_ShowBox = true,
	ESP_ShowHealth = true,
	ESP_ShowDistance = true,
	ESP_ShowName = true,
	ESP_ShowDirection = true,
	ESP_MaxDistance = 500,
	ESP_BoxType = "2D方框"
}

-- UI状态
local MainFrame = nil
local isDragging = false
local dragOffset = Vector2.zero
local isMinimized = false

-- 锁定系统
local LockSystem = {
	lockedPlayer = nil,
	lockedPart = nil,
	lockTime = 0,
	lockPriority = 0,
	switchCooldown = 0,
	targetHistory = {},
	historyIndex = 0,
	velocitySamples = {},
	sampleIndex = 0
}

-- 武器检测
local WeaponDetection = {
	bulletSpeed = 600,
	weaponType = "hitscan",
	lastFireTime = 0,
	distanceCompensation = 1.0
}

-- 射线参数
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

-- ==================== ESP绘制系统（全面优化） ====================
local ESPObjects = {}

local function createESP(player)
	if player == LocalPlayer then return end
	
	local esp = {
		player = player,
		-- 方框
		boxTop = Drawing.new("Line"),
		boxBottom = Drawing.new("Line"),
		boxLeft = Drawing.new("Line"),
		boxRight = Drawing.new("Line"),
		-- 血条
		healthBg = Drawing.new("Line"),
		healthBar = Drawing.new("Line"),
		-- 文字
		nameText = Drawing.new("Text"),
		distText = Drawing.new("Text"),
		-- 背敌指示器
		direction = Drawing.new("Triangle")
	}
	
	-- 方框线条
	for _, line in pairs({esp.boxTop, esp.boxBottom, esp.boxLeft, esp.boxRight}) do
		line.Visible = false
		line.Color = Color3.fromRGB(255, 255, 255)
		line.Thickness = 1.5
		line.Transparency = 0.3
	end
	
	-- 血条背景
	esp.healthBg.Visible = false
	esp.healthBg.Color = Color3.fromRGB(30, 30, 30)
	esp.healthBg.Thickness = 4
	
	-- 血条
	esp.healthBar.Visible = false
	esp.healthBar.Thickness = 3
	
	-- 名字
	esp.nameText.Visible = false
	esp.nameText.Color = Color3.fromRGB(255, 255, 255)
	esp.nameText.Size = 14
	esp.nameText.Center = true
	esp.nameText.Outline = true
	esp.nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
	
	-- 距离
	esp.distText.Visible = false
	esp.distText.Color = Color3.fromRGB(200, 200, 200)
	esp.distText.Size = 13
	esp.distText.Center = true
	esp.distText.Outline = true
	esp.distText.OutlineColor = Color3.fromRGB(0, 0, 0)
	
	-- 背敌指示器
	esp.direction.Visible = false
	esp.direction.Color = Color3.fromRGB(255, 60, 60)
	esp.direction.Thickness = 1
	esp.direction.Filled = true
	
	ESPObjects[player] = esp
	return esp
end

local function removeESP(player)
	if ESPObjects[player] then
		for _, drawing in pairs(ESPObjects[player]) do
			if typeof(drawing) == "Instance" then
				drawing:Remove()
			elseif type(drawing) == "table" then
				for _, d in pairs(drawing) do
					if typeof(d) == "Instance" then d:Remove() end
				end
			end
		end
		ESPObjects[player] = nil
	end
end

-- 获取血量颜色
local function getHealthColor(percent)
	if percent > 0.7 then
		return Color3.fromRGB(0, 255, 80)
	elseif percent > 0.5 then
		return Color3.fromRGB(180, 255, 0)
	elseif percent > 0.3 then
		return Color3.fromRGB(255, 200, 0)
	else
		return Color3.fromRGB(255, 40, 40)
	end
end

local function updateESP()
	if not Settings.ESP then
		for _, esp in pairs(ESPObjects) do
			esp.boxTop.Visible = false
			esp.boxBottom.Visible = false
			esp.boxLeft.Visible = false
			esp.boxRight.Visible = false
			esp.healthBg.Visible = false
			esp.healthBar.Visible = false
			esp.nameText.Visible = false
			esp.distText.Visible = false
			esp.direction.Visible = false
		end
		return
	end
	
	local camPos = Camera.CFrame.Position
	local screenCenter = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
	
	for player, esp in pairs(ESPObjects) do
		local char = player.Character
		if not char then
			esp.boxTop.Visible = false; esp.boxBottom.Visible = false
			esp.boxLeft.Visible = false; esp.boxRight.Visible = false
			esp.healthBg.Visible = false; esp.healthBar.Visible = false
			esp.nameText.Visible = false; esp.distText.Visible = false
			esp.direction.Visible = false
			continue
		end
		
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local head = char:FindFirstChild("Head")
		
		if not hum or not hrp or not head or hum.Health <= 0 then
			esp.boxTop.Visible = false; esp.boxBottom.Visible = false
			esp.boxLeft.Visible = false; esp.boxRight.Visible = false
			esp.healthBg.Visible = false; esp.healthBar.Visible = false
			esp.nameText.Visible = false; esp.distText.Visible = false
			esp.direction.Visible = false
			continue
		end
		
		-- 队伍检测
		if Settings.TeamCheck and player.Team == LocalPlayer.Team then
			esp.boxTop.Visible = false; esp.boxBottom.Visible = false
			esp.boxLeft.Visible = false; esp.boxRight.Visible = false
			esp.healthBg.Visible = false; esp.healthBar.Visible = false
			esp.nameText.Visible = false; esp.distText.Visible = false
			esp.direction.Visible = false
			continue
		end
		
		local targetPos = hrp.Position
		local dist = (targetPos - camPos).Magnitude
		
		if dist > Settings.ESP_MaxDistance then
			esp.boxTop.Visible = false; esp.boxBottom.Visible = false
			esp.boxLeft.Visible = false; esp.boxRight.Visible = false
			esp.healthBg.Visible = false; esp.healthBar.Visible = false
			esp.nameText.Visible = false; esp.distText.Visible = false
			esp.direction.Visible = false
			continue
		end
		
		-- 计算屏幕坐标
		local headPos, headOnScreen = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.5, 0))
		local footPos = Camera:WorldToScreenPoint(hrp.Position - Vector3.new(0, 3, 0))
		
		-- 计算方框尺寸
		local boxHeight = math.abs(headPos.Y - footPos.Y)
		local boxWidth = boxHeight * 0.55
		local boxLeft = headPos.X - boxWidth / 2
		local boxRight = headPos.X + boxWidth / 2
		local boxTop = headPos.Y
		local boxBottom = headPos.Y - boxHeight
		
		-- 屏幕外检测
		local isOnScreen = headPos.Z > 0 and footPos.Z > 0
		
		if isOnScreen then
			-- 隐藏背敌指示器
			esp.direction.Visible = false
			
			-- 方框
			if Settings.ESP_ShowBox then
				esp.boxTop.Visible = true
				esp.boxTop.From = Vector2.new(boxLeft, boxTop)
				esp.boxTop.To = Vector2.new(boxRight, boxTop)
				
				esp.boxBottom.Visible = true
				esp.boxBottom.From = Vector2.new(boxLeft, boxBottom)
				esp.boxBottom.To = Vector2.new(boxRight, boxBottom)
				
				esp.boxLeft.Visible = true
				esp.boxLeft.From = Vector2.new(boxLeft, boxTop)
				esp.boxLeft.To = Vector2.new(boxLeft, boxBottom)
				
				esp.boxRight.Visible = true
				esp.boxRight.From = Vector2.new(boxRight, boxTop)
				esp.boxRight.To = Vector2.new(boxRight, boxBottom)
			else
				esp.boxTop.Visible = false; esp.boxBottom.Visible = false
				esp.boxLeft.Visible = false; esp.boxRight.Visible = false
			end
			
			-- 血条
			if Settings.ESP_ShowHealth then
				local healthPercent = hum.Health / hum.MaxHealth
				local barX = boxLeft - 6
				local barTop = boxTop
				local barBottom = boxBottom
				
				esp.healthBg.Visible = true
				esp.healthBg.From = Vector2.new(barX, barTop)
				esp.healthBg.To = Vector2.new(barX, barBottom)
				
				local healthHeight = (barTop - barBottom) * healthPercent
				esp.healthBar.Visible = true
				esp.healthBar.Color = getHealthColor(healthPercent)
				esp.healthBar.From = Vector2.new(barX, barTop)
				esp.healthBar.To = Vector2.new(barX, barTop - healthHeight)
			else
				esp.healthBg.Visible = false
				esp.healthBar.Visible = false
			end
			
			-- 名字
			if Settings.ESP_ShowName then
				esp.nameText.Visible = true
				esp.nameText.Position = Vector2.new(headPos.X, boxBottom + 18)
				esp.nameText.Text = player.Name
			else
				esp.nameText.Visible = false
			end
			
			-- 距离
			if Settings.ESP_ShowDistance then
				esp.distText.Visible = true
				esp.distText.Position = Vector2.new(headPos.X, boxBottom + 34)
				esp.distText.Text = string.format("[%.0fm]", dist)
			else
				esp.distText.Visible = false
			end
		else
			-- 目标在屏幕外
			esp.boxTop.Visible = false; esp.boxBottom.Visible = false
			esp.boxLeft.Visible = false; esp.boxRight.Visible = false
			esp.healthBg.Visible = false; esp.healthBar.Visible = false
			esp.nameText.Visible = false; esp.distText.Visible = false
			
			-- 背敌指示器
			if Settings.ESP_ShowDirection then
				local flatDir = Vector2.new(targetPos.X - camPos.X, targetPos.Z - camPos.Z)
				if flatDir.Magnitude > 0 then
					flatDir = flatDir.Unit
					local indicatorDist = math.min(ViewportSize.X, ViewportSize.Y) * 0.25
					local indicatorPos = screenCenter + flatDir * indicatorDist
					local perpDir = Vector2.new(-flatDir.Y, flatDir.X) * 10
					
					esp.direction.Visible = true
					esp.direction.PointA = indicatorPos + flatDir * 12
					esp.direction.PointB = indicatorPos + perpDir - flatDir * 6
					esp.direction.PointC = indicatorPos - perpDir - flatDir * 6
				end
			else
				esp.direction.Visible = false
			end
		end
	end
end

-- ==================== FOV绘制 ====================
local fovOuter = Drawing.new("Circle")
fovOuter.Visible = true
fovOuter.Color = Color3.fromRGB(255, 70, 70)
fovOuter.Thickness = 2.2
fovOuter.NumSides = 100
fovOuter.Transparency = 0.65
fovOuter.Filled = false
fovOuter.ZIndex = 10

local fovCrosshair = {}
for i = 1, 4 do
	local line = Drawing.new("Line")
	line.Visible = true
	line.Color = Color3.fromRGB(255, 60, 60)
	line.Thickness = 1.5
	line.Transparency = 0.7
	line.ZIndex = 11
	fovCrosshair[i] = line
end

local lockIndicator = Drawing.new("Circle")
lockIndicator.Visible = false
lockIndicator.Color = Color3.fromRGB(0, 255, 100)
lockIndicator.Thickness = 3
lockIndicator.NumSides = 6
lockIndicator.Transparency = 0.3
lockIndicator.Filled = false
lockIndicator.Radius = 15
lockIndicator.ZIndex = 12

local function updateFOV()
	local center = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
	local fov = Settings.FOV
	
	fovOuter.Position = center
	fovOuter.Radius = fov
	fovOuter.Visible = Settings.Aimbot
	
	local crossLen = fov * 0.2
	local gap = fov * 0.1
	local positions = {
		{center + Vector2.new(gap, 0), center + Vector2.new(gap + crossLen, 0)},
		{center - Vector2.new(gap, 0), center - Vector2.new(gap + crossLen, 0)},
		{center + Vector2.new(0, gap), center + Vector2.new(0, gap + crossLen)},
		{center - Vector2.new(0, gap), center - Vector2.new(0, gap + crossLen)}
	}
	
	for i = 1, 4 do
		fovCrosshair[i].From = positions[i][1]
		fovCrosshair[i].To = positions[i][2]
		fovCrosshair[i].Visible = Settings.Aimbot
	end
	
	if LockSystem.lockedPlayer and Settings.Aimbot then
		lockIndicator.Visible = true
		lockIndicator.Position = center
	else
		lockIndicator.Visible = false
	end
end

-- ==================== UI系统 ====================
local function createUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "ZenAimPro"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	MainFrame = Instance.new("Frame")
	MainFrame.Name = "Main"
	MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
	MainFrame.BackgroundTransparency = 0.05
	MainFrame.BorderSizePixel = 0
	MainFrame.Size = UDim2.new(0, 230, 0, 520)
	MainFrame.Position = UDim2.new(0.02, 0, 0.12, 0)
	MainFrame.ClipsDescendants = true
	MainFrame.ZIndex = 10
	MainFrame.Parent = gui
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 80, 120)
	stroke.Thickness = 1.5
	stroke.Parent = MainFrame
	
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

	local titleBar = Instance.new("Frame")
	titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
	titleBar.BorderSizePixel = 0
	titleBar.Size = UDim2.new(1, 0, 0, 38)
	titleBar.Parent = MainFrame
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(0.65, 0, 1, 0)
	title.Position = UDim2.new(0.05, 0, 0, 0)
	title.Text = "ZenAim Pro"
	title.TextColor3 = Color3.fromRGB(180, 200, 255)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = titleBar

	local minBtn = Instance.new("TextButton")
	minBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 130)
	minBtn.Size = UDim2.new(0, 28, 0, 28)
	minBtn.Position = UDim2.new(1, -34, 0, 5)
	minBtn.Text = "—"
	minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 18
	minBtn.ZIndex = 12
	minBtn.Parent = titleBar
	Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)

	minBtn.Activated:Connect(function()
		isMinimized = not isMinimized
		MainFrame.Size = isMinimized and UDim2.new(0, 230, 0, 42) or UDim2.new(0, 230, 0, 520)
		minBtn.Text = isMinimized and "😌" or "😈"
	end)

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragOffset = Vector2.new(input.Position.X - MainFrame.AbsolutePosition.X, 
			                          input.Position.Y - MainFrame.AbsolutePosition.Y)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local pos = Vector2.new(input.Position.X - dragOffset.X, input.Position.Y - dragOffset.Y)
			pos = Vector2.new(
				math.clamp(pos.X, 0, ViewportSize.X - MainFrame.AbsoluteSize.X),
				math.clamp(pos.Y, 0, ViewportSize.Y - MainFrame.AbsoluteSize.Y)
			)
			MainFrame.Position = UDim2.new(0, pos.X, 0, pos.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.new(1, -6, 1, -44)
	scroll.Position = UDim2.new(0, 3, 0, 42)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
	scroll.ScrollBarThickness = 2
	scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
	scroll.Parent = MainFrame

	return scroll
end

-- UI控件
local function createSlider(parent, name, min, max, default, callback, yPos, decimals)
	decimals = decimals or 2
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, -20, 0, 48)
	container.Position = UDim2.new(0, 10, 0, yPos)
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 16)
	label.Text = name .. ": " .. string.format("%." .. decimals .. "f", default)
	label.TextColor3 = Color3.fromRGB(190, 190, 215)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local bg = Instance.new("Frame")
	bg.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
	bg.BorderSizePixel = 0
	bg.Size = UDim2.new(1, 0, 0, 12)
	bg.Position = UDim2.new(0, 0, 0, 22)
	bg.Parent = container
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Color3.fromRGB(100, 140, 255)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.Parent = bg
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)

	local btn = Instance.new("TextButton")
	btn.BackgroundTransparency = 1
	btn.Size = UDim2.new(1, 0, 1, 14)
	btn.Position = UDim2.new(0, 0, 0, -7)
	btn.Text = ""
	btn.ZIndex = 5
	btn.Parent = bg

	local sliding = false
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
		end
	end)
	UserInputService.InputEnded:Connect(function() sliding = false end)
	btn.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local percent = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
			local val = min + (max - min) * percent
			val = math.clamp(val, min, max)
			fill.Size = UDim2.new(percent, 0, 1, 0)
			label.Text = name .. ": " .. string.format("%." .. decimals .. "f", val)
			callback(val)
		end
	end)
end

local function createToggle(parent, name, default, callback, yPos)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, -20, 0, 38)
	container.Position = UDim2.new(0, 10, 0, yPos)
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Text = name
	label.TextColor3 = Color3.fromRGB(190, 190, 215)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = default and Color3.fromRGB(70, 180, 70) or Color3.fromRGB(60, 60, 80)
	btn.Size = UDim2.new(0, 42, 0, 24)
	btn.Position = UDim2.new(1, -44, 0, 7)
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

	local state = default
	btn.Activated:Connect(function()
		state = not state
		btn.BackgroundColor3 = state and Color3.fromRGB(70, 180, 70) or Color3.fromRGB(60, 60, 80)
		callback(state)
	end)
end

local function createDropdown(parent, name, options, default, callback, yPos)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, -20, 0, 52)
	container.Position = UDim2.new(0, 10, 0, yPos)
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 16)
	label.Text = name
	label.TextColor3 = Color3.fromRGB(190, 190, 215)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local dd = Instance.new("TextButton")
	dd.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	dd.Size = UDim2.new(1, 0, 0, 28)
	dd.Position = UDim2.new(0, 0, 0, 20)
	dd.Text = default
	dd.TextColor3 = Color3.fromRGB(255, 255, 255)
	dd.Font = Enum.Font.Gotham
	dd.TextSize = 13
	dd.Parent = container
	Instance.new("UICorner", dd).CornerRadius = UDim.new(0, 6)

	local idx = 1
	for i, opt in ipairs(options) do
		if opt == default then idx = i; break end
	end

	dd.Activated:Connect(function()
		idx = idx % #options + 1
		local sel = options[idx]
		dd.Text = sel
		callback(sel)
	end)
end

-- 武器检测
local function detectWeapon()
	local character = LocalPlayer.Character
	if not character then return end
	
	for _, tool in ipairs(character:GetChildren()) do
		if tool:IsA("Tool") then
			local name = tool.Name:lower()
			
			if name:find("sniper") or name:find("awp") then
				WeaponDetection.weaponType = "sniper"
				WeaponDetection.bulletSpeed = 850
				WeaponDetection.distanceCompensation = 1.6
			elseif name:find("rifle") or name:find("ar") then
				WeaponDetection.weaponType = "rifle"
				WeaponDetection.bulletSpeed = 700
				WeaponDetection.distanceCompensation = 1.3
			elseif name:find("smg") then
				WeaponDetection.weaponType = "smg"
				WeaponDetection.bulletSpeed = 550
				WeaponDetection.distanceCompensation = 1.0
			elseif name:find("shotgun") then
				WeaponDetection.weaponType = "shotgun"
				WeaponDetection.bulletSpeed = 450
				WeaponDetection.distanceCompensation = 0.7
			elseif name:find("pistol") or name:find("deagle") then
				WeaponDetection.weaponType = "pistol"
				WeaponDetection.bulletSpeed = 600
				WeaponDetection.distanceCompensation = 1.1
			else
				WeaponDetection.weaponType = "hitscan"
				WeaponDetection.bulletSpeed = 650
				WeaponDetection.distanceCompensation = 1.0
			end
			return
		end
	end
	
	WeaponDetection.weaponType = "hitscan"
	WeaponDetection.bulletSpeed = 650
	WeaponDetection.distanceCompensation = 1.0
end

-- 目标锁定
local function shouldSwitchTarget(newTarget)
	if not LockSystem.lockedPlayer then return true end
	if LockSystem.switchCooldown > 0 then return false end
	
	if not LockSystem.lockedPlayer.Character then
		LockSystem.lockedPlayer = nil
		return true
	end
	
	local hum = LockSystem.lockedPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		LockSystem.lockedPlayer = nil
		return true
	end
	
	if Settings.TeamCheck and LockSystem.lockedPlayer.Team == LocalPlayer.Team then
		LockSystem.lockedPlayer = nil
		return true
	end
	
	if newTarget and newTarget.player == LockSystem.lockedPlayer then
		return false
	end
	
	if Settings.StickyLock then
		local currentPart = LockSystem.lockedPlayer.Character:FindFirstChild(Settings.TargetPart)
		if not currentPart then currentPart = LockSystem.lockedPlayer.Character:FindFirstChild("Head") end
		
		if currentPart then
			local screenPos = Camera:WorldToScreenPoint(currentPart.Position)
			local screenCenter = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
			local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
			
			if distFromCenter < Settings.FOV * 1.4 then
				return false
			end
		end
	end
	
	LockSystem.switchCooldown = 0.25
	return true
end

-- 自适应预判
local function getAdaptivePrediction(target)
	if not Settings.Prediction or not target then return target.worldPos end
	
	local part = target.part
	local hum = target.hum
	local char = target.char
	
	local velocities = {}
	
	if hum and hum.MoveDirection.Magnitude > 0.05 then
		table.insert(velocities, hum.MoveDirection * hum.WalkSpeed * 0.85)
	end
	
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		local physVel = root.AssemblyLinearVelocity
		if physVel.Magnitude > 2 then
			table.insert(velocities, physVel * 0.95)
		end
	end
	
	local partVel = part.AssemblyLinearVelocity
	if partVel.Magnitude > 1 then
		table.insert(velocities, partVel * 0.75)
	end
	
	local finalVel = Vector3.zero
	if #velocities > 0 then
		for _, v in ipairs(velocities) do
			finalVel = finalVel + v
		end
		finalVel = finalVel / #velocities
	end
	
	local samples = LockSystem.velocitySamples
	local idx = LockSystem.sampleIndex
	samples[idx] = finalVel
	idx = (idx % 5) + 1
	LockSystem.sampleIndex = idx
	
	local avgVel = Vector3.zero
	local count = 0
	for i = 1, 5 do
		if samples[i] then
			avgVel = avgVel + samples[i]
			count = count + 1
		end
	end
	if count > 0 then avgVel = avgVel / count end
	
	local dist = (part.Position - Camera.CFrame.Position).Magnitude
	local bulletSpeed = WeaponDetection.bulletSpeed
	
	if WeaponDetection.weaponType == "sniper" then
		bulletSpeed = bulletSpeed + dist * 0.35
	elseif WeaponDetection.weaponType == "smg" then
		bulletSpeed = bulletSpeed + dist * 0.12
	end
	
	local travelTime = (dist / bulletSpeed) * WeaponDetection.distanceCompensation * Settings.PredictionStrength
	
	local isJumping = hum and hum.FloorMaterial == Enum.Material.Air
	local jumpCompensation = isJumping and 1.4 or 1.0
	
	return part.Position + avgVel * travelTime * jumpCompensation
end

-- 目标获取（支持4个部位）
local function findTarget()
	local screenCenter = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
	local camPos = Camera.CFrame.Position
	local bestTarget = nil
	local bestScore = math.huge
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		
		local char = player.Character
		if not char then continue end
		
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		
		-- 队伍检测
		if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
		
		local part = char:FindFirstChild(Settings.TargetPart)
		if not part then
			-- 回退：尝试其他部位
			part = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or 
			        char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("LowerTorso")
			if not part then continue end
		end
		
		local partPos = part.Position
		local dist = (partPos - camPos).Magnitude
		if dist > Settings.MaxDistance then continue end
		
		if Settings.VisibilityCheck then
			local dir = (partPos - camPos)
			rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
			local ray = workspace:Raycast(camPos, dir.Unit * dir.Magnitude, rayParams)
			if ray and ray.Instance and not ray.Instance:IsDescendantOf(char) then
				continue
			end
		end
		
		local screenPos, onScreen = Camera:WorldToScreenPoint(partPos)
		if not onScreen then continue end
		
		local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
		
		local effectiveFOV = Settings.FOV
		if Settings.DynamicFOV then
			local root = char:FindFirstChild("HumanoidRootPart")
			local vel = root and root.AssemblyLinearVelocity.Magnitude or 0
			effectiveFOV = effectiveFOV + math.clamp(vel * 2.5, 0, 70)
			
			if hum and hum.FloorMaterial == Enum.Material.Air then
				effectiveFOV = effectiveFOV * 1.25
			end
		end
		
		if screenDist > effectiveFOV then continue end
		
		local score = screenDist * 0.8
		score = score - (hum.Health / hum.MaxHealth) * 40
		score = score + (dist / 100) * 3
		
		if player == LockSystem.lockedPlayer then
			score = score - 60
		end
		
		if score < bestScore then
			bestScore = score
			bestTarget = {
				player = player,
				char = char,
				part = part,
				hum = hum,
				screenPos = screenPos,
				screenDist = screenDist,
				worldPos = partPos
			}
		end
	end
	
	return bestTarget
end

-- 自瞄执行
local function executeAimbot(deltaTime)
	if tick() - WeaponDetection.lastFireTime > 1.0 then
		detectWeapon()
		WeaponDetection.lastFireTime = tick()
	end
	
	if LockSystem.switchCooldown > 0 then
		LockSystem.switchCooldown = LockSystem.switchCooldown - deltaTime
	end
	
	local newTarget = findTarget()
	
	if shouldSwitchTarget(newTarget) then
		if newTarget then
			LockSystem.lockedPlayer = newTarget.player
			LockSystem.lockedPart = newTarget.part
			LockSystem.lockTime = tick()
		else
			LockSystem.lockedPlayer = nil
			LockSystem.lockedPart = nil
		end
	end
	
	if not LockSystem.lockedPlayer or not LockSystem.lockedPlayer.Character then return end
	
	local part = LockSystem.lockedPlayer.Character:FindFirstChild(Settings.TargetPart)
	if not part then
		part = LockSystem.lockedPlayer.Character:FindFirstChild("Head") or 
		        LockSystem.lockedPlayer.Character:FindFirstChild("UpperTorso") or
		        LockSystem.lockedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not part then
			LockSystem.lockedPlayer = nil
			return
		end
	end
	
	local hum = LockSystem.lockedPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		LockSystem.lockedPlayer = nil
		return
	end
	
	local target = {
		player = LockSystem.lockedPlayer,
		char = LockSystem.lockedPlayer.Character,
		part = part,
		hum = hum,
		worldPos = part.Position
	}
	
	local targetPos = getAdaptivePrediction(target)
	local camPos = Camera.CFrame.Position
	local currentLook = Camera.CFrame.LookVector
	local desiredLook = (targetPos - camPos).Unit
	
	local strength = Settings.AimStrength
	local smoothFactor = 0
	
	if strength < 0.3 then
		smoothFactor = 0.12 + (0.3 - strength) * 0.4
	elseif strength < 0.7 then
		smoothFactor = 0.05 + (0.7 - strength) * 0.12
	else
		smoothFactor = 0.015 + (1.0 - strength) * 0.05
	end
	
	smoothFactor = math.clamp(smoothFactor, 0.012, 0.35)
	
	local dist = (targetPos - camPos).Magnitude
	local distFactor = math.clamp(120 / math.max(dist, 20), 0.3, 3.0)
	smoothFactor = smoothFactor * distFactor
	
	if hum.MoveDirection.Magnitude > 0.1 then
		smoothFactor = smoothFactor * 0.65
	end
	
	local frameComp = math.clamp(deltaTime * 60, 0.3, 2.0)
	local lerpFactor = math.clamp(smoothFactor * frameComp, 0.006, 0.5)
	
	local newLook = currentLook:Lerp(desiredLook, lerpFactor).Unit
	local newCFrame = CFrame.lookAt(camPos, camPos + newLook)
	
	Camera.CFrame = newCFrame
end

-- 玩家管理
Players.PlayerAdded:Connect(function(player)
	createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
	removeESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		createESP(player)
	end
end

-- 主循环
RunService.RenderStepped:Connect(function(deltaTime)
	ViewportSize = Camera.ViewportSize
	
	updateFOV()
	updateESP()
	
	if Settings.Aimbot then
		executeAimbot(math.min(deltaTime, 0.1))
	end
	
	UserInputService.MouseDeltaSensitivity = Settings.CameraSens
end)

-- 初始化UI
local scroll = createUI()

local y = 8
createSlider(scroll, "镜头灵敏度", 0.1, 2.5, Settings.CameraSens, function(v) Settings.CameraSens = v end, y, 2)
y = y + 50
createToggle(scroll, "自瞄开关", Settings.Aimbot, function(v) Settings.Aimbot = v end, y)
y = y + 40
createToggle(scroll, "队伍检测", Settings.TeamCheck, function(v) Settings.TeamCheck = v end, y)
y = y + 40
createSlider(scroll, "FOV半径", 30, 350, Settings.FOV, function(v) Settings.FOV = v end, y, 0)
y = y + 50
createDropdown(scroll, "锁定模式", {"磁吸锁定", "软锁", "硬锁"}, Settings.LockMode, function(v) 
	Settings.LockMode = v
	if v == "软锁" then Settings.AimStrength = 0.2
	elseif v == "硬锁" then Settings.AimStrength = 0.9
	else Settings.AimStrength = 0.5 end
end, y)
y = y + 54
createSlider(scroll, "吸附强度", 0.1, 1.0, Settings.AimStrength, function(v) Settings.AimStrength = v end, y, 2)
y = y + 50
createDropdown(scroll, "目标部位", {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, Settings.TargetPart, function(v) Settings.TargetPart = v end, y)
y = y + 54
createToggle(scroll, "智能预判", Settings.Prediction, function(v) Settings.Prediction = v end, y)
y = y + 40
createSlider(scroll, "预判强度", 0.1, 1.5, Settings.PredictionStrength, function(v) Settings.PredictionStrength = v end, y, 2)
y = y + 50
createToggle(scroll, "动态FOV", Settings.DynamicFOV, function(v) Settings.DynamicFOV = v end, y)
y = y + 40
createToggle(scroll, "粘性锁定", Settings.StickyLock, function(v) Settings.StickyLock = v end, y)
y = y + 40
createToggle(scroll, "掩体检测", Settings.VisibilityCheck, function(v) Settings.VisibilityCheck = v end, y)
y = y + 40

-- ESP分区标题
local espLabel = Instance.new("TextLabel")
espLabel.BackgroundTransparency = 1
espLabel.Size = UDim2.new(1, -20, 0, 18)
espLabel.Position = UDim2.new(0, 10, 0, y)
espLabel.Text = "━━ ESP透视设置 ━━"
espLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
espLabel.Font = Enum.Font.GothamBold
espLabel.TextSize = 13
espLabel.TextXAlignment = Enum.TextXAlignment.Center
espLabel.Parent = scroll
y = y + 22

createToggle(scroll, "ESP开关", Settings.ESP, function(v) Settings.ESP = v end, y)
y = y + 40
createToggle(scroll, "显示方框", Settings.ESP_ShowBox, function(v) Settings.ESP_ShowBox = v end, y)
y = y + 40
createToggle(scroll, "显示血条", Settings.ESP_ShowHealth, function(v) Settings.ESP_ShowHealth = v end, y)
y = y + 40
createToggle(scroll, "显示距离", Settings.ESP_ShowDistance, function(v) Settings.ESP_ShowDistance = v end, y)
y = y + 40
createToggle(scroll, "显示名字", Settings.ESP_ShowName, function(v) Settings.ESP_ShowName = v end, y)
y = y + 40
createToggle(scroll, "背敌指向", Settings.ESP_ShowDirection, function(v) Settings.ESP_ShowDirection = v end, y)
y = y + 40
createSlider(scroll, "ESP距离", 100, 1000, Settings.ESP_MaxDistance, function(v) Settings.ESP_MaxDistance = v end, y, 0)

scroll.CanvasSize = UDim2.new(0, 0, 0, y + 60)

print("ZenAim Pro v7.0 已启动")
print("队伍检测 | 4部位选择 | ESP优化方框/血条/名字/距离")