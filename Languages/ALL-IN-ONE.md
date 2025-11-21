# ATG Hub Language System - All-in-One Version 🎯

## 🌟 ภาพรวม

**LanguageSystem.lua** คือระบบ Multi-Language แบบ **All-in-One** ที่รวมทุกอย่างไว้ในไฟล์เดียว!

- ✅ ไม่ต้องโหลดหลายไฟล์
- ✅ ทุกภาษาอยู่ในที่เดียว (EN, TH, JP, CN)
- ✅ ใช้งานง่าย เหมือนระบบธีม
- ✅ ไม่มี External Dependencies
- ✅ โหลดเร็ว ใช้งานทันที

---

## ⚡ Quick Start

### 1. โหลดระบบ (1 บรรทัด)

```lua
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/LanguageSystem.lua"))()
```

### 2. ใช้งานทันที

```lua
-- ดึงข้อความ
print(Lang:Get("window_title"))  -- "ATG HUB Premium"

-- เปลี่ยนภาษา
Lang:SetLanguage("TH")
print(Lang:Get("window_title"))  -- "ATG HUB พรีเมียม"

-- Auto-detect ภาษา
Lang:SetLanguage(Lang:AutoDetectLanguage())
```

---

## 📦 เปรียบเทียบระหว่าง 2 แบบ

### แบบแยกไฟล์ (Modular)
```lua
-- ต้องโหลด 5 ไฟล์ (init.lua + 4 language files)
local Lang = loadstring(game:HttpGet("...init.lua"))()
-- init.lua จะโหลด en.lua, th.lua, jp.lua, cn.lua อีกที

✅ Pros: แยกจัดการง่าย, เพิ่มภาษาใหม่สะดวก
❌ Cons: โหลดช้ากว่า (5 HTTP requests)
```

### แบบ All-in-One ⭐
```lua
-- โหลดแค่ไฟล์เดียว
local Lang = loadstring(game:HttpGet("...LanguageSystem.lua"))()

✅ Pros: โหลดเร็ว (1 HTTP request), ใช้งานง่าย
✅ Pros: ไม่พึ่งพา external files
❌ Cons: ไฟล์ใหญ่กว่า (~50KB)
```

---

## 🎯 การใช้งาน

### ตัวอย่างสมบูรณ์

```lua
-- โหลดระบบภาษา
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/LanguageSystem.lua"))()

-- Auto-detect ภาษาจาก Player
Lang:SetLanguage(Lang:AutoDetectLanguage())

-- สร้าง UI ด้วย Fluent
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHUBUI/main/MainUI.lua"))()

local Window = Fluent:CreateWindow({
    Title = Lang:Get("window_title"),
    SubTitle = Lang:Get("window_subtitle"),
    Size = UDim2.fromOffset(580, 460),
})

-- สร้าง Tabs
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

-- Toggle with translation
Tabs.Main:AddToggle("AutoFeed", {
    Title = Lang:Get("auto_feed"),
    Description = Lang:Get("auto_feed_desc"),
    Default = false
})

print("✅ Language System loaded! Current: " .. Lang:GetCurrentLanguageName())
```

---

## 📚 API Reference

### Core Functions

| Function | คำอธิบาย | ตัวอย่าง |
|----------|----------|----------|
| `Lang:Get(key)` | ดึงข้อความแปล | `Lang:Get("window_title")` |
| `Lang:T(key)` | Shortcut สำหรับ Get | `Lang:T("auto_feed")` |
| `Lang:SetLanguage(code)` | เปลี่ยนภาษา | `Lang:SetLanguage("TH")` |
| `Lang:GetCurrentLanguage()` | ดูภาษาปัจจุบัน | `"EN"` |
| `Lang:GetCurrentLanguageName()` | ดูชื่อภาษา | `"English"` |
| `Lang:AutoDetectLanguage()` | ตรวจจับภาษาอัตโนมัติ | `"TH"` |
| `Lang:GetAvailableLanguages()` | ดูภาษาที่มี | `{"EN", "TH", "JP", "CN"}` |
| `Lang:IsLanguageAvailable(code)` | เช็คว่ามีภาษานี้ไหม | `true/false` |

