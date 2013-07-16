-----------------------------------------------------------------------------------------
--
-- mood.lua
--
-- A screen to the user to choose current mood of the day
--
-----------------------------------------------------------------------------------------

-- Libraries
local storyboard = require "storyboard" 
local widget = require( "widget" )
local upapi = require "upapi"
local math = require( "math")
local physics = require("physics")

display.setStatusBar( display.HiddenStatusBar )
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

local colorSchemes = {
	{231, 76, 60}, -- red
	{230, 126, 34}, -- orange
	{241, 196, 15}, -- yellow
	{39, 174, 96}, -- green
	{41, 128, 185}, -- blue
	{44, 62, 80}, -- dark blue
}

local moodSchemes = {
	"amazing",
	"energized",
	"good",
	"meh",
	"dragging",
	"exhausted",
}


function scene:createScene( event )
	local group = self.view
	
	local background = display.newRect(group, 0,0,display.contentWidth,display.contentHeight)
	background:setFillColor(236, 240, 241)


	-- instruction group for the slider
	local instructionGroup = display.newGroup()
	instructionGroup.x = display.contentWidth * 7/8
	instructionGroup.y = display.contentHeight/2

	local instructionText = display.newText("slide", 0, 0,storyboard.states.font.bold, 24)
	instructionGroup:insert(instructionText,true)
	instructionText:setTextColor(189, 195, 199)
	local upArrow = display.newImageRect("arrow_up.png", 48, 48)
	instructionGroup:insert(upArrow, true)
	upArrow.y = -50
	local downArrow = display.newImageRect("arrow_down.png", 48, 48)
	instructionGroup:insert(downArrow, true)
	downArrow.y = 50

	local questionBackground = display.newRect(0, 0, display.contentWidth, display.contentHeight/12)
	questionBackground:setFillColor(189, 195, 199)
	group:insert(questionBackground)

	local questionText = display.newText("How do you feel today?", 0, 0, storyboard.states.font.bold, 18)
	questionText:setReferencePoint(display.CenterLeftReferencePoint)
	questionText:setTextColor(236, 240, 241)
	questionText.x = 10
	questionText.y = display.contentHeight/24
	group:insert(questionText)
	


	local moodText = display.newText("", 0, 0, storyboard.states.font.bold, 36)
	moodText:setTextColor(236, 240, 241)
	moodText.y = display.contentHeight/2
	group:insert(moodText)

	local checkMark = nil



	function checkTouchHeight(event)
		if event.phase == "moved" or event.phase == "began" then
			local offset = display.contentHeight/12
			local colorIndex = math.floor((event.y - offset)/ ((display.contentHeight-offset)/6)) + 1
			-- set color scheme
			if colorIndex > 0 and colorIndex < 7 then
				background:setFillColor(colorSchemes[colorIndex][1], colorSchemes[colorIndex][2], colorSchemes[colorIndex][3])
				moodText.text = moodSchemes[colorIndex]
				moodText.x = display.contentWidth/2
				storyboard.states.userMood = moodSchemes[colorIndex]
			end
		end
	end

	function onActivation( event )
		if event.phase == "began" then
			instructionGroup:removeSelf()
			Runtime:removeEventListener("touch", onActivation)
			checkMark = display.newImageRect("check.png", 32, 26)
			checkMark:setReferencePoint(display.CenterRightReferencePoint)
			checkMark.x = display.contentWidth - 10
			checkMark.y = display.contentHeight/24
			function checkMark:touch( event )
				if event.phase == "ended" then
					storyboard.gotoScene("game")
				end
			end
			checkMark:addEventListener("touch", checkMark)
			group:insert(checkMark)

		end
	end

	Runtime:addEventListener("touch", checkTouchHeight)
	Runtime:addEventListener("touch", onActivation)
end

function scene:enterScene( event )
	local group = self.view	
end

function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener("touch", checkTouchHeight)
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