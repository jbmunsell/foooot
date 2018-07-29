--
--	Jackson Munsell
--	07/24/18
--	SmallBallPowerup.lua
--
--	Bouncy ball powerup class
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local SmallBallPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
SmallBallPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Neutral,
	PowerupId = PowerupId.SmallBall,
	EffectDuration = 30,
	DisplayName = 'Small Ball',
}

-- Apply effect
function SmallBallPowerup.ApplyEffect(self, ball)
	self.match:SetBallSizeModifier(0.5)
end
function SmallBallPowerup.RemoveEffect(self, ball)
	self.match:SetBallSizeModifier(1)
end

-- return powerup
return SmallBallPowerup
