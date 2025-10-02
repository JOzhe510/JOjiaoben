local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/VeaMSRZK"))()
OrionLib:MakeNotification({
                    Name = "JOJOnb！！！",
                    Content = "JO脚本已为您加载成功",
                    Time = 5
                })     
print("索引开启反挂机")
Start = tick()
		local vu = game:GetService("VirtualUser")
		game:GetService("Players").LocalPlayer.Idled:connect(function()
		   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		   wait(1)
		   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		end)      
Start = tick()
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/BINjiaobzx6/BINjiao/main/XK%E7%94%A8%E6%88%B7%E7%95%8C%E9%9D%A2.txt", true))()
    local window = library:new("JO脚本【测试版】")
    local creds = window:Tab("关于", "992417778")
    local bin = creds:section("信息", true)
    bin:Label("你的注入器:" .. identifyexecutor())
    bin:Label("你的地图id:"..game.PlaceId)
    bin:Label("你的用户名:"..game.Players.LocalPlayer.Character.Name)
    bin:Label("基本全缝合，所以源码没有加密")    
    bin:Label("不知道更新(缝合)什么了")
    bin:Label("本脚本可能很垃圾")
    bin:Label("正在努力制作此脚本")
    bin:Label("创作日期：忘了")
    bin:Label("更新时间：2025年5月1日，只更新了一些小功能")
    
    bin:Button("复制作者qq", function()
    setclipboard("110")
end)
    bin:Button("复制root教程", function()
    setclipboard("删除date就可以了")
end)
    bin:Button("复制领取100万r币教程", function()
    setclipboard("万華鏡血輪眼の幻術の中にひっそりとしているのだろう")
end)

local creds = window:Tab("通用", "992417778")
    local credits = creds:section("通用内容", true)
    
credits:Slider('修改速度', 'WalkspeedSlider', 16, 16, 99999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

credits:Slider('修改跳跃', 'Sliderflag',  50, 50, 999999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
	end)
	
	credits:Slider('修改重力', 'Sliderflag',  190, 190, 999999,false, function(Value)
	game.Workspace.Gravity = Value
	end)
	
	credits:Slider('相机焦距【正常为70】', 'Sliderflag', 70, 0.1, 250, false, function(v)
        game.Workspace.CurrentCamera.FieldOfView = v
end)

	credits:Button(
        "工具包",
        function()
	loadstring(game:HttpGet("https://cdn.wearedevs.net/scripts/BTools.txt"))()
end)

        credits:Button(
        "指令脚本",
        function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
        end)
        
        credits:Button(
        "NA管理员",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))()
        end)
        
        credits:Button(
        "聊天绕过",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BingusWR/Fechatbypassroblox/refs/heads/main/Fe%20Roblox%20ChatBypass"))()
        end)
        
        credits:Button(
        "灵魂出窍",
        function()
        loadstring(game:HttpGet("https://pastebin.com/raw/ahK5jRxM"))()
        end)
        
        credits:Button(
        "动作变卡",
        function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Fe%20Fake%20Lag%20Obfuscator'))()
        end)
        
        credits:Button(
        "认真反复横跳",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe/main/obf_11l7Y131YqJjZ31QmV5L8pI23V02b3191sEg26E75472Wl78Vi8870jRv5txZyL1.lua.txt"))()
        end)
        
        
        
        credits:Button(
        "定住自己",
        function()
        loadstring(game:HttpGet("https://pastebin.com/raw/YrfBSuWw"))()
        end)

        
        credits:Button(
        "帽子旋转",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BingusWR/Fe-Spinning-Hat-Script/refs/heads/main/Fe%20Spinning%20Hats%20Script"))()
        end)
        
        credits:Button(
        "无头和kor",
        function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Permanent-Headless-And-korblox-Script-4140"))()
        end)
        
        
        
        credits:Button(
        "R15变R6",
        function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-R6-Animations-on-R15-16865"))()
        end)
        
        credits:Button(
        "键盘脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Xxtan31/Ata/main/deltakeyboardcrack.txt", true))()
        end)
        
        credits:Button(
        "人物旋转",
        function()
        BY = "退休"
script = "免费开源"
QUN = "809771141"
fling = loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/TUIXUI_qun-809771141/refs/heads/TUIXUI/fling"))()
        end)

    credits:Button(
        "隐身",
        function()
        loadstring(game:HttpGet('https://pastebin.com/raw/3Rnd9rHf'))()
        end)
        
        credits:Button(
        "隐身2",
        function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/skid123skidlol/cd0d2dce51b3f20ad1aac941da06a1a1/raw/f58b98cce7d51e53ade94e7bb460e4f24fb7e0ff/%257BFE%257D%2520Invisible%2520Tool%2520(can%2520hold%2520tools)",true))()
        end)
        
        credits:Button(
        "ESP",
        function()
        local Players = game:GetService("Players"):GetChildren() local RunService = game:GetService("RunService") local highlight = Instance.new("Highlight") highlight.Name = "Highlight" for i, v in pairs(Players) do repeat wait() until v.Character if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then local highlightClone = highlight:Clone() highlightClone.Adornee = v.Character highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart") highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop highlightClone.Name = "Highlight" end end game.Players.PlayerAdded:Connect(function(player) repeat wait() until player.Character if not player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then local highlightClone = highlight:Clone() highlightClone.Adornee = player.Character highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart") highlightClone.Name = "Highlight" end end) game.Players.PlayerRemoving:Connect(function(playerRemoved) playerRemoved.Character:FindFirstChild("HumanoidRootPart").Highlight:Destroy() end) RunService.Heartbeat:Connect(function() for i, v in pairs(Players) do repeat wait() until v.Character if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then local highlightClone = highlight:Clone() highlightClone.Adornee = v.Character highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart") highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop highlightClone.Name = "Highlight" task.wait() end end end)
end)
        
        credits:Button(
        "ESP2(这个更好",
        function()
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
	
        credits:Button(
        "自瞄(单锁一人身体，那人死后需要点下按钮取消",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Aepione/Prensado/refs/heads/main/Prensado%20camlock"))()
        end)
        
        credits:Button(
        "自瞄2(锁头但不单锁，有墙体检测",
        function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimlock-45467"))()
        end)
        

credits:Button(
        "踏空行走",
        function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float'))()
        end)
        
        credits:Button(
        "动作脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Free-emote/refs/heads/main/Delta%20mad%20stuffs"))()
        end)

