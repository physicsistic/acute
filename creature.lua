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

local colorSchemes = {
	{44, 62, 80}, -- dark blue
	{41, 128, 185}, -- blue
	{39, 174, 96}, -- green
	{241, 196, 15}, -- yellow
	{230, 126, 34}, -- orange
	{231, 76, 60}, -- red
}

local moodSchemes = {
	"exhausted",
	"dragging",
	"meh",
	"good",
	"energized",
	"amazing",
}

local function blink(obj)
	local blinkTime = 250
	local function restore()
		transition.to(obj, {time=blinkTime, height=15})
	end
	transition.to(obj, {time=blinkTime, height=0, onComplete=restore})
	-- timer.performWithDelay(510, transition.to(obj, {time=500, height=15}))
end

local function jump(obj)
	local blinkTime = 250
	local function restore()
		transition.to(obj, {time=100, height = obj.height*10/9})
	end
	local function squeeze()
		transition.to(obj, {time=100, height = obj.height*9/10, onComplete=restore})
	end
	local function down()
		transition.to(obj, {time=blinkTime, y = obj.y+40})
	end
	local function up()
		transition.to(obj, {time=blinkTime, height= obj.height *5/4, y = obj.y - 40, onComplete=down})
	end
	transition.to(obj, {time=100, height = obj.height*4/5, onComplete=up})
end


function scene:createScene( event )
	local group = self.view
	
	local background = display.newRect(group, 0,0,display.contentWidth,display.contentHeight)
	background:setFillColor(236, 240, 241)

	local creature = display.newGroup()
	creature:setReferencePoint(display.CenterReferencePoint)
	local figure = display.newImageRect(creature, "figure.png", 200, 200)
	figure.x = display.contentWidth/2
	figure.y = display.contentHeight/2

	local shadow = display.newImageRect(creature, "shadow.png", 100, 30)
	shadow.x = figure.x + 20
	shadow.y = figure.y + figure.height/2 - 5
	shadow:toBack()
	local leftEye = display.newImageRect(creature, "eye.png", 10, 15)
	leftEye.x = figure.x - 10
	leftEye.y = figure.y - figure.height/4

	local rightEye = display.newImageRect(creature, "eye.png", 10, 15)
	rightEye.x = figure.x + 10
	rightEye.y = figure.y - figure.height/4

	local mouth = display.newImageRect(creature, "mouth.png", 120, 30)
	mouth.x = figure.x 
	mouth.y = figure.y + 10

	function animateEyes()
		blink(leftEye)
		blink(rightEye)
	end

	function hyperCreature()
		jump(figure)
		jump(leftEye)
		jump(rightEye)
		jump(mouth)
	end

	timer.performWithDelay(4500, animateEyes, 0)
	timer.performWithDelay(2000, hyperCreature, 0)

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