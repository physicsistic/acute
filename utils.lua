local storyboard = require "storyboard" 
local M = {}

function physicsStateHandler(event, callback)
	if event.phase == "began" then
		event.target.alpha = 0.8
		event.target.cancelButton = false
		display.getCurrentStage():setFocus(event.target)
	elseif event.phase == "moved" then
		-- Threshold of 5 pixels
		if math.sqrt(math.pow(event.x-event.xStart, 2) + math.pow(event.y-event.yStart, 2)) > 5 then
			event.target.alpha = 1
			event.target.cancelButton = true
		end
	elseif event.phase == "ended" or event.phase == "cancelled" then
		print(event.target.cancelButton)
		event.target.alpha = 1
		display.getCurrentStage():setFocus(nil)	
		if event.target.cancelButton == false then
			callback(event)
		end
	end
end

function moveBouncy(obj, deltaX, deltaY, objScale)
	transition.to(obj, {time = 100, xScale = objScale + deltaX, yScale = objScale + deltaY})
end

function M.wobble(obj, wobbleScale, objScale)
	if objScale == nil then objScale = 1 end
	if wobbleScale == nil then wobbleScale = 1 end
	moveBouncy(obj, .3*wobbleScale, -.3*wobbleScale, objScale)
	timer.performWithDelay(100, function () moveBouncy(obj, -.2*wobbleScale, .2*wobbleScale, objScale) end)
	timer.performWithDelay(200, function () moveBouncy(obj, .1*wobbleScale, -.1*wobbleScale, objScale) end)
	timer.performWithDelay(300, function () moveBouncy(obj, 0, 0, objScale) end)
end

function M.fadeIn( obj, time )
	obj.alpha = 0
	transition.to( obj, {time=time or 500, alpha = 1})
end

function M.fadeOut( obj, time )
	obj.alpha = 1
	transition.to( obj, {time=time or 500, alpha = 0})
end

function M.createButton(label, x, y, width, height)
	local defaultButtonHeight = display.contentHeight / 10
	local defaultButtonWidth = display.contentWidth * 3/4

	if width == nil  then width  = defaultButtonWidth end
	if height == nil then height = defaultButtonHeight end 


	local button = display.newGroup()
	button.x = x
	button.y = y
	local buttonBackground = display.newRect(0, 0, width, height)
	buttonBackground:setStrokeColor(236, 240, 241)
	buttonBackground.strokeWidth = 1
	local buttonLabel = display.newText(label, 0, 0, storyboard.states.font.bold, 20)
	button:insert(buttonLabel, true)
	button:insert(1, buttonBackground, true)
	button.bg = buttonBackground

	function button.setActive( isActive )
		if isActive then
			buttonBackground:setFillColor(46, 204, 113)
		else
			buttonBackground:setFillColor(200,200,200)
		end
	end

	function button.fadeIn(time)
		button.alpha = 0
		if time == nil then time = 500 end
		transition.to( button, {time = time, alpha = 1} )
	end

	function button.fadeOut(time)
		button.alpha = 0
		if time == nil then time = 500 end
		transition.to( button, {time = time, alpha = 0} )
	end

	function button.onClick(callback)
		button:addEventListener("touch", function(e)
			physicsStateHandler( e, callback )
		end)
	end

	function button.setWidth( width )
		buttonBackground.width = width
	end

	function  button.setHeight( height )
		buttonBackground.height = height
	end
	function button.setColor(r, g, b)
		buttonBackground:setFillColor(r, g, b)
	end

	function button.setFontSize(size)
		buttonLabel.size = size
		-- body
	end
	button.setActive( true )

	return button
end

M.buttonSep = display.contentHeight / 20

-- A general function for dragging physics bodies
function M.dragBody( event )
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

function M.createBallPrison()
	-- Static groups 
	local staticGroup = display.newGroup()

	-- Physics walls

	staticGroup.ground = display.newLine(staticGroup, 0, display.contentHeight, 2*display.contentWidth, display.contentHeight)
	staticGroup.left = display.newLine(staticGroup, 0, 0, 0, 2*display.contentHeight)
	staticGroup.right = display.newLine(staticGroup, display.contentWidth, 0, display.contentWidth, 2*display.contentHeight)
	staticGroup.ceiling = display.newLine(staticGroup, 0, 0, 2*display.contentWidth, 0)

	function staticGroup.addToPhysics()
		for i=1, staticGroup.numChildren do
			staticGroup[i].alpha = 0
			physics.addBody(staticGroup[i], "static", {friction=0.5, bounce=1})
		end
	end

	function staticGroup.removeFromPhysics()
		for i=1, staticGroup.numChildren do
			physics.removeBody(staticGroup[i])
		end
	end

	return staticGroup
end

function M.createTopBar(text, needCheck)
	local bannerHeight = display.contentHeight/10

	local banner = display.newGroup()
	local bannerBackground = display.newRect(banner, 0,0, display.contentWidth, bannerHeight)
	bannerBackground:setFillColor(189, 195, 199)

	local back = display.newImageRect(banner, "arrow_left_clouds.png", bannerHeight/2, bannerHeight/2)
	back.x = bannerHeight/2
	back.y = bannerHeight/2

	local text = display.newText(banner, text, 0, 0, storyboard.states.font.regular, 24)
	text:setReferencePoint(display.CenterReferencePoint)
	text.x = display.contentWidth/2
	text.y = bannerHeight/2

	if needCheck == nil or needCheck == true then
		checkMarkBackground = display.newRect(banner, display.contentWidth-bannerHeight, 0, bannerHeight, bannerHeight)
		checkMarkBackground:setFillColor(46, 204, 113)

		checkMark = display.newImageRect(banner, "check.png", bannerHeight/2, bannerHeight/2)
		checkMark.x = display.contentWidth - bannerHeight/2
		checkMark.y = bannerHeight/2
	else
		text.x = text.x + back.width
	end

	function banner.backwardClick(callback)
		back:addEventListener("touch", callback)
	end

	function banner.forwardClick(callback)
		if checkMarkBackground then
			checkMarkBackground:addEventListener("touch", callback)
		end
	end

	banner.height = bannerHeight

	return banner
end

function M.generateBackground(r, g, b)
	local background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
	if r and g and b then
		background:setFillColor(r, g, b)
	else
		background:setFillColor(236, 240, 241)
	end
end



return M