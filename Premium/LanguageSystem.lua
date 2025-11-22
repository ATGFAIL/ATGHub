--[[
================================================================
ATG HUB - Premium Auto Translation System
----------------------------------------------------------------
This module auto-translates every UI Title/Description on demand by
sending the original English text directly to LibreTranslate. No
pre-baked language tables are required—developers simply wrap any
English string with Lang:T("Hello world") and the system will:
  1. Detect the request.
  2. Forward the English text to LibreTranslate using the active locale.
  3. Cache the translated result per language.
  4. Fall back to the original text if the API is unavailable.
================================================================
]]

local LanguageSystem = {}
LanguageSystem.__index = LanguageSystem

-- ============================================================
-- CONFIGURATION & STATE
-- ============================================================
LanguageSystem.libreTranslateURL = "http://119.59.124.192:5000/translate"
LanguageSystem.cacheExpiry = 3600 -- seconds
LanguageSystem.requestTimeout = 10 -- seconds
LanguageSystem.autoTranslate = true

LanguageSystem.translationCache = {}
LanguageSystem.manualTranslations = {}
LanguageSystem.friendlyKeyCache = {}
LanguageSystem.persistentCache = {}
LanguageSystem.loadedPersistentLanguages = {}
LanguageSystem.cacheDirtyLanguages = {}
LanguageSystem.cacheFlushScheduled = false
LanguageSystem.cacheFolder = "ATG_LanguageCache"
LanguageSystem.cacheFilePrefix = "locale_"
LanguageSystem.cacheFileExtension = ".json"
LanguageSystem.maxPersistentEntries = 1200

LanguageSystem.Languages = {
    en = {code = "en", name = "English", flag = "🇺🇸"},
    th = {code = "th", name = "ไทย", flag = "🇹🇭"},
    zh = {code = "zh", name = "中文", flag = "🇨🇳"},
    ja = {code = "ja", name = "日本語", flag = "🇯🇵"},
    ko = {code = "ko", name = "한국어", flag = "🇰🇷"},
}

LanguageSystem.supportedLanguages = {}
LanguageSystem.currentLanguage = "en"
LanguageSystem.fallbackLanguage = "en"
LanguageSystem.languageChangeCallbacks = {}

-- ============================================================
-- INTERNAL HELPERS
-- ============================================================
local function refreshSupportedLanguages()
    LanguageSystem.supportedLanguages = {}
    for code in pairs(LanguageSystem.Languages) do
        table.insert(LanguageSystem.supportedLanguages, code)
        LanguageSystem.translationCache[code] = LanguageSystem.translationCache[code] or {}
        LanguageSystem.manualTranslations[code] = LanguageSystem.manualTranslations[code] or {}
    end
    table.sort(LanguageSystem.supportedLanguages)
end

refreshSupportedLanguages()

local HttpService
if game and game.GetService then
    HttpService = game:GetService("HttpService")
else
    HttpService = {
        JSONEncode = function()
            return "{}"
        end,
        JSONDecode = function()
            return {}
        end,
        RequestAsync = function()
            return {Success = false, Body = "{}"}
        end,
    }
end

local FileAPI = {
    read = type(readfile) == "function" and readfile or nil,
    write = type(writefile) == "function" and writefile or nil,
    exists = type(isfile) == "function" and isfile or nil,
    isfolder = type(isfolder) == "function" and isfolder or nil,
    makefolder = type(makefolder) == "function" and makefolder or nil,
}

LanguageSystem.hasFileIO = FileAPI.read ~= nil and FileAPI.write ~= nil and FileAPI.exists ~= nil
LanguageSystem.hasFolderIO = LanguageSystem.hasFileIO and FileAPI.isfolder ~= nil and FileAPI.makefolder ~= nil

local function getCacheFilePath(lang)
    lang = tostring(lang)
    if LanguageSystem.hasFolderIO then
        return string.format("%s/%s%s%s", LanguageSystem.cacheFolder, LanguageSystem.cacheFilePrefix, lang, LanguageSystem.cacheFileExtension)
    end
    return string.format("%s%s%s", LanguageSystem.cacheFilePrefix, lang, LanguageSystem.cacheFileExtension)
