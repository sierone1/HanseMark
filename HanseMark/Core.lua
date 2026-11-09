-- Hanse Mark: manual world-marker actions through WoW's secure input path.
-- All action attributes are prepared outside combat. The restricted snippets alone
-- select an action; ordinary Lua only renders the matching visual state.
local _, HM = ...
local Core = {}
HM.Core = Core

local MARKER_IDS = { 5, 6, 3, 2, 7, 1, 4, 8 }
local MODIFIERS = { "", "SHIFT-", "CTRL-", "ALT-", "CTRL-SHIFT-", "ALT-SHIFT-", "ALT-CTRL-", "ALT-CTRL-SHIFT-" }

local OPEN_CLICK = [[
    control:CallMethod("InputSeen", button, down)
    local helper = control:GetFrameRef("helper")
    local screen = control:GetFrameRef("screen")
    local lifecycle = control:GetFrameRef("lifecycle")
    local picking = button == "Select"
    if picking and down then return false end
    if down and not picking and not screen:IsVisible() then return false end

    -- Key repeat is still one physical press. Keep the latch after cancellation
    -- until the original opening key is actually released.
    if not picking then
        if down then
            if KEY_HELD then return false end
            KEY_HELD = true
        else
            KEY_HELD = false
        end
    end

    if not picking and down then
        if OPEN then
            OPEN = false
            helper:ClearBindings()
            lifecycle:Hide()
            control:CallMethod("CloseView")
            return false
        end
        local count = self:GetAttribute("count") or 0
        if count == 0 then
            control:CallMethod("NoMarkers")
            return false
        end
        local x, y = screen:GetMousePosition()
        if not x or not y then return false end
        ORIGIN_X, ORIGIN_Y = x * screen:GetWidth(), y * screen:GetHeight()
        START_X, START_Y = ORIGIN_X, ORIGIN_Y
        if self:GetAttribute("clamp") then
            local margin=self:GetAttribute("margin") or 124
            local width,height=screen:GetWidth(),screen:GetHeight()
            ORIGIN_X=math.max(math.min(margin,width/2),math.min(width-margin,ORIGIN_X))
            ORIGIN_Y=math.max(math.min(margin,height/2),math.min(height-margin,ORIGIN_Y))
        end
        OPEN = true
        lifecycle:Show()
        local helperName = helper:GetName()
        for i = 1, 8 do
            local prefix = self:GetAttribute("modifier" .. i) or ""
            helper:SetBindingClick(true, prefix .. "ESCAPE", helperName, "Cancel")
            helper:SetBindingClick(true, prefix .. "BUTTON2", helperName, "Cancel")
        end
        for i = 1, 8 do
            local markerButton = control:GetFrameRef("marker" .. i)
            if i <= count and self:GetAttribute("mode") == "click" then
                local angle = math.rad(90 - (i - 1) * 360 / count)
                local radius = self:GetAttribute("radius")
                markerButton:ClearAllPoints()
                markerButton:SetPoint("CENTER", screen, "BOTTOMLEFT", ORIGIN_X + math.cos(angle) * radius, ORIGIN_Y + math.sin(angle) * radius)
                markerButton:Show()
            else
                markerButton:Hide()
            end
        end
        control:CallMethod("OpenView", ORIGIN_X, ORIGIN_Y, START_X, START_Y)
        return false
    end

    if not OPEN then return false end
    if not picking and self:GetAttribute("mode") == "click" then return false end
    if down then return false end

    local x, y = screen:GetMousePosition()
    local pick
    if x and y then
        local dx = x * screen:GetWidth() - ORIGIN_X
        local dy = y * screen:GetHeight() - ORIGIN_Y
        local deadzone = self:GetAttribute("deadzone") or 38
        local moveX,moveY=x*screen:GetWidth()-START_X,y*screen:GetHeight()-START_Y
        if dx * dx + dy * dy > deadzone * deadzone and (picking or moveX*moveX+moveY*moveY > 16) then
            local angle = (90 - math.deg(math.atan2(dy, dx))) % 360
            local count = self:GetAttribute("count") or 0
            if count > 0 then pick = math.floor((angle + 180 / count) / (360 / count)) % count + 1 end
        end
    end
    OPEN = false
    helper:ClearBindings()
    lifecycle:Hide()
    control:CallMethod("CloseView")
    if pick then return "s" .. pick end
    return false
]]

