# ATG Hub Multi-Language System 🌍

ระบบจัดการหลายภาษาสำหรับ ATG Hub ที่รองรับการแปลภาษา UI แบบครบวงจร

## 📋 Table of Contents
- [Features](#-features)
- [Supported Languages](#-supported-languages)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Usage Examples](#-usage-examples)
- [API Reference](#-api-reference)
- [File Structure](#-file-structure)
- [Adding New Languages](#-adding-new-languages)
- [Best Practices](#-best-practices)

---

## ✨ Features

- **4+ ภาษาที่รองรับ**: อังกฤษ, ไทย, ญี่ปุ่น, จีน
- **Auto-Detection**: ตรวจจับภาษาจาก Player Locale อัตโนมัติ
- **Fallback System**: ใช้ภาษาอังกฤษเมื่อไม่พบคำแปล
- **Variable Replacement**: รองรับการแทนที่ตัวแปรในข้อความ
- **Easy Integration**: ใช้งานง่ายกับ Fluent UI
- **Lightweight**: ไฟล์เล็ก โหลดเร็ว
- **Extensible**: เพิ่มภาษาใหม่ได้ง่าย

---

## 🌐 Supported Languages

| Code | Language | Status |
|------|----------|--------|
| EN | English | ✅ Complete |
| TH | ไทย (Thai) | ✅ Complete |
| JP | 日本語 (Japanese) | ✅ Complete |
| CN | 简体中文 (Chinese) | ✅ Complete |
| KR | 한국어 (Korean) | 🚧 Planned |

---

## 📦 Installation

### Method 1: Direct Load (Recommended)
```lua
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/Languages/init.lua"))()
```

### Method 2: Local Require
```lua
local Lang = require(script.Parent.Languages.init)
```

---

## 🚀 Quick Start

### Basic Setup
```lua
-- Load the language system
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/Languages/init.lua"))()

-- Get translated text
print(Lang:Get("window_title"))  -- "ATG HUB Premium"

-- Change language
Lang:SetLanguage("TH")
print(Lang:Get("window_title"))  -- "ATG HUB พรีเมียม"
```

### With Fluent UI
```lua
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHUBUI/main/MainUI.lua"))()
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/Languages/init.lua"))()

-- Create window with translation
local Window = Fluent:CreateWindow({
    Title = Lang:Get("window_title"),
    SubTitle = Lang:Get("window_subtitle"),
    Size = UDim2.fromOffset(580, 460),
})

-- Create tabs with translation
local Tabs = {
    Main = Window:AddTab({
        Title = Lang:Get("tab_main"),
        Icon = "repeat"
    }),
    Settings = Window:AddTab({
        Title = Lang:Get("tab_settings"),
        Icon = "settings"
    })
}
```

---

## 📖 Usage Examples

### 1. Basic Translation
```lua
-- Get a single translation
local title = Lang:Get("auto_feed")

-- Using shortcut
local subtitle = Lang:T("auto_feed_desc")
```

### 2. Variable Replacement
```lua
-- Translation with variables
local text = Lang:Get("amount", {amount = 100})
-- Output: "Amount: 100" (EN) or "จำนวน: 100" (TH)

local version = Lang:Get("version", {version = "1.5.0"})
-- Output: "Version 1.5.0" (EN) or "เวอร์ชัน 1.5.0" (TH)
```

### 3. Language Switching
```lua
-- Get current language
print(Lang:GetCurrentLanguage())  -- "EN"
print(Lang:GetCurrentLanguageName())  -- "English"

-- Change language
Lang:SetLanguage("TH")

-- Auto-detect from player locale
local detectedLang = Lang:AutoDetectLanguage()
Lang:SetLanguage(detectedLang)
```

### 4. Language Selector UI
```lua
local LanguageDropdown = Tabs.Settings:AddDropdown("LangSelect", {
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
```

### 5. Creating UI Elements
```lua
-- Toggle with translation
local AutoFeedToggle = Tabs.Main:AddToggle("AutoFeed", {
    Title = Lang:Get("auto_feed"),
    Description = Lang:Get("auto_feed_desc"),
    Default = false
})

-- Button with translation
local PickUpButton = Tabs.Main:AddButton({
    Title = Lang:Get("pickup_all"),
    Description = Lang:Get("pickup_all_desc"),
    Callback = function()
        print("Picking up...")
    end
})
```

---

## 📚 API Reference

### Core Functions

#### `Lang:Get(key, replacements)`
ดึงข้อความแปลภาษา

**Parameters:**
- `key` (string): Translation key
- `replacements` (table, optional): Variables to replace in text

**Returns:** string

```lua
local text = Lang:Get("auto_feed")
local amount = Lang:Get("amount", {amount = 50})
```

---

#### `Lang:T(key, replacements)`
Shortcut สำหรับ `Get()`

```lua
local text = Lang:T("window_title")
```

---

#### `Lang:SetLanguage(langCode)`
เปลี่ยนภาษา

**Parameters:**
- `langCode` (string): Language code (EN, TH, JP, CN)

**Returns:** boolean (success)

```lua
Lang:SetLanguage("TH")  -- true
Lang:SetLanguage("XX")  -- false (language not found)
```

---

#### `Lang:GetCurrentLanguage()`
ดึงรหัสภาษาปัจจุบัน

**Returns:** string

```lua
print(Lang:GetCurrentLanguage())  -- "EN"
```

---

#### `Lang:GetCurrentLanguageName()`
ดึงชื่อภาษาปัจจุบัน

**Returns:** string

```lua
print(Lang:GetCurrentLanguageName())  -- "English" or "ไทย"
```

---

#### `Lang:AutoDetectLanguage()`
ตรวจจับภาษาจาก Player LocaleId

**Returns:** string (language code)

```lua
local detectedLang = Lang:AutoDetectLanguage()
Lang:SetLanguage(detectedLang)
```

---

#### `Lang:IsLanguageAvailable(langCode)`
ตรวจสอบว่ามีภาษานี้หรือไม่

**Parameters:**
- `langCode` (string): Language code to check

**Returns:** boolean

```lua
if Lang:IsLanguageAvailable("JP") then
    Lang:SetLanguage("JP")
end
```

---

#### `Lang:GetAvailableLanguages()`
ดึงรายการภาษาที่มีทั้งหมด

**Returns:** table (array of language codes)

```lua
local langs = Lang:GetAvailableLanguages()
-- Output: {"EN", "TH", "JP", "CN"}
```

---

#### `Lang:GetAvailableLanguagesWithNames()`
ดึงรายการภาษาพร้อมชื่อเต็ม

**Returns:** table (array of {code, name})

```lua
local langs = Lang:GetAvailableLanguagesWithNames()
for _, lang in ipairs(langs) do
    print(lang.code .. " - " .. lang.name)
end
-- Output:
-- EN - English
-- TH - ไทย (Thai)
-- JP - 日本語 (Japanese)
-- CN - 简体中文 (Chinese)
```

---

#### `Lang:LoadLanguage(langCode, translationTable)`
โหลดภาษาใหม่แบบ manual

**Parameters:**
- `langCode` (string): Language code
- `translationTable` (table): Translation key-value pairs

```lua
local customLang = {
    window_title = "ATG HUB 프리미엄",
    tab_main = "메인",
    -- ... more translations
}
Lang:LoadLanguage("KR", customLang)
```

---

## 📁 File Structure

```
ATGHub/
├── Languages/
│   ├── init.lua          # Main language system
│   ├── en.lua            # English translations
│   ├── th.lua            # Thai translations
│   ├── jp.lua            # Japanese translations
│   ├── cn.lua            # Chinese translations
│   ├── example.lua       # Usage examples
│   └── README.md         # Documentation
├── Premium/
│   └── Raise-Animals-Premium.lua
└── ...
```

---

## 🔧 Adding New Languages

### Step 1: Create Language File

สร้างไฟล์ใหม่ เช่น `kr.lua` (Korean):

```lua
--[[
    Korean Language Pack for ATG Hub
    Language Code: KR
    Version: 1.0.0
]]

return {
    window_title = "ATG HUB 프리미엄",
    window_subtitle = "[ 동물 키우기 ]",

    tab_main = "메인",
    tab_settings = "설정",

    auto_feed = "자동 먹이주기",
    auto_feed_desc = "동물에게 자동으로 먹이를 줍니다",

    -- ... เพิ่ม keys อื่นๆ
}
```

### Step 2: Update init.lua

เพิ่มการโหลดภาษาใหม่ใน `init.lua`:

```lua
-- โหลดภาษาเกาหลี
local krLang = loadLanguageFile("kr")
if krLang then
    Translations["KR"] = krLang
    print("[ATG Language] Loaded Korean language")
end
```

### Step 3: Update Language Names

เพิ่มชื่อภาษาใน function `GetCurrentLanguageName()`:

```lua
function LanguageSystem:GetCurrentLanguageName()
    local names = {
        EN = "English",
        TH = "ไทย",
        JP = "日本語",
        CN = "简体中文",
        KR = "한국어"  -- เพิ่มบรรทัดนี้
    }
    return names[CurrentLanguage] or CurrentLanguage
end
```

---

## 💡 Best Practices

### 1. Use Translation Keys Consistently
```lua
-- ✅ Good - consistent naming
Lang:Get("auto_feed")
Lang:Get("auto_feed_desc")

-- ❌ Bad - inconsistent
Lang:Get("autoFeed")
Lang:Get("auto_feed_description")
```

### 2. Always Provide Fallback
```lua
-- System automatically falls back to English if key not found
local text = Lang:Get("unknown_key")
-- Returns "unknown_key" and shows warning
```

### 3. Use Variable Replacement for Dynamic Content
```lua
-- ✅ Good - flexible
Lang:Get("amount", {amount = playerCount})

-- ❌ Bad - hardcoded
"Amount: " .. tostring(playerCount)
```

### 4. Group Related Translations
```lua
-- In language file, organize by category
return {
    -- Window
    window_title = "...",
    window_subtitle = "...",

    -- Tabs
    tab_main = "...",
    tab_settings = "...",

    -- Features
    auto_feed = "...",
    auto_sell = "...",
}
```

### 5. Test All Languages
```lua
-- Test script
local languages = {"EN", "TH", "JP", "CN"}
for _, lang in ipairs(languages) do
    Lang:SetLanguage(lang)
    print(lang .. ": " .. Lang:Get("window_title"))
end
```

---

## 🎯 Translation Key Reference

### Common Keys

| Key | Description | Example (EN) |
|-----|-------------|--------------|
| `window_title` | Main window title | "ATG HUB Premium" |
| `window_subtitle` | Window subtitle | "[ Raise Animals ]" |
| `tab_main` | Main tab name | "Main" |
| `tab_settings` | Settings tab name | "Settings" |
| `auto_feed` | Auto feed feature | "Auto Feed Animals" |
| `auto_feed_desc` | Auto feed description | "Automatically feed animals" |

### See Full Key List
ดูรายการ key ทั้งหมดได้ที่:
- [en.lua](en.lua) - English (Reference)
- [th.lua](th.lua) - Thai
- [jp.lua](jp.lua) - Japanese
- [cn.lua](cn.lua) - Chinese

---

## 🐛 Troubleshooting

### Issue: Translation not found
```lua
-- Check if key exists
local result = Lang:Get("my_key")
if result == "my_key" then
    warn("Translation key not found!")
end
```

### Issue: Language not loading
```lua
-- Check available languages
local langs = Lang:GetAvailableLanguages()
print("Available:", table.concat(langs, ", "))
```

### Issue: Wrong language detected
```lua
-- Manually set language instead of auto-detect
Lang:SetLanguage("EN")  -- Force English
```

---

## 📝 License

This language system is part of ATG Hub and follows the same license.

---

## 👥 Credits

**Created by:** ATG Team
**Version:** 1.0.0
**Last Updated:** 2024

---

## 🔗 Links

- [ATG Hub Main Repository](#)
- [Fluent UI Library](https://github.com/dawid-scripts/Fluent)
- [Report Issues](#)

---

## 📞 Support

หากมีปัญหาหรือข้อสงสัย:

1. อ่าน [example.lua](example.lua) สำหรับตัวอย่างการใช้งาน
2. ตรวจสอบ API Reference ด้านบน
3. ติดต่อทีม ATG ผ่าน Discord

---

## 🎉 Quick Example - Complete Script

```lua
-- Complete working example
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHUBUI/main/MainUI.lua"))()
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/Languages/init.lua"))()

-- Auto-detect and set language
Lang:SetLanguage(Lang:AutoDetectLanguage())

-- Create UI with translations
local Window = Fluent:CreateWindow({
    Title = Lang:Get("window_title"),
    SubTitle = Lang:Get("window_subtitle"),
    Size = UDim2.fromOffset(580, 460),
})

local Tabs = {
    Main = Window:AddTab({Title = Lang:Get("tab_main"), Icon = "repeat"}),
    Settings = Window:AddTab({Title = Lang:Get("tab_settings"), Icon = "settings"}),
}

-- Language selector
Tabs.Settings:AddDropdown("LangSelect", {
    Title = "Language / ภาษา",
    Values = {"EN", "TH", "JP", "CN"},
    Default = Lang:GetCurrentLanguage(),
    Callback = function(value)
        Lang:SetLanguage(value)
    end
})

-- Features with translation
Tabs.Main:AddToggle("AutoFeed", {
    Title = Lang:Get("auto_feed"),
    Description = Lang:Get("auto_feed_desc"),
    Default = false
})

print("✅ ATG Hub Multi-Language loaded! Language: " .. Lang:GetCurrentLanguageName())
```

---

**Happy Coding! 🚀**
