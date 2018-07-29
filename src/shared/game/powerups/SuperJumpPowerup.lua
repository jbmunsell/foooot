--
--	Jackson Munsell
--	07/27/18
--	SuperJumpPowerup.lua
--
--	Super jump powerup module
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local SuperJumpPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
SuperJumpPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Advantage,
	PowerupId = PowerupId.SuperJump,
	EffectDuration = 25,
	DisplayName = 'Super Jump',
}

-- Apply effect
function SuperJumpPowerup.ApplyEffect(self, ball)
	local controller = self.match:GetDesignatedPowerupController(self, ball)
	if controller then
		self.controller = controller
		controller.jump_modifier = 1.2
	end
end
function SuperJumpPowerup.RemoveEffect(self, ball)
	if self.controller then
		self.controller.jump_modifier = 1.0
	end
end

-- return module
return SuperJumpPowerup
