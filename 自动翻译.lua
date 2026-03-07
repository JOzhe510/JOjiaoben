local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/1379qpalzmtygvezimaliexcvbnqplasdfg/199/refs/heads/main/%E4%BA%91Ul.txt"))()
local Window = Library:new("绿虫虫绿damn")

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local CoreGui = game:GetService("CoreGui")

local TARGET_LANGUAGE = "zh-CN" -- 固定翻译成简体中文
local SCAN_INTERVAL = 2 -- 每2秒扫描一次
local MAX_TEXT_LENGTH = 50000000 -- 最大文本长度限制

local translatedCache = {}
local translatedObjects = {}
local isTranslationEnabled = false
local connection = nil

-- 危险指令列表
local DANGEROUS_COMMANDS = {
    "neon", "shine", "ghost", "gold", "spin", 
    "bighead", "smallhead", "giantdwarf", "squash"
}

-- 支持的UI元素类型
local SUPPORTED_UI_TYPES = {
    "TextLabel", "TextButton", "TextBox", "TextLabel", 
    "Frame", "ScrollingFrame", "ImageButton", "ImageLabel"
}

-- 语言检测模式
local LANGUAGE_PATTERNS = {
    -- 中文 (简体)
    ["zh-CN"] = {
        pattern = "[\199-\244][\128-\191]*[\128-\191]",
        exclude = "[\227][\128-\191][\128-\191]" -- 排除繁体中文特征
    },
    -- 中文 (繁体)
    ["zh-TW"] = {
        pattern = "[\227][\128-\191][\128-\191]"
    },
    -- 日语
    ["ja"] = {
        pattern = "[\123-\125]|[\199-\244][\128-\191]*[\128-\191]",
        exclude = "[\199-\244][\128-\191]*[\128-\191]" -- 排除中文特征
    },
    -- 韩语
    ["ko"] = {
        pattern = "[\234-\235][\128-\191][\128-\191]|[\236-\237][\128-\191][\128-\191]"
    },
    -- 阿拉伯语
    ["ar"] = {
        pattern = "[\216-\219][\128-\191]"
    },
    -- 俄语
    ["ru"] = {
        pattern = "[\208-\209][\128-\191]"
    },
    -- 泰语
    ["th"] = {
        pattern = "[\224-\231][\128-\191]"
    },
    -- 默认英语
    ["en"] = {
        pattern = "[A-Za-z]",
        exclude = "[\199-\244][\128-\191]*[\128-\191]" -- 排除非拉丁字符
    }
}

-- 检查是否为危险文本
local function isDangerousText(text)
    if not text or type(text) ~= "string" then return false end
    local lowerText = text:lower()
    for _, cmd in ipairs(DANGEROUS_COMMANDS) do
        if lowerText:find(cmd) then
            return true
        end
    end
    return false
end

-- 检查是否需要跳过翻译
local function shouldSkipTranslation(text)
    if not text or text == "" or translatedCache[text] then
        return true
    end
    
    -- 跳过纯数字、特殊字符和过长的文本
    if text:match("^%s*$") or 
       text:match("^[0-9%.%s,:/]+$") or 
       #text > MAX_TEXT_LENGTH or
       isDangerousText(text) then
        translatedCache[text] = text
        return true
    end
    
    return false
end

-- 增强的语言检测函数
local function detectLanguage(text)
    if not text or type(text) ~= "string" or text == "" then
        return "en" -- 默认英语
    end
    
    -- 检查是否是中文
    if text:match(LANGUAGE_PATTERNS["zh-CN"].pattern) and 
       (not LANGUAGE_PATTERNS["zh-CN"].exclude or not text:match(LANGUAGE_PATTERNS["zh-CN"].exclude)) then
        return "zh-CN"
    end
    
    -- 检查是否是繁体中文
    if text:match(LANGUAGE_PATTERNS["zh-TW"].pattern) then
        return "zh-TW"
    end
    
    -- 检查是否是日语
    if text:match(LANGUAGE_PATTERNS["ja"].pattern) and 
       (not LANGUAGE_PATTERNS["ja"].exclude or not text:match(LANGUAGE_PATTERNS["ja"].exclude)) then
        return "ja"
    end
    
    -- 检查是否是韩语
    if text:match(LANGUAGE_PATTERNS["ko"].pattern) then
        return "ko"
    end
    
    -- 检查是否是阿拉伯语
    if text:match(LANGUAGE_PATTERNS["ar"].pattern) then
        return "ar"
    end
    
    -- 检查是否是俄语
    if text:match(LANGUAGE_PATTERNS["ru"].pattern) then
        return "ru"
    end
    
    -- 检查是否是泰语
    if text:match(LANGUAGE_PATTERNS["th"].pattern) then
        return "th"
    end
    
    -- 默认认为是英语
    return "en"
end

