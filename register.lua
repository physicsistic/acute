-----------------------------------------------------------------------------------------
--
-- register.lua
--
-- a webview for user to register for a new account
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local upapi = require( "upapi" )
local json = require( "json" )
local math = require( "math" )
local native = require( "native" )
local utils = require( "utils" )

local scene = storyboard.newScene()


local fieldParams = {}
fieldParams.width = display.contentWidth * 3/4
fieldParams.height = display.contentHeight/12

local bannerHeight = display.contentHeight/10

local signupInfo = {}

function createTextField(name, x, y, width, height) -- where x and y are both top left referenced
	local fieldGroup = display.newGroup()
	local field = native.newTextField(x, y, width, height)
	field.font = native.newFont(storyboard.states.font.regular, 24)
	field.hasBackground = false
	field:setTextColor(189, 195, 199)
	fieldGroup:insert(field)
	field.align = "center"

	local fieldBackground = display.newRect(x, y, width, height)
	-- fieldBackground:setFillColor(189, 195, 199)
	

	local fieldLabel = display.newText(name, 0, 0, storyboard.states.font.regular, 16)
	fieldLabel:setReferencePoint(display.CenterReferencePoint)
	fieldLabel.x = field.x 
	fieldLabel.y = field.y
	fieldLabel:setTextColor(189, 195, 199)
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

	-- assets

	local background = display.newRect( group, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(236, 240, 241)

	local topBar = utils.createTopBar("signup")

	-- local banner = display.newRect(group, 0, 0, display.contentWidth, bannerHeight)
	-- banner:setFillColor(189, 195, 199)

	-- local backButton = display.newImageRect(group, "arrow_left_clouds.png", bannerHeight/2, bannerHeight/2)
	-- backButton.x = bannerHeight/2
	-- backButton.y = bannerHeight/2
	
	-- local checkMarkBackground = display.newRect(group, display.contentWidth - bannerHeight, 0, bannerHeight, bannerHeight)
	-- checkMarkBackground:setFillColor(46, 204, 113)

	-- local checkMark = display.newImageRect(group, "check.png", bannerHeight/2, bannerHeight/2)
	-- checkMark.x = display.contentWidth - bannerHeight/2
	-- checkMark.y = bannerHeight/2

	-- local signupText = display.newText(group, "signup", 0, 0, storyboard.states.font.bold, 24)
	-- signupText:setReferencePoint(display.CenterReferencePoint)
	-- signupText.x = display.contentWidth/2
	-- signupText.y = bannerHeight/2


	firstNameGroup = createTextField("first", display.contentWidth/8, bannerHeight + 20, fieldParams.width/2-5, fieldParams.height)
	lastNameGroup = createTextField("last", display.contentWidth/2+5, bannerHeight + 20, fieldParams.width/2-5, fieldParams.height)
	emailGroup = createTextField("email", display.contentWidth/8, firstNameGroup[2].y + 10 + fieldParams.height/2, fieldParams.width, fieldParams.height)
	passwordGroup = createTextField("password", display.contentWidth/8, emailGroup[2].y + 10 + fieldParams.height/2, fieldParams.width, fieldParams.height)
	passwordGroup[1].isSecure = true

	group:insert(firstNameGroup)
	group:insert(lastNameGroup)
	group:insert(emailGroup)
	group:insert(passwordGroup)
	-- signupButton = createButton("signup", display.contentWidth/8, passwordGroup[2].y+10+fieldParams.height/2, fieldParams.width, fieldParams.height)

	function genericFieldListener(event)
		local field = event.target
		local phase = event.phase

		if phase == "began" then
			field.parent[3].alpha = 0
		elseif phase == "submitted" then
			print( field.text )
		elseif phase == "ended" then
			if string.len(field.text) == 0 then
				field.parent[3].alpha = 1
			else
				print(field.parent[3].text)
				signupInfo[field.parent[3].text] = field.text
			end
		end
	end

	firstNameGroup[1]:addEventListener("userInput", genericFieldListener)
	lastNameGroup[1]:addEventListener("userInput", genericFieldListener)
	emailGroup[1]:addEventListener("userInput", genericFieldListener)
	passwordGroup[1]:addEventListener("userInput", genericFieldListener)

	-- Navigation
	function backwardCallback(event)
		if event.phase == "ended" then
			event.target.parent:removeSelf()
			storyboard.gotoScene("welcome",  {effect="slideRight"})
		end
	end

	topBar.backwardClick(backwardCallback)

	function forwardCallback(event)
		if event.phase == "ended" then
			print("user clicked signup check mark")
			upapi.signup(signupInfo, callback)
		end
	end

	topBar.forwardClick(forwardCallback)

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