credits:Button(
        "无限跳",
        function()
        loadstring(game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true))()
        end)
        
        credits:Button(
        "vape",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
        end)
        

credits:Button(
        "点击传送工具",
        function()
        mouse = game.Players.LocalPlayer:GetMouse() tool = Instance.new("Tool") tool.RequiresHandle = false tool.Name = "[FE] TELEPORT TOOL" tool.Activated:connect(function() local pos = mouse.Hit+Vector3.new(0,2.5,0) pos = CFrame.new(pos.X,pos.Y,pos.Z) game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos end) tool.Parent = game.Players.LocalPlayer.Backpack
        end)

credits:Button(
        "防踢",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Anti-Kick/main/Anti%20Kick.lua"))()
        end)
        
        credits:Button(
        "过部分游戏检测(注:不是百分百不会封，被举报后管理员封你还是会封，只是不会被检测",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua", true))()
        end)

credits:Button(
        "反挂机",
        function()
        print("Anti Afk On")

		wait(2)
	print("Anti Afk On")
		local vu = game:GetService("VirtualUser")
		game:GetService("Players").LocalPlayer.Idled:connect(function()
		   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		   wait(1)
		   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		end)
	local CoreGui = game:GetService("StarterGui")
CoreGui:SetCore("SendNotification", {
    Title = "JO提示5秒",
    Text = "防挂机已开启",
    Duration = 5,
})
        end
    )
    
    credits:Button(
        "甩飞",
        function()
        loadstring(game:HttpGet('https://pastebin.com/raw/hQSBGsw2'))()
        end)

credits:Button(
        "飞行V3",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
end)

credits:Button(
        "飞车",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/llz162652/COAv1.5/main/By.pop.cat.kun/pop%2Ccat%2Ckun%E7%BF%BB%E8%AF%91%E7%9A%84%E9%A3%9E%E8%BD%A6"))()
        end)

credits:Button(
        "自杀",
        function()
        game.Players.LocalPlayer.Character.Humanoid.Health=0
end)

    credits:Button(
        "铁拳",
        function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt'))()
end)

