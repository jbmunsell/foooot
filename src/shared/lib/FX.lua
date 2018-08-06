--
--	Jackson Munsell
--	08/01/18
--	FX.lua
--
--	Effects module; contains functions that manipulate objects for effects
--

-- Module
local FX = {}

-- Scale model
-- 	The first parameter is a model, and the second is the factor by which to scale the model.
-- 	This does not store scales of models, so if you call FX.ScaleModel(model, 2) three times in a row, the model will be
-- 		scaled up by a factor of 8.
function FX.ScaleModel(model, f)
	-- Assert primary part
	if not model.PrimaryPart then
		error('Attempt to scale a model with no primary part')
	end

	-- Function to iterate
	local function iterate(func)
		for _, d in pairs(model:GetDescendants()) do
			func(d)
		end
	end

	-- Take a snapshot of the joints
	-- 	When parts are resized, their joints will be destroyed. We have to take a snapshot of them and recreate them
	-- 	after the parts are resized to preserve them.
	local joints = {}
	iterate(function(d)
		if d:IsA('JointInstance') then
			table.insert(joints, {
				Part0 = d.Part0,
				Part1 = d.Part1,
				C0 = d.C0,
				C1 = d.C1,
				Parent = d.Parent,
				ClassName = d.ClassName,
			})
		end
	end)
	
	-- Resize stuff
	iterate(function(d)
		if d:IsA('BasePart') then
			if d ~= model.PrimaryPart then
				local off = model.PrimaryPart.CFrame:toObjectSpace(d.CFrame)
				d.CFrame = d.CFrame + (f - 1) * off.p
			end
			d.Size = d.Size * f
		-- elseif d:IsA('JointInstance') then
		-- 	d.C0 = d.C0 + (f - 1) * d.C0.p
		-- 	d.C1 = d.C1 + (f - 1) * d.C1.p
		elseif d:IsA('Attachment') then
			d.CFrame = d.CFrame + (f - 1) * d.CFrame.p
		end
	end)

	-- Restore joints
	for _, props in pairs(joints) do
		-- Prepare array for properties
		local class, parent = props.ClassName, props.Parent
		props.ClassName = nil
		props.Parent = nil

		-- Create
		local joint = Instance.new(class)
		for k, v in pairs(props) do
			joint[k] = v
		end
		joint.Parent = parent
	end
end

-- return module
return FX
