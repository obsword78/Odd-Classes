local Button = {}
Button.__index = Button

function Button.template()
	local self = setmetatable({}, Button)
	self.SettingType = "ButtonSetting"
	return self
end

function Button:MapTo(guiSetting)
	guiSetting.MouseButton1Click:Connect(function()
		self:SetChanges()
	end)
end

function Button:SetChanges()
	if self.OnChange then
		self:OnChange()
	end
end

return Button
