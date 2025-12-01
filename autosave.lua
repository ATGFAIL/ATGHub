---@diagnostic disable: undefined-global
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local UserId = tostring(LocalPlayer.UserId)

-- ==================== STREAMER MODE SYSTEM ====================
local StreamerMode = {}

-- [[ Config ]]
StreamerMode.ReplaceText = "Protected By ATG Hub"
StreamerMode.ReplaceImage = "rbxassetid://90989180960460"
StreamerMode.ReplaceExact = false

local StringProperties = {"Text", "PlaceholderText", "Value", "Title", "ToolTip", "Description"}

-- [[ Systems ]]
StreamerMode.OriginalValues = {} -- Store original values: { [Instance] = { [Property] = "OldValue" } }
StreamerMode.WatchedObjects = {} -- Store objects being locked
StreamerMode.Connections = {} -- Store events for disconnection
StreamerMode.Targets = {}

-- Helper function to find targets
local function GetTargets()
    local t = {}
    if LocalPlayer then
        if LocalPlayer.Name and LocalPlayer.Name ~= "" then table.insert(t, LocalPlayer.Name) end
        if LocalPlayer.DisplayName and LocalPlayer.DisplayName ~= "" then table.insert(t, LocalPlayer.DisplayName) end
    end
    return t
end

-- Case-insensitive replace function
local function CI_Replace(s, target, repl)
    if type(s) ~= "string" then return s end
    local lower_s = s:lower()
    local lower_t = target:lower()
    local res = ""
    local i = 1
    while true do
        local startPos, endPos = lower_s:find(lower_t, i, true)
        if not startPos then
            res = res .. s:sub(i)
            break
        end
        res = res .. s:sub(i, startPos - 1) .. repl
        i = endPos + 1
    end
    return res
end

local function StringContains(s, target)
    if type(s) ~= "string" then return false end
    return s:lower():find(target:lower(), 1, true) ~= nil
end

-- Backup original value
local function StoreOriginal(inst, prop, value)
    if not StreamerMode.OriginalValues[inst] then
        StreamerMode.OriginalValues[inst] = {}
    end
    -- Only save the first time to preserve the true original value
    if StreamerMode.OriginalValues[inst][prop] == nil then
        StreamerMode.OriginalValues[inst][prop] = value
    end
end

-- Check and replace core logic
local function CheckAndReplaceCore(inst)
    if not inst then return end
    local foundMatch = false

    -- 1. Handle images
    if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
        if inst.Image and inst.Image ~= StreamerMode.ReplaceImage then
            if string.find(inst.Image, UserId) then
                -- Backup original value
                StoreOriginal(inst, "Image", inst.Image)
                -- Replace value
                pcall(function() inst.Image = StreamerMode.ReplaceImage end)
                foundMatch = true
            end
        end
    end

    -- 2. Handle text
    for _, prop in ipairs(StringProperties) do
        local success, val = pcall(function() return inst[prop] end)
        if success and type(val) == "string" and val ~= "" and val ~= StreamerMode.ReplaceText then
            for _, target in ipairs(StreamerMode.Targets) do
                if StringContains(val, target) then
                    -- Backup original value
                    StoreOriginal(inst, prop, val)
                    
                    -- Calculate new value
                    local newVal
                    if StreamerMode.ReplaceExact then
                        newVal = StreamerMode.ReplaceText
                    else
                        newVal = CI_Replace(val, target, StreamerMode.ReplaceText)
                    end
                    
                    -- Replace value
                    pcall(function() inst[prop] = newVal end)
                    foundMatch = true
                end
            end
        end
    end

    if foundMatch then
        StreamerMode.WatchedObjects[inst] = true
    end
end

