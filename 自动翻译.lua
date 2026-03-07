-- 自动翻译替换器 - 完全复刻飞行UI
-- 放在StarterGui或PlayerGui的LocalScript里

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ==================== DeepSeek API配置 ====================
local CONFIG = {
    ApiKey = "sk-734f0b94253b4ad0a69eff281f122fab",
    ApiUrl = "https://api.deepseek.com/v1/chat/completions",
    TargetLanguage = "简体中文",
}

-- 翻译缓存和原文存储
local translationCache = {}        -- 缓存翻译结果 {原文 = 译文}
local objectOriginalTexts = {}     -- 存储对象的原文 {对象 = {原文文本, 属性名}}
local isEnabled = false            -- 翻译开关
local showOriginal = false         -- 显示原文开关
local scanConnection = nil         -- 扫描连接

-- ==================== 创建UI（完全照搬飞行UI） ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TranslatorUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 380)  -- 稍微高点容纳更多按钮
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- 标题栏
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -70, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "自动翻译"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 50, 0, 25)
closeButton.Position = UDim2.new(1, -60, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "关闭UI"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 12
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- ==================== 开关按钮（像飞行按钮） ====================
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 280, 0, 50)
toggleButton.Position = UDim2.new(0.5, -140, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)  -- 蓝色（关闭状态）
toggleButton.BorderSizePixel = 0
toggleButton.Text = "● 开启翻译"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleButton

-- ==================== 显示原文按钮（像平台按钮） ====================
local originalButton = Instance.new("TextButton")
originalButton.Name = "OriginalButton"
originalButton.Size = UDim2.new(0, 280, 0, 40)
originalButton.Position = UDim2.new(0.5, -140, 0.28, 0)
originalButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)  -- 紫色
originalButton.BorderSizePixel = 0
originalButton.Text = "显示原文 (关闭)"
originalButton.TextColor3 = Color3.fromRGB(255, 255, 255)
originalButton.Font = Enum.Font.GothamBold
originalButton.TextSize = 16
originalButton.Parent = mainFrame

local originalCorner = Instance.new("UICorner")
originalCorner.CornerRadius = UDim.new(0, 8)
originalCorner.Parent = originalButton

-- ==================== 语言选择（像速度输入框区域） ====================
local languageLabel = Instance.new("TextLabel")
languageLabel.Name = "LanguageLabel"
languageLabel.Size = UDim2.new(0, 280, 0, 25)
languageLabel.Position = UDim2.new(0.5, -140, 0.42, 0)
languageLabel.BackgroundTransparency = 1
languageLabel.Text = "目标语言:"
languageLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
languageLabel.Font = Enum.Font.Gotham
languageLabel.TextSize = 14
languageLabel.TextXAlignment = Enum.TextXAlignment.Left
languageLabel.Parent = mainFrame

local languageFrame = Instance.new("Frame")
languageFrame.Name = "LanguageFrame"
languageFrame.Size = UDim2.new(0, 280, 0, 35)
languageFrame.Position = UDim2.new(0.5, -140, 0.5, 0)
languageFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
languageFrame.BorderSizePixel = 0
languageFrame.Parent = mainFrame

local languageCorner = Instance.new("UICorner")
languageCorner.CornerRadius = UDim.new(0, 8)
languageCorner.Parent = languageFrame

local languageDropdown = Instance.new("TextButton")
languageDropdown.Name = "LanguageDropdown"
languageDropdown.Size = UDim2.new(0.9, 0, 0.7, 0)
languageDropdown.Position = UDim2.new(0.05, 0, 0.15, 0)
languageDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
languageDropdown.BorderSizePixel = 0
languageDropdown.Text = "简体中文"
languageDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
languageDropdown.Font = Enum.Font.Gotham
languageDropdown.TextSize = 14
languageDropdown.Parent = languageFrame

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 6)
dropdownCorner.Parent = languageDropdown