### Variable Replacement

```lua
-- ใช้ {variable} ในข้อความ
local text = Lang:Get("amount", {amount = 100})
-- EN: "Amount: 100"
-- TH: "จำนวน: 100"

local version = Lang:Get("version", {version = "2.0.0"})
-- EN: "Version 2.0.0"
-- TH: "เวอร์ชัน 2.0.0"
```

---

## 🔑 Translation Keys

### หมวดหมู่ทั้งหมด

<details>
<summary><b>Window & General</b> (6 keys)</summary>

- `window_title`
- `window_subtitle`
- `language`
- `language_name`
- `language_changed`
- `language_changed_desc`
</details>

<details>
<summary><b>Tabs</b> (10 keys)</summary>

- `tab_main`
- `tab_pen`
- `tab_egg`
- `tab_events`
- `tab_autoplay`
- `tab_screen`
- `tab_humanoid`
- `tab_players`
- `tab_server`
- `tab_settings`
</details>

<details>
<summary><b>Auto Features</b> (15 keys)</summary>

- `auto_feed`, `auto_feed_desc`
- `auto_sell`, `auto_sell_desc`, `auto_sell_warn`, `auto_sell_warn_desc`
- `auto_buy_food`, `auto_buy_food_desc`
- `auto_buy_animals`, `auto_buy_animals_desc`
- `auto_place`, `auto_place_desc`
- `auto_pickup`, `auto_pickup_desc`
- `pickup_all`, `pickup_all_desc`
- `auto_exchange_dna`, `auto_exchange_dna_desc`
</details>

<details>
<summary><b>และอีกมากมาย...</b></summary>

- **Selections** (9 keys)
- **Events** (4 keys)
- **Auto Play** (15 keys)
- **Screen & GUI** (6 keys)
- **Humanoid Settings** (7 keys)
- **Players** (3 keys)
- **Server** (8 keys)
- **Notifications** (4 keys)
- **Actions** (12 keys)
- **Status** (7 keys)
- **Common** (8 keys)
- **Numbers & Units** (6 keys)
- **Errors & Warnings** (5 keys)
- **Misc** (5 keys)

**Total: 100+ keys**
</details>

---

## 🌍 ภาษาที่รองรับ

| Code | Language | Status |
|------|----------|--------|
| EN | English | ✅ 100+ keys |
| TH | ไทย (Thai) | ✅ 100+ keys |
| JP | 日本語 (Japanese) | ✅ 100+ keys |
| CN | 简体中文 (Chinese) | ✅ 100+ keys |

---

## 💡 เคล็ดลับการใช้งาน

### 1. เปลี่ยนภาษาพร้อม Notification

```lua
local function changeLanguage(langCode)
    Lang:SetLanguage(langCode)

    Fluent:Notify({
        Title = Lang:Get("language_changed"),
        Content = Lang:Get("language_changed_desc"),
        Duration = 3
    })
end

changeLanguage("TH")
```

### 2. สร้าง Helper Function

```lua
local UIHelper = {}

function UIHelper:CreateToggle(tab, id, titleKey, descKey, default)
    return tab:AddToggle(id, {
        Title = Lang:Get(titleKey),
        Description = Lang:Get(descKey),
        Default = default or false
    })
end

-- ใช้งาน
UIHelper:CreateToggle(Tabs.Main, "AutoFeed", "auto_feed", "auto_feed_desc", false)
```

### 3. เก็บภาษาที่เลือกไว้

```lua
-- Save to config
local SavedLanguage = Lang:GetCurrentLanguage()

-- Load later
Lang:SetLanguage(SavedLanguage)
```

### 4. เพิ่มภาษาใหม่ (Custom)

```lua
-- เพิ่มภาษาเกาหลี
local koreanLang = {
    window_title = "ATG HUB 프리미엄",
    tab_main = "메인",
    -- ... เพิ่ม keys อื่นๆ
}

Lang:LoadLanguage("KR", koreanLang)
Lang:SetLanguage("KR")
```

---

