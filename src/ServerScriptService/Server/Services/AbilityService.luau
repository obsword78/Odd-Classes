local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local AbilityInstance = require(ReplicatedStorage.Shared.Classes.AbilityInstance)
local AbilityDefinitions = require(ServerScriptService.Server.ServerData.ServerAbilityDefinitions)
local knit = require(ReplicatedStorage.Packages.knit)

local AbilityService = knit.CreateService({
	Name = "AbilityService",
	Client = {},
})

AbilityService.Cooldowns = {} -- [player][abilityName] = time
AbilityService.ActiveInstances = {} -- [player] = {instances...}
--------------------------------------------------------------------------------
local function checkAbilityValid(abilityName: string)
	local abilityDef = AbilityDefinitions[abilityName]
	if not abilityDef then
		warn(`[AbilityService] {abilityName} is not a valid Ability Name`)
	end
	return abilityDef
end
--------------------------------------------------------------------------------
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
				if next(undeadInstances) == nil then
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
	local abilityDef = checkAbilityValid(abilityName)
	if not abilityDef then
		return
	end
	-------------------- Cooldown Check
	local now = os.clock()
	server.Cooldowns[player] = server.Cooldowns[player] or {}
	local cd = server.Cooldowns[player][abilityName]
	if cd and now < cd then
		return
	end
	-------------------- Make AbilityInstance
	local instance = AbilityInstance.new(abilityDef, player)
	server.ActiveInstances[player] = server.ActiveInstances[player] or {}
	table.insert(server.ActiveInstances[player] or {}, instance)
	-------------------- Set Cooldown
	if abilityDef.Cooldown then
		server.Cooldowns[player][abilityName] = now + abilityDef.Cooldown
	end

	return instance
end

function AbilityService.Client:Release(player, abilityName)
	local abilityDef = checkAbilityValid(abilityName)
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

---------------------------------------------------------------

function AbilityService:Interrupt(player: Player, reason: string?)
	if not AbilityService.ActiveInstances[player] then
		return
	end
	for _, activeInstance in AbilityService.ActiveInstances[player] do
		activeInstance:Kill(reason)
	end
end

function AbilityService:ReduceCD(player: Player, abilityName: string, seconds: number)
	local abilityDef = checkAbilityValid(abilityName)
	if not abilityDef then
		return
	end
	self.Cooldowns[player][abilityName] -= seconds
end

function AbilityService:CancelCD(player: Player, abilityName: string)
	local abilityDef = checkAbilityValid(abilityName)
	if not abilityDef then
		return
	end
	self.Cooldowns[player][abilityName] = -1
end

return AbilityService
