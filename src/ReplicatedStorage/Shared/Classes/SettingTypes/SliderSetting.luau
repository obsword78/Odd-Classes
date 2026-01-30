local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signal = require(ReplicatedStorage.Packages.signal)
local Slider = {}
Slider.__index = Slider

export type SliderTemplate = {
	Value: number,
	Min: number,
	Max: number,
}

function Slider.template(startingValue: number, min: number, max: number): SliderTemplate
	assert(startingValue, "StartingValue not passed in")
	assert(max, "MaxRange not passed in")
	assert(max > (min or 0), "Max is not larger than Min for SliderSetting")
	assert(startingValue <= max and startingValue >= min, "Starting Value for Slider Setting must be within range")

	local self = setmetatable({}, Slider)
	self.Value = startingValue
	self.Min = min or 0
	self.Max = max
	self.SettingType = "ButtonSetting"
	self.Changed = signal.new()
	return self
end

function Slider:MapTo(settingGui)
	local nub = settingGui.slider.slidernub
	nub.UIDragDetector.DragUDim2 = UDim2.fromScale((self.Value - self.Min) / self.Max, 0)
	settingGui.ValueDisplay.Text = math.round(self.Value)
	nub.UIDragDetector.DragContinue:Connect(function()
		settingGui.ValueDisplay.Text = math.round(self.Value)
	end)
	nub.UIDragDetector.DragEnd:Connect(function()
		self.Value = (nub.UIDragDetector.DragUDim2.X.Scale * self.Max) + self.Min
	end)
end

function Slider:SetChanges()
	if self.OnChange then
		self:OnChange()
	end
end

return Slider
