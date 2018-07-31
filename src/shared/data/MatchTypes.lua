--
--	Jackson Munsell
--	07/30/18
--	MatchTypes.lua
--
--	Match type data
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/enum/MatchType'

-- Module
local MatchTypes = {
	{
		MatchType   = MatchType.FirstToSeven,
		DisplayName = 'First to Seven',
	},
	-- Not yet implemented in Match class
	-- {
	-- 	MatchType   = MatchType.GoldenGoal,
	-- 	DisplayName = 'Golden Goal',
	-- },
	-- {
	-- 	MatchType   = MatchType.Timed,
	-- 	DisplayName = 'Timed',
	-- },
}

-- return module
return MatchTypes
