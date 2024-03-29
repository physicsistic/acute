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
	"not so good",
	"exhausted",
	"dead",
}

local bannerHeight = display.contentHeight/10

function scene:createScene( event )
	local group = self.view
	
	local background = display.newRect(group, 0,0,display.contentWidth,display.contentHeight)
	background:setFillColor(236, 240, 241)

	local topBar = utils.createTopBar("how ya feeling?")

	group:insert(topBar)


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

	utils.fadeIn(instructionGroup)
	utils.fadeIn(topBar)


	local moodText = display.newText("", 0, 0, storyboard.states.font.bold, 36)
	moodText:setTextColor(189, 195, 199)
	moodText.y = display.contentHeight*3/4
	group:insert(moodText)


	function onActivation( event )
		if event.phase == "began" then
			transition.to(instructionGroup, {
				alpha=0,
				time=200,
				onComplete = function()
					instructionGroup:removeSelf()
				end
			})
			Runtime:removeEventListener("touch", onActivation)
		end
	end

    local moodSheet = graphics.newImageSheet( "Moods@2x.png", {
        width = 288,
        height = 288,
        numFrames = 7,
    })


    local bouncyMood = display.newSprite( moodSheet, {start=1, count=7, loopCount=0} )
    bouncyMood:setFrame(2)
    bouncyMood.curFrame = 2
    bouncyMood.alpha = 0
    storyboard.states.userMood = 2 -- set default user mood to 2
    bouncyMood.lastAnimation = 0
    bouncyMood:setReferencePoint(display.CenterReferencePoint)
    bouncyMood.x = display.contentWidth/2
    bouncyMood.y = display.contentHeight/2
    transition.to(bouncyMood, {time=5, xScale = 0.5, yScale = 0.5})
    transition.to(bouncyMood, {time=10, alpha = 1})
    group:insert(bouncyMood)


	function checkTouchHeight(event)
		if event.phase == "moved" or event.phase == "began" then
			local offset = display.contentHeight/12
			local index = math.floor((event.y - bannerHeight)/ ((display.contentHeight - bannerHeight)/7)) + 1
			if index > 0 and index < 8 then
				if index ~= bouncyMood.curFrame and system.getTimer()-bouncyMood.lastAnimation > 300 then
					utils.wobble(bouncyMood, (8-index)/3, 0.5)
					bouncyMood.curFrame = index
					bouncyMood.lastAnimation = system.getTimer()
				end
				bouncyMood:setFrame(index)
				moodText.text = moodSchemes[index]
				moodText.x = display.contentWidth/2
				storyboard.states.userMood = index
			end
		end

	end

	function forwardCallback(event)
		storyboard.gotoScene("game", {effects=fade})
	end

	function backwardCallback(event)
		storyboard.gotoScene("home", {effects=fade})
	end

	topBar.forwardClick(forwardCallback)
	topBar.backwardClick(backwardCallback)

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