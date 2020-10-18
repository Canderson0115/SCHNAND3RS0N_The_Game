
local tileString = [[
#                   !     #
#        !                #
#                         #
#  {}              ###    #
#      #####              #
#                 {}      #
#                         #
#           ##            #
#                         #
#                         #
#       ###               #
                           
    @()          ()        
######################  ###
######################  ###
]]

local tileWidth = 16

local quadInfo = { 
	{ '@',  3 * tileWidth,  0 * tileWidth, false }, -- Player spawn point
	{ '#',  0,  0, true  }, -- bricks 
	{ '(', 16,  0, false }, -- bush left
	{ ')', 32,  0, false }, -- bush right
	{ ' ', 48,  0, false }, -- air
	{ '!',  0, 16, true  }, -- yellow block
	{ '{', 16, 16, false }, -- cloud left
	{ '}', 32, 16, false }, -- cloud right
	{ '*', 48, 16, false }, -- flagpole top
	{ '1',  0, 32, true  }, -- brown block
	{ '^', 16, 32, true  }, -- mushroom top
	{ '|', 32, 32, true  }, -- mushroom bottom
	{ ':', 48, 32, false }, -- flagpole middle
	{ 'I',  0, 48, false }, -- flag frame 1
	{ 'O', 16, 48, false }, -- flag frame 2
	{ 'P', 32, 48, false }, -- flag frame 3
	{ ';', 48, 48, true  }  -- flagpole bottom
}

newMap(16,16,'/graphics/spritesheet.png', tileString, quadInfo)
