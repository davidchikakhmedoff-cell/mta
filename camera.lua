-- Static authorization camera: no movement, no interpolation and no MTA fade-in.
AuthCamera = { active = false }

local function applyStaticCamera()
    local pos, look = AuthConfig.camera.position, AuthConfig.camera.lookAt
    setCameraMatrix(pos[1], pos[2], pos[3], look[1], look[2], look[3])
end

function AuthCamera.start()
    AuthCamera.active = true
    fadeCamera(true, 0)
    applyStaticCamera()
end

function AuthCamera.stop()
    AuthCamera.active = false
    setCameraTarget(localPlayer)
    fadeCamera(true, 0)
end
