local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local DefaultSettings = require(ReplicatedStorage.Shared.Data.DefaultSettings)

local SettingsController = knit.CreateController({
	Name = "SettingsController",
})

local ScreenGui
local SettingsFrame
local CategoriesFrame
local ToggleButton
local SettingsTypesFolder
local SettingsGuiCache

local SelectedCategory = "Video"

SettingsController._SettingValues = {}

local function ToggleVisibility()
	SettingsFrame.Visible = not SettingsFrame.Visible
end

local function LoadCategoryPage(category: string)
	if not SettingsGuiCache:FindFirstChild(category) then
		return
	end
	for _, gui in SettingsFrame.Contents.Margin:GetChildren() do
		if gui:IsA("UIListLayout") then
			continue
		end
		gui.Parent = SettingsGuiCache[SelectedCategory]
	end
	SelectedCategory = category
	for _, settingGui in SettingsGuiCache[category]:GetChildren() do
		settingGui.Parent = SettingsFrame.Contents.Margin
	end
end

function SettingsController:KnitInit()
	ScreenGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Settings")
	SettingsFrame = ScreenGui.SettingsFrame
	CategoriesFrame = SettingsFrame.Categories
	ToggleButton = ScreenGui.Toggle
	SettingsTypesFolder = ReplicatedStorage:WaitForChild("GuiTemplates").SettingTypes
	SettingsGuiCache = Instance.new("Folder")

	SettingsGuiCache.Name = "SettingsGuiCache"
	--====================== Connect Toggle Settings
	ToggleButton.MouseButton1Click:Connect(ToggleVisibility)
	SettingsFrame.Header.Quit.MouseButton1Click:Connect(ToggleVisibility)
	--====================== Connect Category Switching
	for _, categoryButton: TextButton in CategoriesFrame:GetChildren() do
		if not categoryButton:IsA("TextButton") then
			continue
		end
		categoryButton.MouseButton1Click:Connect(function()
			if categoryButton.Name == SelectedCategory then
				return
			end
			CategoriesFrame[SelectedCategory].Text = SelectedCategory
			LoadCategoryPage(categoryButton.Name)
			categoryButton.Text = `<u>{categoryButton.Name}</u>`
		end)
	end
	--====================== Save to Gui Cache & Detect Setting Changes
	for category, categorySettings in DefaultSettings do
		local categoryFolder = Instance.new("Folder")
		categoryFolder.Name = category
		for settingLabel, setting in categorySettings do
			local newSettingGui = SettingsTypesFolder[setting.SettingType]:Clone()
			newSettingGui.SettingLabel.Text = settingLabel
			setting:MapTo(newSettingGui)
			newSettingGui.Parent = categoryFolder
			if setting.Value then
				SettingsController._SettingValues[settingLabel] = setting.Value
				setting:SetChanges()
			end
			if setting.Changed then
				setting.Changed:Connect(function()
					SettingsController._SettingValues[settingLabel] = setting.Value
					setting:SetChanges()
				end)
			end
		end
		categoryFolder.Parent = SettingsGuiCache
	end
	--====================== Load Selected from Cache on startup
	SettingsGuiCache.Parent = ReplicatedStorage
	LoadCategoryPage(SelectedCategory)
	--====================== Print
	print("[SettingsController] Initialised")
end

function SettingsController:GetSettingValue(settingName: string)
	if not SettingsController._SettingValues[settingName] then
		warn(`Attempt to get invalid Setting "{settingName}"`)
	end
	return SettingsController._SettingValues[settingName]
end

function SettingsController:GetAllSettingValues()
	return SettingsController._SettingValues
end

return SettingsController
