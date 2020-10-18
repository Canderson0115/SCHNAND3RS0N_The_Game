--[[----------

	1-1-1

--]]----------


local tileString = [[
/                                                           cC          
/                                  cC                                   
/                                                                       
/      cC                                                               
/   @                                                          cC       
/                    cC                               cC                
/                                cC                                     
S/         cC                                                           
W                                                                   cC  
/                                                  l  ll                
/                                                L/lllL/l               
/            t             t    t            t   //L/l//L/              
T       bB   1   bB               f bB           ll//lll// l            
------------------------------------------------------------------------
========================================================================
========================================================================
==== ===================================================================
========================================================================
]]

local text = {
	{{"That's right! Keep running with " .. map.player.rightButton .. " and " .. map.player.leftButton .. ".", 0, 0.01, blackcolor, smallFont, true, true, false, treyTalkSound, 'default'}},
	{{"I guess those viennas lost y-- >sWhat in the name of Sam Hill is that?!", 0, 0.01, blackcolor, smallFont, true, true, false, treyTalkSound, 'default'}},
	{{"Quick, jump the fence with " .. map.player.jumpButton .. "!", 0, 0.01, blackcolor, smallFont, true, true, false, treyTalkSound, 'default'}},
	{{"I wish Joel and Colton wouldn't leave their boxes lying around like this. Well, you should be able to get over by grabbing the ledge and jumping up!", 0, 0.01, blackcolor, smallFont, true, true, false, treyTalkSound, 'default'}}
}

local spawnText = {"Text displayed when map loads", 0, 0.0166, blackcolor, smallFont, false, false, true, mTalkSound}

local entityText = {
	['Joel'] = {
		['talk1'] = {"It's-a me, Joel!", 0, 0.0166, blackcolor, smallFont, true, true, false, joelTalkSound},
		['wasHitTalk1'] = {"I feel hurt.", 0, 0.0166, blackcolor, smallFont, true, true, false, joelTalkSound},
		['sword1'] = {"Owchie!", 0, 0.1, redcolor, smallFont, true, true, false, joelTalkSound}
	},
	['Colton'] = {
		['talk1'] = {"It's-a me, Colton!", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound},
		['wasHitTalk1'] = {"Did you ever hear the Tragedy of Darth Plagueis the wise? I thought not. It's not a story the Jedi would tell you. It's a Sith legend. Darth Plagueis was a Dark Lord of the Sith, so powerful and so wise he could use the Force to influence the midichlorians to create life... He had such a knowledge of the dark side that he could even keep the ones he cared about from dying. The dark side of the Force is a pathway to many abilities some consider to be unnatural. He became so powerful... the only thing he was afraid of was losing his power, which eventually, of course, he did. Unfortunately, he taught his apprentice everything he knew, then his apprentice killed him in his sleep. It's ironic - he could save others from death, but not himself.", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound},
		['sword1'] = {"Oof.", 0, 0.2, redcolor, smallFont, true, true, false, mTalkSound}
	},
	['Trey'] = {
		['talk1'] = {"Come on! Those viennas will be after us soon!", 0, 0.0166, blackcolor, smallFont, true, true, false, treyTalkSound}, --"Come on, " .. map.player.name .. "! The viennas are chasing us!"
		['sword1'] = {"Ow.", 0, 0.0166, blackcolor, smallFont, true, true, false, treyTalkSound}
	}
}

--[ [ optional: redefine idle and other functions
local entityBehaviorsFunction = function(schnandy)
	local behaviors = {
		['Joel'] = {
			['idle'] = function(dt)
				if not schnandy.completedCutscene then
					schnandy.state = 'cutscene'
				else
					--print("ready")
					schnandy.state = 'talkReady'
				end
			end,
			['cutscene'] = function(dt)
				if schnandy.x < 1500 then
					schnandy.direction = 'right'
					--print("X: " .. schnandy.x)
					schnandy.state = 'walking'
				else
					schnandy.completedCutscene = true
					schnandy.state = 'idle'
				end
			end
		},
		['Sub'] = {
			['idle'] = function(dt)
				if not schnandy.map.completedCutscene then
					schnandy.y = schnandy.y + 16

					-- set up player!!!
					schnandy.map.freezePlayer = true

					schnandy.direction = 'left'
					schnandy.state = 'cutscene'
					schnandy.animations['throughWindow']:restart()
					schnandy.animation = schnandy.animations['throughWindow']
				else
					table.remove(entities, find_value(entities, schnandy))
				end
			end,
			['cutscene'] = function(dt)
				if schnandy.x < 60 then
					schnandy.dx = 50
					schnandy.map.camX = 0
				else
					schnandy.x = 60
					schnandy.dx = 0
					schnandy.state = 'onGround'
					schnandy.animation = schnandy.animations['sitDown']
					
					schnandy.map.cutsceneNO = schnandy.map.cutsceneNO + 1
				end
				if schnandy.y < 190 then
					schnandy.dy = 100
				else
					schnandy.y = 190
					schnandy.dy = 0
				end
				
				-- check for end of animation
				if schnandy.animation:getCurrentFrameNumber() == table.getn(schnandy.animation.frames) - 1 then
					schnandy.animation = schnandy.animations['fallDown']
				end
			end,
			['onGround'] = function(dt)
				if schnandy.map.completedCutscene then
					-- we're done here
					schnandy.state = 'handoff'
				end
			end
		},
		['Trey'] = {
			['idle'] = function(dt)
				if schnandy.map.cutsceneNO <= 1 then
					-- set up for live cutscene
					schnandy.x = 0 - schnandy.width * 2

					if schnandy.map.cutsceneNO == 1 then
						schnandy.direction = 'right'
						schnandy.state = 'part1'
						schnandy.animations['walking']:restart()
						schnandy.animation = schnandy.animations['walking']
					end
				else
					schnandy.state = 'inAir'
				end
			end,
			['part1'] = function(dt)
				if schnandy.x < 48 then
					schnandy.dx = 80
				else
					schnandy.dx = 0
					schnandy.x = 48
					-- talk a bit
					schnandy:talk('talk', 1)
					schnandy.talkNO = 3
					
					schnandy.map.cutsceneNO = schnandy.map.cutsceneNO + 1
					
					schnandy.state = 'part2'
				end
				
			end,
			['part2'] = function(dt)
				
				if schnandy.animation ~= schnandy.animations['walking'] then
					schnandy.animations['walking']:restart()
					schnandy.animation = schnandy.animations['walking']
				end
				
				if schnandy.x < 432 then
					schnandy.dx = 200
				else
					schnandy.dx = 0
					schnandy.animation = schnandy.animations['flying']
					if schnandy.y > -100 then
						schnandy.dy = -500
					else
						schnandy.map.cutsceneNO = schnandy.map.cutsceneNO + 1
						
						-- All done
						schnandy.map.completedCutscene = true
						schnandy.map.freezePlayer = false
					
						schnandy.state = 'inAir'
					end
				end
				
			end
		}
	}
	
	return behaviors
end
--]]

local background = 'graphics/1-1-1.png'

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
	{ '%', 10 * tileWidth, 10 * tileWidth, true  }, -- save point
	{ 'f', 28 * tileWidth,  0 * tileWidth, true  }  -- Fence
}

newMap(16,16,'/graphics/tileset.png', tileString, quadInfo, text, entityText, entityBehaviorsFunction, scrollSpeed, background, 0)
