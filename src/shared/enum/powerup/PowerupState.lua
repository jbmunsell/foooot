--
--	Jackson Munsell
--	07/24/18
--	PowerupState.lua
--
--	Powerup state enum
--

-- Enum
local enum = {
	Spawned		= 0,
	Active		= 1,
	Despawned	= 2,
	Destroyed	= 3,
}

-- return
return require(game:GetService('ReplicatedStorage').src.enum.__enumclass)(enum)
