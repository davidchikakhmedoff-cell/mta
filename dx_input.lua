DXInput = {}; DXInput.__index = DXInput
DXInput.active = nil

function DXInput:new(placeholder, password, maxLength)
    return setmetatable({ placeholder = placeholder, password = password, maxLength = maxLength or 32, text = "", caret = 0, focus = 0, selectAll = false }, self)
end

function DXInput:setText(text) self.text = tostring(text or ""):sub(1, self.maxLength); self.caret = #self.text end
function DXInput:getText() return self.text end
function DXInput:activate() if DXInput.active then DXInput.active.selectAll = false end; DXInput.active = self; self.caret = #self.text end
function DXInput:blur() if DXInput.active == self then DXInput.active = nil end; self.selectAll = false end

function DXInput:draw(x, y, w, h, alpha, icon)
    local active = DXInput.active == self
    self.focus = DXUtils.lerp(self.focus, active and 1 or 0, 0.14)
    local panel, primary, muted, textc = AuthConfig.colors.panel, AuthConfig.colors.primary, AuthConfig.colors.muted, AuthConfig.colors.text
    DXUtils.roundedRect(x, y, w, h, DXUtils.s(10), tocolor(panel[1], panel[2], panel[3], alpha))
    if self.focus > 0.02 then dxDrawRectangle(x + DXUtils.s(14), y + h - 2, w - DXUtils.s(28), 2, tocolor(primary[1], primary[2], primary[3], alpha * self.focus)) end
    dxDrawText(icon or "", x + DXUtils.s(16), y, x + DXUtils.s(44), y + h, tocolor(primary[1], primary[2], primary[3], alpha), 1, "default-bold", "center", "center")
    local display = self.password and string.rep("•", utf8.len(self.text) or #self.text) or self.text
    local shown = (#display > 0) and display or self.placeholder
    local col = (#display > 0) and textc or muted
    local tx = x + DXUtils.s(52)
    dxDrawText(shown, tx, y, x + w - DXUtils.s(16), y + h, tocolor(col[1], col[2], col[3], alpha), 1, "default", "left", "center", true)
    if active and (getTickCount() % 1000) < 520 then
        local cw = dxGetTextWidth(display:sub(1, self.caret), 1, "default")
        dxDrawRectangle(tx + cw + 2, y + DXUtils.s(16), 1, h - DXUtils.s(32), tocolor(255,255,255,alpha))
    end
end

function DXInput:click(x, y, ix, iy, iw, ih)
    if x >= ix and x <= ix + iw and y >= iy and y <= iy + ih then self:activate(); return true end
    if DXInput.active == self then self:blur() end
    return false
end

function DXInput:key(button, press)
    if not press or DXInput.active ~= self then return false end
    if getKeyState("lctrl") or getKeyState("rctrl") then
        if button == "a" then self.selectAll = true; return true end
        if button == "c" then setClipboard(self.text); return true end
        if button == "v" then return true end
    end
    if button == "backspace" then if self.selectAll then self:setText(""); self.selectAll=false else self.text = self.text:sub(1, math.max(0, self.caret - 1)) .. self.text:sub(self.caret + 1); self.caret = math.max(0, self.caret - 1) end; return true end
    if button == "delete" then if self.selectAll then self:setText(""); self.selectAll=false else self.text = self.text:sub(1, self.caret) .. self.text:sub(self.caret + 2) end; return true end
    if button == "arrow_l" then self.caret = math.max(0, self.caret - 1); return true end
    if button == "arrow_r" then self.caret = math.min(#self.text, self.caret + 1); return true end
    return false
end

function DXInput:char(c)
    if DXInput.active ~= self or #self.text >= self.maxLength then return false end
    if self.selectAll then self.text = ""; self.caret = 0; self.selectAll = false end
    self.text = self.text:sub(1, self.caret) .. c .. self.text:sub(self.caret + 1)
    self.caret = self.caret + #c
    return true
end
