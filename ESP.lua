local Workspace, RunService, Players, CoreGui, Lighting = cloneref(game:GetService("Workspace")), cloneref(game:GetService("RunService")), cloneref(game:GetService("Players")), game:GetService("CoreGui"), cloneref(game:GetService("Lighting"))

local ESP = {
    Enabled = true,
    TeamCheck = true,
    MaxDistance = math.huge, -- 无限距离
    FontSize = 11,
    FadeOut = {
        OnDistance = false, -- 禁用距离淡化（因为无限距离）
        OnDeath = false,
        OnLeave = false,
    },
    Options = { 
        Teamcheck = true, TeamcheckRGB = Color3.fromRGB(0, 255, 0),
        Friendcheck = true, FriendcheckRGB = Color3.fromRGB(0, 255, 0),
        Highlight = true, HighlightRGB = Color3.fromRGB(255, 0, 0),
    },
    Drawing = {
        Chams = {
            Enabled  = true,
            Thermal = true,
            FillRGB = Color3.fromRGB(119, 120, 255),
            Fill_Transparency = 100,
            OutlineRGB = Color3.fromRGB(119, 120, 255),
            Outline_Transparency = 100,
            VisibleCheck = true,
        },
        Names = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Flags = {
            Enabled = false,
        },
        Distances = {
            Enabled = true,
            Position = "Text",
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Weapons = {
            Enabled = false, WeaponTextRGB = Color3.fromRGB(119, 120, 255),
            Outlined = false,
            Gradient = false,
            GradientRGB1 = Color3.fromRGB(255, 255, 255), GradientRGB2 = Color3.fromRGB(119, 120, 255),
        },
        Healthbar = {
            Enabled = true,  
            HealthText = true, Lerp = false, HealthTextRGB = Color3.fromRGB(119, 120, 255),
            Width = 2.5,
            Gradient = true, GradientRGB1 = Color3.fromRGB(200, 0, 0), GradientRGB2 = Color3.fromRGB(60, 60, 125), GradientRGB3 = Color3.fromRGB(119, 120, 255), 
        },
        Boxes = {
            Animate = true,
            RotationSpeed = 300,
            Gradient = false, GradientRGB1 = Color3.fromRGB(119, 120, 255), GradientRGB2 = Color3.fromRGB(0, 0, 0), 
            GradientFill = true, GradientFillRGB1 = Color3.fromRGB(119, 120, 255), GradientFillRGB2 = Color3.fromRGB(0, 0, 0), 
            Filled = {
                Enabled = true,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Corner = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
        },
        Highlights = {
            Enabled = true,
            FillColor = Color3.fromRGB(255, 0, 0),
            OutlineColor = Color3.fromRGB(255, 255, 0),
            FillTransparency = 0.5,
            OutlineTransparency = 0,
            OutlineThickness = 2,
        }
    },
    Connections = {
        RunService = RunService,
    },
    Fonts = {},
    PlayerConnections = {},
    PlayerESPInstances = {},
}

-- Def & Vars
local Euphoria = ESP.Connections;
local lplayer = Players.LocalPlayer;
local camera = game.Workspace.CurrentCamera;
local Cam = Workspace.CurrentCamera;
local RotationAngle, Tick = -45, tick();

-- Functions
local Functions = {}
do
    function Functions:Create(Class, Properties)
        local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
        for Property, Value in pairs(Properties) do
            _Instance[Property] = Value
        end
        return _Instance;
    end
    
    function Functions:CleanupPlayerESP(plr)
        if ESP.PlayerESPInstances[plr] then
            for _, instance in pairs(ESP.PlayerESPInstances[plr]) do
                if instance and instance.Parent then
                    instance:Destroy()
                end
            end
            ESP.PlayerESPInstances[plr] = nil
        end
        
        if ESP.PlayerConnections[plr] then
            for _, conn in pairs(ESP.PlayerConnections[plr]) do
                if conn then
                    conn:Disconnect()
                end
            end
            ESP.PlayerConnections[plr] = nil
        end
    end
end;

do -- 主ESP函数
    local ScreenGui = Functions:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "ESPHolder",
    });

    local function CreateESP(plr)
        Functions:CleanupPlayerESP(plr)
        
        ESP.PlayerESPInstances[plr] = {}
        ESP.PlayerConnections[plr] = {}
        
        -- 创建ESP元素
        local Name = Functions:Create("TextLabel", {
            Parent = ScreenGui, 
            Position = UDim2.new(0.5, 0, 0, -11), 
            Size = UDim2.new(0, 100, 0, 20), 
            AnchorPoint = Vector2.new(0.5, 0.5), 
            BackgroundTransparency = 1, 
            TextColor3 = Color3.fromRGB(255, 255, 255), 
            Font = Enum.Font.Code, 
            TextSize = ESP.FontSize, 
            TextStrokeTransparency = 0, 
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
            RichText = true,
            Name = plr.Name .. "_Name",
            Visible = false
        })
        
        local Distance = Functions:Create("TextLabel", {
            Parent = ScreenGui, 
            Position = UDim2.new(0.5, 0, 0, 11), 
            Size = UDim2.new(0, 100, 0, 20), 
            AnchorPoint = Vector2.new(0.5, 0.5), 
            BackgroundTransparency = 1, 
            TextColor3 = ESP.Drawing.Distances.RGB, 
            Font = Enum.Font.Code, 
            TextSize = ESP.FontSize, 
            TextStrokeTransparency = 0, 
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
            RichText = true,
            Name = plr.Name .. "_Distance",
            Visible = false
        })
        
        local Weapon = Functions:Create("TextLabel", {
            Parent = ScreenGui, 
            Position = UDim2.new(0.5, 0, 0, 31), 
            Size = UDim2.new(0, 100, 0, 20), 
            AnchorPoint = Vector2.new(0.5, 0.5), 
            BackgroundTransparency = 1, 
            TextColor3 = Color3.fromRGB(255, 255, 255), 
            Font = Enum.Font.Code, 
            TextSize = ESP.FontSize, 
            TextStrokeTransparency = 0, 
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0), 
            RichText = true,
            Name = plr.Name .. "_Weapon",
            Visible = false
        })
        
        local Box = Functions:Create("Frame", {
            Parent = ScreenGui, 
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
            BackgroundTransparency = ESP.Drawing.Boxes.Filled.Transparency,
            BorderSizePixel = 0,
            Name = plr.Name .. "_Box",
            Visible = false
        })
        
        local Gradient1 = Functions:Create("UIGradient", {
            Parent = Box, 
            Enabled = ESP.Drawing.Boxes.GradientFill, 
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientFillRGB1), 
                ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientFillRGB2)
            }
        })
        
        local Outline = Functions:Create("UIStroke", {
            Parent = Box, 
            Enabled = ESP.Drawing.Boxes.Gradient, 
            Transparency = 0, 
            Color = ESP.Drawing.Boxes.Full.RGB, 
            LineJoinMode = Enum.LineJoinMode.Miter,
            Thickness = 1,
        })
        
        local Gradient2 = Functions:Create("UIGradient", {
            Parent = Outline, 
            Enabled = ESP.Drawing.Boxes.Gradient, 
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientRGB1), 
                ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientRGB2)
            }
        })
        
        local LeftTop, LeftSide, RightTop, RightSide, BottomSide, BottomDown, BottomRightSide, BottomRightDown
        
        if ESP.Drawing.Boxes.Corner.Enabled then
            LeftTop = Functions:Create("Frame", {
                Parent = ScreenGui, 
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, 
                Position = UDim2.new(0, 0, 0, 0),
                Name = plr.Name .. "_LeftTop",
                Visible = false
            })
            
            LeftSide = Functions:Create("Frame", {
                Parent = ScreenGui, 
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, 
                Position = UDim2.new(0, 0, 0, 0),
                Name = plr.Name .. "_LeftSide",
                Visible = false
            })
            
            RightTop = Functions:Create("Frame", {
                Parent = ScreenGui, 
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, 
                Position = UDim2.new(0, 0, 0, 0),
                Name = plr.Name .. "_RightTop",
                Visible = false
            })
            
            RightSide = Functions:Create("Frame", {
                Parent = ScreenGui, 
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, 
                Position = UDim2.new(0, 0, 0, 0),
                Name = plr.Name .. "_RightSide",
                Visible = false
            })
            
            BottomSide = Functions:Create("Frame", {
                Parent = ScreenGui, 
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, 
                Position = UDim2.new(0, 0, 0, 0),
                Name = plr.Name .. "_BottomSide",
                Visible = false
            })
            
            BottomDown = Functions:Create("Frame", {
                Parent = ScreenGui, 
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, 
                Position = UDim2.new(0, 0, 0, 0),
                Name = plr.Name .. "_BottomDown",
                Visible = false
            })
            
            BottomRightSide = Functions:Create("Frame", {
                Parent = ScreenGui, 
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, 
                Position = UDim2.new(0, 0, 0, 0),
                Name = plr.Name .. "_BottomRightSide",
                Visible = false
            })
            
            BottomRightDown = Functions:Create("Frame", {
                Parent = ScreenGui, 
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, 
                Position = UDim2.new(0, 0, 0, 0),
                Name = plr.Name .. "_BottomRightDown",
                Visible = false
            })
        end
        
        local Healthbar = Functions:Create("Frame", {
            Parent = ScreenGui, 
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
            BackgroundTransparency = 0,
            Name = plr.Name .. "_Healthbar",
            Visible = false
        })
        
        local BehindHealthbar = Functions:Create("Frame", {
            Parent = ScreenGui, 
            ZIndex = -1, 
            BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
            BackgroundTransparency = 0,
            Name = plr.Name .. "_BehindHealthbar",
            Visible = false
        })
        
        local HealthbarGradient = Functions:Create("UIGradient", {
            Parent = Healthbar, 
            Enabled = ESP.Drawing.Healthbar.Gradient, 
            Rotation = -90, 
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, ESP.Drawing.Healthbar.GradientRGB1), 
                ColorSequenceKeypoint.new(0.5, ESP.Drawing.Healthbar.GradientRGB2), 
                ColorSequenceKeypoint.new(1, ESP.Drawing.Healthbar.GradientRGB3)
            }
        })
        
        local HealthText = Functions:Create("TextLabel", {
            Parent = ScreenGui, 
            Position = UDim2.new(0.5, 0, 0, 31), 
            Size = UDim2.new(0, 100, 0, 20), 
            AnchorPoint = Vector2.new(0.5, 0.5), 
            BackgroundTransparency = 1, 
            TextColor3 = ESP.Drawing.Healthbar.HealthTextRGB, 
            Font = Enum.Font.Code, 
            TextSize = ESP.FontSize, 
            TextStrokeTransparency = 0, 
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            Name = plr.Name .. "_HealthText",
            Visible = false
        })
        
        local Chams = Functions:Create("Highlight", {
            Parent = ScreenGui, 
            FillTransparency = 1, 
            OutlineTransparency = 0, 
            OutlineColor = Color3.fromRGB(119, 120, 255), 
            DepthMode = "AlwaysOnTop",
            Name = plr.Name .. "_Chams",
            Enabled = false
        })
        
        local WeaponIcon = Functions:Create("ImageLabel", {
            Parent = ScreenGui, 
            BackgroundTransparency = 1, 
            BorderColor3 = Color3.fromRGB(0, 0, 0), 
            BorderSizePixel = 0, 
            Size = UDim2.new(0, 40, 0, 40),
            Name = plr.Name .. "_WeaponIcon",
            Visible = false
        })
        
        local PlayerHighlight = Functions:Create("Highlight", {
            Parent = ScreenGui,
            FillColor = ESP.Drawing.Highlights.FillColor,
            OutlineColor = ESP.Drawing.Highlights.OutlineColor,
            FillTransparency = ESP.Drawing.Highlights.FillTransparency,
            OutlineTransparency = ESP.Drawing.Highlights.OutlineTransparency,
            DepthMode = "AlwaysOnTop",
            Name = plr.Name .. "_Highlight",
            Enabled = false
        })
        
        local instances = {
            Name, Distance, Weapon, Box, Outline, Healthbar, BehindHealthbar, 
            HealthText, Chams, WeaponIcon, PlayerHighlight, Gradient1, Gradient2, HealthbarGradient
        }
        
        if ESP.Drawing.Boxes.Corner.Enabled then
            table.insert(instances, LeftTop)
            table.insert(instances, LeftSide)
            table.insert(instances, RightTop)
            table.insert(instances, RightSide)
            table.insert(instances, BottomSide)
            table.insert(instances, BottomDown)
            table.insert(instances, BottomRightSide)
            table.insert(instances, BottomRightDown)
        end
        
        ESP.PlayerESPInstances[plr] = instances
        
        local function UpdateESP()
            local function HideESP()
                Box.Visible = false
                Name.Visible = false
                Distance.Visible = false
                Weapon.Visible = false
                Healthbar.Visible = false
                BehindHealthbar.Visible = false
                HealthText.Visible = false
                WeaponIcon.Visible = false
                Chams.Enabled = false
                PlayerHighlight.Enabled = false
                
                if ESP.Drawing.Boxes.Corner.Enabled then
                    LeftTop.Visible = false
                    LeftSide.Visible = false
                    RightTop.Visible = false
                    RightSide.Visible = false
                    BottomSide.Visible = false
                    BottomDown.Visible = false
                    BottomRightSide.Visible = false
                    BottomRightDown.Visible = false
                end
            end
            
            local renderConnection = Euphoria.RunService.RenderStepped:Connect(function()
                if not ESP.Enabled then
                    HideESP()
                    return
                end
                
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local HRP = plr.Character.HumanoidRootPart
                    local Humanoid = plr.Character:WaitForChild("Humanoid")
                    local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
                    local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
                    
                    if OnScreen then -- 移除距离检查
                        local Size = HRP.Size.Y
                        local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                        local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                        if ESP.Drawing.Highlights.Enabled then
                            PlayerHighlight.Enabled = true
                            PlayerHighlight.Adornee = plr.Character
                            PlayerHighlight.FillColor = ESP.Drawing.Highlights.FillColor
                            PlayerHighlight.OutlineColor = ESP.Drawing.Highlights.OutlineColor
                            PlayerHighlight.FillTransparency = ESP.Drawing.Highlights.FillTransparency
                            PlayerHighlight.OutlineTransparency = ESP.Drawing.Highlights.OutlineTransparency
                        else
                            PlayerHighlight.Enabled = false
                        end

                        if not ESP.TeamCheck or (plr ~= lplayer and ((lplayer.Team ~= plr.Team and plr.Team) or (not lplayer.Team and not plr.Team))) then
                            
                            if ESP.Drawing.Distances.Enabled then
                                Distance.Visible = true
                                Distance.Text = string.format("[%d米]", math.floor(Dist))
                                Distance.TextColor3 = ESP.Drawing.Distances.RGB
                                Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)
                                
                                if ESP.Drawing.Distances.Position == "Text" then
                                    if ESP.Options.Friendcheck and lplayer:IsFriendsWith(plr.UserId) then
                                        Name.Text = string.format('(<font color="rgb(%d, %d, %d)">F</font>) %s [%d米]', 
                                            ESP.Options.FriendcheckRGB.R * 255, 
                                            ESP.Options.FriendcheckRGB.G * 255, 
                                            ESP.Options.FriendcheckRGB.B * 255, 
                                            plr.Name, math.floor(Dist))
                                    else
                                        Name.Text = string.format('(<font color="rgb(%d, %d, %d)">E</font>) %s [%d米]', 
                                            255, 0, 0, plr.Name, math.floor(Dist))
                                    end
                                end
                            else
                                Distance.Visible = false
                            end
                            
                            Name.Visible = ESP.Drawing.Names.Enabled
                            Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 20)
                            Name.TextColor3 = ESP.Drawing.Names.RGB
                            
                            Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                            Box.Size = UDim2.new(0, w, 0, h)
                            Box.Visible = ESP.Drawing.Boxes.Full.Enabled
                            
                            if ESP.Drawing.Boxes.Filled.Enabled then
                                Box.BackgroundColor3 = ESP.Drawing.Boxes.Filled.RGB
                                if ESP.Drawing.Boxes.GradientFill then
                                    Box.BackgroundTransparency = ESP.Drawing.Boxes.Filled.Transparency
                                    Gradient1.Enabled = true
                                else
                                    Box.BackgroundTransparency = 1
                                    Gradient1.Enabled = false
                                end
                                Box.BorderSizePixel = 1
                            else
                                Box.BackgroundTransparency = 1
                                Gradient1.Enabled = false
                            end
                            
                            Outline.Enabled = ESP.Drawing.Boxes.Gradient
                            Outline.Color = ESP.Drawing.Boxes.Full.RGB
                            Gradient2.Enabled = ESP.Drawing.Boxes.Gradient
                            
                            RotationAngle = RotationAngle + (tick() - Tick) * ESP.Drawing.Boxes.RotationSpeed * math.cos(math.pi / 4 * tick() - math.pi / 2)
                            if ESP.Drawing.Boxes.Animate then
                                Gradient1.Rotation = RotationAngle
                                Gradient2.Rotation = RotationAngle
                            else
                                Gradient1.Rotation = -45
                                Gradient2.Rotation = -45
                            end
                            Tick = tick()
                            
                            if ESP.Drawing.Boxes.Corner.Enabled then
                                LeftTop.Visible = true
                                LeftTop.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                                LeftTop.Size = UDim2.new(0, w / 5, 0, 1)
                                
                                LeftSide.Visible = true
                                LeftSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                                LeftSide.Size = UDim2.new(0, 1, 0, h / 5)
                                
                                BottomSide.Visible = true
                                BottomSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                                BottomSide.Size = UDim2.new(0, 1, 0, h / 5)
                                BottomSide.AnchorPoint = Vector2.new(0, 5)
                                
                                BottomDown.Visible = true
                                BottomDown.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                                BottomDown.Size = UDim2.new(0, w / 5, 0, 1)
                                BottomDown.AnchorPoint = Vector2.new(0, 1)
                                
                                RightTop.Visible = true
                                RightTop.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y - h / 2)
                                RightTop.Size = UDim2.new(0, w / 5, 0, 1)
                                RightTop.AnchorPoint = Vector2.new(1, 0)
                                
                                RightSide.Visible = true
                                RightSide.Position = UDim2.new(0, Pos.X + w / 2 - 1, 0, Pos.Y - h / 2)
                                RightSide.Size = UDim2.new(0, 1, 0, h / 5)
                                RightSide.AnchorPoint = Vector2.new(0, 0)
                                
                                BottomRightSide.Visible = true
                                BottomRightSide.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                                BottomRightSide.Size = UDim2.new(0, 1, 0, h / 5)
                                BottomRightSide.AnchorPoint = Vector2.new(1, 1)
                                
                                BottomRightDown.Visible = true
                                BottomRightDown.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                                BottomRightDown.Size = UDim2.new(0, w / 5, 0, 1)
                                BottomRightDown.AnchorPoint = Vector2.new(1, 1)
                            end
                            
                            if ESP.Drawing.Healthbar.Enabled then
                                local health = math.max(0, Humanoid.Health / Humanoid.MaxHealth)
                                Healthbar.Visible = true
                                Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - health))  
                                Healthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h * health)  
                                
                                BehindHealthbar.Visible = true
                                BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2)  
                                BehindHealthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h)
                                
                                if ESP.Drawing.Healthbar.HealthText then
                                    local healthPercentage = math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)
                                    HealthText.Position = UDim2.new(0, Pos.X - w / 2 - 10, 0, Pos.Y - h / 2 + h * (1 - healthPercentage / 100) - 10)
                                    HealthText.Text = tostring(healthPercentage) .. "%"
                                    HealthText.Visible = true
                                    HealthText.TextColor3 = ESP.Drawing.Healthbar.HealthTextRGB
                                end
                            else
                                Healthbar.Visible = false
                                BehindHealthbar.Visible = false
                                HealthText.Visible = false
                            end
                            
                            Chams.Adornee = plr.Character
                            Chams.Enabled = ESP.Drawing.Chams.Enabled
                            if ESP.Drawing.Chams.Enabled then
                                Chams.FillColor = ESP.Drawing.Chams.FillRGB
                                Chams.OutlineColor = ESP.Drawing.Chams.OutlineRGB
                            end
                            
                            WeaponIcon.Visible = ESP.Drawing.Weapons.Enabled
                            if ESP.Drawing.Weapons.Enabled then
                                WeaponIcon.Position = UDim2.new(0, Pos.X - 20, 0, Pos.Y + h / 2 + 15)
                            end
                            
                            Weapon.Visible = ESP.Drawing.Weapons.Enabled
                            if ESP.Drawing.Weapons.Enabled then
                                Weapon.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 30)
                                Weapon.TextColor3 = ESP.Drawing.Weapons.WeaponTextRGB
                            end
                            
                        else
                            HideESP()
                        end
                    else
                        HideESP()
                    end
                else
                    HideESP()
                end
            end)
            
            table.insert(ESP.PlayerConnections[plr], renderConnection)
            
            local characterAddedConnection = plr.CharacterAdded:Connect(function()
                wait(1)
                Functions:CleanupPlayerESP(plr)
                CreateESP(plr)
            end)
            
            table.insert(ESP.PlayerConnections[plr], characterAddedConnection)
        end
        
        coroutine.wrap(UpdateESP)()
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lplayer then
            CreateESP(player)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player ~= lplayer then
            wait(1)
            CreateESP(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        Functions:CleanupPlayerESP(player)
    end)
end

print("ESP已加载！无距离限制")