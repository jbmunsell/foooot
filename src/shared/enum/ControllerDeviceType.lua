--
--	Jackson Munsell
--	07/19/18
--	ControllerDeviceType.lua
--
--	Controller device type enum
--

-- Enum
local enum = {
	Keyboard = 0,
	Gamepad  = 1,
}

-- return
return require(game:GetService('ReplicatedStorage').src.enum.__enumclass)(enum)
