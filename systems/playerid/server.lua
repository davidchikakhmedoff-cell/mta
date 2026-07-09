RPPlayerID = { free = {}, byPlayer = {}, byId = {}, nextId = 1 }

local function acquireId()
    table.sort(RPPlayerID.free)
    if #RPPlayerID.free > 0 then
        return table.remove(RPPlayerID.free, 1)
    end
    local id = RPPlayerID.nextId
    RPPlayerID.nextId = RPPlayerID.nextId + 1
    return id
end

function assignPlayerDynamicID(player)
    if RPPlayerID.byPlayer[player] then return RPPlayerID.byPlayer[player] end
    local id = acquireId()
    RPPlayerID.byPlayer[player] = id
    RPPlayerID.byId[id] = player
    setElementData(player, "rp:id", id, true)
    return id
end

function releasePlayerDynamicID(player)
    local id = RPPlayerID.byPlayer[player]
    if not id then return end
    RPPlayerID.byPlayer[player] = nil
    RPPlayerID.byId[id] = nil
    removeElementData(player, "rp:id")
    RPPlayerID.free[#RPPlayerID.free + 1] = id
end

function getPlayerByDynamicID(id)
    return RPPlayerID.byId[tonumber(id)]
end

function getPlayerDynamicID(player)
    return RPPlayerID.byPlayer[player] or getElementData(player, "rp:id")
end

addEvent("rp:onPlayerReady", true)
addEventHandler("rp:onPlayerReady", root, function(player)
    if isElement(player) then assignPlayerDynamicID(player) end
end)

addEventHandler("onPlayerQuit", root, function() releasePlayerDynamicID(source) end)
addEventHandler("onResourceStop", resourceRoot, function()
    for player in pairs(RPPlayerID.byPlayer) do
        if isElement(player) then removeElementData(player, "rp:id") end
    end
end)
