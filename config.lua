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
    design = { width = 1920, height = 1080, panelWidth = 460, panelHeight = 560, radius = 16 },
    input = { loginMin = 3, loginMax = 24, passwordMin = 6, passwordMax = 32 },
    rememberKey = "auth_remembered_login",
    spawn = { x = 367.9, y = -2038.8, z = 7.8, rotation = 180, skin = 0, interior = 0, dimension = 0 },
    camera = {
        fadeInMs = 1800,
        points = {
            { pos = {270.0, -1900.0, 25.0}, look = {342.0, -1871.0, 5.5}, duration = 16000 },
            { pos = {410.0, -2010.0, 32.0}, look = {365.0, -2030.0, 7.0}, duration = 18000 },
            { pos = {270.0, -2120.0, 27.0}, look = {390.0, -2050.0, 6.0}, duration = 17000 }
        }
    }
}
