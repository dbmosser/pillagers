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

# ARCADE: EXTRACTION BONUS AND RE-DROP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(G&&G.arcade&&!G.sim){ if(how==='dead') return arcadeRespawn('dead'); if(how==='abandon') return arcadeRaidStop('quit'); }
'@ @'
  // v23.23 (arcade4): and an extraction pays the bonus and drops him back in (arcadeExtracted), the world untouched.
  if(G&&G.arcade&&!G.sim){ if(how==='dead') return arcadeRespawn('dead'); if(how==='extract') return arcadeExtracted(); if(how==='abandon') return arcadeRaidStop('quit'); }
'@

SubRx @'
  ARCADE.deaths=0; ARCADE.holdT=0;   // v23.22 (arcade3)
'@ @'
  ARCADE.deaths=0; ARCADE.holdT=0;   // v23.22 (arcade3)
  ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0; ARCADE.ext=0; ARCADE.banner=null;   // v23.23 (arcade4)
'@

SubRx @'
  ARCADE.holdT=0;   // v23.22 (arcade3)
  try{ ambienceOff(); }catch(_ao){}
'@ @'
  ARCADE.holdT=0;   // v23.22 (arcade3)
  ARCADE.banner=null;   // v23.23 (arcade4)
  try{ ambienceOff(); }catch(_ao){}
'@

