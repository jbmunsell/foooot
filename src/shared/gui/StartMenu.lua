--
--	Jackson Munsell
--	07/26/18
--	StartMenu.lua
--
--	Start menu gui functionality
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

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

	-- Show
	self:Show()
end

-- return module
return StartMenu
