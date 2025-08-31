local ReplicatedStorage = game:GetService("ReplicatedStorage")
local knit = require(ReplicatedStorage.Packages.knit)
--=============================================================================
local AnimationController = knit.CreateController({
	Name = "AnimationController",
})

AnimationController.Animator = nil
AnimationController._LoadedAnimations = {}
AnimationController._AnimationTracks = {}

local function onCharacterAdded(character)
	local animator = character:WaitForChild("Humanoid").Animator
	AnimationController.Animator = animator

	for animation in pairs(AnimationController._AnimationTracks) do
		AnimationController:LoadAnimation(animation)
	end
end
--------------------------------
function AnimationController:KnitStart()
	print("[AnimationController] Started")

	local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	onCharacterAdded(character)
	game.Players.LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
	game.Players.LocalPlayer.CharacterRemoving:Connect(function()
		table.clear(AnimationController._AnimationTracks)

		for _, animation in pairs(AnimationController._LoadedAnimations) do
			AnimationController._AnimationTracks[animation] = AnimationController.Animator:LoadAnimation(animation)
		end
	end)
end

function AnimationController:LoadAnimation(animation: Animation)
	if not animation then
		warn("[AnimationController] Animation not passed in")
		return
	end
	if not animation:IsA("Animation") then
		warn("[AnimationController] animation argument is not an Animation Instance")
		return
	end
	if not AnimationController.Animator then
		warn("[AnimationController] Animator not loaded yet...")
		return
	end

	if not table.find(AnimationController._LoadedAnimations, animation) then
		table.insert(AnimationController._LoadedAnimations, animation)
		AnimationController._AnimationTracks[animation] = AnimationController.Animator:LoadAnimation(animation)
	end

	return AnimationController._AnimationTracks[animation]
end

return AnimationController
