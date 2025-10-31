-- CombinedThemesAndInterfaceManager.lua
-- Single-module pack: Themes + InterfaceManager
local HttpService = game:GetService("HttpService")

local Module = {}
Module.Themes = {
    Names = {}
}

-- helper to register a theme into Module.Themes
local function addTheme(t)
    if type(t) ~= "table" or type(t.Name) ~= "string" then return end
    Module.Themes[t.Name] = t
    table.insert(Module.Themes.Names, t.Name)
end

-- ============================================
-- Theme definitions (add or edit here)
-- ============================================

addTheme({
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
})

addTheme({
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
})

addTheme({
    Name = "Ocean",
    Accent = Color3.fromRGB(14, 116, 144),
    AcrylicMain = Color3.fromRGB(15, 23, 42),
    AcrylicBorder = Color3.fromRGB(34, 211, 238),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(14, 116, 144), Color3.fromRGB(8, 51, 68)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(14, 165, 233),
    Tab = Color3.fromRGB(125, 211, 252),
    Element = Color3.fromRGB(34, 211, 238),
    ElementBorder = Color3.fromRGB(8, 51, 68),
    InElementBorder = Color3.fromRGB(14, 116, 144),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(34, 211, 238),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(34, 211, 238),
    DropdownFrame = Color3.fromRGB(165, 243, 252),
    DropdownHolder = Color3.fromRGB(8, 51, 68),
    DropdownBorder = Color3.fromRGB(14, 116, 144),
    DropdownOption = Color3.fromRGB(34, 211, 238),
    Keybind = Color3.fromRGB(34, 211, 238),
    Input = Color3.fromRGB(34, 211, 238),
    InputFocused = Color3.fromRGB(8, 51, 68),
    InputIndicator = Color3.fromRGB(165, 243, 252),
    Dialog = Color3.fromRGB(8, 51, 68),
    DialogHolder = Color3.fromRGB(14, 116, 144),
    DialogHolderLine = Color3.fromRGB(6, 182, 212),
    DialogButton = Color3.fromRGB(14, 165, 233),
    DialogButtonBorder = Color3.fromRGB(34, 211, 238),
    DialogBorder = Color3.fromRGB(14, 116, 144),
    DialogInput = Color3.fromRGB(8, 51, 68),
    DialogInputLine = Color3.fromRGB(165, 243, 252),
    Text = Color3.fromRGB(240, 249, 255),
    SubText = Color3.fromRGB(186, 230, 253),
    Hover = Color3.fromRGB(34, 211, 238),
    HoverChange = 0.04,
})

addTheme({
    Name = "Sunset",
    Accent = Color3.fromRGB(251, 146, 60),
    AcrylicMain = Color3.fromRGB(20, 20, 20),
    AcrylicBorder = Color3.fromRGB(251, 146, 60),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(251, 146, 60), Color3.fromRGB(234, 88, 12)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(251, 146, 60),
    Tab = Color3.fromRGB(254, 215, 170),
    Element = Color3.fromRGB(251, 146, 60),
    ElementBorder = Color3.fromRGB(124, 45, 18),
    InElementBorder = Color3.fromRGB(194, 65, 12),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(251, 146, 60),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(251, 146, 60),
    DropdownFrame = Color3.fromRGB(254, 215, 170),
    DropdownHolder = Color3.fromRGB(124, 45, 18),
    DropdownBorder = Color3.fromRGB(194, 65, 12),
    DropdownOption = Color3.fromRGB(251, 146, 60),
    Keybind = Color3.fromRGB(251, 146, 60),
    Input = Color3.fromRGB(251, 146, 60),
    InputFocused = Color3.fromRGB(124, 45, 18),
    InputIndicator = Color3.fromRGB(254, 215, 170),
    Dialog = Color3.fromRGB(124, 45, 18),
    DialogHolder = Color3.fromRGB(194, 65, 12),
    DialogHolderLine = Color3.fromRGB(234, 88, 12),
    DialogButton = Color3.fromRGB(234, 88, 12),
    DialogButtonBorder = Color3.fromRGB(251, 146, 60),
    DialogBorder = Color3.fromRGB(234, 88, 12),
    DialogInput = Color3.fromRGB(194, 65, 12),
    DialogInputLine = Color3.fromRGB(254, 215, 170),
    Text = Color3.fromRGB(255, 251, 235),
    SubText = Color3.fromRGB(254, 215, 170),
    Hover = Color3.fromRGB(251, 146, 60),
    HoverChange = 0.04,
})

