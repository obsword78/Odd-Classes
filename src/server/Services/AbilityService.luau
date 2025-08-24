--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Ability = require(ServerScriptService.Server.Classes.Ability)
local AbilityInstance = require(ServerScriptService.Server.Classes.AbilityInstance)
local knit = require(ReplicatedStorage.Packages.knit)

local AbilityService = knit:CreateService({
	Name = "AbilityService",
	Client = {},
})

AbilityService.Abilities = {} -- [name] = Ability
AbilityService.Cooldowns = {} -- [player][abilityName] = time
AbilityService.ActiveInstances = {} -- [player] = {instances...}

-- Register an ability
function AbilityService:RegisterAbility(definition)
	local ability = Ability.new(definition)
	self.Abilities[ability.Name] = ability
	return ability
end

-- Cast ability
function AbilityService:Cast(player, abilityName, params)
	local ability = self.Abilities[abilityName]
	if not ability then
		return
	end

	-- cooldown check
	local now = os.clock()
	self.Cooldowns[player] = self.Cooldowns[player] or {}
	local cd = self.Cooldowns[player][abilityName]
	if cd and now < cd then
		return
	end

	-- start ability
	local instance = AbilityInstance.new(ability, player, params)
	table.insert(self.ActiveInstances[player] or {}, instance)

	-- set cooldown
	if ability.Cooldown then
		self.Cooldowns[player][abilityName] = now + ability.Cooldown
	end

	return instance
end

-- Try recast
function AbilityService:TryRecast(player, abilityName)
	local instances = self.ActiveInstances[player]
	if not instances then
		return
	end
	for _, inst in ipairs(instances) do
		if inst.Ability.Name == abilityName and not inst.Expired then
			if inst:TryRecast() then
				return inst
			end
		end
	end
end

return AbilityService
