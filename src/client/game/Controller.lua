--
--	Jackson Munsell
--	07/19/18
--	Controller.lua
--
--	Controller script
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- services
serve 'RunService'
serve 'UserInputService'

-- includes
include '/lib/util/tableutil'
include '/lib/util/classutil'

include '/lib/classes/Switchboard'

include '/enum/ControllerDeviceType'
include '/enum/KeyboardControlType'
include '/enum/CharacterId'

-- Consts
local BASE_JUMP_POWER      = 48
local BASE_LINEAR_VELOCITY = 14

-- Default mappings
local DEFAULT_MAPPINGS = {
	[KeyboardControlType.Left] = {
		['jump']  = Enum.KeyCode.W,
		['left']  = Enum.KeyCode.A,
		['right'] = Enum.KeyCode.D,
		['kick']  = Enum.KeyCode.Space,
	},
	[KeyboardControlType.Right] = {
		['jump']  = Enum.KeyCode.Up,
		['left']  = Enum.KeyCode.Left,
		['right'] = Enum.KeyCode.Right,
		['kick']  = Enum.KeyCode.P,
	},
}

-- Module
local Controller = classutil.newclass()

-- Get character
function Controller.GetCharacter(self)
	return self.character
end

-- Init
function Controller.Init(self, character, controller_device_type, ...)
	-- Args
	local args = {...}

	-- Set
	self.character = character
	self.ControllerDeviceType = controller_device_type
	if self.ControllerDeviceType == ControllerDeviceType.Keyboard then
		self.KeyboardControlType = args[1]
	end

	-- Members
	self.jump_modifier = 1.0
	self.speed_modifier = 1.0

	-- Update
	self.heartbeat = RunService.Heartbeat:connect(function(dt)
		self:Update(dt)
	end)
end

-- Lock controls
function Controller.LockControls(self)
	self.controls_locked = true
end
function Controller.UnlockControls(self)
	self.controls_locked = false
end

-- Connect
function Controller.Connect(self, character_id, matchbin)
	-- Set player id
	self.character_id = character_id

	-- Create character
	local character = clone('/res/models/characters/Character')
	character.PrimaryPart.Color = self.character
	character.BoxCollider.Transparency = 1
	character.Parent = matchbin
	self.character = character

	-- Rotate if player 2
	if character_id == CharacterId.Player2 then
		character:SetPrimaryPartCFrame(character:GetPrimaryPartCFrame() * CFrame.Angles(0, math.pi, 0))
	end

	-- Switch controller device type
	if self.ControllerDeviceType == ControllerDeviceType.Keyboard then
		self:BindControlMappings(DEFAULT_MAPPINGS[self.KeyboardControlType])
	end
end

-- Bind control mappings
function Controller.BindControlMappings(self, mappings)
	-- Create new switchboard
	self:UnbindMappings()
	self.board = Switchboard.new()

	-- Set mappings
	self.mappings = mappings
end
function Controller.UnbindMappings(self)
	if self.board then
		self.board:disconnect()
		self.board = nil
	end
end

-- Set velocity axis
local UNIT_VECTORS = {
	X = Vector3.new(1, 0, 0),
	Y = Vector3.new(0, 1, 0),
	Z = Vector3.new(0, 0, 1),
}
function Controller.SetVelocityAxis(self, axis, v)
	local character = self:GetCharacter()
	if character then
		local vel = character.PrimaryPart.Velocity
		character.PrimaryPart.Velocity = vel + UNIT_VECTORS[axis] * (-vel[axis] + v)
	end
end

-- Update
function Controller.Update(self, dt)
	-- Get character
	local character = self:GetCharacter()
	local root = character.PrimaryPart

	-- Controls locked
	if self.controls_locked then return end

	-- Handle keyboard controls
	if self.ControllerDeviceType == ControllerDeviceType.Keyboard then
		-- Directional
		local left  = self.mappings.left
		local right = self.mappings.right
		local jump = self.mappings.jump
		local kick = self.mappings.kick
		local body_position = root.BodyPositionX
		if left and UserInputService:IsKeyDown(left) then
			body_position.Position = root.Position + Vector3.new(-BASE_LINEAR_VELOCITY * self.speed_modifier, 0, 0)
		elseif right and UserInputService:IsKeyDown(right) then
			body_position.Position = root.Position + Vector3.new(BASE_LINEAR_VELOCITY * self.speed_modifier, 0, 0)
		else
			body_position.Position = root.Position
		end

		-- Jump
		if jump and UserInputService:IsKeyDown(jump) then
			if root.Velocity.Y <= 0.1 then
				local diff = character.BoxCollider.Position.Y - (character.BoxCollider.Size.Y + workspace.Ground.Size.Y) * .5 - workspace.Ground.Position.Y
				if diff <= 0.1 then
					self:SetVelocityAxis('Y', BASE_JUMP_POWER * self.jump_modifier)
				end
				-- local touching = character.BoxCollider:GetTouchingParts()
				-- if tableutil.getkey(touching, workspace.Ground) then
				-- 	self:SetVelocityAxis('Y', BASE_JUMP_POWER)
				-- end
			end
		end

		-- Kick
		if kick and UserInputService:IsKeyDown(kick) then
			root.Hip.TargetAngle = -50
		else
			root.Hip.TargetAngle = 10
		end
	end
end

-- Destroy
function Controller.Destroy(self)
	self.heartbeat:disconnect()
	self:UnbindMappings()
end

-- return controller
return Controller