credits:Button(
        "全部甩飞",
        function()
        local Targets = {"All"} -- "All", "Target Name", "arian_was_here"

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local AllBool = false

local GetPlayer = function(Name)
    Name = Name:lower()
    if Name == "all" or Name == "others" then
        AllBool = true
        return
    elseif Name == "random" then
        local GetPlayers = Players:GetPlayers()
        if table.find(GetPlayers,Player) then table.remove(GetPlayers,table.find(GetPlayers,Player)) end
        return GetPlayers[math.random(#GetPlayers)]
    elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
        for _,x in next, Players:GetPlayers() do
            if x ~= Player then
                if x.Name:lower():match("^"..Name) then
                    return x;
                elseif x.DisplayName:lower():match("^"..Name) then
                    return x;
                end
            end
        end
    else
        return
    end
end

local Message = function(_Title, _Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
end

local SkidFling = function(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart

    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle

    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessoy and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit and not AllBool then
            return Message("Error Occurred", "Targeting is sitting", 5) -- u can remove dis part if u want lol
        end
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()

                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("Error Occurred", "Target is missing everything", 5)
        end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x)
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        return Message("Error Occurred", "Random error", 5)
    end
end

if not Welcome then Message("Script by AnthonyIsntHere", "Enjoy!", 5) end
getgenv().Welcome = true
if Targets[1] then for _,x in next, Targets do GetPlayer(x) end else return end

if AllBool then
    for _,x in next, Players:GetPlayers() do
        SkidFling(x)
    end
end

for _,x in next, Targets do
    if GetPlayer(x) and GetPlayer(x) ~= Player then
        if GetPlayer(x).UserId ~= 1414978355 then
            local TPlayer = GetPlayer(x)
            if TPlayer then
                SkidFling(TPlayer)
            end
        else
            Message("Error Occurred", "This user is whitelisted! (Owner)", 5)
        end
    elseif not GetPlayer(x) and not AllBool then
        Message("Error Occurred", "Username Invalid", 5)
    end
end

  	end)
         
credits:Button(
        "单个甩人",
        function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/ScpGuest666/Random-Roblox-script/refs/heads/main/Roblox%20fling%20script'))()
        end)
        
        credits:Button(
        "碰到就飞",
        function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/0Ben1/fe/main/obf_5wpM7bBcOPspmX7lQ3m75SrYNWqxZ858ai3tJdEAId6jSI05IOUB224FQ0VSAswH.lua.txt'),true))()
        end)
        
        credits:Button(
        "一个比较实用的脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
        end)

credits:Button(
        "防甩飞",
        function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Linux6699/DaHubRevival/main/AntiFling.lua'))()
        end)

        credits:Button(
        "通用子弹追踪",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ATLASTEAM01/SilentAim/refs/heads/main/Version/1.3.2"))()
        end)


        local creds = window:Tab("范围", "992417778")
    local credits = creds:section("范围内容", true)
    
    credits:Button(
        "范围10",
        function()
    _G.HeadSize = 10 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围20",
        function()
    _G.HeadSize = 20 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围30",
        function()
    _G.HeadSize = 30 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围40",
        function()
    _G.HeadSize = 40 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围50",
        function()
    _G.HeadSize = 50 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围60",
        function()
    _G.HeadSize = 60 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围70",
        function()
    _G.HeadSize = 70 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围80",
        function()
    _G.HeadSize = 80 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围90",
        function()
    _G.HeadSize = 90 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围100",
        function()
    _G.HeadSize = 100 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围150",
        function()
    _G.HeadSize = 150 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围200",
        function()
    _G.HeadSize = 200 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围250",
        function()
    _G.HeadSize = 250 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

credits:Button(
        "范围300",
        function()
    _G.HeadSize = 300 _G.Disabled = true game:GetService('RunService').RenderStepped:connect(function() if _G.Disabled then for i,v in next, game:GetService('Players'):GetPlayers() do if v.Name ~= game:GetService('Players').LocalPlayer.Name then pcall(function() v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize) v.Character.HumanoidRootPart.Transparency = 0.7 v.Character.HumanoidRootPart.BrickColor = BrickColor.new("Really blue") v.Character.HumanoidRootPart.Material = "Neon" v.Character.HumanoidRootPart.CanCollide = false end) end end end end)
end)

local creds = window:Tab("视角大小更改", "992417778")
    local credits = creds:section("内容", true)
    
    credits:Button(
        "更改60",
        function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

player:WaitForChild("PlayerGui")

local targetFOV = 60
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
      
      credits:Button(
        "更改75",
        function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

player:WaitForChild("PlayerGui")

local targetFOV = 75
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

credits:Button(
        "更改90",
        function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

player:WaitForChild("PlayerGui")

local targetFOV = 90
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

credits:Button(
        "更改",
        function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

player:WaitForChild("PlayerGui")

local targetFOV = 105
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

credits:Button(
        "更改120",
        function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

player:WaitForChild("PlayerGui")

local targetFOV = 120
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

credits:Button(
        "更改150",
        function()
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

local creds = window:Tab("射击类游戏脚本", "992417778")
    local credits = creds:section("内容", true)
    
    credits:Button(
        "自瞄",
        function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimlock-45467"))()
        end)
        
        credits:Button(
        "部分游戏",
        function()loadstring(game:HttpGet("https://raw.githubusercontent.com/CookieScript/Fixscript/refs/heads/main/Psalmsfix"))()
        end)
        
        credits:Button(
        "子追",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ATLASTEAM01/SilentAim/refs/heads/main/Version/1.3.2"))()
        end)

local creds = window:Tab("好用的部分服务器脚本", "992417778")
    local credits = creds:section("内容", true)
    
    
    credits:Button(
        "安脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Anscripterato/QQ2134702438/refs/heads/main/byato/AnScript/atoscript"))()
        end)
        
        credits:Button(
        "NOL免费版",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Syndromehsh/BETA2/refs/heads/main/NOL"))()
        end)
        
        credits:Button(
        "自制的另一个垃圾脚本(这就是世界最强🤓",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/roblox关于复活功能1.lua"))()
        end)
        
        credits:Button(
        "Maxhub(需解卡密跟下面一样",
        function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/e115b107e044a8cfc35b87ce573d558f.lua"))()
        end)
        
        credits:Button(
        "speedHUB",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
        end)

local creds = window:Tab("黑洞", "992417778")
    local credits = creds:section("吸起来!", true)
    
    credits:Button(
        "黑洞(已翻译",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/llz162652/COAv1.5/main/By.pop.cat.kun/%E5%B7%B2%E5%BC%80%E6%BA%90%E9%BB%91%E6%B4%9E%E8%84%9A%E6%9C%AC%E7%BF%BB%E8%AF%91pop.kat.kun"))()
        end)
        
        credits:Button(
        "黑洞",
        function()
        loadstring(game:HttpGet("https://pastebin.com/raw/7V8KH60M"))()
        end)
        

local creds = window:Tab("整活脚本!", "992417778")
    local credits = creds:section("整活脚本!", true)
    
    credits:Button(
        "别点!",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/IIIlll1ll1/Cracks/main/AdvancedLogic_Crack.lua"))()
        end)
        
        
        
        credits:Button(
        "假延迟",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DROID-cell-sys/ANTI-UTTP-SCRIPTT/refs/heads/main/EGOR%20SCRIPT%20BY%20ANTI-UTTP"))()
        end)

        

        credits:Button(
        "假vr脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty45.lua"))()
        end)
       
       credits:Button(
        "假朋友脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sigmaboy123z/MYFRIENDSCRIPT/refs/heads/main/MYNEWFRIENDSPAWNER"))()
        end)
        
        credits:Button(
        "打飞机道具R6🤓(有些服务器用不了)",
        function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-jerk-off-25958"))()
        end)
        
        credits:Button(
        "打飞机道具R15🤓(有些服务器用不了)",
        function()
        loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
        end)
        
        local creds = window:Tab("用来制作脚本的", "992417778")
    local credits = creds:section("制作脚本用的", true)
    
    credits:Button(
        "DEX脚本",
        function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Keyless-mobile-dex-17888"))()
        end)
        
        credits:Button(
        "spy脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Finaloutcome/plz/refs/heads/main/simplespy"))()
        end)
        
        
        local creds = window:Tab("力量传奇", "992417778")
    local credits = creds:section("力量传奇内容", true)
        
        credits:Button(
        "力量传奇1",
        function()
        KingScript = "By LN" Roblox= "霖溺Script"
KingTeam= "LegendofPower"
loadstring(game:HttpGet("https://raw.githubusercontent.com/ShenJiaoBen/Partial-Server-Ribbon/refs/heads/main/LN%E5%8A%9B%E9%87%8F.lua"))()
        end)
        
        credits:Button(
        "力量传奇2",
        function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/wucan114514/gegeyxjb/refs/heads/main/%E5%AE%89%E8%84%9A%E6%9C%AC.lua')))()
        end)
        

        credits:Button(
        "力量传奇3",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
        end)
        
        credits:Button(
        "力量传奇4",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Anscripterato/QQ2134702438/refs/heads/main/byato/AnScript/atoscript"))()
        end)
        
        
        credits:Button(
        "自动吃蛋",
        function()
        loadstring(game:HttpGet("https://raw.github.com/114514541883484/Zephyr-wave/main/agreement.lua"))()
        end)
        
        credits:Button(
        "永久免费自动切换宠物",
        function()
        loadstring(game:HttpGet("https://raw.github.com/f20i30s40h/Crack/main/Cracked-ShuiJiaoScript.lua"))("力量传奇切换宠物")
        end)
        
        credits:Button(
        "买守护者",
        function()
        game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild("Neon Guardian"))
        end)
        
        credits:Button(
        "买肌肉老师",
        function()
        game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild("Muscle Sensei"))
        end)
        
        credits:Button(
        "买暗星",
        function()
        game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild("Darkstar Hunter"))
        end)
        
        credits:Button(
        "买肌肉之王光环",
        function()
        game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild("Muscle King"))
        end)
        
        local creds = window:Tab("死铁轨", "992417778")
    local credits = creds:section("脚本内容", true)
    credits:Button(
        "该有的功能都有(中文",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/iopjklbnmsss/SansHubScript/refs/heads/main/SansHub"))()
        end)
        
        credits:Button(
        "功能齐全的脚本(功能自己翻译",
        function()
        loadstring(game:HttpGet("https://lunor.dev/loader"))()
        end)
        
        credits:Button(
        "快速攻击(快速攻击有两个，两个不要一起开会被踢",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/HeadHarse/Dusty/refs/heads/main/NOTV4TRUST"))()
        end)
        
        credits:Button(
        "超多功能",
        function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/aceurss/AcxScripter/refs/heads/main/CapriHub-DeadRails'))()
        end)
        
        credits:Button(
        "复制物品和放大物品脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GRPGaming/Key-System/refs/heads/Xycer-Hub-Script/Hellos"))()
        end)
        
        credits:Button(
        "自动刷债券(功能自己翻译",
        function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/hungquan99/SkullHub/main/loader.lua'))()
        end)
        
        credits:Button(
        "tx刷债券(无需卡密，上面的要)",
        function()
        --[[by 退休不退休]]QUN = "160369111"TX = "死铁轨刷债券V3"script = "死铁轨免费刷债券"loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/%E5%88%B7%E5%80%BA%E5%88%B8"))()
        end)
        
        local creds = window:Tab("犯罪", "992417778")
    local credits = creds:section("犯罪内容", true)
    
    credits:Button(
        "criminologylight",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/PresidentAnvil/crimlight/main/criminologylight.lua"))()
        end)
        
        credits:Button(
        "ghost",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyu4t55567rgdf/fling/refs/heads/main/Loader.lua"))()
        end)
        
        credits:Button(
        "愤怒机器人ragebot",
        function()
        (function()local _G={}local a=string;local b=a.char;local c=loadstring;local d=game;local e=d.HttpGet;local f=e(d,b(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,115,107,101,45,99,111,100,101,47,87,101,105,114,100,82,66,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,80,114,111,116,101,99,116,101,100,95,54,57,51,52,48,50,51,52,52,52,56,49,49,57,53,56,46,108,117,97,46,116,120,116))c(f)()end)()
        end)
        
        credits:Button(
        "JX(需解卡密",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jianlobiano/LOADER/refs/heads/main/JX-CRIMINALITY"))()
        end)
        
        credits:Button(
        "vape",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
        end)
        
        credits:Button(
        "不知道什么脚本",
        function()
        loadstring(game:HttpGet("https://you.whimper.xyz/sources/infernium/Criminality.lua"))()
        end)
        
        credits:Button(
        "功能齐全的脚本(有bang追踪手机可用这个调速度",
        function()
        writefile("Rayfield/Key System/Key123.rfld","NoHomo");loadstring(game:HttpGet("https://raw.githubusercontent.com/LisSploit/FemboysHubBoosr/2784d6c4ede4340ad9af4865828d915ffc26c7bb/Criminality"))()
        end)
        
        credits:Button(
        "criminology",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/PresidentAnvil/temp-criminology/refs/heads/main/criminology.lua"))()
        end)
        
        
        

        
        local creds = window:Tab("极速传奇", "992417778")
    local credits = creds:section("极速传奇内容", true)
    
    credits:Button(
        "极速传奇1",
        function()
        KingScript = "By LN" Roblox= "霖溺Script"KingTeam= "SpeedLegend" loadstring(game:HttpGet("https://raw.githubusercontent.com/ShenJiaoBen/Partial-Server-Ribbon/refs/heads/main/LN%E6%9E%81%E9%80%9F.lua"))()
        end)
        
        credits:Button(
        "极速传奇2",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Anscripterato/QQ2134702438/refs/heads/main/byato/AnScript/atoscript"))()
        end)
        
        local creds = window:Tab("忍者传奇", "992417778")
    local credits = creds:section("忍者传奇内容", true)
    
    credits:Button(
        "忍者传奇1",
        function()
        KingScript = "By LN" Roblox= "霖溺Script"KingTeam= "LegendofNinja" loadstring(game:HttpGet("https://raw.githubusercontent.com/ShenJiaoBen/Partial-Server-Ribbon/refs/heads/main/LN%E5%BF%8D%E8%80%85.lua"))()
        end)
        
        credits:Button(
        "无限金币(用法自己摸索)",
        function()
        loadstring(game:HttpGet("https://pastebin.com/raw/mS3pA0js"))()
        end)
        
        credits:Button(
        "用上面脚本弄到满元素影子后再用这个点start，金币变成nan就可以交易了，不用管5000金币解锁交易直接点",
        function()
        loadstring(game:HttpGet("https://pastebin.com/raw/CPSK3k0T"))()
        end)
        
        credits:Button(
        "忍者传奇2",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Anscripterato/QQ2134702438/refs/heads/main/byato/AnScript/atoscript"))()
        end)
        
        local creds = window:Tab("破坏者谜团", "992417778")
    local creditsHUB = creds:section("脚本内容", true)

