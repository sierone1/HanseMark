local addonName, ns = ...
local defaults = { size = 240, mode = "click", alpha = 0.95, labels = true, language = "auto", skin = "satin", iconScale = 1, deadzoneFraction = .16, clamp = true }
local function normalize(saved)
    if type(saved) ~= "table" then saved = {} end
    local clean = {}
    for key, value in pairs(defaults) do
        if type(saved[key]) == type(value) then clean[key] = saved[key] else clean[key] = value end
    end
    if clean.size ~= clean.size or clean.size == math.huge or clean.size == -math.huge then clean.size = defaults.size end
    if clean.alpha ~= clean.alpha or clean.alpha == math.huge or clean.alpha == -math.huge then clean.alpha = defaults.alpha end
    clean.size = math.max(160, math.min(400, clean.size))
    clean.alpha = math.max(0.35, math.min(1, clean.alpha))
    if clean.mode ~= "click" and clean.mode ~= "hold" then clean.mode = "click" end
    if clean.language ~= "auto" and clean.language ~= "de" and clean.language ~= "en" then clean.language = "auto" end
    local legacy={precision="klar",pure="frei",minimal="frei",line="orbit",outline="orbit",dots="orbit",sunward="alliance"}
    clean.skin=legacy[clean.skin] or clean.skin
    local allowed={alliance=true,horde=true,satin=true,klar=true,orbit=true,frei=true}
    if not allowed[clean.skin] then clean.skin="satin" end
    clean.enabled = {}
    for i = 1, 8 do clean.enabled[i] = not (type(saved.enabled) == "table" and saved.enabled[i] == false) end
    for key,bounds in pairs({iconScale={.8,1.3},deadzoneFraction={.12,.24}}) do
        if clean[key]~=clean[key] or clean[key]==math.huge or clean[key]==-math.huge then clean[key]=defaults[key] end
        clean[key]=math.max(bounds[1],math.min(bounds[2],clean[key]))
    end
    clean.schema = 4
    return clean
end
ns.NormalizeSettings = normalize
function ns.Print(message)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff65dcdbHanse Mark:|r " .. tostring(message)) end
end
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    HanseMarkDB = normalize(HanseMarkDB)
    ns.DB = HanseMarkDB
    if ns.RefreshLocale then ns.RefreshLocale() end
    ns.View:Initialize()
    ns.Core:Initialize()
    ns.Binding:Initialize()
    ns.RegisterSettings()
    SLASH_HANSEMARK1 = "/hansemark"
    SLASH_HANSEMARK2 = "/hmark"
    SlashCmdList.HANSEMARK = function(text)
        if text and text:lower():match("^%s*diag%s*$") then ns.Diagnose() else ns.OpenOptions() end
    end
end)
