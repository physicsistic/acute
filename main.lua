
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



-- persistent states that go between screens 

storyboard.states = {}


storyboard.states.upAPILoginTokenPath = system.pathForFile( "react_upapi_token", system.DocumentsDirectory )
storyboard.states.userXIDPath = system.pathForFile( "react_user_xid", system.DocumentsDirectory )
storyboard.states.loginToken = upapi.readFile(storyboard.states.upAPILoginTokenPath)

-- Firebase attributes
storyboard.states.firebaseURL = "https://react.firebaseio.com/users"

storyboard.states.userInfoFilePath = system.pathForFile("react_user_info", system.DocumentsDirectory )

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

local bouncy = display.newImageRect(group, "sphere.png", 72, 72)
bouncy.x = display.contentWidth/2
bouncy.y = display.contentHeight/2

local function flash(obj, frameTime)
	transition.to(obj, {time = frameTime, alpha=0, transition = easing.inOutQuad, onComplete = function () transition.to(obj, {time=frameTime, alpha=1, transition=easing.inOutQuad}) end})
end

local text = display.newText(group, "loading...", 0, 0, storyboard.states.font.bold, 24)
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
			print(event.response)
			group:removeSelf()
			local meta = json.decode(event.response)["meta"]
			print(meta)
			if meta["code"] == 200 then
				print(event.response)
				storyboard.gotoScene( "waiting" )
				print("user is logged in")
			else 
				print("user session token doesn't exist")
				storyboard.gotoScene( "welcome" )
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


local loginToken = upapi.readFile(storyboard.states.upAPILoginTokenPath)

if loginToken == nil then
	storyboard.gotoScene("welcome")
	group:removeSelf()
else 
	-- check if user is logged in
	checkLoginToken()
end






-- -- Static groups 
-- local staticGroup = display.newGroup()
-- local ground = display.newLine(staticGroup, 0, display.contentHeight * 3/4, 2*display.contentWidth, display.contentHeight * 3/4)
-- local leftWall = display.newLine(staticGroup, 0, 0, 0, display.contentHeight)
-- local rightWall = display.newLine(staticGroup, display.contentWidth, 0, display.contentWidth, display.contentHeight)
-- local ceiling = display.newLine(staticGroup, 0, 0, 2*display.contentWidth, 0)

-- local shadow = display.newRoundedRect(0, 0, 20, 6, 3 )
-- shadow:setReferencePoint(display.CenterReferencePoint)
-- shadow.x = display.contentWidth/2
-- shadow.y = display.contentHeight * 3/4
-- shadow:setFillColor(189, 195, 199)

-- local bouncy = display.newCircle(display.contentWidth/2, display.contentHeight/4, 18)
-- bouncy:setFillColor(230, 126, 34)



-- -- Physics engine starts
-- physics.start()
-- physics.setGravity(0,1)
-- for i=1,staticGroup.numChildren do 
-- 	staticGroup[i].alpha = 0
-- 	physics.addBody(staticGroup[i], "static", {friction=0.5, bounce=0.95})
-- end
-- physics.addBody(bouncy, {friction=0.5, bounce=1, radius = 36})
-- bouncy.gravityScale = gScale





-- -- Visual effects
-- local function shadowChange(event)
-- 	distanceFromGround = ground.y - bouncy.y
-- 	shadow.width =(bouncy.width/2 - shadowParams.short) * (1 - distanceFromGround /(display.contentHeight/2)) + shadowParams.short
-- 	shadow.x = bouncy.x
-- 	shadow.y = display.contentHeight * 3/4 - 20 + bouncy.height / 2
-- end

-- transition.to(bouncy, {time=5000, height = 1500, width = 1500, transition = easing.inQuad})


-- Runtime:addEventListener("enterFrame", shadowChange)

-- -- end of displays



function exitScene()
	physics.stop()
	bouncy:removeSelf()
	background:removeSelf()
	leftWall:removeSelf()
	rightWall:removeSelf()
	ceiling:removeSelf()
	Runtime:removeEventListener("enterFrame", shadowChange)

	-- Check if the tokenPath file exist

	local function networkListener( event )
		if event.isError then 
			print ( "Network error!", event.status, event.response)
		end

		local meta = json.decode(event.response)["meta"]
		if meta["code"] == 200 then

			storyboard.gotoScene( "game" )
			print("user is logged in")
		else 
			print("user session token doesn't exist")
			storyboard.gotoScene( "welcome" )
		end

	end
	local params = {}
	local headers = {}
	headers["Accept"] = "application/json"
	local loginToken = upapi.readFile(storyboard.states.upAPILoginTokenPath)

	print("The login token is: " .. loginToken)
	headers["x-nudge-token"] = loginToken
	
	params.headers = headers
	network.request( "https://jawbone.com/nudge/api/users/@me/", "GET", networkListener, params)

end


-- exitSceneTimer = timer.performWithDelay(5000, exitScene)