addTheme({
    Name = "Lavender",
    Accent = Color3.fromRGB(167, 139, 250),
    AcrylicMain = Color3.fromRGB(20, 20, 25),
    AcrylicBorder = Color3.fromRGB(196, 181, 253),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(167, 139, 250), Color3.fromRGB(109, 40, 217)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(167, 139, 250),
    Tab = Color3.fromRGB(221, 214, 254),
    Element = Color3.fromRGB(196, 181, 253),
    ElementBorder = Color3.fromRGB(55, 48, 163),
    InElementBorder = Color3.fromRGB(124, 58, 237),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(196, 181, 253),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(196, 181, 253),
    DropdownFrame = Color3.fromRGB(237, 233, 254),
    DropdownHolder = Color3.fromRGB(55, 48, 163),
    DropdownBorder = Color3.fromRGB(109, 40, 217),
    DropdownOption = Color3.fromRGB(196, 181, 253),
    Keybind = Color3.fromRGB(196, 181, 253),
    Input = Color3.fromRGB(196, 181, 253),
    InputFocused = Color3.fromRGB(55, 48, 163),
    InputIndicator = Color3.fromRGB(237, 233, 254),
    Dialog = Color3.fromRGB(55, 48, 163),
    DialogHolder = Color3.fromRGB(109, 40, 217),
    DialogHolderLine = Color3.fromRGB(124, 58, 237),
    DialogButton = Color3.fromRGB(139, 92, 246),
    DialogButtonBorder = Color3.fromRGB(196, 181, 253),
    DialogBorder = Color3.fromRGB(124, 58, 237),
    DialogInput = Color3.fromRGB(109, 40, 217),
    DialogInputLine = Color3.fromRGB(237, 233, 254),
    Text = Color3.fromRGB(250, 245, 255),
    SubText = Color3.fromRGB(221, 214, 254),
    Hover = Color3.fromRGB(196, 181, 253),
    HoverChange = 0.04,
})

addTheme({
    Name = "Mint",
    Accent = Color3.fromRGB(52, 211, 153),
    AcrylicMain = Color3.fromRGB(17, 24, 39),
    AcrylicBorder = Color3.fromRGB(110, 231, 183),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(52, 211, 153), Color3.fromRGB(16, 185, 129)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(52, 211, 153),
    Tab = Color3.fromRGB(167, 243, 208),
    Element = Color3.fromRGB(110, 231, 183),
    ElementBorder = Color3.fromRGB(6, 78, 59),
    InElementBorder = Color3.fromRGB(16, 185, 129),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(110, 231, 183),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(110, 231, 183),
    DropdownFrame = Color3.fromRGB(209, 250, 229),
    DropdownHolder = Color3.fromRGB(6, 78, 59),
    DropdownBorder = Color3.fromRGB(16, 185, 129),
    DropdownOption = Color3.fromRGB(110, 231, 183),
    Keybind = Color3.fromRGB(110, 231, 183),
    Input = Color3.fromRGB(110, 231, 183),
    InputFocused = Color3.fromRGB(6, 78, 59),
    InputIndicator = Color3.fromRGB(209, 250, 229),
    Dialog = Color3.fromRGB(6, 78, 59),
    DialogHolder = Color3.fromRGB(16, 185, 129),
    DialogHolderLine = Color3.fromRGB(52, 211, 153),
    DialogButton = Color3.fromRGB(52, 211, 153),
    DialogButtonBorder = Color3.fromRGB(110, 231, 183),
    DialogBorder = Color3.fromRGB(16, 185, 129),
    DialogInput = Color3.fromRGB(6, 95, 70),
    DialogInputLine = Color3.fromRGB(209, 250, 229),
    Text = Color3.fromRGB(236, 253, 245),
    SubText = Color3.fromRGB(167, 243, 208),
    Hover = Color3.fromRGB(110, 231, 183),
    HoverChange = 0.04,
})

