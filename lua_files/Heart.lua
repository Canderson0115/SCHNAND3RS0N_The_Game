--[[
    Represents our HEART(s) in the game, with its own sprite.
]]

Heart = Class{}

function Heart:init(map)
	
	self.startingX = 10
	self.startingY = -50
	
	self.x = startingX
	self.y = self.startingY
	
	self.map = map
	self.texture = love.graphics.newImage('graphics/heart.png')
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'full'
	
	self.tileWidth = 17
	
	self.animations = {
        ['full'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0 * self.tileWidth, 0, 17, 19, self.texture:getDimensions())
            }
        }),
		['half'] = Animation({
			texture = self.texture,
            frames = {
                love.graphics.newQuad(1 * self.tileWidth, 0, 17, 19, self.texture:getDimensions())
            }
		}),
		['empty'] = Animation({
			texture = self.texture,
            frames = {
                love.graphics.newQuad(2 * self.tileWidth, 0, 17, 19, self.texture:getDimensions())
            }
		})
	}
	
	-- initialize animation and current frame we should render
    self.animation = self.animations['full']
    self.currentFrame = self.animation:getCurrentFrame()
	
	-- behavior map we can call based on heart state
    self.behaviors = {
        ['full'] = function(dt, heart)
			self.x = 17 * (heart + 1) + self.map.camX
			self.y = 10 + self.map.camY
		end,
		['half'] = function(dt, heart)
			self.x = 17 * (heart + 1) + self.map.camX
			self.y = 10 + self.map.camY
		end,
		['empty'] = function(dt, heart)
			self.x = 17 * (heart + 1) + self.map.camX
			self.y = 10 + self.map.camY
		end
	}
	
end
	
function Heart:update(dt, heart)
	self.behaviors[self.state](dt, heart)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function Heart:render()
	-- draw sprite
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x),
        math.floor(self.y), 0, 1, 1, 0, 0)
end
