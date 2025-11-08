local httpService = game:GetService("HttpService")

--[[
    SaveManager - ระบบ Auto Save/Load อัตโนมัติ
    รองรับ: Toggle, Slider, Dropdown, Input, Keybind, Colorpicker
]]

local SaveManager = {} do
    SaveManager.Folder = "FluentSettings"
    SaveManager.Ignore = {} -- Elements ที่ไม่ต้องการ save
    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object) 
                return { type = "Toggle", idx = idx, value = object.Value } 
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then 
                    SaveManager.Library.Options[idx]:SetValue(data.value)
                end
            end
        },
        Slider = {
            Save = function(idx, object)
                return { type = "Slider", idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then 
                    SaveManager.Library.Options[idx]:SetValue(tonumber(data.value))
                end
            end
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then 
                    SaveManager.Library.Options[idx]:SetValue(data.value)
                end
            end
        },
        Colorpicker = {
            Save = function(idx, object)
                return {
                    type = "Colorpicker",
                    idx = idx,
                    value = object.Value:ToHex(),
                    transparency = object.Transparency
                }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then 
                    SaveManager.Library.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                end
            end
        },
        Keybind = {
            Save = function(idx, object)
                return { type = "Keybind", idx = idx, value = object.Value, mode = object.Mode }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then 
                    SaveManager.Library.Options[idx]:SetValue(data.value, data.mode)
                end
            end
        },
        Input = {
            Save = function(idx, object)
                return { type = "Input", idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValue(data.value)
                end
            end
        }
    }

    function SaveManager:SetIgnoreIndexes(list)
        for _, v in next, list do
            self.Ignore[v] = true
        end
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:BuildFolderTree()
        local paths = {}
        local parts = self.Folder:split("/")
        
        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, "/", 1, idx)
        end

        table.insert(paths, self.Folder .. "/configs")

        for _, str in next, paths do
            if not isfolder(str) then
                makefolder(str)
            end
        end
    end

    function SaveManager:SaveConfig(name)
        if not self.Library then
            return warn("[SaveManager] Library not set")
        end

        local fullPath = self.Folder .. "/configs/" .. name .. ".json"
        local data = {
            objects = {}
        }

        for idx, option in next, self.Library.Options do
            if not self.Ignore[idx] then
                local optionType = option.Type
                if self.Parser[optionType] then
                    data.objects[idx] = self.Parser[optionType].Save(idx, option)
                end
            end
        end

        local success, encoded = pcall(httpService.JSONEncode, httpService, data)
        if not success then
            return warn("[SaveManager] Failed to encode config: " .. name)
        end

        writefile(fullPath, encoded)
        
        -- แจ้งเตือน
        if self.Library then
            self.Library:Notify({
                Title = "Config Saved",
                Content = "Configuration '" .. name .. "' has been saved successfully!",
                Duration = 3
            })
        end
    end

    function SaveManager:LoadConfig(name)
        if not self.Library then
            return warn("[SaveManager] Library not set")
        end

        local fullPath = self.Folder .. "/configs/" .. name .. ".json"
        
        if not isfile(fullPath) then
            return warn("[SaveManager] Config file not found: " .. name)
        end

        local success, decoded = pcall(function()
            return httpService:JSONDecode(readfile(fullPath))
        end)

        if not success then
            return warn("[SaveManager] Failed to decode config: " .. name)
        end

        -- โหลดค่าทั้งหมด
        for idx, data in next, decoded.objects do
            local optionType = data.type
            if self.Parser[optionType] then
                task.spawn(function()
                    self.Parser[optionType].Load(idx, data)
                end)
            end
        end

        -- แจ้งเตือน
        if self.Library then
            self.Library:Notify({
                Title = "Config Loaded",
                Content = "Configuration '" .. name .. "' has been loaded successfully!",
                Duration = 3
            })
        end
    end

    function SaveManager:DeleteConfig(name)
        local fullPath = self.Folder .. "/configs/" .. name .. ".json"
        
        if isfile(fullPath) then
            delfile(fullPath)
            
            if self.Library then
                self.Library:Notify({
                    Title = "Config Deleted",
                    Content = "Configuration '" .. name .. "' has been deleted.",
                    Duration = 3
                })
            end
        end
    end

    function SaveManager:GetConfigs()
        if not isfolder(self.Folder .. "/configs") then
            makefolder(self.Folder .. "/configs")
        end

        local configs = {}
        for _, file in next, listfiles(self.Folder .. "/configs") do
            local name = file:gsub(self.Folder .. "/configs/", ""):gsub("%.json", "")
            table.insert(configs, name)
        end

        return configs
    end

    function SaveManager:LoadAutoloadConfig()
        local path = self.Folder .. "/autoload.txt"
        if isfile(path) then
            local name = readfile(path)
            
            -- รอให้ UI โหลดเสร็จก่อน
            task.wait(1)
            
            if isfile(self.Folder .. "/configs/" .. name .. ".json") then
                self:LoadConfig(name)
            end
        end
    end

    function SaveManager:SetAutoloadConfig(name)
        writefile(self.Folder .. "/autoload.txt", name)
        
        if self.Library then
            self.Library:Notify({
                Title = "Autoload Set",
                Content = "'" .. name .. "' will load automatically on startup.",
                Duration = 3
            })
        end
    end

    -- สร้าง UI สำหรับจัดการ Config
    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, "SaveManager.Library must be set")

        local section = tab:AddSection("Configuration")

        local configList = section:AddDropdown("ConfigList", {
            Title = "Select Config",
            Values = self:GetConfigs(),
            Default = nil
        })

        local configName = section:AddInput("ConfigName", {
            Title = "Config Name",
            Placeholder = "Enter config name...",
            Default = ""
        })

        -- ปุ่ม Save
        section:AddButton({
            Title = "Save Config",
            Description = "Save current settings",
            Callback = function()
                local name = configName.Value
                if name and name ~= "" then
                    self:SaveConfig(name)
                    configList:SetValues(self:GetConfigs())
                    configList:SetValue(name)
                else
                    self.Library:Notify({
                        Title = "Error",
                        Content = "Please enter a config name!",
                        Duration = 3
                    })
                end
            end
        })

        -- ปุ่ม Load
        section:AddButton({
            Title = "Load Config",
            Description = "Load selected configuration",
            Callback = function()
                local selected = configList.Value
                if selected then
                    self:LoadConfig(selected)
                else
                    self.Library:Notify({
                        Title = "Error",
                        Content = "Please select a config to load!",
                        Duration = 3
                    })
                end
            end
        })

        -- ปุ่ม Delete
        section:AddButton({
            Title = "Delete Config",
            Description = "Delete selected configuration",
            Callback = function()
                local selected = configList.Value
                if selected then
                    self:DeleteConfig(selected)
                    configList:SetValues(self:GetConfigs())
                else
                    self.Library:Notify({
                        Title = "Error",
                        Content = "Please select a config to delete!",
                        Duration = 3
                    })
                end
            end
        })

        -- ปุ่ม Refresh
        section:AddButton({
            Title = "Refresh List",
            Description = "Refresh config list",
            Callback = function()
                configList:SetValues(self:GetConfigs())
            end
        })

        -- Autoload Toggle
        section:AddToggle("AutoloadToggle", {
            Title = "Autoload Config",
            Description = "Automatically load selected config on startup",
            Default = false,
            Callback = function(value)
                if value then
                    local selected = configList.Value
                    if selected then
                        self:SetAutoloadConfig(selected)
                    end
                else
                    if isfile(self.Folder .. "/autoload.txt") then
                        delfile(self.Folder .. "/autoload.txt")
                    end
                end
            end
        })

        -- ปุ่ม Refresh (เพื่ออัพเดทรายการ)
        section:AddButton({
            Title = "Set Autoload",
            Description = "Set selected config as autoload",
            Callback = function()
                local selected = configList.Value
                if selected then
                    self:SetAutoloadConfig(selected)
                else
                    self.Library:Notify({
                        Title = "Error",
                        Content = "Please select a config first!",
                        Duration = 3
                    })
                end
            end
        })

        return section
    end
