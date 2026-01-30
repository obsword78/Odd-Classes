local RunService = game:GetService("RunService")
local ClientAbilityInstance = require(script.ClientAbilityInstance)
local ServerAbilityInstance = require(script.ServerAbilityInstance)

local AbilityInstance = {}

function AbilityInstance.new(...)
	if RunService:IsServer() then
		return ServerAbilityInstance.new(...)
	elseif RunService:IsClient() then
		return ClientAbilityInstance.new(...)
	else
		warn("?")
		return
	end
end

return AbilityInstance
