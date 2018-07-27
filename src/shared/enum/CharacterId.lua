--
--	Jackson Munsell
--	07/19/18
--	PlayerId.lua
--
--	Player id enum
--

-- Enum
local enum = {
	Player1		= 0,
	Player2		= 1,
}

-- return
return require(game:GetService('ReplicatedStorage').src.enum.__enumclass)(enum)
