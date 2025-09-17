local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- 全局控制变量
local TranslationEnabled = true
local TranslatedObjects = {}
local BlacklistedInstances = {}
local UIExpanded = true
local TranslationMethod = "Google" -- 默认翻译方式

-- 创建控制UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TranslationUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 210)
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

-- 翻译方式选择按钮
local MethodBtn = Instance.new("TextButton")
MethodBtn.Size = UDim2.new(0.8, 0, 0, 30)
MethodBtn.Position = UDim2.new(0.1, 0, 0.85, 0)
MethodBtn.Text = "🌐 翻译方式: Google"
MethodBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
MethodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MethodBtn.Font = Enum.Font.Gotham
MethodBtn.Parent = MainFrame

-- 折叠按钮
local ToggleUIBtn = Instance.new("TextButton")
ToggleUIBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleUIBtn.Position = UDim2.new(1, -30, 0, 0)
ToggleUIBtn.Text = "−"
ToggleUIBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ToggleUIBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.Parent = MainFrame

-- 翻译方式配置
local TranslationMethods = {
    Google = {
        url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=%s&dt=t&q=%s",
        name = "Google"
    },
    Bing = {
        url = "https://api.bing.microsoft.com/v7.0/translate?to=%s&text=%s",
        name = "Bing"
    },
    DeepL = {
        url = "https://api-free.deepl.com/v2/translate?target_lang=%s&text=%s",
        name = "DeepL"
    },
    Yandex = {
        url = "https://translate.yandex.net/api/v1.5/tr.json/translate?lang=%s&text=%s",
        name = "Yandex"
    }
}

-- 优化翻译函数
local function deepTranslateText(text, targetLang)
    if not text or #text < 2 then return text end
    
    local success, result = pcall(function()
        local method = TranslationMethods[TranslationMethod]
        if not method then method = TranslationMethods.Google end
        
        local encodedText = HttpService:UrlEncode(text)
        local url = string.format(method.url, targetLang, encodedText)
        
        local response = HttpService:GetAsync(url, true)
        
        -- 不同API的响应解析
        if TranslationMethod == "Google" then
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
            
        elseif TranslationMethod == "Bing" then
            local data = HttpService:JSONDecode(response)
            if data and data.translations and data.translations[1] then
                return data.translations[1].text or text
            end
            
        elseif TranslationMethod == "DeepL" then
            local data = HttpService:JSONDecode(response)
            if data and data.translations and data.translations[1] then
                return data.translations[1].text or text
            end
            
        elseif TranslationMethod == "Yandex" then
            local data = HttpService:JSONDecode(response)
            if data and data.text and data.text[1] then
                return data.text[1] or text
            end
        end
        
        return text
    end)
    
    return success and result or text
end

-- 切换翻译方式
local function cycleTranslationMethod()
    local methods = {"Google", "Bing", "DeepL", "Yandex"}
    local currentIndex = 1
    for i, method in ipairs(methods) do
        if method == TranslationMethod then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = currentIndex % #methods + 1
    TranslationMethod = methods[nextIndex]
    MethodBtn.Text = "🌐 翻译方式: " .. TranslationMethod
    StatusLabel.Text = "已切换至: " .. TranslationMethod
end

-- 优化中文检测
local function isChinese(text)
    return text and text:match("[\228-\233][\128-\191]")
end

-- 优化英文检测
local function isEnglish(text)
    return text and text:match("%a") and not isChinese(text)
end

-- 优化翻译逻辑
local function translateTextElement(element)
    if not TranslationEnabled or BlacklistedInstances[element] then return end
    
    local originalText = element.Text
    if originalText and #originalText > 1 and isEnglish(originalText) and not TranslatedObjects[element] then
        task.spawn(function()
            local translated = deepTranslateText(originalText, "zh-CN")
            if translated ~= originalText then
                TranslatedObjects[element] = {
                    Original = originalText,
                    Translated = translated,
                    Method = TranslationMethod
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

-- 优化监控UI元素
local function monitorUI()
    while TranslationEnabled do
        for _, gui in ipairs(CoreGui:GetDescendants()) do
            if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) then
                translateTextElement(gui)
            end
        end
        task.wait(2)
    end
end

-- UI控制事件
ToggleBtn.MouseButton1Click:Connect(function()
    TranslationEnabled = not TranslationEnabled
    if TranslationEnabled then
        ToggleBtn.Text = "🟢 翻译开启"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
        StatusLabel.Text = "状态: 监控中..."
        task.spawn(monitorUI)
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

-- 切换翻译方式
MethodBtn.MouseButton1Click:Connect(function()
    cycleTranslationMethod()
end)

-- 折叠/展开UI
ToggleUIBtn.MouseButton1Click:Connect(function()
    UIExpanded = not UIExpanded
    if UIExpanded then
        MainFrame.Size = UDim2.new(0, 280, 0, 210)
        ToggleUIBtn.Text = "−"
        ToggleBtn.Visible = true
        StatusLabel.Visible = true
        RevertBtn.Visible = true
        MethodBtn.Visible = true
    else
        MainFrame.Size = UDim2.new(0, 280, 0, 30)
        ToggleUIBtn.Text = "+"
        ToggleBtn.Visible = false
        StatusLabel.Visible = false
        RevertBtn.Visible = false
        MethodBtn.Visible = false
    end
end)

-- 优化新元素监控
game.DescendantAdded:Connect(function(descendant)
    if TranslationEnabled and (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
        task.delay(0.3, function()
            translateTextElement(descendant)
        end)
    end
end)

-- 右键菜单黑名单
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
task.spawn(monitorUI)
print("终极翻译系统已加载 - 4种翻译引擎 | 右键屏蔽 | −/+ 折叠")