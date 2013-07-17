-----------------------------------------------------------------------------------------
--
-- register.lua
--
-- a webview for user to register for a new account
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local upapi = require "upapi"
local json = require("json")
local math = require "math"
local native = require "native"

local scene = storyboard.newScene()


local fieldParams = {}
fieldParams.width = display.contentWidth * 3/4
fieldParams.height = display.contentHeight/12

function createTextField(name, x, y, width, height) -- where x and y are both top left referenced
	local fieldGroup = display.newGroup()
	local field = native.newTextField(x, y, width, height)
	field.font = native.newFont(storyboard.states.font.regular, 24)
	field.hasBackground = false
	field:setTextColor(236, 240, 241)
	fieldGroup:insert(field)

	local fieldBackground = display.newRect(x, y, width, height)
	fieldBackground:setFillColor(189, 195, 199)
	

	local fieldLabel = display.newText(name, 0, 0, storyboard.states.font.regular, 16)
	fieldLabel:setReferencePoint(display.CenterReferencePoint)
	fieldLabel.x = field.x 
	fieldLabel.y = field.y
	fieldLabel:setTextColor(236, 240, 241)
	fieldGroup:insert(fieldBackground)
	fieldGroup:insert(fieldLabel)

	return fieldGroup
end

function createButton(label, x, y, width, height)
	local buttonGroup = display.newGroup()

	local background = display.newRect(x, y, width, height)
	background:setFillColor(46, 204, 113)
	

	local label = display.newText(label, 0, 0, storyboard.states.font.regular, 16)
	label:setReferencePoint(display.CenterReferencePoint)
	label.x = background.x 
	label.y = background.y
	label:setTextColor(236, 240, 241)
	buttonGroup:insert(background)
	buttonGroup:insert(label)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	local background = display.newRect( group, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(236, 240, 241)

	local firstNameGroup = createTextField("first", display.contentWidth/8, display.contentHeight/20, fieldParams.width/2-5, fieldParams.height)
	local lastNameGroup = createTextField("last", display.contentWidth/2+5, display.contentHeight/20, fieldParams.width/2-5, fieldParams.height)
	local emailGroup = createTextField("email", display.contentWidth/8, firstNameGroup[2].y + 10 + fieldParams.height/2, fieldParams.width, fieldParams.height)
	local passwordGroup = createTextField("password", display.contentWidth/8, emailGroup[2].y + 10 + fieldParams.height/2, fieldParams.width, fieldParams.height)

	local signupButton = createButton("signup", display.contentWidth/8, passwordGroup[2].y+10+fieldParams.height/2, fieldParams.width, fieldParams.height)

	function firstNameListener(event)
		print("hello")
		if event.phase == "ended" or event.phase == "submitted" then
			native.setKeyboardFocus(lastNameGroup[1])
			firstNameGroup[3]:removeSelf()
			print( event.target.text )
		end
	end

	function lastNameListener(event)
		if event.phase == "ended" then
			native.setKeyboardFocus(emailGroup[1])
		end
	end

	function emailListener(event)
		if event.phase == "ended" then
			native.setKeyboardFocus(passwordGroup[1])
		end
	end
	print(tostring(firstNameGroup[1].inputType))
	firstNameGroup[1]:addEventListener("userInput", firstNameListener)

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
        local group = self.view


end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
        local group = self.view


end



-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
        local group = self.view


end




---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )


-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )


---------------------------------------------------------------------------------

return scene