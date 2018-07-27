--
--	Jackson Munsell
--	07/24/18
--	BouncyBallPowerup.lua
--
--	Bouncy ball powerup class
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local BouncyBallPowerup = {}
BouncyBallPowerup.__index = BouncyBallPowerup

-- Inherit from superclass
setmetatable(BouncyBallPowerup, { __index = Powerup })

-- Powerup static properties
-- 	Read only please
BouncyBallPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Neutral,
	PowerupId = PowerupId.BouncyBall,
	EffectDuration = 45,
	DisplayName = 'Bouncy Ball',
}

-- Constructor
function BouncyBallPowerup.new(...)
	-- Create object
	local object = setmetatable(Powerup.new(...), BouncyBallPowerup)

	-- return object
	return object
end

-- Apply effect
function BouncyBallPowerup.ApplyEffect(self, ball)
	for _, ball in pairs(self.match.balls) do
		self.match:SetBallElasticity(ball, self.match.BALL_ELASTICITY_BOUNCY)
		ball.BrickColor = BrickColor.new('Magenta')
	end
end
function BouncyBallPowerup.RemoveEffect(self, ball)
	for _, ball in pairs(self.match.balls) do
		self.match:SetBallElasticity(ball, self.match.BALL_ELASTICITY_REGULAR)
		ball.BrickColor = BrickColor.new('Lily white')
	end
end

-- return powerup
return BouncyBallPowerup
