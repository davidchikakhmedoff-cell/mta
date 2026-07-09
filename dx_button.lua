DXButton = {}
DXButton.__index = DXButton

function DXButton:new(text, onClick)
    return setmetatable({ text = text, onClick = onClick, hover = 0, press = 0, enabled = true }, self)
end

function DXButton:draw(x, y, w, h, alpha)
    local hovered = self.enabled and DXUtils.inBox(x, y, w, h)
    self.hover = DXUtils.lerp(self.hover, hovered and 1 or 0, 0.16)
    self.press = DXUtils.lerp(self.press, self.pressed and 1 or 0, 0.22)
    local c = AuthConfig.colors.primary
    local lift = self.hover * 18 - self.press * 10
    DXUtils.roundedRect(x, y + self.press * 2, w, h, DXUtils.s(12), tocolor(c[1] + lift, c[2] + lift, c[3] + lift, alpha))
    dxDrawText(self.text, x, y, x + w, y + h, tocolor(255, 255, 255, alpha), 1, "default-bold", "center", "center")
end

function DXButton:mouse(button, state, x, y, bx, by, bw, bh)
    if not self.enabled or button ~= "left" then return false end
    if state == "down" and x >= bx and x <= bx + bw and y >= by and y <= by + bh then self.pressed = true; return true end
    if state == "up" then
        local was = self.pressed
        self.pressed = false
        if was and x >= bx and x <= bx + bw and y >= by and y <= by + bh and self.onClick then self.onClick(); return true end
    end
    return false
end
