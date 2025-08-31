local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local Animations = require(script.Parent.Animations)
local StaticAbilityDefinitions = require(script.Parent.StaticAbilityDefinitions)
local AnimationController

knit.OnStart():andThen(function()
	AnimationController = knit.GetController("AnimationController")
end)

export type ClientAbilityDefinition = typeof(setmetatable(
	{} :: {
		Name: string,
		AbilitySlot: string,

		CastAnimation: Animation?,
		ChargeAnimation: Animation?,
		ChannelAnimation: Animation?,

		Execute: ((state: { [string]: any }?) -> nil)?,

		ChannelTickRate: number?,
		OnChannelTick: (() -> nil)?,
		OnInterrupted: ((reason: string) -> nil)?,
	},
	StaticAbilityDefinitions.MetaTable
))

export type ClientPassiveDefinition = typeof(setmetatable(
	{} :: {
		Name: string,
		AbilitySlot: string,
	},
	StaticAbilityDefinitions.MetaTable
))
--==========================================================
local ClientAbilityDefinitions: { [string]: ClientAbilityDefinition } = {}
-------------------------
local Player = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
-------------------------
ClientAbilityDefinitions.Exertion = setmetatable({
	Name = "Exertion",
	AbilitySlot = "E",
	Execute = function(_state) end,
}, StaticAbilityDefinitions.MetaTable)
-------------------------
ClientAbilityDefinitions.MovingForce = setmetatable({
	Name = "MovingForce",
	AbilitySlot = "F",
	ChargeAnimation = Animations.Abilities.MovingForceCharge,
	ChannelAnimation = Animations.Abilities.MovingForceChannel,
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
		local hitModels = {}
		local partsInBox = workspace:GetPartBoundsInBox(charBBCFrame, charBBSize, abilityInstance.State.OverlapParams)

		for _, object in pairs(partsInBox) do
			if table.find(hitModels, object.Parent) then
				continue
			end
			abilityInstance.State.OverlapParams:AddToFilter(object.Parent)
			table.insert(hitModels, object.Parent)

			if not object.Parent:FindFirstChild("Humanoid") or object.Parent.PrimaryPart.Anchored then
				abilityInstance:StopChannel("Collision")
			end
		end
	end,
	OnInterrupted = function(reason: string)
		local character = Player.Character
		character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

		if reason == "Collision" then
			AnimationController:LoadAnimation(Animations.Abilities.MovingForceCollision):Play()
		elseif reason == "ChannelRanOut" then
			AnimationController:LoadAnimation(Animations.Abilities.MovingForceNoCollision):Play()
		end
	end,
}, StaticAbilityDefinitions.MetaTable)
-------------------------
ClientAbilityDefinitions.HeavyImpact = setmetatable({
	Name = "HeavyImpact",
	AbilitySlot = "R",
	Execute = function(_state) end,
}, StaticAbilityDefinitions.MetaTable)
-------------------------
ClientAbilityDefinitions.FinalAdrenaline = setmetatable({
	Name = "FinalAdrenaline",
	AbilitySlot = "1",
	Execute = function(_state) end,
}, StaticAbilityDefinitions.MetaTable)

return ClientAbilityDefinitions
