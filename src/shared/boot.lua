--
--	Jackson Munsell
--	07/05/18
--	boot.lua
--
--	Boot module. This script is required at the top other scripts to dump functions into the module's function environment.
-- 		Any member of the boot module is automatically dumped into the function environment which calls the function returned by this
-- 		module script.
--

-- services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

-- Module
local boot = {}

-- Get local player
boot.localPlayer = Players.LocalPlayer

-- Log functions
function boot.log(...)
	local tag = getfenv(2).script.Name
	local args = {...}
	if #args == 0 then args = {'nil'} end
	local str = tostring(table.remove(args, 1))
	local l = string.format(str, unpack(args))
	print(string.format('[%s] %s', tag, l))
end
function boot.warn(...)
	warn(string.format(...))
end
function boot.log_table(tb, tabs)
	tabs = tabs or 0
	for k, v in pairs(tb) do
		if type(v) ~= 'table' then
			print(string.format('%s[%s]: %s', string.rep('\t', tabs), tostring(k), tostring(v)))
		else
			print(string.format('%s[%s]', string.rep('\t', tabs), tostring(k)))
			boot.log_table(v, tabs + 1)
		end
	end
end

-- Fetching
function boot.get(path)
	local stems = {
		['/lib'] = ReplicatedStorage.src.lib,
		['/enum'] = ReplicatedStorage.src.enum,
		['/res'] = ReplicatedStorage.res,
		['/shared/src'] = ReplicatedStorage.src,
		['/server/src'] = ServerScriptService.src,
		['/client/src'] = Players.LocalPlayer and Players.LocalPlayer.PlayerScripts.src,
	}
	if not path then
		boot.warn('No path supplied to \'get\'')
		return
	end
	local object
	for stem, dir in pairs(stems) do
		if string.match(path, '^' .. stem) then
			object = dir
			path = string.sub(path, string.len(stem) + 2)
		end
	end
	if not object then
		boot.warn('No directory stem found for path \'%s\'', path)
	end
	for segment in string.gmatch(path, '([^/\.]+)') do
		object = object:FindFirstChild(segment)
		if not object then
			boot.warn('No object found for path \'%s\'', path)
			break
		end
	end
	return object
end

-- Environment manipulation
function boot.serve(str)
	getfenv(2)[str] = game:GetService(str)
end
function boot.include(path)
	if string.match(path, '\*$') then
		local dir = boot.get(string.sub(path, 1, -2))
		for _, child in pairs(dir:GetChildren()) do
			if child:IsA('ModuleScript') then
				getfenv(2)[child.Name] = require(child)
			end
		end
		return
	end
	local module = boot.get(path)
	if module then
		getfenv(2)[module.Name] = require(module)
	end
end

-- Instance manipulation
function boot.new(class, parent, props)
	local instance = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			instance[k] = v
		end
	end
	instance.Parent = parent
	return instance
end
function boot.clone(object, parent, props)
	if type(object) == 'string' then
		object = boot.get(object)
	end
	if not object then
		boot.warn('Invalid parameter passed to \'clone\'')
		return
	end
	local thing = object:clone()
	if props then
		for k, v in pairs(props) do
			thing[k] = v
		end
	end
	thing.Parent = parent
	return thing
end

-- return boot
return function()
	local env = getfenv(2)
	for k, v in pairs(boot) do
		env[k] = v
	end
end
