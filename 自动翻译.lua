-- 自动翻译器（飞行UI风格）- 直接替换游戏内文本
-- 放在StarterGui或PlayerGui的LocalScript里

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== DeepSeek API配置 ====================
local CONFIG = {
    ApiKey = "sk-734f0b94253b4ad0a69eff281f122fab",
    ApiUrl = "https://api.deepseek.com/v1/chat/completions",
    TargetLanguage = "简体中文",
    Timeout = 10,
}

-- 翻译缓存
local translationCache = {}
local pendingTranslations = {}  -- 防止重复请求相同文本

-- 要监控的文本对象类型
local TEXT_CLASSES = {
    "TextLabel",
    "TextButton",
    "TextBox",
    "Hint",
    "Message",
    "BillboardGui"
}

-- 是否开启自动翻译
local isEnabled = true

-- ==================== 创建UI（飞行风格，但更简洁） ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoTranslator"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 主框架（默认隐藏，按F6显示）
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 200)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- 圆角
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
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "自动翻译替换器"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = titleBar

-- 状态灯
local statusLight = Instance.new("Frame")
statusLight.Size = UDim2.new(0, 12, 0, 12)
statusLight.Position = UDim2.new(1, -20, 0, 11)
statusLight.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- 绿色=开启
statusLight.BorderSizePixel = 0
statusLight.Parent = titleBar

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = statusLight

-- ==================== 开关按钮（像飞行按钮） ====================
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 240, 0, 45)
toggleButton.Position = UDim2.new(0.5, -120, 0.25, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "● 翻译替换已开启"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- ==================== 语言选择（像平台按钮） ====================
local languageButton = Instance.new("TextButton")
languageButton.Size = UDim2.new(0, 240, 0, 35)
languageButton.Position = UDim2.new(0.5, -120, 0.5, 0)
languageButton.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
languageButton.BorderSizePixel = 0
languageButton.Text = "目标语言: 简体中文"
languageButton.TextColor3 = Color3.fromRGB(255, 255, 255)
languageButton.Font = Enum.Font.GothamBold
languageButton.TextSize = 14
languageButton.Parent = mainFrame

local languageCorner = Instance.new("UICorner")
languageCorner.CornerRadius = UDim.new(0, 8)
languageCorner.Parent = languageButton

-- ==================== 统计信息 ====================
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0, 240, 0, 30)
statsLabel.Position = UDim2.new(0.5, -120, 0.75, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "已替换: 0 个文本"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextSize = 14
statsLabel.Parent = mainFrame

-- ==================== 语言列表 ====================
local languages = {
    "简体中文",
    "繁体中文",
    "日语",
    "韩语",
    "法语",
    "德语",
    "俄语",
    "西班牙语",
}
local currentLangIndex = 1

-- ==================== 悬停效果 ====================
local function setupHover(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = originalColor * 1.2
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
end

setupHover(toggleButton)
setupHover(languageButton)

-- ==================== 按钮事件 ====================
toggleButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        toggleButton.Text = "● 翻译替换已开启"
        toggleButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        statusLight.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        toggleButton.Text = "○ 翻译替换已关闭"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        statusLight.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

languageButton.MouseButton1Click:Connect(function()
    currentLangIndex = currentLangIndex % #languages + 1
    CONFIG.TargetLanguage = languages[currentLangIndex]
    languageButton.Text = "目标语言: " .. CONFIG.TargetLanguage
    -- 切换语言时清空缓存，强制重新翻译
    translationCache = {}
end)

-- F6键显示/隐藏UI
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F6 then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- ==================== 翻译函数 ====================
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
    
    -- 避免重复请求相同文本
    if pendingTranslations[originalText] then
        -- 如果已经在翻译中，等待结果
        local count = 0
        while pendingTranslations[originalText] and count < 50 do
            task.wait(0.1)
            count = count + 1
        end
        if translationCache[originalText] then
            callback(translationCache[originalText])
        else
            callback(originalText)
        end
        return
    end
    
    pendingTranslations[originalText] = true
    
    -- 调用DeepSeek API
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
                    content = originalText
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
            Body = HttpService:JSONEncode(requestBody)
        })
        
        if response.Success and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data.choices and #data.choices > 0 then
                return data.choices[1].message.content
            end
        end
        return nil
    end)
    
    pendingTranslations[originalText] = nil
    
    if success and result then
        -- 存入缓存
        translationCache[originalText] = result
        -- 更新统计
        local currentCount = tonumber(string.match(statsLabel.Text, "(%d+)")) or 0
        statsLabel.Text = "已替换: " .. (currentCount + 1) .. " 个文本"
        callback(result)
    else
        callback(originalText)  -- 翻译失败则返回原文
    end
