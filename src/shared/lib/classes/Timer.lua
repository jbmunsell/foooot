--
--	Jackson Munsell
--	07/24/18
--	Timer.lua
--
--	Timer module script
-- 		A timer that runs on a random time interval
--

-- Module
local Timer = {}
Timer.__index = Timer

-- Constructor
function Timer.new(min, max, hit, start_at_zero)
	-- Create object
	local object = setmetatable({}, Timer)

	-- Set
	object.min = min
	object.max = max
	object.hit = hit
	if start_at_zero then
		object._timer = 0
	else
		object:RefreshTimer()
	end

	-- return object
	return object
end

-- Refresh timer
function Timer.RefreshTimer(self)
	self._timer = math.random() * (self.max - self.min) + self.min
end

-- Step
function Timer.Step(self, dt)
	self._timer = self._timer - dt
	if self._timer <= 0 then
		self:RefreshTimer()
		if self.hit then
			self.hit()
		end
	end
end

-- return class
return Timer
