local screenW, screenH = guiGetScreenSize()
local font = "default-bold"

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do setPlayerNametagShowing(player, false) end
end)

addEventHandler("onClientPlayerJoin", root, function() setPlayerNametagShowing(source, false) end)

addEventHandler("onClientRender", root, function()
    local cx, cy, cz = getCameraMatrix()
    local localDim = getElementDimension(localPlayer)
    local localInt = getElementInterior(localPlayer)

    for _, player in ipairs(getElementsByType("player", root, true)) do
        if player ~= localPlayer and isElementOnScreen(player) and getElementDimension(player) == localDim and getElementInterior(player) == localInt then
            local px, py, pz = getPedBonePosition(player, 8)
            local distance = getDistanceBetweenPoints3D(cx, cy, cz, px, py, pz)
            if distance <= RPNicknameConfig.maxDistance and isLineOfSightClear(cx, cy, cz, px, py, pz, true, false, false, true, false, false, false, player) then
                local sx, sy = getScreenFromWorldPosition(px, py, pz + 0.35, 0.06)
                if sx and sy then
                    local fade = math.max(0, math.min(1, (RPNicknameConfig.maxDistance - distance) / (RPNicknameConfig.maxDistance - RPNicknameConfig.visibleDistance)))
                    local scale = math.max(0.65, RPNicknameConfig.baseScale - distance * 0.012)
                    local name = getElementData(player, "rp:name") or getPlayerName(player):gsub("_", " ")
                    local id = getElementData(player, "rp:id") or "?"
                    local color = getElementData(player, "rp:nametagColor") or RPNicknameConfig.defaultColor
                    local text = string.format("%s (%s)", name, id)
                    dxDrawText(text, sx + 1, sy + 1, sx + 1, sy + 1, tocolor(0, 0, 0, 180 * fade), scale, font, "center", "center")
                    dxDrawText(text, sx, sy, sx, sy, tocolor(color[1], color[2], color[3], 255 * fade), scale, font, "center", "center")
                end
            end
        end
    end
end)
