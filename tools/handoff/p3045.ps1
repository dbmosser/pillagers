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

# No live rank, no board during a run (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeHiTick(){
  if(!arcadeBoardAuth()
'@ @'
function arcadeHiTick(){
  return false;   // v28.xx (cw-noliverank), his answer Q71 (2026-10-18): "No live rank readout, and no scoreboard until the game is over." The mid-run NEW HIGH SCORE callout compared the team with the board; the board shows after the run only
  if(!arcadeBoardAuth()
'@

SubRx @'
// The team strip: a run is live and this window is out of it.
function arcadeAttStrip(){
'@ @'
// v28.xx (cw-noliverank), his Q71: a run is live and this window is out of it (a benched player 1, or player 2 hearing the host score word)
function arcadeAttLive(){ return !!(arcadeBenched()||(ARCADE.role==='p2'&&!(G&&G.arcade)&&Date.now()-(+ARCADE.scSeen||0)<ARCADE_ATT.live)); }
// The team strip: a run is live and this window is out of it.
function arcadeAttStrip(){
'@

SubRx @'
ph=arcadeAttPhase(a.t,clip); }
'@ @'
ph=arcadeAttPhase(a.t,clip); if(ph==='board'&&arcadeAttLive()) ph='howto'; }   // v28.xx (cw-noliverank), his Q71: the board waits until the run is over
'@

SubRx @'
var VER='30.44';
'@ @'
var VER='30.45';
'@

$pat = "(?m)^  now:'v30\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.45: The board and the high-score callout wait until the run is over. Check 30.45 fails on v30.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
