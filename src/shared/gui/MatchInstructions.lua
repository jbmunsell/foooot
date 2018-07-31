--
--	Jackson Munsell
--	07/30/18
--	MatchInstructions.lua
--
--	Match instructions gui functionality
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- services
serve 'ContextActionService'

-- includes
include '/lib/util/classutil'
include '/lib/classes/gui/Screen'

-- Module
local MatchInstructions = classutil.extend(Screen)
MatchInstructions.GuiPath = '/res/gui/MatchInstructions'

-- Init
function MatchInstructions.Init(self)
	-- Screen init
	self.__super.Init(self)

	-- Show
	self:Show()
end

-- Poll space
function MatchInstructions.PollAdvance(self)
	-- Wait for space
	local space
	ContextActionService:BindAction('InstructionSpacePress', function(name, state, input)
		if state == Enum.UserInputState.Begin then
			space = true
		end
	end, false, Enum.KeyCode.Space)
	while not space do wait() end
end

-- return module
return MatchInstructions
