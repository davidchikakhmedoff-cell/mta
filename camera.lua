AuthCamera = { active = false, index = 1, started = 0 }

local function setByProgress(point, nextPoint, progress)
    local p = DXUtils.ease(progress)
    local x, y, z = interpolateBetween(point.pos[1], point.pos[2], point.pos[3], nextPoint.pos[1], nextPoint.pos[2], nextPoint.pos[3], p, "InOutQuad")
    local lx, ly, lz = interpolateBetween(point.look[1], point.look[2], point.look[3], nextPoint.look[1], nextPoint.look[2], nextPoint.look[3], p, "InOutQuad")
    setCameraMatrix(x, y, z, lx, ly, lz)
end

function AuthCamera.start()
    AuthCamera.active = true; AuthCamera.index = 1; AuthCamera.started = getTickCount()
    fadeCamera(false, 0, 0, 0, 0)
    setTimer(function() if AuthCamera.active then fadeCamera(true, AuthConfig.camera.fadeInMs, 0, 0, 0) end end, 250, 1)
    addEventHandler("onClientPreRender", root, AuthCamera.render)
end

function AuthCamera.render()
    if not AuthCamera.active then return end
    local points = AuthConfig.camera.points
    local a = points[AuthCamera.index]
    local b = points[AuthCamera.index % #points + 1]
    local elapsed = getTickCount() - AuthCamera.started
    local progress = elapsed / a.duration
    if progress >= 1 then AuthCamera.index = AuthCamera.index % #points + 1; AuthCamera.started = getTickCount(); progress = 0 end
    setByProgress(a, b, progress)
end

function AuthCamera.stop()
    AuthCamera.active = false
    removeEventHandler("onClientPreRender", root, AuthCamera.render)
    fadeCamera(false, 700, 0, 0, 0)
    setTimer(function() setCameraTarget(localPlayer); fadeCamera(true, 1200, 0, 0, 0) end, 750, 1)
end
