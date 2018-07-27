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

include '/enum/powerup/PowerupId'
include '/enum/powerup/PowerupEffectType'
include '/enum/powerup/PowerupState'

-- Consts
local EFFECT_TYPE_COLORS = {
	[PowerupEffectType.Neutral] = Color3.fromRGB(255, 255, 0),
	[PowerupEffectType.Good]    = Color3.fromRGB(0, 255, 0),
	[PowerupEffectType.Bad]     = Color3.fromRGB(255, 0, 0),
}

-- Module
local Powerup = classutil.newclass()

-- Init
function Powerup.Init(self, match)
	self.match = match
end

-- Life cycle
function Powerup.Spawn(self, position)
	-- Set state
	self.state = PowerupState.Spawned

	-- Create new model
	self.model = clone('/res/models/powerups/' .. tableutil.get_key(PowerupId, self.Data.PowerupId), self.match.bin)
	self.model.Coin.Color = EFFECT_TYPE_COLORS[self.Data.PowerupEffectType]
	self:SetPosition(position)

	-- Ease size in
	-- Easing.Ease(.4, 'outBack', Easing.Action(self.model, 'ModelScale', 0, 1))
	-- Easing.Ease(.18, 'outQuad', Easing.Action(self.model, 'ModelTransparency', 1, 0))
end
function Powerup.ShowCollection(self)
	self.model.Parent = nil
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
function Powerup.ShowDespawn(self)
	-- TODO
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
