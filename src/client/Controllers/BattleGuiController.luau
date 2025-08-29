local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local knit = require(ReplicatedStorage.Packages.knit)

local BattleGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("BattleGUI")
local AbilitySlotsFrame = BattleGui.AbilitySlots
local Quickbar = BattleGui.QuickBar
local Quickbar_bar = Quickbar:FindFirstChild("Bar")

local currentQB_tween: TweenBase

local BattleGuiController = knit.CreateController({
	Name = "BattleGuiController",
})

local function hideQuickBar()
	Quickbar.Visible = false

	if currentQB_tween then
		currentQB_tween:Cancel()
		currentQB_tween:Destroy()
	end
end

local function runQuickBar(purpose: string, time: number)
	Quickbar.Purpose.Text = purpose
	Quickbar_bar.Size = UDim2.fromScale(0, 0.8)
	Quickbar.Visible = true

	currentQB_tween = TweenService:Create(
		Quickbar_bar,
		TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0),
		{ Size = UDim2.fromScale(1, 0.8) }
	)
	currentQB_tween:Play()
	currentQB_tween.Completed:Once(hideQuickBar)
end

local function cdFlashAnim(abilitySlotFrame)
	local flashFrame = abilitySlotFrame.Flash
	local tweenBase = TweenService:Create(
		flashFrame,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1 }
	)
	flashFrame.BackgroundTransparency = 0
	flashFrame.Visible = true
	tweenBase:Play()
	tweenBase.Completed:Once(function()
		flashFrame.Visible = false
	end)
end

function BattleGuiController:RunCastBar(castTime: number)
	runQuickBar("Casting...", castTime)
end

function BattleGuiController:RunChannelBar(channelTime: number)
	runQuickBar("Channeling...", channelTime)
end

function BattleGuiController:CancelChannelBar()
	hideQuickBar()
end

function BattleGuiController:RunCD(abilitySlot: string, seconds: number)
	local bar = AbilitySlotsFrame[abilitySlot].CDBar
	local tweenBase = TweenService:Create(
		bar,
		TweenInfo.new(seconds, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{ Size = UDim2.fromScale(1, 0) }
	)
	bar.Size = UDim2.fromScale(1, 1)
	bar.Visible = true
	tweenBase:Play()
	tweenBase.Completed:Once(function()
		cdFlashAnim(bar.Parent)
		bar.Visible = false
	end)
end

function BattleGuiController:ReduceCD(abilitySlot: string, seconds: number) end

function BattleGuiController:SetCD(abilitySlot: string, seconds: number) end

function BattleGuiController:SetCharge(abilitySlot: string, seconds: number) end

function BattleGuiController:SetRecast(abilitySlot: string, timeout: number?) end

function BattleGuiController:Disable(abilitySlot: string) end

function BattleGuiController:Enable(abilitySlot: string) end

return BattleGuiController
