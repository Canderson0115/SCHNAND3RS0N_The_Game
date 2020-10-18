--[[
    Represents our Saugage(s) in the game, with (its/their) own sprite(s).
]]

Meter = Class{}

function Meter:init(entity)
	self.host = entity
	
	self.x = self.host.x
	self.y = self.host.y
	
	self.width = 32
	self.height = 32
	
	self.scaleX = 0.5
	self.scaleY = 0.5
	
	self.texture = love.graphics.newImage('graphics/Detection_Meter.png')
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'
	
	self.showing = false
	
	self.tileWidth = self.width
	self.tileHeight = self.height
	
	self.animations = {
        ['filling'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(1  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(2  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(3  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(4  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(5  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(6  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(7  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(8  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(9  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(10 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(10 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions())
            },
			interval = 0.25
        }),
		['emptying'] = Animation({
            texture = self.texture,
            frames = {
				love.graphics.newQuad(9  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(8  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(7  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(6  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(5  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(4  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(3  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(2  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(1  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(1  * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions())
            },
			interval = 0.05
        }),
		['!'] = Animation({
            texture = self.texture,
            frames = {
				love.graphics.newQuad(0 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(0 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(0 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(0 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions())
            },
			interval = 1
        })
	}
	
	-- initialize animation and current frame we should render
    self.animation = self.animations['filling']
    self.currentFrame = self.animation:getCurrentFrame()
	
	-- behavior map we can call based on heart state
    self.behaviors = {
		['idle'] = function(dt)
			-- do nothing
			self.showing = false
		end,
        ['filling'] = function(dt)
			self.showing = true
			-- check for end of animation
			if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
				-- discovered!
				self.state = '!'
				self.animations['!']:restart()
				self.animation = self.animations['!']
				
				self.host.state = 'chasing'
				self.host.animations['patrolling']:restart()
				self.host.animation = self.host.animations['patrolling']
			end
		end,
		['emptying'] = function(dt)
			self.showing = true
			-- check for end of animation
			if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
				self.state = 'idle'
				
				self.host.state = 'idle'
			end
		end,
		['!'] = function(dt)
			-- check for end of animation
			if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
				self.state = 'idle'
				self.showing = false
			end
		end
	}
	
end
	
function Meter:update(dt)
	self.x = self.host.x - (self.width / 4) * self.scaleX
	self.y = self.host.y - self.height * self.scaleY
	
	self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function Meter:render()
	-- draw sprite
	if self.showing then
		love.graphics.draw(self.animation.texture, self.currentFrame, math.floor(self.x),
			math.floor(self.y), 0, 0.5, 0.5, 0, 0)
	end
end
