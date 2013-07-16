-----------------------------------------------------------------------------------------
--
-- results.lua
--
-- results screen to display the user data after a run of the game
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local upapi = require "upapi"
local json = require("json")
local math = require "math"
-- local GGChart = require( "GGChart" )

local scene = storyboard.newScene()

local function secToHour(seconds)
	local time = {}
	local totalMinutes = math.round(seconds / 60)
	time.hour = math.floor(totalMinutes/60)
	time.minute = totalMinutes % 60
	return time
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	local myImage = nil
	print("displaying session result for user")
	local filename = "sleepGraph.png"
	local directory = system.DocumentsDirectory
	local recentSleepDetails = storyboard.states.sleepData["data"]["items"][1]["details"]
	local sleepDuration = secToHour(recentSleepDetails["duration"])
	local sleepQuality = recentSleepDetails["quality"]
	print(string.format("%d hours %d minutes",sleepDuration.hour, sleepDuration.minute))
	os.setlocale(recentSleepDetails["tz"])
	local asleepTime = os.date("%I:%M %p", recentSleepDetails["asleep_time"])
	local awakenTime = os.date("%I:%M %p", recentSleepDetails["awaken_time"])
	local asleepTimeLabel = display.newText(group, asleepTime, 0, 0, storyboard.states.font.bold, 12)
	
	asleepTimeLabel:setReferencePoint(display.TopLeftReferencePoint)
	local awakenTimeLabel = display.newText(group, awakenTime, 0, 0, storyboard.states.font.bold, 12)
	
	awakenTimeLabel:setReferencePoint(display.TopRightReferencePoint)
	local sleepDurationLabel = display.newText(group, string.format("%dh %dm",sleepDuration.hour, sleepDuration.minute), 0, 0, storyboard.states.font.bold, 24)
	sleepDurationLabel:setReferencePoint(display.TopLeftReferencePoint)
	local sleepQualityLabel = display.newText(group, string.format("%d%%",sleepQuality), 0, 0, storyboard.states.font.bold, 24)
	sleepQualityLabel:setReferencePoint(display.TopRightReferencePoint)


	local function sleepGraphCallback(response)
		myImage = display.newImage(group, response.filename, response.baseDirectory)
		myImage.alpha = 0
		transition.to( myImage, { alpha = 1 } )
		myImage.height = display.contentHeight / 3
		myImage.y = display.contentHeight * 2 / 3
		myImage.x = display.contentWidth / 2
		asleepTimeLabel.x = myImage.x - myImage.width / 2
		awakenTimeLabel.x = myImage.x + myImage.width / 2
		asleepTimeLabel.y = myImage.y + myImage.height / 2
		awakenTimeLabel.y = myImage.y + myImage.height / 2
		sleepDurationLabel.x = asleepTimeLabel.x + asleepTimeLabel.width
		sleepQualityLabel.x = awakenTimeLabel.x - awakenTimeLabel.width
		sleepDurationLabel.y = asleepTimeLabel.y + asleepTimeLabel.height
		sleepQualityLabel.y = awakenTimeLabel.y + awakenTimeLabel.height
		sleepDurationLabel:setTextColor(50,50,50)
		sleepQualityLabel:setTextColor(50,50,50)
		asleepTimeLabel:setTextColor(70,70,70)
		awakenTimeLabel:setTextColor(70,70,70)
	end

	local rtInfo = "your reaction times are ... "
	local rtInfoText = display.newText(group, rtInfo, 10, 10, storyboard.states.font.bold, 18)
	rtInfoText:setTextColor(50,50,50)

	local sleepInfo = "did you realized your sleep was ... "
	local sleepInfoText = display.newText(group, sleepInfo, 10, display.contentHeight*0.45, storyboard.states.font.bold, 18)
	sleepInfoText:setTextColor(50,50,50)

	-- Generating a distribution of user data as compared to global data
	local globalDistribution = display.newImageRect(group, "distribution.png", 300, 150 )
	globalDistribution.x = display.contentWidth / 2
	globalDistribution.y = display.contentHeight / 4

	local dotYPos = {}
	local dotXPos = {}
	local overflowCount = 0
	for i=1,12 do 
		dotYPos[i] = globalDistribution.y + globalDistribution.height / 2
		dotXPos[i] = globalDistribution.x - globalDistribution.width / 2 + globalDistribution.width / 12 * i 
	end
	print(json.encode(storyboard.states.timings))
	
	for i=1,storyboard.states.totalNumRounds do
		local index = math.floor(storyboard.states.timings[i]/0.05) + 1
	
		-- case of too high of a reaction time
		if index > 12 then
			overflowCount = overflowCount + 1
		else
			local newDot = display.newCircle(group, dotXPos[index], dotYPos[index], 5)
			newDot:setFillColor(50,50,50)
			dotYPos[index] = dotYPos[index] - 20
		end
	end

	if overflowCount > 0 then
		print("user wasn't paying attention")
	end
	upapi.getSleepGraph(sleepGraphCallback)
	



	

end



-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
        local group = self.view


end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
        local group = self.view


end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view


end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
        local group = self.view


end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
        local group = self.view


end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
        local group = self.view
        local overlay_name = event.sceneName  -- name of the overlay scene


end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
        local group = self.view
        local overlay_name = event.sceneName  -- name of the overlay scene


end



---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene