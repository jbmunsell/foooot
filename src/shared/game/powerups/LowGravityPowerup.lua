--
--	Jackson Munsell
--	07/24/18
--	LowGravityPowerup.lua
--
--	Low gravity powerup class
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local LowGravityPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
LowGravityPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Neutral,
	PowerupId = PowerupId.LowGravity,
	EffectDuration = 30,
	DisplayName = 'Low Gravity',
}

-- Apply effect
function LowGravityPowerup.ApplyEffect(self, ball)
	if self.match then
		self.match:SetGravityModifier(0.5)
	end
end
function LowGravityPowerup.RemoveEffect(self, ball)
	if self.match then
		self.match:SetGravityModifier(1)
	end
end

-- return powerup
return LowGravityPowerup
