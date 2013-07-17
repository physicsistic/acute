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
	local walkthroughView = native.newWebView( 0, 0, display.contentWidth, display.contentHeight)
	walkthroughView:request("walkthrough.html", system.ResourceDirectory)

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