
# ATG HUB - Multi-Language UI System Documentation

## 📋 Overview

This comprehensive multi-language system allows all Premium scripts to support multiple languages with dynamic switching capabilities. The system is centralized, maintainable, and easy to extend.

## 🏗️ Architecture

### Core Components

1. **LanguageSystem.lua** - Centralized language data and management
2. **LanguageIntegration.lua** - Helper functions and integration utilities
3. **MainUiC.lua** - Updated to load and initialize the language system

### File Structure
```
ATGHub/Premium/
├── LanguageSystem.lua          # Core language data & functions
├── LanguageIntegration.lua     # Integration helpers
├── MainUiC.lua                 # Updated main UI (loads Lang system)
├── Raise-Animals-Premium.lua   # Example: Integrated script
├── Build-a-Zoo.lua             # Example: Integrated script
└── [Other Premium Scripts]     # To be integrated
```

## 🚀 Quick Start

### Basic Integration (3 Steps)

#### Step 1: Load Language System
Add this at the top of your script:

```lua
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/Premium/LanguageSystem.lua"))()
```

#### Step 2: Replace Hardcoded Text
Replace hardcoded strings with `Lang:T()` calls:

```lua
-- BEFORE
local Toggle = Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Description = "Automatically farm enemies",
    Default = false
})

-- AFTER
local Toggle = Tabs.Main:AddToggle("AutoFarm", {
    Title = Lang:T("farm.auto_farm"),
    Description = Lang:T("descriptions.auto_farm_desc"),
    Default = false
})
```

#### Step 3: Add Language Selector
Add to your Settings tab:

```lua
-- Load integration helpers
local LangIntegration = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/Premium/LanguageIntegration.lua"))()

-- Add language selector
LangIntegration.AddLanguageSelector(Tabs.Settings)
```

## 📖 API Reference

### Core Functions

#### `Lang:T(keyPath)` or `Lang:GetText(keyPath)`
Get translated text by key path.

```lua
local text = Lang:T("common.loading")        -- "Loading..." or "กำลังโหลด..."
local title = Lang:T("farm.auto_farm")       -- "Auto Farm" or "ออโต้ฟาร์ม"
local desc = Lang:T("descriptions.fly_desc") -- "Enable flying" or "เปิดการบิน"
```

#### `Lang:SetLanguage(langCode)`
Change current language.

```lua
Lang:SetLanguage("en") -- English
Lang:SetLanguage("th") -- Thai
Lang:SetLanguage("zh") -- Chinese
```

#### `Lang:GetCurrentLanguage()`
Get current language code.

```lua
local current = Lang:GetCurrentLanguage() -- Returns "en", "th", or "zh"
```

#### `Lang:GetAvailableLanguages()`
Get list of all available languages.

```lua
local languages = Lang:GetAvailableLanguages()
-- Returns: { {code="en", name="English", flag="🇺🇸", display="🇺🇸 English"}, ... }
```

#### `Lang:OnLanguageChanged(callback)`
Register callback for language changes.

```lua
Lang:OnLanguageChanged(function(newLang)
    print("Language changed to:", newLang)
    -- Update your UI elements here
end)
```

## 🗂️ Language Key Structure

### Available Key Paths

#### Common
- `common.loading`, `common.success`, `common.error`, `common.warning`
- `common.confirm`, `common.cancel`, `common.ok`, `common.yes`, `common.no`
- `common.close`, `common.save`, `common.delete`, `common.refresh`, `common.reset`
- `common.enable`, `common.disable`, `common.start`, `common.stop`

#### Main Tab
- `main.title`, `main.player_info`, `main.name`, `main.date`, `main.played_time`
- `main.auto_claim`, `main.auto_upgrade`, `main.auto_equip`

#### Farm Tab
- `farm.title`, `farm.auto_farm`, `farm.fast_attack`, `farm.kill_aura`
- `farm.auto_collect`, `farm.radius`, `farm.select_enemy`, `farm.select_target`

#### Settings Tab
- `settings.title`, `settings.language`, `settings.select_language`, `settings.theme`
- `settings.anti_afk`, `settings.auto_rejoin`, `settings.save_config`, `settings.load_config`

#### Server Tab
- `server.title`, `server.server_hop`, `server.rejoin`, `server.lower_server`
- `server.job_id`, `server.input_job_id`, `server.teleport_to_job`, `server.copy_job_id`

#### Humanoid Tab
- `humanoid.title`, `humanoid.walk_speed`, `humanoid.jump_power`, `humanoid.fly`
- `humanoid.noclip`, `humanoid.fly_speed`, `humanoid.enable_walk`, `humanoid.enable_jump`

#### Notifications
- `notifications.script_loaded`, `notifications.feature_enabled`, `notifications.feature_disabled`
- `notifications.no_target`, `notifications.teleport_success`, `notifications.teleport_failed`
- `notifications.invalid_input`, `notifications.please_wait`

#### Descriptions
- `descriptions.auto_farm_desc`, `descriptions.fast_attack_desc`, `descriptions.kill_aura_desc`
- `descriptions.fly_desc`, `descriptions.noclip_desc`, `descriptions.anti_afk_desc`
- `descriptions.server_hop_desc`

## 🌍 Supported Languages

| Code | Language | Flag | Status |
|------|----------|------|--------|
| `en` | English | 🇺🇸 | ✅ Complete |
| `th` | ไทย (Thai) | 🇹🇭 | ✅ Complete |
| `zh` | 中文 (Chinese) | 🇨🇳 | ✅ Complete |

## ➕ Adding New Languages

### Step 1: Add Language Data
Edit `LanguageSystem.lua` and add new language:

```lua