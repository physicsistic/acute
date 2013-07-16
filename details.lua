-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-- Welcome screen for the game. Options to go to the menu or to play game.
--
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local json = require("json")

local upapi = require "upapi"
local scene = storyboard.newScene()

-- Resolution properties
local pixelPerInch = 163
local pointPerInch = 72
local pointPerPixel = pointPerInch / pointPerInch

local textBackgroundHeight = math.round(display.contentHeight / 12)
local textBackgroundWidth = display.contentWidth / 2
local fieldSeparationHeight = display.contentHeight / 12
local logoutButtonHeight = math.round(textBackgroundHeight * 0.8)
local logoutButtonWidth = math.round(display.contentWidth / 3)
local logoutTextSize = math.round(logoutButtonHeight * 0.5 * pointPerPixel)

function  scene:createScene(event)
	print("details page")
	local group = self.view
	local background = display.newRect( group, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor( 230, 230, 230 )
	userInfo = upapi.readFile(storyboard.states.userInfoFilePath)
	userInfoJSON = json.decode(userInfo)
	local firstName = userInfoJSON["user"]["first"]
	local lastName = userInfoJSON["user"]["last"]

	local firstNameDisplay = display.newText( group, firstName, 0, 0, storyboard.states.font.bold, 36)
	firstNameDisplay:setTextColor( 30, 30, 30 )
	firstNameDisplay:setReferencePoint(display.CenterReferencePoint)
	firstNameDisplay.x = display.contentWidth/2
	firstNameDisplay.y = display.contentHeight/5

	local statsGroup = display.newGroup()
	statsGroup.x = display.contentWidth/2
	statsGroup.y = display.contentHeight/2

	local userRanking, fastestTime, meanTime = nil


	-- Displays for user stats
	local rankingLabel = display.newText( group, "rank", 0, 0, storyboard.states.font.bold, 24)
	statsGroup:insert(rankingLabel)
	rankingLabel:setReferencePoint(display.TopRightReferencePoint)
	rankingLabel.x = - display.contentWidth / 20
	rankingLabel.y = - display.contentHeight / 20 * 3
	
	local rankingNum = display. newText( group, "1", 0, 0, storyboard.states.font.bold, 24)
	statsGroup:insert(rankingNum)
	rankingNum:setReferencePoint(display.TopLeftReferencePoint)
	rankingNum.x = display.contentWidth / 20
	rankingNum.y = - display.contentHeight / 20 * 3

	local meanLabel = display.newText( group, "average", 0, 0, storyboard.states.font.bold, 24)
	statsGroup:insert(meanLabel)
	meanLabel:setReferencePoint(display.TopRightReferencePoint)
	meanLabel.x = - display.contentWidth / 20
	meanLabel.y = - display.contentHeight / 20 

	local meanNum = display.newText( group, "0.156", 0, 0, storyboard.states.font.bold, 24)
	statsGroup:insert(meanNum)
	meanNum:setReferencePoint(display.TopLeftReferencePoint)
	meanNum.x = display.contentWidth / 20
	meanNum.y = - display.contentHeight / 20


	local fastestLabel = display.newText( group, "fastest", 0, 0, storyboard.states.font.bold, 24)
	statsGroup:insert(fastestLabel)
	fastestLabel:setReferencePoint(display.TopRightReferencePoint)
	fastestLabel.x = - display.contentWidth / 20
	fastestLabel.y = display.contentHeight / 20

	local fastestNum = display.newText( group, "0.080", 0, 0, storyboard.states.font.bold, 24)
	statsGroup:insert(fastestNum)
	fastestNum:setReferencePoint(display.TopLeftReferencePoint)
	fastestNum.x = display.contentWidth / 20
	fastestNum.y = display.contentHeight / 20

	for i = 1, statsGroup.numChildren do
		statsGroup[i]:setTextColor(100, 100, 100)
	end
	
	group:insert(statsGroup)


	-- Logout button display
	function logoutHandler( event )
		upapi.logout()
		storyboard.gotoScene("welcome")
	end

	-- PLay button display
	function playHandler( event )
		upapi.logout()
		storyboard.gotoScene("game")
	end

	logoutButton = display.newGroup()
	logoutBackground = display.newRoundedRect(group, 0, 0, logoutButtonWidth, logoutButtonHeight, logoutButtonHeight/2)
	logoutBackground:setFillColor(250, 119, 91)
	local logoutLabel = display.newText(group, "logout", 0, 0, storyboard.states.font.bold, logoutTextSize)
	logoutLabel:setTextColor(230,230,230)
	logoutLabel:setReferencePoint(display.BottomCenterReference)
	logoutButton.x = display.contentWidth * 3 / 4
	logoutButton.y = display.contentHeight - logoutButtonHeight * 1.75
	logoutButton:insert(logoutLabel, true)
	logoutButton:insert(1, logoutBackground, true)
	logoutBackground:addEventListener("touch", logoutHandler)
	group:insert(logoutButton)

	playButton = display.newGroup()
	playBackground = display.newRoundedRect(group, 0, 0, logoutButtonWidth, logoutButtonHeight, logoutButtonHeight/2)
	playBackground:setFillColor(43, 217, 69)
	local playLabel = display.newText(group, "play", 0, 0, storyboard.states.font.bold, logoutTextSize)
	playLabel:setTextColor(230,230,230)
	playLabel:setReferencePoint(display.BottomCenterReference)
	playButton.x = display.contentWidth / 4
	playButton.y = display.contentHeight - logoutButtonHeight * 1.75
	playButton:insert(playLabel, true)
	playButton:insert(1, playBackground, true)
	playBackground:addEventListener("touch", playHandler)
	group:insert(playButton)


	local function sleepEventsCallback(callbackError, result)
		if not callbackError then 
			storyboard.states.sleepData = json.decode(result)
		else
			print("Error in getting sleep event data.")
		end
	end 

	local function moodEventsCallback(callbackError, result)
		if not callbackError then 
			storyboard.states.moodData = json.decode(result)
		else
			print("Error in getting mood event data.")
		end
	end 

	upapi.getUserMetrics("sleeps", sleepEventsCallback)
	upapi.getUserMetrics("mood", moodEventsCallback)


	
end


function scene:enterScene( event )
	local group = self.view
	storyboard.purgeScene( "loginScreen" )

	-- Create user on Firebase
	local xid = upapi.readFile(storyboard.states.userXIDPath)
	print("xid registered on the details page is = " .. xid)
	
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