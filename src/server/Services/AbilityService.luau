local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local AbilityInstance = require(ReplicatedStorage.Shared.Classes.AbilityInstance)
local AbilityDefinitions = require(ServerScriptService.Server.Data.ServerAbilityDefinitions)
local knit = require(ReplicatedStorage.Packages.knit)

local AbilityService = knit.CreateService({
	Name = "AbilityService",
	Client = {},
})

AbilityService.Cooldowns = {} -- [player][abilityName] = time
AbilityService.ActiveInstances = {} -- [player] = {instances...}

-- Cast ability
function AbilityService.Client:Cast(player, abilityName)
	local server = self.Server
	local abilityDef = AbilityDefinitions[abilityName]
	if not abilityDef then
		return
	end

	-- cooldown check
	local now = os.clock()
	server.Cooldowns[player] = server.Cooldowns[player] or {}
	local cd = server.Cooldowns[player][abilityName]
	if cd and now < cd then
		return
	end

	-- start ability
	task.wait(abilityDef.CastTime)
	local instance = AbilityInstance.new(abilityDef, player)
	table.insert(server.ActiveInstances[player] or {}, instance)

	-- set cooldown
	if abilityDef.Cooldown then
		server.Cooldowns[player][abilityName] = now + abilityDef.Cooldown
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