## 🔧 ข้อแตกต่างกับแบบแยกไฟล์

| คุณสมบัติ | All-in-One | Modular (แยกไฟล์) |
|-----------|------------|-------------------|
| จำนวนไฟล์ | 1 ไฟล์ | 5 ไฟล์ |
| HTTP Requests | 1 request | 5 requests |
| ความเร็วโหลด | ⚡ เร็วกว่า | ช้ากว่า |
| ขนาดไฟล์ | ~50KB | ~25KB (5 files) |
| การจัดการ | ง่าย, ไฟล์เดียว | ซับซ้อนกว่า |
| เพิ่มภาษาใหม่ | แก้ 1 ไฟล์ | เพิ่ม 1 ไฟล์ใหม่ |
| เหมาะสำหรับ | **Production** | Development |

---

## 📝 เมื่อไหร่ควรใช้แบบไหน

### ใช้ All-in-One เมื่อ:
- ✅ ต้องการความเร็วในการโหลด
- ✅ ต้องการความเรียบง่าย
- ✅ ใช้งานจริง (Production)
- ✅ ไม่ต้องการเพิ่มภาษาใหม่บ่อยๆ

### ใช้ Modular (แยกไฟล์) เมื่อ:
- ✅ กำลังพัฒนา (Development)
- ✅ ต้องการเพิ่ม/แก้ภาษาบ่อย
- ✅ มีหลายคนร่วมแปล
- ✅ ต้องการจัดการแต่ละภาษาแยก

---

## 🚀 การอัพเดต

### อัพเดตจาก Modular มา All-in-One

```lua
-- เดิม (Modular)
local Lang = loadstring(game:HttpGet("...Languages/init.lua"))()

-- ใหม่ (All-in-One) - เปลี่ยนแค่ URL
local Lang = loadstring(game:HttpGet("...Languages/LanguageSystem.lua"))()

-- การใช้งานเหมือนเดิมทุกอย่าง!
```

---

## 📊 Performance

### Benchmark (โดยประมาณ)

```
Modular (5 files):
├─ HTTP Requests: 5x
├─ Load Time: ~2-3 วินาที
└─ Total Size: ~25KB

All-in-One (1 file):
├─ HTTP Requests: 1x
├─ Load Time: ~0.5-1 วินาที ⚡
└─ Total Size: ~50KB
```

**All-in-One เร็วกว่า 2-3 เท่า!**

---

## ✅ Checklist การใช้งาน

- [ ] โหลด LanguageSystem.lua
- [ ] เรียก AutoDetectLanguage()
- [ ] สร้าง UI ด้วย Lang:Get()
- [ ] เพิ่ม Language Selector
- [ ] ทดสอบทุกภาษา
- [ ] เก็บภาษาที่เลือกไว้ในการตั้งค่า

---

## 🔗 Links

- **GitHub:** https://github.com/ATGFAIL/ATGHub/tree/main/Languages
- **Raw File:** https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/LanguageSystem.lua
- **Documentation:** [README.md](README.md)
- **Quick Start:** [QUICKSTART.md](QUICKSTART.md)

---

## 💬 Support

ถ้ามีปัญหาหรือคำถาม:
1. ดู [README.md](README.md) สำหรับเอกสารเต็ม
2. ดู [example.lua](example.lua) สำหรับตัวอย่างการใช้งาน
3. ติดต่อ ATG Team ผ่าน Discord

---

**Created by ATG Team** 🚀
**Version:** 2.0.0 (All-in-One)
**Last Updated:** 2024

---

## 🎉 สรุป

**LanguageSystem.lua** คือตัวเลือกที่ดีที่สุดสำหรับ:
- ✅ โหลดเร็ว (1 request)
- ✅ ใช้งานง่าย (ไฟล์เดียว)
- ✅ ไม่พึ่งพา external files
- ✅ เหมาะสำหรับ Production

**Copy & Paste Ready:**
```lua
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/LanguageSystem.lua"))()
Lang:SetLanguage(Lang:AutoDetectLanguage())
print(Lang:Get("window_title"))
```

**Happy Coding! 🚀**
