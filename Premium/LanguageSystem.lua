-- ============================================================
-- ATG HUB - Pure Auto-Translation System
-- Uses LibreTranslate API for all translations
-- No manual translation data required
-- ============================================================

local LanguageSystem = {}
LanguageSystem.__index = LanguageSystem

-- ============================================================
-- AUTO-TRANSLATION CONFIGURATION
-- ============================================================
LanguageSystem.libreTranslateURL = "http://119.59.124.192:5000/translate"
LanguageSystem.translationCache = {} -- Cache for auto-translated strings
LanguageSystem.cacheExpiry = 3600 -- Cache expiry in seconds (1 hour)
LanguageSystem.requestTimeout = 10 -- Request timeout in seconds

-- ============================================================
-- BASIC LANGUAGE STRUCTURE (Minimal)
-- ============================================================
LanguageSystem.Languages = {
    en = {
        code = "en",
        name = "English",
        flag = "🇺🇸"
    },
    th = {
        code = "th",
        name = "ไทย",
        flag = "🇹🇭"
    },
    zh = {
        code = "zh",
        name = "中文",
        flag = "🇨🇳"
    },
    ja = {
        code = "ja",
        name = "日本語",
        flag = "🇯🇵"
    },
    ko = {
        code = "ko",
        name = "한국어",
        flag = "🇰🇷"
    }
}

-- ============================================================
-- CURRENT LANGUAGE STATE
-- ============================================================
LanguageSystem.currentLanguage = "en"
LanguageSystem.supportedLanguages = {"en", "th", "zh", "ja", "ko"}
LanguageSystem.fallbackLanguage = "en"

-- ============================================================
-- AUTO-TRANSLATION FUNCTIONS
-- ============================================================

-- Initialize translation cache
local function initTranslationCache()
    for _, langCode in ipairs(LanguageSystem.supportedLanguages) do
        LanguageSystem.translationCache[langCode] = LanguageSystem.translationCache[langCode] or {}
    end
end

-- Get HttpService (Roblox environment)
local HttpService = nil
if game and game.GetService then
    HttpService = game:GetService("HttpService")
else
    -- Fallback for non-Roblox environments
    HttpService = {
        JSONEncode = function(t) return "" end,
        JSONDecode = function(s) return {} end,
        RequestAsync = function() return {Success = false, Body = "{}"} end
    }
end

-- Auto-translate using LibreTranslate API with request function
local function translateText(url, text, sourceLang, targetLang)
    -- Validate input
    if not text or type(text) ~= "string" or text == "" then
        return text
    end

    -- Normalize Unicode (basic)
    text = text:gsub("[\194-\244][\128-\191]*", function(c) return c end)

    -- Check cache first
    local cacheKey = sourceLang .. "_" .. targetLang .. "_" .. text
    LanguageSystem.translationCache[targetLang] = LanguageSystem.translationCache[targetLang] or {}
    local cached = LanguageSystem.translationCache[targetLang][cacheKey]
    if cached and (os.time() - cached.timestamp) < LanguageSystem.cacheExpiry then
        return cached.translatedText
    end

    -- Create JSON Body
    local requestBody = {
        q = text,
        source = sourceLang,
        target = targetLang
    }

    local jsonBody = HttpService:JSONEncode(requestBody)

    -- Use HttpService:RequestAsync (Roblox standard)
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonBody
        })
    end)

    if success and response and response.Success then
        local decodedResponse = HttpService:JSONDecode(response.Body)
        local translated = decodedResponse.translatedText

        -- Normalize Unicode in result
        if translated then
            translated = translated:gsub("[\194-\244][\128-\191]*", function(c) return c end)

            -- Cache the result
            LanguageSystem.translationCache[targetLang][cacheKey] = {
                translatedText = translated,
                timestamp = os.time()
            }

            return translated
        end
    end

    -- Fallback: return original text with indicator
    return "🔄 " .. text
end

-- ============================================================
-- ENHANCED FEATURES: Date/Number Formatting & Unicode Support
-- ============================================================

-- Unicode validation and normalization
local function validateUnicode(text)
    if not text or type(text) ~= "string" then return false end
    local success = pcall(function()
        return text:len() > 0 and utf8.len(text) ~= nil
    end)
    return success
end

local function normalizeUnicode(text)
    if not validateUnicode(text) then return text end
    return text:gsub("[\194-\244][\128-\191]*", function(c)
        return c -- Keep valid UTF-8 sequences
    end)
end

-- Date formatting for different locales
local function formatDate(locale, timestamp)
    timestamp = timestamp or os.time()
    local dateTable = os.date("*t", timestamp)

    if locale == "th" then
        local thaiYear = dateTable.year + 543
        return string.format("%02d/%02d/%d", dateTable.day, dateTable.month, thaiYear)
    elseif locale == "zh" or locale == "ja" then
        return string.format("%d年%02d月%02d日", dateTable.year, dateTable.month, dateTable.day)
    elseif locale == "ko" then
        return string.format("%d년 %02d월 %02d일", dateTable.year, dateTable.month, dateTable.day)
    else -- en
        return string.format("%02d/%02d/%d", dateTable.month, dateTable.day, dateTable.year)
    end
end

