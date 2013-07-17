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
display.setStatusBar( display.HiddenStatusBar )

local gScale = 9.8

local function tadaLeft(obj)
	local dT = 50
	transition.to(obj, {time = dT, xScale = 1, yScale = 1, rotation = -3})
	timer.performWithDelay(dT, function () transition.to(obj, {time = dT, xScale = 0.9, yScale = 0.9, rotation = 3}) end)
	timer.performWithDelay(dT*2, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = -3}) end)
	timer.performWithDelay(dT*3, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = 3}) end)
	timer.performWithDelay(dT*4, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = -3}) end)
	timer.performWithDelay(dT*5, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = 3}) end)
	timer.performWithDelay(dT*6, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = -3}) end)
	timer.performWithDelay(dT*7, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = 3}) end)
	timer.performWithDelay(dT*8, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = -3}) end)
	timer.performWithDelay(dT*9, function () transition.to(obj, {time = dT, xScale = 1, yScale = 1, rotation = 0}) end)
end

local function tadaRight(obj)
	local dT = 50
	transition.to(obj, {time = dT, xScale = 1, yScale = 1, rotation = 3})
	timer.performWithDelay(dT, function () transition.to(obj, {time = dT, xScale = 0.9, yScale = 0.9, rotation = -3}) end)
	timer.performWithDelay(dT*2, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = 3}) end)
	timer.performWithDelay(dT*3, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = -3}) end)
	timer.performWithDelay(dT*4, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = 3}) end)
	timer.performWithDelay(dT*5, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = -3}) end)
	timer.performWithDelay(dT*6, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = 3}) end)
	timer.performWithDelay(dT*7, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = -3}) end)
	timer.performWithDelay(dT*8, function () transition.to(obj, {time = dT, xScale = 1.1, yScale = 1.1, rotation = 3}) end)
	timer.performWithDelay(dT*9, function () transition.to(obj, {time = dT, xScale = 1, yScale = 1, rotation = 0}) end)
end

local function shake(obj)
	local dT = 50
	transition.to(obj, {time = dT, x = obj.x-10})
	timer.performWithDelay(dT, function () transition.to(obj, {time = dT, x = obj.x+10}) end)
	timer.performWithDelay(dT*2, function () transition.to(obj, {time = dT, x = obj.x-10}) end)
	timer.performWithDelay(dT*3, function () transition.to(obj, {time = dT, x = obj.x+10}) end)
	timer.performWithDelay(dT*4, function () transition.to(obj, {time = dT, x = obj.x-10}) end)
	timer.performWithDelay(dT*5, function () transition.to(obj, {time = dT, x = obj.x+10}) end)
	timer.performWithDelay(dT*6, function () transition.to(obj, {time = dT, x = obj.x-10}) end)
	timer.performWithDelay(dT*7, function () transition.to(obj, {time = dT, x = obj.x+10}) end)
	timer.performWithDelay(dT*8, function () transition.to(obj, {time = dT, x = obj.x-10}) end)
	timer.performWithDelay(dT*9, function () transition.to(obj, {time = dT, x = obj.x+10}) end)
end


-- Initialize New Scene
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true


