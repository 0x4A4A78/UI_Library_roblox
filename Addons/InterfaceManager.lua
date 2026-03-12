local httpService = game:GetService("HttpService")

local InterfaceManager = {}
do
	InterfaceManager.Folder = "JINGJOKSettings"
	InterfaceManager.Settings = {
		Theme = "Darker",
		Acrylic = false,
		Transparency = true,
		MenuKeybind = "LeftControl"
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
			end
		end
	end

	function InterfaceManager:BuildInterfaceSection(tab)
		assert(self.Library, "Must set InterfaceManager.Library")
		local Library = self.Library
		local Settings = InterfaceManager.Settings

		InterfaceManager:LoadSettings()

		-- Force Darker theme
		Settings.Theme = "Darker"
		Library:SetTheme("Darker")

		local section = tab:AddSection("Interface")

		section:AddButton({
			Title = "Discord",
			Description = "คัดลอกลิงค์เชิญ Discord",
			Callback = function()
				setclipboard("https://discord.gg/7wNFFqNMGZ")
				Library:Notify({
					Title = "Discord",
					Content = "คัดลอกลิงค์ Discord แล้ว!",
					Duration = 3
				})
			end
		})

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

		local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
		MenuKeybind:OnChanged(function()
			Settings.MenuKeybind = MenuKeybind.Value
			InterfaceManager:SaveSettings()
		end)
		Library.MinimizeKeybind = MenuKeybind
	end
end

return InterfaceManager
