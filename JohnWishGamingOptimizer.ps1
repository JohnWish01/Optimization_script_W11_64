<#
    W11::OPTIMIZER - Windows 11 Gaming Optimizer
    github.com/JohnWish01

    Copyright (c) 2025-2026 John Wish. Tous droits réservés / All rights reserved.
    Utilisation personnelle gratuite. Copie, modification, redistribution et vente
    interdites sans autorisation écrite de l'auteur. Voir le fichier LICENSE.
    Free for personal use. Copying, modifying, redistributing or selling is not
    allowed without the author's written permission. See the LICENSE file.
    Source officielle / Official source : https://github.com/JohnWish01/Optimization_script_W11_64
    ----------------------------------------
    Lancer / Run :         clic droit > Exécuter avec PowerShell   (menu interactif)
    Tout d'un coup / All : .\JohnWishGamingOptimizer.ps1 -Tout      (alias -All)
    Réglages d'origine :   touche R dans le menu, ou .\JohnWishGamingOptimizer.ps1 -Restaurer (alias -Restore)
    Langue / Language :    -Langue fr|en|es|de|nl|zh|ja|ar|th       (alias -Language)
    (depuis une console : powershell -ExecutionPolicy Bypass -File .\JohnWishGamingOptimizer.ps1 -Restaurer)

    Les droits administrateur ne sont nécessaires que pour la planification GPU (HAGS).
    Avant chaque modification, l'ancienne valeur est enregistrée dans
    Documents\JohnWishOptimizer\sauvegarde-<date>.json
#>
param(
    [Alias('All')][switch]$Tout,
    [Alias('Restore')][switch]$Restaurer,
    [Alias('Language')][string]$Langue
)

$ErrorActionPreference = 'Stop'
$Version = 'v2.0'
$DossierSauvegarde = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'JohnWishOptimizer'

# GUID fixe de notre copie du mode « Performances optimales » : on ne la crée qu'une fois.
$GuidUltimateSource = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
$GuidUltimateCopie  = '4a6e3b1c-7d2f-4e8a-9c15-6b0d2f8e1a73'
$GuidHautePerf      = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
# Nom de ce mode selon la langue de Windows
$NomsUltimate       = 'Performances optimales|Ultimate Performance|Máximo rendimiento|Ultimative Leistung|Ultieme prestaties|卓越性能|究極のパフォーマンス|الأداء الأقصى|ประสิทธิภาพสูงสุด'

$script:Anciennes = @()
$script:Erreurs = 0
$script:EstAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

# Vraie console (et pas une sortie redirigée vers un fichier) ?
$script:Interactif = $false
try { $script:Interactif = -not [Console]::IsOutputRedirected -and -not [Console]::IsInputRedirected } catch { }
# Couleurs néon (codes ANSI) seulement si la console les gère
$script:VT = $script:Interactif -and $Host.UI.SupportsVirtualTerminal

# Windows PowerShell 5.1 écrit en page de code 850 : les symboles (◆ ▶ ● ○, katakana
# de la pluie, « œ », chinois…) deviendraient des « ? ». On passe la console en UTF-8
# le temps du script, puis on remet son réglage d'origine.
$script:EncodageOrigine = $null
if ($script:Interactif) {
    try {
        $script:EncodageOrigine = [Console]::OutputEncoding
        [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
    } catch { }
}
function Restore-Console {
    if ($script:EncodageOrigine) {
        try { [Console]::OutputEncoding = $script:EncodageOrigine } catch { }
    }
}

# ===========================================================================
#  LANGUES
#  Une section [code] par langue, une ligne « clé=texte » par phrase.
#  {0}, {1}… sont remplacés par des valeurs (nombre de modules, chemin…).
# ===========================================================================

$OrdreLangues = @('fr', 'en', 'es', 'de', 'nl', 'zh', 'ja', 'ar', 'th')

$TextesBruts = @'
[fr]
nom=Français
lang.titre=Choisis ta langue
lang.aide=↑↓ choisir · Entrée valider
intro=> initialisation des modules... OK
g.perf=PERFORMANCE
g.jeu=JEU
g.win=WINDOWS
e.actif=● ACTIF
e.todo=○ À ACTIVER
e.admin=◇ ADMIN
e.na=– N/A
compteur={0}/{1} ACTIFS · {2} À INJECTER
aide=↑↓ choisir · Espace cocher · A tout · N rien · R origine · Entrée lancer · Q quitter
v.admin=Verrouillé : relance le script en administrateur pour l'activer.
v.na=Non concerné : OneDrive ne démarre pas avec Windows sur ce PC.
confirm=Injecter {0} module(s) dans le système ? [O]ui / [N]on
confirm.r=Remettre les réglages d'origine (ceux d'avant le script) ? [O]ui / [N]on
aucun=Aucun module coché. Coche-en avec Espace.
quitte=>> Déconnexion. Aucune modification.
connexion=> connexion au noyau... OK
cible=> cible : {0}
inj=injection > {0}
ignore={0} ignoré : {1}
ign.admin=nécessite les droits administrateur
ign.na=non concerné sur ce PC
sauve=Anciens réglages sauvegardés : {0}
sauve.err=Sauvegarde des anciens réglages : {0}
fin=SYSTÈME OPTIMISÉ. {0} module(s) en ligne. Bon jeu.
fin.err=INJECTION TERMINÉE AVEC {0} ERREUR(S) (voir ci-dessus).
redem=Redémarre ton PC pour appliquer tous les réglages.
annul=Pour revenir aux réglages d'origine : relance le script et appuie sur R.
attente=Appuie sur Entrée pour fermer
alim.deja=Déjà actif : mode d'alimentation inchangé
alim.hp=Mode indisponible sur ce PC : « Hautes performances » activé à la place
alim.aucun=Aucun mode haute performance sur ce PC : mode d'alimentation inchangé
alim.err=powercfg /setactive a échoué
hags.info=Actif après redémarrage, si la carte graphique et son pilote le gèrent
r.aucune=Aucune sauvegarde trouvée dans {0}
r.de=Réglages d'origine retrouvés dans {0} sauvegarde(s)
r.admin={0} : relance la restauration en administrateur
r.ok=Registre restauré
r.souris=Réglages de la souris rechargés
r.souris.err=Souris : {0}
r.alim=Ancien mode d'alimentation réactivé
r.alim.err=Impossible de réactiver l'ancien mode d'alimentation
r.fin=ROLLBACK COMPLET. Système revenu à son état d'origine.
r.fin.err=ROLLBACK TERMINÉ AVEC {0} ERREUR(S).
r.deco=Déconnecte-toi ou redémarre pour que tout soit pris en compte.
m.alim.n=Mode d'alimentation optimal
m.alim.d=Le processeur reste à pleine vitesse, sans mise en veille de ses cœurs.
m.hags.n=Planification GPU (HAGS)
m.hags.d=La carte graphique gère sa mémoire. Requis pour la Frame Generation (DLSS 3 / FSR 3).
m.jeu.n=Mode Jeu
m.jeu.d=Windows donne la priorité au jeu lancé.
m.bar.n=Game Bar en sommeil
m.bar.d=Plus d'enregistrement vidéo en arrière-plan, plus d'ouverture par la manette.
m.fen.n=Jeux en mode fenêtré
m.fen.d=Moins de latence et VRR en fenêtré / plein écran fenêtré (DirectX 10-11).
m.sou.n=Visée brute (souris)
m.sou.d=Coupe l'accélération : la visée ne dépend plus de la vitesse du geste.
m.vis.n=Effets visuels au minimum
m.vis.d=Réglage « Meilleures performances » : animations et transparences coupées.
m.exp.n=Explorateur sans pubs
m.exp.d=Masque les suggestions et pubs OneDrive dans l'Explorateur.
m.men.n=Menus instantanés
m.men.d=Supprime le délai d'ouverture des menus.
m.one.n=OneDrive hors du démarrage
m.one.d=OneDrive ne se lance plus avec Windows (comme dans le Gestionnaire des tâches).

[en]
nom=English
lang.titre=Choose your language
lang.aide=↑↓ select · Enter confirm
intro=> initializing modules... OK
g.perf=PERFORMANCE
g.jeu=GAMING
g.win=WINDOWS
e.actif=● ACTIVE
e.todo=○ TO ENABLE
e.admin=◇ ADMIN
e.na=– N/A
compteur={0}/{1} ACTIVE · {2} TO INJECT
aide=↑↓ select · Space toggle · A all · N none · R restore · Enter run · Q quit
v.admin=Locked: run the script as administrator to enable it.
v.na=Not applicable: OneDrive does not start with Windows on this PC.
confirm=Inject {0} module(s) into the system? [Y]es / [N]o
confirm.r=Restore the original settings (from before the script)? [Y]es / [N]o
aucun=No module selected. Select some with Space.
quitte=>> Disconnected. No changes made.
connexion=> connecting to kernel... OK
cible=> target: {0}
inj=injecting > {0}
ignore={0} skipped: {1}
ign.admin=requires administrator rights
ign.na=not applicable on this PC
sauve=Previous settings saved: {0}
sauve.err=Saving previous settings: {0}
fin=SYSTEM OPTIMIZED. {0} module(s) online. Have fun.
fin.err=INJECTION FINISHED WITH {0} ERROR(S) (see above).
redem=Restart your PC to apply all settings.
annul=To go back to the original settings: run the script again and press R.
attente=Press Enter to close
alim.deja=Already active: power plan unchanged
alim.hp=Plan not available on this PC: "High performance" enabled instead
alim.aucun=No high performance plan on this PC: power plan unchanged
alim.err=powercfg /setactive failed
hags.info=Active after restart, if your graphics card and driver support it
r.aucune=No backup found in {0}
r.de=Original settings found in {0} backup(s)
r.admin={0}: run the restore as administrator
r.ok=Registry restored
r.souris=Mouse settings reloaded
r.souris.err=Mouse: {0}
r.alim=Previous power plan re-enabled
r.alim.err=Could not re-enable the previous power plan
r.fin=ROLLBACK COMPLETE. System back to its original state.
r.fin.err=ROLLBACK FINISHED WITH {0} ERROR(S).
r.deco=Sign out or restart for everything to take effect.
m.alim.n=Ultimate power plan
m.alim.d=The CPU stays at full speed, with no core parking.
m.hags.n=GPU scheduling (HAGS)
m.hags.d=The graphics card manages its own memory. Required for Frame Generation (DLSS 3 / FSR 3).
m.jeu.n=Game Mode
m.jeu.d=Windows gives priority to the running game.
m.bar.n=Game Bar asleep
m.bar.d=No more background video recording, no more opening from the controller.
m.fen.n=Windowed game optimizations
m.fen.d=Lower latency and VRR in windowed / borderless games (DirectX 10-11).
m.sou.n=Raw aim (mouse)
m.sou.d=Turns off acceleration: aiming no longer depends on how fast you move.
m.vis.n=Minimal visual effects
m.vis.d="Best performance" setting: animations and transparency off.
m.exp.n=Ad-free File Explorer
m.exp.d=Hides OneDrive suggestions and ads in File Explorer.
m.men.n=Instant menus
m.men.d=Removes the delay before menus open.
m.one.n=OneDrive off at startup
m.one.d=OneDrive no longer starts with Windows (like in Task Manager).

[es]
nom=Español
lang.titre=Elige tu idioma
lang.aide=↑↓ elegir · Intro confirmar
intro=> inicializando módulos... OK
g.perf=RENDIMIENTO
g.jeu=JUEGO
g.win=WINDOWS
e.actif=● ACTIVO
e.todo=○ POR ACTIVAR
e.admin=◇ ADMIN
e.na=– N/D
compteur={0}/{1} ACTIVOS · {2} POR INYECTAR
aide=↑↓ elegir · Espacio marcar · A todo · N nada · R original · Intro iniciar · Q salir
v.admin=Bloqueado: ejecuta el script como administrador para activarlo.
v.na=No aplica: OneDrive no se inicia con Windows en este PC.
confirm=¿Inyectar {0} módulo(s) en el sistema? [S]í / [N]o
confirm.r=¿Restaurar los ajustes originales (de antes del script)? [S]í / [N]o
aucun=Ningún módulo marcado. Márcalos con Espacio.
quitte=>> Desconectado. Sin cambios.
connexion=> conectando con el núcleo... OK
cible=> objetivo: {0}
inj=inyectando > {0}
ignore={0} omitido: {1}
ign.admin=requiere permisos de administrador
ign.na=no aplica en este PC
sauve=Ajustes anteriores guardados: {0}
sauve.err=Guardado de los ajustes anteriores: {0}
fin=SISTEMA OPTIMIZADO. {0} módulo(s) en línea. ¡A jugar!
fin.err=INYECCIÓN TERMINADA CON {0} ERROR(ES) (ver arriba).
redem=Reinicia tu PC para aplicar todos los ajustes.
annul=Para volver a los ajustes originales: vuelve a ejecutar el script y pulsa R.
attente=Pulsa Intro para cerrar
alim.deja=Ya activo: plan de energía sin cambios
alim.hp=Plan no disponible en este PC: se activó «Alto rendimiento»
alim.aucun=No hay plan de alto rendimiento en este PC: sin cambios
alim.err=powercfg /setactive falló
hags.info=Activo tras reiniciar, si la tarjeta gráfica y su controlador lo admiten
r.aucune=No se encontró ninguna copia en {0}
r.de=Ajustes originales encontrados en {0} copia(s)
r.admin={0}: ejecuta la restauración como administrador
r.ok=Registro restaurado
r.souris=Ajustes del ratón recargados
r.souris.err=Ratón: {0}
r.alim=Plan de energía anterior reactivado
r.alim.err=No se pudo reactivar el plan de energía anterior
r.fin=ROLLBACK COMPLETO. Sistema devuelto a su estado original.
r.fin.err=ROLLBACK TERMINADO CON {0} ERROR(ES).
r.deco=Cierra sesión o reinicia para que todo surta efecto.
m.alim.n=Plan de energía máximo
m.alim.d=El procesador se mantiene a máxima velocidad, sin suspender núcleos.
m.hags.n=Programación de GPU (HAGS)
m.hags.d=La tarjeta gráfica gestiona su propia memoria. Necesario para Frame Generation (DLSS 3 / FSR 3).
m.jeu.n=Modo de juego
m.jeu.d=Windows da prioridad al juego en ejecución.
m.bar.n=Game Bar en reposo
m.bar.d=Sin grabación de vídeo en segundo plano ni apertura desde el mando.
m.fen.n=Juegos en modo ventana
m.fen.d=Menos latencia y VRR en ventana / ventana sin bordes (DirectX 10-11).
m.sou.n=Puntería pura (ratón)
m.sou.d=Desactiva la aceleración: la puntería ya no depende de la velocidad del gesto.
m.vis.n=Efectos visuales mínimos
m.vis.d=Ajuste «Mejor rendimiento»: animaciones y transparencias desactivadas.
m.exp.n=Explorador sin anuncios
m.exp.d=Oculta las sugerencias y anuncios de OneDrive en el Explorador.
m.men.n=Menús instantáneos
m.men.d=Elimina el retraso al abrir los menús.
m.one.n=OneDrive fuera del inicio
m.one.d=OneDrive ya no se inicia con Windows (como en el Administrador de tareas).

