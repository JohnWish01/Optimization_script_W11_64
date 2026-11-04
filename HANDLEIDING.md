# Handleiding — W11::OPTIMIZER

Deze handleiding legt stap voor stap uit hoe je het script gebruikt, ook als je nog nooit een PowerShell-script hebt gestart. Reken op ongeveer 5 minuten.

*[Français](MODE-EMPLOI.md) · [English](USER-GUIDE.md) · [Español](GUIA.md) · [Deutsch](ANLEITUNG.md) · [Nederlands](HANDLEIDING.md) · [中文](GUIDE-ZH.md) · [日本語](GUIDE-JA.md) · [العربية](GUIDE-AR.md) · [ไทย](GUIDE-TH.md)*

---

## 1. Wat het script doet (en wat niet)

**Het doet:** het wijzigt 10 instellingen van Windows 11 zodat games beter draaien (energiebeheerschema, Gamemodus, Xbox Game Bar, muis, visuele effecten…). Het zijn dezelfde instellingen die je ook zelf in de Windows-instellingen kunt wijzigen. Welke, kies je in een menu.

**Het doet niet:**
- het installeert of downloadt niets en heeft geen internet nodig;
- het verwijdert geen bestanden en komt niet aan je games of stuurprogramma's;
- het draait niet op de achtergrond: zodra het gesloten is, draait er niets meer.

**Goed om te weten:** vóór elke wijziging bewaart het de oude waarden. Je kunt dus op elk moment **alles terugzetten zoals het was** (zie stap 6).

---

## 2. Het script downloaden

1. Klik op de GitHub-pagina van het project op het bestand **`JohnWishGamingOptimizer.ps1`**.
2. Klik op **Download raw file** (het pictogram met een pijl naar beneden, rechtsboven de code).
3. Het bestand komt in je map **Downloads**. Je kunt het daar laten of verplaatsen.

> Andere mogelijkheid: groene knop **Code** → **Download ZIP**, daarna rechtsklik op het ZIP-bestand → **Alles uitpakken**.

### De blokkering opheffen (één keer)

Windows blokkeert vaak scripts van internet. Zo voorkom je foutmeldingen:

1. Rechtsklik op `JohnWishGamingOptimizer.ps1` → **Eigenschappen**.
2. Vink onderaan het tabblad **Algemeen** **Blokkering opheffen** aan (staat het vakje er niet, dan is het bestand niet geblokkeerd).
3. Klik op **OK**.

---

## 3. Het script starten

### Eenvoudige manier

1. Rechtsklik op `JohnWishGamingOptimizer.ps1`.
2. Kies **Uitvoeren met PowerShell**.
   In Windows 11 moet je soms eerst op **Meer opties weergeven** klikken.

> ⚠️ **Niet dubbelklikken** op het bestand: het zou dan in Kladblok openen in plaats van starten.

### Als het venster meteen sluit of meldt dat "het uitvoeren van scripts is uitgeschakeld"

