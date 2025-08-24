local RunService = game:GetService("RunService")

local AbilityInstance = {}
AbilityInstance.__index = AbilityInstance

function AbilityInstance.new(ability, caster, params)
	local self = setmetatable({}, AbilityInstance)
	self.Ability = ability
	self.Caster = caster
	self.Params = params
	self.State = {}

	self.StartTime = os.clock()
	self.Expired = false

	-- Run Execute immediately
	if ability.Execute then
		self.State = ability.Execute(caster, params) or {}
	end

	-- Handle lingering effects
	if ability.Duration then
		task.delay(ability.Duration, function()
			if not self.Expired then
				self:Expire()
			end
		end)
	end

	-- Handle ticking
	if ability.TickRate then
		self.TickConn = RunService.Heartbeat:Connect(function(dt)
			self._tickElapsed = (self._tickElapsed or 0) + dt
			if self._tickElapsed >= ability.TickRate then
				self._tickElapsed = 0
				if ability.OnTick then
					ability.OnTick(caster, self.State)
				end
			end
		end)
	end

	return self
end

function AbilityInstance:TryRecast()
	local ability = self.Ability
	if ability.Recast and (not ability.RecastCondition or ability.RecastCondition(self.Caster, self.State)) then
		self.State = ability.Recast(self.Caster, self.State) or self.State
		return true
	end
	return false
end

function AbilityInstance:Expire()
	self.Expired = true
	if self.TickConn then
		self.TickConn:Disconnect()
	end
	if self.Ability.OnExpire then
		self.Ability.OnExpire(self.Caster, self.State)
	end
end

return AbilityInstance
