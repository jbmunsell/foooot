--
--	Jackson Munsell
--	07/28/18
--	PregameMenu.lua
--
--	Pregame menu gui functionality
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'
include '/lib/classes/gui/Screen'
include '/lib/classes/gui/Carousel'

include '/data/MatchTypes'

-- Characters
local CHARACTERS = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 165, 0),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(238, 130, 238),
}

-- Module
local PregameMenu = classutil.extend(Screen)
PregameMenu.GuiPath = '/res/gui/PregameMenu'

-- Init
function PregameMenu.Init(self, settings)
	-- Super
	self.__super.Init(self)

	-- Connect to play button
	self.frame.PlayButton.Activated:connect(function()
		-- Construct settings
		local settings = {}
		settings.player1_character = self.player1_selection:GetSelection()
		settings.player2_character = self.player2_selection:GetSelection()
		settings.match_type = self.match_type_selection:GetSelection()
		settings.powerups_enabled = self.powerups_setting_selection:GetSelection()

		-- Set member to allow continuation
		self.settings = settings
	end)

	-- Create character carousels
	self.player1_selection = Carousel.new(self.frame.Player1Carousel, CHARACTERS)
	self.player2_selection = Carousel.new(self.frame.Player2Carousel, CHARACTERS)

	-- Selection
	local function update_selection(carousel, entry)
		carousel.parent.Display.BackgroundColor3 = entry
	end
	self.player1_selection:SetSelectionChangedCallback(update_selection)
	self.player2_selection:SetSelectionChangedCallback(update_selection)

	-- Create settings carousels
	self.match_type_selection = Carousel.new(self.frame.MatchTypeContainer.Carousel, MatchTypes)
	self.powerups_setting_selection = Carousel.new(self.frame.PowerupsContainer.Carousel, { true, false })
	self.match_type_selection:SetArrowSizeFactor(0.5)
	self.powerups_setting_selection:SetArrowSizeFactor(0.5)

	-- Selection change
	self.match_type_selection:SetSelectionChangedCallback(function(carousel, entry)
		carousel.parent.Display.Text = string.upper(entry.DisplayName)
	end)
	self.powerups_setting_selection:SetSelectionChangedCallback(function(carousel, entry)
		carousel.parent.Display.Text = string.upper(entry and 'On' or 'Off')
	end)

	-- Set all starting selections
	if settings then
		self.player1_selection:SelectItem(settings.player1_character)
		self.player2_selection:SelectItem(settings.player2_character)
		self.match_type_selection:SelectItem(settings.match_type)
		self.powerups_setting_selection:SelectItem(settings.powerups_enabled)
	else
		self.player1_selection:SelectRandomIndex()
		self.player2_selection:SelectRandomIndex()
	end

	-- Show
	self:Show()
end

-- Poll settings
function PregameMenu.PollSettings(self)
	while not self.settings do wait() end
	return self.settings
end

-- return module
return PregameMenu