end

local function ensureCacheDirectory()
    if not LanguageSystem.hasFolderIO then
        return LanguageSystem.hasFileIO
    end
    local ok, exists = pcall(FileAPI.isfolder, LanguageSystem.cacheFolder)
    if ok and exists then
        return true
    end
    if not ok and exists == nil then
        return false
    end
    local created = pcall(FileAPI.makefolder, LanguageSystem.cacheFolder)
    return created == true
end

local rawHttpRequest = nil
if type(request) == "function" then
    rawHttpRequest = request
elseif type(http_request) == "function" then
    rawHttpRequest = http_request
elseif syn and type(syn.request) == "function" then
    rawHttpRequest = syn.request
elseif http and type(http.request) == "function" then
    rawHttpRequest = http.request
elseif fluxus and type(fluxus.request) == "function" then
    rawHttpRequest = fluxus.request
end

local function postJson(url, jsonBody)
    if rawHttpRequest then
        local success, response = pcall(rawHttpRequest, {
            Url = url,
            Method = "POST",
            Headers = {['Content-Type'] = 'application/json'},
            Body = jsonBody,
        })
        if not success or not response then
            return nil
        end
        local ok = response.Success
        if ok == nil and response.StatusCode then
            ok = response.StatusCode >= 200 and response.StatusCode < 300
        end
        if ok == false then
            return nil
        end
        return response.Body
    end

    if HttpService and HttpService.RequestAsync then
        local success, response = pcall(function()
            return HttpService:RequestAsync({
                Url = url,
                Method = "POST",
                Headers = {['Content-Type'] = 'application/json'},
                Body = jsonBody,
            })
        end)
        if not success or not response or not response.Success then
            return nil
        end
        return response.Body
    end

    return nil
end

local function validateUnicode(text)
    if not text or type(text) ~= "string" then
        return false
    end
    local ok = pcall(function()
        return text:len() > 0 and utf8.len(text) ~= nil
    end)
    return ok
end

local function normalizeUnicode(text)
    if not validateUnicode(text) then
        return text
    end
    return text:gsub("[\194-\244][\128-\191]*", function(c)
        return c
    end)
end

local function toTitleCase(segment)
    return segment:gsub("_%s*", " ")
        :gsub("(%a)([%w']*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
end

local function prettifyKey(raw)
    if LanguageSystem.friendlyKeyCache[raw] then
        return LanguageSystem.friendlyKeyCache[raw]
    end
    local lastChunk = raw:match("([%w_%-]+)$") or raw
    local pretty = toTitleCase(lastChunk)
    LanguageSystem.friendlyKeyCache[raw] = pretty
    return pretty
end

local function ensureLanguageBuckets(lang)
    LanguageSystem.translationCache[lang] = LanguageSystem.translationCache[lang] or {}
    LanguageSystem.manualTranslations[lang] = LanguageSystem.manualTranslations[lang] or {}
    LanguageSystem.persistentCache[lang] = LanguageSystem.persistentCache[lang] or {}
end

local function getPersistentEntryCount(lang)
    local bucket = LanguageSystem.persistentCache[lang]
    if not bucket then return 0 end
    local count = 0
    for _ in pairs(bucket) do
        count += 1
    end
    return count
end

function LanguageSystem:TrimPersistentCache(lang)
    local bucket = self.persistentCache[lang]
    if not bucket then return end
    local entryCount = getPersistentEntryCount(lang)
    if entryCount <= self.maxPersistentEntries then
        return
    end

    local runtimeCache = self.translationCache[lang] or {}
    repeat
        local oldestKey, oldestTimestamp = nil, math.huge
        for key, meta in pairs(runtimeCache) do
            if bucket[key] and meta and meta.timestamp and meta.timestamp < oldestTimestamp then
                oldestTimestamp = meta.timestamp
                oldestKey = key
            end
        end
        if not oldestKey then
            break
        end
        bucket[oldestKey] = nil
        runtimeCache[oldestKey] = nil
        entryCount -= 1
    until entryCount <= self.maxPersistentEntries
end

function LanguageSystem:WriteCacheToFile(lang)
    if not self.hasFileIO then
        return
    end
    ensureCacheDirectory()
    local entries = self.persistentCache[lang]
    if not entries or next(entries) == nil then
        return
    end

    local payload = {
        version = 1,
        entries = entries,
    }

    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, payload)
    if not ok then
        return
    end

    pcall(FileAPI.write, getCacheFilePath(lang), encoded)
