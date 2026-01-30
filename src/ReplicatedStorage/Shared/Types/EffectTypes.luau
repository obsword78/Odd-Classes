local EffectTypes = {}

export type EffectInstance = {
	descriptor: EffectDescription,
	source: Humanoid?,
	target: Humanoid?,
	startTime: number,
	endTime: number,
	stacks: number,
	nextTickAt: number,
	custom: {}, -- per-instance params

	IsExpired: (self: EffectInstance) -> boolean,
}
type StackInformation = {
	type: "independent" | "accumulate" | "renew" | "overwrite",
	max: number?,
	refreshOnStack: boolean?,
}
export type EffectDescription = {
	id: string,
	baseDuration: number,
	tickInterval: number,
	stackInfo: StackInformation?,
	priority: number,
	tags: { string },
	onApply: ((effect: EffectInstance) -> nil)?,
	onTick: ((effect: EffectInstance) -> nil)?,
	onRemove: ((effect: EffectInstance) -> nil)?,
}
return EffectTypes