[de]
nom=Deutsch
lang.titre=Wähle deine Sprache
lang.aide=↑↓ wählen · Enter bestätigen
intro=> Module werden initialisiert... OK
g.perf=LEISTUNG
g.jeu=SPIEL
g.win=WINDOWS
e.actif=● AKTIV
e.todo=○ AKTIVIEREN
e.admin=◇ ADMIN
e.na=– N/V
compteur={0}/{1} AKTIV · {2} ZU INJIZIEREN
aide=↑↓ wählen · Leertaste an/aus · A alle · N keine · R Original · Enter starten · Q Ende
v.admin=Gesperrt: Starte das Skript als Administrator, um es zu aktivieren.
v.na=Nicht zutreffend: OneDrive startet auf diesem PC nicht mit Windows.
confirm={0} Modul(e) ins System injizieren? [J]a / [N]ein
confirm.r=Originaleinstellungen (vor dem Skript) wiederherstellen? [J]a / [N]ein
aucun=Kein Modul ausgewählt. Wähle welche mit der Leertaste.
quitte=>> Verbindung getrennt. Keine Änderungen.
connexion=> Verbindung zum Kernel... OK
cible=> Ziel: {0}
inj=Injektion > {0}
ignore={0} übersprungen: {1}
ign.admin=erfordert Administratorrechte
ign.na=auf diesem PC nicht zutreffend
sauve=Vorherige Einstellungen gesichert: {0}
sauve.err=Sicherung der vorherigen Einstellungen: {0}
fin=SYSTEM OPTIMIERT. {0} Modul(e) online. Viel Spaß.
fin.err=INJEKTION MIT {0} FEHLER(N) BEENDET (siehe oben).
redem=Starte deinen PC neu, um alle Einstellungen anzuwenden.
annul=Zurück zu den Originaleinstellungen: Skript erneut starten und R drücken.
attente=Enter drücken zum Schließen
alim.deja=Bereits aktiv: Energieplan unverändert
alim.hp=Plan auf diesem PC nicht verfügbar: „Höchstleistung“ stattdessen aktiviert
alim.aucun=Kein Hochleistungsplan auf diesem PC: Energieplan unverändert
alim.err=powercfg /setactive fehlgeschlagen
hags.info=Aktiv nach Neustart, wenn Grafikkarte und Treiber es unterstützen
r.aucune=Keine Sicherung gefunden in {0}
r.de=Originaleinstellungen in {0} Sicherung(en) gefunden
r.admin={0}: Wiederherstellung als Administrator starten
r.ok=Registrierung wiederhergestellt
r.souris=Mauseinstellungen neu geladen
r.souris.err=Maus: {0}
r.alim=Vorheriger Energieplan wieder aktiviert
r.alim.err=Vorheriger Energieplan konnte nicht aktiviert werden
r.fin=ROLLBACK ABGESCHLOSSEN. System im Originalzustand.
r.fin.err=ROLLBACK MIT {0} FEHLER(N) BEENDET.
r.deco=Melde dich ab oder starte neu, damit alles wirksam wird.
m.alim.n=Ultimative Leistung
m.alim.d=Der Prozessor bleibt auf voller Leistung, ohne Kern-Parking.
m.hags.n=GPU-Planung (HAGS)
m.hags.d=Die Grafikkarte verwaltet ihren Speicher selbst. Nötig für Frame Generation (DLSS 3 / FSR 3).
m.jeu.n=Spielmodus
m.jeu.d=Windows bevorzugt das laufende Spiel.
m.bar.n=Game Bar im Ruhezustand
m.bar.d=Keine Videoaufnahme im Hintergrund, kein Öffnen per Controller.
m.fen.n=Spiele im Fenstermodus
m.fen.d=Weniger Latenz und VRR im Fenster- / randlosen Modus (DirectX 10-11).
m.sou.n=Rohe Zielerfassung (Maus)
m.sou.d=Schaltet die Beschleunigung ab: Zielen hängt nicht mehr vom Tempo ab.
m.vis.n=Minimale visuelle Effekte
m.vis.d=Einstellung „Optimale Leistung“: Animationen und Transparenz aus.
m.exp.n=Explorer ohne Werbung
m.exp.d=Blendet OneDrive-Vorschläge und Werbung im Explorer aus.
m.men.n=Sofortige Menüs
m.men.d=Entfernt die Verzögerung beim Öffnen von Menüs.
m.one.n=OneDrive nicht im Autostart
m.one.d=OneDrive startet nicht mehr mit Windows (wie im Task-Manager).

[nl]
nom=Nederlands
lang.titre=Kies je taal
lang.aide=↑↓ kiezen · Enter bevestigen
intro=> modules initialiseren... OK
g.perf=PRESTATIES
g.jeu=GAMEN
g.win=WINDOWS
e.actif=● ACTIEF
e.todo=○ ACTIVEREN
e.admin=◇ ADMIN
e.na=– N.v.t.
compteur={0}/{1} ACTIEF · {2} TE INJECTEREN
aide=↑↓ kiezen · Spatie aan/uit · A alles · N niets · R origineel · Enter starten · Q stoppen
v.admin=Vergrendeld: start het script als administrator om dit te activeren.
v.na=Niet van toepassing: OneDrive start op deze pc niet met Windows.
confirm={0} module(s) in het systeem injecteren? [J]a / [N]ee
confirm.r=Oorspronkelijke instellingen (van vóór het script) terugzetten? [J]a / [N]ee
aucun=Geen module aangevinkt. Vink aan met Spatie.
quitte=>> Verbinding verbroken. Niets gewijzigd.
connexion=> verbinden met de kernel... OK
cible=> doel: {0}
inj=injectie > {0}
ignore={0} overgeslagen: {1}
ign.admin=vereist administratorrechten
ign.na=niet van toepassing op deze pc
sauve=Vorige instellingen opgeslagen: {0}
sauve.err=Opslaan van vorige instellingen: {0}
fin=SYSTEEM GEOPTIMALISEERD. {0} module(s) online. Veel plezier.
fin.err=INJECTIE KLAAR MET {0} FOUT(EN) (zie hierboven).
redem=Start je pc opnieuw op om alle instellingen toe te passen.
annul=Terug naar de oorspronkelijke instellingen: start het script opnieuw en druk op R.
attente=Druk op Enter om te sluiten
alim.deja=Al actief: energiebeheer ongewijzigd
alim.hp=Schema niet beschikbaar op deze pc: 'Hoge prestaties' geactiveerd
alim.aucun=Geen hogeprestatieschema op deze pc: energiebeheer ongewijzigd
alim.err=powercfg /setactive mislukt
hags.info=Actief na herstart, als de videokaart en het stuurprogramma het ondersteunen
r.aucune=Geen back-up gevonden in {0}
r.de=Oorspronkelijke instellingen gevonden in {0} back-up(s)
r.admin={0}: start het herstel als administrator
r.ok=Register hersteld
r.souris=Muisinstellingen opnieuw geladen
r.souris.err=Muis: {0}
r.alim=Vorig energiebeheerschema opnieuw actief
r.alim.err=Kon het vorige energiebeheerschema niet activeren
r.fin=ROLLBACK VOLTOOID. Systeem terug in originele staat.
r.fin.err=ROLLBACK KLAAR MET {0} FOUT(EN).
r.deco=Meld je af of start opnieuw zodat alles wordt toegepast.
m.alim.n=Ultiem energiebeheer
m.alim.d=De processor blijft op volle snelheid, zonder kernen te parkeren.
m.hags.n=GPU-planning (HAGS)
m.hags.d=De videokaart beheert zelf haar geheugen. Nodig voor Frame Generation (DLSS 3 / FSR 3).
m.jeu.n=Spelmodus
m.jeu.d=Windows geeft voorrang aan het spel dat draait.
m.bar.n=Game Bar in slaapstand
m.bar.d=Geen video-opname op de achtergrond, niet meer openen met de controller.
m.fen.n=Games in venstermodus
m.fen.d=Minder vertraging en VRR in venster / randloos venster (DirectX 10-11).
m.sou.n=Puur richten (muis)
m.sou.d=Zet versnelling uit: richten hangt niet meer af van hoe snel je beweegt.
m.vis.n=Minimale visuele effecten
m.vis.d=Instelling 'Beste prestaties': animaties en transparantie uit.
m.exp.n=Verkenner zonder reclame
m.exp.d=Verbergt OneDrive-suggesties en reclame in de Verkenner.
m.men.n=Directe menu's
m.men.d=Verwijdert de vertraging bij het openen van menu's.
m.one.n=OneDrive niet bij opstarten
m.one.d=OneDrive start niet meer met Windows (zoals in Taakbeheer).

[zh]
nom=中文
lang.titre=选择语言
lang.aide=↑↓ 选择 · Enter 确认
intro=> 正在初始化模块... OK
g.perf=性能
g.jeu=游戏
g.win=WINDOWS
e.actif=● 已启用
e.todo=○ 待启用
e.admin=◇ 需管理员
e.na=– 不适用
compteur={0}/{1} 已启用 · {2} 待注入
aide=↑↓ 选择 · 空格 勾选 · A 全选 · N 全不选 · R 还原 · Enter 开始 · Q 退出
v.admin=已锁定：请以管理员身份运行脚本以启用此项。
v.na=不适用：此电脑上 OneDrive 不会随 Windows 启动。
confirm=将 {0} 个模块注入系统？ [Y] 是 / [N] 否
confirm.r=恢复原始设置（使用脚本之前的设置）？ [Y] 是 / [N] 否
aucun=未勾选任何模块。请用空格键勾选。
quitte=>> 已断开连接。未做任何更改。
connexion=> 正在连接内核... OK
cible=> 目标：{0}
inj=正在注入 > {0}
ignore={0} 已跳过：{1}
ign.admin=需要管理员权限
ign.na=此电脑不适用
sauve=原设置已备份：{0}
sauve.err=备份原设置：{0}
fin=系统已优化。{0} 个模块已上线。祝游戏愉快。
fin.err=注入完成，但有 {0} 个错误（见上文）。
redem=重启电脑以应用所有设置。
annul=如需恢复原始设置：重新运行脚本并按 R。
attente=按 Enter 关闭
alim.deja=已启用：电源计划未更改
alim.hp=此电脑不支持该计划：已改为启用“高性能”
alim.aucun=此电脑没有高性能计划：电源计划未更改
alim.err=powercfg /setactive 失败
hags.info=重启后生效（需显卡及驱动支持）
r.aucune=在 {0} 中未找到备份
r.de=在 {0} 个备份中找到原始设置
r.admin={0}：请以管理员身份运行恢复
r.ok=注册表已恢复
r.souris=鼠标设置已重新加载
r.souris.err=鼠标：{0}
r.alim=已重新启用原电源计划
r.alim.err=无法重新启用原电源计划
r.fin=回滚完成。系统已恢复原状。
r.fin.err=回滚完成，但有 {0} 个错误。
r.deco=注销或重启后所有更改才会完全生效。
m.alim.n=卓越性能电源计划
m.alim.d=处理器保持全速运行，不会让核心进入休眠。
m.hags.n=GPU 硬件加速计划 (HAGS)
m.hags.d=由显卡自行管理显存。帧生成 (DLSS 3 / FSR 3) 需要此功能。
m.jeu.n=游戏模式
m.jeu.d=Windows 优先处理正在运行的游戏。
m.bar.n=Game Bar 休眠
m.bar.d=不再后台录制视频，也不会被手柄按键打开。
m.fen.n=窗口化游戏优化
m.fen.d=窗口 / 无边框模式下延迟更低并支持 VRR (DirectX 10-11)。
m.sou.n=原始瞄准 (鼠标)
m.sou.d=关闭鼠标加速：瞄准不再受移动速度影响。
m.vis.n=最少视觉效果
m.vis.d=“调整为最佳性能”：关闭动画和透明效果。
m.exp.n=无广告资源管理器
m.exp.d=隐藏文件资源管理器中的 OneDrive 推荐和广告。
m.men.n=即时菜单
m.men.d=去除菜单打开前的延迟。
m.one.n=OneDrive 不再开机启动
m.one.d=OneDrive 不再随 Windows 启动（与任务管理器中的设置相同）。

