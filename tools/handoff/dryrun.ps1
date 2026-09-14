param([string]$Prev, [string]$New)
# dryrun.ps1 -Prev 1366 -New 1367
# Applies p<New> and f<New> to a scratch copy of the previous build (the previous dry copy if one
# exists, else HEAD, which is right once Prev has shipped) and builds two fixtures for :8803:
#   tools\fxdry<NN>.html  the drafted build with its checks    (run the new check twice: PASS)
#   tools\fxctl<NN>.html  the previous build with the new checks (run the new check once: FAIL)
# Both names are in .git/info/exclude; ship.sh commit deletes only fx[0-9]*.html.
$root = 'C:\claudecode\dark raiders'; $h = "$root\tools\handoff"
$base = Join-Path $env:TEMP 'pillagers-dry'
$a = "$base\dry$Prev"; $sp = "$base\dry$New"
if (-not (Test-Path "$a\dark_raiders.html")) {
  New-Item -ItemType Directory -Force $a | Out-Null
  Copy-Item "$root\dark_raiders.html" "$a\dark_raiders.html" -Force; Copy-Item "$root\tools\mkfixture.ps1" "$a\mkfixture.ps1" -Force
}
New-Item -ItemType Directory -Force $sp | Out-Null
Copy-Item "$a\dark_raiders.html" "$sp\dark_raiders.html" -Force; Copy-Item "$a\mkfixture.ps1" "$sp\mkfixture.ps1" -Force
foreach ($f in "p$New", "f$New") {
  $t = [IO.File]::ReadAllText("$h\$f.ps1").Replace("$root\dark_raiders.html", "$sp\dark_raiders.html").Replace("$root\tools\mkfixture.ps1", "$sp\mkfixture.ps1")
  [IO.File]::WriteAllText("$sp\$f.ps1", $t, (New-Object Text.UTF8Encoding $false))
  Write-Output "$f -> $(powershell -NoProfile -ExecutionPolicy Bypass -File "$sp\$f.ps1")"
}
$n2 = $New.Substring(2)
Write-Output ("dry: " + (powershell -NoProfile -ExecutionPolicy Bypass -File "$sp\mkfixture.ps1" -Src "$sp\dark_raiders.html" -Dst "$root\tools\fxdry$n2.html" 2>&1 | Select-Object -Last 1))
Write-Output ("ctl: " + (powershell -NoProfile -ExecutionPolicy Bypass -File "$sp\mkfixture.ps1" -Src "$a\dark_raiders.html" -Dst "$root\tools\fxctl$n2.html" 2>&1 | Select-Object -Last 1))
