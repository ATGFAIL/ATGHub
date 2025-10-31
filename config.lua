-- InterfaceManager (improved)
-- - embeds built-in themes
-- - auto-loads theme modules from script:GetChildren()
-- - ApplyTheme tries multiple library/window APIs as fallback
-- - Save/Load settings to file if file API available
-- - BuildInterfaceSection uses SetTheme which calls ApplyTheme
-- Usage:
-- local IM = require(path.to.InterfaceManager)
-- IM:SetLibrary(Fluent)   -- optional (will default to internal DefaultLibrary)
-- IM:BuildInterfaceSection(tab)

local HttpService = game:GetService("HttpService")

local InterfaceManager = {}
InterfaceManager.Folder = "FluentSettings"
InterfaceManager.Settings = {
    Theme = "Dark",
    Acrylic = true,
    Transparency = true,
    MenuKeybind = "LeftControl"
}

-- File API detection (exploit environments vary)
local has_isfile = type(isfile) == "function"
local has_readfile = type(readfile) == "function"
local has_writefile = type(writefile) == "function"
local has_makefolder = type(makefolder) == "function"
local has_isfolder = type(isfolder) == "function"

-- Internal helpers ---------------------------------------------------------
local function safeEncode(tab)
    local ok, res = pcall(function() return HttpService:JSONEncode(tab) end)
    if ok then return res end
    return nil
end

local function safeDecode(str)
    local ok, res = pcall(function() return HttpService:JSONDecode(str) end)
    if ok then return res end
    return nil
end

-- ======================================================================
-- Themes table (embedded)
-- ======================================================================
local Themes = {}
Themes.Names = {
    "Dark","Darker","Light","Aqua","Amethyst","Rose","Emerald","Crimson",
    "Ocean","Sunset","Lavender","Mint","Coral","Gold","Midnight","Forest",
}

-- (Only a subset expanded here for brevity — include any themes you want)
Themes["Emerald"] = {
    Name = "Emerald",
    Accent = Color3.fromRGB(16, 185, 129),
    AcrylicMain = Color3.fromRGB(18, 18, 18),
    AcrylicBorder = Color3.fromRGB(52, 211, 153),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(16, 185, 129), Color3.fromRGB(5, 150, 105)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(16, 185, 129),
    Tab = Color3.fromRGB(110, 231, 183),
    Element = Color3.fromRGB(52, 211, 153),
    ElementBorder = Color3.fromRGB(6, 95, 70),
    InElementBorder = Color3.fromRGB(16, 185, 129),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(52, 211, 153),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(52, 211, 153),
    DropdownFrame = Color3.fromRGB(110, 231, 183),
    DropdownHolder = Color3.fromRGB(6, 78, 59),
    DropdownBorder = Color3.fromRGB(4, 120, 87),
    DropdownOption = Color3.fromRGB(52, 211, 153),
    Keybind = Color3.fromRGB(52, 211, 153),
    Input = Color3.fromRGB(52, 211, 153),
    InputFocused = Color3.fromRGB(6, 78, 59),
    InputIndicator = Color3.fromRGB(110, 231, 183),
    Dialog = Color3.fromRGB(6, 78, 59),
    DialogHolder = Color3.fromRGB(4, 120, 87),
    DialogHolderLine = Color3.fromRGB(6, 95, 70),
    DialogButton = Color3.fromRGB(16, 185, 129),
    DialogButtonBorder = Color3.fromRGB(52, 211, 153),
    DialogBorder = Color3.fromRGB(16, 185, 129),
    DialogInput = Color3.fromRGB(6, 95, 70),
    DialogInputLine = Color3.fromRGB(110, 231, 183),
    Text = Color3.fromRGB(240, 253, 244),
    SubText = Color3.fromRGB(167, 243, 208),
    Hover = Color3.fromRGB(52, 211, 153),
    HoverChange = 0.04,
}

