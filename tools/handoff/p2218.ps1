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

# PLAYER 2 GETS THE UNDERCROFT MUSIC BACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(typeof NET==='object'&&NET&&NET.same==='p2'&&netSndWho()!=='p2'&&!NET.hostSeed) return false;
'@ @'
  // v22.18, from the whole-game bug hunt of 2026-10-08 (K29): AND ONLY WHILE THERE IS A PLAYER 1 WINDOW TO PLAY IT. The player 2
  // window keeps its same machine mode when its link to player 1 ends, so once the player 1 window was closed (or crashed, or ended
  // the party) the Undercroft in the player 2 window stayed silent on every visit until it was reloaded. A link to the host that
  // ends marks it (NET.p1Gone, in netReset), and with no link in again this window plays the song itself.
  if(typeof NET==='object'&&NET&&NET.same==='p2'&&netSndWho()!=='p2'&&!NET.hostSeed&&!(NET.p1Gone&&!netInCount())) return false;
'@

SubRx @'
  var ps=NET.peers.slice(), i;
'@ @'
  var ps=NET.peers.slice(), i;
  if(typeof NETP2!=='undefined'&&NETP2&&NET.role==='join'&&NET.seat>=1) NET.p1Gone=1;   // v22.18 (K29): the player 2 window lost its link to player 1, so the Undercroft song is its own again
'@

SubRx @'
var VER='22.17';
'@ @'
var VER='22.18';
'@

$pat = "(?m)^  now:'v22\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.18: In same machine co-op, the player 2 window plays the Undercroft music again once the player 1 window is gone. Check 22.18 fails on v22.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
