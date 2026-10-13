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

# THE FORGE: SHOCK ROUNDS CHAIN AND STUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      e.panicX=(typeof sx==='number'&&isFinite(sx))?sx:e.x; e.panicY=(typeof sy==='number'&&isFinite(sy))?sy:e.y;
    }
  }
  return true;
}
'@ @'
      e.panicX=(typeof sx==='number'&&isFinite(sx))?sx:e.x; e.panicY=(typeof sy==='number'&&isFinite(sy))?sy:e.y;
    }
  } else if(el==='shock'){
    elemArc(e,d,seat,sx,sy);
    if(ELEM_MACH[e.kind]&&!e.boss&&!(e.stunImm>0)){ e.stunT=(e.kind==='warden'||e.kind==='choir')?0.25:0.5; e.stunImm=e.stunT+2.5; }
  }
  return true;
}
// v23.xx, THE FORGE (2026-10-12), forge4: SHOCK. Every shock hit arcs half its damage to the nearest other body within 160 that the
// shooter would fight, with a clear line between the two (the arc is soaked by armour as a round is, never by a Bulwark shield, and
// finds no weak point). One arc per shooter every 0.2 s, so an SMG or a scattergun blast arcs about five times a second, not once a
// pellet. Never to the Peddler, the Survivor before he turns, a pillager at peace, a hire or a pillager who joined you. The arc turns
// a man onto the shooter as a round does, and its kill is the shooter's. A machine hit by shock is stunned for 0.5 s (a Warden or a
// Choir 0.25 s, the Overseer not at all): rooted, blind and silent, then immune for 2.5 s, so no gun holds a machine down for good
// (the v6.83 lesson on the overheat). Host or solo only; no draw on any stream.
var ELEM_MACH={sentry:1,crawler:1,listener:1,bulwark:1,howler:1,snitch:1,warden:1,choir:1};
function elemSoak(e,d){
  var sk, ab;
  if(e.armor>0&&d>0){ sk=armorById(e.rig).absorb||0; ab=Math.min(e.armor,d*sk); e.armor-=ab; d-=ab; }
  return d;
}
function elemArcOk(t){
  if(!elemOk(t)||t.kind==='peddler') return false;
  if(t.kind==='stray'&&!t.hostile) return false;
  if(t.kind==='raider'&&t.hostile===false) return false;
  return true;
}
function elemProvoke(t,sx,sy,seat){
  if(!isFinite(sx)||!isFinite(sy)) return;
  if(t.kind==='raider'){
    if(t.downed) return;
    if(t.state==='extract'){ if(!runnerTurns(t,sx,sy)) t.alert=2.6; }
    else { t.alert=2.6; t.state='chase'; t.tx=sx; t.ty=sy; returnFire(t,sx,sy); }
  } else if(t.kind==='snitch'){
    if(t.state!=='alarm'){ t.state='alarm'; t.lost=0; t.wind=3.5; t.markX=sx; t.markY=sy; t.markSeat=seat|0; }
  } else if(t.kind!=='peddler'&&t.kind!=='stray'){ t.alert=2.6; t.state='chase'; t.tx=sx; t.ty=sy; }
}
function elemArc(e,d,seat,sx,sy){
  var cd=G.arcCd||(G.arcCd={}), L=G.ents, i, t, best=null, bd=160, dd, a;
  if(cd[seat]>0) return null;
  for(i=0;i<L.length;i++){
    t=L[i]; if(t===e||!elemArcOk(t)) continue;
    dd=Math.hypot(t.x-e.x,t.y-e.y);
    if(dd<bd&&losClear(e.x,e.y,t.x,t.y,G.map.segs)){ bd=dd; best=t; }
  }
  if(!best) return null;
  cd[seat]=0.2;
  a=elemSoak(best,0.5*d);
  best.hp-=a; best.hitT=.16; best.pHitT=.3; best.pHitSeat=seat|0;
  elemProvoke(best,sx,sy,seat);
  elemCredit(best,seat);
  G.arcFx={x1:e.x,y1:e.y,x2:best.x,y2:best.y,t:0};
  if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(best.x,best.y-Math.round(best.r*1.1),Math.max(1,Math.round(a)),ELEM.shock.c,best.hp<=0);
  return best;
}
'@

SubRx @'
function elemTick(dt){
  var L=G.ents, i, e, t;
  for(i=0;i<L.length;i++){
    e=L[i];

'@ @'
function elemTick(dt){
  var L=G.ents, i, e, t, k;
  if(G.arcCd) for(k in G.arcCd) if(G.arcCd[k]>0) G.arcCd[k]=Math.max(0,G.arcCd[k]-dt);   // v23.xx (forge4): the arc cooldown per shooter
  for(i=0;i<L.length;i++){
    e=L[i];
    if(e.stunT>0){ e.stunT-=dt; if(e.stunT<0) e.stunT=0; }
    if(e.stunImm>0){ e.stunImm-=dt; if(e.stunImm<0) e.stunImm=0; }

'@

SubRx @'
function elemHold(e,dt){
  var dx, dy, d;

'@ @'
function elemHold(e,dt){
  var dx, dy, d;
  if(e.stunT>0){ e.moving=false; e.cd=Math.max(e.cd||0,0.35); return true; }   // v23.xx (forge4): stunned by shock: no sight, no move, no shot, as the overheat

'@

SubRx @'
var VER='25.14';
'@ @'
var VER='25.15';
'@

$pat = "(?m)^  now:'v25\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.15: Shock rounds from a MK III gun jump to a second enemy and briefly stun machines. Check 25.15 fails on v25.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
