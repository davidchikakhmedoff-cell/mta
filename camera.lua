-- Static authorization camera: no movement, no interpolation.
AuthCamera = { active = false }

local function applyStaticCamera()
    local pos, look = AuthConfig.camera.position, AuthConfig.camera.lookAt
    setCameraMatrix(pos[1], pos[2], pos[3], look[1], look[2], look[3])
end

function AuthCamera.start()
    AuthCamera.active = true
    fadeCamera(false, 0, 0, 0, 0)
    applyStaticCamera()
    setTimer(function()
        if AuthCamera.active then
            applyStaticCamera()
            fadeCamera(true, AuthConfig.camera.fadeInMs, 0, 0, 0)
        end
    end, 250, 1)
end

function AuthCamera.stop()
    AuthCamera.active = false
    setCameraTarget(localPlayer)
    fadeCamera(true, 1200, 0, 0, 0)
end
