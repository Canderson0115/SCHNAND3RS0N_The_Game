--[[
    Represents our enemies in the game, with their own sprites.
]]

Enemy = Class{}

function Enemy:init(map, x, y, name)
	
	self.x = x
	self.y = y
	
	self.dx = 0
	self.dy = 0
	
	self.name = name
	
	self.startPointX = x
	
	self.dead = false
	
	self.map = map
	
	self.terminalVelocity = 50
	
	-- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
	self.state = 'idle'
	
	self.explosionTexture = love.graphics.newImage('graphics/explosion.png')
	
	self.direction = 'right'

	if name == "sausage boss" then

		self.defaultTexture = love.graphics.newImage('graphics/viennaBoss.png')

		self.spawnX = self.x
		self.spawnY = self.y
		
		self.x = -1000
		self.y = self.y - 6 * 16 + 2
		
		self.xOffset = 0
		self.yOffset = 0

		self.width = 94
		self.height = 113
		
		-- initialize variables
		self.hittable = true
		self.canHit = true
		self.health = 1000
		if self.map.scrollSpeed then
			self.walkingSpeed = self.map.scrollSpeed
		else
			self.walkingSpeed = 50
		end
		
		self.meter = Meter(self)
		
		self.meter.animations['emptying'].interval = 0.2
		
		self.tileWidth = 16
		self.tileHeight = 18

		self.animations = {
			['idle'] = Animation({
					texture = self.defaultTexture,
					frames = {
						love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(1 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(2 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(2 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions())
					},
					interval = 0.1
				}),
			['running'] = Animation({
					texture = self.defaultTexture,
					frames = {
						love.graphics.newQuad(2 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(4 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(5 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(6 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(7 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(8 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(9 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					},
					interval = 0.15
				}),
			['dying'] = Animation({
					texture = self.defaultTexture,
					frames = {
						love.graphics.newQuad(0 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(1 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(2 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(2 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(2 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions())
					},
					interval = 0.4
				})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitbox = Hitbox(self.map, self.x + self.xOffset, self.y + self.yOffset, self.width - 20, self.height)
		self.lineOfSight = Hitbox(self.map, self.x + self.width / 2, self.y + self.height / 2, 0, 0)
		self.spawnBox = Hitbox(self.map, self.spawnX, self.spawnY - 16, 32, 32)

		self.changedDirection = false
		
		-- behavior map we can call based on heart state
		self.behaviors = {
			['idle'] = function(dt)
				
				self.dx = 0
				
				if self.spawnBox:hitboxCollides(self.map.player.hitbox) then
					self.state = 'running'
					self.animations['running']:restart()
					self.animation = self.animations['running']
					
					self.x = 0 - self.width
				end

			end,
			['running'] = function(dt)
				
				if self.x == -1000 then self.x = -self.width end
				
				if self.x < self.map.camX then
					self.dx = 100
				else
					self.dx = self.walkingSpeed
				end
				
				if self.hitbox:hitboxCollides(self.map.player.hitbox) then
					self.map.player:hurt(100)
					self.map.player:knockback(self)
				end
			end,
			['chasing'] = function(dt)
				self.searching = false
				self.hittable = true
				self.canHit = true

				if self.x + self.width > self.map.player.x + self.map.player.width then
					self.direction = 'left'
				else
					self.direction = 'right'
				end

				if self.direction == 'right' then
					-- move about
					if self.dx < self.walkingSpeed * 4 then self.dx = self.dx + 5 end
				else
					if self.dx > -self.walkingSpeed * 4 then self.dx = self.dx - 5 end
				end
			end,
			['dying'] = function(dt)
				self.dx = 0
				self.searching = false

				self.hittable = false
				self.canHit = false

				-- die
				if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
					self.dead = true

					--[[ set this tile to air so that self does not instantly respawn
					self.map:setTile(self.x / self.map.tileWidth + 1,
					math.floor((self.y + 4) / self.map.tileHeight + 1), ' ')
					--]]
					--print("Removed at " .. self.x / self.map.tileWidth + 1 .. ", " .. math.floor((self.y + 4) / self.map.tileHeight + 1))
				end
			end
		}
		
	elseif name == "pastry boss" then

		self.defaultTexture = love.graphics.newImage('graphics/pastryBossWalk.png')

		self.spawnX = self.x
		self.spawnY = self.y
		
		self.width = 34
		self.height = 37
		
		self.xOffset = self.width / 2
		self.yOffset = self.height / 2
		
		-- initialize variables
		self.hittable = true
		self.canHit = true
		self.health = 10
		if self.map.scrollSpeed then
			self.walkingSpeed = self.map.scrollSpeed
		else
			self.walkingSpeed = 30
		end
		self.dx = 0
		self.meter = Meter(self)
		
		self.meter.animations['emptying'].interval = 0.2
		
		self.tileWidth = 34
		self.tileHeight = 37

		self.animations = {
			['idle'] = Animation({
					texture = self.defaultTexture,
					frames = {
						love.graphics.newQuad(0 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions())
					}
				}),
			['walking'] = Animation({
					texture = self.defaultTexture,
					frames = {
						love.graphics.newQuad(2 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(3 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(4 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(5 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(6 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(7 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(8 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(9 * self.width, 0, self.width, self.height, self.defaultTexture:getDimensions()),
					},
					interval = 0.15
				})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitbox = Hitbox(self.map, self.x, self.y + 5, self.width, self.height - 3)
		self.lineOfSight = Hitbox(self.map, self.x + self.width / 2, self.y + self.height / 2, 0, 0)

		self.changedDirection = false
		
		-- behavior map we can call based on heart state
		self.behaviors = {
			['idle'] = function(dt)
				
				self.state = 'walking'

			end,
			['walking'] = function(dt)
				
				self:changeAnimation('walking')
				
				self.canFall = true
				
				-- check for player
				if self.hitbox:hitboxCollides(self.map.player.hitbox) then
					self.map.player:hurt(1)
					self.map.player:knockback(self)
				end
				
				if self.direction == 'right' then
					
					self.xOffset = 0
					
					-- move about
					if self.dx < self.walkingSpeed then self.dx = self.dx + 5 end
					
					if self.hitbox:tileCollides('right') then
						-- hit tile on right; turn around
						self.direction = 'left'
						self.dx = 0
					end
				else -- left
					
					self.xOffset = self.width / 3
					
					-- move about
					if self.dx > -self.walkingSpeed then self.dx = self.dx - 5 end
					
					if self.hitbox:tileCollides('left') then
						-- hit tile on right; turn around
						self.direction = 'right'
						self.dx = 0
					end
				end
				
			end,
			['running'] = function(dt)
				
				if self.x == -1000 then self.x = -self.width end
				
				if self.x < self.map.camX then
					self.dx = 100
				else
					self.dx = self.walkingSpeed
				end
				
				if self.hitbox:hitboxCollides(self.map.player.hitbox) then
					self.map.player:hurt(100)
					self.map.player:knockback(self)
				end
			end,
			['chasing'] = function(dt)
				self.searching = false
				self.hittable = true
				self.canHit = true

				if self.x + self.width > self.map.player.x + self.map.player.width then
					self.direction = 'left'
				else
					self.direction = 'right'
				end

				if self.direction == 'right' then
					-- move about
					if self.dx < self.walkingSpeed * 4 then self.dx = self.dx + 5 end
				else
					if self.dx > -self.walkingSpeed * 4 then self.dx = self.dx - 5 end
				end
			end,
			['dying'] = function(dt)
				self.dx = 0
				self.searching = false

				self.hittable = false
				self.canHit = false

				-- die
				if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
					self.dead = true

					--[[ set this tile to air so that self does not instantly respawn
					self.map:setTile(self.x / self.map.tileWidth + 1,
					math.floor((self.y + 4) / self.map.tileHeight + 1), ' ')
					--]]
					--print("Removed at " .. self.x / self.map.tileWidth + 1 .. ", " .. math.floor((self.y + 4) / self.map.tileHeight + 1))
				end
			end
		}
		
	else -- angry vienna
		self.defaultTexture = love.graphics.newImage('graphics/sausage.png')
		self.movingTexture = love.graphics.newImage('graphics/Angry_Vienna.png')

		self.width = 8
		self.height = 18
		
		self.xOffset = self.width / 2
		self.yOffset = self.height / 2
		
		-- initialize variables
		self.hittable = true
		self.canHit = true
		self.health = 1
		self.walkingSpeed = 40
		self.dx = 0
		self.meter = Meter(self)
		
		self.tileWidth = 16
		self.tileHeight = 18

		self.animations = {
			['idle'] = Animation({
					texture = self.defaultTexture,
					frames = {
						love.graphics.newQuad(0 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(1 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(2 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(3 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(4 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(5 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(6 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions())
					},
					interval = 0.1
				}),
			['patrolling'] = Animation({
					texture = self.movingTexture,
					frames = {
						love.graphics.newQuad(0 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(1 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(2 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(3 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(4 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(5 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(6 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(0 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(1 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(2 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(3 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(4 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(5 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions()),
						love.graphics.newQuad(6 * self.tileWidth, 0, self.tileWidth, self.tileHeight, self.movingTexture:getDimensions())
					},
					interval = 0.1
				}),
			['detecting'] = Animation({
					texture = self.movingTexture,
					frames = {
						love.graphics.newQuad(0 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(3 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(0 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(3 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(0 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(3 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(3 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions())
					},
					interval = 0.3
				}),
			['dying'] = Animation({
					texture = self.defaultTexture,
					frames = {
						love.graphics.newQuad(0 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(1 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(2 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(2 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions()),
						love.graphics.newQuad(2 * self.tileWidth, 2, self.tileWidth, self.tileHeight, self.defaultTexture:getDimensions())
					},
					interval = 0.4
				})
		}

		-- initialize animation and current frame we should render
		self.animation = self.animations['idle']
		self.currentFrame = self.animation:getCurrentFrame()

		self.hitbox = Hitbox(self.map, self.x + self.xOffset, self.y + self.yOffset, self.width, self.height)
		self.lineOfSight = Hitbox(self.map, self.x + self.width / 2, self.y + self.height / 2, 0, 0)

		self.changedDirection = false
		
		-- behavior map we can call based on heart state
		self.behaviors = {
			['idle'] = function(dt)
				
				self.dx = 0
				
				self.state = 'patrolling'
				self.animations['patrolling']:restart()
				self.animation = self.animations['patrolling']
			end,
			['patrolling'] = function(dt)
				self.hittable = true
				self.canHit = true
				
				-- check for line of sight detection
				self.searching = true
				
				if self.direction == 'right' then
					-- change line of sight
					local startpoint = self.x
					local endpoint = self.x + VIRTUAL_WIDTH / 2
					local done = false
					self.lineOfSight:changeProperties(self.x + self.width / 2, self.y + 5, startpoint - self.x, 8)
					while not done do
						if not self.lineOfSight:tileCollides('right') and startpoint < endpoint then
							--print("LOS width: " .. self.lineOfSight.width)
							--print("collides: " .. tostring(self.lineOfSight:tileCollides('right')))
							--print("tile at: " .. tostring(self.map:collides(self.map:tileAt(self.lineOfSight.x + self.lineOfSight.width, self.lineOfSight.y))))
							startpoint = startpoint + 2
							self.lineOfSight:changeProperties(self.x + self.width / 2, self.y + 5, startpoint - self.x, 8)
						else
							endpoint = startpoint
							done = true
						end
					end
					self.lineOfSight:changeProperties(self.x + self.width / 2, self.y + 5, endpoint - self.x, 8)
					
					-- move about
					if self.dx < self.walkingSpeed then self.dx = self.dx + 5 end
					
					if self.hitbox:tileCollides('right') then
						-- hit tile on right; turn around
						self.direction = 'left'
						self.dx = 0
					end
				else -- left
					local startpoint = self.x
					local endpoint = self.x - VIRTUAL_WIDTH / 2
					local done = false
					self.lineOfSight:changeProperties(startpoint, self.y + 5, self.x + self.width / 2 - startpoint, 8)
					while not done do
						if not self.lineOfSight:tileCollides('left') and startpoint > endpoint then
							--print("LOS width: " .. self.lineOfSight.width)
							--print("collides: " .. tostring(self.lineOfSight:tileCollides('right')))
							--print("tile at: " .. tostring(self.map:collides(self.map:tileAt(self.lineOfSight.x + self.lineOfSight.width, self.lineOfSight.y))))
							startpoint = startpoint - 2
							self.lineOfSight:changeProperties(startpoint, self.y + 5, self.x + self.width / 2 - startpoint, 8)
						else
							endpoint = startpoint
							done = true
						end
					end
					self.lineOfSight:changeProperties(endpoint, self.y + 5, self.x + self.width / 2 - endpoint, 8)
					
					if self.dx > -self.walkingSpeed then self.dx = self.dx - 5 end
					
					if self.hitbox:tileCollides('left') then
						self.direction = 'right'
						self.dx = 0
					end
				end
				
				
				--[ [
				if self.direction == 'right' then
					if self.x >= self.startPointX + 35 then self.direction = 'left' end
				else
					if self.x <= self.startPointX - 35 then self.direction = 'right' end
				end
				--]]
				
			end,
			['detecting'] = function(dt)
				self.dx = 0
				self.searching = true
			end,
			['chasing'] = function(dt)
				self.searching = false
				self.hittable = true
				self.canHit = true
				
				if self.x + self.width > self.map.player.x + self.map.player.width then
					self.direction = 'left'
				else
					self.direction = 'right'
				end
				
				if self.direction == 'right' then
					-- move about
					if self.dx < self.walkingSpeed * 4 then self.dx = self.dx + 7 end
					if self.hitbox:tileCollides('right') then
						-- hit tile on right; turn around
						self.dx = 0
						self.state = 'detecting'
					elseif self.hitbox:tileCollides('left') then
						self.dx = self.walkingSpeed
					end
				else
					if self.dx > -self.walkingSpeed * 4 then self.dx = self.dx - 7 end
					if self.hitbox:tileCollides('left') then
						self.dx = 0
						self.state = 'detecting'
					elseif self.hitbox:tileCollides('right') then
						self.dx = -self.walkingSpeed
					end
				end
			end,
			['dying'] = function(dt)
				self.dx = 0
				self.searching = false
				self.hittable = false
				self.canHit = false
				
				-- die
				if self.animation:getCurrentFrameNumber() == table.getn(self.animation.frames) - 1 then
					self.dead = true

					--[[ set this tile to air so that self does not instantly respawn
					self.map:setTile(self.x / self.map.tileWidth + 1,
						math.floor((self.y + 4) / self.map.tileHeight + 1), ' ')
					--]]
					--print("Removed at " .. self.x / self.map.tileWidth + 1 .. ", " .. math.floor((self.y + 4) / self.map.tileHeight + 1))
				end
			end
		}
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

function Enemy:checkForPlayer(damage)
	-- checks if self hits player
	if self.hitbox:hitboxCollides(self.map.player.hitbox) then
		-- hit player, cause player minor damage
		self.map.player:hurt(damage)
		self.map.player:knockback(self)
	end
end

function Enemy:checkForPlayerSword(damage)
	-- check for player's sword attack
	if self.hitbox:hitboxCollides(self.map.player.swordHitbox) then
		-- been hit by sword, take damage
		self.health = self.health - damage
		if self.health <= 0 then
			-- health has dropped below 0; time to die
			self.state = 'dying'
			self.animations['dying']:restart()
			self.animation = self.animations['dying']
		end
	end
end

function Enemy:checkForPlayerInSight()
	if self.lineOfSight:hitboxCollides(self.map.player.hitbox) then
		if self.state == 'patrolling' then
			-- seeing player
			self.state = 'detecting'
			self.animations['detecting']:restart()
			self.animation = self.animations['detecting']

			self.meter.state = 'filling'
			self.meter.animations['filling']:restart()
			self.meter.animation = self.meter.animations['filling']
		end
	else
		if self.state == 'detecting' then
			self.state = 'patrolling'
			self.animations['patrolling']:restart()
			self.animation = self.animations['patrolling']
			
			self.meter.state = 'emptying'
			self.meter.animations['emptying']:restart()
			self.meter.animation = self.meter.animations['emptying']
		end
	end
end

function Enemy:changeAnimation(anim)
	if self.animation ~= self.animations[anim] then
		self.animations[anim]:restart()
		self.animation = self.animations[anim]
	end
end

function Enemy:updateGravity(dt)
	-- check if there's not a tiles directly beneath enemy
	if not self.map:collides(self.map:tileAt(self.x + self.xOffset, self.y + self.height + 2)) and
		not self.map:collides(self.map:tileAt(self.x + self.width / 2, self.y + self.height + 2)) and
		not self.map:collides(self.map:tileAt(self.x + self.width - self.xOffset, self.y + self.height + 2)) then
		-- no ground under enemy
		
		-- apply map's gravity before y velocity
		if self.dy < self.terminalVelocity then
			self.dy = self.dy + self.map.gravity * dt
		elseif self.dy > self.terminalVelocity then
			self.dy = self.terminalVelocity
		end
		
	else -- ground is under enemy
		self.y = self.map:tileAt(self.x + self.width / 2, 
			self.y + self.height + 2).y * self.map.tileHeight - self.map.tileHeight - self.height - 2
		self.dy = 0
	end
end

function Enemy:update(dt)
	-- update hitbox
	self.hitbox:changeProperties(self.x, self.y + 5, self.width, self.height - 3)
	
	if self.canHit then self:checkForPlayer(1) end
	if self.hittable then self:checkForPlayerSword(1) end
	if self.searching then self:checkForPlayerInSight() end
	if self.canFall then self:updateGravity(dt) end
	
	self.x = self.x + self.dx * dt
	self.y = self.y + self.dy * dt
	
	self.behaviors[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
	
	if self.state ~= 'dying' then
		self.meter:update(dt)
	else
		self.meter.showing = false
	end
end

function Enemy:render()
	if self.direction == 'right' then
        self.scaleX = 1
		self.xOffsetFactor = 2
    else
        self.scaleX = -1
		self.xOffsetFactor = 2
    end
	
	local xOffset = 0 --self.width / 2
	local yOffset = 0 --self.height / 2
	-- draw sprite
    love.graphics.draw(self.animation.texture, self.currentFrame, math.floor(self.x + self.xOffset),
        math.floor(self.y + self.yOffset + 2), 0, self.scaleX, 1, self.xOffset * self.xOffsetFactor, self.yOffset)
	
	if show_hitboxes then
		self.hitbox:render()
		self.lineOfSight:render()
	end
	
	if self.meter.showing then self.meter:render() end
end
