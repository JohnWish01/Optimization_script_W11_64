
# Active le mode Ultimate Performance / Deactivate Ultimate performance mode
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

# Active le Game Mode / Activate Game Mode
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f

# Désactive la Xbox Game Bar / Deactivate Xbox Game Bar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f

# Désactive les effets visuels inutiles / Deactivate useless visual effect 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f

# Désactive les suggestions et pubs dans l’explorateur / Deactivate ads and suggestions in explorer
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d 0 /f

# Réduction du délai de réponse des menus / Reduction of menus response delays 
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d 0 /f

# Supprime les apps inutiles du démarrage (OneDrive, etc.) / Delete useless startup apps (OneDrive, etc..)
Get-CimInstance Win32_StartupCommand | Where-Object { $_.Command -like "*onedrive*" } | ForEach-Object { $_.Delete() }

# Affiche un message de fin / Displays an end message
Write-Host "Optimisation Windows pour le gaming terminée ! Redémarre ton PC pour appliquer tous les réglages." -ForegroundColor Green
