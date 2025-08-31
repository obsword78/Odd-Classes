local Pool = {}
local ActivePoolObject = {}
----------------------------------------
export type Pool = {
	template: Instance,
	available: { Instance? },
	reset: ((obj: Instance) -> nil)?,
	acquire: (self: Pool) -> Instance,
	release: (self: Pool, obj: Instance) -> nil,
	size: (self: Pool) -> number,
}

export type ActivePoolObject = typeof(setmetatable(
	{} :: {
		parentPool: Pool,
		instance: Instance,
	},
	ActivePoolObject
))
----------------------------------------
Pool.__index = Pool
ActivePoolObject.__index = function(poolObject, index)
	return ActivePoolObject[index] or poolObject.instance[index]
end
ActivePoolObject.__newindex = function(poolObject, index, value)
	poolObject.instance[index] = value
end
----------------------------------------
local function warnPoolObjectDestruction()
	warn("An object that belonged to a Pool object was destroyed")
end

local function cloneWrapper(template)
	local clone = template:Clone()
	clone.Destroying:Once(warnPoolObjectDestruction)
	return clone
end
----------------------------------------
function Pool.new(template, size, resetCallback: ((obj: Instance) -> nil)?): Pool
	local self = setmetatable({}, Pool)
	self.template = template
	self.available = {}
	self.reset = resetCallback

	for _i = 1, size do
		table.insert(self.available, cloneWrapper(template))
	end

	return self
end

function Pool:acquire(): ActivePoolObject
	local item
	if #self.available > 0 then
		item = table.remove(self.available)
	else
		item = cloneWrapper(self.template)
	end
	return ActivePoolObject.new(self, item)
end

function Pool:release(obj)
	obj.Parent = nil
	if self.reset then
		self.reset(obj)
	end
	table.insert(self.available, obj)
end

function Pool:size()
	return #self.available
end
----------------------------------------
function ActivePoolObject.new(parentPool: Pool, item: Instance): ActivePoolObject
	local self = setmetatable({
		parentPool = parentPool,
		instance = item,
	}, ActivePoolObject)
	return self
end

function ActivePoolObject:release()
	self.parentPool:release(self.instance)
	setmetatable(self, nil)
	table.clear(self)
end

return Pool
