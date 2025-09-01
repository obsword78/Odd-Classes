local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local signal = require(ReplicatedStorage.Packages.signal)
local KeyMap = {}
KeyMap.__index = KeyMap
----------------------------
local chainMetaTable = {
	__index = function(keyMapTemplate, bindName)
		return (bindName == "close" and function()
			return setmetatable(keyMapTemplate, KeyMap)
		end) or (bindName == "onChange" and function(func)
			rawset(keyMapTemplate, "OnChange", func)
			return keyMapTemplate
		end) or function(bind)
			table.insert(keyMapTemplate.Value, { BindName = bindName, InputBinding = bind })
			return keyMapTemplate
		end
	end,
}
----------------------------
export type keyMapping = {
	BindName: string,
	InputBinding: Enum.KeyCode,
}
export type KeyMapTemplate = typeof(setmetatable(
	{} :: {
		Value: { keyMapping },
	},
	chainMetaTable
))
----------------------------
local function contstructMappingGui(mappingGui, setting, keymapTemplate)
	mappingGui.mappedKey.Text = setting.InputBinding.Name
	mappingGui.BindName.Text = setting.BindName

	mappingGui.mappedKey.MouseButton1Click:Connect(function()
		if keymapTemplate.SettingBind then
			return
		end
		keymapTemplate.SettingBind = true
		mappingGui.mappedKey.Text = "Select a keybind..."

		local newInputObject = UserInputService.InputBegan:Wait()
		if newInputObject.KeyCode ~= Enum.KeyCode.Unknown then
			setting.InputBinding = newInputObject.KeyCode
		elseif newInputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			setting.InputBinding = Enum.KeyCode.MouseLeftButton
		elseif newInputObject.UserInputType == Enum.UserInputType.MouseButton2 then
			setting.InputBinding = Enum.KeyCode.MouseRightButton
		elseif newInputObject.UserInputType == Enum.UserInputType.MouseButton3 then
			setting.InputBinding = Enum.KeyCode.MouseMiddleButton
		else
			mappingGui.mappedKey.Text = setting.InputBinding.Name
			return
		end
		mappingGui.mappedKey.Text = setting.InputBinding.Name
		keymapTemplate.Changed:Fire()
		keymapTemplate.SettingBind = false
	end)
end
----------------------------
function KeyMap.template(): KeyMapTemplate
	local self = setmetatable({}, chainMetaTable)
	self.Value = {}
	self.SettingBind = false
	self.SettingType = "KeyMapSetting"
	self.Changed = signal.new()
	return self
end

function KeyMap:MapTo(settingGui)
	local MappingsFrame = settingGui.Mappings
	local mapping_template = MappingsFrame.mapping
	contstructMappingGui(mapping_template, self.Value[1], self)
	for i = 2, #self.Value do
		local new_mapping = mapping_template:Clone()
		local v = self.Value[i]
		contstructMappingGui(new_mapping, v, self)
		new_mapping.Parent = MappingsFrame
	end
end

function KeyMap:SetChanges()
	if self.OnChange then
		self:OnChange()
	end
end

return KeyMap
