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
include '/shared/src/gui/PregameMenu'
include '/shared/src/gui/MatchInstructions'

include '/client/src/game/Match'

-- New loop
-- 	Create start menu
-- 		If single player, then launch single player prematch interface
-- 		Elseif online play, then launch online play interface

-- Gameplay loop
-- 	NOTE: The reason that we control things from this script instead of using button click events inside the other modules is to avoid circular dependencies.
-- 		If the control flow were event-based in the other scripts, then we would have this infinite require problem right here, which would prevent the game from ever
-- 		starting (each module requires the one that comes next clockwise).
-- 
-- 		   StartMenu
-- 	   /			  \
-- 	 /				   \
-- 	Match				PregameMenu
-- 	 \				   /
-- 	  \			 	 /
-- 	  MatchInstructions
-- 
-- 
while true do
	-- Create a start menu
	local menu = StartMenu.new()
	local option = menu:PollPlayOption()
	menu:Destroy()

	-- If option is local, then start a local match (this is the only possible case for now, because online play has not been enabled)
	if option == 'local' then
		log('local play selected')
		-- Show pregame menu and wait for settings to be submitted
		local pregame = PregameMenu.new()
		local settings = pregame:PollSettings()
		pregame:Destroy()

		-- Show match instructions and wait for them to press space
		local instructions = MatchInstructions.new()
		instructions:PollAdvance()
		instructions:Destroy()

		-- Create match and wait for it to be completed
		local match = Match.new(settings)
		match:PollCompletion()
		match:Destroy()
	elseif option == 'online' then
		error('Online play is not enabled yet.')
	else
		error('Invalid play option returned from start menu.')
	end
end

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