end

local function queueCacheFlush()
    if not LanguageSystem.hasFileIO then
        return
    end
    if LanguageSystem.cacheFlushScheduled then
        return
    end
    LanguageSystem.cacheFlushScheduled = true
    task.defer(function()
        LanguageSystem.cacheFlushScheduled = false
        for lang in pairs(LanguageSystem.cacheDirtyLanguages) do
            LanguageSystem:WriteCacheToFile(lang)
        end
        LanguageSystem.cacheDirtyLanguages = {}
    end)
end

function LanguageSystem:EnsurePersistentCache(lang)
    if not self.hasFileIO then
        ensureLanguageBuckets(lang)
        return
    end

    if self.loadedPersistentLanguages[lang] then
        ensureLanguageBuckets(lang)
        return
    end

    ensureLanguageBuckets(lang)
    ensureCacheDirectory()

    local path = getCacheFilePath(lang)
    local ok, exists = pcall(FileAPI.exists, path)
    if not ok or not exists then
        self.loadedPersistentLanguages[lang] = true
        return
    end

    local readOk, contents = pcall(FileAPI.read, path)
    if not readOk or type(contents) ~= "string" or contents == "" then
        self.loadedPersistentLanguages[lang] = true
        return
    end

    local decodeOk, decoded = pcall(HttpService.JSONDecode, HttpService, contents)
    if decodeOk and type(decoded) == "table" then
        local entries = decoded.entries or decoded
        if type(entries) == "table" then
            for source, translated in pairs(entries) do
                if type(source) == "string" and type(translated) == "string" then
                    self.persistentCache[lang][source] = translated
                    self.translationCache[lang][source] = {
                        translatedText = translated,
                        timestamp = os.time(),
                    }
                end
            end
        end
    end

    self.loadedPersistentLanguages[lang] = true
end

function LanguageSystem:PersistTranslation(lang, sourceText, translatedText)
    if not sourceText or not translatedText then
        return
    end
    ensureLanguageBuckets(lang)
    self.persistentCache[lang][sourceText] = translatedText
    self.cacheDirtyLanguages[lang] = true
    self:TrimPersistentCache(lang)
    queueCacheFlush()
end

local function resolveSourceText(raw, defaultText)
    if type(defaultText) == "string" and defaultText ~= "" then
        return defaultText
    end
    if type(raw) ~= "string" or raw == "" then
        return "INVALID_TEXT"
    end

    -- If the developer already passed natural English (contains spaces or punctuation) use it verbatim.
    if raw:find("%s") or raw:find("[,:!?]") then
        return raw
    end

    -- Otherwise assume key-style identifier (e.g. main.auto_sell)
    if raw:find("%.") or raw:find("_") then
        return prettifyKey(raw)
    end

    return raw
end

local function translateText(url, text, sourceLang, targetLang)
    local payload = {
        q = text,
        source = sourceLang,
        target = targetLang,
        format = "text",
    }

    local body = HttpService:JSONEncode(payload)
    local responseBody = postJson(url, body)
    if not responseBody then
        return nil
    end

    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, responseBody)
    if not ok or not decoded or not decoded.translatedText then
        return nil
    end

    return normalizeUnicode(decoded.translatedText)
end

local function loadSavedLanguage()
    if getgenv and type(getgenv) == "function" then
        local env = getgenv()
        if env and env.ATG_Language and LanguageSystem:IsLanguageSupported(env.ATG_Language) then
            LanguageSystem.currentLanguage = env.ATG_Language
        end
    end
end

