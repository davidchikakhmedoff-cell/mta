AuthUI = { visible = false, mode = "login", alpha = 0, targetAlpha = 0, switching = false, remember = false, notice = nil, blocked = {"fire", "aim_weapon", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "jump", "sprint", "crouch", "enter_exit", "vehicle_fire", "vehicle_secondary_fire", "chatbox"} }

function AuthUI.init()
    AuthUI.login = DXInput:new("Логин", false, AuthConfig.input.loginMax)
    AuthUI.password = DXInput:new("Пароль", true, AuthConfig.input.passwordMax)
    AuthUI.repeatPassword = DXInput:new("Повторите пароль", true, AuthConfig.input.passwordMax)
    AuthUI.submit = DXButton:new("Войти", AuthUI.submitForm)
    local saved = getElementData(localPlayer, AuthConfig.rememberKey) or loadRememberedLogin()
    if saved then AuthUI.login:setText(saved); AuthUI.remember = true end
end

function loadRememberedLogin()
    if not fileExists("remember.xml") then return false end
    local f = xmlLoadFile("remember.xml"); if not f then return false end
    local value = xmlNodeGetAttribute(f, "login"); xmlUnloadFile(f); return value
end

function saveRememberedLogin(login)
    if fileExists("remember.xml") then fileDelete("remember.xml") end
    if not login then return end
    local f = xmlCreateFile("remember.xml", "auth"); xmlNodeSetAttribute(f, "login", login); xmlSaveFile(f); xmlUnloadFile(f)
end

function AuthUI.show()
    if AuthUI.visible then return end
    if not AuthUI.login then AuthUI.init() end
    AuthUI.visible = true; AuthUI.targetAlpha = 255; showCursor(true); showChat(false); toggleAllControls(false, true, false)
    addEventHandler("onClientRender", root, AuthUI.render)
    addEventHandler("onClientClick", root, AuthUI.click)
    addEventHandler("onClientKey", root, AuthUI.key)
    addEventHandler("onClientCharacter", root, AuthUI.char)
    addEventHandler("onClientPaste", root, AuthUI.paste)
end

function AuthUI.hide()
    AuthUI.targetAlpha = 0; showCursor(false); showChat(true); toggleAllControls(true)
    removeEventHandler("onClientClick", root, AuthUI.click)
    removeEventHandler("onClientKey", root, AuthUI.key)
    removeEventHandler("onClientCharacter", root, AuthUI.char)
    removeEventHandler("onClientPaste", root, AuthUI.paste)
end

function AuthUI.setNotice(text, good)
    AuthUI.notice = { text = text, good = good, tick = getTickCount() }
end

function AuthUI.switchMode(mode)
    AuthUI.mode = mode; AuthUI.submit.text = mode == "login" and "Войти" or "Создать аккаунт"; AuthUI.setNotice(nil)
end

function AuthUI.validate()
    local login, pass, repeatPass = AuthUI.login:getText(), AuthUI.password:getText(), AuthUI.repeatPassword:getText()
    if not login:match("^[A-Za-z0-9_]+$") or #login < AuthConfig.input.loginMin or #login > AuthConfig.input.loginMax then return false, "Логин: 3-24 символа, латиница, цифры и _." end
    if #pass < AuthConfig.input.passwordMin or #pass > AuthConfig.input.passwordMax then return false, "Пароль должен быть от 6 до 32 символов." end
    if AuthUI.mode == "register" and pass ~= repeatPass then return false, "Пароли не совпадают." end
    return true
end

function AuthUI.submitForm()
    local ok, err = AuthUI.validate(); if not ok then AuthUI.setNotice(err, false); return end
    AuthUI.submit.enabled = false
    if AuthUI.mode == "login" then triggerServerEvent("auth:login", localPlayer, AuthUI.login:getText(), AuthUI.password:getText(), AuthUI.remember) else triggerServerEvent("auth:register", localPlayer, AuthUI.login:getText(), AuthUI.password:getText(), AuthUI.repeatPassword:getText(), AuthUI.remember) end
end

