# Anleitung — W11::OPTIMIZER

Diese Anleitung erklärt Schritt für Schritt, wie du das Skript benutzt, auch wenn du noch nie ein PowerShell-Skript gestartet hast. Rechne mit etwa 5 Minuten.

*[Français](MODE-EMPLOI.md) · [English](USER-GUIDE.md) · [Español](GUIA.md) · [Deutsch](ANLEITUNG.md) · [Nederlands](HANDLEIDING.md) · [中文](GUIDE-ZH.md) · [日本語](GUIDE-JA.md) · [العربية](GUIDE-AR.md) · [ไทย](GUIDE-TH.md)*

---

## 1. Was das Skript macht (und was nicht)

**Es macht:** Es ändert 10 Einstellungen von Windows 11, damit Spiele besser laufen (Energiesparplan, Spielmodus, Xbox Game Bar, Maus, visuelle Effekte …). Es sind dieselben Einstellungen, die du auch von Hand in den Windows-Einstellungen ändern könntest. Welche, wählst du in einem Menü aus.

**Es macht nicht:**
- Es installiert und lädt nichts herunter und braucht kein Internet.
- Es löscht keine Dateien und rührt weder deine Spiele noch deine Treiber an.
- Es läuft nicht im Hintergrund: Sobald es geschlossen ist, läuft nichts mehr.

**Gut zu wissen:** Vor jeder Änderung speichert es die alten Werte. Du kannst also jederzeit **alles wieder so machen, wie es vorher war** (siehe Schritt 6).

---

## 2. Das Skript herunterladen

1. Klicke auf der GitHub-Seite des Projekts auf die Datei **`JohnWishGamingOptimizer.ps1`**.
2. Klicke auf **Download raw file** (das Symbol mit dem Pfeil nach unten, oben rechts über dem Code).
3. Die Datei landet in deinem Ordner **Downloads**. Du kannst sie dort lassen oder verschieben.

> Alternative: grüner Button **Code** → **Download ZIP**, dann Rechtsklick auf die ZIP-Datei → **Alle extrahieren**.

### Die Datei zulassen (nur einmal)

Windows blockiert oft Skripte aus dem Internet. So vermeidest du Fehlermeldungen:

1. Rechtsklick auf `JohnWishGamingOptimizer.ps1` → **Eigenschaften**.
2. Unten auf der Registerkarte **Allgemein** das Kästchen **Zulassen** anhaken (fehlt das Kästchen, ist die Datei nicht blockiert).
3. Auf **OK** klicken.

---

## 3. Das Skript starten

### Einfacher Weg

1. Rechtsklick auf `JohnWishGamingOptimizer.ps1`.
2. **Mit PowerShell ausführen** wählen.
   Unter Windows 11 musst du eventuell zuerst auf **Weitere Optionen anzeigen** klicken.

> ⚠️ **Kein Doppelklick** auf die Datei: Sie würde im Editor geöffnet statt gestartet.

### Wenn sich das Fenster sofort schließt oder „die Ausführung von Skripts ist deaktiviert“ erscheint

