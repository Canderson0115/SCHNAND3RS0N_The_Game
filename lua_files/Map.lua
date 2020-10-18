--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]

require 'lua files/Util'

Map = Class{}

-- mushroom tiles
MUSHROOM_TOP = '^'

-- jump block
JUMP_BLOCK = '!'
JUMP_BLOCK_HIT = '1'

-- a speed to multiply delta time to scroll map; smooth value
local SCROLL_SPEED = 62

-- declaring local variables that will be used only inside map-functions.lua
local tileW, tileH, tileset, quads, tileTable

-- constructor for our map object
function Map:init()

	-- map control buttons
	self.advanceButton = 'space'
	
	self.tileHeight = 16
	self.tileWidth = 16
	
    --self.mapWidth = 60 --27
    --self.mapHeight = 28 --15
	
    -- applies positive Y influence on anything affected
    self.gravity = 600

    -- associate player with map
    self.player = Player(self)
	-- associate churro with map
	self.churro = Churro(self)
	
	--self.sausage = Sausage(self, 8 * self.tileWidth, 12 * self.tileHeight - 4)
	
	self.text = {}
	
	self.completedCutscenes = {}
	
    -- camera offsets
    self.camX = 0
    self.camY = -3

	
	self.sounds = {
		['talk'] = love.audio.newSource('sounds/sfx_menu_move4.wav', 'static'),
		['advance'] = love.audio.newSource('sounds/sfx_menu_move4.wav', 'static'),
		['joelTalk'] = love.audio.newSource('sounds/Joel_talking.mp3', 'static')
	}
	
	self.musicTracks = {
		['cascade'] = love.audio.newSource('music/cascade.mp3', 'static'),
		['tiles'] = love.audio.newSource('music/FloorTiles.mp3', 'static'),
		['8bitTiles'] = love.audio.newSource('music/8BitFloorTiles.mp3', 'static'),
		['defaultDance'] = love.audio.newSource('music/DefaultDance.mp3', 'static')
	}
	
	mTalkSound = self.sounds['talk']
	joelTalkSound = self.sounds['joelTalk']
	treyTalkSound = self.sounds['talk']
	
end

function loadMap(path)
	
	map.isDisplayingMessage = false
	
	if SUB and SUB ~= 0 then
		-- Sub area; change path to include sub number
		if not string.find(path, "_") then
			path = string.gsub(path, ".lua", "_" .. SUB .. ".lua")
		end
		print(path)
		if not love.filesystem.getInfo(path) then
			print("[ERROR] Subscreen Malfunction")
			path = 'maps/World -2/Level 1/lv1.lua'
			SUB = 0
		end
	end
	
	love.filesystem.load(path)() -- attention! extra parenthesis (because reasons)
end

