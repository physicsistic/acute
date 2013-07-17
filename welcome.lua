-----------------------------------------------------------------------------------------
--
-- welcome.lua
--
-- Welcome screen for the game. Options to go to the Details or to play game.
--
-----------------------------------------------------------------------------------------

-- Libraries
local storyboard = require "storyboard" 
local widget = require( "widget" )
local upapi = require "upapi"
local math = require( "math")
local physics = require("physics")
local utils = require("utils")
local ball = require("ball")

-- Local variables for parameters in this screen



display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "background", 236, 240, 241 )

local gScale = 9.8*4
local deltaT = 10
local deltaX = 20


-- Initialize New Scene
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

--
function scene:createScene( event )
	
	local group = self.view

	local prison = utils.createBallPrison()
	group:insert(prison)

	-- Screen buttons

	local loginButton = utils.createButton("login with UP", display.contentWidth/2, display.contentHeight*3/5)
	local signupButton = utils.createButton("register", display.contentWidth/2, loginButton.y + utils.buttonSep + loginButton.height)
	
	group:insert(loginButton)
	group:insert(signupButton)

	loginButton.onClick(function(e)
		storyboard.gotoScene( 'loginScreen', {effect = "slideLeft"})	
	end)

	signupButton.onClick(function(e)
		storyboard.gotoScene( 'register', {effect = "slideLeft"})	
	end)

	loginButton.fadeIn()
	signupButton.fadeIn()

	-- Mr. Bouncy himself

	if not event.params then
		event.params = {
			ballX =  display.contentWidth/2 + (math.random(-30,30)+10)*3,
			ballY =  display.contentHeight/4
		}
	end

	local bouncy = ball.create(event.params.ballX, event.params.ballY)

	function bouncy:touch ( event )
		if event.phase == "began" then
			event.target:setFrame(2)
		elseif event.phase == "ended" then
			event.target:setFrame(1)
		end
	end

	bouncy:addEventListener( "touch", bouncy )
	group:insert(bouncy)


	-- Physics engine starts

	physics.start()
	physics.setGravity(0,1)
	
	prison.addToPhysics()

	physics.addBody(loginButton, "dynamic", {friction=0.5, bounce=.9, density=1})
	physics.addBody(signupButton, "dynamic", {friction=0.5, bounce=.9, density=1})
	physics.addBody(bouncy, {friction=0.5, bounce=1, radius = 36})

	local loginJoint = physics.newJoint('pivot', loginButton, prison.ceiling, loginButton.x, loginButton.y )
	local signupJoint = physics.newJoint('pivot', signupButton, prison.ceiling, signupButton.x, signupButton.y )

	local range = 25

	loginJoint.isLimitEnabled = true
	signupJoint.isLimitEnabled = true
	loginJoint:setRotationLimits( -range, range )
	signupJoint:setRotationLimits( -range, range )

	bouncy:addEventListener( "touch", utils.dragBody )
	loginButton:addEventListener( "touch", utils.dragBody )
	signupButton:addEventListener( "touch", utils.dragBody )

	bouncy.gravityScale = gScale
	


	-- Accelerometer 
	system.setAccelerometerInterval( 50 )
	function onAccelerate(event)
		physics.setGravity(event.xInstant + event.xGravity, (event.yInstant + event.yGravity)*(-1))
		local function resetGravityListener () 
			physics.setGravity(event.xGravity, 1) 
		end
		timer.performWithDelay(50, resetGravityListener)
	end

	Runtime:addEventListener("accelerometer", onAccelerate)

end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener("accelerometer", onAccelerate)
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