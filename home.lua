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

local gScale = 9.8


-- Initialize New Scene
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

function scene:createScene( event )
	local group = self.view

	-- Static groups 
	local staticGroup = display.newGroup()

	local bouncy = ball.create()

	local playButton = utils.createButton("play", display.contentWidth/2, display.contentHeight*3/5)
	local insightsButton = utils.createButton("insights", display.contentWidth/2, playButton.y + utils.buttonSep + playButton.height)	
	insightsButton.setActive( false )

	group:insert(bouncy)
	group:insert(playButton)
	group:insert(insightsButton)

	playButton.fadeIn()
	insightsButton.fadeIn()

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