-- ==================== 状态信息（像速度标签） ====================
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 280, 0, 25)
statusLabel.Position = UDim2.new(0.5, -140, 0.68, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "状态: 已关闭 | 缓存: 0"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

-- ==================== 删除UI按钮（和飞行UI一样） ====================
local deleteButton = Instance.new("TextButton")
deleteButton.Name = "DeleteButton"
deleteButton.Size = UDim2.new(0, 120, 0, 35)
deleteButton.Position = UDim2.new(0.5, -60, 0.85, 0)
deleteButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
deleteButton.BorderSizePixel = 0
deleteButton.Text = "删除UI"
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Font = Enum.Font.Gotham
deleteButton.TextSize = 13
deleteButton.Parent = mainFrame

local deleteCorner = Instance.new("UICorner")
deleteCorner.CornerRadius = UDim.new(0, 6)
deleteCorner.Parent = deleteButton

-- ==================== 打开UI按钮（隐藏时的悬浮按钮） ====================
local openUIButton = Instance.new("TextButton")
openUIButton.Name = "OpenUIButton"
openUIButton.Size = UDim2.new(0, 80, 0, 35)
openUIButton.Position = UDim2.new(0, 10, 0, 10)
openUIButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
openUIButton.BorderSizePixel = 0
openUIButton.Text = "翻译"
openUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openUIButton.Font = Enum.Font.Gotham
openUIButton.TextSize = 12
openUIButton.Visible = false
openUIButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openUIButton

-- ==================== 语言列表 ====================
local languages = {
    "简体中文",
    "繁体中文",
    "英语",
    "日语",
    "韩语",
    "法语",
    "德语",
    "俄语",
}
local currentLangIndex = 1

-- ==================== 悬停效果函数 ====================
local function setupButtonHover(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = originalColor * 1.2
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
end

-- 给所有按钮添加悬停效果
setupButtonHover(closeButton)
setupButtonHover(toggleButton)
setupButtonHover(originalButton)
setupButtonHover(languageDropdown)
setupButtonHover(deleteButton)
setupButtonHover(openUIButton)

-- ==================== UI事件 ====================
closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openUIButton.Visible = true
end)

openUIButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openUIButton.Visible = false
end)

deleteButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- 语言选择
languageDropdown.MouseButton1Click:Connect(function()
    currentLangIndex = currentLangIndex % #languages + 1
    CONFIG.TargetLanguage = languages[currentLangIndex]
    languageDropdown.Text = CONFIG.TargetLanguage
    -- 清空缓存，强制重新翻译
    translationCache = {}
    updateStatus()
end)

-- ==================== 翻译函数 ====================
local function callDeepSeekAPI(text, callback)
    local success, result = pcall(function()
        local requestBody = {
            model = "deepseek-chat",
            messages = {
                {
                    role = "system",
                    content = string.format("你是一个翻译助手。请把用户输入的内容翻译成%s。只返回翻译结果，不要有任何解释或额外内容。", CONFIG.TargetLanguage)
                },
                {
                    role = "user",
                    content = text
                }
            },
            temperature = 0.3,
            max_tokens = 500,
            stream = false
        }
        
        local response = HttpService:RequestAsync({
            Url = CONFIG.ApiUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. CONFIG.ApiKey
            },
            Body = HttpService:JSONEncode(requestBody),
            Timeout = 5
        })
        
        if response.Success and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data.choices and #data.choices > 0 then
                return data.choices[1].message.content
            end
        end
        return nil
    end)
    
    if success and result then
        callback(result)
    else
        callback(text)  -- 失败返回原文
    end
end

local function translateText(originalText, callback)
    if not originalText or type(originalText) ~= "string" or originalText == "" then
        callback(originalText)
        return
    end
    
    -- 检查缓存
    if translationCache[originalText] then
        callback(translationCache[originalText])
        return
    end
    
    -- 调用API
    callDeepSeekAPI(originalText, function(translated)
        translationCache[originalText] = translated
        updateStatus()
        callback(translated)
    end)
end

