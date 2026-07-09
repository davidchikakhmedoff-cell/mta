-- DX authorization panel. All drawing and clicks use the same calculated hitboxes.
AuthUI = {
    visible = false,
    mode = "login",
    alpha = 0,
    targetAlpha = 0,
    remember = false,
    notice = nil,
    helpVisible = false,
    hitboxes = {}
}

function AuthUI.init()
    AuthUI.login = DXInput:new("Логин", false, AuthConfig.input.loginMax)
    AuthUI.password = DXInput:new("Пароль", true, AuthConfig.input.passwordMax)
    AuthUI.repeatPassword = DXInput:new("Повторите пароль", true, AuthConfig.input.passwordMax)
    AuthUI.rpName = DXInput:new("RP-ник: Name Surname", false, 32)
    AuthUI.submit = DXButton:new("Войти", AuthUI.submitForm)

    local saved = loadRememberedLogin()
    if saved then
        AuthUI.login:setText(saved)
        AuthUI.remember = true
    end
end

function loadRememberedLogin()
    if not fileExists("remember.xml") then return false end
    local file = xmlLoadFile("remember.xml")
    if not file then return false end
    local value = xmlNodeGetAttribute(file, "login")
    xmlUnloadFile(file)
    return value
end

function saveRememberedLogin(login)
    if fileExists("remember.xml") then fileDelete("remember.xml") end
    if not login then return end

    local file = xmlCreateFile("remember.xml", "auth")
    xmlNodeSetAttribute(file, "login", login)
    xmlSaveFile(file)
    xmlUnloadFile(file)
end

local function buildLayout()
    local screenW, screenH = guiGetScreenSize()
    local s = DXUtils.s
    local width = s(AuthConfig.design.panelWidth)
    local height = s(AuthConfig.design.panelHeight + (AuthUI.mode == "register" and 148 or 0))
    local x, y = (screenW - width) / 2, (screenH - height) / 2
    local pad = s(38)
    local inputW, inputH = width - pad * 2, s(56)
    local cy = y + s(152)

    local boxes = {
        panel = { x = x, y = y, w = width, h = height, pad = pad },
        login = { x = x + pad, y = cy, w = inputW, h = inputH }
    }

    cy = cy + s(70)
    boxes.password = { x = x + pad, y = cy, w = inputW, h = inputH }

    if AuthUI.mode == "register" then
        cy = cy + s(70)
        boxes.repeatPassword = { x = x + pad, y = cy, w = inputW, h = inputH }
        cy = cy + s(70)
        boxes.rpName = { x = x + pad, y = cy, w = inputW, h = inputH }
        cy = cy + s(46)
        boxes.rpHelp = { x = x + pad, y = cy, w = inputW, h = s(24) }
    end

    cy = cy + s(70)
    boxes.remember = { x = x + pad, y = cy, w = s(210), h = s(24), box = s(18) }

    cy = cy + s(50)
    boxes.submit = { x = x + pad, y = cy, w = inputW, h = inputH }

    cy = cy + s(78)
    boxes.switchLine = { x = x + pad, y = cy - s(8), w = inputW, h = s(40) }
    boxes.switch = { x = x + pad, y = cy - s(8), w = 0, h = s(40) }

    return boxes
end

function AuthUI.show()
    if AuthUI.visible then return end
    if not AuthUI.login then AuthUI.init() end

    AuthUI.visible = true
    AuthUI.targetAlpha = 255
    showCursor(true)
    showChat(false)
    toggleAllControls(false, true, false)

    addEventHandler("onClientRender", root, AuthUI.render)
    addEventHandler("onClientClick", root, AuthUI.click)
    addEventHandler("onClientKey", root, AuthUI.key)
    addEventHandler("onClientCharacter", root, AuthUI.char)
    addEventHandler("onClientPaste", root, AuthUI.paste)
end

local function removeInputHandlers()
    removeEventHandler("onClientClick", root, AuthUI.click)
    removeEventHandler("onClientKey", root, AuthUI.key)
    removeEventHandler("onClientCharacter", root, AuthUI.char)
    removeEventHandler("onClientPaste", root, AuthUI.paste)
