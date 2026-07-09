local db

local function validLogin(login)
    return type(login) == "string" and #login >= AuthConfig.input.loginMin and #login <= AuthConfig.input.loginMax and login:match("^[A-Za-z0-9_]+$") ~= nil
end

local function validPassword(password)
    return type(password) == "string" and #password >= AuthConfig.input.passwordMin and #password <= AuthConfig.input.passwordMax
end

local function passwordHash(password, serial)
    return hash("sha256", tostring(password) .. ":" .. tostring(serial) .. ":" .. AuthConfig.resourceName)
end

local function now()
    return getRealTime().timestamp
end

local function initDatabase()
    db = dbConnect("sqlite", AuthConfig.database.file)
    if not db then
        outputDebugString("[Auth] SQLite connection failed.", 1)
        return false
    end

    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            login TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            serial TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            last_login INTEGER NOT NULL
        )
    ]])
    return true
end

local function queryOne(sql, ...)
    local handle = dbQuery(db, sql, ...)
    local result = dbPoll(handle, -1)
    return result and result[1]
end

local function spawnAuthorizedPlayer(player)
    local s = AuthConfig.spawn
    spawnPlayer(player, s.x, s.y, s.z, s.rotation, s.skin, s.interior, s.dimension)
    fadeCamera(player, true)
    setCameraTarget(player, player)
    toggleAllControls(player, true)
end

addEventHandler("onResourceStart", resourceRoot, initDatabase)

addEvent("auth:login", true)
addEventHandler("auth:login", root, function(login, password, remember)
    if client ~= source then return end
    if not db then triggerClientEvent(client, "auth:response", resourceRoot, false, "База данных недоступна."); return end
    if not validLogin(login) or not validPassword(password) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Проверьте логин и пароль."); return end

    local row = queryOne("SELECT id, password, serial FROM players WHERE login = ? LIMIT 1", login)
    if not row then triggerClientEvent(client, "auth:response", resourceRoot, false, "Аккаунт не найден."); return end

    local serial = getPlayerSerial(client)
    if row.password ~= passwordHash(password, row.serial) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Неверный логин или пароль."); return end

    dbExec(db, "UPDATE players SET last_login = ?, serial = ? WHERE id = ?", now(), serial, row.id)
    setElementData(client, "auth:loggedIn", true, false)
    setElementData(client, "auth:login", login, false)
    spawnAuthorizedPlayer(client)
    triggerClientEvent(client, "auth:response", resourceRoot, true, "Добро пожаловать!", remember and login or false)
end)

addEvent("auth:register", true)
addEventHandler("auth:register", root, function(login, password, repeatPassword, remember)
    if client ~= source then return end
    if not db then triggerClientEvent(client, "auth:response", resourceRoot, false, "База данных недоступна."); return end
    if not validLogin(login) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Логин: 3-24 символа, латиница, цифры и _. "); return end
    if not validPassword(password) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Пароль должен быть от 6 до 32 символов."); return end
    if password ~= repeatPassword then triggerClientEvent(client, "auth:response", resourceRoot, false, "Пароли не совпадают."); return end
    if queryOne("SELECT id FROM players WHERE login = ? LIMIT 1", login) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Аккаунт уже существует."); return end

    local serial, stamp = getPlayerSerial(client), now()
    local ok = dbExec(db, "INSERT INTO players (login, password, serial, created_at, last_login) VALUES (?, ?, ?, ?, ?)", login, passwordHash(password, serial), serial, stamp, stamp)
    if not ok then triggerClientEvent(client, "auth:response", resourceRoot, false, "Не удалось создать аккаунт."); return end

    setElementData(client, "auth:loggedIn", true, false)
    setElementData(client, "auth:login", login, false)
    spawnAuthorizedPlayer(client)
    triggerClientEvent(client, "auth:response", resourceRoot, true, "Аккаунт создан!", remember and login or false)
end)

addEventHandler("onPlayerJoin", root, function()
    fadeCamera(source, false, 0, 0, 0, 0)
    toggleAllControls(source, false, true, false)
end)
