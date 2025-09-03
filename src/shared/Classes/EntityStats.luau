local ReplicatedStorage = game:GetService("ReplicatedStorage")
local deepcopy = require(ReplicatedStorage.Shared.Utils.deepcopy)
local EntityStats = {}
EntityStats.__index = EntityStats
-------------------------------------------------------
export type EntityStatsData = {
	WalkSpeed: number?,
	JumpPower: number?,
	MaxHealth: number?,
	Size: number?,

	Protection: number?,
	Resist: number?,
	CritReduction: number?,
	Immune: number?,
	Immortal: boolean?,

	[string]: any,
}
export type EntityStats = {
	_data: EntityStatsData,
	Get: (self: EntityStats, statName: string) -> any,
	GetBoolean: (self: EntityStats, statName: string) -> boolean,
	Increment: (self: EntityStats, statName: string, amount: number) -> nil,
	SetCustomStat: (self: EntityStats, statName: string, value: any) -> nil,
	ImprintHumanoid: () -> nil,
	Destroy: () -> nil,
}
-------------------------------------------------------
local function imprint_hum_check(self)
	if not self._refObject then
		warn("[EntityStats] ImprintHumanoid called without a refObject")
		return
	elseif not self._refObject:IsA("Model") then
		warn("[EntityStats] ImprintHumanoid called on a non-Model")
		return
	elseif not self._refObject:FindFirstChildWhichIsA("Humanoid") then
		warn("[EntityStats] ImprintHumanoid called on a Model without a Humanoid")
		return
	end
	return true
end
-------------------------------------------------------
function EntityStats.new(
	refObject: Instance?,
	statisticData: { [string]: number }?,
	registryParent: { [Instance]: EntityStats }
): EntityStats
	local self = setmetatable({}, EntityStats)
	self._data = statisticData and deepcopy(statisticData) or {}
	self._refObject = refObject
	self._registryParent = registryParent
	return self
end

function EntityStats:Get(statName: string)
	return self._data[statName] or 0
end

function EntityStats:GetBoolean(statName: string)
	return self._data[statName] and true or false
end

function EntityStats:Increment(statName: string, amount: number)
	if not self._data[statName] then
		self:SetCustomStat(statName, amount)
	end
	self._data[statName] += amount
end

function EntityStats:SetCustomStat(statName: string, value: any)
	self._data[statName] = value
end

-- Built-in to imprint statistics to the refObject if it is a Humanoid
function EntityStats:ImprintHumanoid()
	if not imprint_hum_check(self) then
		return
	end
	local humanoid = self._refObject.Humanoid

	for statName, value in pairs(self._data) do
		if statName == "WalkSpeed" then
			humanoid.WalkSpeed = value
		elseif statName == "JumpPower" then
			humanoid.JumpPower = value
		elseif statName == "MaxHealth" then
			humanoid.MaxHealth = value
			humanoid.Health = value -- Set current health to max health'
		elseif statName == "Size" then
			humanoid.BodyDepthScale.Value = value
			humanoid.BodyHeightScale.Value = value
			humanoid.BodyWidthScale.Value = value
			humanoid.HeadScale.Value = value
		end
	end
end

function EntityStats:Destroy()
	self._registryParent[self._refObject] = nil
	table.clear(self)
end

return EntityStats
