--[[
    Represents our CHURROS in the game, with its own sprite.
]]

Churro = Class{}

function Churro:init(map)
	
	self.x = 0
	self.y = -50
	
	self.startingY = -50
	
	self.map = map
	self.texture = love.graphics.newImage('graphics/Advenchurro.png')
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'
	
	self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, 16, 20, self.texture:getDimensions())
            }
        })
	}
	
	-- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()
	
	-- behavior map we can call based on churro state
    self.behaviors = {
        ['idle'] = function(dt)
			self.x = 0
			self.y = -50
		end,
		['get'] = function(dt)
			if self.y > self.startingY - 50 then
				self.y = self.y - 50 * dt
			else
				self.state = 'idle'
			end
		end
	}
	
end

function Churro:get(startingX, startingY)
	self.x = (startingX - 1) * self.map.tileWidth
	self.y = (startingY - 1) * self.map.tileHeight
	self.startingY = startingY * self.map.tileHeight
	self.state = 'get'
end
	
function Churro:update(dt)
	self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function Churro:render()
	-- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x),
        math.floor(self.y), 0, 1, 1, 0, 0)
end
