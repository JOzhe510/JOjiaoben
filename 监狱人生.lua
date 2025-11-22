local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IsTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()
local MobileScale = IsMobile and 0.85 or 1
local IslandWidth = IsMobile and 160 or 200
local IslandHeight = IsMobile and 35 or 40
local IslandYPos = IsMobile and 5 or 10
local Window = nil
local ShowIslandNotification = nil
local DynamicIsland = Instance.new("ScreenGui")
DynamicIsland.Name = "OPAI_DynamicIsland"
DynamicIsland.ResetOnSpawn = false
DynamicIsland.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DynamicIsland.Parent = PlayerGui
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, IslandWidth, 0, IslandHeight)
MainFrame.Position = UDim2.new(0.5, -IslandWidth/2, 0, IslandYPos)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = DynamicIsland
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, IsMobile and 18 or 20)
Corner.Parent = MainFrame
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(80, 80, 255)
Stroke.Thickness = IsMobile and 1.2 or 1.5
Stroke.Transparency = 0.5
Stroke.Parent = MainFrame
local Logo = Instance.new("TextLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.new(0, IsMobile and 60 or 80, 1, 0)
Logo.Position = UDim2.new(0, IsMobile and 8 or 10, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "OPAI"
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextSize = IsMobile and 14 or 16
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = MainFrame
local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.new(0, IsMobile and 6 or 8, 0, IsMobile and 6 or 8)
StatusDot.Position = UDim2.new(0, IsMobile and 72 or 95, 0.5, IsMobile and -3 or -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = MainFrame
local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Size = UDim2.new(0, IsMobile and 70 or 80, 1, 0)
TimeLabel.Position = UDim2.new(1, IsMobile and -75 or -90, 0, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "00:00:00"
TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeLabel.TextSize = IsMobile and 12 or 14
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
TimeLabel.Parent = MainFrame
local IsShowingNotification = false
local NotificationQueue = {}
local ClickButton = Instance.new("TextButton")
ClickButton.Size = UDim2.new(1, 0, 1, 0)
ClickButton.BackgroundTransparency = 1
ClickButton.Text = ""
ClickButton.ZIndex = 15
ClickButton.AutoButtonColor = false
ClickButton.Parent = MainFrame
local clickStartTime = 0
local isDragging = false
local originalPos = MainFrame.Position
ClickButton.MouseEnter:Connect(function()
	if not IsShowingNotification then
		local hoverWidth = IslandWidth + (IsMobile and 8 or 10)
		local hoverHeight = IslandHeight + (IsMobile and 2 or 2)
		TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, hoverWidth, 0, hoverHeight),
			Position = UDim2.new(0.5, -hoverWidth/2, originalPos.Y.Scale, originalPos.Y.Offset - 1)
		}):Play()
	end
end)
ClickButton.MouseLeave:Connect(function()
	if not IsShowingNotification then
		TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, IslandWidth, 0, IslandHeight),
			Position = originalPos
		}):Play()
	end
end)
ClickButton.MouseButton1Down:Connect(function()
	clickStartTime = tick()
	isDragging = false
	if not IsShowingNotification then
		local pressWidth = IslandWidth - 5
		local pressHeight = IslandHeight - 1
		TweenService:Create(MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, pressWidth, 0, pressHeight),
			Position = UDim2.new(0.5, -pressWidth/2, originalPos.Y.Scale, originalPos.Y.Offset + 0.5)
		}):Play()
	end
end)
ClickButton.MouseButton1Up:Connect(function()
	local clickDuration = tick() - clickStartTime
	if not IsShowingNotification then
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, IslandWidth, 0, IslandHeight),
			Position = originalPos
		}):Play()
	end
	if clickDuration < 0.3 and not isDragging then
		local VirtualInputManager = game:GetService("VirtualInputManager")
		task.spawn(function()
			task.wait(0.15)
			pcall(function()
				local keyCode = IsMobile and Enum.KeyCode.RightShift or Enum.KeyCode.K
				VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
				task.wait(0.05)
				VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
			end)
		end)
	end
