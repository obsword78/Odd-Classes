local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientAbilityDefinitions = require(ReplicatedStorage.Shared.Data.ClientAbilityDefinitions)
local RunService = game:GetService("RunService")
local knit = require(ReplicatedStorage.Packages.knit)
local BattleGuiController

knit.OnStart():andThen(function()
	BattleGuiController = knit.GetController("BattleGuiController")
end)

type AbilityInstanceState = {
	TimeCharged: number?,
	Dead: boolean?,
}

type AbilityInstance = {
	Def: ClientAbilityDefinitions.ClientAbilityDefinition,
	State: AbilityInstanceState,
	StartTime: number,
	StoppedChannel: boolean,
	Expired: boolean,

	StopChannel: (self: AbilityInstance, reason: string) -> nil,
}

local AbilityInstance = {}
AbilityInstance.__index = AbilityInstance

local function _startCast(self)
	BattleGuiController:RunCastBar(self.Def.CastTime)
	task.wait(self.Def.CastTime)
	self:_Flow(false)
end
local function _startCharge(self)
	self.ChargeReleased = false
	while not self.ChargeReleased and (os.clock() - self.StartTime) < (self.Def.MaxChargeTime or 3) do
		task.wait()
	end
	self.State.TimeCharged = math.min(os.clock() - self.StartTime, self.Def.MaxChargeTime or 3)
	self:_Flow(false)
end
local function _flow(self)
	if self.Def.Execute then
		self:_Execute()
	end
	if self.Def.ChannelTime then
		self:_StartChannel()
	end
end

function AbilityInstance.new(abilityDef): AbilityInstance
	local self = setmetatable({}, AbilityInstance)
	self.Def = abilityDef
	self.State = {}

	self.StartTime = os.clock()
	self.StoppedChannel = false
	self.Expired = false

	abilityDef = nil -- cleanup variable

	if self.Def.Chargeable then
		self:_StartCharge()
	elseif self.Def.CastTime then
		self:_StartCast()
	else
		self:_Flow(true)
	end

	return self
end

function AbilityInstance:_StartCast()
	task.spawn(_startCast, self)
end

function AbilityInstance:_StartCharge()
	task.spawn(_startCharge, self)
end

function AbilityInstance:_Flow(spawn: boolean?)
	if spawn then
		task.spawn(_flow, self)
	else -- already running in spawn
		_flow(self)
	end
end

function AbilityInstance:_Execute()
	self.Def.Execute(self.State)
end

function AbilityInstance:_StartChannel()
	if not self.Def.ChannelConditions or self.Def.ChannelConditions(self.State) then
		if self.Def.ChannelAnimationId then
			local animation: Animation = Instance.new("Animation")
			animation.AnimationId = self.Def.ChannelAnimationId
			self.ChannelAnim = Players.LocalPlayer.Character.Humanoid.Animator:LoadAnimation(animation)
			self.ChannelAnim:Play()
		end

		self._ChannelTickConn = RunService.Heartbeat:Connect(function(dt)
			self._tickElapsed = (self._tickElapsed or 0) + dt
			if self._tickElapsed >= (self.Def.ChannelTickRate or 0) then
				if self.Def.OnChannelTick then
					self.Def.OnChannelTick(self, dt)
				end
				self._tickElapsed = 0
			end
		end)

		BattleGuiController:RunChannelBar(self.Def.ChannelTime)

		task.delay(self.Def.ChannelTime, function()
			if not self.StoppedChannel then
				self:StopChannel("ChannelRanOut")
			end
		end)
	end
end

function AbilityInstance:StopChannel(reason: string)
	self.StoppedChannel = true
	BattleGuiController:CancelChannelBar()
	if self.ChannelAnim then
		self.ChannelAnim:Stop()
	end
	if self._ChannelTickConn then
		self._ChannelTickConn:Disconnect()
	end
	if self.Def.OnInterrupted then
		self.Def.OnInterrupted(reason)
	end
end

function AbilityInstance:IsDead()
	return (self.Def.ChannelTime and self.StoppedChannel) or self.State.Dead
end

return AbilityInstance
