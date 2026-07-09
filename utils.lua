DXUtils = {}

local screenW, screenH = guiGetScreenSize()
local scaleX, scaleY = screenW / AuthConfig.design.width, screenH / AuthConfig.design.height
local scale = math.min(scaleX, scaleY)

function DXUtils.screen()
    return screenW, screenH, scale
end

function DXUtils.s(value)
    return math.floor(value * scale + 0.5)
end

function DXUtils.color(rgb, alpha)
    return tocolor(rgb[1], rgb[2], rgb[3], alpha or 255)
end

function DXUtils.lerp(from, to, progress)
    return from + (to - from) * math.max(0, math.min(1, progress))
end

function DXUtils.inBox(x, y, width, height)
    local cursorX, cursorY = getCursorPosition()
    if not cursorX then return false end

    cursorX, cursorY = cursorX * screenW, cursorY * screenH
    return cursorX >= x and cursorX <= x + width and cursorY >= y and cursorY <= y + height
end

function DXUtils.roundedRect(x, y, width, height, radius, color)
    radius = math.min(radius, width / 2, height / 2)
    dxDrawRectangle(x + radius, y, width - radius * 2, height, color)
    dxDrawRectangle(x, y + radius, radius, height - radius * 2, color)
    dxDrawRectangle(x + width - radius, y + radius, radius, height - radius * 2, color)
    dxDrawCircle(x + radius, y + radius, radius, 180, 270, color, color, 16)
    dxDrawCircle(x + width - radius, y + radius, radius, 270, 360, color, color, 16)
    dxDrawCircle(x + radius, y + height - radius, radius, 90, 180, color, color, 16)
    dxDrawCircle(x + width - radius, y + height - radius, radius, 0, 90, color, color, 16)
end

function DXUtils.shadow(x, y, width, height, radius, alpha)
    for i = 5, 1, -1 do
        DXUtils.roundedRect(x - i * 2, y - i * 2, width + i * 4, height + i * 4, radius + i * 2, tocolor(0, 0, 0, (alpha or 70) / i))
    end
end
