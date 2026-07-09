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

local function query(sql, ...)
    local handle = dbQuery(db, sql, ...)
    return dbPoll(handle, -1) or {}
end

local function queryOne(sql, ...)
    return query(sql, ...)[1]
end

local function columnExists(name)
    for _, row in ipairs(query("PRAGMA table_info(players)")) do
        if row.name == name then return true end
    end
    return false
end

local function addColumn(name, definition)
    if not columnExists(name) then
        dbExec(db, "ALTER TABLE players ADD COLUMN " .. name .. " " .. definition)
    end
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

    addColumn("pos_x", "REAL")
    addColumn("pos_y", "REAL")
    addColumn("pos_z", "REAL")
    addColumn("rotation", "REAL")
    addColumn("interior", "INTEGER DEFAULT 0")
    addColumn("dimension", "INTEGER DEFAULT 0")
    addColumn("health", "REAL DEFAULT 100")
    addColumn("armor", "REAL DEFAULT 0")
    addColumn("money", "INTEGER DEFAULT 0")
    addColumn("skin", "INTEGER DEFAULT 0")
    addColumn("weapons", "TEXT")
    addColumn("has_position", "INTEGER DEFAULT 0")
    return true
end

local function getPlayerWeapons(player)
    local weapons = {}
    for slot = 0, 12 do
        local weapon = getPedWeapon(player, slot)
        local ammo = getPedTotalAmmo(player, slot)
        if weapon and weapon > 0 and ammo and ammo > 0 then
            weapons[#weapons + 1] = { weapon = weapon, ammo = ammo }
        end
    end
    return toJSON(weapons, true)
end

local function restoreWeapons(player, weaponsJson)
    takeAllWeapons(player)
    if not weaponsJson or weaponsJson == "" then return end

    local weapons = fromJSON(weaponsJson)
    if type(weapons) ~= "table" then return end

    for _, item in ipairs(weapons) do
        if item.weapon and item.ammo then
            giveWeapon(player, tonumber(item.weapon), tonumber(item.ammo), false)
        end
    end
end

local function applyPlayerState(player, row)
    setElementHealth(player, tonumber(row.health) or 100)
    setPedArmor(player, tonumber(row.armor) or 0)
    setPlayerMoney(player, tonumber(row.money) or 0)
    restoreWeapons(player, row.weapons)
end

local function spawnAt(player, data)
    spawnPlayer(player, data.x, data.y, data.z, data.rotation, data.skin, data.interior, data.dimension)
    setPedRotation(player, data.rotation)
    setElementInterior(player, data.interior)
    setElementDimension(player, data.dimension)
    fadeCamera(player, true, 0)
    setCameraTarget(player, player)
    toggleAllControls(player, true)
end

local function spawnAuthorizedPlayer(player, row)
    if tonumber(row.has_position) == 1 and row.pos_x and row.pos_y and row.pos_z then
        spawnAt(player, {
            x = tonumber(row.pos_x),
            y = tonumber(row.pos_y),
            z = tonumber(row.pos_z),
            rotation = tonumber(row.rotation) or AuthConfig.spawn.rotation,
            skin = tonumber(row.skin) or AuthConfig.spawn.skin,
            interior = tonumber(row.interior) or AuthConfig.spawn.interior,
            dimension = tonumber(row.dimension) or AuthConfig.spawn.dimension
        })
        applyPlayerState(player, row)
        return
    end

    local s = AuthConfig.spawn
    spawnAt(player, { x = s.x, y = s.y, z = s.z, rotation = s.rotation, skin = s.skin, interior = s.interior, dimension = s.dimension })
    setElementHealth(player, 100)
    setPedArmor(player, 0)
end

local function getPlayerId(player)
    return getElementData(player, "auth:playerId")
end

local function savePlayerState(player)
    local id = getPlayerId(player)
    if not db or not id or not isElement(player) then return false end

    local x, y, z = getElementPosition(player)
    local _, _, rz = getElementRotation(player)
    return dbExec(db, [[
        UPDATE players SET
            pos_x = ?, pos_y = ?, pos_z = ?, rotation = ?, interior = ?, dimension = ?,
            health = ?, armor = ?, money = ?, skin = ?, weapons = ?, has_position = 1
        WHERE id = ?
    ]], x, y, z, rz, getElementInterior(player), getElementDimension(player), getElementHealth(player), getPedArmor(player), getPlayerMoney(player), getElementModel(player), getPlayerWeapons(player), id)
end

local function respawnAtHospital(player)
    if not isElement(player) or not getPlayerId(player) then return end

    local h = AuthConfig.hospital
    spawnAt(player, { x = h.x, y = h.y, z = h.z, rotation = h.rotation, skin = getElementModel(player) or h.skin, interior = h.interior, dimension = h.dimension })
    setElementHealth(player, h.health)
    setPedArmor(player, 0)
    fadeCamera(player, true, 0)
    setCameraTarget(player, player)
    savePlayerState(player)
end

addEventHandler("onResourceStart", resourceRoot, initDatabase)

addEvent("auth:login", true)
addEventHandler("auth:login", root, function(login, password, remember)
    if client ~= source then return end
    if not db then triggerClientEvent(client, "auth:response", resourceRoot, false, "База данных недоступна."); return end
    if not validLogin(login) or not validPassword(password) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Проверьте логин и пароль."); return end

    local row = queryOne("SELECT * FROM players WHERE login = ? LIMIT 1", login)
    if not row then triggerClientEvent(client, "auth:response", resourceRoot, false, "Аккаунт не найден."); return end
    if row.password ~= passwordHash(password, row.serial) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Неверный логин или пароль."); return end

    dbExec(db, "UPDATE players SET last_login = ?, serial = ? WHERE id = ?", now(), getPlayerSerial(client), row.id)
    setElementData(client, "auth:loggedIn", true, false)
    setElementData(client, "auth:login", login, false)
    setElementData(client, "auth:playerId", row.id, false)
    spawnAuthorizedPlayer(client, row)
    triggerClientEvent(client, "auth:response", resourceRoot, true, "Добро пожаловать!", remember and login or false)
end)

addEvent("auth:register", true)
addEventHandler("auth:register", root, function(login, password, repeatPassword, remember)
    if client ~= source then return end
    if not db then triggerClientEvent(client, "auth:response", resourceRoot, false, "База данных недоступна."); return end
    if not validLogin(login) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Логин: 3-24 символа, латиница, цифры и _."); return end
    if not validPassword(password) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Пароль должен быть от 6 до 32 символов."); return end
    if password ~= repeatPassword then triggerClientEvent(client, "auth:response", resourceRoot, false, "Пароли не совпадают."); return end
    if queryOne("SELECT id FROM players WHERE login = ? LIMIT 1", login) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Аккаунт уже существует."); return end

    local serial, stamp = getPlayerSerial(client), now()
    local ok = dbExec(db, "INSERT INTO players (login, password, serial, created_at, last_login, skin) VALUES (?, ?, ?, ?, ?, ?)", login, passwordHash(password, serial), serial, stamp, stamp, AuthConfig.spawn.skin)
    if not ok then triggerClientEvent(client, "auth:response", resourceRoot, false, "Не удалось создать аккаунт."); return end

    local row = queryOne("SELECT * FROM players WHERE login = ? LIMIT 1", login)
    setElementData(client, "auth:loggedIn", true, false)
    setElementData(client, "auth:login", login, false)
    setElementData(client, "auth:playerId", row.id, false)
    spawnAuthorizedPlayer(client, row)
    triggerClientEvent(client, "auth:response", resourceRoot, true, "Аккаунт создан!", remember and login or false)
end)

addEventHandler("onPlayerWasted", root, function()
    fadeCamera(source, true, 0)
    setTimer(respawnAtHospital, 3000, 1, source)
end)

addEventHandler("onPlayerQuit", root, function()
    savePlayerState(source)
end)

addEventHandler("onPlayerJoin", root, function()
    fadeCamera(source, true, 0)
    toggleAllControls(source, false, true, false)
end)
