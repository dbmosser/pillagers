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

# HOLD H FOR AN ARMOUR PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(code==='KeyH'&&G&&!G.over&&!G.paused&&!repeat) quickHeal();   // v25.xx (keyswap): H is the quick heal, no backpack needed
'@ @'
if(code==='KeyH'&&G&&!G.over&&!G.paused&&!repeat){ HHOLD.arm=1; HHOLD.t=0; }   // v25.xx (holdhplate): H is armed here; a tap heals and a hold slots a plate, decided in holdHTick
'@

SubRx @'
function nextGun(){
'@ @'
// v25.xx (holdhplate), HIS ORDER 2026-10-13 ("hold H = armour plate, tap H stays heal"): ONE KEY, TWO ACTIONS. The press arms H (HHOLD) and
// nothing happens yet. holdHTick, run every frame from updatePlayer, decides: the key let go before HHOLD.sec (0.35 s) is a TAP and
// quick-heals, as H always did (on the release now, so a tap takes the few hundredths of a second it is held); the key still down at
// 0.35 s is a HOLD and slots an armour plate through useArmor, the path the belt takes (so ARMOUR FULL, ALREADY SLOTTING and the rig's
// ceiling apply as there), once; letting go after that does nothing. A tap never starts a plate and a hold never heals. A lost focus
// forgets the press (releaseAllKeys).
var HHOLD={arm:0,t:0,sec:0.35};
function quickPlate(){
  var p=G&&G.player;
  if(!G||G.sim||G.over||G.paused||G.trade||!p||p.downed||p.dying||p.specOut) return false;
  if(findArmor()<0){ say('NO ARMOUR PLATE'); return false; }
  try{ useArmor(); }catch(_qp){}
  return true;
}
function holdHTick(dt){
  if(!HHOLD.arm) return;
  if(!G||G.over||G.sim){ HHOLD.arm=0; return; }
  if(keys['KeyH']){
    HHOLD.t+=dt;
    if(HHOLD.t>=HHOLD.sec){ HHOLD.arm=0; quickPlate(); }
  } else { HHOLD.arm=0; quickHeal(); }
}
function nextGun(){
'@

SubRx @'
if(G.barT>0) G.barT-=dt;   // v25.xx (keyswap): the crowbar swing
'@ @'
if(G.barT>0) G.barT-=dt;   // v25.xx (keyswap): the crowbar swing
  holdHTick(dt);   // v25.xx (holdhplate): H, a tap or a hold
'@

SubRx @'
keys={}; mouse.down=false; if(G) G.sprinting=false;
'@ @'
keys={}; try{ HHOLD.arm=0; }catch(_hh){} mouse.down=false; if(G) G.sprinting=false;
'@

SubRx @'
G.bag.splice(ix,1); startPrep('armor',k4);   // v22.74 (R29): the use bar says SLOTTING
'@ @'
G.bag.splice(ix,1); if(startPrep('armor',k4)) return;   // v22.74 (R29): the use bar says SLOTTING; v25.xx (holdhplate): a plate plays its own armour clack (PREP_FOLEY.plate), the pick chirp only when it has none
'@

SubRx @'
land:[['injector',{}],['bandageWrap',{g:0.6,dur:0.18,at:0.22}]]}
'@ @'
land:[['injector',{}],['bandageWrap',{g:0.6,dur:0.18,at:0.22}]]},
  // v25.xx (holdhplate), HIS ORDER 2026-10-13: the plate had no row, so slotting one still played the pick chirp (and again as it landed). It
  // clacks as the plate seats, again as the strap pulls tight at the middle of the wind-up, and lands with the heavy clack.
  plate:{s:[[0,'plateClack',{rate:1.2,g:0.55,dur:0.14}],[0.55,'plateClack',{rate:0.95,g:0.6,dur:0.14}]],
         land:[['plateClack',{rate:0.78,g:1.05}]]}
'@

SubRx @'
['KeyH','quick heal'],
'@ @'
['KeyH','quick heal (tap), armour plate (hold)'],
'@

SubRx @'
' quick heal &nbsp; '
'@ @'
' quick heal, hold for armour plate &nbsp; '
'@

SubRx @'
var VER='25.75';
'@ @'
var VER='25.76';
'@

$pat = "(?m)^  now:'v25\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.76: Tap H to heal, hold H to slot an armour plate, and a plate now clacks into place instead of chirping. Check 25.76 fails on v25.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
