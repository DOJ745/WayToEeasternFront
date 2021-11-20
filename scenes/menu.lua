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

	-- Load our UI
	local uiData = json.decodeFile( system.pathForFile( "scenes/main_menu/ui/main_menu.json", system.ResourceDirectory ) )
	ui = tiled.new( uiData, "scenes/main_menu/ui" )
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
		recordsBackground.alpha = 1.0
		scene.score:loadScores()
		tempTable = scene.score:getScoreTable()

		local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, font, 44 )

    	for i = 1, 10 do
        	if ( tempTable[i] ) then
            	local yPos = 150 + ( i * 52 )
 
            	local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX - 50, yPos, font, 36 )
            	rankNum:setFillColor( 0.95 )
            	rankNum.anchorX = 1
 
            	local thisScore = display.newText( sceneGroup, tempTable[i], display.contentCenterX-30, yPos, font, 36 )
            	thisScore.anchorX = 0
        	end
    	end

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
	local exit = ui:findObject( "exit" )

	function exit:tap()
		native.requestExit()
	end
	fx.breath(exit)

	records:addEventListener("tap")
	chooseLevel:addEventListener("tap")
	exit:addEventListener("tap")


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
