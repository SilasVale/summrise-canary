$ErrorActionPreference = 'Stop'
$id = '4c718d6e44c83388c7e07bd0d811fa0b7cf22e2fced85d35d0021dd26b11f687'
$base = 'https://console.saisi.online'
$tok = (Get-Content 'C:\SummriseConsole\operator.token' -Raw).Trim()
$sw = [Diagnostics.Stopwatch]::StartNew()
$a = Invoke-RestMethod -Uri "$base/auth" -Method Post -ContentType 'application/json' -Body (ConvertTo-Json @{token=$tok}) -TimeoutSec 90
Write-Output ("auth: " + $sw.ElapsedMilliseconds + " ms")
$h = @{Authorization=('Bearer '+$a.token)}
$g = Invoke-RestMethod -Uri "$base/grants" -Method Post -Headers $h -ContentType 'application/json' -Body (ConvertTo-Json @{device_id=$id;tools=@('state.get');expires_in_s=300}) -TimeoutSec 90
Write-Output ("grant: " + $sw.ElapsedMilliseconds + " ms")
$b = @{device_id=$id;grant=$g;request=@{jsonrpc='2.0';id=1;method='tools/call';params=@{name='state.get';arguments=@{}}}}
$r = Invoke-RestMethod -Uri "$base/mcp" -Method Post -Headers $h -ContentType 'application/json' -Body (ConvertTo-Json $b -Depth 8) -TimeoutSec 90
Write-Output ("mcp: " + $sw.ElapsedMilliseconds + " ms")
Write-Output ('STATE: ' + $r.result.content[0].text.Substring(0, [Math]::Min(160, $r.result.content[0].text.Length)))
