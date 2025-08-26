local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local AbilityInstance = require(ReplicatedStorage.Shared.Classes.AbilityInstance)
local ClientAbilityDefinitions = require(ReplicatedStorage.Shared.Data.ClientAbilityDefinitions)

local AbilityController = knit.CreateController({
	Name = "AbilityController",
})

AbilityController.Cooldowns = {} -- [abilityName] = time
AbilityController.ActiveInstances = {} -- {instances...}

function AbilityController:Cast(abilityName: string)
	local abilityDef = ClientAbilityDefinitions[abilityName]
	if not abilityDef then
		return
	end

	local now = os.clock()
	local cd = self.Cooldowns[abilityName]
	if cd and now < cd then
		return
	end

	task.wait(abilityDef.CastTime)
	local instance = AbilityInstance.new(abilityDef)
	table.insert(AbilityController.ActiveInstances, instance)

	if abilityDef.Cooldown then
		AbilityController.Cooldowns[abilityName] = now + abilityDef.Cooldown
	end

	return instance
end

return AbilityController
