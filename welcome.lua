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
display.setDefault( "background", 236, 240, 241 )

local shadowParams = {}
shadowParams.short = 12
shadowParams.long = 36

local gScale = 9.8*4
local deltaT = 10
local deltaX = 20

-- A general function for dragging physics bodies
local function dragBody( event )
    local body = event.target
    local phase = event.phase
    local stage = display.getCurrentStage()

    if "began" == phase then
        stage:setFocus( body, event.id )
        body.isFocus = true

        -- Create a temporary touch joint and store it in the object for later reference
        body.tempJoint = physics.newJoint( "touch", body, event.x, event.y )

    elseif body.isFocus then
        if "moved" == phase then
        
            -- Update the joint to track the touch
            body.tempJoint:setTarget( event.x, event.y )

        elseif "ended" == phase or "cancelled" == phase then
            stage:setFocus( body, nil )
            body.isFocus = false
            
            -- Remove the joint when the touch ends                 
            body.tempJoint:removeSelf()
                
        end
    end

    -- Stop further propagation of touch event
    return true
end


-- Initialize New Scene
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

local function createButton(label, x, y, width, height)
	local button = display.newGroup()
	button.x = x
	button.y = y
	local buttonBackground = display.newRect(0, 0, width, height)
	buttonBackground:setFillColor(46, 204, 113)
	buttonBackground:setStrokeColor(236, 240, 241)
	buttonBackground.strokeWidth = 1
	local buttonLabel = display.newText(label, 0, 0, storyboard.states.font.bold, 20)
	button:insert(buttonLabel, true)
	button:insert(1, buttonBackground, true)
	button.bg = buttonBackground
	return button
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

	-- Physics walls

	local ground = display.newLine(staticGroup, 0, display.contentHeight, 2*display.contentWidth, display.contentHeight)
	local leftWall = display.newLine(staticGroup, 0, 0, 0, 2*display.contentHeight)
	local rightWall = display.newLine(staticGroup, display.contentWidth, 0, display.contentWidth, 2*display.contentHeight)
	local ceiling = display.newLine(staticGroup, 0, 0, 2*display.contentWidth, 0)

	group:insert(staticGroup)	

	-- Screen buttons

	local loginButton = createButton("login with UP", display.contentWidth/2, display.contentHeight*3/5, buttonWidth, buttonHeight)
	local signupButton = createButton("register", display.contentWidth/2, loginButton.y + buttonSep + buttonHeight, buttonWidth, buttonHeight)
	
	group:insert(loginButton)
	group:insert(signupButton)

	function activeStateHandler(event)
		if event.phase == "began" then
			event.target.alpha = 0.8
			event.target.cancelButton = false
			display.getCurrentStage():setFocus(event.target)
		elseif event.phase == "moved" then
			event.target.alpha = 1
			event.target.cancelButton = true
		elseif event.phase == "ended" or event.phase == "cancelled" then
			event.target.alpha = 1
			display.getCurrentStage():setFocus(nil)	
		end
	end

	function ifPressedGotoScene( event, sceneName )
		if event.phase == "ended" and not event.target.cancelButton then
			Runtime:removeEventListener("enterFrame", shadowChange)
			for i=1, #staticGroup do
				physics.removeBody(staticGroup[i])
			end
			storyboard.gotoScene( sceneName )
		end
	end

	
	loginButton:addEventListener("touch", function(e)
		activeStateHandler(e)
		ifPressedGotoScene(e, 'loginScreen')
	end)


	signupButton:addEventListener("touch", function(e)
		activeStateHandler(e)
		ifPressedGotoScene(e, 'register')
	end)

	loginButton.alpha = 0
	signupButton.alpha = 0

	local showIt = {time = 500, alpha = 1}
	transition.to( loginButton, showIt )
	transition.to( signupButton, showIt )

	-- Mr. Bouncy himself

	local sheet = graphics.newImageSheet( "sphere-sheet.png", {
    	width = 72,
    	height = 72,
    	numFrames = 2,
	})
	local bouncy = display.newSprite( sheet, {start=1, count=2} )
	bouncy:setReferencePoint(display.CenterReferencePoint)

	if not event.params then
		event.params = {
			ballX =  display.contentHeight/6,
			ballY =  display.contentWidth/2
		}
	end

	bouncy.x = event.params.ballX
	bouncy.y = event.params.ballY
	

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
	
	for i=1, staticGroup.numChildren do 
		staticGroup[i].alpha = 0
		physics.addBody(staticGroup[i], "static", {friction=0.5, bounce=1})
		-- group:insert(staticGroup[i])
	end
	physics.addBody(loginButton, "dynamic", {friction=0.5, bounce=.9, density=1})
	physics.addBody(signupButton, "dynamic", {friction=0.5, bounce=.9, density=1})
	physics.addBody(bouncy, {friction=0.5, bounce=1, radius = 36})

	local loginJoint = physics.newJoint('pivot', loginButton, ceiling, loginButton.x, loginButton.y )
	local signupJoint = physics.newJoint('pivot', signupButton, ceiling, signupButton.x, signupButton.y )

	local range = 25

	loginJoint.isLimitEnabled = true
	signupJoint.isLimitEnabled = true
	loginJoint:setRotationLimits( -range, range )
	signupJoint:setRotationLimits( -range, range )

	bouncy:addEventListener( "touch", dragBody )
	loginButton:addEventListener( "touch", dragBody )
	signupButton:addEventListener( "touch", dragBody )

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