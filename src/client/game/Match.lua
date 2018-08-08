--
--	Jackson Munsell
--	07/20/18
--	Match.lua
--
--	Local match script
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- services
serve 'UserInputService'
serve 'RunService'
serve 'Players'

-- includes
include '/lib/util/tableutil'
include '/lib/util/classutil'

include '/lib/FX'
include '/lib/Easing'

include '/lib/classes/Timer'
include '/lib/classes/Spring'

include '/data/Flags'

include '/client/src/game/Controller'

include '/shared/src/gui/MatchGui'

include '/enum/ControlType'
include '/enum/CharacterId'
include '/enum/powerup/PowerupId'
include '/enum/powerup/PowerupState'
include '/enum/powerup/PowerupEffectType'

-- Tags
local localPlayer = Players.LocalPlayer

----------------------------------------------------------------------------------------------
-- Consts
----------------------------------------------------------------------------------------------
local GOALS_TO_WIN              = (Flags.GOLDEN_GOAL and 1 or 7)

local BALL_SPAWN_POSITION       = CFrame.new(0, 75, 0)
local BALL_SPAWN_VELOCITY_RANGE = 20
local PLAYER_SPAWN_DISTANCE     = 55
local PLAYER_SPAWN_HEIGHT       = 45

local POWERUP_CLASSES           = {}

local POWERUP_SPAWN_TIME_MIN    = 10
local POWERUP_SPAWN_TIME_MAX    = 15
local POWERUP_STAY_MIN          = 30
local POWERUP_STAY_MAX          = 45
local POWERUP_SPAWN_X_MIN       = -55
local POWERUP_SPAWN_X_MAX       = 55
local POWERUP_SPAWN_Y_MIN       = 45
local POWERUP_SPAWN_Y_MAX       = 115
----------------------------------------------------------------------------------------------
-- End consts
----------------------------------------------------------------------------------------------

-- Populate powerup classes
for _, module in pairs(get('/shared/src/game/powerups'):GetChildren()) do
	local contents = require(module)
	if contents.Data and contents.Data.PowerupId then
		POWERUP_CLASSES[contents.Data.PowerupId] = contents
	end
end

-- Powerup testing
local TEST_SINGLE_POWERUP = false
if TEST_SINGLE_POWERUP then
	local path = '/shared/src/game/powerups/GoldenBootPowerup'
	local powerup = require(get(path))
	POWERUP_CLASSES = {
		[powerup.Data.PowerupId] = powerup,
	}
end

-- Module
local Match = classutil.newclass()

-- Init
function Match.Init(self, settings)
	-- Consts
	self.BALL_ELASTICITY_REGULAR = 0.6
	self.BALL_ELASTICITY_BOUNCY  = 0.95

	-- Settings
	self.settings = settings

	-- State
	self.goal_detection_enabled    = true
	self.powerup_detection_enabled = true

	-- Modifiers
	self.ball_size_modifier = 1
	self.gravity_modifier = 1

	-- Tables
	self.powerups = {}
	self.touch_trackers = {}
	self.score = {
		[CharacterId.Player1] = 0,
		[CharacterId.Player2] = 0,
	}

	-- Timers
	self.powerup_spawn_timer = Timer.new(
		POWERUP_SPAWN_TIME_MIN,
		POWERUP_SPAWN_TIME_MAX,
		function() self:SpawnRandomPowerup() end
	)

	-- Gui
	self.gui = MatchGui.new()
	UserInputService.MouseIconEnabled = false

	-- Init
	self:InitObjects()
	self:InitControllers()
	self:InitCamera()

	-- Start play
	spawn(function()
		self:StartPlay()
	end)

	-- Goal line technology
	self.heartbeat = RunService.Heartbeat:connect(function(dt)
		self:Update(dt)
	end)
end
function Match.InitObjects(self)
	-- Clear old
	for i = 1, 2 do
		local model = workspace:FindFirstChild('Controller_Player' .. i)
		if model then model:Destroy() end
	end

	-- Create bin
	self.bin = new('Model', workspace, { Name = 'MatchBin' })

	-- Create ball
	self.balls = {}

	-- Tag goals
	self.left_goal = workspace.GoalLeft
	self.right_goal = workspace.GoalRight
end
function Match.InitControllers(self)
	-- Create controller for keyboard left
	self.controller_left = Controller.new(self.settings.player1_character, ControlType.KeyboardLeft)
	self.controller_right = Controller.new(self.settings.player2_character, ControlType.KeyboardRight)
	self.controller_left:Connect(CharacterId.Player1, self.bin)
	self.controller_right:Connect(CharacterId.Player2, self.bin)
