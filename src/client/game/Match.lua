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
serve 'RunService'
serve 'Players'

-- includes
include '/lib/Roact'
include '/lib/Rodux'
include '/lib/RoactRodux'
include '/lib/GLib'

include '/lib/util/tableutil'

include '/lib/classes/Timer'

include '/client/src/Controller'

include '/shared/src/gui/classes/Screen'

include '/shared/src/gui/ScoreDisplay'
include '/shared/src/gui/GoalText'
include '/shared/src/gui/PlayCountdown'
include '/shared/src/gui/PowerupText'

include '/enum/ControllerDeviceType'
include '/enum/KeyboardControlType'
include '/enum/CharacterId'
include '/enum/powerup/PowerupId'
include '/enum/powerup/PowerupState'

-- Tags
local c = Roact.createElement
local local_player = Players.LocalPlayer

----------------------------------------------------------------------------------------------
-- Consts
----------------------------------------------------------------------------------------------
local GOALS_TO_WIN              = 7

local BALL_SPAWN_POSITION       = CFrame.new(0, 75, 0)
local BALL_SPAWN_VELOCITY_RANGE = 20
local PLAYER_SPAWN_DISTANCE     = 55
local PLAYER_SPAWN_HEIGHT       = 45

local POWERUP_CLASSES           = {}

local POWERUP_SPAWN_TIME_MIN    = 15
local POWERUP_SPAWN_TIME_MAX    = 30
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

-- Module
local Match = {}
Match.__index = Match

-- Constructor
function Match.new()
	-- Create object
	local object = setmetatable({}, Match)

	-- Init
	object:Init()

	-- return object
	return object
end

-- Init
function Match.Init(self)
	-- Constas
	self.BALL_ELASTICITY_REGULAR = 0.6
	self.BALL_ELASTICITY_BOUNCY  = 0.95

	-- State
	self.goal_detection_enabled    = true
	self.powerup_detection_enabled = true

	-- Tables
	self.powerups = {}

	-- Timers
	self.powerup_spawn_timer = Timer.new(
		POWERUP_SPAWN_TIME_MIN,
		POWERUP_SPAWN_TIME_MAX,
		function() self:SpawnRandomPowerup() end
	)

	-- Init
	self:InitObjects()
	self:InitGui()
	self:InitControllers()

	-- Start play
	self:StartPlay()

	-- Goal line technology
	self.heartbeat = RunService.Heartbeat:connect(function(dt)
		self:Update(dt)
	end)
end
function Match.InitObjects(self)
	-- Create bin
	self.bin = new('Model', workspace)

	-- Create ball
	self.balls = {}

	-- Tag goals
	self.left_goal = workspace.GoalLeft
	self.right_goal = workspace.GoalRight

	-- Set camera point
	local camera = workspace.CurrentCamera
	camera.CFrame = CFrame.new(Vector3.new(0, 90, 350), Vector3.new(0, 90, 0))
	camera.FieldOfView = 20
end
function Match.InitGui(self)
	-- Create gui store
	self.store = Rodux.Store.new(Match.reduce)

	-- Wrap elements in a store
	self.gui = c(RoactRodux.StoreProvider, {
		store = self.store,
	}, {
		Main = Roact.createElement(Screen, {}, {
			c(GoalText),
			c(PlayCountdown),
			c(ScoreDisplay),
			c(PowerupText),
		}),
	})

	-- Mount
	self.gui_handle = Roact.mount(self.gui, local_player.PlayerGui)
end
function Match.InitControllers(self)
	-- Create controller for keyboard left
	self.controller_left = Controller.new(ControllerDeviceType.Keyboard, KeyboardControlType.Left)
	self.controller_right = Controller.new(ControllerDeviceType.Keyboard, KeyboardControlType.Right)
	self.controller_left:Connect(CharacterId.Player1)
	self.controller_right:Connect(CharacterId.Player2)
end

-- reduce gui state
function Match.reduce(state, action)
	state = state or {
		showing_goal_text = false,
		showing_countdown = false,
		showing_powerup_text = false,
		countdown_count = 0,

		score = {
			[CharacterId.Player1] = 0,
			[CharacterId.Player2] = 0,
		},
	}

	local nstate = {}

	if action.type == 'HIDE_GOAL_TEXT' then
		nstate.showing_goal_text = false
	elseif action.type == 'GOAL_SCORED' then
		nstate.score = {}
		local pscore = state.score[action.scorer] + 1
		nstate.score[action.scorer] = pscore
		nstate.showing_goal_text = true
		local pkey = string.upper(tableutil.get_key(CharacterId, action.scorer))
		if pscore >= GOALS_TO_WIN then
			nstate.goal_text = string.format('%s WINS!', pkey)
		else
			nstate.goal_text = string.format('GOAL BY %s!', pkey)
		end
	elseif action.type == 'SET_COUNTDOWN_TEXT' then
		nstate.showing_countdown = true
		nstate.countdown_count = action.count
	elseif action.type == 'HIDE_COUNTDOWN_TEXT' then
		nstate.showing_countdown = false
	elseif action.type == 'SHOW_POWERUP_TEXT' then
		nstate.showing_powerup_text = true
		nstate.powerup_text = action.text
	elseif action.type == 'HIDE_POWERUP_TEXT' then
		nstate.showing_powerup_text = false
	end

	if nstate then
		return tableutil.merge_into_new(state, nstate)
	end

	return state
