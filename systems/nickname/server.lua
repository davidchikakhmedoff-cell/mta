function isValidRPNickname(name)
    if type(name) ~= "string" then return false end
    return name:match("^[A-Z][a-z]+ [A-Z][a-z]+$") ~= nil
end

function setPlayerRPNickname(player, name)
    if not isElement(player) or not isValidRPNickname(name) then return false end
    setElementData(player, "rp:name", name, true)
    setPlayerName(player, name:gsub(" ", "_"))
    return true
end

function getPlayerRPNickname(player)
    return getElementData(player, "rp:name") or getPlayerName(player):gsub("_", " ")
end

function setPlayerNametagColor(player, r, g, b)
    if not isElement(player) then return false end
    setElementData(player, "rp:nametagColor", { tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255 }, true)
    return true
end

function getPlayerNametagColor(player)
    return getElementData(player, "rp:nametagColor") or RPNicknameConfig.defaultColor
end

addEvent("rp:onPlayerReady", true)
addEventHandler("rp:onPlayerReady", root, function(player)
    if not isElement(player) then return end
    setPlayerNametagShowing(player, false)
    if not getElementData(player, "rp:nametagColor") then
        setPlayerNametagColor(player, unpack(RPNicknameConfig.defaultColor))
    end
end)

addEventHandler("onPlayerJoin", root, function() setPlayerNametagShowing(source, false) end)
addEventHandler("onResourceStart", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do setPlayerNametagShowing(player, false) end
end)
