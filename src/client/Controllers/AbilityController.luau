local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

local AbilityController = knit.CreateController({
	Name = "AbilityController",
})

function AbilityController:Cast() end

return AbilityController
