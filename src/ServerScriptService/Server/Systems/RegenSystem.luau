local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local DamagePacket = require(ReplicatedStorage.Shared.Classes.DamagePacket)
local EntityService = require(script.Parent.Parent.Services.EntityService)
local DamageService
----------------------------------------------------------
knit.OnStart():andThen(function()
	DamageService = knit.GetService("DamageService")
end)
------------------------------------------
local RegenSystem = knit.CreateService({
	Name = "RegenSystem",
	Client = {},
})
------------------------------------------
local regenRate = 0.5
------------------------------------------
function RegenSystem:KnitStart()
	print("{RegenSystem} Started")

	local Entities_registry = EntityService:_GetRegistry()
	task.spawn(function()
		while task.wait(regenRate) do
			for _, entity in pairs(Entities_registry) do
				local totalTickRegen = 0
				if entity:GetBoolean("BaseRegeneration") then
					totalTickRegen += entity:GetStatValue("BaseRegeneration")
				end
				if entity:GetRuntimeData("BonusRegeneration") then
					for _, value in pairs(entity:GetRuntimeData("BonusRegeneration")) do
						totalTickRegen += value
					end
				end

				if
					totalTickRegen <= 0
					or entity:GetRuntimeData("Health").Raw[1].CurrentValue >= entity:GetStatValue("MaxBaseHealth")
				then
					continue
				end

				local regenPacket = DamagePacket.new({
					amount = -totalTickRegen * regenRate,
					type = "healing",
					source = entity._refObject,
					target = entity._refObject,
					tags = { "regeneration" },
				})
				DamageService:Apply(regenPacket)
			end
		end
	end)
end

return RegenSystem
