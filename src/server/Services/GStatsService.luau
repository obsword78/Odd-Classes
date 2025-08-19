local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

local GStatsService = knit.createService({
    Name = "GStatsService",
    Client = {},
})

local Stats = require(ReplicatedStorage.Shared.Classes.Stats)

function GStatsService.Init()
	print("[GStatsService] Initialized")

	workspace.ChildAdded:Connect(function(child)
        if not Players:GetPlayerFromCharacter(child) then return end
        local character = child
        local humanoid = character:WaitForChild("Humanoid", 10)

        if not humanoid then
            warn("[GStatsService] Humanoid not found in character")
            return
        end

        humanoid.WalkSpeed = 
	end)
end

return GStatsService
