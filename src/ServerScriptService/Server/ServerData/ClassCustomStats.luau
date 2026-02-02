local ClassCustomStats = {}

ClassCustomStats.Physical = {
	MaxBaseHealth = 1000,
	Size = 1.5,
	WalkSpeed = 10,
	JumpPower = 50,
	--------------
	Protection = 20,
	Resist = 5,
	Viability = 100,
	Rejection = 2,
	CritReduction = 0,

	BaseRegeneration = 2,
	--------------
	Stamina = 100,
	--------------
	PassiveDefinitionName = "Stamina",
}

ClassCustomStats.Engager = {
	MaxBaseHealth = 600,
	Size = 1,
	WalkSpeed = 14,
	JumpPower = 60,
	--------------
	--------------
	PassiveDefinitionName = "Opportunity",
}

return ClassCustomStats
