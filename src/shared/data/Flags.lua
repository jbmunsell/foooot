--
--	Jackson Munsell
--	08/07/18
--	Flags.lua
--
--	Flags module script
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- services
serve 'ReplicatedStorage'

-- Module
local Flags = {}

-- Flags
Flags.GOLDEN_GOAL      = false
Flags.POWERUPS_BIPOLAR = false

-- Create values to bind
local folder = new('Folder', ReplicatedStorage, { Name = 'Flags' })
for key, val in pairs(Flags) do
	local value = new('BoolValue', folder, { Name = key, Value = val })
	value.Changed:connect(function(nval)
		Flags[key] = nval
	end)
end

-- return module
return Flags
