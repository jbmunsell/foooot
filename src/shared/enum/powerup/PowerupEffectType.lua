--
--	Jackson Munsell
--	07/24/18
--	PowerupEffectType.module.lua
--
--	Powerup effect type enum module
--

-- Enum
local enum = {
	Neutral		= 0,
	Good		= 1,
	Bad			= 2,
}

-- return
return require(game:GetService('ReplicatedStorage').src.enum.__enumclass)(enum)
