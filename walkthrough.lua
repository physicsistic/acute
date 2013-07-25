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
	local bannerHeight = display.contentHeight/10

	local walkthroughView = native.newWebView( 0, bannerHeight, display.contentWidth, display.contentHeight-bannerHeight)
	walkthroughView:request("walkthrough.html", system.ResourceDirectory)

	local bannerBackground = display.newRect(group, 0,0, display.contentWidth, bannerHeight)
	bannerBackground:setFillColor(189, 195, 199)

	local check = display.newImageRect(group, "check.png", bannerHeight/2, bannerHeight/2)
	check.x = display.contentWidth-bannerHeight/2
	check.y = bannerHeight/2
	function check:touch(event)
		if event.phase == "ended" then
			-- check:removeEventListener("touch", check)
			walkthroughView:removeSelf()
			storyboard.gotoScene("welcome", {effect="slideLeft"})
		end
	end
	check:addEventListener("touch", check)

	local text = display.newText(group, "swipe for walkthrough", 0, 0, storyboard.states.font.regular, 14)
	text:setReferencePoint(display.CenterReferencePoint)
	text.x = (display.contentWidth-bannerHeight)/2
	text.y = bannerHeight/2


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