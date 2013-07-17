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

local moodSchemes = {
	"amazing",
	"energized",
	"good",
	"meh",
	"dragging",
	"exhausted",
	"dead",
}


local userFirebaseURL = 'https://react.firebaseio.com/users/'

function sleepPattern(rawdata)
	print(rawdata)
	local sessionHistory = json.decode(rawdata)
	local lessSleep = {total = 0, count = 0, average = 0}
	local moreSleep = {total = 0, count = 0, average = 0}

	
	local temp = {}
	local medianSleepDuration

	for k, v in pairs(sessionHistory) do
		if v["sleepDuration"] ~= nil then
			table.insert( temp, v["sleepDuration"] )
			print(v["fastestReactTime"])
			table.sort( temp )
			if math.fmod(#temp,2) == 0 then
				medianSleepDuration = ( temp[#temp/2] + temp[(#temp/2)+1] ) / 2
			else
				medianSleepDuration = temp[math.ceil(#temp/2)]
			end
		end

		if v["mood"] ~= nil then
			
		end
	end


	for k, v in pairs(sessionHistory) do
		if v["sleepDuration"] ~= nil then
			if v["sleepDuration"] < medianSleepDuration then
				lessSleep.total = lessSleep.total + v["fastestReactTime"]
				lessSleep.count = lessSleep.count + 1
			else
				moreSleep.total = moreSleep.total + v["fastestReactTime"]
				moreSleep.count = moreSleep.count + 1
			end
			lessSleep.average = lessSleep.total / lessSleep.count
			moreSleep.average = moreSleep.total / moreSleep.count
		else
			lessSleep.average = ""
		end
	end

	print("less sleep count = " .. lessSleep.count)
	print("more sleep count = " .. moreSleep.count)

end

function networkErrorHandler(event)
	if event.isError then
		print( "Network error!" .. event.stats, event.response)
	else
		sleepPattern(event.response)
	end

end

function getUserHistory(xid)
	-- sample data from Zach for testing
	zach_xid = "RGaCBFg9CsBWTbPeM_ZTiw"
	ye_xid = "RGaCBFg9CsBNhnVrZnP0Fg"
	network.request(userFirebaseURL .. ye_xid .. "/sessions.json", "GET", networkErrorHandler)
end
