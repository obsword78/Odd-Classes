local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
local ClassInputs = require(ReplicatedStorage.Shared.Data.ClassInputs)

local AbilityService
local AbilityController
local ClassController
--===========================================================================
local InputController = knit.CreateController({
	Name = "InputController",
})
----------------------------------------
local _inputaction_connections = {}
local AbilitiesContext
----------------------------------------
local function _Cast(abilityName)
	AbilityController:Cast(abilityName)
	AbilityService:Cast(abilityName)
end
local function _Release(abilityName)
	AbilityController:Release(abilityName)
	AbilityService:Release(abilityName)
end
----------------------------------------
knit.OnStart():andThen(function()
	ClassController = knit.GetController("ClassController")
	AbilityService = knit.GetService("AbilityService")
	AbilityController = knit.GetController("AbilityController")

	AbilitiesContext = game.Players.LocalPlayer.PlayerGui.Abilities

	ClassController.ClassSelected:Connect(function(className)
		for _, connection in _inputaction_connections do
			connection:Disconnect()
		end
		table.clear(_inputaction_connections)

		for abilityName: string, inputSlot: string in ClassInputs[className] do
			table.insert(
				_inputaction_connections,
				AbilitiesContext[inputSlot].Pressed:Connect(function()
					_Cast(abilityName)
				end)
			)
			table.insert(
				_inputaction_connections,
				AbilitiesContext[inputSlot].Released:Connect(function()
					_Release(abilityName)
				end)
			)
		end
	end)
end)

return InputController
