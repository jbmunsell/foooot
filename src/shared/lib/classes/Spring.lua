--
--	Jackson Munsell
--	07/20/18
--	Spring.lua
--
--	Spring class
--

-- Consts
local e = 2.718281828459045

-- Module
local Spring = {}
Spring.__index = Spring

-- Constructor
function Spring.new(pos, goal)
	-- Create object
	local object = setmetatable({}, Spring)

	-- Set values
	object.position = pos
	object.goal = goal
	object.speed = 1
	object.damping = 1

	-- return object
	return object
end

-- Setters
function Spring.set_position(self, position)
	self.position = position
end
function Spring.set_goal(self, goal)
	self.goal = goal
end
function Spring.set_speed(self, speed)
	self.speed = speed
end
function Spring.set_damping(self, damping)
	self.damping = damping
end

-- Update
function Spring.update(dt)
	-- Coefficients
	local ppc, pvc, vvc, vpc
	
	-- Over damped
	if damping > 1 then
		local za = -w * damping
		local zb = w * math.sqrt(damping * damping - 1)
		local z1 = za - zb
		local z2 = za + zb
		
		local e1 = math.pow(e, z1 * dt)
		local e2 = math.pow(e, z2 * dt)
		
		local inv = 1 / (2 * zb)
		
		local e1inv = e1 * inv
		local e2inv = e2 * inv
		
		local z1e1inv = z1 * e1inv
		local z2e2inv = z2 * e2inv
		
		ppc = e1inv * z2 - z2e2inv + e2
		pvc = -e1inv + e2inv
		
		vpc = (z1e1inv - z2e2inv + e2) * z2
		vvc = -z1e1inv + z2e2inv
		
	-- Under damped
	elseif damping < 1 then
		local oz = w * damping
		local alpha = w * math.sqrt(1 - damping * damping)
		
		local et = math.pow(e, -oz * dt)
		local ct = math.cos(alpha * dt)
		local st = math.sin(alpha * dt)
		
		local invalpha = 1 / alpha
		
		local esin = et * st
		local ecos = et * ct
		local eoz = et * oz * st * invalpha
		
		ppc = ecos + eoz
		pvc = esin * invalpha
		
		vpc = -esin * alpha - oz * eoz
		vvc = ecos - eoz
		
	-- Critically damped
	elseif damping == 1 then
		local eterm = math.pow(e, -w * dt)
		local tme = dt * eterm
		local tmef = tme * w
		
		ppc = tme + eterm
		pvc = tme
		
		vpc = -w * tme
		vvc = -tme + eterm
	end
	
	-- Set position and velocity
	local oldpos = self.position - self.goal
	local oldvel = self.velocity
	
	-- Set
	self.position = oldpos * ppc + oldvel * pvc + self.goal
	self.velocity = oldpos * vpc + oldvel * vvc

	-- return
	return self.position, self.velocity
end

-- return module
return Spring