function newMap(tileWidth, tileHeight, tilesetPath, tileString, quadInfo, text, entityText, entityBehaviorsFunction, scrollSpeed, background, bgSpeed, music)

	tileW = tileWidth
	tileH = tileHeight
	tileset = love.graphics.newImage(tilesetPath)

	local tilesetW, tilesetH = tileset:getWidth(), tileset:getHeight()

	quads = {}

	collidable = {}
	
	-- Epic map stuff
	for _,info in ipairs(quadInfo) do
		-- info[1] = the character, info[2] = x, info[3] = y, info[4] = collidable
		quads[info[1]] = love.graphics.newQuad(info[2], info[3], tileW,  tileH, tilesetW, tilesetH)
		
		-- this tile can be bumped
		if info[4] == true then
			table.insert(collidable, info[1])
		end
	end

	-- reset enemies, entities and menus
	enemies = {}
	entities = {}
	if WORLD == 0 or WORLD == -1 then
		map.menuDisplay = true
	else
		map.menuDisplay = false
	end
	
	if scrollSpeed then map.scrollSpeed = scrollSpeed else map.scrollSpeed = nil end
	
	-- sets up text
	map.text = text
	
	if map.text == nil then
		map.text = {}
	end
	if map.entityText == nil then
		map.entityText = {}
	end
	
	local textNumber = 1
	
	tileTable = {}

	local width = #(tileString:match("[^\n]+"))
	
	map.mapWidth = width + 1

	for x = 1, width, 1 do tileTable[x] = {} end

	-- lets us make maps with characters :D
	local rowIndex,columnIndex = 1,1
	for row in tileString:gmatch("[^\n]+") do
		assert(#row == width, 'Map is not aligned: width of row ' .. tostring(rowIndex) .. ' should be ' .. tostring(width) .. ', but it is ' .. tostring(#row))
		columnIndex = 1
		for character in row:gmatch(".") do
			tileTable[columnIndex][rowIndex] = character
			
			local X = (columnIndex - 1) * map.tileWidth
			local Y = (rowIndex - 1) * map.tileHeight
			
			--<<{{ SPECIAL MAP OBJECTS }}>>--
			if character == 't' then
				-- places the y value at the start of the text table
				local tab = map.text[textNumber]
				table.insert(tab, 1, rowIndex)
				-- places the x value in front of the y value so that the table looks like text = { {x, y, {messageData}} }
				table.insert(tab, 1, columnIndex)
				
				local hitbox = Hitbox(map, X, Y, map.tileWidth, map.tileHeight)
				table.insert(tab, hitbox)
				
				local wasHit = false
				table.insert(tab, wasHit)
				
				-- should return { {x, y, {messageData}, hitbox, wasHit} }
				
				textNumber = textNumber + 1
			elseif character == 'J' then
				-- spawn Joel
				local t = nil
				if entityText ~= nil then t = entityText['Joel'] end
				local extraY = 0
				if WORLD == 0 then extraY = -3 end
				local joel = Schnanderson(map, X - 4, Y - 4 + extraY, 'Joel', t, entityBehaviorsFunction)
				table.insert(entities, 1, joel)
				
			elseif character == 'O' then
				-- spawn Colton
				local t = nil
				if entityText ~= nil then t = entityText['Colton'] end
				local extraY = 0
				if WORLD == 0 then extraY = -3 end
				local colton = Schnanderson(map, X - 4, Y - 4 + extraY, 'Colton', t, entityBehaviorsFunction)
				table.insert(entities, 1, colton)
				
			elseif character == 'T' then
				-- spawn Trey
				local t = nil
				if entityText ~= nil then t = entityText['Trey'] end
				local extraY = 0
				if WORLD == 0 then extraY = -3 end
				local trey = Schnanderson(map, X - 8, Y - 3 + extraY, 'Trey', t, entityBehaviorsFunction)
				table.insert(entities, 1, trey)
				
			elseif character == 'W' then
				-- spawn breaking window
				local window = Schnanderson(map, X, Y, 'window')
				table.insert(entities, window)
			
			elseif character == 'L' then
				-- spawn large box
				local window = Schnanderson(map, X, Y, 'box')
				table.insert(entities, window)
				
			elseif character == 'l' then
				-- spawn small box
				local window = Schnanderson(map, X, Y, 'box', nil, nil, 0.5)
				table.insert(entities, window)
				
			elseif character == '&' then
				-- spawn end of level sign
				local window = Schnanderson(map, X, Y, 'sign')
				table.insert(entities, window)
				
			elseif character == 'S' then
				-- spawn cutscene Subscriber
				local extraY = 0
				if WORLD == 0 then extraY = -3 end
				local sub = Schnanderson(map, X - 4, Y - 4 + extraY, 'Sub', {}, entityBehaviorsFunction)
				table.insert(entities, 1, sub)
				
			elseif character == 'A' then
				-- spawn angry vienna
				local sausage = Enemy(map, X - 4, Y - 4, 'angry sausage')
				table.insert(enemies, 1, sausage)
				
			elseif character == '1' then
				-- spawn Vienna Boss
				local sausage = Enemy(map, X - 4, Y - 4, 'sausage boss')
				table.insert(enemies, 1, sausage)
				
			elseif character == '2' then
				-- spawn Pastry Boss
				local pastry = Enemy(map, X - 4, Y - 4, 'pastry boss')
				table.insert(enemies, 1, pastry)
				
			elseif character == 'V' then
				-- spawn van
				local van = Van(map, X, Y, 'start')
				table.insert(entities, van)
			end
			
			columnIndex = columnIndex + 1
		end
		rowIndex = rowIndex + 1
	end
	
	map.mapHeight = rowIndex
	
	if map.menuDisplay then
		map.player.mute = true
		if WORLD == -1 then
			map.menu = Menu(map, 'regular', smallFont, {"Start Game", ":New Game", ":Load Save", "::File 1", "::File 2", "::File 3", ":Delete File", "::Delete File 1", ":::Don't Delete", ":::Yes, delete", "::Delete File 2", ":::Don't Delete", ":::Yes, delete", "::Delete File 3", ":::Don't delete", ":::Yes, delete", "Settings", ":Toggle Mute - Off", ":Set Controls", "Quit Game"})
		elseif WORLD == 0 then
			map.menu = Menu(map, 'regular', smallFont, {"Choose Level", "Settings", ":Toggle Mute - Off", ":Set Controls", "End Game"})
		end
	else
		map.player.mute = false
	end
	
	-- cache width and height of map in pixels
    map.mapWidthPixels = map.mapWidth * map.tileWidth
    map.mapHeightPixels = map.mapHeight * map.tileHeight
	
	-- set up backgrounds
	map.backgrounds = {}
	
	if background ~= nil then
		for i = 0, 1 do
			local speed = bgSpeed
			if bgSpeed then
				speed = bgSpeed
			end
			if i == 0 then
				local bg = Background(map, 0, 0, speed, background)
				table.insert(map.backgrounds, bg)
			elseif i == 1 and speed ~= 0 then
				local bg = Background(map, 1, 0, speed, background)
				table.insert(map.backgrounds, bg)
			end
		end
	end
	
	-- start the background music, assuming that it exists
	if map.musicTracks[music] then
		if not map.musicTracks[music]:isPlaying() then
			for i, value in ipairs(map.musicTracks) do
				value:stop()
			end
			map.music = map.musicTracks[music]
			map.musicTracks[music]:setVolume(0.1)
			map.musicTracks[music]:setLooping(true)
			if not mute then
				map.musicTracks[music]:play()
			end
		end
	else
		map.music = map.musicTracks['cascade']
		if not map.music:isPlaying() then
			for i, value in pairs(map.musicTracks) do
				value:stop()
			end
			map.music:setVolume(0.25)
			map.music:setLooping(true)
			if not mute then
				map.music:play()
			end
		end
	end
	
	local currentScreen = WORLD .. "-" .. LEVEL .. "-" .. LV
	local completed = false
	for i, screen in ipairs(map.completedCutscenes) do
		if screen == currentScreen then
			completed = true
		end
	end
	if completed then
		--print("Already completed at " .. currentScreen)
		map.completedCutscene = true
	else
		map.completedCutscene = false
	end
	map.cutsceneNO = 0
	
end

-- return whether a given tile is collidable
function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT,
        MUSHROOM_TOP, MUSHROOM_BOTTOM
    }

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidable) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:collidesBooster(tile)
	local collidables = {
		MUSHROOM_TOP
	}
	
	for _, v in ipairs(collidables) do
		if tile.id == v then
			return true
		end
	end
