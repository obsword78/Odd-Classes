local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BoolSwitchSetting = require(ReplicatedStorage.Shared.Classes.SettingTypes.BoolSwitchSetting)
local KeyMapSetting = require(ReplicatedStorage.Shared.Classes.SettingTypes.KeyMapSetting)
local SelectorSetting = require(ReplicatedStorage.Shared.Classes.SettingTypes.SelectorSetting)
local SliderSetting = require(ReplicatedStorage.Shared.Classes.SettingTypes.SliderSetting)
---------------------------------------------------------
local DefaultSettings = {} -- DefaultSettings[category][settingName] = mapSetting
---------------------------
DefaultSettings.Video = {}
---------------------------
DefaultSettings.Audio = {}
---------------------------
DefaultSettings.Gameplay = {}
DefaultSettings.Gameplay.Combat = KeyMapSetting.template()
	.Casual_Attack(Enum.KeyCode.MouseLeftButton)
	.Primary_Ability(Enum.KeyCode.E)
	.Secondary_Ability(Enum.KeyCode.R)
	.Utility_Ability(Enum.KeyCode.F)
	.Ultimate_Ability(Enum.KeyCode.One)
	.onChange(function(self)
		for _, inputAction in game.Players.LocalPlayer.PlayerGui.Abilities:GetChildren() do
			inputAction.KeyboardBinding.KeyCode = self.Value[tonumber(inputAction.Name)].InputBinding
		end
	end)
	.close()
---------------------------
DefaultSettings.Accessibility = {}
---------------------------
DefaultSettings["Misc."] = {}

return DefaultSettings