end

-- ==================== 扫描并替换文本 ====================
local processedObjects = {}  -- 记录已处理的对象
local scanConnections = {}    -- 存储连接

local function scanAndTranslate(instance)
    if not isEnabled then return end
    if processedObjects[instance] then return end  -- 已经处理过
    
    -- 检查是否是文本对象
    for _, className in ipairs(TEXT_CLASSES) do
        if instance:IsA(className) then
            -- 获取文本属性
            local textProp = nil
            if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
                textProp = "Text"
            elseif instance:IsA("Hint") or instance:IsA("Message") then
                textProp = "Text"
            elseif instance:IsA("BillboardGui") then
                -- BillboardGui本身没有文本，需要遍历子对象
                for _, child in ipairs(instance:GetChildren()) do
                    if child:IsA("TextLabel") then
                        scanAndTranslate(child)
                    end
                end
                return
            end
            
            if textProp and instance[textProp] and instance[textProp] ~= "" then
                local originalText = instance[textProp]
                
                -- 检查是否已经是中文（简单判断）
                if string.match(originalText, "[\228-\233][\128-\191]+") then
                    return  -- 已经包含中文字符，不翻译
                end
                
                -- 保存原始文本（如果还没保存）
                if not instance:GetAttribute("OriginalText") then
                    instance:SetAttribute("OriginalText", originalText)
                end
                
                -- 翻译并替换
                translateText(originalText, function(translated)
                    if translated and translated ~= originalText then
                        instance[textProp] = translated
                        processedObjects[instance] = true
                    end
                end)
            end
            break
        end
    end
    
    -- 如果是GuiObject，可能有子对象
    if instance:IsA("GuiObject") or instance:IsA("Folder") or instance:IsA("ScreenGui") then
        for _, child in ipairs(instance:GetChildren()) do
            scanAndTranslate(child)
        end
    end
end

-- ==================== 监控新添加的对象 ====================
local function setupWatcher()
    -- 监听新添加的对象
    local connection = playerGui.DescendantAdded:Connect(function(descendant)
        task.wait(0.5)  -- 稍微延迟，等对象完全加载
        scanAndTranslate(descendant)
    end)
    table.insert(scanConnections, connection)
    
    -- 定期重新扫描（处理动态更新的文本）
    local heartbeatConn = RunService.Heartbeat:Connect(function()
        if not isEnabled then return end
        
        -- 每5秒扫描一次（避免性能问题）
        if tick() % 5 < 0.1 then
            for _, descendant in ipairs(playerGui:GetDescendants()) do
                scanAndTranslate(descendant)
            end
        end
    end)
    table.insert(scanConnections, heartbeatConn)
end

-- ==================== 初始化扫描 ====================
local function initialize()
    print("自动翻译替换器已启动 - 按F6打开设置")
    
    -- 先扫描现有所有对象
    for _, descendant in ipairs(playerGui:GetDescendants()) do
        scanAndTranslate(descendant)
    end
    
    -- 设置监控
    setupWatcher()
end

-- 启动
initialize()

-- ==================== 清理函数 ====================
screenGui.Destroying:Connect(function()
    for _, conn in ipairs(scanConnections) do
        conn:Disconnect()
    end
end)