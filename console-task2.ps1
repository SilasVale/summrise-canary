$ErrorActionPreference = 'Stop'
$cmd = @'
@echo off
tasklist /FI "IMAGENAME eq summrise-console.exe" 2>nul | find /I "summrise-console.exe" >nul
if not errorlevel 1 exit /b 0
C:\SummriseConsole\summrise-console.exe --operator-token-file C:\SummriseConsole\operator.token --grant-key-file C:\SummriseConsole\grant.seed --data C:\SummriseConsole --bind 0.0.0.0 --port 19000
'@
Set-Content -Path 'C:\SummriseConsole\run-console.cmd' -Value $cmd -Encoding ASCII

$action = New-ScheduledTaskAction -Execute 'C:\SummriseConsole\run-console.cmd'
$boot = New-ScheduledTaskTrigger -AtStartup
$tick = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 3650)
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -ExecutionTimeLimit ([TimeSpan]::Zero) -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName 'SummriseConsole' -Action $action -Trigger $boot,$tick -Settings $settings -User 'SYSTEM' -RunLevel Highest -Force | Out-Null
$t = Get-ScheduledTask -TaskName 'SummriseConsole'
Write-Output ("triggers=" + $t.Triggers.Count + " limit=" + $t.Settings.ExecutionTimeLimit + " multiple=" + $t.Settings.MultipleInstances + " restart=" + $t.Settings.RestartCount)
Start-ScheduledTask -TaskName 'SummriseConsole'
Start-Sleep -Seconds 5
(Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:19000/health' -TimeoutSec 10).Content
