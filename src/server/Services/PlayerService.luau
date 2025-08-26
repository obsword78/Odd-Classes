local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local knit = require(ReplicatedStorage.Packages.knit)
local trove = require(ReplicatedStorage.Packages.trove)

local PlayerService = knit.CreateService({
	Name = "PlayerService",
	Client = {},
})
--=============================================================
local PlayerProfile = require(ReplicatedStorage.Shared.Classes.PlayerProfile)
local playerProfiles: { [Player]: PlayerProfile.PlayerProfile } = {}
---------------------------------------------------------------
local PROFILE_TEMPLATE = {
	Inventory = {},
	Rox = 0,
}
local PlayerStore = ProfileStore.New("PlayerProfiles", PROFILE_TEMPLATE)
local PlayerStoreProfiles: { [Player]: typeof(PlayerStore:StartSessionAsync()) } = {}
---------------------------------------------------------------
function PlayerService:KnitInit()
	print("[PlayerService] Initialized")

	Players.PlayerAdded:Connect(function(player)
		--------------------------------------------------------------------
		local storeProfile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
			Cancel = function()
				return player.parent ~= Players
			end,
		})

		if storeProfile then
			storeProfile:AddUserId(player.UserId)
			storeProfile:Reconcile()

			storeProfile.OnSessionEnd:Connect(function()
				PlayerStoreProfiles[player] = nil
				player:Kick("Your profile has ended. Please rejoin.")
			end)

			if player.Parent == Players then
				PlayerStoreProfiles[player] = storeProfile
			else -- Left before session could be created
				storeProfile:EndSession()
			end
		else
			player:Kick("Player data profile could not be created.")
		end
		---------------------------------------------------------------------
		local playerProfile = PlayerProfile.new(player, playerProfiles)
		local troveInstance = trove.new()
		troveInstance:Add(playerProfile)
		troveInstance:AttachToInstance(player)

		playerProfile:SetData("Inventory", storeProfile.Data.Inventory)
		playerProfile:SetData("Rox", storeProfile.Data.Rox)

		playerProfiles[player] = playerProfile

		print("[PlayerService] Player added:", player.Name)
	end)
end

function PlayerService:GetPlayerProfile(player: Player): PlayerProfile.PlayerProfile?
	return playerProfiles[player]
end

function PlayerService.Client:SelectClass(player: Player, className: string)
	playerProfiles[player]:SetData("SelectedClass", className)
end

return PlayerService

-- FAQ for future Developers (mainly just Creator actually, he's a little dementic):
-- 1. Why are there PlayerProfile instances AND StoreProfiles, why not just remove PlayerProfiles?
--    Yes, StoreProfiles support data caching like PlayerProfiles,
--    but there are exclusive properties like SelectedClass
--    which shouldn't be saved persistently and stored in the StoreProfile.
