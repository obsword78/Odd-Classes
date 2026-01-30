local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DamageService = require(ServerScriptService.Server.Services.DamageService)
local DamagePacket = require(ReplicatedStorage.Shared.Classes.DamagePacket)
local EffectTypes = require(ReplicatedStorage.Shared.Types.EffectTypes)
local EffectRegistry: { [string]: EffectTypes.EffectDescription } = {}
local frz = table.freeze
--===========================
EffectRegistry.burn = frz({
	id = "burn",
	baseDuration = 5.0,
	tickInterval = 1.0,
	stackInfo = frz({ type = "stack", max = 5, refreshOnStack = true }),
	priority = 10,
	tags = frz({ "dot", "fire" }),
	onApply = function(effect) end,
	onTick = function(effect)
		local burnPacket = DamagePacket.new({
			amount = 1,
			type = "physical",
			source = effect.source,
			target = effect.target,
		})
		DamageService:Apply(burnPacket)
	end,
	onRemove = function(effect) end,
})

return frz(EffectRegistry)
