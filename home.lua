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
local json = require("json")
local utils = require("utils")
local ball = require("ball")

display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background", 236, 240, 241 )

local gScale = 9.8*4


-- Initialize New Scene
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

function scene:createScene( event )
	local group = self.view


	local prison = utils.createBallPrison()

	if not event.params then
		event.params = {
			ballX =  display.contentWidth/2 + (math.random(-30,30)+10)*3,
			ballY =  display.contentHeight/4
		}
	end

	local bouncy = ball.create(event.params.ballX, event.params.ballY)

	-- Screen buttons

	local playButton = utils.createButton("play", display.contentWidth/2, display.contentHeight*3/5)
	local insightsButton = utils.createButton("insights", display.contentWidth/2, playButton.y + utils.buttonSep + playButton.height)	
	insightsButton.setActive( false )

	group:insert(prison)
	group:insert(bouncy)
	group:insert(playButton)
	group:insert(insightsButton)

	playButton.fadeIn()
	insightsButton.fadeIn()

	playButton.onClick(function(e)
		storyboard.gotoScene( "game", {effect="fade"})
	end)

-- Physics engine starts

	physics.start()
	physics.setGravity(0,1)
	
	prison.addToPhysics()

	physics.addBody(playButton, "dynamic", {friction=0.5, bounce=.9, density=1})
	physics.addBody(insightsButton, "dynamic", {friction=0.5, bounce=.9, density=1})
	physics.addBody(bouncy, {friction=0.5, bounce=1, radius = 36})

	local playJoin = physics.newJoint('pivot', playButton, prison.ceiling, playButton.x, playButton.y )
	local insightsJoint = physics.newJoint('pivot', insightsButton, prison.ceiling, insightsButton.x, insightsButton.y )

	bouncy:addEventListener( "touch", utils.dragBody )
	playButton:addEventListener( "touch", utils.dragBody )
	insightsButton:addEventListener( "touch", utils.dragBody )

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