-----------------------------------------------------------------------------------------
--
-- walkthrough.lua
--
-- A walkthrough for new user
--
-----------------------------------------------------------------------------------------

-- Libraries
local storyboard = require( "storyboard" )
local widget = require( "widget" )

display.setStatusBar( display.HiddenStatusBar )
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true


function scene:createScene( event )
	local group = self.view

	local background = display.newRect( group, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(236, 240, 241)

	local topText = display.newText( group, "This is Bouncy.", 0, 0, storyboard.states.font.bold, 28)
	topText:setReferencePoint(display.CenterReferencePoint)
	topText.x = display.contentWidth/2
	topText.y = display.contentHeight/6

	local bottomText = display.newText( group, "Bouncy likes to play.", 0, 0, storyboard.states.font.bold, 28)
	bottomText:setReferencePoint(display.CenterReferencePoint)
	bottomText.x = display.contentWidth/2
	bottomText.y = display.contentHeight*5/6
	
	local ground = display.newLine(0, display.contentHeight*4/6, 2*display.contentWidth, display.contentHeight*4/6)
	local bouncy = display.newImageRect("orangeBouncy.png", 48,48)
	bouncy:setReferencePoint(display.CenterReferencePoint)
	bouncy.x = display.contentWidth/2
	bouncy.y = display.contentHeight/3

	physics.start()
	physics.setGravity(0,1)
	physics.addBody(ground, "static", {friction=0.5, bounce=1})
	physics.addBody(bouncy, {friction=0.5, bounce=1, radius = 48})
	bouncy.gravityScale = gScale
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