end

-- Camera stuff
function Match.InitCamera(self)
	-- Set camera point
	local camera = workspace.CurrentCamera
	local CAMERA_CFRAME = CFrame.new(Vector3.new(0, 90, 350), Vector3.new(0, 90, 0))
	camera.FieldOfView = 20

	-- Create cam shake spring
	self.camshake = Spring.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
	self.camshake.speed = 20

	-- Connect to render step for shake
	RunService.RenderStepped:connect(function(dt)
		self.camshake:Update(dt)
		camera.CFrame = CAMERA_CFRAME + self.camshake.position
	end)
end
function Match.ShakeCamera(self)
	local JIP = 40
	spawn(function()
		local connection = RunService.Heartbeat:connect(function(dt)
			self.camshake.velocity = self.camshake.velocity + Vector3.new(math.random(-JIP, JIP), math.random(-JIP, JIP), 0)
		end)
		delay(1.4, function()
			connection:disconnect()
		end)
	end)
end

-- Spawn ball
function Match.ClearBalls(self)
	for _, ball in pairs(self.balls) do
		self.touch_trackers[ball] = nil
		ball:Destroy()
	end
	self.balls = {}
end
function Match.AddBall(self, ball)
	-- Parent and insert
	ball.Parent = self.bin
	table.insert(self.balls, ball)

	-- Listen for touched
	local controllers = {self.controller_left, self.controller_right}
	local last_sound = 0
	local FREQUENCY_THRESHOLD = 0.1
	ball.PrimaryPart.Touched:connect(function(hit)
		-- Particles
		local offset = (hit.Position - ball.PrimaryPart.Position)
		local contact = CFrame.new(ball.PrimaryPart.Position + offset.unit * ball.PrimaryPart.Size.X * .5)
		FX.EmitAmountFromContainer(get('/res/emitters/BallHit'), contact, 1)

		-- Crossbar reaction
		if hit.Name == 'Crossbar' and ball.PrimaryPart.Velocity.magnitude > 20 then
			workspace.GameSounds.BallHitBar:Play()
			workspace.GameSounds.CrossbarPing:Play()
			-- Commented out because it's not a good check. Since velocity is already changed by the time touched fires, we don't know if it was a rebound
			-- if (-ball.PrimaryPart.Velocity.X * hit.Parent.GoalPlane.CFrame.lookVector.Z) > 0 then
				workspace.GameSounds.NearMiss:Play()
			-- end
		end

		-- Do hit sound
		local stamp = tick()
		if ball.PrimaryPart.Velocity.magnitude > 1 and stamp - last_sound >= FREQUENCY_THRESHOLD then
			local sound = workspace.GameSounds.BallHit
			for _, powerup in pairs(self.powerups) do
				if powerup.state == PowerupState.Active and powerup.Data.PowerupId == PowerupId.BouncyBall then
					sound = workspace.GameSounds.BouncyBallHit
				end
			end
			last_sound = stamp
			sound:Play()
		end
		for _, controller in pairs(controllers) do
			if hit:IsDescendantOf(controller:GetCharacter()) then
				self.touch_trackers[ball] = controller
				break
			end
		end
	end)
end
function Match.SpawnBall(self, position)
	-- Clone new
	local ball = clone('/res/models/balls/StandardBall')
	self:SetBallElasticity(ball, self.BALL_ELASTICITY_REGULAR)
	self:ChangeSingleBallSizeModifier(ball, 1, self.ball_size_modifier)
	ball.PrimaryPart.CFrame = (position and CFrame.new(position) or BALL_SPAWN_POSITION)
	ball.PrimaryPart.Velocity = Vector3.new(
		math.random(-BALL_SPAWN_VELOCITY_RANGE, BALL_SPAWN_VELOCITY_RANGE),
		math.random(0, BALL_SPAWN_VELOCITY_RANGE),
		0)
	self:AddBall(ball)
end
function Match.SetBallsAnchored(self, anchored)
	for _, ball in pairs(self.balls) do
		ball.PrimaryPart.Anchored = anchored
	end
end
function Match.SetBallElasticity(self, ball, elasticity)
	local old = ball.PrimaryPart.CustomPhysicalProperties
	ball.PrimaryPart.CustomPhysicalProperties = PhysicalProperties.new(
		old.Density,
		old.Friction,
		elasticity,
		old.FrictionWeight,
		old.ElasticityWeight
	)
end
function Match.ChangeSingleBallSizeModifier(self, ball, old, modifier)
	local factor = modifier / old
	FX.ScaleModel(ball, factor)
	ball.PrimaryPart.UpForce.Force = ball.PrimaryPart.UpForce.Force * math.pow(factor, 3)
