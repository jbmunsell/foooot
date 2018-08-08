--
--	Jackson Munsell
--	07/19/18
--	ControlType.lua
--
--	Control type enum
--

-- Enum
local enum = {
	KeyboardLeft  = 0,
	KeyboardRight = 1,
	Gamepad       = 2,
}

-- return
return require(game:GetService('ReplicatedStorage').src.enum.__enumclass)(enum)
