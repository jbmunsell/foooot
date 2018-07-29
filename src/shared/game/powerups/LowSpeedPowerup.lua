--
--	Jackson Munsell
--	07/27/18
--	LowSpeedPowerup.lua
--
--	Low speed powerup module
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local LowSpeedPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
LowSpeedPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Disadvantage,
	PowerupId = PowerupId.LowSpeed,
	EffectDuration = 25,
	DisplayName = 'Low Speed',
}

-- Apply effect
function LowSpeedPowerup.ApplyEffect(self, ball)
	local controller = self.match:GetDesignatedPowerupController(self, ball)
	if controller then
		self.controller = controller
		controller.speed_modifier = 0.5
	end
end
function LowSpeedPowerup.RemoveEffect(self, ball)
	if self.controller then
		self.controller.speed_modifier = 1.0
	end
end

-- return module
return LowSpeedPowerup
