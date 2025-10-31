local HttpService = game:GetService("HttpService")

local InterfaceManager = {}
InterfaceManager.Folder = "FluentSettings"
InterfaceManager.Settings = {
    Theme = "Dark",
    Acrylic = true,
    Transparency = true,
    MenuKeybind = "LeftControl"
}

-- File API detection (exploit environments vary) --------------------------------
local has_isfile = type(isfile) == "function"
local has_readfile = type(readfile) == "function"
local has_writefile = type(writefile) == "function"
local has_makefolder = type(makefolder) == "function"
local has_isfolder = type(isfolder) == "function"

-- Internal helpers --------------------------------------------------------------
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

-- Fallback theme names (used if Fluent library doesn't provide Themes)
local FALLBACK_THEME_NAMES = {
    "Dark","Darker","Light","Aqua","Amethyst","Rose","Emerald","Crimson",
    "Ocean","Sunset","Lavender","Mint","Coral","Gold","Midnight","Forest"
}

-- Public API -------------------------------------------------------------------
function InterfaceManager:SetFolder(folder)
    if type(folder) ~= "string" then return end
    self.Folder = folder
    -- try to build folder tree if possible
    if has_makefolder and has_isfolder then
        self:BuildFolderTree()
    end
end

function InterfaceManager:SetLibrary(library)
    self.Library = library
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

-- Convenience: change theme programmatically
function InterfaceManager:SetTheme(name)
    if type(name) ~= "string" then return end
    self.Settings.Theme = name
    self:SaveSettings()
    if self.Library and type(self.Library.SetTheme) == "function" then
        pcall(function() self.Library:SetTheme(name) end)
    end
end

-- BuildInterfaceSection:
-- Expects 'tab' object with AddSection function and section with AddDropdown / AddToggle / AddKeybind methods.
-- The function will attempt to use Library.Themes.Names if available, otherwise fallback list.
function InterfaceManager:BuildInterfaceSection(tab)
    assert(tab, "InterfaceManager:BuildInterfaceSection requires a tab object")

    local Library = self.Library or {}
    local Settings = self.Settings

    self:LoadSettings()

    -- derive theme list from library if available
    local themeValues = FALLBACK_THEME_NAMES
    if Library.Themes and type(Library.Themes.Names) == "table" then
        themeValues = Library.Themes.Names
    elseif Library.Themes and type(Library.Themes) == "table" then
        -- maybe it's keyed by name; build a names list
        local names = {}
        for k, v in pairs(Library.Themes) do
            if type(k) == "string" then
                table.insert(names, k)
            end
        end
        if #names > 0 then themeValues = names end
    end

    -- Create Interface section
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
                -- call library set theme if present
                if Library and type(Library.SetTheme) == "function" then
                    pcall(function() Library:SetTheme(Value) end)
                end
                Settings.Theme = Value
                self:SaveSettings()
            end
        })

        -- Set initial value if supported
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

    -- Keybind for minimize (if tab supports AddKeybind)
    if section.AddKeybind then
        local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
        if MenuKeybind and type(MenuKeybind.OnChanged) == "function" then
            MenuKeybind:OnChanged(function()
                Settings.MenuKeybind = MenuKeybind.Value
                self:SaveSettings()
            end)
        end
        -- expose for library usage
        if Library then
            Library.MinimizeKeybind = MenuKeybind
        end
    end

    return true
end

-- Return module
return InterfaceManager
