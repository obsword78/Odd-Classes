local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ClassCustomStats = require(ServerScriptService.Server.ServerData.ClassCustomStats)
local knit = require(ReplicatedStorage.Packages.knit)
local trove = require(ReplicatedStorage.Packages.trove)

local EntityService = knit.CreateService({
	Name = "EntityService",
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
local function ApplyStatsInstance(object: Model)
	local player = Players:GetPlayerFromCharacter(object)
	local humanoid = object:WaitForChild("Humanoid", 10)

	if not humanoid then
		warn(`[EntityService] Humanoid not found in {object}`)
		return
	end

	local StatsInstance = EntityStats.new(object, nil, EntityStats_registry)
	local troveInstance = trove.new()
	EntityStats_registry[object] = StatsInstance
	troveInstance:Add(StatsInstance)
	troveInstance:AttachToInstance(object)

	if player then
		local selectedClass = PlayerService:GetPlayerProfile(player):GetData("SelectedClass")
		if selectedClass then
			if ClassCustomStats[selectedClass] then
				for statName, baseValue in pairs(ClassCustomStats[selectedClass]) do
					StatsInstance:SetCustomStat(statName, baseValue)
				end
			end
		end
	end

	StatsInstance:ImprintHumanoid()
end
------------------------------------------
function EntityService:KnitStart()
	print("[EntityService] Initialized")

	workspace.ChildAdded:Connect(ApplyStatsInstance)
	ApplyStatsInstance(workspace.Surroundings.Dummy)
	ApplyStatsInstance(workspace.Surroundings.MovingDummy)
	ApplyStatsInstance(workspace.Surroundings.MovableDummy)
	ApplyStatsInstance(workspace.Rig)
end

function EntityService:GetEntityStats(entity: Model): EntityStats.EntityStats?
	return EntityStats_registry[entity]
end

return EntityService