[ja]
nom=日本語
lang.titre=言語を選択
lang.aide=↑↓ 選択 · Enter 決定
intro=> モジュールを初期化中... OK
g.perf=パフォーマンス
g.jeu=ゲーム
g.win=WINDOWS
e.actif=● 有効
e.todo=○ 未適用
e.admin=◇ 管理者
e.na=– 対象外
compteur={0}/{1} 有効 · {2} 件を適用予定
aide=↑↓ 選択 · Space 切替 · A 全選択 · N 全解除 · R 復元 · Enter 実行 · Q 終了
v.admin=ロック中：有効にするには管理者としてスクリプトを実行してください。
v.na=対象外：この PC では OneDrive は Windows と一緒に起動しません。
confirm={0} 個のモジュールをシステムに適用しますか？ [Y] はい / [N] いいえ
confirm.r=元の設定（スクリプト使用前）に戻しますか？ [Y] はい / [N] いいえ
aucun=モジュールが選択されていません。Space で選択してください。
quitte=>> 切断しました。変更はありません。
connexion=> カーネルに接続中... OK
cible=> 対象：{0}
inj=適用中 > {0}
ignore={0} をスキップ：{1}
ign.admin=管理者権限が必要です
ign.na=この PC では対象外です
sauve=以前の設定を保存しました：{0}
sauve.err=以前の設定の保存：{0}
fin=システム最適化完了。{0} 個のモジュールがオンライン。楽しんで！
fin.err=適用完了（エラー {0} 件、上記参照）。
redem=すべての設定を反映するには PC を再起動してください。
annul=元の設定に戻すには：スクリプトを再実行して R を押します。
attente=Enter キーで閉じます
alim.deja=すでに有効：電源プランは変更しません
alim.hp=この PC ではこのプランを使えません：代わりに「高パフォーマンス」を有効化
alim.aucun=この PC に高パフォーマンスプランはありません：変更なし
alim.err=powercfg /setactive に失敗しました
hags.info=再起動後に有効（グラフィックカードとドライバーの対応が必要）
r.aucune={0} にバックアップが見つかりません
r.de={0} 個のバックアップから元の設定を取得しました
r.admin={0}：管理者として復元を実行してください
r.ok=レジストリを復元しました
r.souris=マウス設定を再読み込みしました
r.souris.err=マウス：{0}
r.alim=以前の電源プランを再有効化しました
r.alim.err=以前の電源プランを再有効化できませんでした
r.fin=ロールバック完了。システムは元の状態に戻りました。
r.fin.err=ロールバック完了（エラー {0} 件）。
r.deco=すべてを反映するにはサインアウトまたは再起動してください。
m.alim.n=究極のパフォーマンス電源プラン
m.alim.d=CPU を常にフル速度で動作させ、コアを休止させません。
m.hags.n=GPU スケジューリング (HAGS)
m.hags.d=グラフィックカードが自身のメモリを管理します。フレーム生成 (DLSS 3 / FSR 3) に必要です。
m.jeu.n=ゲームモード
m.jeu.d=Windows が実行中のゲームを優先します。
m.bar.n=Game Bar をスリープ
m.bar.d=バックグラウンド録画を止め、コントローラーで開かないようにします。
m.fen.n=ウィンドウゲームの最適化
m.fen.d=ウィンドウ / ボーダーレスで遅延を減らし VRR に対応 (DirectX 10-11)。
m.sou.n=ローエイム (マウス)
m.sou.d=加速を無効化：エイムが動かす速さに左右されなくなります。
m.vis.n=視覚効果を最小限に
m.vis.d=「パフォーマンスを優先」設定：アニメーションと透明効果をオフ。
m.exp.n=広告なしのエクスプローラー
m.exp.d=エクスプローラーの OneDrive の提案や広告を非表示にします。
m.men.n=メニューを即表示
m.men.d=メニューが開くまでの遅延をなくします。
m.one.n=OneDrive の自動起動を停止
m.one.d=OneDrive が Windows と一緒に起動しなくなります（タスクマネージャーと同じ）。

[ar]
nom=العربية
lang.titre=اختر لغتك
lang.aide=↑↓ اختيار · Enter تأكيد
intro=> جارٍ تهيئة الوحدات... OK
g.perf=الأداء
g.jeu=الألعاب
g.win=WINDOWS
e.actif=● مفعّل
e.todo=○ للتفعيل
e.admin=◇ مسؤول
e.na=– غير متاح
compteur={0}/{1} مفعّلة · {2} للحقن
aide=↑↓ اختيار · مسافة تحديد · A الكل · N لا شيء · R استعادة · Enter تشغيل · Q خروج
v.admin=مقفل: شغّل السكربت كمسؤول لتفعيله.
v.na=غير متاح: لا يبدأ OneDrive مع Windows على هذا الجهاز.
confirm=حقن {0} وحدة في النظام؟ [Y] نعم / [N] لا
confirm.r=استعادة الإعدادات الأصلية (قبل السكربت)؟ [Y] نعم / [N] لا
aucun=لم يتم تحديد أي وحدة. حدّد بمفتاح المسافة.
quitte=>> تم قطع الاتصال. لم يتم أي تغيير.
connexion=> جارٍ الاتصال بالنواة... OK
cible=> الهدف: {0}
inj=جارٍ الحقن > {0}
ignore=تم تخطي {0}: {1}
ign.admin=يتطلب صلاحيات المسؤول
ign.na=غير متاح على هذا الجهاز
sauve=تم حفظ الإعدادات السابقة: {0}
sauve.err=حفظ الإعدادات السابقة: {0}
fin=تم تحسين النظام. {0} وحدة متصلة. استمتع باللعب.
fin.err=انتهى الحقن مع {0} خطأ (انظر أعلاه).
redem=أعد تشغيل الجهاز لتطبيق كل الإعدادات.
annul=للعودة إلى الإعدادات الأصلية: أعد تشغيل السكربت واضغط R.
attente=اضغط Enter للإغلاق
alim.deja=مفعّل مسبقًا: لم تتغير خطة الطاقة
alim.hp=الخطة غير متاحة على هذا الجهاز: تم تفعيل «أداء عالٍ» بدلًا منها
alim.aucun=لا توجد خطة أداء عالٍ على هذا الجهاز: لم تتغير خطة الطاقة
alim.err=فشل powercfg /setactive
hags.info=يُفعّل بعد إعادة التشغيل إذا كانت بطاقة الرسومات وتعريفها يدعمانه
r.aucune=لم يتم العثور على نسخة احتياطية في {0}
r.de=تم العثور على الإعدادات الأصلية في {0} نسخة احتياطية
r.admin={0}: شغّل الاستعادة كمسؤول
r.ok=تمت استعادة السجل
r.souris=تمت إعادة تحميل إعدادات الفأرة
r.souris.err=الفأرة: {0}
r.alim=أُعيد تفعيل خطة الطاقة السابقة
r.alim.err=تعذّر إعادة تفعيل خطة الطاقة السابقة
r.fin=اكتمل التراجع. عاد النظام إلى حالته الأصلية.
r.fin.err=انتهى التراجع مع {0} خطأ.
r.deco=سجّل الخروج أو أعد التشغيل ليُطبّق كل شيء.
m.alim.n=خطة طاقة الأداء الأقصى
m.alim.d=يبقى المعالج بأقصى سرعة دون إيقاف أي نواة.
m.hags.n=جدولة GPU (HAGS)
m.hags.d=تدير بطاقة الرسومات ذاكرتها بنفسها. مطلوب لتوليد الإطارات (DLSS 3 / FSR 3).
m.jeu.n=وضع الألعاب
m.jeu.d=يمنح Windows الأولوية للعبة قيد التشغيل.
m.bar.n=إيقاف Game Bar
m.bar.d=لا تسجيل فيديو في الخلفية، ولا فتح من يد التحكم.
m.fen.n=تحسين الألعاب في وضع النافذة
m.fen.d=تأخير أقل ودعم VRR في وضع النافذة وبلا حدود (DirectX 10-11).
m.sou.n=تصويب خام (الفأرة)
m.sou.d=يوقف التسارع: لم يعد التصويب يعتمد على سرعة الحركة.
m.vis.n=أقل التأثيرات المرئية
m.vis.d=إعداد «أفضل أداء»: إيقاف الحركات والشفافية.
m.exp.n=مستكشف ملفات بلا إعلانات
m.exp.d=يخفي اقتراحات وإعلانات OneDrive في مستكشف الملفات.
m.men.n=قوائم فورية
m.men.d=يزيل التأخير قبل فتح القوائم.
m.one.n=إيقاف OneDrive عند بدء التشغيل
m.one.d=لن يبدأ OneDrive مع Windows (كما في إدارة المهام).

[th]
nom=ไทย
lang.titre=เลือกภาษา
lang.aide=↑↓ เลือก · Enter ยืนยัน
intro=> กำลังเริ่มต้นโมดูล... OK
g.perf=ประสิทธิภาพ
g.jeu=เกม
g.win=WINDOWS
e.actif=● เปิดอยู่
e.todo=○ รอเปิด
e.admin=◇ แอดมิน
e.na=– ไม่เกี่ยว
compteur=เปิดอยู่ {0}/{1} · รอติดตั้ง {2}
aide=↑↓ เลือก · Space ติ๊ก · A ทั้งหมด · N ไม่เลือก · R คืนค่า · Enter เริ่ม · Q ออก
v.admin=ล็อกอยู่: รันสคริปต์ในฐานะผู้ดูแลระบบเพื่อเปิดใช้
v.na=ไม่เกี่ยวข้อง: OneDrive ไม่ได้เปิดพร้อม Windows บนเครื่องนี้
confirm=ติดตั้ง {0} โมดูลลงระบบ? [Y] ใช่ / [N] ไม่
confirm.r=คืนค่าการตั้งค่าเดิม (ก่อนใช้สคริปต์) ? [Y] ใช่ / [N] ไม่
aucun=ยังไม่ได้เลือกโมดูล กด Space เพื่อเลือก
quitte=>> ตัดการเชื่อมต่อแล้ว ไม่มีการเปลี่ยนแปลง
connexion=> กำลังเชื่อมต่อเคอร์เนล... OK
cible=> เป้าหมาย: {0}
inj=กำลังติดตั้ง > {0}
ignore=ข้าม {0}: {1}
ign.admin=ต้องใช้สิทธิ์ผู้ดูแลระบบ
ign.na=ไม่เกี่ยวข้องกับเครื่องนี้
sauve=บันทึกการตั้งค่าเดิมแล้ว: {0}
sauve.err=บันทึกการตั้งค่าเดิม: {0}
fin=ปรับแต่งระบบเสร็จแล้ว {0} โมดูลออนไลน์ ขอให้สนุกกับเกม
fin.err=ติดตั้งเสร็จ แต่มีข้อผิดพลาด {0} รายการ (ดูด้านบน)
redem=รีสตาร์ทเครื่องเพื่อให้การตั้งค่าทั้งหมดมีผล
annul=หากต้องการคืนค่าเดิม: รันสคริปต์อีกครั้งแล้วกด R
attente=กด Enter เพื่อปิด
alim.deja=เปิดอยู่แล้ว: ไม่เปลี่ยนแผนพลังงาน
alim.hp=เครื่องนี้ไม่มีแผนนี้: เปิด "ประสิทธิภาพสูง" แทน
alim.aucun=เครื่องนี้ไม่มีแผนประสิทธิภาพสูง: ไม่เปลี่ยนแผนพลังงาน
alim.err=powercfg /setactive ล้มเหลว
hags.info=มีผลหลังรีสตาร์ท หากการ์ดจอและไดรเวอร์รองรับ
r.aucune=ไม่พบข้อมูลสำรองใน {0}
r.de=พบการตั้งค่าเดิมในข้อมูลสำรอง {0} ชุด
r.admin={0}: รันการกู้คืนในฐานะผู้ดูแลระบบ
r.ok=กู้คืนรีจิสทรีแล้ว
r.souris=โหลดการตั้งค่าเมาส์ใหม่แล้ว
r.souris.err=เมาส์: {0}
r.alim=เปิดแผนพลังงานเดิมอีกครั้งแล้ว
r.alim.err=ไม่สามารถเปิดแผนพลังงานเดิมได้
r.fin=ย้อนกลับเสร็จสมบูรณ์ ระบบกลับสู่สถานะเดิมแล้ว
r.fin.err=ย้อนกลับเสร็จ แต่มีข้อผิดพลาด {0} รายการ
r.deco=ออกจากระบบหรือรีสตาร์ทเพื่อให้ทุกอย่างมีผล
m.alim.n=แผนพลังงานประสิทธิภาพสูงสุด
m.alim.d=ซีพียูทำงานเต็มความเร็วตลอดเวลา ไม่พักคอร์
m.hags.n=จัดตารางงาน GPU (HAGS)
m.hags.d=การ์ดจอจัดการหน่วยความจำเอง จำเป็นสำหรับ Frame Generation (DLSS 3 / FSR 3)
m.jeu.n=โหมดเกม
m.jeu.d=Windows ให้ความสำคัญกับเกมที่กำลังเล่น
m.bar.n=ปิด Game Bar
m.bar.d=ไม่บันทึกวิดีโอเบื้องหลัง และไม่เปิดจากจอยอีก
m.fen.n=เกมในโหมดหน้าต่าง
m.fen.d=ลดดีเลย์และรองรับ VRR ในโหมดหน้าต่าง / ไร้ขอบ (DirectX 10-11)
m.sou.n=เล็งแบบดิบ (เมาส์)
m.sou.d=ปิดอัตราเร่ง: การเล็งไม่ขึ้นกับความเร็วในการขยับอีก
m.vis.n=ลดเอฟเฟกต์ภาพ
m.vis.d=ตั้งค่า "ประสิทธิภาพดีที่สุด": ปิดแอนิเมชันและความโปร่งใส
m.exp.n=File Explorer ไร้โฆษณา
m.exp.d=ซ่อนคำแนะนำและโฆษณา OneDrive ใน File Explorer
m.men.n=เมนูเปิดทันที
m.men.d=ตัดความหน่วงก่อนเปิดเมนู
m.one.n=ไม่เปิด OneDrive ตอนเริ่มเครื่อง
m.one.d=OneDrive จะไม่เปิดพร้อม Windows (เหมือนใน Task Manager)
'@

