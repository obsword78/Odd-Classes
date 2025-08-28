export type SharedAbilityDefinition = {
	Name: string,
	Cooldown: number?,

	CastTime: number?,

	Chargeable: boolean?, -- ability key can be held to charge it
	MaxChargeTime: number?,

	ChannelTime: number?,
}

-- StaticAbilityDefinitions are basically all static data/functions that each Ability shares on both Client and Server
local StaticAbilityDefinitions: { [string]: SharedAbilityDefinition } = {}

StaticAbilityDefinitions.MovingForce = {
	Name = "MovingForce",
	Cooldown = 5,
	Chargeable = true,
	MaxChargeTime = 0.4,
	ChannelTime = 5,
}

return StaticAbilityDefinitions