end
function Match.SetBallSizeModifier(self, modifier)
	local old = self.ball_size_modifier
	for _, ball in pairs(self.balls) do
		self:ChangeSingleBallSizeModifier(ball, old, modifier)
	end
	self.ball_size_modifier = modifier
end
function Match.SetGravityModifier(self, modifier)
	local f = (modifier / self.gravity_modifier)
	workspace.Gravity = workspace.Gravity * f
	self.gravity_modifier = modifier
	for _, ball in pairs(self.balls) do
		ball.PrimaryPart.UpForce.Force = ball.PrimaryPart.UpForce.Force * f
	end
end

-- Start play
function Match.StartPlay(self)
	-- Cleanup play
	self:CleanupPlay()

	-- Spawn new ball
	self:SpawnBall()
	self:SetBallsAnchored(true)

	-- Enable goal detection
	self.goal_detection_enabled = true

	-- Reset character positions and velocities
	local left = self.controller_left:GetCharacter()
	local right = self.controller_right:GetCharacter()
	left:SetPrimaryPartCFrame(CFrame.new(-PLAYER_SPAWN_DISTANCE, PLAYER_SPAWN_HEIGHT, 0))
	right:SetPrimaryPartCFrame(CFrame.new(PLAYER_SPAWN_DISTANCE, PLAYER_SPAWN_HEIGHT, 0) * CFrame.Angles(0, math.pi, 0))
	for _, character in pairs({left, right}) do
		character.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
		character.PrimaryPart.BodyPositionX.Position = character.PrimaryPart.Position
	end

	-- Lock controls until the countdown ends
	self.controller_left:LockControls()
	self.controller_right:LockControls()

	-- Countdown
	for i = 3, 1, -1 do
		self.gui:SetCountdownText(i)
		self.gui:ShowCountdownLabel() -- Call after setting so that it's after the text is set
		wait(1)
	end
	self.gui:HideCountdownLabel()

	-- Unlock controls
	self:SetBallsAnchored(false)
	self.controller_left:UnlockControls()
	self.controller_right:UnlockControls()
end
function Match.CleanupPlay(self)
	-- Hide goal
	self.gui:HideScoreLabel()

	-- Clear stuff
	self:ClearPowerups()
	self:ClearBalls()
end

-- Powerup functions
function Match.ClearPowerups(self)
	for i = #self.powerups, 1, -1 do
		local powerup = self.powerups[i]
		powerup:Destroy()
		table.remove(self.powerups, i)
	end
end
function Match.SpawnPowerup(self, powerup_id, position)
	-- Get class from id
	local class = POWERUP_CLASSES[powerup_id]
	if not class then
		error('No powerup class found for powerup id ' .. powerup_id)
	end

	-- Create new powerup
	local powerup = class.new(self)
	powerup:Spawn(position or Vector3.new(0, 50, 0))

	-- Insert
	table.insert(self.powerups, powerup)

	-- return powerup
	return powerup
end
function Match.SpawnRandomPowerup(self)
	-- Select a random id
	local ids = {}
	for id, class in pairs(POWERUP_CLASSES) do
		table.insert(ids, id)
	end

	-- Get random
	local id = tableutil.getrandom(ids)
	local powerup = self:SpawnPowerup(id, Vector3.new(
		math.random(POWERUP_SPAWN_X_MIN, POWERUP_SPAWN_X_MAX),
		math.random(POWERUP_SPAWN_Y_MIN, POWERUP_SPAWN_Y_MAX),
		0
	))

	-- Delay destruction if still spawned
	delay(math.random(POWERUP_STAY_MIN, POWERUP_STAY_MAX), function()
		if powerup.state == PowerupState.Spawned then
			powerup:Despawn()
		end
	end)
end

-- Register goal
-- 	Accepts a CharacterId enum of the player that scored as a parameter
function Match.RegisterGoal(self, scorer)
	-- Disable goal detection
	self.goal_detection_enabled = false

	-- Play goal scored sound
	local sound = workspace.GameSounds.GoalScored
	sound.TimePosition = 1.0
	sound.Volume = 0.5
	sound:Play()
	delay(3.5, function()
		Easing.Ease(1.0, 'linear', Easing.Action(sound, 'Volume', 0))
	end)

	-- Shake
	self:ShakeCamera()

	-- Check win conditions
	local score_text = 'scored'
	local score = self.score[scorer] + 1
	self.score[scorer] = score
	if score >= GOALS_TO_WIN then
		score_text = 'wins'
		delay(3, function()
			self.completed = true
		end)
	else
		-- Delay reset play
		delay(3, function()
			self:StartPlay()
		end)
	end
	self.gui:UpdateScoreDisplay(self.score)

	-- Show goal text
	self.gui:ShowScoreLabel(string.format('%s %s!', string.upper(tableutil.getkey(CharacterId, scorer)), string.upper(score_text)))
