--
--	Jackson Munsell
--	07/27/18
--	MatchGui.lua
--
--	Match gui functionality
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/Easing'
include '/lib/GLib'
include '/lib/util/classutil'

include '/lib/classes/gui/Screen'

include '/enum/CharacterId'

-- Module
local MatchGui = classutil.extend(Screen)
MatchGui.GuiPath = '/res/gui/MatchGui'

-- Init
function MatchGui.Init(self)
	-- Super
	self.__super.Init(self)

	-- Hide all elements
	self:HideScoreLabel(true)
	self:HidePowerupLabel(true)
	self:HideCountdownLabel()

	-- Set score text
	self.container.ScoreDisplay.Text = '0-0'

	-- Show
	self:Show()
end

-- Hide labels
function MatchGui.HideLabel(self, label, instant)
	Easing.Ease((instant and 0 or 0.25), 'outQuad', Easing.Action(label, 'FrameTransparency', 1))
end
function MatchGui.HideScoreLabel(self, instant)
	self:HideLabel(self.container.PlayerScoreLabel, instant)
end
function MatchGui.HidePowerupLabel(self, instant)
	self:HideLabel(self.container.PowerupLabel, instant)
end
function MatchGui.HideCountdownLabel(self)
	self:HideLabel(self.container.CountdownLabel, true)
end

-- Set countdown text
function MatchGui.SetCountdownText(self, count)
	self.container.CountdownLabel.Text = tostring(count)
end
function MatchGui.ShowCountdownLabel(self)
	GLib.SetTransparency(self.container.CountdownLabel, 0)
end

-- Show score label
function MatchGui.ShowScoreLabel(self, text)
	local label = self.container.PlayerScoreLabel
	label.Text = text
	GLib.SetTransparency(label, 0)
end

-- Show powerup label
function MatchGui.ShowPowerupLabel(self, text, duration)
	local label = self.container.PowerupLabel
	label.Text = text
	GLib.SetTransparency(label, 0)
	delay(duration, function()
		self:HidePowerupLabel()
	end)
end

-- Update score display
function MatchGui.UpdateScoreDisplay(self, score)
	self.container.ScoreDisplay.Text = string.format('%d-%d', score[CharacterId.Player1], score[CharacterId.Player2])
end

-- return module
return MatchGui
