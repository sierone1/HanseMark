local addonName, ns = ...
local action = "CLICK HanseMarkOpenButton:LeftButton"
local media = "Interface\\AddOns\\" .. addonName .. "\\Media\\"
local function notify(key) if ns.Print then ns.Print(ns.L[key]) end end
local function canChange() if InCombatLockdown() then notify("COMBAT_SETTINGS"); return false end return true end
local function label(parent,key,x,y,width,template)
    local t=parent:CreateFontString(nil,"OVERLAY",template or "GameFontHighlight")
    t:SetPoint("TOPLEFT",x,y); t:SetWidth(width or 400); t:SetJustifyH("LEFT")
    if key then t:SetText(ns.L[key]) end
    return t
end
local function button(parent,x,y,width,fn)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
    b:SetPoint("TOPLEFT",x,y); b:SetSize(width,28); b:SetScript("OnClick",fn); return b
end
local function check(parent,x,y,fn)
    local c=CreateFrame("CheckButton",nil,parent)
    c:SetPoint("TOPLEFT",x,y); c:SetSize(24,24)
    c:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    c:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    c:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    c:SetScript("OnClick",fn); return c
end
local function save(panel)
    ns.Core:ApplySettings(); panel:Refresh()
end
local function slider(panel,parent,key,y,low,high,step)
    local s=CreateFrame("Slider",nil,parent,"BackdropTemplate")
    s:SetPoint("TOPLEFT",8,y); s:SetSize(280,18)
    s:EnableMouse(true);s:SetOrientation("HORIZONTAL"); s:SetMinMaxValues(low,high); s:SetValueStep(step); s:SetObeyStepOnDrag(true)
    s:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    s:SetBackdropColor(.07,.11,.15,1); s:SetBackdropBorderColor(.3,.4,.5,1)
    s:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    s:GetThumbTexture():SetSize(12,24);s:GetThumbTexture():SetVertexColor(.38,.85,.84,1)
    s.valueLabel=label(parent,nil,302,y,70)
    s:SetScript("OnValueChanged",function(_,value)
        if panel.refreshing then return end
        if not canChange() then panel:Refresh(); return end
        ns.DB[key]=key=="size" and math.floor(value+.5) or math.floor(value*100+.5)/100
        save(panel)
    end)
    return s
end

