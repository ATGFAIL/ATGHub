local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")

local SaveManager = {} do
	SaveManager.Folder = "ATGSaveSetting"
	SaveManager.Ignore = {}
	SaveManager.AutoSaveEnabled = true
	SaveManager.AutoLoadEnabled = true
	SaveManager.SaveDebounce = false
	SaveManager.SaveDelay = 0.5 -- ดีเลย์ในการบันทึกหลังจากมีการเปลี่ยนแปลง (วินาที)
	
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

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function SaveManager:GetConfigPath()
		local placeId = game.PlaceId
		return self.Folder .. "/MapConfig." .. placeId .. ".json"
	end

	function SaveManager:GetSettingsPath()
		return self.Folder .. "/SaveSetting.json"
	end

	function SaveManager:LoadSettings()
		local settingsPath = self:GetSettingsPath()
		if isfile(settingsPath) then
			local success, decoded = pcall(function()
				return httpService:JSONDecode(readfile(settingsPath))
			end)
			
			if success and decoded then
				self.AutoSaveEnabled = decoded.AutoSave ~= false
				self.AutoLoadEnabled = decoded.AutoLoad ~= false
			end
		end
	end

	function SaveManager:SaveSettings()
		local settingsPath = self:GetSettingsPath()
		local data = {
			AutoSave = self.AutoSaveEnabled,
			AutoLoad = self.AutoLoadEnabled
		}
		
		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if success then
			writefile(settingsPath, encoded)
		end
	end

	function SaveManager:AutoSave()
		if not self.AutoSaveEnabled then return end
		if self.SaveDebounce then return end
		
		self.SaveDebounce = true
		task.delay(self.SaveDelay, function()
			self:Save()
			self.SaveDebounce = false
		end)
	end

	function SaveManager:Save()
		if not self.AutoSaveEnabled then return false, "auto save is disabled" end

		local fullPath = self:GetConfigPath()
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

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load()
		if not self.AutoLoadEnabled then return false, "auto load is disabled" end
		
		local file = self:GetConfigPath()
		if not isfile(file) then return false, "config file not found" end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, "decode error" end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(function() 
					self.Parser[option.type].Load(option.idx, option) 
				end)
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"InterfaceTheme", "AcrylicToggle", "TransparentToggle", "MenuKeybind"
		})
	end

	function SaveManager:BuildFolderTree()
		if not isfolder(self.Folder) then
			makefolder(self.Folder)
		end
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
		self.Options = library.Options
	end

	function SaveManager:SetupAutoSave()
		-- เชื่อมต่อกับทุก Options ให้บันทึกอัตโนมัติเมื่อมีการเปลี่ยนแปลง
		for idx, option in pairs(self.Options) do
			if self.Ignore[idx] then continue end
			
			if option.Changed then
				option:Changed(function()
					self:AutoSave()
				end)
			elseif option.OnChanged then
				option:OnChanged(function()
					self:AutoSave()
				end)
			end
		end
	end

	function SaveManager:LoadAutoConfig()
		-- โหลด Settings ก่อน
		self:LoadSettings()
		
		if not self.AutoLoadEnabled then 
			return self.Library:Notify({
				Title = "Interface",
				Content = "Config Loader",
				SubContent = "Auto load is disabled",
				Duration = 5
			})
		end

		local success, err = self:Load()
		if not success then
			return self.Library:Notify({
				Title = "Interface",
				Content = "Config Loader",
				SubContent = "Failed to auto load: " .. err,
				Duration = 5
			})
		end

		self.Library:Notify({
			Title = "Interface",
			Content = "Config Loader",
			SubContent = "Auto loaded config for Place ID: " .. game.PlaceId,
			Duration = 5
		})
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

		local section = tab:AddSection("Auto Save Configuration")

		-- Toggle Auto Save
		local autoSaveToggle = section:AddToggle("AutoSaveToggle", {
			Title = "Auto Save",
			Description = "Automatically save settings in real-time",
			Default = self.AutoSaveEnabled,
			Callback = function(value)
				self.AutoSaveEnabled = value
				self:SaveSettings()
				
				if value then
					self:Save()
					self.Library:Notify({
						Title = "Interface",
						Content = "Config Loader",
						SubContent = "Auto save enabled",
						Duration = 3
					})
				else
					self.Library:Notify({
						Title = "Interface",
						Content = "Config Loader",
						SubContent = "Auto save disabled",
						Duration = 3
					})
				end
			end
		})

		-- Toggle Auto Load
		local autoLoadToggle = section:AddToggle("AutoLoadToggle", {
			Title = "Auto Load",
			Description = "Automatically load settings on startup",
			Default = self.AutoLoadEnabled,
			Callback = function(value)
				self.AutoLoadEnabled = value
				self:SaveSettings()
				
				self.Library:Notify({
					Title = "Interface",
					Content = "Config Loader",
					SubContent = "Auto load " .. (value and "enabled" or "disabled"),
					Duration = 3
				})
			end
		})

		-- ข้อมูลเพิ่มเติม
		section:AddParagraph({
			Title = "Info",
			Content = "Config file: MapConfig." .. game.PlaceId .. ".json\n" ..
					 "Settings are saved automatically when changed.\n" ..
					 "Config is specific to this Place ID."
		})

		-- เพิ่ม Toggle เข้า Ignore list
		self:SetIgnoreIndexes({ "AutoSaveToggle", "AutoLoadToggle" })
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
