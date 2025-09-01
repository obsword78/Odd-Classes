local ContentProvider = game:GetService("ContentProvider")
local Animations = {}

Animations.Abilities = {}
------------------------------------------------------------------------------
Animations.Abilities.MovingForceCharge = "rbxassetid://119501115508177"
Animations.Abilities.MovingForceChannel = "rbxassetid://6881035317"
Animations.Abilities.MovingForceCollision = "rbxassetid://90017705370595"
Animations.Abilities.MovingForceNoCollision = "rbxassetid://89680333417950"
Animations.Abilities.MovingForceBash = "rbxassetid://132707928304142"
------------------------------------------------------------------------------
task.spawn(function()
	local arrayForm = {}
	for _, categoryTable in Animations do
		for key, animationId in categoryTable do
			local Id_cache = animationId
			categoryTable[key] = Instance.new("Animation")
			categoryTable[key].AnimationId = Id_cache
			table.insert(arrayForm, categoryTable[key])
		end
	end
	ContentProvider:PreloadAsync(arrayForm)
end)

return table.freeze(Animations)
