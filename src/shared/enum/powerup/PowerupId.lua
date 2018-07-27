--
--	Jackson Munsell
--	07/24/18
--	PowerupId.lua
--
--	Powerup id enum 
--

-- Enum
local enum = {
	BouncyBall		= 0,
	TriplePlay		= 1,
}

-- return
return require(game:GetService('ReplicatedStorage').src.enum.__enumclass)(enum)
