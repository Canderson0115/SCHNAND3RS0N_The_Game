--[[
    Represents our player in the game, with its own sprite.
]]

Player = Class{}

local WALKING_SPEED = 140
local JUMP_VELOCITY = 200
local DX_REDUCER = 550

function Player:init(map)
	
	--print("Epic")
    
	-- buttons that are used for controls
	self.downButton = 's'
	self.leftButton = 'a'
	self.rightButton = 'd'
	self.jumpButton = 'space'
	self.rollButton = 's'
	self.attackButton = 'j'
	self.item2Button = 'k'
	self.interactButton = 'w'
	
	self.buttons = { self.downButton, self.leftButton, self.rightButton, self.jumpButton, self.rollButton, self.attackButton, self.item2Button, self.interactButton }
	
	self.hoverButton = 'h'
	self.resetButton = 'r'
	self.healButton = 'h'
	
	
	-- initialize a whole bunch of player variables
    self.x = 0
    self.y = -420
	
	self.spawnPointX = 0
	self.spawnPointY = 0
	
    self.width = 16
    self.height = 20
	self.rotation = 0
	
	self.rollInterval = 0
	self.diving = false
	
	self.endLevelCounter = 0
	
	self.hide = false
	
	-- change this once save files are added
	self.heartContainers = 3
	
	self.health = self.heartContainers * 2
	self.coins = 0
	
	-- gravity cap
	self.terminalVelocity = 350
	
	self.uStop = false
	self.dStop = false
	self.rStop = false
	self.lStop = false
	
	self.fallingSword = false
	
	self.mute = mute
	
	self.action = 'unavailable'
	
    -- offset from top left to center to support sprite flipping
    self.xOffset = 8
    self.yOffset = 10
	
	self.xtraOffset = 0
	self.ytraOffset = 0

    -- reference to map for checking tiles
    self.map = map
	
	-- spawn hearts
	self.hearts = {}
	self.currentHeart = 0
	
	for heart = 0, self.heartContainers - 1, 1 do
		self.hearts[heart] = Heart(self.map)
		self.currentHeart = heart
	end
	
	-- current inventory
	self.inventory = {}
	--self:giveItem('sword')
	
	local function find_value (tab, val)
		for index, value in ipairs(tab) do
			if value == val then
				return index
			end
		end

		return -1
	end
	
	if find_value (self.inventory, 'sword') > -1 then
		self.swordHitbox = Hitbox(self.map, 0, -50, 0, 0)
	end
	
	-- set up table to hold completed levels
	self.completedWorlds = {}
	self.completedLevels = {}
	
    --[[ low storage sound effects (everything is OOF)
    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/oof.mp3', 'static'),
        ['hit'] = love.audio.newSource('sounds/oof.mp3', 'static'),
        ['coin'] = love.audio.newSource('sounds/oof.mp3', 'static'),
		['hurt'] = love.audio.newSource('sounds/oof.mp3', 'static'),
		['oof'] = love.audio.newSource('sounds/oof.mp3', 'static')
    }
	--]]
	
	--[ [ real sound effects
	self.sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['coin'] = love.audio.newSource('sounds/coin.wav', 'static'),
		['hurt'] = love.audio.newSource('sounds/damage.mp3', 'static'),
		['oof'] = love.audio.newSource('sounds/oof.mp3', 'static'),
		['swordSwing'] = love.audio.newSource('sounds/swordSwing.mp3', 'static')
    }
	--]]

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'

    -- determines sprite flipping
    self.direction = 'right'

    -- x and y velocity
    self.dx = 0
    self.dy = 0

    --[[ position on top of map tiles
    self.y = 100--map.tileHeight * (map.mapHeight - 2) - self.height
    self.x = 30--map.tileWidth * 5
	--]]
	
	self.texture = love.graphics.newImage('graphics/Adventure Sprites.png')
	self.swords = love.graphics.newImage('graphics/Swords.png')
	self.swordsWidth = 32
	self.edgeTexture = love.graphics.newImage('graphics/Holding Ledge.png')
	
	self.currentTexture = self.texture

    -- initialize all player animations
    self.animations = {
        ['idle'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(0 * self.width, 0, 16, 20, self.texture:getDimensions())
            }
        }),
        ['walking'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(17 * self.width, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(18 * self.width, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(19 * self.width, 0, 16, 20, self.texture:getDimensions()),
                love.graphics.newQuad(18 * self.width, 0, 16, 20, self.texture:getDimensions()),
				-- You need an extra frame at the end, apparently
				love.graphics.newQuad(18 * self.width, 0, 16, 20, self.texture:getDimensions())
            },
            interval = 0.15
        }),
        ['jumping'] = Animation({
            texture = self.texture,
            frames = {
                love.graphics.newQuad(17 * self.width, 0, 16, 20, self.texture:getDimensions())
            }
        }),
		['edge'] = Animation({
			texture = self.texture,
			frames = {
				love.graphics.newQuad(21 * self.width, 0, 16, 20, self.texture:getDimensions())
			}
		}),
		['edgeHoldAway'] = Animation({
            texture = self.edgeTexture,
            frames = {
                love.graphics.newQuad(1 * self.width, 0, 16, 20, self.edgeTexture:getDimensions())
            }
        }),
		['edgeJump'] = Animation({
            texture = self.edgeTexture,
            frames = {
                love.graphics.newQuad(2 * self.width, 0, 16, 20, self.edgeTexture:getDimensions()),
                love.graphics.newQuad(3 * self.width, 0, 16, 20, self.edgeTexture:getDimensions()),
                love.graphics.newQuad(4 * self.width, 0, 16, 20, self.edgeTexture:getDimensions()),
                love.graphics.newQuad(5 * self.width, 0, 16, 20, self.edgeTexture:getDimensions()),
				love.graphics.newQuad(6 * self.width, 0, 16, 20, self.edgeTexture:getDimensions()),
                love.graphics.newQuad(7 * self.width, 0, 16, 20, self.edgeTexture:getDimensions()),
				-- You need an extra frame at the end, apparently
				love.graphics.newQuad(7 * self.width, 0, 16, 20, self.edgeTexture:getDimensions())
            },
            interval = 0.05
        }),
		['crouching'] = Animation({
			texture = self.texture,
			frames = {
				love.graphics.newQuad(22 * self.width, 0, 16, 20, self.texture:getDimensions())
			}
		}),
		['rollingG'] = Animation({
			texture = self.texture,
			frames = {
				love.graphics.newQuad(23 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(24 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(25 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(26 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(27 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(28 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(29 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(30 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(31 * self.width, 0, 16, 20, self.texture:getDimensions())
			},
			interval = 0.08
		}),
		['rollingA'] = Animation({
			texture = self.texture,
			frames = {
				-- it doesn't seem to include the first frame
				love.graphics.newQuad(24 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(25 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(26 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(27 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(28 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(29 * self.width, 0, 16, 20, self.texture:getDimensions()),
				love.graphics.newQuad(30 * self.width, 0, 16, 20, self.texture:getDimensions())
			},
			interval = 0.095 --.15
		}),
		['diving'] = Animation({
			texture = self.texture,
			frames = {
				love.graphics.newQuad(20 * self.width, 0, 16, 20, self.texture:getDimensions())
			}
		}),
		['dying'] = Animation({
			texture = self.texture,
			frames = {
				love.graphics.newQuad(1 * self.width, 0, 16, 20, self.texture:getDimensions())
			}
		}),
		['swordSwingDown'] = Animation({
			texture = self.swords,
			frames = {
				love.graphics.newQuad(0 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(1 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(2 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(3 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(4 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(5 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(6 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(7 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions())
			},
			interval = 0.04
		}),
		['swordHoldDown'] = Animation({
			texture = self.swords,
			frames = {
				love.graphics.newQuad(8 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(8 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(8 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions())
			},
			interval = .125
		}),
		['swordSheath'] = Animation({
			texture = self.swords,
			frames = {
				love.graphics.newQuad(9 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(10 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(11 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(12 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions()),
				love.graphics.newQuad(13 * self.swordsWidth, 0, 32, 32, self.swords:getDimensions())
			},
			interval = 0.1
		}),
		['stareForward'] = Animation({
			texture = self.texture,
			frames = {
				love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
				love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.texture:getDimensions()),
				love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.texture:getDimensions())
			},
			interval = 3
		})
    }

    -- initialize animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()
	
	-- set up player hitbox
	self.hitboxXOffset = 2
	self.hitboxYOffset = 1
	self.hitboxWidth = self.width
	self.hitboxHeight = self.height
	
	self.hitbox = Hitbox(self.map, self.x + self.hitboxXOffset, self.y + self.hitboxYOffset, self.hitboxWidth, self.hitboxHeight)
	
    -- behavior map we can call based on player state
    self.behaviors = {
        ['idle'] = function(dt)
			
			self.hide = false
			
			self.action = 'available'
			
			if self.animation == self.animations['stareForward']
				and self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
				
				self.animation = self.animations['idle']
				
			end
			
			if love.keyboard.isDown(self.downButton) then
				self.animation = self.animations['crouching']
			elseif love.keyboard.wasReleased(self.downButton) then
				self.animation = self.animations['idle']
			end
			
            -- add spacebar functionality to trigger jump state
            if love.keyboard.wasPressed(self.jumpButton) then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                if not self.mute then self.sounds['jump']:play() end
            elseif love.keyboard.isDown(self.leftButton) then
                self.direction = 'left'
				if not self.lStop then
					--self.dx = -WALKING_SPEED
					self.state = 'walking'
					self.animations['walking']:restart()
					self.animation = self.animations['walking']
				end
            elseif love.keyboard.isDown(self.rightButton) then
                self.direction = 'right'
				if not self.rStop then
					--self.dx = WALKING_SPEED
					self.state = 'walking'
					self.animations['walking']:restart()
					self.animation = self.animations['walking']
				end
            else
                if self.dx > 0 then
					self.dx = self.dx - DX_REDUCER * dt
				elseif self.dx < 0 then
					self.dx = self.dx + DX_REDUCER * dt
				end
				if self.dx < 30 and self.dx > -30 then
					self.dx = 0
				end
            end
			
			-- kills player if they are inside a block
			if self.map:collides(self.map:tileAt(self.x + self.width / 2, self.y + self.height - 1)) then
				self:hurt(999)
				--self.y = self.y - 2
			end
			
			-- check if there's a tile directly beneath us
            if not self.map:collides(self.map:tileAt(self.x + 6, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height)) then
                
                -- if not, player is falling
                self.state = 'jumping'
                self.animation = self.animations['jumping']
				self.dStop = false
            end
			
			-- check if player is standing on a save point
			if self.map:tileAt(self.x + 6, self.y + self.height).id == '%' or
				self.map:tileAt(self.x + self.width - 7, self.y + self.height).id == '%' then
				
				if love.keyboard.wasPressed(self.rollButton) then
					self.map.menuDisplay = true
					self.map.menu = Menu(self.map, 'regular', smallFont, {"Cancel", "Save", ":File 1", ":File 2", ":File 3", "Load", ":File 1", ":File 2", ":File 3", "Delete File", ":Delete File 1", "::Don't Delete", "::Yes, delete", ":Delete File 2", "::Don't Delete", "::Yes, delete", ":Delete File 3", "::Don't delete", "::Yes, delete"}, true)
				end
				
			end
			
			-- check for collisions moving left and right
			--[ [ or don't
            self:checkRightCollision()
            self:checkLeftCollision()
			--]]
			
			self:defaultHitbox()
        end,
        ['walking'] = function(dt)
            
			self.action = 'available'
			
            -- keep track of input to switch movement while walking, or reset
            -- to idle if we're not moving
            if love.keyboard.wasPressed(self.jumpButton) then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                if not self.mute then self.sounds['jump']:play() end
			elseif love.keyboard.wasPressed(self.rollButton) then
				self.state = 'rolling'
				self.animations['rollingG']:restart()
				self.animation = self.animations['rollingG']
				self.rollInterval = 0
            elseif love.keyboard.isDown(self.leftButton) then
                self.direction = 'left'
				if not self.lStop then
					if self.dx > -WALKING_SPEED then
						self.dx = self.dx - 30
					else
						self.dx = self.dx + 30
					end
				end
            elseif love.keyboard.isDown(self.rightButton) then
                self.direction = 'right'
				if not self.rStop then
					if self.dx < WALKING_SPEED then
						self.dx = self.dx + 30
					else
						self.dx = self.dx - 30
					end
				end
            else
				if self.dx > 0 then
					self.dx = self.dx - DX_REDUCER * dt
				elseif self.dx < 0 then
					self.dx = self.dx + DX_REDUCER * dt
				end
                self.state = 'idle'
				self.animations['stareForward']:restart()
                self.animation = self.animations['stareForward']
            end

            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
			
			-- check for BOOST PAD
			if self.map:collidesBooster(self.map:tileAt(self.x + self.width / 2, self.y + self.height)) then
				if self.direction == 'right' then
					self.dx = self.dx + 1000
				else
					self.dx = self.dx - 1000
				end
			end

            -- check if there's a tile directly beneath us
            if not self.map:collides(self.map:tileAt(self.x + 6, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height)) then
                
                -- if not, player is falling
                self.state = 'jumping'
                self.animation = self.animations['jumping']
				self.dStop = false
            end
			
			-- update hitbox
			self:defaultHitbox()
        end,
		['rolling'] = function(dt)
			
			if (self.animation == self.animations['rollingG'] and self.animation:getCurrentFrameNumber() >= 5)
				or (self.animation == self.animations['rollingA'] and self.animation:getCurrentFrameNumber() >= 4) then
				self.action = 'available'
			else
				self.action = 'unavailable'
			end
			
			if self.rollInterval == 0 then
				if self.direction == 'right' and self.dx < 250 then
					self.dx = 250
				elseif self.direction == 'left' and self.dx > -250 then
					self.dx = -250
				end
			else
				if self.dx > 50 then
					self.dx = self.dx - 500 * dt
				elseif self.dx < -50 then
					self.dx = self.dx + 500 * dt
				end
			end
			
			if love.keyboard.wasPressed(self.jumpButton) and self.rollInterval < 0.5 then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                if not self.mute then self.sounds['jump']:play() end
			end
			
			if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
				self.state = 'idle'
				self.animations['stareForward']:restart()
                self.animation = self.animations['stareForward']
				self.rollInterval = 0
			end
			
			-- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
			
			-- check if there's a tile directly beneath us
            if not self.map:collides(self.map:tileAt(self.x + 6, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height)) then
                
                -- if not, player is falling
                self.state = 'jumping'
                self.animation = self.animations['jumping']
				self.dStop = false
            end
			
			self.rollInterval = self.rollInterval + 1 * dt
			
			-- update hitbox
			self.hitboxXOffset = 4
			self.hitboxYOffset = 10
			self.hitboxWidth = self.width - 8
			self.hitboxHeight = self.height - 12
		end,
		['dying'] = function(dt)
			
			self.action = 'unavailable'
			
			self.dx = 0
			
			self:resetTexture()
			
			if self.y > self.map.mapHeight * 16 + self.height * 5 then
				self:reset()
				self:heal()
			else
				self.dy = self.dy + 5.5
			end
			
			-- update hitbox
			self:defaultHitbox()
			self.hitboxWidth = 0
			self.hitboxHeight = 0
		end,
        ['jumping'] = function(dt)
			
			self.action = 'available'
			
			-- below the screen
            if self.y > self.map.mapHeight * 16 - 12 then
				
				-- check if there is sub screen under this one
				local tempSub = SUB - 1
				local mapString = ""
				if tempSub ~= 0 then
					mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '_' .. tempSub ..'.lua'
				else
					mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '.lua'
				end
				--print("ms: " .. mapString)
				--print(love.filesystem.getInfo(mapString))
				if love.filesystem.getInfo(mapString) then
					SUB = SUB - 1
					--print("sub " .. SUB)
					self.y = 8
					Map:reloadMap()
				else -- no sub screen
					-- ouch
					self:hurt(2)
					if self.state ~= 'dying' then
						self:reset()
					end
					--self.y = 0 - self.height
				end
				
            end
			
			if CHEATS then
				if love.keyboard.wasPressed(self.jumpButton) and self.rollInterval < 0.5 then
					self.dy = -JUMP_VELOCITY
					self.state = 'jumping'
					self.animation = self.animations['jumping']
					if not self.mute then self.sounds['jump']:play() end
				end
				if love.keyboard.isDown(self.hoverButton) then
					if self.dy >= 0 then
						self.dStop = true
						self.dy = 0
					end
				end
			end

			if love.keyboard.isDown(self.downButton) and self.dy > 0 then
				self:resetTexture()
				self.animation = self.animations['diving']
				if self.direction == 'left' then
					self.rotation = (3 * math.pi) / 2
				elseif self.direction == 'right' then
					self.rotation = math.pi / 2
				end
				self.diving = true
			end
			
			if love.keyboard.wasReleased(self.downButton) then
				self.animation = self.animations['jumping']
				self.rotation = 0
				self.diving = false
            elseif love.keyboard.isDown(self.leftButton) then
				self.direction = 'left'
				if not self.lStop then
					if self.dx > -WALKING_SPEED then
						self.dx = self.dx - 30
					end
				end
            elseif love.keyboard.isDown(self.rightButton) then
                self.direction = 'right'
                if not self.rStop then
					if self.dx < WALKING_SPEED then
						self.dx = self.dx + 30
					end
				end
			else
				if self.dx > 0 then
					self.dx = self.dx - DX_REDUCER * dt
				elseif self.dx < 0 then
					self.dx = self.dx + DX_REDUCER * dt
				end
				if self.dx < 30 and self.dx > -30 then
					self.dx = 0
				end
            end
			
			-- check for alternate animation
			if self.animation ~= self.animations['jumping'] and self.animation ~= self.animations['diving'] then
				print("Not jumping animation")
				if self.animation:isCompleted() then
					print("Done with alt anim\n")
					self:changeAnimation('jumping')
				end
			end

            -- apply map's gravity before y velocity
			if self.dy < self.terminalVelocity and not self.dStop then
				self.dy = self.dy + self.map.gravity * dt
			end

            -- check if there's a tile directly beneath us
            if self.map:collides(self.map:tileAt(self.x + 6, self.y + self.height)) or
                self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height)) then
                
                -- if so, reset velocity and position and change state
                self.dy = 0
                
				if self.diving == false then
					self.state = 'idle'
					self.animations['stareForward']:restart()
					self.animation = self.animations['stareForward']
					self:resetTexture()
				else
					self.state = 'rolling'
					self.animations['rollingA']:restart()
					self.animation = self.animations['rollingA']
					self.rollInterval = 0
				end
				
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
				self.dStop = true
				self.rotation = 0
				
				if self.animation == self.animations['swordHoldDown'] then
					self.state = 'sword'
				end
			else
				self.dStop = false
            end
			
			local factor = 1.5
			-- check if there's a tile two heights below us
			if (self.map:collides(self.map:tileAt(self.x + 6, self.y + self.height * factor)) or
				self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height * factor))) and
				self.dy > 0 then
				
				self.dy = 0
				
                if self.diving == false and self.animation ~= self.animations['swordHoldDown'] then
					self.state = 'idle'
					self.animations['stareForward']:restart()
					self.animation = self.animations['stareForward']
					self:resetTexture()
				elseif self.diving == true then
					self.state = 'rolling'
					self.animations['rollingA']:restart()
					self.animation = self.animations['rollingA']
					self.rollInterval = 0
				end
                
				self.y = (self.map:tileAt(self.x, self.y + self.height * factor).y - 1) * self.map.tileHeight - self.height
				self.dStop = true
				self.diving = false
				self.rotation = 0
			end
			
            -- check for collisions moving left and right
            self:checkRightCollision()
            self:checkLeftCollision()
			
			-- update hitbox
			self:defaultHitbox()
        end,
		['hurt'] = function(dt)
			
			self.action = 'available'
			
			self.state = 'idle'
			
			-- update hitbox
			self:defaultHitbox()
		end,
		['sword'] = function(dt)
			--print("current frame: " .. tostring(self.animation:getCurrentFrameNumber()))
			--print("total frames in animation: " .. tostring(table.getn(self.animation.frames)))
			
			if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
				
				if self.animation == self.animations['swordSwingDown'] then
					self.animations['swordHoldDown']:restart()
					self.animation = self.animations['swordHoldDown']
					self.canSwing = true
				elseif self.animation == self.animations['swordHoldDown'] then
					--if not self.fallingSword then
					self.animations['swordSheath']:restart()
					self.animation = self.animations['swordSheath']
					--[[else
						self.animations['swordHoldDown']:restart()
					end]]
				elseif self.animation == self.animations['swordSheath'] then
					-- end of sword down animation
					self.state = 'idle'
					self.animations['stareForward']:restart()
					self.animation = self.animations['stareForward']
					self:resetTexture()
				end
			end
			
			-- sword hitbox stuff
			if find_value (self.inventory, 'sword') > -1 then
				if self.animation == self.animations['swordSwingDown']
					and (self.animation:getCurrentFrameNumber() == 6) then
					if self.direction == 'right' then
						self.swordHitbox:changeProperties(self.x + 17, self.y + 4, 17, 12)
					elseif self.direction == 'left' then
						self.swordHitbox:changeProperties(self.x - 18, self.y + 4, 17, 12)
					end
				elseif self.animation == self.animations['swordHoldDown'] then
					if self.direction == 'right' then
						self.swordHitbox:changeProperties(self.x + 17, self.y + 12, 17, 4)
					elseif self.direction == 'left' then
						self.swordHitbox:changeProperties(self.x - 18, self.y + 12, 17, 4)
					end
				else
					self.swordHitbox:deInit()
				end
			end
			
			-- Hit that block!
			if self.map.blockHitBox ~= nil then
				--if self.animation == self.animations['swordHoldDown']
				if self.swordHitbox:hitboxCollides(self.map.blockHitBox) then

					self.map:setTile(self.map.blockHitBox.x / self.map.tileWidth + 1,
						self.map.blockHitBox.y / self.map.tileHeight + 1, JUMP_BLOCK_HIT)
					self.coins = self.coins + 1
					self.map.churro:get(self.map.blockHitBox.x / self.map.tileHeight + 1,
						self.map.blockHitBox.y / self.map.tileHeight + 1)
					if not self.mute then self.sounds['coin']:play() end
					self.map.blockHitBox:deInit()

				end
			end
			
			if not self.fallingSword then
				if love.keyboard.isDown(self.leftButton) and self.animation == self.animations['swordSheath']
					and self.direction == 'left' then
					
					if not self.lStop then
						if self.dx > -WALKING_SPEED then
							self.dx = self.dx - 5
						end
					end
					
				elseif love.keyboard.isDown(self.rightButton) and self.animation == self.animations['swordSheath']
					and self.direction == 'right' then
					
					if not self.rStop then
						if self.dx < WALKING_SPEED then
							self.dx = self.dx + 5
						end
					end
					
				else
					if self.dx > 0 then
						self.dx = self.dx - DX_REDUCER / 2.25 * dt
					elseif self.dx < 0 then
						self.dx = self.dx + DX_REDUCER / 2.25 * dt
					end
					if self.dx < 30 and self.dx > -30 then
						self.dx = 0
					end
				end
			end
			
			-- check for collisions moving left and right
			--[ [ or don't
            self:checkRightCollision()
            self:checkLeftCollision()
			--]]
			
			
			-- == Falling Stuff == --
			
			-- check if there's not a tile directly beneath us
            if not self.map:collides(self.map:tileAt(self.x + 6, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height)) then
                
				
				if self.direction == 'left' and self.dx < 0 then
					if not self.lStop then
						if self.dx > -WALKING_SPEED / 2 then
							self.dx = self.dx - 30
						end
					end
				elseif self.direction == 'right' and self.dx > 0 then
					if not self.rStop then
						if self.dx < WALKING_SPEED / 2 then
							self.dx = self.dx + 30
						end
					end
				else
					if self.dx > 0 then
						self.dx = self.dx - DX_REDUCER * dt
					elseif self.dx < 0 then
						self.dx = self.dx + DX_REDUCER * dt
					end
					if self.dx < 30 and self.dx > -30 then
						self.dx = 0
					end
				end
				
                -- player is falling
				
				if love.keyboard.isDown(self.downButton) and self.dy > 0 then
					self:resetTexture()
					self.state = 'jumping'
					self.animation = self.animations['diving']
					self.fallingSword = false
					if self.direction == 'left' then
						self.rotation = (3 * math.pi) / 2
					elseif self.direction == 'right' then
						self.rotation = math.pi / 2
					end
					self.diving = true
				end

				-- below the screen
				if self.y > self.map.mapHeight * 16 - 12 then
					
					self:resetTexture()
					
					-- check if there is sub screen under this one
					local tempSub = SUB + 1
					local mapString = ""
					if tempSub ~= 0 then
						mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '_' .. tempSub ..'.lua'
					else
						mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '.lua'
					end
					if love.filesystem.getInfo(mapString) then
						SUB = SUB + 1
						self.y = 8
						Map:reloadMap()
					else -- no sub screen
						-- ouch
						self:hurt(2)
						if self.state ~= 'dying' then
							self:reset()
						end
					end
					self.fallingSword = false
					--self.y = 0 - self.height
				end

				-- apply map's gravity before y velocity
				if self.dy < self.terminalVelocity and not self.dStop then
					self.dy = self.dy + self.map.gravity * dt
				end

				if not self.dStop then
					self.fallingSword = true
					if love.keyboard.isDown(self.attackButton) and self.animation == self.animations['swordHoldDown'] then
						self.animations['swordHoldDown']:restart()
					end
				else
					self.fallingSword = false
				end

				-- check if there's a tile directly beneath us
				if self.map:collides(self.map:tileAt(self.x + 6, self.y + self.height)) or
					self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height)) then

					-- if so, reset velocity and position and change state
					self.dy = 0

					self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
					self.dStop = true
					self.rotation = 0
					if self.animation ~= self.animations['swordHoldDown'] and self.animation ~= self.animations['swordSwingDown'] then
						self.state = 'idle'
						self.animations['stareForward']:restart()
						self.animation = self.animations['stareForward']
						self:resetTexture()
					end
					self.fallingSword = false
				else
					self.dStop = false
				end

				local factor = 1.5
				-- check if there's a tile two heights below us
				if (self.map:collides(self.map:tileAt(self.x + 6, self.y + self.height * factor)) or
						self.map:collides(self.map:tileAt(self.x + self.width - 7, self.y + self.height * factor))) and
					self.dy > 0 then

					self.dy = 0

					if self.animation ~= self.animations['swordHoldDown'] and self.animation ~= self.animations['swordSwingDown'] then
						self.state = 'idle'
						self.animations['stareForward']:restart()
						self.animation = self.animations['stareForward']
						self:resetTexture()
					end
					self.fallingSword = false
					self.y = (self.map:tileAt(self.x, self.y + self.height * factor).y - 1) * self.map.tileHeight - self.height
					self.dStop = true
					self.diving = false
					self.rotation = 0
				end
				
				self.dStop = false
				
			else
				self.fallingSword = false
            end
			
			-- update hitbox
			self:defaultHitbox()
			
		end,
		['endLevel'] = function(dt)
			
			self.dx = 0
			self.dy = 0
			
			self:handoff()
			
			self.cSub.state = 'dance'
			
			if self.cSub.doneDancing then
				-- End Level
				print("End Level")
				
				-- !!!
				
				table.insert(self.completedLevels, LEVEL)
				
				self.state = 'transition'
				
				self.y = 0
				
				self.map:transitionToSave()
			end
			
		end,
		['transition'] = function(dt)
			self.action = 'unavailable'
			self.hide = true
			
			if WORLD == 0 then
				self.hide = false
				self.state = 'idle'
			end
		end,
		['edge'] = function(dt)
			
			self.action = 'unavailable'
			
			self.dy = 0
			self.dx = 0
			self.rotation = 0
			self.diving = false
			
			if love.keyboard.wasPressed(self.jumpButton) then
                
				-- Jump off of the edge
				
				self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
				
				if self.animation == self.animations['edgeHoldAway'] then
					self:changeAnimation('edgeJump')
					
					if self.direction == 'right' then self.direction = 'left' else self.direction = 'right' end
					
				else
					self.animation = self.animations['jumping']
				end

				if not self.mute then self.sounds['jump']:play() end
				
			elseif love.keyboard.isDown(self.leftButton) then
				if self.direction == 'right' then
					-- facing away
					self.animation = self.animations['edgeHoldAway']
				end
			elseif love.keyboard.isDown(self.rightButton) then
				if self.direction == 'left' then
					-- facing away
					self.animation = self.animations['edgeHoldAway']
				end
			elseif love.keyboard.wasReleased(self.leftButton) or love.keyboard.wasReleased(self.rightButton) then
				self:changeAnimation('edge')
			elseif love.keyboard.wasPressed(self.downButton) then
				self.state = 'idle'
				self.animations['stareForward']:restart()
                self.animation = self.animations['stareForward']
				--self.rotation = 0
			end
			
			-- update hitbox
			self:defaultHitbox()
			
		end
    }
	
end

function Player:actions(dt)
	-- has actions that you can do while standing, walking, etc.
	
	for i, entity in ipairs(entities) do
		if entity.name == 'sign' then
			if entity.hitbox:hitboxCollides(self.hitbox) then
				if entity.state == 'idle' then
					entity.state = 'filling'
				elseif entity.state == 'full' then
					self.state = 'endLevel'
				end
			else
				entity.state = 'idle'
			end
		end
	end
	
	if self.state ~= 'sword' then self.canSwing = true end
	
	if love.keyboard.wasPressed(self.attackButton) and find_value(self.inventory, 'sword') > -1 and self.canSwing then
		-- swing sword
		self.state = 'sword'
		self.animations['swordSwingDown']:restart()
		self.animation = self.animations['swordSwingDown']
		self.xOffset = 16
		self.yOffset = 16
		self.ytraOffset = 12
		if self.direction == 'right' then
			self.xtraOffset = -2
		else
			self.xtraOffset = -18
		end
		self.canSwing = false
		if not self.mute then self.sounds['swordSwing']:play() end
	elseif love.keyboard.wasPressed(self.resetButton) then
		self.animation = self.animations['idle']
		self:resetTexture()
	end
	
	-- heal if player has a medkit
	if love.keyboard.wasPressed(self.healButton) and find_value(self.inventory, 'medkit') > -1 and self.health < self.heartContainers * 2 then
		self:heal()
		table.remove(self.inventory, find_value(self.inventory, 'medkit'))
	end
	
	-- OOooHHhh! ChEaTs! O_o
	if CHEATS then
		if love.keyboard.isDown('l') and self.state ~= 'idle' then
			if self.direction == 'left' then
				self.dx = -500
			else
				self.dx = 500
			end
		end
		
		if love.keyboard.wasPressed('h') then
			self:heal()
		elseif love.keyboard.wasPressed('r') then
			self:reset()
		end
	end
end

function Player:defaultHitbox()
	self.hitboxXOffset = 2
	self.hitboxYOffset = 1
	self.hitboxWidth = self.width
	self.hitboxHeight = self.height
end

function Player:giveItem(item)
	table.insert(self.inventory, item)
end

function Player:changeAnimation(newAnimation)
	
	self.animation = self.animations[newAnimation]
	self.animations[newAnimation]:restart()
	
end

function Player:reset()
	
	-- reset map
	self.map:reloadMap()
	
	-- resets player's momentum and position on the map
	if self.spawnPointX > 0 and self.spawnPointY > 0 then
		self.x = self.spawnPointX
		self.y = self.spawnPointY
		self.dx = 0
		self.dy = 0
		
		-- maybe have a respawn animation
		self.state = 'idle'
		self.animation = self.animations['idle']
		
		self.rollInterval = 0
		self.rotation = 0
		self.diving = false
	else
		self.y = 0 - self.height
	end
	
	self.map.camX = math.max(0, math.min(self.x - VIRTUAL_WIDTH / 2,
			math.min(self.map.mapWidthPixels - self.map.tileWidth - VIRTUAL_WIDTH, self.x)))
end

function Player:resetPosition()
	
	-- resets player's momentum and position on the map
	if self.spawnPointX > 0 and self.spawnPointY > 0 then
		self.x = self.spawnPointX
		self.y = self.spawnPointY
		self.dx = 0
		self.dy = 0
		
		-- maybe have a respawn animation
		self.state = 'idle'
		self.animation = self.animations['idle']
		
		self.rollInterval = 0
		self.rotation = 0
		self.diving = false
	else
		self.y = 0 - self.height
	end
end

function Player:set0()
	self.x = 0
	self.y = -420
end

function Player:hurt(damage)
	
	if self.health == 0 then return end
	
	-- take damage
	self.health = self.health - damage
	if self.health < 0 then
		self.health = 0
	end
	
	while damage > 0 do
		
		if self.hearts[self.currentHeart].state == 'full' and damage == 1 then
			self.hearts[self.currentHeart].state = 'half'
			self.hearts[self.currentHeart].animation = self.hearts[self.currentHeart].animations['half']
			damage = 0
		elseif self.hearts[self.currentHeart].state == 'half' and damage == 1 then
			self.hearts[self.currentHeart].state = 'empty'
			self.hearts[self.currentHeart].animation = self.hearts[self.currentHeart].animations['empty']
			if self.currentHeart - 1 >= 0 then
				self.currentHeart = self.currentHeart - 1
			end
			damage = 0
		elseif self.hearts[self.currentHeart].state == 'full' and damage == 2 then
			self.hearts[self.currentHeart].state = 'empty'
			self.hearts[self.currentHeart].animation = self.hearts[self.currentHeart].animations['empty']
			if self.currentHeart - 1 >= 0 then
				self.currentHeart = self.currentHeart - 1
			end
			damage = 0
		elseif self.hearts[self.currentHeart].state == 'half' and damage == 2 then
			self.hearts[self.currentHeart].state = 'empty'
			self.hearts[self.currentHeart].animation = self.hearts[self.currentHeart].animations['empty']
			if self.currentHeart - 1 >= 0 then
				self.currentHeart = self.currentHeart - 1
			end
			damage = damage - 1
		elseif self.hearts[self.currentHeart].state == 'full' and damage > 2 then
			self.hearts[self.currentHeart].state = 'empty'
			self.hearts[self.currentHeart].animation = self.hearts[self.currentHeart].animations['empty']
			if self.currentHeart - 1 >= 0 then
				self.currentHeart = self.currentHeart - 1
			end
			damage = damage - 2
		elseif self.hearts[self.currentHeart].state == 'half' and damage > 2 then
			self.hearts[self.currentHeart].state = 'empty'
			self.hearts[self.currentHeart].animation = self.hearts[self.currentHeart].animations['empty']
			if self.currentHeart - 1 >= 0 then
				self.currentHeart = self.currentHeart - 1
			end
			damage = damage - 1
		else
			-- player is already dead; this shouldn't happen later
			damage = 0
		end
	end
	
	if self.currentHeart < 0 then
		self.currentHeart = 0
	end
	
	if self.health <= 0 then
		-- call death function
		self:die()
	else
		-- *hurt sound*
		if not self.mute then self.sounds['hurt']:play() end
	end
end

function Player:knockback(enemy)
	
	if self.state == 'dying' then return end
	
	if self.x + self.width / 2 < enemy.x + enemy.width / 2 then
		--print("left side")
		self.x = enemy.x - self.width - 2
		self.dx = -250 --150
	elseif self.x + self.width / 2 > enemy.x + enemy.width / 2 then
		--print("right side")
		self.x = enemy.x + enemy.width + 6
		self.dx = 250
	else
		-- inside enemy??
		print("ERROR: Knockback 1")
	end
end

function Player:heal()
	for heart = 0, self.heartContainers - 1, 1 do
		self.hearts[heart].state = 'full'
		self.hearts[heart].animation = self.hearts[heart].animations['full']
		self.currentHeart = heart
	end
	
	self.health = self.heartContainers * 2
end

function Player:die()
	-- OOF
	
	self.dx = 0
	self.dy = -JUMP_VELOCITY
	self.rollInterval = 0
	self.rotation = 0
	self.diving = false
	
	-- set dying state
	self.state = 'dying'
	self.animation = self.animations['dying']
	
	if not self.mute then self.sounds['oof']:play() end
end

-- jumping and block hitting logic
function Player:calculateJumps()
    
    -- if we have negative y velocity (jumping), check if we collide
    -- with any blocks above us
    if self.dy < 0 and self.state ~= 'dying' then
        if self.map:collides(self.map:tileAt(self.x + 3, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width - 4, self.y)) then
            -- reset y velocity
            self.dy = 0

            -- change block to different block
            local playCoin = false
            local playHit = false
            if self.map:tileAt(self.x, self.y).id == JUMP_BLOCK then
				--[[
                self.map:setTile(math.floor(self.x / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                playCoin = true
				self.coins = self.coins + 1
				self.map.churro:get(self.map:tileAt(self.x, self.y).x, self.map:tileAt(self.x, self.y).y)
				--]]
            else
                playHit = true
            end
            if self.map:tileAt(self.x + self.width - 1, self.y).id == JUMP_BLOCK then
				--[[
                self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileWidth) + 1,
                    math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                playCoin = true
				self.coins = self.coins + 1
				self.map.churro:get(self.map:tileAt(self.x + self.width - 1, self.y).x, self.map:tileAt(self.x + self.width - 1, self.y).y)
				--]]
            else
                playHit = true
            end

			if not self.mute then
				if playCoin then
					self.sounds['coin']:play()
				elseif playHit then
					self.sounds['hit']:play()
				end
			end
        end
    end
end

function Player:resetTexture()
	self.xOffset = 8
	self.yOffset = 10
	self.xtraOffset = 0
	self.ytraOffset = 0
	if find_value(self.inventory, 'sword') > -1 then self.swordHitbox:deInit() end
end

-- checks two tiles to our left to see if a collision occurred
function Player:checkLeftCollision()
    if self.dx < 0 then
        -- check if there's a tile directly to the left of us
		
		-- collision at head and not one tile above head and not one tile above midpoint
        if self.map:collides(self.map:tileAt(self.x - 1, self.y + 4)) and
			not self.map:collides(self.map:tileAt(self.x - 1, self.y + 4 - self.height)) and
			not self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height / 2 - self.height)) then
			
			-- if so, reset velocity and position and change state
			self:stopLeftMomentum()
			
			if self.dy > 150 and self.direction == 'left' and love.keyboard.isDown(self.leftButton) and self.diving == false then
				self.state = 'edge'
                self.animation = self.animations['edge']
				if self.y % 16 ~= 0 then
					self.y = math.floor(self.y / 16) * 16 - 4
				end
				self:resetTexture()
			end
			
		-- collision at midpoint and not at one tile above midpoint
		elseif self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height / 2)) and
			not self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height / 2 - self.height)) then
			
			-- if so, reset velocity and position and change state
			self:stopLeftMomentum()
			
			if self.dy > 2 and self.direction == 'left' and love.keyboard.isDown(self.leftButton) and self.diving == false then
				self.state = 'edge'
                self.animation = self.animations['edge']
				if self.y % 16 ~= 0 then
					self.y = math.floor(self.y / 16 + 1) * 16 - 4
				end
				self:resetTexture()
			end
			
		elseif self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            
            -- if so, reset velocity and position and change state
            self:stopLeftMomentum()
		end
	else
		self.lStop = false
    end
end

-- checks two tiles to our right to see if a collision occurred
function Player:checkRightCollision()
    if self.dx > 0 then
        -- check if there's a tile directly to the right of us
		
		-- collision at head but not one tile above head and not one tile above midpoint
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y + 4)) and
			not self.map:collides(self.map:tileAt(self.x + self.width, self.y + 4 - self.height)) and
			not self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height / 2 - self.height)) then
			
			self:stopRightMomentum()
			
			--[ [
			if self.dy > 150 and self.direction == 'right' and love.keyboard.isDown(self.rightButton) and self.diving == false then
				self.state = 'edge'
                self.animation = self.animations['edge']
				if self.y % 16 ~= 0 then
					self.y = math.floor(self.y / 16) * 16 - 4
				end
				self:resetTexture()
				self.dy = 0
			end
			--]]
			
		-- collision at midpoint but not at one tile above midpoint
		elseif self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height / 2)) and
			not self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height / 2 - self.height)) then
			
			self:stopRightMomentum()
			
			if self.dy > 2 and self.direction == 'right' and love.keyboard.isDown(self.rightButton) and self.diving == false then
				self.state = 'edge'
                self.animation = self.animations['edge']
				if self.y % 16 ~= 0 then
					self.y = math.floor(self.y / 16 + 1) * 16 - 4
				end
				self.dy = 0
				self:resetTexture()
			end
			
		-- collision at feet
		elseif self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then

			-- if so, reset velocity and position and change state
			self:stopRightMomentum()
			
			--[[
			if self.dy > 2 and self.direction == 'right' then
				self.state = 'edge'
                self.animation = self.animations['edge']
				self.y = (self.map:tileAt(self.x + self.width, self.y + self.height - 1).y - 1) * self.map.tileHeight -- - self.height
			end
			--]]
		end
	else
		self.rStop = false
    end
end

function Player:stopLeftMomentum()
	self.dx = 0
	self.x = self.map:tileAt(self.x - 1, self.y + 3).x * self.map.tileWidth
	self.lStop = true
end

function Player:stopRightMomentum()
	self.dx = 0
	self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
	self.rStop = true
end

function Player:saveData(file)
	local tabToSave = {}
	tabToSave.name = self.name
	tabToSave.buttons = self.buttons
	tabToSave.heartContainers = self.heartContainers
	tabToSave.inventory = self.inventory
	tabToSave.world = WORLD
	tabToSave.level = LEVEL
	
	--save
	local s = table.show(tabToSave, "loadedhero")
	--print(s)
	local success, message = love.filesystem.write( file .. ".txt", s) -- puts the hero table as lua code table named loadedhero

	if success then
		self.map:displayMessage("Saved.", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound)
	else
		self.map:displayMessage("There was an error. :(", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound)
	end
	--print("Result: " .. tostring(success))
	--print("Error message: " .. tostring(message))
end

function Player:loadData(file)
	--load
	local filename = file .. ".txt"
	if love.filesystem.getInfo(filename) then
		chunk = love.filesystem.load( file .. ".txt" )
		chunk()  -- this runs the code -> makes a table named loadedhero
		
		self.name = loadedhero.name
		self.buttons = loadedhero.buttons
		self.heartContainers = loadedhero.heartContainers
		self.inventory = loadedhero.inventory
		WORLD = loadedhero.world
		LEVEL = loadedhero.level
		LV = 1
		
		self.map:displayMessage("Save file loaded.", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound)
		return true
	else
		print("displaying")
		self.map:displayMessage("This save file is empty.", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound)
		return false
	end
end

function Player:deleteData(file)
	--load
	local filename = file .. ".txt"
	if love.filesystem.getInfo(filename) then
		local success = love.filesystem.remove( file .. ".txt" )
		
		if success then
			self.map:displayMessage("Save file deleted.", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound)
		else
			self.map:displayMessage("There was an error deleting this file.", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound)
		end
	else
		self.map:displayMessage("This save file is already empty.", 0, 0.0166, blackcolor, smallFont, true, true, false, mTalkSound)
	end
end

function Player:handoff()
	local cSubExists = false
	for i, entity in ipairs(entities) do
		if entity.name == "Sub" then
			cSubExists = true

			entity.x = self.x
			entity.y = self.y
			entity.direction = self.direction
			self.cSub = entity
		end
	end

	if not cSubExists then
		local sub = Schnanderson(self.map, self.x, self.y, 'Sub')
		sub.direction = self.direction
		table.insert(entities, sub)
		self.cSub = sub
	end
end

function Player:update(dt)
	
	if self.action == 'available' then
		self:actions(dt)
	end
	
	if self.swordHitbox == nil then self.swordHitbox = Hitbox(self.map) end
	
	-- check for above screen
	if self.y < 0 - self.height + 6 then
		--print("above")
		local tempSub = SUB + 1
		local mapString = ""
		if tempSub ~= 0 then
			mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '_' .. tempSub ..'.lua'
		else
			mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '.lua'
		end
		--print("ms: " .. mapString)
		--print(love.filesystem.getInfo(mapString))
		if love.filesystem.getInfo(mapString) then
			SUB = SUB + 1
			--print("sub " .. SUB)
			self.y = self.map.mapHeightPixels - 40
			self.dy = -JUMP_VELOCITY * 1.5
			Map:reloadMap()
		end
	end
	
	-- check if screen change is necessary
	local previousLV = LV
	if self.x + self.width / 2 < 0 or self.x + self.width / 2 > (map.mapWidth - 1) * 16 then
		-- left
		if self.x + self.width / 2 < 0 then
			LV = LV - 1
			
			local mapString = ""
			if SUB ~= 0 then
				mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '_' .. SUB ..'.lua'
			else
				mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '.lua'
			end
			
			-- check if map file exists (if updated LOVE, then use .getInfo, not .exists)
			-- if it does, load it. If not, load the same map again
			if major == 0 and minor == 10 and revision == 2 then
				if love.filesystem.exists(mapString) then
					loadMap(mapString)
				else
					LV = previousLV
				end
			else
				if love.filesystem.getInfo(mapString) then
					loadMap(mapString)
				else
					LV = previousLV
				end
			end
			
			self.x = (map.mapWidth - 1) * 16 - self.width / 2
			self.map.camX = math.max(0, math.min(self.x - VIRTUAL_WIDTH / 2,
					math.min(self.map.mapWidthPixels - self.map.tileWidth - VIRTUAL_WIDTH, self.x)))
			
		-- right
		elseif self.x + self.width / 2 > (map.mapWidth - 1) * 16 then
			LV = LV + 1
			local mapString = ""
			if SUB ~= 0 then
				mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '_' .. SUB ..'.lua'
			else
				mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '.lua'
			end
			
			-- check if map file exists (if updated LOVE, then use .getInfo, not .exists)
			-- if it does, load it. If not, load the same map again
			if major == 0 and minor == 10 and revision == 2 then
				if love.filesystem.exists(mapString) then
					loadMap(mapString)
				else
					LV = previousLV
				end
			else
				if love.filesystem.getInfo(mapString) then
					loadMap(mapString)
				else
					LV = previousLV
				end
			end
			
			self.x = 0 - self.width / 2
			self.map.camX = math.max(0, math.min(self.x - VIRTUAL_WIDTH / 2,
					math.min(self.map.mapWidthPixels - self.map.tileWidth - VIRTUAL_WIDTH, self.x)))
		end
	end
	
    self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
	
	-- update hearts
	for heart = 0, self.heartContainers - 1, 1 do
		self.hearts[heart]:update(dt, heart)
	end
	
    self.x = self.x + self.dx * dt
	
	if self.map.scrollSpeed then
		if self.x < self.map.camX and self.map.camX ~= 0 then
			self.x = self.map.camX
		elseif self.x + self.width > self.map.camX + VIRTUAL_WIDTH and
			self.map.camX ~= self.map.mapWidthPixels - VIRTUAL_WIDTH - self.map.tileWidth then
			
			self.x = self.map.camX + VIRTUAL_WIDTH - self.width
			
		end
	end

    self:calculateJumps()

    -- apply velocity
    self.y = self.y + self.dy * dt
	
	-- update hitbox
	self.hitbox:changeProperties(self.x + self.hitboxXOffset, self.y + self.hitboxYOffset, self.width - self.hitboxXOffset * 2, self.height - self.hitboxYOffset)
	
end

function Player:render()
    local scaleX

    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

	-- print messages
	if display_diagnostics then
		love.graphics.setFont(smallFont)
		--love.graphics.print("Advenchurros: " .. self.coins, 40, 40)
		love.graphics.print("X: " .. tostring(self.x), VIRTUAL_WIDTH + self.map.camX - 80, 50)
		love.graphics.print("Y: " .. tostring(self.y), VIRTUAL_WIDTH + self.map.camX - 80, 55)
		love.graphics.print("Name: " .. tostring(self.name), VIRTUAL_WIDTH + self.map.camX - 80, 60)
	end
	
	--[[ print inventory
	love.graphics.print("Inventory: ", 40, 40)
	for i, v in ipairs(self.inventory) do
		love.graphics.print(v, 40, 40 + 10 * i)
	end
	--]]
	
	-- draw hearts
	for heart = 0, self.heartContainers - 1, 1 do
		self.hearts[heart]:render(dt)
	end
	
	-- check for cutscene Sub; if he is there do not render player
	local cutsceneSubPresent = false
	for i, entity in ipairs(entities) do
		if entity.name == "Sub" then cutsceneSubPresent = true end
	end
	if not cutsceneSubPresent and not self.hide then
		-- draw sprite with scale factor and offsets
		love.graphics.draw(self.animation.texture, self.currentFrame, math.floor(self.x + self.xOffset),
			math.floor(self.y + self.yOffset), self.rotation, scaleX, 1, self.xOffset + self.xtraOffset, self.yOffset + self.ytraOffset)
	end
	
	--[ [ little rectangle to check x and y values visually
	if find_value (self.inventory, 'sword') > -1 and show_hitboxes then
		self.swordHitbox:render()
	end
	--]]
	
	if show_hitboxes then self.hitbox:render() end
end
