-----------------------------------------------------------------------------------------
--
-- insights.lua
--
-- Gives a detailed overview of the user current ranking in the database
--
-----------------------------------------------------------------------------------------

-- Libraries
local storyboard = require("storyboard")
local widget = require("widget")
local upapi = require("upapi")
local math = require("math")
local physics = require("physics")
local json = require("json")

display.setStatusBar( display.HiddenStatusBar )
local scene = storyboard.newScene()
storyboard.purgeOnSceneChange = true



function scene:createScene( event )
	local group = self.view

	local background = display.newRect(group, 0,0,display.contentWidth,display.contentHeight)
	background:setFillColor(236, 240, 241)
	group:insert(background)

	local frame = display.newRect(group, 0, 0, display.contentWidth-50, 290)
	frame:setReferencePoint(display.TopCenterReferencePoint)
	frame.x = display.contentWidth/2
	frame.y = 130

	local title = display.newText(group, "world ranking", 0, 0, storyboard.states.font.bold, 24)
	title:setReferencePoint(display.BottomCenterReferencePoint)
	title.x = display.contentWidth/2
	title.y = 120
	title:setTextColor(189, 195, 199)


	local backArrow = display.newImageRect("arrow_left.png",32,32)
	backArrow.x = 20
	backArrow.y = 20
	group:insert(backArrow)

	function backArrow:touch(event)
		if event.phase == "ended" then
			storyboard.gotoScene("home", {effect="slideRight"})
		end
	end
	backArrow:addEventListener("touch", backArrow)

	-- get current world ranking
	local function orderWorldRanking(failed, result)
		if not failed then
			local currentRankings = json.decode(result)
			storyboard.states.worldRankings = currentRankings
			local fontSize = 0
			local textColor = {}
			local topRanked = false
			local yPos = 100

			-- iterate through the users to pribnt to screen
			for i=1, 7 do
				print(tostring(i) .. currentRankings[i].name .. currentRankings[i].value .. currentRankings[i].xid)
				yPos = yPos + 40
				if storyboard.states.userXID == currentRankings[i].xid then
					fontSize = 24
					textColor.r=230
					textColor.g=126
					textColor.b=34
					topRanked = true
				else
					fontSize = 18
					textColor.r=149
					textColor.g=155
					textColor.b=159
				end
				-- rank
				local rank = display.newText(group, tostring(i), 0, yPos, storyboard.states.font.bold, fontSize)
				rank:setReferencePoint(display.TopRightReferencePoint)
				rank.x=50
				rank:setTextColor(textColor.r, textColor.g, textColor.b)
				-- parsed name
				local index = string.find(currentRankings[i].name, "_")
				local nameString = string.sub(currentRankings[i].name, 1, index-1).. " " .. string.sub(currentRankings[i].name, index+1, index+1) .."."
				local name = display.newText(group, nameString, 70, yPos, storyboard.states.font.bold, fontSize)
				name:setTextColor(textColor.r, textColor.g, textColor.b)
				--  timings
				local score = display.newText(group, string.format("%.3f", currentRankings[i].value).."s", 0, yPos, storyboard.states.font.bold, fontSize)
				score:setReferencePoint(display.TopRightReferencePoint)
				score.x = display.contentWidth-40
				score:setTextColor(textColor.r, textColor.g, textColor.b)
			end

			if topRanked == false then
				local userIndex = 8
				for i=8,table.getn(currentRankings) do
					if storyboard.states.userXID == currentRankings[i].xid then
						userIndex = i
					end
				end
				textColor.r = 46
				textColor.g = 204
				textColor.b = 113
				yPos = yPos + 60

				
				-- rank
				local rank = display.newText(group, tostring(userIndex), 0, yPos, storyboard.states.font.bold, fontSize)
				rank:setReferencePoint(display.TopRightReferencePoint)
				rank.x=50
				rank:setTextColor(textColor.r, textColor.g, textColor.b)
				-- parsed name
				local index = string.find(currentRankings[userIndex].name, "_")
				local nameString = string.sub(currentRankings[userIndex].name, 1, index-1).. " " .. string.sub(currentRankings[userIndex].name, index+1, index+1) .."."
				local name = display.newText(group, "You", 70, yPos, storyboard.states.font.bold, fontSize)
				name:setTextColor(textColor.r, textColor.g, textColor.b)
				--  timings
				local score = display.newText(group, string.format("%.3f", currentRankings[userIndex].value).."s", 0, yPos, storyboard.states.font.bold, fontSize)
				score:setReferencePoint(display.TopRightReferencePoint)
				score.x = display.contentWidth-50
				score:setTextColor(textColor.r, textColor.g, textColor.b)

			end
		end
	end
	upapi.parseWorldRanking(orderWorldRanking)

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