-- Number formatting for different locales
local function formatNumber(locale, number)
    if type(number) ~= "number" then return tostring(number) end

    local str = string.format("%.2f", number)

    if locale == "th" or locale == "en" then
        return str:gsub("(%d)(%d%d%d)%.", "%1,%2.")
               :gsub("(%d)(%d%d%d),", "%1,%2,")
    elseif locale == "zh" or locale == "ja" or locale == "ko" then
        return str:gsub("(%d)(%d%d%d)%.", "%1,%2.")
               :gsub("(%d)(%d%d%d),", "%1,%2,")
    else
        return str
    end
end

-- Time formatting
local function formatTime(locale, seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- ============================================================
-- CORE FUNCTIONS
-- ============================================================

-- Enhanced GetText with auto-translation
function LanguageSystem:GetText(keyPath)
    -- Validate input
    if not keyPath or type(keyPath) ~= "string" then
        return "INVALID_KEY"
    end

    -- Check if language is supported
    if not self:IsLanguageSupported(self.currentLanguage) then
        self.currentLanguage = self.fallbackLanguage
    end

    -- If current language is English, return key path (no translation needed)
    if self.currentLanguage == "en" then
        return normalizeUnicode(keyPath)
    end

    -- Check cache first
    local cacheKey = "key_" .. self.currentLanguage .. "_" .. keyPath
    self.translationCache[self.currentLanguage] = self.translationCache[self.currentLanguage] or {}
    local cached = self.translationCache[self.currentLanguage][cacheKey]
    if cached and (os.time() - cached.timestamp) < self.cacheExpiry then
        return cached.translatedText
    end

    -- Auto-translate the key path
    local translated = translateText(self.libreTranslateURL, keyPath, "en", self.currentLanguage)

    -- Cache the result
    self.translationCache[self.currentLanguage][cacheKey] = {
        translatedText = translated,
        timestamp = os.time()
    }

    return translated
end

-- Short alias for GetText
function LanguageSystem:T(keyPath)
    return self:GetText(keyPath)
end

-- Set current language
function LanguageSystem:SetLanguage(langCode)
    if not langCode or type(langCode) ~= "string" then
        return false
    end

    if not self:IsLanguageSupported(langCode) then
        return false
    end

    local oldLanguage = self.currentLanguage
    self.currentLanguage = langCode

    -- Save to getgenv for persistence (Roblox environment)
    if getgenv then
        getgenv().ATG_Language = langCode
    end

    return true
end

-- Get current language
function LanguageSystem:GetCurrentLanguage()
    return self.currentLanguage
end

-- Get all available languages
function LanguageSystem:GetAvailableLanguages()
    local languages = {}
    for code, data in pairs(self.Languages) do
        table.insert(languages, {
            code = code,
            name = data.name,
            flag = data.flag,
            display = string.format("%s %s", data.flag, data.name)
        })
    end

    table.sort(languages, function(a, b)
        return a.name < b.name
    end)

    return languages
end

-- Check if language is supported
function LanguageSystem:IsLanguageSupported(langCode)
    for _, supported in ipairs(self.supportedLanguages) do
        if supported == langCode then
            return true
        end
    end
    return false
end

-- Format date according to current language locale
function LanguageSystem:FormatDate(timestamp)
    return formatDate(self.currentLanguage, timestamp)
end

-- Format number according to current language locale
function LanguageSystem:FormatNumber(number)
    return formatNumber(self.currentLanguage, number)
end

-- Format time duration
function LanguageSystem:FormatTime(seconds)
    return formatTime(self.currentLanguage, seconds)
end

-- Get localized date and time string
function LanguageSystem:GetLocalizedDateTime()
    local now = os.time()
    local dateStr = self:FormatDate(now)
    local timeStr = os.date("%H:%M:%S", now)
    return dateStr .. " " .. timeStr
end

-- Validate and normalize text for Unicode compliance
function LanguageSystem:ValidateAndNormalizeText(text)
    if not validateUnicode(text) then
        return text
    end
    return normalizeUnicode(text)
end

-- Clear translation cache
function LanguageSystem:ClearTranslationCache()
    self.translationCache = {}
    initTranslationCache()
end

-- Test auto-translation
function LanguageSystem:TestAutoTranslation(text, targetLang)
    if not text or not targetLang then
        return "❌ Invalid parameters"
    end

    print("[LanguageSystem] Testing auto-translation...")
    print("Original text: " .. text)
    print("Target language: " .. targetLang)

    local result = translateText(self.libreTranslateURL, text, "en", targetLang)
    print("Translated result: " .. result)

    return result
end

-- Initialize language system
function LanguageSystem:Initialize()
    -- Initialize translation cache
    initTranslationCache()

    -- Load saved language from getgenv (Roblox environment)
    if getgenv and type(getgenv) == "function" then
        local genv = getgenv()
        if genv and genv.ATG_Language then
            local savedLang = genv.ATG_Language
            if self.Languages[savedLang] then
                self.currentLanguage = savedLang
            end
        end
    end

    return self
end

-- ============================================================
-- GLOBAL INSTANCE
-- ============================================================
local instance = setmetatable({}, LanguageSystem)
instance:Initialize()

-- Expose globally
if getgenv and type(getgenv) == "function" then
    local genv = getgenv()
    if genv then
        genv.ATG_Lang = instance
    end
end
_G.ATG_Lang = instance

return instance
