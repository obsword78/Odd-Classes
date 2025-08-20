local PlayerProfile = {}
PlayerProfile.__index = PlayerProfile

function PlayerProfile.new(player: Player, registryTable, storeProfile): PlayerProfile
	local self = setmetatable({}, PlayerProfile)
	self.player = player
	self._data = {}
	self._registryPointer = registryTable
	self._storeProfile = storeProfile
	return self
end

function PlayerProfile:SetData(dataName: PlayerProfileData, value: any)
	if self._data[dataName] ~= nil then
		self._data[dataName] = value

		if self._storeProfile.Data[dataName] then
			self._storeProfile.Data[dataName] = value
		end
	else
		error("Invalid data name: " .. tostring(dataName))
	end
end

function PlayerProfile:GetData(dataName: PlayerProfileData): any
	return self._data[dataName]
end

function PlayerProfile:Destroy()
	self.player = nil
	self.stats = nil
	self._registryPointer[self.player] = nil
	self._registryPointer = nil
end

export type PlayerProfile = {
	player: Player,
	data: {
		SelectedClass: string?,
		Inventory: {},
		Rox: number,
	},
}

type PlayerProfileData = "Inventory" | "Rox" | "SelectedClass"

return PlayerProfile
