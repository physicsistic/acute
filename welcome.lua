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

-- Local variables for parameters in this screen
local buttonHeight = display.contentHeight / 10
local buttonWidth = display.contentWidth * 3/4
local buttonSep = display.contentHeight / 20


display.setStatusBar( display.HiddenStatusBar )
local shadowParams = {}
shadowParams.short = 12
shadowParams.long = 36

local gScale = 9.8*4
local deltaT = 10
local deltaX = 20




-- Initialize New Scene
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

local function createButton(label, x, y, width, height)
	local button = display.newGroup()
	button.x = x
	button.y = y
	local buttonBackground = display.newRect(0, 0, width, height)
	buttonBackground:setFillColor(46, 204, 113)
	local buttonLabel = display.newText(label, 0, 0, storyboard.states.font.bold, 20)
	button:insert(buttonLabel, true)
	button:insert(1, buttonBackground, true)
	return button
end

local function wobble(obj)
	
	local goCenter = function (obj) transition.to(obj, {time=deltaT, x = x+deltaX}) end
	local goLeft = function (obj) transition.to(obj, {time=deltaT*2, x = x - deltaX*2, onComplete = goCenter}) end
	transition.to(obj, {time=deltaT, x = x + deltaX, onComplete = goLeft})
end

--
function scene:createScene( event )
	local group = self.view

	-- Static groups 
	local staticGroup = display.newGroup()

	-- Background Color
	local background = display.newRect(group, 0,0,display.contentWidth,display.contentHeight)
	background:setFillColor(236, 240, 241)
	group:insert(background)

	local loginButton = createButton("login with UP", display.contentWidth/2, display.contentHeight*3/5, buttonWidth, buttonHeight)
	group:insert(loginButton)

	function loginButton:touch(event)
		if event.phase == "ended" then
			Runtime:removeEventListener("enterFrame", shadowChange)
			for i=1,staticGroup.numChildren do
				physics.removeBody(staticGroup[i])
			end
			storyboard.gotoScene("loginScreen")
			
		end
	end
	loginButton:addEventListener("touch", loginButton)

	local signupButton = createButton("register", display.contentWidth/2, loginButton.y + buttonSep + buttonHeight, buttonWidth, buttonHeight)
	group:insert(signupButton)

	function signupButton:touch(event)
		if event.phase == "ended" then
			Runtime:removeEventListener("enterFrame", shadowChange)
			for i=1,staticGroup.numChildren do
				physics.removeBody(staticGroup[i])
			end
			storyboard.gotoScene("register")
		end
	end
	signupButton:addEventListener("touch", signupButton)

	
	local ground = display.newLine(staticGroup, 0, display.contentHeight, 2*display.contentWidth, display.contentHeight)
	local leftWall = display.newLine(staticGroup, 0, 0, 0, 2*display.contentHeight)
	local rightWall = display.newLine(staticGroup, display.contentWidth, 0, display.contentWidth, 2*display.contentHeight)
	local ceiling = display.newLine(staticGroup, 0, 0, 2*display.contentWidth, 0)


	local bouncy = display.newImageRect("sphere.png", 72, 72)
	bouncy:setReferencePoint(display.CenterReferencePoint)
	bouncy.x = display.contentWidth/2
	bouncy.y = display.contentHeight/6



	group:insert(bouncy)
	
	group:insert(staticGroup)

	
	

	-- Physics engine starts
	physics.start()
	physics.setGravity(0,1)
	print(staticGroup.numChildren)
	for i=1,staticGroup.numChildren do 
		staticGroup[i].alpha = 0
		physics.addBody(staticGroup[i], "static", {friction=0.5, bounce=1})
		-- group:insert(staticGroup[i])
	end
	physics.addBody(loginButton, "static", {friction=0.5, bounce=1})
	physics.addBody(bouncy, {friction=0.5, bounce=1, radius = 36})
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