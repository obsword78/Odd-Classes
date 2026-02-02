local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ComponentTypes = require(ReplicatedStorage.Shared.Types.ParabolicTravellerComponentTypes)

local ParabolicTraveller = {}
ParabolicTraveller.__index = ParabolicTraveller
----------------------------------------------------
export type ParabolicTravellerParams = {
	start: Vector3, -- required
	duration: number, -- required
	gravity: Vector3?, -- optional, default = workspace.Gravity
	force: Vector3?, -- direction-based
	target: Vector3?, -- target-based
	ignoreList: { Instance }?,
	travellerComponents: {
		CollisionComponent: ComponentTypes.CollisionComponent?,
		ImpactComponent: ComponentTypes.ImpactComponent?,
	},
}
export type ParabolicTraveller = {
	-- Properties
	Start: Vector3,
	Direction: Vector3,
	Distance: number,
	Target: Vector3?,
	Duration: number,
	Elapsed: number,
	Gravity: Vector3,
	RaycastParams: RaycastParams,
	_LastPos: Vector3,

	CollisionComponent: ComponentTypes.CollisionComponent?,
	ImpactComponent: ComponentTypes.ImpactComponent?,

	-- Methods
	Step: (self: ParabolicTraveller, dt: number) -> Vector3,
	Ignore: (self: ParabolicTraveller, instance: Instance | { Instance }) -> nil,
	IsDone: (self: ParabolicTraveller) -> boolean,
}
----------------------------------------------------
function ParabolicTraveller.new(params: ParabolicTravellerParams): ParabolicTraveller
	local self = setmetatable({}, ParabolicTraveller)
	self.Start = params.start
	self.Duration = params.duration
	self.Elapsed = 0
	self.Gravity = params.gravity or Vector3.new(0, -workspace.Gravity, 0)
	self.RaycastParams = RaycastParams.new()
	self._LastPos = self.Start

	if params.travellerComponents then
		if params.travellerComponents.CollisionComponent then
			self.CollisionComponent = params.travellerComponents.CollisionComponent
		end
		if params.travellerComponents.ImpactComponent then
			self.ImpactComponent = params.travellerComponents.ImpactComponent
		end
	end

	-- TODO: put this in collision component
	self.RaycastParams.FilterDescendantsInstances = params.ignoreList or { workspace.Terrain }
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Include

	if params.target then
		if params.force then
			warn("Passed in Parabolic 'force', which is ignored since there is already a 'target' specified")
		end
		-- Target-based: calculate direction & distance
		local displacement = params.target - params.start
		self.Distance = displacement.Magnitude
		self.Direction = displacement.Unit
		self.Target = params.target
	elseif params.force then
		-- Direction-based
		self.Direction = params.force.Unit
		self.Distance = params.force.Magnitude
		self.Target = nil
	else
		error("ParabolicTraveller: invalid parameters, need target or force")
	end
	return self
end

function ParabolicTraveller:Step(dt): (Vector3, RaycastResult?)
	assert(dt and typeof(dt) == "number", 'Needs valid "dt" argument')
	self.Elapsed += dt
	local t = math.clamp(self.Elapsed / self.Duration, 0, 1)
	local horizontal = self.Direction * (self.Distance * t)
	local vertical = 0.5 * self.Gravity * (self.Duration * t) ^ 2
	local nextPos = self.Start + horizontal + vertical

	if self.CollisionComponent then
		self.CollisionComponent:StoreResult(self._LastPos, nextPos)
	end

	self._LastPos = nextPos

	return nextPos, self.CollisionComponent and self.CollisionComponent.RaycastResult
end

function ParabolicTraveller:Ignore(instance: Instance | { Instance })
	self.RaycastParams:AddToFilter(instance)
end

function ParabolicTraveller:IsDone()
	return self.Elapsed >= self.Duration
end

function ParabolicTraveller:Cancel()
	self.Elapsed = self.Duration
end

return ParabolicTraveller
