--[[
	______________________
	
	Schnand3rs0n: The Game
			0.0.9

	 By the Schnand3rs0n 
	  Development Team

		October	2020
	______________________

	Expanded from Super Mario Bros. Demo CS50 by Colton Ogden (who gave Original Credit to Nintendo)

	Maps adapted from Kikito's Love Tile Tutorial
	https://github.com/kikito/love-tile-tutorial/wiki

	Started January 2020

]]

--[[

	Instructions on using Dev Tools

	1. Activate DEV MODE by pausing with ESCAPE, holding 1 and 5, and pressing N
	2. Open console by pressing ` on the top left of keyboard
	3. Enter code to be executed and press enter

	Some commands:
	WORLD = X (put in a world number: 0 is level select, -1 is test world)
	CHEATS = true
	CAM_CONTROL = true (enables camera movement with arrow keys)

--]]

--[[
	Run ~/../../Applications/love.app/Contents/MacOS/love ~/Desktop/Code/Schnandy/
	on Mac Terminal to see printed messages.
	(development only)
]]

Class = require 'lua files/class'
push = require 'lua files/push'

require 'lua files/Animation'
require 'lua files/Table'

require 'lua files/Map'
require 'lua files/Player'
require 'lua files/Churro'
require 'lua files/Heart'
require 'lua files/Hitbox'
require 'lua files/Sausage'
require 'lua files/Arrow'
require 'lua files/TextBox'
require 'lua files/Schnandy'
require 'lua files/Menu'
require 'lua files/Background'
require 'lua files/van'
require 'lua files/Enemy'
require 'lua files/Meter'

-- close resolution to NES but 16:9
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- actual window resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- seed RNG
math.randomseed(os.time())

-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')

-- an object to contain our map data
map = Map()

-- starting map
WORLD = -1
LEVEL = 1
LV = 1
SUB = 0

DEVMODE = false
CHEATS = false

-- in case you're interested in breaking boundaries ;)
CAM_CONTROL = false
CAM_SPEED = 10

mute = false

-- performs initialization of all objects and data needed by program
function love.load()

	-- gets current love version
	major, minor, revision, codename = love.getVersion()
	
	
	-- FONTS --
    -- sets up a different, better-looking retro font as our default
    love.graphics.setFont(love.graphics.newFont('fonts/04B_03__.TTF', 8))
	smallFont = love.graphics.newFont('fonts/04B_03__.TTF', 8)
	sansFont = love.graphics.newFont('fonts/sans-undertale.ttf', 16)
	titleFont = love.graphics.newFont('fonts/botsmatic.ttf', 16)
	
	-- sets up a few useful colors
	whitecolor = {1, 1, 1, 1}
	blackcolor = {0, 0, 0, 1}
	redcolor = {1, 0, 0, 1}
	greencolor = {0.1, 1, 0.1, 1}
	purplecolor = {0.8, 0, 1, 1}
	
	-- sets up alpha value to allow fading
	alpha = 0

    -- sets up virtual screen resolution for an authentic retro feel
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })

    love.window.setTitle('Schnand3rs0n The Game')
	
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
	love.keyboard.textInput = {}
	
	is_playing = true
	do_step = false
	display_FPS = false
	display_diagnostics = false
	show_hitboxes = false
	text_disabled = false
	
	local mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '.lua'
	if love.filesystem.getInfo(mapString) then
		loadMap(mapString)
	else
		WORLD = -2
		LEVEL = 1
		LV = 1
		loadMap('maps/World -2/Level 1/lv1.lua')
		print("You shouldn't be here >:I")
	end
	
	commandText = ''
	
	CURRENT_DT = 0
	INTERVAL = 0
	INTERVAL_STEP = false
	INTERVAL_LIMIT = 0.0166
end

-- called whenever window is resized
function love.resize(w, h)
    push:resize(w, h)
end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is pressed
function love.keypressed(key)
	
    if key == 'escape' then
		is_playing = false
	elseif key == 'm' and not receivingText then
		if mute == false then
			mute = true
		else
			mute = false
		end
	end
	
	if receivingText then
		if key == 'enter' or key == 'return' then 

			commandText = string.gsub(commandText, '>', '')
			commandText = string.gsub(commandText, '|', '')

			print("Final message: " .. commandText)

			if WORLD ~= -1 then
				prevCommand = commandText

				if commandText ~= "" then
					assert(loadstring(commandText .. "; print('Command completed: ' .. commandText)"),
						[[Sorry, whatever you just typed in the Command Terminal is not a real function.
						You will have to restart the game. I hope you've saved recently! ;)]])()
				end
			else -- Title screen, entering name
				if commandText == "" then commandText = "Subscriber" end
				print("Name is " .. commandText)
				map.player.name = commandText
				WORLD = 0
				map:transition()
			end

			receivingText = false
		elseif key == 'delete' or key == 'backspace' then
			commandText = string.gsub(commandText, '|', '')

			commandText = string.sub(commandText, 1, -2)

			commandText = commandText .. '|'
		elseif key == 'up' and prevCommand then
			commandText = ">" .. prevCommand
		end
	end
	if DEVMODE then
		if not receivingText then
			if key == 'o' then
				do_step = true
			elseif key == 'p' then
				if is_playing then
					is_playing = false
				else
					is_playing = true
				end
			elseif key == '`' then
				receivingText = true
				commandText = '>'
				--print("Start message")
			end
		end
	end

    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

--[[ sleep function; fails to launch game sometimes
local clock = os.clock
function sleep(n)  -- seconds
	local t0 = clock()
	while clock() - t0 <= n do 
		print("waiting")
	end
end
--]]

function love.textinput(t)
	if receivingText and t ~= '`' then
		commandText = string.gsub(commandText, '|', '')
		
		if commandText == "" and t == " " then
			-- do nothing; you can't start your name with a space.
		else
			if string.len(commandText) < 10 or WORLD ~= -1 then
				commandText = commandText .. t
			end
		end
		
		commandText = commandText .. '|'
		--print("Command text: " .. commandText)
	end
	
	love.keyboard.textInput = love.keyboard.textInput .. t
end

-- called every frame, with dt passed in as delta in time since last frame
function love.update(dt)

	--[[
	if WORLD ~= prevWORLD or LEVEL ~= prevLEVEL then
		local mapString = 'maps/World ' .. WORLD .. '/Level ' .. LEVEL .. '/lv' .. LV .. '.lua'
		if love.filesystem.getInfo(mapString) then
			loadMap(mapString)
		end
	end
	--]]
	
	prevWORLD = WORLD
	prevLEVEL = LEVEL
	
    if (is_playing or do_step) and (not too_slow or override_slow) then
        do_step = false
		
		map:update(dt)
		
		-- update fade
		if isFading then

			fadeTimer = fadeTimer + dt

			if fadeMode == 'toBlack' then
				alpha = fadeTimer / fadeLimit
				if alpha >= 1 then
					alpha = 1
					isFading = false
					doneFading = true
					--print("done fading to black")
					if doWhenComplete then assert(loadstring(doWhenComplete .. ";"),
						[[Looks like that fade command was not real. Sorry! ;)]])() end
				end
			else
				alpha = 1 - (fadeTimer / fadeLimit)
				if alpha <= 0 then
					alpha = 0
					isFading = false
					doneFading = true
					--print("done fading back")
					if doWhenComplete then assert(loadstring(doWhenComplete .. ";"),
						[[Looks like that fade command was not real. Sorry! ;)]])() end
				end
			end

		end

		-- reset all keys pressed and released this frame
		love.keyboard.keysPressed = {}
		love.keyboard.keysReleased = {}
		love.keyboard.textInput = ""
	else
		if love.keyboard.wasPressed('y') then
			love.event.quit()
		elseif love.keyboard.wasPressed('n') then
			is_playing = true
			if love.keyboard.isDown('1') and love.keyboard.isDown('5') then
				DEVMODE = true
			else
				DEVMODE = false
			end
		end
	end
	
	if too_slow then
		if love.keyboard.isDown('6') and love.keyboard.isDown('9') then
			override_slow = true
		end
	end
	
	if INTERVAL_LIMIT == nil then INTERVAL_LIMIT = 0.0166 end
	
	CURRENT_DT = dt
	if INTERVAL >= INTERVAL_LIMIT then
		INTERVAL = dt
		INTERVAL_STEP = true
	else
		INTERVAL = INTERVAL + dt
		INTERVAL_STEP = false
	end
	
	if mute then
		love.audio.stop()
	end
