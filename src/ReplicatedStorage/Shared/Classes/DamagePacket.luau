local DamagePacket = {}
DamagePacket.__index = DamagePacket
------------------------------------------------
type DamageModification = {
	value: number,
	type: "PhysicalPen" | "MagicalPen" | "PhysicalPen%" | "MagicalPen%" | "Amount%",
}
type DamagePacketParams = {
	amount: number,
	type: "physical" | "magical" | "essence" | "heal",
	source: Model,
	target: Model,
	isCritical: boolean?,
	modifications: { DamageModification }?,
	tags: { string }?,
}
export type DamagePacket = {
	amount: number,
	type: "physical" | "magical" | "essence" | "heal",
	source: Model?,
	target: Model?,
	isCritical: boolean,
	modifications: { DamageModification }?,
	tags: { string }?,
	timestamp: number,
}
------------------------------------------------
function DamagePacket.new(params: DamagePacketParams): DamagePacket?
	if not (params.source and params.target and params.type and params.amount) then
		warn("Missing essential argument in Damage Packet Parameters. Params Record:", params)
		return
	end

	local self = setmetatable({}, DamagePacket)
	self.amount = params.amount
	self.type = params.type
	self.source = params.source
	self.target = params.target
	self.isCritical = params.isCritical or false
	self.modifications = params.modifications
	self.tags = params.tags
	self.timestamp = os.clock()
	return self
end

function DamagePacket:IsCritical()
	return self.isCritical
end

function DamagePacket:AddTag(tag)
	table.insert(self.tags, tag)
end

return DamagePacket