end)
local dragging = false
local dragInput, dragStart, startPos
local function updateDrag(input)
	local delta = input.Position - dragStart
	local distance = delta.Magnitude
	if distance > 5 then
		isDragging = true
	end
	local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	MainFrame.Position = newPos
	originalPos = newPos
end
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if isDragging then
					MainFrame.Size = UDim2.new(0, 200, 0, 40)
				end
			end
		end)
	end
end)
MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateDrag(input)
	end
end)
local NotifIcon = Instance.new("TextLabel")
NotifIcon.Name = "NotifIcon"
NotifIcon.Size = UDim2.new(0, IsMobile and 30 or 35, 0, IsMobile and 30 or 35)
NotifIcon.Position = UDim2.new(0, IsMobile and 12 or 15, 0.5, IsMobile and -15 or -17.5)
NotifIcon.BackgroundTransparency = 1
NotifIcon.Text = "✓"
NotifIcon.TextColor3 = Color3.fromRGB(0, 255, 150)
NotifIcon.TextSize = IsMobile and 20 or 24
NotifIcon.Font = Enum.Font.GothamBold
NotifIcon.Visible = false
NotifIcon.ZIndex = 5
NotifIcon.Parent = MainFrame
local NotifTextContainer = Instance.new("Frame")
NotifTextContainer.Name = "NotifText"
NotifTextContainer.Size = UDim2.new(1, IsMobile and -80 or -100, 1, 0)
NotifTextContainer.Position = UDim2.new(0, IsMobile and 45 or 55, 0, 0)
NotifTextContainer.BackgroundTransparency = 1
NotifTextContainer.Visible = false
NotifTextContainer.ZIndex = 5
NotifTextContainer.Parent = MainFrame
local NotifTitle = Instance.new("TextLabel")
NotifTitle.Name = "Title"
NotifTitle.Size = UDim2.new(1, 0, 0, IsMobile and 18 or 20)
NotifTitle.Position = UDim2.new(0, 0, 0, IsMobile and 6 or 8)
NotifTitle.BackgroundTransparency = 1
NotifTitle.Text = "标题"
NotifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
NotifTitle.TextSize = IsMobile and 13 or 15
NotifTitle.Font = Enum.Font.GothamBold
NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
NotifTitle.TextTruncate = Enum.TextTruncate.AtEnd
NotifTitle.Parent = NotifTextContainer
local NotifContent = Instance.new("TextLabel")
NotifContent.Name = "Content"
NotifContent.Size = UDim2.new(1, 0, 0, IsMobile and 16 or 18)
NotifContent.Position = UDim2.new(0, 0, 0, IsMobile and 24 or 28)
NotifContent.BackgroundTransparency = 1
NotifContent.Text = "内容"
NotifContent.TextColor3 = Color3.fromRGB(180, 180, 180)
NotifContent.TextSize = IsMobile and 10 or 12
NotifContent.Font = Enum.Font.Gotham
NotifContent.TextXAlignment = Enum.TextXAlignment.Left
NotifContent.TextTruncate = Enum.TextTruncate.AtEnd
NotifContent.Parent = NotifTextContainer
local function ShowIslandNotification(title, content, notifType)
	if IsShowingNotification then
		table.insert(NotificationQueue, {title = title, content = content, notifType = notifType or "info"})
		return
	end
	IsShowingNotification = true
	local iconColor, iconText, strokeColor
	if notifType == "success" then
		iconColor = Color3.fromRGB(0, 255, 150)
		iconText = "✓"
		strokeColor = Color3.fromRGB(0, 255, 150)
	elseif notifType == "error" then
		iconColor = Color3.fromRGB(255, 80, 80)
		iconText = "✕"
		strokeColor = Color3.fromRGB(255, 80, 80)
	elseif notifType == "warning" then
		iconColor = Color3.fromRGB(255, 200, 0)
		iconText = "⚠"
		strokeColor = Color3.fromRGB(255, 200, 0)
	else
		iconColor = Color3.fromRGB(100, 150, 255)
		iconText = "ℹ"
		strokeColor = Color3.fromRGB(100, 150, 255)
	end
	NotifIcon.TextColor3 = iconColor
	NotifIcon.Text = iconText
	NotifTitle.Text = title
	NotifContent.Text = content
	local notifOriginalSize = UDim2.new(0, IslandWidth, 0, IslandHeight)
	local notifOriginalPos = originalPos
	local originalStrokeColor = Stroke.Color
	local originalStrokeThickness = Stroke.Thickness
	MainFrame.Size = notifOriginalSize
	MainFrame.Position = notifOriginalPos
	Logo.Visible = false
	StatusDot.Visible = false
	TimeLabel.Visible = false
	NotifIcon.Visible = true
	NotifTextContainer.Visible = true
	local expandedWidth = IsMobile and 260 or 320
	local expandedHeight = IsMobile and 50 or 60
	local expandTween = TweenService:Create(
		MainFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0, expandedWidth, 0, expandedHeight),
			Position = UDim2.new(0.5, -expandedWidth/2, notifOriginalPos.Y.Scale, notifOriginalPos.Y.Offset)
		}
	)
	local strokeColorTween = TweenService:Create(
		Stroke,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Color = strokeColor, Thickness = 2}
	)
	expandTween:Play()
	strokeColorTween:Play()
	task.wait(3.5)
	local shrinkTween = TweenService:Create(
		MainFrame,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
		{
			Size = notifOriginalSize,
			Position = notifOriginalPos
		}
	)
	local strokeResetTween = TweenService:Create(
		Stroke,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Color = originalStrokeColor, Thickness = originalStrokeThickness}
	)
	shrinkTween:Play()
	strokeResetTween:Play()
	task.wait(0.3)
	NotifIcon.Visible = false
	NotifTextContainer.Visible = false
	Logo.Visible = true
	StatusDot.Visible = true
	TimeLabel.Visible = true
	task.wait(0.2)
	IsShowingNotification = false
	originalPos = notifOriginalPos
	if #NotificationQueue > 0 then
		local nextNotif = table.remove(NotificationQueue, 1)
		ShowIslandNotification(nextNotif.title, nextNotif.content, nextNotif.notifType)
	end
