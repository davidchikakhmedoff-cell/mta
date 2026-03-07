--[[
    login_panel/client.lua
    DX-панель авторизации/регистрации:
    - блокировка управления, чата и HUD до входа
    - окно логина + окно регистрации
    - всплывающие окна ошибок/подсказок
]]

local sx, sy = guiGetScreenSize()

local ui = {
    visible = true,
    mode = "login", -- login/register
    focusField = nil,

    loginData = {
        login = "",
        password = ""
    },

    registerData = {
        login = "",
        password = "",
        passwordRepeat = "",
        email = ""
    },

    popup = {
        visible = false,
        text = "",
        closeText = "Закрыть"
    },

    forgotPopup = false,
    maxFieldLength = 64
}

local colors = {
    bg = tocolor(10, 12, 16, 220),
    panel = tocolor(20, 24, 31, 240),
    panelSoft = tocolor(27, 32, 41, 235),
    text = tocolor(245, 248, 255, 245),
    muted = tocolor(174, 182, 198, 245),
    accent = tocolor(255, 168, 64, 255),
    danger = tocolor(230, 90, 90, 255),
    inputBg = tocolor(15, 19, 25, 235),
    inputFocus = tocolor(38, 47, 60, 235),
    button = tocolor(34, 41, 53, 240),
    buttonHover = tocolor(46, 56, 72, 250)
}

local blocks = {
    main = {
        w = math.min(520, math.floor(sx * 0.9)),
        h = math.min(440, math.floor(sy * 0.85))
    },
    popup = {
        w = math.min(440, math.floor(sx * 0.8)),
        h = 180
    }
}
blocks.main.x = math.floor((sx - blocks.main.w) / 2)
blocks.main.y = math.floor((sy - blocks.main.h) / 2)
blocks.popup.x = math.floor((sx - blocks.popup.w) / 2)
blocks.popup.y = math.floor((sy - blocks.popup.h) / 2)

local hudComponentsToToggle = {
    "ammo",
    "armour",
    "breath",
    "clock",
    "health",
    "money",
    "vehicle_name",
    "weapon",
    "area_name",
    "wanted",
    "radio"
}

local clickable = {}

local function isPointInRect(px, py, x, y, w, h)
    return px >= x and px <= (x + w) and py >= y and py <= (y + h)
end

local function lockPlayerState()
    showChat(false)
    for _, component in ipairs(hudComponentsToToggle) do
        showPlayerHudComponent(component, false)
    end

    toggleAllControls(false, true, false)
    setElementFrozen(localPlayer, true)
    showCursor(true)
end

local function unlockPlayerState()
    showChat(true)
    for _, component in ipairs(hudComponentsToToggle) do
        showPlayerHudComponent(component, true)
    end

    toggleAllControls(true, true, true)
    setElementFrozen(localPlayer, false)
    showCursor(false)
end

local function addClickable(id, x, y, w, h, onClick)
    clickable[#clickable + 1] = {
        id = id,
        x = x,
        y = y,
        w = w,
        h = h,
        onClick = onClick
    }
end

