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
local upapi = require "upapi"

local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true


-- -- Resolution properties
-- local pixelPerInch = 163
-- local pointPerInch = 72
-- local pointPerPixel = pointPerInch / pointPerInch


-- -- Display object properties
-- local textBackgroundHeight = math.round(display.contentHeight / 12)
-- local textBackgroundWidth = display.contentWidth / 4 * 3
-- local fieldSeparationHeight = display.contentHeight / 18

-- local loginButtonHeight = math.round(textBackgroundHeight * 0.8)
-- local loginButtonWidth = math.round(display.contentWidth / 3)
-- local fieldFontSize = math.round(textBackgroundHeight * 0.8 * pointPerPixel)
-- local fieldInfoFontSize = math.round(fieldFontSize / 2)
-- local fieldLabelFontSize = math.round(fieldFontSize * 0.8)
-- local loginTextSize = math.round(loginButtonHeight * 0.5 * pointPerPixel)

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

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------
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
---------------------------------------------------------------------------------
-- BEGINNING OF IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	local movingGroup = display.newGroup()

	local background = display.newRect( group, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(236, 240, 241)


	local banner = display.newRect(group, 0, 0, display.contentWidth, bannerHeight)
	banner:setFillColor(189, 195, 199)

	local backButton = display.newImageRect(group, "arrow_left_clouds.png", bannerHeight/2, bannerHeight/2)
	backButton.x = bannerHeight/2
	backButton.y = bannerHeight/2
	
	local loginButton = display.newRect(group, display.contentWidth - bannerHeight, 0, bannerHeight, bannerHeight)
	loginButton:setFillColor(46, 204, 113)

	local checkMark = display.newImageRect(group, "check.png", bannerHeight/2, bannerHeight/2)
	checkMark.x = display.contentWidth - bannerHeight/2
	checkMark.y = bannerHeight/2

	local signupText = display.newText(group, "login", 0, 0, storyboard.states.font.bold, 24)
	signupText:setReferencePoint(display.CenterReferencePoint)
	signupText.x = display.contentWidth/2
	signupText.y = bannerHeight/2


	emailGroup = createTextField("email", display.contentWidth/8, bannerHeight + 20, fieldParams.width, fieldParams.height)
	passwordGroup = createTextField("password", display.contentWidth/8, emailGroup[2].y + 10 + fieldParams.height/2, fieldParams.width, fieldParams.height)
	passwordGroup[1].isSecure = true

	group:insert(emailGroup)
	group:insert(passwordGroup)

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
			end
		end
	end

	emailGroup[1]:addEventListener("userInput", genericFieldListener)
	passwordGroup[1]:addEventListener("userInput", genericFieldListener)

	-- Navigation
	function backButton:touch(event)
		if event.phase == "ended" then
			storyboard.gotoScene("welcome", {effect="slideRight"})
		end
	end
	backButton:addEventListener("touch", backButton)	
	-- local emailFieldParams = {}
	-- emailFieldParams.x = display.contentWidth/2 - textBackgroundWidth/2
	-- emailFieldParams.y = (display.contentHeight/2 - 2 * textBackgroundHeight - fieldSeparationHeight) / 2

	-- emailFieldBackground = display.newRect(group, emailFieldParams.x, emailFieldParams.y, textBackgroundWidth, textBackgroundHeight)
	-- emailFieldBackground:setFillColor(189, 195, 199)

	-- -- Email input field
	-- emailField = native.newTextField( emailFieldParams.x, emailFieldParams.y, textBackgroundWidth, textBackgroundHeight, emailListener)
	-- emailField.align = "center"
	-- emailField.inputType = "email"
	-- emailField.font = native.newFont(storyboard.states.font.regular, 24)
	-- emailField:setReferencePoint(display.BottomCenterReferencePoint)
	-- emailField.hasBackground = false
	-- emailField:setTextColor(236, 240, 241)

	-- local emailLabel = display.newText(group, "email", 0, 0, storyboard.states.font.regular, fieldFontSize / 3)
	-- emailLabel:setReferencePoint(display.BottomCenterReference)
	-- emailLabel:setTextColor(127, 140, 141)
	-- emailLabel.x = display.contentWidth / 2
	-- emailLabel.y = emailFieldParams.y - textBackgroundHeight / 3
	-- movingGroup:insert(emailLabel)


	-- local pwdFieldParams = {}
	-- pwdFieldParams.x = display.contentWidth/2 - textBackgroundWidth/2
	-- pwdFieldParams.y = (display.contentHeight/2 - 2 * textBackgroundHeight - fieldSeparationHeight) / 2 + textBackgroundHeight + fieldSeparationHeight

	-- -- Password input field
	-- pwdField = native.newTextField(pwdFieldParams.x, pwdFieldParams.y, textBackgroundWidth, textBackgroundHeight, pwdListener)
	-- pwdField.align = "center"
	-- pwdField.isSecure = true
	-- pwdField.size = native.newFont(storyboard.states.font.regular, 24)
	-- pwdField.hasBackground = false
	-- pwdField.alpha = 0
	-- emailField:setTextColor(236, 240, 241)


	-- -- Email input label
	-- local pwdLabel = display.newText(group, "password", 0, 0, storyboard.states.font.regular, fieldFontSize / 3)
	-- pwdLabel:setReferencePoint(display.BottomCenterReference)
	-- pwdLabel:setTextColor(127, 140, 141)
	-- pwdLabel.x = display.contentWidth / 2
	-- pwdLabel.y = pwdFieldParams.y - textBackgroundHeight / 3
	-- movingGroup:insert(pwdLabel)
	-- group:insert(movingGroup)
	-- -- Password field background
	-- pwdFieldBackground = display.newRect(group, pwdFieldParams.x, pwdFieldParams.y, textBackgroundWidth, textBackgroundHeight)
	-- pwdFieldBackground:setFillColor(189, 195, 199)

	-- function pwdFieldBackground:touch(event)
	-- 	if event.phase == "began" then
	-- 		native.setKeyboardFocus(pwdField)
	-- 	end
	-- end

	-- pwdFieldBackground:addEventListener("touch", pwdFieldBackground)

	-- pwdFieldInput = display.newText(group, "", 0, 0, storyboard.states.font.regular, fieldInfoFontSize)
	-- pwdFieldInput:setReferencePoint(display.LeftCenterReferencePoint)
	-- pwdFieldInput.x = pwdField.x
	-- pwdFieldInput.y = pwdField.y

	-- -- Login button display

	-- local loginButton = createButton("login", display.contentWidth / 2, pwdField.y + loginButtonHeight + fieldSeparationHeight, display.contentWidth * 3/4, textBackgroundHeight)
	

	-- group:insert(loginButton)


	-- -- Email Listener
	-- function emailListener( event )
	-- 	if event.phase == "began" then
 --    	elseif event.phase == "editing" then
 --    		-- emailFieldInput.text = event.text
 --    		-- if emailFieldInput.width > textBackgroundWidth then
 --    		-- 	emailFieldInput.size = emailFieldInput.size * 2/3
 --    		-- elseif emailFieldInput.width < textBackgroundWidth * 2/3 and emailFieldInput.size < fieldInfoFontSize then
 --    		-- 	emailFieldInput.size = emailFieldInput.size * 3/2
 --    		-- end
 --    		-- print(emailFieldInput.width)
	--     elseif event.phase == "submitted" then

	--     	if string.len(pwdField.text) == 0 then
	-- 	    	native.setKeyboardFocus( pwdField )
	--     	end

	--     end
	-- end

	-- -- Password Listener
	-- function pwdListener( event )
	-- 	if event.phase == "began" then
	-- 	elseif event.phase == "editing" then
	-- 		-- local n = string.len(pwdField.text)
	-- 		-- pwdFieldInput.text = string.rep("*", n)
	-- 		-- if pwdFieldInput.width > textBackgroundWidth then
 --   --  			pwdFieldInput.size = pwdFieldInput.size * 2/3
 --   --  		elseif pwdFieldInput.width < textBackgroundWidth * 2/3 and pwdFieldInput.size < fieldInfoFontSize then
 --   --  			pwdFieldInput.size = pwdFieldInput.size * 3/2
 --   --  		end
 --   --  		print(pwdFieldInput.width)
	--     elseif event.phase == "submitted" then

 --    		if string.len(emailField.text) == 0 then
	-- 	    	native.setKeyboardFocus( emailField )
	-- 	    end
	   
	--     end
	-- end

	

	-- Login button handler
	function loginButton:touch( event )
		if event.phase == "ended" then
			if (string.len(passwordGroup[1].text) > 0) and (string.len(emailGroup[1].text) > 0) then
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
							wrongInfoPrompt.y = passwordGroup[1].y + fieldParams.height
							wrongInfoPrompt:setTextColor(39, 174, 96)

							timer.performWithDelay(750, function() wrongInfoPrompt:removeSelf() end)

						else
							print("Program should only come here when there is no login error.\n Login succeeded.")
							loginButton:removeEventListener("touch", loginButton)
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

							storyboard.gotoScene("waiting")
							
						end
					else
						print( "Error in getting response.")
					end
				end
				upapi.login(emailGroup[1].text, passwordGroup[1].text, loginCallback)
			else
				print("Missing login information called")
				local missingInfoPrompt = display.newText("oops. you forgot something!", 0, 0, storyboard.states.font.regular, 16)
				missingInfoPrompt:setReferencePoint(display.TopCenterReferencePoint)
				missingInfoPrompt.x = display.contentWidth / 2
				missingInfoPrompt.y = passwordGroup[1].y + fieldParams.height
				missingInfoPrompt:setTextColor(39, 174, 96)
				timer.performWithDelay(750, function() missingInfoPrompt:removeSelf() end)
			end
			passwordGroup[1].text = nil
			emailGroup[1].text = nil
		end
	end
	emailGroup[1]:addEventListener("userInput", genericFieldListener)
	passwordGroup[1]:addEventListener("userInput", genericFieldListener)
	loginButton:addEventListener("touch", loginButton)

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view


end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	--loginBackground:removeEventListener( "touch", loginButton )
	passwordGroup[1]:removeEventListener( "userInput", genericFieldListener )
	emailGroup[1]:removeEventListener( "userInput", genericFieldListener)

	native.setKeyboardFocus(nil)

	-- Manually remove all field objects
	passwordGroup[1]:removeSelf()
	emailGroup[1]:removeSelf()
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