end

function AuthUI.hide(immediate, keepControlsDisabled)
    AuthUI.targetAlpha = 0
    AuthUI.submit.enabled = false
    showCursor(false)
    showChat(true)
    if not keepControlsDisabled then
        toggleAllControls(true)
    end
    removeInputHandlers()

    if immediate then
        AuthUI.alpha = 0
        AuthUI.visible = false
        AuthUI.hitboxes = {}
        removeEventHandler("onClientRender", root, AuthUI.render)
    end
end

function AuthUI.setNotice(text, good)
    AuthUI.notice = text and { text = text, good = good, tick = getTickCount() } or nil
end

function AuthUI.switchMode(mode)
    AuthUI.mode = mode
    AuthUI.submit.text = mode == "login" and "Войти" or "Создать аккаунт"
    AuthUI.setNotice(nil)
end

function AuthUI.validate()
    local login = AuthUI.login:getText()
    local password = AuthUI.password:getText()
    local repeatPassword = AuthUI.repeatPassword:getText()
    local rpName = AuthUI.rpName:getText()

    if not login:match("^[A-Za-z0-9_]+$") or #login < AuthConfig.input.loginMin or #login > AuthConfig.input.loginMax then
        return false, "Логин: 3-24 символа, латиница, цифры и _."
    end
    if #password < AuthConfig.input.passwordMin or #password > AuthConfig.input.passwordMax then
        return false, "Пароль должен быть от 6 до 32 символов."
    end
    if AuthUI.mode == "register" and password ~= repeatPassword then
        return false, "Пароли не совпадают."
    end
    if AuthUI.mode == "register" and not rpName:match("^[A-Z][a-z]+ [A-Z][a-z]+$") then
        return false, "RP-ник должен быть в формате Name Surname."
    end
    return true
end

function AuthUI.submitForm()
    local ok, err = AuthUI.validate()
    if not ok then
        AuthUI.setNotice(err, false)
        return
    end

    AuthUI.submit.enabled = false
    if AuthUI.mode == "login" then
        triggerServerEvent("auth:login", localPlayer, AuthUI.login:getText(), AuthUI.password:getText(), AuthUI.remember)
    else
        triggerServerEvent("auth:register", localPlayer, AuthUI.login:getText(), AuthUI.password:getText(), AuthUI.repeatPassword:getText(), AuthUI.remember, AuthUI.rpName:getText())
    end
end