end

-- InterfaceManager (ปรับปรุงเล็กน้อย)
local InterfaceManager = {} do
    InterfaceManager.Folder = "FluentSettings"
    InterfaceManager.Settings = {
        Theme = "Dark",
        Acrylic = true,
        Transparency = true,
        MenuKeybind = "LeftControl"
    }

    function InterfaceManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function InterfaceManager:SetLibrary(library)
        self.Library = library
    end

    function InterfaceManager:BuildFolderTree()
        local paths = {}
        local parts = self.Folder:split("/")
        
        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, "/", 1, idx)
        end

        table.insert(paths, self.Folder)
        table.insert(paths, self.Folder .. "/settings")

        for _, str in next, paths do
            if not isfolder(str) then
                makefolder(str)
            end
        end
    end

    function InterfaceManager:SaveSettings()
        writefile(self.Folder .. "/options.json", httpService:JSONEncode(InterfaceManager.Settings))
    end

    function InterfaceManager:LoadSettings()
        local path = self.Folder .. "/options.json"
        if isfile(path) then
            local success, decoded = pcall(function()
                return httpService:JSONDecode(readfile(path))
            end)

            if success then
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
            end
        end
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")
        local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()

        local section = tab:AddSection("Interface")

        local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
            Title = "Theme",
            Description = "Changes the interface theme.",
            Values = Library.Themes,
            Default = Settings.Theme,
            Callback = function(Value)
                Library:SetTheme(Value)
                Settings.Theme = Value
                InterfaceManager:SaveSettings()
            end
        })

        InterfaceTheme:SetValue(Settings.Theme)
    
        if Library.UseAcrylic then
            section:AddToggle("AcrylicToggle", {
                Title = "Acrylic",
                Description = "The blurred background requires graphic quality 8+",
                Default = Settings.Acrylic,
                Callback = function(Value)
                    Library:ToggleAcrylic(Value)
                    Settings.Acrylic = Value
                    InterfaceManager:SaveSettings()
                end
            })
        end
    
        section:AddToggle("TransparentToggle", {
            Title = "Transparency",
            Description = "Makes the interface transparent.",
            Default = Settings.Transparency,
            Callback = function(Value)
                Library:ToggleTransparency(Value)
                Settings.Transparency = Value
                InterfaceManager:SaveSettings()
            end
        })
    
        local MenuKeybind = section:AddKeybind("MenuKeybind", { 
            Title = "Minimize Bind", 
            Default = Settings.MenuKeybind 
        })
        
        MenuKeybind:OnChanged(function()
            Settings.MenuKeybind = MenuKeybind.Value
            InterfaceManager:SaveSettings()
        end)
        
        Library.MinimizeKeybind = MenuKeybind
    end
end

-- ส่งออกทั้งสองตัว
return {
    SaveManager = SaveManager,
    InterfaceManager = InterfaceManager
}
