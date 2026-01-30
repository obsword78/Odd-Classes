local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signal = require(ReplicatedStorage.Packages.signal)
local Selector = {}
Selector.__index = Selector

function Selector.template(startingValue: string, values: { string })
	local getPoint = table.find(values, startingValue)
	assert(getPoint, `Starting Value {startingValue} for Selector Setting is not included in all Values table`)

	local self = setmetatable({}, Selector)
	self.Value = startingValue
	self.Values = values
	self.CurrentPoint = getPoint
	self.SettingType = "SelectorSetting"
	self.Changed = signal.new()
	return self
end

function Selector:MapTo(settingGui)
	settingGui.Selected.Text = self.Value
	settingGui.Left.MouseButton1Click:Connect(function()
		self.CurrentPoint -= 1
		if self.CurrentPoint <= 0 then
			self.CurrentPoint = #self.Values
		end
		self.Value = self.Values[self.CurrentPoint]
		settingGui.Selected.Text = self.Value
		self.Changed:Fire()
	end)
	settingGui.Right.MouseButton1Click:Connect(function()
		self.CurrentPoint += 1
		if self.CurrentPoint > #self.Values then
			self.CurrentPoint = 1
		end
		self.Value = self.Values[self.CurrentPoint]
		settingGui.Selected.Text = self.Value
		self.Changed:Fire()
	end)
end

function Selector:SetChanges()
	if self.OnChange then
		self:OnChange()
	end
end

return Selector
