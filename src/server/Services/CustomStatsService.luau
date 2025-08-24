local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

local CustomStatsService = knit.CreateService({
	Name = "CustomStatsService",
	Client = {},
})

local GStats = require(ReplicatedStorage.Shared.Classes.EntityStats)

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

		local StatsInstance = GStats.new(character)
		StatsInstance:ImprintHumanoid()
	end)
end

return CustomStatsService