Themes["Crimson"] = {
    Name = "Crimson",
    Accent = Color3.fromRGB(220, 38, 38),
    AcrylicMain = Color3.fromRGB(20, 20, 20),
    AcrylicBorder = Color3.fromRGB(239, 68, 68),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(220, 38, 38), Color3.fromRGB(153, 27, 27)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(220, 38, 38),
    Tab = Color3.fromRGB(252, 165, 165),
    Element = Color3.fromRGB(239, 68, 68),
    ElementBorder = Color3.fromRGB(127, 29, 29),
    InElementBorder = Color3.fromRGB(185, 28, 28),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(239, 68, 68),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(239, 68, 68),
    DropdownFrame = Color3.fromRGB(252, 165, 165),
    DropdownHolder = Color3.fromRGB(127, 29, 29),
    DropdownBorder = Color3.fromRGB(153, 27, 27),
    DropdownOption = Color3.fromRGB(239, 68, 68),
    Keybind = Color3.fromRGB(239, 68, 68),
    Input = Color3.fromRGB(239, 68, 68),
    InputFocused = Color3.fromRGB(127, 29, 29),
    InputIndicator = Color3.fromRGB(252, 165, 165),
    Dialog = Color3.fromRGB(127, 29, 29),
    DialogHolder = Color3.fromRGB(153, 27, 27),
    DialogHolderLine = Color3.fromRGB(185, 28, 28),
    DialogButton = Color3.fromRGB(220, 38, 38),
    DialogButtonBorder = Color3.fromRGB(239, 68, 68),
    DialogBorder = Color3.fromRGB(220, 38, 38),
    DialogInput = Color3.fromRGB(153, 27, 27),
    DialogInputLine = Color3.fromRGB(252, 165, 165),
    Text = Color3.fromRGB(254, 242, 242),
    SubText = Color3.fromRGB(254, 202, 202),
    Hover = Color3.fromRGB(239, 68, 68),
    HoverChange = 0.04,
}

-- Add more embedded themes here as needed...
-- ======================================================================

-- Auto-load child modules as themes (safe require)
if type(script) == "table" and type(script.GetChildren) == "function" then
    for _, child in next, script:GetChildren() do
        local ok, required = pcall(function() return require(child) end)
        if ok and type(required) == "table" and type(required.Name) == "string" then
            Themes[required.Name] = required
            -- add name to Names if not present
            local exists = false
            for _, n in ipairs(Themes.Names) do
                if n == required.Name then exists = true break end
            end
            if not exists then
                table.insert(Themes.Names, required.Name)
            end
        else
            if not ok then
                -- debug: child failed to require; don't error out
                warn("[InterfaceManager] failed to require child theme:", tostring(child.Name), tostring(required))
            end
        end
    end
end

-- ======================================================================
-- DefaultLibrary wrapper — so IM:SetLibrary() can accept other libs
-- ======================================================================
local DefaultLibrary = {}
DefaultLibrary.Themes = Themes
DefaultLibrary.CurrentTheme = Themes[InterfaceManager.Settings.Theme] or nil
DefaultLibrary.MinimizeKeybind = nil
DefaultLibrary.UseAcrylic = true -- flag for BuildInterfaceSection to show Acrylic toggle

function DefaultLibrary:SetTheme(nameOrTable)
    if type(nameOrTable) == "string" then
        DefaultLibrary.CurrentTheme = Themes[nameOrTable] or DefaultLibrary.CurrentTheme
    elseif type(nameOrTable) == "table" and type(nameOrTable.Name) == "string" then
        DefaultLibrary.CurrentTheme = nameOrTable
    end
    -- If user provided a hook, call it
    if InterfaceManager.OnThemeChanged then
        pcall(function() InterfaceManager.OnThemeChanged(DefaultLibrary.CurrentTheme and DefaultLibrary.CurrentTheme.Name or nil, DefaultLibrary.CurrentTheme) end)
    end
end

function DefaultLibrary:ToggleAcrylic(enabled)
    InterfaceManager.Settings.Acrylic = enabled
    if InterfaceManager.OnAcrylicToggled then
        pcall(function() InterfaceManager.OnAcrylicToggled(enabled) end)
    end
end

function DefaultLibrary:ToggleTransparency(enabled)
    InterfaceManager.Settings.Transparency = enabled
    if InterfaceManager.OnTransparencyToggled then
        pcall(function() InterfaceManager.OnTransparencyToggled(enabled) end)
    end
end

-- Attach by default
InterfaceManager.Library = DefaultLibrary
InterfaceManager.Themes = Themes

-- ======================================================================
-- Public API: File/Folder management
-- ======================================================================
function InterfaceManager:SetFolder(folder)
    if type(folder) ~= "string" then return end
    self.Folder = folder
    if has_makefolder and has_isfolder then
        self:BuildFolderTree()
    end
end

function InterfaceManager:SetLibrary(library)
    if type(library) ~= "table" then return end
    self.Library = library
    if library.Themes then
        self.Themes = library.Themes
    end
end

