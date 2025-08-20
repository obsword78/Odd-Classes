local GStats = {}
GStats.__index = GStats

local function deepCopy(original: { [string]: number })
	local copy = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

function GStats.new(refObject: Instance?, statisticData: { [string]: number }?): GStats
	local self = setmetatable({}, GStats)
	self._data = statisticData and deepCopy(statisticData) or {}
	self._refObject = refObject
	return self
end

function GStats:Get(statName: string)
	return self._data[statName] or 0
end

function GStats:Change(statName: string, amount: number)
	if not self._data[statName] then
		self._data[statName] = 0
	end
	self._data[statName] += amount
end

-- Built-in to imprint statistics to the refObject if it is a Humanoid
function GStats:ImprintHumanoid()
	if not self._refObject then
		warn("[GStats] ImprintHumanoid called without a refObject")
		return
	end
	local _humanoid
	if self._refObject:IsA("Model") then
		if not self._refObject:FindFirstChild("Humanoid") then
			warn("[GStats] ImprintHumanoid called on a Model without a Humanoid")
			return
		end
		_humanoid = self._refObject.Humanoid
	end
	if not _humanoid and not self._refObject:IsA("Humanoid") then
		warn("[GStats] ImprintHumanoid called on a refObject that is not a Humanoid")
		return
	end
	_humanoid = self._refObject

	for statName, value in pairs(self._data) do
		if statName == "WalkSpeed" then
			self._refObject.WalkSpeed = value
		elseif statName == "JumpPower" then
			self._refObject.JumpPower = value
		elseif statName == "MaxHealth" then
			self._refObject.MaxHealth = value
			self._refObject.Health = value -- Set current health to max health
		end
	end
end

export type GStats = {
	Get: (self: GStats, statName: string) -> number,
	Change: (self: GStats, statName: string, amount: number) -> (),
	ImprintHumanoid: (self: GStats) -> (),
}

return GStats
