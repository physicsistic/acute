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
	
	local function callback( event )
		if event.isError then
			print("Network error!", event.states, event.response)
		else
			print(event.response)
			native.showAlert(event.reponse)
		end
	end
	local params = {}
	params.body = dataJSON
	network.request(deviceStateURL .. deviceID .. ".json", "PUT", callback, params)
end

function getDeviceState(deviceID, callback)
	local function networkHandler(event)
		if event.isError then
			print("Network error!", event.state, event.response)
			native.showAlert(event.response)
			state = nil
		else
			callback(event.response)
		end
	end
	network.request(deviceStateURL .. deviceID .. ".json", "GET", networkHandler)
end