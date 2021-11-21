-- Extends an object to load a new map

-- Libs
local json = require( "json" )
local fx = require( "com.ponywolf.ponyfx" )

-- Define module
local M = {}

local levelStatuses
local composer = require( "composer" )

local filePath = system.pathForFile( "levelStatuses.json", system.DocumentsDirectory )

function loadLevelStatuses()

	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		levelStatuses = json.decode( contents )

		print("LENGTH - ", #levelStatuses)
		for i = 1, #levelStatuses do
			print("Level " .. i .. " status - ", levelStatuses[i].level)
		end

	end

end

function TESTloadLevelStatuses()

	local TESTlevelStatuses
	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		TESTlevelStatuses = json.decode( contents )

		print("LENGTH - ", #TESTlevelStatuses)
		for i = 1, #TESTlevelStatuses do
			print("Level " .. i .. " status - ", TESTlevelStatuses[i].level)
		end

	end

	return TESTlevelStatuses
end

function changeLevelStatus(levelName)

	local file = io.open( filePath, "w" )

	if (file) then

		if levelName == "level1" then
			levelStatuses[1].level = 1
		elseif levelName == "level2" then
			levelStatuses[2].level = 1
		end
		
		file:write( json.encode( levelStatuses ) )
		io.close( file )
	end
end

function M.new( instance )

	if not instance then error( "ERROR: Expected display object" ) end
  
	-- Get current scene and sounds
	local scene = composer.getScene( composer.getSceneName("current") )
	print("CURRENT EXIT SCENE - ", composer.getSceneName("current"))
	local sounds = scene.sounds

	local testLevels = TESTloadLevelStatuses()

	function exit:getLevelStatuses() return testLevels end
  
	if not instance.bodyType then
		physics.addBody( instance, "static", { isSensor = true } )
	end

	function instance:collision( event )
		
		local phase, other = event.phase, event.other
		if phase == "began" and other.name == "hero" and not other.isDead then

			other.isDead = true
			other.linearDamping = 8
			audio.play( sounds.door )

			loadLevelStatuses()

			if (string.match(self.map, "level1")) then
				changeLevelStatus("level1")
			elseif (string.match(self.map, "level2")) then
				changeLevelStatus("level2")
			end
			
			self.fill.effect = "filter.exposure"

			transition.to( self.fill.effect, { time = 666, exposure = -5, onComplete = function()
				fx.fadeOut( function()
					print("SELF.MAP (NEXT LEVEL) value - ", self.map)
					composer.gotoScene( "scenes.refresh", { params = { map = self.map, score = scene.score:get() } } )
				end )
			end } )
		end
	end

	instance:addEventListener("collision")
	return instance
end

return M
