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

	local progressIndicator = display.newGroup()
	progressIndicator:setReferencePoint(CenterReferencePoint)
	progressIndicator.x = display.contentWidth/2
	progressIndicator.y = display.contentHeight*24/25

	for i=1,5 do
		local circle = display.newCircle(0,0,5)
		progressIndicator:insert(circle, true)
		circle.x = -40 + (i-1)*20
	end
	progressIndicator[1]:setFillColor(176, 180, 181)
	group:insert(progressIndicator)


	local ground = display.newLine(group, 0, display.contentHeight*3/4, 2*display.contentWidth, display.contentHeight*3/4)
	ground.alpha = 0
	local sheet = graphics.newImageSheet( "storyline_sprites.png", {
	        width = 138,
	        height = 138,
	        numFrames = 5,
	    })

    local bouncy = display.newSprite( sheet, {start=1, count=5} )
    transition.to(bouncy, {time = 10, xScale=0.5, yScale=0.5})
    bouncy:setReferencePoint(display.CenterReferencePoint)
	bouncy.y = display.contentHeight/3
	bouncy.x = display.contentWidth/2
	group:insert(bouncy)


	physics.start()
	physics.setGravity(0,50)
	physics.addBody(ground, "static", {friction=0.5, bounce=1})
	physics.addBody(bouncy, "dynamic", {friction=0.5, bounce=1, radius=36})
	-- physics.setDrawMode("hybrid")

	local function scrollListener( event )
		local phase = event.phase
	    local direction = event.direction
	    local target = event.target
	    if "began" == phase then
		    	startingX = target:getContentPosition()
		    	panelIndex = math.floor(math.abs(startingX)/display.contentWidth)
		    	print("starting position = " .. startingX)
	    elseif "moved" == phase then
		    if startingX then
		    	currentX = target:getContentPosition()
		    	diff = currentX - startingX
		    	print("displacement = ".. diff)

		    	if math.abs(diff) > 0.3 * display.contentWidth then
		    		-- user has scrolled to the last screen: special handling case
		    		if startingX == (-4) * display.contentWidth then
		    			if sign(diff) < 0 then
			    			target:scrollToPosition {x = panelIndex*sign(startingX)* display.contentWidth, y = 0}
			    			bouncy:setFrame(panelIndex+1)
			    		else
				    		target:scrollToPosition {x = (panelIndex*sign(startingX) + sign(diff)) * display.contentWidth, y = 0}
				    		bouncy:setFrame(panelIndex+1-sign(diff))
				    		progressIndicator[panelIndex+1]:setFillColor(255,255,255)
				    		progressIndicator[panelIndex+1-sign(diff)]:setFillColor(176, 180, 181)

				    	end
				    elseif startingX == 0 then
				    	if sign(diff) > 0 then
			    			target:scrollToPosition {x = panelIndex*sign(startingX)* display.contentWidth, y = 0}
			    			bouncy:setFrame(panelIndex+1)
				    	else
				    		target:scrollToPosition {x = (panelIndex*sign(startingX) + sign(diff)) * display.contentWidth, y = 0}
				    		bouncy:setFrame(panelIndex+1-sign(diff))
				    		progressIndicator[panelIndex+1]:setFillColor(255,255,255)
				    		progressIndicator[panelIndex+1-sign(diff)]:setFillColor(176, 180, 181)
				    	end
				    -- code for the first 3 panels
					else -- LEGACY CODE: startingX > (-3)*display.contentWidth then
		    			target:scrollToPosition {x = (panelIndex*sign(startingX) + sign(diff)) * display.contentWidth, y = 0}
		    			bouncy:setFrame(panelIndex+1-sign(diff))
				    	progressIndicator[panelIndex+1]:setFillColor(255,255,255)
				    	progressIndicator[panelIndex+1-sign(diff)]:setFillColor(176, 180, 181)
		    		end
		    	else
		    		target:scrollToPosition {x = panelIndex*sign(startingX)* display.contentWidth, y = 0}
		    		bouncy:setFrame(panelIndex+1)
		    	end
		    end
	        print( "Moved" )
	    elseif "ended" == phase then
	        print( "Ended" )
	    end
	end

	-- scroll view for the storyline widget
	local scrollView = widget.newScrollView {
		top = 0,
		left = 0,
		width = display.contentWidth,
		height = display.contentHeight,
		scrollWdith = display.contentWidth * 5, 
		scrollHeight = display.contentHeight,
		hideBackground = true,
		verticalScrollDisabled = true,
		friction = 0.3,
		listener = scrollListener,
	}
	group:insert(scrollView)

	for i=1,table.getn(topTexts) do
		local line = display.newLine(i*display.contentWidth, 0, i*display.contentWidth, display.contentHeight)
		scrollView:insert(line)

		-- texts
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

	local line = display.newLine(5*display.contentWidth, 0, 5*display.contentWidth, display.contentHeight)
	scrollView:insert(line)


	local upBand = display.newImageRect("orange-up.png", 368, 250)
	upBand:setReferencePoint(display.CenterReferencePoint)
	transition.to(upBand, {time = 10, xScale=0.65, yScale=0.65})
	upBand.x = 2.5*display.contentWidth
	upBand.y = display.contentHeight/2
	scrollView:insert(upBand)

	local startButton = utils.createButton("start", display.contentWidth*4.5, display.contentHeight*3/4+30, display.contentWidth*3/4, 60)

	-- local rectangle = display.newRect(group, 0,0, 200, 60)
	function startButton:touch(event)
	    if event.phase == "moved" then
	        local dx = math.abs( event.x - event.xStart )
	        local dy = math.abs( event.y - event.yStart )

	        if dx > 5 or dy > 5 then
	            scrollView:takeFocus( event )
	        end
	    elseif event.phase == "ended" then
		    display.getCurrentStage():setFocus(nil)
		    event.target:removeEventListener("touch", ontouch)
		    event.target:removeSelf()
		    storyboard.gotoScene("welcome") 
	        print("event ended")
	    end

	    return true
	end
	startButton:addEventListener("touch", ontouch)
	scrollView:insert(startButton)
	


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