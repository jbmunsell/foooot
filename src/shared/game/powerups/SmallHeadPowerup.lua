--
--	Jackson Munsell
--	07/24/18
--	SmallHeadPowerup.lua
--
--	Small head powerup class
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local SmallHeadPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
SmallHeadPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Disadvantage,
	PowerupId = PowerupId.SmallHead,
	EffectDuration = 30,
	DisplayName = 'Small Head',
}

-- Apply effect
function SmallHeadPowerup.ApplyEffect(self, ball)
	local controller = self.match:GetDesignatedPowerupController(self, ball)
	if controller then
		self.controller = controller
		self.controller:SetSizeModifier(0.5)
	end
end
function SmallHeadPowerup.RemoveEffect(self, ball)
	if self.controller then
		self.controller:SetSizeModifier(1)
	end
end

-- return powerup
return SmallHeadPowerup
