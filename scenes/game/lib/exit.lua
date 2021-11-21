-- Extends an object to load a new map

-- Libs
local json = require( "json" )
local fx = require( "com.ponywolf.ponyfx" )

-- Define module
local M = {}

local levelStatuses = {}
local composer = require( "composer" )

local filePath = system.pathForFile( "levelStatuses.json", system.DocumentsDirectory )

function preLoadLevelStatuses()

	local preLevelStatuses
	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		preLevelStatuses = json.decode( contents )

		print("LENGTH - ", #preLevelStatuses)
		for i = 1, #preLevelStatuses do
			print("Level " .. i .. " status - ", preLevelStatuses[i].level)
		end

	end

	return preLevelStatuses
end

function changeLevelStatus(levelName)

	local file = io.open( filePath, "w" )
	if file then

		if levelName == "level1" then
			levelStatuses[1].level = 1
		elseif levelName == "level2" then
			levelStatuses[2].level = 1
		end
		
		file:write( json.encode( levelStatuses ) )
		io.close( file )
	end
end

levelStatuses = preLoadLevelStatuses()

function M.new( instance )

	if not instance then error( "ERROR: Expected display object" ) end
  
	-- Get current scene and sounds
	local scene = composer.getScene( composer.getSceneName("current") )
	print("CURRENT EXIT SCENE - ", composer.getSceneName("current"))
	local sounds = scene.sounds
  
	if not instance.bodyType then
		physics.addBody( instance, "static", { isSensor = true } )
	end

	function instance:collision( event )
		
		local phase, other = event.phase, event.other
		if phase == "began" and other.name == "hero" and not other.isDead then

			other.isDead = true
			other.linearDamping = 8
			audio.play( sounds.door )

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
