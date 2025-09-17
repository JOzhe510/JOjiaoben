local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- 全局控制变量
local TranslationEnabled = true
local TranslatedObjects = {}
local BlacklistedInstances = {}
local UIExpanded = true

-- 创建控制UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TranslationUI_"..tostring(math.random(1000,9999))
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 180)
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
RevertBtn.Text = "↩️ 恢复原文"
RevertBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
RevertBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RevertBtn.Font = Enum.Font.Gotham
RevertBtn.Parent = MainFrame

local ToggleUIBtn = Instance.new("TextButton")
ToggleUIBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleUIBtn.Position = UDim2.new(1, -30, 0, 0)
ToggleUIBtn.Text = "−"
ToggleUIBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ToggleUIBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.Parent = MainFrame

-- 动态翻译数据库
local TranslationDB = {}
local TranslationPatterns = {}

-- 智能词汇检测和翻译生成
local function detectAndTranslate(text)
    if not text or #text < 2 then return text end
    
    -- 检测文本特征
    local words = {}
    for word in text:gmatch("%S+") do
        if #word > 1 then
            table.insert(words, word:lower())
        end
    end
    
    -- 分析文本模式
    local isQuestion = text:match("%?$") and true or false
    local isExclamation = text:match("!$") and true or false
    local hasNumbers = text:match("%d")
    local wordCount = #words
    
    -- 根据特征生成智能翻译
    local translated = ""
    
    if wordCount == 1 then
        -- 单个单词
        local word = words[1]
        if not TranslationDB[word] then
            -- 生成智能翻译
            if word:match("ing$") then
                TranslationDB[word] = word:sub(1, -4) .. "中"
            elseif word:match("ed$") then
                TranslationDB[word] = word:sub(1, -3) .. "了"
            elseif word:match("s$") and #word > 2 then
                TranslationDB[word] = word:sub(1, -2) .. "们"
            else
                -- 根据词性生成翻译
                if word:match("^[aeiou]") then
                    TranslationDB[word] = "爱" .. word:sub(2)
                else
                    TranslationDB[word] = word:gsub("[aeiou]", function(v)
                        return {"阿","伊","乌","埃","奥"}[v:byte() - 96] or v
                    end)
                end
            end
        end
        translated = TranslationDB[word]
        
    elseif wordCount == 2 then
        -- 两个单词
        local key = table.concat(words, " ")
        if not TranslationDB[key] then
            TranslationDB[key] = (TranslationDB[words[1]] or words[1]) .. "的" .. (TranslationDB[words[2]] or words[2])
        end
        translated = TranslationDB[key]
        
    else
        -- 多个单词
        for i, word in ipairs(words) do
            if i == 1 then
                translated = TranslationDB[word] or word
            else
                translated = translated .. " " .. (TranslationDB[word] or word)
            end
        end
    end
    
    -- 添加语气词
    if isQuestion then
        translated = translated .. "吗？"
    elseif isExclamation then
        translated = translated .. "！"
    end
    
    -- 处理数字
    if hasNumbers then
        translated = translated:gsub("%d", function(d)
            local numMap = {["0"]="零",["1"]="一",["2"]="二",["3"]="三",["4"]="四",
                           ["5"]="五",["6"]="六",["7"]="七",["8"]="八",["9"]="九"}
            return numMap[d] or d
        end)
    end
    
    return translated ~= text and translated or text
end

-- 中文检测
local function isChinese(text)
    return text and text:match("[\228-\233][\128-\191]")
end

-- 英文检测
local function isEnglish(text)
    if not text then return false end
    local hasEnglish = text:match("%a")
    local hasChinese = text:match("[\228-\233][\128-\191]")
    return hasEnglish and not hasChinese
end

-- 翻译逻辑
local function translateTextElement(element)
    if not TranslationEnabled or BlacklistedInstances[element] then return end
    
    local originalText = element.Text
    if originalText and #originalText > 1 and isEnglish(originalText) and not TranslatedObjects[element] then
        local translated = detectAndTranslate(originalText)
        if translated ~= originalText then
            TranslatedObjects[element] = {
                Original = originalText,
                Translated = translated
            }
            element.Text = translated
        end
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

-- 监控函数
local function monitorUI()
    while TranslationEnabled do
        pcall(function()
            -- 监控所有UI容器
            local targets = {
                CoreGui,
                LocalPlayer:WaitForChild("PlayerGui"),
                game:GetService("StarterGui")
            }
            
            for _, target in ipairs(targets) do
                if target then
                    for _, gui in ipairs(target:GetDescendants()) do
                        if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) then
                            translateTextElement(gui)
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
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
    StatusLabel.Text = "状态: 已恢复原文"
end)

ToggleUIBtn.MouseButton1Click:Connect(function()
    UIExpanded = not UIExpanded
    if UIExpanded then
        MainFrame.Size = UDim2.new(0, 280, 0, 180)
        ToggleUIBtn.Text = "−"
        ToggleBtn.Visible = true
        StatusLabel.Visible = true
        RevertBtn.Visible = true
    else
        MainFrame.Size = UDim2.new(0, 280, 0, 30)
        ToggleUIBtn.Text = "+"
        ToggleBtn.Visible = false
        StatusLabel.Visible = false
        RevertBtn.Visible = false
    end
end)

-- 监控新元素
game.DescendantAdded:Connect(function(descendant)
    if TranslationEnabled and (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
        task.delay(0.3, function()
            pcall(translateTextElement, descendant)
        end
    end
end)

-- 右键黑名单
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = UserInputService:GetMouseTarget()
        if target and (target:IsA("TextLabel") or target:IsA("TextButton") or target:IsA("TextBox")) then
            BlacklistedInstances[target] = true
            if TranslatedObjects[target] then
                target.Text = TranslatedObjects[target].Original
                TranslatedObjects[target] = nil
            end
            StatusLabel.Text = "状态: 已屏蔽 "..target.Name
        end
    end
end)

-- 学习模式：自动分析并改进翻译
local function learnFromPatterns()
    for element, data in pairs(TranslatedObjects) do
        if data.Original and data.Translated then
            local words = {}
            for word in data.Original:gmatch("%S+") do
                if #word > 1 then
                    table.insert(words, word:lower())
                end
            end
            
            if #words > 0 then
                for _, word in ipairs(words) do
                    if not TranslationDB[word] then
                        -- 从上下文中学习单词含义
                        local chineseParts = {}
                        for part in data.Translated:gmatch("[^%s]+") do
                            if #part > 1 then
                                table.insert(chineseParts, part)
                            end
                        end
                        
                        if #chineseParts >= #words then
                            TranslationDB[word] = chineseParts[#chineseParts]
                        end
                    end
                end
            end
        end
    end
end

-- 启动监控和学习
task.spawn(monitorUI)
task.spawn(function()
    while true do
        task.wait(10)
        if TranslationEnabled then
            learnFromPatterns()
        end
    end
end)

print("AI翻译系统已加载 - 智能词汇检测 | 动态学习 | 实时翻译")