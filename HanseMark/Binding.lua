local _, ns = ...
local Binding = {}
ns.Binding = Binding
local action = "CLICK HanseMarkOpenButton:LeftButton"
function Binding:Refresh()
    if InCombatLockdown() then self.pending = true; return end
    if not ns.Core.button then self.pending = true; return end
    if not self.owner then self.owner = CreateFrame("Frame", "HanseMarkBindingOwner", UIParent) end
    ClearOverrideBindings(self.owner)
    self.keys = {}
    -- Some clients expose the header as a bindable entry. Respect that existing
    -- explicit assignment without rewriting any saved user keybindings.
    for _, command in ipairs({ action, "HEADER_HANSEMARK" }) do
        local keys = { GetBindingKey(command) }
        for _, key in ipairs(keys) do
            if key and not self.keys[key] then
                SetOverrideBindingClick(self.owner, true, key, "HanseMarkOpenButton", "LeftButton")
                self.keys[key] = true
            end
        end
    end
    self.pending = false
end
function Binding:Initialize()
    if self.events then return end
    self.events = CreateFrame("Frame")
    for _, event in ipairs({"UPDATE_BINDINGS", "PLAYER_LOGIN", "PLAYER_REGEN_ENABLED"}) do self.events:RegisterEvent(event) end
    self.events:SetScript("OnEvent", function() self:Refresh() end)
    self:Refresh()
end
function ns.Diagnose()
    local de = ns.L.CANCEL == "Abbrechen"
    local version = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("HanseMark", "Version") or "1.0.0"
    ns.Print((de and "Version: " or "Version: ") .. tostring(version))
    ns.Print((de and "Steuerung bereit: " or "Controller ready: ") .. tostring(ns.Core.button ~= nil))
    if ns.Core.button then
        ns.Print((de and "Knopf sichtbar: " or "Button visible: ") .. tostring(ns.Core.button:IsVisible()))
        ns.Print((de and "Bildschirmrahmen: " or "Screen frame: ") .. tostring(ns.Core.screen:GetWidth()) .. " × " .. tostring(ns.Core.screen:GetHeight()))
    end
    for _, command in ipairs({action, "HEADER_HANSEMARK"}) do
        local keys = { GetBindingKey(command) }
        ns.Print(command .. ": " .. (#keys > 0 and table.concat(keys, ", ") or (de and "unbelegt" or "unbound")))
        for _, key in ipairs(keys) do
            ns.Print(key .. " → " .. tostring(GetBindingAction(key, true)))
        end
    end
    ns.Print((de and "Letzte Eingabe: " or "Last input: ") .. tostring(ns.Core.lastInput or (de and "keine" or "none")))
    ns.Print((de and "Aktive Marker: " or "Enabled markers: ") .. tostring(ns.Core.count or 0))
    ns.Print((de and "Darstellung: " or "Appearance: ") .. tostring(ns.DB.skin))
    local failures = 0
    for path, state in pairs(ns.TextureDiagnostics or {}) do
        if state == "failed" then
            failures = failures + 1
            ns.Print((de and "Grafik nicht geladen: " or "Texture not loaded: ") .. path)
        end
    end
    ns.Print((de and "Erkannte Grafik-Ladefehler: " or "Detected texture load failures: ") .. failures)
    ns.Print((de and "Ring offen: " or "Ring open: ") .. tostring(ns.Core:IsOpen()))
    ns.Print((de and "Letzter gewählter Bodenmarker: " or "Last selected world marker: ") .. tostring(ns.Core.lastMarker or "—"))
    ns.Print((de and "In Gruppe: " or "In group: ") .. tostring(IsInGroup()))
    ns.Print((de and "Boden-Zielkreis aktiv: " or "Ground targeting active: ") .. tostring(SpellIsTargeting()))
end
