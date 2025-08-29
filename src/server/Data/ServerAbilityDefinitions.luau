local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local StaticAbilityDefinitions = require(ReplicatedStorage.Shared.Data.StaticAbilityDefinitions)
export type ServerAbilityDefinition = typeof(setmetatable(
	{} :: {
		Name: string,
		ResourceCost: number? | ((caster: any) -> number)?,
		-- CooldownIgnoresCDR: boolean?,
		OnCastStart: ((caster: Player) -> any?)?,

		Execute: ((caster: any, ctx: any) -> any?)?,

		ChannelTickRate: number?,
		OnChannelTick: ((caster: any, castData: any) -> ())?,
		OnInterrupted: ((caster: any, reason: string) -> ())?,
	},
	StaticAbilityDefinitions.MetaTable
))
--=================================================
local ServerAbilityDefinitions: { [string]: ServerAbilityDefinition } = {}

local CustomStatsService
knit.OnStart():andThen(function()
	CustomStatsService = knit.GetService("CustomStatsService")
end)

ServerAbilityDefinitions.MovingForce = setmetatable({
	Name = "MovingForce",
	ChannelTickRate = 0.02,
	OnCastStart = function(caster: Player)
		local entityStats = CustomStatsService:GetEntityStats(caster.Character)
		entityStats:Increment("Stamina", -10)
	end,
	Execute = function(caster: Player, state)
		local character = caster.Character

		if state.TimeCharged == 0.4 then
			local overlapParams = OverlapParams.new()
			overlapParams.FilterDescendantsInstances = { character }
			state.OverlapParams = overlapParams
		else
			local charBBCFrame, charBBSize = character:GetBoundingBox()
			local result = workspace:Blockcast(charBBCFrame, charBBSize, charBBCFrame.LookVector * 4)

			if result then
				print(`Bashed {result.Instance.Parent}`)
			end

			state.Dead = true
		end
	end,
	ChannelConditions = function(state: { [string]: any })
		return state.TimeCharged == 0.4
	end,
	OnChannelTick = function(abilityInstance, _dT)
		local character = abilityInstance.Caster.Character

		local charBBCFrame, charBBSize = character:GetBoundingBox()
		local serverLeeway = 5
		-- local hit = {}

		-- debugPart.CFrame = charBBCFrame
		-- debugPart.Size = charBBSize + Vector3.new(0, 0, serverLeeway)

		if
			#workspace:GetPartBoundsInBox(
				charBBCFrame * CFrame.new(0, 0, -serverLeeway / 2),
				charBBSize + Vector3.new(0, 0, serverLeeway),
				abilityInstance.State.OverlapParams
			) > 0
		then
			abilityInstance:StopChannel("Collision")
		end

		-- for _, object in
		-- 	pairs(workspace:GetPartBoundsInBox(charBBCFrame, charBBSize, abilityInstance.State.OverlapParams))
		-- do
		-- 	if not object.Parent:IsA("Model") or table.find(hit, object.Parent) then
		-- 		continue
		-- 	end
		-- 	table.insert(hit, object.Parent)
		-- end

		-- if #hit > 0 then
		-- 	-- for _, _objectHit in pairs(hit) do
		-- 	-- end
		-- end
	end,
	OnInterrupted = function(_caster: Player, _reason: string)
		-- print(caster, reason)
	end,
}, StaticAbilityDefinitions.MetaTable)

return ServerAbilityDefinitions