-- Toggle character GUI visibility
local function ToggleCharacterGui(char, visible)
    if not char then return end
    -- Wait a moment for new character to load
    if visible == false then task.wait(0.5) end
    
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
            if visible == false then
                -- Hide (backup enabled state)
                StoreOriginal(v, "Enabled", v.Enabled)
                v.Enabled = false
            else
                -- Restore (use backup if available, otherwise enable)
                if StreamerMode.OriginalValues[v] and StreamerMode.OriginalValues[v]["Enabled"] ~= nil then
                    v.Enabled = StreamerMode.OriginalValues[v]["Enabled"]
                else
                    v.Enabled = true
                end
            end
        end
    end
end

-- Start protection
function StreamerMode:Start()
    self.Targets = GetTargets()
    
    -- 1. Handle character (hide GUI)
    if LocalPlayer.Character then
        task.spawn(function() ToggleCharacterGui(LocalPlayer.Character, false) end)
    end
    self.Connections["CharAdded"] = LocalPlayer.CharacterAdded:Connect(function(char)
        task.spawn(function() ToggleCharacterGui(char, false) end)
    end)
    
    self.Connections["DisplayName"] = LocalPlayer:GetPropertyChangedSignal("DisplayName"):Connect(function()
        self.Targets = GetTargets()
    end)

    -- 2. Scan existing CoreGui
    for _, desc in ipairs(CoreGui:GetDescendants()) do
        CheckAndReplaceCore(desc)
    end

    -- 3. Detect new CoreGui elements
    self.Connections["CoreAdded"] = CoreGui.DescendantAdded:Connect(function(desc)
        task.delay(0.1, function() CheckAndReplaceCore(desc) end)
    end)

    -- 4. Heartbeat loop (lock values)
    self.Connections["Heartbeat"] = RunService.Heartbeat:Connect(function()
        for inst, _ in pairs(self.WatchedObjects) do
            if inst and inst.Parent then
                CheckAndReplaceCore(inst)
            else
                self.WatchedObjects[inst] = nil
            end
        end
    end)
end

-- Stop protection and restore
function StreamerMode:Stop()
    -- 1. Disconnect all connections
    for _, conn in pairs(self.Connections) do
        conn:Disconnect()
    end
    self.Connections = {}
    self.WatchedObjects = {}

    -- 2. Restore original values to all modified objects
    for inst, props in pairs(self.OriginalValues) do
        if inst and inst.Parent then
            for propName, originalVal in pairs(props) do
                pcall(function()
                    inst[propName] = originalVal
                end)
            end
        end
    end
    
    -- 3. Clear backup table
    self.OriginalValues = {}
    
    -- 4. Show character GUI again
    if LocalPlayer.Character then
        ToggleCharacterGui(LocalPlayer.Character, true)
    end
end

-- ==================== SAVE MANAGER SYSTEM ====================
local SaveManager = {}

SaveManager.FolderRoot = "ATGSettings"
SaveManager.Ignore = {}
SaveManager.Options = {}
SaveManager.AutoSaveEnabled = false
SaveManager.AutoSaveConfig = nil
SaveManager.AutoSaveDebounce = false
SaveManager.OriginalCallbacks = {}
SaveManager.Parser = {
    Toggle = {
        Save = function(idx, object) 
            return { type = "Toggle", idx = idx, value = object.Value } 
        end,
        Load = function(idx, data)
            if SaveManager.Options[idx] then 
                SaveManager.Options[idx]:SetValue(data.value)
            end
        end,
    },
    Slider = {
        Save = function(idx, object)
            return { type = "Slider", idx = idx, value = tostring(object.Value) }
        end,
        Load = function(idx, data)
            if SaveManager.Options[idx] then 
                SaveManager.Options[idx]:SetValue(data.value)
            end
        end,
    },
    Dropdown = {
        Save = function(idx, object)
            return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi }
        end,
        Load = function(idx, data)
            if SaveManager.Options[idx] then
                SaveManager.Options[idx]:SetValue(data.value)
            end
        end,
    },
    Colorpicker = {
        Save = function(idx, object)
            return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
        end,
        Load = function(idx, data)
            if SaveManager.Options[idx] then 
                SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
            end
        end,
    },
    Keybind = {
        Save = function(idx, object)
            return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Options[idx] then 
                SaveManager.Options[idx]:SetValue(data.key, data.mode)
            end
        end,
    },
    Input = {
        Save = function(idx, object)
            return { type = "Input", idx = idx, text = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Options[idx] and type(data.text) == "string" then
                SaveManager.Options[idx]:SetValue(data.text)
            end
        end,
    },
}

