local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local signal = require(ReplicatedStorage.Packages.signal)

local PlayerService
local BattleGuiController

knit.OnStart():andThen(function()
	PlayerService = knit.GetService("PlayerService")
	BattleGuiController = knit.GetController("BattleGuiController")
end)
--===========================================================================
local ClassController = knit.CreateController({
	Name = "ClassController",
})

ClassController.ClassSelected = signal.new()

function ClassController:Select(className: string)
	ClassController.Class = className
	ClassController.ClassSelected:Fire(className)
	PlayerService:SelectClass(className)
	BattleGuiController:LoadAbilitySlots(className)
end

return ClassController
