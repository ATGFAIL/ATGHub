---@diagnostic disable: undefined-global
local httpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local SaveManager = {} do
	SaveManager.FolderRoot = "ATGSettings"
	SaveManager.SubFolder = nil  -- ถ้าตั้งไว้จะใช้แทน PlaceId (share save ข้าม PlaceId)
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
		local sub = self.SubFolder or getPlaceId()
		return root .. "/" .. sub
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

		local sub = self.SubFolder or getPlaceId()
		local placeFolder = root .. "/" .. sub
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

	function SaveManager:SetSubFolder(name)
		self.SubFolder = name and tostring(name) or nil
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

	local function createLoadingUI(total)
		local TweenService = game:GetService("TweenService")
		local CoreGui     = game:GetService("CoreGui")

		local gui = Instance.new("ScreenGui")
		gui.Name            = "SaveManagerLoading"
		gui.ResetOnSpawn    = false
		gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder    = 9999

		-- Card
		local card = Instance.new("Frame")
		card.Size                  = UDim2.new(0, 300, 0, 108)
		card.Position              = UDim2.new(0.5, -150, 0, -130)
		card.BackgroundColor3      = Color3.fromRGB(13, 13, 18)
		card.BackgroundTransparency = 0
		card.BorderSizePixel       = 0
		card.Parent                = gui
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

		local cardGrad = Instance.new("UIGradient", card)
		cardGrad.Color    = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(20, 20, 32)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 10, 14)),
		})
		cardGrad.Rotation = 135

		-- Glowing border
		local stroke = Instance.new("UIStroke", card)
		stroke.Color             = Color3.fromRGB(82, 160, 255)
		stroke.Thickness         = 1.2
		stroke.Transparency      = 0.35
		stroke.ApplyStrokeMode   = Enum.ApplyStrokeMode.Border

		-- Top accent bar (animates width 0 → full)
		local accentBar = Instance.new("Frame", card)
		accentBar.Size             = UDim2.new(0, 0, 0, 2)
		accentBar.Position         = UDim2.new(0, 0, 0, 0)
		accentBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		accentBar.BorderSizePixel  = 0
		accentBar.ZIndex           = 4
		Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)
		local accentGrad = Instance.new("UIGradient", accentBar)
		accentGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(139, 92, 246)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(82, 160, 255)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(16, 185, 129)),
		})

		-- Inner padding
		local inner = Instance.new("Frame", card)
		inner.Size                  = UDim2.new(1, -32, 1, -20)
		inner.Position              = UDim2.new(0, 16, 0, 14)
		inner.BackgroundTransparency = 1

		-- "LOADING SAVE" title
		local titleLbl = Instance.new("TextLabel", inner)
		titleLbl.Size              = UDim2.new(0.65, 0, 0, 18)
		titleLbl.Position          = UDim2.new(0, 0, 0, 0)
		titleLbl.BackgroundTransparency = 1
		titleLbl.TextColor3        = Color3.fromRGB(225, 225, 240)
		titleLbl.TextSize          = 12
		titleLbl.Font              = Enum.Font.GothamBold
		titleLbl.Text              = "LOADING SAVE"
		titleLbl.TextXAlignment    = Enum.TextXAlignment.Left
		titleLbl.TextTransparency  = 1

		-- Count  "X / Y"
		local countLbl = Instance.new("TextLabel", inner)
		countLbl.Size              = UDim2.new(0.35, 0, 0, 18)
		countLbl.Position          = UDim2.new(0.65, 0, 0, 0)
		countLbl.BackgroundTransparency = 1
		countLbl.TextColor3        = Color3.fromRGB(82, 160, 255)
		countLbl.TextSize          = 12
		countLbl.Font              = Enum.Font.GothamBold
		countLbl.Text              = "0 / " .. total
		countLbl.TextXAlignment    = Enum.TextXAlignment.Right
		countLbl.TextTransparency  = 1

		-- Progress bar background
		local barBg = Instance.new("Frame", inner)
		barBg.Size             = UDim2.new(1, 0, 0, 7)
		barBg.Position         = UDim2.new(0, 0, 0, 26)
		barBg.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
		barBg.BorderSizePixel  = 0
		barBg.ClipsDescendants = true
		Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

		-- Progress bar fill
		local barFill = Instance.new("Frame", barBg)
		barFill.Size             = UDim2.new(0, 0, 1, 0)
		barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		barFill.BorderSizePixel  = 0
		barFill.ZIndex           = 2
		Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
		local fillGrad = Instance.new("UIGradient", barFill)
		fillGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(139, 92, 246)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(82, 160, 255)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(16, 185, 129)),
		})

		-- Shimmer overlay on fill
		local shimmer = Instance.new("Frame", barFill)
		shimmer.Size             = UDim2.new(0.35, 0, 1, 0)
		shimmer.Position         = UDim2.new(-0.4, 0, 0, 0)
		shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		shimmer.BackgroundTransparency = 0.65
		shimmer.BorderSizePixel  = 0
		shimmer.ZIndex           = 3
		Instance.new("UICorner", shimmer).CornerRadius = UDim.new(1, 0)

		-- Percent label
		local pctLbl = Instance.new("TextLabel", inner)
		pctLbl.Size              = UDim2.new(0.5, 0, 0, 14)
		pctLbl.Position          = UDim2.new(0, 0, 0, 41)
		pctLbl.BackgroundTransparency = 1
		pctLbl.TextColor3        = Color3.fromRGB(100, 100, 130)
		pctLbl.TextSize          = 10
		pctLbl.Font              = Enum.Font.Gotham
		pctLbl.Text              = "0%"
		pctLbl.TextXAlignment    = Enum.TextXAlignment.Left
		pctLbl.TextTransparency  = 1

		-- Status label
		local statusLbl = Instance.new("TextLabel", inner)
		statusLbl.Size              = UDim2.new(0.5, 0, 0, 14)
		statusLbl.Position          = UDim2.new(0.5, 0, 0, 41)
		statusLbl.BackgroundTransparency = 1
		statusLbl.TextColor3        = Color3.fromRGB(70, 70, 95)
		statusLbl.TextSize          = 10
		statusLbl.Font              = Enum.Font.Gotham
		statusLbl.Text              = "INITIALIZING"
		statusLbl.TextXAlignment    = Enum.TextXAlignment.Right
		statusLbl.TextTransparency  = 1

		pcall(function() gui.Parent = CoreGui end)

		-- === Animations ===
		-- Slide in
		TweenService:Create(card,
			TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, -150, 0, 24) }
		):Play()

		-- Fade in text
		task.delay(0.25, function()
			local fi = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
			for _, lbl in ipairs({ titleLbl, countLbl, pctLbl, statusLbl }) do
				TweenService:Create(lbl, fi, { TextTransparency = 0 }):Play()
			end
		end)

		-- Accent bar sweep
		TweenService:Create(accentBar,
			TweenInfo.new(0.55, Enum.EasingStyle.Quad),
			{ Size = UDim2.new(1, 0, 0, 2) }
		):Play()

		-- Border pulse loop
		local alive = true
		task.spawn(function()
			while alive do
				TweenService:Create(stroke,
					TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{ Transparency = 0.7 }
				):Play()
				task.wait(1.6)
				if not alive then break end
				TweenService:Create(stroke,
					TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{ Transparency = 0.15 }
				):Play()
				task.wait(1.6)
			end
		end)

		-- Shimmer loop
		task.spawn(function()
			while alive do
				shimmer.Position = UDim2.new(-0.4, 0, 0, 0)
				TweenService:Create(shimmer,
					TweenInfo.new(1.0, Enum.EasingStyle.Linear),
					{ Position = UDim2.new(1.4, 0, 0, 0) }
				):Play()
				task.wait(2.2)
			end
		end)

		-- updateFn
		local function updateFn(current, tot)
			local ratio = current / tot
			local pct   = math.floor(ratio * 100)
			countLbl.Text  = current .. " / " .. tot
			pctLbl.Text    = pct .. "%"
			statusLbl.Text = pct >= 100 and "COMPLETE" or "LOADING..."
			TweenService:Create(barFill,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad),
				{ Size = UDim2.new(ratio, 0, 1, 0) }
			):Play()
		end

		-- handle with animated exit
		local handle = {}
		function handle:Destroy()
			alive = false
			TweenService:Create(card,
				TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{ Position = UDim2.new(0.5, -150, 0, -130) }
			):Play()
			task.delay(0.35, function() pcall(function() gui:Destroy() end) end)
		end

		return handle, updateFn
	end

	function SaveManager:Load(name)
		if (not name) then
			return false, "no config file is selected"
		end

		local file = getConfigFilePath(self, name)
		if not isfile(file) then return false, "invalid file" end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, "decode error" end

		local objects = decoded.objects or {}
		local total = #objects

		task.spawn(function()
			local others = {}
			local toggles = {}
			for i = 1, total do
				local option = objects[i]
				if option.type == "Toggle" then
					toggles[#toggles + 1] = option
				else
					others[#others + 1] = option
				end
			end

			local grandTotal = #others + #toggles
			local handle, updateFn = createLoadingUI(grandTotal)
			local count = 0

			for i = 1, #others do
				local option = others[i]
				local parser = self.Parser[option.type]
				if parser then
					pcall(parser.Load, option.idx, option)
				end
				count = count + 1
				updateFn(count, grandTotal)
				task.wait(0.1)
			end

			for i = 1, #toggles do
				local option = toggles[i]
				pcall(self.Parser.Toggle.Load, option.idx, option)
				count = count + 1
				updateFn(count, grandTotal)
				task.wait(0.01)
			end

			handle:Destroy()
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
					if originalCallback then
						originalCallback(...)
					end

					-- Debounce: รวม save หลายๆ การเปลี่ยนแปลงเป็นครั้งเดียว
					if self.AutoSaveEnabled and self.AutoSaveConfig and not self.AutoSaveDebounce then
						self.AutoSaveDebounce = true
						task.delay(3, function()
							self.AutoSaveDebounce = false
							if self.AutoSaveEnabled and self.AutoSaveConfig then
								self:Save(self.AutoSaveConfig)
							end
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

		-- เปิดใช้ Auto Save
		if uiSettings and uiSettings.autosave_enabled then
			if isfile(getConfigFilePath(self, fixedConfigName)) then
				task.defer(function()
					pcall(function() self:EnableAutoSave(fixedConfigName) end)
				end)
			end
		end
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
