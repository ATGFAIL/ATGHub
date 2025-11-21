--[[
    ATG Hub Multi-Language System
    ระบบจัดการหลายภาษาสำหรับ ATG Hub

    Author: ATG Team
    Version: 1.0.0

    Supported Languages:
    - EN (English)
    - TH (Thai)
    - JP (Japanese)
    - CN (Chinese Simplified)
    - KR (Korean)
]]

local LanguageSystem = {}
LanguageSystem.__index = LanguageSystem

-- Default language
local CurrentLanguage = "EN"
local Translations = {}

-- โหลดไฟล์ภาษาทั้งหมด
local function loadLanguageFile(langCode)
    local success, result = pcall(function()
        local url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/" .. langCode:lower() .. ".lua"
        return loadstring(game:HttpGet(url))()
    end)

    if success then
        return result
    else
        warn("[ATG Language] Failed to load language file: " .. langCode)
        return nil
    end
end

-- Initialize language system
function LanguageSystem:Init()
    print("[ATG Language] Initializing Multi-Language System...")

    -- โหลดภาษาเริ่มต้น (English)
    local enLang = loadLanguageFile("en")
    if enLang then
        Translations["EN"] = enLang
        print("[ATG Language] Loaded English language")
    end

    -- โหลดภาษาไทย
    local thLang = loadLanguageFile("th")
    if thLang then
        Translations["TH"] = thLang
        print("[ATG Language] Loaded Thai language")
    end

    -- โหลดภาษาญี่ปุ่น
    local jpLang = loadLanguageFile("jp")
    if jpLang then
        Translations["JP"] = jpLang
        print("[ATG Language] Loaded Japanese language")
    end

    -- โหลดภาษาจีน
    local cnLang = loadLanguageFile("cn")
    if cnLang then
        Translations["CN"] = cnLang
        print("[ATG Language] Loaded Chinese language")
    end

    print("[ATG Language] System initialized successfully!")
end

-- ดึงข้อความตาม key
function LanguageSystem:Get(key, replacements)
    local translation = Translations[CurrentLanguage]

    -- ถ้าหาภาษาปัจจุบันไม่เจอ ใช้ภาษาอังกฤษแทน
    if not translation then
        translation = Translations["EN"]
    end

    -- ถ้ายังหาไม่เจอ return key เลย
    if not translation or not translation[key] then
        warn("[ATG Language] Translation key not found: " .. tostring(key))
        return key
    end

    local text = translation[key]

    -- แทนที่ค่าตัวแปรถ้ามี (เช่น {player}, {count})
    if replacements and type(replacements) == "table" then
        for k, v in pairs(replacements) do
            text = text:gsub("{" .. k .. "}", tostring(v))
        end
    end

    return text
end

-- เปลี่ยนภาษา
function LanguageSystem:SetLanguage(langCode)
    langCode = langCode:upper()

    if Translations[langCode] then
        CurrentLanguage = langCode
        print("[ATG Language] Language changed to: " .. langCode)
        return true
    else
        warn("[ATG Language] Language not available: " .. langCode)
        return false
    end
end

-- ดึงภาษาปัจจุบัน
function LanguageSystem:GetCurrentLanguage()
    return CurrentLanguage
end

-- ดึงชื่อภาษาปัจจุบันแบบเต็ม
function LanguageSystem:GetCurrentLanguageName()
    local names = {
        EN = "English",
        TH = "ไทย",
        JP = "日本語",
        CN = "简体中文",
        KR = "한국어"
    }
    return names[CurrentLanguage] or CurrentLanguage
end

-- ดึงรายการภาษาที่มี
function LanguageSystem:GetAvailableLanguages()
    local langs = {}
    for lang, _ in pairs(Translations) do
        table.insert(langs, lang)
    end
    table.sort(langs)
    return langs
end

-- ดึงรายการภาษาแบบมีชื่อเต็ม
function LanguageSystem:GetAvailableLanguagesWithNames()
    local langs = {}
    local names = {
        EN = "English",
        TH = "ไทย (Thai)",
        JP = "日本語 (Japanese)",
        CN = "简体中文 (Chinese)",
        KR = "한국어 (Korean)"
    }

    for lang, _ in pairs(Translations) do
        table.insert(langs, {
            code = lang,
            name = names[lang] or lang
        })
    end

    table.sort(langs, function(a, b) return a.code < b.code end)
    return langs
end

-- ตรวจสอบว่ามีภาษานี้หรือไม่
function LanguageSystem:IsLanguageAvailable(langCode)
    return Translations[langCode:upper()] ~= nil
end

-- โหลดภาษาเพิ่มเติมแบบ manual
function LanguageSystem:LoadLanguage(langCode, translationTable)
    langCode = langCode:upper()
    Translations[langCode] = translationTable
    print("[ATG Language] Manually loaded language: " .. langCode)
end

-- ดึง raw translation table (สำหรับ debug)
function LanguageSystem:GetRawTranslations()
    return Translations
end

-- Auto-detect language จาก locale (ถ้าเป็นไปได้)
function LanguageSystem:AutoDetectLanguage()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    if LocalPlayer then
        local locale = LocalPlayer.LocaleId or ""

        -- แปลง locale เป็น language code
        if locale:find("th") then
            return "TH"
        elseif locale:find("ja") then
            return "JP"
        elseif locale:find("zh") then
            return "CN"
        elseif locale:find("ko") then
            return "KR"
        else
            return "EN"
        end
    end

    return "EN"
end

-- Shortcut function สำหรับใช้งานง่ายๆ
function LanguageSystem:T(key, replacements)
    return self:Get(key, replacements)
end

-- สร้าง instance
local Lang = setmetatable({}, LanguageSystem)

-- Auto-initialize เมื่อ require
Lang:Init()

-- Export
return Lang
