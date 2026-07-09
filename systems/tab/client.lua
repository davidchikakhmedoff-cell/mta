local tab = { visible = false, search = "", players = {}, lastRefresh = 0 }
local sw, sh = guiGetScreenSize()

local function s(value) return DXUtils.s(value) end

local function refreshPlayers()
    tab.players = {}
    local needle = tab.search:lower()
    for _, player in ipairs(getElementsByType("player")) do
        local id = tostring(getElementData(player, "rp:id") or "?")
        local name = getElementData(player, "rp:name") or getPlayerName(player):gsub("_", " ")
        local lower = name:lower()
        if needle == "" or id:find(needle, 1, true) or lower:find(needle, 1, true) then
            tab.players[#tab.players + 1] = { player = player, id = id, name = name, level = getElementData(player, "rp:level") or 1, ping = getPlayerPing(player), color = getElementData(player, "rp:nametagColor") or {255, 255, 255} }
        end
    end
    table.sort(tab.players, function(a, b) return tonumber(a.id) and tonumber(b.id) and tonumber(a.id) < tonumber(b.id) end)
end

local function drawTab()
    if getTickCount() - tab.lastRefresh > 500 then tab.lastRefresh = getTickCount(); refreshPlayers() end
    local w, h = s(760), s(560)
    local x, y = (sw - w) / 2, (sh - h) / 2
    DXUtils.shadow(x, y, w, h, s(18), 80)
    DXUtils.roundedRect(x, y, w, h, s(18), DXUtils.color(AuthConfig.colors.window, 245))
    dxDrawText("Игроки онлайн", x + s(28), y + s(20), x + w, y + s(54), tocolor(255,255,255,255), 1.25, "default-bold", "left", "center")

    local searchX, searchY, searchW, searchH = x + s(28), y + s(68), w - s(56), s(42)
    DXUtils.roundedRect(searchX, searchY, searchW, searchH, s(10), DXUtils.color(AuthConfig.colors.panel, 255))
    dxDrawText(tab.search == "" and "Поиск по ID или нику..." or tab.search, searchX + s(14), searchY, searchX + searchW, searchY + searchH, tab.search == "" and DXUtils.color(AuthConfig.colors.muted, 255) or tocolor(255,255,255,255), 1, "default", "left", "center")

    local headY = y + s(128)
    dxDrawText("ID", x + s(34), headY, x + s(90), headY + s(28), DXUtils.color(AuthConfig.colors.primary, 255), 1, "default-bold", "left", "center")
    dxDrawText("Ник", x + s(110), headY, x + s(430), headY + s(28), DXUtils.color(AuthConfig.colors.primary, 255), 1, "default-bold", "left", "center")
    dxDrawText("Уровень", x + s(470), headY, x + s(570), headY + s(28), DXUtils.color(AuthConfig.colors.primary, 255), 1, "default-bold", "left", "center")
    dxDrawText("Ping", x + s(620), headY, x + w - s(30), headY + s(28), DXUtils.color(AuthConfig.colors.primary, 255), 1, "default-bold", "right", "center")

    local rowY = headY + s(34)
    for i, row in ipairs(tab.players) do
        if i > 12 then break end
        local ry = rowY + (i - 1) * s(31)
        if i % 2 == 0 then dxDrawRectangle(x + s(24), ry, w - s(48), s(30), tocolor(255,255,255,10)) end
        dxDrawText(row.id, x + s(34), ry, x + s(90), ry + s(30), tocolor(230,230,230,255), 1, "default", "left", "center")
        dxDrawText(row.name, x + s(110), ry, x + s(430), ry + s(30), tocolor(row.color[1], row.color[2], row.color[3],255), 1, "default-bold", "left", "center", true)
        dxDrawText(tostring(row.level), x + s(470), ry, x + s(570), ry + s(30), tocolor(230,230,230,255), 1, "default", "left", "center")
        dxDrawText(tostring(row.ping), x + s(620), ry, x + w - s(30), ry + s(30), tocolor(230,230,230,255), 1, "default", "right", "center")
    end
end

addEventHandler("onClientKey", root, function(button, press)
    if button == "tab" then
        cancelEvent()
        if AuthUI and AuthUI.visible then return end
        tab.visible = press
        showCursor(false)
        if press then refreshPlayers(); addEventHandler("onClientRender", root, drawTab) else removeEventHandler("onClientRender", root, drawTab) end
    elseif tab.visible and press then
        cancelEvent()
        if button == "backspace" then tab.search = tab.search:sub(1, -2); refreshPlayers() end
    end
end)

addEventHandler("onClientCharacter", root, function(char)
    if not tab.visible then return end
    if #tab.search < 32 then tab.search = tab.search .. char; refreshPlayers() end
end)
