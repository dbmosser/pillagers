# Prints ACTIVE or STALLED for the hourly watchdog task, plus the facts behind it. Read-only; changes nothing.
# ACTIVE: a Claude session wrote tools\handoff\heartbeat.txt in the last 45 minutes (it is working; do nothing).
$root='C:\claudecode\dark raiders'; $hb="$root\tools\handoff\heartbeat.txt"
$hbMin=if(Test-Path $hb){ [int]((Get-Date)-(Get-Item $hb).LastWriteTime).TotalMinutes }else{ 9999 }
$ct=[int64](git -C $root log -1 --format=%ct); $cMin=[int]((Get-Date).ToUniversalTime()-[DateTimeOffset]::FromUnixTimeSeconds($ct).UtcDateTime).TotalMinutes
$idle=powershell -NoProfile -ExecutionPolicy Bypass -File "$root\tools\idle.ps1"
$free=[math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB,1)
$srv=try{ (Invoke-WebRequest http://localhost:8802/dark_raiders.html -UseBasicParsing -TimeoutSec 3).StatusCode -eq 200 }catch{ $false }
$v=if($hbMin -le 45){ 'ACTIVE' }else{ 'STALLED' }
"$v heartbeat $hbMin min ago, last commit $cMin min ago, he last touched the PC $idle s ago, free RAM $free GB, play server up: $srv"
