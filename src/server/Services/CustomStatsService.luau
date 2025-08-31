local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ClassCustomStats = require(ServerScriptService.Server.Data.ClassCustomStats)
local knit = require(ReplicatedStorage.Packages.knit)
local trove = require(ReplicatedStorage.Packages.trove)

local CustomStatsService = knit.CreateService({
	Name = "CustomStatsService",
	Client = {},
})

local EntityStats = require(ReplicatedStorage.Shared.Classes.EntityStats)
local EntityStats_registry = {}
------------------------------------------
local PlayerService
knit.OnStart():andThen(function()
	PlayerService = knit.GetService("PlayerService")
end)
------------------------------------------

function CustomStatsService:KnitInit()
	print("[CustomStatsService] Initialized")

	workspace.ChildAdded:Connect(function(child)
		local player = Players:GetPlayerFromCharacter(child)
		if not player then
			return
		end
		local character = child
		local humanoid = character:WaitForChild("Humanoid", 10)

		if not humanoid then
			warn("[CustomStatsService] Humanoid not found in character")
			return
		end

		local StatsInstance = EntityStats.new(character, nil, EntityStats_registry)
		EntityStats_registry[character] = StatsInstance

		local selectedClass = PlayerService:GetPlayerProfile(player):GetData("SelectedClass")
		if selectedClass then
			if ClassCustomStats[selectedClass] then
				for statName, baseValue in pairs(ClassCustomStats[selectedClass]) do
					StatsInstance:SetCustomStat(statName, baseValue)
				end
			end
		end

		StatsInstance:ImprintHumanoid()

		local troveInstance = trove.new()
		troveInstance:Add(StatsInstance)
		troveInstance:AttachToInstance(player)
	end)
end

function CustomStatsService:GetEntityStats(entity: Model): EntityStats.EntityStats?
	return EntityStats_registry[entity]
end

return CustomStatsService
