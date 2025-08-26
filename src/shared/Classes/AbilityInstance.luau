local RunService = game:GetService("RunService")

local AbilityInstance = {}
AbilityInstance.__index = AbilityInstance

function AbilityInstance.new(abilityDef, caster)
	local self = setmetatable({}, AbilityInstance)
	self.Definition = abilityDef
	self.Caster = caster
	self.State = nil

	self.StartTime = os.clock()
	self.Expired = false

	-- Run Execute immediately
	if abilityDef.Execute then
		self.State = abilityDef.Execute(caster) or {}
	end

	if abilityDef.ChannelTime then
		self.TickConn = RunService.Heartbeat:Connect(function(dt)
			self._tickElapsed = (self._tickElapsed or 0) + dt
			if self._tickElapsed >= abilityDef.TickRate then
				self._tickElapsed = 0
				if abilityDef.OnChannelTick then
					abilityDef.OnChannelTick(caster, self.State)
				end
			end
		end)

		task.delay(abilityDef.ChannelTime, function()
			if not self.Expired then
				self:Expire()
			end
		end)
	end

	-- Handle lingering effects
	if abilityDef.Duration then
		task.delay(abilityDef.Duration, function()
			if not self.Expired then
				self:Expire()
			end
		end)
	end

	return self
end

function AbilityInstance:TryRecast()
	local abilityDef = self.Definition
	if
		abilityDef.Recast and (not abilityDef.RecastCondition or abilityDef.RecastCondition(self.Caster, self.State))
	then
		self.State = abilityDef.Recast(self.Caster, self.State) or self.State
		return true
	end
	return false
end

function AbilityInstance:Expire()
	self.Expired = true
	if self.TickConn then
		self.TickConn:Disconnect()
	end
	if self.Definition.OnExpire then
		self.Definition.OnExpire(self.Caster, self.State)
	end
end

return AbilityInstance