-- Helper functions
local function sanitizeFilename(name)
    name = tostring(name or "")
    name = name:gsub("%s+", "_")
    name = name:gsub("[^%w%-%_]", "")
    if name == "" then return "Unknown" end
    return name
end

local function getPlaceId()
    local ok, id = pcall(function() return tostring(game.PlaceId) end)
    if ok and id then return id end
    return "UnknownPlace"
end

local function ensureFolder(path)
    if not isfolder(path) then
        makefolder(path)
    end
end

local function getConfigsFolder(self)
    local root = self.FolderRoot
    local placeId = getPlaceId()
    return root .. "/" .. placeId
end

local function getConfigFilePath(self, name)
    local folder = getConfigsFolder(self)
    return folder .. "/" .. name .. ".json"
end

local function getSaveManagerUIPath(self)
    local folder = getConfigsFolder(self)
    return folder .. "/savemanager_ui.json"
end

function SaveManager:BuildFolderTree()
    local root = self.FolderRoot
    ensureFolder(root)

    local placeId = getPlaceId()
    local placeFolder = root .. "/" .. placeId
    ensureFolder(placeFolder)

    -- Migrate legacy configs
    local legacySettingsFolder = root .. "/settings"
    if isfolder(legacySettingsFolder) then
        local files = listfiles(legacySettingsFolder)
        for i = 1, #files do
            local f = files[i]
            if f:sub(-5) == ".json" then
                local base = f:match("([^/\\]+)%.json$")
                if base and base ~= "options" then
                    local dest = placeFolder .. "/" .. base .. ".json"
                    if not isfile(dest) then
                        local ok, data = pcall(readfile, f)
                        if ok and data then
                            pcall(writefile, dest, data)
                        end
                    end
                end
            end
        end

        local autopath = legacySettingsFolder .. "/autoload.txt"
        if isfile(autopath) then
            local autodata = readfile(autopath)
            local destAuto = placeFolder .. "/autoload.txt"
            if not isfile(destAuto) then
                pcall(writefile, destAuto, autodata)
            end
        end
    end
end

function SaveManager:SetIgnoreIndexes(list)
    for _, key in next, list do
        self.Ignore[key] = true
    end
end

function SaveManager:SetFolder(folder)
    self.FolderRoot = tostring(folder or "ATGSettings")
    self:BuildFolderTree()
end

function SaveManager:SetLibrary(library)
    self.Library = library
    self.Options = library.Options
end

function SaveManager:Save(name)
    if (not name) then
        return false, "no config file is selected"
    end

    local fullPath = getConfigFilePath(self, name)
    local data = { objects = {} }

    for idx, option in next, SaveManager.Options do
        if not self.Parser[option.Type] then continue end
        if self.Ignore[idx] then continue end
        table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
    end

    local success, encoded = pcall(httpService.JSONEncode, httpService, data)
    if not success then
        return false, "failed to encode data"
    end

    local folder = fullPath:match("^(.*)/[^/]+$")
    if folder then ensureFolder(folder) end

    writefile(fullPath, encoded)
    return true
end

function SaveManager:SaveUI()
    local uiPath = getSaveManagerUIPath(self)
    local uiData = {
        autoload_enabled = (self:GetAutoloadConfig() ~= nil),
        autoload_config = (self:GetAutoloadConfig() or nil),
        autosave_enabled = self.AutoSaveEnabled,
        autosave_config = self.AutoSaveConfig
    }

    local success, encoded = pcall(httpService.JSONEncode, httpService, uiData)
    if success then
        local folder = uiPath:match("^(.*)/[^/]+$")
        if folder then ensureFolder(folder) end
        writefile(uiPath, encoded)
    end
end

