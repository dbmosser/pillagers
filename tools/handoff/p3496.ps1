$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# MACHINES IN THE PLAYER 2 WINDOW COME BACK FROM A BROKEN SPOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(e.nT){
      dx=(e.ntx-e.x)*k; dy=(e.nty-e.y)*k; e.x+=dx; e.y+=dy;
'@ @'
    if(e.nT){
      if(!isFinite(e.x)||!isFinite(e.y)||!isFinite(e.face)){ e.x=e.ntx; e.y=e.nty; e.face=e.ntf; }   // v34.xx (cw-p2nan): robot report p2:nan, machines at a broken spot in the player 2 window; the easing and the snap test both stay broken on it, so it never came back
      dx=(e.ntx-e.x)*k; dy=(e.nty-e.y)*k; e.x+=dx; e.y+=dy;
'@

SubRx @'
var VER='34.95';
'@ @'
var VER='34.96';
'@

$pat = "(?m)^  now:'v34\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.96: In a two player raid, a machine that drops out of the player 2 window comes back on the next frame instead of staying gone. Check 34.96 fails on v34.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
