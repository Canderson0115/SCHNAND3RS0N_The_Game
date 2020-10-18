--[[
    Represents special Schnand3rs0n members in the game
	as well as some other entities.
]]

Schnanderson = Class{}

local WALKING_SPEED = 140 * 1.5
local JUMP_VELOCITY = 200
local DX_REDUCER = 550

function Schnanderson:init(map, x, y, name, text, behaviorsFunction, scale)
	
	self.x = x
	self.y = y
	
	-- x and y velocity
    self.dx = 0
    self.dy = 0
	
	self.scaleX = 1
	self.scaleY = 1
	
	self.name = name
	
	self.map = map
	
	self.text = text
	
	self.dead = false
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'
	
	self.explosionTexture = love.graphics.newImage('graphics/explosion.png')
	
	if name == 'Sub' then
		
		self.defaultTexture = love.graphics.newImage('graphics/Adventure Sprites.png')
		self.windowTexture = love.graphics.newImage('graphics/subThroughWindow.png')
		self.danceTexture = love.graphics.newImage('graphics/SubDance.png')
		
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
			}),
			['throughWindow'] = Animation({
				texture = self.windowTexture,
				frames = {
					love.graphics.newQuad(0  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(1  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(2  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(3  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(4  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(5  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(6  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(7  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(8  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(9  * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(10 * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(11 * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(12 * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(13 * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(14 * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions()),
					love.graphics.newQuad(15 * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions())
				},
				interval = .1
			}),
			['fallDown'] = Animation({
				texture = self.windowTexture,
				frames = {
					love.graphics.newQuad(15 * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions())
				}
			}),
			['sitDown'] = Animation({
				texture = self.windowTexture,
				frames = {
					love.graphics.newQuad(16 * (self.width + 2), 0, self.width, self.height, self.windowTexture:getDimensions())
				}
			}),
			['dance'] = Animation({
				texture = self.danceTexture,
				frames = {
					love.graphics.newQuad(1  * self.width, 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(2  * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(3  * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(4  * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(5  * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(6  * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(7  * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(8  * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(9  * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(10 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(11 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(12 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(13 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(14 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(15 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(16 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(17 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(18 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(19 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(20 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(21 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(22 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(23 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(24 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(25 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(26 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(27 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(28 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(29 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(30 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(31 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(32 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(33 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(34 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(35 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(36 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(37 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(38 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(39 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(40 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(41 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(42 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(43 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(44 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(45 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(46 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(47 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(48 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(49 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(50 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(51 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(52 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(53 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(54 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(55 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(56 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(57 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(58 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(59 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(60 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(61 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(62 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(63 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(64 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(65 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(66 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(67 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(68 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions()),
					love.graphics.newQuad(69 * (self.width), 0, self.width, self.height, self.danceTexture:getDimensions())
				},
				interval = 0.1
			})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitboxXOffset = 6
		self.hitboxYOffset = 1
		-- initialize hitbox
		self.hitbox = Hitbox(self.map, self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
			self.width - self.hitboxXOffset * 2, self.height - self.hitboxYOffset)
		
		self.talkNO = 1
		self.swordTalkNO = 1
		self.wasHit = false
		self.wasHitNO = 1
		self.completedShowOff = false
		self.wasDisplayingMessage = false
		
		self.hitWithCurrentSlash = false
		
		self.doneDancing = false
		
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
			
			-- check for player interaction - just to be thorough ;)
			if self.hitbox:hitboxCollides(self.map.player.hitbox)
				and love.keyboard.isDown(self.map.player.interactButton) then

				self:talk('talk', 1)
				self.map:displayMessage("Hi, myself!", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound)
				
			end
			
		end
		self.behaviors['forward'] = tempBehav
		
		-- 'handoff'
		local tempBehav = function(dt)
			
			self.map.player.x = self.x
			self.map.player.y = self.y
			self.map.player.direction = self.direction
			
			--print("removing self...")
			table.remove(entities, find_value(entities, self))
			
		end
		self.behaviors['handoff'] = tempBehav
		
		-- 'dance'
		local tempBehav = function(dt)
			
			self:changeAnimation('dance')
			
			if self:endOfAnimation() then
				self.doneDancing = true
				self.state = 'handoff'
			end
			
		end
		self.behaviors['dance'] = tempBehav
		
		-- end standard functions --
		
	elseif name == 'window' then
		
		self.defaultTexture = love.graphics.newImage('graphics/windowShatter.png')
		
		self.texture = self.defaultTexture
		
		self.width = 32
		self.height = 32
		
		self.scaleX = 0.5
		self.scaleY = 1
		
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
				}
			}),
			['shatter'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(0  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(1  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(2  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(3  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(4  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(5  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(6  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(7  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(8  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(9  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(10 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(11 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
				},
				interval = 0.1
			}),
			['shattered'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(11 * self.width, 0, self.width, self.height, self.texture:getDimensions())
				}
			})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitboxXOffset = 0
		self.hitboxYOffset = 0
		-- initialize hitbox
		self.hitbox = Hitbox(self.map, self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
			self.width - self.hitboxXOffset * 2, self.height - self.hitboxYOffset)
		
		self.talkNO = 1
		self.swordTalkNO = 1
		self.wasHit = false
		self.wasHitNO = 1
		self.completedShowOff = false
		self.wasDisplayingMessage = false
		
		self.hitWithCurrentSlash = false
		
		-- behavior map we can call based on Schnanderson state
		self.behaviors = {
			['idle'] = function(dt)
				-- potentially check for player hitting it
				
				if self.map.completedCutscene then
					self.state = 'shattered'
					self.animation = self.animations['shattered']
				else
					self.state = 'shatter'
					self.animations['shatter']:restart()
					self.animation = self.animations['shatter']
				end
			end,
			['shatter'] = function(dt)
				--[ [ check if animation is over
				if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
					self.state = 'shattered'
					self.animation = self.animations['shattered']
				end
				--]]
			end,
			['shattered'] = function(dt)
				-- do nothing
			end
		}
	
	elseif name == 'box' then
		
		self.defaultTexture = love.graphics.newImage('graphics/tileset.png')
		
		self.texture = self.defaultTexture
		
		self.width = 32
		self.height = 32
		
		if scale then
			self.scaleX = scale
			self.scaleY = scale
		else
			self.scaleX = 1
			self.scaleY = 1
		end
		
		--print("Scale: " .. self.scaleX)
		
		-- determines flip of sprite
		self.direction = 'n/a'
		
		-- offset from top left to center to support sprite flipping
		self.xOffset = 0
		self.yOffset = 0

		self.animations = {
			['idle'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(12 * self.width, 2 * self.height, self.width, self.height, self.texture:getDimensions())
				}
			})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitboxXOffset = 0
		self.hitboxYOffset = 0
		-- initialize hitbox
		self.hitbox = Hitbox(self.map, self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
			self.width - self.hitboxXOffset * 2, self.height - self.hitboxYOffset)
		
		self.talkNO = 1
		self.swordTalkNO = 1
		self.wasHit = false
		self.wasHitNO = 1
		self.completedShowOff = false
		self.wasDisplayingMessage = false
		
		self.hitWithCurrentSlash = false
		
		-- behavior map we can call based on Schnanderson state
		self.behaviors = {
			['idle'] = function(dt)
				
				for i, enemy in ipairs(enemies) do
					if enemy.name == 'sausage boss' then
						if self.hitbox:hitboxCollides(enemy.hitbox) or self.hitbox:hitboxCollides(self.map.player.swordHitbox) then
							self.state = 'explode'

							if self.width * self.scaleX == 16 then
								local x = self.x / self.map.tileWidth + 1
								local y = math.floor((self.y + 4) / self.map.tileHeight + 1)
								self.map:setTile(x, y, ' ')
								--print("Removed at (" .. x .. ", " .. y .. ")")
							elseif self.width * self.scaleX == 32 then
								--[ [ set this tile to air so that self does not instantly respawn
								for i = 0, 1 do
									for p = 0, 1 do
										self.map:setTile(self.x / self.map.tileWidth + 1 + i,
											math.floor((self.y + 4) / self.map.tileHeight + 1 + p), ' ')
									end
								end
								--]]
							end
						end
					end
				end
				
			end
		}
		
	elseif name == 'sign' then
		
		self.defaultTexture = love.graphics.newImage('graphics/exitSign.png')
		
		self.texture = self.defaultTexture
		
		self.width = 32
		self.height = 32
		
		if scale then
			self.scaleX = scale
			self.scaleY = scale
		else
			self.scaleX = 1
			self.scaleY = 1
		end
		
		--print("Scale: " .. self.scaleX)
		
		-- determines flip of sprite
		self.direction = 'n/a'
		
		-- offset from top left to center to support sprite flipping
		self.xOffset = 0
		self.yOffset = 0

		self.animations = {
			['idle'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.texture:getDimensions())
				}
			}),
			['filling'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(1 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(2 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(4 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(5 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(6 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(7 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(8 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(9 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(10 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(11 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(12 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(13 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(13 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(13 * self.width, 0, self.width, self.height, self.texture:getDimensions())
				},
				interval = 0.15
			}),
			['full'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(14 * self.width, 0, self.width, self.height, self.texture:getDimensions())
				}
			})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitboxXOffset = 0
		self.hitboxYOffset = 0
		-- initialize hitbox
		self.hitbox = Hitbox(self.map, self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
			self.width - self.hitboxXOffset * 2, self.height - self.hitboxYOffset)
		
		self.talkNO = 1
		self.swordTalkNO = 1
		self.wasHit = false
		self.wasHitNO = 1
		self.completedShowOff = false
		self.wasDisplayingMessage = false
		
		self.hitWithCurrentSlash = false
		
		-- behavior map we can call based on Schnanderson state
		self.behaviors = {
			['idle'] = function(dt)
				
				self:changeAnimation('idle')
				
				--[[
				if self.hitbox:hitboxCollides(map.player.hitbox) and WORLD > 0 then
					map.player.state = "endLevel"
				end
				--]]
				
			end,
			['filling'] = function(dt)
				
				self:changeAnimation('filling')
				
				if self.animation:isCompleted() then
					self.state = 'full'
				end
				
			end,
			['full'] = function(dt)
				self:changeAnimation('full')
			end
		}
	
	elseif name == 'treyPhone' then
		
		self.defaultTexture = love.graphics.newImage('graphics/treyPhone.png')
		
		self.texture = self.defaultTexture
		
		self.width = 32
		self.height = 32
		
		self.scaleX = 1
		self.scaleY = 1
		
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
				}
			}),
			['talk'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(0  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(1  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(2  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(3  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(3  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions())
				},
				interval = 0.1
			}),
			['surprised'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(4  * self.width, 0, self.width, self.height, self.texture:getDimensions())
				}
			}),
			['surprisedTalk'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(4  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(5  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(6  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(7  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					love.graphics.newQuad(7  * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions())
				},
				interval = 0.1
			})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitboxXOffset = 0
		self.hitboxYOffset = 0
		-- initialize hitbox
		self.hitbox = Hitbox(self.map, self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
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
			if behaviors[self.name] ~= nil then
				self.behaviors = behaviors[self.name]
			else
				self.behaviors = {
					['idle'] = function(dt)
						self.wasDisplayingMessage = false
					end
				}
			end
		else
			self.behaviors = {
				['idle'] = function(dt)
					self.wasDisplayingMessage = false
				end
			}
		end
		
		
		-- a few standard functions --
		
		-- 'talkReady'
		local tempBehav = function(dt)
			
			if self.map.player.state ~= 'sword' and self.hitWithCurrentSlash then
				self.hitWithCurrentSlash = false
			end
			
			if self.animation == self.animations['talk'] and not self.map.isDisplayingMessage then
				self.state = 'idle'
				self.animations['idle']:restart()
				self.animation = self.animations['idle']
			end
			-- check for player interaction
			if self.hitbox:hitboxCollides(self.map.player.hitbox)
				and love.keyboard.isDown(self.map.player.interactButton) then

				if self.wasHit then
					self:talk('wasHitTalk', self.wasHitNO)
					self.wasHitNO = self.wasHitNO + 1
				else
					self:talk('talk', self.talkNO)
					self.talkNO = self.talkNO + 1
				end
			end
			
			-- check for player sword hit
			if find_value(self.map.player.inventory, 'sword') > -1 then
				if self.hitbox:hitboxCollides(self.map.player.swordHitbox) and not self.isDisplayingMessage
					and not self.hitWithCurrentSlash then

					self.wasHit = true
					self.hitWithCurrentSlash = true

					self:talk('sword', self.swordTalkNO)

					self.swordTalkNO = self.swordTalkNO + 1
				end
			end
		end
		self.behaviors['talkReady'] = tempBehav
		
	elseif name == 'Trey' then
		
		self.defaultTexture = love.graphics.newImage('graphics/Trey_talking.png')
		self.talkTexture = love.graphics.newImage('graphics/Trey_talking.png')
		self.flyingTexture = love.graphics.newImage('graphics/treyFlying.png')
		self.inAirTexture = love.graphics.newImage('graphics/treyInAir.png')
		
		self.texture = self.defaultTexture
		
		self.width = 16
		self.height = 19
		
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
			['walking'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.texture:getDimensions())
				},
				interval = .15
			}),
			['flying'] = Animation({
				texture = self.flyingTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.flyingTexture:getDimensions())
				},
				interval = .15
			}),
			['inAir'] = Animation({
				texture = self.inAirTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.inAirTexture:getDimensions())
				},
				interval = .15
			}),
			['talk'] = Animation({
				texture = self.talkTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(1 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(2 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions())
				},
				interval = .1
			}),
			['stareForward'] = Animation({
				texture = self.talkTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions())
				}
			})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitboxXOffset = 6
		self.hitboxYOffset = 1
		-- initialize hitbox
		self.hitbox = Hitbox(self.map, self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
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
			if behaviors[self.name] ~= nil then
				self.behaviors = behaviors[self.name]
			else
				self.behaviors = {
					['idle'] = function(dt)
						self.wasDisplayingMessage = false

						self.state = 'talkReady'
					end
				}
			end
		else
			self.behaviors = {
				['idle'] = function(dt)
					self.wasDisplayingMessage = false
					
					self.state = 'talkReady'
				end
			}
		end
		
		
		-- a few standard functions --
		
		-- 'talkReady'
		local tempBehav = function(dt)
			
			if self.map.player.state ~= 'sword' and self.hitWithCurrentSlash then
				self.hitWithCurrentSlash = false
			end
			
			if self.animation == self.animations['talk'] and not self.map.isDisplayingMessage then
				self.state = 'idle'
				self.animations['idle']:restart()
				self.animation = self.animations['idle']
			end
			-- check for player interaction
			if self.hitbox:hitboxCollides(self.map.player.hitbox)
				and love.keyboard.isDown(self.map.player.interactButton) then

				if self.wasHit then
					self:talk('wasHitTalk', self.wasHitNO)
					self.wasHitNO = self.wasHitNO + 1
				else
					self:talk('talk', self.talkNO)
					self.talkNO = self.talkNO + 1
				end
			end
			
			-- check for player sword hit
			if find_value(self.map.player.inventory, 'sword') > -1 then
				if self.hitbox:hitboxCollides(self.map.player.swordHitbox) and not self.isDisplayingMessage
					and not self.hitWithCurrentSlash then

					self.wasHit = true
					self.hitWithCurrentSlash = true

					self:talk('sword', self.swordTalkNO)

					self.swordTalkNO = self.swordTalkNO + 1
				end
			end
		end
		self.behaviors['talkReady'] = tempBehav
		
		-- 'inAir'
		local tempBehav = function(dt)
			self.dx = 0
			self.dy = 0
			
			if self.map.player.state ~= 'sword' and self.hitWithCurrentSlash then
				self.hitWithCurrentSlash = false
			end
			
			if self.animation ~= self.animations['inAir'] then
				self.animations['inAir']:restart()
				self.animation = self.animations['inAir']
			end
			-- check for player interaction
			if self.hitbox:hitboxCollides(self.map.player.hitbox)
				and love.keyboard.isDown(self.map.player.interactButton) then

				if self.wasHit then
					self:talk('wasHitTalk', self.wasHitNO)
					self.wasHitNO = self.wasHitNO + 1
				else
					self:talk('talk', self.talkNO)
					self.talkNO = self.talkNO + 1
				end
			end
			
			-- check for player sword hit
			if find_value(self.map.player.inventory, 'sword') > -1 then
				if self.hitbox:hitboxCollides(self.map.player.swordHitbox) and not self.isDisplayingMessage
					and not self.hitWithCurrentSlash then

					self.wasHit = true
					self.hitWithCurrentSlash = true

					self:talk('sword', self.swordTalkNO)

					self.swordTalkNO = self.swordTalkNO + 1
				end
			end
		end
		self.behaviors['inAir'] = tempBehav
		
		-- end standard functions --
		
	elseif name == 'Colton' then
		
		self.defaultTexture = love.graphics.newImage('graphics/Colton.png')
		self.talkTexture = love.graphics.newImage('graphics/Colton_talking.png')
		
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
			['flip'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(7  * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(8  * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(9  * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(10 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(11 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(12 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(13 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(14 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(15 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(15 * self.width, 0, self.width, self.height, self.texture:getDimensions())
				},
				interval = .13
			}),
			['talk'] = Animation({
				texture = self.talkTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(1 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(2 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions())
				},
				interval = .1
			}),
			['stareForward'] = Animation({
				texture = self.talkTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions())
				}
			})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitboxXOffset = 6
		self.hitboxYOffset = 1
		-- initialize hitbox
		self.hitbox = Hitbox(self.map, self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
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
			if behaviors[self.name] ~= nil then
				self.behaviors = behaviors[self.name]
			else
				self.behaviors = {
					['idle'] = function(dt)
						self.wasDisplayingMessage = false

						self.state = 'talkReady'
					end
				}
			end
		else
			self.behaviors = {
				['idle'] = function(dt)
					self.wasDisplayingMessage = false
					
					self.state = 'talkReady'
				end
			}
		end
		
		
		-- a few standard functions --
		
		-- 'talkReady'
		local tempBehav = function(dt)
			
			if self.map.player.state ~= 'sword' and self.hitWithCurrentSlash then
				self.hitWithCurrentSlash = false
			end
			
			if self.animation == self.animations['talk'] and not self.map.isDisplayingMessage then
				self.state = 'idle'
				self.animations['idle']:restart()
				self.animation = self.animations['idle']
			end
			-- check for player interaction
			if self.hitbox:hitboxCollides(self.map.player.hitbox)
				and love.keyboard.isDown(self.map.player.interactButton) then

				if self.wasHit then
					self:talk('wasHitTalk', self.wasHitNO)
					self.wasHitNO = self.wasHitNO + 1
				else
					self:talk('talk', self.talkNO)
					self.talkNO = self.talkNO + 1
				end
			end
			
			-- check for player sword hit
			if find_value(self.map.player.inventory, 'sword') > -1 then
				if self.hitbox:hitboxCollides(self.map.player.swordHitbox) and not self.isDisplayingMessage
					and not self.hitWithCurrentSlash then

					self.wasHit = true
					self.hitWithCurrentSlash = true

					self:talk('sword', self.swordTalkNO)

					self.swordTalkNO = self.swordTalkNO + 1
				end
			end
		end
		self.behaviors['talkReady'] = tempBehav
		
		-- end standard functions --
		
	else -- Joel
		
		self.defaultTexture = love.graphics.newImage('graphics/Joel.png')
		self.talkTexture = love.graphics.newImage('graphics/Joel_talking.png')
		
		self.texture = self.defaultTexture
		
		self.width = 16
		self.height = 20
		
		-- determines flip of sprite
		self.direction = 'right'
		
		-- offset from top left to center to support sprite flipping
		self.xOffset = self.width / 2
		self.yOffset = self.height / 2
		
		self.walkingSpeed = WALKING_SPEED

		self.animations = {
			['idle'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.texture:getDimensions())
				},
				interval = .15
			}),
			['walking'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(1  * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(2  * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(3  * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(3  * self.width, 0, self.width, self.height, self.texture:getDimensions())
				},
				interval = .15
			}),
			['flip'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(7  * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(8  * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(9  * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(10 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(11 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(12 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(13 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(14 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(15 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(15 * self.width, 0, self.width, self.height, self.texture:getDimensions())
				},
				interval = .13
			}),
			['hairFix'] = Animation({
				texture = self.defaultTexture,
				frames = {
					love.graphics.newQuad(16 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(17 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(18 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(19 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(20 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(21 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(22 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(23 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(24 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(25 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(26 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(27 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(28 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(29 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(30 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(31 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(32 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(33 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(34 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
					love.graphics.newQuad(34 * self.width, 0, self.width, self.height, self.texture:getDimensions())
				},
				interval = .05
			}),
			['talk'] = Animation({
				texture = self.talkTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(1 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(2 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions()),
					love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions())
				},
				interval = .1
			}),
			['stareForward'] = Animation({
				texture = self.talkTexture,
				frames = {
					love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.talkTexture:getDimensions())
				}
			})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitboxXOffset = 6
		self.hitboxYOffset = 1
		-- initialize hitbox
		self.hitbox = Hitbox(self.map, self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
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
			if behaviors[self.name] ~= nil then
				self.behaviors = behaviors[self.name]
			end
		else
			self.behaviors = {
				['idle'] = function(dt)
					self.wasDisplayingMessage = false
					
					self.state = 'talkReady'
				end
			}
		end
		
		-- a few standard functions --
		
		-- 'talkReady'
		local tempBehav = function(dt)
			
			if self.animation ~= self.animations['idle'] then
				self.animations['idle']:restart()
				self.animation = self.animations['idle']
			end
			
			self.completedShowOff = true
			
			if self.dx > 0 then
				self.dx = self.dx - DX_REDUCER * dt
			elseif self.dx < 0 then
				self.dx = self.dx + DX_REDUCER * dt
			end
			if self.dx < 30 and self.dx > -30 then
				self.dx = 0
			end
			
			if self.map.player.state ~= 'sword' and self.hitWithCurrentSlash then
				self.hitWithCurrentSlash = false
			end
			
			if self.animation == self.animations['talk'] and not self.map.isDisplayingMessage then
				print("back to idle")
				self.state = 'idle'
				self.animations['idle']:restart()
				self.animation = self.animations['idle']
			end
			-- check for player interaction
			if self.hitbox:hitboxCollides(self.map.player.hitbox)
				and love.keyboard.isDown(self.map.player.interactButton) then

				if self.wasHit then
					self:talk('wasHitTalk', self.wasHitNO)
					self.wasHitNO = self.wasHitNO + 1
				else
					self:talk('talk', self.talkNO)
					self.talkNO = self.talkNO + 1
				end
			end
			
			-- check for player sword hit
			if find_value(self.map.player.inventory, 'sword') > -1 then
				if self.hitbox:hitboxCollides(self.map.player.swordHitbox) and not self.isDisplayingMessage
					and not self.hitWithCurrentSlash then

					self.wasHit = true
					self.hitWithCurrentSlash = true

					self:talk('sword', self.swordTalkNO)

					self.swordTalkNO = self.swordTalkNO + 1
				end
			end
		end
		self.behaviors['talkReady'] = tempBehav
		
		-- 'showingOff'
		tempBehav = function(dt)
			print("egg")
			if self.animation == self.animations['idle']
				or self.animation == self.animations['talk'] then

				self.animations['flip']:restart()
				self.animation = self.animations['flip']
			end

			-- check for end of animation
			if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then

				if self.animation == self.animations['flip'] then
					self.animations['hairFix']:restart()
					self.animation = self.animations['hairFix']

				elseif self.animation == self.animations['hairFix'] then

					self.state = 'idle'
					self.animations['idle']:restart()
					self.animation = self.animations['idle']

					self.completedShowOff = true
					
				end
			end
		end
		self.behaviors['showingOff'] = tempBehav
		
		-- walking
		tempBehav = function(dt)
			
			if self.animation == self.animations['idle'] then
				self.animations['walking']:restart()
				self.animation = self.animations['walking']
			end
			
			if self.destination ~= nil then
				if self.destination.x > self.x then self.direction = 'right' else self.direction = 'left' end
			end
			
			if self.direction == 'right' then
				if not self.rStop then
					if self.dx < self.walkingSpeed then
						self.dx = self.dx + 30
					else
						self.dx = self.dx - 30
					end
				end
			else -- left
				if not self.lStop then
					if self.dx > -self.walkingSpeed then
						self.dx = self.dx - 30
					else
						self.dx = self.dx + 30
					end
				end
			end
			
			self.state = 'idle'
		end
		self.behaviors['walking'] = tempBehav
		-- end standard functions --

	end
	
	
	-- in case of emergency, explode.
	local tWidth = 32
	local explosion = Animation({
		texture = self.explosionTexture,
		frames = {
			love.graphics.newQuad(0  * tWidth, 0, tWidth, tWidth, self.explosionTexture:getDimensions()),
			love.graphics.newQuad(1  * tWidth, 0, tWidth, tWidth, self.explosionTexture:getDimensions()),
			love.graphics.newQuad(2  * tWidth, 0, tWidth, tWidth, self.explosionTexture:getDimensions()),
			love.graphics.newQuad(3  * tWidth, 0, tWidth, tWidth, self.explosionTexture:getDimensions()),
			love.graphics.newQuad(4  * tWidth, 0, tWidth, tWidth, self.explosionTexture:getDimensions()),
			love.graphics.newQuad(5  * tWidth, 0, tWidth, tWidth, self.explosionTexture:getDimensions()),
			love.graphics.newQuad(6  * tWidth, 0, tWidth, tWidth, self.explosionTexture:getDimensions()),
			love.graphics.newQuad(6  * tWidth, 0, tWidth, tWidth, self.explosionTexture:getDimensions())
		},
		interval = .1
	})
	self.animations['explode'] = explosion
	
	local explode = function(dt)
		if self.animation ~= self.animations['explode'] then
			self.animations['explode']:restart()
			self.animation = self.animations['explode']
		end
		-- end of animation; remove from entity table
		if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
			self.dead = true
		end
	end
	self.behaviors['explode'] = explode
	
end

function Schnanderson:talk(mType, messageNO)
	
	self.wasDisplayingMessage = true
	
	local pMP = self.map.player.x + (self.map.player.width / 2) -- player midpoint
	local sMP = self.x + (self.width) -- self midpoint
	--print('Player x: ' .. self.map.player.x .. ' Player width / 2: ' .. self.map.player.width / 2 .. ' total: ' .. pMP)
	--print('self x: ' .. self.x .. ' self width / 2: ' .. self.width / 2 .. ' total: ' .. sMP)
	if pMP >= sMP then
		self.direction = 'right'
	else
		self.direction = 'left'
	end
	
	if self.animations['talk'] ~= nil then
		self.animations['talk']:restart()
		self.animation = self.animations['talk']
	end
	local keyString = mType .. tostring(messageNO)
	--print(keyString)
	local md = self.text[keyString] -- md meaning Message Data
	if md ~= nil then
		self.map:displayMessage(md[1], md[2], md[3], md[4], md[5], md[6], md[7], md[8], md[9])
		self.isDisplayingMessage = true
	else
		messageNO = messageNO - 1
		if messageNO < 1 then return end
		self:talk(mType, messageNO)
		return
	end
	
end

function Schnanderson:changeAnimation(anim)
	if self.animation ~= self.animations[anim] then
		self.animations[anim]:restart()
		self.animation = self.animations[anim]
	end
end

function Schnanderson:endOfAnimation()
	if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
		return true
	else
		return false
	end
end
	
function Schnanderson:update(dt)
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
	
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
	
	-- update hitbox
	self.hitbox:changeProperties(self.x + self.hitboxXOffset, self.y + self.hitboxYOffset,
		self.width + self.hitboxXOffset * 2 / 3, self.height - self.hitboxYOffset)
end

function Schnanderson:render()
	-- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if self.direction == 'right' then
        self.scaleX = 1
		self.xOffsetFactor = 0
    elseif self.direction == 'left' then
        self.scaleX = -1
		self.xOffsetFactor = 2
	else
		self.xOffsetFactor = 0
    end
	
	-- draw sprite with scale factor and offsets
    love.graphics.draw(self.animation.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset), 0, self.scaleX, self.scaleY, self.xOffset * self.xOffsetFactor, self.yOffset)
	
	if show_hitboxes then
		self.hitbox:render()
	end
end
