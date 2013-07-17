-----------------------------------------------------------------------------------------
--
-- waiting.lua
--
-- The waitng screen when the time for rematch hasn't been reached
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
	group:insert(background)

	local info = display.newText(group, "under construction", 0, 0, storyboard.states.font.bold, 24)
	info:setReferencePoint(display.CenterReferencePoint)
	info.x = display.contentWidth/2
	info.y = display.contentHeight/2
	info:setTextColor(127, 140, 141)
	group:insert(info)

	local backArrow = display.newImageRect("arrow_left.png",36,36)
	backArrow.x = 20
	backArrow.y = 20
	group:insert(backArrow)

	function backArrow:touch(event)
		if event.phase == "ended" then
			storyboard.gotoScene("home")
		end
	end
	backArrow:addEventListener("touch", backArrow)


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