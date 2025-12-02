---@diagnostic disable: undefined-global
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
	SaveManager.IsLoading = false
	SaveManager.IsSaving = false -- เพิ่ม flag สำหรับป้องกันการเซฟซ้ำ
	SaveManager.CallbackLocks = {} -- เก็บ lock สำหรับแต่ละ option
	
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

		-- ป้องกันการเซฟซ้อนกัน
		if self.IsSaving then
			return false, "already saving"
		end

		self.IsSaving = true

		local fullPath = getConfigFilePath(self, name)
		local data = { objects = {} }

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end
			
			local success, result = pcall(function()
				return self.Parser[option.Type].Save(idx, option)
			end)
			
			if success and result then
				table.insert(data.objects, result)
			end
		end

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			self.IsSaving = false
			return false, "failed to encode data"
		end

		local folder = fullPath:match("^(.*)/[^/]+$")
		if folder then ensureFolder(folder) end

		writefile(fullPath, encoded)
		
		self.IsSaving = false
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

	-- ปิด callback ทั้งหมดชั่วคราว
	function SaveManager:DisableAllCallbacks()
		for idx, option in next, self.Options do
			if option.Callback then
				-- เก็บ callback เดิม
				if not self.OriginalCallbacks[idx] then
					self.OriginalCallbacks[idx] = option.Callback
				end
				-- ตั้งเป็น function ว่าง
				option.Callback = function() end
			end
		end
	end

	-- เปิด callback ทั้งหมดกลับมา
	function SaveManager:EnableAllCallbacks()
		for idx, option in next, self.Options do
			if self.OriginalCallbacks[idx] then
				option.Callback = self.OriginalCallbacks[idx]
			end
		end
	end

	function SaveManager:Load(name)
		if (not name) then
			return false, "no config file is selected"
		end

		local file = getConfigFilePath(self, name)
		if not isfile(file) then return false, "invalid file" end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, "decode error" end

		-- เปิด flag IsLoading
		self.IsLoading = true

		-- ปิด callback ทั้งหมดก่อนโหลด
		self:DisableAllCallbacks()

		-- โหลดข้อมูลทีละตัว
		task.spawn(function()
			for i, option in ipairs(decoded.objects) do
				if self.Parser[option.type] then
					local success, err = pcall(function() 
						self.Parser[option.type].Load(option.idx, option) 
					end)
					
					if not success then
						warn("Load error for " .. tostring(option.idx) .. ": " .. tostring(err))
					end
				end
				
				-- รอทุก 3 options
				if i % 3 == 0 then
					task.wait(0.05) -- รอสั้นๆ
				end
			end
			
			-- รอให้ทุกอย่างเสร็จสมบูรณ์
			task.wait(1)
			
			-- เปิด callback กลับมา
			self:EnableAllCallbacks()
			
			-- ถ้ามี auto save ให้ตั้งค่า callback ใหม่
			if self.AutoSaveEnabled and self.AutoSaveConfig then
				self:SetupAutoSaveCallbacks()
			end
			
			-- ปิด flag IsLoading
			self.IsLoading = false
		end)

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

	-- ตั้งค่า callback สำหรับ auto save แยกออกมาเป็นฟังก์ชันต่างหาก
	function SaveManager:SetupAutoSaveCallbacks()
		for idx, option in next, self.Options do
			if not self.Ignore[idx] and self.Parser[option.Type] then
				-- เก็บ callback เดิมถ้ายังไม่เคยเก็บ
				if not self.OriginalCallbacks[idx] then
					self.OriginalCallbacks[idx] = option.Callback
				end

				local originalCallback = self.OriginalCallbacks[idx]
				
				-- สร้าง wrapper callback ที่ปลอดภัย
				option.Callback = function(...)
					local args = {...}
					
					-- ป้องกันการเรียกซ้ำ
					if self.CallbackLocks[idx] then
						return
					end
					
					-- ไม่เรียก callback ตอน loading หรือ saving
					if self.IsLoading or self.IsSaving then
						return
					end

					self.CallbackLocks[idx] = true

					-- เรียก original callback ใน coroutine แยก
					task.spawn(function()
						if originalCallback then
							local success, err = pcall(function()
								originalCallback(table.unpack(args))
							end)
							
							if not success then
								warn("Callback error for " .. tostring(idx) .. ": " .. tostring(err))
							end
						end
						
						-- รอให้ callback เสร็จก่อน unlock
						task.wait(0.1)
						self.CallbackLocks[idx] = false
						
						-- Auto save หลังจาก callback เสร็จ
						if self.AutoSaveEnabled and self.AutoSaveConfig and not self.AutoSaveDebounce and not self.IsLoading and not self.IsSaving then
							self.AutoSaveDebounce = true
							
							task.spawn(function()
								task.wait(1.5) -- รอนานขึ้นเพื่อความปลอดภัย
								
								if self.AutoSaveEnabled and self.AutoSaveConfig and not self.IsLoading and not self.IsSaving then
									self:Save(self.AutoSaveConfig)
								end
								
								task.wait(0.5)
								self.AutoSaveDebounce = false
							end)
						end
					end)
				end
			end
		end
	end

	function SaveManager:EnableAutoSave(configName)
		self.AutoSaveEnabled = true
		self.AutoSaveConfig = configName
		self:SaveUI()
		
		-- ตั้งค่า callback
		self:SetupAutoSaveCallbacks()
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
		
		-- ล้าง locks
		self.CallbackLocks = {}
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

		local AutoloadToggle = section:AddToggle("SaveManager_AutoloadToggle", {
			Title = "Auto Load",
			Description = "Auto Load Save",
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

		local AutoSaveToggle = section:AddToggle("SaveManager_AutoSaveToggle", {
			Title = "Auto Save",
			Description = "Auto Save When You Settings",
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
			-- Auto Load
			if uiSettings.autoload_enabled then
				task.spawn(function()
					task.wait(2)
					
					if isfile(getConfigFilePath(self, fixedConfigName)) then
						SaveManager:Load(fixedConfigName)
						
						task.wait(3)
						
						if SaveManager.Options and SaveManager.Options.SaveManager_AutoloadToggle then
							-- ใช้ pcall ป้องกัน error
							pcall(function()
								SaveManager.Options.SaveManager_AutoloadToggle:SetValue(true)
							end)
						end
					end
				end)
			end

			-- Auto Save
			if uiSettings.autosave_enabled then
				task.spawn(function()
					task.wait(5) -- รอนานกว่าเดิม
					
					if isfile(getConfigFilePath(self, fixedConfigName)) then
						self:EnableAutoSave(fixedConfigName)
						
						if SaveManager.Options and SaveManager.Options.SaveManager_AutoSaveToggle then
							pcall(function()
								SaveManager.Options.SaveManager_AutoSaveToggle:SetValue(true)
							end)
						end
					end
				end)
			end
		end
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
