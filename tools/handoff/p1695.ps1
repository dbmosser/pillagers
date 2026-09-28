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

# TURNED DOWN AT A BOX SOMEONE ELSE IS SEARCHING, A PLAYER LETS GO OF THE BOX HE STEPPED AWAY FROM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(G.searching===near){ G.searching=null; G.searchT=0; }
'@ @'
    // v16.95, co-op hunt 2026-09-28: turned down at a box someone else holds, this window lets go of any box it was searching,
    // not only this one. It kept the box it had stepped away from, so the host kept paying that box out to him (a party of three
    // or four), or on the host kept it marked held by him with its bar frozen. A linked window sends the stop at once.
    if(G.searching){ G.searching=null; G.searchT=0; }
    if(NET.role==='join') netSrchStop();
'@

SubRx @'
  if(G.searching!==near&&near.netAskT!==undefined&&G.t-near.netAskT<1) return 'wait';   // a request the host turned down is not made again every frame
'@ @'
  if(G.searching!==near&&near.netAskT!==undefined&&G.t-near.netAskT<1){   // a request the host turned down is not made again every frame
    if(G.searching){ G.searching=null; G.searchT=0; } netSrchStop();   // v16.95, co-op hunt 2026-09-28: and the box he stepped away from is let go, as above
    return 'wait';
  }
'@

SubRx @'
var VER='16.94';
'@ @'
var VER='16.95';
'@

$pat = "(?m)^  now:'v16\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.95: Co-op hunt 2026-09-28, loot: netSrchHold turned a player down at a box a teammate holds but only cleared his search when it was that same box. A player already searching another box kept it, netSrchSync saw nothing change and sent no stop, and netSrchTick on the host, which checks reach only when a search starts, kept paying the old box out to him from wherever he stood; on the host the old box stayed held by seat 0 with its bar frozen. The refusal now clears any search in hand and a linked window sends the stop in the same frame; the one second wait before asking again for a box that turned him down does the same. No number moved and no new words. Check 16.95 fails on v16.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