-- ============================================================
-- CORE TRANSLATION PIPELINE
-- ============================================================
function LanguageSystem:GetText(rawText, defaultText)
    if type(rawText) ~= "string" and type(defaultText) ~= "string" then
        return "INVALID_TEXT"
    end

    if not self:IsLanguageSupported(self.currentLanguage) then
        self.currentLanguage = self.fallbackLanguage
    end

    ensureLanguageBuckets(self.currentLanguage)
    self:EnsurePersistentCache(self.currentLanguage)

    local sourceText = resolveSourceText(rawText, defaultText)
    sourceText = normalizeUnicode(sourceText)

    if self.currentLanguage == self.fallbackLanguage or not self.autoTranslate then
        return sourceText
    end

    local manual = self.manualTranslations[self.currentLanguage]
    if manual and manual[sourceText] then
        return manual[sourceText]
    end

    local cacheBucket = self.translationCache[self.currentLanguage]
    local cached = cacheBucket and cacheBucket[sourceText]
    if cached and (os.time() - cached.timestamp) < self.cacheExpiry then
        return cached.translatedText
    end

    local translated = translateText(self.libreTranslateURL, sourceText, self.fallbackLanguage, self.currentLanguage)
    local translationSucceeded = translated ~= nil and translated ~= ""
    if not translationSucceeded then
        return sourceText
    end

    cacheBucket[sourceText] = {
        translatedText = translated,
        timestamp = os.time(),
    }

    self:PersistTranslation(self.currentLanguage, sourceText, translated)

    return translated
end

function LanguageSystem:T(rawText, defaultText)
    return self:GetText(rawText, defaultText)
end

LanguageSystem.Get = LanguageSystem.GetText

-- ============================================================
-- LANGUAGE MANAGEMENT
-- ============================================================
function LanguageSystem:SetLanguage(langCode)
    if type(langCode) ~= "string" then
        return false
    end
    langCode = langCode:lower()
    if not self:IsLanguageSupported(langCode) then
        return false
    end
    if langCode == self.currentLanguage then
        return true
    end

    local oldLanguage = self.currentLanguage
    self.currentLanguage = langCode

    ensureLanguageBuckets(langCode)
    self:EnsurePersistentCache(langCode)

    if getgenv and type(getgenv) == "function" then
        local env = getgenv()
        if env then
            env.ATG_Language = langCode
        end
    end

    self:TriggerLanguageChangeCallbacks(oldLanguage, langCode)
    return true
end

function LanguageSystem:OnLanguageChanged(callback)
    if type(callback) ~= "function" then
        return false
    end
    table.insert(self.languageChangeCallbacks, callback)
    return true
end

function LanguageSystem:TriggerLanguageChangeCallbacks(oldLang, newLang)
    for _, callback in ipairs(self.languageChangeCallbacks) do
        pcall(function()
            callback(newLang, oldLang)
        end)
    end
end

function LanguageSystem:RegisterTranslation(langCode, sourceText, translatedText)
    if type(langCode) ~= "string" or type(sourceText) ~= "string" or type(translatedText) ~= "string" then
        return false
    end
    langCode = langCode:lower()
    if not self:IsLanguageSupported(langCode) then
        return false
    end
    ensureLanguageBuckets(langCode)
    self.manualTranslations[langCode][sourceText] = translatedText
    self.translationCache[langCode][sourceText] = {
        translatedText = translatedText,
        timestamp = os.time(),
    }
    self:PersistTranslation(langCode, sourceText, translatedText)
    return true
end

function LanguageSystem:AddLanguage(langCode, data)
    if type(langCode) ~= "string" or type(data) ~= "table" then
        return false
    end
    if type(data.name) ~= "string" or data.name == "" then
        return false
    end
    langCode = langCode:lower()
    data.code = langCode
    self.Languages[langCode] = data
    refreshSupportedLanguages()
    return true
end

function LanguageSystem:SetLibreTranslateURL(url)
    if type(url) ~= "string" or url == "" then
        return false
    end
    self.libreTranslateURL = url
    self:ClearTranslationCache()
    return true
end

function LanguageSystem:SetAutoTranslation(enabled)
    self.autoTranslate = not not enabled
    return true
end

function LanguageSystem:GetCurrentLanguage()
    return self.currentLanguage
end

function LanguageSystem:GetCurrentLanguageName()
    local meta = self.Languages[self.currentLanguage]
    return meta and meta.name or self.currentLanguage
