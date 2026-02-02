local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local knit = require(ReplicatedStorage.Packages.knit)
local ParabolicTraveller = require(ReplicatedStorage.Shared.Classes.ParabolicTraveller)
--------------------------------------------------------
local ParabolaService = knit.CreateService({
	Name = "ParabolaService",
})
--------------------------------------------------------
local traveller_registry = {}
local object_registry = {}
local cframe_registry = {}
local runtimeConnection
--------------------------------------------------------
local function stepped(dt)
	for obj, traveller in pairs(traveller_registry) do
		if traveller:IsDone() then
			traveller_registry[obj] = nil
			object_registry[traveller.RegistryIndex] = nil
			cframe_registry[traveller.RegistryIndex] = nil
		else
			local newPos = traveller:Step(dt)
			cframe_registry[obj] = CFrame.new(newPos)
		end
	end

	workspace:BulkMoveTo(object_registry, cframe_registry, Enum.BulkMoveMode.FireCFrameChanged)

	if next(traveller_registry) == nil then
		runtimeConnection:Disconnect()
		runtimeConnection = nil
	end
end
--------------------------------------------------------
function ParabolaService:Create(object: Model, params)
	params.index = #object_registry + 1
	local travellerInstance = ParabolicTraveller.new(params)

	traveller_registry[params.index] = travellerInstance
	object_registry[params.index] = object
	cframe_registry[params.index] = CFrame.new(params.start)

	if not runtimeConnection then
		runtimeConnection = RunService.Heartbeat:Connect(stepped)
	end
end
--------------------------------------------------------s
return ParabolaService
