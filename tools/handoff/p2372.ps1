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

# TRIPWIRE MINES GO OFF (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      else explodeFrag(fr);
      G.frags.splice(i,1);
    }
  }
}
'@ @'
      else explodeFrag(fr);
      G.frags.splice(i,1);
    }
  }
  tickTrips(dt);   // v23.xx (feat1b): the strung Tripwire Mines (nothing to do with none strung, so the bot never pays)
}
'@

SubRx @'
function explodeFrag(f){
'@ @'
// v23.xx (feat1b), HIS #6 (2026-10-12): "tripwire mine -- good idea". WHAT SETS A WIRE OFF AND WHAT IT DOES. An armed wire goes off
// when a body steps across it: every machine but the hovering Snitch, and every pillager, hostile or neutral. Never a player, never
// the hire, never the Peddler or the Stray, and never a body that is down for good. The test is the body step of this frame against
// the wire (the step is remembered per body only while a wire is strung, and a body standing on the wire when it arms sets it off
// only once it moves). Only the window that runs the bodies tests it (solo, or the host). The blast is its own (tripBlast): 150 across,
// 140 at the centre falling to 30 at the edge, through line of sight, to bodies only: no player damage at all (no team damage, no
// self damage) and no wall damage, so explodeFrag is untouched. The owner gets the credit (the kill, the notoriety, the provoke), and
// the survivors run at the blast. No draw on any stream: the sparks and the decal use the cosmetic stream as the frag does.
var TRIP_PREV=(typeof WeakMap==='function')?new WeakMap():null, TRIP_R=150;
function tripCatches(e){
  if(!e||!(e.hp>0)||e.finished||e.merc||e.friendlyPC) return false;
  if(e.kind==='peddler'||e.kind==='stray'||e.kind==='snitch') return false;
  return true;
}
function tripCross(x0,y0,x1,y1,T){
  var rx=x1-x0, ry=y1-y0, sx=T.bx-T.ax, sy=T.by-T.ay, den=rx*sy-ry*sx;
  if(Math.abs(den)<1e-9) return -1;
  var qx=T.ax-x0, qy=T.ay-y0, t=(qx*sy-qy*sx)/den, u=(qx*ry-qy*rx)/den;
  return (t>=0&&t<=1&&u>=0&&u<=1)?t:-1;
}
function tickTrips(dt){
  if(!G||!G.trips||!G.trips.length) return;
  var i, j, T, e, pv, n, t, x0, x1, y0, y1;
  for(i=G.trips.length-1;i>=0;i--){ T=G.trips[i]; if(T.arm>0) T.arm-=dt; T.life-=dt; if(T.life<=0) G.trips.splice(i,1); }
  if(G.sim||!TRIP_PREV||netEntsPeer()) return;
  n=G.tripTick=(G.tripTick||0)+1;
  for(j=0;j<G.ents.length;j++){
    e=G.ents[j]; if(!tripCatches(e)) continue;
    pv=TRIP_PREV.get(e);
    if(pv&&pv.n===n-1&&(pv.x!==e.x||pv.y!==e.y)){
      x0=Math.min(pv.x,e.x)-1; x1=Math.max(pv.x,e.x)+1; y0=Math.min(pv.y,e.y)-1; y1=Math.max(pv.y,e.y)+1;
      for(i=0;i<G.trips.length;i++){
        T=G.trips[i]; if(T.fx||T.arm>0) continue;
        if(x1<Math.min(T.ax,T.bx)||x0>Math.max(T.ax,T.bx)||y1<Math.min(T.ay,T.by)||y0>Math.max(T.ay,T.by)) continue;
        t=tripCross(pv.x,pv.y,e.x,e.y,T);
        if(t>=0){ G.trips.splice(i,1); tripBlast(T,pv.x+(e.x-pv.x)*t,pv.y+(e.y-pv.y)*t); break; }
      }
    }
    if(pv){ pv.x=e.x; pv.y=e.y; pv.n=n; } else TRIP_PREV.set(e,{x:e.x,y:e.y,n:n});
  }
}
function tripBlast(T,x,y){
  var p=G.player, R=TRIP_R, seat=(T&&T.seat)|0, i, e, de, dm, bp={x:x,y:y}, sd=Math.hypot(x-p.x,y-p.y);
  try{ if(sd<R*2) padRumble(Math.max(0.3,1-sd/(R*2)),200); }catch(_rb){}
  sfx("boom",x,y);
  if(!G.sim){ spark(x,y,'#ff6a4a',28,320); decal(x,y,'#141210',fxn(16,24)); G.puffs.push({x:x,y:y,t:0,life:.5,c:'#ff8a5a',r:44}); }
  G.shake=Math.max(G.shake,sd<300?8:(sd<700?4:1.5));
  flash(x,y,260,'#ff7a4a',.42);
  ping(x,y,520,false,false,'env','fire');
  for(i=G.ents.length-1;i>=0;i--){
    e=G.ents[i];
    if(!e||e.finished||e.merc) continue;
    de=dist(e,bp);
    if(de<R+e.r&&losClear(x,y,e.x,e.y,G.map.segs)){
      dm=110*(1-Math.max(0,de-e.r)/R)+30;
      e.hp-=dm; e.hitT=.2;
      if(!seat) notoAggress(e);
      if(e.hp<=0){ e.byPlayer=!seat; e.bySeat=seat; }
      e.pHitT=.3; e.pHitSeat=seat;
      if(e.state!=='alarm'&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.downed){ e.state='chase'; e.alert=2.5; e.tx=x; e.ty=y; }
    }
  }
}
function explodeFrag(f){
'@

SubRx @'
var VER='23.71';
'@ @'
var VER='23.72';
'@

$pat = "(?m)^  now:'v23\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.72: A Tripwire Mine now goes off when a machine or a pillager steps across it, and never hurts a player. Check 23.72 fails on v23.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
