-----------------------------------------------------------------------------------------
--
-- errorScreen.lua
--
-- Display error message when something went wrong and allow user to restart action
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

function scene:createScene( event )
	local group = self.view
	
	local background = display.newRect(group, 0,0,display.contentWidth,display.contentHeight)
	background:setFillColor(236, 240, 241)



	local errorMessage = display.newText("Oops. Something went wrong.", 0, 0 , storyboard.states.font.regular, 18)
	errorMessage:setReferencePoint(display.centerReferencePoint)
	errorMessage.x = display.contentWidth/2
	errorMessage.y = display.contentHeight/2
	errorMessage:setTextColor(189, 195, 199)




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