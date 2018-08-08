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

-- Model transparency manipulation
-- 	Log model transparency. This function bookmarks the transparency values of a model's children so that it can set relative transparencies later on
function FX.LogModelTransparency(model)
	-- Tag it
	local tag = Instance.new('BoolValue', model)
	tag.Name = '_TransparencyTag'
	tag.Value = true

	-- Bookmark transparency of all descendants
	for _, object in pairs(model:GetDescendants()) do
		if object:IsA('BasePart') or object:IsA('Decal') then
			local ctval = object:FindFirstChild('_CurrentTransparency')
			if not ctval then
				ctval = Instance.new('NumberValue', object)
				ctval.Name = '_CurrentTransparency'
			end
			ctval.Value = 0

			local tval  = object:FindFirstChild('_FullTransparency')
			if not tval then
				tval = Instance.new('NumberValue', object)
				tval.Name = '_FullTransparency'
			end
			tval.Value = object.Transparency
		end
	end
end

-- 	Get model transparency. This returns the _CurrentTransparency value inside of a model
function FX.GetModelTransparency(model)
	return model:FindFirstChild('_CurrentTransparency') and model._CurrentTransparency.Value or 0
end

-- 	Set model transparency. This function sets the model transparency relative to what it was logged at. Example: if you have a model with a part in it that is
-- 		at 0.8 transparency, and then you call FX.SetModelTransparency(model, 0.5), then it will set the transparency to be half of what it was logged at, which 
-- 		would be [0.8 + 0.5 * (1 - 0.8))] = 0.9
function FX.SetModelTransparency(model, transparency)
	-- Log if not logged
	if not model:FindFirstChild('_TransparencyTag') then
		FX.LogModelTransparency(model)
	end

	-- Set current transparency
	local ctval = model:FindFirstChild('_CurrentTransparency')
	if not ctval then
		ctval = Instance.new('NumberValue', model)
		ctval.Name = '_CurrentTransparency'
	end
	ctval.Value = transparency

	-- Set all descendants based on their full transparency
	for _, object in pairs(model:GetDescendants()) do
		if object:IsA('BasePart') or object:IsA('Decal') then
			if object:FindFirstChild('_FullTransparency') and object:FindFirstChild('_CurrentTransparency') then
				object._CurrentTransparency.Value = transparency
				object.Transparency = object._FullTransparency.Value + transparency * (1 - object._FullTransparency.Value)
			end
		end
	end
end

-- Set emitters enabled
function FX.SetEmittersEnabled(container, enabled)
	for _, object in pairs(container:GetDescendants()) do
		if object:IsA('ParticleEmitter') then
			object.Enabled = enabled
		end
	end
end
function FX.EnableEmitters(container)
	FX.SetEmittersEnabled(container, true)
end
function FX.DisableEmitters(container)
	FX.SetEmittersEnabled(container, false)
end

-- Destroy emitter container
-- 	This function will disable particle emitters and then wait the maximum lifetime before destroying the container.
-- 	This should be used to destroy an emitter object without removing the particles instantly.
function FX.DestroyEmitterContainer(container)
	-- Disable emitters
	FX.DisableEmitters(container)

	-- Get max lifetime
	local mlife = 0
	for _, object in pairs(container:GetDescendants()) do
		if object:IsA('ParticleEmitter') and object.Lifetime.Max > mlife then
			mlife = object.Lifetime.Max
		end
	end

	-- Wait max and destroy
	print(mlife)
	delay(mlife, function()
		container:Destroy()
	end)
end

-- Emit from container
-- 	This function will clone the object passed as first parameter, place it at the given cframe, and emit particles of the given amount.
-- 	Then it will wait for the particles to die and destroy the emitter container.
function FX.EmitAmountFromContainer(container, cframe, amount)
	-- Clone emitter
	local em = container:clone()
	FX.DisableEmitters(em)

	-- Position based on class
	if em:IsA('BasePart') then
		em.CFrame = cframe
	elseif em:IsA('ArcHandles') then
		local attachment = Instance.new('Attachment', workspace:FindFirstChildOfClass('Terrain'))
		attachment.Name = container.Name
		attachment.CFrame = cframe
		for _, child in pairs(em:GetChildren()) do
			child.Parent = attachment
		end
		em = attachment
	end

	-- Emit
	for _, object in pairs(em:GetDescendants()) do
		if object:IsA('ParticleEmitter') then
			object:Emit(amount)
		end
	end

	-- Destroy
	FX.DestroyEmitterContainer(em)
end

-- return module
return FX
