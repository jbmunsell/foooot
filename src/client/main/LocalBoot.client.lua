--
--	Jackson Munsell
--	07/05/18
--	LocalMain.lua
--
--	Main local script
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- services
serve 'ReplicatedStorage'
serve 'Players'

-- includes
include '/shared/src/gui/StartMenu'

-- Menu
local menu = StartMenu.new()
