--
--	Jackson Munsell
--	07/30/18
--	MatchType.lua
--
--	Match type enum
--

-- Enum
local enum = {
	FirstToSeven = 0,
	GoldenGoal   = 1,
	Timed        = 2,
}

-- return
return require(game:GetService('ReplicatedStorage').src.enum.__enumclass)(enum)