function scene:createScene( event )
	local group = self.view

	-- Static groups 
	local staticGroup = display.newGroup()

	-- Background Color
	local background = display.newRect(group, 0,0,display.contentWidth,display.contentHeight)
	background:setFillColor(236, 240, 241)
	group:insert(background)

	-- Signout button

	-- local signoutButton = display.newText(group, "Sign Out", 0,0, storyboard.states.font.bold, 16)
	-- signoutButton:setTextColor(0,0,0)
	-- function signoutButton:touch(event)
	-- 	if event.phase == "ended" then
	-- 		upapi.writeFile(storyboard.states.upAPILoginTokenPath, " ")
	-- 		upapi.writeFile(storyboard.states.userXIDPath, " ")
	-- 		storyboard.gotoScene("welcome")
	-- 	end
	-- end
	-- signoutButton:addEventListener("touch", signoutButton)
	
	local ground = display.newLine(staticGroup, 0, display.contentHeight, 2*display.contentWidth, display.contentHeight)
	local leftWall = display.newLine(staticGroup, 0, 0, 0, 2*display.contentHeight)
	local rightWall = display.newLine(staticGroup, display.contentWidth, 0, display.contentWidth, 2*display.contentHeight)
	local ceiling = display.newLine(staticGroup, 0, 0, 2*display.contentWidth, 0)
	group:insert(staticGroup)

	local insightsButton = utils.createButton("insights", display.contentWidth/2, display.contentHeight*5/6, display.contentWidth * 3/4, display.contentHeight/10)
	group:insert(insightsButton)


	local timeToNextPlay = 100
	local nextPlayTime = os.time() + timeToNextPlay

	local countdownTimer = display.newText("", 0, 0, storyboard.states.font.bold, 80)
	countdownTimer:setTextColor(189, 195, 199)
	countdownTimer:setReferencePoint(display.TopCenterReferencePoint)
	countdownTimer.x = display.contentWidth/2
	countdownTimer.y = 10
	group:insert(countdownTimer)

	local countdownInfo = display.newText("min to next play", 0, 0, storyboard.states.font.regular, 30)
	countdownInfo:setTextColor(189, 195, 199)
	countdownInfo:setReferencePoint(display.TopCenterReferencePoint)
	countdownInfo.x = display.contentWidth/2
	countdownInfo.y = countdownTimer.y + countdownTimer.height - 20
	group:insert(countdownInfo)
	countdownInfo.alpha = 0

	local bouncy = display.newImageRect("sphere.png", 72, 72)
	bouncy:setReferencePoint(display.CenterReferencePoint)
	bouncy.x = display.contentWidth/2
	bouncy.y = display.contentHeight/3
	group:insert(bouncy)


	local coverScreen = display.newRect(0,0,display.contentWidth,display.contentHeight)
	coverScreen:setFillColor(236, 240, 241)


	local tickTimer = nil
	function updateCountdownTimer(nextPlayTime)
		timeToNextPlay = nextPlayTime - os.time()
		print(timeToNextPlay)

		if timeToNextPlay <= 0 then 
			countdownTimer:removeSelf()
			countdownInfo:removeSelf()
			timer.cancel(tickTimer)
			local playButton = utils.createButton("play", display.contentWidth/2, display.contentHeight/2, display.contentWidth /2, display.contentHeight/10)
			group:insert(playButton)
			print("user free to play next game")
			insightsButton:removeSelf()
			bouncy:removeSelf()
			shake(playButton)
			function playButton:touch(event)
				if event.phase == "ended" then
					playButton:removeEventListener("touch", playButton)
					playButton:removeSelf()
					storyboard.gotoScene("mood")
				end
			end

			playButton:addEventListener("touch", playButton)
		elseif timeToNextPlay <= 60 and timeToNextPlay > 0 then
			countdownTimer.text = string.format("%d", timeToNextPlay)
			countdownInfo.text = "sec to next play"
			bouncy.gravityScale = 1000
			-- timer.performWithDelay(1000, function() updateCountdownTimer(nextPlayTime) end)
		elseif timeToNextPlay > 60 then
			local minLeft = math.floor(timeToNextPlay/60) + 1
			countdownTimer.text = string.format("%d", minLeft)
			bouncy.gravityScale = (101-minLeft)*2
			-- timer.performWithDelay(1000, function() updateCountdownTimer(nextPlayTime) end)
		end

	end

	


	function lastPlayBehaviorCallback(failed, result)
		if not failed then
			print("user playing behaviro retrieved from database")
			if json.decode(result)== nil then
				nextPlayTime = os.time()
			else
				local lastPlayedTime = json.decode(result)["last_played"]
				nextPlayTime = lastPlayedTime + 60
				
			end
			tickTimer = timer.performWithDelay(1000, function() updateCountdownTimer(nextPlayTime); end, 0)
			timer.performWithDelay(1000, function()countdownInfo.alpha=1 end)
			coverScreen:removeSelf()
		else
			print("failed to retrieve result")
		end

	end
	-- Handle countdown timer 
	upapi.getBehaviorData(storyboard.states.userXID, lastPlayBehaviorCallback)


	local function onCollision(self, event)
		if event.x < display.contentWidth /2 then 
			tadaLeft(self)
		else
			tadaRight(self)
		end
	end
	insightsButton.collision = onCollision
	insightsButton:addEventListener("collision", insightsButton)

	function insightsButton:touch(event)
		if event.phase == "began" then
			timer.cancel(tickTimer)
			storyboard.gotoScene("insights")
		end
	end
	insightsButton:addEventListener("touch", insightsButton)
	

	-- Physics engine starts
	physics.start()
	physics.setGravity(0,1)
	print(staticGroup.numChildren)
	for i=1,staticGroup.numChildren do 
		staticGroup[i].alpha = 0
		physics.addBody(staticGroup[i], "static", {friction=0.5, bounce=1})
	end
	physics.addBody(bouncy, {friction=0.5, bounce=1, radius = 36})
	physics.addBody(insightsButton, "static", {friction=0.5, bounce=1})
	bouncy.gravityScale = gScale


	-- Get user information and trends
	local function userTrendsCallback(failed, result)
		if failed then
			print("Network failure. Please try again.")
		else
			print("printing user call back result: " .. result)
			local userTrend = json.decode(result)

			local recentData = ((userTrend.data).data)[7]

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
end

function scene:exitScene( event )
	local group = self.view
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