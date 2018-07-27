--
--	Jackson Munsell
--	07/26/18
--	classutil.lua
--
--	Class util module
--

-- Module
local classutil = {}

-- New
function classutil.newclass()
	-- Create class
	local class = {}
	class.__index = class

	-- Constructor
	class.new = function(...)
		-- Create object
		local object = setmetatable({}, class)

		-- Init
		if object.Init then
			object:Init(...)
		end

		-- return object
		return object
	end

	-- return class
	return class
end

-- Extend
function classutil.extend(super)
	-- Assert
	if not super then
		error('No superclass provided to classutil.extend')
	end

	-- Create class
	local class = classutil.newclass()

	-- Set super
	class.__super = super
	setmetatable(class, { __index = super })

	-- return class
	return class
end

-- return module
return classutil
