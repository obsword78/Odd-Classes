local RunService = game:GetService("RunService")
--------------------------------------------------------
type AbilityInstanceState = {
	TimeCharged: number?,
	ChannelStopped: boolean?,
	Dead: boolean?,
}
type ServerAbilityInstance = {
	Def: any,
	State: AbilityInstanceState,
	StartTime: number,

	StopChannel: (self: ServerAbilityInstance, reason: string) -> nil,
	IsDead: (self: ServerAbilityInstance) -> boolean?,
}
--------------------------------------------------------
local ServerAbilityInstance = {}
ServerAbilityInstance.__index = ServerAbilityInstance
--------------------------------------------------------
local function _startCast(self)
	if self.Def.OnCastStart then
		self.Def.OnCastStart(self.Caster)
	end
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
--------------------------------------------------------
function ServerAbilityInstance.new(abilityDef, caster)
	local self = setmetatable({}, ServerAbilityInstance)
	self.Def = abilityDef
	self.Caster = caster
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

function ServerAbilityInstance:_StartCast()
	task.spawn(_startCast, self)
end

function ServerAbilityInstance:_StartCharge()
	task.spawn(_startCharge, self)
end

function ServerAbilityInstance:_Flow(spawn: boolean?)
	if spawn then
		task.spawn(_flow, self)
	else -- already running in spawn
		_flow(self)
	end
end

function ServerAbilityInstance:_Execute()
	self.Def.Execute(self.Caster, self.State)
end

function ServerAbilityInstance:_StartChannel()
	if not self.Def.ChannelConditions or self.Def.ChannelConditions(self.State) then
		self._ChannelTickConn = RunService.Heartbeat:Connect(function(dt)
			self._tickElapsed = (self._tickElapsed or 0) + dt
			if self._tickElapsed >= (self.Def.ChannelTickRate or 0) then
				if self.Def.OnChannelTick then
					self.Def.OnChannelTick(self, dt)
				end
				self._tickElapsed = 0
			end
		end)

		task.delay(self.Def.ChannelTime, function()
			if not self.StoppedChannel then
				self:StopChannel("ChannelRanOut")
			end
		end)
	end
end

function ServerAbilityInstance:StopChannel(reason: string)
	self.State.ChannelStopped = true
	if self._ChannelTickConn then
		self._ChannelTickConn:Disconnect()
	end
	if self.Def.OnInterrupted then
		self.Def.OnInterrupted(self.Caster, self.State, reason)
	end
end

function ServerAbilityInstance:FullInterrupt(reason: string) end

function ServerAbilityInstance:IsDead()
	return (self.Def.ChannelTime and self.State.ChannelStopped) or self.State.Dead
end

return ServerAbilityInstance
