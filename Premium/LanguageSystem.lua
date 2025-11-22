--[[
================================================================
ATG HUB - Premium Language System
----------------------------------------------------------------
* Deterministic English fallbacks for key-style identifiers (e.g. "main.auto_sell" → "Auto Sell").
* Optional manual overrides and auto-translation via LibreTranslate.
* Central callback bus for LanguageIntegration.lua and any Fluent UI elements.
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
LanguageSystem.baseTextOverrides = {
    -- Tabs / Sections
    ["tabs.main"] = "Main",
    ["tabs.farm"] = "Farm",
    ["tabs.egg"] = "Egg",
    ["tabs.event"] = "Event",
    ["tabs.autoplay"] = "Auto Play",
    ["tabs.screen"] = "Screen",
    ["tabs.humanoid"] = "Humanoid",
    ["tabs.players"] = "Players",
    ["tabs.server"] = "Server",
    ["tabs.settings"] = "Settings",

    -- Settings / Common
    ["settings.title"] = "Settings",
    ["settings.language"] = "Language",
    ["settings.select_language"] = "Select language",
    ["common.loading"] = "Loading...",
    ["common.loading_player_info"] = "Loading player information...",
    ["common.select_items"] = "Select items",
    ["common.multi_select"] = "Multi-select",
    ["common.auto_buy_desc"] = "Automatically purchase the selected items",
    ["common.success"] = "Success",

    -- Main panel text
    ["main.player_info"] = "Player information",
    ["main.name"] = "Name",
    ["main.date"] = "Date",
    ["main.played_time"] = "Played time",
    ["main.auto_buy_food"] = "Auto buy food",
    ["main.auto_buy_animals"] = "Auto buy animals",
    ["main.auto_feed"] = "Auto feed",
    ["main.auto_feed_animals"] = "Auto feed animals",
    ["main.auto_sell"] = "Auto sell",
    ["main.select_animals_feed"] = "Select animals to feed",
    ["main.feed_all_desc"] = "Feed all selected animals automatically",
    ["main.feed_animals_desc"] = "Continuously feeds every selected animal",
    ["main.select_animals_sell"] = "Select animals to sell",
    ["main.select_animals_sell_desc"] = "Choose animals that will be sold automatically",
    ["main.auto_buy_food_desc"] = "Purchase food items on a loop",

    -- Descriptions used across demos / integrations
    ["descriptions.test_notification_desc"] = "Show a multi-language notification",
    ["descriptions.confirmation_dialog_desc"] = "Display a confirmation dialog",
    ["descriptions.speed_boost_desc"] = "Toggle a faster walk speed",
    ["descriptions.jump_power_desc"] = "Adjust jump power",
    ["descriptions.player_name_desc"] = "Enter a display name",
    ["descriptions.auto_farm_desc"] = "Automatically farm enemies",
    ["descriptions.select_weapon_desc"] = "Pick the weapon to use",
    ["descriptions.special_abilities_desc"] = "Select special abilities",
    ["descriptions.attack_button_desc"] = "Keybind used to attack",

    -- Notifications & dynamic strings
    ["notifications.welcome"] = "Welcome to ATG Hub",
    ["notifications.script_loaded"] = "Script loaded successfully",
    ["notifications.press_left_ctrl"] = "Press Left Control to toggle the UI",
    ["notifications.success"] = "Success",
    ["notifications.button_pressed"] = "Button pressed",
    ["notifications.confirm_action"] = "Confirm action",
    ["notifications.want_to_continue"] = "Do you want to continue?",
    ["notifications.confirm"] = "Confirm",
    ["notifications.confirmed"] = "Confirmed",
    ["notifications.action_completed"] = "Action completed",
    ["notifications.cancel"] = "Cancel",
    ["notifications.enabled"] = "Enabled",
    ["notifications.disabled"] = "Disabled",
    ["notifications.speed_set_50"] = "Speed set to 50",
    ["notifications.speed_reset"] = "Speed reset to default",
    ["notifications.saved"] = "Saved",
    ["notifications.your_name_is"] = "Your name is: ",
    ["notifications.weapon_switched"] = "Weapon switched",
    ["notifications.using_weapon"] = "Using weapon: ",
    ["notifications.skill_used"] = "Skill used",
    ["notifications.attack"] = "Attack",
    ["notifications.loading"] = "Loading...",
    ["notifications.feature_enabled"] = "Feature enabled",
    ["notifications.feature_disabled"] = "Feature disabled",
    ["notifications.please_wait"] = "Please wait...",
    ["notifications.auto_sell_warn"] = "Auto-sell warning",
    ["notifications.select_animal_sell"] = "Select at least one animal before selling",
    ["notifications.tycoon_folder_not_found"] = "Tycoon folder not found",
    ["notifications.pickup_count"] = "Picked up %d animals!",

    -- Screen utilities
    ["screen.remove_gui"] = "Remove GUI",
    ["screen.remove_gui_desc"] = "Remove every GUI from the screen",
    ["screen.remove_notify"] = "Block notifications",
    ["screen.remove_notify_desc"] = "Hide in-game notifications",

    -- Server management
    ["server.job_id"] = "Job ID",
    ["server.input_job_id_title"] = "Input Job ID",
    ["server.paste_job_id_here"] = "Paste job ID here",
    ["server.teleport_to_job_title"] = "Teleport to job",
    ["server.teleport_to_job_desc"] = "Teleport to the server with the provided Job ID",
    ["server.copy_current_job_id_title"] = "Copy current Job ID",
    ["server.copy_current_job_id_desc"] = "Copy the current server Job ID",

    -- Farm helpers
    ["farm.animal_management"] = "Animal management",
    ["farm.pickup_all_animals"] = "Pick up all animals",
    ["farm.pickup_all_animals_desc"] = "Collect every animal back into storage",
    ["farm.auto_place_animals"] = "Auto place animals",
    ["farm.select_animals_place_title"] = "Select animals to place",
    ["farm.select_animals_place_description"] = "Choose animals that should be placed automatically",
    ["farm.auto_pickup_animals"] = "Auto pick up animals",
    ["farm.select_animals_pickup_title"] = "Select animals to pick up",
    ["farm.select_animals_pickup_description"] = "Choose animals that will be collected automatically",

    -- Egg / events / autoplay
    ["egg.dino_exchange"] = "Dino exchange",
    ["event.desert_event"] = "Desert event",
    ["autoplay.play"] = "Play",
    ["autoplay.auto_play"] = "Auto play",
    ["autoplay.swap_animal"] = "Swap animal",
    ["autoplay.config"] = "Config",
    ["autoplay.advanced"] = "Advanced",

    -- Players / humanoid helpers
    ["players.player"] = "Player",
    ["players.teleport"] = "Teleport",
    ["players.method"] = "Teleport method",
    ["players.instant"] = "Instant",
    ["players.tween"] = "Tween",
    ["players.moveto"] = "Move to",
    ["players.player_info"] = "Player info",
    ["players.player_name"] = "Player name",
    ["players.movement"] = "Movement",
    ["players.speed_boost"] = "Speed boost",
    ["players.jump_power"] = "Jump power",
    ["humanoid.speed_jump"] = "Speed & jump",
    ["humanoid.fly_noclip"] = "Fly & noclip",
}

LanguageSystem.manualTranslations = {}
LanguageSystem.derivedTextCache = {}
LanguageSystem.wordOverrides = {
    ui = "UI",
    id = "ID",
    xp = "XP",
    hp = "HP",
    fps = "FPS",
    afk = "AFK",
    pvp = "PvP",
    pve = "PvE",
}

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
-- HELPER FUNCTIONS
-- ============================================================
local function refreshSupportedLanguages()
    LanguageSystem.supportedLanguages = {}
    for code in pairs(LanguageSystem.Languages) do
        table.insert(LanguageSystem.supportedLanguages, code)
    end
    table.sort(LanguageSystem.supportedLanguages)
end

local function ensureLanguageBuckets(langCode)
    LanguageSystem.translationCache[langCode] = LanguageSystem.translationCache[langCode] or {}
    LanguageSystem.manualTranslations[langCode] = LanguageSystem.manualTranslations[langCode] or {}
end

local function initTranslationCache()
    for _, code in ipairs(LanguageSystem.supportedLanguages) do
        ensureLanguageBuckets(code)
    end
end

refreshSupportedLanguages()
initTranslationCache()

-- HttpService shim
local HttpService = nil
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

-- Unicode helpers
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
    local chunks = {}
    for token in segment:gmatch("[^_%-]+") do
        local lower = token:lower()
        local override = LanguageSystem.wordOverrides[lower]
        if override then
            table.insert(chunks, override)
        elseif #token <= 2 then
            table.insert(chunks, lower:upper())
        else
            table.insert(chunks, lower:sub(1, 1):upper() .. lower:sub(2))
        end
    end
    return table.concat(chunks, " ")
end

local function resolveBaseText(keyPath, defaultText)
    if type(keyPath) ~= "string" or keyPath == "" then
        return "INVALID_KEY"
    end

    if type(defaultText) == "string" and defaultText ~= "" then
        LanguageSystem.baseTextOverrides[keyPath] = defaultText
        LanguageSystem.derivedTextCache[keyPath] = defaultText
        return defaultText
    end

    if LanguageSystem.baseTextOverrides[keyPath] then
        return LanguageSystem.baseTextOverrides[keyPath]
    end

    if LanguageSystem.derivedTextCache[keyPath] then
        return LanguageSystem.derivedTextCache[keyPath]
    end

    local segment = keyPath:match("([%w_%-]+)$") or keyPath
    local friendly = toTitleCase(segment)
    if friendly == "" then
        friendly = keyPath
    end

    LanguageSystem.derivedTextCache[keyPath] = friendly
    return friendly
end

local function translateText(url, text, sourceLang, targetLang)
    if not HttpService or not HttpService.RequestAsync then
        return text
    end

    local payload = {
        q = text,
        source = sourceLang,
        target = targetLang,
    }

    local jsonBody = HttpService:JSONEncode(payload)
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
            },
            Body = jsonBody,
        })
    end)

    if not success or not response or not response.Success then
        return nil
    end

    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, response.Body)
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
-- CORE API
-- ============================================================
function LanguageSystem:GetText(keyPath, defaultText)
    if type(keyPath) ~= "string" or keyPath == "" then
        return "INVALID_KEY"
    end

    if not self:IsLanguageSupported(self.currentLanguage) then
        self.currentLanguage = self.fallbackLanguage
    end

    local baseText = resolveBaseText(keyPath, defaultText)
    baseText = normalizeUnicode(baseText)

    if self.currentLanguage == self.fallbackLanguage then
        return baseText
    end

    local manual = self.manualTranslations[self.currentLanguage]
    if manual and manual[keyPath] then
        return manual[keyPath]
    end

    local cacheBucket = self.translationCache[self.currentLanguage]
    if cacheBucket then
        local cached = cacheBucket[keyPath]
        if cached and (os.time() - cached.timestamp) < self.cacheExpiry then
            return cached.translatedText
        end
    end

    if not self.autoTranslate then
        return baseText
    end

    local translated = translateText(self.libreTranslateURL, baseText, self.fallbackLanguage, self.currentLanguage)
    if not translated or translated == "" then
        translated = baseText
    end

    if cacheBucket then
        cacheBucket[keyPath] = {
            translatedText = translated,
            timestamp = os.time(),
        }
    end

    return translated
