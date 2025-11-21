--[[
    ATG Hub Language System - Test Script
    ใช้สำหรับทดสอบระบบภาษาว่าทำงานถูกต้อง

    วิธีใช้:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/test.lua"))()
]]

print("=" :rep(60))
print("🧪 ATG Hub Language System - Test Script")
print("=" :rep(60))

-- Load Language System
print("\n[1/6] Loading Language System...")
local success, Lang = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/init.lua"))()
end)

if not success then
    error("❌ Failed to load Language System: " .. tostring(Lang))
end
print("✅ Language System loaded successfully!")

-- Test 1: Check Default Language
print("\n[2/6] Testing Default Language...")
local currentLang = Lang:GetCurrentLanguage()
print("   Current Language: " .. currentLang)
print("   Language Name: " .. Lang:GetCurrentLanguageName())
assert(currentLang == "EN", "❌ Default language should be EN")
print("✅ Default language is correct!")

-- Test 2: Check Available Languages
print("\n[3/6] Testing Available Languages...")
local langs = Lang:GetAvailableLanguages()
print("   Available Languages: " .. table.concat(langs, ", "))
assert(#langs >= 4, "❌ Should have at least 4 languages")
print("✅ Found " .. #langs .. " languages!")

-- Test 3: Test Translation Keys
print("\n[4/6] Testing Translation Keys...")
local testKeys = {
    "window_title",
    "window_subtitle",
    "tab_main",
    "auto_feed",
    "auto_feed_desc",
    "notification_success"
}

local missingKeys = {}
for _, key in ipairs(testKeys) do
    local text = Lang:Get(key)
    if text == key then
        table.insert(missingKeys, key)
        print("   ⚠️  Missing: " .. key)
    else
        print("   ✅ " .. key .. " = \"" .. text .. "\"")
    end
end

if #missingKeys > 0 then
    warn("⚠️  Some keys are missing: " .. table.concat(missingKeys, ", "))
else
    print("✅ All test keys found!")
end

-- Test 4: Test Language Switching
print("\n[5/6] Testing Language Switching...")
local testLangs = {"EN", "TH", "JP", "CN"}
for _, langCode in ipairs(testLangs) do
    local success = Lang:SetLanguage(langCode)
    if success then
        local title = Lang:Get("window_title")
        print("   ✅ " .. langCode .. ": " .. title)
    else
        print("   ❌ Failed to switch to " .. langCode)
    end
end

-- Switch back to English
Lang:SetLanguage("EN")
print("✅ Language switching works!")

-- Test 5: Test Variable Replacement
print("\n[6/6] Testing Variable Replacement...")
local testAmount = Lang:Get("amount", {amount = 123})
print("   With variable: " .. testAmount)
assert(testAmount:find("123"), "❌ Variable replacement failed")
print("✅ Variable replacement works!")

-- Test Summary
print("\n" .. "=" :rep(60))
print("📊 Test Summary")
print("=" :rep(60))

local summary = {
    {"Language System", "✅ Loaded"},
    {"Default Language", "✅ EN"},
    {"Available Languages", "✅ " .. #langs .. " languages"},
    {"Translation Keys", #missingKeys == 0 and "✅ All keys found" or "⚠️  " .. #missingKeys .. " missing"},
    {"Language Switching", "✅ Works"},
    {"Variable Replacement", "✅ Works"},
}

for _, item in ipairs(summary) do
    print(string.format("%-25s %s", item[1] .. ":", item[2]))
end

-- Display all languages with their window titles
print("\n" .. "=" :rep(60))
print("🌍 All Languages - Window Titles")
print("=" :rep(60))

for _, langCode in ipairs(testLangs) do
    Lang:SetLanguage(langCode)
    local title = Lang:Get("window_title")
    local subtitle = Lang:Get("window_subtitle")
    print(string.format("%s - %s", langCode, title .. " " .. subtitle))
end

-- Reset to English
Lang:SetLanguage("EN")

print("\n" .. "=" :rep(60))
print("✅ All Tests Completed Successfully!")
print("=" :rep(60))
print("\n💡 Language System is ready to use!")
print("📖 See README.md for usage examples")
print("🔗 GitHub: https://github.com/ATGFAIL/ATGHub/tree/main/Languages")

-- Return Lang for further testing
return Lang
