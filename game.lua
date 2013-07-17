-- 
-- Abstract: Reaction Time Game
-- Details:	 Test the reaction time of the user
-- Copyright (C) Ye Zhao


local storyboard = require("storyboard")
local upapi = require "upapi"
local json = require("json")
local math = require( "math")
local physics = require("physics")
local utils = require("utils")
local ball = require("ball")

local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

local user_xid = upapi.readFile(storyboard.states.userXIDPath)

local gScale = 9.8/4


function moveBouncy(obj, deltaX, deltaY)
	transition.to(obj, {time = 100, xScale = 1 + deltaX, yScale = 1 + deltaY})
end

function wobble(obj)
	moveBouncy(obj, .3, -.3)
	timer.performWithDelay(100, function () moveBouncy(obj, -.2, .2) end)
	timer.performWithDelay(200, function () moveBouncy(obj, .1, -.1) end)
	timer.performWithDelay(300, function () moveBouncy(obj, 0, 0) end)
end



function  scene:createScene(event)
	local group = self.view
	-- Display and graphics
	display.setStatusBar(display.HiddenStatusBar)
	display.setDefault( "background", 236, 240, 241 )

	-- Holder object for the popping circle

	local popTimer = nil
	local roundNum = 1
	sessionData = {}
	
	-- Static groups 
	local prison = utils.createBallPrison()

	bouncy = display.newCircle(group, display.contentWidth/2, display.contentHeight/2, 36)
	bouncy:setFillColor(189, 195, 199)

	function bouncy:touch(event)
		if event.phase == "began" then
			tapTime = system.getTimer()
			print("Bouncy is tapped at time = " .. tapTime)
			pauseTimer()
			if tapTime < popCompleted then
				print("tapped too early")
				timer.cancel( popTimer )
				--physics.pause()
				wobble(bouncy)
				-- local fx = (1-math.random()) * 100
				-- local fy = (1-math.random()) * 100
				bouncy:setFillColor(192, 57, 43)
				-- bouncy:applyLinearImpulse(fx, fy, bouncy.x, bouncy.y)
				timer.performWithDelay(1000, function()bouncy:setFillColor(189, 195, 199) end)

			else
				print("tapped after signal turned")
				bouncy:setFillColor(39, 174, 96)
				wobble(bouncy)
				local function resetBouncy()
					if bouncy ~= nil then
						print(bouncy)
						bouncy:setFillColor(189, 195, 199)
					end
				end

				if roundNum < storyboard.states.totalNumRounds then
					timer.performWithDelay(1000, resetBouncy)
				end
				reactionTime = math.round(tapTime - popCompleted)/1000
				updateTime(reactionTime)
				roundNum = roundNum + 1
				print("reaction time = " .. tapTime-popCompleted)
	
			end

			if roundNum > storyboard.states.totalNumRounds then
				print("game over")
				local endGameEvent = { name = "endGame", target = Runtime }
				Runtime:dispatchEvent(endGameEvent)
			else
				-- timer.performWithDelay(500, function () bouncy:setFillColor(230, 126, 34) end)
				local testReactionEvent = { name = "testReaction", target = Runtime }
				Runtime:dispatchEvent(testReactionEvent)

				print("game goes on ")
				
			end
				
		end
	end
	bouncy:addEventListener( "touch", bouncy)
	--bouncy:addEventListener( "touch", utils.dragBody )

	-- Physics engine starts
	physics.start()

	local function randomizeGravity()
		local fy = (math.random() - 0.5)
		local fx = (math.random() - 0.5)
		physics.setGravity(fx, fy)
	end

	randomizeGravity()

	physics.setGravity(0,1)
	prison.addToPhysics()
	physics.addBody(bouncy, {friction=0.5, bounce=0.85, radius = 36})
	bouncy.gravityScale = gScale

	gravityTimer = timer.performWithDelay(500, randomizeGravity, 0)



	-- Variables for keeping track of game progres
	local tapTime = nil
	local popTime = nil
	local aveReactTime = nil
	local fastestReactTime = nil


	function updateTime(newTime)
		if aveReactTime == nil then aveReactTime = newTime
		else
			preciseAveReactTime = (aveReactTime * (roundNum - 1) + newTime) / roundNum
			aveReactTime = math.round(preciseAveReactTime * 1000) / 1000
		end
		if fastestReactTime == nil then fastestReactTime = newTime
		elseif fastestReactTime > newTime then fastestReactTime = newTime
		end

		local t = os.date('*t')
		local reactionTimingInstance = {}
		reactionTimingInstance.timestamp = t
		reactionTimingInstance.reactionTime = newTime
		upapi.insertTimingToDatabase(reactionTimingInstance)
		sessionData.timings[roundNum]=newTime
	end

	function testReaction()
		print("Round = " .. roundNum)
		popDelay = math.random(2500, 5000)
		popStart = system.getTimer()
		popTimer = timer.performWithDelay(popDelay, function ()
			bouncy:setFillColor(230, 126, 34)
		end)
		print("Start = " .. popStart)
		print("Delay = " .. popDelay)
		popCompleted = popStart + popDelay
		print("Completed = " .. popCompleted)
	end

	function pauseTimer()
		timer.cancel(popTimer)
	end



	function endGame( )
		sessionData.endTime = os.time()
		sessionData.fastestReactTime = fastestReactTime
		sessionData.aveReactTime = aveReactTime
		sessionData.userMood = storyboard.states.userMood
		sessionData.sleepQuality = storyboard.states.sleepQuality
		sessionData.sleepDuration = storyboard.states.sleepDuration
		print(json.encode(sessionData.timings))
		local behavior = {}
		behavior.last_played = sessionData.endTime
		behavior.duration = sessionData.endTime - sessionData.startTime

		upapi.updateBehavior(behavior)
		upapi.updateTimings(sessionData)
		timer.performWithDelay(5,function() storyboard.gotoScene("stats") end)
	end

	

	Runtime:addEventListener( "testReaction", testReaction)
	Runtime:addEventListener( "endGame", endGame)

	if roundNum == 1 then
		local testReactionEvent = { name = "testReaction", target = Runtime }
		Runtime:dispatchEvent(testReactionEvent)
		sessionData.startTime = os.time()
		sessionData.timings = {}
	end

-- physics.setDrawMode( "hybrid" ) 

	
end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener("testReaction", testReaction)
	print("Removed event listener for test reaction")
	Runtime:removeEventListener("touch", randomTap)
	print("Remove event listener for randomTap")
	timer.cancel(gravityTimer)
	-- Update user performance if relevant

	

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

