type AbilityDefinition = {
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
	TickRate: number?, -- how often OnTick/OnChannelTick triggers

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

local Ability = {}
Ability.__index = Ability

function Ability.new(definition: AbilityDefinition)
	local self = setmetatable({}, Ability)
	self.Definition = definition
	return self
end

function Ability:GetName(): string
	return self.Definition.Name
end

function Ability:Execute(caster: any, ctx: any): any?
	return self.Definition.Execute and self.Definition.Execute(caster, ctx)
end

return Ability
