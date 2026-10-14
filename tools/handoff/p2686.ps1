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

# RAID EVENTS: OVERSEER RAMPAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v26.xx (flow10), HIS ANSWER (2026-10-14), the raid events, the sixth and last: OVERSEER RAMPAGE, "the boss leaves its lair and sweeps the map". Only in a raid whose
// Overseer is alive. A 12 s warning with the ring on the Overseer, then for RAMP.dur (120) s it is OFF THE LEASH: 60 percent faster, it walks three waypoints
// on open ground in three different quarters of the map (a side stream of the event picks them) and then comes for YOU wherever you are. It does this with its
// own leash: each frame its LAIR is moved to the waypoint it is walking to (and its sight of you is a sight inside 1,100 of that), so the walk, the hold-and-fire
// and the phases are the Overseer code as it is, only home has moved; it goes by the street grid because it has seen you (seenYou stays on). A waypoint is done at 160
// or after 35 s. When the time is up, or the Overseer dies, its lair, speed and walk are put back and it goes home. The ring and the mark follow it. DEMO and CAREER
// are the same.
var RAMP={dur:120,fast:1.6,reach:160,wpT:35};
EVENTS.rampage={name:'OVERSEER RAMPAGE',sub:'IT LEAVES THE LAIR',warn:12,dur:RAMP.dur,r:170,fade:4,col:'#d04aff',
  ok:function(){ return CFG.boss!==0; },
  mx:function(ev){ var b=ev.d.b; return (b&&b.hp>0)?b.x:ev.x; },
  my:function(ev){ var b=ev.d.b; return (b&&b.hp>0)?b.y:ev.y; },
  pick:function(ev){
    var b=G.bossRef, L=evS().live, i;
    if(!b||!(b.hp>0)||G.ents.indexOf(b)<0||b.rmp) return false;
    for(i=0;i<L.length;i++) if(L[i].id==='rampage'&&L[i].ph!=='end') return false;
    ev.x=b.x; ev.y=b.y; ev.d.b=b;
    return true;
  },
  start:function(ev){
    var b=ev.d.b, wps=[], qs=[0,1,2,3], seed=(((G.seed>>>0)^Math.imul((ev.n|0)+61,2654435761))>>>0)||1;
    if(!b||!(b.hp>0)) return;
    sideStream(seed,EV.tag+11,function(){
      var k, ix, q, t, x, y, cx, cy;
      for(k=0;k<3;k++){
        ix=Math.floor(rr()*qs.length); q=qs.splice(ix,1)[0];
        cx=WORLD_W*(0.25+0.5*(q&1)); cy=WORLD_H*(0.25+0.5*(q>>1));
        for(t=0;t<40;t++){
          x=cx+(rr()-0.5)*700; y=cy+(rr()-0.5)*700;
          if(x>300&&y>300&&x<WORLD_W-300&&y<WORLD_H-300&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)){ wps.push({x:x,y:y}); break; }
        }
      }
    });
    b.rmp=1; b.rmpL=[b.lairX,b.lairY]; b.rmpSpd=b.spd; b.spd=b.spd*RAMP.fast; b.seenYou=true;
    ev.d.wps=wps; ev.d.wi=0; ev.d.wt=0; ev.r=90;
    try{ say('OVERSEER RAMPAGE','crit',{sub:'IT HAS LEFT THE LAIR'}); }catch(_rs){}
  },
  tick:function(ev,dt){
    var b=ev.d.b, p=G.player, wp, w=ev.d.wps||[];
    if(!b||!b.rmp) return;
    if(!(b.hp>0)||G.ents.indexOf(b)<0){ ev.d.over=1; return; }
    ev.d.wt+=dt;
    if(ev.d.wi<w.length&&(Math.hypot(b.x-w[ev.d.wi].x,b.y-w[ev.d.wi].y)<RAMP.reach||ev.d.wt>RAMP.wpT)){ ev.d.wi++; ev.d.wt=0; }
    wp=(ev.d.wi<w.length)?w[ev.d.wi]:{x:p.x,y:p.y};
    b.lairX=wp.x; b.lairY=wp.y; b.tx=wp.x; b.ty=wp.y; b.seenYou=true;
  },
  done:function(ev){ return !!ev.d.over; },
  end:function(ev){
    var b=ev.d.b;
    if(b&&b.rmp){
      b.rmp=0; if(b.rmpL){ b.lairX=b.rmpL[0]; b.lairY=b.rmpL[1]; } if(b.rmpSpd) b.spd=b.rmpSpd;
      if(b.hp>0){ try{ say('OVERSEER RETURNS','info'); }catch(_re){} }
    }
  },
  live:function(ev){ var w=ev.d.wps||[]; return (ev.d.wi<w.length)?('SWEEP '+(ev.d.wi+1)+'/'+w.length):'HUNTING YOU'; }
};
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.85';
'@ @'
var VER='26.86';
'@

$pat = "(?m)^  now:'v26\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.86: The Overseer rampage event: the boss leaves its lair for two minutes and sweeps the map, then comes for you. Check 26.86 fails on v26.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
