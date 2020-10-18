--[[------------

	World 0
	Level 1
	Screen 1

--]]------------


local tileString = [[
/                         /
                           
                           
                           
                           
                           
                           
                           
                           
                           
          V                
            SJ             
                           
///////////////////////////
///////////////////////////
///////////////////////////
///////////@///////////////
///////////////////////////
]]

local text = {
	{{"This text is displayed with a 't' on the map.", 0, 0.0166, blackcolor, smallFont, false, false, true, mTalkSound}}
}

local spawnText = {"Text displayed when map loads", 0, 0.0166, blackcolor, smallFont, false, false, true, mTalkSound}

local entityText = {
	['Joel'] = {
		['talk1'] = {"Pretty noice car we've got here, eh? ;)", 0, 0.0166, blackcolor, smallFont, true, true, false, joelTalkSound},
		['wasHitTalk1'] = {"I'm so wounded.", 0, 0.0166, blackcolor, smallFont, true, true, false, joelTalkSound},
		['sword1'] = {"ow", 0, 0.0166, redcolor, smallFont, true, true, false, joelTalkSound}
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

local background = 'graphics/selectWorld.png'

local scrollSpeed = nil

local tileWidth = 16

local quadInfo = { 
	{ ' ',  0 * tileWidth,  0 * tileWidth, false }, -- air
	{ 's',  0 * tileWidth,  0 * tileWidth, false }, -- enemy; place air
	{ 't',  0 * tileWidth,  0 * tileWidth, false }, -- text; place air
	{ 'J',  0 * tileWidth,  0 * tileWidth, false }, -- Joel; place air
	{ 'V',  0 * tileWidth,  0 * tileWidth, false }, -- Van; place air
	{ 'S',  0 * tileWidth,  0 * tileWidth, false }, -- Subscriber entity; place air
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
	{ '{', 22 * tileWidth,  8 * tileWidth, false }, -- cloud left
	{ '}', 23 * tileWidth,  8 * tileWidth, false }, -- cloud left
	{ '1', 21 * tileWidth,  9 * tileWidth, true  }, -- dead ! block
	{ 'p', 15 * tileWidth, 14 * tileWidth, true  }, -- platform left
	{ '_', 17 * tileWidth, 14 * tileWidth, true  }, -- platform middle
	{ 'P', 19 * tileWidth, 14 * tileWidth, true  }  -- platform right
}

newMap(16,16,'/graphics/tileset.png', tileString, quadInfo, text, entityText, entityBehaviorsFunction, scrollSpeed, background, -3) --, spawnText
