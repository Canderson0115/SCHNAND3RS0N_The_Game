
local tileString = [[
  //////     {}        (---
  /     !               [==
  /                     [==
  /    s       {}       [==
  /    p_P              <==
  /                      [=
  /             s        [=
  /   {}       p_P       [=
  /                      [=
  /                      <=
  /       p_P             <
     t                     
     @     s bBJ        bB 
  (------------------------
  [========================
]]

local text = {
	{{"Hey, you're not supposed to be here!", 0, 0.0166, redcolor, smallFont, false, false, true, mTalkSound}}
}

local spawnText = {"Walk backwards for controls rundown.", 0, 0.0166, blackcolor, smallFont, false, false, true, mTalkSound}

local entityText = {
	['Joel'] = {
		['talk1'] = {"Hey, Subscriber. Watch this!", 0, 0.0166, blackcolor, smallFont, true, true, false, joelTalkSound},
		['wasHitTalk1'] = {"Hey, you bad man who attacked me with your sword. Watch this!", 0, 0.0166, blackcolor, smallFont, true, true, false, joelTalkSound},
		['sword1'] = {"Ouch! WHY DID YOU HIT ME WITH YOUR SWORD???>p\nOh, well. at least I can still do this!", 0, 0.03, {1, 0, 0, 1}, smallFont, true, true, false, joelTalkSound},
		['sword2'] = {"WHY DID YOU HIT ME WITH YOUR SWORD AGAIN?!?!?!?!>p\nAt least I'm still the best at standing front flips and have great hair.", 0, 0.0275, redcolor, smallFont, true, true, false, joelTalkSound},
		['sword3'] = {"STOP THAT, YOU FOOL!", 0, 0.03, redcolor, smallFont, true, true, false, joelTalkSound}
	}
}

local entityBehaviorsFunction = function(Schnanderson)
	local behaviors = {
		['Joel'] = {
			['idle'] = function(dt)
				print("hmm")
				if Schnanderson.wasDisplayingMessage then
					Schnanderson.wasDisplayingMessage = false
					print("oof")
					Schnanderson.state = 'showingOff'
				else
					Schnanderson.state = 'talkReady'
				end
			end
		}
	}
	
	return behaviors
end

local tileWidth = 16

local quadInfo = { 
	{ ' ',  0 * tileWidth,  0 * tileWidth, false }, -- air
	{ 's',  0 * tileWidth,  0 * tileWidth, false }, -- enemy; place air
	{ 't',  0 * tileWidth,  0 * tileWidth, false }, -- text; place air
	{ 'J',  0 * tileWidth,  0 * tileWidth, false }, -- Joel; place air
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

newMap(16,16,'/graphics/tileset.png', tileString, quadInfo, text, entityText, entityBehaviorsFunction) --, spawnText
