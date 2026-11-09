# Hanse Mark

![Hanse Mark](docs/logo.png)

[English instructions](README.md)

Hanse Mark ist ein anpassbares Bodenmarker-Kreismenü für Gruppen- und Raidleiter in **WoW Forever**. Öffne es am Mauszeiger, wähle ein Symbol und platziere es auf dem Boden. Version **1.0.0** richtet sich an Forever **1.60.1 / Interface 16001** und enthält Deutsch und Englisch. Zusätzliche Addons werden nicht benötigt.

## Funktionen und Gestaltungen

Wähle eine beliebige Kombination der acht Bodenmarker. Aktive Symbole verteilen sich gleichmäßig; Vorlagen wählen keine, drei, fünf oder alle acht Markierungen. Ein deaktiviertes Symbol verschwindet aus dem Menü, ohne vorhandene Bodenmarkierungen zu entfernen.

Sechs Gestaltungen sind enthalten:

- **Allianz:** Blau und Gold mit verziertem Fraktionsrahmen.
- **Horde:** Rot und dunkles Metall mit verziertem Fraktionsrahmen.
- **Satin:** ein zurückhaltender Metallring; die Standardgestaltung.
- **Klar:** schwarze Ringe und Trennlinien zwischen den Segmenten.
- **Orbit:** schwarze Ringe und kleine Striche ohne Segmenttrennlinien.
- **Frei:** freistehende Symbole mit weicher Hervorhebung beim Darüberfahren.

Ringgröße, Symbolgröße, Deckkraft, Markernamen, neutrale Mitte und Bildschirmbegrenzung sind einstellbar. Die Sprache folgt dem Spielclient oder wird auf Deutsch beziehungsweise Englisch festgelegt.

## Installation und erster Start

**CurseForge App:** Wähle deine WoW-Forever-Installation beziehungsweise das passende Profil, suche Hanse Mark und installiere es. Starte WoW anschließend vollständig neu, besonders bei neuen Grafikdateien.

**Manuell:** Schließe WoW, entpacke das Addon-ZIP und kopiere den enthaltenen Ordner `HanseMark` nach `Interface/AddOns` deines Forever-Clients. Danach muss diese Datei vorhanden sein:

`<Ordner deines Forever-Clients>/Interface/AddOns/HanseMark/HanseMark.toc`

Vermeide einen zweiten verschachtelten `HanseMark`-Ordner. Starte WoW, aktiviere das Addon und öffne **Esc > Optionen > AddOns > Hanse Mark** oder `/hansemark`. Weise eine Taste zu; automatisch wird keine belegt. Eine bereits verwendete Taste wird erst nach Bestätigung der angezeigten bisherigen Belegung ersetzt.

## Einstellungen und sichere Vorschauen

**Bedienung** enthält die aktuelle Taste, Zuweisung/Entfernung und Klick-/Haltemodus. **Marker** enthält einzelne Symbole und Vorlagen. **Darstellung** bietet die sechs Gestaltungen und Anzeigeoptionen. **Info** enthält Sprache, Hilfe, Diagnose und bestätigtes Zurücksetzen.

Die eingebettete Vorschau folgt deinen Einstellungen. Die große Vorschau reagiert auf die Maus und setzt keine Marker. Mitte und Außenbereich wählen nichts aus. Beim Schließen kehrst du zum gleichen Einstellungsreiter zurück. Aktiviere mindestens einen Marker für eine Ringvorschau.

## Marker platzieren

**Klickmodus:**

1. Drücke die zugewiesene Taste zum Öffnen.
2. Klicke auf das gewünschte sichtbare Symbol.
3. Bewege die Maus auf gültigen Boden und klicke erneut zum Platzieren.

**Haltemodus:**

1. Halte die zugewiesene Taste gedrückt.
2. Bewege die Maus in Richtung des gewünschten Markers und lasse die Taste los.
3. Klicke auf gültigen Boden zum Platzieren.

Loslassen in der neutralen Mitte bricht ab. Escape oder Rechtsklick beendet die Ringauswahl. Schließe einen bereits aktiven Boden-Zielkreis zunächst mit WoWs normalem Abbruch. Im Klickmodus muss das Symbol selbst angeklickt werden; hervorgehobene Segmente allein sind keine Klickziele.

## Kampf, Berechtigungen und gespeicherte Einstellungen

Der manuell ausgelöste geschützte Ablauf unterstützt die Nutzung im Kampf. Gruppenrechte, Reichweite und gültiger Boden bleiben WoW-Regeln; das Addon gewährt keine zusätzlichen Markierungsrechte. Eine leere Markerauswahl führt keine Markeraktion aus. Einstellungen und Tasten werden außerhalb des Kampfes geändert. Automatische Bosslogik oder Platzierung gibt es nicht.

Gestaltung und Bedienung werden accountweit in `HanseMarkDB` innerhalb des jeweiligen WoW-Clients/Accounts gespeichert. Tasten verwenden WoWs aktiven Belegungssatz. Schließe WoW für Updates und ersetze den Addonordner, während die gespeicherten Variablen erhalten bleiben. Einstellungen werden automatisch übernommen. Bestätigtes Zurücksetzen stellt Standardwerte wieder her und behält die Taste; ihre Entfernung ist eine eigene Aktion.

## Befehle und Problemlösung

- `/hansemark` oder `/hmark`: Einstellungen öffnen.
- `/hansemark diag` oder `/hmark diag`: Diagnose ausgeben.

Kein Ring: Taste und aktivierte Marker prüfen. Keine Platzierung: Gruppenrechte und gültigen Boden prüfen. Fehlende Grafiken: Ordnerstruktur kontrollieren und WoW vollständig neu starten; `/reload` kann bei neuen Dateien unzureichend sein. Für Fehlermeldungen Version, Forever-Build, Sprache, Bedienmodus, Marker, Gruppenrolle, Kampfzustand, reproduzierbare Schritte und Diagnose angeben. Persönliche Angaben vor dem Teilen von Screenshots entfernen.

## Mitwirkende und Lizenz

Entwickelt von **Steve Motzek (Hanse)** mit KI-Unterstützung bei Entwicklung und Grafik. Die Gestaltung enthält KI-generierte/bearbeitete Bilder und programmatisch erstellte Oberflächentexturen. Die veröffentlichte Stilübersicht kombiniert tatsächliche Addontexturen und ist **keine Spielaufnahme**.

Die Nutzung ist im Rahmen der **All-Rights-Reserved-Lizenz** kostenlos. Die Berechtigungen stehen in `LICENSE.txt`. Blizzard-Namen, Marken und Spielressourcen bleiben bei ihren Rechteinhabern. Hanse Mark ist ein unabhängiges Fan-Addon ohne Verbindung zu oder Unterstützung durch Blizzard.

[Änderungen](CHANGELOG.md) · [Lizenz](LICENSE.txt) · [Prüfstand](docs/VALIDATION.md)

## Source and support / Quellcode und Hilfe

[Source / Quellcode](https://github.com/sierone1/HanseMark) · [Issues / Fehler melden](https://github.com/sierone1/HanseMark/issues)
