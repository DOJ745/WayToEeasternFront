-- Include modules/libraries
local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )
local tiled = require( "com.ponywolf.ponytiled" )
local physics = require( "physics" )
local json = require( "json" )

local scoring = require( "scenes.game.lib.score" )
local heartBar = require( "scenes.game.lib.heartBar" )

local map, hero, heart, parallax, soundManager, levelStatus

local scene = composer.newScene()

function scene:create(event)

	local sceneGroup = self.view  -- Add scene display objects to this group

	-- Sounds
	local sndDir = "scenes/game/sfx/"
	scene.sounds = {

		bark = audio.loadSound(sndDir .. "bark.mp3");
		meow = audio.loadSound(sndDir .. "meow.mp3");

		enemyDeath = audio.loadSound(sndDir .. "enemyDeath.mp3");

		level0Music = audio.loadSound(sndDir .. "background/level0_music.mp3");
		level1Music = audio.loadSound(sndDir .. "background/level1_music.mp3");
		level2Music = audio.loadSound(sndDir .. "background/level2_music.mp3");

		door = audio.loadSound( sndDir .. "door.mp3" ),

		hurt = {
			audio.loadSound( sndDir .. "hurt1.mp3" ),
			audio.loadSound( sndDir .. "hurt2.mp3" ),
		},

		hit = audio.loadSound( sndDir .. "hit.mp3" ),
		coin = audio.loadSound( sndDir .. "coin.wav" ),
	}

	-- Start physics before loading map
	physics.start()
	physics.setGravity( 0, 30 )

	-- Load our map
	local filename = event.params.map or "scenes/game/levels/level0.json"
	local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
	map = tiled.new( mapData, "scenes/game/levels" )
	--map.xScale, map.yScale = 0.85, 0.85

	-- Find our hero script
	map.extensions = "scenes.game.lib."
	map:extend("hero")

	hero = map:findObject("hero")
	hero.filename = filename

	-- Find scripts our enemies and other items

	--map:extend( "blob", "enemy", "exit", "coin", "spikes" )
	map:extend("blob", "enemyOfficer", "enemySoldier", "exit", "coin", "spikes")

	-- Find the parallax layer
	--parallax = map:findLayer("parallax")

	-- Find the music object
	soundManager = map:findObject("levelMusic")
	if (soundManager ~= nil ) then
		print("Found music object!")
		print("Property 'music' - ", soundManager.music)
	end

	levelStatus = map:findObject("levelStatus")
	if (levelStatus ~= nil ) then
		print("Found level status!")
		print("Property 'isOpened' - " .. tostring(levelStatus.isOpened))
	end

	-- Add our scoring module
	local coin = display.newImageRect(sceneGroup, "scenes/game/img/coin.png", 64, 64 )

	-- Coin icon position
	coin.x = display.contentWidth - coin.contentWidth / 2 - 24
	coin.y = display.screenOriginY + coin.contentHeight / 2 + 20

	scene.score = scoring.new( { score = event.params.score } )
	local score = scene.score

	-- Points positions
	score.x = display.contentWidth - score.contentWidth / 2 - 35 - coin.width
	score.y = display.screenOriginY + score.contentHeight / 2 + 34

	-- Add our hearts module
	heart = heartBar.new()

	heart.x = 48
	heart.y = display.screenOriginY + heart.contentHeight / 2 + 16

	hero.heart = heart

	-- Touch the hearts to go back to the main menu
	function heart:tap(event)
		fx.fadeOut( function()
				composer.gotoScene("scenes.menu")
			end )
	end
	heart:addEventListener("tap")

	-- Insert our game items in the correct back-to-front order
	sceneGroup:insert(map)
	sceneGroup:insert(score)
	sceneGroup:insert(coin)
	sceneGroup:insert(heart)

end

-- Function to scroll the map
local function enterFrame( event )

	local elapsed = event.time

	-- Easy way to scroll a map based on a character
	if hero and hero.x and hero.y and not hero.isDead then
		local x, y = hero:localToContent( 0, 0 )
		x, y = display.contentCenterX - x, display.contentCenterY - y
		map.x, map.y = map.x + x, map.y + y

		-- Easy parallax
		if parallax then
			parallax.x, parallax.y = map.x / 6, map.y / 8  -- Affects x more than y
		end
	end
end

-- This function is called when scene comes fully on screen
function scene:show( event )

	local phase = event.phase
	if ( phase == "will" ) then
		fx.fadeIn()	-- Fade up from black
		Runtime:addEventListener( "enterFrame", enterFrame )
	elseif ( phase == "did" ) then
		-- Start playing wind sound
		-- For more details on options to play a pre-loaded sound, see the Audio Usage/Functions guide:
		-- https://docs.coronalabs.com/guide/media/audioSystem/index.html

		if (soundManager.music == "level0") then
			audio.play( self.sounds.level0Music, { loops = -1, fadein = 750, channel = 15 } )
		end

		if (soundManager.music == "level1") then
			audio.play( self.sounds.level1Music, { loops = -1, fadein = 750, channel = 15 } )
		end

		if (soundManager.music == "level2") then
			audio.play( self.sounds.level2Music, { loops = -1, fadein = 750, channel = 15 } )
		end

	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )

	local phase = event.phase
	if ( phase == "will" ) then
		audio.fadeOut( { time = 1000 } )
	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end
end

-- This function is called when scene is destroyed
function scene:destroy( event )

	audio.stop()  -- Stop all audio
	for s, v in pairs( self.sounds ) do  -- Release all audio handles
		audio.dispose( v )
		self.sounds[s] = nil
	end
end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene
