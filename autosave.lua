local httpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local SaveManager = {} do
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
				return { type = "Dropdown", idx = idx, value = object.Value, mutli = object.Multi }
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

	-- helpers
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

	-- ไฟล์สำหรับเซฟ UI ของ SaveManager เอง
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

	-- เซฟ UI ของ SaveManager แยกต่างหาก
	function SaveManager:SaveUI()
		local uiPath = getSaveManagerUIPath(self)
		local uiData = {
			autoload = self:GetAutoloadConfig(),
			autosave_enabled = self.AutoSaveEnabled,
			autosave_config = self.AutoSaveConfig
		}

		local success, encoded = pcall(httpService.JSONEncode, httpService, uiData)
		if success then
			writefile(uiPath, encoded)
		end
	end

	-- โหลด UI ของ SaveManager
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
		
		-- ถ้าเป็น autoload ให้ลบ autoload ด้วย
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

	-- ฟังก์ชัน Auto Save
	function SaveManager:EnableAutoSave(configName)
		self.AutoSaveEnabled = true
		self.AutoSaveConfig = configName
		self:SaveUI()
		
		-- บันทึก callback เดิมและตั้ง callback ใหม่
		for idx, option in next, self.Options do
			if not self.Ignore[idx] and self.Parser[option.Type] then
				-- เก็บ callback เดิมไว้ถ้ายังไม่เคยเก็บ
				if not self.OriginalCallbacks[idx] then
					self.OriginalCallbacks[idx] = option.Callback
				end
				
				-- สร้าง callback ใหม่
				option.Callback = function(...)
					-- เรียก callback เดิม
					if self.OriginalCallbacks[idx] then
						self.OriginalCallbacks[idx](...)
					end
					
					-- Auto save ด้วย debounce
					if self.AutoSaveEnabled and self.AutoSaveConfig and not self.AutoSaveDebounce then
						self.AutoSaveDebounce = true
						task.spawn(function()
							task.wait(1) -- รอ 1 วินาทีก่อนเซฟ
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
		
		-- คืนค่า callback เดิม
		for idx, option in next, self.Options do
			if self.OriginalCallbacks[idx] then
				option.Callback = self.OriginalCallbacks[idx]
			end
		end
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

		local section = tab:AddSection("📁 Configuration Manager")

		-- โหลด UI settings
		local uiSettings = self:LoadUI()

		-- Config Name Input
		section:AddInput("SaveManager_ConfigName", { 
			Title = "💾 Config Name",
			Placeholder = "ใส่ชื่อคอนฟิก...",
			Description = "พิมพ์ชื่อสำหรับคอนฟิกใหม่"
		})

		-- Config List Dropdown
		local configs = self:RefreshConfigList()
		local ConfigListDropdown = section:AddDropdown("SaveManager_ConfigList", { 
			Title = "📋 Available Configs", 
			Values = configs, 
			AllowNull = true,
			Description = "เลือกคอนฟิกที่ต้องการจัดการ"
		})

		-- สร้าง AutoSave.json ถ้าไม่มีไฟล์เลย
		if #configs == 0 then
			local success = self:Save("AutoSave")
			if success then
				configs = self:RefreshConfigList()
				ConfigListDropdown:SetValues(configs)
				ConfigListDropdown:SetValue("AutoSave")
				
				if uiSettings then
					self.AutoSaveConfig = "AutoSave"
					self.AutoSaveEnabled = uiSettings.autosave_enabled or false
				end
			end
		elseif uiSettings and uiSettings.autosave_config then
			-- โหลดค่า autosave config จาก UI settings
			ConfigListDropdown:SetValue(uiSettings.autosave_config)
			self.AutoSaveConfig = uiSettings.autosave_config
			self.AutoSaveEnabled = uiSettings.autosave_enabled or false
		end

		-- Autoload Toggle
		local currentAutoload = self:GetAutoloadConfig()
		local autoloadDesc = currentAutoload and ('ปัจจุบัน: "' .. currentAutoload .. '"') or "ไม่มีคอนฟิกโหลดอัตโนมัติ"
		
		local AutoloadToggle = section:AddToggle("SaveManager_AutoloadToggle", {
			Title = "🔄 Auto Load",
			Description = autoloadDesc,
			Default = currentAutoload ~= nil,
			Callback = function(value)
				local selectedConfig = SaveManager.Options.SaveManager_ConfigList.Value
				
				if value then
					if not selectedConfig then
						SaveManager.Options.SaveManager_AutoloadToggle:SetValue(false)
						return
					end

					self:SetAutoloadConfig(selectedConfig)
				else
					self:DisableAutoload()
				end
			end
		})

		-- Auto Save Toggle
		local autosaveDesc = self.AutoSaveConfig and ('กำลังบันทึกอัตโนมัติไปที่: "' .. self.AutoSaveConfig .. '"') or "เลือกคอนฟิกเพื่อเปิดใช้งาน"
		
		local AutoSaveToggle = section:AddToggle("SaveManager_AutoSaveToggle", {
			Title = "💾 Auto Save",
			Description = autosaveDesc,
			Default = self.AutoSaveEnabled,
			Callback = function(value)
				local selectedConfig = SaveManager.Options.SaveManager_ConfigList.Value
				
				if value then
					if not selectedConfig then
						SaveManager.Options.SaveManager_AutoSaveToggle:SetValue(true)
						return
					end

					self:EnableAutoSave(selectedConfig)
				else
					self:DisableAutoSave()
				end
			end
		})

		-- เมื่อเลือก config ใน dropdown
		ConfigListDropdown:OnChanged(function(value)
			if value and self.AutoSaveEnabled then
				self.AutoSaveConfig = value
				self:SaveUI()
			end
		end)

		section:AddButton({
			Title = "💾 Save New Config",
			Description = "สร้างไฟล์คอนฟิกใหม่",
			Callback = function()
				local name = SaveManager.Options.SaveManager_ConfigName.Value

				if name:gsub(" ", "") == "" then
					return
				end

				local success, err = self:Save(name)
				if not success then
					return
				end

				ConfigListDropdown:SetValues(self:RefreshConfigList())
				ConfigListDropdown:SetValue(name)
			end
		})

		section:AddButton({
			Title = "📂 Load Config", 
			Description = "โหลดคอนฟิกที่เลือก",
			Callback = function()
				local name = SaveManager.Options.SaveManager_ConfigList.Value

				if not name then
					return
				end

				self:Load(name)
			end
		})

		section:AddButton({
			Title = "🗑️ Delete Config",
			Description = "ลบคอนฟิกที่เลือกถาวร",
			Callback = function()
				local name = SaveManager.Options.SaveManager_ConfigList.Value

				if not name then
					return
				end

				-- Confirmation dialog
				self.Library:Dialog({
					Title = "ลบคอนฟิก",
					Content = string.format('คุณแน่ใจหรือไม่ว่าต้องการลบ "%s"?', name),
					Buttons = {
						{
							Title = "ลบ",
							Callback = function()
								local success, err = self:Delete(name)
								if not success then
									return
								end

								-- Update dropdown
								ConfigListDropdown:SetValues(self:RefreshConfigList())
								ConfigListDropdown:SetValue(nil)
								
								-- Update autosave if deleted config was autosave
								if self.AutoSaveConfig == name then
									self:DisableAutoSave()
									SaveManager.Options.SaveManager_AutoSaveToggle:SetValue(false)
								end
								
								-- บันทึก UI
								self:SaveUI()
							end
						},
						{
							Title = "ยกเลิก",
							Callback = function() 
							end
						}
					}
				})
			end
		})

		section:AddButton({
			Title = "🔄 Refresh List", 
			Description = "อัพเดทรายการคอนฟิกที่มี",
			Callback = function()
				local configs = self:RefreshConfigList()
				ConfigListDropdown:SetValues(configs)
				ConfigListDropdown:SetValue(nil)
			end
		})

		-- Ignore UI controls ของ SaveManager
		SaveManager:SetIgnoreIndexes({ 
			"SaveManager_ConfigName",
			"SaveManager_ConfigList",
			"SaveManager_AutoloadToggle",
			"SaveManager_AutoSaveToggle"
		})

		-- โหลด UI settings และเปิดใช้ auto save / auto load ถ้าเคยเปิดไว้
		if uiSettings then
			-- Auto Load
			if uiSettings.autoload_enabled and uiSettings.autoload_config then
				task.spawn(function()
					SaveManager:Load(uiSettings.autoload_config)
					SaveManager.Options.SaveManager_AutoloadToggle:SetValue(true)
				end)
			end

			-- Auto Save
			if uiSettings.autosave_enabled and uiSettings.autosave_config then
				self:EnableAutoSave(uiSettings.autosave_config)
				SaveManager.Options.SaveManager_AutoSaveToggle:SetValue(true)
			end
		end
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
