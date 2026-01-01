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
	SaveManager.LoadingInProgress = false -- ป้องกันการโหลดซ้อน
	
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

		-- Migrate legacy configs (ทำแบบ sync ครั้งเดียว)
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

	-- ฟังก์ชันโหลดแบบ Async (แบ่งโหลดเป็นชุดเล็กๆ)
	function SaveManager:LoadAsync(name, onProgress)
		if self.LoadingInProgress then
			return false, "loading already in progress"
		end
		
		if (not name) then
			return false, "no config file is selected"
		end

		local file = getConfigFilePath(self, name)
		if not isfile(file) then return false, "invalid file" end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, "decode error" end

		self.LoadingInProgress = true
		
		-- แบ่งการโหลดออกเป็นชุดเล็กๆ (batch)
		local BATCH_SIZE = 10 -- เพิ่มเป็น 10 items ต่อ batch
		local BATCH_DELAY = 0.03 -- ลด delay เหลือ 0.03 วินาที
		
		task.spawn(function()
			local totalItems = #decoded.objects
			local loadedItems = 0
			
			for i = 1, totalItems, BATCH_SIZE do
				-- โหลด batch นี้
				for j = i, math.min(i + BATCH_SIZE - 1, totalItems) do
					local option = decoded.objects[j]
					if self.Parser[option.type] then
						local parser = self.Parser[option.type]
						pcall(parser.Load, option.idx, option)
					end
					loadedItems = loadedItems + 1
				end
				
				-- แจ้ง progress (ถ้ามี callback)
				if onProgress then
					onProgress(loadedItems, totalItems)
				end
				
				-- รอก่อนโหลด batch ถัดไป (เว้นแต่เป็น batch สุดท้าย)
				if i + BATCH_SIZE <= totalItems then
					task.wait(BATCH_DELAY)
				end
			end
			
			self.LoadingInProgress = false
		end)

		return true
	end

	-- ฟังก์ชันโหลดแบบเดิม (ปรับ Priority ใหม่)
	function SaveManager:Load(name)
		if (not name) then
			return false, "no config file is selected"
		end

		local file = getConfigFilePath(self, name)
		if not isfile(file) then return false, "invalid file" end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, "decode error" end

		-- Priority Loading (โหลดตามลำดับความสำคัญ)
		-- 1. Slider, Input = สำคัญมาก (โหลดก่อน)
		-- 2. Dropdown, Colorpicker, Keybind = ปานกลาง
		-- 3. Toggle = โหลดทีหลังสุด
		
		local function getTypePriority(typeStr)
			if typeStr == "Slider" or typeStr == "Input" then
				return 1 -- สำคัญมาก
			elseif typeStr == "Dropdown" or typeStr == "Colorpicker" or typeStr == "Keybind" then
				return 2 -- ปานกลาง
			elseif typeStr == "Toggle" then
				return 3 -- โหลดทีหลังสุด
			end
			return 4 -- อื่นๆ
		end
		
		-- Phase 1: โหลด Slider และ Input ก่อน (เร็วที่สุด)
		for _, option in next, decoded.objects do
			if self.Parser[option.type] and getTypePriority(option.type) == 1 then
				local parser = self.Parser[option.type]
				pcall(parser.Load, option.idx, option)
			end
		end
		
		-- Phase 2: โหลด Dropdown, Colorpicker, Keybind ทีหลัง (background)
		task.spawn(function()
			task.wait(0.05)
			for _, option in next, decoded.objects do
				if self.Parser[option.type] and getTypePriority(option.type) == 2 then
					local parser = self.Parser[option.type]
					pcall(parser.Load, option.idx, option)
					task.wait(0.005) -- delay เล็กน้อย
				end
			end
			
			-- Phase 3: โหลด Toggle ทีหลังสุด
			task.wait(0.1)
			for _, option in next, decoded.objects do
				if self.Parser[option.type] and getTypePriority(option.type) == 3 then
					local parser = self.Parser[option.type]
					pcall(parser.Load, option.idx, option)
					task.wait(0.005) -- delay เล็กน้อย
				end
			end
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
			-- ใช้ LoadAsync เพื่อป้องกัน lag
			self:Load(name) -- หรือใช้ LoadAsync(name) ถ้าต้องการ
		end
	end

	-- ฟังก์ชัน Auto Save ที่ปรับปรุงแล้ว
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

					-- Auto save ด้วย debounce ที่ยาวขึ้น
					if self.AutoSaveEnabled and self.AutoSaveConfig and not self.AutoSaveDebounce then
						self.AutoSaveDebounce = true
						task.spawn(function()
							task.wait(2) -- เพิ่มเป็น 2 วินาที (จาก 1 วินาที)
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

		-- โหลดแบบ Async เมื่อเริ่มต้น
		if uiSettings and uiSettings.autoload_enabled then
			if isfile(getConfigFilePath(self, fixedConfigName)) then
				task.spawn(function()
					task.wait(0.5) -- รอให้ UI โหลดเสร็จก่อน
					pcall(function() self:Load(fixedConfigName) end)
				end)
			end
		end

		section:AddToggle("SaveManager_AutoloadToggle", {
			Title = "Auto Load",
			Description = "Auto Load Save",
			Default = (uiSettings and uiSettings.autoload_enabled) or false,
			Callback = function(value)
				if value then
					if not isfile(getConfigFilePath(self, fixedConfigName)) then
						self:Save(fixedConfigName)
					end

					local ok = self:SetAutoloadConfig(fixedConfigName)
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

		section:AddToggle("SaveManager_AutoSaveToggle", {
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

		-- เปิดใช้ Auto Save แบบ delayed
		if uiSettings and uiSettings.autosave_enabled then
			if isfile(getConfigFilePath(self, fixedConfigName)) then
				task.spawn(function()
					task.wait(1) -- รอให้ทุกอย่างโหลดเสร็จ
					pcall(function() self:EnableAutoSave(fixedConfigName) end)
				end)
			end
		end
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