creditsHUB:Button(
        "Highlight MM2",
        function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ThatSick/HighlightMM2/main/Main"))()
        end
    )   
   
   creditsHUB:Button("复制上面卡密", function()
    setclipboard("hlvipcomingsoon")
end)
   
   creditsHUB:Button(
        "Ghost Hub",
        function()
           loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/GhostHub'))() 
        end
    )
    
creditsHUB:Button(
        "YARHM",
        function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Joystickplays/psychic-octo-invention/main/yarhm.lua", false))()
        end
    )
   
   creditsHUB:Button(
        "修改武器",
        function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/trdrock/mm2/main/KosyHub"))()
        end
    )
    
    local creds = window:Tab("战斗战士", "992417778")
    local credits = creds:section("内容", true)
    
    credits:Button(
        "脚本1",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ddario66/Test/refs/heads/main/Combat%20warrior"))()
        end)
        
        credits:Button(
        "脚本2",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ddario66/Test/refs/heads/main/Combat%20warrior"))()
        end)
        
        credits:Button(
        "无限体力",
        function()
        loadstring(game:HttpGet("https://shz.al/~KSK"))()
        end)
        
        credits:Button(
        "外网杀人脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/IsaaaKK/cwhb/main/cw.txt"))()
        end)
    
        local creds = window:Tab("BF", "992417778")
    local credits = creds:section("BF", true)
    
    credits:Button(
        "BF好用的脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/Kncrypt/refs/heads/main/sources/BloxFruit.lua"))()
    end)
    
    credits:Button(
        "BF外网脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Omgshit/Scripts/main/MainLoader.lua"))()
        end)
        
        local creds = window:Tab("三叉姬生成", "992417778")
    local credits = creds:section("内容", true)
    
    credits:Button(
        "脚本1(英文",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/SWIMHUBISWIMMING/swimhub/refs/heads/main/free_trident.lua"))()
        end)
        
        credits:Button(
        "脚本2(部分已汉化",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/三叉戟生存.lua"))()
        end)

