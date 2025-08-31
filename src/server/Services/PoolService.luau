local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local Pool = require(ReplicatedStorage.Shared.Classes.Pool)
----------------------------------------------------------
local PoolService = knit.CreateService({
	Name = "PoolService",
	Client = {},
})
----------------------------------------------------------
export type Pool = Pool.Pool
export type ActivePoolObject = Pool.ActivePoolObject
----------------------------------------------------------
PoolService.RegisteredPools = {}
PoolService.DefaultSize = 3
----------------------------------------------------------
local function getValidInstanceTemplate(classNameString)
	local success, resultTemplate = pcall(function()
		local newInstance = Instance.new(classNameString)
		return newInstance
	end)
	return success and resultTemplate
end
----------------------------------------------------------
function PoolService:CreateCustomPool(
	className: string,
	template: Instance,
	resetCallback: ((obj: Instance) -> nil)?
): Pool
	if PoolService.RegisteredPools[className] then
		warn(`{className} is already a Class Name with a registered Pool. Choose another Class Name.`)
	end

	PoolService.RegisteredPools[className] = Pool.new(template, PoolService.DefaultSize, resetCallback)
	return PoolService.RegisteredPools[className]
end

function PoolService:GetItemOf(className: string): ActivePoolObject?
	local activePoolObject: Pool.ActivePoolObject

	if not PoolService.RegisteredPools[className] then
		local new_template = getValidInstanceTemplate(className)
		if new_template then
			PoolService.RegisteredPools[className] = Pool.new(new_template, PoolService.DefaultSize)
		else
			warn(`{className} is not a valid Instance type.`)
			return
		end
	end

	activePoolObject = PoolService.RegisteredPools[className]:acquire()

	return activePoolObject
end

return PoolService
