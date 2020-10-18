--[[
    Represents the backgrounds in the game.
]]

Background = Class{}

function Background:init(map, x, y, speed, path)
	
	self.x = x
	self.y = y - 2
	
	self.map = map
	self.texture = love.graphics.newImage(path)
	
	if self.x ~= 0 then self.x = self.texture:getWidth() end
	
	self.speed = speed
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'
	
	self.width = self.texture:getWidth()
	self.height = self.texture:getHeight()
	
	if self.height < VIRTUAL_HEIGHT then
		self.scaleY = VIRTUAL_HEIGHT / self.height
		self.scaleX = self.scaleY
	else
		self.scaleX = 1
		self.scaleY = 1
	end

	-- additional backgrounds
	self.addBGs = 0
	
	if self.speed == nil then
		local done = false
		while not done do
			local length = self.width * self.scaleX * (self.addBGs + 1)
			if length < self.map.mapWidthPixels then
				-- not across whole map yet
				self.addBGs = self.addBGs + 1
			elseif length >= self.map.mapWidthPixels then
				self.followFactor = length / self.map.mapWidthPixels
				done = true
			end
		end
		--print("Additional BGs: " .. self.addBGs)
		--print("Follow factor: " .. self.followFactor)
	end
	
	self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0, 0, self.width, self.height, self.texture:getDimensions())
            },
			interval = .15
        })
	}
	
	-- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()
	
	-- behavior map we can call based on state
    self.behaviors = {
        ['idle'] = function(dt)
			if self.speed == nil then 
				self.state = 'followPlayer'
			else
				self.state = 'move'
			end
		end,
		['move'] = function(dt)
			-- let's get moving!
			if self.x + self.width < 0 then
				self.x = self.width + self.speed * 2
			else
				self.x = self.x + self.speed
			end
			
		end,
		['followPlayer'] = function(dt)
			
			if self.x > 0 and self.x + self.width < self.map.mapWidthPixels then
				-- within boundaries of the map; can follow camera x
				self.x = 0 --self.map.camX * self.followFactor
			end
			
		end
	}
	
end

--[[

	self.map.mapWidthPixels
	self.map.camX
	self.width

--]]
	
function Background:update(dt)
	self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function Background:render()
	-- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x),
        math.floor(self.y), 0, self.scaleX, self.scaleY, 0, 0)
	
	for i = 1, self.addBGs do
		--print("For " .. i .. " 2nd x is " .. math.floor(self.x + (self.width * self.scaleX) * i))
		--print("X: " .. self.x)
		love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x + (self.width * self.scaleX) * i - 1 * (i - 1)),
			math.floor(self.y), 0, self.scaleX, self.scaleY, 0, 0)
	end
end
