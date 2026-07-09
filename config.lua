AuthConfig = {
    resourceName = "premium_dx_auth",
    colors = {
        window = {30, 30, 30},
        panel = {37, 37, 37},
        primary = {79, 195, 247},
        white = {255, 255, 255},
        text = {205, 210, 214},
        muted = {145, 150, 156},
        error = {239, 83, 80},
        success = {102, 187, 106},
        black = {0, 0, 0}
    },
    design = { width = 1920, height = 1080, panelWidth = 460, panelHeight = 560, radius = 16, overlayAlpha = 35 },
    input = { loginMin = 3, loginMax = 24, passwordMin = 6, passwordMax = 32 },
    rememberKey = "auth_remembered_login",
    database = { file = "auth.db", table = "players" },
    spawn = { x = 367.9, y = -2038.8, z = 7.8, rotation = 180, skin = 0, interior = 0, dimension = 0 },
    camera = {
        fadeInMs = 1600,
        position = {375.0, -2055.0, 28.0},
        lookAt = {365.0, -1935.0, 7.0}
    }
}