# Lecture des sections [code] et des lignes « clé=texte »
$Textes = @{}
$section = $null
foreach ($ligne in ($TextesBruts -split "`r?`n")) {
    if ($ligne -match '^\[(\w+)\]$') { $section = $Matches[1]; $Textes[$section] = @{}; continue }
    $i = $ligne.IndexOf('=')
    if ($section -and $i -gt 0) { $Textes[$section][$ligne.Substring(0, $i)] = $ligne.Substring($i + 1) }
}

# Langue de départ : -Langue, sinon celle de Windows, sinon l'anglais
$script:L = 'en'
$langueWindows = try { (Get-UICulture).TwoLetterISOLanguageName } catch { 'en' }
if ($OrdreLangues -contains $langueWindows) { $script:L = $langueWindows }
if ($Langue) {
    if ($OrdreLangues -contains $Langue.ToLower()) { $script:L = $Langue.ToLower() }
    else { Write-Host "Langue inconnue / unknown language: $Langue ($($OrdreLangues -join ', '))" -ForegroundColor Yellow }
}

# Texte traduit (avec l'anglais en secours si une phrase manque)
function T($cle) {
    $texte = $Textes[$script:L][$cle]
    if (-not $texte) { $texte = $Textes['en'][$cle] }
    if (-not $texte) { $texte = $cle }
    if ($args.Count) { return ($texte -f $args) }
    return $texte
}

# ===========================================================================
#  LARGEUR À L'ÉCRAN
#  Un caractère chinois ou japonais occupe 2 cases, un accent thaï ou arabe 0.
# ===========================================================================

function Get-LargeurCar([int]$c) {
    if (($c -ge 0x0300 -and $c -le 0x036F) -or ($c -ge 0x0610 -and $c -le 0x061A) -or ($c -ge 0x064B -and $c -le 0x065F) -or
        $c -eq 0x0670 -or $c -eq 0x0E31 -or ($c -ge 0x0E34 -and $c -le 0x0E3A) -or ($c -ge 0x0E47 -and $c -le 0x0E4E) -or
        ($c -ge 0x200B -and $c -le 0x200F)) { return 0 }
    if (($c -ge 0x1100 -and $c -le 0x115F) -or ($c -ge 0x2E80 -and $c -le 0xA4CF) -or ($c -ge 0xAC00 -and $c -le 0xD7A3) -or
        ($c -ge 0xF900 -and $c -le 0xFAFF) -or ($c -ge 0xFE30 -and $c -le 0xFE4F) -or ($c -ge 0xFF00 -and $c -le 0xFF60) -or
        ($c -ge 0xFFE0 -and $c -le 0xFFE6)) { return 2 }
    return 1
}

function Get-Largeur([string]$s) {
    $n = 0
    foreach ($ch in $s.ToCharArray()) { $n += Get-LargeurCar ([int]$ch) }
    return $n
}

# Complète (ou coupe) un texte pour qu'il occupe exactement $largeur cases
function Format-Largeur([string]$s, [int]$largeur) {
    $n = 0; $sb = [Text.StringBuilder]::new()
    foreach ($ch in $s.ToCharArray()) {
        $w = Get-LargeurCar ([int]$ch)
        if ($n + $w -gt $largeur) { break }
        [void]$sb.Append($ch); $n += $w
    }
    return $sb.ToString() + (' ' * ($largeur - $n))
}

# Coupe un texte en lignes d'au plus $largeur cases. Les langues sans espaces
# (chinois, japonais, thaï) sont coupées entre deux caractères.
function Split-Texte([string]$texte, [int]$largeur) {
    $morceaux = New-Object System.Collections.Generic.List[object]
    foreach ($mot in ($texte -split ' ')) {
        if (-not $mot) { continue }
        if ((Get-Largeur $mot) -le $largeur) { $morceaux.Add(@($mot, $true)); continue }
        $premier = $true
        foreach ($ch in $mot.ToCharArray()) {
            if ((Get-LargeurCar ([int]$ch)) -eq 0 -and $morceaux.Count) {
                $dernier = $morceaux[$morceaux.Count - 1]; $dernier[0] += $ch; continue   # accent : reste avec sa lettre
            }
            $morceaux.Add(@([string]$ch, $premier)); $premier = $false
        }
    }
    $lignes = @(); $ligne = ''
    foreach ($m in $morceaux) {
        $ajout = if ($ligne -and $m[1]) { ' ' + $m[0] } else { $m[0] }
        if ((Get-Largeur ($ligne + $ajout)) -gt $largeur) { $lignes += $ligne; $ligne = $m[0] }
        else { $ligne += $ajout }
    }
    if ($ligne) { $lignes += $ligne }
    return $lignes
}

# ===========================================================================
#  PALETTE NÉON
# ===========================================================================

$E = [char]27
function Rgb($r, $g, $b) { if ($script:VT) { "$E[38;2;$r;$g;${b}m" } else { '' } }
function Fond($r, $g, $b) { if ($script:VT) { "$E[48;2;$r;$g;${b}m" } else { '' } }
$C = @{
    Cadre   = Rgb 0 200 255      # cyan néon
    Titre   = Rgb 0 240 255
    Rose    = Rgb 255 40 200     # magenta néon : sélection
    Vert    = Rgb 0 255 120      # actif
    Ambre   = Rgb 255 185 0      # à activer
    Texte   = Rgb 225 230 240
    Gris    = Rgb 100 110 130
    Rouge   = Rgb 255 60 60
    FondSel = Fond 55 0 50
    Reset   = $(if ($script:VT) { "$E[0m" } else { '' })
}

# ===========================================================================
#  INTERFACE
# ===========================================================================

# Intro : le portrait cyberpunk apparaît d'abord en caractères ASCII qui se décodent,
# puis un balayage le révèle en pixels ; reflets sur les lunettes, canon qui pulse,
# néons qui grésillent, fiche « SCAN » tapée à côté, et sortie en « glitch ».
# Image : 96 x 96 pixels, 128 couleurs (1 octet taille, 1 octet nb couleurs, palette RVB, puis index).
$PortraitDonnees = @'
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
PA4PDw8PDgoKCgoKHzoaBhAQBQw8Pj5kPj1AHQ48Zj9APkJBQUFBEjdGIiFTRiUmNjYuNiU4ODBKcFJTSS04SRMVFRUpExUTFior
KioqKS9OUkw2LihTOCFGNiZTIigiZQ8PDw8PCwoKCgoLGhoZEQUEEAc5ZD4+PjJlQGVpZjw/ZD8bQUFBQUZTISZeJDAuSi44Ji42
OC5fTFJTNS02SSkqKiopKioqKSkWKSkqKilJSl8oRiIoUyUiTC41RiEiRh4ODw8PCwoKCgoDBgYGEAUABAc5ZD49PTJmbm5uZjo6
QDo8J0ESQlFnIksoJi4wMDA2JTA2NTZeSlJSMy42SiwXFyoXFxcqFyoqKSkpKhUtSlJOKCghTDgiKFImOCQhJDwODw4PCwoICggA
AAABEAUEBQY5Pj09Oxxpbm5uZjwgOiA6PUInRjxLJEwkNSY2LkooJTU4JlJOSkxMMzMwSiwVKioXFxcqKioXFyoWKSoTNUpeJE4h
IlIuIkZMLjYjITcPDw4PCwkICgkAAAAABRAEEAYcPT09ORxpbm5uZjw6OiA8QDk0NzooKCgoMy41MEwlLjU2Ll9GOEtMMzMuTC0V
KRcqKiopKikXFxcVKSoVLUpTJF4oIUZLJSI2RjAoISQgDg4PDgoICgkAAAAABRAEEAYcPTI9OTlpbm5uZSA6IB46PyBlMj8kMCQ4
JjYwS0okMDAwS15FNkpLNTMuSjMVKioXKioqKhcXFxcqKSkqLElTJF5eIiReLiQoMCg2ISEwHA8OCwoICgkAAAAABRAFEAYaPTI9
Oz5pbm5uQB4fHgsPICBlOj4kKCg2JkowUzAlNS44X04tMzhKODM1NUkTKxcVKikXFxcqKhcqKhUqFTVTKEZ/KCROSyYoNSJGJCEo
Nzc9IA4KCgkAAQEBEBAEBAUZOzI9PmRpbmlmQB0eHQoKDiBAOi8kIkomNjg2UyglNSZSX0wsM0xKSi44LkwpKhcVFykXFyoXFxcX
FRUqFS9TRih8TChGXigkRjAjTiEjHw4eHQsKCgoCBAQFEBABAQUZOzI9ZGVmbmZkPx4eDQYQCA8gOigiJEslTDBKSyUmNSVwcEkT
LlNMSy42LkotFSoXKhcXKhUVFxcXFxYpFSxTRihOX0ooXiQoIk4kJEYhLQ4OCwoKCgoCBAQFEBAEBAUZOzs9ZGRmbmZAQCAfBxER
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
VEl3d3djdnd3eXt9f399fXt9e3h7e3RtSERIMQMCAgMLDw4eIDkHBxIbEjIcBgABBxIyOzscORwZBwICBxkZNxlTSE95f357e3pJ
E2pRFBUVLCkTFDFqalRRSUdEUHF3d3t9e31+fn16d3Z3UERiSG9ub3t0RERPRENDQ0kGAAIJDx8gOTsHBxIyEjIcBgEBBxIyOzIc
HBoaDAICBxocPRpISGd+cV9/en1OE1QxEykWFSo3N1R5eXlIQ0NEfHxxelBIYmNhYWBgYWNIQ0RERUBAc2FDQ2BjdmNIRE9NBgIJ
Dx8gOz0ZBxk+GzIcBgEBBxIyOzIcIBoNDQwMDA0cGjREaGx/cUJ8f316M2pqLBUWFVFwelB6YkNDQ1B6YWJjRENDdmJiYmJiUFBD
RE8nQDxndkhEen9/f39/dk9ILwMJDx85Oz0ZGTI+MjsZBgEBBxkcOxwcHBkMDAwICAwZPUNIWnF/f0FFf39+N1R/URMqKisxY3d3
UE9dYVBISEhEQ0NESEREREhISCdFbWFpZ2dzYE96f39/f39/f3RESBwJHRo5Oz0ZMmRkPTIbBgYGEhwyOxwcGhkZDAwMDAwcRENc
W399f0RCSn9/amp9ajEVKhMsY316bWxsXUhPT1BgbXh3c3t7fX5+fXJye3N4eHl2T2F/f39/f39/f35PSFEaGho5OzsZPmVkPjIy
BwYGEhsyOxwcGgwMDAwNDAxFREhabH96f0dCRU5/fWt7fTcTFRM3dn13dGhoe39/f39+bH5/f39/f39/f294e294b3l0T3d/f39/
f39/f39jT1cZDBocMjIcPmVlPjQcDAcHEhsyOxwcGgMCCAgJCBJIXVpVcn55fjdERUVef2tyfmozMTd6dn53bWhofn9/f39+bX9/
f39/f39/fm94e3h4b3lhT3p/f39/f39/f392T10HAhkcMjIyPmVkPj0cDAcHGTIyMhwcGgMCDAgIDEhgaFVVen14fxxRRUVFcHln
fX16en57dnpjbWhoc319fX15bH1/f39/f39/fm94e3h4eHlhT3p/f39/f39/f392T2IUBxw5HDIcPWVlPjIcDAcSGzIyHBwcGg0M
GRkNL09rVVpVentvfxwyX0VFRXFrcn5+fn19Y2Njent3dnh4eHh4eHhpaWdubmtvbmlue25ubnl0T3Z/f39/f39/f35jT2JIRFBd
VmUaOWVlPjIcDAcSGzIyMhwcGhoZGRk0SGxaWlZVfXlvfz0Mfk5FRUl6cnl9fX5gT2BgYGF3XV1daGhoaHZlQEBAQEBAQEBAcmVA
QGd3T2B/f39/f39/f31gT3ZNQ0NDQ0QZHGRlPjIcDAwbMjI7MhwcGhoZHD1NbGhVWlZVfXlvfVEMUX9JRUVJfWtyc35gT2BPT096
bW1tbW1saG1mQEBAQEBAQEBAa2tAQGV5YE92f39/f39/f3dPYHZbaUhDQ0MaOWRkPTIyGRkcMjI7OzkaHzo0R1BdbFVaWlhVenNv
e2cMHHB+RUVFXnl5cnNQT1BPTU9IT1BQYGBhdHZ5a2tnZ2ZlZWVAZXJlQEBrdk9ESH9/f39/ek9PY2xVWGlYREM5PWRkPjIyMjI9
PT07Ozk/UURESE9sVVpWVlhVd3Nve2cIDBtwcEVFRU5xfX1QT1BPT09EYH1xdmJgT2B5eHN5eXt7e3l5cn19c2tueW1IQ0NIcXFj
T09idlpaWFhbaUhkZGRkPj4+Pj0yMjs5PWdIQ0NgXWxcWlpWVlpVcnNveWsyNDQyck5FRUVFTl9jYWFgT2BjT2Bjd31/dk9zb3hH
ISQkR05jd3lgen14eHltT0RET09PT2J2W1paWFpaWFs+ZD5kPjIyHBw9NDdNSENDQ2hdaGhVWlpaWlpVa3h4c3InQ0RITnFJRklF
J2JgT2NjY3Z2YGBQT09PUE90e3leJCIhISEhIUdgb314eHh5eG1hYGBhdm9oVlpaWFpaWlgyPj0+Ozk9UU1IT11IQ0NDaGxVb1xa
WlpaWlpVbHh4eVEbQkNDQUNEUEhORU5hTWBgT2BPYGBgYWNhYE9PYXR4e3t5Y05HJFBgb319fXt5e3t7d3dvaFpaWlpaWlpaWloy
PTJkUU1EQ0NPWmlIQ0NYa1VsbVVaWFpaWFpVaHh4eVQbGydCSS9Uf2J8f3ZhT09PT09PSHF9Y2BgYWNjYWBQT2BhdXl7fXNQb3h4
eXl5e3djbUhsVVpaWlpaWlhaWlocPmtIQ0NDQ01pWGdEQ1VrWGhvVlpaWlpaWlpaW2x4eWobGzdyfXJOJzNJTnFxY2BgY1BPRERQ
fmNPT09QYGFjY2FgUE9PYHRQeHNzc3N4c21gb0NgW1haWlpaWFhaWlprYkRDQ0NDTVtVaF1DT2toW2xWWlpaWFhWVVZaVWh4c3o0
NHt4e0hCFRUsLy9JTl52fX16Y0hERFBPT09PT09PT2BhY3djYWNPdH9/f39/fXRQeUREa1VaWFhaWlhaWlp2SENDQ0NPaFhaaE1I
a2xVbFZaWlpVWFtoaGhoVltveH40anh5RyMxKyoXGCosLC9FTl9xcXF2YE9PT09PT09PT01PT3hzc3t0T2FiYmJjYWBgY0hDYlpY
WlhYWlpaWlpDdkhDQ0hpVVpaW1VoalVsaFVcVVZobGxoaGhsbFlseH43en1xQhYrKhYqFhUXFywsLS0vL0VJXnZhT09PT09PT09P
T3R3fn5/dmBgYGBgYGNoWlhESGhVWFhaWlpaWlpDQ31ERGlYWlhcWmh4VmhrVVVYaGxsW1VVVVVWaGhseHpUN3teJRgpKSsXKysr
KxcXFSoqLC0tL0lfcXZgT09PT09PUGB2f39/f39/dnZ7eXN4a2traFtaWFhaWFpaWFpPT2N5VVtYWFhYWmtbVXhoW2hsbFtVWGhq
cmxaVWhseHlUNFNKNSksFhUrKysrFyoXLEkvLCosLC0vSV9+emNPT09PUGF2f39/f39/YWF7c3NzaFVVWlpYWFhYWlhYVVtoW1V6
bFVcWlxVbGhYaGxsbGxbVVtrfX9+e359aFVob3lnVCRRTi0tSSwVKysXKyoVLUpFLRcVFSosLUVGXnF9dmBPT2FQYFBIREREQ2Fz
b294bFVaWFhYWlpaWlhVaGxobFtbfVtWXFZobFVYXFlbVVZod35/fnl4eHh7fWhWbHt+RCQxUzUvSUksFxcXFyoVLUkvLBUWFhUV
FSwtL0VJXn13Y2NgUE9ERERERHZzeHh4bFZYWFpYWlhYXFVob1taaGxbbHdVXFpobGxsbGxsb3p9fXtzb3NzeHhve3JVbH9EIzEs
IyctL05OLSwsKSsVLUktFRYWFhYpKRUVKi0vRUl5eXljYWN0dG1tY3doaGx4eFtYWlpaWlhYVWhzW1VVVVVsaHFsVVxWW2hoc3t7
e3l4b214eXl4b3hzbFhVeURBMSwjIykrLS9eXklJRS0sKywsFSoqFSkpKhYpKRQzRUV2eHhPT01PTU9PT3ZoVVVbaFtaWlpYWFhV
bHpbVVpqaFVVaGh3WlhcWlVab29veHhoVWh5c21vcmN2VVVrREEsMUEjMRcqFSwvSV5eXkkvLy0sKxcXFikpFhUWFSxJRUVjc3hg
T0hISEhPYG1obGhVVVhYWFpaWFVsfVtVXFhoanJrbGxsbFVoXFZoeHN4bFVaeHNsaGtjREh9fXJEQSwYJSMrGCoXFxcsLUVOX39w
TklFLy0tLCsXFxYpEzczRUVGcXttSENDQ0NPd2xVWWhsaFZaWlpaWFVraFVcVVxaVVpobG9samhbaFVsc2xZVWx5b1hncUhDRH5/
f0cjKxcXJSUYKRcXKxcXKy0vRl5/f398X05JRS8tLCsVLDcvRUVJemx5d2N2dnd3aGxvaFVZbGhZWlpYWFtsVVxVaHpVVVVVVVVo
bHJoaGhsW1VoeHhoaHJQQ0NIf39/TiUxKyktLykXFxcXKxcXFxcsLS9GTl98f39/fF5JRS8tLS9FRUVfb1VoaGhoaGhrbFpoeGxb
VWxsVVhYVWhoVVVsfW9VVVVVVVVVbHlyaGxsVWh4aFpyY0RDQ099f39iJRgqFyxFSiwXFxcXFxcXFyoXFywtLy9FSV58f39/fF5J
RUVFSV53WlhYVVVVWFhaaGpbVWxoWGxbXFhYVmxbVWt7aFVsbGxoaFpVVmx+bFV4bFVVa3FIQ0RPWmt/f3wkFRgrKxUzTjUVFxcr
GBcXFxcXKxcVKywsLC9FSU5wf39/fHx/f3tVWlhYWFhYWFhcVVpsaFVYbFtbbFZVaGxVcnNbVVp4eHJ4cnNsaFZrelVseWx6YkRI
VWlpWn1/f0cTGBYXKxUxVEkvLBcrKysXKysrFysqKxcWFywtLycvRk5ffn9eR3FoVVhYWlpaWFpaWGhsWFx3aFVob1lVbGhreFtV
aGw=
'@

