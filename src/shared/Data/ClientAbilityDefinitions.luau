local StaticAbilityDefinitions = require(script.Parent.StaticAbilityDefinitions)

export type ClientAbilityDefinition = typeof(setmetatable(
	{} :: {
		CastAnimationId: string?,

		Execute: ((state: { [string]: any }?) -> { [string]: any }?)?,

		ChannelAnimationId: string?,
		ChannelTickRate: number?,
		OnChannelTick: (() -> nil)?,
		OnInterrupted: ((reason: string) -> nil)?,
	},
	StaticAbilityDefinitions.SharedAbilityDefinition
))
--==========================================================
local ClientAbilityDefinitions: { [string]: ClientAbilityDefinition } = {}
-------------------------
local Player = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
-------------------------
ClientAbilityDefinitions.MovingForce = setmetatable({
	ChannelTickRate = 0.1,
	ChannelAnimationId = "rbxassetid://6881035317",
	Execute = function(state)
		local character = Player.Character

		if state.TimeCharged ~= 0.4 then
			local charBBCFrame, charBBSize = character:GetBoundingBox()
			local result = workspace:Blockcast(charBBCFrame, charBBSize, charBBCFrame.LookVector * 2.5)
			local gap = result and result.Distance or 2.5

			character:PivotTo(character:GetPivot() * CFrame.new(0, 0, -gap))
			state.Dead = true
		else
			local overlapParams = OverlapParams.new()
			overlapParams.FilterDescendantsInstances = { character }
			state.OverlapParams = overlapParams

			character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		end
		return
	end,
	ChannelConditions = function(state: { [string]: any })
		return state.TimeCharged == 0.4
	end,
	OnChannelTick = function(abilityInstance, dT)
		local character = Player.Character
		local cameraLookVector = Camera:GetPivot().LookVector
		local targetLookVector = character:GetPivot().LookVector:Lerp(cameraLookVector, 0.05)
		local pivotTo = CFrame.lookAlong(
			character:GetPivot().Position,
			Vector3.new(targetLookVector.X, 0, targetLookVector.Z)
		) * CFrame.new(0, 0, -50 * dT)

		character.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
		character.PrimaryPart.AssemblyAngularVelocity = Vector3.zero

		character:PivotTo(pivotTo)

		local charBBCFrame, charBBSize = character:GetBoundingBox()
		if #workspace:GetPartBoundsInBox(charBBCFrame, charBBSize, abilityInstance.State.OverlapParams) > 0 then
			abilityInstance:StopChannel("Collision")
		end
	end,
	OnInterrupted = function(_reason: string)
		local character = Player.Character
		character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	end,
}, StaticAbilityDefinitions.MovingForce)

return ClientAbilityDefinitions
