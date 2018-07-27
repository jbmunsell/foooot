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

	-- Set visibility
	self.container.PrimaryContainer.Visible = true
	self.container.InstructionsContainer.Visible = false

	-- Connect events
	self.container.PrimaryContainer.PlayButton.Activated:connect(function()
		-- Hide main
		self.container.PrimaryContainer.Visible = false
		self.container.InstructionsContainer.Visible = true

		-- Wait for space
		local space
		ContextActionService:BindAction('InstructionSpacePress', function(name, state, input)
			if state == Enum.UserInputState.Begin then
				space = true
			end
		end, false, Enum.KeyCode.Space)
		while not space do wait() end

		-- Destroy
		self:Destroy()
	end)

	-- Show
	self:Show()
end

-- return module
return StartMenu
