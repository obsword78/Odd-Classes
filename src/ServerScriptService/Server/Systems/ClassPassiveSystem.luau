local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerAbilityDefinitions = require(ServerScriptService.Server.ServerData.ServerAbilityDefinitions)
local knit = require(ReplicatedStorage.Packages.knit)
----------------------------------------------------------
-- knit.OnStart():andThen(function() end)
------------------------------------------
local ClassPassiveSystem = knit.CreateService({
	Name = "ClassPassiveSystem",
	Client = {},
})
------------------------------------------
local passiveTickRegistry = {}
local passiveTickRateRegistry = {}
------------------------------------------
function ClassPassiveSystem:KnitStart()
	print("{ClassPassiveSystem} Started")

	RunService.Heartbeat:Connect(function(dt)
		for entity, onTickFunc in pairs(passiveTickRegistry) do
			if table.isfrozen(entity) then
				print("removed")
				passiveTickRegistry[entity] = nil
				passiveTickRateRegistry[entity] = nil
				continue
			end

			local tickRate = passiveTickRateRegistry[entity]
			if tickRate then
				onTickFunc(game.Players:GetPlayerFromCharacter(entity._refObject), dt)
			end
		end
	end)
end

function ClassPassiveSystem:ApplyPassive(entity, passiveDefinitionName: string)
	local passiveDefinition = ServerAbilityDefinitions[passiveDefinitionName]
	if not passiveDefinition then
		return
	end
	if passiveDefinition.OnApply then
		local player = game.Players:GetPlayerFromCharacter(entity._refObject)
		if player then
			passiveDefinition.OnApply(player)
		end
	end
	if passiveDefinition.OnTick then
		passiveTickRegistry[entity] = passiveDefinition.OnTick
		passiveTickRateRegistry[entity] = passiveDefinition.TickRate
	end
end

return ClassPassiveSystem
