-- ============================================================
-- ATG HUB - Language Integration Example
-- This file demonstrates how to integrate the language system
-- into existing Premium scripts
-- ============================================================

-- ============================================================
-- STEP 1: Load Language System at the top of your script
-- ============================================================
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Premium/LanguageSystem.lua"))()

-- Or if using local file:
-- local Lang = require(script.Parent.LanguageSystem)

-- ============================================================
-- STEP 2: Add Language Selector to Settings Tab
-- ============================================================
local function AddLanguageSelector(SettingsTab)
    local Section = SettingsTab:AddSection(string.format("[ 🌐 ] %s", Lang:T("settings.language")))
    
    -- Get available languages
    local languages = Lang:GetAvailableLanguages()
    local languageValues = {}
    local currentIndex = 1
    
    for i, langData in ipairs(languages) do
        table.insert(languageValues, langData.display)
        if langData.code == Lang:GetCurrentLanguage() then
            currentIndex = i
        end
    end
    
    -- Create dropdown
    local LanguageDropdown = Section:AddDropdown("LanguageSelect", {
        Title = Lang:T("settings.select_language"),
        Description = "Choose your preferred language",
        Values = languageValues,
        Multi = false,
        Default = currentIndex,
    })
    
    -- Handle language change
    LanguageDropdown:OnChanged(function(value)
        -- Find selected language code
        for _, langData in ipairs(languages) do
            if langData.display == value then
                Lang:SetLanguage(langData.code)
                
                -- Notify user
                if Fluent and Fluent.Notify then
                    Fluent:Notify({
                        Title = Lang:T("settings.language"),
                        Content = string.format("Language changed to %s", langData.name),
                        Duration = 3
                    })
                end
                
                -- Reload UI to apply changes
                task.wait(0.5)
                if Window and Window.Minimize then
                    Window:Minimize()
                    task.wait(0.1)
                    Window:Minimize()
                end
                
                break
            end
        end
    end)
    
    return LanguageDropdown
end

-- ============================================================
-- STEP 3: Replace Hardcoded Strings with Lang:T() calls
-- ============================================================

-- BEFORE (Hardcoded):
-- local Toggle = Tabs.Main:AddToggle("AutoFarm", {
--     Title = "Auto Farm",
--     Description = "Automatically farm enemies",
--     Default = false
-- })

-- AFTER (Multi-language):
local function CreateAutoFarmToggle(MainTab)
    local Toggle = MainTab:AddToggle("AutoFarm", {
        Title = Lang:T("farm.auto_farm"),
        Description = Lang:T("descriptions.auto_farm_desc"),
        Default = false
    })
    return Toggle
end

-- ============================================================
-- GITHUB RAW URL
-- ============================================================
-- Use this URL to load the language system:
-- https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Premium/LanguageSystem.lua

-- ============================================================
-- STEP 4: Update Notifications
-- ============================================================

-- BEFORE:
-- Fluent:Notify({
--     Title = "Success",
--     Content = "Feature enabled",
--     Duration = 3
-- })

-- AFTER:
local function NotifySuccess(message)
    if Fluent and Fluent.Notify then
        Fluent:Notify({
            Title = Lang:T("common.success"),
            Content = message or Lang:T("notifications.feature_enabled"),
            Duration = 3
        })
    end
end

-- ============================================================
-- STEP 5: Update Tab Titles
-- ============================================================

-- BEFORE:
-- local Tabs = {
--     Main = Window:AddTab({ Title = "Main", Icon = "home" }),
--     Farm = Window:AddTab({ Title = "Farm", Icon = "target" }),
--     Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
-- }

-- AFTER:
local function CreateTabs(Window)
    local Tabs = {
        Main = Window:AddTab({ Title = Lang:T("main.title"), Icon = "home" }),
        Farm = Window:AddTab({ Title = Lang:T("farm.title"), Icon = "target" }),
        Settings = Window:AddTab({ Title = Lang:T("settings.title"), Icon = "settings" }),
        Server = Window:AddTab({ Title = Lang:T("server.title"), Icon = "server" }),
        Humanoid = Window:AddTab({ Title = Lang:T("humanoid.title"), Icon = "user" }),
    }
    return Tabs
end

-- ============================================================
-- STEP 6: Dynamic Language Updates
-- ============================================================

