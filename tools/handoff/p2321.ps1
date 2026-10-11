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

# ARCADE RAID: ENDLESS, RANDOM KIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(_gpBack.length&&G&&!G.sim){ G.spliced=G.spliced||[]; for(var _gpi=0;_gpi<_gpBack.length;_gpi++) if(G.spliced.indexOf(_gpBack[_gpi])<0) G.spliced.push(_gpBack[_gpi]); }   // v21.96 (K6): the gun in the pile is this raid's to bring home on an abandon
'@ @'
  if(_gpBack.length&&G&&!G.sim){ G.spliced=G.spliced||[]; for(var _gpi=0;_gpi<_gpBack.length;_gpi++) if(G.spliced.indexOf(_gpBack[_gpi])<0) G.spliced.push(_gpBack[_gpi]); }   // v21.96 (K6): the gun in the pile is this raid's to bring home on an abandon
  if(ARCADE&&ARCADE.on&&G&&!G.sim) arcadePostBuild(G);   // v23.21 (arcade2): an arcade raid is this same build made endless, with a random kit (the arcade section)
'@

SubRx @'
  for(var _rv=0;_rv<G.ents.length;_rv++){
'@ @'
  for(var _rv=0;!G.arcade&&_rv<G.ents.length;_rv++){   // v23.21 (arcade2): an arcade raid says no rival line
'@

SubRx @'
// Leaving the arcade. For now it is the sandbox out; later builds stop the arcade raid and put the pad picks back first.
function arcadeLeave(){
  if(!ARCADE.on) return false;
  return arcadeSandboxOut();
}
'@ @'
// v23.21, HIS ORDER (2026-10-11), build 2 of 20 (arcade2): THE ENDLESS ARCADE RAID, solo for now. arcadeDeploy builds a normal raid
// through the real startRaid inside the sandbox, under a session overlay of the dials (no raid clock, a 15 second extraction call),
// and arcadePostBuild then makes it an arcade raid: G.arcade, no clock, no ring ever closes, no peddler and no stray, the key panel
// collapsed, and a random kit. buildRaid is not touched and the kit draws only Math.random, so the seeded build is the build a
// normal raid gets, and a normal raid after the arcade is byte for byte the same. The kit: a gun in hand from ARCADE_GUNS1 and a
// different one stowed from ARCADE_GUNS2 (never a pistol, a Tacker or bare hands), plain field copies, a full magazine each and six
// more magazines for the gun in hand, 3 Bandages and a Medkit, a Frag and a Smoke, full armour and full health. arcadeLeave now
// stops the arcade raid (no run is settled, nothing is saved, no card) before it puts his profile and his dials back.
var ARCADE_CFG={raidSec:0,extractWait:15};
var ARCADE_GUNS1=['rifle','carbine','smg','shotgun','lmg'];
var ARCADE_GUNS2=['magnum','dmr','shotgun','chatter','smg','carbine'];
// The session overlay of the dials. The old values are kept in ARCADE.cfg0 (undefined for a dial that was not set), and
// arcadeSandboxOut puts them back.
function arcadeCfgIn(){
  if(!ARCADE.on||ARCADE.cfg0) return false;
  var o={}, k;
  for(k in ARCADE_CFG) if(Object.prototype.hasOwnProperty.call(ARCADE_CFG,k)){
    o[k]=Object.prototype.hasOwnProperty.call(CFG,k)?CFG[k]:undefined;
    CFG[k]=ARCADE_CFG[k];
  }
  ARCADE.cfg0=o;
  return true;
}
function arcadeGun(id){
  var w=WEAPONS[id], c={}, k;
  if(!w) return null;
  for(k in w) if(Object.prototype.hasOwnProperty.call(w,k)) c[k]=w[k];
  return c;
}
// The random loadout, from Math.random only (never rr, pick or rollFieldGun, which are the seeded stream).
function arcadeKitApply(p,g,why){
  if(!p||!g) return false;
  var A=ARCADE_GUNS1.filter(function(k){ return !!WEAPONS[k]; }), a, B, b, k;
  a=A.length?A[Math.floor(Math.random()*A.length)]:'rifle';
  B=ARCADE_GUNS2.filter(function(k2){ return k2!==a&&!!WEAPONS[k2]; });
  b=B.length?B[Math.floor(Math.random()*B.length)]:null;
  p.wep=arcadeGun(a); p.sec=b?arcadeGun(b):WEAPONS.fists;
  p.ammo=p.wep.mag; p.secAmmo=(p.sec&&p.sec.mag)||0; p.reserve=6*p.wep.mag;
  p.wepIssued=false; p.secIssued=false; p.wepFromArmory=false; p.secFromArmory=false;
  p.swapped=false; p.reloading=0; p.jam=0;
  p.armor=(p.armorCap===undefined?ARMOR_MAX:p.armorCap);
  p.hp=p.maxhp||100; p.revived=false;
  if(!Array.isArray(g.bag)) g.bag=[];
  g.bag.length=0; g.bag.push('bandage','bandage','bandage','medkit');
  if(!g.pouch||typeof g.pouch!=='object') g.pouch={};
  for(k in g.pouch) if(Object.prototype.hasOwnProperty.call(g.pouch,k)) g.pouch[k]=0;
  g.pouch.frag=1; g.pouch.smoke=1; if(g.pouch.decoy===undefined) g.pouch.decoy=0;
  g.issuedBandages=0; g.tsel=0;
  g.hotAssign={}; g.hotAuto={};
  if(g.tel) g.tel.weapon=p.wep.name;
  if(G===g){ try{ gunKeysSettle({deploy:1}); }catch(_gk){} try{ G.hot=gunCell(); }catch(_gc){} }
  return true;
}
// Run from startRaid right after the build, in every window that builds the arcade raid, so both builds stay identical.
function arcadePostBuild(g){
  if(!g||g.sim) return false;
  var i, e;
  g.arcade=1; g.raidLen=0; g.timeLeft=0;
  for(i=0;i<(g.zones||[]).length;i++) g.zones[i].closeAt=undefined;
  for(i=g.ents.length-1;i>=0;i--){ e=g.ents[i]; if(e&&(e.kind==='peddler'||e.kind==='stray')) g.ents.splice(i,1); }
  g.legendOn=0; g.hotAssign=null;
  arcadeKitApply(g.player,g,'drop');
  return true;
}
// Drop into an arcade raid. Enters the sandbox and the dial overlay first when they are not on yet.
function arcadeDeploy(o){
  o=o||{};
  if(!ARCADE.on&&!arcadeSandboxIn(o.role||'host')) return false;
  arcadeCfgIn();
  if(G&&G.arcade) arcadeRaidStop('new');
  var mi=(o.mapIx!==undefined)?o.mapIx:ARCADE.mapIx;
  P.mapIx=clamp((mi|0),0,FIXED_MAPS.length-1);
  if(o.cond) P.cond=o.cond;
  if(o.seed!==undefined) pendSeed=(o.seed>>>0);
  startRaid();
  return !!(G&&G.arcade);
}
// Stop an arcade raid with nothing settled: no run, no card, no save. Mirrors the instant quit teardown in endRaid.
function arcadeRaidStop(why){
  if(!G||!G.arcade) return false;
  G.drag=null;
  try{ ambienceOff(); }catch(_ao){}
  try{ togglePauseBox(false); }catch(_tp){}
  try{ var _oc=document.getElementById('outcome'); if(_oc) _oc.classList.remove('on'); }catch(_oc2){}
  G=null; keys={};
  if(why!=='leave'&&why!=='new'){ try{ showScreen('hub'); }catch(_sh){} }
  return true;
}
// Leaving the arcade: the arcade raid stops, then the sandbox out puts his profile and his dials back.
function arcadeLeave(){
  if(!ARCADE.on) return false;
  var hadRaid=arcadeRaidStop('leave'), r=arcadeSandboxOut();
  if(hadRaid){ try{ showScreen('hub'); }catch(_sh2){} }
  return r;
}
'@

SubRx @'
var VER='23.20';
'@ @'
var VER='23.21';
'@

$pat = "(?m)^  now:'v23\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.21: Groundwork for the 2 PLAYER ARCADE DEMO: an arcade raid has no clock, every extraction stays open, and every drop comes with a random loadout. Check 23.21 fails on v23.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
