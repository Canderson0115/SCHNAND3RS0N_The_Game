--[[
    Represents the advancement arrows in the game.
]]

Arrow = Class{}

function Arrow:init(map, x, y)
	
	self.x = x
	self.y = y
	
	self.map = map
	self.texture = love.graphics.newImage('graphics/Advance_Arrow.png')
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'
	
	self.width = 8
	self.height = 8
	
	self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
				love.graphics.newQuad(1 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
				love.graphics.newQuad(1 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
            },
			interval = .15
        })
	}
	
	-- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()
	
	-- behavior map we can call based on churro state
    self.behaviors = {
        ['idle'] = function(dt)
			
		end
	}
	
end
	
function Arrow:update(dt)
	self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function Arrow:render()
	-- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x),
        math.floor(self.y), 0, 1, 1, 0, 0)
end
