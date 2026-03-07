--[[
    tab_system/client.lua
    DX TAB-таблица с поиском и прокруткой:
    - открытие/закрытие по TAB (toggle)
    - поиск по ID и никнейму в реальном времени
    - колонки: ID, Ник, Ping, Отыгранное время
]]

local sx, sy = guiGetScreenSize()

-- Состояние TAB-окна.
local tabVisible = false
local searchQuery = ""
local searchFocused = false
local scrollOffset = 0
local filteredPlayers = {}

-- Кэш списка игроков, чтобы не делать лишние перерасчёты каждый кадр.
local playersDirty = true

-- Параметры минималистичного UI.
local panel = {
    w = math.min(980, math.floor(sx * 0.75)),
    h = math.min(620, math.floor(sy * 0.78))
}
panel.x = math.floor((sx - panel.w) / 2)
panel.y = math.floor((sy - panel.h) / 2)

local headerHeight = 46
local searchHeight = 34
local tableHeaderHeight = 34
local rowHeight = 28
local tablePadding = 14

-- Цветовая схема: тёмный фон + белый текст + оранжевый акцент.
local colors = {
    bg = tocolor(12, 14, 18, 220),
    panel = tocolor(20, 24, 31, 230),
    panelSoft = tocolor(27, 32, 41, 230),
    text = tocolor(245, 248, 255, 245),
    muted = tocolor(174, 182, 198, 245),
    accent = tocolor(255, 168, 64, 255),
    line = tocolor(67, 76, 94, 240),
    rowAlt = tocolor(24, 29, 37, 210),
    rowHover = tocolor(37, 45, 58, 225)
}

local placeholderText = "Поиск по ID или нику..."

-- Форматирует часы, беря данные из level_system (player:hours),
-- при отсутствии делает fallback на rp.playedSeconds.
local function getPlayedHoursText(player)
    local hours = tonumber(getElementData(player, "player:hours"))
    if not hours then
        local playedSeconds = tonumber(getElementData(player, "rp.playedSeconds")) or 0
        hours = playedSeconds / 3600
    end
    return string.format("%.1f ч", math.max(0, hours))
end

-- Возвращает список игроков для таблицы.
local function getAllPlayersData()
    local rows = {}

    for _, player in ipairs(getElementsByType("player")) do
        local id = tonumber(getElementData(player, "player:id")) or 0
        local name = getPlayerName(player) or "Unknown"

        rows[#rows + 1] = {
            element = player,
            id = id,
            idText = tostring(id),
            name = name,
            nameLower = string.lower(name),
            ping = getPlayerPing(player) or 0,
            played = getPlayedHoursText(player)
        }
    end

    table.sort(rows, function(a, b)
        return a.id < b.id
    end)

    return rows
end

