-- Include modules/libraries
local composer = require( "composer" )

-- Variables local to scene
local prevScene = composer.getSceneName( "previous" )

-- Create a new Composer scene
local scene = composer.newScene()

function scene:show( event )

	local phase = event.phase
	local options = { params = event.params }
	if ( phase == "will" ) then
		composer.removeScene( prevScene )
	elseif ( phase == "did" ) then
		composer.gotoScene("scenes.menu")
	end
end

--scene:addEventListener("create")
scene:addEventListener("show", scene)
--scene:addEventListener("hide")
--scene:addEventListener("destroy")

return scene
