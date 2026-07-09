local function validLogin(login)
    return type(login) == "string" and #login >= AuthConfig.input.loginMin and #login <= AuthConfig.input.loginMax and login:match("^[A-Za-z0-9_]+$") ~= nil
end

local function validPassword(password)
    return type(password) == "string" and #password >= AuthConfig.input.passwordMin and #password <= AuthConfig.input.passwordMax
end

addEvent("auth:login", true)
addEventHandler("auth:login", root, function(login, password, remember)
    if client ~= source then return end
    if not validLogin(login) or not validPassword(password) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Проверьте логин и пароль."); return end
    local account = getAccount(login, password)
    if not account then triggerClientEvent(client, "auth:response", resourceRoot, false, "Неверный логин или пароль."); return end
    if logIn(client, account, password) then
        setAccountData(account, "auth:lastLogin", getRealTime().timestamp)
        triggerClientEvent(client, "auth:response", resourceRoot, true, "Добро пожаловать!", remember and login or false)
        local s = AuthConfig.spawn
        spawnPlayer(client, s.x, s.y, s.z, s.rotation, s.skin, s.interior, s.dimension)
        fadeCamera(client, true)
        setCameraTarget(client, client)
    else
        triggerClientEvent(client, "auth:response", resourceRoot, false, "Не удалось выполнить вход.")
    end
end)

addEvent("auth:register", true)
addEventHandler("auth:register", root, function(login, password, repeatPassword, remember)
    if client ~= source then return end
    if not validLogin(login) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Логин: 3-24 символа, латиница, цифры и _."); return end
    if not validPassword(password) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Пароль должен быть от 6 до 32 символов."); return end
    if password ~= repeatPassword then triggerClientEvent(client, "auth:response", resourceRoot, false, "Пароли не совпадают."); return end
    if getAccount(login) then triggerClientEvent(client, "auth:response", resourceRoot, false, "Аккаунт уже существует."); return end
    local account = addAccount(login, password)
    if not account then triggerClientEvent(client, "auth:response", resourceRoot, false, "Не удалось создать аккаунт."); return end
    setAccountData(account, "auth:registeredAt", getRealTime().timestamp)
    logIn(client, account, password)
    triggerClientEvent(client, "auth:response", resourceRoot, true, "Аккаунт создан!", remember and login or false)
    local s = AuthConfig.spawn
    spawnPlayer(client, s.x, s.y, s.z, s.rotation, s.skin, s.interior, s.dimension)
    fadeCamera(client, true)
    setCameraTarget(client, client)
end)

addEventHandler("onPlayerJoin", root, function() fadeCamera(source, false, 0, 0, 0, 0) end)
