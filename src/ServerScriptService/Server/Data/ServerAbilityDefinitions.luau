local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local EffectService = require(ServerScriptService.Server.Services.EffectService)
local knit = require(ReplicatedStorage.Packages.knit)
local DamagePacket = require(ReplicatedStorage.Shared.Classes.DamagePacket)
local StaticAbilityDefinitions = require(ReplicatedStorage.Shared.Data.StaticAbilityDefinitions)
local CustomStatsService
local PoolService
local DamageService
--------------------------------------
knit.OnStart():andThen(function()
	CustomStatsService = knit.GetService("CustomStatsService")
	PoolService = knit.GetService("PoolService")
	DamageService = knit.GetService("DamageService")
end)
--------------------------------------
export type ServerAbilityDefinition = {
	Name: string,
	ResourceCost: number? | ((caster: any) -> number)?,
	-- CooldownIgnoresCDR: boolean?,
	OnCastStart: ((caster: Player) -> any?)?,

	OnChargeStart: ((caster: Player, state: any) -> nil)?,

	Execute: ((caster: any, ctx: any) -> any?)?,

	ChannelTickRate: number?,
	OnChannelTick: ((caster: any, castData: any) -> ())?,
	OnInterrupted: ((caster: any, state: any, reason: string) -> ())?,
}
export type ServerPassiveDefinition = {
	Name: string,
	OnApply: ((caster: Player) -> ())?,
	OnTick: ((caster: Player, dt: number) -> ())?,
}
export type ServerDefinition = typeof(setmetatable(
	{} :: ServerAbilityDefinition | ServerPassiveDefinition,
	StaticAbilityDefinitions.MetaTable
))
--=================================================
local ServerAbilityDefinitions: { [string]: ServerDefinition } = {}
-------------------------
ServerAbilityDefinitions.Punch = setmetatable({
	Name = "Punch",
	Execute = function(caster, state)
		-- local entityStats = CustomStatsService:GetEntityStats(caster.Character)
		local newDamagePacket = DamagePacket.new({
			amount = 10,
			type = "physical",
			source = caster.Character,
			target = caster.Character,
		})
		DamageService:Apply(newDamagePacket)
		-- if entityStats:Get("EmpowerPunch") then
		-- else
		-- end
	end,
}, StaticAbilityDefinitions.MetaTable)
-------------------------
ServerAbilityDefinitions.Exertion = setmetatable({
	Name = "Exertion",
	Execute = function(caster, state)
		-- Damage receive event
	end,
}, StaticAbilityDefinitions.MetaTable)
-------------------------
ServerAbilityDefinitions.MovingForce = setmetatable({
	Name = "MovingForce",
	ChannelTickRate = 0.02,
	OnChargeStart = function(caster: Player)
		local entityStats = CustomStatsService:GetEntityStats(caster.Character)
		entityStats:Increment("Stamina", -10)
	end,
	Execute = function(caster: Player, state)
		local character = caster.Character

		if state.TimeCharged == 0.4 then
			local overlapParams = OverlapParams.new()
			overlapParams.FilterDescendantsInstances = { character }
			state.OverlapParams = overlapParams
			state.Dragged = {}
		else
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { character }
			local charBBCFrame, charBBSize = character:GetBoundingBox()
			local result = workspace:Blockcast(charBBCFrame, charBBSize, charBBCFrame.LookVector * 6, raycastParams)

			if result and result.Instance.Parent:FindFirstChildWhichIsA("Humanoid") then
				local newDamagePacket = DamagePacket.new({
					amount = 20,
					type = "physical",
					source = caster.Character,
					target = result.Instance.Parent,
				})
				EffectService:ApplyEffect(result.Instance.Parent, "burn", caster.Character)
				DamageService:Apply(newDamagePacket)
				print(`Bashed {result.Instance.Parent}`)
			end

			state.Dead = true
		end
	end,
	ChannelConditions = function(state: { [string]: any })
		return state.TimeCharged == 0.4
	end,
	OnChannelTick = function(abilityInstance, _dT)
		local character: Model = abilityInstance.Caster.Character

		local charBBCFrame, charBBSize = character:GetBoundingBox()
		local serverLeeway = 3.8
		local hitModels = {}
		local partsInBox = workspace:GetPartBoundsInBox(
			charBBCFrame * CFrame.new(0, 0, -serverLeeway / 2),
			charBBSize + Vector3.new(0, 0, serverLeeway),
			abilityInstance.State.OverlapParams
		)

		for _, object in pairs(partsInBox) do
			if table.find(hitModels, object.Parent) then
				continue
			end
			abilityInstance.State.OverlapParams:AddToFilter(object.Parent)
			table.insert(hitModels, object.Parent)

			if object.Parent:FindFirstChildWhichIsA("Humanoid") and not object.Parent.PrimaryPart.Anchored then
				object.Parent:PivotTo(character:GetPivot() * CFrame.new(0, 0, -3))

				local newDamagePacket = DamagePacket.new({
					amount = 25,
					type = "physical",
					source = abilityInstance.Caster.Character,
					target = object.Parent,
				})
				if DamageService:Apply(newDamagePacket) then
					continue
				end

				local weld = PoolService:GetItemOf("WeldConstraint")
				weld.Part0 = character.PrimaryPart
				weld.Part1 = object.Parent.PrimaryPart
				weld.Name = `{object.Parent.Name}%physicaldrag%{character.Name}`
				weld.Parent = character.PrimaryPart
				table.insert(abilityInstance.State.Dragged, weld)
			else
				abilityInstance:StopChannel("Collision")
				break
			end
		end
	end,
	OnInterrupted = function(_caster: Player, state, reason: string)
		for _, weld in pairs(state.Dragged) do
			if reason == "Collision" then
				local newDamagePacket = DamagePacket.new({
					amount = 40,
					type = "physical",
					source = _caster.Character,
					target = weld.Part1.Parent,
				})
				DamageService:Apply(newDamagePacket)
			end
			weld:release()
		end
		state.Dead = true
	end,
}, StaticAbilityDefinitions.MetaTable)
-------------------------
ServerAbilityDefinitions.HeavyImpact = setmetatable({
	Name = "HeavyImpact",
	Execute = function(caster, state)
		local entityStats = CustomStatsService:GetEntityStats(caster.Character)
		-- Punch cooldown reset
		entityStats:SetCustomStat("EmpowerPunch", true)
	end,
}, StaticAbilityDefinitions.MetaTable)
-------------------------
ServerAbilityDefinitions.FinalAdrenaline = setmetatable({
	Name = "FinalAdrenaline",
	Execute = function(caster, state)
		local entityStats = CustomStatsService:GetEntityStats(caster.Character)
		entityStats:SetCustomStat("FinalAdrenaline", true)
	end,
}, StaticAbilityDefinitions.MetaTable)

return ServerAbilityDefinitions
