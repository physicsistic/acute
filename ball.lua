local storyboard = require "storyboard" 
local utils = require("utils")

-- Module namespace

local M = {}

function M.create(x,y)
    local sheet = graphics.newImageSheet( "sphere-sheet.png", {
        width = 72,
        height = 72,
        numFrames = 2,
    })

    local bouncy = display.newSprite( sheet, {start=1, count=2} )
    bouncy:setReferencePoint(display.CenterReferencePoint)

    if x == nil then x = display.contentWidth/2 end
    if y == nil then y = display.contentHeight/3 end

    bouncy.x = x
    bouncy.y = y

    function bouncy:touch ( event )
        if event.phase == "began" then
            event.target:setFrame(2)
        elseif event.phase == "ended" then
            event.target:setFrame(1)
        end
    end

    bouncy:addEventListener( "touch", bouncy )

    return bouncy
end


return M