function SaveManager:LoadUI()
    local uiPath = getSaveManagerUIPath(self)
    if not isfile(uiPath) then return nil end

    local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(uiPath))
    if success then
        return decoded
    end
    return nil
end

function SaveManager:Load(name)
    if (not name) then
        return false, "no config file is selected"
    end

    local file = getConfigFilePath(self, name)
    if not isfile(file) then return false, "invalid file" end

    local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
    if not success then return false, "decode error" end

    for _, option in next, decoded.objects do
        if self.Parser[option.type] then
            task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
        end
    end

    return true
end

function SaveManager:Delete(name)
    if not name then
        return false, "no config file is selected"
    end

    local file = getConfigFilePath(self, name)
    if not isfile(file) then 
        return false, "config does not exist" 
    end

    delfile(file)
    
    local autopath = getConfigsFolder(self) .. "/autoload.txt"
    if isfile(autopath) then
        local currentAutoload = readfile(autopath)
        if currentAutoload == name then
            delfile(autopath)
        end
    end
    
    return true
end

function SaveManager:GetAutoloadConfig()
    local autopath = getConfigsFolder(self) .. "/autoload.txt"
    if isfile(autopath) then
        return readfile(autopath)
    end
    return nil
end

function SaveManager:SetAutoloadConfig(name)
    if not name then
        return false, "no config name provided"
    end
    
    local file = getConfigFilePath(self, name)
    if not isfile(file) then
        return false, "config does not exist"
    end
    
    local autopath = getConfigsFolder(self) .. "/autoload.txt"
    writefile(autopath, name)
    self:SaveUI()
    return true
end

function SaveManager:DisableAutoload()
    local autopath = getConfigsFolder(self) .. "/autoload.txt"
    if isfile(autopath) then
        delfile(autopath)
        self:SaveUI()
        return true
    end
    return false, "no autoload config set"
end

function SaveManager:IgnoreThemeSettings()
    self:SetIgnoreIndexes({
        "InterfaceTheme", "AcrylicToggle", "TransparentToggle", "MenuKeybind"
    })
end

function SaveManager:RefreshConfigList()
    local folder = getConfigsFolder(self)
    if not isfolder(folder) then
        return {}
    end
    local list = listfiles(folder)
    local out = {}
    for i = 1, #list do
        local file = list[i]
        if file:sub(-5) == ".json" then
            local name = file:match("([^/\\]+)%.json$")
            if name and name ~= "options" and name ~= "autoload" and name ~= "savemanager_ui" then
                table.insert(out, name)
            end
        end
    end
    return out
end

function SaveManager:LoadAutoloadConfig()
    local name = self:GetAutoloadConfig()
    if name then
        self:Load(name)
    end
end

function SaveManager:EnableAutoSave(configName)
    self.AutoSaveEnabled = true
    self.AutoSaveConfig = configName
    self:SaveUI()

    for idx, option in next, self.Options do
        if not self.Ignore[idx] and self.Parser[option.Type] then
            if not self.OriginalCallbacks[idx] then
                self.OriginalCallbacks[idx] = option.Callback
            end

            local originalCallback = self.OriginalCallbacks[idx]
            option.Callback = function(...)
                if option._isInCallback then
                    return
                end

                option._isInCallback = true

                if originalCallback then
                    local success, err = pcall(originalCallback, ...)
                    if not success then
                        warn("Callback error for " .. tostring(idx) .. ": " .. tostring(err))
                    end
                end

                option._isInCallback = false

                if self.AutoSaveEnabled and self.AutoSaveConfig and not self.AutoSaveDebounce then
                    self.AutoSaveDebounce = true
                    task.spawn(function()
                        task.wait(1)
                        if self.AutoSaveEnabled and self.AutoSaveConfig then
                            self:Save(self.AutoSaveConfig)
                        end
                        self.AutoSaveDebounce = false
                    end)
                end
            end
        end
    end
end

