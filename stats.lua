-----------------------------------------------------------------------------------------
--
-- stats.lua
--
-- summary of user's performance 
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local upapi = require "upapi"
local json = require("json")
local math = require "math"

local scene = storyboard.newScene()


local bannerHeight = display.contentHeight / 15
local cardHeight = display.contentHeight / 6

local function createButton(label, x, y, width, height)
	local button = display.newGroup()
	button.x = x
	button.y = y
	local buttonBackground = display.newRect(0, 0, width, height)
	buttonBackground:setFillColor(230, 126, 34)
	local buttonLabel = display.newText(label, 0, 0, storyboard.states.font.bold, 20)
	button:insert(buttonLabel, true)
	button:insert(1, buttonBackground, true)
	return button
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	local background = display.newRect( group, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(236, 240, 241)


	local banner = display.newGroup()

	local bannerBackground = display.newRect(0, 0, display.contentWidth, bannerHeight)
	bannerBackground:setFillColor(236, 240, 241)
	local bannerText = display.newText("cool bounce!", 0, 0, storyboard.states.font.bold, 24)
	bannerText:setTextColor(107, 120, 121)
	banner:insert(1, bannerBackground, true)
	banner:insert(bannerText, true)
	banner.x = display.contentWidth/2
	banner.y = bannerHeight
	group:insert(banner)


	local aveCard = display.newGroup()
	local aveCardBackground = display.newRect(0, 0, display.contentWidth/2, cardHeight)
	aveCardBackground:setFillColor(189, 195, 199)
	local aveCardLabel = display.newText("average", 0, 0, storyboard.states.font.regular, 16)
	local aveCardInfo = display.newText("0.233s", 0, 0, storyboard.states.font.bold, 40)
	aveCardInfo:setTextColor(127, 140, 141)
	aveCardLabel:setTextColor(236, 240, 241)
	aveCard:insert(1, aveCardBackground, true)
	aveCard:insert(aveCardLabel, true)
	aveCard:insert(aveCardInfo, true)
	aveCard.x = display.contentWidth/4 - 5
	aveCard.y = banner.y + bannerHeight + cardHeight/2
	aveCardLabel.y = cardHeight / 4
	aveCardInfo.y = (-1) * cardHeight / 8
	aveCardInfo.text = string.format("%.3fs",sessionData.aveReactTime)
	group:insert(aveCard)

	local bestCard = display.newGroup()
	local bestCardBackground = display.newRect(0, 0, display.contentWidth/2, cardHeight)
	bestCardBackground:setFillColor(189, 195, 199)
	local bestCardLabel = display.newText("best", 0, 0, storyboard.states.font.regular, 16)
	local bestCardInfo = display.newText("0.178s", 0, 0, storyboard.states.font.bold, 40)
	bestCardInfo:setTextColor(127, 140, 141)
	bestCardLabel:setTextColor(236, 240, 241)
	bestCard:insert(1, bestCardBackground, true)
	bestCard:insert(bestCardLabel, true)
	bestCard:insert(bestCardInfo, true)
	bestCard.x = display.contentWidth * 3/4 + 2
	bestCard.y = banner.y + bannerHeight + cardHeight/2
	bestCardLabel.y = cardHeight / 4
	bestCardInfo.y = (-1) * cardHeight / 8
	bestCardInfo.text = string.format("%.3fs",sessionData.fastestReactTime)
	group:insert(bestCard)


	-- webview scorecards
	local webView = native.newWebView(0, bestCard.y + cardHeight/2 + 10, display.contentWidth, 260)
	local screen1URL = "screen1=" .. tostring(storyboard.states.screen1.moreSleep) .. "+" .. tostring(storyboard.states.screen1.lessSleep)
	-- if storyboard.states.screen1.moreSleep == nil or 
	local timingsURL = "&timings="
	for i=1,table.getn(storyboard.states.screen3.timings) do 
		timingsURL = timingsURL ..  storyboard.states.screen3.timings[i] .. "+" 
	end
	timingsURL = timingsURL .. sessionData.aveReactTime
	local moodsURL = "&moods="
	for i=1,table.getn(storyboard.states.screen3.moods) do 
		moodsURL = moodsURL ..  storyboard.states.screen3.moods[i] .. "+" 
	end
	moodsURL = moodsURL .. storyboard.states.userMood
	local screen2URL = "&screen2=" .. storyboard.states.currentGenderStats.time .. "+" .. storyboard.states.currentAgeStats.time
	local parsedURL = "stats.html?" .. screen1URL .. timingsURL .. moodsURL .. "&recent=" .. sessionData.aveReactTime .. screen2URL
	print(parsedURL)
	webView:request(parsedURL, system.ResourceDirectory)
	webView.hasBackground = false
	group:insert(webView)
	


	-- button to replay
	local replayButton = createButton("home", display.contentWidth/2, display.contentHeight * 10/11, display.contentWidth/2, display.contentHeight/11)
	group:insert(replayButton)
	function replayButton:touch(event)
		if event.phase == "began" then
			storyboard.gotoScene("home")
			replayButton:removeEventListener("touch", replayButton)

		end
	end

	replayButton:addEventListener("touch", replayButton)
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