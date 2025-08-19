local Stats = {}
Stats.__index = Stats

function Stats.new()
	local self = setmetatable({}, Stats)
	self._data = {}
	return self
end

function Stats:Get(statName: string)
	return self._data[statName] or 0
end

function Stats:Change(statName: string, amount: number)
	if not self._data[statName] then
		self._data[statName] = 0
	end
	self._data[statName] += amount
end

return Stats