end

-- Check goals
function Match.CheckGoals(self)
	-- Check all balls
	for _, ball in pairs(self.balls) do
		-- Tag stuff
		local part = ball.PrimaryPart
		local left_goal = self.left_goal
		local right_goal = self.right_goal

		-- Try left
		local left_goal_plane = left_goal.GoalPlane
		local right_goal_plane = right_goal.GoalPlane
		if (part.Position.X + part.Size.X * .5) < left_goal_plane.Position.X and part.Position.Y < left_goal_plane.Position.Y + left_goal_plane.Size.Y * .5
		and part.Position.Y > left_goal_plane.Position.Y - left_goal_plane.Size.Y * .5 then
			self:RegisterGoal(CharacterId.Player2)
			break

		-- Try right
		elseif (part.Position.X - part.Size.X * .5) > right_goal_plane.Position.X and part.Position.Y < right_goal_plane.Position.Y + right_goal_plane.Size.Y * .5
		and part.Position.Y > right_goal_plane.Position.Y - right_goal_plane.Size.Y * .5 then
			self:RegisterGoal(CharacterId.Player1)
			break
		end
	end
end

-- Check powerup against balls
function Match.CheckPowerupAgainstBalls(self, powerup)
	-- Check all balls
	for _, ball in pairs(self.balls) do
		local bnp = (ball.PrimaryPart.Position - Vector3.new(0, 0, ball.PrimaryPart.Position.Z)) - powerup.position
		local dist = bnp:Dot(bnp)
		if dist <= math.pow((ball.PrimaryPart.Size.X + powerup.model.Coin.Size.Y) * .5, 2) then
			-- Collect powerup
			powerup:ShowCollection()
			powerup:Activate(ball)
			self.gui:ShowPowerupLabel(string.upper(powerup.Data.DisplayName), 2, powerup.polarity)
			break
		end
	end
end

-- Get designated powerup controller
function Match.GetDesignatedPowerupController(self, powerup, ball)
	-- Get the guy that last touched it
	local toucher = self.touch_trackers[ball]
	if not toucher then
		warn('No toucher for ball')
		return
	end

	-- Get other guy
	local other = (toucher == self.controller_left and self.controller_right or self.controller_left)

	-- Check who to affect based on polarity
	if powerup.polarity == PowerupEffectType.Good then
		-- If it's a disadvantage, then apply to the other guy. Else apply to us
		return (powerup.Data.PowerupEffectType == PowerupEffectType.Disadvantage and other or toucher)
	elseif powerup.polarity == PowerupEffectType.Bad then
		-- If it's an advantage, then apply it to the other guy. Else apply it to us
		return (powerup.Data.PowerupEffectType == PowerupEffectType.Advantage and other or toucher)
	else
		error(string.format('Unsure how to handle powerup polarity: %d', powerup.polarity))
	end
end

-- Update
function Match.Update(self, dt)
	-- Goal line technology
	if self.goal_detection_enabled then
		self:CheckGoals()
	end

	-- Powerup technology
	if self.settings.powerups_enabled and self.powerup_detection_enabled then
		-- Check all active powerups
		for i = #self.powerups, 1, -1 do
			local powerup = self.powerups[i]
			if powerup.state == PowerupState.Spawned then
				-- Check balls
				self:CheckPowerupAgainstBalls(powerup)
			elseif powerup.state == PowerupState.Destroyed then
				table.remove(self.powerups, i)
			end
		end

		-- Step timer
		self.powerup_spawn_timer:Step(dt)
	end
end

-- Poll completion
function Match.PollCompletion(self)
	while not self.completed do wait() end
end

-- Destroy
function Match.Destroy(self)
	-- Cleanup play
	self:CleanupPlay()

	-- Put mouse back
	UserInputService.MouseIconEnabled = true

	-- Destroy gui
	self.gui:Destroy()

	-- Controllers
	self.controller_left:Destroy()
	self.controller_right:Destroy()

	-- Update
	self.heartbeat:disconnect()

	-- Model
	self.bin:Destroy()

	-- Done. Local kernel listens to this so that it can show start menu again
	-- 	once match is complete
	self.destroyed = true
end

-- return module
return Match
