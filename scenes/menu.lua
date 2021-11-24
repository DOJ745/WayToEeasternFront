-- Include modules/libraries
local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )
local tiled = require( "com.ponywolf.ponytiled" )
local exiting = require( "scenes.game.lib.exit" )
local scoring = require( "scenes.game.lib.score" )
local json = require( "json" )

-- Variables local to scene
local ui, backgroundMusic, start
local font = "scenes/game/font/Special Elite.ttf"
local filePath = system.pathForFile( "levelStatuses.json", system.DocumentsDirectory )

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

function loadLevelStatuses()

	local levelStatuses = {}
	local file = io.open( filePath, "r" )


	if file then
		local contents = file:read( "*a" )
		io.close( file )
		levelStatuses = json.decode( contents )

		print("LENGTH of levelStasuses.json(MENU) - ", #levelStatuses)
		for i = 1, #levelStatuses do
			print("Level " .. i .. " status - ", levelStatuses[i].isOpen)
		end
	else
		file = io.open( filePath, "w" )
		if file then
			file:write('[{"isOpen":0, "levelNumber":1},{"isOpen":0, "levelNumber":2}]')
			io.close(file)
		end
		
	end

	return levelStatuses
end

local backupLevelStatuses = loadLevelStatuses()

-- This function is called when scene is created
function scene:create( event )

	local sceneGroup = self.view  -- Add scene display objects to this group

	backupLevelStatuses = loadLevelStatuses()

	-- stream music
	backgroundMusic = audio.loadStream( "scenes/main_menu/sfx/main_menu_music.mp3" )

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

		local background = display.newImageRect( sceneGroup, "scenes/main_menu/ui/backgroundColor.png", 3000, 2500 )
		
		scene.score:loadScores()
		tempTable = scene.score:getScoreTable()

		local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, font, 44 )
		highScoresHeader:setFillColor(0)
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


		closeRecordsButton = display.newText( sceneGroup, "Close", display.contentCenterX, 710, font, 44 )
    	closeRecordsButton:setFillColor(0)
		
		local function closeRecords()
			closeRecordsButton:removeEventListener("tap", closeRecords)
			display.remove(closeRecordsButton)
			display.remove(highScoresHeader)
			display.remove(background)

			for i = 1, 10 do
				if (tempTable[i]) then
					display.remove(rankNum[i])
					display.remove(thisScore[i])
				end
			end
		end

		closeRecordsButton:addEventListener("tap", closeRecords)
	end

	fx.breath(records)

	--Find the choose level button
	chooseLevel = ui:findObject( "chooseLevel" )
	function chooseLevel:tap()

		local levelStatuses = loadLevelStatuses()

		if (levelStatuses == nil) then 
			print("WARNING! Use backup data about level")
			levelStatuses = TEST 
		end

		local levelButtons = {}
		local background = display.newImageRect( sceneGroup, "scenes/main_menu/ui/backgroundColor.png", 3000, 2500 )
		local chooseLevelHeader = display.newText( sceneGroup, "Choose level", display.contentCenterX, 100, font, 44 )
		chooseLevelHeader:setFillColor(0)

		local function startLevel(levelNumber)

			return function(event)

                print("TESTING arg things - ", event.name, event.phase, levelNumber)

				fx.fadeOut( function()
					composer.gotoScene( "scenes.game", { params = { 
						map = "scenes/game/levels/level" .. levelNumber .. ".json"} 
					} 
				) end)

        	end
		end

		for i = 1, #levelStatuses do

			levelButtons[i] = display.newText( sceneGroup, "Level " .. i, display.contentCenterX, 100 + i * 90, font, 44 )

			if (levelStatuses[i].isOpen == 0) then
				levelButtons[i]:setFillColor(0.65, 0.65, 0.65)
				levelButtons[i].text = "Level " .. levelStatuses[i].levelNumber .. " BLOCKED"
			else
				levelButtons[i].text = "Level " .. levelStatuses[i].levelNumber .. " UNLOCKED"
				levelButtons[i]:setFillColor(0)
				levelButtons[i]:addEventListener("tap",  startLevel(levelStatuses[i].levelNumber))
			end
		end

		closeLevelsButton = display.newText( sceneGroup, "Close", display.contentCenterX, 710, font, 44 )
    	closeLevelsButton:setFillColor(0)
		
		local function closeLevels()
			closeLevelsButton:removeEventListener("tap", closeLevels)
			display.remove(closeLevelsButton)
			display.remove(chooseLevelHeader)
			display.remove(background)

			for i = 1, #levelStatuses do
				levelButtons[i]:removeEventListener("tap", startLevel)
				display.remove(levelButtons[i])
			end
		end

		closeLevelsButton:addEventListener("tap", closeLevels)
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
		
		backupLevelStatuses = loadLevelStatuses()

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

		start:removeEventListener("tap")
		records:removeEventListener("tap")
		chooseLevel:removeEventListener("tap")
		exit:removeEventListener("tap")

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