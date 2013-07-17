-----------------------------------------------------------------------------------------
--
-- mood.lua
--
-- A screen to the user to choose current mood of the day
--
-----------------------------------------------------------------------------------------

-- Libraries
local storyboard = require( "storyboard" )
local widget = require( "widget" )
local upapi = require( "upapi" )
local math = require( "math")
local physics = require("physics" )
local utils = require( 'utils' )

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

	local topBar = utils.createTopBar("feeling?")

	function backwardCallback(event)
		if event.phase == "ended" then
			event.target.parent:removeSelf()
			storyboard.gotoScene("home",  {effect="slideRight"})
		end
	end
	topBar.backwardClick(backwardCallback)


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

			function forwardCallback( event )
				if event.phase == "ended" then
					event.target.parent:removeSelf()
					storyboard.gotoScene("game", {effects="fade"})
				end
			end

			topBar.forwardClick(forwardCallback)

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