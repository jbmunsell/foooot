--
--	Jackson Munsell
--	07/24/18
--	PowerupId.lua
--
--	Powerup id enum 
--

-- Enum
local enum = {
	BouncyBall = 0,
	TriplePlay = 1,
	SuperJump  = 2,
	LowJump    = 3,
	SuperSpeed = 4,
	LowSpeed   = 5,
	BigBall    = 6,
	SmallBall  = 7,
	BigHead    = 8,
	SmallHead  = 9,
	GoldenBoot = 10,
	LowGravity = 11,
}

-- return
return require(game:GetService('ReplicatedStorage').src.enum.__enumclass)(enum)
