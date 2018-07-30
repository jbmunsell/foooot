--
--	Jackson Munsell
--	07/26/18
--	Screen.lua
--
--	Screen class module script
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- services
serve 'Players'

-- includes
include '/lib/util/classutil'

-- Module
local Screen = classutil.newclass()

-- Init
function Screen.Init(self)
	-- Check for gui path
	if not self.GuiPath then
		error('Screen subclass has no GuiPath property')
	end

	-- Get
	local screen = get(self.GuiPath)
	if not screen then
		error('No screen found for GuiPath \'%s\'', self.GuiPath)
	end

	-- Clone
	self.screen = clone(screen, Players.LocalPlayer:WaitForChild('PlayerGui'), { Enabled = false })
	self.container = self.screen:FindFirstChild('Container')
	self.components = self.screen:FindFirstChild('Components')
	self.frame = self.container and self.container:FindFirstChild('Frame')
end

-- Show
function Screen.Show(self)
	self.screen.Enabled = true
end

-- Destroy
function Screen.Destroy(self)
	-- Debounce
	if self.destroying or self.destroyed then return end
	self.destroying = true

	-- Destroy screen
	if self.screen then
		self.screen:Destroy()
	end

	-- Set final flag
	self.destroyed = true
	self.destroying = false
end

-- return module
return Screen
