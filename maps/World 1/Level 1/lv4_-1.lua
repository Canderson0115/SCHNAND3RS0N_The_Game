--[[----------

	1-1-4_-1

--]]----------

local tileString = [[
=================================]  [====                                /
=================================]  <~~~~                                 
=================================]                                        
=================================]                                        
=================================]                                        
=================================]                                        
=================================]                                        
=================================]                         (--)           
=================================] @  T      (-)           [==]           
==================================------)    [=]           [==]           
========================================]    [=]   (--)    [==]     (-----
========================================]    [=]   [==]    [==]     [=====
========================================]    [=]   [==]    [==]     [=====
========================================]    [=]   [==]    [==]     [=====
========================================]    [=]   [==]    [==]     [=====
]]

local text = {
	{{"Heyo! It's me, Trey!", 0, 0.0166, blackcolor, smallFont, false, false, true, mTalkSound, 'default'}}
}

local spawnText = {"Text displayed when map loads", 0, 0.0166, blackcolor, smallFont, false, false, true, mTalkSound}

local entityText = {
	['Trey'] = {
		['talk1'] = {"Whew, I think we lost them!>p Be careful, though - there are some sausages in these caves looking for us.", 0, 0.0166, blackcolor, smallFont, true, true, false, treyTalkSound},
		['wasHitTalk1'] = {"Go ahead and get caught by the sausages, see if I care.", 0, 0.0166, {0.7, 0, 1, 1}, smallFont, true, true, false, treyTalkSound},
		['sword1'] = {"Why? :(", 0, 0.0166, redcolor, smallFont, true, true, false, treyTalkSound}
	}
}

--[[ optional: redefine idle
local entityBehaviorsFunction = function(Schnanderson)
	local behaviors = {
		['Joel'] = {
			['idle'] = function(dt)
				print("Performs whatever functions are desired for current screen")
			end
			
		}
	}
	
	return behaviors
end
--]]

local background = 'graphics/caveBg2.png'

--local scrollSpeed = 50

local tileWidth = 16

local quadInfo = { 
	{ ' ', 20 * tileWidth,  0 * tileWidth, false }, -- air
	{ 's', 20 * tileWidth,  0 * tileWidth, false }, -- enemy; place air
	{ 'A', 20 * tileWidth,  0 * tileWidth, false }, -- angry sausage; place air
	{ '1',  0 * tileWidth,  0 * tileWidth, false }, -- Sausage Boss; place air
	{ 't', 20 * tileWidth,  0 * tileWidth, false }, -- text; place air
	{ 'J', 20 * tileWidth,  0 * tileWidth, false }, -- Joel; place air
	{ 'O', 20 * tileWidth,  0 * tileWidth, false }, -- Colton; place air
	{ 'S', 20 * tileWidth,  0 * tileWidth, false }, -- Sub; place air
	{ 'T', 20 * tileWidth,  0 * tileWidth, false }, -- Trey; place air
	{ 'W', 20 * tileWidth,  0 * tileWidth, true  }, -- Window; place invisible block
	{ 'L',  0 * tileWidth,  0 * tileWidth, true  }, -- Large box; place invisible block
	{ 'l',  0 * tileWidth,  0 * tileWidth, true  }, -- Small box; place invisible block
	{ '@', 20 * tileWidth,  0 * tileWidth, false }, -- Player spawn point
	{ '/', 20 * tileWidth,  0 * tileWidth, true  }, -- invisible block
	{ '(', 25 * tileWidth,  1 * tileWidth, true  }, -- ground left
	{ '-', 26 * tileWidth,  1 * tileWidth, true  }, -- ground middle
	{ ')', 27 * tileWidth,  1 * tileWidth, true  }, -- ground right
	{ '[', 25 * tileWidth,  2 * tileWidth, true  }, -- dirt wall left
	{ '=', 26 * tileWidth,  2 * tileWidth, true  }, -- dirt wall middle
	{ ']', 27 * tileWidth,  2 * tileWidth, true  }, -- dirt wall right
	{ '<', 25 * tileWidth,  3 * tileWidth, true  }, -- dirt wall bottom left
	{ '~', 26 * tileWidth,  3 * tileWidth, true  }, -- dirt wall bottom middle
	{ '>', 27 * tileWidth,  3 * tileWidth, true  }, -- dirt wall bottom right
	{ 'b', 22 * tileWidth,  7 * tileWidth, false }, -- bush left
	{ 'B', 23 * tileWidth,  7 * tileWidth, false }, -- bush right
	{ '!', 21 * tileWidth,  8 * tileWidth, true  }, -- ! block
	{ 'c', 22 * tileWidth,  8 * tileWidth, false }, -- cloud left
	{ 'C', 23 * tileWidth,  8 * tileWidth, false }, -- cloud right
	--{ '1', 21 * tileWidth,  9 * tileWidth, true  }, -- dead ! block
	{ 'p', 15 * tileWidth, 14 * tileWidth, true  }, -- platform left
	{ '_', 17 * tileWidth, 14 * tileWidth, true  }, -- platform middle
	{ 'P', 19 * tileWidth, 14 * tileWidth, true  }, -- platform right
	{ '%', 10 * tileWidth, 10 * tileWidth, true  }  -- save point
}

newMap(16,16,'/graphics/caveTileset.png', tileString, quadInfo, text, entityText, entityBehaviorsFunction, scrollSpeed, background) --, speed
