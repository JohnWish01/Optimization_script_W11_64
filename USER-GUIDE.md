# User guide — W11::OPTIMIZER

This guide walks you through the script step by step, even if you have never run a PowerShell script before. It takes about 5 minutes.

*[Français](MODE-EMPLOI.md) · [English](USER-GUIDE.md) · [Español](GUIA.md) · [Deutsch](ANLEITUNG.md) · [Nederlands](HANDLEIDING.md) · [中文](GUIDE-ZH.md) · [日本語](GUIDE-JA.md) · [العربية](GUIDE-AR.md) · [ไทย](GUIDE-TH.md)*

---

## 1. What the script does (and doesn't do)

**It does:** change 10 Windows 11 settings so games run better (power plan, Game Mode, Xbox Game Bar, mouse, visual effects…). These are the same settings you could change by hand in Windows Settings. You pick which ones in a menu.

**It doesn't:**
- install or download anything, or need the Internet;
- delete any file or touch your games or drivers;
- run in the background: once it is closed, nothing keeps running.

**Good to know:** before every change, it records the previous values. You can **put everything back the way it was** at any time (see step 6).

---

## 2. Download the script

1. On the project's GitHub page, click the **`JohnWishGamingOptimizer.ps1`** file.
2. Click **Download raw file** (the down-arrow icon at the top right of the code).
3. The file lands in your **Downloads** folder. You can leave it there or move it anywhere.

> Alternative: green **Code** button → **Download ZIP**, then right-click the ZIP → **Extract All**.

### Unblock the file (once)

Windows often blocks scripts downloaded from the Internet. To avoid error messages:

1. Right-click `JohnWishGamingOptimizer.ps1` → **Properties**.
2. At the bottom of the **General** tab, tick **Unblock** (if there is no such box, the file isn't blocked).
3. Click **OK**.

---

## 3. Run the script

### Easy way

1. Right-click `JohnWishGamingOptimizer.ps1`.
2. Choose **Run with PowerShell**.
   On Windows 11 you may first need to click **Show more options** to see it.

> ⚠️ **Don't double-click** the file: it would open in Notepad instead of running.

### If the window closes immediately or says "running scripts is disabled"

1. Open the folder that contains the script.
2. Right-click an empty area of the folder → **Open in Terminal**.
3. Copy this line, paste it into the window (right-click to paste) and press **Enter**:

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1
```

This command allows **only this run** of the script: it doesn't change your PC's security settings.

### To unlock the "GPU scheduling" module (administrator)

One module needs administrator rights. Without them it is simply locked (`◇ ADMIN`) and everything else works.

1. Right-click the **Start** button → **Terminal (Admin)** → **Yes**.
2. Type `cd` followed by a space, drag the script's folder into the window, and press **Enter**.
3. Paste the command above and press **Enter**.

---

## 4. Use the menu

1. **The intro** plays (animation, logo, BIOS-style boot). Press any key to skip it.
2. **Pick your language** with the **↑ ↓** arrows, then **Enter**.
3. **The menu** shows the 10 modules and their status:

| Status | Meaning |
|---|---|
| `● ACTIVE` | The setting is already in place |
| `○ TO ENABLE` | The setting isn't in place yet |
| `◇ ADMIN` | Run the script as administrator (see above) |
| `– N/A` | Doesn't apply to this PC (e.g. OneDrive doesn't start with Windows) |

Modules that aren't active yet are **ticked by default**. The description of the selected module is shown at the bottom of the frame.

| Key | Action |
|---|---|
| **↑ ↓** | Move through the list |
| **Space** | Tick / untick the module |
| **A** | Tick all |
| **N** | Untick all |
| **Enter** | Apply the ticked modules (then **Y** to confirm) |
| **R** | Restore the original settings (see step 6) |
| **Q** or **Esc** | Quit **without changing anything** |

4. After you confirm, each module shows `[OK]` (done) or `[X]` (problem, with an explanation).

---

## 5. After running the script

- **Restart your PC**: some settings (GPU scheduling, part of the visual effects) only take effect after a restart.
- **The settings stay** after closing the script and after restarts. You don't need to run it again at each startup.
- A major Windows update can sometimes reset some settings: just run the script again, it will show you what is no longer `● ACTIVE`.

---

## 6. Put everything back

1. Run the script again (as in step 3).
2. In the menu, press **R**, then **Y** to confirm.
3. Restart your PC.

The script restores the settings as they were **before its very first use**, even if you ran it several times.

If the "GPU scheduling" module was applied, run the script **as administrator** to restore it.

> The previous values are stored in `Documents\JohnWishOptimizer\`. **Don't delete this folder** if you want to be able to go back.

---

## 7. FAQ

**The file opens in Notepad.**
Close it and use right-click → **Run with PowerShell** (step 3).

**Windows or my antivirus shows a warning.**
The script isn't digitally signed, like most free scripts. It's a plain text file: you can open it in Notepad to read exactly what it does before running it.

**Colours or symbols look wrong (`?` or boxes).**
Use **Windows Terminal** (built into Windows 11) instead of the old PowerShell window: the "Open in Terminal" method from step 3.

**The intro picture is small or cut off.**
Make the window bigger before running the script: the picture adapts and gets sharper. Any key skips the intro.

**Can it cause trouble with game anti-cheat?**
The script only changes Windows settings. It doesn't touch game files or memory, and nothing keeps running once it's closed.

**How do I uninstall it?**
There's nothing to uninstall. To undo its effects, follow step 6, then delete the file.

**I want to apply everything without the menu.**

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -All
```

**I want to pick the language directly** (`fr`, `en`, `es`, `de`, `nl`, `zh`, `ja`, `ar`, `th`):

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Language en
```

---

*© 2025-2026 John Wish — All rights reserved. Free for personal use; copying, modifying, redistributing or selling is not allowed without permission. See [LICENSE](LICENSE).*
