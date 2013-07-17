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

local roundSounds = {
	audio.loadSound("round1.mp3"),
	audio.loadSound("round2.mp3"),
	audio.loadSound("round3.mp3"),
	audio.loadSound("round4.mp3"),
	audio.loadSound("round5.mp3")
}

local badRoundSound = audio.loadSound("badround.mp3")

local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

local user_xid = upapi.readFile(storyboard.states.userXIDPath)

local gScale = 9.8/4
local Ball = {}

function moveBouncy(obj, deltaX, deltaY)
	transition.to(obj, {time = 100, xScale = 1 + deltaX, yScale = 1 + deltaY})
end

function wobble(obj)
	moveBouncy(obj, .3, -.3)
	timer.performWithDelay(100, function () moveBouncy(obj, -.2, .2) end)
	timer.performWithDelay(200, function () moveBouncy(obj, .1, -.1) end)
	timer.performWithDelay(300, function () moveBouncy(obj, 0, 0) end)
end

-- State Object

local State = {
	totalNumberOfRounds = 5,
	currentRound = 1,
	misses = 0,
	gracePeriod = 1500, -- in MS
	minCountDownTime = 2700,
	maxCountDownTime = 6000, 
	state = "waiting"
}

function State:prematureHit()
	print( "FAIL" )
	State.misses = State.misses + 1

	audio.play( badRoundSound )
	State:cancelCountDown('angry')
end

function State:reactionHit()
	if State.gracePeriodTimer then timer.cancel( State.gracePeriodTimer ) end
	local elapsed = system.getTimer()-State.startTime
	print( "ELAPSED", elapsed, State.currentRound )
	State.currentRound = State.currentRound+1
	State:setState('waiting')

	audio.play(roundSounds[State.currentRound])

	if State.currentRound > State.totalNumberOfRounds then
		print( "DONE" )
		-- timer.performWithDelay(1000, function()
		-- 	storyboard.gotoScene( "home", {effect="fade"})
		-- end)
	end

end


function State:startCountDown()
	local delay = math.random(State.minCountDownTime, State.maxCountDownTime)
	if State.countDownTimer then timer.cancel( State.countDownTimer ) end
	State.countDownTimer = timer.performWithDelay(delay, State.startReactionTimer, 1)
	State:setState("countdown")
	print( "START COUNTDOWN")
end

function State:cancelCountDown(state)
	timer.cancel( State.countDownTimer )
	State:setState(state or 'waiting')
	print( "CANCLE COUNT DOWN")
end

function State:startReactionTimer()
	print( "START REACTION TIMER" )
	State:setState('reaction')
	State.gracePeriodTimer = timer.performWithDelay(
		State.gracePeriod,
		State.cancelReactionTimer,
		1
	)
	State.startTime = system.getTimer()
end

function State:cancelReactionTimer()
	print( "CANCELING REACTION TIMER ")
	State:startCountDown()
end


function State:setState( state )
	print( "SETTING STATE", state)
	State.state = state
	Ball:setState(state)
end

-- Ball Event Handlers

function Ball:touchDown(e)
	print("TOUCH DOWN")
	wobble( bouncy )
	bouncy.tempJoint = physics.newJoint( "touch", bouncy, e.x, e.y )

	if State.state == "countdown" then
		State:prematureHit()
	elseif State.state == "reaction" then
		State:reactionHit()
	end
end

function Ball:touchMove(e)
	if bouncy.tempJoint then bouncy.tempJoint:setTarget( e.x, e.y ) end
end

function Ball:touchUp(e)
	if bouncy.tempJoint then bouncy.tempJoint:removeSelf() end
	
	-- Sloooow the ball down
	local maxV = 1
	vx, vy = bouncy:getLinearVelocity( )
	vx = math.max(math.min( vx, maxV ), -maxV)
	vy = math.max(math.min( vy, maxV ), -maxV)
	bouncy:setLinearVelocity( vx, vy )

	Ball:gotoRandomSpot()

	State:startCountDown()
end

function Ball:setState( state )
	if state == "waiting" or state == "countdown" then
		bouncy:setFillColor(189, 195, 199)
	elseif state == "reaction" then
		bouncy:setFillColor(39, 174, 96)
	elseif state == "angry" then
		bouncy:setFillColor(174, 39, 96)
	end
end

