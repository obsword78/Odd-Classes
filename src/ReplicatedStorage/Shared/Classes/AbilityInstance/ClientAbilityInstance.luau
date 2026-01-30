local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientAbilityDefinitions = require(ReplicatedStorage.Shared.ReplicatedData.ClientAbilityDefinitions)
local RunService = game:GetService("RunService")
local knit = require(ReplicatedStorage.Packages.knit)
local BattleGuiController
local AnimationController
--------------------------------------------------------------------------------
type AbilityInstanceState = {
	TimeCharged: number?,
	ChannelStopped: boolean?,
	Dead: boolean?,
}
type ClientAbilityInstance = {
	Def: ClientAbilityDefinitions.ClientAbilityDefinition,
	State: AbilityInstanceState,
	StartTime: number,

	StopChannel: (self: ClientAbilityInstance, reason: string) -> nil,
	IsDead: (self: ClientAbilityInstance) -> boolean?,
}
--------------------------------------------------------------------------------
knit.OnStart():andThen(function()
	if not RunService:IsClient() then
		return
	end
	BattleGuiController = knit.GetController("BattleGuiController")
	AnimationController = knit.GetController("AnimationController")
end)
--------------------------------------------------------------------------------
local AbilityInstance = {}
AbilityInstance.__index = AbilityInstance
---------------------------------------------------
local function _startCast(self)
	BattleGuiController:RunCastBar(self.Def.CastTime)
	if self.Def.CastAnimation then
		self.CastAnim = AnimationController:LoadAnimation(self.Def.CastAnimation)
		self.CastAnim:Play()
	end
	task.wait(self.Def.CastTime)
	if self.CastAnim then
		self.CastAnim:Stop()
	end
	self:_Flow(false)
end
local function _startCharge(self)
	self.ChargeReleased = false
	if self.Def.ChargeAnimation then
		self.ChargeAnim = AnimationController:LoadAnimation(self.Def.ChargeAnimation)
		self.ChargeAnim:Play()
	end
	while not self.ChargeReleased and (os.clock() - self.StartTime) < (self.Def.MaxChargeTime or 3) do
		task.wait()
	end
	if self.ChargeAnim then
		self.ChargeAnim:Stop()
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
---------------------------------------------------
function AbilityInstance.new(abilityDef): ClientAbilityInstance
	local self = setmetatable({}, AbilityInstance)
	self.Def = abilityDef
	self.State = {}

	self.StartTime = os.clock()
	self.StoppedChannel = false

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
	if self:IsDead() then
		return
	end
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
		if self.Def.ChannelAnimation then
			self.ChannelAnim = AnimationController:LoadAnimation(self.Def.ChannelAnimation)
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
			if not self.State.ChannelStopped then
				self:StopChannel("ChannelRanOut")
			end
		end)
	end
end

function AbilityInstance:StopChannel(reason: string)
	self.State.ChannelStopped = true
	BattleGuiController:CancelChannelBar()
	if self.ChannelAnim then
		self.ChannelAnim:Stop()
	end
	if self._ChannelTickConn then
		self._ChannelTickConn:Disconnect()
		self._ChannelTickConn = nil
	end
	if self.Def.OnInterrupted then
		self.Def.OnInterrupted(reason)
	end
end

function AbilityInstance:Kill(reason: string)
	if self.State.Dead then
		return
	end
	self.State.Dead = true
	AbilityInstance:StopChannel(reason or "Interrupted")
	self.ChargeReleased = true
end

function AbilityInstance:IsDead()
	return (self.Def.ChannelTime and self.State.ChannelStopped) or self.State.Dead
end

return AbilityInstance
