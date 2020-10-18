--[[
    Represents the advancement arrows in the game.
]]

Van = Class{}

function Van:init(map, x, y, stage)
	
	self.x = x
	self.y = y
	
	self.map = map
	self.defualtTexture = love.graphics.newImage('graphics/SchnanderVan.png')
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'
	
	if stage == 'not start' then
		
	else
		-- start

		self.width = 112
		self.height = 48

		self.animations = {
			['idle'] = Animation({
					texture = self.defualtTexture,
					frames = {
						love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.defualtTexture:getDimensions()),
						love.graphics.newQuad(1 * self.width, 0, self.width, self.height, self.defualtTexture:getDimensions()),
						love.graphics.newQuad(2 * self.width, 0, self.width, self.height, self.defualtTexture:getDimensions()),
						love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.defualtTexture:getDimensions()),
						love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.defualtTexture:getDimensions())
					},
					interval = .02
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
	
end
	
function Van:update(dt)
	self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function Van:render()
	-- draw sprite with scale factor and offsets
    love.graphics.draw(self.animation.texture, self.currentFrame, math.floor(self.x),
        math.floor(self.y), 0, 1, 1, 0, 0)
end
