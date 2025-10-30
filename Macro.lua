-- MacroModule.lua
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local MacroModule = {}
MacroModule.__index = MacroModule

-- internal state
local recording = false
local playing = false
local macroData = {}
local startTime = 0
local looping = false
local hookInstalled = false
local oldNamecall = nil

local eventsCount = 0
local durationTime = 0

-- default folder structure (can be overridden with SetFolder)
MacroModule.FolderRoot = "ATGHUB_Macro"
local SUB_FOLDER = MacroModule.FolderRoot .. "/Anime Last Stand"

-- compatibility / config fields (SaveManager-like)
MacroModule.Library = nil
MacroModule.Options = {}      -- populated when SetLibrary is called (Library.Options)
MacroModule.Ignore = {}
local IGNORE_THEME = false

-- helpers: sanitize & filesystem helpers
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

local function getMapName()
    local ok, map = pcall(function() return Workspace:FindFirstChild("Map") end)
    if ok and map and map:IsA("Instance") then
        return sanitizeFilename(map.Name)
    end
    local ok2, wname = pcall(function() return Workspace.Name end)
    if ok2 and wname then return sanitizeFilename(wname) end
    return "UnknownMap"
end

local function ensureFolder(path)
    if not isfolder then return end
    if not isfolder(path) then
        makefolder(path)
    end
end

-- build tree similar to SaveManager: <root>/<PlaceId>/<MapName>/settings
function MacroModule:BuildFolderTree()
    local root = self.FolderRoot or "ATGHUB_Macro"
    ensureFolder(root)

    local placeId = getPlaceId()
    local placeFolder = root .. "/" .. placeId
    ensureFolder(placeFolder)

    local mapName = getMapName()
    local mapFolder = placeFolder .. "/" .. mapName
    ensureFolder(mapFolder)

    local settingsFolder = mapFolder .. "/settings"
    ensureFolder(settingsFolder)

    -- migrate legacy if exists (<root>/settings)
    local legacySettingsFolder = root .. "/settings"
    if isfolder and isfolder(legacySettingsFolder) then
        local files = listfiles(legacySettingsFolder)
        for i = 1, #files do
            local f = files[i]
            if f:sub(-5) == ".json" then
                local base = f:match("([^/\\]+)%.json$")
                if base and base ~= "options" then
                    local dest = settingsFolder .. "/" .. base .. ".json"
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
            local destAuto = settingsFolder .. "/autoload.txt"
            if not isfile(destAuto) then
                pcall(writefile, destAuto, autodata)
            end
        end
    end
end

local function getConfigsFolder(self)
    local root = self.FolderRoot or MacroModule.FolderRoot or "ATGHUB_Macro"
    local placeId = getPlaceId()
    local mapName = getMapName()
    return root .. "/" .. placeId .. "/" .. mapName .. "/settings"
end

local function getConfigFilePath(self, name)
    local folder = getConfigsFolder(self)
    return folder .. "/" .. name .. ".json"
end

-- status updater (uses Library:Notify for messages and Library.Options area if provided)
local function notify(title, content, duration)
    if MacroModule.Library and MacroModule.Library.Notify then
        pcall(function()
            MacroModule.Library:Notify({ Title = title or "Macro System", Content = content or "", Duration = duration or 3 })
        end)
    else
        -- fallback
        print(("[MacroModule] %s: %s"):format(title or "Info", tostring(content)))
    end
end

local function updateStatus()
    local text = string.format("📊 Events: %d\n⏱️ Duration: %.3fs\n🔗 Hook: %s", eventsCount, durationTime, (hookInstalled and "Active ✓" or "Inactive ✗"))
    -- try to update Library.Options location if exists (best-effort)
    if MacroModule.Library and MacroModule.Library.Options and MacroModule.Library.Options.StatusText then
        pcall(function()
            if MacroModule.Library.Options.StatusText.SetValue then
                MacroModule.Library.Options.StatusText:SetValue(text)
            end
        end)
        return
    end
    -- otherwise attempt to set known Tab/Main update if present in Options table
    if MacroModule.Options and MacroModule.Options.Status and MacroModule.Options.Status.SetValue then
        pcall(function() MacroModule.Options.Status:SetValue(text) end)
    end
end