addTheme({
    Name = "Coral",
    Accent = Color3.fromRGB(251, 113, 133),
    AcrylicMain = Color3.fromRGB(24, 20, 25),
    AcrylicBorder = Color3.fromRGB(251, 113, 133),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(251, 113, 133), Color3.fromRGB(244, 63, 94)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(251, 113, 133),
    Tab = Color3.fromRGB(253, 164, 175),
    Element = Color3.fromRGB(251, 113, 133),
    ElementBorder = Color3.fromRGB(136, 19, 55),
    InElementBorder = Color3.fromRGB(225, 29, 72),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(251, 113, 133),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(251, 113, 133),
    DropdownFrame = Color3.fromRGB(254, 205, 211),
    DropdownHolder = Color3.fromRGB(136, 19, 55),
    DropdownBorder = Color3.fromRGB(225, 29, 72),
    DropdownOption = Color3.fromRGB(251, 113, 133),
    Keybind = Color3.fromRGB(251, 113, 133),
    Input = Color3.fromRGB(251, 113, 133),
    InputFocused = Color3.fromRGB(136, 19, 55),
    InputIndicator = Color3.fromRGB(254, 205, 211),
    Dialog = Color3.fromRGB(136, 19, 55),
    DialogHolder = Color3.fromRGB(225, 29, 72),
    DialogHolderLine = Color3.fromRGB(244, 63, 94),
    DialogButton = Color3.fromRGB(244, 63, 94),
    DialogButtonBorder = Color3.fromRGB(251, 113, 133),
    DialogBorder = Color3.fromRGB(225, 29, 72),
    DialogInput = Color3.fromRGB(190, 18, 60),
    DialogInputLine = Color3.fromRGB(254, 205, 211),
    Text = Color3.fromRGB(255, 241, 242),
    SubText = Color3.fromRGB(254, 205, 211),
    Hover = Color3.fromRGB(251, 113, 133),
    HoverChange = 0.04,
})

addTheme({
    Name = "Gold",
    Accent = Color3.fromRGB(245, 158, 11),
    AcrylicMain = Color3.fromRGB(20, 20, 18),
    AcrylicBorder = Color3.fromRGB(251, 191, 36),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(245, 158, 11), Color3.fromRGB(180, 83, 9)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(245, 158, 11),
    Tab = Color3.fromRGB(253, 224, 71),
    Element = Color3.fromRGB(251, 191, 36),
    ElementBorder = Color3.fromRGB(120, 53, 15),
    InElementBorder = Color3.fromRGB(217, 119, 6),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(251, 191, 36),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(251, 191, 36),
    DropdownFrame = Color3.fromRGB(254, 240, 138),
    DropdownHolder = Color3.fromRGB(120, 53, 15),
    DropdownBorder = Color3.fromRGB(180, 83, 9),
    DropdownOption = Color3.fromRGB(251, 191, 36),
    Keybind = Color3.fromRGB(251, 191, 36),
    Input = Color3.fromRGB(251, 191, 36),
    InputFocused = Color3.fromRGB(120, 53, 15),
    InputIndicator = Color3.fromRGB(254, 240, 138),
    Dialog = Color3.fromRGB(120, 53, 15),
    DialogHolder = Color3.fromRGB(180, 83, 9),
    DialogHolderLine = Color3.fromRGB(217, 119, 6),
    DialogButton = Color3.fromRGB(245, 158, 11),
    DialogButtonBorder = Color3.fromRGB(251, 191, 36),
    DialogBorder = Color3.fromRGB(217, 119, 6),
    DialogInput = Color3.fromRGB(180, 83, 9),
    DialogInputLine = Color3.fromRGB(254, 240, 138),
    Text = Color3.fromRGB(254, 252, 232),
    SubText = Color3.fromRGB(253, 230, 138),
    Hover = Color3.fromRGB(251, 191, 36),
    HoverChange = 0.04,
})

