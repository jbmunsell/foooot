--
--	Jackson Munsell
--	07/05/18
--	LocalMain.lua
--
--	Main local script
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/shared/src/gui/StartMenu'

include '/client/src/game/Match'

-- Gameplay loop
while true do
	-- Create a start menu
	local menu = StartMenu.new()
	while not menu.destroyed do
		wait()
	end

	-- Create a match
	local match = Match.new()
	while not match.destroyed do
		wait()
	end
end
