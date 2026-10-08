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

# PLAYER 1 NEVER OPENS OVER A PLAYER 2 RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function p2LiveBeat(){ try{ localStorage.setItem(p2LiveKey(),String(Date.now())); return true; }catch(_b){ return false; } }
'@ @'
// v20.35, from the whole-game bug hunt of 2026-10-08 (H24): and a second mark while that window is in a raid, so player 1 never
// opens a fresh player 2 window over a raid in progress (see netSamePick).
function p2RaidKey(){ return 'salvagerun:p2raid'; }
function p2LiveBeat(){ try{ localStorage.setItem(p2LiveKey(),String(Date.now())); if(typeof G!=='undefined'&&G&&!G.sim&&!G.over) localStorage.setItem(p2RaidKey(),String(Date.now())); else localStorage.removeItem(p2RaidKey()); return true; }catch(_b){ return false; } }
function p2RaidNow(){ var t=0; try{ t=+localStorage.getItem(p2RaidKey())||0; }catch(_g){ t=0; } return !!(t&&Math.abs(Date.now()-t)<75000); }
'@

SubRx @'
  try{ window.addEventListener('pagehide',function(){ try{ localStorage.removeItem(p2LiveKey()); }catch(_r){} }); }catch(_ph){}
'@ @'
  try{ window.addEventListener('pagehide',function(){ try{ localStorage.removeItem(p2LiveKey()); localStorage.removeItem(p2RaidKey()); }catch(_r){} }); }catch(_ph){}
'@

SubRx @'
  if(typeof BroadcastChannel!=='function'||!netSupported()){ netModeMsg('This browser cannot run two game windows. 1 PLAYER still works.'); return 'unsupported'; }
'@ @'
  // v20.35, from the whole-game bug hunt of 2026-10-08 (H24): A PLAYER 2 WINDOW IN A RAID IS NEVER OPENED OVER. After player 1
  // reloads mid raid, player 2 picks up the raid (his ruling of 2026-10-02) and no link is left, so the open below navigated the
  // live player 2 window to a new address and his raid went as a page-away. Player 1 is told to let that raid finish; once player
  // 2 is back in the Undercroft the pick opens it again as before.
  if(netInCount()===0&&typeof p2RaidNow==='function'&&p2RaidNow()){ netModeMsg('Player 2 is still in a raid in the other window. Let it finish there, then pick 2 PLAYER again.',true); return 'p2raid'; }
  if(typeof BroadcastChannel!=='function'||!netSupported()){ netModeMsg('This browser cannot run two game windows. 1 PLAYER still works.'); return 'unsupported'; }
'@

SubRx @'
var VER='20.34';
'@ @'
var VER='20.35';
'@

$pat = "(?m)^  now:'v20\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.35: On one PC, picking 2 PLAYER again never throws away a raid player 2 is still playing. Check 20.35 fails on v20.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
