-- Score libs
local json = require( "json" )

-- Define module
local M = {}

function M.new( options )

	-- Default options for instance
	options = options or {}
	local label = options.label or ""
	local x, y = options.x or 0, options.y or 0

	local font = options.font or "scenes/game/font/Special Elite.ttf"
	local size = options.size or 56

	local align = options.align or "right"
	local stroked = options.stroked or true
	local color = options.color or { 1, 1, 1, 1 }
	local width = options.width or 256

	-- Params for file
	local scoresTable = {}
	local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

	local score
	local num = options.score or 0
	
	local textOptions = { x = x, y = y, text = label .. " " .. num, width = width, font = font, fontSize = size, align = align }

	score = display.newEmbossedText( textOptions )
	score.num = num
	score.target = num

	score:setFillColor( unpack(color) )

	function score:add( points )
		self.target = self.target + ( points or 100 )

		local function countUp()
			local diff = math.ceil( ( self.target - self.num ) / 12 )
			self.num = self.num + diff

			if self.num > self.target then
				self.num = self.target
				timer.cancel( self.timer )
				self.timer = nil
			end

			self.text = label .. " " .. ( self.num or 0 )
		end
		
		if not self.timer then
			self.timer = timer.performWithDelay( 30, countUp, -1 )
		end
	end
  
	function score:get() return self.target or 0 end

	function score:loadScores()
		
		local file = io.open( filePath, "r" )
 
    	if file then
        	local contents = file:read( "*a" )
        	io.close( file )
        	scoresTable = json.decode( contents )
    	end
 
    	if ( scoresTable == nil or #scoresTable == 0 ) then
        	scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    	end

	end

	function score:saveScore()

		for i = #scoresTable, 11, -1 do
			table.remove( scoresTable, i )
		end
	 
		local file = io.open( filePath, "w" )
	 
		if file then
			file:write( json.encode( scoresTable ) )
			io.close( file )
		end

	end

	function score:setScore(score)

		-- Insert the saved score from the last game into the table, then reset it
		table.insert( scoresTable, score )
	
		-- Sort the table entries from highest to lowest
		local function compare( a, b )
			return a > b
		end
		table.sort( scoresTable, compare )

	end

	function score:getScoreTable() return scoresTable end

	function score:finalize()
		-- On remove, cleanup instance
		if self and self.timer then timer.cancel( self.timer ) end
	end

	score:addEventListener("finalize")

	-- Return instance
	return score
end

return M