function InterfaceManager:BuildFolderTree()
    if not has_makefolder or not has_isfolder then
        return
    end

    local paths = {}
    local parts = string.split(self.Folder, "/")
    for idx = 1, #parts do
        paths[#paths + 1] = table.concat(parts, "/", 1, idx)
    end
    table.insert(paths, self.Folder .. "/settings")

    for i = 1, #paths do
        local p = paths[i]
        if not isfolder(p) then
            makefolder(p)
        end
    end
end

function InterfaceManager:SaveSettings()
    if not has_writefile then return end
    local encoded = safeEncode(self.Settings)
    if not encoded then return end
    local ok = pcall(function()
        writefile(self.Folder .. "/options.json", encoded)
    end)
    return ok
end

function InterfaceManager:LoadSettings()
    if not has_isfile or not has_readfile then return end
    local path = self.Folder .. "/options.json"
    if not isfile(path) then return end
    local raw = readfile(path)
    local decoded = safeDecode(raw)
    if type(decoded) == "table" then
        for k, v in pairs(decoded) do
            self.Settings[k] = v
        end
    end
end

-- ======================================================================
-- Theme applying logic (tries many fallbacks)
-- ======================================================================
function InterfaceManager:ApplyTheme(name)
    if type(name) ~= "string" then return false end

    local lib = self.Library or {}
    local themeTable = nil

    -- Find theme table from library or internal Themes
    if lib.Themes and type(lib.Themes[name]) == "table" then
        themeTable = lib.Themes[name]
    elseif self.Themes and type(self.Themes[name]) == "table" then
        themeTable = self.Themes[name]
    end

    local tried = {}
    local success = false

    local function tryCall(target, fnName, arg)
        if success then return end
        if not target or type(target[fnName]) ~= "function" then return end
        local ok, err = pcall(function()
            target[fnName](target, arg)
        end)
        table.insert(tried, {target = target, fn = fnName, ok = ok, err = err})
        if ok then success = true end
    end

    -- 1) Try common library-level methods (string)
    local libFnNames_str = {"SetTheme", "SetThemeName", "ChangeTheme", "ApplyThemeName", "SetThemeByName"}
    for _, fn in ipairs(libFnNames_str) do
        tryCall(lib, fn, name)
        if success then break end
    end

    -- 2) Try library-level methods with table
    if not success and themeTable then
        local libFnNames_tab = {"SetTheme", "ApplyTheme", "UpdateTheme", "SetThemeTable", "ApplyThemeTable"}
        for _, fn in ipairs(libFnNames_tab) do
            tryCall(lib, fn, themeTable)
            if success then break end
        end
    end

    -- 3) Try window objects inside library (common patterns)
    if not success then
        local candidates = {}
        if lib.Windows and type(lib.Windows) == "table" then
            for _, w in pairs(lib.Windows) do table.insert(candidates, w) end
        end
        if lib.Window and type(lib.Window) == "table" then table.insert(candidates, lib.Window) end
        -- also scan top-level fields for Table-like windows
        for k, v in pairs(lib) do
            if type(v) == "table" and (v.SetTheme or v.ApplyTheme or v.UpdateTheme) then
                table.insert(candidates, v)
            end
        end

        for _, win in ipairs(candidates) do
            if success then break end
            local tryFns = {"SetTheme", "ApplyTheme", "SetThemeName", "UpdateTheme", "ApplyThemeTable"}
            for _, fn in ipairs(tryFns) do
                tryCall(win, fn, themeTable or name)
                if success then break end
            end
        end
    end

    -- 4) Last-resort generic attempts
    if not success then
        local fallbacks = {"ApplyTheme", "UpdateTheme", "SetColors", "ReloadTheme", "LoadTheme"}
        for _, fn in ipairs(fallbacks) do
            tryCall(lib, fn, themeTable or name)
            if success then break end
        end
    end

    -- Save settings and call hooks if success
    if success then
        self.Settings.Theme = name
        pcall(function() self:SaveSettings() end)
        if self.OnThemeChanged then
            pcall(function() self.OnThemeChanged(name, themeTable) end)
        end
    else
        -- debug output to help user understand what was tried
        warn("[InterfaceManager] ApplyTheme('" .. tostring(name) .. "') failed. Methods tried:")
        for _, t in ipairs(tried) do
            local tname = tostring(t.fn) .. " on " .. (t.target and tostring(t.target) or "nil")
            warn("  ", tname, " ok=", tostring(t.ok))
            if not t.ok and t.err then warn("     err:", tostring(t.err)) end
        end
    end

    return success
