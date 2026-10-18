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

# THE AIM LANE POINTS AT THE PLAYER THE MACHINE WILL SHOOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(p&&!p.downed&&isFinite(p.x)&&isFinite(p.y)){
'@ @'
  // v28.xx (cw-lanetarget), CLOUD HUNT 2026-10-15: in co-op the lane snapped to this window's own player even when the machine was
  // aiming at the teammate, so the host saw the full red lane on himself while the round went to player 2 (and player 2 the mirror). It snaps
  // to you only when you are the machine's target, in either window (solo always: you are the only target); otherwise it follows the facing.
  if(p&&!p.downed&&isFinite(p.x)&&isFinite(p.y)&&!(NET.on&&netTargetFor(e)!==p)){
'@

SubRx @'
var VER='29.04';
'@ @'
var VER='29.05';
'@

$pat = "(?m)^  now:'v29\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.05: In two-player play a machines red aim lane points at whichever of you it is about to shoot. Check 29.05 fails on v29.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
