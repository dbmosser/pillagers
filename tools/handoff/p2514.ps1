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

# THE FORGE: FIRE ROUNDS BURN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      life:wep.rng/1180,player:!!fromPlayer,owner:sh,tint:wep.tint||'#ffd48a',
      thru:(wep.id==='lance')?1:0});
'@ @'
      life:wep.rng/1180,player:!!fromPlayer,owner:sh,tint:wep.tint||'#ffd48a',
      el:(fromPlayer&&wep.el&&ELEM[wep.el])?wep.el:'',   // v23.xx (forge3): a MK III round carries its element
      thru:(wep.id==='lance')?1:0});
'@

SubRx @'
var ew={dmg:BE.wep.dmg,spread:BE.wep.spread,rng:BE.wep.rng,noise:0,tint:BE.wep.tint,_echo:1};
'@ @'
var ew={dmg:BE.wep.dmg,spread:BE.wep.spread,rng:BE.wep.rng,noise:0,tint:BE.wep.tint,_echo:1,el:BE.wep.el||''};   // v23.xx (forge3): the second and third rounds of a MK III burst carry the element
'@

SubRx @'
var _dc=WK?'#ff8a3c':(edmg>0&&_backShot?'#ffc04a':'#FFF6DC');
'@ @'
var _dc=WK?'#ff8a3c':((b.el&&ELEM[b.el])?ELEM[b.el].c:(edmg>0&&_backShot?'#ffc04a':'#FFF6DC'));   // v23.xx (forge3): an element round shows its colour; a weak point stays orange, the more important fact
'@

SubRx @'
              if(!b._hitTold){ b._hitTold=1; G.tel.hits++; }
'@ @'
              if(b.el&&!(NET.on&&netEntsPeer())) elemHit(en,b.el,edmg,0,(b.owner||p).x,(b.owner||p).y);   // v23.xx (forge3): THE FORGE, the element of a MK III round
              if(!b._hitTold){ b._hitTold=1; G.tel.hits++; }
'@

SubRx @'
  G.frameN=(G.frameN||0)+1;
'@ @'
  G.frameN=(G.frameN||0)+1;
  if(G.elemAny) elemTick(dt);   // v23.xx (forge3): THE FORGE, burns and the other element timers; never set in the sim
'@

SubRx @'
      if(e.cd>0) e.cd-=dt;
      continue;
    }
    // The Peddler runs no AI whatsoever.
'@ @'
      if(e.cd>0) e.cd-=dt;
      continue;
    }
    if(G.elemAny&&elemHold(e,dt)) continue;   // v23.xx (forge3): a panicking pillager runs and fires nothing
    // The Peddler runs no AI whatsoever.
'@

SubRx @'
function updateEnts(dt){

'@ @'
// v23.xx, THE FORGE (2026-10-12), forge3: FIRE. HIS IDEA: "a pack-a-punch mechanism to upgrade guns and add elemental damage would be
// cool". A round from a MK III gun carries its element (b.el, the Burst Carbine echoes too) and elemHit applies it to the body it hit,
// with d the damage the round really dealt after the weak point, the shield and the armour. FIRE: the body burns for 3 s at 4 + a
// quarter of the hit a second (at most 18; armour does not stop fire), and the burn is the shooter's kill (elemCredit, the same
// marks a round writes, so contracts, the kill feed and the scores pay as for a round). A pillager hit by fire panics for 1.2 s (once
// in 5 s): he runs straight away from the shooter, fires nothing and does not roll, then fights on. Machines burn and keep fighting.
// No status on a hire, a pillager who joined you, a body that is finished or dead. The timers run once a frame on the host or solo
// (elemTick); a linked window runs no body. Plain arithmetic, no draw on any stream; the sim and the bot never fire a forged gun.
function elemOk(e){ return !!(e&&!e.merc&&!e.friendlyPC&&!e.finished&&!e.gone&&e.hp>0); }
function elemCredit(e,seat){
  if(!e||e.hp>0) return;
  if((seat|0)>0){ e.byPlayer=false; e.bySeat=seat|0; } else e.byPlayer=true;
}
function elemHit(e,el,d,seat,sx,sy){
  if(!ELEM[el]||!elemOk(e)||!(d>0)) return false;
  G.elemAny=1; seat=seat|0;
  if(el==='fire'){
    e.burnT=3.0; e.burnDps=Math.max(e.burnDps||0,Math.min(18,4+0.25*d)); e.burnBy=seat;
    if(e.kind==='raider'&&!e.downed&&!(e.panicCd>0)){
      e.panicT=1.2; e.panicCd=5; e.roll=0;
      e.panicX=(typeof sx==='number'&&isFinite(sx))?sx:e.x; e.panicY=(typeof sy==='number'&&isFinite(sy))?sy:e.y;
    }
  }
  return true;
}
function elemTick(dt){
  var L=G.ents, i, e, t;
  for(i=0;i<L.length;i++){
    e=L[i];
    if(e.panicCd>0){ e.panicCd-=dt; if(e.panicCd<0) e.panicCd=0; }
    if(e.panicT>0){ e.panicT-=dt; if(e.panicT<0||e.downed||e.hp<=0) e.panicT=0; }
    if(e.burnT>0){
      t=Math.min(dt,e.burnT); e.burnT-=dt;
      if(e.hp>0&&!e.finished&&!e.merc&&!e.friendlyPC){ e.hp-=(e.burnDps||0)*t; elemCredit(e,e.burnBy|0); }
      if(e.burnT<=0){ e.burnT=0; e.burnDps=0; }
    }
  }
}
function elemHold(e,dt){
  var dx, dy, d;
  if(!(e.panicT>0)) return false;
  if(e.kind!=='raider'||e.downed||e.hp<=0||e.merc||e.friendlyPC){ e.panicT=0; return false; }
  dx=e.x-(isFinite(e.panicX)?e.panicX:e.x); dy=e.y-(isFinite(e.panicY)?e.panicY:e.y); d=Math.sqrt(dx*dx+dy*dy);
  if(d<1){ dx=-Math.cos(e.face||0); dy=-Math.sin(e.face||0); d=1; }
  moveToward(e,e.x+dx/d*200,e.y+dy/d*200,(e.spd||120)*1.1,dt);
  e.face=Math.atan2(dy,dx); e.cd=Math.max(e.cd||0,0.3); e.roll=0;
  return true;
}
function updateEnts(dt){

'@

SubRx @'
var VER='25.13';
'@ @'
var VER='25.14';
'@

$pat = "(?m)^  now:'v25\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.14: Fire rounds from a MK III gun burn their target and make pillagers panic. Check 25.14 fails on v25.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
