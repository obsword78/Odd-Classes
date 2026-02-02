local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParabolicTravellerComponentTypes = require(ReplicatedStorage.Shared.Types.ParabolicTravellerComponentTypes)
local BlockcastComponent = {}

BlockcastComponent.__index = BlockcastComponent

function BlockcastComponent.new(
	size: Vector3,
	facetowards: boolean?,
	params: RaycastParams?,
	callback: ((RaycastResult?) -> any?)?
): ParabolicTravellerComponentTypes.CollisionComponent
	local self = setmetatable({}, BlockcastComponent)
	self._facetowards = facetowards or false
	self._size = size
	self._params = params or RaycastParams.new()
	self._callback = callback
	self.RaycastResult = nil
	return self
end

function BlockcastComponent:StoreResult(startPos: Vector3, endPos: Vector3)
	local cframe = if self._facetowards then CFrame.lookAt(startPos, endPos) else CFrame.new(startPos)
	self.RaycastResult = workspace:Blockcast(cframe, self._size, endPos - startPos, self._params)

	if self.RaycastResult and self._callback then
		self._callback(self.RaycastResult)
	end
end

return BlockcastComponent
