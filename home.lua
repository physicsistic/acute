-----------------------------------------------------------------------------------------
--
-- waiting.lua
--
-- The waitng screen when the time for rematch hasn't been reached
--
-----------------------------------------------------------------------------------------

-- Libraries
local storyboard = require "storyboard" 
local widget = require( "widget" )
local upapi = require "upapi"
local math = require( "math")
local physics = require("physics")
local json = require("json")
local utils = require("utils")
local ball = require("ball")

display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background", 236, 240, 241 )

local gScale = 9.8*4


-- Initialize New Scene
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

function scene:createScene( event )
	local group = self.view


	local prison = utils.createBallPrison()

	if not event.params then
		event.params = {
			ballX =  display.contentWidth/2 + (math.random(-30,30)+10)*3,
			ballY =  display.contentHeight/4
		}
	end

	local bouncy = ball.create(event.params.ballX, event.params.ballY)

	-- Screen buttons

	local playButton = utils.createButton("play", display.contentWidth/2, display.contentHeight*3/5)
	local insightsButton = utils.createButton("insights", display.contentWidth/2, playButton.y + utils.buttonSep + playButton.height)	
	insightsButton.setActive( false )
	local signoutButton = utils.createButton("log out", display.contentWidth/2, display.contentHeight*11/12)
	signoutButton.setWidth(display.contentWidth/3)
	signoutButton.setHeight(display.contentHeight/15)
	signoutButton.setColor(230, 126, 34)
	signoutButton.setFontSize(14)

	group:insert(prison)
	group:insert(bouncy)
	group:insert(playButton)
	group:insert(insightsButton)

	playButton.fadeIn()
	insightsButton.fadeIn()
	signoutButton.fadeIn()

	playButton.onClick(function(e)
		physics.removeBody( playButton )
		physics.removeBody( bouncy )

		playButton.fadeOut()
		insightsButton.fadeOut()
		signoutButton.fadeOut()

		transition.to( bouncy, {
			x = display.contentWidth/2,
			y = display.contentHeight/2,
			xScale = 1,
			yScale = 1,
			time = 700,
			transition = easing.outExpo,
			rotation = 0, 
			onComplete = function()
				storyboard.gotoScene( "mood" )
			end
		})
		
		
	end)

	signoutButton.onClick(function(e)
		physics.removeBody( playButton )
		physics.removeBody( bouncy )
		playButton.fadeOut()
		signoutButton.fadeOut()
		insightsButton.fadeOut()
		storyboard.gotoScene( "welcome" )

	end)

	insightsButton.onClick(function(e)
		native.showAlert( "Bouncy Doesn't Know You", "You'll need to play with bouncy more before you get deep insights.")
	end)

-- Physics engine starts

	physics.start()
	physics.setGravity(0,1)
	
	prison.addToPhysics()

	physics.addBody(playButton, "dynamic", {friction=0.5, bounce=.9, density=1})
	physics.addBody(insightsButton, "dynamic", {friction=0.5, bounce=.9, density=1})
	physics.addBody(bouncy, {friction=0.5, bounce=1, radius = 36})

	local playJoint = physics.newJoint('pivot', playButton, prison.ceiling, playButton.x, playButton.y )
	local insightsJoint = physics.newJoint('pivot', insightsButton, prison.ceiling, insightsButton.x, insightsButton.y )

	local range = 25

	playJoint.isLimitEnabled = true
	insightsJoint.isLimitEnabled = true
	playJoint:setRotationLimits( -range, range )
	insightsJoint:setRotationLimits( -range, range )


	bouncy:addEventListener( "touch", utils.dragBody )
	playButton:addEventListener( "touch", utils.dragBody )
	insightsButton:addEventListener( "touch", utils.dragBody )

	bouncy.gravityScale = gScale

	-- Accelerometer 
	system.setAccelerometerInterval( 50 )
	function onAccelerate(event)
		physics.setGravity(event.xInstant + event.xGravity, (event.yInstant + event.yGravity)*(-1))
		local function resetGravityListener () 
			physics.setGravity(event.xGravity, 1) 
		end
		timer.performWithDelay(50, resetGravityListener)
	end

	Runtime:addEventListener("accelerometer", onAccelerate)

	-- Get user information and trends for analysis later
	local function userTrendsCallback(failed, result)
		if failed then
			print("Network failure. Please try again.")
		else
			-- print("printing user call back result: " .. result)
			local userTrend = json.decode(result)

			local recentData = ((userTrend.data).data)[8]

			if recentData == nil then
			else
				-- get sleep quality if possible
				if recentData[2]["s_quality"] then
					storyboard.states.sleepQuality = recentData[2]["s_quality"]
				else
					storyboard.states.sleepQuality = nil
				end

				if recentData[2]["s_duration"] then
					storyboard.states.sleepDuration = recentData[2]["s_duration"]
				else
					storyboard.states.sleepDuration = nil
				end
				print(storyboard.states.sleepQuality)
			end

		end
	end

	upapi.getUserMetrics("trends", userTrendsCallback)


end

function scene:enterScene( event )
	local group = self.view	
	-- upapi.getUserMetrics("friends", friendsCallback)
	local file = io.open(storyboard.states.userInfoFilePath, "r")
	storyboard.states.userInfo = json.decode(file:read("*a"))
	io.close(file)

	-- get current gender data
	local function parseCurrentGenderStats(error, response)
		storyboard.states.currentGenderStats = json.decode(response)
	end
	upapi.getGenderStats(tostring(storyboard.states.userInfo.gender), parseCurrentGenderStats)

	-- get current gender data
	local function parseCurrentAgeStats(error, response)
		print(response)
		if reponse then
			storyboard.states.currentAgeStats = json.decode(response)
		else
			local stats = {}
			stats.time = 0
			stats.count = 0 
			storyboard.states.currentAgeStats = stats
		end
	end
	upapi.getAgeStats(string.sub(tostring(storyboard.states.userInfo.dob),1,4), parseCurrentAgeStats)

end

function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener("accelerometer", onAccelerate)

end

function scene:destroyScene( event )
	local group = self.view
end


-----------------------------------------------------------------------------------------
-- Event Listeners
-----------------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )

scene:addEventListener( "enterScene", scene )

scene:addEventListener( "exitScene", scene )

scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene