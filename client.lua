addEventHandler("onClientResourceStart", resourceRoot, function()
    setElementFrozen(localPlayer, true)
    AuthCamera.start()
    AuthUI.show()
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    showCursor(false); showChat(true); toggleAllControls(true); setCameraTarget(localPlayer); setElementFrozen(localPlayer, false)
end)

addEvent("auth:response", true)
addEventHandler("auth:response", resourceRoot, function(success, message, rememberedLogin)
    AuthUI.submit.enabled = true
    AuthUI.setNotice(message, success)
    if not success then return end
    saveRememberedLogin(rememberedLogin)
    setElementFrozen(localPlayer, false)
    setTimer(function() AuthUI.hide(); AuthCamera.stop() end, 650, 1)
end)
