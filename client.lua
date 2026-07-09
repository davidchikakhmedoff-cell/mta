addEventHandler("onClientResourceStart", resourceRoot, function()
    fadeCamera(true, 0)
    setElementFrozen(localPlayer, true)
    AuthCamera.start()
    AuthUI.show()
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    showCursor(false)
    showChat(true)
    toggleAllControls(true)
    setCameraTarget(localPlayer)
    setElementFrozen(localPlayer, false)
end)

addEvent("auth:response", true)
addEventHandler("auth:response", resourceRoot, function(success, message, rememberedLogin)
    AuthUI.setNotice(message, success)

    if not success then
        AuthUI.submit.enabled = true
        return
    end

    -- Hide the authorization UI immediately, then let the server spawn the player.
    saveRememberedLogin(rememberedLogin)
    AuthCamera.active = false
    AuthUI.hide(true, true)
    triggerServerEvent("auth:spawnReady", localPlayer)
end)

addEvent("auth:spawned", true)
addEventHandler("auth:spawned", resourceRoot, function()
    fadeCamera(true, 0)
    setCameraTarget(localPlayer)
    setElementFrozen(localPlayer, false)
end)