end
task.spawn(function()
	while task.wait(1) do
		TimeLabel.Text = os.date("%H:%M:%S")
		TweenService:Create(StatusDot, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
		task.wait(0.5)
		TweenService:Create(StatusDot, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
	end
end)
local function CreateDesktopUI()
	Window = UILibrary.new({
		Name = "OPAI HUB",
		Keybind = "K",
		TextSize = 15,
	})
	Window:DrawCategory({Name = "━━━ 主菜单 ━━━"})
local HomeTab = Window:DrawTab({Name = "主页", Icon = "home", EnableScrolling = true});
local PrisonTab = Window:DrawTab({Name = "监狱人生", Icon = "alert-octagon", EnableScrolling = true});
local SettingsTab = Window:DrawTab({Name = "设置", Icon = "settings", EnableScrolling = true});
local WelcomeSection = HomeTab:DrawSection({Name = "━━━ OPAI HUB v1.0 ━━━"});
local InfoSection = HomeTab:DrawSection({Name = "━━━ 开发信息 ━━━"});
local AdSection = HomeTab:DrawSection({Name = "━━━ 加群获取最新版本 ━━━"});
local ThanksSection = HomeTab:DrawSection({Name = "━━━ 感谢支持 ━━━"});

-- 武器传送功能
local WeaponSection = PrisonTab:DrawSection({Name = "武器传送"});

WeaponSection:AddButton({
	Name = "获取喷子",
	Callback = function()
		local character = LocalPlayer.Character
		if not character then return end
		
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoidRootPart then return end
		
		humanoidRootPart.CFrame = CFrame.new(820.33, 100.88, 2216.97)
		
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		
		ShowIslandNotification("传送成功", "已传送到 喷子 位置", "success")
	end
})

WeaponSection:AddButton({
	Name = "获取M9",
	Callback = function()
		local character = LocalPlayer.Character
		if not character then return end
		
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoidRootPart then return end
		
		humanoidRootPart.CFrame = CFrame.new(813.25, 101.00, 2217.21)
		
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		
		ShowIslandNotification("传送成功", "已传送到 M9 位置", "success")
	end
})

WeaponSection:AddButton({
	Name = "获取AK",
	Callback = function()
		local character = LocalPlayer.Character
		if not character then return end
		
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoidRootPart then return end
		
		humanoidRootPart.CFrame = CFrame.new(-931.53, 94.31, 2038.86)
		
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		
		ShowIslandNotification("传送成功", "已传送到 AK 位置", "success")
	end
})

-- 自动射击功能
local ShootSection = PrisonTab:DrawSection({Name = "自动射击"});

local autoShootEnabled = false
local shootLoop

local function getNearestHead()
    local nearestDistance = 500
    local nearestHead = nil
    local nearestPlayer = nil
    
    local localHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not localHead then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local head = player.Character:FindFirstChild("Head")
        if not head then continue end
        
        local distance = (localHead.Position - head.Position).Magnitude
        if distance <= 500 and distance < nearestDistance then
            nearestDistance = distance
            nearestHead = head
            nearestPlayer = player
        end
    end
    
    return nearestHead, nearestPlayer
end

ShootSection:AddToggle({
	Name = "自动射击",
	Default = false,
	Flag = "AutoShoot",
	Callback = function(state)
		autoShootEnabled = state
		if state then
			if shootLoop then
				shootLoop:Disconnect()
				shootLoop = nil
			end
			
			shootLoop = game:GetService("RunService").Heartbeat:Connect(function()
				if not autoShootEnabled then return end
				
				local Event = game:GetService("ReplicatedStorage"):FindFirstChild("GunRemotes"):FindFirstChild("ShootEvent")
				if not Event then return end
				
				local nearestHead, nearestPlayer = getNearestHead()
				
				if nearestHead and nearestPlayer then
					local character = LocalPlayer.Character
					local rootPart = character and character:FindFirstChild("HumanoidRootPart")
					
					if rootPart then
						local direction = (nearestHead.Position - rootPart.Position).Unit
						local shootCFrame = CFrame.new(rootPart.Position, rootPart.Position + direction)
						
						Event:FireServer({
							{
								rootPart.Position,
								nearestHead.Position,
								workspace:FindFirstChild(nearestPlayer.Name):FindFirstChild("Head"),
								shootCFrame
							}
						})
					end
				end
			end)
			
			ShowIslandNotification("自动射击", "已开启", "success")
		else
			if shootLoop then
				shootLoop:Disconnect()
				shootLoop = nil
			end
			
			ShowIslandNotification("自动射击", "已关闭", "info")
		end
	end
})

task.wait(1)
if IsMobile then
	ShowIslandNotification("OPAI HUB", "手机版v1.0 - 开发者: OPAI工作室 - XiaoMao", "success")
	task.wait(3.5)
	ShowIslandNotification("QQ群", "154919631 加群获取源码和最新版", "info")
	task.wait(3.5)
	ShowIslandNotification("欢迎", "手机版加载成功 点击灵动岛打开菜单", "success")
	task.wait(1.5)
	ShowIslandNotification("提示", "已添加武器传送和自动射击功能", "info")
else
	ShowIslandNotification("OPAI HUB", "电脑版v1.0 - 开发者: OPAI工作室 - XiaoMao", "success")
	task.wait(3.5)
	ShowIslandNotification("QQ群", "154919631 加群获取源码和最新版", "info")
	task.wait(3.5)
	ShowIslandNotification("欢迎", "v1.0 加载成功 按K键或点击灵动岛", "success")
end
end

CreateDesktopUI()