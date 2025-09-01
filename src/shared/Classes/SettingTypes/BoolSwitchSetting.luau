local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signal = require(ReplicatedStorage.Packages.signal)
local BoolSwitch = {}
BoolSwitch.__index = BoolSwitch

export type BoolSwitchTemplate = {
	Value: boolean,
}

local function GuiSwitch(guiSetting, trueOrFalse: boolean)
	local truedSide = trueOrFalse and guiSetting.Left or guiSetting.Right
	local falsedSide = truedSide == guiSetting.Left and guiSetting.Right or guiSetting.Left

	truedSide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	truedSide.TextColor3 = Color3.fromRGB(0, 144, 255)
	truedSide.FontFace.Weight = Enum.FontWeight.Bold
	falsedSide.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	falsedSide.TextColor3 = Color3.fromRGB(255, 255, 255)
	falsedSide.FontFace.Weight = Enum.FontWeight.Regular
end

function BoolSwitch.template(startingValue: boolean): BoolSwitchTemplate
	local self = setmetatable({}, BoolSwitch)
	self.Value = startingValue or true
	self.SettingType = "ButtonSetting"
	self.Changed = signal.new()
	return self
end

function BoolSwitch:MapTo(guiSetting)
	guiSetting.Left:Connect(function()
		if self.Value then
			return
		end
		GuiSwitch(guiSetting, true)
		self.Value = true
		self.Changed:Fire()
	end)
	guiSetting.Right:Connect(function()
		if not self.Value then
			return
		end
		GuiSwitch(guiSetting, false)
		self.Value = false
		self.Changed:Fire()
	end)
end

function BoolSwitch:SetChanges()
	if self.OnChange then
		self:OnChange()
	end
end

return BoolSwitch
