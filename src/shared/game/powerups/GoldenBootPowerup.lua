--
--	Jackson Munsell
--	07/24/18
--	GoldenBootPowerup.lua
--
--	Golden boot powerup class
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local GoldenBootPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
GoldenBootPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Advantage,
	PowerupId = PowerupId.GoldenBoot,
	EffectDuration = 30,
	DisplayName = 'Golden Boot',
}

-- Apply effect
function GoldenBootPowerup.ApplyEffect(self, ball)
	local controller = self.match:GetDesignatedPowerupController(self, ball)
	if controller then
		self.controller = controller
		self.controller:SetKickSpeedModifier(4)
	end
end
function GoldenBootPowerup.RemoveEffect(self, ball)
	if self.controller then
		self.controller:SetKickSpeedModifier(1)
	end
end

-- return powerup
return GoldenBootPowerup
