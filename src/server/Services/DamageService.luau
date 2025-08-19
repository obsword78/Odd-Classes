local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

local DamageService = knit.createService({
	Name = "DamageService",
	Client = {},
})

function DamageService:KnitInit()
	print("[DamageService] Initialized")
end

function DamageService:KnitStart()
	print("[DamageService] Started")
end

return DamageService