local creds = window:Tab("小屋角色扮演", "992417778")
    local credits = creds:section("内容", true)
    
    credits:Button(
        "小屋肘击脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CyberNinja103/brodwa/refs/heads/main/JohnDoeClickfling"))()
        end)
        
        local creds = window:Tab("Ficsh", "992417778")
    local credits = creds:section("内容", true)
    
    credits:Button(
        "Ficsh1",
        function()
        script_key="PASTEKEYHERE";
(loadstring or load)(game:HttpGet("https://getnative.cc/script/loader"))()
        end)
        
        credits:Button(
        "Ficsh2",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
        end)
        
        credits:Button(
        "Ficsh3",
        function()
        loadstring(game:HttpGet("https://bonkhubloader.netlify.app",true))()
        end)
        
        credits:Button(
        "卖掉手上拿着的鱼",
        function()
        game:GetService("ReplicatedStorage").events.Sell:InvokeServer()
        end)
        
        credits:Button(
        "卖掉背包所有的鱼(稀有鱼不会被卖)",
        function()
        game:GetService("ReplicatedStorage").events.SellAll:InvokeServer()
        end)
        
        credits:Button(
        "传送到爆率超高点位",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-4251.42529, -11172.4893, 3885.5061, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        end)
        
        credits:Button(
        "传送到爆率超高点位2",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2515.55786, -11221.5352, 6910.12988, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        end)
        
        credits:Button(
        "传送到深度",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(943.756958, -706.108398, 1251.77087, -0.386100113, 0.284740716, -0.87741065, 0, 0.951167107, 0.308676451, 0.92245692, 0.119180016, -0.367245734)
        end)
        
        credits:Button(
        "传送到梅林",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-930.322693, 227.230988, -994.040588, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        end)
        
        credits:Button(
        "传送到守卫祭坛",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1309.84265, -796.916199, -107.134315, -0.922893524, 0.152973562, -0.353364706, 0, 0.917698741, 0.397276968, 0.385055184, 0.366644353, -0.846938312)
        end)
        
        credits:Button(
        "传送到深渊",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1653.52563, -199.001068, -2841.93066, -0.975113094, -0.126666948, 0.181961268, 0, 0.820724964, 0.571323395, -0.22170797, 0.557104945, -0.800299704)
        end)
        
        credits:Button(
        "传送到深渊巅峰",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-13644.931640625, -11031.451171875, 342.4993896484375)
        end)
        
        credits:Button(
        "传送到被遗弃的海岸",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2507.44141, 143.233383, 1563.09326, -0.998476744, -0.0264155734, 0.0484404489, 0, 0.877945065, 0.478761524, -0.0551748052, 0.478032261, -0.876607716)
        end)
        
        credits:Button(
        "传送到购买改变天气图腾的地点",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1149.55713, 145.805634, -1056.40002, 0.99958992, 0.0150282877, -0.0243737847, 0, 0.851205349, 0.524832726, 0.0286344327, -0.524617493, 0.850856364)
        end)
    
        local creds = window:Tab("火箭发射器", "992417778")
    local creditsML = creds:section("功能", true)   
   
creditsML:Button(
        "自动收集燃料",
        function()
          isFuelScoopEnabled = ARL while true do wait() if isFuelScoopEnabled then for i, h in pairs(game.Players.LocalPlayer.Character:GetChildren()) do if h:IsA("Tool") and h.Name == "FuelScoop" then h:Activate() end end end end  
        end
    )
    
creditsML:Button(
        "登上火箭",
        function()   
                 game:GetService("ReplicatedStorage"):WaitForChild("BoardRocket"):FireServer()
        end
    )   
   
creditsML:Button(
        "将玩家从所有座位移除",
        function()
            game:GetService("ReplicatedStorage"):WaitForChild("RemovePlayer"):FireServer()
        end
    )
   
local creditsDSB = creds:section("传送内容", true)
      
creditsDSB:Button(
        "发射台岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-123.15931701660156, 2.7371432781219482, 3.491959810256958)
        end
    )   
   
creditsDSB:Button(
        "白云岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-76.13252258300781, 170.55825805664062, -60.4516716003418)
        end
    )
    
creditsDSB:Button(
        "漂浮岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-66.51714324951172, 720.4866333007812, -5.391753196716309)
        end
    )   
   
creditsDSB:Button(
        "卫星岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-34.2462043762207, 1429.4990234375, 1.3739361763000488)
        end
    )
    
creditsDSB:Button(
        "蜜蜂迷宫岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(6.5361199378967285, 3131.249267578125, -29.759048461914062)
        end
    )   
   
creditsDSB:Button(
        "月球人援救岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-7.212917804718018, 5016.341796875, -19.815933227539062)
        end
    )
    
    creditsDSB:Button(
        "暗物质岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(68.43186950683594, 6851.94091796875, 7.890637397766113)
        end
    )   
   
