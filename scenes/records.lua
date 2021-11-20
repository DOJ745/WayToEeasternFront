-- Include modules/libraries
local composer = require "composer"
local scoring = require( "scenes.game.lib.score" )
local json = require( "json" )

-- Variables local to scene
--

-- Create a new Composer scene
local scene = composer.newScene()


function gotoMenu()
    composer.gotoScene("scenes.menu", { params =  {} } );
end

-- This function is called when scene is created
function scene:create( event )

	local sceneGroup = self.view  -- Add scene display objects to this group

    scene.score = scoring.new( { score = event.params.score } )
	local score = scene.score
    

    local font = "scenes/game/font/Special Elite.ttf"
		local testBackground = display.newImageRect( sceneGroup, "scenes/main_menu/ui/scoresBackgroundColor.png", 3000, 2500 )
		
		scene.score:loadScores()
		tempTable = scene.score:getScoreTable()

		local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, font, 44 )

    	for i = 1, 10 do
        	if ( tempTable[i] ) then
            	local yPos = 150 + ( i * 52 )
 
            	local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX - 50, yPos, font, 36 )
            	rankNum:setFillColor( 0.95 )
            	rankNum.anchorX = 1
 
            	local thisScore = display.newText( sceneGroup, tempTable[i], display.contentCenterX - 30, yPos, font, 36 )
            	thisScore.anchorX = 0
        	end
    	end

		closeButton = display.newText( sceneGroup, "Close", display.contentCenterX, 735, font, 44 )
    	closeButton:setFillColor( 0.75, 0.95, 1 )

		closeButton:addEventListener("tap", gotoMenu)

end

local function enterFrame(event)
	local elapsed = event.time
end

-- This function is called when scene comes fully on screen
function scene:show( event )

	local phase = event.phase
	if ( phase == "will" ) then
		Runtime:addEventListener( "enterFrame", enterFrame )
	elseif ( phase == "did" ) then

	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )

	local phase = event.phase
	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end
end

-- This function is called when scene is destroyed
function scene:destroy( event )

  --collectgarbage()
end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene
