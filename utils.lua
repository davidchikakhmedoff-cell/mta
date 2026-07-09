DXUtils = {}

local sw, sh = guiGetScreenSize()
local sx, sy = sw / AuthConfig.design.width, sh / AuthConfig.design.height
local scale = math.min(sx, sy)
local whitePixel

function DXUtils.screen() return sw, sh, scale end
function DXUtils.s(v) return math.floor(v * scale + 0.5) end
function DXUtils.color(rgb, alpha) return tocolor(rgb[1], rgb[2], rgb[3], alpha or 255) end
function DXUtils.lerp(a, b, t) return a + (b - a) * math.max(0, math.min(1, t)) end
function DXUtils.ease(t) return interpolateBetween(0, 0, 0, 1, 0, 0, t, "InOutQuad") end
function DXUtils.inBox(x, y, w, h) local mx, my = getCursorPosition(); if not mx then return false end; mx, my = mx * sw, my * sh; return mx >= x and mx <= x + w and my >= y and my <= y + h end

local function pixel()
    if isElement(whitePixel) then return whitePixel end
    whitePixel = dxCreateTexture(1, 1, "argb")
    local p = dxCreatePixels(1, 1)
    dxSetPixelColor(p, 0, 0, 255, 255, 255, 255)
    dxSetTexturePixels(whitePixel, p)
    return whitePixel
end

function DXUtils.roundedRect(x, y, w, h, r, color)
    r = math.min(r, w / 2, h / 2)
    dxDrawRectangle(x + r, y, w - r * 2, h, color)
    dxDrawRectangle(x, y + r, r, h - r * 2, color)
    dxDrawRectangle(x + w - r, y + r, r, h - r * 2, color)
    dxDrawCircle(x + r, y + r, r, 180, 270, color, color, 16)
    dxDrawCircle(x + w - r, y + r, r, 270, 360, color, color, 16)
    dxDrawCircle(x + r, y + h - r, r, 90, 180, color, color, 16)
    dxDrawCircle(x + w - r, y + h - r, r, 0, 90, color, color, 16)
end

function DXUtils.shadow(x, y, w, h, r, alpha)
    for i = 5, 1, -1 do
        DXUtils.roundedRect(x - i * 2, y - i * 2, w + i * 4, h + i * 4, r + i * 2, tocolor(0, 0, 0, (alpha or 70) / i))
    end
end

addEventHandler("onClientResourceStop", resourceRoot, function() if isElement(whitePixel) then destroyElement(whitePixel) end end)
