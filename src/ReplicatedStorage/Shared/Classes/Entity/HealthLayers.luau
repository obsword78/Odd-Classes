local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DamagePacket = require(ReplicatedStorage.Shared.Classes.DamagePacket)
-------------------------------------------------------
local HealthLayers = {}
HealthLayers.__index = HealthLayers
local HealthLayer = {}
HealthLayer.__index = HealthLayer
-------------------------------------------------------
export type HealthLayers = {
	Raw: { HealthLayer },
	Dirty: boolean,

	AddLayer: (self: HealthLayers, layerData: HealthLayer) -> nil,
	RemoveLayer: (self: HealthLayers, layerPriority: number) -> nil,
	GetTotalCurrentValue: (self: HealthLayers) -> number,
}

export type HealthLayer = {
	Priority: number,
	CurrentValue: number,
	AttemptKillUponDeplete: boolean?,

	AbsorbModification: (number, DamagePacket.DamagePacket) -> number, -- returns shield remaining
	AbsorbCondition: ((DamagePacket.DamagePacket) -> boolean)?,
	OnAbsorb: ((DamagePacket.DamagePacket) -> nil)?,
	OnDeplete: ((DamagePacket.DamagePacket) -> nil)?,
} -------------------------------------------------------
local function basicAbsorbModification(currentValue: number, damagePacket: DamagePacket.DamagePacket)
	local toReduce = math.min(currentValue, damagePacket.amount)
	damagePacket.amount -= toReduce
	return currentValue - toReduce
end

-- local function metalAbsorbModification(currentValue: number, damagePacket: DamagePacket.DamagePacket)
-- 	damagePacket.amount = 0
-- 	return currentValue - 1
-- end
-------------------------------------------------------
function HealthLayers.new(baseHealth: number): HealthLayers
	local self = setmetatable({}, HealthLayers)
	self.Raw = {
		HealthLayer.new(0, baseHealth, true),
	}
	self.Dirty = true
	return self
end

function HealthLayers:AddLayer(layerData: HealthLayer)
	self.Raw[layerData.Priority] = layerData
	self.Dirty = true
end

function HealthLayers:RemoveLayer(layerPriority: number)
	self.Raw[layerPriority] = nil
	self.Dirty = true
end

function HealthLayers:GetOrdered(): { HealthLayer }
	if self.Dirty then
		local orderedLayers = {}
		for _, layerData in pairs(self.Raw) do
			table.insert(orderedLayers, layerData)
		end
		table.sort(orderedLayers, function(a, b)
			return a.Priority > b.Priority
		end)
		self._orderedCache = orderedLayers
		self.Dirty = false
	end
	return self._orderedCache
end
-------------------------------------------------------
function HealthLayer.new(priority: number, startingValue: number, killOnDeplete: boolean?): HealthLayer
	local self = setmetatable({}, HealthLayer)
	self.Priority = priority
	self.CurrentValue = startingValue
	self.AttemptKillUponDeplete = killOnDeplete or false
	self.AbsorbModification = basicAbsorbModification
	return self
end
-------------------------------------------------------
return HealthLayers
