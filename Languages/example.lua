--[[
    ================================================
    ATG Hub Multi-Language System - Usage Examples
    ================================================

    This file demonstrates how to use the language system
    in your ATG Hub scripts.

    Version: 1.0.0
    Author: ATG Team
]]

-- ========================================
-- 1. BASIC SETUP - Load the Language System
-- ========================================

-- Load the language system (ใช้วิธีใดวิธีหนึ่ง)
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/init.lua"))()

-- หรือถ้าเป็น local file
-- local Lang = require(script.Parent.Languages.init)


-- ========================================
-- 2. BASIC USAGE - Get Translated Text
-- ========================================

-- ดึงข้อความแบบพื้นฐาน
local windowTitle = Lang:Get("window_title")
print(windowTitle)  -- Output: "ATG HUB Premium" (EN) or "ATG HUB พรีเมียม" (TH)

-- ใช้ shortcut function T() (ทำงานเหมือน Get())
local subtitle = Lang:T("window_subtitle")
print(subtitle)


-- ========================================
-- 3. USING WITH FLUENT UI
-- ========================================

-- สร้าง Window ด้วยภาษา
local Window = Fluent:CreateWindow({
    Title = Lang:Get("window_title"),
    SubTitle = Lang:Get("window_subtitle"),
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
})

-- สร้าง Tabs ด้วยภาษา
local Tabs = {
    Main = Window:AddTab({
        Title = Lang:Get("tab_main"),
        Icon = "repeat"
    }),

    Settings = Window:AddTab({
        Title = Lang:Get("tab_settings"),
        Icon = "settings"
    }),

    Players = Window:AddTab({
        Title = Lang:Get("tab_players"),
        Icon = "users"
    })
}

-- สร้าง Toggle ด้วยภาษา
local AutoFeedToggle = Tabs.Main:AddToggle("AutoFeed", {
    Title = Lang:Get("auto_feed"),
    Description = Lang:Get("auto_feed_desc"),
    Default = false
})

AutoFeedToggle:OnChanged(function(value)
    print(Lang:Get("auto_feed") .. ": " .. tostring(value))
end)

-- สร้าง Button ด้วยภาษา
local PickUpButton = Tabs.Main:AddButton({
    Title = Lang:Get("pickup_all"),
    Description = Lang:Get("pickup_all_desc"),
    Callback = function()
        print("Picking up all animals...")
    end
})


-- ========================================
-- 4. VARIABLE REPLACEMENT
-- ========================================

-- ใช้ตัวแปรในข้อความ (ถ้าข้อความมี {variable})
local playerCount = 10
local text = Lang:Get("amount", {amount = playerCount})
print(text)  -- Output: "Amount: 10" (EN) or "จำนวน: 10" (TH)

-- ตัวอย่างหลายตัวแปร
local versionText = Lang:Get("version", {version = "1.5.0"})
print(versionText)  -- Output: "Version 1.5.0" (EN) or "เวอร์ชัน 1.5.0" (TH)


-- ========================================
-- 5. LANGUAGE SWITCHING
-- ========================================

-- เปลี่ยนภาษา
print("Current Language: " .. Lang:GetCurrentLanguage())  -- "EN"

Lang:SetLanguage("TH")  -- เปลี่ยนเป็นภาษาไทย
print("New Language: " .. Lang:GetCurrentLanguage())  -- "TH"

-- ตรวจสอบว่ามีภาษานี้หรือไม่
if Lang:IsLanguageAvailable("JP") then
    Lang:SetLanguage("JP")
    print("Switched to Japanese")
end

-- Auto-detect ภาษาจาก Player Locale
local detectedLang = Lang:AutoDetectLanguage()
print("Detected Language: " .. detectedLang)
Lang:SetLanguage(detectedLang)


-- ========================================
-- 6. LANGUAGE SELECTOR IN UI
-- ========================================

-- สร้าง Dropdown สำหรับเลือกภาษา
local LanguageDropdown = Tabs.Settings:AddDropdown("LanguageSelector", {
    Title = "Language / ภาษา",
    Values = {"EN", "TH", "JP", "CN"},
    Default = Lang:GetCurrentLanguage(),
    Multi = false,
    Callback = function(selectedLang)
        Lang:SetLanguage(selectedLang)

        -- แจ้งเตือนผู้ใช้
        Fluent:Notify({
            Title = Lang:Get("language_changed"),
            Content = Lang:Get("language_changed_desc"),
            Duration = 3
        })

        -- รีโหลด UI (optional)
        task.wait(1)
        if getgenv().ATG_ReloadUI then
            getgenv().ATG_ReloadUI()
        end
    end
})

-- แสดงรายชื่อภาษาทั้งหมดพร้อมชื่อ
local langList = Lang:GetAvailableLanguagesWithNames()
for _, lang in ipairs(langList) do
    print(lang.code .. " - " .. lang.name)
