--[[
    Represents save points in the game.
]]

SavePoint = Class{}

function SavePoint:init(map, x, y)
	
	self.x = x
	self.y = y
	
	self.map = map
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'
	
	self.defaultTexture = love.graphics.newImage('graphics/Adventure Sprites.png')

	self.texture = self.defaultTexture

	self.width = 16
	self.height = 20

	-- determines flip of sprite
	self.direction = 'right'

	-- offset from top left to center to support sprite flipping
	self.xOffset = self.width / 2
	self.yOffset = self.height / 2

	self.animations = {
		['idle'] = Animation({
			texture = self.defaultTexture,
			frames = {
				love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.texture:getDimensions())
			},
			interval = .15
		}),
		['stareForward'] = Animation({
			texture = self.defaultTexture,
			frames = {
				love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions())
			}
		})
	}

	-- initialize animation and current frame we should render
	self.animation = self.animations['idle']
	self.currentFrame = self.animation:getCurrentFrame()

	self.hitboxXOffset = 0
	self.hitboxYOffset = -4
	-- initialize hitbox
	self.hitbox = Hitbox(self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
		self.width - self.hitboxXOffset * 2, self.height - self.hitboxYOffset)

	self.talkNO = 1
	self.swordTalkNO = 1
	self.wasHit = false
	self.wasHitNO = 1
	self.completedShowOff = false
	self.wasDisplayingMessage = false

	self.hitWithCurrentSlash = false

	-- behavior map we can call based on Schnanderson state
	if behaviorsFunction ~= nil then
		local behaviors = behaviorsFunction(self)
		self.behaviors = behaviors[self.name]
	else
		self.behaviors = {
			['idle'] = function(dt)
				self.wasDisplayingMessage = false

				self.state = 'forward'
				self.animation = self.animations['stareForward']
			end
		}
	end

	-- a few standard functions --

	-- 'forward'
	local tempBehav = function(dt)
		self.completedShowOff = true

		-- check for player interaction - just to be thorough ;)
		if self.hitbox:hitboxCollides(self.map.player.hitbox)
			and love.keyboard.isDown(self.map.player.interactButton) then

			self:talk('talk', 1)
			self.map:displayMessage("Hi, myself!", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound)

		end

	end
	self.behaviors['forward'] = tempBehav

	-- end standard functions --

end

function SavePoint:update(dt)
	-- update behaviors and animation
	if not self.isDisplayingMessage then
		self.behaviors[self.state](dt)
	else
		-- check if character shouldn't be talking
		if self.map.mInterval == string.len(self.map.currentMessage) or self.map.mInFreeze then
			self.animation = self.animations['stareForward']
		else
			self.animation = self.animations['talk']
		end
	end
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
	
	-- check for end of dialogue
	if not self.map.isDisplayingMessage and self.isDisplayingMessage then self.isDisplayingMessage = false end
	
	-- update hitbox
	self.hitbox:changeProperties(self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
		self.width + self.hitboxXOffset * 2 / 3, self.height - self.hitboxYOffset)
end

function SavePoint:render()
	-- draw sprite with scale factor and offsets
    love.graphics.draw(self.animation.texture, self.currentFrame, math.floor(self.x),
        math.floor(self.y), 0, 1, 1, 0, 0)
	
	self.hitbox:render()
end
