local playTimers = {}

function getPlayerRequiredExperience(level)
    return math.max(1, tonumber(level) or 1) * 4
end

function getPlayerLevel(player)
    return tonumber(getElementData(player, "rp:level")) or 1
end

function setPlayerLevel(player, level)
    if not isElement(player) then return false end
    level = math.max(1, math.floor(tonumber(level) or 1))
    setElementData(player, "rp:level", level, true)
    return true
end

function getPlayerExperience(player)
    return tonumber(getElementData(player, "rp:experience")) or 0
end

local function saveLevel(player)
    if not AuthDBExec or not getElementData(player, "auth:playerId") then return end
    AuthDBExec("UPDATE players SET level = ?, experience = ? WHERE id = ?", getPlayerLevel(player), getPlayerExperience(player), getElementData(player, "auth:playerId"))
end

function addPlayerExperience(player, amount)
    if not isElement(player) then return false end
    local exp = getPlayerExperience(player) + math.max(0, tonumber(amount) or 0)
    local level = getPlayerLevel(player)
    local leveled = false

    while exp >= getPlayerRequiredExperience(level) do
        exp = exp - getPlayerRequiredExperience(level)
        level = level + 1
        leveled = true
    end

    setElementData(player, "rp:experience", exp, true)
    setPlayerLevel(player, level)
    saveLevel(player)

    if amount > 0 then outputChatBox("Вы получили " .. amount .. " EXP за час игры.", player, 79, 195, 247) end
    if leveled then outputChatBox("Поздравляем! Ваш уровень повышен до " .. level .. ".", player, 102, 187, 106) end
    return true
end

local function startTimer(player)
    if playTimers[player] then killTimer(playTimers[player]) end
    playTimers[player] = setTimer(function(target)
        if isElement(target) and getElementData(target, "auth:loggedIn") then
            addPlayerExperience(target, 1)
        end
    end, 3600000, 0, player)
end

addEvent("rp:onPlayerReady", true)
addEventHandler("rp:onPlayerReady", root, function(player, row)
    if not isElement(player) then return end
    setPlayerLevel(player, tonumber(row and row.level) or 1)
    setElementData(player, "rp:experience", tonumber(row and row.experience) or 0, true)
    startTimer(player)
end)

addEventHandler("onPlayerQuit", root, function()
    saveLevel(source)
    if playTimers[source] then killTimer(playTimers[source]); playTimers[source] = nil end
end)

addEventHandler("onResourceStop", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        saveLevel(player)
        if playTimers[player] then killTimer(playTimers[player]); playTimers[player] = nil end
    end
end)
