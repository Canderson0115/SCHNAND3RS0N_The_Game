-- Represents the menus that appear in the game

Menu = Class{}

-- Represents the nodes within a given menu's table
MenuNode = Class{}
function MenuNode:init(name, parent)
	self.name = name
	self.parent = parent
	self.depth = 0
end

function Menu:init(map, menuType, font, options, freezePlayer, f, title, cursorUp, cursorDown, advance, returnButton)
	
	-- initialize all variables
	self.map = map
	self.type = menuType
	self.font = font
	self.cursorNO = 1
	self.chose = false
	self.options = options
	self.menus = {}
	self.map.freezePlayer = freezePlayer
	self.doWhenComplete = f
	
	if cursorUp ~= nil then
		self.up = cursorUp
		self.down = cursorDown
		self.advance = advance
		self.returnButton = returnButton
	else
		self.up = 'w'
		self.down = 's'
		self.advance = 'space'
		self.returnButton = 'a'
	end
	
	
	local rootNode = MenuNode("root")
	local parent = MenuNode("no name", "root")
	local prevNode = parent
	
	for i, value in ipairs(options) do
		
		local node = MenuNode("no name", "root")
		
		if value == "Choose Level" then
			local additional = 0
			for p = 1, 10 do
				if love.filesystem.getInfo('maps/World ' .. p) then
					table.insert(options, i + p + additional, ":World " .. p)
					--print("Inserted World " .. p .. " at " .. i + p + additional)
					for q = 1, 10 do
						--print('maps/World ' .. p .. '/Level ' .. q .. ':')
						if love.filesystem.getInfo('maps/World ' .. p .. '/Level ' .. q) then
							--print("Exists")
							table.insert(options, i + p + q + additional, "::Level " .. q)
							--print("Inserted Level " .. q .. " at " .. i + p + q + additional)
							--additional = additional + 1
						else
							--print("Doesn't exist")
						end
					end
				end
			end
		end
		
		--https://www.lua.org/pil/20.1.html
		--https://www.lua.org/pil/20.html
		
		-- string.find looks for a character in a string and returns the starting and ending indeces where it was found
		local j, p = string.find(value, ":")
		
		if j == nil and p == nil then
			-- this node is in the root
			
			node.name = value
			node.parent = rootNode
			node.depth = 0
			
			--print(node.name .. " is a root item")
			
			-- prevNode allows for navigation
			prevNode = node
			
		else
			--[ [ found a submenu
			
			-- count number of times : shows up
			local valueWithoutMarker, count = string.gsub(value, ":", "")
			
			--print(valueWithoutMarker .. " is " .. count .. " deep.")
			
			node.name = valueWithoutMarker
			node.depth = count
			
			if node.depth > prevNode.depth then
				-- previous node must be parent to this one
				node.parent = prevNode
			elseif node.depth == prevNode.depth then
				-- previous node has the same parent to this one
				node.parent = prevNode.parent
			elseif node.depth < prevNode.depth then
				-- previous node is not directly related to this one
				while node.depth <= prevNode.depth do
					-- go back in the nodes until you find current node's parent
					prevNode = prevNode.parent
				end
				node.parent = prevNode
			end
			--print(node.name .. "'s parent is " .. node.parent.name)
			
			prevNode = node
				
		end
		
		-- insert completed node into the menus table
		table.insert(self.menus, node)
			
	end
	
	self:changeCurrentMenu(rootNode)
	
end

function Menu:changeCurrentMenu(parentNode)
	
	-- set up table
	local tempMenu = {}
	for i, value in ipairs(self.menus) do
		if value.parent.name == parentNode.name then
			table.insert(tempMenu, value)
		end
	end
	if table.getn(tempMenu) > 0 then
		self.currentMenu = tempMenu
		self.cursorNO = 1
	else
		-- do whatever function is associated with this item.
		--print(parentName .. " has no associated menu.")
		self:doFunction(parentNode)
	end
	
	-- make menu
	
	if self.type == 'y/n' then
		-- do stuff
	else -- regular type
		
		-- gets max width of the options
		local width = 0
		for i, node in ipairs(self.currentMenu) do
			value = node.name
			if self.font:getWidth(value) > width then width = self.font:getWidth(value) end
		end
		
		-- width of options plus one extra character space on either side
		self.characterWidth = self.font:getWidth(string.sub(self.currentMenu[1].name, 1, 1)) * 2
		self.width = width + (self.characterWidth * 2)
		
		-- height of each option multiplied by the number of options times two (so that we can skip a line)
		-- plus one line above and below
		self.characterHeight = self.font:getHeight(self.currentMenu[1].name)
		self.height = self.characterHeight * ((table.getn(self.currentMenu) * 2) + 1)
		
		self.x = VIRTUAL_WIDTH / 2 + self.map.camX - self.width / 2
		if WORLD ~= -1 then
			self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
		else
			self.y = VIRTUAL_HEIGHT / 1.45
		end
		
	end
end

function Menu:changeCurrentValueNameTo(name)
	self.currentMenu[self.cursorNO].name = name
end

function Menu:update(dt)
	if not self.gettingInput then

		if love.keyboard.wasPressed(self.advance) then
			if not self.changingControls then
				-- advance to new menu
				self:changeCurrentMenu(self.currentMenu[self.cursorNO])
			else
				self:changeControlsUpdate(self.currentMenu[self.cursorNO].name)
			end
		elseif love.keyboard.wasPressed(self.returnButton) then
			if not self.changingControls then
				-- go back to previous menu
				if self.currentMenu[1].parent.name ~= "root" then
					self:changeCurrentMenu(self.currentMenu[1].parent.parent)
				end
			end
		elseif love.keyboard.wasPressed('escape') and self.changingControls then
			self.changingControls = false
			self:changeCurrentMenu(MenuNode("Settings", "root"))
		end

		if love.keyboard.wasPressed(self.up) then
			if (not self.changingControls and self.cursorNO > 1) or (self.changingControls and self.cursorNO > 2) then
				self.cursorNO = self.cursorNO - 1
			else
				self.cursorNO = table.getn(self.currentMenu)
			end
		elseif love.keyboard.wasPressed(self.down) then
			if self.cursorNO < table.getn(self.currentMenu) then
				self.cursorNO = self.cursorNO + 1
			else
				local additional = 0
				if self.changingControls then additional = 1 end
				self.cursorNO = 1 + additional
			end
		end

	else -- getting input
		
		self.x = VIRTUAL_WIDTH / 2 + self.map.camX - self.width / 2
		
	end
end

function Menu:render()
	if self.x ~= nil then
		--[ [ v1.0 draws rectangle
		love.graphics.setColor(whitecolor)
		love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
		love.graphics.setColor(blackcolor)
		love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
		
		-- draws items in the current menu
		for i, value in ipairs(self.currentMenu) do
			love.graphics.print(value.name, self.x + self.characterWidth, self.y + (self.characterHeight * ((i - 0.5) * 2)))
		end
		
		-- cursor
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.rectangle('line', self.x + self.characterWidth - 2, self.y + (self.characterHeight * ((self.cursorNO - 0.5) * 2)) - 1, self.width - self.characterWidth * 2 + 3, self.characterHeight + 2)
		
		love.graphics.setColor(whitecolor)
		--]]
	end
end

function Menu:changeControlsUpdate(name)
	
end

-- holds all menu functions
function Menu:doFunction(node)
	--print("received " .. node.name)
	
	local doPrint = true
	if node.name == "End Game" then
		is_playing = false
	elseif node.name == "Toggle Mute - Off" then
		self:changeCurrentValueNameTo("Toggle Mute - On")
		mute = true
	elseif node.name == "Toggle Mute - On" then
		self:changeCurrentValueNameTo("Toggle Mute - Off")
		mute = false
		self.map.music:play()
	elseif node.name == "Set Controls" then
		self.changingControls = true
		local tempMenu = {"Press Escape to Cancel:", "Jump:", "Right:", "Left:", "Crouch/Roll:", "Attack/Item 1:", "Item 2:", "Advance Button:", "Return Button:"}
		self.currentMenu = {}
		for i, value in ipairs(tempMenu) do
			local s = string.gsub(value, ":", "")
			local node = MenuNode(s, "root")
			table.insert(self.currentMenu, node)
		end
	elseif string.find(node.name, "Level") then
		WORLD = tonumber(string.sub(node.parent.name, -1, -1))
		LEVEL = tonumber(string.sub(node.name, -1, -1))
		
		if DEVMODE and love.keyboard.isDown('0') then
			local done
			LV = 1
			while not done do
				local mapString = "maps/World " .. WORLD .. "/Level " .. LEVEL .. "/lv" .. LV .. ".lua"
				if love.filesystem.getInfo(mapString) then
					LV = LV + 1
				else
					LV = LV - 1
					done = true
				end
			end
		else
			LV = 1
		end
		local mapString = "maps/World " .. WORLD .. "/Level " .. LEVEL .. "/lv" .. LV .. ".lua"
		map.player.x = 0
		map.player.y = -420
		loadMap(mapString)
	elseif node.name == "Cancel" then
		self.map.freezePlayer = false
		self.map.menuDisplay = false
	elseif node.name == "Don't Save" then
		map.menuDisplay = false
		if self.doWhenComplete then assert(loadstring(self.doWhenComplete .. ";"),
				[[Looks like that menu command was not real. Sorry! ;)]])() end
	elseif node.parent.name == "Save" then
		self.map.player:saveData(node.name)
		self.map.freezePlayer = false
		self.map.menuDisplay = false
		if self.doWhenComplete then
			print("Doing function: " .. self.doWhenComplete)
			assert(loadstring(self.doWhenComplete .. ";"),
				[[Looks like that menu command was not real. Sorry! ;)]])()
		else
			print("whoopsie")
		end
	elseif node.parent.name == "Load" then
		self.map.player:loadData(node.name)
		self.map.freezePlayer = false
		self.map.menuDisplay = false
	elseif node.parent.name == "Load Save" then
		local success = self.map.player:loadData(node.name)
		if success then
			self.map.player:set0()
			self.map:reloadMap()
		else
			self:changeCurrentMenu(node.parent.parent)
		end
	elseif node.parent.parent.name == "Delete File" then
		if node.name == "Yes, delete" then
			local s = string.sub(node.parent.name, 8, -1)
			self.map.player:deleteData(s)
		end
		if WORLD == -1 then
			self:changeCurrentMenu(node.parent.parent.parent)
		else
			self.map.freezePlayer = false
			self.map.menuDisplay = false
		end
	elseif node.parent.name == "Start Game" then
		receivingText = true
		commandText = "|"
		self.map.menuDisplay = false
	else
		doPrint = false
	end
	
	if doPrint then
		--print("Doing function of " .. name)
	else
		print("ERROR 1: " .. node.name .. " has no associated function.")
	end
end
