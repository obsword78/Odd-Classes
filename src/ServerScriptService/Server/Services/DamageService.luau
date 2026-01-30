local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local signal = require(ReplicatedStorage.Packages.signal)
local DamagePacket = require(ReplicatedStorage.Shared.Classes.DamagePacket)
local CustomStatsService
----------------------------------------------------------
knit.OnStart():andThen(function()
	CustomStatsService = knit.GetService("CustomStatsService")
end)
------------------------------------------
local DamageService = knit.CreateService({
	Name = "DamageService",
})
------------------------------------------ LOCAL VARIABLES
local def_scale = 1
local modificationPriority = {
	["Amount%"] = 0,
	["PhysicalPen%"] = 1,
	["MagicalPen%"] = 2,
	["PhysicalPen"] = 3,
	["MagicalPen"] = 4,
}
------------------------------------------ LOCAL FUNCTIONS
local function modification_priority_sort(a, b)
	return modificationPriority[a.type] < modificationPriority[b.type]
end
local function apply_modifications(damagePacket, prot, resist)
	table.sort(damagePacket.modifications, modification_priority_sort)
	for _, modification in damagePacket.modifications do
		if modification.type == "Amount%" then
			damagePacket.amount *= (modification.value / 100)
		elseif modification.type == "PhysicalPen%" then
			prot -= prot * (modification.value / 100)
		elseif modification.type == "MagicalPen%" then
			resist -= resist * (modification.value / 100)
		elseif modification.type == "PhysicalPen" then
			prot -= modification.value
		elseif modification.type == "MagicalPen" then
			resist -= modification.value
		end
	end
	return prot, resist
end
------------------------------------------ SERVICE EVENTS
DamageService.DamageApplied = signal.new()
------------------------------------------ SERVICE FUNCTIONS
function DamageService:Apply(damagePacket: DamagePacket.DamagePacket)
	if not damagePacket.target or not damagePacket.target:IsDescendantOf(workspace) then
		return
	end
	local humanoid = damagePacket.target:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then
		return
	end
	------------------------------------------
	local targetEntityStats = CustomStatsService:GetEntityStats(damagePacket.target)
	if not targetEntityStats then
		return
	end
	------------------------------------------
	if targetEntityStats:GetBoolean("Immune") then
		DamageService.DamageApplied:Fire(damagePacket, false)
		return
	end
	------------------------------------------
	local targetProtection = targetEntityStats:Get("Protection")
	local targetResist = targetEntityStats:Get("Resist")
	local targetCritReduc = targetEntityStats:Get("CritReduction")
	if damagePacket.modifications then
		targetProtection, targetResist = apply_modifications(damagePacket, targetProtection, targetResist)
	end
	if damagePacket.isCritical then
		damagePacket.amount *= (1 - targetCritReduc / 100)
	end
	targetProtection = math.max(0, targetProtection)
	targetResist = math.max(0, targetResist)
	------------------------------------------
	local defense_to_apply = (damagePacket.type == "physical" and targetProtection)
		or (damagePacket.type == "magical" and targetResist)
		or 0
	local damageToDeal = damagePacket.amount / (1 + (defense_to_apply / def_scale))
	local targetHealth = humanoid.Health - damageToDeal
	------------------------------------------
	humanoid.Health = targetEntityStats:Get("Immortal") and math.max(1, targetHealth) or targetHealth

	DamageService.DamageApplied:Fire(damagePacket, humanoid.Health <= 0)
	return humanoid.Health <= 0
end

function DamageService:IsAttackingMe(damagePacket: DamagePacket.DamagePacket, me: Model, attacker: Model)
	return damagePacket.target == me and damagePacket.source == attacker
end

return DamageService
