local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles


local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


if not table.clone then
    table.clone = function(t)
        local nt = {}
        for k,v in pairs(t) do nt[k] = v end
        return nt
    end
end

Library.ShowToggleFrameInKeybinds = true 
Library.ShowCustomCursor = true
Library.NotifySide = "Right"

local Window = Library:CreateWindow({
    Title = ' 被遗弃｜BETATEST',
    Footer = "正式版 V7.0.0",
    Icon = 106397684977541,
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    NotifySide = "Right",
    TabPadding = 8,
    MenuFadeTime = 0
})

local Tabs = {
    new = Window:AddTab('公告', 'user'),
    Main = Window:AddTab('快捷功能区','house'),
    Aimbot = Window:AddTab('自瞄区','earth'),
    Esp = Window:AddTab('绘制区','eye'),
    tzq = Window:AddTab('通知提示','eye'),
    ani = Window:AddTab('反效果区','file'),
    Max = Window:AddTab('动作区','file'),
    Sat = Window:AddTab('体力区','moon'),
    zdg = Window:AddTab('自动格挡','file'),
    zdx = Window:AddTab('自动修机','moon'),
    lol = Window:AddTab('披萨区','earth'),
    tfz = Window:AddTab('塔夫炸弹','moon'),
    ["UI Settings"] = Window:AddTab('UI调试', 'settings')
}

local _env = getgenv and getgenv() or {}
local _hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

local new = Tabs.new:AddRightGroupbox('自己随便弄的')

new:AddLabel("调节视角")
new:AddLabel("请输入文本")
new:AddLabel("请输入文本")
new:AddLabel("请输入文本")







local KillerSurvival = Tabs.Main:AddLeftGroupbox("调节功能")

local MainTabbox = Tabs.Main:AddRightTabbox()
local Lighting = MainTabbox:AddTab("视角调节")

Lighting:AddSlider("B",{
    Text = "视角数值",
    Min = 70,
    Default = 70,
    Max = 120,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
   _env.FovValue = v
    end
})

  _G.FovValue = 70

Camera:AddToggle("应用范围",{
    Text = "应用",
    Callback = function(v)
        _env.FOV = v
        game:GetService("RunService").RenderStepped:Connect(function()
            if _env.FOV then
                workspace.Camera.FieldOfView = _env.FovValue
            end
        end)
    end
})