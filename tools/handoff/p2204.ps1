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

# PLAYER 2 ROUNDS MEET THE ARMOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
              var WK=weakHit(en,b.x,b.y,ux,uy);   // v20.27 (H1): along the round's path
'@ @'
              var _nar=0;   // v22.04 (K16): on a linked window, the armour flag the host soaks this round with
              var WK=weakHit(en,b.x,b.y,ux,uy);   // v20.27 (H1): along the round's path
'@

SubRx @'
              } else if(en.armor>0){
                var esk=armorById(en.rig).absorb||0;
'@ @'
              } else if(NET.on&&netEntsPeer()){
                // v22.04, from the whole-game bug hunt of 2026-10-08 (K16): THE HOST SOAKS PLAYER 2'S ROUNDS WITH THE ARMOUR IT KEEPS.
                // This window soaked the round with its own copy of the man's armour and sent what was left. A pillager who came up
                // after the build is drawn here with no armour at all, so a Breacher Plate soaked nothing for player 2 and he dropped
                // the man two or three times faster than the host did, and on a pillager from the build the plate had to be worn
                // down twice, once in each window. The round now goes to the host whole, with a flag, and the host takes it off the
                // armour it runs, in the same order as its own rounds: armour first, then the back shot bonus.
                _nar=1;
              } else if(en.armor>0){
                var esk=armorById(en.rig).absorb||0;
'@

SubRx @'
edmg*=1.5; _backShot=true;
'@ @'
edmg*=1.5; _backShot=true; if(_nar) _nar=1.5;
'@

SubRx @'
              if(NET.on&&netEntsPeer()) netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK); else en.hp-=edmg;
'@ @'
              if(NET.on&&netEntsPeer()) netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar); else en.hp-=edmg;
'@

SubRx @'
function netShotSend(e,dmg,ang,wk){
'@ @'
function netShotSend(e,dmg,ang,wk,ar){
'@

SubRx @'
  if(wk&&wk.name) m.wk=netClean(wk.name,16);
'@ @'
  if(wk&&wk.name) m.wk=netClean(wk.name,16);
  if(ar>0) m.ar=+ar;   // v22.04 (K16): a round the host soaks with its own armour for this man: 1, or 1.5 for a back shot
'@

SubRx @'
  if(typeof m.wk==='string'&&m.wk){ L=weakOf(e); if(L) for(i=0;i<L.length;i++) if(L[i].name===m.wk){ applyWeak(e,L[i]); break; } }
'@ @'
  if(typeof m.wk==='string'&&m.wk){ L=weakOf(e); if(L) for(i=0;i<L.length;i++) if(L[i].name===m.wk){ applyWeak(e,L[i]); break; } }
  if(typeof m.ar==='number'&&m.ar>=1&&m.ar<=1.5&&!m.wk&&e.armor>0){ var _nab=d/m.ar, _nsk=armorById(e.rig).absorb||0, _nea=Math.min(e.armor,_nab*_nsk); e.armor-=_nea; d=(_nab-_nea)*m.ar; }   // v22.04 (K16): armour first, then the back shot bonus, as a host round
'@

SubRx @'
var VER='22.03';
'@ @'
var VER='22.04';
'@

$pat = "(?m)^  now:'v22\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.04: In co-op, pillager armour now soaks the rounds of player 2 the same as the rounds of the host. Check 22.04 fails on v22.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
