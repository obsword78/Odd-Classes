local ParabolicTravellerComponentTypes = {}

export type RaycastComponent = {}
export type ReflectComponent = {}

export type CollisionComponent = {
	StoreResult: (self: CollisionComponent, startPos: Vector3, endPos: Vector3) -> nil,
	RaycastResult: RaycastResult?,
}
export type ImpactComponent = ReflectComponent

return ParabolicTravellerComponentTypes
