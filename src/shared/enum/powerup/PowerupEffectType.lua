--
--	Jackson Munsell
--	07/24/18
--	PowerupEffectType.module.lua
--
--	Powerup effect type enum module
--

-- Enum
local enum = {
	Neutral      = 0,
	Advantage    = 1,
	Disadvantage = 2,
	Good         = 3,
	Bad          = 4,
}

-- return
return require(game:GetService('ReplicatedStorage').src.enum.__enumclass)(enum)
