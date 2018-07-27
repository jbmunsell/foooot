--
--	Jackson Munsell
--	07/08/18
--	GLib.lua
--
--	Graphics library
--

-- boot
require(game:GetService('ReplicatedStorage').src.boot)()

-- services
serve 'Players'

-- includes
include '/lib/Roact'

include '/res/Palette'

-- Module
local GLib = {}

-- Consts
GLib.GOLDEN_RATIO = 1.61803398875

-- Reconcile color
function GLib.GetPaletteColor(color)
	return Palette[color]
end

-- return library
return GLib
