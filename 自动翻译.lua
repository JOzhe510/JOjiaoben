local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- 全局控制变量
local TranslationEnabled = true
local TranslatedObjects = {}
local BlacklistedInstances = {}

-- 创建控制UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TranslationUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🔤 实时翻译控制面板"
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
ToggleBtn.Text = "🟢 翻译开启"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.8, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.1, 0, 0.5, 0)
StatusLabel.Text = "状态: 监控中..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

local RevertBtn = Instance.new("TextButton")
RevertBtn.Size = UDim2.new(0.8, 0, 0, 30)
RevertBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
RevertBtn.Text = "↩️ 恢复所有原文"
RevertBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
RevertBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RevertBtn.Font = Enum.Font.Gotham
RevertBtn.Parent = MainFrame

-- 深度翻译函数
local function deepTranslateText(text, targetLang)
    local success, result = pcall(function()
        local encodedText = HttpService:UrlEncode(text)
        local url = string.format("https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=%s&dt=t&q=%s", 
            targetLang, encodedText)
        
        local response = HttpService:GetAsync(url, true)
        local data = HttpService:JSONDecode(response)
        
        if data and data[1] then
            local translatedText = ""
            for _, segment in ipairs(data[1]) do
                if segment[1] then
                    translatedText = translatedText .. segment[1]
                end
            end
            return translatedText ~= "" and translatedText or text
        end
        return text
    end)
    
    return success and result or text
end

-- 检查是否为中文
local function isChinese(text)
    return text and text:match("[\228-\233][\128-\191]")
end

-- 检查是否为英文
local function isEnglish(text)
    return text and text:match("%a") and not isChinese(text)
end

-- 翻译文本元素
local function translateTextElement(element)
    if not TranslationEnabled or BlacklistedInstances[element] then return end
    
    local originalText = element.Text
    if originalText and #originalText > 2 and isEnglish(originalText) then
        spawn(function()
            local translated = deepTranslateText(originalText, "zh-CN")
            if translated ~= originalText then
                TranslatedObjects[element] = {
                    Original = originalText,
                    Translated = translated
                }
                element.Text = translated
            end
        end)
    end
end

-- 恢复原文
local function revertAllTranslations()
    for element, data in pairs(TranslatedObjects) do
        if element and element.Parent then
            element.Text = data.Original
        end
    end
    TranslatedObjects = {}
end

-- 监控UI元素
local function monitorUI()
    while TranslationEnabled do
        for _, gui in ipairs(CoreGui:GetDescendants()) do
            if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) and not TranslatedObjects[gui] then
                translateTextElement(gui)
            end
        end
        wait(1)
    end
end

-- UI控制事件
ToggleBtn.MouseButton1Click:Connect(function()
    TranslationEnabled = not TranslationEnabled
    if TranslationEnabled then
        ToggleBtn.Text = "🟢 翻译开启"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        StatusLabel.Text = "状态: 监控中..."
        spawn(monitorUI)
    else
        ToggleBtn.Text = "🔴 翻译关闭"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 80)
        StatusLabel.Text = "状态: 已暂停"
    end
end)

RevertBtn.MouseButton1Click:Connect(function()
    revertAllTranslations()
    StatusLabel.Text = "状态: 已恢复所有原文"
end)

-- 新元素监控
game.DescendantAdded:Connect(function(descendant)
    if TranslationEnabled and (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
        wait(0.5) -- 等待元素稳定
        translateTextElement(descendant)
    end
end)

-- 右键菜单添加黑名单
local ContextActionService = game:GetService("ContextActionService")
ContextActionService:BindAction("BlacklistElement", function(_, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin and inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = inputObject.Target
        if target and (target:IsA("TextLabel") or target:IsA("TextButton") or target:IsA("TextBox")) then
            BlacklistedInstances[target] = true
            if TranslatedObjects[target] then
                target.Text = TranslatedObjects[target].Original
                TranslatedObjects[target] = nil
            end
            StatusLabel.Text = "状态: 已黑名单 "..target.Name
        end
    end
end, false, Enum.UserInputType.MouseButton2)

-- 初始化
spawn(monitorUI)
print("高级翻译系统已加载 - 右键点击可屏蔽元素")