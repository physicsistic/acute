
-----------------------------------------------------------------------------------------
--
-- main.lua
--
-- Main screen for the app to direct different paths.
--
-----------------------------------------------------------------------------------------


-- hide the status bar
display.setStatusBar(display.HiddenStatusBar)

-- include the Corona "storyboard" module
local storyboard = require "storyboard"
local json = require "json"
local upapi = require "upapi"
local physics = require "physics"
local math = require "math"
local native = require "native"
local animate = require "animate"
-- local analysis = require "analysis"


-- persistent states that go between screens 

storyboard.states = {}


storyboard.states.upAPILoginTokenPath = system.pathForFile( "react_upapi_token", system.CachesDirectory )
storyboard.states.userXIDPath = system.pathForFile( "react_user_xid", system.CachesDirectory )
storyboard.states.loginToken = upapi.readFile(storyboard.states.upAPILoginTokenPath)

-- Firebase attributes
storyboard.states.firebaseURL = "https://react.firebaseio.com/users"

storyboard.states.userInfoFilePath = system.pathForFile("react_user_info", system.CachesDirectory )

-- Font states
storyboard.states.font = {}
storyboard.states.font.regular = "Montserrat-Regular"
storyboard.states.font.bold = "Montserrat-Bold"
-- Storing session data
storyboard.states.sessionTimings = {}
-- Firebase user data
storyboard.states.userXID = upapi.readFile(storyboard.states.userXIDPath)
-- Session timing
storyboard.states.timings = {}
-- Number of rounds to play (default set to 5)
storyboard.states.totalNumRounds = 5

storyboard.states.location = {}


local group = display.newGroup()

local background = display.newRect(group, 0, 0, display.contentWidth, display.contentHeight)
background:setFillColor(236, 240, 241)

local bouncy = display.newImageRect(group, "Ball.png", 72, 72)
bouncy.x = display.contentWidth/2
bouncy.y = display.contentHeight/2


local function flash(obj, frameTime)
	transition.to(obj, {time = frameTime, alpha=.5, transition = easing.inOutQuad, onComplete = function () transition.to(obj, {time=frameTime, alpha=1, transition=easing.inOutQuad}) end})
end

local text = display.newText(group, "inflating ball...", 0, 0, storyboard.states.font.bold, 24)
text:setTextColor(189, 195, 199)
text.x = display.contentWidth/2
text.y = display.contentHeight * 5/6


flash(bouncy, 500)
flashingTimer = timer.performWithDelay(1000, function() flash(bouncy, 500)end, 0)

function checkLoginToken()
	local function networkListener( event )
		if event.isError then 
			print ( "Network error!", event.status, event.response)
		else
			local meta = json.decode(event.response)["meta"]
			if meta["code"] == 200 then
				print("user is logged in")
				gotoHomeScreen()
			else 
				print("user session token doesn't exist")
				gotoWelcomeScreen()
			end
		end

	end
	local params = {}
	local headers = {}
	headers["Accept"] = "application/json"


	headers["x-nudge-token"] = loginToken
	
	params.headers = headers
	network.request( "https://jawbone.com/nudge/api/users/@me/", "GET", networkListener, params)
end

function magicTransition( toScreen )
	local params = {
		ballY = display.contentHeight/6,
		ballX = display.contentWidth/2 + math.random(-100,100)
	}

	timer.cancel( flashingTimer )

	transition.to( text, {
		time = 500,
		alpha = 0
	})

	transition.to( bouncy, {
		x=params.ballX,
		y=params.ballY,
		time= 1300,
		transition = easing.outQuad,
		onComplete = function()
			group:removeSelf()
			storyboard.gotoScene( toScreen, {params=params} )
		end
	})
end


function gotoHomeScreen()
	magicTransition('home')
end


function gotoWelcomeScreen()
	magicTransition('welcome')
end


local loginToken = upapi.readFile(storyboard.states.upAPILoginTokenPath)

if loginToken == nil then
	gotoWelcomeScreen()
else 
	-- check if user is logged in
	checkLoginToken()
end