function AuthUI.render()
    AuthUI.alpha = DXUtils.lerp(AuthUI.alpha, AuthUI.targetAlpha, 0.08)
    local alpha = AuthUI.alpha

    if alpha < 1 and AuthUI.targetAlpha == 0 then
        AuthUI.visible = false
        removeEventHandler("onClientRender", root, AuthUI.render)
        return
    end

    local screenW, screenH = guiGetScreenSize()
    local s = DXUtils.s
    AuthUI.hitboxes = buildLayout()
    local boxes = AuthUI.hitboxes
    local panel = boxes.panel

    dxDrawRectangle(0, 0, screenW, screenH, tocolor(0, 0, 0, AuthConfig.design.overlayAlpha * (alpha / 255)))
    DXUtils.shadow(panel.x, panel.y, panel.w, panel.h, s(18), 85 * alpha / 255)
    DXUtils.roundedRect(panel.x, panel.y, panel.w, panel.h, s(18), DXUtils.color(AuthConfig.colors.window, alpha))

    local cy = panel.y + s(34)
    dxDrawText(AuthUI.mode == "login" and "Добро пожаловать" or "Создание аккаунта", panel.x, cy, panel.x + panel.w, cy + s(34), tocolor(255, 255, 255, alpha), 1.35, "default-bold", "center", "center")
    cy = cy + s(36)
    dxDrawText(AuthUI.mode == "login" and "Войдите в свой аккаунт" or "Добро пожаловать на сервер", panel.x, cy, panel.x + panel.w, cy + s(24), DXUtils.color(AuthConfig.colors.text, alpha), 1, "default", "center", "center")

    AuthUI.login:draw(boxes.login.x, boxes.login.y, boxes.login.w, boxes.login.h, alpha, "👤")
    AuthUI.password:draw(boxes.password.x, boxes.password.y, boxes.password.w, boxes.password.h, alpha, "🔒")
    if AuthUI.mode == "register" then
        AuthUI.repeatPassword:draw(boxes.repeatPassword.x, boxes.repeatPassword.y, boxes.repeatPassword.w, boxes.repeatPassword.h, alpha, "✓")
        AuthUI.rpName:draw(boxes.rpName.x, boxes.rpName.y, boxes.rpName.w, boxes.rpName.h, alpha, "RP")
        local helpColor = DXUtils.inBox(boxes.rpHelp.x, boxes.rpHelp.y, boxes.rpHelp.w, boxes.rpHelp.h) and tocolor(120, 215, 255, alpha) or DXUtils.color(AuthConfig.colors.primary, alpha)
        dxDrawText("Как должен быть ник?", boxes.rpHelp.x, boxes.rpHelp.y, boxes.rpHelp.x + boxes.rpHelp.w, boxes.rpHelp.y + boxes.rpHelp.h, helpColor, 1, "default-bold", "center", "center")
    end

    local remember = boxes.remember
    DXUtils.roundedRect(remember.x, remember.y, remember.box, remember.box, s(4), AuthUI.remember and DXUtils.color(AuthConfig.colors.primary, alpha) or DXUtils.color(AuthConfig.colors.panel, alpha))
    if AuthUI.remember then
        dxDrawText("✓", remember.x, remember.y - 1, remember.x + remember.box, remember.y + remember.box, tocolor(255, 255, 255, alpha), 1, "default-bold", "center", "center")
    end
    dxDrawText("Запомнить меня", remember.x + s(28), remember.y - s(2), panel.x + panel.w, remember.y + remember.box, DXUtils.color(AuthConfig.colors.text, alpha), 1, "default", "left", "center")
    if AuthUI.mode == "login" then
        dxDrawText("Забыли пароль?", panel.x, remember.y - s(2), panel.x + panel.w - panel.pad, remember.y + remember.box, DXUtils.color(AuthConfig.colors.primary, alpha), 1, "default", "right", "center")
    end

    AuthUI.submit:draw(boxes.submit.x, boxes.submit.y, boxes.submit.w, boxes.submit.h, alpha)

    local lead = AuthUI.mode == "login" and "Нет аккаунта?" or "Уже есть аккаунт?"
    local link = AuthUI.mode == "login" and "Регистрация" or "Войти"
    local gap = s(8)
    local leadWidth = dxGetTextWidth(lead, 1, "default")
    local linkWidth = dxGetTextWidth(link, 1, "default-bold")
    local totalWidth = leadWidth + gap + linkWidth
    local lineX = panel.x + (panel.w - totalWidth) / 2
    local lineY = boxes.switchLine.y + s(8)
    boxes.switch = { x = lineX + leadWidth + gap, y = boxes.switchLine.y, w = linkWidth, h = boxes.switchLine.h }
    local hoveredLink = DXUtils.inBox(boxes.switch.x, boxes.switch.y, boxes.switch.w, boxes.switch.h)
    local linkColor = hoveredLink and tocolor(120, 215, 255, alpha) or DXUtils.color(AuthConfig.colors.primary, alpha)
    dxDrawText(lead, lineX, lineY, lineX + leadWidth, lineY + s(24), DXUtils.color(AuthConfig.colors.muted, alpha), 1, "default", "left", "center")
    dxDrawText(link, boxes.switch.x, lineY, boxes.switch.x + linkWidth, lineY + s(24), linkColor, 1, "default-bold", "left", "center")

    if AuthUI.helpVisible then
        local hw, hh = s(520), s(300)
        local hx, hy = (screenW - hw) / 2, (screenH - hh) / 2
        DXUtils.shadow(hx, hy, hw, hh, s(16), 95)
        DXUtils.roundedRect(hx, hy, hw, hh, s(16), DXUtils.color(AuthConfig.colors.window, alpha))
        dxDrawText("Как должен быть RP-ник?", hx, hy + s(22), hx + hw, hy + s(58), tocolor(255,255,255,alpha), 1.25, "default-bold", "center", "center")
        local text = "Правильно: John Smith, Michael Johnson\nНеправильно: john Smith, John_Smith, John123, J Smith\n\nПравила: два слова, один пробел, только латиница.\nПервая буква имени и фамилии заглавная, остальные строчные.\nМинимум 2 символа в имени и фамилии."
        dxDrawText(text, hx + s(32), hy + s(74), hx + hw - s(32), hy + hh - s(58), DXUtils.color(AuthConfig.colors.text, alpha), 1, "default", "left", "top", true, true)
        AuthUI.hitboxes.helpClose = { x = hx + hw - s(132), y = hy + hh - s(46), w = s(100), h = s(30) }
        DXUtils.roundedRect(AuthUI.hitboxes.helpClose.x, AuthUI.hitboxes.helpClose.y, AuthUI.hitboxes.helpClose.w, AuthUI.hitboxes.helpClose.h, s(8), DXUtils.color(AuthConfig.colors.primary, alpha))
        dxDrawText("Понятно", AuthUI.hitboxes.helpClose.x, AuthUI.hitboxes.helpClose.y, AuthUI.hitboxes.helpClose.x + AuthUI.hitboxes.helpClose.w, AuthUI.hitboxes.helpClose.y + AuthUI.hitboxes.helpClose.h, tocolor(255,255,255,alpha), 1, "default-bold", "center", "center")
    end

    if AuthUI.notice then
        local color = AuthUI.notice.good and AuthConfig.colors.success or AuthConfig.colors.error
        DXUtils.roundedRect(panel.x + panel.pad, panel.y + panel.h - s(44), panel.w - panel.pad * 2, s(34), s(8), tocolor(color[1], color[2], color[3], 220 * alpha / 255))
        dxDrawText(AuthUI.notice.text, panel.x + panel.pad + s(10), panel.y + panel.h - s(44), panel.x + panel.w - panel.pad - s(10), panel.y + panel.h - s(10), tocolor(255, 255, 255, alpha), 0.9, "default", "center", "center", true)
    end
