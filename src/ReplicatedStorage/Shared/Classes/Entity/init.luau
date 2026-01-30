local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HealthLayers = require(script.HealthLayers)
local deepcopy = require(ReplicatedStorage.Shared.Utils.deepcopy)
local Entity = {}
Entity.__index = Entity
-------------------------------------------------------
export type EntityStatData = { -- numbers or booleans
	WalkSpeed: number?,
	JumpPower: number?,
	MaxBaseHealth: number?,
	Size: number?,

	Protection: number?, -- i think this is physical defense
	Resist: number?, -- i think this is magical defense
	Viability: number?, -- heal effectiveness 100% default
	Rejection: number?, -- chance to reject negative effects
	CritReduction: number?, -- (0% to 100%)

	CritChance: number?,

	Immune: number?,
	Immortal: boolean?,

	[string]: any,
}

export type EntityRuntimeData = { -- data that with object references
	Health: HealthLayers.HealthLayers,
}

export type Entity = {
	_data: EntityStatData,
	_runtimeData: EntityRuntimeData,
	_refObject: Instance?,

	Get: (self: Entity, statName: string) -> any,
	GetBoolean: (self: Entity, statName: string) -> boolean,
	Increment: (self: Entity, statName: string, amount: number) -> nil,
	SetCustomStat: (self: Entity, statName: string, value: any) -> nil,
	ImprintHumanoid: (self: Entity) -> nil,
	Destroy: () -> nil,
}
-------------------------------------------------------
local function imprint_hum_check(self)
	if not self._refObject then
		warn("[Entity] ImprintHumanoid called without a refObject")
		return
	elseif not self._refObject:IsA("Model") then
		warn("[Entity] ImprintHumanoid called on a non-Model")
		return
	elseif not self._refObject:FindFirstChildWhichIsA("Humanoid") then
		warn("[Entity] ImprintHumanoid called on a Model without a Humanoid")
		return
	end
	return true
end
-------------------------------------------------------
function Entity.new(refObject: Instance?, statisticData: { [string]: number }?, runtimeData: EntityRuntimeData?): Entity
	local self = setmetatable({}, Entity)
	self._data = statisticData and deepcopy(statisticData) or {}
	self._runtimeData = runtimeData or {
		Health = HealthLayers.new(self._data.MaxBaseHealth or 100),
	}
	self._refObject = refObject
	return self
end
----------------------------------------------------------------------------------
function Entity:GetStatValue(statName: string)
	return self._data[statName] or 0
end

function Entity:GetBoolean(statName: string)
	return self._data[statName] and true or false
end

function Entity:Increment(statName: string, amount: number)
	if not self._data[statName] then
		self:SetCustomStat(statName, amount)
	end
	self._data[statName] += amount
end

function Entity:SetCustomStat(statName: string, value: any)
	self._data[statName] = value
end
----------------------------------------------------------------------------------
function Entity:GetRuntimeData(dataName: string): any
	return self._runtimeData[dataName]
end
----------------------------------------------------------------------------------
-- Imprint CustomStats, which are meant for the Humanoid, onto the Humanoid
function Entity:ImprintHumanoid()
	if not imprint_hum_check(self) then
		return
	end
	local humanoid = self._refObject.Humanoid

	for statName, value in pairs(self._data) do
		if statName == "WalkSpeed" then
			humanoid.WalkSpeed = value
		elseif statName == "JumpPower" then
			humanoid.JumpPower = value
		elseif statName == "MaxBaseHealth" then
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
----------------------------------------------------------------------------------
function Entity:Destroy() -- TODO: This is not enough
	for _, runtimeData in pairs(self._runtimeData) do
		if typeof(runtimeData) == "table" and runtimeData.Destroy then
			runtimeData:Destroy()
		end
	end
	self._data = nil
	self._runtimeData = nil
	self._refObject = nil
end

return Entity
