local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParabolicTravellerComponentTypes = require(ReplicatedStorage.Shared.Types.ParabolicTravellerComponentTypes)
local RaycastComponent = {}
RaycastComponent.__index = RaycastComponent

function RaycastComponent.new(
	params: RaycastParams?,
	callback: ((RaycastResult?) -> any?)?
): ParabolicTravellerComponentTypes.CollisionComponent
	local self = setmetatable({}, RaycastComponent)
	self._params = params or RaycastParams.new()
	self._callback = callback
	self.RaycastResult = nil
	return self
end

function RaycastComponent:StoreResult(startPos: Vector3, endPos: Vector3)
	self.RaycastResult = workspace:Raycast(startPos, endPos - startPos, self._params)

	if self.RaycastResult and self._callback then
		self._callback(self.RaycastResult)
	end
end

return RaycastComponent
