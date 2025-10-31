-- Combined InterfaceManager + Themes (single module)
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

-- Internal helpers
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
-- Themes table (embedded themes + auto-load from script children)
-- ======================================================================
local Themes = {}
Themes.Names = {
    "Dark","Darker","Light","Aqua","Amethyst","Rose","Emerald","Crimson",
    "Ocean","Sunset","Lavender","Mint","Coral","Gold","Midnight","Forest",
}

-- (Built-in theme examples)
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

-- (other built-in themes omitted here for brevity in this snippet; 
--  include the rest exactly as in your working file)

-- Auto-load child modules as themes (like your snippet):
if type(script) == "table" and type(script.GetChildren) == "function" then
    for _, child in next, script:GetChildren() do
        -- try to require; pcall so a bad child won't crash the module
        local ok, required = pcall(function() return require(child) end)
        if ok and type(required) == "table" and type(required.Name) == "string" then
            Themes[required.Name] = required
            -- add name if not already in Names
            local exists = false
            for _, n in ipairs(Themes.Names) do
                if n == required.Name then
                    exists = true
                    break
                end
            end
            if not exists then
                table.insert(Themes.Names, required.Name)
            end
        end
    end
end

-- ======================================================================
-- Minimal "Library" wrapper so InterfaceManager can call library methods directly
-- ======================================================================
local DefaultLibrary = {}
DefaultLibrary.Themes = Themes
DefaultLibrary.CurrentTheme = Themes[InterfaceManager.Settings.Theme] or nil

function DefaultLibrary:SetTheme(name)
    if type(name) ~= "string" then return end
    InterfaceManager.Settings.Theme = name
    DefaultLibrary.CurrentTheme = Themes[name] or DefaultLibrary.CurrentTheme
    if InterfaceManager.OnThemeChanged then
        pcall(function() InterfaceManager.OnThemeChanged(name, DefaultLibrary.CurrentTheme) end)
    end
end

function DefaultLibrary:ToggleAcrylic(enabled)
    if type(enabled) ~= "boolean" then return end
    InterfaceManager.Settings.Acrylic = enabled
    if InterfaceManager.OnAcrylicToggled then
        pcall(function() InterfaceManager.OnAcrylicToggled(enabled) end)
    end
end

function DefaultLibrary:ToggleTransparency(enabled)
    if type(enabled) ~= "boolean" then return end
    InterfaceManager.Settings.Transparency = enabled
    if InterfaceManager.OnTransparencyToggled then
        pcall(function() InterfaceManager.OnTransparencyToggled(enabled) end)
    end
end

DefaultLibrary.MinimizeKeybind = nil

-- Attach library into InterfaceManager by default
InterfaceManager.Library = DefaultLibrary
InterfaceManager.Themes = Themes

-- Public API -------------------------------------------------------------------
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

function InterfaceManager:SetTheme(name)
    if type(name) ~= "string" then return end
    self.Settings.Theme = name
    self:SaveSettings()
    if self.Library and type(self.Library.SetTheme) == "function" then
        pcall(function() self.Library:SetTheme(name) end)
    end
end

function InterfaceManager:BuildInterfaceSection(tab)
    assert(tab, "InterfaceManager:BuildInterfaceSection requires a tab object")

    local Library = self.Library or {}
    local Settings = self.Settings

    self:LoadSettings()

    local themeValues = Themes.Names or {}
    if Library.Themes and type(Library.Themes.Names) == "table" then
        themeValues = Library.Themes.Names
    elseif Library.Themes and type(Library.Themes) == "table" then
        local names = {}
        for k, v in pairs(Library.Themes) do
            if type(k) == "string" then
                table.insert(names, k)
            end
        end
        if #names > 0 then themeValues = names end
    end

    local section = nil
    if tab.AddSection then
        section = tab:AddSection("Interface")
    else
        error("tab:AddSection missing - cannot build interface section")
    end

    if section.AddDropdown then
        local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
            Title = "Theme",
            Description = "Changes the interface theme.",
            Values = themeValues,
            Default = Settings.Theme,
            Callback = function(Value)
                if Library and type(Library.SetTheme) == "function" then
                    pcall(function() Library:SetTheme(Value) end)
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

-- Return InterfaceManager as module (themes accessible at InterfaceManager.Themes)
return InterfaceManager
