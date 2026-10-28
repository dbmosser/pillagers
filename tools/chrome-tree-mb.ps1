# chrome-tree-mb.ps1 -Port N : MB held by the whole test Chrome on that debugging port (the browser plus every process that shares its
# --user-data-dir). 10-28: health.sh step 2b counted only the one process with the port flag (about 100 MB while the tree held 3.6 GB),
# so the gate browser restart never fired and the Codex lane sat waiting for RAM.
param([int]$Port = 9346)
$all = @(Get-CimInstance Win32_Process -Filter "Name='chrome.exe'")
$b = $all | Where-Object { [string]$_.CommandLine -match ('remote-debugging-port=' + $Port + '(\s|$)') -and [string]$_.CommandLine -notmatch '--type=' } | Select-Object -First 1
if (-not $b) { Write-Output 0; exit 0 }
$u = [regex]::Match([string]$b.CommandLine, '--user-data-dir="?([^" ]+)').Groups[1].Value
$t = [long]0
foreach ($p in $all) { if ($u -and ([string]$p.CommandLine -match ([regex]::Escape($u) + '("|\s|$)'))) { $t += $p.WorkingSetSize } }
Write-Output ([int]($t / 1MB))