-- Store UI elements that need updating
local UIElements = {
    toggles = {},
    buttons = {},
    paragraphs = {},
    sections = {},
}

-- Register UI element for language updates
local function RegisterUIElement(element, textKey, property)
    property = property or "Title"
    table.insert(UIElements[element.Type or "toggles"], {
        element = element,
        textKey = textKey,
        property = property
    })
end

-- Update all UI elements when language changes
local function UpdateAllUIElements()
    for category, elements in pairs(UIElements) do
        for _, data in ipairs(elements) do
            if data.element and data.textKey then
                local newText = Lang:T(data.textKey)
                pcall(function()
                    if data.element.SetTitle then
                        data.element:SetTitle(newText)
                    elseif data.element[data.property] then
                        data.element[data.property] = newText
                    end
                end)
            end
        end
    end
end

-- Register language change callback
Lang:OnLanguageChanged(function(newLang)
    print(string.format("[Language] Changed to: %s", newLang))
    UpdateAllUIElements()
end)

-- ============================================================
-- STEP 7: Helper Functions for Common Patterns
-- ============================================================

-- Create a toggle with language support
local function CreateLangToggle(tab, id, titleKey, descKey, default)
    local toggle = tab:AddToggle(id, {
        Title = Lang:T(titleKey),
        Description = Lang:T(descKey),
        Default = default or false
    })
    
    RegisterUIElement(toggle, titleKey, "Title")
    return toggle
end

-- Create a button with language support
local function CreateLangButton(tab, titleKey, descKey, callback)
    local button = tab:AddButton({
        Title = Lang:T(titleKey),
        Description = Lang:T(descKey),
        Callback = callback
    })
    
    RegisterUIElement(button, titleKey, "Title")
    return button
end

-- Create a section with language support
local function CreateLangSection(tab, titleKey)
    local section = tab:AddSection(string.format("[ 🎯 ] %s", Lang:T(titleKey)))
    RegisterUIElement(section, titleKey, "Title")
    return section
end

-- ============================================================
-- STEP 8: Complete Integration Example
-- ============================================================

local function IntegrateLanguageSystem(Window, Tabs)
    -- Add language selector to Settings tab
    if Tabs.Settings then
        AddLanguageSelector(Tabs.Settings)
    end
    
    -- Example: Create auto farm toggle with multi-language support
    if Tabs.Farm then
        local Section = CreateLangSection(Tabs.Farm, "farm.auto_farm")
        
        local AutoFarmToggle = CreateLangToggle(
            Tabs.Farm,
            "AutoFarmToggle",
            "farm.auto_farm",
            "descriptions.auto_farm_desc",
            false
        )
        
        AutoFarmToggle:OnChanged(function(value)
            if value then
                NotifySuccess(Lang:T("notifications.feature_enabled"))
            else
                NotifySuccess(Lang:T("notifications.feature_disabled"))
            end
        end)
    end
    
    -- Example: Server hop button with multi-language
    if Tabs.Server then
        CreateLangButton(
            Tabs.Server,
            "server.server_hop",
            "descriptions.server_hop_desc",
            function()
                -- Server hop logic here
                NotifySuccess(Lang:T("notifications.please_wait"))
            end
        )
    end
end

-- ============================================================
-- USAGE EXAMPLES
-- ============================================================

--[[
    -- Get translated text:
    local text = Lang:T("common.loading")
    local farmTitle = Lang:T("farm.title")
    
    -- Set language:
    Lang:SetLanguage("th") -- Thai
    Lang:SetLanguage("en") -- English
    Lang:SetLanguage("zh") -- Chinese
    
    -- Get current language:
    local current = Lang:GetCurrentLanguage()
    
    -- Get available languages:
    local languages = Lang:GetAvailableLanguages()
    for _, lang in ipairs(languages) do
        print(lang.code, lang.name, lang.flag)
    end
]]

-- ============================================================
-- EXPORT
-- ============================================================
return {
    Lang = Lang,
    AddLanguageSelector = AddLanguageSelector,
    CreateLangToggle = CreateLangToggle,
    CreateLangButton = CreateLangButton,
    CreateLangSection = CreateLangSection,
    IntegrateLanguageSystem = IntegrateLanguageSystem,
    NotifySuccess = NotifySuccess,
    UpdateAllUIElements = UpdateAllUIElements,
}
