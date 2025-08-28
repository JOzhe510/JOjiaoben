local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
local window = DrRayLibrary:Load("DrRay", "Default")

local tab = DrRayLibrary.newTab("My Tab", "ImageIdHere")



tab.newToggle("启用视角", "请输入文本", true, function(v)
    _env.FOV = v
        game:GetService("RunService").RenderStepped:Connect(function()
            if _env.FOV then
                workspace.Camera.FieldOfView = _env.FovValue
            end
        end)
end)


tab.newSlider("视角数值", "请输入文本", 120, false, function(v)
    _env.FovValue = v
end)
