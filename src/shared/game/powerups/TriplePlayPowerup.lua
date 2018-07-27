--
--	Jackson Munsell
--	07/25/18
--	TriplePlayPowerup.lua
--
--	Turns one ball into three
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

include '/shared/src/game/powerups/Powerup'

include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupId'

-- Module
local TriplePlayPowerup = classutil.extend(Powerup)

-- Powerup static properties
-- 	Read only please
TriplePlayPowerup.Data = {
	PowerupEffectType = PowerupEffectType.Neutral,
	PowerupId = PowerupId.TriplePlay,
	DisplayName = 'Triple Ball',
}

-- Apply effect
function TriplePlayPowerup.ApplyEffect(self, ball)
	for i = 1, 2 do
		local nball = clone(ball)
		nball.CFrame = nball.CFrame + (CFrame.Angles(0, 0, math.random() * math.pi * 2) * CFrame.new(8, 0, 0)).p
		self.match:AddBall(nball)
	end
end

-- return powerup
return TriplePlayPowerup