end
-- Output:
-- EN - English
-- TH - ไทย (Thai)
-- JP - 日本語 (Japanese)
-- CN - 简体中文 (Chinese)


-- ========================================
-- 7. HELPER FUNCTIONS (Optional)
-- ========================================

-- สร้าง Helper เพื่อใช้งานง่ายขึ้น
local UIHelper = {}

function UIHelper:CreateToggle(tab, id, titleKey, descKey, default)
    return tab:AddToggle(id, {
        Title = Lang:Get(titleKey),
        Description = Lang:Get(descKey),
        Default = default or false
    })
end

function UIHelper:CreateButton(tab, titleKey, descKey, callback)
    return tab:AddButton({
        Title = Lang:Get(titleKey),
        Description = Lang:Get(descKey),
        Callback = callback
    })
end

function UIHelper:Notify(titleKey, contentKey, duration)
    Fluent:Notify({
        Title = Lang:Get(titleKey),
        Content = Lang:Get(contentKey),
        Duration = duration or 5
    })
end

-- ใช้งาน Helper
local AutoSellToggle = UIHelper:CreateToggle(
    Tabs.Main,
    "AutoSell",
    "auto_sell",
    "auto_sell_desc",
    false
)

UIHelper:Notify("notification_success", "auto_feed_desc", 3)


-- ========================================
-- 8. ADVANCED: ADD CUSTOM TRANSLATIONS
-- ========================================

-- เพิ่มภาษาใหม่แบบ manual (ไม่ต้องมีไฟล์แยก)
local customKoreanLang = {
    window_title = "ATG HUB 프리미엄",
    window_subtitle = "[ 동물 키우기 ]",
    tab_main = "메인",
    tab_settings = "설정",
    auto_feed = "자동 먹이주기",
    -- ... เพิ่ม key อื่นๆ
}

Lang:LoadLanguage("KR", customKoreanLang)
Lang:SetLanguage("KR")


-- ========================================
-- 9. DEBUGGING
-- ========================================

-- ดู raw translation table (สำหรับ debug)
local allTranslations = Lang:GetRawTranslations()
for langCode, translations in pairs(allTranslations) do
    print("Language: " .. langCode)
    print("Keys count: " .. #translations)
end

-- ตรวจสอบ missing keys
local testKey = "some_key_that_might_not_exist"
local result = Lang:Get(testKey)
if result == testKey then
    warn("Translation key not found: " .. testKey)
end


-- ========================================
-- 10. COMPLETE EXAMPLE - FULL SCRIPT
-- ========================================

--[[
    ตัวอย่างสคริปต์ที่สมบูรณ์

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHUBUI/main/MainUI.lua"))()
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/init.lua"))()

-- Auto-detect language
local detectedLang = Lang:AutoDetectLanguage()
Lang:SetLanguage(detectedLang)

-- Create Window
local Window = Fluent:CreateWindow({
    Title = Lang:Get("window_title"),
    SubTitle = Lang:Get("window_subtitle"),
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
})

-- Create Tabs
local Tabs = {
    Main = Window:AddTab({Title = Lang:Get("tab_main"), Icon = "repeat"}),
    Settings = Window:AddTab({Title = Lang:Get("tab_settings"), Icon = "settings"}),
}

-- Language Selector
Tabs.Settings:AddDropdown("LangSelect", {
    Title = "Language / ภาษา",
    Values = {"EN", "TH", "JP", "CN"},
    Default = Lang:GetCurrentLanguage(),
    Callback = function(value)
        Lang:SetLanguage(value)
        Fluent:Notify({
            Title = Lang:Get("language_changed"),
            Content = Lang:Get("language_changed_desc"),
            Duration = 3
        })
    end
})

-- Add Features
Tabs.Main:AddToggle("AutoFeed", {
    Title = Lang:Get("auto_feed"),
    Description = Lang:Get("auto_feed_desc"),
    Default = false
}):OnChanged(function(value)
    print(Lang:Get("auto_feed") .. ": " .. tostring(value))
end)

print("ATG Hub Multi-Language System loaded successfully!")
print("Current Language: " .. Lang:GetCurrentLanguageName())
]]

-- ========================================
-- END OF EXAMPLES
-- ========================================

print([[
========================================
ATG Hub Language System Examples Loaded!
========================================

Available Functions:
- Lang:Get(key, replacements)      - Get translated text
- Lang:T(key, replacements)        - Shortcut for Get()
- Lang:SetLanguage(code)           - Change language
- Lang:GetCurrentLanguage()        - Get current language code
- Lang:GetCurrentLanguageName()    - Get current language name
- Lang:AutoDetectLanguage()        - Auto-detect from player locale
- Lang:IsLanguageAvailable(code)   - Check if language exists
- Lang:GetAvailableLanguages()     - Get all language codes
- Lang:LoadLanguage(code, table)   - Add custom language

Supported Languages: EN, TH, JP, CN
]])
