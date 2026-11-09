local _, ns = ...

local en = {
    TITLE = "Hanse Mark", SUBTITLE = "World marker ring", SETTINGS = "Settings",
    MODE = "Interaction", CLICK = "Press, select, then place", HOLD = "Hold, aim, release, then place",
    SIZE = "Ring size", OPACITY = "Opacity", LABELS = "Show marker name", LANGUAGE = "Language",
    AUTO = "Automatic", GERMAN = "Deutsch", ENGLISH = "English", PREVIEW = "Preview", CLOSE = "Close",
    CANCEL = "Cancel", SELECT = "Choose a marker", WORLD = "World marker", PREVIEW_LABEL = "Preview — no markers are placed",
    BINDING = "Open world marker ring", KEY_HELP = "Set your key under Esc > Options > Keybindings > Hanse Mark. No key is assigned automatically.",
    PLACE_HELP = "Choose a marker, then click a valid ground position. Escape or right-click cancels.",
    HOLD_HELP = "Hold your key, aim at a marker and release. Then click the ground. Release in the center to cancel.",
    COMBAT_SETTINGS = "Settings can only be changed outside combat.", COMBAT_PREVIEW = "Preview is unavailable in combat.",
    READY = "Ready. Use /hansemark for settings and assign a key under Keybindings > Hanse Mark.",
    GROUP_HELP = "World markers require a group and the marking permissions granted by WoW.",
    TEST_NOTE = "Combat behavior must be verified in your actual game client.",
    STAR = "Star", CIRCLE = "Circle", DIAMOND = "Diamond", TRIANGLE = "Triangle", MOON = "Moon", SQUARE = "Square", CROSS = "Cross", SKULL = "Skull",
}
en.MARKERS = "Visible world markers"
en.ALL = "All 8"; en.NONE = "None"; en.THREE = "3 markers"; en.FIVE = "5 markers"
en.SKIN = "Menu style"
en.PRECISION = "Precision"; en.OUTLINE = "Outline"; en.MINIMAL = "Minimal"
en.NO_MARKERS = "No markers are enabled. Open /hansemark and enable at least one marker."
en.SUBSET_HELP = "Disabled markers are hidden from this menu; existing world markers remain unchanged."
local de = {
    TITLE = "Hanse Mark", SUBTITLE = "Kreismenü für Bodenmarkierungen", SETTINGS = "Einstellungen",
    MODE = "Bedienung", CLICK = "Drücken, auswählen, dann platzieren", HOLD = "Halten, auswählen, loslassen, dann platzieren",
    SIZE = "Ringgröße", OPACITY = "Deckkraft", LABELS = "Markernamen anzeigen", LANGUAGE = "Sprache",
    AUTO = "Automatisch", GERMAN = "Deutsch", ENGLISH = "English", PREVIEW = "Vorschau", CLOSE = "Schließen",
    CANCEL = "Abbrechen", SELECT = "Marker auswählen", WORLD = "Bodenmarkierung", PREVIEW_LABEL = "Vorschau — es werden keine Marker gesetzt",
    BINDING = "Kreismenü für Bodenmarkierungen öffnen", KEY_HELP = "Taste unter Esc > Optionen > Tastenbelegung > Hanse Mark festlegen. Es wird keine Taste automatisch belegt.",
    PLACE_HELP = "Marker auswählen und danach auf eine gültige Bodenstelle klicken. Escape oder Rechtsklick bricht ab.",
    HOLD_HELP = "Taste halten, in Richtung eines Markers zeigen und loslassen. Danach auf den Boden klicken. Loslassen in der Mitte bricht ab.",
    COMBAT_SETTINGS = "Einstellungen können nur außerhalb des Kampfes geändert werden.", COMBAT_PREVIEW = "Die Vorschau ist im Kampf nicht verfügbar.",
    READY = "Bereit. Einstellungen mit /hansemark öffnen und unter Tastenbelegung > Hanse Mark eine Taste festlegen.",
    GROUP_HELP = "Bodenmarkierungen benötigen eine Gruppe und die von WoW gewährten Markierungsrechte.",
    TEST_NOTE = "Die Kampffunktion muss auf deinem tatsächlichen Spielclient geprüft werden.",
    STAR = "Stern", CIRCLE = "Kreis", DIAMOND = "Diamant", TRIANGLE = "Dreieck", MOON = "Mond", SQUARE = "Quadrat", CROSS = "Kreuz", SKULL = "Totenkopf",
}
de.MARKERS = "Sichtbare Bodenmarkierungen"
de.ALL = "Alle 8"; de.NONE = "Keine"; de.THREE = "3 Marker"; de.FIVE = "5 Marker"
de.SKIN = "Menüstil"
de.PRECISION = "Präzision"; de.OUTLINE = "Kontur"; de.MINIMAL = "Minimal"
de.NO_MARKERS = "Keine Marker aktiviert. Öffne /hansemark und aktiviere mindestens einen Marker."
de.SUBSET_HELP = "Deaktivierte Marker verschwinden aus diesem Menü; gesetzte Bodenmarkierungen bleiben erhalten."
en.INTERACTION_TAB="Interaction"; de.INTERACTION_TAB="Bedienung"
en.MARKERS_TAB="Markers"; de.MARKERS_TAB="Marker"
en.APPEARANCE_TAB="Appearance"; de.APPEARANCE_TAB="Darstellung"
en.INFO_TAB="Info"; de.INFO_TAB="Info"
en.EMBEDDED_PREVIEW="Live preview · no marker actions"; de.EMBEDDED_PREVIEW="Live-Vorschau · keine Markeraktionen"
en.CURRENT_KEY="Current key: "; de.CURRENT_KEY="Aktuelle Taste: "
en.UNBOUND="Unbound"; de.UNBOUND="Unbelegt"
en.BIND_KEY="Assign key"; de.BIND_KEY="Taste zuweisen"
en.UNBIND="Remove binding"; de.UNBIND="Belegung entfernen"
en.BINDING_CHANGED="The key assignment changed. Please try again."; de.BINDING_CHANGED="Die Tastenbelegung wurde zwischenzeitlich verändert. Bitte erneut versuchen."
en.BINDING_FAILED="The key could not be assigned."; de.BINDING_FAILED="Die Taste konnte nicht zugewiesen werden."
en.CAPTURE_HELP="Press a key or mouse side button. Modifiers are supported. Escape or right-click cancels."; de.CAPTURE_HELP="Taste oder Maus-Seitentaste drücken. Kombinationen sind möglich. Escape oder Rechtsklick bricht ab."
en.BIND_CONFLICT="%s is assigned to %s. Replace this binding?"; de.BIND_CONFLICT="%s ist mit %s belegt. Diese Belegung ersetzen?"
en.REPLACE="Replace"; de.REPLACE="Ersetzen"
en.DIAGNOSTICS="Show diagnostic report"; de.DIAGNOSTICS="Diagnosebericht anzeigen"
en.INFO_HELP="Hanse Mark places world markers through your explicit input. Select a marker, then choose valid ground. Group permissions still apply. Escape/right-click cancels. Settings change only outside combat."; de.INFO_HELP="Hanse Mark setzt Bodenmarkierungen durch deine ausdrückliche Eingabe. Marker auswählen und danach gültigen Boden bestimmen. Gruppenrechte bleiben maßgeblich. Escape/Rechtsklick bricht ab. Einstellungen nur außerhalb des Kampfes ändern."
en.SKIN="Menu style"; de.SKIN="Menüstil"
en.ICON_SCALE="Icon size";de.ICON_SCALE="Symbolgröße"
en.DEADZONE="Neutral center zone";de.DEADZONE="Neutrale Mittelzone"
en.KEEP_ON_SCREEN="Keep the ring on screen near edges";de.KEEP_ON_SCREEN="Ring an Bildschirmrändern sichtbar halten"
en.RESET="Reset settings";de.RESET="Einstellungen zurücksetzen"
en.RESET_CONFIRM="Reset Hanse Mark settings? Your keybindings will be kept.";de.RESET_CONFIRM="Hanse-Mark-Einstellungen zurücksetzen? Deine Tastenbelegung bleibt erhalten."
ns.L = {}
function ns.RefreshLocale()
    local choice = ns.DB and ns.DB.language or "auto"
    local useGerman = choice == "de" or (choice ~= "en" and GetLocale() == "deDE")
    local source = useGerman and de or en
    for key, value in pairs(en) do ns.L[key] = source[key] or value end
    _G.BINDING_HEADER_HANSEMARK = "Hanse Mark"
    _G["BINDING_NAME_CLICK HanseMarkOpenButton:LeftButton"] = ns.L.BINDING
end
ns.RefreshLocale()
ns.MarkerNames = { "STAR", "CIRCLE", "DIAMOND", "TRIANGLE", "MOON", "SQUARE", "CROSS", "SKULL" }
