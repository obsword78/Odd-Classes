-- ServerScriptService/Services/EffectService.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local EffectInstance = require(ReplicatedStorage.Shared.Classes.EffectInstance)
local EffectRegistry = require(ReplicatedStorage.Shared.ReplicatedData.EffectRegistry)
--=================================================
local EffectService = Knit.CreateService({
	Name = "EffectService",
	Client = {
		EffectApplied = Knit.CreateSignal(),
		EffectRemoved = Knit.CreateSignal(),
	},
})
EffectService.ActiveEffects = {} -- [entity] = { [effectName] = EffectInstance }
--=================================================
function EffectService:ApplyEffect(target, effectName, source, stack: number)
	local definition = EffectRegistry[effectName]
	if not definition then
		warn(`Effect not defined: {effectName}`)
		return
	end

	self.ActiveEffects[target] = self.ActiveEffects[target] or {}

	local existingInstance = self.ActiveEffects[target][effectName]

	if existingInstance and existingInstance.stackInfo then
		self.ActiveEffects[target][effectName]:StackApply()
	else
		self.ActiveEffects[target][effectName] = EffectInstance.new(definition, target, source)
	end
	self.Client.EffectApplied:FireAll(target, effectName)
end

function EffectService:RemoveEffect(target, effectName)
	if self.ActiveEffects[target] and self.ActiveEffects[target][effectName] then
		self.ActiveEffects[target][effectName]:Destroy()
		self.ActiveEffects[target][effectName] = nil
		self.Client.EffectRemoved:FireAll(target, effectName)
	end
end

function EffectService:KnitStart()
	task.spawn(function()
		while true do
			for target, effects in pairs(self.ActiveEffects) do
				-- if entity is gone, remove it from EffectService's ActiveRegistry

				for effectName, effect in pairs(effects) do
					if effect:IsExpired() then
						self:RemoveEffect(target, effectName)
					elseif effect.descriptor.onTick and effect.descriptor.tickInterval then
						if not effect._lastTick or os.clock() - effect._lastTick >= effect.descriptor.tickInterval then
							effect.descriptor.onTick(effect)
							effect._lastTick = os.clock()
						end
					end
				end
			end
			task.wait(0.2) -- tick interval (server load tradeoff)
		end
	end)
end

return EffectService
