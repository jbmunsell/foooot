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

	-- Params and starting set
	if not b then
		b = a
		if prop == "PrimaryPartCFrame" then
			a = ob:GetPrimaryPartCFrame()
		elseif GLib and prop == "FrameTransparency" then
			a = GLib.GetTransparency(ob)
		elseif FX and ((prop == "Transparency" and not ob:IsA("BasePart") and not ob:IsA("Decal") and not ob:IsA("Texture")) 
						or (prop == "ModelTransparency"))
		then
			a = FX.GetTransparency(ob)
		else
			a = ob[prop]
		end
	else
		if prop == "PrimaryPartCFrame" then
			ob:SetPrimaryPartCFrame(a)
		elseif GLib and prop == "FrameTransparency" then
			GLib.SetTransparency(ob, a)
		elseif FX and ((prop == "Transparency" and not ob:IsA("BasePart") and not ob:IsA("Decal") and not ob:IsA("Texture"))
						or (prop == "ModelTransparency"))
		then
			FX.SetTransparency(ob, a)
		else
			ob[prop] = a
		end
	end

	-- Select lerp function
	local lf = Action.Easing.Lerp.SelectFunction(a, b)

	-- Create object
	return {
		ob = ob,
		prop = prop,
		start = a,
		fin = b,
		lerp = lf,
	}
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
				GLib.SetTransparency(self.ob, dl)
			elseif hit.prop == "Transparency" and not self.ob:IsA("BasePart") and not self.ob:IsA("Decal") and not self.ob:IsA("Texture") then
				FX.SetTransparency(self.ob, dl)
			elseif hit.prop == "ModelTransparency" then
				FX.SetTransparency(self.ob, dl)
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
