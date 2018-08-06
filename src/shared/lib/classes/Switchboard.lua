--
--	Jackson Munsell
--	02/08/17
--	Switchbaord.lua
--
--	Handles lifetime and maintenance of many connection objects
--

-- Services
local UserInputService = game:GetService('UserInputService')
local ContextActionService = game:GetService('ContextActionService')

-- Module
local Switchboard = {}
Switchboard.__index = Switchboard

-- Constructor
function Switchboard.new(connections)
	local object = setmetatable({}, Switchboard)
	object.connections = connections or {}
	object.actions = {}
	return object
end

-- Bind action
function Switchboard.Bind(self, ...)
	for i, v in pairs({...}) do
		table.insert(self.connections, v)
	end
end
function Switchboard.BindAction(self, ...)
	local args = {...}
	local name = args[1]
	table.insert(self.actions, name)
	ContextActionService:BindAction(unpack(args))
end
function Switchboard.BindActionAtPriority(self, ...)
	local args = {...}
	local name = args[1]
	table.insert(self.actions, name)
	ContextActionService:BindActionAtPriority(unpack(args))
end
function Switchboard.UnbindAction(self, name)
	for i = #self.actions, 1, -1 do
		if self.actions[i] == name then
			table.remove(self.actions, i)
			ContextActionService:UnbindAction(name)
			break
		end
	end
end

-- Release method
function Switchboard.disconnect(self)
	for i, v in pairs(self.connections) do
		v:disconnect()
	end
	for i, v in pairs(self.actions) do
		ContextActionService:UnbindAction(v)
	end
	self.connections = {}
	self.actions = {}
end

-- Destroy
function Switchboard.Destroy(self)
	self:disconnect()
end

-- Return Switchboard
return Switchboard