-- Фильтрует список по текущей строке поиска (ID или ник).
local function rebuildFilteredPlayers()
    local allPlayers = getAllPlayersData()
    local q = string.lower(searchQuery or "")

    filteredPlayers = {}

    for _, row in ipairs(allPlayers) do
        if q == "" or string.find(row.idText, q, 1, true) or string.find(row.nameLower, q, 1, true) then
            filteredPlayers[#filteredPlayers + 1] = row
        end
    end

    -- Гарантируем корректный offset после фильтрации.
    local maxRows = math.max(1, math.floor((panel.h - headerHeight - searchHeight - tableHeaderHeight - (tablePadding * 2)) / rowHeight))
    local maxOffset = math.max(0, #filteredPlayers - maxRows)
    if scrollOffset > maxOffset then
        scrollOffset = maxOffset
    end

    playersDirty = false
end

-- Переключение TAB (на одно нажатие).
local function toggleTabWindow()
    tabVisible = not tabVisible
    showCursor(tabVisible)

    if tabVisible then
        playersDirty = true
        searchFocused = false
    else
        searchQuery = ""
        searchFocused = false
        scrollOffset = 0
    end
end

-- Проверка попадания курсора в поле поиска.
local function isPointInSearch(x, y)
    local searchY = panel.y + headerHeight
    local searchX = panel.x + tablePadding
    local searchW = panel.w - (tablePadding * 2)
    return x >= searchX and x <= (searchX + searchW) and y >= searchY and y <= (searchY + searchHeight)
end

-- Прокрутка таблицы колесом.
local function handleScroll(key)
    if not tabVisible then
        return
    end

    local visibleRows = math.max(1, math.floor((panel.h - headerHeight - searchHeight - tableHeaderHeight - (tablePadding * 2)) / rowHeight))
    local maxOffset = math.max(0, #filteredPlayers - visibleRows)

    if key == "mouse_wheel_down" then
        scrollOffset = math.min(maxOffset, scrollOffset + 1)
    elseif key == "mouse_wheel_up" then
        scrollOffset = math.max(0, scrollOffset - 1)
    end
end

-- Фокус поля поиска по клику мыши.
addEventHandler("onClientClick", root, function(button, state, cursorX, cursorY)
    if not tabVisible or button ~= "left" or state ~= "down" then
        return
    end

    searchFocused = isPointInSearch(cursorX, cursorY)
end)

-- Обработка ввода текста для поля поиска.
addEventHandler("onClientCharacter", root, function(character)
    if not tabVisible or not searchFocused then
        return
    end

    if utf8.len(searchQuery) >= 24 then
        return
    end

    if character and character ~= "\t" and character ~= "\r" and character ~= "\n" then
        searchQuery = searchQuery .. character
        playersDirty = true
    end
end)

-- Обработка управляющих клавиш окна TAB.
addEventHandler("onClientKey", root, function(button, press)
    if not press then
        return
    end

    -- TAB работает как toggle: переключаем окно и блокируем стандартный scoreboard.
    if button == "tab" then
        toggleTabWindow()
        cancelEvent()
        return
    end

    if not tabVisible then
        return
    end

    if button == "backspace" and searchFocused then
        local length = utf8.len(searchQuery)
        if length and length > 0 then
            searchQuery = utf8.sub(searchQuery, 1, length - 1) or ""
            playersDirty = true
        end
        cancelEvent()
    elseif button == "mouse_wheel_up" or button == "mouse_wheel_down" then
        handleScroll(button)
        cancelEvent()
    elseif button == "escape" then
        tabVisible = false
        showCursor(false)
        searchQuery = ""
        searchFocused = false
        scrollOffset = 0
        cancelEvent()
    end
end)

-- Если игроки добавились/удалились/сменили ник, помечаем кэш как устаревший.
addEventHandler("onClientPlayerJoin", root, function()
    playersDirty = true
end)

addEventHandler("onClientPlayerQuit", root, function()
    playersDirty = true
end)

addEventHandler("onClientPlayerChangeNick", root, function()
    playersDirty = true
end)

-- При изменении ID или времени тоже перефильтровываем таблицу.
addEventHandler("onClientElementDataChange", root, function(dataName)
    if getElementType(source) ~= "player" then
        return
    end

    if dataName == "player:id" or dataName == "player:hours" or dataName == "rp.playedSeconds" then
        playersDirty = true
    end
end)


-- Главный рендер DX-интерфейса.
addEventHandler("onClientRender", root, function()
    if not tabVisible then
        return
    end

    if playersDirty then
        rebuildFilteredPlayers()
    end

    -- Затемнение фона за TAB.
    dxDrawRectangle(0, 0, sx, sy, colors.bg)

    -- Основная панель.
    dxDrawRectangle(panel.x, panel.y, panel.w, panel.h, colors.panel)
    dxDrawRectangle(panel.x + 1, panel.y + 1, panel.w - 2, panel.h - 2, colors.panelSoft)

    -- Заголовок + количество игроков online.
    dxDrawText("Baku RPG | AZE", panel.x + 16, panel.y + 10, panel.x + panel.w - 16, panel.y + headerHeight, colors.text, 1.05, "default-bold", "left", "top")
    dxDrawText("Players Online: " .. tostring(#getElementsByType("player")), panel.x + 16, panel.y + 10, panel.x + panel.w - 16, panel.y + headerHeight, colors.accent, 1.0, "default-bold", "right", "top")

    -- Поле поиска (DX-стиль).
    local searchY = panel.y + headerHeight
    dxDrawRectangle(panel.x + tablePadding, searchY, panel.w - (tablePadding * 2), searchHeight, tocolor(15, 19, 25, 230))

    local shownText = searchQuery
    local shownColor = colors.text
    if shownText == "" and not searchFocused then
        shownText = placeholderText
        shownColor = colors.muted
    end

    dxDrawText(shownText, panel.x + tablePadding + 10, searchY + 8, panel.x + panel.w - tablePadding - 10, searchY + searchHeight, shownColor, 0.95, "default-bold", "left", "top")

    -- Зона таблицы и заголовков колонок.
    local tableX = panel.x + tablePadding
    local tableY = searchY + searchHeight + 10
    local tableW = panel.w - (tablePadding * 2)
    local tableH = panel.h - (headerHeight + searchHeight + 10 + tablePadding)

    dxDrawRectangle(tableX, tableY, tableW, tableHeaderHeight, tocolor(15, 19, 25, 230))

    local idX = tableX + 14
    local nickX = tableX + 90
    local pingX = tableX + math.floor(tableW * 0.72)
    local timeX = tableX + math.floor(tableW * 0.84)

    dxDrawText("ID", idX, tableY + 8, nickX - 8, tableY + tableHeaderHeight, colors.accent, 0.95, "default-bold", "left", "top")
    dxDrawText("Никнейм", nickX, tableY + 8, pingX - 8, tableY + tableHeaderHeight, colors.accent, 0.95, "default-bold", "left", "top")
    dxDrawText("Ping", pingX, tableY + 8, timeX - 8, tableY + tableHeaderHeight, colors.accent, 0.95, "default-bold", "left", "top")
    dxDrawText("Отыгранное время", timeX, tableY + 8, tableX + tableW - 8, tableY + tableHeaderHeight, colors.accent, 0.95, "default-bold", "left", "top")

    -- Вертикальные разделители колонок через dxDrawLine.
    dxDrawLine(nickX - 12, tableY, nickX - 12, tableY + tableH, colors.line, 1)
    dxDrawLine(pingX - 12, tableY, pingX - 12, tableY + tableH, colors.line, 1)
    dxDrawLine(timeX - 12, tableY, timeX - 12, tableY + tableH, colors.line, 1)

    -- Рендер строк с учётом прокрутки.
    local rowsStartY = tableY + tableHeaderHeight
    local visibleRows = math.max(1, math.floor((tableH - tableHeaderHeight) / rowHeight))

    for i = 1, visibleRows do
        local playerIndex = i + scrollOffset
        local row = filteredPlayers[playerIndex]
        if not row then
            break
        end

        local rowY = rowsStartY + ((i - 1) * rowHeight)
        local bgColor = (i % 2 == 0) and colors.rowAlt or tocolor(0, 0, 0, 0)

        if isCursorShowing() then
            local cx, cy = getCursorPosition()
            if cx and cy then
                cx, cy = cx * sx, cy * sy
                if cx >= tableX and cx <= (tableX + tableW) and cy >= rowY and cy <= (rowY + rowHeight) then
                    bgColor = colors.rowHover
                end
            end
        end

        if bgColor then
            dxDrawRectangle(tableX, rowY, tableW, rowHeight, bgColor)
        end

        dxDrawText(row.idText, idX, rowY + 6, nickX - 8, rowY + rowHeight, colors.text, 0.92, "default-bold", "left", "top", true, false, false)
        dxDrawText(row.name, nickX, rowY + 6, pingX - 8, rowY + rowHeight, colors.text, 0.92, "default-bold", "left", "top", true, false, false)
        dxDrawText(tostring(row.ping), pingX, rowY + 6, timeX - 8, rowY + rowHeight, colors.text, 0.92, "default-bold", "left", "top", true, false, false)
        dxDrawText(row.played, timeX, rowY + 6, tableX + tableW - 8, rowY + rowHeight, colors.text, 0.92, "default-bold", "left", "top", true, false, false)
    end

    -- Индикатор прокрутки (если игроков больше, чем помещается).
    local totalPlayers = #filteredPlayers
    if totalPlayers > visibleRows then
        local scrollX = tableX + tableW - 5
        local scrollY = rowsStartY
        local scrollH = visibleRows * rowHeight

        local thumbH = math.max(24, math.floor(scrollH * (visibleRows / totalPlayers)))
        local maxOffset = totalPlayers - visibleRows
        local thumbY = scrollY

        if maxOffset > 0 then
            thumbY = scrollY + math.floor((scrollH - thumbH) * (scrollOffset / maxOffset))
        end

        dxDrawRectangle(scrollX, scrollY, 3, scrollH, tocolor(45, 53, 67, 220))
        dxDrawRectangle(scrollX, thumbY, 3, thumbH, colors.accent)
    end
end)