SubRx @'
// Leaving the arcade: the arcade raid stops, then the sandbox out puts his profile and his dials back.
'@ @'
// v23.23, HIS ORDER (2026-10-11), build 4 of 20 (arcade4): EXTRACTION BONUS, BANNER AND RE-DROP. In an arcade raid a finished pull (or
// being hauled aboard downed) no longer settles the raid: it pays EXTRACTION BONUS +2,500 and pays the haul pot a second time
// (HAUL x2), counts the extraction, shows the EXTRACTED! banner for 3 seconds with the new TEAM SCORE, and drops him straight back
// into the same raid: a fresh random kit, full health, a spot at least 900 from every ring (map spawns first, farthest from live
// hostiles, Math.random only), his pull and the ship hold of the ring he left on cleared so the ring can be called again, and a
// 6 second drop-in hold (3 + 3). The world is not rebuilt, so a teammate fight goes on. No run is counted and nothing is saved.
var ARCADE_XBONUS=2500, ARCADE_BANNER_T=3, ARCADE_REDROP_R=900;
function arcadeN(n){ return String(Math.round(+n||0)).replace(/\B(?=(\d{3})+(?!\d))/g,','); }
// The re-drop spot: at least minR from every ring. The map spawns come first (they are known to be reachable); then random open
// ground; and if nothing clears minR, the candidate farthest from the nearest ring.
function arcadeRedropSpot(p,g,minR){
  var m=g.map, c=[], i, j, s, e, d, rd, sc, best=null, bs=-1, far=null, fs=-1, x, y, pass;
  if(!m) return false;
  function ringD(x2,y2){ var k, z, r=1e9, dd; for(k=0;k<(g.zones||[]).length;k++){ z=g.zones[k]; if(!z) continue; dd=Math.hypot(z.x-x2,z.y-y2); if(dd<r) r=dd; } return r; }
  function foeD(x2,y2){ var k, en, r=1e9, dd; for(k=0;k<g.ents.length;k++){ en=g.ents[k]; if(!en||!(en.hp>0)||en.merc||en.kind==='peddler'||en.kind==='stray') continue; dd=Math.hypot(en.x-x2,en.y-y2); if(dd<r) r=dd; } return r; }
  for(pass=0;pass<2&&!best;pass++){
    c.length=0;
    if(pass===0){ if(Array.isArray(m.spawns)) for(i=0;i<m.spawns.length;i++){ s=m.spawns[i]; if(s) c.push({x:s.x,y:s.y}); } }
    else for(i=0;i<240;i++){ x=60+Math.random()*(WORLD_W-120); y=60+Math.random()*(WORLD_H-120); c.push({x:x,y:y}); }
    for(i=0;i<c.length;i++){
      s=c[i]; if(!(s.x>30&&s.y>30&&s.x<WORLD_W-30&&s.y<WORLD_H-30)||!spotFree(m,s.x,s.y,22)) continue;
      rd=ringD(s.x,s.y);
      if(rd>fs){ fs=rd; far=s; }
      if(rd<minR) continue;
      sc=foeD(s.x,s.y)+Math.random();
      if(sc>bs){ bs=sc; best=s; }
    }
  }
  s=best||far;
  if(!s) return false;
  p.x=s.x; p.y=s.y;
  return true;
}
function arcadeExtracted(){
  if(!G||!G.arcade||!G.player) return false;
  var p=G.player, i, z, pot=Math.max(0,ARCADE.pot|0);
  // his pull and the hold of the ring he left on: cleared, so the ship is gone and the ring can be called again
  for(i=0;i<(G.zones||[]).length;i++){
    z=G.zones[i]; if(!z) continue;
    if(dist(p,z)<z.r&&typeof z.hold==='number'){ z.beaconT=null; z.hold=null; if(z===G.active){ G.beaconT=null; G.shipHold=null; } }
    z.pullT=null; z.boardT=0; z.pullFloor=0;
  }
  ARCADE.mine=(ARCADE.mine|0)+ARCADE_XBONUS+pot;
  ARCADE.pot=0; ARCADE.ext=(ARCADE.ext|0)+1;
  ARCADE.banner={t0:G.t,bonus:ARCADE_XBONUS,haul:pot,team:(ARCADE.mine|0)+(ARCADE.mate|0)};
  G.deathBeat=null; p.dying=false; p.downed=false; p.downT=0; p.pendKiller=null; p.prep=null; p.prepA=null;
  p.cooking=0; p.cookT=0; p.cookKind=null;
  arcadeRedropSpot(p,G,ARCADE_REDROP_R);
  arcadeKitApply(p,G,'redrop');
  p.vx=0; p.vy=0; G.anchX=undefined; G.shake=0;
  ARCADE.holdT=3+3;
  return true;
}
// The arcade layer of the HUD, drawn from drawHUD. For now the EXTRACTED! banner: 3 seconds in the centre, on game time.
function arcadeHud(){
  if(!G||!G.arcade||!ctx) return;
  var b=ARCADE.banner, k, a, y, cx=Math.round(W/2), bw, bh;
  if(!b) return;
  k=G.t-b.t0;
  if(!(k>=0&&k<ARCADE_BANNER_T)){ ARCADE.banner=null; return; }
  a=Math.max(0,Math.min(1,k/0.15,(ARCADE_BANNER_T-k)/0.4));
  bw=LH(440); bh=LH(156); y=Math.round(H*0.30);
  ctx.save(); ctx.globalAlpha=a; ctx.textAlign='center'; ctx.textBaseline='alphabetic';
  ctx.fillStyle='rgba(6,9,13,.84)'; ctx.fillRect(cx-bw/2,y-LH(56),bw,bh);
  ctx.strokeStyle='rgba(127,196,160,.80)'; ctx.lineWidth=2; ctx.strokeRect(cx-bw/2+1,y-LH(56)+1,bw-2,bh-2);
  ctx.font=FSz(TYPE.huge,1.6); ctx.fillStyle='#7fc4a0'; ctx.fillText('EXTRACTED!',cx,y);
  ctx.font=FS(TYPE.head); ctx.fillStyle='#ffc04a';
  ctx.fillText('EXTRACTION BONUS +'+arcadeN(b.bonus),cx,y+LH(30));
  if(b.haul>0) ctx.fillText('HAUL x2 +'+arcadeN(b.haul),cx,y+LH(52));
  ctx.font=FS(TYPE.title); ctx.fillStyle='#e8eef2';
  ctx.fillText('TEAM SCORE '+arcadeN(b.team),cx,y+LH(86));
  ctx.restore();
}
// Leaving the arcade: the arcade raid stops, then the sandbox out puts his profile and his dials back.
'@

SubRx @'
  // v8.93: the resize grips. Every panel that can be scaled gets three short
'@ @'
  if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }   // v23.23 (arcade4): the arcade layer, the EXTRACTED! banner
  // v8.93: the resize grips. Every panel that can be scaled gets three short
'@

SubRx @'
var VER='23.22';
'@ @'
var VER='23.23';
'@

$pat = "(?m)^  now:'v23\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.23: In the arcade demo an extraction pays a 2,500 bonus plus your haul again and drops you back in. Check 23.23 fails on v23.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
