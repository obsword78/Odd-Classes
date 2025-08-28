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

function AbilityService:KnitInit()
	task.defer(function()
		while task.wait(10) do
			for player, activeInstances in pairs(AbilityService.ActiveInstances) do
				local undeadInstances = {}
				for _, activeInstance in pairs(activeInstances) do
					if activeInstance:IsDead() then
						continue
					end
					table.insert(undeadInstances, activeInstance)
				end
				if #undeadInstances <= 0 then
					continue
				end
				table.clear(AbilityService.ActiveInstances[player])
				table.move(undeadInstances, 1, #undeadInstances, 1, AbilityService.ActiveInstances[player])
			end
		end
	end)
end

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
	local instance = AbilityInstance.new(abilityDef, player)
	server.ActiveInstances[player] = server.ActiveInstances[player] or {}
	table.insert(server.ActiveInstances[player] or {}, instance)

	-- set cooldown
	if abilityDef.Cooldown then
		server.Cooldowns[player][abilityName] = now + abilityDef.Cooldown
	end

	return instance
end

function AbilityService.Client:Release(player, abilityName)
	local abilityDef = AbilityDefinitions[abilityName]
	if not abilityDef then
		return
	end

	for _, activeInstance in pairs(AbilityService.ActiveInstances[player]) do
		if activeInstance:IsDead() or activeInstance.Def.Name ~= abilityName then
			continue
		end
		if activeInstance.ChargeReleased ~= nil then
			activeInstance.ChargeReleased = true
		end
		break
	end
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
