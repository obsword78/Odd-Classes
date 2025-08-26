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

local Players = game:GetService("Players")

local ClientAbilityDefinitions: { [string]: ClientAbilityDefinition } = {}

local Player = Players.LocalPlayer

ClientAbilityDefinitions.MovingForce = {
	Name = "MovingForce",
	CastTime = 0.5,
	ChannelTime = 2,

	Execute = function(caster: Player, params: { any }) end,
	OnChannelTick = function(_, dT)
		local character = Player.Character
		character:PivotTo(character:GetPivot() * CFrame.new(0, 0, -100 * dT))
	end,
	OnInterrupted = function() end,
}

return ClientAbilityDefinitions
