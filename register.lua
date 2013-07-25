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
	field.align = "center"
	if name == "password" then field.isSecure = true end

	local fieldBackground = display.newRect(x, y, width, height)

	local fieldLabel = display.newText(name, 0, 0, storyboard.states.font.regular, 16)
	fieldLabel:setReferencePoint(display.CenterReferencePoint)
	fieldLabel.x = field.x 
	fieldLabel.y = field.y
	fieldLabel:setTextColor(189, 195, 199)
	fieldGroup:insert(fieldBackground)
	fieldGroup:insert(fieldLabel)
	fieldGroup:insert(field)

	return fieldGroup
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- assets

	local background = display.newRect( group, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(236, 240, 241)

	local topBar = utils.createTopBar("signup")


	firstNameGroup = createTextField("first", display.contentWidth/8, bannerHeight + 20, fieldParams.width/2-5, fieldParams.height)
	lastNameGroup = createTextField("last", display.contentWidth/2+5, bannerHeight + 20, fieldParams.width/2-5, fieldParams.height)
	emailGroup = createTextField("email", display.contentWidth/8, firstNameGroup[2].y + 10 + fieldParams.height/2, fieldParams.width, fieldParams.height)
	passwordGroup = createTextField("password", display.contentWidth/8, emailGroup[2].y + 10 + fieldParams.height/2, fieldParams.width, fieldParams.height)


	-- signupButton = createButton("signup", display.contentWidth/8, passwordGroup[2].y+10+fieldParams.height/2, fieldParams.width, fieldParams.height)

	function genericFieldListener(event)
		local field = event.target
		local phase = event.phase

		if phase == "began" then
			field.parent[2].alpha = 0
		elseif phase == "submitted" then
			print( field.text )
		elseif phase == "ended" then
			if string.len(field.text) == 0 then
				field.parent[2].alpha = 1
			else
				print(field.parent[2].text)
				signupInfo[field.parent[2].text] = field.text
			end
		end
	end

	firstNameGroup[3]:addEventListener("userInput", genericFieldListener)
	lastNameGroup[3]:addEventListener("userInput", genericFieldListener)
	emailGroup[3]:addEventListener("userInput", genericFieldListener)
	passwordGroup[3]:addEventListener("userInput", genericFieldListener)

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
			local function registrationCallback(loginError, result)
				event.target.parent:removeSelf()
				print("Program should only come here when there is no login error.\n Login succeeded.")
				upapi.writeFile(storyboard.states.userInfoFilePath, result)

				local token = response["token"]
				local xid = response["user"]["xid"]
				storyboard.states.loginToken = token
				storyboard.states.userXID = xid

				local userInfo = {}
				userInfo["gender"] = response["user"]["gender"]
				userInfo["height"] = response["user"]["basic_info"]["height"]
				userInfo["weight"] = response["user"]["basic_info"]["weight"]
				userInfo["dob"] = response["user"]["basic_info"]["dob"]
				userInfo["name"] = response["user"]["first"] .. "_" .. response["user"]["last"]

				-- add data to firebase for syncing
				local appStateData = {}
				appStateData["token"] = token
				appStateData["userXID"] = xid

				upapi.createFirebaseUser(xid, userInfo)

				-- store data locally
				local file = io.open(storyboard.states.userTokenFilePath, "w")
				file:write(token)
				io.close(file)


				local file = io.open(storyboard.states.userXIDFilePath, "w")
				file:write(xid)
				io.close(file)

				local file = io.open(storyboard.states.userReturnedFilePath, "w")
				file:write("logged")
				io.close(file)

				loadingWidget:stop()
				loadingWidget:removeSelf()
				storyboard.gotoScene("home", {effect="slideLeft"})
			end
			upapi.signup(signupInfo, registrationCallback)
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
	firstNameGroup:removeEventListener("userInput", genericFieldListener)
	lastNameGroup:removeEventListener("userInput", genericFieldListener)
	emailGroup:removeEventListener("userInput", genericFieldListener)
	passwordGroup:removeEventListener("userInput", genericFieldListener)
	
	native.setKeyboardFocus(nil)

	firstNameGroup:removeSelf()
	lastNameGroup:removeSelf()
	emailGroup:removeSelf()
	passwordGroup:removeSelf()

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