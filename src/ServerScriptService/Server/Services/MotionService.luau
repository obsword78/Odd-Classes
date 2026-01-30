local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

local MotionService = knit.CreateService({
	Name = "MotionService",
})

return MotionService
