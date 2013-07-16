module(..., package.seeall)

function moveBouncy(obj, deltaX, deltaY)
	transition.to(obj, {time = 100, x = obj.x + deltaX, y = obj.y + deltaY})
end

function wobble(obj)
	moveBouncy(obj, 10, 6)
	timer.performWithDelay(100, function () moveBouncy(obj, -18, -12) end)
	timer.performWithDelay(200, function () moveBouncy(obj, 16, 10) end)
	timer.performWithDelay(300, function () moveBouncy(obj, -14, -8) end)
	timer.performWithDelay(400, function () moveBouncy(obj, 6, 4) end)
	timer.performWithDelay(500, function () physics.start() end)
end

function flash(obj, frameTime)
	transition.to(obj, {time = frameTime, alpha = 0, transition=easing.outQuad})
	timer.performWithDelay( frameTime * 2, function () transition.to(obj, {time = frameTime, alpha = 1, transition=easing.inQuad})end)
	timer.performWithDelay( frameTime * 3, function () transition.to(obj, {time = frameTime, alpha = 0, transition=easing.outQuad})end)
	timer.performWithDelay( frameTime * 4, function () transition.to(obj, {time = frameTime, alpha = 1, transition=easing.inQuad})end)
	timer.performWithDelay( frameTime * 5, function () transition.to(obj, {time = frameTime, alpha = 0, transition=easing.outQuad})end)
	timer.performWithDelay( frameTime * 6, function () transition.to(obj, {time = frameTime, alpha = 1, transition=easing.inQuad})end)
	timer.performWithDelay( frameTime * 7, function () physics.start() end)

end