function Show-Portrait {
    if (-not $script:VT) { return }
    try { $LC = [Console]::WindowWidth; $HC = [Console]::WindowHeight } catch { return }
    try { $octets = [Convert]::FromBase64String(($PortraitDonnees -replace '\s', '')) } catch { return }
    $N = [int]$octets[0]; $NP = [int]$octets[1]; $base = 2 + 3 * $NP
    $pal = [int[]]::new($NP)
    for ($i = 0; $i -lt $NP; $i++) { $pal[$i] = ([int]$octets[2 + 3 * $i] -shl 16) -bor ([int]$octets[3 + 3 * $i] -shl 8) -bor [int]$octets[4 + 3 * $i] }

    $S = [math]::Min($N, [math]::Min(($HC - 1) * 2, $LC - 2)); $S -= $S % 2
    if ($S -lt 24) { return }
    $LI = $S / 2                                   # lignes de texte occupées par l'image
    $hud = ($LC - $S) -ge 48
    $largeurTotale = if ($hud) { $S + 44 } else { $S }
    $ox = [int](($LC - $largeurTotale) / 2) + 1; $oy = [int](($HC - $LI) / 2) + 1
    $e = [char]27
    $rnd = [Random]::new()

    function Rgbi($r, $g, $b) { ([int][math]::Min(255, [math]::Max(0, $r)) -shl 16) -bor ([int][math]::Min(255, [math]::Max(0, $g)) -shl 8) -bor [int][math]::Min(255, [math]::Max(0, $b)) }
    function Melange($c, $d, $t) {
        Rgbi (((($c -shr 16) -band 255) * (1 - $t)) + ((($d -shr 16) -band 255) * $t)) (((($c -shr 8) -band 255) * (1 - $t)) + ((($d -shr 8) -band 255) * $t)) ((($c -band 255) * (1 - $t)) + (($d -band 255) * $t))
    }
    function Echelle($c, $k) { Rgbi ((($c -shr 16) -band 255) * $k) ((($c -shr 8) -band 255) * $k) (($c -band 255) * $k) }

    # --- L'image à la taille de la fenêtre --------------------------------------------
    $img = [int[][]]::new($S)
    for ($y = 0; $y -lt $S; $y++) {
        $l = [int[]]::new($S); $sy = [int][math]::Floor($y * $N / $S)
        for ($x = 0; $x -lt $S; $x++) { $l[$x] = $pal[$octets[$base + $sy * $N + [int][math]::Floor($x * $N / $S)]] }
        $img[$y] = $l
    }

    # --- Version ASCII : un caractère par case selon la luminosité, dans la couleur de l'image
    $rampe = ' .:-=+*#%@'
    $asciiCar = [char[][]]::new($LI); $asciiCoul = [int[][]]::new($LI); $asciiFond = [int[][]]::new($LI); $debut = [int[][]]::new($LI)
    for ($r = 0; $r -lt $LI; $r++) {
        $asciiCar[$r] = [char[]]::new($S); $asciiCoul[$r] = [int[]]::new($S); $asciiFond[$r] = [int[]]::new($S); $debut[$r] = [int[]]::new($S)
        for ($x = 0; $x -lt $S; $x++) {
            $c = Melange $img[2 * $r][$x] $img[2 * $r + 1][$x] 0.5
            $lum = 0.3 * (($c -shr 16) -band 255) + 0.59 * (($c -shr 8) -band 255) + 0.11 * ($c -band 255)
            $asciiCar[$r][$x] = $rampe[[math]::Min(9, [int]($lum / 255 * 12))]
            $asciiCoul[$r][$x] = Echelle $c 1.5
            $asciiFond[$r][$x] = Echelle $c 0.38
            $debut[$r][$x] = $rnd.Next(2, 20)
        }
    }
    $glyphes = '01<>/\|#$%&*+=?!'.ToCharArray()
    $vertCode = Rgbi 0 200 150

    # --- Zones animées (en fraction de la taille de l'image) ----------------------------
    $verres = New-Object System.Collections.Generic.List[int[]]     # x, y, position sur la diagonale
    for ($y = [int]($S * 0.33); $y -le [int]($S * 0.50); $y++) {
        for ($x = [int]($S * 0.25); $x -le [int]($S * 0.70); $x++) {
            $c = $img[$y][$x]
            if ((($c -shr 16) -band 255) + (($c -shr 8) -band 255) + ($c -band 255) -gt 150) { $verres.Add([int[]]@($x, $y, ($x + [int](($y - $S * 0.33) * 0.6)))) }
        }
    }
    $vx0 = [int]($S * 0.25); $vx1 = [int]($S * 0.70) + [int]($S * 0.1)
    $canon = New-Object System.Collections.Generic.List[int[]]      # x, y
    $mx = $S * 0.855; $my = $S * 0.715; $mr = $S * 0.095
    for ($y = [int]($my - $mr); $y -le [int]($my + $mr); $y++) {
        for ($x = [int]($mx - $mr); $x -le [math]::Min($S - 1, [int]($mx + $mr)); $x++) {
            if (($x - $mx) * ($x - $mx) + ($y - $my) * ($y - $my) -gt $mr * $mr) { continue }
            $c = $img[$y][$x]; $rr = ($c -shr 16) -band 255; $gg = ($c -shr 8) -band 255
            if ($rr -gt 110 -and $rr -gt $gg + 50) { $canon.Add([int[]]@($x, $y)) }
        }
    }
    $neons = @((New-Object System.Collections.Generic.List[int[]]), (New-Object System.Collections.Generic.List[int[]]))   # x, y, couleur éteinte
    for ($y = 0; $y -lt [int]($S * 0.62); $y++) {
        for ($x = 0; $x -lt $S; $x++) {
            if ($x -lt $S * 0.16) { $cote = 0 } elseif ($x -gt $S * 0.86) { $cote = 1 } else { continue }
            $c = $img[$y][$x]; $rr = ($c -shr 16) -band 255; $gg = ($c -shr 8) -band 255; $bb = $c -band 255
            $max = [math]::Max($rr, [math]::Max($gg, $bb)); $min = [math]::Min($rr, [math]::Min($gg, $bb))
            if ($max -gt 150 -and $max - $min -gt 80) { $neons[$cote].Add([int[]]@($x, $y, (Echelle $c 0.45))) }
        }
    }

    # --- Fiche « SCAN » tapée à droite ---------------------------------------------------
    $fiche = @(
        @('┌─[ SCAN://SUBJECT ]', ''),
        @('│ IDENT ..... ', 'github.com/JohnWish01'),
        @('│ OPTICS .... ', 'NEON-GRADE'),
        @('│ WEAPON .... ', 'CHARGED'),
        @('│ STATUS .... ', 'ARMED // ONLINE'),
        @('│ THREAT .... ', '██████████ MAX'),
        @('└─> ', 'TARGET LOCKED')
    )
    $cCadre = "$e[38;2;0;220;255m"; $cGris = "$e[38;2;110;120;150m"; $cRose = "$e[38;2;255;60;210m"; $cRouge = "$e[38;2;255;40;60m"
    $hx = $ox + $S + 4; $hy = $oy + [int]($LI / 2) - 4

    $codesF = @{}; $codesB = @{}
    $toile = [int[][]]::new($S)
    for ($y = 0; $y -lt $S; $y++) { $toile[$y] = [int[]]::new($S) }
    $sb = [Text.StringBuilder]::new(65536)
    $chrono = [Diagnostics.Stopwatch]::new()
    $debutBalayage = 24; $finBalayage = 48; $images = 90; $glitch = 12
    $blanc = Rgbi 255 255 255; $cyan = Rgbi 0 255 255

    [Console]::Write("$e[?25l$e[0m$e[2J")
    try {
        for ($f = 0; $f -lt $images + $glitch; $f++) {
            $chrono.Restart()
            # Ligne jusqu'où le balayage a révélé les pixels
            $scan = if ($f -lt $debutBalayage) { -1 } else { [int](($f - $debutBalayage) * $LI / ($finBalayage - $debutBalayage)) }

            # Pixels de l'image + effets
            for ($y = 0; $y -lt $S; $y++) { [Array]::Copy($img[$y], $toile[$y], $S) }
            if ($f -ge $finBalayage) {
                # Reflet qui traverse les verres (deux passages)
                foreach ($dep in 52, 72) {
                    if ($f -ge $dep -and $f -lt $dep + 12) {
                        $bande = $vx0 + ($f - $dep) * ($vx1 - $vx0) / 11.0
                        $epaisseur = [math]::Max(1.5, $S / 40.0)
                        foreach ($p in $verres) {
                            $d = [math]::Abs($p[2] - $bande)
                            if ($d -lt $epaisseur) { $toile[$p[1]][$p[0]] = Melange $toile[$p[1]][$p[0]] $blanc (0.75 - 0.4 * $d / $epaisseur) }
                        }
                    }
                }
                # Canon qui pulse
                $k = 1 + 0.4 * [math]::Sin($f * 0.45)
                foreach ($p in $canon) { $toile[$p[1]][$p[0]] = Echelle $img[$p[1]][$p[0]] $k }
            }
            # Néons du décor qui grésillent
            foreach ($cote in 0, 1) {
                if ($rnd.Next(9) -eq 0) { foreach ($p in $neons[$cote]) { $toile[$p[1]][$p[0]] = $p[2] } }
            }
            # Glitch final : lignes décalées, teinte et bandes de bruit
            if ($f -ge $images) {
                $force = $f - $images + 1
                for ($n = 0; $n -lt $force * 2; $n++) {
                    $y = $rnd.Next($S); $dec = $rnd.Next(-6, 7)
                    $copie = [int[]]$toile[$y].Clone()
                    $teinte = $rnd.Next(3) -eq 0
                    for ($x = 0; $x -lt $S; $x++) {
                        $c = $copie[(($x + $dec) % $S + $S) % $S]
                        $toile[$y][$x] = if ($teinte) { $c -band 0x00FFFF } else { $c }
                    }
                }
                if ($rnd.Next(2) -eq 0) {
                    $y = $rnd.Next($S); $c = if ($rnd.Next(2) -eq 0) { $cyan } else { $blanc }
                    for ($x = $rnd.Next($S); $x -lt $S; $x += $rnd.Next(1, 4)) { $toile[$y][$x] = $c }
                }
            }

            # Rendu
            [void]$sb.Clear()
            for ($r = 0; $r -lt $LI; $r++) {
                [void]$sb.Append("$e[$($oy + $r);$($ox)H")
                $dF = -1; $dB = -1
                if ($r -eq $scan -and $f -lt $finBalayage) {
                    [void]$sb.Append("$e[38;2;200;255;255m$e[48;2;0;140;170m").Append([string][char]0x2580 * $S); continue
                }
                $pixels = $r -lt $scan -or $f -ge $finBalayage
                $hautL = $toile[2 * $r]; $basL = $toile[2 * $r + 1]
                for ($x = 0; $x -lt $S; $x++) {
                    if ($pixels) { $ch = $hautL[$x]; $cb = $basL[$x] }
                    elseif ($f -ge $debut[$r][$x]) { $cb = $asciiFond[$r][$x] } else { $cb = 0 }
                    if ($cb -ne $dB) {
                        $code = $codesB[$cb]
                        if (-not $code) { $code = "$e[48;2;$(($cb -shr 16) -band 255);$(($cb -shr 8) -band 255);$($cb -band 255)m"; $codesB[$cb] = $code }
                        [void]$sb.Append($code); $dB = $cb
                    }
                    if ($pixels) {
                        if ($ch -eq $cb) { [void]$sb.Append(' '); continue }
                        $car = [char]0x2580
                    } elseif ($f -lt $debut[$r][$x]) {
                        if ($rnd.Next(5) -ne 0) { [void]$sb.Append(' '); continue }
                        $ch = $vertCode; $car = $glyphes[$rnd.Next($glyphes.Count)]
                    } else {
                        $ch = $asciiCoul[$r][$x]; $car = $asciiCar[$r][$x]
                        if ($car -eq ' ') { [void]$sb.Append(' '); continue }
                    }
                    if ($ch -ne $dF) {
                        $code = $codesF[$ch]
                        if (-not $code) { $code = "$e[38;2;$(($ch -shr 16) -band 255);$(($ch -shr 8) -band 255);$($ch -band 255)m"; $codesF[$ch] = $code }
                        [void]$sb.Append($code); $dF = $ch
                    }
                    [void]$sb.Append($car)
                }
            }
            [void]$sb.Append("$e[0m")
            # Fiche tapée lettre par lettre
            if ($hud -and $f -ge 8) {
                $reste = ($f - 8) * 4
                for ($i = 0; $i -lt $fiche.Count; $i++) {
                    $lab = $fiche[$i][0]; $val = $fiche[$i][1]
                    $nl = [math]::Min($lab.Length, $reste); $reste -= $nl
                    $nv = [math]::Min($val.Length, [math]::Max(0, $reste)); $reste -= $nv
                    $cv = if ($i -eq $fiche.Count - 1) { $cRouge } elseif ($i -eq 1) { $cCadre } else { $cRose }
                    if ($i -eq $fiche.Count - 1 -and $nv -eq $val.Length -and ($f -shr 2) % 2 -eq 1) { $nv = 0 }
                    $texte = "$cCadre$($lab.Substring(0, [math]::Min(2, $nl)))$cGris$($lab.Substring([math]::Min(2, $nl), $nl - [math]::Min(2, $nl)))$cv$($val.Substring(0, $nv))$e[0m"
                    [void]$sb.Append("$e[$($hy + $i);$($hx)H$e[K").Append($texte)
                    if ($reste -le 0) { break }
                }
            }
            [Console]::Write($sb.ToString())

            $touche = $false
            try { $touche = [Console]::KeyAvailable } catch { }
            if ($touche) { [void][Console]::ReadKey($true); break }
            $attente = 50 - $chrono.ElapsedMilliseconds   # ~20 images par seconde
            if ($attente -gt 0) { Start-Sleep -Milliseconds $attente }
        }
    } finally {
        [Console]::Write("$e[0m$e[2J$e[H$e[?25h")
    }
}

