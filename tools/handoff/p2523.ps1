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

# BANDAGES AND MEDKITS SOUND LIKE THEM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function startPrep(kind,key){
'@ @'
// v25.23 (usefoleya), HIS ORDER 2026-10-12 (about 21:10): "add sounds for bandaging, applying armor, etc". A BANDAGE AND A MEDKIT SOUND
// LIKE ONE. Starting either played the menu chirp (blip pick), and landing it played the menu chirp again; nothing in between, so a
// heal under fire sounded like opening the backpack. Now each one plays its recorded foley (the v25.20 bank) against its own wind-up
// timer: a Bandage tears open, wraps three times through the 1.5 s wind-up and lands with a short tape rip and a pat; a Medkit snaps
// its case, unzips, rummages at about 0.7 s and lands with the injector and a gauze wrap. The stages are read off the wind-up as it
// crosses them (prepFoley, from tickPrepSlot), never scheduled ahead, so a wind-up that ends early (going down clears it) plays
// nothing more. Yours is centred (split speakers put it on your seat side); your teammates hear it where you stand, and a bandage you
// put on a teammate sounds the same. A kind with no row here (a plate, until its build) keeps the chirp. Cosmetic only: no seeded
// draw, nothing under G.sim, no game state.
// PREP_FOLEY[kind]: s is the stages [fraction of the wind-up, bank clip, foley options]; land is what plays as it lands.
var PREP_FOLEY={
  bandage:{s:[[0,'bandageTear',{}],[0.3,'bandageWrap',{}],[0.6,'bandageWrap',{rate:0.9,g:0.9}],[0.85,'bandageWrap',{rate:1.12,g:0.75,dur:0.2}]],
           land:[['bandageTear',{off:0.3,dur:0.16,g:0.6,rate:1.2}],['pickup',{g:0.7,at:0.07}]]},
  medkit:{s:[[0,'medkitSnap',{}],[0,'medkitZip',{at:0.14,g:0.9}],[0.47,'rummage',{}],[0.75,'bandageWrap',{g:0.7,dur:0.2}]],
          land:[['injector',{}],['bandageWrap',{g:0.6,dur:0.18,at:0.22}]]}
};
// the row for a wind-up: by item key, else by what the item does (a heal with a ceiling is a Bandage, any other heal a Medkit)
function prepFoleyK(PR){
  var it=PR&&ITEMS[PR.key];
  if(!it) return null;
  return PREP_FOLEY[PR.key]||PREP_FOLEY[it.use==='heal'?(it.capHp?'bandage':'medkit'):(it.use==='armor'?'plate':'')]||null;
}
// play the stages the wind-up crossed between t0 and t1 seconds; true when this kind has foley (so the caller drops its chirp)
function prepFoley(PR,t0,t1){
  var K=prepFoleyK(PR), m, i, s;
  if(!K) return false;
  if(typeof foley!=='function') return true;
  m=(PR.max>0)?PR.max:1;
  for(i=0;i<K.s.length;i++){ s=K.s[i]; if(t0<s[0]*m&&s[0]*m<=t1) foley(s[1],null,null,s[2]); }
  return true;
}
function prepFoleyLand(PR){
  var K=prepFoleyK(PR), i;
  if(!K) return false;
  if(typeof foley==='function') for(i=0;i<K.land.length;i++) foley(K.land[i][0],null,null,K.land[i][1]);
  return true;
}
function startPrep(kind,key){
'@

SubRx @'
  if(kind==='armor') G.player.prepA=_pr; else G.player.prep=_pr;
}
'@ @'
  if(kind==='armor') G.player.prepA=_pr; else G.player.prep=_pr;
  return prepFoley(_pr,-1,0);   // v25.23 (usefoleya): the first stage, as it starts; true drops the chirp
}
'@

SubRx @'
function tickPrepSlot(p,slot,dt){
  if(!p[slot]) return;
  p[slot].t+=dt;
'@ @'
function tickPrepSlot(p,slot,dt){
  if(!p[slot]) return;
  var _pf0=p[slot].t;
  p[slot].t+=dt;
  prepFoley(p[slot],_pf0,p[slot].t);   // v25.23 (usefoleya): the stages it crossed this frame; a cleared wind-up has none left
'@

SubRx @'
    if(!(it&&it.hot>0&&CFG.healOverTime!==0)) say('PATCHED UP');
  }
  blip('pick');
'@ @'
    if(!(it&&it.hot>0&&CFG.healOverTime!==0)) say('PATCHED UP');
  }
  if(!prepFoleyLand(PR)) blip('pick');   // v25.23 (usefoleya): its own landing, else the chirp
'@

SubRx @'
  G.bag.splice(idx,1); startPrep('heal',k); blip('pick');
'@ @'
  G.bag.splice(idx,1); if(!startPrep('heal',k)) blip('pick');   // v25.23 (usefoleya): the Bandage or Medkit plays its own
'@

SubRx @'
      G.bag.splice(ix,1); startPrep('heal',s2.itemKey); blip('pick');
'@ @'
      G.bag.splice(ix,1); if(!startPrep('heal',s2.itemKey)) blip('pick');   // v25.23 (usefoleya): its own foley
'@

SubRx @'
  startPrep(arm?'armor':'heal',key);
  p[arm?'prepA':'prep'].aid=s;
'@ @'
  var _pfa=startPrep(arm?'armor':'heal',key);   // v25.23 (usefoleya): true when it plays its own foley
  p[arm?'prepA':'prep'].aid=s;
'@

SubRx @'
  blip('pick');   // v22.74 (R29): the use bar says APPLYING or SLOTTING ... ON NAME
'@ @'
  if(!_pfa) blip('pick');   // v22.74 (R29): the use bar says APPLYING or SLOTTING ... ON NAME
'@

SubRx @'
'ally'); blip('pick');   // v22.xx (R51): PLATE SLOTTED FOR NAME, PATCHED UP NAME
'@ @'
'ally'); if(!prepFoleyLand(PR)) blip('pick');   // v22.xx (R51): PLATE SLOTTED FOR NAME, PATCHED UP NAME. v25.23 (usefoleya): its own landing
'@

SubRx @'
var VER='25.22';
'@ @'
var VER='25.23';
'@

$pat = "(?m)^  now:'v25\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.23: A Bandage now tears, wraps and tapes, and a Medkit snaps, unzips, rummages and injects, in time with the wind-up. Check 25.23 fails on v25.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