end

-- called each frame, used to render to the screen
function love.draw()
    -- begin virtual resolution drawing
    push:apply('start')

    -- clear screen using Mario background blue
	if major == 0 and minor == 10 and revision == 2 then
    	love.graphics.clear(108, 140, 255, 255)
	else
		love.graphics.clear(108 / 255, 140 / 255, 255 / 255, 255 / 255)
    end
	
    -- renders our map object onto the screen
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    map:render()
	--drawMap()

	if receivingText then
		if WORLD == -1 then
			love.graphics.setColor(whitecolor)
			love.graphics.printf(commandText, map.camX, 11 + 170, VIRTUAL_WIDTH, 'center')
			love.graphics.printf("Enter the subscriber's name:", map.camX, 3 + 170, VIRTUAL_WIDTH, 'center')
			love.graphics.setColor(1, 1, 1, 1)
		else
			love.graphics.setColor(0, 1, 0, 1)
			love.graphics.print(commandText, map.camX, 11 + map.camY)
			love.graphics.print("You are using Dev commands. Proceed with caution!", map.camX, 3 + map.camY)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end
	
	-- displays FPS o_O
	displayFPS()
	
	-- quit message
	if not is_playing then
		love.graphics.setColor(whitecolor)
		love.graphics.setFont(smallFont)
		love.graphics.printf("Are you sure you want to quit? y / n", map.camX, 80 + map.camY, VIRTUAL_WIDTH, 'center')
	end
	
	if too_slow then
		love.graphics.setColor(greencolor)
		love.graphics.setFont(smallFont)
		love.graphics.printf("Game is running too slowly. Please wait for framerate to rise.", map.camX, 80 + map.camY, VIRTUAL_WIDTH, 'center')
	end
	
	if DEVMODE then
		love.graphics.setColor(greencolor)
		love.graphics.setFont(smallFont)
		love.graphics.printf("DEV MODE", map.camX, 10 + map.camY, VIRTUAL_WIDTH, 'center')
	end
	
	love.graphics.setColor(0, 0, 0, alpha)
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	
    -- end virtual resolution
    push:apply('end')
end

-- Allows the Frames Per Second to be shown
function displayFPS()
	if display_FPS then
		love.graphics.setColor(0, 1, 0, 1)
		love.graphics.setFont(smallFont)
		love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
		
		if display_diagnostics then
			love.graphics.print('dt: ' .. tostring(CURRENT_DT), VIRTUAL_WIDTH - 100, 20)
			love.graphics.print('interval: ' .. tostring(INTERVAL), VIRTUAL_WIDTH - 100, 40)
		end
		
		love.graphics.setColor(255, 255, 255, 255)
	end
	
	if love.timer.getFPS() < 30 then
		too_slow = true
	else
		too_slow = false
	end
end

function find_value (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return index
		end
	end

	return -1
end

-- Fades screen to black and/or back
function fade(mode, time, f)
	
	isFading = true
	doneFading = false
	doWhenComplete = f
	
	fadeMode = mode
	if fadeMode == 'toBlack' then
		alpha = 0
	else
		alpha = 1
	end
	fadeTimer = 0
	fadeLimit = time
	
end

function wait(seconds)
	local start = os.time()
	repeat until os.time() > start + seconds
end