# Séquence de démarrage façon BIOS (pour le style). Les infos matérielles sont lues
# pour de vrai (lecture seule) ; les « modules » qui démarrent sont de la mise en scène.
function Show-Boot {
    if (-not $script:VT) { return }
    $e = [char]27
    $rnd = [Random]::new()
    function Pause-Boot($ms) {
        if ($script:BootVite) { return }
        $t = $false; try { $t = [Console]::KeyAvailable } catch { }
        if ($t) { [void][Console]::ReadKey($true); $script:BootVite = $true; return }
        Start-Sleep -Milliseconds $ms
    }
    $script:BootVite = $false
    $cy = Rgb 0 220 255; $ro = Rgb 255 40 200; $ve = Rgb 0 255 120; $am = Rgb 255 185 0; $bl = Rgb 225 230 240; $gr = Rgb 90 100 125; $z = "$e[0m"

    # Infos matérielles (lecture seule)
    $cpu = 'UNKNOWN CPU'; $threads = '?'; $ram = '?'; $gpu = 'UNKNOWN GPU'; $os = 'WINDOWS'
    try { $p = Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1; $cpu = ($p.Name -replace '\s+', ' ').Trim(); $threads = $p.NumberOfLogicalProcessors } catch { }
    try { $ram = [math]::Round((Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory / 1GB) } catch { }
    try { $g = Get-CimInstance Win32_VideoController -ErrorAction Stop | Where-Object { $_.Name -notmatch 'Basic|Virtual|Remote|Parsec|Meta' } | Select-Object -First 1; if ($g) { $gpu = $g.Name.Trim() } } catch { }
    try { $o = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop; $os = "$($o.Caption -replace 'Microsoft ', '') build $($o.BuildNumber)" } catch { }

    [Console]::Write("$e[?25l$e[2J$e[H")
    try {
        [Console]::Write("`r`n  $ro▌$cy W11::BIOS $Version $gr// NEON-KERNEL // github.com/JohnWish01$z`r`n")
        [Console]::Write("  $cy$('─' * 70)$z`r`n`r`n")
        Pause-Boot 250

        # Test mémoire qui défile
        $total = if ($ram -is [double] -or $ram -is [int] -or $ram -is [long]) { [long]$ram * 1048576 } else { 16777216 }
        for ($i = 0; $i -le 20; $i++) {
            $kb = [long]($total * $i / 20)
            $plein = [int]($i * 1.2)
            [Console]::Write(("`r  $gr MEMTEST  $bl{0,12:N0} KB  $cy[{1}{2}]$z" -f $kb, ('█' * $plein), ('░' * (24 - $plein))))
            Pause-Boot 35
        }
        [Console]::Write("  $ve OK$z`r`n`r`n")

        $materiel = @(
            @('CPU', "$cpu  $gr($threads threads)"),
            @('RAM', "$ram GB"),
            @('GPU', $gpu),
            @('OS ', $os)
        )
        foreach ($m in $materiel) {
            [Console]::Write("  $gr[$ve  OK  $gr]$cy $($m[0])  $gr▸$bl $($m[1])$z`r`n")
            Pause-Boot 120
        }
        [Console]::Write("`r`n")

        $etapes = @(
            'Loading neon-kernel modules', 'Mounting /dev/registry', 'Starting power.daemon',
            'Starting gamebar.sentinel', 'Calibrating mouse.raw_input', 'Compiling dx.swapchain shaders',
            'Decrypting visual.fx matrix', '!ICE countermeasure detected', 'Rerouting through proxy node',
            'Syncing chrono.daemon', 'Injecting low-latency patch', 'Establishing neural link'
        )
        $roue = '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'.ToCharArray()
        foreach ($etape in $etapes) {
            $alerte = $etape.StartsWith('!')
            $texte = $etape.TrimStart('!')
            $adresse = '0x{0:X8}' -f $rnd.Next()
            if (-not $script:BootVite) {
                for ($k = 0; $k -lt $rnd.Next(3, 9); $k++) {
                    [Console]::Write("`r  $gr[  $cy$($roue[$k % $roue.Count])$gr   ]$bl $texte $gr$adresse$z")
                    Pause-Boot 45
                }
            }
            if ($alerte) { [Console]::Write("`r  $gr[$am WARN$gr ]$am $texte $gr$adresse$z`r`n") }
            else { [Console]::Write("`r  $gr[$ve  OK  $gr]$bl $texte $gr$adresse$z`r`n") }
            Pause-Boot 30
        }
        [Console]::Write("`r`n  $ro>> $ve")
        foreach ($c in 'ALL SYSTEMS NOMINAL // READY'.ToCharArray()) { [Console]::Write($c); Pause-Boot 22 }
        [Console]::Write($z)
        Pause-Boot 700
    } finally {
        [Console]::Write("$e[0m$e[2J$e[H$e[?25h")
    }
}

# Écran de démarrage : le logo apparaît ligne par ligne avec un effet « glitch ».
function Show-Intro {
    if (-not $script:VT) { return }
    $logo = @(
        '╔═╗╔═╗╔╦╗╦╔╦╗╦╔═╗╔═╗╦═╗'
        '║ ║╠═╝ ║ ║║║║║╔═╝║╣ ╠╦╝'
        '╚═╝╩   ╩ ╩╩ ╩╩╚═╝╚═╝╩╚═'
    )
    $sousTitre = "W11 // GAMING  $Version"
    $message = T 'intro'
    try { $largeur = [Console]::WindowWidth; $hauteur = [Console]::WindowHeight } catch { return }
    $haut = [math]::Max(0, [int](($hauteur - 7) / 2))
    $gauche = { param($texte) [math]::Max(0, [int](($largeur - (Get-Largeur $texte)) / 2)) }
    $bruit = '░▒▓█<>/\|#*=+-'.ToCharArray()
    $rnd = [Random]::new()

    [Console]::Write("$E[?25l$E[2J")
    try {
        for ($i = 0; $i -lt $logo.Count; $i++) {
            $x = & $gauche $logo[$i]
            # 3 passages de « bruit » qui se résolvent en la vraie ligne
            foreach ($passe in 1..3) {
                $glitch = -join ($logo[$i].ToCharArray() | ForEach-Object {
                    if ($_ -ne ' ' -and $rnd.Next(4) -lt (4 - $passe)) { $bruit[$rnd.Next($bruit.Count)] } else { $_ } })
                [Console]::Write("$E[$($haut + $i + 1);$($x + 1)H" + $(if ($passe -lt 3) { $C.Rose } else { $C.Titre }) + $glitch)
                Start-Sleep -Milliseconds 45
            }
            [Console]::Write("$E[$($haut + $i + 1);$($x + 1)H$($C.Titre)$($logo[$i])")
        }
        $x = & $gauche $sousTitre
        [Console]::Write("$E[$($haut + 4);$($x + 1)H$($C.Gris)$sousTitre")
        $x = & $gauche $message
        [Console]::Write("$E[$($haut + 6);$($x + 1)H$($C.Vert)")
        foreach ($c in $message.ToCharArray()) { [Console]::Write($c); Start-Sleep -Milliseconds 18 }
        Start-Sleep -Milliseconds 650
    } finally {
        [Console]::Write("$($C.Reset)$E[2J$E[H$E[?25h")
    }
}

# Barre du haut, sur toutes les pages
function Show-Barre {
    $acces = if ($script:EstAdmin) { 'ROOT' } else { 'STANDARD' }
    Write-Host ("  {0}▌ {1}W11::OPTIMIZER {0}▐ {2}{3}  {4}░▒▓ {5}github.com/JohnWish01 {4}▓▒░{6}" -f
        $C.Rose, $C.Titre, $C.Gris, $Version, $C.Cadre, $C.Vert, $C.Reset)
    Write-Host ("  {0}USER://{1}{2}   {0}ACCESS://{3}{4}   {0}LANG://{1}{5}{6}" -f $C.Gris, $C.Texte, $env:USERNAME, $(if ($script:EstAdmin) { $C.Rose } else { $C.Texte }), $acces, $script:L.ToUpper(), $C.Reset)
    Write-Host ("  {0}{1}{2}" -f $C.Cadre, ('─' * 70), $C.Reset)
}

function Write-Titre($texte) {
    Write-Host ""
    Write-Host ("  {0}┌─[ {1}{2}{0} ]{3}" -f $C.Cadre, $C.Rose, $texte, $C.Reset)
}

# Texte qui s'affiche lettre par lettre, façon terminal.
function Write-Terminal($texte, $couleur = 'Green') {
    foreach ($c in $texte.ToCharArray()) {
        Write-Host $c -NoNewline -ForegroundColor $couleur
        Start-Sleep -Milliseconds 8
    }
    Write-Host ""
}

function Write-Ok($texte)     { Write-Host ("  {0}│ {1}[OK]{2} {3}{4}" -f $C.Cadre, $C.Vert, $C.Texte, $texte, $C.Reset) }
function Write-Info($texte)   { Write-Host ("  {0}│ {1}[i]{2}  {3}{4}" -f $C.Cadre, $C.Ambre, $C.Gris, $texte, $C.Reset) }
function Write-Erreur($texte) { Write-Host ("  {0}│ {1}[X]  {2}{3}" -f $C.Cadre, $C.Rouge, $texte, $C.Reset); $script:Erreurs++ }

function Show-Progression($numero, $total, $nom) {
    $largeur = 24
    $plein = [math]::Round($largeur * $numero / $total)
    $barre = ('▓' * $plein) + ('░' * ($largeur - $plein))
    Write-Host ("  {0}│ {1}[{2}] {3,3}%  {4}{5}{6}" -f $C.Cadre, $C.Titre, $barre, [math]::Round(100 * $numero / $total), $C.Gris, (T 'inj' $nom), $C.Reset)
}

function Wait-Fin {
    Write-Host ""
    Read-Host ("  └─> " + (T 'attente')) | Out-Null
    Restore-Console
}

# Lit une touche du clavier et la traduit en commande du menu.
function Read-Touche {
    $k = [Console]::ReadKey($true)
    if ($k.Key -eq 'C' -and ($k.Modifiers -band [ConsoleModifiers]::Control)) { return 'Q' }   # Ctrl+C
    switch ($k.Key) {
        'UpArrow'   { return 'Haut' }
        'DownArrow' { return 'Bas' }
        'Spacebar'  { return 'Espace' }
        'Enter'     { return 'Entree' }
        'Escape'    { return 'Q' }
        default     { return $k.KeyChar.ToString().ToUpper() }
    }
}

# ===========================================================================
#  REGISTRE (avec sauvegarde de l'ancienne valeur)
# ===========================================================================

# Lit une valeur du registre : $null si elle n'existe pas.
function Get-Reg($Chemin, $Nom) {
    if (-not (Test-Path $Chemin)) { return $null }
    $cle = Get-Item -Path $Chemin
    if ($cle.GetValueNames() -notcontains $Nom) { return $null }
    $data = $cle.GetValue($Nom, $null, 'DoNotExpandEnvironmentNames')
    if ($data -is [byte[]]) { $data = [int[]]$data }   # pour pouvoir l'écrire en JSON
    return @{ Type = $cle.GetValueKind($Nom).ToString(); Valeur = $data }
}

function Get-RegValeur($Chemin, $Nom) {
    $v = Get-Reg $Chemin $Nom
    if ($v) { return $v.Valeur } else { return $null }
}

# Écrit une valeur du registre, après avoir noté l'ancienne pour pouvoir la restaurer.
function Set-Reg($Chemin, $Nom, $Type, $Valeur) {
    $ancienne = Get-Reg $Chemin $Nom
    $script:Anciennes += [pscustomobject]@{
        Chemin = $Chemin; Nom = $Nom; Existait = [bool]$ancienne
        Type = $(if ($ancienne) { $ancienne.Type } else { $null })
        Valeur = $(if ($ancienne) { $ancienne.Valeur } else { $null })
    }
    if (-not (Test-Path $Chemin)) { New-Item -Path $Chemin -Force | Out-Null }
    New-ItemProperty -Path $Chemin -Name $Nom -PropertyType $Type -Value $Valeur -Force | Out-Null
}

# ===========================================================================
#  OUTILS SYSTÈME
# ===========================================================================

function Get-ModeAlimentationActif {
    $sortie = powercfg /getactivescheme
    if ($sortie -match '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\s*\((.*)\)') {
        return [pscustomobject]@{ Guid = $Matches[1]; Nom = $Matches[2] }
    }
    return $null
}

function Test-ModeAlimentation($Guid) {
    return [bool]((powercfg /list) -match $Guid)
}

# Un mode « Performances optimales » existe déjà (créé par Windows ou par une ancienne version du script) ?
function Find-ModeUltimate {
    foreach ($ligne in (powercfg /list)) {
        if ($ligne -match '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\s*\((.*)\)') {
            $guid = $Matches[1]
            if ($Matches[2] -match $NomsUltimate) { return $guid }
        }
    }
    return $null
}

# Applique tout de suite les réglages de la souris lus dans le registre (sinon il faut se déconnecter).
function Update-Souris {
    if (-not ('JW.Souris' -as [type])) {
        Add-Type -Namespace JW -Name Souris -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true)]
public static extern bool SystemParametersInfo(uint action, uint param, int[] vparam, uint winIni);
'@
    }
    $p = 'HKCU:\Control Panel\Mouse'
    $valeurs = [int[]]@([int](Get-RegValeur $p 'MouseThreshold1'), [int](Get-RegValeur $p 'MouseThreshold2'), [int](Get-RegValeur $p 'MouseSpeed'))
    [void][JW.Souris]::SystemParametersInfo(0x0004, 0, $valeurs, 0x02)   # SPI_SETMOUSE, SPIF_SENDCHANGE
}

