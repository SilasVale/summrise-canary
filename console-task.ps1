$ErrorActionPreference = 'Stop'
$t = Get-ScheduledTask -TaskName 'SummriseConsole'
# The console is a control plane: a task Windows stops after 72 hours, with restart disabled, is a
# console that dies on the third day and stays dead.
$t.Settings.ExecutionTimeLimit = 'PT0S'
$t.Settings.RestartCount = 3
$t.Settings.RestartInterval = 'PT1M'
$t.Settings.StartWhenAvailable = $true
Set-ScheduledTask -TaskName 'SummriseConsole' -Settings $t.Settings | Out-Null
$v = (Get-ScheduledTask -TaskName 'SummriseConsole').Settings
Write-Output ("ExecutionTimeLimit=" + $v.ExecutionTimeLimit + " RestartCount=" + $v.RestartCount + " RestartInterval=" + $v.RestartInterval + " StartWhenAvailable=" + $v.StartWhenAvailable)