local function drawInputField(label, key, value, x, y, w, h, isPassword)
    local focused = ui.focusField == key
    dxDrawText(label, x, y - 18, x + w, y, colors.muted, 0.9, "default-bold", "left", "top")
    dxDrawRectangle(x, y, w, h, focused and colors.inputFocus or colors.inputBg)

    local shown = value
    if isPassword and value ~= "" then
        shown = string.rep("*", utf8.len(value) or #value)
    end

    if shown == "" then
        shown = label
        dxDrawText(shown, x + 10, y + 8, x + w - 10, y + h, colors.muted, 0.95, "default-bold", "left", "top", true)
    else
        dxDrawText(shown, x + 10, y + 8, x + w - 10, y + h, colors.text, 0.95, "default-bold", "left", "top", true)
    end

    addClickable("field:" .. key, x, y, w, h, function()
        ui.focusField = key
    end)
end

local function drawButton(id, text, x, y, w, h, onClick, accent)
    local cx, cy = getCursorPosition()
    local hovered = false
    if cx and cy then
        cx, cy = cx * sx, cy * sy
        hovered = isPointInRect(cx, cy, x, y, w, h)
    end

    local color = accent and colors.accent or colors.button
    if hovered then
        color = accent and tocolor(255, 182, 90, 255) or colors.buttonHover
    end

    dxDrawRectangle(x, y, w, h, color)
    dxDrawText(text, x, y, x + w, y + h, colors.text, 0.95, "default-bold", "center", "center", true)

    addClickable(id, x, y, w, h, onClick)
end

local function showPopup(text)
    ui.popup.visible = true
    ui.popup.text = text or "Ошибка"
end

local function hidePopup()
    ui.popup.visible = false
    ui.popup.text = ""
end

local function renderLoginPanel()
    local x, y, w, h = blocks.main.x, blocks.main.y, blocks.main.w, blocks.main.h

    dxDrawRectangle(0, 0, sx, sy, colors.bg)
    dxDrawRectangle(x, y, w, h, colors.panel)
    dxDrawRectangle(x + 1, y + 1, w - 2, h - 2, colors.panelSoft)

    dxDrawText("Baku RPG | Авторизация", x + 20, y + 16, x + w - 20, y + 44, colors.text, 1.05, "default-bold", "left", "top")

    local fieldX = x + 24
    local fieldW = w - 48
    local startY = y + 68
    local fieldH = 38

    drawInputField("Логин", "login.login", ui.loginData.login, fieldX, startY, fieldW, fieldH, false)
    drawInputField("Пароль", "login.password", ui.loginData.password, fieldX, startY + 72, fieldW, fieldH, true)

    local buttonY = startY + 160
    drawButton("login", "Вход", fieldX, buttonY, fieldW, 42, function()
        triggerServerEvent("loginPanel:requestLogin", resourceRoot, ui.loginData.login, ui.loginData.password)
    end, true)

    drawButton("register-open", "Регистрация", fieldX, buttonY + 52, fieldW, 38, function()
        ui.mode = "register"
        ui.focusField = nil
    end)

    drawButton("forgot", "Забыли пароль?", fieldX, buttonY + 98, fieldW, 34, function()
        ui.forgotPopup = true
        ui.focusField = nil
    end)
end

local function renderRegisterPanel()
    local x, y, w, h = blocks.main.x, blocks.main.y, blocks.main.w, blocks.main.h

    dxDrawRectangle(0, 0, sx, sy, colors.bg)
    dxDrawRectangle(x, y, w, h, colors.panel)
    dxDrawRectangle(x + 1, y + 1, w - 2, h - 2, colors.panelSoft)

    dxDrawText("Baku RPG | Регистрация", x + 20, y + 16, x + w - 20, y + 44, colors.text, 1.05, "default-bold", "left", "top")

    local fieldX = x + 24
    local fieldW = w - 48
    local startY = y + 66
    local fieldH = 34
    local gap = 56

    drawInputField("Логин", "register.login", ui.registerData.login, fieldX, startY, fieldW, fieldH, false)
    drawInputField("Пароль", "register.password", ui.registerData.password, fieldX, startY + gap, fieldW, fieldH, true)
    drawInputField("Повторите пароль", "register.passwordRepeat", ui.registerData.passwordRepeat, fieldX, startY + gap * 2, fieldW, fieldH, true)
    drawInputField("Email", "register.email", ui.registerData.email, fieldX, startY + gap * 3, fieldW, fieldH, false)

    local buttonY = startY + (gap * 4) + 6

    drawButton("register-submit", "Зарегистрироваться", fieldX, buttonY, fieldW, 40, function()
        triggerServerEvent(
            "loginPanel:requestRegister",
            resourceRoot,
            ui.registerData.login,
            ui.registerData.password,
            ui.registerData.passwordRepeat,
            ui.registerData.email
        )
    end, true)

    drawButton("register-back", "Назад", fieldX, buttonY + 50, fieldW, 34, function()
        ui.mode = "login"
        ui.focusField = nil
    end)
end

local function renderPopup(text, closeAction)
    local x, y, w, h = blocks.popup.x, blocks.popup.y, blocks.popup.w, blocks.popup.h

    dxDrawRectangle(x, y, w, h, tocolor(20, 24, 31, 245))
    dxDrawRectangle(x + 1, y + 1, w - 2, h - 2, tocolor(27, 32, 41, 235))

    dxDrawText(text, x + 16, y + 26, x + w - 16, y + 100, colors.text, 0.98, "default-bold", "center", "center", true, true)

    drawButton("popup-close", "Закрыть", x + 26, y + h - 56, w - 52, 34, function()
        closeAction()
    end)
end

addEventHandler("onClientRender", root, function()
    if not ui.visible then
        return
    end

    clickable = {}

    if ui.mode == "register" then
        renderRegisterPanel()
    else
        renderLoginPanel()
    end

    if ui.forgotPopup then
        renderPopup("Свяжитесь с администрацией в Telegram", function()
            ui.forgotPopup = false
        end)
    elseif ui.popup.visible then
        renderPopup(ui.popup.text, hidePopup)
    end
end)

addEventHandler("onClientClick", root, function(button, state, x, y)
    if not ui.visible or button ~= "left" or state ~= "down" then
        return
    end

    if ui.popup.visible or ui.forgotPopup then
        -- Пока открыт popup, клики только по нему.
        for _, hit in ipairs(clickable) do
            if hit.id == "popup-close" and isPointInRect(x, y, hit.x, hit.y, hit.w, hit.h) then
                hit.onClick()
                return
            end
        end
        return
    end

    for _, hit in ipairs(clickable) do
        if isPointInRect(x, y, hit.x, hit.y, hit.w, hit.h) then
            hit.onClick()
            return
        end
    end

    ui.focusField = nil
end)

local function getFocusedValueRef()
    if not ui.focusField then
        return nil, nil
    end

    local scope, field = ui.focusField:match("^(%w+)%.(%w+)$")
    if not scope or not field then
        return nil, nil
    end

    local bucket = scope == "login" and ui.loginData or ui.registerData
    if not bucket then
        return nil, nil
    end

    return bucket, field
end

addEventHandler("onClientCharacter", root, function(char)
    if not ui.visible or ui.popup.visible or ui.forgotPopup then
        return
    end

    local bucket, field = getFocusedValueRef()
    if not bucket or not field then
        return
    end

    local value = bucket[field] or ""
    local length = utf8.len(value) or #value
    if length >= ui.maxFieldLength then
        return
    end

    if char and char ~= "\r" and char ~= "\n" and char ~= "\t" then
        bucket[field] = value .. char
    end
end)

addEventHandler("onClientKey", root, function(button, press)
    if not ui.visible or not press then
        return
    end

    if button == "escape" then
        cancelEvent()
        return
    end

    if ui.popup.visible or ui.forgotPopup then
        if button == "enter" or button == "num_enter" then
            if ui.popup.visible then
                hidePopup()
            else
                ui.forgotPopup = false
            end
            cancelEvent()
        end
        return
    end

    local bucket, field = getFocusedValueRef()

    if button == "backspace" and bucket and field then
        local value = bucket[field] or ""
        local length = utf8.len(value)
        if length and length > 0 then
            bucket[field] = utf8.sub(value, 1, length - 1) or ""
        end
        cancelEvent()
    elseif button == "tab" then
        cancelEvent()
    end
end)

addEvent("loginPanel:onLoginResult", true)
addEventHandler("loginPanel:onLoginResult", resourceRoot, function(success, message)
    if success then
        ui.visible = false
        ui.popup.visible = false
        ui.forgotPopup = false
        ui.focusField = nil
        unlockPlayerState()
        return
    end

    showPopup(message or "Неверный логин или пароль")
end)

addEvent("loginPanel:onRegisterResult", true)
addEventHandler("loginPanel:onRegisterResult", resourceRoot, function(success, message)
    if success then
        showPopup(message or "Регистрация завершена")
        ui.mode = "login"
        ui.focusField = nil
        ui.loginData.login = ui.registerData.login
        ui.loginData.password = ""
        ui.registerData.password = ""
        ui.registerData.passwordRepeat = ""
        return
    end

    showPopup(message or "Ошибка регистрации")
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    ui.visible = true
    ui.mode = "login"
    ui.focusField = nil
    lockPlayerState()
end)


addEventHandler("onClientResourceStop", resourceRoot, function()
    if ui.visible then
        unlockPlayerState()
    end
end)