-- This preview owns no secure frames, clicks or bindings. It renders only textures.
local function buildPreview(panel)
    local frame=CreateFrame("Frame",nil,panel)
    frame:SetSize(240,240); frame:SetPoint("CENTER",panel,"TOPRIGHT",-140,-270); frame:EnableMouse(false)
    frame.base=frame:CreateTexture(nil,"BACKGROUND"); frame.base:SetAllPoints()
    frame.highlight=frame:CreateTexture(nil,"ARTWORK"); frame.highlight:SetAllPoints()
    frame.outerFrame=frame:CreateTexture(nil,"ARTWORK",nil,1);frame.outerFrame:SetAllPoints()
    frame.icons={}
    for i=1,8 do local t=frame:CreateTexture(nil,"OVERLAY"); t:SetTexture(ns.MarkerIconPath and ns.MarkerIconPath(i) or "Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..i); frame.icons[i]=t end
    frame.name=frame:CreateFontString(nil,"OVERLAY","GameFontNormal"); frame.name:SetPoint("CENTER"); frame.name:SetWidth(90)
    frame.caption=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); frame.caption:SetPoint("TOP",frame,"BOTTOM",0,-14); frame.caption:SetWidth(180)
    function frame:Refresh()
        local active=ns.Core.activeIndices or {}; local count=#active
        local style=ns.GetStyle();local skin=style.id
        local frameScale=style.frame and 1.4 or 1
        local box=panel.previewBox or 180
        local requested=math.max(160,math.min(400,ns.DB.size))
        local size=box*(.65+.35*(requested-160)/240)/frameScale;self:SetSize(size,size)
        self.outerFrame:ClearAllPoints();self.outerFrame:SetPoint("CENTER",self,"CENTER",0,0)
        self.outerFrame:SetSize(size*frameScale,size*frameScale)
        self.caption:ClearAllPoints();self.caption:SetPoint("TOP",self,"BOTTOM",0,-14-size*(frameScale-1)/2)
        self.name:SetWidth(size*.36)
        local font,_,flags=GameFontNormal:GetFont();self.name:SetFont(font,math.max(10,math.min(13,size*.055)),flags)
        for _,t in ipairs(self.icons) do t:Hide() end
        self:SetAlpha(ns.DB.alpha)
        if count==0 then self.base:Hide(); self.highlight:Hide();self.outerFrame:Hide(); self.name:SetText(ns.L.NONE); self.caption:SetText(ns.L.NO_MARKERS); return end
        local textureProblem=not ns.ApplyTexture(self.base,ns.StyleTexturePath(style,count));self.base:Show()
        if style.frame then
            if not ns.ApplyTexture(self.outerFrame,media.."Frames\\"..style.id..".tga") then textureProblem=true end
            self.outerFrame:Show()
        else self.outerFrame:Hide() end
        if not ns.ApplyTexture(self.highlight,ns.StyleTexturePath(style,count,1)) then textureProblem=true end
        self.highlight:Show()
        for slot,iconID in ipairs(active) do
            local angle=math.rad(90-(slot-1)*360/count); local t=self.icons[iconID]
            t:ClearAllPoints(); t:SetPoint("CENTER",self,"CENTER",math.cos(angle)*size*.36,math.sin(angle)*size*.36); t:SetSize(size*.135*ns.DB.iconScale,size*.135*ns.DB.iconScale)
            local path=ns.MarkerIconPath and ns.MarkerIconPath(iconID,size*.135*ns.DB.iconScale*UIParent:GetEffectiveScale()) or "Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..iconID
            if not ns.ApplyTexture(t,path) then
                textureProblem=true;t:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..iconID)
            end
            t:Show()
        end
        self.name:SetText(ns.DB.labels and ns.L[ns.MarkerNames[active[1]]] or "")
        self.textureProblem=textureProblem
        self.caption:SetText(textureProblem and ns.TextureProblemText() or ns.L.EMBEDDED_PREVIEW)
    end
    return frame
end

