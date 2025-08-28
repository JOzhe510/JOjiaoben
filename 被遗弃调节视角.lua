local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
local window = DrRayLibrary:Load("DrRay", "Default")

local tab = DrRayLibrary.newTab("My Tab", "ImageIdHere")


tab.newToggle("Toggle", "Toggle! (prints the state)", true, function(toggleState)
    if toggleState then
        print("On")
    else
        print("Off")
    end
    _env.FOV = v
        game:GetService("RunService").RenderStepped:Connect(function()
            if _env.FOV then
                workspace.Camera.FieldOfView = _env.FovValue
            end
        end)
end)


tab.newSlider("调节视角", "Epic slider", 120, false, function(v)
    _env.FovValue = v
end)