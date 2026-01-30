local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectTypes = require(ReplicatedStorage.Shared.Types.EffectTypes)
local EffectInstance = {}
EffectInstance.__index = EffectInstance
--================================================
local function refreshEffect(now, self, triggerApply)
	self.startTime = now
	self.endTime = now + self.descriptor.baseDuration
	self.nextTickAt = now + self.descriptor.tickInterval
	if triggerApply then
		self.descriptor.onApply(self)
	end
end
--================================================
-- constructor
function EffectInstance.new(descriptor: EffectTypes.EffectDescription, target, source): EffectTypes.EffectInstance
	local self = setmetatable({}, EffectInstance)
	self.descriptor = descriptor
	self.target = target
	self.source = source

	self.stacks = descriptor.stackInfo and 1 or 0

	refreshEffect(os.clock(), self, descriptor.onApply)

	return self
end

function EffectInstance:StackApply(bulk: number)
	local stackInfo = self.descriptor.stackInfo
	local now = os.clock()

	if stackInfo.type == "independent" then
		self.stacks = math.min(self.stacks + 1, stackInfo.max or math.huge)
	elseif stackInfo.type == "accumulate" then
		self.custom.value = (self.custom.value or 0) + (bulk or 0)
	elseif stackInfo.type == "renew" then
		refreshEffect(now, self)
		return
	elseif stackInfo.type == "overwrite" then
		refreshEffect(now, self, true)
		self.stacks = self.descriptor.stackInfo and 1 or 0
		return
	end

	if stackInfo.refreshOnStack then
		refreshEffect(now, self)
	end
end

function EffectInstance:IsExpired()
	return os.clock() >= self.endTime
end

function EffectInstance:Destroy()
	coroutine.wrap(self.descriptor.onRemove)(self)
end

return EffectInstance
