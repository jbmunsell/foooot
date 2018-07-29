--
--	Jackson Munsell
--	07/27/18
--	LowJumpPowerup.lua
--
--	Low jump powerup module
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local LowJumpPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
LowJumpPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Disadvantage,
	PowerupId = PowerupId.LowJump,
	EffectDuration = 25,
	DisplayName = 'Low Jump',
}

-- Apply effect
function LowJumpPowerup.ApplyEffect(self, ball)
	local controller = self.match:GetDesignatedPowerupController(self, ball)
	if controller then
		self.controller = controller
		controller.jump_modifier = 0.75
	end
end
function LowJumpPowerup.RemoveEffect(self, ball)
	if self.controller then
		self.controller.jump_modifier = 1.0
	end
end

-- return module
return LowJumpPowerup
