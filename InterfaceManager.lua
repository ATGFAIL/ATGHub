local httpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════════
-- Load Language System
-- ═══════════════════════════════════════════════════════════════
local Lang = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Languages/AllInOne.lua"))()

local InterfaceManager = {} do
	InterfaceManager.Folder = "FluentSettings"
    InterfaceManager.Settings = {
        Theme = "Dark",
        Acrylic = true,
        Transparency = true,
        MenuKeybind = "LeftControl",
        Language = "EN" -- Added Language setting
    }

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder;
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

		for i = 1, #paths do
			local str = paths[i]
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
            local data = readfile(path)
            local success, decoded = pcall(httpService.JSONDecode, httpService, data)

            if success then
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
                
                -- Apply loaded language
                if InterfaceManager.Settings.Language then
                    Lang:SetLanguage(InterfaceManager.Settings.Language)
                end
            end
        end
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")
		local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()

		local section = tab:AddSection(Lang:Get("tab_settings"))

        -- ═══════════════════════════════════════════════════════════
        -- Language Selector
        -- ═══════════════════════════════════════════════════════════
        local languageNames = {}
        local languageCodes = {}
        local availableLanguages = Lang:GetAvailableLanguagesWithNames()
        
        for _, langData in ipairs(availableLanguages) do
            table.insert(languageNames, langData.name)
            languageCodes[langData.name] = langData.code
        end

        local currentLangName = Lang:GetCurrentLanguageName()
        for _, langData in ipairs(availableLanguages) do
            if langData.code == Settings.Language then
                currentLangName = langData.name
                break
            end
        end

        local LanguageDropdown = section:AddDropdown("InterfaceLanguage", {
            Title = Lang:Get("language"),
            Description = Lang:Get("language_changed_desc"),
            Values = languageNames,
            Default = currentLangName,
            Callback = function(Value)
                local langCode = languageCodes[Value]
                if langCode then
                    Lang:SetLanguage(langCode)
                    Settings.Language = langCode
                    InterfaceManager:SaveSettings()
                    
                    -- Notify user
                    Library:Notify({
                        Title = Lang:Get("language_changed"),
                        Content = Lang:Get("language_changed_desc"),
                        Duration = 3
                    })
                    
                    -- Reload UI after short delay
                    task.wait(1)
                    Library:Notify({
                        Title = Lang:Get("notification_info"),
                        Content = "UI will reload to apply language...",
                        Duration = 2
                    })
                end
            end
        })

        -- ═══════════════════════════════════════════════════════════
        -- Theme Selector
        -- ═══════════════════════════════════════════════════════════
		local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
			Title = Lang:Get("tab_settings"),
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
	
        -- ═══════════════════════════════════════════════════════════
        -- Acrylic Toggle
        -- ═══════════════════════════════════════════════════════════
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
	
        -- ═══════════════════════════════════════════════════════════
        -- Transparency Toggle
        -- ═══════════════════════════════════════════════════════════
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
	
        -- ═══════════════════════════════════════════════════════════
        -- Menu Keybind
        -- ═══════════════════════════════════════════════════════════
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

return InterfaceManager