end

function Map:displayMessage(message, i, limit, color, font, freeze, continuePressRequired, staysUntilScreenMove, mTalkSound, treyStatus)
	if text_disabled then return end
	
	-- update x position
	self.currentMessageX = 40 + self.camX
	
	if i == 0 then
		self.mInterval = 0
		self.currentMessageY = VIRTUAL_HEIGHT - 27 + self.camY + 3
		self.currentMessage = message
		self.mFreeze = freeze
		self.mColor = color
		self.mFont = font
		self.mTalkSound = mTalkSound
		self.continuePressRequired = continuePressRequired
		self.staysUntilScreenMove = staysUntilScreenMove
		INTERVAL_LIMIT = limit
		self.mPrevLV = LV
		self.mInFreeze = false
		self.mLines = 1
		self.mLineLimitI = 0
		
		if treyStatus and treyStatus ~= 'hidden' then
			self.treyStatus = treyStatus
			self.mTrey = Schnanderson(self, self.currentMessageX - 51, self.currentMessageY - 8, 'treyPhone')
		else
			self.treyStatus = 'hidden'
			self.mTrey = nil
		end
		
		self.prevMessage = message
		
		self.arrow = Arrow(self, 0, -50)
		self.textbox = TextBox(self, self.currentMessageX - 8, self.currentMessageY - 8)
	end
	
	-- check for new line command
	if font:getWidth(string.sub(message, self.mLineLimitI, i)) >= 350 or string.sub(message, i, i + 1) == ">n" then
		if string.sub(message, i, i + 1) == ">n" then
			message = string.gsub(message, ">n", "", 1)
		end
		self.mLines = self.mLines + 1
		if self.mLines > 2 then
			if self.continuePressRequired then
				if self.treyStatus == 'default' then
					self.mTrey.animation = self.mTrey.animations['idle']
				elseif self.treyStatus == 'surprised' then
					self.mTrey.animation = self.mTrey.animations['surprised']
				end
				
				self.mInFreeze = true
			end
		else
			self.mLineLimitI = i
			message = string.sub(message, 1, i) .. "\n" .. string.sub(message, i + 1, -1)
			self.currentMessage = message
		end
	end
	
	self.isDisplayingMessage = true
	
	-- check for inserted pause
	if (string.sub(message, i, i + 1) == ">p" and self.continuePressRequired) or self.mInFreeze then
		message = string.gsub(message, ">p", "", 1)
		self.currentMessage = message
		-- show little arrow to prompt a button being pushed
		self.arrow.x = VIRTUAL_WIDTH - 50 + self.camX
		self.arrow.y = VIRTUAL_HEIGHT - 14 + self.camY + 3
		
		if self.treyStatus == 'default' then
			self.mTrey.animation = self.mTrey.animations['idle']
		elseif self.treyStatus == 'surprised' then
			self.mTrey.animation = self.mTrey.animations['surprised']
		end
		
		if love.keyboard.isDown(self.advanceButton) then
			self.mInFreeze = false
			
			if self.mLines > 2 then
				self.currentMessage = string.sub(message, i, -1)
				self.mLines = 1
				i = 1
				self.arrow.x = -50
				self.arrow.y = 0
				self.mLineLimitI = 0
			end

			if not mute then
				self.sounds['advance']:play()
			end
		else
			self.mInFreeze = true
			if self.treyStatus == 'default' then
				self.mTrey.animation = self.mTrey.animations['idle']
			elseif self.treyStatus == 'surprised' then
				self.mTrey.animation = self.mTrey.animations['surprised']
			end
		end
	elseif string.sub(message, i, i + 1) == ">s" then
		message = string.gsub(message, ">s", "", 1)
		self.currentMessage = message
		self.treyStatus = 'surprised'
	end
	
	-- end of message
	if i == string.len(message) then
		
		if self.continuePressRequired then
			-- show little arrow to prompt a button being pushed
			self.arrow.x = VIRTUAL_WIDTH - 50 + self.camX
			self.arrow.y = VIRTUAL_HEIGHT - 14 + self.camY
			
			if self.treyStatus == 'default' then
				self.mTrey.animation = self.mTrey.animations['idle']
			elseif self.treyStatus == 'surprised' then
				self.mTrey.animation = self.mTrey.animations['surprised']
			end
			
			if love.keyboard.isDown(self.advanceButton) then
				love.keyboard.keysPressed[self.advanceButton] = false
				
				self.isDisplayingMessage = false
				self.mFreeze = false
				
				if not mute then
					self.sounds['advance']:play()
				end

				return 0
			else
				self.mFreeze = true
			end
		elseif staysUntilScreenMove then
			self.mFreeze = false
		else
			self.isDisplayingMessage = false
			self.mFreeze = false

			return 0
		end
	else
		if not self.mInFreeze then
			-- plays sound if the current character is not a space
			if string.sub(self.currentMessage, self.mInterval, self.mInterval) ~= ' ' then
				--mTalkSound:seek(0)
				if mTalkSound ~= nil and not mute then mTalkSound:play() end
			end
			
			-- make Trey talk
			if self.treyStatus == 'default' then
				if self.mTrey.animation ~= self.mTrey.animations['talk'] then
					self.mTrey.animations['talk']:restart()
					self.mTrey.animation = self.mTrey.animations['talk']
				end
			elseif self.treyStatus == 'surprised' then
				if self.mTrey.animation ~= self.mTrey.animations['surprisedTalk'] then
					self.mTrey.animations['surprisedTalk']:restart()
					self.mTrey.animation = self.mTrey.animations['surprisedTalk']
				end
			end

			i = i + 1
		end
	end
	
	return i
