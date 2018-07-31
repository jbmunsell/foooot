--
--	Jackson Munsell
--	07/28/18
--	Carousel.lua
--
--	Carousel gui class functionality module
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- includes
include '/lib/util/classutil'

-- Module
local Carousel = classutil.newclass()

-- Init
function Carousel.Init(self, parent, data)
	-- Set
	self.parent = parent

	-- Construct
	self:Construct()
	self:Connect()

	-- Set data
	self:SetData(data)
end

-- Construct
function Carousel.Construct(self)
	-- Get components folder
	local path = '/res/gui/components/carousel'
	local components = get(path)
	if not components then
		error(string.format('No carousel components found at path \'%s\'', path))
	end

	-- Copy components into parent
	for _, component in pairs(components:GetChildren()) do
		local tcom = clone(component, self.parent)
	end
end
function Carousel.SetArrowSizeFactor(self, f)
	local arrow_left = self.parent:FindFirstChild('ArrowLeft')
	local arrow_right = self.parent:FindFirstChild('ArrowRight')
	if arrow_left and arrow_right then
		for _, arrow in pairs({arrow_left, arrow_right}) do
			arrow.Size = UDim2.new(f, 0, f, 0)
		end
	end
end

-- Connect
function Carousel.Connect(self)
	-- Get stuff
	local arrow_left = self.parent:FindFirstChild('ArrowLeft')
	local arrow_right = self.parent:FindFirstChild('ArrowRight')
	if not arrow_left or not arrow_right then
		error('Arrows not found in parent')
	end

	-- Connect
	arrow_left.Activated:connect(function() self:ShiftLeft() end)
	arrow_right.Activated:connect(function() self:ShiftRight() end)
end

-- Set data
function Carousel.SetData(self, data)
	-- Assert
	if type(data) ~= 'table' then
		error(string.format('Invalid argument #1 to Carousel.SetData; table expected, got %s', type(data)))
	end

	-- Set
	self.data = data
	self:SelectIndex(1)
end
function Carousel.SetSelectionChangedCallback(self, func)
	if type(func) ~= 'function' then
		error(string.format('Invalid argument #1 to Carousel.SetSelectionChangedCallback; function expected, got %s', type(func)))
	end
	self.SelectionChanged = func
	self:SelectionChanged(self.data[self.index])
end
function Carousel.GetSelection(self)
	return self.data[self.index]
end

-- Select index
function Carousel.SelectIndex(self, index)
	-- Assert
	if not self.data then
		error('Attempt to set index with no data set')
	end

	-- Wrap index
	self.index = ((index - 1) % #self.data) + 1

	-- Grab thing
	if self.SelectionChanged then
		self:SelectionChanged(self.data[self.index])
	end
end
function Carousel.ShiftRight(self)
	self:SelectIndex(self.index + 1)
end
function Carousel.ShiftLeft(self)
	self:SelectIndex(self.index - 1)
end

-- return module
return Carousel
