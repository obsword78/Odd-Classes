local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

local AbilityService
local AbilityController

knit.OnStart():andThen(function()
	AbilityService = knit.GetService("AbilityService")
	AbilityController = knit.GetController("AbilityController")
end)
--===========================================================================
local InputController = knit.CreateController({
	Name = "InputController",
})

local _connected_abilities = {}

local function CastAbility(actionName, inputState)
	if inputState == Enum.UserInputState.Begin then
		AbilityController:Cast(actionName)
		AbilityService:Cast(actionName)
	end
end

function InputController:ConnectAbility(abilityName: string, keycode: Enum.KeyCode)
	ContextActionService:BindAction(abilityName, CastAbility, false, keycode)
	table.insert(_connected_abilities, abilityName)
end

function InputController:DisconnectAbility(abilityName: string)
	ContextActionService:UnbindAction(abilityName)
	table.remove(_connected_abilities, table.find(_connected_abilities, abilityName))
end

function InputController:SwitchAbilityKeybind(abilityName: string, keycode: Enum.KeyCode)
	InputController:DisconnectAbility(abilityName)
	InputController:ConnectAbility(abilityName, keycode)
end

function InputController:DisconnectAllAbilities()
	for _, abilityName in pairs(_connected_abilities) do
		ContextActionService:UnbindAction(abilityName)
	end
	table.clear(_connected_abilities)
end

return InputController
