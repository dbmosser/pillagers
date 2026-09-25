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

SubRx @'
  (function(){
    var LK=map.locked||[];
    for(var lk=0;lk<LK.length;lk++){
      var kid='key_'+LK[lk].id, LR4=LK[lk];
'@ @'
  (function(){
    var LK=map.locked||[];
    // v15.56, keys audit finding 4: A DOOR KEY IS NEVER HIDDEN IN THE VAULT CASE OR BEHIND ANOTHER LOCKED DOOR. The promise
    // below only asked whether a box stood inside the room THIS key opens, so two kinds of box it must never use were legal.
    // THE VAULT CASE (v4.40) is a jackpot with no cache flag and already stands when this runs, so a door's only key could go
    // into the one box the map never marks (his v4.40 answer: not on the map, not marked), and with a Data Core burned the
    // sector map then drew KEY on it. And an ordinary crate, locker or safe standing inside a DIFFERENT locked room, which the
    // v2.12 reach pass leaves where it is on purpose, was legal too, so a door could need a second key first, and two rooms
    // could hold each other's keys with nothing saying so. sealedAny asks the same 40 unit question of every locked room.
    var sealedAny=function(CC){
      for(var _lq=0;_lq<LK.length;_lq++){ var _L=LK[_lq];
        if(CC.x>_L.x-40&&CC.x<_L.x+_L.w+40&&CC.y>_L.y-40&&CC.y<_L.y+_L.h+40) return true; }
      return false;
    };
    for(var lk=0;lk<LK.length;lk++){
      var kid='key_'+LK[lk].id, LR4=LK[lk];
'@
SubRx @'
      var have=false;
      for(var ci3=0;ci3<containers.length&&!have;ci3++)
        if(containers[ci3].loot.indexOf(kid)>=0&&outside(containers[ci3])) have=true;
      if(have) continue;
'@ @'
      // v15.56, keys audit finding 4: A DOOR KEY IS NEVER HIDDEN IN THE VAULT CASE OR BEHIND ANOTHER LOCKED DOOR. A key that
      // rolled into a safe or cache inside ANOTHER locked room kept the promise here and no reachable key was placed. Only a
      // copy clear of every locked room keeps it now (haveOpen). have still records the old answer, any copy outside this
      // room, because it decides below whether the draw is taken, and that must not move.
      var have=false, haveOpen=false;
      for(var ci3=0;ci3<containers.length&&!haveOpen;ci3++)
        if(containers[ci3].loot.indexOf(kid)>=0&&outside(containers[ci3])){ have=true; if(!sealedAny(containers[ci3])) haveOpen=true; }
      if(haveOpen) continue;
'@
SubRx @'
      if(!cands.length) continue;
      var pickC=cands[ri(0,cands.length-1)];
      pickC.loot.push(kid);
'@ @'
      if(!cands.length) continue;
      // v15.56, keys audit finding 4: A DOOR KEY IS NEVER HIDDEN IN THE VAULT CASE OR BEHIND ANOTHER LOCKED DOOR. The list and
      // the one ri draw are exactly as they were, so every seed takes the same draws in the same order and every key that
      // already landed in an open box stays in that box. Only a pick that is THE VAULT CASE or stands inside a locked room walks
      // on through the same list to the next box clear of every locked room. When a copy behind another door satisfied the old
      // test no draw was ever taken here, so none is taken now: that walk starts at the raid seed instead. No box, no count, no
      // loot table and no draw moved, so the seed 4242 fingerprint holds.
      var _kat=have?((seed>>>0)%cands.length):ri(0,cands.length-1), pickC=null;
      for(var _kstep=0;_kstep<cands.length&&!pickC;_kstep++){
        var _kbox=cands[(_kat+_kstep)%cands.length];
        if(_kbox.type!=='jackpot'&&!sealedAny(_kbox)) pickC=_kbox;
      }
      if(!pickC) continue;
      pickC.loot.push(kid);
'@
SubRx @'
var VER='15.55';
'@ @'
var VER='15.56';
'@

$pat = "(?m)^  now:'v15\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.56: A DOOR KEY IS NEVER HIDDEN IN THE VAULT CASE OR BEHIND ANOTHER LOCKED DOOR. The rule that every locked door has a key somewhere on the map could put that key in the unmarked Vault Case, or in a box inside a different locked room, so one door needed another key first. The key now goes to an ordinary box clear of every locked room, and a key that already landed in one stays exactly where it was. Check 15.56 stages a Foreman Office key inside the Blast Freezer on COLD STORAGE and reads where both door keys land; it fails on v15.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