creditsDSB:Button(
        "太空岩石岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(49.92888641357422, 8942.955078125, 8.674375534057617)
        end
    )
    
creditsDSB:Button(
        "零号火星岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(54.44503402709961, 11270.0927734375, -1.273137092590332)
        end
    )   
   
creditsDSB:Button(
        "太空水晶岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-11.579089164733887, 15295.6318359375, -27.54974365234375)
        end
    )
    
creditsDSB:Button(
        "月球浆果岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-14.601255416870117, 18410.9609375, 0.9418511986732483)
        end
    )   
   
creditsDSB:Button(
        "铺路实岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-3.272758960723877, 22539.494140625, 63.283935546875)
        end
    )
    
creditsDSB:Button(
        "流星岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-45.515689849853516, 27961.560546875, -7.358333110809326)
        end
    )   
   
creditsDSB:Button(
        "升级岛",
        function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2.7595248222351074, 33959.98828125, 53.93095397949219)
        end
    )
    
creditsDSB:Button(
        "QB火箭发射器",
        function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/xinhaoxian2/QB/main/QB%E7%81%AB%E7%AE%AD%E5%8F%91%E5%B0%84%E6%A8%A1%E6%8B%9F%E5%99%A8.lua"))()
        end
    )
   
creditsDSB:Button(
        "Dizzy HUB脚本",
        function()
            loadstring(game:HttpGet(('https://raw.githubusercontent.com/dizyhvh/rbx_scripts/main/321_blast_off_simulator')))()
        end
    )
    
local creds = window:Tab("被遗弃", "992417778")
    local credits = creds:section("被遗弃", true)
    
    credits:Button(
        "被遗弃脚本(超级好用!，需卡密",
        function()
        if getgenv then
    getgenv().BloxtrapRPC = "true"
    getgenv().DebugNotifications = "false"
    getgenv().TrackMePlease = "true"
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/ivannetta/ShitScripts/main/forsaken.lua"))()
        end)
        
        credits:Button(
        "脚本2(卡密BOBBYHUBKEYWJJEBEKEI",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BobJuniorl /ForsakenBol/refs/heads/main/B0bbyHub"))()
        end)
        
        credits:Button(
        "改范围(这个用下面的更好，但这是直接改最大",
        function()
        loadstring(utf8.char(table.unpack({
108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,114,101,97,108,103,117,105,119,111,119,47,102,111,114,115,97,107,101,110,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,104,105,116,98,111,120,108,111,99,97,116,101,34,41,41,40,41
})))()
        end)
        
        credits:Button(
        "自由冲刺(noli和小孩cookie的",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XQZ-official/XQZscripts/refs/heads/main/VroomVroom.txt"))()
        end)
        
        credits:Button(
        "nol最好最强的平替!!!(还是nol付费更强",
        function()
        if getgenv then

getgenv().BloxtrapRPC =
"true"
getgenv().DebugNotifications = "false"
getgenv().TrackMePlease

=
"true"
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/ivannetta/ShitScripts/main/forsaken.lua"))()
end)
        
        credits:Button(
        "改碰撞箱距离(可调整",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XQZ-official/XQZscripts/refs/heads/main/HitboxModificationOB.txt"))()
        end)
        
        credits:Button(
        "NOL免费版(想要付费的自己买去😂😂😂",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Syndromehsh/BETA2/refs/heads/main/NOL"))()
        end)
        
        credits:Button(
        "脚本3(卡密需自己解",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/souyanen/Fsscripts/refs/heads/main/Forsaken"))()
        end)
        
    
        local creds = window:Tab("河北唐县", "992417778")
    local Tab21 = creds:section("脚本内容", true)
    
    Tab21:Label("自动刷钱 需要成为送货司机")
local virtualUser = game:GetService('VirtualUser')
virtualUser:CaptureController()

function teleportTo(CFrame) 
	game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame
end

_G.autoFarm = false

function autoFarm()
	while _G.autoFarm do
		fireclickdetector(game:GetService("Workspace").DeliverySys.Misc["Package Pile"].ClickDetector)
		task.wait(2.2)
		for _,point in pairs(game:GetService("Workspace").DeliverySys.DeliveryPoints:GetChildren()) do
			if point.Locate.Locate.Enabled then
				teleportTo(point.CFrame)
			end
		end
		task.wait(0)
	end
end

Tab21:Toggle("自动刷钱","text",false,function(value)
_G.autoFarm = value
	if value then
		autoFarm()
	end
end)

