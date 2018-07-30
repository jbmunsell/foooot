# foooot
Foooot is a small Roblox football game, still in development. I really wanted to create a fun little game and open the source to the community to see what people think! It's inspired by [Sports Heads: Football Championship](http://www.mousebreaker.com/game/sport-heads-football-championship), which is a flash game that I used to play with my friends at school instead of doing schoolwork.

# Game information
This little game is entirely client-sided. I'll work on adding online support later. For now, it's just intended for local multiplayer (two players on the same computer using the same keyboard).

# Code information
## Boot module
You'll notice that every script (excluding libraries) requires the `boot` module at the very top of the script. The boot module does an interesting trick by manipulating the function environment that calls it. The quick explanation of this is that when a script requires the boot module and calls the function that it returns, the boot module puts a few functions inside that module, like `include` and `serve`.

This is just a nifty trick to eliminate redundancies. Instead of writing out this:
```lua
local PregameMenu = require(game:GetService('ReplicatedStorage').src.gui.PregameMenu)
```
the `include` function allows you to write this (which evaluates to exactly the same thing as above):
```lua
	include '/shared/src/gui/PregameMenu'
```
This works by requiring PregameMenu, and then setting that required module to a variable inside the calling script that has the same name as the module script. The `serve` function is very similar, and helps eliminate redundancies when getting services. Instead of
```lua
	local UserInputService = game:GetService('UserInputService')
```
the `serve` function lets you do this:
```lua
	serve 'UserInputService'
```
which is essentially the exact same thing as the longer way demonstrated above.

If you'd like a deeper explanation of how this works, [send me a tweet](http://twitter.com/biostreem). If enough people ask, I'll add some more technical details on this page.

Jacksopn is jacmosn
