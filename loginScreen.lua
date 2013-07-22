-----------------------------------------------------------------------------------------
--
-- loginScreen.lua
--
-- Login screen for the user authentification process
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local math = require( "math" )
local json = require( "json" )
local upapi = require( "upapi" )
local utils = require( "utils" )


local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true

local fieldParams = {}
fieldParams.width = display.contentWidth * 3/4
fieldParams.height = display.contentHeight/12

local bannerHeight = display.contentHeight/10

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

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	local movingGroup = display.newGroup()

	local background = display.newRect( group, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(236, 240, 241)

	local topBar = utils.createTopBar("login")




	emailGroup = createTextField("email", display.contentWidth/8, bannerHeight + 20, fieldParams.width, fieldParams.height)
	passwordGroup = createTextField("password", display.contentWidth/8, emailGroup[2].y + 10 + fieldParams.height/2, fieldParams.width, fieldParams.height)
	-- passwordGroup[3].isSecure = true


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
			end
		end
	end

	emailGroup[3]:addEventListener("userInput", genericFieldListener)
	passwordGroup[3]:addEventListener("userInput", genericFieldListener)

	-- Navigation
	function backwardCallback(event)
		if event.phase == "ended" then
			event.target.parent:removeSelf()
			storyboard.gotoScene("welcome", {effect="slideRight"})
		end
	end
	

	-- Login button handler
	function forwardCallback( event )
		if event.phase == "ended" then
			if (string.len(passwordGroup[3].text) > 0) and (string.len(emailGroup[3].text) > 0) then
				-- Login callback
				local function loginCallback(loginError, result)
					print("Are there any login errors?")
					print(loginError)
					if not loginError then
						response = json.decode(result)

						if response["error"] then
							print("Login failed. Please try again.")
							local wrongInfoPrompt = display.newText("darn. check what you typed!", 0, 0, storyboard.states.font.regular, 16)
							wrongInfoPrompt:setReferencePoint(display.TopCenterReferencePoint)
							wrongInfoPrompt.x = display.contentWidth / 2
							wrongInfoPrompt.y = passwordGroup[3].y + fieldParams.height
							wrongInfoPrompt:setTextColor(39, 174, 96)

							timer.performWithDelay(750, function() wrongInfoPrompt:removeSelf() end)

						else
							event.target.parent:removeSelf()
							print("Program should only come here when there is no login error.\n Login succeeded.")
							upapi.writeFile(storyboard.states.userInfoFilePath, result)

							local token = response["token"]
							local xid = response["user"]["xid"]
							local userInfo = {}
							userInfo["gender"] = response["user"]["gender"]
							userInfo["height"] = response["user"]["basic_info"]["height"]
							userInfo["weight"] = response["user"]["basic_info"]["weight"]
							userInfo["dob"] = response["user"]["basic_info"]["dob"]
							userInfo["name"] = response["user"]["first"] .. "_" .. response["user"]["last"]

							upapi.createFirebaseUser(xid, userInfo)
							upapi.writeFile(storyboard.states.userXIDPath, xid)
							storyboard.states.userXID = xid						
							print("login token = " .. token)
							print("user xid = " .. xid)
							upapi.writeFile(storyboard.states.upAPILoginTokenPath, token)
							storyboard.states.loginToken = token

							storyboard.gotoScene("home", {effect="slideLeft"})
							
						end
					else
						print( "Error in getting response.")
					end
				end
				upapi.login(emailGroup[3].text, passwordGroup[3].text, loginCallback)
			else
				print("Missing login information called")
				local missingInfoPrompt = display.newText("oops. you forgot something!", 0, 0, storyboard.states.font.regular, 16)
				missingInfoPrompt:setReferencePoint(display.TopCenterReferencePoint)
				missingInfoPrompt.x = display.contentWidth / 2
				missingInfoPrompt.y = passwordGroup[3].y + fieldParams.height
				missingInfoPrompt:setTextColor(39, 174, 96)
				timer.performWithDelay(750, function() missingInfoPrompt:removeSelf() end)
			end
			passwordGroup[3].text = nil
			emailGroup[3].text = nil
		end
	end

	topBar.backwardClick(backwardCallback)
	topBar.forwardClick(forwardCallback)
	group:insert(emailGroup)
	group:insert(passwordGroup)


end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view


end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	passwordGroup[3]:removeEventListener( "userInput", genericFieldListener )
	emailGroup[3]:removeEventListener( "userInput", genericFieldListener)

	native.setKeyboardFocus(nil)

	-- Manually remove all field objects
	passwordGroup:removeSelf()
	emailGroup:removeSelf()
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
end

---------------------------------------------------------------------------------
-- END OF IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )

scene:addEventListener( "enterScene", scene )

scene:addEventListener( "exitScene", scene )

scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene
