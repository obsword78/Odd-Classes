local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StaticAbilityDefinitions = require(ReplicatedStorage.Shared.Data.StaticAbilityDefinitions)
export type ServerAbilityDefinition = typeof(setmetatable(
	{} :: {
		-- ResourceCost: number? | ((caster: any) -> number)?,
		-- CooldownIgnoresCDR: boolean?,

		Execute: ((caster: any, ctx: any) -> any?)?,

		ChannelTickRate: number?,
		OnChannelTick: ((caster: any, castData: any) -> ())?,
		OnInterrupted: ((caster: any, reason: string) -> ())?,
	},
	StaticAbilityDefinitions.SharedAbilityDefinition
))
--=================================================
local ServerAbilityDefinitions: { [string]: ServerAbilityDefinition } = {}

ServerAbilityDefinitions.MovingForce = setmetatable({
	ChannelTickRate = 0.1,
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
	OnChannelTick = function(abilityInstance, dT)
		local character = abilityInstance.Caster.Character

		local charBBCFrame, charBBSize = character:GetBoundingBox()
		local hit = {}

		for _, object in
			pairs(workspace:GetPartBoundsInBox(charBBCFrame, charBBSize, abilityInstance.State.OverlapParams))
		do
			if not object.Parent:IsA("Model") or table.find(hit, object.Parent) then
				continue
			end
			table.insert(hit, object.Parent)
		end

		if #hit > 0 then
			-- for _, _objectHit in pairs(hit) do
			-- end
			abilityInstance:StopChannel("Collision")
		end
	end,
	OnInterrupted = function(caster: Player, reason: string)
		print(caster, reason)
	end,
}, StaticAbilityDefinitions.MovingForce)

return ServerAbilityDefinitions
