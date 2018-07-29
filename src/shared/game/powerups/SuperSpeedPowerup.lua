--
--	Jackson Munsell
--	07/27/18
--	SuperSpeedPowerup.lua
--
--	Super speed powerup module
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local SuperSpeedPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
SuperSpeedPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Advantage,
	PowerupId = PowerupId.SuperSpeed,
	EffectDuration = 25,
	DisplayName = 'Super Speed',
}

-- Apply effect
function SuperSpeedPowerup.ApplyEffect(self, ball)
	local controller = self.match:GetDesignatedPowerupController(self, ball)
	if controller then
		self.controller = controller
		controller.speed_modifier = 1.5
	end
end
function SuperSpeedPowerup.RemoveEffect(self, ball)
	if self.controller then
		self.controller.speed_modifier = 1.0
	end
end

-- return module
return SuperSpeedPowerup