-- 翻译函数
local function translate(text)
    if shouldSkipTranslation(text) then
        return translatedCache[text] or text
    end

    -- 检测源语言
    local sourceLang = detectLanguage(text)
    
    -- 如果检测到已经是中文，直接返回
    if sourceLang == "zh-CN" or sourceLang == "zh-TW" then
        translatedCache[text] = text
        return text
    end

    -- 使用备选翻译API（如果Google翻译失败）
    local function tryAlternativeAPI()
        local success, response = pcall(function()
            return game:HttpGet(
                ("https://api.mymemory.translated.net/get?q=%s&langpair=%s|%s")
                :format(HttpService:UrlEncode(text), sourceLang, TARGET_LANGUAGE)
            )
        end)
        
        if success and response then
            local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
            if ok and data and data.responseData and data.responseData.translatedText then
                return data.responseData.translatedText
            end
        end
        return nil
    end

    -- 尝试使用Google翻译API，但指定明确的源语言
    local success, response = pcall(function()
        return game:HttpGet(
            ("https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s")
            :format(sourceLang, TARGET_LANGUAGE, HttpService:UrlEncode(text))
        )
    end)

    if success and response then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
        if ok and data and data[1] then
            local translatedText = ""
            for _, segment in ipairs(data[1]) do
                if segment[1] then
                    translatedText = translatedText .. segment[1]
                end
            end
            
            if translatedText ~= "" and translatedText ~= text then
                translatedCache[text] = translatedText
                print("翻译: \"" .. text .. "\" -> \"" .. translatedText .. "\"")
                return translatedText
            end
        end
    end

    -- 尝试备选API
    local altTranslation = tryAlternativeAPI()
    if altTranslation then
        translatedCache[text] = altTranslation
        print("备选API翻译: \"" .. text .. "\" -> \"" .. altTranslation .. "\"")
        return altTranslation
    end

    translatedCache[text] = text
    return text -- 出错时返回原文
end

-- 检查UI元素是否有文本内容
local function hasTextContent(gui)
    if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
        return gui.Text and gui.Text ~= ""
    elseif gui:IsA("ImageButton") or gui:IsA("ImageLabel") then
        return gui:GetAttribute("Text") or gui.Name ~= ""
    end
    return false
end

-- 获取UI元素的文本内容
local function getTextContent(gui)
    if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
        return gui.Text
    elseif gui:IsA("ImageButton") or gui:IsA("ImageLabel") then
        return gui:GetAttribute("Text") or gui.Name
    end
    return nil
end

-- 设置UI元素的文本内容
local function setTextContent(gui, text)
    if gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox") then
        gui.Text = text
    elseif gui:IsA("ImageButton") or gui:IsA("ImageLabel") then
        gui:SetAttribute("OriginalText", getTextContent(gui))
        gui:SetAttribute("Text", text)
    end
end

-- 扫描并翻译UI元素
local function scanAndTranslate()
    local count = 0
    
    -- 扫描PlayerGui
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if not translatedObjects[gui] and hasTextContent(gui) then
            local text = getTextContent(gui)
            if text and text ~= "" then
                translatedObjects[gui] = true
                local translatedText = translate(text)
                if getTextContent(gui) == text then -- 确保文本没有被修改过
                    setTextContent(gui, translatedText)
                    count = count + 1
                end
            end
        end
    end
    
    -- 扫描CoreGui（游戏界面元素）
    for _, gui in ipairs(CoreGui:GetDescendants()) do
        if not translatedObjects[gui] and hasTextContent(gui) then
            local text = getTextContent(gui)
            if text and text ~= "" then
                translatedObjects[gui] = true
                local translatedText = translate(text)
                if getTextContent(gui) == text then -- 确保文本没有被修改过
                    setTextContent(gui, translatedText)
                    count = count + 1
                end
            end
        end
    end
    
    return count
end

local Tab9994 = Window:Tab("翻译", '5436396975')
local Section7891 = Tab9994:section("汉化", true)

-- 修复了Toggle回调函数的问题
Section7891:Toggle("自动翻译", "NightVision", false, function(state)
    isTranslationEnabled = state
    if state then
        print("自动翻译已开启，每" .. SCAN_INTERVAL .. "秒扫描一次")
        
        -- 关闭之前的连接（如果有）
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        -- 立即扫描一次
        local count = scanAndTranslate()
        if count > 0 then
            print("初始扫描翻译了 " .. count .. " 个文本")
        end
        
        -- 创建新的定时扫描
        connection = RunService.Heartbeat:Connect(function()
            if isTranslationEnabled then
                local count = scanAndTranslate()
                if count > 0 then
                    print("自动扫描翻译了 " .. count .. " 个文本")
                end
                -- 使用task.wait而不是wait
                task.wait(SCAN_INTERVAL)
            end
        end)
    else
        -- 关闭定时扫描
        if connection then
            connection:Disconnect()
            connection = nil
        end
        print("自动翻译已关闭")
    end
end)

-- 添加手动扫描按钮
Section7891:Button("立即扫描翻译", function()
    local count = scanAndTranslate()
    Library:Notification("扫描完成", "翻译了 " .. count .. " 个文本", 5)
end)

-- 添加清空缓存按钮
Section7891:Button("清空翻译缓存", function()
    translatedCache = {}
    translatedObjects = {}
    Library:Notification("缓存已清空", "下次扫描将重新翻译所有文本", 5)
end)

task.spawn(function()
    task.wait(3)
    local count = scanAndTranslate()
    if count > 0 then
        print("初始扫描翻译了 " .. count .. " 个文本")
    end
end)