end

local function inBox(x, y, box)
    return box and x >= box.x and x <= box.x + box.w and y >= box.y and y <= box.y + box.h
end

function AuthUI.click(button, state, x, y)
    if button ~= "left" then return end
    local boxes = AuthUI.hitboxes
    if not boxes.panel then return end

    if AuthUI.helpVisible then
        if state == "up" and inBox(x, y, boxes.helpClose) then AuthUI.helpVisible = false end
        return
    end

    if state == "down" then
        AuthUI.login:click(x, y, boxes.login.x, boxes.login.y, boxes.login.w, boxes.login.h)
        AuthUI.password:click(x, y, boxes.password.x, boxes.password.y, boxes.password.w, boxes.password.h)
        if AuthUI.mode == "register" then
            AuthUI.repeatPassword:click(x, y, boxes.repeatPassword.x, boxes.repeatPassword.y, boxes.repeatPassword.w, boxes.repeatPassword.h)
            AuthUI.rpName:click(x, y, boxes.rpName.x, boxes.rpName.y, boxes.rpName.w, boxes.rpName.h)
            if inBox(x, y, boxes.rpHelp) then AuthUI.helpVisible = true end
        end
        if inBox(x, y, boxes.remember) then
            AuthUI.remember = not AuthUI.remember
        end
    end

    AuthUI.submit:mouse(button, state, x, y, boxes.submit.x, boxes.submit.y, boxes.submit.w, boxes.submit.h)
    if state == "up" and inBox(x, y, boxes.switch) then
        AuthUI.switchMode(AuthUI.mode == "login" and "register" or "login")
    end
end

function AuthUI.key(button, press)
    cancelEvent()
    if AuthUI.helpVisible then return end
    if DXInput.active then DXInput.active:key(button, press) end
end

function AuthUI.char(char)
    if AuthUI.helpVisible then return end
    if DXInput.active then DXInput.active:char(char) end
end

function AuthUI.paste(text)
    if not DXInput.active or not text then return end
    for char in tostring(text):gmatch(".") do
        DXInput.active:char(char)
    end
end
