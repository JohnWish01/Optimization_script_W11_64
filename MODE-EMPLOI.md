# Mode d'emploi — W11::OPTIMIZER

Ce guide explique pas à pas comment utiliser le script, même si vous n'avez jamais lancé de script PowerShell. Comptez environ 5 minutes.

*[Français](MODE-EMPLOI.md) · [English](USER-GUIDE.md) · [Español](GUIA.md) · [Deutsch](ANLEITUNG.md) · [Nederlands](HANDLEIDING.md) · [中文](GUIDE-ZH.md) · [日本語](GUIDE-JA.md) · [العربية](GUIDE-AR.md) · [ไทย](GUIDE-TH.md)*

---

## 1. Ce que fait le script (et ce qu'il ne fait pas)

**Il fait :** il change 10 réglages de Windows 11 pour que les jeux tournent mieux (mode d'alimentation, Mode Jeu, Xbox Game Bar, souris, effets visuels…). Ce sont les mêmes réglages que vous pourriez changer à la main dans les Paramètres de Windows. Vous choisissez lesquels dans un menu.

**Il ne fait pas :**
- il n'installe rien, ne télécharge rien et n'a pas besoin d'Internet ;
- il ne supprime aucun fichier et ne touche ni à vos jeux, ni à vos pilotes ;
- il ne tourne pas en arrière-plan : une fois fermé, il n'y a plus rien qui fonctionne.

**Bon à savoir :** avant chaque modification, il note les anciennes valeurs. Vous pouvez donc **tout remettre comme avant** à tout moment (voir l'étape 6).

---

## 2. Télécharger le script

1. Sur la page GitHub du projet, cliquez sur le fichier **`JohnWishGamingOptimizer.ps1`**.
2. Cliquez sur le bouton **Download raw file** (l'icône avec une flèche vers le bas, en haut à droite du code).
3. Le fichier arrive dans votre dossier **Téléchargements**. Vous pouvez le laisser là ou le déplacer où vous voulez.

> Autre possibilité : bouton vert **Code** → **Download ZIP**, puis clic droit sur le ZIP → **Extraire tout**.

### Débloquer le fichier (une seule fois)

Windows bloque souvent les scripts venus d'Internet. Pour éviter les messages d'erreur :

1. Clic droit sur `JohnWishGamingOptimizer.ps1` → **Propriétés**.
2. En bas de l'onglet **Général**, cochez **Débloquer** (si la case n'existe pas, c'est que le fichier n'est pas bloqué).
3. Cliquez sur **OK**.

---

## 3. Lancer le script

### Méthode simple

1. Clic droit sur `JohnWishGamingOptimizer.ps1`.
2. Choisissez **Exécuter avec PowerShell**.
   Sur Windows 11, il faut parfois d'abord cliquer sur **Afficher d'autres options** pour voir cette ligne.

> ⚠️ **Ne double-cliquez pas** sur le fichier : il s'ouvrirait dans le Bloc-notes au lieu de se lancer.

### Si la fenêtre se ferme aussitôt ou affiche « l'exécution de scripts est désactivée »

1. Ouvrez le dossier qui contient le script.
2. Faites un clic droit dans un espace vide du dossier → **Ouvrir dans le Terminal**.
3. Copiez cette ligne, collez-la dans la fenêtre (clic droit pour coller) et appuyez sur **Entrée** :

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1
```

Cette commande autorise **uniquement ce lancement** du script : elle ne change pas la sécurité de votre PC.

### Pour débloquer le module « Planification GPU » (administrateur)

Un des modules a besoin des droits administrateur. Sans eux, il est simplement verrouillé (`◇ ADMIN`) et tout le reste fonctionne.

1. Clic droit sur le bouton **Démarrer** → **Terminal (administrateur)** → **Oui**.
2. Tapez `cd` suivi d'un espace, puis glissez le dossier du script dans la fenêtre, et appuyez sur **Entrée**.
3. Collez la commande ci-dessus et appuyez sur **Entrée**.

---

## 4. Utiliser le menu

1. **L'intro** s'affiche (animation, logo, démarrage façon BIOS). Appuyez sur n'importe quelle touche pour la passer.
2. **Choisissez votre langue** avec les flèches **↑ ↓**, puis **Entrée**.
3. **Le menu** affiche les 10 modules et leur état :

| État | Signification |
|---|---|
| `● ACTIF` | Le réglage est déjà en place |
| `○ À ACTIVER` | Le réglage n'est pas encore en place |
| `◇ ADMIN` | Il faut lancer le script en administrateur (voir plus haut) |
| `– N/A` | Ne concerne pas ce PC (par exemple OneDrive ne démarre pas avec Windows) |

Les modules pas encore actifs sont **cochés d'office**. La description du module sélectionné s'affiche en bas du cadre.

| Touche | Action |
|---|---|
| **↑ ↓** | Se déplacer dans la liste |
| **Espace** | Cocher / décocher le module |
| **A** | Tout cocher |
| **N** | Tout décocher |
| **Entrée** | Lancer les modules cochés (puis **O** pour confirmer) |
| **R** | Remettre les réglages d'origine (voir l'étape 6) |
| **Q** ou **Échap** | Quitter **sans rien changer** |

4. Après confirmation, chaque module s'affiche avec `[OK]` (réussi) ou `[X]` (problème, avec l'explication).

---

## 5. Après le script

- **Redémarrez votre PC** : certains réglages (Planification GPU, une partie des effets visuels) ne prennent effet qu'après un redémarrage.
- **Les réglages restent** après la fermeture du script et après les redémarrages. Vous n'avez pas besoin de le relancer à chaque démarrage.
- Une grosse mise à jour de Windows peut parfois remettre certains réglages par défaut : relancez simplement le script, il vous montrera ce qui n'est plus `● ACTIF`.

---

## 6. Tout remettre comme avant

1. Relancez le script (comme à l'étape 3).
2. Dans le menu, appuyez sur **R**, puis sur **O** pour confirmer.
3. Redémarrez le PC.

Le script remet les réglages tels qu'ils étaient **avant sa toute première utilisation**, même si vous l'avez lancé plusieurs fois.

Si le module « Planification GPU » avait été appliqué, lancez le script **en administrateur** pour la remise à l'origine.

> Les anciennes valeurs sont enregistrées dans `Documents\JohnWishOptimizer\`. **Ne supprimez pas ce dossier** si vous voulez pouvoir revenir en arrière.

---

## 7. Questions fréquentes

**Le fichier s'ouvre dans le Bloc-notes.**
Fermez-le et utilisez le clic droit → **Exécuter avec PowerShell** (étape 3).

**Windows ou mon antivirus affiche un avertissement.**
Le script n'est pas signé numériquement, comme la plupart des scripts gratuits. C'est un simple fichier texte : vous pouvez l'ouvrir dans le Bloc-notes pour lire exactement ce qu'il fait avant de le lancer.

**Les couleurs ou les symboles s'affichent mal (des `?` ou des carrés).**
Utilisez le **Terminal Windows** (installé d'office sur Windows 11) plutôt que l'ancienne fenêtre PowerShell : méthode « Ouvrir dans le Terminal » de l'étape 3.

**L'image de l'intro est petite ou coupée.**
Agrandissez la fenêtre avant de lancer le script : l'image s'adapte et devient plus nette. Une touche permet de passer l'intro.

**Est-ce que ça peut poser problème avec l'anti-triche des jeux ?**
Le script ne modifie que des réglages de Windows. Il ne touche ni aux fichiers des jeux ni à leur mémoire, et il ne tourne plus une fois fermé.

**Comment désinstaller le script ?**
Il n'y a rien à désinstaller. Si vous voulez annuler ses effets, faites l'étape 6, puis supprimez le fichier.

**Je veux tout appliquer sans passer par le menu.**

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Tout
```

**Je veux choisir la langue directement** (`fr`, `en`, `es`, `de`, `nl`, `zh`, `ja`, `ar`, `th`) :

```powershell
powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Langue fr
```

---

*© 2025-2026 John Wish — Tous droits réservés. Utilisation personnelle gratuite ; copie, modification, redistribution et vente interdites sans autorisation. Voir [LICENSE](LICENSE).*
