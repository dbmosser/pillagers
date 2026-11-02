param([string]$Tag,[switch]$NoFixture,[string]$Root='C:\claudecode\dark raiders')
# 11-02 (remote gate, tools/handoff/gate-remote.sh): -NoFixture applies the patches only (the shipper; the test copies are built on the spare PC);
# -Root is the copy to work from (the spare PC's gate copy). The p and f files always name the usual path, so that path is what gets replaced.
# dryrun-pf.ps1 -Tag pfa (2026-10-17, for preflight.sh): dryrun.ps1 under a private tag. Applies p<Tag>.ps1 and f<Tag>.ps1 to a
# scratch copy of the CURRENT game and fixture and builds tools\fxdry<Tag>.html (the drafted build with its checks) and
# tools\fxctl<Tag>.html (the current build with the new checks). Nothing in the repo changes.
$named = 'C:\claudecode\dark raiders'; $root = $Root; $h = "$root\tools\handoff"
$sp = Join-Path $env:TEMP ('pillagers-dry\pf' + $Tag)
Remove-Item -Recurse -Force $sp -ErrorAction SilentlyContinue; New-Item -ItemType Directory -Force $sp | Out-Null
Copy-Item "$root\dark_raiders.html" "$sp\base.html" -Force; Copy-Item "$sp\base.html" "$sp\dark_raiders.html" -Force
Copy-Item "$root\tools\mkfixture.ps1" "$sp\mkfixture.ps1" -Force
foreach ($f in "p$Tag", "f$Tag") {
  $t = [IO.File]::ReadAllText("$h\$f.ps1").Replace("$named\dark_raiders.html", "$sp\dark_raiders.html").Replace("$named\tools\mkfixture.ps1", "$sp\mkfixture.ps1")
  [IO.File]::WriteAllText("$sp\$f.ps1", $t, (New-Object Text.UTF8Encoding $false))
  Write-Output "$f -> $(powershell -NoProfile -ExecutionPolicy Bypass -File "$sp\$f.ps1")"
}
if ($NoFixture) { exit 0 }
Write-Output ("dry: " + (powershell -NoProfile -ExecutionPolicy Bypass -File "$sp\mkfixture.ps1" -Src "$sp\dark_raiders.html" -Dst "$root\tools\fxdry$Tag.html" 2>&1 | Select-Object -Last 1))
Write-Output ("ctl: " + (powershell -NoProfile -ExecutionPolicy Bypass -File "$sp\mkfixture.ps1" -Src "$sp\base.html" -Dst "$root\tools\fxctl$Tag.html" 2>&1 | Select-Object -Last 1))
