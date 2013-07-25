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

local storyboard = require( "storyboard" )

local moodSchemes = {}
moodSchemes["dead"]= 1
moodSchemes["exhausted"]=2
moodSchemes["dragging"]= 3
moodSchemes["meh"]= 4
moodSchemes["good"]= 5
moodSchemes["energized"]= 6
moodSchemes["amazing"]= 7


local userFirebaseURL = 'https://react.firebaseio.com/users/'

storyboard.states.screen1 = {}
storyboard.states.screen2 = {}
storyboard.states.screen3 = {}
storyboard.states.screen3.moods = {}
storyboard.states.screen3.timings ={}

function sleepPattern(rawdata)
	local sessionHistory = json.decode(rawdata)
	local lessSleep = {total = 0, count = 0, average = 0}
	local moreSleep = {total = 0, count = 0, average = 0}

	
	local temp = {}
	local medianSleepDuration


	for k, v in pairs(sessionHistory) do
		if v["sleepDuration"] ~= nil then
			table.insert( temp, v["sleepDuration"] )
			print(v["sleepDuration"] .. " = " .. v["fastestReactTime"])
			table.sort( temp )
			if math.fmod(#temp,2) == 0 then
				medianSleepDuration = ( temp[#temp/2] + temp[(#temp/2)+1] ) / 2
			else
				medianSleepDuration = temp[math.ceil(#temp/2)]
			end
		end

		if v["userMood"] ~= nil then
			print(v["userMood"])
			if v["aveReactTime"] < 1.5 then
				table.insert(storyboard.states.screen3.moods, moodSchemes[v["userMood"]])
				table.insert(storyboard.states.screen3.timings, v["aveReactTime"])
			end
		end
	end


	for k, v in pairs(sessionHistory) do
		if v["sleepDuration"] ~= nil then
			if v["sleepDuration"] <= medianSleepDuration then
				lessSleep.total = lessSleep.total + v["fastestReactTime"]
				lessSleep.count = lessSleep.count + 1
			else
				moreSleep.total = moreSleep.total + v["fastestReactTime"]
				moreSleep.count = moreSleep.count + 1
			end
			lessSleep.average = lessSleep.total / lessSleep.count
			moreSleep.average = moreSleep.total / moreSleep.count
			storyboard.states.screen1.moreSleep = moreSleep.average
			storyboard.states.screen1.lessSleep = lessSleep.average
		else
		end
	end

	local sessionStats = {}
	sessionStats.screen1 = storyboard.states.screen1
	sessionStats.screen3 = storyboard.states.screen3


	print("less sleep count = " .. lessSleep.count)
	print("more sleep count = " .. moreSleep.count)

	print(json.encode(storyboard.states.screen3))
	print(json.encode(storyboard.states.screen1))

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
	if xid == nil then
		xid = "RGaCBFg9CsBWTbPeM_ZTiw"
	end
	print("user xid is " .. xid)
	network.request(userFirebaseURL .. xid .. "/sessions.json", "GET", networkErrorHandler)
end
