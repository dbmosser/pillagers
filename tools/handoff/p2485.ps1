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

# SPOTTED BY THE OVERSEER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BOSS_NAME='THE OVERSEER';
'@ @'
var BOSS_NAME='THE OVERSEER';
// v24.xx (overseerline), HIS NOTE (2026-10-12): "'Spotted by something huge' -- change to 'Spotted by the Overseer'". The callout
// fired for ANY warden that saw you, and every raid has a plain WARDEN (mkWarden) besides THE OVERSEER (a warden with e.boss).
// Now THE OVERSEER says SPOTTED BY THE OVERSEER, and a plain warden says SPOTTED BY A WARDEN (its own name, never the boss).
// The host carries which one it was in the party mark (boss:1), so a teammate window says the same line.
function wardenSpotLine(boss){ return boss?('SPOTTED BY '+BOSS_NAME):'SPOTTED BY A WARDEN'; }
'@

SubRx @'
if(!e.announced){ e.announced=true; if(p&&p.net){ if(NET.on) netMarkSend({t:'mark',k:'big',nid:e.nid|0,seat:p.seat|0}); } else say('SPOTTED BY SOMETHING HUGE','warn');
'@ @'
if(!e.announced){ e.announced=true; if(p&&p.net){ if(NET.on) netMarkSend({t:'mark',k:'big',nid:e.nid|0,seat:p.seat|0,boss:e.boss?1:0}); } else say(wardenSpotLine(e.boss),'warn');
'@

SubRx @'
if(k==='big'){ if(mine&&!G.sim) say('SPOTTED BY SOMETHING HUGE','warn'); return 'mark:big'; }
'@ @'
if(k==='big'){ if(mine&&!G.sim) say(wardenSpotLine(m.boss!==undefined?(m.boss|0):(e&&e.boss)),'warn'); return 'mark:big'; }   /* v24.xx (overseerline): the line names the one that saw him */
'@

SubRx @'
var VER='24.84';
'@ @'
var VER='24.85';
'@

$pat = "(?m)^  now:'v24\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.85: THE OVERSEER seeing you now calls SPOTTED BY THE OVERSEER, and a plain Warden calls SPOTTED BY A WARDEN. Check 24.85 fails on v24.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
