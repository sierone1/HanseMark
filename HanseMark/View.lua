local addonName, ns = ...
local View = {}
ns.View = View
local media = "Interface\\AddOns\\" .. addonName .. "\\Media\\"
function ns.MarkerIconPath(index, pixels)
    local resolution=64
    if pixels and pixels>48 then resolution=128 end
    if pixels and pixels>96 then resolution=256 end
    if pixels and pixels>192 then resolution=512 end
    return media .. "Icons\\" .. resolution .. "\\Marker" .. index .. ".tga"
end
-- Record explicit loader failures without treating an undocumented nil return
-- as proof of a missing file. Actual-client diagnostics remain distinguishable.
ns.TextureDiagnostics=ns.TextureDiagnostics or {}
function ns.ApplyTexture(texture,path)
    local result=texture:SetTexture(path)
    ns.TextureDiagnostics[path]=result==false and "failed" or result==true and "loaded" or "unknown"
    return result~=false
end
function ns.StyleTexturePath(style,count,selection)
    local prefix=style.assetPrefix or style.id
    return media..prefix..count..(selection and "Selected"..selection or "Base")..".tga"
end
function ns.TextureProblemText()
    return ns.L.CANCEL=="Abbrechen" and "Grafik konnte nicht geladen werden. Dateien prüfen und WoW vollständig neu starten."
        or "A texture could not be loaded. Check the files and fully restart WoW."
end
local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end

function View:Initialize()
    if self.frame then return end
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(false)
    self.frame = frame
    self.previewEscape = CreateFrame("Frame", "HanseMarkPreviewEscape", UIParent)
    self.previewEscape:SetSize(1, 1)
    self.previewEscape:SetPoint("CENTER")
    self.previewEscape:Hide()
    self.previewEscape:SetScript("OnHide", function()
        if self.preview then self:Close() end
    end)
    table.insert(UISpecialFrames, "HanseMarkPreviewEscape")
    local base = frame:CreateTexture(nil, "BACKGROUND")
    base:SetAllPoints(); ns.ApplyTexture(base,ns.StyleTexturePath(ns.GetStyle(),8))
    self.base = base
    self.highlight = frame:CreateTexture(nil, "ARTWORK")
    self.highlight:SetAllPoints()
    self.outerFrame=frame:CreateTexture(nil,"ARTWORK",nil,1)
    self.outerFrame:SetAllPoints()
    self.icons = {}
    for i = 1, 8 do
        local icon = frame:CreateTexture(nil, "OVERLAY")
        icon:SetTexture(ns.MarkerIconPath(i))
        self.icons[i] = icon
    end
    self.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.label:SetPoint("CENTER", 0, 4)
    self.label:SetTextColor(.90, .96, 1)
    self.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.hint:SetPoint("CENTER", 0, -15)
    self.hint:SetTextColor(.61, .70, .77)
    self.caption = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.caption:SetPoint("TOP", frame, "BOTTOM", 0, -12)
    self.caption:SetWidth(360)
    self.caption:SetTextColor(.40, .88, .87)
    frame:SetScript("OnUpdate", function(_, elapsed)
        if self.preview then
            self.previewTime = self.previewTime + elapsed
            if (not self.modalActive and self.previewTime > 10) or InCombatLockdown() then self:Close(); return end
            -- Preview follows only mouse position; it owns no secure input or action.
            local scale=UIParent:GetEffectiveScale()
            local x,y=GetCursorPosition()
            local dx,dy=x/scale-self.x,y/scale-self.y
            local size=self.frame:GetWidth()
            local deadzone=(ns.Core and ns.Core.deadzone) or size*(ns.DB.deadzoneFraction or .16)
            local distance=dx*dx+dy*dy
            local index
            if self.count>0 and distance>deadzone*deadzone and distance<=(size*.5)^2 then
                local step=360/self.count
                index=math.floor(((90-math.deg(atan2(dy,dx)))%360+step/2)/step)%self.count+1
            end
            self:SetSelection(index)
            if not index then self.label:SetText(ns.DB.labels and ns.L.SELECT or "") end
        else
            local scale = UIParent:GetEffectiveScale()
            local x, y = GetCursorPosition()
            local dx, dy = x / scale - self.x, y / scale - self.y
            local index
            local deadzone = (ns.Core and ns.Core.deadzone) or ns.DB.deadzone or (ns.DB.size or 240) * .16
            local mx,my=x/scale-(self.startX or self.x),y/scale-(self.startY or self.y)
            local moved=ns.DB.mode~="hold" or mx*mx+my*my>16
            if dx * dx + dy * dy > deadzone * deadzone and moved then
                if self.count > 0 then
                    local step = 360 / self.count
                    index = math.floor(((90 - math.deg(atan2(dy, dx))) % 360 + step / 2) / step) % self.count + 1
                end
            end
            self:SetSelection(index)
        end
    end)
    frame:Hide()
