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

local EntityStats = require(ReplicatedStorage.Shared.Classes.Entity)
local EntityStats_registry = {}
------------------------------------------
local PlayerService
knit.OnStart():andThen(function()
	PlayerService = knit.GetService("PlayerService")
end)
------------------------------------------
local function CleanFromRegistry(object: Model)
	local statsInstance = EntityStats_registry[object]
	if statsInstance then
		statsInstance:Destroy()
		EntityStats_registry[object] = nil
	end
end

local function ApplyStatsInstance(object: Model)
	local humanoid = object:WaitForChild("Humanoid", 10)

	if not humanoid then
		warn(`[EntityService] Humanoid not found in {object}`)
		return
	end

	local StatsInstance = EntityStats.new(object, nil)
	local troveInstance = trove.new()
	EntityStats_registry[object] = StatsInstance
	troveInstance:Add(function()
		CleanFromRegistry(object)
	end)
	troveInstance:AttachToInstance(object)

	local player = Players:GetPlayerFromCharacter(object)
	if player then
		local selectedClass = PlayerService:GetPlayerProfile(player):GetData("SelectedClass")
		if selectedClass and ClassCustomStats[selectedClass] then
			for statName, baseValue in pairs(ClassCustomStats[selectedClass]) do
				StatsInstance:SetCustomStat(statName, baseValue)
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

-- Get Entity Object for a given Model (ref_object)
function EntityService:GetEntity(ref_object: Model): EntityStats.Entity?
	return EntityStats_registry[ref_object]
end

return EntityService