end

function Map:reloadMap()
	self.isDisplayingMessage = false
	self.mFreeze = false
	local mapString = ""
	if SUB ~= 0 then
		--print("sub world")
		mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '_' .. SUB ..'.lua'
	else
		--print("overworld")
		mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '.lua'
	end
	if love.filesystem.getInfo(mapString) then
		--print("Pre-load sub: " .. SUB)
		loadMap(mapString)
	else
		WORLD = -2
		LEVEL = 1
		LV = 1
		loadMap('maps/World -2/Level 1/lv1.lua')
		print("You shouldn't be here >:I")
	end
end

function Map:transition()
	fade('toBlack', 0)
	WORLD = 0
	LEVEL = 1
	LV = 1
	self:reloadMap()
	fade('back', 1)
end

function Map:transitionToSave()
	
	if not isFading then fade('toBlack', 1, 'map:savePrompt()') end
	
end

function Map:savePrompt()
	WORLD = 0
	LEVEL = 0
	LV = 1
	self.camX = 0
	self:reloadMap()
	fade('back', 0)
	self.menuDisplay = true
	self.menu = Menu(map, 'regular', smallFont, {"Save", ":File 1", ":File 2", ":File 3", "Don't Save"}, true, 'map:transition()')
end

-- function to update camera offset with delta time
function Map:update(dt)
	
	if DEVMODE then
		if love.keyboard.wasPressed('f') then
			if self.mFreeze then self.mFreeze = false else self.mFreeze = true end
		end
	end
	
	if self.isDisplayingMessage and INTERVAL_STEP then
		self.mInterval = self:displayMessage(self.currentMessage, self.mInterval, INTERVAL_LIMIT, self.mColor,
			self.mFont, self.mFreeze, self.continuePressRequired, self.staysUntilScreenMove, self.mTalkSound, self.treyStatus)
		self.arrow:update(dt)
		self.textbox:update(dt)
		if self.mTrey then self.mTrey:update(dt) end
	end
	
	-- update moving backgrounds
	if self.backgrounds ~= nil then
		for i, bg in ipairs(self.backgrounds) do
			bg:update(dt)
		end
	end
	
	-- in case you're interested in breaking boundaries ;)
	if CAM_CONTROL then
		if love.keyboard.isDown('right') then
			self.camX = self.camX + CAM_SPEED
		elseif love.keyboard.isDown('left') then
			self.camX = self.camX - CAM_SPEED
		end

		if love.keyboard.isDown('up') then
			self.camY = self.camY - CAM_SPEED
		elseif love.keyboard.isDown('down') then
			self.camY = self.camY + CAM_SPEED
		end

		if love.keyboard.isDown('/') then
			self.camX = math.max(0, math.min(self.player.x - VIRTUAL_WIDTH / 2,
					math.min(self.mapWidthPixels - self.tileWidth - VIRTUAL_WIDTH, self.player.x)))

			self.camY = -3
		end
	elseif self.scrollSpeed then
		
		if not self.mFreeze and not self.freezePlayer and self.player.state ~= 'dying' then
			-- check for end of map to avoid scrolling past border
			if self.scrollSpeed > 0 then -- moving right
				if self.camX + VIRTUAL_WIDTH < self.mapWidthPixels - self.tileWidth - 2 then
					self.camX = self.camX + self.scrollSpeed * dt
				else
					self.camX = self.mapWidthPixels - VIRTUAL_WIDTH - self.tileWidth
				end
			else -- moving left
				if self.camX > 2 then
					self.camX = self.camX + self.scrollSpeed * dt
				else
					self.camX = 0
				end
			end
		end
		
	else
		-- keep camera's X coordinate following the player, preventing camera from
		-- scrolling past 0 to the left and the map's width
		self.camX = math.max(0, math.min(self.player.x - VIRTUAL_WIDTH / 2,
				math.min(self.mapWidthPixels - self.tileWidth - VIRTUAL_WIDTH, self.player.x)))
	end
	
	-- check for completed cutscene
	if self.completedCutscene then
		local currentScreen = WORLD .. "-" .. LEVEL .. "-" .. LV
		local completed = false
		for i, screen in ipairs(self.completedCutscenes) do
			if screen == currentScreen then
				completed = true
			end
		end
		if not completed then
			--print("Completed at " .. currentScreen)
			table.insert(self.completedCutscenes, currentScreen)
		end
	end
	
	-- freeze everything if the message needs to
	if not self.mFreeze then

		if not self.freezePlayer then
			self.player:update(dt)
		end
		
		-- check for end of level music
		if self.player.state == 'endLevel' then
			if not self.musicTracks['defaultDance']:isPlaying() then
				self.music:stop()
				print("play dance")
				for i, value in ipairs(self.musicTracks) do
					value:stop()
					print(value)
				end
				self.musicTracks['defaultDance']:setVolume(1)
				self.musicTracks['defaultDance']:setLooping(false)
				if not mute then
					self.musicTracks['defaultDance']:play()
				end
			else
				print("Already playing")
			end
		end

		self.churro:update(dt)

		for index, enemy in ipairs(enemies) do
			if enemy.dead then
				table.remove(enemies, index)
			else
				enemy:update(dt)
			end
		end
		
		for index, entity in ipairs(entities) do
			if entity.dead then
				table.remove(entities, index)
			else
				entity:update(dt)
			end
		end
		
		if self.menuDisplay then
			self.menu:update(dt)
		end
		
		if love.keyboard.wasPressed('i') then
			--self:displayMessage("Use A and D to run. Space is jump. S is crouch, but if you press it while walking, you will roll. You can swing your sword with J. To interact with NPCs, use W. If you have a medkit in your inventory, press H to heal.", 0, 0.0166, blackcolor, smallFont, true, true, true, mTalkSound)
		end

		-- iterate through the text stuff
		for i, value in ipairs(self.text) do
			-- within each node { {x, y, etc.} }
			--					  ^
			for q, value1 in ipairs(value) do
				if q == 4 then
					-- if player collides with text hitbox and has not already seen this message, display the message
					if value1:hitboxCollides(self.player.hitbox) and not value[5] then
						if self.prevMessage == nil then self.prevMessage = "" end
						if (value[3][1] ~= self.prevMessage and not self.isDisplayingMessage) then
							self:displayMessage(value[3][1], value[3][2], value[3][3], value[3][4],
								value[3][5], value[3][6], value[3][7], value[3][8], value[3][9], value[3][10])
							self.text[i][5] = true
						end
					end
				end
			end
		end
		
	else
		for index, entity in ipairs(entities) do
			if entity.isDisplayingMessage then
				entity:update(dt)
			end
		end
	end
	
