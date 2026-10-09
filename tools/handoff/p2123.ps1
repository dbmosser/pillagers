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

# THE CRIER MARKS THE RIGHT PLAYER EVERY TIME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        if(sees){ e.markX=p.x; e.markY=p.y; }
'@ @'
        if(sees){ e.markX=p.x; e.markY=p.y; e.markSeat=(p&&p.net)?(p.seat|0):0; }   // v21.23, from the review of 2026-10-09 (R3): the marked player follows the marked place
'@

SubRx @'
                en.markX=p.x; en.markY=p.y;
'@ @'
                en.markX=p.x; en.markY=p.y; en.markSeat=0;   // v21.23 (R3): your round marks you
'@

SubRx @'
e.wind=3.5; e.markX=sx; e.markY=sy; }
'@ @'
e.wind=3.5; e.markX=sx; e.markY=sy; e.markSeat=s; }   /* v21.23 (R3): a round from one of the party marks him */
'@

SubRx @'
if(!G.sim){ if(e) sfxHere('alarm',e.x,e.y); if(mine) say('A crier has you. Kill it or move.'); }
'@ @'
if(!G.sim){ if(mine) say('A crier has you. Kill it or move.'); }   /* v21.23 (R4): the host already sends the alarm sound, so it is not played twice here */
'@

SubRx @'
var VER='21.22';
'@ @'
var VER='21.23';
'@

$pat = "(?m)^  now:'v21\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.23: In co-op, a Crier always marks the player it is watching, and its alarm plays once. Check 21.23 fails on v21.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