-- Serialization helpers (same as earlier)
local function serializeArg(arg)
    local argType = typeof(arg)
    if argType == "Instance" then
        return { type = "Instance", path = arg:GetFullName(), className = arg.ClassName }
    elseif argType == "CFrame" then
        return { type = "CFrame", components = {arg:GetComponents()} }
    elseif argType == "Vector3" then
        return { type = "Vector3", x = arg.X, y = arg.Y, z = arg.Z }
    elseif argType == "Color3" then
        return { type = "Color3", r = arg.R, g = arg.G, b = arg.B }
    elseif argType == "table" then
        local serialized = {}
        for k, v in pairs(arg) do serialized[k] = serializeArg(v) end
        return { type = "table", data = serialized }
    else
        return { type = argType, value = arg }
    end
end

local function deserializeArg(data)
    if type(data) ~= "table" or not data.type then return data end
    if data.type == "Instance" then
        local success, result = pcall(function()
            local obj = game
            for part in data.path:gmatch("[^.]+") do
                if part ~= "game" then
                    obj = obj:WaitForChild(part, 3)
                end
            end
            return obj
        end)
        return success and result or nil
    elseif data.type == "CFrame" then
        return CFrame.new(unpack(data.components))
    elseif data.type == "Vector3" then
        return Vector3.new(data.x, data.y, data.z)
    elseif data.type == "Color3" then
        return Color3.new(data.r, data.g, data.b)
    elseif data.type == "table" then
        local result = {}
        for k, v in pairs(data.data) do result[k] = deserializeArg(v) end
        return result
    else
        return data.value
    end
end