function AuthUI.render()
    AuthUI.alpha = DXUtils.lerp(AuthUI.alpha, AuthUI.targetAlpha, 0.08)
    local a = AuthUI.alpha
    if a < 1 and AuthUI.targetAlpha == 0 then AuthUI.visible = false; removeEventHandler("onClientRender", root, AuthUI.render); return end
    local sw, sh = guiGetScreenSize(); dxDrawRectangle(0, 0, sw, sh, tocolor(0,0,0,120 * (a / 255)))
    local s = DXUtils.s; local w, h = s(AuthConfig.design.panelWidth), s(AuthConfig.design.panelHeight + (AuthUI.mode == "register" and 78 or 0)); local x, y = (sw - w) / 2, (sh - h) / 2
    DXUtils.shadow(x, y, w, h, s(18), 85 * a / 255); DXUtils.roundedRect(x, y, w, h, s(18), DXUtils.color(AuthConfig.colors.window, a))
    local pad = s(38); local cy = y + s(34)
    dxDrawText(AuthUI.mode == "login" and "Добро пожаловать" or "Создание аккаунта", x, cy, x + w, cy + s(34), tocolor(255,255,255,a), 1.35, "default-bold", "center", "center")
    cy = cy + s(36); dxDrawText(AuthUI.mode == "login" and "Войдите в свой аккаунт" or "Добро пожаловать на сервер", x, cy, x + w, cy + s(24), DXUtils.color(AuthConfig.colors.text, a), 1, "default", "center", "center")
    cy = cy + s(48); AuthUI.login:draw(x + pad, cy, w - pad*2, s(56), a, "👤")
    cy = cy + s(70); AuthUI.password:draw(x + pad, cy, w - pad*2, s(56), a, "🔒")
    if AuthUI.mode == "register" then cy = cy + s(70); AuthUI.repeatPassword:draw(x + pad, cy, w - pad*2, s(56), a, "✓") end
    cy = cy + s(70); local box = s(18); DXUtils.roundedRect(x + pad, cy, box, box, s(4), AuthUI.remember and DXUtils.color(AuthConfig.colors.primary,a) or DXUtils.color(AuthConfig.colors.panel,a)); if AuthUI.remember then dxDrawText("✓", x+pad, cy-1, x+pad+box, cy+box, tocolor(255,255,255,a), 1, "default-bold", "center", "center") end
    dxDrawText("Запомнить меня", x + pad + s(28), cy - s(2), x + w, cy + box, DXUtils.color(AuthConfig.colors.text,a), 1, "default", "left", "center")
    if AuthUI.mode == "login" then dxDrawText("Забыли пароль?", x, cy - s(2), x + w - pad, cy + box, DXUtils.color(AuthConfig.colors.primary,a), 1, "default", "right", "center") end
    cy = cy + s(50); AuthUI.submit:draw(x + pad, cy, w - pad*2, s(56), a)
    cy = cy + s(78); local lead = AuthUI.mode == "login" and "Нет аккаунта? " or "Уже есть аккаунт? "; local link = AuthUI.mode == "login" and "Регистрация" or "Войти"
    dxDrawText(lead, x, cy, x + w, cy + s(24), DXUtils.color(AuthConfig.colors.muted,a), 1, "default", "center", "center")
    dxDrawText(link, x + s(120), cy, x + w, cy + s(24), DXUtils.color(AuthConfig.colors.primary,a), 1, "default-bold", "center", "center")
    if AuthUI.notice and AuthUI.notice.text then local c = AuthUI.notice.good and AuthConfig.colors.success or AuthConfig.colors.error; DXUtils.roundedRect(x + pad, y + h - s(44), w - pad*2, s(34), s(8), tocolor(c[1],c[2],c[3],220 * a/255)); dxDrawText(AuthUI.notice.text, x+pad+s(10), y+h-s(44), x+w-pad-s(10), y+h-s(10), tocolor(255,255,255,a), .9, "default", "center", "center", true) end
end

function AuthUI.click(button, state, x, y)
    if button ~= "left" or state ~= "down" and state ~= "up" then return end
    local sw, sh = guiGetScreenSize(); local s = DXUtils.s; local w, h = s(AuthConfig.design.panelWidth), s(AuthConfig.design.panelHeight + (AuthUI.mode == "register" and 78 or 0)); local px, py = (sw - w)/2, (sh-h)/2; local pad=s(38); local cy=py+s(152)
    if state == "down" then AuthUI.login:click(x,y,px+pad,cy,w-pad*2,s(56)); cy=cy+s(70); AuthUI.password:click(x,y,px+pad,cy,w-pad*2,s(56)); if AuthUI.mode=="register" then cy=cy+s(70); AuthUI.repeatPassword:click(x,y,px+pad,cy,w-pad*2,s(56)) end; cy=cy+s(70); if x>=px+pad and x<=px+pad+s(210) and y>=cy and y<=cy+s(24) then AuthUI.remember=not AuthUI.remember end end
    local btnY = py + h - s(166); AuthUI.submit:mouse(button,state,x,y,px+pad,btnY,w-pad*2,s(56))
    if state == "up" and y >= py + h - s(88) and y <= py + h - s(48) then AuthUI.switchMode(AuthUI.mode == "login" and "register" or "login") end
end
function AuthUI.key(button, press) cancelEvent(); if DXInput.active then DXInput.active:key(button, press) end end
function AuthUI.char(c) if DXInput.active then DXInput.active:char(c) end end
function AuthUI.paste(text) if DXInput.active and text then for char in tostring(text):gmatch(".") do DXInput.active:char(char) end end end