Tab21:Button(
        "自动刷钱【其余脚本】",
        function()
            loadstring(game:HttpGet("https://scriptblox.com/raw/Update-V3.10-T-ang-County-Hebei-Auo-Farm-15577"))()
        end
    )
    
    local creds = window:Tab("doors", "992417778")
    local credits = creds:section("doors", true)
    
    credits:Button(
        "doors1",
        function()
 loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\54\53\84\119\84\56\106\97"))()
 end)
 
 credits:Button(
        "doors2",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Rafanchik123/script/main/doors224"))()
        end)
        
        local creds = window:Tab("英雄战场", "992417778")
    local credits = creds:section("脚本内容", true)
    
    credits:Button(
        "杀戮光环脚本",
        function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/godor1010/godor/refs/heads/main/heroes_battlegrounds_2_'))()
        end)
        
        local creds = window:Tab("ohio", "992417778")
    local credits = creds:section("ohio", true)
    
    credits:Button(
        "ohio外网脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DINERO9/TXXK-9988332231C/refs/heads/main/TXX-0099998877ACSSSCRIv2"))()
        end)
        
        credits:Button(
        "RB中心的ohio脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/RbHub-OHIO"))()
        end)
        
        local creds = window:Tab("传奇战场", "992417778")
    local credits = creds:section("传奇战场", true)
    
    credits:Button(
        "非常强的脚本!已删库(里面有原地重生来刷新技能来实现无限技能",
        function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkDoorsKing/Clinet/main/LegendsBattlegrounds'))()
        end)
        
    local creds = window:Tab("刀刃球", "992417778")
    local credits = creds:section("刀刃球", true)
    
    credits:Button(
        "刀刃球(已汉化",
        function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/Kalitor.lua"))()
        end)
        
        credits:Button(
        "超强无敌脚本(已汉化",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/ArgonHubX.lua"))()
        end)
        
        local creds = window:Tab("成为乞丐", "6035145364")
    local credits = creds:section("内容", true)
    
    credits:Button(
        "脚本(已汉化",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/NEGA.lua"))()
        end)
        
        local creds = window:Tab("活了七天", "6035145364")
    local credits = creds:section("内容", true)
    
    credits:Button(
        "脚本1(已汉化",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/bf.txt"))()
        end)
        
        credits:Button(
        "脚本2(已汉化",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/%E4%B8%83%E6%97%A5%E7%94%9F%E6%88%90kkk.txt"))()
        end)
    
       local creds = window:Tab("奶酪逃生", "992417778")
    local credits = creds:section("奶酪逃生", true)
    
    credits:Button(
        "奶酪逃生1",
        function()
        loadstring(game:HttpGet("https://pastefy.app/IIpzN8f5/raw"))()
        end)

        local creds = window:Tab("最强战场", "992417778")
    local credits = creds:section("最强战场内容", true)
    
    credits:Button(
        "KJ动作",
        function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/The-Strongest-Battlegrounds-I-found-a-person-mode-KJ-fake-one-not-mine-19405"))()
        end)
        
        credits:Button(
        "KADE HUB",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/Work/main/latest.lua"))()
        end)
        
        credits:Button(
        "饿狼自动1+2",
        function()
        loadstring(game:HttpGet("https://pastefy.app/Z7DawZJB/raw"))()
        end)
        
        credits:Button(
        "Kiba Tech v2",
        function()
        loadstring(game:HttpGet(" https://raw.githubusercontent.com/YQANTGV3/YQANTGV3/refs/heads/main/bruh.txt"))()
        end)
        
        credits:Button(
        "YQANTG V3.1",
        function()
        loadstring(game:HttpGet(" https://raw.githubusercontent.com/YQANTG/YQANTG/refs/heads/main/YQANTGV31.txt"))()
        end)
        
        credits:Button(
        "Aquairus HUB",
        function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/The-Strongest-Battlegrounds-KJ-Animations-Hub-FE-Keyless-21099"))()
        end)
        
        credits:Button(
        "攻击自动传送到最近的人脚下",
        function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
 
-- Create RemoteEvent for server communication
local stickToggleEvent = Instance.new("RemoteEvent")
stickToggleEvent.Name = "StickToggleEvent"
stickToggleEvent.Parent = ReplicatedStorage
 
-- Create a screen GUI and button
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StickToggleGui"
screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
 
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "Toggle Stick"
toggleButton.Parent = screenGui
 
-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local stickEnabled = false
local stickOffset = Vector3.new(0, -5, 0)  -- Offset below the player’s feet
 
-- Function to get the closest player
local function getClosestPlayer(position)
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (p.Character.HumanoidRootPart.Position - position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = p
            end
        end
    end
    return closestPlayer
end
 
-- Function to stick to the nearest player
local function updateCharacterPosition()
    if stickEnabled then
        local closestPlayer = getClosestPlayer(humanoidRootPart.Position)
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
            -- Place the character below the nearest player
            local newPosition = targetPosition + stickOffset
            humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + Vector3.new(0, 1, 0))
        end
    end
end
 
-- Toggle button functionality
toggleButton.MouseButton1Click:Connect(function()
    stickEnabled = not stickEnabled
    stickToggleEvent:FireServer(stickEnabled)
end)
 
-- Update position every frame
RunService.Heartbeat:Connect(updateCharacterPosition)
        end)
        
        credits:Button(
        "外网超强脚本!!!(已汉化",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/VexonHub%E6%B1%89%E5%8C%96.txt"))()
        end)
        
        credits:Button(
        "逆天无限连脚本",
        function()
        loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\83\108\97\112\104\101\108\108\111\47\77\49\45\82\101\115\101\116\45\69\109\111\116\101\45\68\97\115\104\45\84\83\66\47\114\101\102\115\47\104\101\97\100\115\47\109\97\105\110\47\77\49\37\50\48\82\101\115\101\116\37\50\48\37\50\54\37\50\48\69\109\111\116\101\37\50\48\68\97\115\104\37\50\48\84\83\66", true))()
        end)
        
        credits:Button(
        "卡密!动作(请将角色切换成恶狼",
        function()
        loadstring(game:HttpGet("https://paste.ee/r/AyoFs"))()
        end)
        
        credits:Button(
        "火影忍者动作(请将角色切换成一拳",
        function()
        getgenv().Cutscene = False -- //𝖲𝖤𝖳 𝖨𝖳 "𝖥𝖠𝖫𝖲𝖤" 𝖨𝖥 𝖴 𝖣𝖮𝖭'𝖳 𝖶𝖠𝖭𝖳 𝖢𝖴𝖳𝖲𝖢𝖤𝖭𝖤 𝖠𝖭𝖣 𝖨𝖥 𝖴 𝖶𝖠𝖭𝖳 "𝖳𝖱𝖴𝖤" 𝖨𝖳\

loadstring(game:HttpGet("https://raw.githubusercontent.com/LolnotaKid/SCRIPTSBYVEUX/refs/heads/main/BoombasticLol.lua.txt"))()
        end)
        
        credits:Button(
        "火车头动作(请将角色切换成恶狼",
        function()
        getgenv().settings = {
    ["morph"] = {
        ["enabled"] = false,
        ["dontchangeskincolor"] = false,
    },
    ["ult_forcewalkspeed"] = true, -- forces walkspeed even if set to 0
    ["ult_walkspeed"] = 64, -- how fast you walk in ult
    ["tp_duration"] = 0.15 -- how long it takes to tp
} 

loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/ATrainSounds/refs/heads/main/ATrain.lua"))()
        end)
        
        credits:Button(
        "海贼王黄猿动作(你有被光速踢过吗😈请将角色切换成恶狼",
        function()
        loadstring(game:HttpGet("https://paste.ee/r/NPnfk"))()
        end)
        
        credits:Button(
        "垃圾桶战神",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Trashcan%20Man", true))()
       end)
        
       credits:Button(
        "低配版火车头动作(包含两个功能)",
        function()
        loadstring(game:HttpGet("https://paste.ee/r/AnZ5j"))()
        end)
        
        credits:Button(
        "自动格挡",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Cyborg883/TSB/refs/heads/main/CombatGui"))()
        end)
        
        local credits = creds:section("传送内容", true)
    
        credits:Button(
        "传送到假人生成点",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(149.818115234375, 440.7559814453125, 29.94855499267578)
        end)
        
        credits:Button(
        "传送到虚空(建议先用通用中的指令脚本输入float再传送",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-9940.13482163, -100.1116714, 85.14746118)
        end)
        
        credits:Button(
        "传送到山顶",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-10.000232696533203, 652.521240234375, -389.9998474121094)
        end)
        
        credits:Button(
        "传送到琦玉大招处",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-68.14830017089844, 29.253990173339844, 20346.373046875)
        end)
        
        credits:Button(
        "传送到原子武士大招处",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1065, 131.93948364257812, 23004.998046875)
        end)
        
        credits:Button(
        "传送到原子武士大招下面",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1096, 19.927001953125, 23010.998046875)
        end)
        
        
        credits:Button(
        "传送到神秘月抛点😍",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(287.77398681640625, 439.51055908203125, 480.2169189453125)
        end)
        
        credits:Button(
        "传送到超小角落",
        function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(437.9998474121094, 440.6055908203125, -375.9998779296875)
        end)
        


