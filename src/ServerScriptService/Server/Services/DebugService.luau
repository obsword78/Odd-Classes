local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local PoolService
------------------------------------------------
knit.OnStart():andThen(function()
	PoolService = knit.GetService("PoolService")
end)
------------------------------------------------
local DebugService = knit.CreateService({
	Name = "DebugService",
})
------------------------------------------------
function DebugService:KnitInit()
	DebugService.DebugFolder = Instance.new("Folder")
	DebugService.DebugFolder.Name = "Debug"
	DebugService.DebugFolder.Parent = workspace
end

function DebugService:CreateDebugPart(cframe: CFrame, size: Vector3, color: Color3?, transparency: number?): Part
	local debugPart = PoolService:GetItemOf("Part")
	debugPart.Anchored = true
	debugPart.CanCollide = false
	debugPart.CanTouch = false
	debugPart.CanQuery = false
	debugPart.Transparency = transparency or 0.2
	debugPart.Color = color or Color3.fromRGB(181, 0, 0)
	debugPart.CastShadow = false
	debugPart.CFrame = cframe
	debugPart.Size = size
	debugPart.Parent = DebugService.DebugFolder

	task.delay(30, debugPart.release, debugPart)
	return debugPart
end

function DebugService.Client:CreateDebugPart(cframe: CFrame, size: Vector3, color: Color3?, transparency: number?): Part
	return DebugService:CreateDebugPart(cframe, size, color, transparency)
end

return DebugService
