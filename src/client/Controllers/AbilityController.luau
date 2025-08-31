local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local AbilityInstance = require(ReplicatedStorage.Shared.Classes.AbilityInstance)
local ClientAbilityDefinitions = require(ReplicatedStorage.Shared.Data.ClientAbilityDefinitions)
local BattleGuiController

knit.OnStart():andThen(function()
	BattleGuiController = knit.GetController("BattleGuiController")
end)
--------------------------------------------------------------------------------
local AbilityController = knit.CreateController({
	Name = "AbilityController",
})
--------------------------------------------------------------------------------
AbilityController.Cooldowns = {} -- [abilityName] = time
AbilityController.ActiveInstances = {} -- {instances...}
--------------------------------------------------------------------------------
function AbilityController:KnitInit()
	task.defer(function()
		while task.wait(10) do
			local undeadInstances = {}
			for _, activeInstance in pairs(AbilityController.ActiveInstances) do
				if activeInstance:IsDead() then
					continue
				end
				table.insert(undeadInstances, activeInstance)
			end
			if #undeadInstances <= 0 then
				continue
			end
			table.clear(AbilityController.ActiveInstances)
			table.move(undeadInstances, 1, #undeadInstances, 1, AbilityController.ActiveInstances)
		end
	end)
end

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

	local instance = AbilityInstance.new(abilityDef)
	table.insert(AbilityController.ActiveInstances, instance)

	if abilityDef.Cooldown then
		AbilityController.Cooldowns[abilityName] = now + abilityDef.Cooldown
		BattleGuiController:RunCD(abilityDef.AbilitySlot, abilityDef.Cooldown)
	end

	return instance
end

function AbilityController:Release(abilityName: string)
	local abilityDef = ClientAbilityDefinitions[abilityName]
	if not abilityDef then
		return
	end

	for _, activeInstance in pairs(AbilityController.ActiveInstances) do
		if activeInstance:IsDead() or activeInstance.Def.Name ~= abilityName then
			continue
		end
		if activeInstance.ChargeReleased ~= nil then
			activeInstance.ChargeReleased = true
		end
		break
	end
end

return AbilityController