local function assignedKeys()
    local keys,seen={},{}
    for _,command in ipairs({action,"HEADER_HANSEMARK"}) do
        for _,key in ipairs({GetBindingKey(command)}) do
            if not seen[key] then keys[#keys+1]=key;seen[key]=true end
        end
    end
    return keys
end
local function currentKey()
    local keys=assignedKeys();return #keys>0 and table.concat(keys,", ") or ns.L.UNBOUND
end
function ns.CancelKeyCapture()
    local f=ns.keyCapture
    if f then f:EnableKeyboard(false); f:EnableMouse(false); f:Hide() end
end
function ns.AssignKey(key,expectedConflict,panel)
    if not canChange() then return false end
    local conflict=GetBindingAction(key) or ""
    if conflict~=expectedConflict and conflict~=action then notify("BINDING_CHANGED"); return false end
    local old=assignedKeys()
    if not SetBinding(key,action) then notify("BINDING_FAILED"); return false end
    for _,prior in ipairs(old) do if prior~=key then SetBinding(prior) end end
    SaveBindings(GetCurrentBindingSet())
    ns.Binding:Refresh(); panel:Refresh(); return true
end
function ns.StartKeyCapture(panel)
    if not canChange() then return end
    if not ns.keyCapture then
        local f=CreateFrame("Frame","HanseMarkKeyCapture",UIParent,"BackdropTemplate")
        f:SetSize(450,150); f:SetPoint("CENTER"); f:SetFrameStrata("TOOLTIP")
        f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
        f:SetBackdropColor(.025,.045,.07,1); f:SetBackdropBorderColor(.4,.85,.85,1)
        f.text=label(f,nil,20,-25,410)
        local cancel=button(f,140,-105,170,function() ns.CancelKeyCapture() end)
        f.cancel=cancel
        local function capture(key)
            if not canChange() then ns.CancelKeyCapture(); return end
            if key=="ESCAPE" or key=="BUTTON2" then ns.CancelKeyCapture(); return end
            if key=="LSHIFT" or key=="RSHIFT" or key=="LCTRL" or key=="RCTRL" or key=="LALT" or key=="RALT" then return end
            if key=="BUTTON1" or key=="BUTTON2" or key=="UNKNOWN" then return end
            local prefix=(IsAltKeyDown() and "ALT-" or "")..(IsControlKeyDown() and "CTRL-" or "")..(IsShiftKeyDown() and "SHIFT-" or "")
            key=prefix..key
            ns.CancelKeyCapture()
            local conflict=GetBindingAction(key) or ""
            if conflict~="" and conflict~=action then
                StaticPopupDialogs.HANSEMARK_BIND_CONFLICT={text=ns.L.BIND_CONFLICT,button1=ns.L.REPLACE,button2=ns.L.CANCEL,timeout=0,whileDead=true,hideOnEscape=true,
                    OnAccept=function(_,data) ns.AssignKey(data.key,data.conflict,data.panel) end}
                StaticPopup_Show("HANSEMARK_BIND_CONFLICT",key,GetBindingText(conflict,"BINDING_NAME_"),{key=key,conflict=conflict,panel=panel})
            else ns.AssignKey(key,conflict,panel) end
        end
        f:SetScript("OnKeyDown",function(_,key) capture(key) end)
        f:SetScript("OnMouseDown",function(_,key)
            local numbered=key:match("^Button(%d+)$")
            if key=="RightButton" then ns.CancelKeyCapture()
            elseif key=="MiddleButton" then capture("BUTTON3")
            elseif numbered then capture("BUTTON"..numbered) end
        end)
        f:SetScript("OnHide",function(self) self:EnableKeyboard(false); self:EnableMouse(false) end)
        f:RegisterEvent("PLAYER_REGEN_DISABLED"); f:SetScript("OnEvent",function() ns.CancelKeyCapture() end)
        ns.keyCapture=f
    end
    local f=ns.keyCapture; f.text:SetText(ns.L.CAPTURE_HELP); f.cancel:SetText(ns.L.CANCEL)
    f:EnableKeyboard(true); f:EnableMouse(true); f:SetPropagateKeyboardInput(false); f:Show()
end

function ns.CreateOptionsCanvas(parent,native)
    local panel=CreateFrame("Frame",native and "HanseMarkSettingsCanvas" or "HanseMarkOptionsFrame",parent,"BackdropTemplate")
    panel:SetSize(native and 650 or 800,530)
    panel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    panel:SetBackdropColor(.035,.052,.073,.97);panel:SetBackdropBorderColor(.18,.3,.35,.8)
    panel.separators={}
    for i=1,3 do
        local t=panel:CreateTexture(nil,"BACKGROUND");t:SetColorTexture(.21,.39,.43,.6);panel.separators[i]=t
    end
    if not native then
        panel:SetPoint("CENTER"); panel:SetFrameStrata("DIALOG"); panel:SetClampedToScreen(true); panel:EnableMouse(true)
        panel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
        panel:SetBackdropColor(.04,.06,.085,.99); panel:SetBackdropBorderColor(.25,.5,.55,1)
        table.insert(UISpecialFrames,"HanseMarkOptionsFrame")
    end
    panel.title=label(panel,"TITLE",16,-14,700,"GameFontNormalLarge")
    panel.subtitle=label(panel,"SUBTITLE",16,-44,700)
    panel.brand=panel:CreateTexture(nil,"ARTWORK");panel.brand:SetSize(48,48);panel.brand:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-18,-12);panel.brand:SetTexture(media.."Icon.tga")
    panel.tabs={}; panel.pages={}
    for i,key in ipairs({"INTERACTION_TAB","MARKERS_TAB","APPEARANCE_TAB","INFO_TAB"}) do
        panel.tabs[key]=button(panel,16+(i-1)*145,-76,138,function() panel:SelectTab(key) end)
        local scroll=CreateFrame("ScrollFrame",nil,panel)
        scroll:SetPoint("TOPLEFT",16,-120); scroll:SetPoint("BOTTOMRIGHT",panel,"BOTTOMRIGHT",-295,58)
        local content=CreateFrame("Frame",nil,scroll); content:SetSize(440,420); scroll:SetScrollChild(content)
        local bar=CreateFrame("Slider",nil,panel,"BackdropTemplate")
        bar:EnableMouse(true);bar:SetOrientation("VERTICAL");bar:SetWidth(8);bar:SetValueStep(16)
        bar:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"});bar:SetBackdropColor(.1,.15,.19,.5)
        bar:SetThumbTexture("Interface\\Buttons\\WHITE8X8");bar:GetThumbTexture():SetSize(8,38);bar:GetThumbTexture():SetVertexColor(.32,.65,.68,.9)
        local page={scroll=scroll,content=content,bar=bar,offset=0,range=0}
        bar:SetScript("OnValueChanged",function(_,value) page.offset=value;scroll:SetVerticalScroll(value) end)
        scroll:EnableMouseWheel(true)
        scroll:SetScript("OnMouseWheel",function(_,delta) bar:SetValue(math.max(0,math.min(page.range,page.offset-delta*36))) end)
        panel.pages[key]=page;scroll:Hide();bar:Hide()
    end
    local interaction=panel.pages.INTERACTION_TAB.content
    panel.keyLabel=label(interaction,nil,8,-8,390,"GameFontNormal")
    panel.bind=button(interaction,8,-35,185,function() ns.StartKeyCapture(panel) end)
    panel.unbind=button(interaction,205,-35,185,function()
        if not canChange() then return end
        for _,key in ipairs(assignedKeys()) do SetBinding(key) end
        SaveBindings(GetCurrentBindingSet()); ns.Binding:Refresh(); panel:Refresh()
    end)
    panel.keyHelp=label(interaction,"KEY_HELP",8,-78,395)
    panel.modeLabel=label(interaction,"MODE",8,-152,395,"GameFontNormal")
    panel.click=check(interaction,8,-181,function() if canChange() then ns.DB.mode="click";save(panel) else panel:Refresh() end end)
    panel.clickText=label(interaction,"CLICK",40,-185,355)
    panel.hold=check(interaction,8,-230,function() if canChange() then ns.DB.mode="hold";save(panel) else panel:Refresh() end end)
    panel.holdText=label(interaction,"HOLD",40,-234,355)
    panel.placeHelp=label(interaction,"PLACE_HELP",8,-346,390)
    local markers=panel.pages.MARKERS_TAB.content
    panel.markerTitle=label(markers,"MARKERS",8,-8,400,"GameFontNormal")
    panel.markerChecks={};panel.markerTexts={};panel.markerIcons={}
    for i=1,8 do
        local iconID=i; local x=8+((i-1)%2)*205;local y=-38-math.floor((i-1)/2)*45
        panel.markerChecks[i]=check(markers,x,y,function(self)
            if canChange() then ns.DB.enabled[iconID]=self:GetChecked() and true or false;save(panel) else panel:Refresh() end
        end)
        local icon=markers:CreateTexture(nil,"ARTWORK");icon:SetTexture(ns.MarkerIconPath and ns.MarkerIconPath(i) or "Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..i);icon:SetSize(24,24);icon:SetPoint("TOPLEFT",x+28,y)
        panel.markerIcons[i]=icon
        panel.markerTexts[i]=label(markers,nil,x+58,y-4,140)
    end
    panel.presets={}
    for i,entry in ipairs({{8,"ALL"},{0,"NONE"},{3,"THREE"},{5,"FIVE"}}) do
        local count,key=entry[1],entry[2]
        panel.presets[i]=button(markers,8+((i-1)%2)*205,-230-math.floor((i-1)/2)*36,195,function()
            if not canChange() then return end
            for icon=1,8 do ns.DB.enabled[icon]=icon<=count end;save(panel)
        end);panel.presets[i].localeKey=key
    end
    panel.subsetHelp=label(markers,"SUBSET_HELP",8,-322,395)
    local appearance=panel.pages.APPEARANCE_TAB.content
    panel.skinTitle=label(appearance,"SKIN",8,-8,395,"GameFontNormal");panel.skins={}
    panel.skinDropdown=CreateFrame("DropdownButton",nil,appearance,"WowStyle1DropdownTemplate")
    panel.skinDropdown:SetPoint("TOPLEFT",8,-38);panel.skinDropdown:SetWidth(395)
    panel.skinDropdown:SetupMenu(function(_,root)
        for _,style in ipairs(ns.Styles) do
            root:CreateRadio(ns.StyleName(style),function() return ns.DB.skin==style.id end,function()
                if canChange() then ns.DB.skin=style.id;save(panel) end
            end)
        end
    end)
    panel.sizeText=label(appearance,"SIZE",8,-92,395,"GameFontNormal");panel.size=slider(panel,appearance,"size",-121,160,400,10)
    panel.alphaText=label(appearance,"OPACITY",8,-160,395,"GameFontNormal");panel.alpha=slider(panel,appearance,"alpha",-189,.35,1,.05)
    panel.iconScaleText=label(appearance,"ICON_SCALE",8,-228,395,"GameFontNormal")
    panel.iconScale=slider(panel,appearance,"iconScale",-257,.8,1.3,.05)
    panel.deadzoneText=label(appearance,"DEADZONE",8,-296,395,"GameFontNormal")
    panel.deadzoneFraction=slider(panel,appearance,"deadzoneFraction",-325,.12,.24,.01)
    panel.clamp=check(appearance,8,-386,function(self)
        if canChange() then ns.DB.clamp=self:GetChecked() and true or false;save(panel) else panel:Refresh() end
    end)
    panel.clampText=label(appearance,"KEEP_ON_SCREEN",40,-390,355)
    appearance:SetHeight(450)
    panel.labels=check(appearance,8,-346,function(self)
        if canChange() then ns.DB.labels=self:GetChecked() and true or false;save(panel) else panel:Refresh() end
    end)
    panel.labelsText=label(appearance,"LABELS",40,-350,355)
    local info=panel.pages.INFO_TAB.content
    panel.info=label(info,"INFO_HELP",8,-8,395)
    panel.langText=label(info,"LANGUAGE",8,-155,395,"GameFontNormal");panel.languages={}
    for i,entry in ipairs({{"auto","AUTO"},{"de","GERMAN"},{"en","ENGLISH"}}) do
        local value,key=entry[1],entry[2]
        panel.languages[i]=button(info,8,-185-(i-1)*36,395,function()
            if not canChange() then return end
            ns.DB.language=value;ns.RefreshLocale();panel:Refresh()
        end);panel.languages[i].localeKey=key;panel.languages[i].languageValue=value
    end
    panel.reset=button(info,8,-350,395,function()
        if not canChange() then return end
        StaticPopupDialogs.HANSEMARK_RESET={text=ns.L.RESET_CONFIRM,button1=ns.L.RESET,button2=ns.L.CANCEL,timeout=0,whileDead=true,hideOnEscape=true,
            OnAccept=function()
                if not canChange() then return end
                local clean=ns.NormalizeSettings({})
                for key in pairs(ns.DB) do ns.DB[key]=nil end
                for key,value in pairs(clean) do ns.DB[key]=value end
                ns.RefreshLocale();save(panel)
            end}
        StaticPopup_Show("HANSEMARK_RESET")
    end)
    panel.diagnostics=button(info,8,-310,395,function() ns.Diagnose() end)
    panel.previewFrame=buildPreview(panel)
    panel.preview=button(panel,16,-478,200,function()
        if canChange() and ns.View.PreviewModal then ns.View:PreviewModal() end
    end)
    if not native then
        panel.close=button(panel,590,-478,190,function() ns.CancelKeyCapture();ns.View:Close();panel:Hide() end)
    end
    function panel:SelectTab(key)
        self.activeTab=key
        for tab,page in pairs(self.pages) do if tab==key then page.scroll:Show();if page.range>0 then page.bar:Show() else page.bar:Hide() end else page.scroll:Hide();page.bar:Hide() end end
        for tab,b in pairs(self.tabs) do b:SetText((tab==key and "• " or "")..ns.L[tab]) end
    end
    function panel:Refresh()
        self.refreshing=true
        self.title:SetText(ns.L.TITLE.." — "..ns.L.SETTINGS);self.subtitle:SetText(ns.L.SUBTITLE)
        self.keyLabel:SetText(ns.L.CURRENT_KEY..currentKey());self.bind:SetText(ns.L.BIND_KEY);self.unbind:SetText(ns.L.UNBIND)
        self.keyHelp:SetText(ns.L.KEY_HELP);self.modeLabel:SetText(ns.L.MODE);self.clickText:SetText(ns.L.CLICK);self.holdText:SetText(ns.L.HOLD)
        self.click:SetChecked(ns.DB.mode~="hold");self.hold:SetChecked(ns.DB.mode=="hold");self.placeHelp:SetText(ns.L.PLACE_HELP)
        self.markerTitle:SetText(ns.L.MARKERS)
        for i=1,8 do self.markerChecks[i]:SetChecked(ns.DB.enabled[i]);self.markerTexts[i]:SetText(ns.L[ns.MarkerNames[i]]) end
        for _,b in ipairs(self.presets) do b:SetText(ns.L[b.localeKey]) end
        self.subsetHelp:SetText(ns.L.SUBSET_HELP);self.skinTitle:SetText(ns.L.SKIN)
        self.skinDropdown:SetDefaultText(ns.StyleName(ns.GetStyle()))
        self.skinDropdown:GenerateMenu()
        self.iconScaleText:SetText(ns.L.ICON_SCALE);self.iconScale:SetValue(ns.DB.iconScale);self.iconScale.valueLabel:SetText(math.floor(ns.DB.iconScale*100+.5).."%")
        self.deadzoneText:SetText(ns.L.DEADZONE);self.deadzoneFraction:SetValue(ns.DB.deadzoneFraction);self.deadzoneFraction.valueLabel:SetText(math.floor(ns.DB.deadzoneFraction*100+.5).."%")
        self.clamp:SetChecked(ns.DB.clamp);self.clampText:SetText(ns.L.KEEP_ON_SCREEN)
        self.sizeText:SetText(ns.L.SIZE);self.size:SetValue(ns.DB.size);self.size.valueLabel:SetText(tostring(ns.DB.size))
        self.alphaText:SetText(ns.L.OPACITY);self.alpha:SetValue(ns.DB.alpha);self.alpha.valueLabel:SetText(math.floor(ns.DB.alpha*100+.5).."%")
        self.labels:SetChecked(ns.DB.labels);self.labelsText:SetText(ns.L.LABELS);self.info:SetText(ns.L.INFO_HELP);self.langText:SetText(ns.L.LANGUAGE)
        for _,b in ipairs(self.languages) do b:SetText((ns.DB.language==b.languageValue and "• " or "")..ns.L[b.localeKey]) end
        self.reset:SetText(ns.L.RESET);self.diagnostics:SetText(ns.L.DIAGNOSTICS);self.preview:SetText(ns.L.PREVIEW);if self.close then self.close:SetText(ns.L.CLOSE) end
        self:Layout();self.previewFrame:Refresh();self:SelectTab(self.activeTab or "INTERACTION_TAB");self.refreshing=false
    end
    -- Geometry comes from the actual native canvas; content and footer never
    -- assume the dimensions of the independent fallback window.
    function panel:Layout()
        if self.layingOut then return end
        self.layingOut=true
        local w,h=self:GetWidth(),self:GetHeight()
        if w<300 or h<250 then self.layingOut=false;return end
        local pad,gap=16,20
        local previewWidth=math.max(150,math.min(220,w*.29))
        local viewportWidth=w-pad*2-gap-previewWidth-14
        local cw=viewportWidth-8
        local viewportHeight=math.max(80,h-178)
        self.previewBox=previewWidth-12
        self.separators[1]:ClearAllPoints();self.separators[1]:SetPoint("TOPLEFT",self,"TOPLEFT",pad,-108);self.separators[1]:SetSize(w-pad*2,1)
        self.separators[2]:ClearAllPoints();self.separators[2]:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",pad,52);self.separators[2]:SetSize(w-pad*2,1)
        self.separators[3]:ClearAllPoints();self.separators[3]:SetPoint("TOPLEFT",self,"TOPLEFT",pad+viewportWidth+20,-118);self.separators[3]:SetSize(1,viewportHeight)
        self.title:SetWidth(w-90);self.subtitle:SetWidth(w-90)
        local tabWidth=(w-pad*2-18)/4
        local tabKeys={"INTERACTION_TAB","MARKERS_TAB","APPEARANCE_TAB","INFO_TAB"}
        for i,key in ipairs(tabKeys) do
            local b=self.tabs[key];b:ClearAllPoints();b:SetPoint("TOPLEFT",pad+(i-1)*(tabWidth+6),-76);b:SetWidth(tabWidth)
        end
        local function anchor(object,parent,x,y,width,height)
            object:ClearAllPoints();object:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y)
            if width then object:SetWidth(width) end;if height then object:SetHeight(height) end
        end
        local function text(object,parent,y,width,x)
            anchor(object,parent,x or 8,y,width or cw-16)
            return y+math.max(16,object:GetStringHeight())+12
        end
        local function row(a,b,parent,y)
            local half=(cw-24)/2
            anchor(a,parent,8,y,half,30);anchor(b,parent,16+half,y,half,30)
            return y+44
        end
        local function checkrow(c,t,parent,y)
            anchor(c,parent,8,y,24,24);anchor(t,parent,40,y+3,cw-48)
            return y+math.max(24,t:GetStringHeight()+6)+14
        end
        local function slide(title,control,parent,y)
            y=text(title,parent,y)
            anchor(control,parent,8,y,cw-100,18)
            anchor(control.valueLabel,parent,cw-80,y,72)
            return y+40
        end
        local function finish(key,height)
            local page=self.pages[key]
            page.scroll:ClearAllPoints();page.scroll:SetPoint("TOPLEFT",self,"TOPLEFT",pad,-118);page.scroll:SetSize(viewportWidth,viewportHeight)
            page.content:SetWidth(cw);page.content:SetHeight(height+12)
            page.bar:ClearAllPoints();page.bar:SetPoint("TOPLEFT",self,"TOPLEFT",pad+viewportWidth+3,-118);page.bar:SetHeight(viewportHeight)
            page.range=math.max(0,height+12-viewportHeight)
            page.bar:SetMinMaxValues(0,page.range);page.bar:SetValue(math.min(page.offset,page.range))
        end
        local parent=self.pages.INTERACTION_TAB.content
        local y=text(self.keyLabel,parent,8)
        y=row(self.bind,self.unbind,parent,y);y=text(self.keyHelp,parent,y)
        y=text(self.modeLabel,parent,y+8);y=checkrow(self.click,self.clickText,parent,y);y=checkrow(self.hold,self.holdText,parent,y)
        y=text(self.placeHelp,parent,y+8);finish("INTERACTION_TAB",y)
        parent=self.pages.MARKERS_TAB.content;y=text(self.markerTitle,parent,8)
        local column=(cw-16)/2
        for i=1,8 do
            local x=8+((i-1)%2)*column;local top=y+math.floor((i-1)/2)*44
            anchor(self.markerChecks[i],parent,x,top,24,24);anchor(self.markerIcons[i],parent,x+26,top,24,24)
            anchor(self.markerTexts[i],parent,x+54,top+4,column-60)
        end
        y=y+4*44+12;y=row(self.presets[1],self.presets[2],parent,y);y=row(self.presets[3],self.presets[4],parent,y)
        y=text(self.subsetHelp,parent,y);finish("MARKERS_TAB",y)
        parent=self.pages.APPEARANCE_TAB.content;y=text(self.skinTitle,parent,8)
        anchor(self.skinDropdown,parent,8,y,cw-16,30);y=y+48
        y=slide(self.sizeText,self.size,parent,y);y=slide(self.alphaText,self.alpha,parent,y)
        y=slide(self.iconScaleText,self.iconScale,parent,y);y=slide(self.deadzoneText,self.deadzoneFraction,parent,y)
        y=checkrow(self.labels,self.labelsText,parent,y);y=checkrow(self.clamp,self.clampText,parent,y)
        finish("APPEARANCE_TAB",y)
        parent=self.pages.INFO_TAB.content;y=text(self.info,parent,8);y=text(self.langText,parent,y+8)
        for _,b in ipairs(self.languages) do anchor(b,parent,8,y,cw-16,30);y=y+40 end
        anchor(self.diagnostics,parent,8,y,cw-16,30);y=y+44;anchor(self.reset,parent,8,y,cw-16,30);y=y+42
        finish("INFO_TAB",y)
        self.previewFrame:ClearAllPoints();self.previewFrame:SetPoint("CENTER",self,"TOPRIGHT",-pad-previewWidth/2,-118-math.min(viewportHeight*.44,150))
        self.previewFrame.caption:SetWidth(previewWidth)
        self.preview:ClearAllPoints();self.preview:SetPoint("BOTTOMLEFT",self,"BOTTOMLEFT",pad,12);self.preview:SetWidth(math.min(240,w*.45))
        if self.close then self.close:ClearAllPoints();self.close:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-pad,12);self.close:SetWidth(150) end
        self.layout={width=w,height=h,contentWidth=cw,viewportWidth=viewportWidth,viewportHeight=viewportHeight,previewWidth=previewWidth,footerTop=h-48}
        self.layingOut=false
    end
    panel:SetScript("OnSizeChanged",function() if not panel.refreshing then panel:Layout();panel.previewFrame:Refresh();panel:SelectTab(panel.activeTab or "INTERACTION_TAB") end end)
    panel:SetScript("OnShow",function() panel:Refresh() end)
    panel:SetScript("OnHide",function() ns.CancelKeyCapture();if ns.View.preview then ns.View:Close() end end)
    panel:RegisterEvent("PLAYER_REGEN_DISABLED")
    panel:SetScript("OnEvent",function() ns.CancelKeyCapture();if ns.View.preview then ns.View:Close() end;if not native then panel:Hide() end end)
    panel:Hide();return panel
