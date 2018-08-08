--
--	Jackson Munsell
--	01/21/17
--	Action.lua
--
--	Easing action, tween object
--

-- Optional dependencies
local GLib, FX

-- Module
local Action = {}
Action.__index = Action
Action.__tostring = function(self)
	return tostring(self.ob)
end

-- Create a single hit
function Action.hit(ob, prop, val)
	-- Get a and b
	local a, b
	if type(val) == "table" then
		a, b = val.start, val.fin
	else
		a = val
	end

	-- Create object
	local object = {}

	-- Capture scale
	if FX and prop == 'ModelScale' and ob:IsA('Model') and ob.PrimaryPart then
		local s = ob.PrimaryPart.Size
		local m = math.max(s.X, s.Y, s.Z)
		object._full_scale = m
		for _, axis in pairs({'X', 'Y', 'Z'}) do
			if s[axis] == m then
				object._full_scale_axis = axis
				break
			end
		end
	end

	-- Params and starting set
	if not b then
		b = a
		if prop == "PrimaryPartCFrame" then
			a = ob:GetPrimaryPartCFrame()
		elseif GLib and prop == "FrameTransparency" then
			a = GLib.GetFrameTransparency(ob)
		elseif FX and prop == "ModelTransparency" then
			a = FX.GetModelTransparency(ob)
		elseif FX and prop == "ModelScale" then
			a = 1
		else
			a = ob[prop]
		end
	else
		if prop == "PrimaryPartCFrame" then
			ob:SetPrimaryPartCFrame(a)
		elseif GLib and prop == "FrameTransparency" then
			GLib.SetFrameTransparency(ob, a)
		elseif FX and prop == 'ModelTransparency' then
			FX.SetModelTransparency(ob, a)
		elseif FX and prop == 'ModelScale' then
			FX.ScaleModel(ob, a)
		else
			ob[prop] = a
		end
	end

	-- Select lerp function
	local lf = Action.Easing.Lerp.SelectFunction(a, b)

	-- Create object
	object.ob = ob
	object.prop = prop
	object.start = a
	object.fin = b
	object.lerp = lf

	-- return object
	return object
end

-- Constructor
function Action.new(ob, props, a, b)
	-- Includes
	if FX == nil then
		FX = false
		for _, d in pairs(game:GetService('ReplicatedStorage'):GetDescendants()) do
			if d.Name == 'FX' and d:IsA('ModuleScript') then
				FX = require(d)
			end
		end
	end
	if GLib == nil then
		GLib = false
		for _, d in pairs(game:GetService('ReplicatedStorage'):GetDescendants()) do
			if d.Name == 'GLib' and d:IsA('ModuleScript') then
				GLib = require(d)
			end
		end
	end

	-- Only one property
	if type(props) == "string" then
		props = {[props] = (a and b and {start = a, fin = b} or a)}
	end

	-- Iterate props
	local hits = {}
	for prop, val in pairs(props) do
		hits[prop] = Action.hit(ob, prop, val)
	end

	-- Return from hits
	return Action.fromHits(ob, hits)
end

-- From hits
function Action.fromHits(ob, hits)
	-- Create object
	local action = setmetatable({
		hits = hits,
		ob = ob,
		udata = type(ob) == "userdata",
	}, Action)
	return action
end

-- Step
function Action.step(self, e)
	if not self.ob or (self.udata and not self.ob.Parent) then return false end
	for prop, hit in pairs(self.hits) do
		if hit.lerp then
			local dl = hit.lerp(hit.start, hit.fin, e)
			if prop == "PrimaryPartCFrame" then
				self.ob:SetPrimaryPartCFrame(dl)
			elseif hit.prop == "FrameTransparency" then
				GLib.SetFrameTransparency(self.ob, dl)
			elseif hit.prop == "ModelTransparency" then
				FX.SetModelTransparency(self.ob, dl)
			elseif hit.prop == 'ModelScale' then
				if hit._full_scale_axis then
					FX.ScaleModel(self.ob, (hit._full_scale / self.ob.PrimaryPart.Size[hit._full_scale_axis]) * dl)
				else
					error('Attempt to scale thing with no full scale axis')
				end
			else
				self.ob[prop] = dl
			end
		else
			self.ob[prop] = hit.fin
		end
	end
end

-- Inverse
function Action.inverse(self)
	local hits = {}
	for prop, hit in pairs(self.hits) do
		hits[prop] = Action.hit(self.ob, prop, {start = hit.fin, fin = hit.start})
	end
	return Action.fromHits(self.ob, hits)
	-- return Action.new(self.ob, self.prop, self.fin, self.start)
end

-- Return Action
return Action
