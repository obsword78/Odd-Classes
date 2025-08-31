local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local signal = require(ReplicatedStorage.Packages.signal)
local ClassInputs = require(ReplicatedStorage.Shared.Data.ClassInputs)

local PlayerService
local InputController
local BattleGuiController

knit.OnStart():andThen(function()
	PlayerService = knit.GetService("PlayerService")
	InputController = knit.GetController("InputController")
	BattleGuiController = knit.GetController("BattleGuiController")
end)
--===========================================================================
local ClassController = knit.CreateController({
	Name = "ClassController",
})

ClassController.ClassSelected = signal.new()

function ClassController:Select(className: string)
	ClassController.ClassSelected:Fire(className)
	PlayerService:SelectClass(className)
	BattleGuiController:LoadAbilitySlots(className)

	if not ClassInputs[className] then
		warn(`Couldn't find Inputs for "{className}"`)
		return
	end

	InputController:DisconnectAllAbilities()
	for abilityName, inputBind in ClassInputs[className] do
		InputController:ConnectAbility(abilityName, inputBind)
	end
end

return ClassController
