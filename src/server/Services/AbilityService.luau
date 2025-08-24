--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Ability = require(ServerScriptService.Server.Classes.Ability)
local AbilityInstance = require(ServerScriptService.Server.Classes.AbilityInstance)
local knit = require(ReplicatedStorage.Packages.knit)

local AbilityService = knit:CreateService({
	Name = "AbilityService",
	Client = {},
})

return AbilityService