-- Hook installer (SimpleSpy-style)
function MacroModule:InstallHook()
    if hookInstalled then return true end
    local ok, err = pcall(function()
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if (method == "FireServer" or method == "InvokeServer") and recording then
                if (self and (self:IsA and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")))) then
                    local currentTime = tick() - startTime
                    local serializedArgs = {}
                    for i, arg in ipairs(args) do serializedArgs[i] = serializeArg(arg) end

                    table.insert(macroData, {
                        time = currentTime,
                        remoteName = self.Name,
                        remotePath = self:GetFullName(),
                        remoteType = method,
                        args = serializedArgs
                    })

                    eventsCount = #macroData
                    durationTime = currentTime
                    updateStatus()
                end
            end
            return oldNamecall(self, ...)
        end)
        hookInstalled = true
        return true
    end)
    if not ok then
        warn("Hook installation failed: " .. tostring(err))
        return false
    end
    updateStatus()
    return true
end

-- Play macro
function MacroModule:PlayMacro(loop)
    if #macroData == 0 then
        notify("Macro System", "❌ ไม่มีมาโครให้เล่น!", 3)
        return
    end

    playing = true
    looping = loop or false

    task.spawn(function()
        repeat
            local playStart = tick()
            for _, action in ipairs(macroData) do
                if not playing then break end
                local targetTime = playStart + action.time
                local waitTime = targetTime - tick()
                if waitTime > 0 then task.wait(waitTime) end
                if not playing then break end

                pcall(function()
                    local remote = game
                    for part in action.remotePath:gmatch("[^.]+") do
                        if part ~= "game" then
                            remote = remote:FindFirstChild(part) or remote:WaitForChild(part, 2)
                        end
                    end
                    if remote then
                        local deserializedArgs = {}
                        for i, arg in ipairs(action.args) do deserializedArgs[i] = deserializeArg(arg) end
                        if action.remoteType == "FireServer" and remote.FireServer then
                            remote:FireServer(unpack(deserializedArgs))
                        elseif action.remoteType == "InvokeServer" and remote.InvokeServer then
                            remote:InvokeServer(unpack(deserializedArgs))
                        end
                    end
                end)
            end

            if looping and playing then task.wait(0.5) end
        until not looping or not playing

        playing = false
    end)
end

function MacroModule:StopPlaying()
    looping = false
    playing = false
    if MacroModule.Options and MacroModule.Options.AutoPlayToggle and MacroModule.Options.AutoPlayToggle.SetValue then
        pcall(function() MacroModule.Options.AutoPlayToggle:SetValue(false) end)
    end
end

-- Save macro to file or clipboard
function MacroModule:SaveMacro(filename)
    if #macroData == 0 then
        notify("Macro System", "❌ ไม่มีข้อมูลมาโครให้บันทึก!", 3)
        return false
    end
    if not filename or filename == "" then
        notify("Macro System", "❌ กรุณากรอกชื่อไฟล์!", 3)
        return false
    end

    -- build folder tree for configs
    self:BuildFolderTree()
    local success, result = pcall(function()
        local data = {
            macroData = macroData,
            timestamp = os.time(),
            totalEvents = #macroData,
            totalDuration = durationTime
        }
        local json = HttpService:JSONEncode(data)
        if writefile then
            local fullPath = getConfigFilePath(self, filename)
            -- ensure folder
            local folder = fullPath:match("^(.*)/[^/]+$")
            if folder then ensureFolder(folder) end
            writefile(fullPath, json)
            return true
        else
            setclipboard(json)
            return "clipboard"
        end
    end)

    if success then
        if result == "clipboard" then
            notify("Macro System", "📋 บันทึกแล้ว! ข้อมูลถูกคัดลอกไปยังคลิปบอร์ด", 5)
        else
            notify("Macro System", "💾 บันทึกไฟล์สำเร็จ!", 3)
        end
        return true
    else
        notify("Macro System", "❌ การบันทึกล้มเหลว: " .. tostring(result), 5)
        return false
    end
end

-- Load macro from file
function MacroModule:LoadMacro(filename)
    if not filename or filename == "" then
        notify("Macro System", "❌ กรุณาเลือกไฟล์!", 3)
        return false
    end

    local ok, res = pcall(function()
        if readfile then
            local fullPath = getConfigFilePath(self, filename)
            if isfile and not isfile(fullPath) then
                return nil, "ไฟล์ไม่พบ"
            end
            local content = readfile(fullPath)
            return HttpService:JSONDecode(content)
        else
            return nil, "ระบบไฟล์ไม่รองรับ"
        end
    end)

    if ok and res then
        macroData = res.macroData or {}
        eventsCount = #macroData
        durationTime = res.totalDuration or 0
        updateStatus()
        notify("Macro System", "✅ โหลดมาโครสำเร็จ!", 3)
        return true
    else
        notify("Macro System", "❌ โหลดไฟล์ล้มเหลว: " .. tostring(res), 5)
        return false
    end
end

-- refresh config list
function MacroModule:RefreshConfigList()
    self:BuildFolderTree()
    local folder = getConfigsFolder(self)
    if not isfolder or not isfolder(folder) then return {} end
    local list = listfiles(folder)
    local out = {}
    for i = 1, #list do
        local file = list[i]
        if file:sub(-5) == ".json" then
            local name = file:match("([^/\\]+)%.json$")
            if name and name ~= "options" then
                table.insert(out, name)
            end
        end
    end
    return out
end

function MacroModule:LoadAutoloadConfig()
    local autopath = getConfigsFolder(self) .. "/autoload.txt"
    if isfile and isfile(autopath) then
        local name = readfile(autopath)
        local success, err = self:LoadMacro(name)
        if not success then
            notify("Interface", "Failed to load autoload config: " .. tostring(err), 7)
            return
        end
        notify("Interface", string.format("Auto loaded config %q", name), 7)
    end
end

-- API: compatibility methods
function MacroModule:SetLibrary(library)
    self.Library = library
    self.Options = library.Options or self.Options
end

function MacroModule:SetFolder(folder)
    folder = tostring(folder or self.FolderRoot or "ATGHUB_Macro")
    self.FolderRoot = folder
    -- update SUB_FOLDER style for backward compat (keep default subpath if not explicit settings path)
    SUB_FOLDER = folder
    self:BuildFolderTree()
end

function MacroModule:SetIgnoreIndexes(list)
    if type(list) ~= "table" then return end
    for _, key in next, list do
        self.Ignore[key] = true
    end
end

function MacroModule:IgnoreThemeSettings()
    self:SetIgnoreIndexes({ "InterfaceTheme", "AcrylicToggle", "TransparentToggle", "MenuKeybind" })
end

-- UI builder: BuildInterfaceSection(tab)
function MacroModule:BuildInterfaceSection(tab)
    assert(tab, "BuildInterfaceSection expects a tab object")
    -- We'll create UI controls under the provided tab
    -- store reference to tab-based options for update callbacks
    self.Tab = tab

    -- Try to create a "Macro" section and inputs (best-effort; depends on Fluent API)
    local section = tab:AddSection("Macro")

    -- Filename input
    self.Options.FilenameInput = tab:AddInput("Macro_FilenameInput", {
        Title = "ชื่อไฟล์",
        Default = "",
        Placeholder = "กรอกชื่อไฟล์ (ไม่ต้องมี .json)",
        Numeric = false,
        Finished = false,
    })

    -- File dropdown
    self.Options.FileDropdown = tab:AddDropdown("Macro_FileDropdown", {
        Title = "เลือกไฟล์มาโคร",
        Values = self:RefreshConfigList(),
        Multi = false,
        Default = 1,
    })

    tab:AddButton({
        Title = "💾 บันทึกมาโคร",
        Description = "บันทึกมาโครปัจจุบันลงไฟล์",
        Callback = function()
            local filename = (self.Options.FilenameInput and self.Options.FilenameInput.Value) or ""
            if filename == "" or not filename then
                filename = os.date("macro_%Y%m%d_%H%M%S")
            end
            self:SaveMacro(filename)
            pcall(function() self.Options.FileDropdown:SetValues(self:RefreshConfigList()) end)
        end
    })

    -- Record toggle
    self.Options.RecordToggle = tab:AddToggle("Macro_RecordToggle", {
        Title = "⏺️ บันทึกมาโคร",
        Description = "เริ่ม/หยุด การบันทึกมาโคร",
        Default = false
    })

    self.Options.RecordToggle:OnChanged(function()
        if self.Options.RecordToggle.Value then
            if not hookInstalled then
                if not self:InstallHook() then
                    notify("Macro System", "❌ ติดตั้ง Hook ไม่สำเร็จ!", 3)
                    self.Options.RecordToggle:SetValue(false)
                    return
                end
            end
            recording = true
            macroData = {}
            startTime = tick()
            eventsCount = 0
            durationTime = 0
            updateStatus()
            notify("Macro System", "🎬 เริ่มบันทึกมาโครแล้ว", 2)
        else
            recording = false
            notify("Macro System", string.format("✅ บันทึกเสร็จสิ้น: %d events", #macroData), 3)
            updateStatus()
        end
    end)

    -- AutoPlay toggle
    self.Options.AutoPlayToggle = tab:AddToggle("Macro_AutoPlayToggle", {
        Title = "🔁 เล่นมาโครอัตโนมัติ",
        Description = "เล่นมาโครวนลูปเมื่อเปิด",
        Default = false
    })

    self.Options.AutoPlayToggle:OnChanged(function()
        if self.Options.AutoPlayToggle.Value then
            if not playing then
                self:PlayMacro(true)
                notify("Macro System", "🔁 เริ่มเล่นมาโครแบบวนลูป", 2)
            end
        else
            self:StopPlaying()
            notify("Macro System", "⏹️ หยุดเล่นมาโคร", 2)
        end
    end)

    tab:AddButton({
        Title = "▶️ เล่นมาโคร",
        Description = "เล่นมาโครหนึ่งรอบ",
        Callback = function()
            if playing then
                notify("Macro System", "⏸️ หยุดเล่นมาโครชั่วคราว", 2)
                self:StopPlaying()
                if self.Options.AutoPlayToggle and self.Options.AutoPlayToggle.SetValue then
                    self.Options.AutoPlayToggle:SetValue(false)
                end
            else
                self:PlayMacro(false)
                notify("Macro System", "▶️ เริ่มเล่นมาโครหนึ่งรอบ", 2)
            end
        end
    })

    tab:AddButton({
        Title = "📂 โหลดมาโคร",
        Description = "โหลดมาโครจากไฟล์",
        Callback = function()
            local selectedFile = (self.Options.FileDropdown and self.Options.FileDropdown.Value) or nil
            if selectedFile and selectedFile ~= "ไม่มีไฟล์ที่บันทึกไว้" and selectedFile ~= "ไม่มีระบบไฟล์" then
                self:LoadMacro(selectedFile)
            else
                notify("Macro System", "❌ กรุณาเลือกไฟล์ที่ถูกต้อง", 3)
            end
        end
    })

    tab:AddButton({
        Title = "🗑️ ล้างข้อมูล",
        Description = "ล้างข้อมูลมาโครปัจจุบัน",
        Callback = function()
            macroData = {}
            eventsCount = 0
            durationTime = 0
            updateStatus()
        end
    })

    tab:AddButton({
        Title = "อัพเดทรายการไฟล์",
        Description = "รีเฟรชรายการไฟล์มาโคร (จากโฟลเดอร์)",
        Callback = function()
            pcall(function() self.Options.FileDropdown:SetValues(self:RefreshConfigList()) end)
            notify("Macro System", "🔄 อัพเดทรายการไฟล์แล้ว", 2)
        end
    })
end

-- BuildConfigSection: ให้ UI สำหรับจัดการไฟล์ (Create/Load/Overwrite/Refresh/Autoload)
function MacroModule:BuildConfigSection(tab)
    assert(self.Library, "Must set MacroModule.Library via SetLibrary before BuildConfigSection")

    local section = tab:AddSection("Macro Configuration")

    section:AddInput("Macro_ConfigName", { Title = "Config name" })
    section:AddDropdown("Macro_ConfigList", { Title = "Config list", Values = self:RefreshConfigList(), AllowNull = true })

    section:AddButton({
        Title = "Create config",
        Callback = function()
            local name = self.Options.Macro_ConfigName and self.Options.Macro_ConfigName.Value or ""
            if name:gsub(" ", "") == "" then
                return self.Library:Notify({ Title = "Interface", Content = "Config loader", SubContent = "Invalid config name (empty)", Duration = 7 })
            end
            local success, err = self:SaveMacro(name)
            if not success then
                return self.Library:Notify({ Title = "Interface", Content = "Config loader", SubContent = "Failed to save config: " .. tostring(err), Duration = 7 })
            end
            self.Library:Notify({ Title = "Interface", Content = "Config loader", SubContent = string.format("Created config %q", name), Duration = 7 })
            -- refresh list
            pcall(function() self.Options.Macro_ConfigList:SetValues(self:RefreshConfigList()); self.Options.Macro_ConfigList:SetValue(nil) end)
        end
    })

    section:AddButton({
        Title = "Load config",
        Callback = function()
            local name = self.Options.Macro_ConfigList and self.Options.Macro_ConfigList.Value
            local success, err = self:LoadMacro(name)
            if not success then
                return self.Library:Notify({ Title = "Interface", Content = "Config loader", SubContent = "Failed to load config: " .. tostring(err), Duration = 7 })
            end
            self.Library:Notify({ Title = "Interface", Content = "Config loader", SubContent = string.format("Loaded config %q", name), Duration = 7 })
        end
    })

    section:AddButton({
        Title = "Overwrite config",
        Callback = function()
            local name = self.Options.Macro_ConfigList and self.Options.Macro_ConfigList.Value
            local success, err = self:SaveMacro(name)
            if not success then
                return self.Library:Notify({ Title = "Interface", Content = "Config loader", SubContent = "Failed to overwrite config: " .. tostring(err), Duration = 7 })
            end
            self.Library:Notify({ Title = "Interface", Content = "Config loader", SubContent = string.format("Overwrote config %q", name), Duration = 7 })
        end
    })

    section:AddButton({ Title = "Refresh list", Callback = function()
        pcall(function() self.Options.Macro_ConfigList:SetValues(self:RefreshConfigList()); self.Options.Macro_ConfigList:SetValue(nil) end)
    end })

    local AutoloadButton
    AutoloadButton = section:AddButton({
        Title = "Set as autoload",
        Description = "Current autoload config: none",
        Callback = function()
            local name = self.Options.Macro_ConfigList and self.Options.Macro_ConfigList.Value
            local autopath = getConfigsFolder(self) .. "/autoload.txt"
            if writefile then
                writefile(autopath, tostring(name))
                AutoloadButton:SetDesc("Current autoload config: " .. tostring(name))
                self.Library:Notify({ Title = "Interface", Content = "Config loader", SubContent = string.format("Set %q to auto load", name), Duration = 7 })
            else
                self.Library:Notify({ Title = "Interface", Content = "Config loader", SubContent = "Filesystem not supported", Duration = 7 })
            end
        end
    })

    -- populate current autoload desc if exists
    local autop = getConfigsFolder(self) .. "/autoload.txt"
    if isfile and isfile(autop) then
        local name = readfile(autop)
        pcall(function() AutoloadButton:SetDesc("Current autoload config: " .. tostring(name)) end)
    end

    -- mark ignore indexes for these UI fields (so SaveManager-like behavior)
    self:SetIgnoreIndexes({ "Macro_ConfigList", "Macro_ConfigName" })
end

-- convenience aliases & Init
function MacroModule:Init(deps)
    deps = deps or {}
    if deps.Library then self:SetLibrary(deps.Library) end
    if deps.Folder then self:SetFolder(deps.Folder) end
    return self
end

-- expose some util getters
function MacroModule:GetState()
    return {
        recording = recording,
        playing = playing,
        eventsCount = eventsCount,
        durationTime = durationTime,
        hookInstalled = hookInstalled,
        macros = macroData
    }
end

-- expose methods
MacroModule.InstallHook = MacroModule.InstallHook
MacroModule.PlayMacro = MacroModule.PlayMacro
MacroModule.StopPlaying = MacroModule.StopPlaying
MacroModule.SaveMacro = MacroModule.SaveMacro
MacroModule.LoadMacro = MacroModule.LoadMacro
MacroModule.RefreshConfigList = MacroModule.RefreshConfigList
MacroModule.LoadAutoloadConfig = MacroModule.LoadAutoloadConfig

-- ensure default folder structure on load
MacroModule:BuildFolderTree()

return MacroModule
