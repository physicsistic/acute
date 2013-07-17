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

local moodSchemes = {
	"amazing",
	"energized",
	"good",
	"meh",
	"dragging",
	"exhausted",
	"totall done",
}

local bannerHeight = display.contentHeight/10

function scene:createScene( event )
	local group = self.view
	
	local background = display.newRect(group, 0,0,display.contentWidth,display.contentHeight)
	background:setFillColor(236, 240, 241)

	local banner = display.newRect(group, 0, 0, display.contentWidth, bannerHeight)
	banner:setFillColor(189, 195, 199)

	local backButton = display.newImageRect(group, "arrow_left_clouds.png", bannerHeight/2, bannerHeight/2)
	backButton.x = bannerHeight/2
	backButton.y = bannerHeight/2
	
	local loginButton = display.newRect(group, display.contentWidth - bannerHeight, 0, bannerHeight, bannerHeight)
	loginButton:setFillColor(46, 204, 113)

	local checkMark = display.newImageRect(group, "check.png", bannerHeight/2, bannerHeight/2)
	checkMark.x = display.contentWidth - bannerHeight/2
	checkMark.y = bannerHeight/2

	local signupText = display.newText(group, "how do you feel?", 0, 0, storyboard.states.font.bold, 18)
	signupText:setReferencePoint(display.CenterReferencePoint)
	signupText.x = display.contentWidth/2
	signupText.y = bannerHeight/2


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



	local moodText = display.newText("", 0, 0, storyboard.states.font.bold, 36)
	moodText:setTextColor(236, 240, 241)
	moodText.y = display.contentHeight/2
	group:insert(moodText)


	function checkTouchHeight(event)
		if event.phase == "moved" or event.phase == "began" then
			local offset = display.contentHeight/12
			local colorIndex = math.floor((event.y - offset)/ ((display.contentHeight-offset)/7)) + 1
			if colorIndex > 0 and colorIndex < 7 then

			end
		end
	end

	function onActivation( event )
		if event.phase == "began" then
			instructionGroup:removeSelf()
			Runtime:removeEventListener("touch", onActivation)

			function checkMark:touch( event )
				if event.phase == "ended" then
					storyboard.gotoScene("game")
				end
			end
			checkMark:addEventListener("touch", checkMark)
			group:insert(checkMark)

		end
	end

    local moodSheet = graphics.newImageSheet( "Moods@2x.png", {
        width = 144,
        height = 144,
        numFrames = 7,
    })

    local bouncyMood = display.newSprite( moodSheet, {start=4, count=7} )
    bouncyMood:setReferencePoint(display.CenterReferencePoint)
    bouncyMood.x = display.contentWidth/2
    bouncyMood.y = display.contentHeight/2

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