end

function LanguageSystem:T(keyPath, defaultText)
    return self:GetText(keyPath, defaultText)
end

LanguageSystem.Get = LanguageSystem.GetText

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

function LanguageSystem:RegisterKey(keyPath, englishText)
    if type(keyPath) ~= "string" or type(englishText) ~= "string" then
        return false
    end
    self.baseTextOverrides[keyPath] = englishText
    self.derivedTextCache[keyPath] = englishText
    return true
end

function LanguageSystem:RegisterTranslation(langCode, keyPath, translatedText)
    if type(langCode) ~= "string" or type(keyPath) ~= "string" or type(translatedText) ~= "string" then
        return false
    end
    langCode = langCode:lower()
    ensureLanguageBuckets(langCode)
    self.manualTranslations[langCode][keyPath] = translatedText
    if self.translationCache[langCode] then
        self.translationCache[langCode][keyPath] = nil
    end
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
    ensureLanguageBuckets(langCode)
    return true
end

function LanguageSystem:SetLibreTranslateURL(url)
    if type(url) ~= "string" or url == "" then
        return false
    end
    self.libreTranslateURL = url
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
    langCode = langCode:lower()
    return self.Languages[langCode] ~= nil
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
function LanguageSystem:ClearTranslationCache()
    self.translationCache = {}
    initTranslationCache()
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
    initTranslationCache()
    loadSavedLanguage()
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