addTheme({
    Name = "Midnight",
    Accent = Color3.fromRGB(99, 102, 241),
    AcrylicMain = Color3.fromRGB(15, 23, 42),
    AcrylicBorder = Color3.fromRGB(129, 140, 248),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(99, 102, 241), Color3.fromRGB(67, 56, 202)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(99, 102, 241),
    Tab = Color3.fromRGB(165, 180, 252),
    Element = Color3.fromRGB(129, 140, 248),
    ElementBorder = Color3.fromRGB(30, 27, 75),
    InElementBorder = Color3.fromRGB(67, 56, 202),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(129, 140, 248),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(129, 140, 248),
    DropdownFrame = Color3.fromRGB(199, 210, 254),
    DropdownHolder = Color3.fromRGB(30, 27, 75),
    DropdownBorder = Color3.fromRGB(67, 56, 202),
    DropdownOption = Color3.fromRGB(129, 140, 248),
    Keybind = Color3.fromRGB(129, 140, 248),
    Input = Color3.fromRGB(129, 140, 248),
    InputFocused = Color3.fromRGB(30, 27, 75),
    InputIndicator = Color3.fromRGB(199, 210, 254),
    Dialog = Color3.fromRGB(30, 27, 75),
    DialogHolder = Color3.fromRGB(67, 56, 202),
    DialogHolderLine = Color3.fromRGB(79, 70, 229),
    DialogButton = Color3.fromRGB(99, 102, 241),
    DialogButtonBorder = Color3.fromRGB(129, 140, 248),
    DialogBorder = Color3.fromRGB(67, 56, 202),
    DialogInput = Color3.fromRGB(49, 46, 129),
    DialogInputLine = Color3.fromRGB(199, 210, 254),
    Text = Color3.fromRGB(238, 242, 255),
    SubText = Color3.fromRGB(199, 210, 254),
    Hover = Color3.fromRGB(129, 140, 248),
    HoverChange = 0.04,
})

addTheme({
    Name = "Forest",
    Accent = Color3.fromRGB(34, 197, 94),
    AcrylicMain = Color3.fromRGB(20, 25, 20),
    AcrylicBorder = Color3.fromRGB(74, 222, 128),
    AcrylicGradient = ColorSequence.new(Color3.fromRGB(34, 197, 94), Color3.fromRGB(21, 128, 61)),
    AcrylicNoise = 0.92,
    TitleBarLine = Color3.fromRGB(34, 197, 94),
    Tab = Color3.fromRGB(134, 239, 172),
    Element = Color3.fromRGB(74, 222, 128),
    ElementBorder = Color3.fromRGB(20, 83, 45),
    InElementBorder = Color3.fromRGB(22, 163, 74),
    ElementTransparency = 0.87,
    ToggleSlider = Color3.fromRGB(74, 222, 128),
    ToggleToggled = Color3.fromRGB(0, 0, 0),
    SliderRail = Color3.fromRGB(74, 222, 128),
    DropdownFrame = Color3.fromRGB(187, 247, 208),
    DropdownHolder = Color3.fromRGB(20, 83, 45),
    DropdownBorder = Color3.fromRGB(21, 128, 61),
    DropdownOption = Color3.fromRGB(74, 222, 128),
    Keybind = Color3.fromRGB(74, 222, 128),
    Input = Color3.fromRGB(74, 222, 128),
    InputFocused = Color3.fromRGB(20, 83, 45),
    InputIndicator = Color3.fromRGB(187, 247, 208),
    Dialog = Color3.fromRGB(20, 83, 45),
    DialogHolder = Color3.fromRGB(21, 128, 61),
    DialogHolderLine = Color3.fromRGB(22, 163, 74),
    DialogButton = Color3.fromRGB(34, 197, 94),
    DialogButtonBorder = Color3.fromRGB(74, 222, 128),
    DialogBorder = Color3.fromRGB(22, 163, 74),
    DialogInput = Color3.fromRGB(21, 128, 61),
    DialogInputLine = Color3.fromRGB(187, 247, 208),
    Text = Color3.fromRGB(240, 253, 244),
    SubText = Color3.fromRGB(187, 247, 208),
    Hover = Color3.fromRGB(74, 222, 128),
    HoverChange = 0.04,
})

-- ============================================
-- InterfaceManager
-- ============================================
local InterfaceManager = {}
InterfaceManager.Folder = "FluentSettings"
InterfaceManager.Settings = {
    Theme = "Dark",
    Acrylic = true,
    Transparency = true,
    MenuKeybind = "LeftControl"
}

-- safe checks for file API (exploit environment may vary)
local has_isfile = type(isfile) == "function"
local has_readfile = type(readfile) == "function"
local has_writefile = type(writefile) == "function"
local has_makefolder = type(makefolder) == "function"
local has_isfolder = type(isfolder) == "function"

function InterfaceManager:SetFolder(folder)
    self.Folder = folder or self.Folder
    self:BuildFolderTree()