-- ==================== 文本扫描和替换 ====================
local function shouldTranslate(text)
    if not text or text == "" then return false end
    -- 简单判断是否包含中文
    if string.match(text, "[\228-\233][\128-\191]+") then
        return false  -- 已经是中文，不翻译
    end
    return true
end

local function processTextObject(obj, textProp)
    if not obj or not obj[textProp] then return end
    
    local originalText = obj[textProp]
    if originalText == "" then return end
    
    -- 保存原文（如果还没保存）
    if not objectOriginalTexts[obj] then
        objectOriginalTexts[obj] = {text = originalText, prop = textProp}
    end
    
    -- 需要翻译
    if shouldTranslate(originalText) then
        translateText(originalText, function(translated)
            if showOriginal then
                -- 如果当前是显示原文模式，就不改
                return
            else
                -- 否则替换成翻译
                obj[textProp] = translated
            end
        end)
    end
end

local function scanAndTranslate(instance)
    if not isEnabled then return end
    
    -- 检查各种文本对象
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        processTextObject(instance, "Text")
    elseif instance:IsA("Hint") or instance:IsA("Message") then
        processTextObject(instance, "Text")
    end
    
    -- 继续扫描子对象
    for _, child in ipairs(instance:GetChildren()) do
        scanAndTranslate(child)
    end
end

-- ==================== 切换显示模式 ====================
local function applyDisplayMode()
    if showOriginal then
        -- 显示原文
        for obj, data in pairs(objectOriginalTexts) do
            if obj and obj.Parent then  -- 对象还存在
                obj[data.prop] = data.text
            end
        end
        originalButton.Text = "显示原文 (开启)"
        originalButton.BackgroundColor3 = Color3.fromRGB(200, 120, 80)  -- 橙色
    else
        -- 显示翻译
        for obj, data in pairs(objectOriginalTexts) do
            if obj and obj.Parent and translationCache[data.text] then
                obj[data.prop] = translationCache[data.text]
            end
        end
        originalButton.Text = "显示原文 (关闭)"
        originalButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)  -- 紫色
    end
end

-- ==================== 开关翻译 ====================
local function startTranslation()
    isEnabled = true
    toggleButton.Text = "● 关闭翻译"
    toggleButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)  -- 红色
    
    -- 清空原文记录（重新开始）
    objectOriginalTexts = {}
    
    -- 立即扫描一次
    scanAndTranslate(playerGui)
    
    -- 定期扫描新出现的文本
    scanConnection = RunService.Heartbeat:Connect(function()
        if not isEnabled then return end
        -- 每2秒扫描一次
        if tick() % 2 < 0.1 then
            scanAndTranslate(playerGui)
        end
    end)
    
    updateStatus()
end

local function stopTranslation()
    isEnabled = false
    toggleButton.Text = "● 开启翻译"
    toggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)  -- 蓝色
    
    -- 停止扫描
    if scanConnection then
        scanConnection:Disconnect()
        scanConnection = nil
    end
    
    -- 清空缓存（但保持当前显示不变）
    translationCache = {}
    -- 注意：不清空objectOriginalTexts，这样显示原文按钮还能工作
    
    updateStatus()
end

-- ==================== 更新状态显示 ====================
local function updateStatus()
    local cacheCount = 0
    for _ in pairs(translationCache) do
        cacheCount = cacheCount + 1
    end
    
    local status = isEnabled and "开启" or "关闭"
    statusLabel.Text = string.format("状态: %s | 缓存: %d", status, cacheCount)
end

-- ==================== 按钮事件 ====================
toggleButton.MouseButton1Click:Connect(function()
    if isEnabled then
        stopTranslation()
    else
        startTranslation()
    end
end)

originalButton.MouseButton1Click:Connect(function()
    showOriginal = not showOriginal
    applyDisplayMode()
end)

-- ==================== 初始化 ====================
screenGui.Parent = playerGui
updateStatus()
print("自动翻译器已加载 - 开启后自动翻译游戏内文本")

-- 清理函数
screenGui.Destroying:Connect(function()
    if scanConnection then
        scanConnection:Disconnect()
    end
end)