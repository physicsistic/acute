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
	"totall done",
}


local userFirebaseURL = 'https://react.firebaseio.com/users/'

function sleepPattern(rawdata)
	print(rawdata)
	local sessionHistory = json.decode(rawdata)

	local lessSleepTotal = 0
	local lessSleepCount = 0
	local moreSleepTotal = 0
	local moreSleepCount = 0
	local temp = {}
	local medianSleepDuration

	for k, v in pairs(sessionHistory) do
		if v["sleepDuration"] ~= nil do
			table.insert( temp, v["sleepDuration"] )
			print(v["fastestReactTime"])
			table.sort( temp )
			if math.fmod(#temp,2) == 0 then
				medianSleepDuration = ( temp[#temp/2] + temp[(#temp/2)+1] ) / 2
			else
				medianSleepDuration = temp[math.ceil(#temp/2)]
			end
		end
	end

	print("median sleep is" .. medianSleepDuration)

	for k, v in pairs(sessionHistory) do
		if v["sleepDuration"] < medianSleepDuration then
			lessSleepTotal = lessSleepTotal + v["fastestReactTime"]
			lessSleepCount = lessSleepCount + 1
		else
			moreSleepTotal = moreSleepTotal + v["fastestReactTime"]
			moreSleepCount = moreSleepCount + 1
		end
	end

	print("less sleep count = " .. lessSleepCount)
	print("more sleep count = " .. moreSleepCount)

	print("less sleep fastest reaction time = " .. (lessSleepTotal / lessSleepCount))
	print("more sleep fastest reaction time = " .. (moreSleepTotal / moreSleepCount))

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
