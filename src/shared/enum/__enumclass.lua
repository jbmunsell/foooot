--
--	Jackson Munsell
--	07/19/18
--	__enumclass.lua
--
--	Enumeration class; errors if you try to access an invalid enum item
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- Module
local __enumclass = {}
__enumclass.__index = function(tb, key)
	local val = rawget(tb, key)
	if val then
		return val
	else
		error(string.format('Invalid enum item: \'%s\'', key))
	end
end

-- return __enumclass
return function(tb)
	return setmetatable(tb, __enumclass)
end
