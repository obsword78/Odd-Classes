local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

local DamageService = knit.CreateService({
	Name = "DamageService",
	Client = {},
})

function DamageService:KnitInit()
	print("[DamageService] Initialized")
end

function DamageService:KnitStart()
	print("[DamageService] Started")
end

function DamageService:Damage() end

return DamageService
