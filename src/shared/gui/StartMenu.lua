--
--	Jackson Munsell
--	07/26/18
--	StartMenu.lua
--
--	Start menu gui functionality
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- services
serve 'ContextActionService'

-- includes
include '/lib/util/classutil'

include '/lib/classes/gui/Screen'

-- Module
local StartMenu = classutil.extend(Screen)
StartMenu.GuiPath = '/res/gui/StartMenu'

-- Init
function StartMenu.Init(self)
	-- Super
	self.__super.Init(self)

	-- Connect events
	self.container.PlayButton.Activated:connect(function()
		self.play_option = 'local'
		log('set play option')
	end)

	-- Play music
	workspace.GameSounds.GameMusic:Play()

	-- Show
	self:Show()
end

-- Poll play option
function StartMenu.PollPlayOption(self)
	-- Poll
	log('polling play option')
	while not self.play_option do wait() end
	log('play option found')
	return self.play_option
end

-- return module
return StartMenu
