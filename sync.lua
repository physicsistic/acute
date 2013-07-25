-----------------------------------------------------------------------------------------
--
-- sync.lua
--
-- sync the states of the apps via firebase for each devices
--
-----------------------------------------------------------------------------------------


module(..., package.seeall)

local math = require( "math" )
local network = require( "network" )
local json = require( "json" )

local deviceStateURL = "https://acuteappstate.firebaseio.com/devices/"	

function updateDeviceState(deviceID, rawData)
	local dataJSON = json.encode(rawData)
	local text = display.newText("event request started", 0, 125, native.systemFont, 14)
			text:setTextColor(0,0,0)

	function updateDeviceStateHandler( event )
		if event.isError then
			print("Network error!", event.states, event.response)
			local text1 = display.newText("event error", 0, 150, native.systemFont, 14)
			text:setTextColor(0,0,0)
		else
			print("event correctly processed and added to app state database")
			local text1 = display.newText("event response retrieved", 0, 150, native.systemFont, 14)
			text:setTextColor(0,0,0)
			print(event.response)
			local text2 = display.newText(event.response, 0, 175, native.systemFont, 14)
			text:setTextColor(0,0,0)
		end
	end
	local params = {}
	params.body = dataJSON
	local text3 = display.newText(dataJSON, 0, 200, native.systemFont, 14)
	text3:setTextColor(0,0,0)

	local URL = deviceStateURL .. deviceID .. ".json"
	local text4 = display.newText(URL, 0, 225, 200, 200, native.systemFont, 14)
	text4:setTextColor(0,0,0)
	network.request(URL, "PUT", updateDeviceStateHandler, params)
end

function getDeviceState(deviceID, callback)
	local function networkHandler(event)
		if event.isError then
			print("Network error!", event.state, event.response)
			state = nil
		else
			callback(event.response)

		end
	end
	network.request(deviceStateURL .. deviceID .. ".json", "GET", networkHandler)
end