local CANCEL_CLICK = [[
    OPEN = false
    self:ClearBindings()
    control:GetFrameRef("lifecycle"):Hide()
    control:CallMethod("CloseView")
    return false
]]

-- Physical mouse clicks go to real secure buttons, rather than relying on a
-- BUTTON1 override (the client can reserve its normal selection input).
local MARKER_CLICK = [[
    if button ~= "LeftButton" then return false end
    if down then return false end
    if not OPEN then return false end
    OPEN = false
    control:CallMethod("SelectionSeen", self:GetAttribute("marker"))
    control:GetFrameRef("helper"):ClearBindings()
    control:GetFrameRef("lifecycle"):Hide()
    control:CallMethod("CloseView")
]]

-- UIParent can disappear (for example Alt-Z). A protected, invisible sentinel
-- follows its visibility so an invisible ring can never retain mouse bindings.
local LIFECYCLE_HIDE = [[
    OPEN = false
    control:GetFrameRef("helper"):ClearBindings()
    control:CallMethod("CloseView")
]]

local function database()
    return HM.DB or HM.db or {}
end

function Core:ApplySettings()
    if not self.button then return false, "uninitialized" end
    if InCombatLockdown() then
        self.pending = true
        return false, "combat"
    end
    self:Dismiss()
    local db = database()
    local size = tonumber(db.size) or 240
    if size ~= size then size = 240 end
    size = math.max(160, math.min(400, size))
    local style = HM.GetStyle and HM.GetStyle()
    local frameScale = style and style.frame and 1.4 or 1
    local available = math.max(32, math.min(UIParent:GetWidth(), UIParent:GetHeight()) - 8)
    size = math.min(size, available / frameScale)
    self.effectiveSize, self.frameScale = size, frameScale
    local deadzone = size * (tonumber(db.deadzoneFraction) or .16)
    if deadzone ~= deadzone then deadzone = size * 0.16 end
    deadzone = math.max(16, math.min(size * 0.3, deadzone))
    self.button:SetAttribute("mode", db.mode == "hold" and "hold" or "click")
    self.button:SetAttribute("deadzone", deadzone)
    self.button:SetAttribute("radius", size * .36)
    self.button:SetAttribute("clamp", db.clamp ~= false)
    self.button:SetAttribute("margin", size * frameScale * .5 + 4)
    local active = {}
    for icon = 1, 8 do
        if not db.enabled or db.enabled[icon] ~= false then active[#active + 1] = icon end
    end
    self.activeIndices, self.count = active, #active
    self.button:SetAttribute("count", #active)
    for slot = 1, 8 do
        local id = active[slot] and MARKER_IDS[active[slot]]
        self.button:SetAttribute("*type-s" .. slot, id and "worldmarker" or nil)
        self.button:SetAttribute("*action-s" .. slot, id and "set" or nil)
        self.button:SetAttribute("*marker-s" .. slot, id)
        local markerButton = self.markerButtons[slot]
        markerButton:SetAttribute("type", id and "worldmarker" or nil)
        markerButton:SetAttribute("marker", id)
        markerButton:Hide()
    end
    local iconScale=math.max(.8,math.min(1.3,tonumber(db.iconScale) or 1))
    local maxHit=#active>1 and size*.72*math.sin(math.pi/#active)*.85 or size*.3
    local hitSize=math.min(size*.22*iconScale,maxHit)
    for _,markerButton in ipairs(self.markerButtons) do markerButton:SetSize(hitSize,hitSize) end
    self.hitSize=hitSize
    self.deadzone = deadzone
    self.pending = nil
    return true
end

function Core:IsOpen()
    return self.open == true
end

-- Configuration and preview code may dismiss only outside combat. In combat,
-- Escape/right-click run CANCEL_CLICK through an actual hardware event.
function Core:Dismiss()
    if not self.controller then return true end
    if InCombatLockdown() then return false, "combat" end
    self.controller:Execute("OPEN = false; KEY_HELD = false")
    ClearOverrideBindings(self.helper)
    self.lifecycle:Hide()
    self.controller:CloseView()
    return true
end

function Core:Initialize()
    if self.button then return true end
    if InCombatLockdown() then
        self.pendingInitialize = true
        if not self.retry then
            self.retry = CreateFrame("Frame")
            self.retry:RegisterEvent("PLAYER_REGEN_ENABLED")
            self.retry:SetScript("OnEvent", function() Core:Initialize() end)
        end
        return false, "combat"
    end

    local controller = CreateFrame("Frame", "HanseMarkSecureController", UIParent, "SecureHandlerBaseTemplate")
    local screen = CreateFrame("Frame", "HanseMarkSecureScreen", UIParent, "SecureFrameTemplate")
    screen:SetAllPoints(UIParent)
    screen:EnableMouse(false)
    local lifecycle = CreateFrame("Frame", "HanseMarkSecureLifecycle", UIParent, "SecureFrameTemplate")
    lifecycle:SetSize(1, 1)
    lifecycle:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    lifecycle:EnableMouse(false)
    lifecycle:Hide()
    local button = CreateFrame("Button", "HanseMarkOpenButton", UIParent, "SecureActionButtonTemplate")
    button:SetSize(1, 1)
    button:EnableMouse(false)
    button:RegisterForClicks("AnyDown", "AnyUp")
    button:SetAttribute("useOnKeyDown", false)
    for index, id in ipairs(MARKER_IDS) do
        button:SetAttribute("*type-s" .. index, "worldmarker")
        button:SetAttribute("*action-s" .. index, "set")
        button:SetAttribute("*marker-s" .. index, id)
    end
    for index, prefix in ipairs(MODIFIERS) do button:SetAttribute("modifier" .. index, prefix) end

    local helper = CreateFrame("Button", "HanseMarkCancelButton", UIParent, "SecureActionButtonTemplate")
    helper:SetSize(1, 1)
    helper:EnableMouse(false)
    helper:RegisterForClicks("AnyDown", "AnyUp")
    helper:SetAttribute("useOnKeyDown", true)
    controller:SetFrameRef("screen", screen)
    controller:SetFrameRef("helper", helper)
    controller:SetFrameRef("lifecycle", lifecycle)
    local markerButtons = {}
    for index, id in ipairs(MARKER_IDS) do
        local markerButton = CreateFrame("Button", "HanseMarkMarker" .. index, lifecycle, "SecureActionButtonTemplate")
        markerButton:SetFrameStrata("DIALOG")
        markerButton:SetFrameLevel(100)
        markerButton:EnableMouse(true)
        markerButton:RegisterForClicks("LeftButtonUp")
        markerButton:SetAttribute("useOnKeyDown", false)
        markerButton:SetAttribute("type", "worldmarker")
        markerButton:SetAttribute("action", "set")
        markerButton:SetAttribute("marker", id)
        SecureHandlerWrapScript(markerButton, "OnClick", controller, MARKER_CLICK)
        controller:SetFrameRef("marker" .. index, markerButton)
        markerButtons[index] = markerButton
    end
    self.markerButtons = markerButtons
    controller.NoMarkers = function()
        if HM.Print then HM.Print(HM.L.NO_MARKERS) end
    end
    controller.SelectionSeen = function(_, marker) Core.lastMarker = marker end
    controller.OpenView = function(_, x, y, startX, startY)
        Core.open, Core.originX, Core.originY = true, x, y
        if HM.View and HM.View.Open then HM.View:Open(x, y, startX, startY) end
    end
    controller.InputSeen = function(_, buttonName, down)
        Core.lastInput = tostring(buttonName) .. (down and " DOWN" or " UP")
    end
    controller.CloseView = function()
        Core.open = false
        if HM.View and HM.View.Close then HM.View:Close() end
    end
    controller:Execute("OPEN = false; KEY_HELD = false; ORIGIN_X = 0; ORIGIN_Y = 0")
    SecureHandlerWrapScript(button, "OnClick", controller, OPEN_CLICK)
    SecureHandlerWrapScript(helper, "OnClick", controller, CANCEL_CLICK)
    SecureHandlerWrapScript(lifecycle, "OnHide", controller, LIFECYCLE_HIDE)
    self.controller, self.screen, self.button, self.helper = controller, screen, button, helper
    self.lifecycle = lifecycle
    self.pendingInitialize = nil
    if self.retry then self.retry:UnregisterEvent("PLAYER_REGEN_ENABLED") end

    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
    events:RegisterEvent("DISPLAY_SIZE_CHANGED")
    events:RegisterEvent("UI_SCALE_CHANGED")
    events:SetScript("OnEvent", function(_, event)
        if Core.pending or event ~= "PLAYER_REGEN_ENABLED" then Core:ApplySettings() end
    end)
    self.events = events
    return self:ApplySettings()
end

Core.markerIDs = MARKER_IDS
