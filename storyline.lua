-----------------------------------------------------------------------------------------
--
-- storyline.lua
--
-- A walkthrough for the user when they were about to play the game for the first time
--
-----------------------------------------------------------------------------------------

-- Libraries
local storyboard = require( "storyboard" )
local widget = require( "widget" )
local utils = require( "utils" )
local physics = require("physics")

display.setStatusBar( display.HiddenStatusBar )
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

local topTexts = {
	"This is Bouncy",
	"Why play with Bouncy?",
	"Bouncy is smarter with UP.",
	"Play with Bouncy for SCIENCE",
	"           ",
}

local bottomTexts1 = {
	"Bouncy helps you",
	"He'll tell you how your",
	"UP Measures sleep. And",
	"Be part of the largest study",
	"",
}
local bottomTexts2 = {
	"optimize your mental acuity.",
	"mood affects your speed.",
	"sleep affects mental acuity.",
	"on mood, sleep, and acuity.",
	"",
	
}


local smallTexts = {
	"Just by playing a simple reaction time game.",
	"Are you faster when happy?",
	"But by how much?!",
	"It's easier than donating organs!",
	"",
}

local bouncyImages = {
	"greenBouncy.png",
	"redBouncy.png",
	"orangeBouncy.png",
	"orangeBouncy.png"
}

function sign(number)
	if number > 0 then return 1 else return -1 end
end


function scene:createScene( event )
	local group = self.view

	local background = display.newRect(group, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(236, 240, 241)

	local function scrollListener( event )
		local phase = event.phase
	    local direction = event.direction
	    local target = event.target
	    if "began" == phase then
		    	startingX = target:getContentPosition()
		    	startingPanel = math.floor(math.abs(startingX)/display.contentWidth)
		    	print("starting position = " .. startingX)
	    elseif "moved" == phase then
		    if startingX then
		    	currentX = target:getContentPosition()
		    	diff = currentX - startingX
		    	print("displacement = ".. diff)

		    	if math.abs(diff) > 0.3 * display.contentWidth then
		    		-- user has scrolled to the last screen: special handling case
		    		if startingX == (-3) * display.contentWidth then
		    			if sign(diff) < 0 then
			    			target:scrollToPosition {x = startingPanel*sign(startingX)* display.contentWidth, y = 0}
			    		else
				    		target:scrollToPosition {x = (startingPanel*sign(startingX) + sign(diff)) * display.contentWidth, y = 0}
				    	end
				    -- code for the first 3 panels
					else -- LEGACY CODE: startingX > (-3)*display.contentWidth then
		    			target:scrollToPosition {x = (startingPanel*sign(startingX) + sign(diff)) * display.contentWidth, y = 0}
		    		end
		    	else
		    		target:scrollToPosition {x = startingPanel*sign(startingX)* display.contentWidth, y = 0}
		    	end
		    end
	        print( "Moved" )
	    elseif "ended" == phase then
	        print( "Ended" )
	    end

    -- If we have reached one of the scrollViews limits
    if event.limitReached then
        if "up" == direction then
            print( "Reached Top Limit" )
        elseif "down" == direction then
            print( "Reached Bottom Limit" )
        elseif "left" == direction then
            print( "Reached Left Limit" )
        elseif "right" == direction then
            print( "Reached Right Limit" )
        end
    end
	end

	-- scroll view for the storyline widget
	local scrollView = widget.newScrollView {
		top = 0,
		left = 0,
		width = display.contentWidth,
		height = display.contentHeight,
		scrollWdith = display.contentWidth * 4, 
		scrollHeight = display.contentHeight,
		hideBackground = true,
		verticalScrollDisabled = true,
		friction = 0.3,
		listener = scrollListener,
	}

	for i=1,table.getn(topTexts) do
		local line = display.newLine(i*display.contentWidth, 0, i*display.contentWidth, display.contentHeight)
		scrollView:insert(line)

		local topText = display.newText(group, topTexts[i], 0, 0, storyboard.states.font.bold, 18)
		topText:setReferencePoint(display.BottomCenterReferencePoint)
		topText.x = (i-0.5)*display.contentWidth
		topText.y = display.contentHeight/5
		topText:setTextColor(139, 155, 159)
		scrollView:insert(topText)

		local bottomText1 = display.newText(group, bottomTexts1[i], 0, 0, storyboard.states.font.bold, 18)
		bottomText1:setReferencePoint(display.BottomCenterReferencePoint)
		bottomText1.x = (i-0.5)*display.contentWidth
		bottomText1.y = display.contentHeight * 4/5
		bottomText1:setTextColor(149, 155, 159)
		scrollView:insert(bottomText1)

		local bottomText2 = display.newText(group, bottomTexts2[i], 0, 0, storyboard.states.font.bold, 18)
		bottomText2:setReferencePoint(display.BottomCenterReferencePoint)
		bottomText2.x = (i-0.5)*display.contentWidth
		bottomText2.y = display.contentHeight * 4/5 + bottomText1.height
		bottomText2:setTextColor(149, 155, 159)
		scrollView:insert(bottomText2)

		local smallText = display.newText(group, smallTexts[i], 0, display.contentHeight*4/5, storyboard.states.font.regular, 12)
		smallText:setReferencePoint(display.BottomCenterReferencePoint)
		smallText.x = (i-0.5)*display.contentWidth
		smallText.y = bottomText2.y + bottomText2.height
		smallText:setTextColor(189, 195, 199)
		scrollView:insert(smallText)
	end


	local ground = display.newLine(group, 0, display.contentHeight*3/4, 2*display.contentWidth, display.contentHeight*3/4)
	local bouncy = display.newImageRect(group, "orangeBouncy.png", 72, 72)
	bouncy.y = display.contentHeight/3
	bouncy.x = display.contentWidth/2


	physics.start()
	physics.setGravity(0,50)
	physics.addBody(ground, "static", {friction=0.5, bounce=1})
	physics.addBody(bouncy, "dynamic", {friction=0.5, bounce=1, radius=36})
	physics.setDrawMode("hybrid")

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