end

function View:SetSelection(index)
    if self.selected == index then return end
    self.selected = index
    if index then
        if not ns.ApplyTexture(self.highlight,ns.StyleTexturePath(self.style,self.count,index)) then
            self.textureProblem=true
            if self.preview then self.caption:SetText(ns.TextureProblemText()) end
        end
        self.highlight:Show()
        self.label:SetText(ns.DB.labels and ns.L[ns.MarkerNames[self.activeIndices[index]]] or "")
        self.hint:SetText("")
    else
        self.highlight:Hide()
        self.label:SetText(ns.L.CANCEL)
        self.hint:SetText("")
    end
end

function View:Open(x, y, startX, startY)
    self:Initialize()
    self:HidePreviewModal(false)
    self.preview = false
    self.previewEscape:Hide()
    self.activeIndices = (ns.Core and ns.Core.activeIndices) or {}
    self.count = #self.activeIndices
    if self.count == 0 then
        if ns.Print then ns.Print(ns.L.NO_MARKERS) end
        return
    end
    local style=ns.GetStyle()
    self.skin=style.id
    self.style=style
    self.textureProblem=false
    if style.frame then
        if not ns.ApplyTexture(self.outerFrame,media.."Frames\\"..style.id..".tga") then self.textureProblem=true end
        self.outerFrame:Show()
    else self.outerFrame:Hide() end
    if not ns.ApplyTexture(self.base,ns.StyleTexturePath(style,self.count)) then self.textureProblem=true end
    self.x, self.y = x, y
    self.startX,self.startY=startX or x,startY or y
    local size = (ns.Core and ns.Core.effectiveSize) or ns.DB.size or 240
    self.frame:SetSize(size, size)
    self.frame:SetFrameStrata("DIALOG")
    self.outerFrame:ClearAllPoints()
    self.outerFrame:SetPoint("CENTER", self.frame, "CENTER", 0, 0)
    local frameScale=style.frame and 1.4 or 1
    self.outerFrame:SetSize(size*frameScale,size*frameScale)
    self.caption:ClearAllPoints()
    self.caption:SetPoint("TOP",self.frame,"BOTTOM",0,-12-size*(frameScale-1)/2)
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    self.frame:SetAlpha(ns.DB.alpha or .95)
    self.label:SetWidth(size * .36)
    local fontPath, _, fontFlags = GameFontNormal:GetFont()
    self.label:SetFont(fontPath, math.max(10, math.min(14, size * .055)), fontFlags)
    for _, icon in ipairs(self.icons) do icon:Hide() end
    for slot, iconID in ipairs(self.activeIndices) do
        local icon = self.icons[iconID]
        icon:Show()
        local angle = math.rad(90 - (slot - 1) * 360 / self.count)
        icon:ClearAllPoints()
        icon:SetPoint("CENTER", self.frame, "CENTER", math.cos(angle) * size * .36, math.sin(angle) * size * .36)
        local iconSize=size * .135 * (ns.DB.iconScale or 1)
        if not ns.ApplyTexture(icon,ns.MarkerIconPath(iconID,iconSize*UIParent:GetEffectiveScale())) then
            self.textureProblem=true
            icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..iconID)
        end
        icon:SetSize(iconSize,iconSize)
    end
    self.selected = false
    self:SetSelection(nil)
    self.caption:SetText(not IsInGroup() and ns.L.GROUP_HELP or "")
    self.frame:Show()
end

function View:Close()
    self.preview = false
    if self.frame then self.frame:Hide() end
    if self.previewEscape then self.previewEscape:Hide() end
    self:HidePreviewModal(true)
