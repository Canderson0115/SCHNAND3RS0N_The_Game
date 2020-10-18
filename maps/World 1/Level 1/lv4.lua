--[[----------

	1-1-4

--]]----------

local tileString = [[
                                        (
                                        [
                                        [
                                        [
                                        [
                                        [
                                        [
                   L/                   [
                   //l                  [
                   lL/                  [
              lll  l//                 (=
              lL/  L/ll        t       [=
   @ 1        l// l//ll                [=
---------------------------------)  (--==
=================================]  [====
]]

local text = {
	{{"Quick, jump into this hole!", 0, 0.0166, blackcolor, smallFont, false, false, true, mTalkSound, 'surprised'}}
}

local spawnText = {"Text displayed when map loads", 0, 0.0166, blackcolor, smallFont, false, false, true, mTalkSound}

local entityText = {
	['Joel'] = {
		['talk1'] = {"As an entity, I say this message when you, the player, talk to me.", 0, 0.0166, blackcolor, smallFont, true, true, false, joelTalkSound},
		['wasHitTalk1'] = {"After the player hits me with the sword, I say this when spoken to.", 0, 0.0166, blackcolor, smallFont, true, true, false, joelTalkSound},
		['sword1'] = {"As an entity, this is what I say when you, the player, hit me with your sword.", 0, 0.0166, redcolor, smallFont, true, true, false, joelTalkSound}
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

--local background = 'graphics/1-1-1.png'

local scrollSpeed = 50

local tileWidth = 16

local quadInfo = { 
	{ ' ',  0 * tileWidth,  0 * tileWidth, false }, -- air
	{ 's',  0 * tileWidth,  0 * tileWidth, false }, -- enemy; place air
	{ 'A',  0 * tileWidth,  0 * tileWidth, false }, -- angry sausage; place air
	{ '1',  0 * tileWidth,  0 * tileWidth, false }, -- Sausage Boss; place air
	{ 't',  0 * tileWidth,  0 * tileWidth, false }, -- text; place air
	{ 'J',  0 * tileWidth,  0 * tileWidth, false }, -- Joel; place air
	{ 'O',  0 * tileWidth,  0 * tileWidth, false }, -- Colton; place air
	{ 'S',  0 * tileWidth,  0 * tileWidth, false }, -- Sub; place air
	{ 'T',  0 * tileWidth,  0 * tileWidth, false }, -- Trey; place air
	{ ':',  0 * tileWidth,  0 * tileWidth, false }, -- Warp exit point; place air
	{ 'W',  0 * tileWidth,  0 * tileWidth, true  }, -- Window; place invisible block
	{ 'L',  0 * tileWidth,  0 * tileWidth, true  }, -- Large box; place invisible block
	{ 'l',  0 * tileWidth,  0 * tileWidth, true  }, -- Small box; place invisible block
	{ '@',  0 * tileWidth,  0 * tileWidth, false }, -- Player spawn point
	{ '/',  0 * tileWidth,  0 * tileWidth, true  }, -- invisible block
	{ '(',  1 * tileWidth,  1 * tileWidth, true  }, -- grass left
	{ '-',  3 * tileWidth,  1 * tileWidth, true  }, -- grass middle
	{ ')',  5 * tileWidth,  1 * tileWidth, true  }, -- grass right
	{ '[',  1 * tileWidth,  3 * tileWidth, true  }, -- dirt wall left
	{ '=',  3 * tileWidth,  3 * tileWidth, true  }, -- dirt wall middle
	{ ']',  5 * tileWidth,  3 * tileWidth, true  }, -- dirt wall right
	{ '<',  1 * tileWidth,  5 * tileWidth, true  }, -- dirt wall bottom left
	{ '~',  3 * tileWidth,  5 * tileWidth, true  }, -- dirt wall bottom middle
	{ '>',  5 * tileWidth,  5 * tileWidth, true  }, -- dirt wall bottom right
	{ '#', 21 * tileWidth,  7 * tileWidth, true  }, -- bricks
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

newMap(16,16,'/graphics/tileset.png', tileString, quadInfo, text, entityText, entityBehaviorsFunction, scrollSpeed) --, background, speed
