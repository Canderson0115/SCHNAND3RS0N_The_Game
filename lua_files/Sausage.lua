--[[
    Represents our Saugage(s) in the game, with (its/their) own sprite(s).
]]

Sausage = Class{}

function Sausage:init(map, x, y)
	
	self.x = x
	self.y = y
	
	self.xOffset = 4
	self.yOffset = 2
	
	self.width = 8
	self.height = 18
	
	self.dead = false
	
	self.map = map
	self.texture = love.graphics.newImage('graphics/sausage.png')
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'
	
	self.tileWidth = 16
	self.tileHeight = 20
	
	self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(1 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(2 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(3 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(4 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(5 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(6 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions())
            },
			interval = 0.1
        }),
		['dying'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(1 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(2 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(2 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions()),
				love.graphics.newQuad(2 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.texture:getDimensions())
            },
			interval = 0.4
        })
	}
	
	-- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()
	
	self.hitbox = Hitbox(self.x + self.xOffset, self.y + self.yOffset, self.width, self.height)
	
	-- behavior map we can call based on heart state
    self.behaviors = {
        ['idle'] = function(dt)
			self.hitbox:changeProperties(self.x + self.xOffset, self.y + self.yOffset, self.width, self.height)
			
			-- checks if self hits player
			if self.hitbox:hitboxCollides(self.map.player.hitbox) then
				-- hit player, cause player minor damage
				self.map.player:hurt(1)
				self.map.player:knockback(self.x, self.width)
				
				--[[ if we want the sausages to talk
				local color = {1, 0, 0, 1}
				self.map:displayMessage("Take that, Subscriber!", 0, 0.0166, color, smallFont, true, true)
				--]]
			end
			
			-- check for player's sword attack
			if self.hitbox:hitboxCollides(self.map.player.swordHitbox) then
				-- been hit by sword, take damage
				-- in this case, only one hit makes self die
				self.state = 'dying'
				self.animations['dying']:restart()
				self.animation = self.animations['dying']
				
				--[[
				local color = {1, 0, 0, 1}
				self.map:displayMessage("Ouch, I'm dying!!", 0, 0.2, color, smallFont, false, false)
				--]]
			end
		end,
		['dying'] = function(dt)
			-- die
			if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
				self.dead = true
				
				-- set this tile to air so that self does not instantly respawn
				self.map:setTile(self.x / self.map.tileWidth + 1,
						math.floor((self.y + 4) / self.map.tileHeight + 1), ' ')
				--print("Removed at " .. self.x / self.map.tileWidth + 1 .. ", " .. math.floor((self.y + 4) / self.map.tileHeight + 1))
			end
		end
	}
	
end
	
function Sausage:update(dt)
	self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function Sausage:render()
	-- draw sprite
    love.graphics.draw(self.texture, self.currentFrame, math.floor(self.x),
        math.floor(self.y), 0, 1, 1, 0, 0)
	
	--self.hitbox:render()
end