end

function View:RestoreSettingsTarget(target)
    if not target or InCombatLockdown() then return end
    if target.tab and ns.settingsCanvas then ns.settingsCanvas:SelectTab(target.tab) end
    if target.categoryID and Settings and type(Settings.OpenToCategory)=="function" then
        Settings.OpenToCategory(target.categoryID)
        if target.tab and ns.settingsCanvas then ns.settingsCanvas:SelectTab(target.tab) end
    elseif target.fallback and ns.fallbackOptions then
        ns.fallbackOptions:Refresh()
        if target.tab then ns.fallbackOptions:SelectTab(target.tab) end
        ns.fallbackOptions:Show()
    elseif target.native and SettingsPanel then
        if ShowUIPanel then ShowUIPanel(SettingsPanel) else SettingsPanel:Show() end
    end
end

function View:HidePreviewModal(restore)
    if self.hidingModal then return end
    self.hidingModal=true
    self.modalActive=false
    if self.previewWindow then self.previewWindow:Hide() end
    local restoreSettings=self.restoreSettings
    local target=self.restoreTarget
    self.restoreSettings=nil
    self.restoreTarget=nil
    self.hidingModal=false
    if restore and restoreSettings then self:RestoreSettingsTarget(target) end
end

function View:Preview()
    if InCombatLockdown() then return end
    self:Open(UIParent:GetWidth() / 2, UIParent:GetHeight() / 2)
    if not self.count or self.count == 0 then return end
    self.preview, self.previewTime = true, 0
    self.frame:SetFrameStrata("TOOLTIP")
    self.previewEscape:Show()
    self.caption:SetText(self.textureProblem and ns.TextureProblemText() or ns.L.PREVIEW_LABEL)
end

-- A dedicated visual-only window keeps the large preview off settings controls.
function View:PreviewModal()
    if InCombatLockdown() then return end
    self:Close()
    local restore=SettingsPanel and SettingsPanel:IsShown()
    local fallback=ns.fallbackOptions and ns.fallbackOptions:IsShown()
    local canvas=restore and ns.settingsCanvas or fallback and ns.fallbackOptions
    local target={native=restore,fallback=fallback,tab=canvas and canvas.activeTab}
    if restore and ns.settingsCategory and ns.settingsCategory.GetID then target.categoryID=ns.settingsCategory:GetID() end
    if restore then
        if HideUIPanel then HideUIPanel(SettingsPanel) else SettingsPanel:Hide() end
    end
    if fallback then ns.fallbackOptions:Hide() end
    self:Preview()
    if not self.count or self.count==0 then
        if restore or fallback then self:RestoreSettingsTarget(target) end
        return
    end
    if not self.previewWindow then
        local window=CreateFrame("Frame","HanseMarkLargePreview",UIParent,"BackdropTemplate")
        window:SetPoint("CENTER")
        window:SetFrameStrata("FULLSCREEN_DIALOG")
        window:EnableMouse(true)
        window:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
        window:SetBackdropColor(.025,.04,.06,.99)
        window:SetBackdropBorderColor(.25,.65,.68,1)
        window.title=window:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
        window.title:SetPoint("TOP",0,-20)
        window.close=CreateFrame("Button",nil,window,"UIPanelButtonTemplate")
        window.close:SetPoint("BOTTOMRIGHT",-20,18);window.close:SetSize(160,28)
        window.close:SetScript("OnClick",function() self:Close() end)
        window:SetScript("OnHide",function() if not self.hidingModal then self:Close() end end)
        table.insert(UISpecialFrames,"HanseMarkLargePreview")
        self.previewWindow=window
    end
    local outer=self.frame:GetWidth()*(ns.GetStyle().frame and 1.4 or 1)
    self.previewWindow:SetSize(math.min(UIParent:GetWidth()-30,math.max(480,outer+90)),math.min(UIParent:GetHeight()-30,math.max(470,outer+160)))
    self.previewWindow.title:SetText(ns.L.TITLE.." — "..ns.L.PREVIEW)
    self.previewWindow.close:SetText(ns.L.CLOSE)
    self.restoreSettings=restore or fallback
    self.restoreTarget=target
    self.modalActive=true
    self.previewWindow:Show()
end
