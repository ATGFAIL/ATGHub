local httpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local SaveManager = {} do
	SaveManager.FolderRoot = "ATGSettings"
	SaveManager.Ignore = {}
	SaveManager.Options = {}
	SaveManager.AutoSaveEnabled = false
	SaveManager.AutoSaveConnection = nil
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

	function SaveManager:BuildFolderTree()
		local root = self.FolderRoot
		ensureFolder(root)

		local placeId = getPlaceId()
		local placeFolder = root .. "/" .. placeId
		ensureFolder(placeFolder)

		-- Migrate legacy configs
		local legacyPaths = {
			root .. "/settings",
			root .. "/" .. placeId .. "/*/settings"
		}
		
		for _, legacyPattern in ipairs(legacyPaths) do
			if isfolder(legacyPattern) or legacyPattern:find("*") then
				local function tryMigrate(legacySettingsFolder)
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

				if legacyPattern:find("*") then
					local baseFolder = legacyPattern:match("^(.*)/%*")
					if isfolder(baseFolder) then
						local subfolders = listfiles(baseFolder)
						for _, subfolder in ipairs(subfolders) do
							tryMigrate(subfolder .. "/settings")
						end
					end
				else
					tryMigrate(legacyPattern)
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
		return true
	end

	function SaveManager:DisableAutoload()
		local autopath = getConfigsFolder(self) .. "/autoload.txt"
		if isfile(autopath) then
			delfile(autopath)
			return true
		end
		return false, "no autoload config set"
	end

	function SaveManager:StartAutoSave(configName)
		self:StopAutoSave()
		self.AutoSaveEnabled = true
		
		self.AutoSaveConnection = task.spawn(function()
			while self.AutoSaveEnabled do
				task.wait(60) -- 60 วินาที = 1 นาที
				if self.AutoSaveEnabled and configName then
					local success, err = self:Save(configName)
					if success and self.Library then
						self.Library:Notify({
							Title = "Auto Save",
							Content = "Config Saved",
							SubContent = string.format('Auto-saved "%s"', configName),
							Duration = 2
						})
					end
				end
			end
		end)
	end

	function SaveManager:StopAutoSave()
		self.AutoSaveEnabled = false
		if self.AutoSaveConnection then
			task.cancel(self.AutoSaveConnection)
			self.AutoSaveConnection = nil
		end
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
				if name and name ~= "options" then
					table.insert(out, name)
				end
			end
		end
		return out
	end

	function SaveManager:LoadAutoloadConfig()
		local name = self:GetAutoloadConfig()
		if name then
			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify({
					Title = "Config Loader",
					Content = "Failed to load autoload config",
					SubContent = err,
					Duration = 5
				})
			end

			self.Library:Notify({
				Title = "Config Loader",
				Content = "Autoload Success",
				SubContent = string.format('Loaded "%s"', name),
				Duration = 3
			})
		end
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

		local section = tab:AddSection("📁 Configuration Manager")

		-- Config Name Input
		section:AddInput("SaveManager_ConfigName", { 
			Title = "💾 Config Name",
			Placeholder = "Enter config name...",
			Description = "Type a name for your config file"
		})

		-- Config List Dropdown
		local ConfigListDropdown = section:AddDropdown("SaveManager_ConfigList", { 
			Title = "📋 Available Configs", 
			Values = self:RefreshConfigList(), 
			AllowNull = true,
			Description = "Select a config to manage"
		})

		-- Autoload Toggle
		local currentAutoload = self:GetAutoloadConfig()
		local AutoloadToggle = section:AddToggle("SaveManager_AutoloadToggle", {
			Title = "🔄 Auto Load",
			Description = currentAutoload and ('Current: "' .. currentAutoload .. '"') or "No autoload config set",
			Default = currentAutoload ~= nil,
			Callback = function(value)
				local selectedConfig = SaveManager.Options.SaveManager_ConfigList.Value
				
				if value then
					if not selectedConfig then
						if AutoloadToggle.SetValue then
							AutoloadToggle:SetValue(false)
						end
						return self.Library:Notify({
							Title = "Config Loader",
							Content = "Error",
							SubContent = "Please select a config first",
							Duration = 3
						})
					end

					local success, err = self:SetAutoloadConfig(selectedConfig)
					if success then
						if AutoloadToggle.SetDescription then
							AutoloadToggle:SetDescription('Current: "' .. selectedConfig .. '"')
						end
						self.Library:Notify({
							Title = "Config Loader",
							Content = "Autoload Enabled",
							SubContent = string.format('"%s" will load automatically', selectedConfig),
							Duration = 3
						})
					else
						if AutoloadToggle.SetValue then
							AutoloadToggle:SetValue(false)
						end
						self.Library:Notify({
							Title = "Config Loader",
							Content = "Error",
							SubContent = err or "Failed to set autoload",
							Duration = 3
						})
					end
				else
					local success, err = self:DisableAutoload()
					if success then
						if AutoloadToggle.SetDescription then
							AutoloadToggle:SetDescription("No autoload config set")
						end
						self.Library:Notify({
							Title = "Config Loader",
							Content = "Autoload Disabled",
							SubContent = "Configs will no longer auto-load",
							Duration = 3
						})
					end
				end
			end
		})

		-- Auto Save Toggle
		local AutoSaveToggle = section:AddToggle("SaveManager_AutoSaveToggle", {
			Title = "💾 Auto Save",
			Description = "Automatically save config every 1 minute",
			Default = false,
			Callback = function(value)
				local selectedConfig = SaveManager.Options.SaveManager_ConfigList.Value
				
				if value then
					if not selectedConfig then
						if AutoSaveToggle.SetValue then
							AutoSaveToggle:SetValue(false)
						end
						return self.Library:Notify({
							Title = "Auto Save",
							Content = "Error",
							SubContent = "Please select a config first",
							Duration = 3
						})
					end

					self:StartAutoSave(selectedConfig)
					self.Library:Notify({
						Title = "Auto Save",
						Content = "Auto Save Enabled",
						SubContent = string.format('"%s" will save every 1 minute', selectedConfig),
						Duration = 3
					})
				else
					self:StopAutoSave()
					self.Library:Notify({
						Title = "Auto Save",
						Content = "Auto Save Disabled",
						SubContent = "Automatic saving stopped",
						Duration = 3
					})
				end
			end
		})

		-- Update Auto Save when config selection changes
		ConfigListDropdown.Changed = function(value)
			if SaveManager.AutoSaveEnabled then
				self:StopAutoSave()
				if AutoSaveToggle.SetValue then
					AutoSaveToggle:SetValue(false)
				end
				self.Library:Notify({
					Title = "Auto Save",
					Content = "Auto Save Stopped",
					SubContent = "Config selection changed",
					Duration = 2
				})
			end
		end

		section:AddButton({
			Title = "📝 Create Config File",
			Description = "Create a new empty configuration file",
			Callback = function()
				local name = SaveManager.Options.SaveManager_ConfigName.Value

				if name:gsub(" ", "") == "" then
					return self.Library:Notify({
						Title = "Config Loader",
						Content = "Invalid Name",
						SubContent = "Config name cannot be empty",
						Duration = 3
					})
				end

				local success, err = self:Save(name)
				if not success then
					return self.Library:Notify({
						Title = "Config Loader",
						Content = "Creation Failed",
						SubContent = err or "Unknown error",
						Duration = 5
					})
				end

				self.Library:Notify({
					Title = "Config Loader",
					Content = "Config Created",
					SubContent = string.format('Created "%s"', name),
					Duration = 3
				})

				ConfigListDropdown:SetValues(self:RefreshConfigList())
				ConfigListDropdown:SetValue(name)
			end
		})

		section:AddButton({
			Title = "🗑️ Delete Config",
			Description = "Permanently delete selected config",
			Callback = function()
				local name = SaveManager.Options.SaveManager_ConfigList.Value

				if not name then
					return self.Library:Notify({
						Title = "Config Loader",
						Content = "No Config Selected",
						SubContent = "Please select a config to delete",
						Duration = 3
					})
				end

				self.Library:Dialog({
					Title = "Delete Config",
					Content = string.format('Are you sure you want to delete "%s"?', name),
					Buttons = {
						{
							Title = "Delete",
							Callback = function()
								-- Stop auto save if deleting active config
								if self.AutoSaveEnabled then
									self:StopAutoSave()
									if AutoSaveToggle.SetValue then
										AutoSaveToggle:SetValue(false)
									end
								end

								local success, err = self:Delete(name)
								if not success then
									return self.Library:Notify({
										Title = "Config Loader",
										Content = "Delete Failed",
										SubContent = err or "Unknown error",
										Duration = 5
									})
								end

								self.Library:Notify({
									Title = "Config Loader",
									Content = "Config Deleted",
									SubContent = string.format('Deleted "%s"', name),
									Duration = 3
								})

								ConfigListDropdown:SetValues(self:RefreshConfigList())
								ConfigListDropdown:SetValue(nil)
								
								local currentAutoload = self:GetAutoloadConfig()
								if currentAutoload then
									if AutoloadToggle.SetValue then
										AutoloadToggle:SetValue(true)
									end
									if AutoloadToggle.SetDescription then
										AutoloadToggle:SetDescription('Current: "' .. currentAutoload .. '"')
									end
								else
									if AutoloadToggle.SetValue then
										AutoloadToggle:SetValue(false)
									end
									if AutoloadToggle.SetDescription then
										AutoloadToggle:SetDescription("No autoload config set")
									end
								end
							end
						},
						{
							Title = "Cancel"
						}
					}
				})
			end
		})

		section:AddButton({
			Title = "🔄 Refresh List", 
			Description = "Update available configs list",
			Callback = function()
				local configs = self:RefreshConfigList()
				ConfigListDropdown:SetValues(configs)
				
				self.Library:Notify({
					Title = "Config Loader",
					Content = "List Refreshed",
					SubContent = string.format("Found %d config(s)", #configs),
					Duration = 2
				})
			end
		})

		SaveManager:SetIgnoreIndexes({ 
			"SaveManager_ConfigList", 
			"SaveManager_ConfigName",
			"SaveManager_AutoloadToggle",
			"SaveManager_AutoSaveToggle"
		})
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
