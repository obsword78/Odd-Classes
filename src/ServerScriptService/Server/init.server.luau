local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)

knit.AddServices(script.Services)
knit.AddServices(script.Systems)

knit.Start()
	:andThen(function()
		print("[Knit] Server started successfully")
	end)
	:catch(function(err)
		warn("[Knit] Error starting server: " .. tostring(err))
	end)