1. Öffne den Ordner, in dem das Skript liegt.
2. Rechtsklick auf eine freie Stelle im Ordner → **In Terminal öffnen**.
3. Kopiere diese Zeile, füge sie ins Fenster ein (Rechtsklick zum Einfügen) und drücke **Enter**:

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1
```

Dieser Befehl erlaubt **nur diesen einen Start** des Skripts: Die Sicherheitseinstellungen deines PCs bleiben unverändert.

### Das Modul „GPU-Planung“ freischalten (Administrator)

Ein Modul braucht Administratorrechte. Ohne sie ist es einfach gesperrt (`◇ ADMIN`), alles andere funktioniert.

1. Rechtsklick auf den **Start**-Button → **Terminal (Administrator)** → **Ja**.
2. Tippe `cd` und ein Leerzeichen, ziehe den Ordner des Skripts ins Fenster und drücke **Enter**.
3. Füge den Befehl von oben ein und drücke **Enter**.

---

## 4. Das Menü benutzen

1. **Das Intro** läuft (Animation, Logo, Start im BIOS-Stil). Eine beliebige Taste überspringt es.
2. **Wähle deine Sprache** mit den Pfeiltasten **↑ ↓**, dann **Enter**.
3. **Das Menü** zeigt die 10 Module und ihren Status:

| Status | Bedeutung |
|---|---|
| `● AKTIV` | Die Einstellung ist bereits gesetzt |
| `○ AKTIVIEREN` | Die Einstellung ist noch nicht gesetzt |
| `◇ ADMIN` | Das Skript muss als Administrator gestartet werden (siehe oben) |
| `– N/V` | Betrifft diesen PC nicht (z. B. startet OneDrive nicht mit Windows) |

Noch nicht aktive Module sind **standardmäßig angehakt**. Die Beschreibung des ausgewählten Moduls steht unten im Rahmen.

| Taste | Aktion |
|---|---|
| **↑ ↓** | In der Liste bewegen |
| **Leertaste** | Modul an- / abhaken |
| **A** | Alle anhaken |
| **N** | Alle abhaken |
| **Enter** | Angehakte Module anwenden (dann **J** zum Bestätigen) |
| **R** | Originaleinstellungen wiederherstellen (siehe Schritt 6) |
| **Q** oder **Esc** | Beenden, **ohne etwas zu ändern** |

4. Nach der Bestätigung zeigt jedes Modul `[OK]` (erfolgreich) oder `[X]` (Problem, mit Erklärung).

---

## 5. Nach dem Skript

- **Starte deinen PC neu**: Manche Einstellungen (GPU-Planung, ein Teil der visuellen Effekte) wirken erst nach einem Neustart.
- **Die Einstellungen bleiben** auch nach dem Schließen des Skripts und nach Neustarts erhalten. Du musst es nicht bei jedem Start erneut ausführen.
- Ein großes Windows-Update kann manche Einstellungen zurücksetzen: Starte das Skript einfach erneut, es zeigt dir, was nicht mehr `● AKTIV` ist.

---

## 6. Alles wieder wie vorher

1. Starte das Skript erneut (wie in Schritt 3).
2. Drücke im Menü **R**, dann **J** zum Bestätigen.
3. Starte den PC neu.

Das Skript stellt die Einstellungen so wieder her, wie sie **vor seiner allerersten Benutzung** waren, auch wenn du es mehrmals gestartet hast.

Wurde das Modul „GPU-Planung“ angewendet, starte das Skript für die Wiederherstellung **als Administrator**.

> Die alten Werte liegen in `Documents\JohnWishOptimizer\` (der Ordner **Dokumente**). **Lösche diesen Ordner nicht**, wenn du zurückkehren können willst.

---

## 7. Häufige Fragen

**Die Datei öffnet sich im Editor.**
Schließe sie und nutze Rechtsklick → **Mit PowerShell ausführen** (Schritt 3).

**Windows oder mein Virenscanner zeigt eine Warnung.**
Das Skript ist nicht digital signiert, wie die meisten kostenlosen Skripte. Es ist eine einfache Textdatei: Du kannst sie im Editor öffnen und genau nachlesen, was sie tut, bevor du sie startest.

**Farben oder Symbole werden falsch angezeigt (`?` oder Kästchen).**
Benutze **Windows-Terminal** (in Windows 11 enthalten) statt des alten PowerShell-Fensters: die Methode „In Terminal öffnen“ aus Schritt 3.

**Das Bild im Intro ist klein oder abgeschnitten.**
Vergrößere das Fenster vor dem Start: Das Bild passt sich an und wird schärfer. Eine beliebige Taste überspringt das Intro.

**Kann es Probleme mit dem Anti-Cheat von Spielen geben?**
Das Skript ändert nur Windows-Einstellungen. Es greift weder auf Spieldateien noch auf den Speicher von Spielen zu und läuft nach dem Schließen nicht weiter.

**Wie deinstalliere ich es?**
Es gibt nichts zu deinstallieren. Um seine Änderungen rückgängig zu machen, folge Schritt 6 und lösche dann die Datei.

**Ich will alles ohne Menü anwenden.**

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -All
```

**Ich will die Sprache direkt wählen** (`fr`, `en`, `es`, `de`, `nl`, `zh`, `ja`, `ar`, `th`):

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Language de
```

---

*© 2025-2026 John Wish — Alle Rechte vorbehalten. Kostenlos für den persönlichen Gebrauch; Kopieren, Ändern, Weitergeben oder Verkaufen ohne Erlaubnis verboten. Siehe [LICENSE](LICENSE).*
