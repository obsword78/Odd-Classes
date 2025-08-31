export type SharedAbilityDefinition = {
	Cooldown: number?,
	CastTime: number?,
	Chargeable: boolean?, -- ability key can be held to charge it
	MaxChargeTime: number?,
	ChannelTime: number?,
}

export type SharedPassiveDefinition = {}

type LocalMetaTable = {
	__index: (definition: any, index: string) -> any,
}

-- StaticAbilityDefinitions are basically all static data/functions that each Ability shares on both Client and Server
local StaticAbilityDefinitions: { [string]: SharedAbilityDefinition | SharedPassiveDefinition | LocalMetaTable } = {}
-------------------------
StaticAbilityDefinitions.MetaTable = {
	__index = function(definition, index)
		return StaticAbilityDefinitions[rawget(definition, "Name")][index]
	end,
}
-------------------------
StaticAbilityDefinitions.Punch = {
	Cooldown = 1,
	CastTime = 0.2,
}
-------------------------
StaticAbilityDefinitions.Exertion = {
	Cooldown = 15,
	CastTime = 1,
}
-------------------------
StaticAbilityDefinitions.MovingForce = {
	Cooldown = 10,
	Chargeable = true,
	MaxChargeTime = 0.4,
	ChannelTime = 3,
}
-------------------------
StaticAbilityDefinitions.HeavyImpact = {
	Cooldown = 8,
}
-------------------------
StaticAbilityDefinitions.FinalAdrenaline = {
	Cooldown = 180,
	CastTime = 2,
}

return StaticAbilityDefinitions
