local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local signal = require(ReplicatedStorage.Packages.signal)
local DamagePacket = require(ReplicatedStorage.Shared.Classes.DamagePacket)
local HealthLayers = require(ReplicatedStorage.Shared.Classes.Entity.HealthLayers)
local EntityService
----------------------------------------------------------
knit.OnStart():andThen(function()
	EntityService = knit.GetService("EntityService")
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
	local targetEntity = EntityService:GetEntity(damagePacket.target)
	if not targetEntity then
		return
	end
	------------------------------------------
	if targetEntity:GetBoolean("Immune") then
		DamageService.DamageApplied:Fire(damagePacket, false)
		return
	end
	------------------------------------------
	local targetProtection = targetEntity:GetStatValue("Protection")
	local targetResist = targetEntity:GetStatValue("Resist")
	local targetCritReduc = targetEntity:GetStatValue("CritReduction")
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
	damagePacket.amount /= (1 + (defense_to_apply / def_scale))

	if damagePacket.type == "heal" then
		local viability = targetEntity:GetStatValue("Viability")
		damagePacket.amount *= viability / 100
	end
	------------------------------------------
	local healthRuntimeData = targetEntity:GetRuntimeData("Health")
	local orderedHealthLayers = healthRuntimeData:GetOrdered()

	for _, healthLayer: HealthLayers.HealthLayer in pairs(orderedHealthLayers) do
		if healthLayer.AbsorbCondition and not healthLayer.AbsorbCondition(damagePacket) then
			continue
		end

		local remainingHealthLayer = healthLayer.AbsorbModification(healthLayer.CurrentValue, damagePacket)
		local isImmortal = targetEntity:GetStatValue("Immortal")
		if isImmortal and healthLayer.AttemptKillUponDeplete then
			healthLayer.CurrentValue = math.max(1, remainingHealthLayer)
		else
			healthLayer.CurrentValue = remainingHealthLayer
		end
		if healthLayer.OnAbsorb then
			healthLayer.OnAbsorb(damagePacket)
		end
		if remainingHealthLayer <= 0 and healthLayer.OnDeplete then
			healthLayer.OnDeplete(damagePacket)
		end
		if damagePacket.amount <= 0 then
			break
		end
	end
	------------------------------------------
	humanoid.Health = orderedHealthLayers[1].CurrentValue

	DamageService.DamageApplied:Fire(damagePacket, humanoid.Health <= 0)
end

-- function DamageService:IsAttackingMe(damagePacket: DamagePacket.DamagePacket, me: Model, attacker: Model)
-- 	return damagePacket.target == me and damagePacket.source == attacker
-- end

return DamageService
