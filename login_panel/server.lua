--[[
    login_panel/server.lua
    Серверная логика авторизации и регистрации:
    - SQLite-база accounts.db
    - хеширование пароля через sha256
    - обработка событий login/register
]]

local db = dbConnect("sqlite", "accounts.db")

if not db then
    outputDebugString("[login_panel] Не удалось подключиться к SQLite", 1)
else
    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            login TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            email TEXT NOT NULL
        )
    ]])
end

local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function isValidText(value, minLen, maxLen)
    if type(value) ~= "string" then
        return false
    end

    local len = utf8.len(value)
    return len and len >= minLen and len <= maxLen
end

local function setPlayerAuthed(player, state)
    if not isElement(player) then
        return
    end

    setElementData(player, "auth:loggedIn", state and true or false)
end

addEvent("loginPanel:requestLogin", true)
addEventHandler("loginPanel:requestLogin", resourceRoot, function(login, password)
    local player = client
    if not isElement(player) or not db then
        return
    end

    login = trim(tostring(login or ""))
    password = tostring(password or "")

    if not isValidText(login, 3, 24) or not isValidText(password, 3, 64) then
        triggerClientEvent(player, "loginPanel:onLoginResult", resourceRoot, false, "Неверный логин или пароль")
        return
    end

    local rows = dbPoll(dbQuery(db, "SELECT id, password FROM accounts WHERE login = ? LIMIT 1", login), -1)
    local account = rows and rows[1]
    local passwordHash = hash("sha256", password)

    if not account or account.password ~= passwordHash then
        triggerClientEvent(player, "loginPanel:onLoginResult", resourceRoot, false, "Неверный логин или пароль")
        return
    end

    setPlayerAuthed(player, true)
    triggerClientEvent(player, "loginPanel:onLoginResult", resourceRoot, true, "Успешный вход")
end)

addEvent("loginPanel:requestRegister", true)
addEventHandler("loginPanel:requestRegister", resourceRoot, function(login, password, passwordRepeat, email)
    local player = client
    if not isElement(player) or not db then
        return
    end

    login = trim(tostring(login or ""))
    password = tostring(password or "")
    passwordRepeat = tostring(passwordRepeat or "")
    email = trim(tostring(email or ""))

    if not isValidText(login, 3, 24) then
        triggerClientEvent(player, "loginPanel:onRegisterResult", resourceRoot, false, "Логин должен быть от 3 до 24 символов")
        return
    end

    if not isValidText(password, 3, 64) then
        triggerClientEvent(player, "loginPanel:onRegisterResult", resourceRoot, false, "Пароль должен быть от 3 до 64 символов")
        return
    end

    if password ~= passwordRepeat then
        triggerClientEvent(player, "loginPanel:onRegisterResult", resourceRoot, false, "Пароли не совпадают")
        return
    end

    if not string.find(email, "^[^%s@]+@[^%s@]+%.[^%s@]+$") then
        triggerClientEvent(player, "loginPanel:onRegisterResult", resourceRoot, false, "Некорректный Email")
        return
    end

    local existing = dbPoll(dbQuery(db, "SELECT id FROM accounts WHERE login = ? LIMIT 1", login), -1)
    if existing and existing[1] then
        triggerClientEvent(player, "loginPanel:onRegisterResult", resourceRoot, false, "Логин уже существует")
        return
    end

    local ok = dbExec(db, "INSERT INTO accounts (login, password, email) VALUES (?, ?, ?)", login, hash("sha256", password), email)
    if not ok then
        triggerClientEvent(player, "loginPanel:onRegisterResult", resourceRoot, false, "Ошибка базы данных")
        return
    end

    triggerClientEvent(player, "loginPanel:onRegisterResult", resourceRoot, true, "Аккаунт создан. Теперь войдите.")
end)

addEventHandler("onPlayerJoin", root, function()
    setPlayerAuthed(source, false)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        setPlayerAuthed(player, false)
    end
end)
