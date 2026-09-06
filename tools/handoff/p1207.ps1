$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS NOTE, 2026-09-06 16:33: "crawler attacks and pathfinding were still kinda
# messed up... like if the player stops walking sometimes the crawler will too".
# Reproduced on COLD STORAGE at seed 4242: a crawler given his live position
# as its last sighting from 778 units ran at him, its alert clock (2.4 at 0.5 a
# second) ran out at 378 units, it dropped to investigate, packScatter sent it
# 90 to 240 units off the point, and it turned to patrol 106 units from a man
# standing still, just outside its 100-unit sight. Walking feeds it sightings
# and footsteps; standing still starves the clock. The chase is now held while
# the crawler is still more than 40 units from its last sighting, for at most
# chaseHold seconds of overtime, so an unreachable point cannot hold it forever.
SubRx @'
      if(!sees&&e.alert<=0){
        e.state=e.kind==='raider'?'loot':'investigate';
        e.role=null; e.scattered=0;
        if(e.state==='investigate') packScatter();
      }
    }
    else if(e.state==='investigate'){
'@ @'
      // v12.07, HIS NOTE of 2026-09-06 ("if the player stops walking sometimes
      // the crawler will too"): A CHASE DOES NOT EXPIRE BEFORE THE CHASER GETS
      // WHERE IT WAS GOING. The alert clock (2.4 at 0.5 a second, under five
      // seconds) ran while a crawler was still crossing the ground to the last
      // place it saw him, so a crawler more than five seconds of travel from that
      // point dropped to investigate on the way, packScatter pushed it 90 to 240
      // units off the point, and it walked past a man standing still just
      // outside its 100-unit sight. Measured at seed 4242: from 778 units it
      // gave up 106 short of him and turned away. While a crawler is still more
      // than 40 units from its last sighting the chase is held, for at most
      // chaseHold seconds of overtime (8; 0 restores the old clock), so a point
      // nothing can reach cannot hold it forever. A sighting resets the overtime.
      if(sees) e.chaseHold=0;
      var _chHold=(CFG.chaseHold===undefined?8:CFG.chaseHold);
      var _chFar=(e.kind==='crawler'&&_cg&&e.tx!==undefined&&_chHold>0&&(e.chaseHold||0)<_chHold&&dist(e,{x:e.tx,y:e.ty})>40);
      if(!sees&&e.alert<=0&&_chFar){ e.chaseHold=(e.chaseHold||0)+dt; }
      else if(!sees&&e.alert<=0){
        e.chaseHold=0;
        e.state=e.kind==='raider'?'loot':'investigate';
        e.role=null; e.scattered=0;
        if(e.state==='investigate') packScatter();
      }
    }
    else if(e.state==='investigate'){
'@

# STAMPS.
SubRx @'
var VER='12.06';
'@ @'
var VER='12.07';
'@
SubRx @'
var WHATSNEW_VER='12.06';
'@ @'
var WHATSNEW_VER='12.07';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A CRAWLER THAT WAS COMING FOR YOU KEEPS COMING. It no longer gives up on the way to the last place it saw you; standing still does not switch it off.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.06:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.06 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.06:[^']*'",{ param($m) "now:'v12.07: HIS NOTE of 2026-09-06, a crawler stopped when he stopped. Its alert clock ran out while it was still crossing the ground to the last place it saw him, so it dropped to investigate on the way, was scattered 90 to 240 units off the point, and walked past a man standing still just outside its 100-unit sight. A crawler still more than 40 units from its last sighting now holds the chase for up to 8 seconds of overtime (chaseHold; 0 restores the old clock). Check 12.07 runs a crawler at a standing player from 600 units and requires a bite, and requires a chase on an unreachable point to end; fails on v12.06.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