end

function InterfaceManager:SetLibrary(library)
    self.Library = library
end

function InterfaceManager:BuildFolderTree()
    if not has_makefolder or not has_isfolder then
        -- cannot create folders in this environment; skip safely
        return
    end

    local paths = {}
    local parts = string.split(self.Folder, "/")
    for idx = 1, #parts do
        paths[#paths + 1] = table.concat(parts, "/", 1, idx)
    end

    table.insert(paths, self.Folder .. "/settings")

    for i = 1, #paths do
        local str = paths[i]
        if not isfolder(str) then
            makefolder(str)
        end
    end
end

function InterfaceManager:SaveSettings()
    if not has_writefile then
        return
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(self.Settings)
    end)
    if ok and type(encoded) == "string" then
        pcall(function()
            writefile(self.Folder .. "/options.json", encoded)
        end)
    end
end

function InterfaceManager:LoadSettings()
    if not has_isfile or not has_readfile then
        return
    end

    local path = self.Folder .. "/options.json"
    if isfile(path) then
        local raw = readfile(path)
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                self.Settings[k] = v
            end
        end
    end
end

-- BuildInterfaceSection expects a 'tab' object with AddSection / AddDropdown / AddToggle / AddKeybind methods
-- and a Library object that can SetTheme / ToggleAcrylic / ToggleTransparency etc.
function InterfaceManager:BuildInterfaceSection(tab)
    assert(tab, "BuildInterfaceSection(tab) requires a tab object")

    local Library = self.Library or {}
    local Settings = self.Settings

    -- fallback to module Themes if library doesn't provide a themes list
    local themeValues = {}
    if Library.Themes and type(Library.Themes.Names) == "table" then
        themeValues = Library.Themes.Names
    else
        themeValues = Module.Themes.Names
    end

    self:LoadSettings()

    local section = tab:AddSection and tab:AddSection("Interface") or error("tab:AddSection missing")

    local InterfaceTheme = section:AddDropdown and section:AddDropdown("InterfaceTheme", {
        Title = "Theme",
        Description = "Changes the interface theme.",
        Values = themeValues,
        Default = Settings.Theme,
        Callback = function(Value)
            if Library.SetTheme then
                Library:SetTheme(Value)
            end
            Settings.Theme = Value
            self:SaveSettings()
        end
    }) or error("section:AddDropdown missing")

    -- set initial value if dropdown supports SetValue
    if InterfaceTheme and InterfaceTheme.SetValue then
        InterfaceTheme:SetValue(Settings.Theme)
    end

    if Library.UseAcrylic then
        section:AddToggle("AcrylicToggle", {
            Title = "Acrylic",
            Description = "The blurred background requires graphic quality 8+",
            Default = Settings.Acrylic,
            Callback = function(Value)
                if Library.ToggleAcrylic then
                    Library:ToggleAcrylic(Value)
                end
                Settings.Acrylic = Value
                self:SaveSettings()
            end
        })
    end

    section:AddToggle("TransparentToggle", {
        Title = "Transparency",
        Description = "Makes the interface transparent.",
        Default = Settings.Transparency,
        Callback = function(Value)
            if Library.ToggleTransparency then
                Library:ToggleTransparency(Value)
            end
            Settings.Transparency = Value
            self:SaveSettings()
        end
    })

    local MenuKeybind = section:AddKeybind and section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
    if MenuKeybind and MenuKeybind.OnChanged then
        MenuKeybind:OnChanged(function()
            Settings.MenuKeybind = MenuKeybind.Value
            self:SaveSettings()
        end)
        if Library then
            Library.MinimizeKeybind = MenuKeybind
        end
    end
end

InterfaceManager.SetTheme = function(self, name)
    -- convenience: set theme from module if available
    if Module.Themes[name] then
        self.Settings.Theme = name
        self:SaveSettings()
        if self.Library and self.Library.SetTheme then
            self.Library:SetTheme(name)
        end
    end
end

-- expose InterfaceManager on Module
Module.InterfaceManager = InterfaceManager

-- convenience API: get theme data
function Module:GetTheme(name)
    return self.Themes[name]
end

function Module:GetThemeNames()
    return self.Themes.Names
end

-- convenience: add runtime theme
function Module:RegisterTheme(themeTable)
    addTheme(themeTable)
end

-- final return
return Module
