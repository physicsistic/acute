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
local analysis = require("analysis")

local roundSounds = {
	audio.loadStream("round1.mp3"),
	audio.loadStream("round2.mp3"),
	audio.loadStream("round3.mp3"),
	audio.loadStream("round4.mp3"),
	audio.loadStream("round5.mp3")
}

local badRoundSound = audio.loadSound("badround.mp3")

local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

local user_xid = storyboard.states.userXID

local gScale = 9.8


function  scene:createScene(event)
	local group = self.view
	-- Display and graphics
	display.setStatusBar(display.HiddenStatusBar)

	-- Set background to Sublime black
	-- display.setDefault( "background", 39, 40, 33) -- black
	display.setDefault( "background", 236, 240, 241 ) -- clouds


	local Ball = {}

	-- State Object

	local State = {
		totalNumberOfRounds = 5,
		currentRound = 1,
		misses = 0,
		gracePeriod = 1500, -- in MS
		minCountDownTime = 1200,
		maxCountDownTime = 4000, 
		state = "waiting",
		gameOver = false
	}

	function State:prematureHit()
		State.misses = State.misses + 1

		audio.play( badRoundSound )
		State:cancelCountDown('angry')
	end

	function State:reactionHit()
		if State.gracePeriodTimer then timer.cancel( State.gracePeriodTimer ) end
		local elapsed = system.getTimer()-State.startTime
		print( "ELAPSED", elapsed, State.currentRound )
		updateTime( elapsed )
		audio.play(roundSounds[State.currentRound])
		State.currentRound = State.currentRound+1
		State:setState('waiting')
		system.vibrate()

		if State.currentRound > State.totalNumberOfRounds then
			print( "DONE" )
			State.gameOver = true
		end

	end


	function State:startCountDown()
		local delay = math.random(State.minCountDownTime, State.maxCountDownTime)
		if State.countDownTimer then timer.cancel( State.countDownTimer ) end
		State.countDownTimer = timer.performWithDelay(delay, State.startReactionTimer, 1)
		State:setState("countdown")
		-- print( "START COUNTDOWN")
	end

	function State:cancelCountDown(state)
		timer.cancel( State.countDownTimer )
		State:setState(state or 'waiting')
		-- print( "CANCLE COUNT DOWN")
	end

	function State:startReactionTimer()
		-- print( "START REACTION TIMER" )
		State:setState('reaction')
		State.gracePeriodTimer = timer.performWithDelay(
			State.gracePeriod,
			State.cancelReactionTimer,
			1
		)
		State.startTime = system.getTimer()
	end

	function State:cancelReactionTimer()
		-- print( "CANCELING REACTION TIMER ")
		State:startCountDown()
	end


	function State:setState( state )
		-- print( "SETTING STATE", state)
		State.state = state
		Ball:setState(state)
	end

	-- Ball Event Handlers

	function Ball:touchDown(e)
		-- print("TOUCH DOWN")
		utils.wobble(bouncy)
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
		
		if State.gameOver then
			endGame()
			return
		end

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
		end
		transition.to( bouncy, {
			x=x,
			y=y,
			time=400,
			transition=easing.outExpo
		})

		utils.wobble(bouncy, 1)
	end


	-- Holder object for the popping circle

	sessionData = {}
	
	-- Static groups 
	local prison = utils.createBallPrison()

	--bouncy = display.newCircle(group, event.params.ballX, event.params.ballY, 36)
	bouncy = display.newCircle(group, display.contentWidth/2, display.contentHeight/2, 48)
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

	local instructionText = display.newText(
		"tap ball when green",
		0,
		display.contentHeight-50,
		storyboard.states.font.bold,
		24
	)
	instructionText.x = display.contentWidth/2
	instructionText:setTextColor(189, 195, 199)
	-- TODO: 'green' should be in green

	utils.fadeIn(instructionText)
	-- START EVERYTHIGN
	timer.performWithDelay(3000, function()
		State:startCountDown()
		sessionData.startTime = os.time()
		sessionData.timings = {}		
		utils.fadeOut(instructionText, 1000)
	end)

	
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
	physics.addBody(bouncy, {friction=0.5, bounce=0.5, radius = 36*1.5})
	gravityTimer = timer.performWithDelay(50, centerGravity, 0)
	bouncy.gravityScale = gScale


	-- Variables for keeping track of game progres
	local aveReactTime = nil
	local fastestReactTime = nil

	function updateTime(newTime)
		if aveReactTime == nil then aveReactTime = newTime
		else
			preciseAveReactTime = (aveReactTime * (State.currentRound - 1) + newTime) / State.currentRound
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
		sessionData.timings[State.currentRound]=newTime
	end


	function explodeBall()
		balls = {}

		local r = 10
		local force = 10

		function c() return math.random(-20,20) end

		for i=1,100 do
			local b = display.newCircle(group, 0, 0, r)
			b:setFillColor(189+c(), 195+c(), 199+c())
			local angle = math.random(0, 360)
			local d = math.random(0,36*1.5)
			b.x = bouncy.x + math.sin(angle)*d
			b.y = bouncy.y + math.cos(angle)*d
			balls[i] = b
			group:insert(b)
			physics.addBody(b, {friction=0.5, bounce=0.5, radius = r})
			
			timer.performWithDelay(math.random(0,150), function()
				b:applyForce(
					math.random(-force,force),
					math.random(-force,force),
					b.x, b.y)
			end)
			
		end

		if gravityTimer then timer.cancel( gravityTimer ) end
		physics.setGravity(0, 30)

		bouncy.alpha = 0
		bouncy.y = 1000
		physics.removeBody( prison.ground )

	end

	function endGame( )
		sessionData.endTime = os.time()
		sessionData.fastestReactTime = fastestReactTime/1000
		sessionData.aveReactTime = aveReactTime/1000
		sessionData.userMood = storyboard.states.userMood
		sessionData.sleepQuality = storyboard.states.sleepQuality
		sessionData.sleepDuration = storyboard.states.sleepDuration
		print("Encoded Timings", json.encode(sessionData.timings))
		local behavior = {}
		behavior.last_played = sessionData.endTime
		behavior.duration = sessionData.endTime - sessionData.startTime

		upapi.updateBehavior(behavior)
		upapi.updateTimings(sessionData)
		
		

		if State.gracePeriodTimer then timer.cancel( State.gracePeriodTimer ) end
		if State.countDownTimer then timer.cancel( State.countDownTimer ) end
		if gravityTimer then timer.cancel( gravityTimer ) end

		bouncy:removeEventListener( "touch", bouncy )
		explodeBall()

		timer.performWithDelay(
			1500,
			function()
				storyboard.gotoScene("stats", {effect="slideDown"})
				--group:removeSelf()
			end
		)
	end


-- physics.setDrawMode( "hybrid" ) 

	
end

function scene:enterScene( event )
	local group = self.view

	analysis.getUserHistory(storyboard.states.userXID )

end

function scene:exitScene( event )
	local group = self.view
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

