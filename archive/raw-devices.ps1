$ErrorActionPreference = 'Stop'
$base = 'https://console.saisi.online'
$tok = (Get-Content 'C:\SummriseConsole\operator.token' -Raw).Trim()
$a = Invoke-RestMethod -Uri "$base/auth" -Method Post -ContentType 'application/json' -Body (ConvertTo-Json @{token=$tok}) -TimeoutSec 60
$h = @{Authorization=('Bearer '+$a.token)}
$d = Invoke-RestMethod -Uri "$base/devices" -Method Get -Headers $h -TimeoutSec 60
foreach ($x in $d) { Write-Output ("name=" + $x.name + " online=" + $x.online + " version=" + $x.version + " seen=" + $x.last_seen_ms) }
