--
--	Jackson Munsell
--	07/24/18
--	Powerup.lua
--
--	Powerup superclass script
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/Easing'

include '/lib/util/tableutil'
include '/lib/util/classutil'

include '/data/Flags'

include '/enum/powerup/PowerupId'
include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupState'

-- Consts
local EFFECT_TYPE_COLORS = {
	[PowerupEffectType.Neutral] = Color3.fromRGB(255, 255, 0),
	[PowerupEffectType.Good]    = Color3.fromRGB(0, 255, 0),
	[PowerupEffectType.Bad]     = Color3.fromRGB(255, 0, 0),
}
local POWERUP_POLARITIES = {
	PowerupEffectType.Good,
	PowerupEffectType.Bad,
}

-- Module
local Powerup = classutil.newclass()

-- Init
function Powerup.Init(self, match)
	-- Set match
	self.match = match

	-- Assing polarity
	if self.Data.PowerupEffectType == PowerupEffectType.Advantage or self.Data.PowerupEffectType == PowerupEffectType.Disadvantage then
		if Flags.POWERUPS_BIPOLAR then
			self.polarity = (tableutil.getrandom(POWERUP_POLARITIES))
		else
			self.polarity = (self.Data.PowerupEffectType == PowerupEffectType.Advantage and PowerupEffectType.Good or PowerupEffectType.Bad)
		end
	end
end

-- Life cycle
function Powerup.Spawn(self, position)
	-- Set state
	self.state = PowerupState.Spawned

	-- Create new model
	-- 	Pull the color from our polarity, and if we don't have a polarity (neutral powerup) then use the powerup effect type (which will be neutral)
	self.model = clone('/res/models/powerups/' .. tableutil.getkey(PowerupId, self.Data.PowerupId))
	self.model.Coin.Color = EFFECT_TYPE_COLORS[self.polarity or self.Data.PowerupEffectType]
	self:SetPosition(position)

	-- Play blop
	workspace.GameSounds.PowerupSpawn:Play()

	-- Ease size in
	Easing.Ease(.4, 'outBack', Easing.Action(self.model, 'ModelScale', 0.2, 1))
	Easing.Ease(.18, 'outQuad', Easing.Action(self.model, 'ModelTransparency', 1, 0))

	-- Set parent
	self.model.Parent = self.match.bin
end
function Powerup.ShowCollection(self)
	-- Sound
	if self.polarity and self.polarity == PowerupEffectType.Bad then
		workspace.GameSounds.PowerupBad:Play()
	else
		workspace.GameSounds.PowerupGood:Play()
	end

	-- Collect
	Easing.EaseWithCallback(.3, 'outCubic', Easing.Action(self.model, 'ModelScale', 1.75), function()
		Easing.EaseWithCallback(.3, 'inCubic', Easing.Action(self.model, 'ModelScale', 0.1), function()
			self.model.Parent = nil
		end)
	end)
end
function Powerup.Activate(self, ball)
	self.state = PowerupState.Active
	self:ApplyEffect(ball)
	if self.Data.EffectDuration then
		delay(self.Data.EffectDuration, function()
			self:Destroy()
		end)
	end
end
function Powerup.Despawn(self)
	self.state = PowerupState.Despawned
	Easing.EaseWithCallback(.4, 'inBack', Easing.Action(self.model, 'ModelScale', 1, 0.1), function()
		self:Destroy()
	end)
	delay(.1, function()
		Easing.Ease(.2, 'linear', Easing.Action(self.model, 'ModelTransparency', 1))
	end)
end

-- Set position
function Powerup.SetPosition(self, position)
	self.position = position
	self.model:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(0, math.pi * .5, 0))
end

-- Apply effect
function Powerup.ApplyEffect(self, ball)
	warn('Powerup superclass ApplyEffect called. Did you forget to override?')
end

-- Cleanup
function Powerup.Destroy(self)
	-- Debounce with state
	if self.state == PowerupState.Destroyed then return end
	self.state = PowerupState.Destroyed

	-- Remove effect
	if self.RemoveEffect then
		self:RemoveEffect()
	end

	-- Model
	self.model:Destroy()

	-- Remove match reference
	self.match = nil
end

-- return class
return Powerup
