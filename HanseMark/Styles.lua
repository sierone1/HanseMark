local _, ns = ...
ns.Styles = {
    {id="alliance", en="Alliance", de="Allianz", frame=true},
    {id="horde", en="Horde", de="Horde", frame=true},
    {id="satin", en="Satin", de="Satin"},
    {id="klar", en="Clear", de="Klar"},
    {id="orbit", en="Orbit", de="Orbit"},
    {id="frei", en="Free", de="Frei"},
}
ns.StyleByID = {}
for _, style in ipairs(ns.Styles) do ns.StyleByID[style.id] = style end
function ns.GetStyle()
    return ns.StyleByID[ns.DB and ns.DB.skin] or ns.StyleByID.satin
end
function ns.StyleName(style)
    return ns.L.CANCEL == "Abbrechen" and style.de or style.en
end