1. Open de map waarin het script staat.
2. Rechtsklik op een lege plek in de map → **Openen in Terminal**.
3. Kopieer deze regel, plak hem in het venster (rechtsklik om te plakken) en druk op **Enter**:

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1
```

Deze opdracht staat **alleen deze keer** het script toe: de beveiliging van je pc verandert niet.

### De module "GPU-planning" ontgrendelen (beheerder)

Eén module heeft beheerdersrechten nodig. Zonder die rechten is ze gewoon vergrendeld (`◇ ADMIN`) en werkt de rest wel.

1. Rechtsklik op de knop **Start** → **Terminal (Administrator)** → **Ja**.
2. Typ `cd` gevolgd door een spatie, sleep de map van het script naar het venster en druk op **Enter**.
3. Plak de opdracht hierboven en druk op **Enter**.

---

## 4. Het menu gebruiken

1. **De intro** speelt af (animatie, logo, opstarten in BIOS-stijl). Druk op een willekeurige toets om hem over te slaan.
2. **Kies je taal** met de pijltjestoetsen **↑ ↓** en dan **Enter**.
3. **Het menu** toont de 10 modules en hun status:

| Status | Betekenis |
|---|---|
| `● ACTIEF` | De instelling is al toegepast |
| `○ ACTIVEREN` | De instelling is nog niet toegepast |
| `◇ ADMIN` | Start het script als beheerder (zie hierboven) |
| `– N.v.t.` | Niet van toepassing op deze pc (bijvoorbeeld OneDrive start niet mee met Windows) |

Modules die nog niet actief zijn, zijn **standaard aangevinkt**. De beschrijving van de gekozen module staat onderaan in het kader.

| Toets | Actie |
|---|---|
| **↑ ↓** | Door de lijst bewegen |
| **Spatie** | Module aan- / uitvinken |
| **A** | Alles aanvinken |
| **N** | Alles uitvinken |
| **Enter** | Aangevinkte modules toepassen (daarna **J** om te bevestigen) |
| **R** | Oorspronkelijke instellingen terugzetten (zie stap 6) |
| **Q** of **Esc** | Stoppen **zonder iets te wijzigen** |

4. Na bevestiging toont elke module `[OK]` (gelukt) of `[X]` (probleem, met uitleg).

---

## 5. Na het script

- **Start je pc opnieuw op**: sommige instellingen (GPU-planning, een deel van de visuele effecten) werken pas na een herstart.
- **De instellingen blijven** na het sluiten van het script en na herstarts behouden. Je hoeft het niet bij elke start opnieuw uit te voeren.
- Een grote Windows-update kan sommige instellingen terugzetten: start het script gewoon opnieuw, het laat zien wat niet meer `● ACTIEF` is.

---

## 6. Alles terugzetten zoals het was

1. Start het script opnieuw (zoals in stap 3).
2. Druk in het menu op **R** en dan op **J** om te bevestigen.
3. Start de pc opnieuw op.

Het script zet de instellingen terug zoals ze waren **vóór het allereerste gebruik**, ook als je het meerdere keren hebt gestart.

Werd de module "GPU-planning" toegepast, start het script dan **als beheerder** om ze terug te zetten.

> De oude waarden staan in `Documents\JohnWishOptimizer\` (de map **Documenten**). **Verwijder deze map niet** als je terug wilt kunnen.

---

## 7. Veelgestelde vragen

**Het bestand opent in Kladblok.**
Sluit het en gebruik rechtsklik → **Uitvoeren met PowerShell** (stap 3).

**Windows of mijn antivirus geeft een waarschuwing.**
Het script is niet digitaal ondertekend, zoals de meeste gratis scripts. Het is een gewoon tekstbestand: je kunt het in Kladblok openen en precies lezen wat het doet voordat je het start.

**Kleuren of symbolen worden verkeerd weergegeven (`?` of vakjes).**
Gebruik **Windows Terminal** (standaard in Windows 11) in plaats van het oude PowerShell-venster: de methode "Openen in Terminal" uit stap 3.

**De afbeelding in de intro is klein of afgesneden.**
Maak het venster groter voordat je het script start: de afbeelding past zich aan en wordt scherper. Elke toets slaat de intro over.

**Kan het problemen geven met de anti-cheat van games?**
Het script wijzigt alleen Windows-instellingen. Het komt niet aan de bestanden of het geheugen van games en draait niet meer zodra het gesloten is.

**Hoe verwijder ik het?**
Er valt niets te verwijderen. Wil je de wijzigingen ongedaan maken, volg dan stap 6 en verwijder daarna het bestand.

**Ik wil alles toepassen zonder menu.**

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -All
```

**Ik wil de taal direct kiezen** (`fr`, `en`, `es`, `de`, `nl`, `zh`, `ja`, `ar`, `th`):

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Language nl
```

---

*© 2025-2026 John Wish — Alle rechten voorbehouden. Gratis voor persoonlijk gebruik; kopiëren, wijzigen, verspreiden of verkopen zonder toestemming is niet toegestaan. Zie [LICENSE](LICENSE).*