end

function LanguageSystem:GetAvailableLanguages()
    local languages = {}
    for code, data in pairs(self.Languages) do
        table.insert(languages, {
            code = code,
            name = data.name,
            flag = data.flag,
            display = string.format("%s %s", data.flag or "", data.name or code),
        })
    end
    table.sort(languages, function(a, b)
        return a.name < b.name
    end)
    return languages
end

function LanguageSystem:GetAvailableLanguagesWithNames()
    local languages = {}
    for code, data in pairs(self.Languages) do
        table.insert(languages, {
            code = code,
            name = data.name,
            flag = data.flag,
        })
    end
    table.sort(languages, function(a, b)
        return a.name < b.name
    end)
    return languages
end

function LanguageSystem:IsLanguageSupported(langCode)
    if type(langCode) ~= "string" then
        return false
    end
    return self.Languages[langCode:lower()] ~= nil
end

-- ============================================================
-- FORMATTING HELPERS
-- ============================================================
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
    else
        return string.format("%02d/%02d/%d", dateTable.month, dateTable.day, dateTable.year)
    end
end

local function formatNumber(_, number)
    if type(number) ~= "number" then
        return tostring(number)
    end
    local str = string.format("%.2f", number)
    return str:gsub("(%d)(%d%d%d)%.", "%1,%2.")
        :gsub("(%d)(%d%d%d),", "%1,%2,")
end

local function formatTime(_, seconds)
    seconds = math.max(0, seconds or 0)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function LanguageSystem:FormatDate(timestamp)
    return formatDate(self.currentLanguage, timestamp)
end

function LanguageSystem:FormatNumber(number)
    return formatNumber(self.currentLanguage, number)
end

function LanguageSystem:FormatTime(seconds)
    return formatTime(self.currentLanguage, seconds)
end

function LanguageSystem:GetLocalizedDateTime()
    local now = os.time()
    local dateStr = self:FormatDate(now)
    local timeStr = os.date("%H:%M:%S", now)
    return dateStr .. " " .. timeStr
end

function LanguageSystem:ValidateAndNormalizeText(text)
    if not validateUnicode(text) then
        return text
    end
    return normalizeUnicode(text)
end

-- ============================================================
-- CACHE UTILITIES & TESTING
-- ============================================================
function LanguageSystem:ClearTranslationCache(resetPersistent)
    self.translationCache = {}
    for _, code in ipairs(self.supportedLanguages) do
        ensureLanguageBuckets(code)
        self.translationCache[code] = {}
        if resetPersistent then
            self.persistentCache[code] = {}
            self.loadedPersistentLanguages[code] = false
            if self.hasFileIO then
                pcall(FileAPI.write, getCacheFilePath(code), HttpService:JSONEncode({version = 1, entries = {}}))
            end
        else
            for source, translated in pairs(self.persistentCache[code]) do
                self.translationCache[code][source] = {
                    translatedText = translated,
                    timestamp = os.time(),
                }
            end
        end
    end
end

function LanguageSystem:TestAutoTranslation(text, targetLang)
    if type(text) ~= "string" or text == "" or type(targetLang) ~= "string" then
        return "❌ Invalid parameters"
    end
    print("[LanguageSystem] Testing auto-translation...")
    print("Original text: " .. text)
    print("Target language: " .. targetLang)
    local translated = translateText(self.libreTranslateURL, text, self.fallbackLanguage, targetLang)
    translated = translated or text
    print("Translated result: " .. translated)
    return translated
end

function LanguageSystem:Initialize()
    refreshSupportedLanguages()
    ensureCacheDirectory()
    loadSavedLanguage()
    ensureLanguageBuckets(self.currentLanguage)
    self:EnsurePersistentCache(self.currentLanguage)
    return self
end

-- ============================================================
-- GLOBAL SINGLETON
-- ============================================================
local instance = setmetatable({}, LanguageSystem)
instance:Initialize()

if getgenv and type(getgenv) == "function" then
    local env = getgenv()
    if env then
        env.ATG_Lang = instance
    end
end
_G.ATG_Lang = instance

return instance