function Ball:gotoRandomSpot()
	local dx = 0
	local dy = 0
	local x = 0
	local y = 0


	while math.sqrt(dx*dx+dy*dy) < 150 do
		x = math.random(50, display.contentWidth-50)
		y = math.random(50, display.contentHeight-50)
		dx = x-bouncy.x
		dy = y-bouncy.y
		print( math.sqrt(dx*dx+dy*dy) )
	end
	print( x, y)
	transition.to( bouncy, {
		x=x,
		y=y,
		xScale = 1,
		yScale = 1,
		time=400,
		transition=easing.outExpo
	})

	wobble(bouncy)
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

	--bouncy = display.newCircle(group, event.params.ballX, event.params.ballY, 36)
	bouncy = display.newCircle(group, display.contentWidth/2, display.contentHeight/2, 36)
	bouncy.xScale = 2
	bouncy.yScale = 2
	bouncy:setFillColor(189, 195, 199)

	Ball:gotoRandomSpot()

	function bouncy:touch(e)
		if e.phase == "began" then
			display.getCurrentStage():setFocus(e.target)
			Ball:touchDown(e)
		elseif e.phase == "moved" then
			Ball:touchMove(e)
		elseif e.phase == "ended" then
			display.getCurrentStage():setFocus(nil)
			Ball:touchUp(e)
		end

	end

	bouncy:addEventListener( "touch", bouncy )

	-- Physics engine starts
	physics.start()

	-- Gravity points towards the center of the screen
	local function centerGravity()
		local dx = bouncy.x - display.contentCenterX
		local dy = bouncy.y - display.contentCenterY

		fx = -3*dx/display.contentWidth + (math.random()*.2-.1)
		fy = -3*dy/display.contentHeight + (math.random()*.2-.1)

		physics.setGravity(fx, fy)
	end

	centerGravity()

	prison.addToPhysics()
	physics.addBody(bouncy, {friction=0.5, bounce=0.5, radius = 36})
	gravityTimer = timer.performWithDelay(50, centerGravity, 0)
	bouncy.gravityScale = gScale

	State:startCountDown()


	-- -- Variables for keeping track of game progres
	-- local tapTime = nil
	-- local popTime = nil
	-- local aveReactTime = nil
	-- local fastestReactTime = nil


	-- function updateTime(newTime)
	-- 	if aveReactTime == nil then aveReactTime = newTime
	-- 	else
	-- 		preciseAveReactTime = (aveReactTime * (roundNum - 1) + newTime) / roundNum
	-- 		aveReactTime = math.round(preciseAveReactTime * 1000) / 1000
	-- 	end
	-- 	if fastestReactTime == nil then fastestReactTime = newTime
	-- 	elseif fastestReactTime > newTime then fastestReactTime = newTime
	-- 	end

	-- 	local t = os.date('*t')
	-- 	local reactionTimingInstance = {}
	-- 	reactionTimingInstance.timestamp = t
	-- 	reactionTimingInstance.reactionTime = newTime
	-- 	upapi.insertTimingToDatabase(reactionTimingInstance)
	-- 	sessionData.timings[roundNum]=newTime
	-- end


	-- function endGame( )
	-- 	sessionData.endTime = os.time()
	-- 	sessionData.fastestReactTime = fastestReactTime
	-- 	sessionData.aveReactTime = aveReactTime
	-- 	sessionData.userMood = storyboard.states.userMood
	-- 	sessionData.sleepQuality = storyboard.states.sleepQuality
	-- 	sessionData.sleepDuration = storyboard.states.sleepDuration
	-- 	print(json.encode(sessionData.timings))
	-- 	local behavior = {}
	-- 	behavior.last_played = sessionData.endTime
	-- 	behavior.duration = sessionData.endTime - sessionData.startTime

	-- 	upapi.updateBehavior(behavior)
	-- 	upapi.updateTimings(sessionData)
	-- 	timer.performWithDelay(5,function() storyboard.gotoScene("stats") end)
	-- end

	

	-- Runtime:addEventListener( "testReaction", testReaction)
	-- Runtime:addEventListener( "endGame", endGame)

	-- if roundNum == 1 then
	-- 	local testReactionEvent = { name = "testReaction", target = Runtime }
	-- 	--Runtime:dispatchEvent(testReactionEvent)
	-- 	sessionData.startTime = os.time()
	-- 	sessionData.timings = {}
	-- end

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

