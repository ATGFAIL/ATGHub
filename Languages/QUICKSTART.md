# Quick Start - ATG Hub Multi-Language System ⚡

## ⏱️ การเริ่มต้นแบบ 3 นาที

### 1️⃣ โหลดระบบภาษา

```lua
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/init.lua"))()
```

### 2️⃣ ใช้งานทันที

```lua
-- ดึงข้อความแปล
print(Lang:Get("window_title"))  -- "ATG HUB Premium"

-- เปลี่ยนภาษา
Lang:SetLanguage("TH")
print(Lang:Get("window_title"))  -- "ATG HUB พรีเมียม"
```

### 3️⃣ ใช้กับ Fluent UI

```lua
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHUBUI/main/MainUI.lua"))()
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/init.lua"))()

-- สร้าง Window
local Window = Fluent:CreateWindow({
    Title = Lang:Get("window_title"),
    SubTitle = Lang:Get("window_subtitle"),
    Size = UDim2.fromOffset(580, 460),
})

-- สร้าง Tabs
local Tabs = {
    Main = Window:AddTab({Title = Lang:Get("tab_main"), Icon = "repeat"}),
    Settings = Window:AddTab({Title = Lang:Get("tab_settings"), Icon = "settings"}),
}

-- เพิ่ม Toggle
Tabs.Main:AddToggle("AutoFeed", {
    Title = Lang:Get("auto_feed"),
    Description = Lang:Get("auto_feed_desc"),
    Default = false
})

-- Language Selector
Tabs.Settings:AddDropdown("LangSelect", {
    Title = "Language / ภาษา",
    Values = {"EN", "TH", "JP", "CN"},
    Default = Lang:GetCurrentLanguage(),
    Callback = function(value)
        Lang:SetLanguage(value)
    end
})
```

---

## 🎯 ภาษาที่รองรับ

- **EN** - English
- **TH** - ไทย
- **JP** - 日本語
- **CN** - 简体中文

---

## 🔧 Functions ที่ใช้บ่อย

| Function | คำอธิบาย |
|----------|----------|
| `Lang:Get("key")` | ดึงข้อความแปล |
| `Lang:SetLanguage("TH")` | เปลี่ยนภาษา |
| `Lang:GetCurrentLanguage()` | ดูภาษาปัจจุบัน |
| `Lang:AutoDetectLanguage()` | ตรวจจับภาษาอัตโนมัติ |

---

## 📌 Translation Keys ที่ใช้บ่อย

### Window
- `window_title` - ชื่อหน้าต่าง
- `window_subtitle` - ชื่อรอง

### Tabs
- `tab_main` - แท็บหลัก
- `tab_settings` - แท็บตั้งค่า
- `tab_players` - แท็บผู้เล่น

### Features
- `auto_feed` - ให้อาหารอัตโนมัติ
- `auto_sell` - ขายอัตโนมัติ
- `auto_buy_food` - ซื้ออาหารอัตโนมัติ
- `pickup_all` - เก็บทั้งหมด

### Actions
- `start` - เริ่ม
- `stop` - หยุด
- `enable` - เปิด
- `disable` - ปิด

---

## 💡 ตัวอย่างการใช้ตัวแปร

```lua
-- ข้อความที่มี {variable}
local text = Lang:Get("amount", {amount = 100})
-- EN: "Amount: 100"
-- TH: "จำนวน: 100"

local version = Lang:Get("version", {version = "1.5.0"})
-- EN: "Version 1.5.0"
-- TH: "เวอร์ชัน 1.5.0"
```

---

## 📖 ดูเอกสารเพิ่มเติม

- [README.md](README.md) - เอกสารฉบับเต็ม
- [example.lua](example.lua) - ตัวอย่างการใช้งานทั้งหมด
- [GitHub Repository](https://github.com/ATGFAIL/ATGHub/tree/main/Languages)

---

## ✅ เริ่มใช้งานเลย!

Copy โค้ดด้านล่างนี้ไปใช้ได้เลย:

```lua
-- ATG Hub with Multi-Language Support
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHUBUI/main/MainUI.lua"))()
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/init.lua"))()

-- Auto-detect language from player
Lang:SetLanguage(Lang:AutoDetectLanguage())

-- Create your UI here...
local Window = Fluent:CreateWindow({
    Title = Lang:Get("window_title"),
    SubTitle = Lang:Get("window_subtitle"),
    Size = UDim2.fromOffset(580, 460),
})

print("✅ Multi-Language loaded! Current: " .. Lang:GetCurrentLanguageName())
```

**Happy Coding! 🚀**