end
function ns.RegisterSettings()
    if ns.settingsStatus=="registered" then return true end
    if type(Settings)~="table" or type(Settings.RegisterCanvasLayoutCategory)~="function" or type(Settings.RegisterAddOnCategory)~="function" then ns.settingsStatus="unavailable";return false end
    local ok=pcall(function()
        ns.settingsCanvas=ns.settingsCanvas or ns.CreateOptionsCanvas(UIParent,true)
        ns.settingsCategory=ns.settingsCategory or Settings.RegisterCanvasLayoutCategory(ns.settingsCanvas,"Hanse Mark")
        Settings.RegisterAddOnCategory(ns.settingsCategory)
    end)
    ns.settingsStatus=ok and "registered" or "error";return ok
end
function ns.OpenOptions()
    if not canChange() then return end
    if ns.Core:IsOpen() then ns.Core:Dismiss() end
    ns.View:Close()
    if ns.RegisterSettings() and type(Settings.OpenToCategory)=="function" then Settings.OpenToCategory(ns.settingsCategory:GetID());return end
    ns.fallbackOptions=ns.fallbackOptions or ns.CreateOptionsCanvas(UIParent,false)
    local panel=ns.fallbackOptions;panel:SetScale(math.min(1,(UIParent:GetWidth()-40)/800,(UIParent:GetHeight()-40)/530));panel:Refresh();panel:Show()
end
