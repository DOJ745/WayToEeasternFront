-- Include modules/libraries
local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )
local tiled = require( "com.ponywolf.ponytiled" )
local scoring = require( "scenes.game.lib.score" )
local json = require( "json" )

-- Variables local to scene
local ui, backgroundMusic, start

-- Create a new Composer scene
local scene = composer.newScene()

local function key(event)
	-- go back to menu if we are not already there
	if event.phase == "up" and event.keyName == "escape" then
		if not (composer.getSceneName("current") == "scenes.menu") then
			fx.fadeOut(function ()
					composer.gotoScene("scenes.menu")
				end)
		end
	end
end


-- This function is called when scene is created
function scene:create( event )

	local sceneGroup = self.view  -- Add scene display objects to this group

	-- stream music
	backgroundMusic = audio.loadStream( "scenes/main_menu/sfx/main_menu_music.mp3" )


	local levelsTileData = {}
	local levelFiles = {"scenes/game/levels/level1.json"}

	for i = 1, #levelFiles do
		local levelData = json.decodeFile( system.pathForFile(levelFiles[i], system.ResourceDirectory) )
		--local tileData = tiled.new(levelData, "scenes/game/levels")
		--levelsTileData.insert(tileData)
	end

	-- Load our UI
	local uiData = json.decodeFile( system.pathForFile("scenes/main_menu/ui/main_menu.json", system.ResourceDirectory) )
	ui = tiled.new(uiData, "scenes/main_menu/ui")
	ui.x, ui.y = display.contentCenterX - ui.designedWidth / 2, display.contentCenterY - ui.designedHeight / 2

	scene.score = scoring.new( { score = event.params.score } )
	local score = scene.score

	-- Find the start button
	start = ui:findObject("start")
	function start:tap()
		fx.fadeOut( function()
				composer.gotoScene( "scenes.game", { params =  {} } )
			end )
	end
	fx.breath(start)

	-- Find the records button
	recordsBackground = ui:findLayer("recordsWindow")
	records = ui:findObject("records")

	function records:tap()

		local font = "scenes/game/font/Special Elite.ttf"
		local testBackground = display.newImageRect( sceneGroup, "scenes/main_menu/ui/scoresBackgroundColor.png", 3000, 2500 )
		
		scene.score:loadScores()
		tempTable = scene.score:getScoreTable()

		local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, font, 44 )
		local rankNum = {} 
		local thisScore = {}

    	for i = 1, 10 do
        	if (tempTable[i]) then
            	local yPos = 150 + ( i * 52 )
 
				rankNum[i] = display.newText( sceneGroup, i .. ")", display.contentCenterX - 50, yPos, font, 36 )
            	rankNum[i]:setFillColor(0)
            	rankNum[i].anchorX = 1
 
				thisScore[i] = display.newText( sceneGroup, tempTable[i], display.contentCenterX - 30, yPos, font, 36 )
				thisScore[i]:setFillColor(0)
            	thisScore[i].anchorX = 0
        	end
    	end


		closeButton = display.newText( sceneGroup, "Close", display.contentCenterX, 710, font, 44 )
    	closeButton:setFillColor( 0.75, 0.95, 1 )
		
		local function closeRecords()
			display.remove(closeButton)
			display.remove(highScoresHeader)
			display.remove(testBackground)

			for i = 1, 10 do
				if (tempTable[i]) then
					display.remove(rankNum[i])
					display.remove(thisScore[i])
				end
			end
		end

		closeButton:addEventListener("tap", closeRecords)
	end

	fx.breath(records)

	--Find the choose level button
	chooseLevel = ui:findObject( "chooseLevel" )
	function chooseLevel:tap()
		fx.fadeOut( function()
				composer.gotoScene( "scenes.game", { params = {} } )
			end )
	end
	fx.breath(chooseLevel)

	-- Find the exit button
	exit = ui:findObject( "exit" )
	function exit:tap()
		native.requestExit()
	end
	fx.breath(exit)

	-- Transtion in logo at the start of app
	transition.from(ui:findObject( "title" ), { xScale = 2.5, yScale = 2.5, time = 1333, transition = easing.outQuad } )

	sceneGroup:insert(ui)
	-- escape key
	Runtime:addEventListener("key", key)
end

local function enterFrame(event)
	local elapsed = event.time
end

-- This function is called when scene comes fully on screen
function scene:show( event )

	local phase = event.phase
	if ( phase == "will" ) then
		fx.fadeIn()
		-- add enterFrame listener
		Runtime:addEventListener( "enterFrame", enterFrame )

	elseif ( phase == "did" ) then

		start:addEventListener("tap")
		records:addEventListener("tap")
		chooseLevel:addEventListener("tap")
		exit:addEventListener("tap")

		timer.performWithDelay( 10, function()
			audio.play( backgroundMusic, { loops = -1, channel = 1 } )
			audio.fade({ channel = 1, time = 333, volume = 0.8 } )
		end)	
	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )

	local phase = event.phase
	if ( phase == "will" ) then
		start:removeEventListener( "tap" )
		audio.fadeOut( { channel = 1, time = 1500 } )
	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end
end

-- This function is called when scene is destroyed
function scene:destroy( event )
	audio.stop()  -- Stop all audio
	audio.dispose(backroundMusic)  -- Release music handle
	Runtime:removeEventListener("key", key)
end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene
