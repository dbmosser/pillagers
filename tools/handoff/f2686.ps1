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

if ($s.Contains("  {v:'26.86',what:")) { throw "check 26.86 is in the fixture already" }

SubRx @'
  {v:'26.85',what:
'@ @'
  {v:'26.86',what:'flow10, his yes to the Overseer rampage event: with the Overseer alive a ring and a countdown on it, then for 120 s it is off its leash, 60 percent faster, its lair moved to each of three waypoints in turn and then to the player, the mark and ring on it; the end (or its death) puts the lair and the speed back',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, E, ev, ev2, i, b, l0x, l0y, spd0, w, M, mk, cap=[], proto, oArc, s, hit, saw, needR='RAMP'+'AGE';
     function liveIt(x){ for(i=0;i<200&&x.ph==='warn';i++) flowTick(0.25); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof evLaunch!=='function'||typeof flowTick!=='function'||!EVENTS.rampage) return 'there is no rampage event in this build';
       p=g.player; keys={};
       say=function(m,kd,o){ if(String(m).indexOf(needR)>=0) saw=1; }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0; g.t=5; flowTick(0.1); E=g.flow.ev; E.plan.length=0;
       b=g.bossRef; if(!b){ g.bossDone=0; b=bossTick(true); }
       if(!b||!(b.hp>0)) return 'SKIP: staging: no Overseer in the fixture raid';
       l0x=b.lairX; l0y=b.lairY; spd0=b.spd;
       // ONE: a launch rings the Overseer
       ev=evLaunch('rampage');
       if(!ev) return 'ONE: no rampage launched with the Overseer alive';
       if(Math.hypot(ev.x-b.x,ev.y-b.y)>1) bad.push('ONE: the ring is not on the Overseer');
       if(evLaunch('rampage')) bad.push('ONE: a second rampage launched on the Overseer already on one');
       // TWO: live: off the leash, faster, three waypoints in three different quarters
       saw=0; liveIt(ev);
       if(ev.ph!=='live') bad.push('TWO: the rampage never went live');
       w=ev.d.wps||[];
       if(w.length!==3) bad.push('TWO: '+w.length+' waypoints');
       else {
         if(Math.abs(b.spd-spd0*RAMP.fast)>0.01) bad.push('TWO: the Overseer walks at '+b.spd+', not '+(spd0*RAMP.fast));
         if(!saw) bad.push('TWO: no OVERSEER RAMPAGE callout');
         s=0; for(i=0;i<3;i++) s+=((w[i].x<WORLD_W/2)?1:2)+((w[i].y<WORLD_H/2)?0:2);
         if(w[0].x===w[1].x||(((w[0].x<WORLD_W/2)===(w[1].x<WORLD_W/2))&&((w[0].y<WORLD_H/2)===(w[1].y<WORLD_H/2)))) bad.push('TWO: two waypoints are in the same quarter');
         if(Math.hypot(b.lairX-w[0].x,b.lairY-w[0].y)>1||Math.hypot(b.tx-w[0].x,b.ty-w[0].y)>1||!b.seenYou) bad.push('TWO: the Overseer is not heading for the first waypoint');
       }
       // THREE: arriving at a waypoint sends it to the next, and after the third it comes for the player
       if(w.length===3){
         b.x=w[0].x+30; b.y=w[0].y; flowTick(0.25);
         if(Math.hypot(b.lairX-w[1].x,b.lairY-w[1].y)>1) bad.push('THREE: after the first waypoint it is not on the second');
         b.x=w[1].x; b.y=w[1].y; flowTick(0.25); b.x=w[2].x; b.y=w[2].y; flowTick(0.25);
         p.x+=300; p.y+=100; flowTick(0.25);
         if(Math.hypot(b.lairX-p.x,b.lairY-p.y)>1||Math.hypot(b.tx-p.x,b.ty-p.y)>1) bad.push('THREE: after the third waypoint it is not coming for the player');
       }
       // FOUR: the mark and the ring are on the Overseer
       b.x=ev.x+400; b.y=ev.y;
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='ev'&&Math.abs(M[i].x-b.x)<1&&Math.abs(M[i].y-b.y)<1) mk++;
       if(!mk) bad.push('FOUR: the mark is not on the Overseer');
       render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(b.x,0,b.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2&&Math.abs(cap[i][2]-ev.r*ZOOM())<1.5) hit++;
       if(!hit) bad.push('FOUR: no ring was drawn on the Overseer ('+cap.length+' arcs)');
       // FIVE: the end puts its lair and speed back
       ev.lt=ev.dur-0.1; flowTick(0.25);
       if(ev.ph!=='end') bad.push('FIVE: the rampage is '+ev.ph+' after its time');
       if(b.rmp||b.lairX!==l0x||b.lairY!==l0y||Math.abs(b.spd-spd0)>0.01) bad.push('FIVE: the Overseer is not as it was (lair '+Math.round(b.lairX)+','+Math.round(b.lairY)+' of '+Math.round(l0x)+','+Math.round(l0y)+', speed '+b.spd+' of '+spd0+')');
       // SIX: a second rampage ends when the Overseer dies, with its lair and speed back
       for(i=0;i<20;i++) flowTick(0.25);
       ev2=evLaunch('rampage');
       if(ev2){
         liveIt(ev2); b.hp=0; flowTick(0.25);
         if(ev2.ph!=='end') bad.push('SIX: the rampage is '+ev2.ph+' after the Overseer died');
         if(b.rmp||b.lairX!==l0x||b.spd!==spd0&&Math.abs(b.spd-spd0)>0.01) bad.push('SIX: the dead Overseer keeps its rampage lair or speed');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(proto&&oArc) proto.arc=oArc; }catch(_p){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
