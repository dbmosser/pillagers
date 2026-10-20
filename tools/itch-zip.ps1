# itch-zip.ps1 (2026-10-20): builds tools\publish\pillagers-web.zip for itch. Called by tools/handoff/ship.sh (every ship) and
# tools/itch-daily.sh (the daily catch-up), so both upload the same thing:
#   index.html                 the game (the caller copies dark_raiders.html there first)
#   attract.mp4 / attract.webm the title's gameplay clip, when one sits beside the game (v21.17)
#   the licence texts          that must travel with the game (tools/PUBLISH.md): tools\fonts\OFL-*.txt for the five embedded fonts and
#                              tools\sounds\*.txt for the recorded sounds. They sit at the top of the zip beside index.html, because
#                              Windows PowerShell 5.1 writes folder entries with backslashes, which other unzippers misread.
# Exits 1 (and leaves the old zip alone) if the game or the licence files are missing, so a broken zip is never uploaded.
param([string]$Root = 'C:\claudecode\dark raiders')
$ErrorActionPreference = 'Stop'
$pub = Join-Path $Root 'tools\publish'
$game = Join-Path $pub 'index.html'
if (-not (Test-Path $game)) { Write-Output 'itch-zip: tools\publish\index.html is missing'; exit 1 }
$p = @($game)
foreach ($f in 'attract.mp4', 'attract.webm') {
  $s = Join-Path $Root $f
  if (Test-Path $s) { Copy-Item -Force $s (Join-Path $pub $f); $p += (Join-Path $pub $f) }
}
$fonts = @(Get-ChildItem (Join-Path $Root 'tools\fonts') -Filter 'OFL-*.txt' -ErrorAction SilentlyContinue)
$sounds = @(Get-ChildItem (Join-Path $Root 'tools\sounds') -Filter '*.txt' -ErrorAction SilentlyContinue)
if ($fonts.Count -eq 0 -or $sounds.Count -eq 0) { Write-Output 'itch-zip: licence files missing in tools\fonts or tools\sounds'; exit 1 }
foreach ($f in $fonts + $sounds) { $d = Join-Path $pub $f.Name; Copy-Item -Force $f.FullName $d; $p += $d }
Compress-Archive -Force -Path $p -DestinationPath (Join-Path $pub 'pillagers-web.zip')
Write-Output ('itch-zip: ' + $p.Count + ' files, ' + ($fonts.Count + $sounds.Count) + ' of them licences')
