
local tileString = [[
)                              (
]                              [
]                              [
]     {}                       [
]                              [
]           (-)                [
]           [!]  {}            [
]          p~~~P               [
]                              [
]                              [
>       p_P                    <
                                
    @bB        bB     bB        
------------------------)      (
========================]      [
]]

local tileWidth = 16

local quadInfo = { 
	{ ' ',  0 * tileWidth,  0 * tileWidth, false }, -- air
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
	{ '1', 21 * tileWidth,  9 * tileWidth, true  },  -- dead ! block
	{ 'p', 15 * tileWidth, 14 * tileWidth, true  }, -- platform left
	{ '_', 17 * tileWidth, 14 * tileWidth, true  }, -- platform middle
	{ 'P', 19 * tileWidth, 14 * tileWidth, true  }  -- platform right
}

newMap(16,16,'/graphics/tileset.png', tileString, quadInfo)