# ===========================================================================
#  MODULES D'OPTIMISATION
#  Chaque module : Cle (pour ses textes « m.<cle>.n » et « m.<cle>.d »), Groupe,
#  Indispo (raison s'il ne s'applique pas à ce PC), Actif (déjà appliqué ?), Appliquer.
# ===========================================================================

$Modules = @(
    [pscustomobject]@{
        Cle = 'alim'; Groupe = 'g.perf'
        Indispo = { $null }
        Actif = { $m = Get-ModeAlimentationActif; [bool]($m -and ($m.Guid -eq $GuidUltimateCopie -or $m.Nom -match $NomsUltimate)) }
        Appliquer = {
            $actuel = Get-ModeAlimentationActif
            if ($actuel -and ($actuel.Guid -eq $GuidUltimateCopie -or $actuel.Nom -match $NomsUltimate)) {
                Write-Info (T 'alim.deja')
                return
            }
            $guid = Find-ModeUltimate
            if (-not $guid) {
                $null = powercfg /duplicatescheme $GuidUltimateSource $GuidUltimateCopie
                if (Test-ModeAlimentation $GuidUltimateCopie) { $guid = $GuidUltimateCopie }
            }
            if ($guid) {
                $null = powercfg /setactive $guid
                if ($LASTEXITCODE -ne 0) { throw (T 'alim.err') }
            } else {
                # Certains PC (souvent les portables récents) ne proposent pas ce mode.
                $null = powercfg /setactive $GuidHautePerf
                if ($LASTEXITCODE -eq 0) { Write-Info (T 'alim.hp') }
                else { Write-Info (T 'alim.aucun') }
            }
        }
    }
    [pscustomobject]@{
        Cle = 'hags'; Groupe = 'g.perf'
        Indispo = { if (-not $script:EstAdmin) { 'ADMIN' } else { $null } }
        Actif = { (Get-RegValeur 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode') -eq 2 }
        Appliquer = {
            Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 2
            Write-Info (T 'hags.info')
        }
    }
    [pscustomobject]@{
        Cle = 'jeu'; Groupe = 'g.jeu'
        Indispo = { $null }
        Actif = { (Get-RegValeur 'HKCU:\Software\Microsoft\GameBar' 'AutoGameModeEnabled') -ne 0 }
        Appliquer = {
            Set-Reg 'HKCU:\Software\Microsoft\GameBar' 'AllowAutoGameMode' 'DWord' 1
            Set-Reg 'HKCU:\Software\Microsoft\GameBar' 'AutoGameModeEnabled' 'DWord' 1
        }
    }
    [pscustomobject]@{
        Cle = 'bar'; Groupe = 'g.jeu'
        Indispo = { $null }
        Actif = {
            (Get-RegValeur 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled') -eq 0 -and
            (Get-RegValeur 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled') -eq 0
        }
        Appliquer = {
            Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 'DWord' 0
            Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 'DWord' 0
            Set-Reg 'HKCU:\Software\Microsoft\GameBar' 'UseNexusForGameBarEnabled' 'DWord' 0
            Set-Reg 'HKCU:\Software\Microsoft\GameBar' 'ShowStartupPanel' 'DWord' 0
        }
    }
    [pscustomobject]@{
        Cle = 'fen'; Groupe = 'g.jeu'
        Indispo = { $null }
        Actif = { (Get-RegValeur 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences' 'DirectXUserGlobalSettings') -match 'SwapEffectUpgradeEnable=1' }
        Appliquer = {
            # La valeur contient plusieurs réglages « clé=valeur; » : on ne touche qu'au nôtre.
            $chemin = 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences'
            $actuel = [string](Get-RegValeur $chemin 'DirectXUserGlobalSettings')
            $autres = @($actuel -split ';' | Where-Object { $_ -and $_ -notmatch '^SwapEffectUpgradeEnable=' })
            $nouveau = (($autres + 'SwapEffectUpgradeEnable=1') -join ';') + ';'
            Set-Reg $chemin 'DirectXUserGlobalSettings' 'String' $nouveau
        }
    }
    [pscustomobject]@{
        Cle = 'sou'; Groupe = 'g.jeu'
        Indispo = { $null }
        Actif = { (Get-RegValeur 'HKCU:\Control Panel\Mouse' 'MouseSpeed') -eq '0' }
        Appliquer = {
            Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseSpeed' 'String' '0'
            Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' 'String' '0'
            Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' 'String' '0'
            Update-Souris
        }
    }
    [pscustomobject]@{
        Cle = 'vis'; Groupe = 'g.win'
        Indispo = { $null }
        Actif = { (Get-RegValeur 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting') -eq 2 }
        Appliquer = {
            Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' 'DWord' 2
            Set-Reg 'HKCU:\Control Panel\Desktop' 'UserPreferencesMask' 'Binary' ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
            Set-Reg 'HKCU:\Control Panel\Desktop\WindowMetrics' 'MinAnimate' 'String' '0'
            Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAnimations' 'DWord' 0
        }
    }
    [pscustomobject]@{
        Cle = 'exp'; Groupe = 'g.win'
        Indispo = { $null }
        Actif = { (Get-RegValeur 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSyncProviderNotifications') -eq 0 }
        Appliquer = { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSyncProviderNotifications' 'DWord' 0 }
    }
    [pscustomobject]@{
        Cle = 'men'; Groupe = 'g.win'
        Indispo = { $null }
        Actif = { (Get-RegValeur 'HKCU:\Control Panel\Desktop' 'MenuShowDelay') -eq '0' }
        Appliquer = { Set-Reg 'HKCU:\Control Panel\Desktop' 'MenuShowDelay' 'String' '0' }
    }
    [pscustomobject]@{
        Cle = 'one'; Groupe = 'g.win'
        Indispo = { if (-not (Get-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' 'OneDrive')) { 'N/A' } else { $null } }
        Actif = { $v = Get-RegValeur 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run' 'OneDrive'; [bool]($v -and ($v[0] -band 1)) }
        Appliquer = {
            Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run' 'OneDrive' 'Binary' ([byte[]](0x03,0,0,0,0,0,0,0,0,0,0,0))
        }
    }
)

# Nom et description de chaque module dans la langue choisie
function Update-TextesModules {
    foreach ($m in $Modules) {
        $m | Add-Member -NotePropertyName Nom -NotePropertyValue (T "m.$($m.Cle).n") -Force
        $m | Add-Member -NotePropertyName Description -NotePropertyValue (T "m.$($m.Cle).d") -Force
    }
}
Update-TextesModules

# ===========================================================================
#  RESTAURATION
# ===========================================================================

# Remet les réglages d'origine, c'est-à-dire ceux d'avant la toute première utilisation
# du script : on lit toutes les sauvegardes, de la plus ancienne à la plus récente, et
# pour chaque réglage on garde la première valeur notée.
function Invoke-Restauration {
    Clear-Host
    Show-Barre
    Write-Titre "SYS://ROLLBACK"
    $fichiers = @(Get-ChildItem -Path $DossierSauvegarde -Filter 'sauvegarde-*.json' -ErrorAction SilentlyContinue | Sort-Object Name)
    if ($fichiers.Count -eq 0) {
        Write-Erreur (T 'r.aucune' $DossierSauvegarde)
        Wait-Fin
        exit 1
    }
    Write-Info (T 'r.de' $fichiers.Count)
    $origine = [ordered]@{}
    $modeOrigine = $null
    foreach ($fi in $fichiers) {
        try { $sauvegarde = Get-Content -LiteralPath $fi.FullName -Raw -Encoding UTF8 | ConvertFrom-Json }
        catch { Write-Erreur "$($fi.Name) : $($_.Exception.Message)"; continue }
        if (-not $modeOrigine -and $sauvegarde.ModeAlimentation) { $modeOrigine = $sauvegarde.ModeAlimentation }
        foreach ($v in @($sauvegarde.Registre)) {
            if (-not $v) { continue }
            $cle = "$($v.Chemin)|$($v.Nom)"
            if (-not $origine.Contains($cle)) { $origine[$cle] = $v }   # la première valeur notée = l'origine
        }
    }
    $valeurs = @($origine.Values)
    foreach ($v in $valeurs) {
        try {
            if ($v.Existait) {
                $data = $v.Valeur
                if ($v.Type -eq 'Binary') { $data = [byte[]]@($data) }
                if (-not (Test-Path $v.Chemin)) { New-Item -Path $v.Chemin -Force | Out-Null }
                New-ItemProperty -Path $v.Chemin -Name $v.Nom -PropertyType $v.Type -Value $data -Force | Out-Null
            } elseif (Test-Path $v.Chemin) {
                Remove-ItemProperty -Path $v.Chemin -Name $v.Nom -ErrorAction SilentlyContinue
            }
        } catch {
            if ($v.Chemin -like 'HKLM:*' -and -not $script:EstAdmin) {
                Write-Erreur (T 'r.admin' $v.Nom)
            } else {
                Write-Erreur "$($v.Chemin)\$($v.Nom) : $($_.Exception.Message)"
            }
        }
    }
    Write-Ok (T 'r.ok')
    if ($valeurs | Where-Object { $_.Chemin -like '*Control Panel\Mouse' }) {
        try { Update-Souris; Write-Ok (T 'r.souris') } catch { Write-Erreur (T 'r.souris.err' $_.Exception.Message) }
    }

    if ($modeOrigine -and (Test-ModeAlimentation $modeOrigine)) {
        $null = powercfg /setactive $modeOrigine
        if ($LASTEXITCODE -eq 0) { Write-Ok (T 'r.alim') }
        else { Write-Erreur (T 'r.alim.err') }
    }

    Write-Host ("  {0}│{1}" -f $C.Cadre, $C.Reset)
    if ($script:Erreurs -eq 0) { Write-Terminal ("  └─> " + (T 'r.fin')) 'Green' }
    else { Write-Terminal ("  └─> " + (T 'r.fin.err' $script:Erreurs)) 'Red' }
    Write-Host ("      " + (T 'r.deco')) -ForegroundColor Yellow
    Wait-Fin
    exit 0
}

if ($Restaurer) { Invoke-Restauration }

# ===========================================================================
#  AFFICHAGE DES CADRES
# ===========================================================================

$LargeurMenu = 68   # largeur intérieure du cadre, en cases

# Une ligne du cadre : │ contenu │  (le contenu est complété à la bonne largeur)
function Format-Ligne($visible, $couleur = '', $fond = '') {
    return ("  {0}│{1}{2}{3}{4}{0}│{4}" -f $C.Cadre, $fond, $couleur, (Format-Largeur $visible $LargeurMenu), $C.Reset)
}

# Haut du cadre : ┌─[ TITRE ]──────── texte à droite ─┐
function Format-Haut($titre, $droite) {
    $gauche = "─[ $titre ]"
    $droite = " $droite ─"
    $tirets = [math]::Max(1, $LargeurMenu - (Get-Largeur $gauche) - (Get-Largeur $droite))
    return ("  {0}┌{1}{2}{3}┐{4}" -f $C.Cadre, $gauche, ('─' * $tirets), $droite, $C.Reset)
}

# Panneau de 2 lignes en bas du cadre
function Add-Panneau($lignes, $texte, $couleur) {
    $W = $LargeurMenu
    $lignes.Add(("  {0}├{1}┤{2}" -f $C.Cadre, ('─' * $W), $C.Reset))
    $desc = @(Split-Texte $texte ($W - 4))
    if ($desc.Count -eq 0) { $desc = @('') }
    $desc[0] = "> $($desc[0])"
    for ($j = 1; $j -lt $desc.Count; $j++) { $desc[$j] = "  $($desc[$j])" }   # retrait sous le texte
    while ($desc.Count -lt 2) { $desc += '' }
    foreach ($d in $desc[0..1]) { $lignes.Add((Format-Ligne " $d" $couleur)) }
    $lignes.Add(("  {0}└{1}┘{2}" -f $C.Cadre, ('─' * $W), $C.Reset))
}

# Affiche des lignes. Dans une vraie console, elles sont redessinées à la même place.
function Write-Lignes($lignes) {
    if ($script:Interactif) {
        $texte = ($lignes | ForEach-Object { $_ + $(if ($script:VT) { "$E[K" } else { '' }) }) -join "`r`n"
        [Console]::SetCursorPosition(0, $script:HautMenu)
        [Console]::Write($texte)
    } else {
        $lignes | ForEach-Object { Write-Host $_ }
    }
}

function Start-Ecran {
    Clear-Host
    Show-Barre
    Write-Host ""
    $script:HautMenu = 0
    if ($script:Interactif) {
        $script:HautMenu = [Console]::CursorTop
        [Console]::CursorVisible = $false
        [Console]::TreatControlCAsInput = $true   # Ctrl+C arrive comme une touche : le menu quitte proprement
    }
}

function Stop-Ecran {
    if ($script:Interactif) { [Console]::CursorVisible = $true; [Console]::TreatControlCAsInput = $false }
}

function Exit-SansModif {
    Stop-Ecran
    Write-Host ""
    Write-Terminal ("  " + (T 'quitte')) 'DarkGray'
    Restore-Console
    exit 0
}

# ===========================================================================
#  CHOIX DE LA LANGUE
# ===========================================================================

function Get-LignesLangues($selection) {
    $lignes = New-Object System.Collections.Generic.List[string]
    $lignes.Add((Format-Haut 'SYS://LANG' "$($selection + 1)/$($OrdreLangues.Count)"))
    for ($i = 0; $i -lt $OrdreLangues.Count; $i++) {
        $code = $OrdreLangues[$i]
        $nom = $Textes[$code]['nom']
        $curseur = if ($i -eq $selection) { ' ▶ ' } else { '   ' }
        $visible = "$curseur[$($code.ToUpper())] $nom"
        if ($i -eq $selection) { $lignes.Add((Format-Ligne $visible $C.Rose $C.FondSel)) }
        else { $lignes.Add((Format-Ligne $visible $C.Texte)) }
    }
    # Le titre et l'aide s'affichent dans la langue sélectionnée
    $code = $OrdreLangues[$selection]
    Add-Panneau $lignes $Textes[$code]['lang.titre'] $C.Ambre
    $lignes.Add(("  {0}{1}{2}" -f $C.Gris, $Textes[$code]['lang.aide'], $C.Reset))
    return $lignes
}

function Select-Langue {
    $selection = [math]::Max(0, [array]::IndexOf($OrdreLangues, $script:L))
    Start-Ecran
    try {
        while ($true) {
            Write-Lignes (Get-LignesLangues $selection)
            $t = Read-Touche
            if ($t -eq 'Haut') { $selection = ($selection - 1 + $OrdreLangues.Count) % $OrdreLangues.Count }
            elseif ($t -eq 'Bas') { $selection = ($selection + 1) % $OrdreLangues.Count }
            elseif ($t -eq 'Entree') { break }
            elseif ($t -eq 'Q') { Exit-SansModif }
        }
    } finally { Stop-Ecran }
    $script:L = $OrdreLangues[$selection]
    Update-TextesModules
}

# ===========================================================================
#  MENU DES MODULES
# ===========================================================================

# État de chaque module au lancement
foreach ($m in $Modules) {
    $raison = & $m.Indispo
    $actif = $false
    try { $actif = [bool](& $m.Actif) } catch { }
    $m | Add-Member -NotePropertyName Raison -NotePropertyValue $raison
    $m | Add-Member -NotePropertyName EtaitActif -NotePropertyValue $actif
    # Par défaut : on coche tout ce qui n'est pas déjà fait et qui est possible
    $m | Add-Member -NotePropertyName Choisi -NotePropertyValue (-not $raison -and -not $actif)
}

function Get-LignesMenu($selection, $message) {
    $W = $LargeurMenu
    $lignes = New-Object System.Collections.Generic.List[string]
    $nbActifs = @($Modules | Where-Object EtaitActif).Count
    $nbChoisis = @($Modules | Where-Object Choisi).Count
    $lignes.Add((Format-Haut 'SYS://MODULES' (T 'compteur' $nbActifs $Modules.Count $nbChoisis)))

    $groupe = ''
    for ($i = 0; $i -lt $Modules.Count; $i++) {
        $m = $Modules[$i]
        if ($m.Groupe -ne $groupe) {
            $groupe = $m.Groupe
            $lignes.Add((Format-Ligne "  ◆ $(T $groupe)" $C.Rose))
        }
        $curseur = if ($i -eq $selection) { ' ▶ ' } else { '   ' }
        $case = if ($m.Raison) { '[·]' } elseif ($m.Choisi) { '[■]' } else { '[ ]' }
        if ($m.Raison -eq 'ADMIN')  { $etat = T 'e.admin'; $couleurEtat = $C.Gris }
        elseif ($m.Raison)          { $etat = T 'e.na';    $couleurEtat = $C.Gris }
        elseif ($m.EtaitActif)      { $etat = T 'e.actif'; $couleurEtat = $C.Vert }
        else                        { $etat = T 'e.todo';  $couleurEtat = $C.Ambre }

        # Colonnes : curseur (3) + case (3) + espace (1) + nom (47) + état (14) = 68
        $fond = if ($i -eq $selection) { $C.FondSel } else { '' }
        $couleurNom = if ($i -eq $selection) { $C.Rose } elseif ($m.Raison) { $C.Gris } else { $C.Texte }
        $couleurCase = if ($m.Choisi) { $C.Rose } else { $C.Gris }
        $nom = Format-Largeur $m.Nom ($W - 14 - 7)
        $etat = Format-Largeur $etat 14
        $lignes.Add("  $($C.Cadre)│$fond$couleurNom$curseur$couleurCase$case $couleurNom$nom$couleurEtat$etat$($C.Reset)$($C.Cadre)│$($C.Reset)")
    }

    # Panneau : description du module sélectionné, ou message de confirmation
    $m = $Modules[$selection]
    if ($message) { Add-Panneau $lignes $message $C.Ambre }
    elseif ($m.Raison -eq 'ADMIN') { Add-Panneau $lignes (T 'v.admin') $C.Gris }
    elseif ($m.Raison) { Add-Panneau $lignes (T 'v.na') $C.Gris }
    else { Add-Panneau $lignes $m.Description $C.Texte }
    $lignes.Add(("  {0}{1}{2}" -f $C.Gris, (T 'aide'), $C.Reset))
    return $lignes
}

if (-not $Tout) {
    Show-Portrait
    Show-Intro
    Show-Boot
    if (-not $Langue) { Select-Langue }
    Start-Ecran
    $selection = 0
    try {
        while ($true) {
            Write-Lignes (Get-LignesMenu $selection)
            $t = Read-Touche
            if ($t -eq 'Haut') { $selection = ($selection - 1 + $Modules.Count) % $Modules.Count }
            elseif ($t -eq 'Bas') { $selection = ($selection + 1) % $Modules.Count }
            elseif ($t -eq 'Espace') { $m = $Modules[$selection]; if (-not $m.Raison) { $m.Choisi = -not $m.Choisi } }
            elseif ($t -eq 'A') { $Modules | Where-Object { -not $_.Raison } | ForEach-Object { $_.Choisi = $true } }
            elseif ($t -eq 'N') { $Modules | ForEach-Object { $_.Choisi = $false } }
            elseif ($t -eq 'Q') { Exit-SansModif }
            elseif ($t -eq 'R') {
                # Remettre les réglages d'origine (ceux d'avant le script)
                if (-not (Get-ChildItem -Path $DossierSauvegarde -Filter 'sauvegarde-*.json' -ErrorAction SilentlyContinue)) {
                    Write-Lignes (Get-LignesMenu $selection (T 'r.aucune' $DossierSauvegarde)); [void](Read-Touche); continue
                }
                Write-Lignes (Get-LignesMenu $selection (T 'confirm.r'))
                $ok = Read-Touche
                if ('O', 'Y', 'J', 'S' -contains $ok) { $script:VersOrigine = $true; break }
            }
            elseif ($t -eq 'Entree') {
                $nb = @($Modules | Where-Object Choisi).Count
                if ($nb -eq 0) { Write-Lignes (Get-LignesMenu $selection (T 'aucun')); [void](Read-Touche); continue }
                Write-Lignes (Get-LignesMenu $selection (T 'confirm' $nb))
                $ok = Read-Touche
                # Oui = O (oui), Y (yes), J (ja), S (sí)
                if ('O', 'Y', 'J', 'S' -contains $ok) { break }
            }
        }
    } finally { Stop-Ecran }
    if ($script:VersOrigine) { Invoke-Restauration }
} else {
    $Modules | Where-Object { -not $_.Raison } | ForEach-Object { $_.Choisi = $true }
}

# ===========================================================================
#  INJECTION
# ===========================================================================

$aFaire = @($Modules | Where-Object Choisi)
$modeAvant = Get-ModeAlimentationActif

Clear-Host
Show-Barre
Write-Titre "SYS://INJECTION"
Write-Terminal ("  │ " + (T 'connexion')) 'DarkGreen'
Write-Terminal ("  │ " + (T 'cible' "$env:USERNAME@$env:COMPUTERNAME")) 'DarkGreen'

for ($i = 0; $i -lt $aFaire.Count; $i++) {
    $m = $aFaire[$i]
    Show-Progression ($i + 1) $aFaire.Count $m.Nom
    try {
        & $m.Appliquer
        Write-Ok $m.Nom
    } catch {
        Write-Erreur "$($m.Nom) : $($_.Exception.Message)"
    }
}
foreach ($m in @($Modules | Where-Object Raison)) {
    $pourquoi = if ($m.Raison -eq 'ADMIN') { T 'ign.admin' } else { T 'ign.na' }
    Write-Info (T 'ignore' $m.Nom $pourquoi)
}

# Sauvegarde des anciennes valeurs
try {
    New-Item -ItemType Directory -Path $DossierSauvegarde -Force | Out-Null
    $fichier = Join-Path $DossierSauvegarde ("sauvegarde-{0:yyyy-MM-dd_HH-mm-ss}.json" -f (Get-Date))
    [pscustomobject]@{ ModeAlimentation = $(if ($modeAvant) { $modeAvant.Guid } else { $null }); Registre = $script:Anciennes } |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $fichier -Encoding UTF8
    Write-Ok (T 'sauve' $fichier)
} catch { Write-Erreur (T 'sauve.err' $_.Exception.Message) }

# Message de fin
Write-Host ("  {0}│{1}" -f $C.Cadre, $C.Reset)
if ($script:Erreurs -eq 0) {
    Write-Terminal ("  └─> " + (T 'fin' $aFaire.Count)) 'Green'
} else {
    Write-Terminal ("  └─> " + (T 'fin.err' $script:Erreurs)) 'Red'
}
Write-Host ("      " + (T 'redem')) -ForegroundColor Yellow
Write-Host ("      " + (T 'annul')) -ForegroundColor Yellow
Write-Host ("`n      {0}github.com/JohnWish01{1}" -f $C.Cadre, $C.Reset)
Wait-Fin
