--
--	Jackson Munsell
--	01/21/17
--	Lerp.lua
--
--	Lerps anything ever
--

-- Module
local Lerp = {}
setmetatable(Lerp, Lerp)

-- Lerp functions
-- 		Number
function Lerp.number(a, b, e)
	return b * e + a * (1 - e)
end

-- 		Color3
function Lerp.Color3(a, b, e)
	-- TODO: Convert through a better color space
	local lerp = Lerp.number
	return Color3.new(lerp(a.r, b.r, e), lerp(a.g, b.g, e), lerp(a.b, b.b, e))
end

-- 		UDim2
function Lerp.UDim2(a, b, e)
	local lerp = Lerp.number
	return UDim2.new(lerp(a.X.Scale, b.X.Scale, e), lerp(a.X.Offset, b.X.Offset, e),
					 lerp(a.Y.Scale, b.Y.Scale, e), lerp(a.Y.Offset, b.Y.Offset, e))
end

-- 		Vector3
function Lerp.Vector3(a, b, e)
	return a:lerp(b, e)
end
function Lerp.Vector2(a, b, e)
	return a:lerp(b, e)
end

-- 		CFrame
Lerp.CFrame = Lerp.Vector3
Lerp.Vector2 = Lerp.Vector3

-- Select lerp function
function Lerp.SelectFunction(a, b)
	-- Check types
	local ta, tb = typeof(a), typeof(b)
	if ta ~= tb then
		error(string.format("Type '%s' of argument #2 does not match type '%s' of argument #1", tb, ta))
	end

	-- Spit out function
	return Lerp[ta]
end

-- Main lerp function
function Lerp.__call(self, a, b, e)
	return self.SelectFunction(a, b)(a, b, e)
end

-- Return Lerp
return Lerp
