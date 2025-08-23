local ReplicatedStorage = game:GetService("ReplicatedStorage")
local goodsignal = require(ReplicatedStorage.Packages.goodsignal)

local EventBus = {}
EventBus._signals = {} :: { [string]: BindableEvent }

-- Subscribes to the Event with the passed eventName and returns the EventConnection. If no Event can't be found, register a new Event with the given eventName.
function EventBus:Subscribe(eventName: string, callback: (...any) -> any): RBXScriptConnection
	if not self._signals[eventName] then
		self._signals[eventName] = goodsignal.new()
	end
	return self._signals[eventName]:Connect(callback)
end

function EventBus:Publish(eventName: string, ...)
	if not self._signals[eventName] then
		return
	end
	self._signals[eventName]:Fire(...)
end

return EventBus
