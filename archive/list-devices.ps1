$ErrorActionPreference = 'Stop'
$base = 'https://console.saisi.online'
$tok = (Get-Content 'C:\SummriseConsole\operator.token' -Raw).Trim()
$a = Invoke-RestMethod -Uri "$base/auth" -Method Post -ContentType 'application/json' -Body (ConvertTo-Json @{token=$tok}) -TimeoutSec 60
$h = @{Authorization=('Bearer '+$a.token)}
$d = Invoke-RestMethod -Uri "$base/devices" -Method Get -Headers $h -TimeoutSec 60
Write-Output ("count: " + @($d).Count)
foreach ($x in $d) {
  $name = $x.name
  if (-not $name) { $name = '(no name)' }
  Write-Output ("- " + $name + "  id=" + $x.id.Substring(0,12) + "…  last_seen_ms=" + $x.last_seen_ms)
}
