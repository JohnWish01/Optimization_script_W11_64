# W11::OPTIMIZER — Windows 11 Gaming Optimizer

🇫🇷 Un script pour optimiser Windows 11 pour le jeu, plutôt utile sur les PC moins puissants quand on veut profiter de toutes leurs ressources. Interface façon terminal cyberpunk : intro animée (portrait cyberpunk qui se décode en ASCII puis se révèle en pixels), séquence de démarrage façon BIOS, choix de la langue, puis un menu aux flèches pour choisir ses réglages.

📖 **Mode d'emploi pas à pas / Step-by-step user guide :** [Français](MODE-EMPLOI.md) · [English](USER-GUIDE.md) · [Español](GUIA.md) · [Deutsch](ANLEITUNG.md) · [Nederlands](HANDLEIDING.md) · [中文](GUIDE-ZH.md) · [日本語](GUIDE-JA.md) · [العربية](GUIDE-AR.md) · [ไทย](GUIDE-TH.md)

**Langues / Languages :** Français · English · Español · Deutsch · Nederlands · 中文 · 日本語 · العربية · ไทย
(L'arabe s'affiche de gauche à droite : les consoles Windows ne gèrent pas l'écriture de droite à gauche.)

## Les modules

| # | Module | Effet |
|---|---|---|
| 1 | Performances optimales | Active le mode d'alimentation « Performances optimales » (ou « Hautes performances » si le PC ne le propose pas) |
| 2 | Mode Jeu | Windows donne la priorité au jeu lancé |
| 3 | Xbox Game Bar en sommeil | Plus d'enregistrement vidéo en arrière-plan, plus d'ouverture par la manette |
| 4 | Jeux en mode fenêtré | Moins de latence et VRR en fenêtré / plein écran fenêtré (DirectX 10-11) |
| 5 | Planification GPU (HAGS) | La carte graphique gère sa mémoire, requis pour la Frame Generation (DLSS 3 / FSR 3). **Administrateur requis**, actif après redémarrage |
| 6 | Visée brute | Coupe l'accélération de la souris (« Améliorer la précision du pointeur ») |
| 7 | Effets visuels au minimum | Réglage « Meilleures performances » |
| 8 | Explorateur sans pubs | Masque les pubs et suggestions OneDrive |
| 9 | Menus instantanés | Supprime le délai d'ouverture des menus |
| 10 | OneDrive hors du démarrage | Désactivé comme dans le Gestionnaire des tâches |

## Utilisation

1. Télécharger `JohnWishGamingOptimizer.ps1`.
2. Clic droit sur le fichier → **Exécuter avec PowerShell**.
   Pour le module HAGS, lancer PowerShell **en administrateur** (sinon ce module est simplement verrouillé).
3. Choisir sa langue avec **↑ ↓** puis **Entrée** (la langue de Windows est proposée d'office).
4. Le menu affiche les modules par groupe (Performance, Jeu, Windows) avec leur état : `● ACTIF`, `○ À ACTIVER`, `◇ ADMIN` (droits administrateur requis). Les modules pas encore actifs sont cochés d'office.
   - **↑ ↓** pour choisir un module (sa description s'affiche en bas) ;
   - **Espace** pour le cocher ou le décocher ;
   - `A` pour tout cocher, `N` pour tout décocher ;
   - `R` pour remettre les réglages d'origine (voir plus bas) ;
   - **Entrée** pour lancer, puis `O` pour confirmer ; `Q` ou Échap pour quitter sans rien changer.
   - Une touche passe l'animation d'intro.
5. Redémarrer le PC.

Tout appliquer sans menu, ou choisir la langue directement (`fr`, `en`, `es`, `de`, `nl`, `zh`, `ja`, `ar`, `th`) :

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Tout
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Langue en
```

## Revenir aux réglages d'origine

Les réglages restent appliqués après la fermeture du script et après un redémarrage. Avant toute modification, le script enregistre les anciennes valeurs dans `Documents\JohnWishOptimizer\`.

Pour tout remettre comme avant la **toute première** utilisation du script (même s'il a été lancé plusieurs fois) : relancer le script et appuyer sur **R** dans le menu, puis `O` pour confirmer. Ou, sans menu :

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Restaurer
```

(En administrateur si le module HAGS avait été appliqué.)

---

🇬🇧 A Windows 11 gaming optimizer with a cyberpunk terminal UI: animated intro (a cyberpunk portrait decoded from ASCII into pixels), BIOS-style boot sequence, language selection, then an arrow-key menu to pick your tweaks. Available in 9 languages; pick one directly with `-Language en` (`fr`, `en`, `es`, `de`, `nl`, `zh`, `ja`, `ar`, `th`).

**Modules:** Ultimate Performance power plan (High Performance fallback), Game Mode, Xbox Game Bar background recording off, optimizations for windowed games, hardware-accelerated GPU scheduling (HAGS, admin only), mouse acceleration off, visual effects set to "best performance", no OneDrive ads in File Explorer, instant menus, OneDrive disabled at startup.

**Usage:** right-click the file → **Run with PowerShell** (run PowerShell as administrator to unlock HAGS). In the menu, use **↑ ↓** to move, **Space** to toggle a module, `A` for all, `N` for none, `R` to restore the original settings, **Enter** then `O` to apply, `Q` or Esc to quit. Use `-All` to apply everything without the menu. Restart your PC afterwards.

**Undo:** settings persist after closing the script. Previous values are saved in `Documents\JohnWishOptimizer\` before anything changes. Press `R` in the menu (or use `-Restore`) to bring back the settings from before the very first run (as administrator if HAGS was applied).

## Licence / License

© 2025-2026 John Wish — **Tous droits réservés / All rights reserved.**

🇫🇷 Utilisation personnelle gratuite. Copie, modification, redistribution et vente interdites sans mon autorisation écrite. Pour partager le script, partagez le lien de ce dépôt. Détails : [LICENSE](LICENSE).

🇬🇧 Free for personal use. Copying, modifying, redistributing or selling is not allowed without my written permission. To share the script, share a link to this repository. Details: [LICENSE](LICENSE).