function SaveManager:DisableAutoSave()
    self.AutoSaveEnabled = false
    self.AutoSaveConfig = nil
    self:SaveUI()
    
    for idx, option in next, self.Options do
        if self.OriginalCallbacks[idx] then
            option.Callback = self.OriginalCallbacks[idx]
        end
    end
end

function SaveManager:BuildConfigSection(tab)
    assert(self.Library, "Must set SaveManager.Library")

    local section = tab:AddSection("[ 📁 ] Configuration Manager")

    local uiSettings = self:LoadUI()

    local fixedConfigName = "AutoSave"
    if not isfile(getConfigFilePath(self, fixedConfigName)) then
        pcall(function() self:Save(fixedConfigName) end)
    end

    local currentAutoload = self:GetAutoloadConfig()
    local autoloadDesc = currentAutoload and ('Current: "' .. currentAutoload .. '"') or 'Will load "AutoSave.json" automatically on startup'
    
    local AutoloadToggle = section:AddToggle("SaveManager_AutoloadToggle", {
        Title = "Auto Load",
        Description = autoloadDesc,
        Default = (uiSettings and uiSettings.autoload_enabled) or false,
        Callback = function(value)
            if value then
                if not isfile(getConfigFilePath(self, fixedConfigName)) then
                    self:Save(fixedConfigName)
                end

                local ok, err = self:SetAutoloadConfig(fixedConfigName)
                if not ok then
                    if SaveManager.Options and SaveManager.Options.SaveManager_AutoloadToggle then
                        SaveManager.Options.SaveManager_AutoloadToggle:SetValue(false)
                    end
                end
            else
                self:DisableAutoload()
            end
        end
    })

    local autosaveDesc = self.AutoSaveConfig and ('Currently auto-saving to: "' .. tostring(self.AutoSaveConfig) .. '"') or 'Auto-save to "AutoSave.json"'
    
    local AutoSaveToggle = section:AddToggle("SaveManager_AutoSaveToggle", {
        Title = "Auto Save",
        Description = autosaveDesc,
        Default = (uiSettings and uiSettings.autosave_enabled) or false,
        Callback = function(value)
            if value then
                if not isfile(getConfigFilePath(self, fixedConfigName)) then
                    self:Save(fixedConfigName)
                end

                self:EnableAutoSave(fixedConfigName)
            else
                self:DisableAutoSave()
            end
        end
    })

    SaveManager:SetIgnoreIndexes({ 
        "SaveManager_AutoloadToggle",
        "SaveManager_AutoSaveToggle"
    })

    if uiSettings then
        if uiSettings.autoload_enabled then
            task.spawn(function()
                if isfile(getConfigFilePath(self, fixedConfigName)) then
                    SaveManager:Load(fixedConfigName)
                    if SaveManager.Options and SaveManager.Options.SaveManager_AutoloadToggle then
                        SaveManager.Options.SaveManager_AutoloadToggle:SetValue(true)
                    end
                end
            end)
        end

        if uiSettings.autosave_enabled then
            if isfile(getConfigFilePath(self, fixedConfigName)) then
                self:EnableAutoSave(fixedConfigName)
                if SaveManager.Options and SaveManager.Options.SaveManager_AutoSaveToggle then
                    SaveManager.Options.SaveManager_AutoSaveToggle:SetValue(true)
                end
            end
        end
    end
end

SaveManager:BuildFolderTree()

-- ==================== UI SETUP ====================
-- Streamer Mode Section
local StreamerSection = Tabs.Main:AddSection("Miscellaneous")

local StreamerToggle = StreamerSection:AddToggle("StreamerModeToggle", {
    Title = "Protect Name",
    Description = "Protects your name",
    Default = false
})

StreamerToggle:OnChanged(function()
    if Options.StreamerModeToggle.Value then
        StreamerMode:Start()
    else
        StreamerMode:Stop()
    end
end)

Options.StreamerModeToggle:SetValue(false)

-- Configuration Manager Section
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Main)

-- Return both modules
return {
    StreamerMode = StreamerMode,
    SaveManager = SaveManager
}
