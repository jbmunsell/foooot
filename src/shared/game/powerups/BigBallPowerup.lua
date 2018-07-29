--
--	Jackson Munsell
--	07/24/18
--	BigBallPowerup.lua
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
local BigBallPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
BigBallPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Neutral,
	PowerupId = PowerupId.BigBall,
	EffectDuration = 30,
	DisplayName = 'Big Ball',
}

-- Apply effect
function BigBallPowerup.ApplyEffect(self, ball)
	self.match:SetBallSizeModifier(2)
end
function BigBallPowerup.RemoveEffect(self, ball)
	self.match:SetBallSizeModifier(1)
end

-- return powerup
return BigBallPowerup
