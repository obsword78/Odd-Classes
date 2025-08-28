export type SharedAbilityDefinition = {
	Cooldown: number?,

	CastTime: number?,

	Chargeable: boolean?, -- ability key can be held to charge it
	MaxChargeTime: number?,

	ChannelTime: number?,
}

type LocalMetaTable = {
	__index: (definition: any, index: string) -> any,
}

-- StaticAbilityDefinitions are basically all static data/functions that each Ability shares on both Client and Server
local StaticAbilityDefinitions: { [string]: SharedAbilityDefinition | LocalMetaTable } = {}

StaticAbilityDefinitions.MetaTable = {
	__index = function(definition, index)
		return StaticAbilityDefinitions[rawget(definition, "Name")][index]
	end,
}

StaticAbilityDefinitions.MovingForce = {
	Cooldown = 5,
	Chargeable = true,
	MaxChargeTime = 0.4,
	ChannelTime = 5,
}

return StaticAbilityDefinitions