end

-- gets the tile type at a given pixel coordinate
function Map:tileAt(x, y)
	local X = math.floor(x / self.tileWidth) + 1
	local Y = math.floor(y / self.tileHeight) + 1
	if X < self.mapWidth and Y < self.mapHeight then
		return {
			x = X,
			y = Y,
			id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
		}
	else
		return {
			x = X,
			y = Y,
			id = ' '
		}
	end
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
	if (x < self.mapWidth and x > 0) and (y < self.mapHeight and y > 0) then
		return tileTable[x][y] --[(y - 1) * self.mapWidth + x]
	end
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, id)
	tileTable[x][y] = id
    --self.tiles[(y - 1) * self.mapWidth + x] = id
end

-- renders our map to the screen, to be called by main's render
function Map:render()
	
	if self.backgrounds ~= nil then
		for i, bg in ipairs(self.backgrounds) do
			bg:render()
		end
	end
	
	for columnIndex,column in ipairs(tileTable) do
		for rowIndex,char in ipairs(column) do
			local x,y = (columnIndex-1)*tileW, (rowIndex-1)*tileH
			love.graphics.draw(tileset, quads[ char ] , x, y)
			
			--<<(( SPECIAL MAP OBJECTS ))>>--
			-- set Player's x and y to spawn point if the map is just starting up
			if char == '@' then
				if self.player.x == 0 and self.player.y == -420 then
					self.player.x = x
					self.player.y = y - 4
				end
				self.player.spawnPointX = x
				self.player.spawnPointY = y - 4
			elseif char == '!' then
				self.blockHitBox = Hitbox(self, x, y, self.tileWidth, self.tileHeight)
			elseif char == 's' then
				local sausage = Sausage(self, x, y - 4)
				if table.getn(enemies) == 0 then
					table.insert(enemies, sausage)
				else
					for index, enemy in ipairs(enemies) do
						if (enemy.x == sausage.x and enemy.y == sausage.y) then break end
						if index == table.getn(enemies) and (enemy.x ~= sausage.x and enemy.y ~= sausage.y) then
							table.insert(enemies, sausage)
						end
					end
				end
			end
		end
	end
	
	--[[ shows block's hitbox
	if self.blockHitBox ~= nil then
		self.blockHitBox:render()
	end
	--]]

	if self.isDisplayingMessage then
		love.graphics.setColor(1, 1, 1, 0.8)
		self.textbox:render()
		
		love.graphics.setColor(self.mColor)
		love.graphics.setFont(smallFont)
		love.graphics.print(string.sub(self.currentMessage, 1, self.mInterval), self.currentMessageX, self.currentMessageY)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(smallFont)
		
		self.arrow:render()
		if self.mTrey then self.mTrey:render() end
	end
	
	self.churro:render()
	
	
	for index, enemy in ipairs(enemies) do
		enemy:render()
	end
	
	for index, entity in ipairs(entities) do
		entity:render()
	end
	
	if self.menuDisplay then
		self.menu:render()
	end
	
	self.player:render()
	
end