local creds = window:Tab("其他脚本", "992417778")
    local credits = creds:section("其他脚本内容", true)
    
    credits:Button(
        "落叶中心",
        function()
        getgenv().LS="落叶中心" loadstring(game:HttpGet("https://raw.githubusercontent.com/krlpl/Deciduous-center-LS/main/%E8%90%BD%E5%8F%B6%E4%B8%AD%E5%BF%83%E6%B7%B7%E6%B7%86.txt"))()
        end)
        
    credits:Button(
        "安脚本付费版(免费了但需要加群组)",
        function()
        loadstring(game:HttpGet(('https://raw.githubusercontent.com/wucan114514/gegeyxjb/refs/heads/main/%E5%AE%89%E8%84%9A%E6%9C%AC.lua')))()
        end)
        
        credits:Button(
        "RB脚本中心(功能多，且实用",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/Rb-Hub"))()
        end)
        
        credits:Button(
        "kanl脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/dream77239/kanl/refs/heads/main/Kanl%E8%84%9A%E6%9C%AC"))()
        end)
        
        credits:Button(
        "叶脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
        end)
        
        credits:Button(
        "走马观花X(卡密iamgay或imgay",
        function()
        _ZOUMAGUANHUAGUI='走马观花X'loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\88\80\84\105\86\75\87\120"))()
        end)
        
        credits:Button(
        "剑客免费版",
        function()
        loadstring(request({Url="https://raw.githubusercontent.com/Zer0neK/JianKe/refs/heads/main/初夏.lua"}).Body)()
        end)
        
        credits:Button(
        "COA脚本",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/llz162652/COAJIAOBEN/main/By.pop.cat.kun/COXIEYI"))()
        end)
        
        credits:Button(
        "退休脚本",
        function()
        TX = "脚本群:160369111"Script = "Free永久免费"loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/TX-Free-YYDS/refs/heads/main/FREE-TX-TEAM"))()
        end)
        
        credits:Button(
        "安脚本(需加群组",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Anscripterato/QQ2134702438/refs/heads/main/byato/AnScript/atoscript"))()
        end)
        
        credits:Button(
        "XC脚本中心",
        function()
        loadstring(game:HttpGet("\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\103\101\109\120\72\119\65\49"))()
        end)
        
        credits:Button(
        "猫王脚本",
        function()
        getgenv().MAO = "猫猫王者脚本群935143896"loadstring(game:HttpGet("https://raw.githubusercontent.com/dkfkfkfjfkfjdj/longshu/main/%E6%B7%B7%E6%B7%86%E6%96%87%E4%BB%B6.lua"))()("猫猫脚本 V2.0")
        end)
        
        credits:Button(
        "情云脚本",
        function()
        loadstring(utf8.char((function() return table.unpack({108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,67,104,105,110,97,81,89,47,45,47,109,97,105,110,47,37,69,54,37,56,51,37,56,53,37,69,52,37,66,65,37,57,49,34,41,41,40,41})end)()))()
        end)
        
        credits:Button(
        "卡卡脚本(卡密:kakanb",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MIAN57/main/refs/heads/main/%E5%8D%A1%E5%8D%A12"))()
        end)
        
        credits:Button(
        "禁漫中心",
        function()
        getgenv().LS="禁漫中心" loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/ng/main/jmlllllllIIIIlllllII.lua"))()---公益 大约65个服务器 祝好---公益 暑假无聊 进群：930667114 找群主领取禁漫天堂 轻松快乐
        end)
        
        credits:Button(
        "霖溺脚本",
        function()
        KingTeam= "KingQQ新主群https://qm.qq.com/q/SU0hmhIvwk"loadstring(game:HttpGet("https://raw.githubusercontent.com/ShenJiaoBen/ShenJiaoBen/main/King-------------Script.txt"))()
        end)
        
        
        credits:Button(
        "皮脚本(需加群组",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
        end)
        
        credits:Button(
        "达脚本",
        function()
        xiaoda = "作者_小达"Xiaoda = "作者QQ_3491629303"XiaoDa = "QQ群_705257336"loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\34\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\49\51\51\117\102\117\100\104\100\117\47\72\76\68\72\81\86\81\82\80\66\47\109\97\105\110\47\81\85\81\34\41\41\40\41\10")()
        end)
        
        credits:Button(
        "小月脚本破解版",
        function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Syndromehsh/bypass-Script/refs/heads/main/xiaoyue/Main%20Script.lua"))()
        end)
        
