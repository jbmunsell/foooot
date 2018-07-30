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

-- Characters
local CHARACTERS = {
	'jackson',
	'joe',
	'brian',
}

-- Module
local PregameMenu = classutil.extend(Screen)
PregameMenu.GuiPath = '/res/gui/PregameMenu'

-- Init
function PregameMenu.Init(self)
	-- Super
	self.__super.Init(self)

	-- Create carousels
	self.player1_selection = Carousel.new(self.frame.Player1Carousel, CHARACTERS)
	self.player2_selection = Carousel.new(self.frame.Player2Carousel, CHARACTERS)

	-- Selection
	local function update_selection(carousel, entry)
		log(entry)
	end
	self.player1_selection.SelectionChanged = update_selection
	self.player2_selection.SelectionChanged = update_selection

	-- Show
	self:Show()
end

-- return module
return PregameMenu