end

-- Convenience: change theme programmatically (uses ApplyTheme)
function InterfaceManager:SetTheme(name)
    if type(name) ~= "string" then return end
    local ok = self:ApplyTheme(name)
    if not ok then
        -- Still save so UI shows the selected value
        self.Settings.Theme = name
        pcall(function() self:SaveSettings() end)
        warn("[InterfaceManager] SetTheme: couldn't apply theme '"..tostring(name).."', saved as default only.")
    end
end

-- ======================================================================
-- Build interface section for a tab
-- Expects tab:AddSection, section:AddDropdown/AddToggle/AddKeybind etc.
-- ======================================================================
function InterfaceManager:BuildInterfaceSection(tab)
    assert(tab, "InterfaceManager:BuildInterfaceSection requires a tab object")

    local Library = self.Library or {}
    local Settings = self.Settings

    -- load saved settings first
    self:LoadSettings()

    -- derive theme list
    local themeValues = Themes.Names or {}
    if Library.Themes and type(Library.Themes.Names) == "table" then
        themeValues = Library.Themes.Names
    elseif Library.Themes and type(Library.Themes) == "table" then
        local names = {}
        for k, v in pairs(Library.Themes) do
            if type(k) == "string" then table.insert(names, k) end
        end
        if #names > 0 then themeValues = names end
    end

    -- create section
    local section = nil
    if tab.AddSection then
        section = tab:AddSection("Interface")
    else
        error("tab:AddSection missing - cannot build interface section")
    end

    -- Dropdown for theme selection
    if section.AddDropdown then
        local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
            Title = "Theme",
            Description = "Changes the interface theme.",
            Values = themeValues,
            Default = Settings.Theme,
            Callback = function(Value)
                -- Use InterfaceManager:SetTheme which handles fallbacks & saving
                pcall(function() self:SetTheme(Value) end)

                -- Also try calling library directly if it has a SetTheme that expects a table
                -- (keeps backward compatibility)
                if Library and type(Library.SetTheme) == "function" then
                    -- try both string and table
                    pcall(function()
                        local use = Library.Themes and Library.Themes[Value] or Settings.Theme
                        if use then
                            -- if library expects table, passing table is safe; if expects string, it might ignore
                            Library:SetTheme(use)
                        else
                            Library:SetTheme(Value)
                        end
                    end)
                end

                Settings.Theme = Value
                self:SaveSettings()
            end
        })

        if InterfaceTheme and type(InterfaceTheme.SetValue) == "function" then
            pcall(function() InterfaceTheme:SetValue(Settings.Theme) end)
        end
    else
        error("section:AddDropdown missing - cannot build theme dropdown")
    end

    -- Acrylic toggle (only add if library indicates support)
    if Library and Library.UseAcrylic and section.AddToggle then
        section:AddToggle("AcrylicToggle", {
            Title = "Acrylic",
            Description = "The blurred background requires graphic quality 8+",
            Default = Settings.Acrylic,
            Callback = function(Value)
                if Library and type(Library.ToggleAcrylic) == "function" then
                    pcall(function() Library:ToggleAcrylic(Value) end)
                end
                Settings.Acrylic = Value
                self:SaveSettings()
            end
        })
    end

    -- Transparency toggle
    if section.AddToggle then
        section:AddToggle("TransparentToggle", {
            Title = "Transparency",
            Description = "Makes the interface transparent.",
            Default = Settings.Transparency,
            Callback = function(Value)
                if Library and type(Library.ToggleTransparency) == "function" then
                    pcall(function() Library:ToggleTransparency(Value) end)
                end
                Settings.Transparency = Value
                self:SaveSettings()
            end
        })
    end

    -- Keybind for minimize (if supported)
    if section.AddKeybind then
        local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
        if MenuKeybind and type(MenuKeybind.OnChanged) == "function" then
            MenuKeybind:OnChanged(function()
                Settings.MenuKeybind = MenuKeybind.Value
                self:SaveSettings()
            end)
        end
        if Library then
            Library.MinimizeKeybind = MenuKeybind
        end
    end

    return true
end

-- expose Themes for direct access
InterfaceManager.Themes = Themes

-- allow user code to override hook callbacks:
-- InterfaceManager.OnThemeChanged = function(name, themeTable) end
-- InterfaceManager.OnAcrylicToggled = function(bool) end
-- InterfaceManager.OnTransparencyToggled = function(bool) end

return InterfaceManager
