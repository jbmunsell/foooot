--
--	Jackson Munsell
--	07/08/18
--	GLib.lua
--
--	Graphics library
--

-- Module
local GLib = {}

-- Consts
GLib.GOLDEN_RATIO = 1.61803398875

-- Transparency properties of gui objects
-- 	This section is for functions that recursively set the transparency of an entire frame
-- 	based on the original values of properties. For example, if you have a frame that
-- 	is at 0.7 transparency and you call GLib.SetTransparency(frame, 0.5) then the transparency will be set to
-- 	half of the ORIGINAL transparency (which is 0.7), so the resulting transparency will be 0.35
local TransProps = {
	Frame		= {'BackgroundTransparency'},
	TextLabel	= {'BackgroundTransparency', 'TextTransparency', 'TextStrokeTransparency'},
	TextBox		= {'BackgroundTransparency', 'TextTransparency', 'TextStrokeTransparency'},
	TextButton	= {'BackgroundTransparency', 'TextTransparency', 'TextStrokeTransparency'},
	TextButton	= {'BackgroundTransparency', 'TextTransparency', 'TextStrokeTransparency'},
	ImageLabel	= {'BackgroundTransparency', 'ImageTransparency'},
	ImageButton	= {'BackgroundTransparency', 'ImageTransparency'},
	ScrollingFrame	= {'BackgroundTransparency'},
}
function GLib.LogTransparency(f)
	if not f:FindFirstChild('_Transparency') then
		local value = Instance.new('NumberValue', f)
		value.Name = '_Transparency'
		value.Value = 0
	end
	local function ltrans(ob)
		if ob:IsA('GuiObject') and TransProps[ob.ClassName] then
			for _, prop in pairs(TransProps[ob.ClassName]) do
				local pn = '_' .. prop
				local val = ob:FindFirstChild(pn)
				if not val then
					val = Instance.new('NumberValue', ob)
					val.Name = pn
				end
				val.Value = ob[prop]
			end
		end
		for _, child in pairs(ob:GetChildren()) do
			ltrans(child)
		end
	end
	ltrans(f)
end
function GLib.SetTransparency(f, trans)
	if not f:FindFirstChild('_Transparency') then GLib.LogTransparency(f) end
	local val = f:FindFirstChild('_Transparency')
	if not val then
		val = Instance.new('NumberValue', f)
		val.Name = '_Transparency'
	end
	val.Value = trans
	local function set(ob)
		if ob:IsA('GuiObject') and TransProps[ob.ClassName] then
			for _, prop in pairs(TransProps[ob.ClassName]) do
				local val = ob:FindFirstChild('_' .. prop)
				if val then
					ob[prop] = val.Value + trans * (1 - val.Value)
				end
			end
		end
		for _, child in pairs(ob:GetChildren()) do
			set(child)
		end
	end
	set(f)
end
function GLib.GetTransparency(f)
	local val = f:FindFirstChild('_Transparency')
	return val and val.Value or 0
end

-- return library
return GLib
