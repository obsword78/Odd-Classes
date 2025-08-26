export type ClientAbilityDefinition = {
	Name: string, -- Ability name

	CastTime: number?,
	CastAnimationId: string?,
	OnCast: ((player: Player, params: {}?) -> ())?, -- Local callback for prediction

	ChannelTime: number?,
	ChannelTickRate: number?,

	OnChannelTick: (() -> nil)?,
	OnInterrupted: (() -> nil)?,
}

local ClientAbilityDefinitions: { [string]: ClientAbilityDefinition } = {}

ClientAbilityDefinitions.MovingForce = {
	Name = "MovingForce",
	CastTime = 0.5,
	ChannelTime = 2,
	ChannelTickRate = 0.1,

	OnChannelTick = function() end,
	OnInterrupted = function() end,
}

return ClientAbilityDefinitions