end

-- Spawn ball
function Match.ClearBalls(self)
	for _, ball in pairs(self.balls) do
		ball:Destroy()
	end
	self.balls = {}
end
function Match.AddBall(self, ball)
	ball.Parent = self.bin
	table.insert(self.balls, ball)
end
function Match.SpawnBall(self, position)
	-- Clone new
	local ball = clone('/res/models/balls/StandardBall')
	self:SetBallElasticity(ball, self.BALL_ELASTICITY_REGULAR)
	ball.CFrame = (position and CFrame.new(position) or BALL_SPAWN_POSITION)
	ball.Velocity = Vector3.new(
		math.random(-BALL_SPAWN_VELOCITY_RANGE, BALL_SPAWN_VELOCITY_RANGE),
		math.random(0, BALL_SPAWN_VELOCITY_RANGE),
		0)
	self:AddBall(ball)
end
function Match.SetBallsAnchored(self, anchored)
	for _, ball in pairs(self.balls) do
		ball.Anchored = anchored
	end
end
function Match.SetBallElasticity(self, ball, elasticity)
	local old = ball.CustomPhysicalProperties
	ball.CustomPhysicalProperties = PhysicalProperties.new(
		old.Density,
		old.Friction,
		elasticity,
		old.FrictionWeight,
		old.ElasticityWeight
	)
end

-- Start play
function Match.StartPlay(self)
	-- Hide goal text
	self.store:dispatch({
		type = 'HIDE_GOAL_TEXT',
	})

	-- Spawn ball
	self:ClearBalls()
	self:SpawnBall()
	self:SetBallsAnchored(true)

	-- Clear powerups
	self:ClearPowerups()

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
		self.store:dispatch({
			type = 'SET_COUNTDOWN_TEXT',
			count = i,
		})
		wait(1)
	end
	self.store:dispatch({
		type = 'HIDE_COUNTDOWN_TEXT',
	})

	-- Unlock controls
	self:SetBallsAnchored(false)
	self.controller_left:UnlockControls()
	self.controller_right:UnlockControls()
end

-- Spawn powerup
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
			powerup:Destroy()
		end
	end)
end

-- Register goal
-- 	Accepts a CharacterId enum of the player that scored
function Match.RegisterGoal(self, scorer)
	-- Disable goal detection
	self.goal_detection_enabled = false

	-- Delay reset play
	delay(3, function()
		self:StartPlay()
	end)

	-- Show goal text
	self.store:dispatch({
		type = 'GOAL_SCORED',
		scorer = scorer,
	})

	-- Check win conditions
	local state = self.store:getState()
	for character_id, score in pairs(state.score) do
		if score >= GOALS_TO_WIN then
			log('%s wins!', tableutil.get_key(CharacterId, character_id))
			delay(3, function()
				self:Destroy()
			end)
		end
	end
end

-- Check goals
function Match.CheckGoals(self)
	-- Check all balls
	for _, ball in pairs(self.balls) do
		-- Tag stuff
		local left_goal = self.left_goal
		local right_goal = self.right_goal

		-- Try left
		local left_goal_plane = left_goal.GoalPlane
		local right_goal_plane = right_goal.GoalPlane
		if (ball.Position.X + ball.Size.X * .5) < left_goal_plane.Position.X and ball.Position.Y < left_goal_plane.Position.Y + left_goal_plane.Size.Y * .5
		and ball.Position.Y > left_goal_plane.Position.Y - left_goal_plane.Size.Y * .5 then
			self:RegisterGoal(CharacterId.Player2)
			break

		-- Try right
		elseif (ball.Position.X - ball.Size.X * .5) > right_goal_plane.Position.X and ball.Position.Y < right_goal_plane.Position.Y + right_goal_plane.Size.Y * .5
		and ball.Position.Y > right_goal_plane.Position.Y - right_goal_plane.Size.Y * .5 then
			self:RegisterGoal(CharacterId.Player1)
			break
		end
	end
end

-- Check powerup against balls
function Match.CheckPowerupAgainstBalls(self, powerup)
	-- Check all balls
	for _, ball in pairs(self.balls) do
		local bnp = (ball.Position - Vector3.new(0, 0, ball.Position.Z)) - powerup.position
		local dist = bnp:Dot(bnp)
		if dist <= math.pow((ball.Size.X + powerup.model.Coin.Size.Y) * .5, 2) then
			-- Collect powerup
			powerup:ShowCollection()
			powerup:Activate(ball)
			self.store:dispatch({
				type = 'SHOW_POWERUP_TEXT',
				text = string.format('%s!', string.upper(powerup.Data.DisplayName)),
			})
			delay(2, function()
				self.store:dispatch({
					type = 'HIDE_POWERUP_TEXT',
				})
			end)
			break
		end
	end
end

-- Update
function Match.Update(self, dt)
	-- Goal line technology
	if self.goal_detection_enabled then
		self:CheckGoals()
	end

	-- Powerup technology
	if self.powerup_detection_enabled then
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

-- Destroy
function Match.Destroy(self)
	-- Gui
	Roact.unmount(self.gui_handle)

	-- Controllers
	self.controller_left:Destroy()
	self.controller_right:Destroy()

	-- Update
	self.heartbeat:disconnect()

	-- Model
	self.bin:Destroy()

	-- Done. Start menu listens to this so that it can present itself again once the match is destroyed
	self.destroyed = true
end

-- return module
return Match
