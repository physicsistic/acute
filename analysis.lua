-----------------------------------------------------------------------------------------
--
-- analysis.lua
--
-- computes all the data etc for the user to generate the stats page at the end of the game
--
-----------------------------------------------------------------------------------------


module(..., package.seeall)

-- Libraries
local math = require( "math" )
local network = require( "network" )
local upapi = require( "upapi" )
local json = require( "json" )


local userFirebaseURL = 'https://react.firebaseio.com/users/'

function networkErrorHandler(event, callback)
	if event.isError then
		print( "Network error!" .. event.stats, event.response)
	else
		print( "RESPONSE: " .. event.response)
		if callback then
			callback(event.response)
		end
	end

end

function getUserHistory(xid)
	-- sample data from Zach for testing
	if xid == nil then
		xid = "RGaCBFg9CsBWTbPeM_ZTiw"
	end
	network.request(userFirebaseURL .. xid .. "/sessions.json", "GET", networkErrorHandler)
end

function personalReactionAnalysis(rawdata)
	local sessionHistory = json.decode(rawdata)

	for k, v in pairs(sessionHistory) do
		local session = sessionHistory[k]
	end

end