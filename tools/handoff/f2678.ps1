$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'26.78',what:")) { throw "check 26.78 is in the fixture already" }

SubRx @'
  {v:'26.77',what:
'@ @'
  {v:'26.78',what:'flow4, his yes to fire hazards that make spots impassable (not from the map edges): the raid plans two fuel fires away from the drop and the rings, a lit fire puts the player and the machines back on its edge and burns whoever touches it, the Director never lands a pack in one, it ends, and it is a mark on the minimap and the map',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], S, f, e, d, hp0, i, j, x0, y0, ok, free, cap=[], proto, oArc, s, hit, t1, t2, M, oSh, oAr, oIv, z, eh0, ex0, ey0, mk;
     function nearCut(){ g.ents=g.ents.filter(function(q){ return !(q&&!q.neutral&&q.kind!=='peddler'&&q.kind!=='stray'&&(q.kind!=='raider'||q.hostile)&&dist(q,p)<1500); }); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof fireAdd!=='function'||typeof flowTick!=='function') return 'there are no fire hazards in this build';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv;
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0; nearCut();
       // ONE: the plan: two fires, away from the drop and the rings, inside the time window
       flowTick(0.1); S=g.flow;
       if(!S||!S.fplan||S.fplan.length<1) return 'ONE: the raid planned '+(S&&S.fplan?S.fplan.length:'no')+' fires';
       for(i=0;i<S.fplan.length;i++){
         f=S.fplan[i];
         if(Math.hypot(f.x-p.x,f.y-p.y)<699) bad.push('ONE: fire '+i+' is only '+Math.round(Math.hypot(f.x-p.x,f.y-p.y))+' from the drop');
         for(j=0;j<g.zones.length;j++) if(Math.hypot(f.x-g.zones[j].x,f.y-g.zones[j].y)<299) bad.push('ONE: fire '+i+' is within 300 of ring '+j);
         if(!(f.at>=69.9&&f.at<=250.1)) bad.push('ONE: fire '+i+' lights at '+f.at.toFixed(0)+' s');
       }
       t1=firePlan({}); t2=firePlan({});
       if(JSON.stringify(t1)!==JSON.stringify(t2)) bad.push('ONE: the same seed planned two different sets of fires');
       // TWO: a lit fire is impassable: the player put on its edge, a machine too, and whoever touches it burns
       render2D(0);
       // open ground for the test fire: the centre and eight points round its edge are all clear of walls
       ok=0;
       for(i=-400;i<=400&&!ok;i+=40) for(j=-400;j<=400;j+=40){
         x0=p.x+i; y0=p.y+j;
         if(Math.hypot(i,j)<250||!spotFree(g.map,x0,y0,30)||!navReachable(g.map,x0,y0)) continue;
         free=1; for(z=0;z<8;z++) if(!spotFree(g.map,x0+Math.cos(z*0.7854)*(FIRE.r+30),y0+Math.sin(z*0.7854)*(FIRE.r+30),8)) free=0;
         if(free){ ok=1; break; }
       }
       if(!ok) return 'SKIP: staging: no open ground near the drop for a test fire';
       f=fireAdd(x0,y0,FIRE.r,FIRE.life,'test',0);
       p.arcSh=0; p.armor=0; p.iv=0; hp0=p.hp;
       e=mkCrawler(f.x-20,f.y+10); e.hp=e.maxhp=300; g.ents.push(e); eh0=e.hp;
       p.x=f.x+30; p.y=f.y+5;
       for(i=0;i<12;i++) flowTick(0.1);
       d=Math.hypot(p.x-f.x,p.y-f.y);
       if(d<f.r+(p.r||11)-0.5) bad.push('TWO: the player stands '+Math.round(d)+' from the middle of a fire of '+f.r);
       d=Math.hypot(e.x-f.x,e.y-f.y);
       if(d<f.r+e.r-0.5) bad.push('TWO: a machine stands '+Math.round(d)+' from the middle of a fire');
       if(!(p.hp<hp0)) bad.push('TWO: the player took no burn at the edge of a fire for 1.2 s (hp '+hp0+' to '+p.hp+')');
       if(!(e.hp<eh0)) bad.push('TWO: the machine took no burn at the edge (hp '+eh0+' to '+e.hp+')');
       // THREE: away from the fire nothing happens
       p.x=f.x+f.r+160; p.y=f.y; hp0=p.hp; ex0=p.x; ey0=p.y;
       for(i=0;i<8;i++) flowTick(0.1);
       if(p.hp<hp0||Math.abs(p.x-ex0)>0.01||Math.abs(p.y-ey0)>0.01) bad.push('THREE: a player 160 from the fire was moved or burned');
       // FOUR: the Director never lands a pack in a fire (a free spot inside one is refused, the same spot outside is not)
       ok=0;
       for(i=-120;i<=120&&!ok;i+=20) for(j=-120;j<=120;j+=20){
         x0=p.x+i; y0=p.y+j;
         if(Math.hypot(x0-f.x,y0-f.y)<f.r+80) continue;
         if(spotFree(g.map,x0,y0,22)&&navReachable(g.map,x0,y0)&&!shutRoomAt(g.map,x0,y0)&&!flowZoneNear(x0,y0,DIR.ring)){
           if(!arcadeWaveOk([],{x:x0+900,y:y0},x0,y0,0,5000)) continue;
           ok=1; z=fireAdd(x0,y0,40,FIRE.life,'test',0);
           if(arcadeWaveOk([],{x:x0+900,y:y0},x0,y0,0,5000)) bad.push('FOUR: a pack may land in a fire');
           else { z.t=999; if(!arcadeWaveOk([],{x:x0+900,y:y0},x0,y0,0,5000)) bad.push('FOUR: a spent fire still blocks the spot'); }
           break;
         }
       }
       // FIVE: the marks and the flames draw
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='fire'&&Math.abs(M[i].x-f.x)<1) mk++;
       if(!mk) bad.push('FIVE: the fire is not a mark on the maps');
       render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(f.x,0,f.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2&&cap[i][2]>=f.r*ZOOM()*0.99) hit++;
       if(!hit) bad.push('FIVE: no fire disc was drawn at the fire ('+cap.length+' arcs)');
       // SIX: it ends: after its life it is not a fire, and the embers go
       f.t=f.warn+f.life+1;
       if(fireAt(f.x,f.y,0)===f) bad.push('SIX: a fire past its life still blocks');
       p.x=f.x; p.y=f.y; flowTick(0.1);
       if(Math.hypot(p.x-f.x,p.y-f.y)>0.5) bad.push('SIX: a spent fire still moves the player');
       f.t=f.warn+f.life+FIRE.ember+1; flowTick(0.1);
       if(g.flow.fires.indexOf(f)>=0) bad.push('SIX: the embers never went out');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(proto&&oArc) proto.arc=oArc; }catch(_p){}
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
