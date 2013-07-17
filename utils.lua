local storyboard = require "storyboard" 
local M = {}

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

return M