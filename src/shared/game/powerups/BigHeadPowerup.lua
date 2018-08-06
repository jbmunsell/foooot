--
--	Jackson Munsell
--	07/24/18
--	BigHeadPowerup.lua
--
--	Big head powerup class
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local BigHeadPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
BigHeadPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Advantage,
	PowerupId = PowerupId.BigHead,
	EffectDuration = 30,
	DisplayName = 'Big Head',
}

-- Apply effect
function BigHeadPowerup.ApplyEffect(self, ball)
	local controller = self.match:GetDesignatedPowerupController(self, ball)
	if controller then
		self.controller = controller
		self.controller:SetSizeModifier(2)
	end
end
function BigHeadPowerup.RemoveEffect(self, ball)
	if self.controller then
		self.controller:SetSizeModifier(1)
	end
end

-- return powerup
return BigHeadPowerup
