--
--	Jackson Munsell
--	07/07/18
--	ServerBoot.lua
--
--	Main server script
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- services
serve 'Players'

-- Flags
local SPAWN_PARTS = false

-- Consts
local PURPLE_PART_COUNT = 15

-- Spawn function
local function spawn_part()
	local part = clone('/res/models/PurplePart', workspace.PurpleParts, {
		CFrame = CFrame.new(math.random(-40, 40), 5, math.random(-40, 40)),
	})
	part.Touched:connect(function(hit)
		if hit.Parent then
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				player.Score.Value = player.Score.Value + 1
				part:Destroy()
				spawn_part()
			end
		end
	end)
end

-- Spawn purple parts
if SPAWN_PARTS then
	for i = 1, PURPLE_PART_COUNT do
		spawn_part()
	end
end

-- Player setup
Players.PlayerAdded:connect(function(player)
	new('IntValue', player, {
		Name = 'Score',
		Value = 0,
	})
end)
