--
--	Jackson Munsell
--	01/21/17
--	Easing.lua
--
--	Easing library
--

-- Services
local RunService = game:GetService("RunService")

-- Modules
local Styles = require(script.Styles)
local Action = require(script.Action)
local Lerp = require(script.Lerp)

-- Module
local Easing = {
	-- Vars
	stamps = {},
	idstamps = {},
}
for k, v in pairs(Styles) do
	Easing[k] = v
end
Easing.Lerp = Lerp
Action.Easing = Easing

-- Action function
function Easing.Action(...)
	return Action.new(...)
end

-- Stamping functions
function Easing.Stamp(action, stamp)
	local tb = Easing.stamps[action.ob]
	if not tb then
		tb = {}
		Easing.stamps[action.ob] = tb
	end
	for prop, h in pairs(action.hits) do
		-- if tb[prop] and tb[prop] > stamp then return false end
		tb[prop] = stamp
		tb.__interps = (tb.__interps or 0) + 1
	end
	return true
end
function Easing.GetStamp(action, prop)
	local tb = Easing.stamps[action.ob]
	return tb and tb[prop]
end
function Easing.RemoveStamp(action)
	local tb = Easing.stamps[action.ob]
	if tb then
		for prop, v in pairs(action.hits) do
			tb[prop] = nil
			tb.__interps = tb.__interps - 1
			if tb.__interps <= 0 then
				Easing.stamps[action.ob] = nil
				break
			end
		end
	end
end

-- Identifier
function Easing.StampIdentifier(id)
	Easing.idstamps[id] = tick()
	return Easing.idstamps[id]
end
function Easing.GetIdentifierStamp(id)
	return Easing.idstamps[id]
end

-- Ease with identifier
function Easing.EaseWithIdentifierAsync(id, dur, style, ...)
	local stamp = Easing.StampIdentifier(id)
	Easing.EaseAsync(dur, style, function() if Easing.GetIdentifierStamp(id) ~= stamp then return false end end, ...)
end
function Easing.EaseWithIdentifier(...)
	local args = {...}
	spawn(function()
		Easing.EaseWithIdentifierAsync(unpack(args))
	end)
end

-- Ease function
function Easing.EaseAsync(dur, style, ...)
	-- Arguments
	if type(dur) ~= "number" then
		error('Expected number as argument #1 to EaseAsync')
	end
	if type(style) ~= "string" then
		error('Expected string as argument #2 to EaseAsync')
	end

	-- Negative duration will tween the whole thing backwards
	local _easing = true
	local ease = Easing[style]
	local neg = (dur < 0)
	dur = (neg and math.abs(dur) or dur)

	-- Assert style
	if not ease then
		error(string.format('Unable to find easing style \'%s\'', style))
	end

	-- Arguments
	local args = {...}
	local stamp = tick()
	for i, v in pairs(args) do
		if type(v) ~= "function" then
			Easing.Stamp(v, stamp)
		end
	end

	-- Zero duration
	if dur == 0 then
		for i, v in pairs(args) do
			local t = type(v)
			if t == "function" then
				v(1)
			else
				v:step(1)
			end
		end
		return
	end

	-- Begin loop
	local start = tick()
	local con
	local interrupt = false
	con = RunService.Heartbeat:connect(function()
		local e = math.min((tick() - start) / dur, 1)
		local pc = e
		e = ease(e)
		local d = (neg and 1 - e or e)
		for i = #args, 1, -1 do
			local v = args[i]
			local t = type(v)
			if t ~= "function" then
				for prop, hit in pairs(v.hits) do
					if Easing.GetStamp(v, prop) ~= stamp then
						v.hits[prop] = nil
					end
				end
				if v:step(d) == false then pc = 1; interrupt = true end
			elseif t == "function" then
				if v(d) == false then pc = 1; interrupt = true end
			end
		end
		if pc == 1 or #args == 0 then
			con:disconnect()
			_easing = false
			for k, v in pairs(args) do
				if type(v) ~= "function" then
					Easing.RemoveStamp(v)
				end
			end
		end
	end)

	-- Block thread
	repeat wait() until not _easing

	-- Return interruption
	return not interrupt
end

-- Ease synchronous
function Easing.Ease(...)
	local args = {...}
	local dur = args[1]
	if dur and dur == 0 then
		Easing.EaseAsync(unpack(args))
	else
		spawn(function()
			Easing.EaseAsync(unpack(args))
		end)
	end
end

-- Ease with a callback function
function Easing.EaseWithCallback(...)
	local args = {...}
	local cb = table.remove(args, #args)
	if type(cb) ~= "function" then
		error('Expected function as last argument to EaseWithCallback')
	end

	local function run()
		Easing.EaseAsync(unpack(args))
		cb()
	end
	if args[1] == 0 then
		run()
	else
		spawn(run)
	end
end

-- TODO
--	Keep tables for objects
-- 	Store stamps as key, value pairs in object table
-- 	Maintain '__interps' key that tracks the number of interps
-- 	Release table if __interps == 0

-- Return Easing
return Easing
