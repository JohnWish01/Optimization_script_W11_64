
# Matrix-style loading animation
function Show-MatrixLoading {
    $symbols = @('#','%','$','@','&','!','+','=','*')
    $lines = 12
    $columns = 60
    for ($i = 0; $i -lt $lines; $i++) {
        $line = ""
        for ($j = 0; $j -lt $columns; $j++) {
            $char = $symbols | Get-Random
            $line += $char
        }
        Write-Host $line -ForegroundColor Green
        Start-Sleep -Milliseconds 80
    }
    Start-Sleep -Milliseconds 300
    Clear-Host
}

Show-MatrixLoading



# Logo ASCII
Write-Host ""
Write-Host "         ██╗ ██████╗ ██╗  ██╗███╗   ██╗    ██╗    ██╗██╗███████╗██╗  ██╗" -ForegroundColor Green
Write-Host "         ██║██╔═══██╗██║  ██║████╗  ██║    ██║    ██║██║██╔════╝██║  ██║" -ForegroundColor Green
Write-Host "         ██║██║   ██║███████║██╔██╗ ██║    ██║ █╗ ██║██║███████╗███████║" -ForegroundColor Green
Write-Host "    ██   ██║██║   ██║██╔══██║██║╚██╗██║    ██║███╗██║██║╚════██║██╔══██║" -ForegroundColor Green
Write-Host "    ╚█████╔╝╚██████╔╝██║  ██║██║ ╚████║    ╚███╔███╔╝██║███████║██║  ██║" -ForegroundColor Green
Write-Host "     ╚════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝     ╚══╝╚══╝ ╚═╝╚══════╝╚═╝  ╚═╝" -ForegroundColor DarkGreen
Write-Host "               >>===[ J O H N   W I S H   D E V ]===<<" -ForegroundColor Yellow
Write-Host "        █▓▒░   ⚡ Windows Gaming Optimization Script ⚡   ░▒▓█" -ForegroundColor Cyan
Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# Active le mode Ultimate Performance
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

# Active le Game Mode
reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 1 /f

# Désactive la Xbox Game Bar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 1 /f

# Désactive les effets visuels inutiles
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f

# Désactive les suggestions et pubs dans l’explorateur
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d 0 /f

# Réduction du délai de réponse des menus
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d 0 /f

# Supprime les apps inutiles du démarrage
Get-CimInstance Win32_StartupCommand | Where-Object { $_.Command -like "*onedrive*" } | ForEach-Object { $_.Delete() }

# Message de fin
Write-Host "`n[✔] Optimisation Windows pour le gaming terminée !" -ForegroundColor Green
Write-Host "[ℹ] Redémarre ton PC pour appliquer tous les réglages." -ForegroundColor Yellow
Write-Host "`nCreated by John Wish - 2025" -ForegroundColor Cyan
