export type ServerAbilityDefinition = {
	-- Basic info
	Name: string,
	Cooldown: number?,
	ResourceCost: number? | ((caster: any) -> number)?,
	CooldownIgnoresCDR: boolean?,

	-- Casting / charge
	CastTime: number?, -- windup before Execute
	Chargeable: boolean?, -- ability key can be held to charge it
	MinChargeTime: number?,
	MaxChargeTime: number?,

	-- Channeling
	ChannelTime: number?,
	TickRate: number?, -- how often OnLingerTick/OnChannelTick triggers

	-- Recasting
	RecastWindow: number | "infinite"?,
	AutoRecast: boolean?,
	MaxRecasts: number?,
	RecastCondition: ((caster: any, castData: any) -> boolean)?,
	Recast: ((caster: any, castData: any) -> any?)?, -- return new castData

	-- Execution / events
	CanCast: ((caster: any, ctx: any) -> (boolean, string?))?,
	OnCastStart: ((caster: any, ctx: any) -> ())?,
	Execute: ((caster: any, ctx: any) -> any?)?,
	OnCastEnd: ((caster: any, ctx: any, castData: any) -> ())?,

	OnChannelStart: ((caster: any, castData: any) -> ())?,
	OnChannelTick: ((caster: any, castData: any) -> ())?,
	OnInterrupted: ((caster: any, why: string, castData: any) -> ())?,

	-- Lingering / persistent effects
	Duration: number?, -- optional total lifetime
	OnLingerStart: ((caster: any, castData: any) -> ())?,
	OnLingerTick: ((caster: any, castData: any) -> ())?,
	OnExpire: ((caster: any, castData: any) -> ())?,
}

local ServerAbilityDefinitions: { [string]: ServerAbilityDefinition } = {}

ServerAbilityDefinitions.MovingForce = {
	Name = "MovingForce",
	CastTime = 0.5,
	ChannelTime = 2,
	TickRate = 0.1,

	OnChannelTick = function(caster: Player, castData)
		local character = caster.Character
		print(character, castData)
	end,
	OnInterrupted = function(caster: Player, reason, castData)
		print(caster, reason, castData)
	end,
}

return ServerAbilityDefinitions
