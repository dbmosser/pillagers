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

if ($s.Contains("  {v:'26.81',what:")) { throw "check 26.81 is in the fixture already" }

SubRx @'
  {v:'26.80',what:
'@ @'
  {v:'26.81',what:'flow6, his yes to the machine convoy event: a ring at the start with a countdown, then a carrier (a Bulwark) and four armoured elite crawlers set off across the map for a far destination with the mark and ring on the carrier; killing the carrier drops the convoy crate (three cache rolls and a safe roll) and ends it; reaching the destination removes the train and drops nothing',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], E, ev, ev2, i, d, crew, car, e, n, M, mk, cr, nCr, cap=[], proto, oArc, s, hit, tagC='CONVOY '+'CRATE', needA='CONVOY '+'AWAY';
     function liveIt(x){ for(i=0;i<200&&x.ph==='warn';i++) flowTick(0.25); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof evLaunch!=='function'||typeof flowTick!=='function'||!EVENTS.convoy) return 'there is no convoy event in this build';
       p=g.player; keys={};
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0; g.t=5; flowTick(0.1); E=g.flow.ev; E.plan.length=0;
       // ONE: a launch: a start 700 to 1100 away, a far destination
       ev=evLaunch('convoy');
       if(!ev) return 'SKIP: staging: the convoy found no ground';
       d=Math.hypot(ev.x-p.x,ev.y-p.y);
       if(d<699||d>1101) bad.push('ONE: the start is '+Math.round(d)+' from the player');
       d=Math.hypot(ev.d.dx-ev.x,ev.d.dy-ev.y);
       if(d<1099) bad.push('ONE: the destination is only '+Math.round(d)+' from the start');
       // TWO: after the warning the train forms: a carrier (a Bulwark) and four armoured elite crawlers
       n=g.ents.length; liveIt(ev);
       if(ev.ph!=='live') bad.push('TWO: the convoy never went live');
       crew=ev.d.crew||[]; car=ev.d.car;
       if(crew.length!==5||!car) return 'TWO: the train is '+crew.length+' bodies';
       if(car.kind!=='bulwark'||!car.carrier) bad.push('TWO: the carrier is a '+car.kind);
       n=0; for(i=1;i<crew.length;i++){ e=crew[i]; if(e.kind==='crawler'&&e.elite&&e.armor>=70) n++; }
       if(n!==4) bad.push('TWO: '+n+' of the 4 escorts are armoured elite crawlers');
       for(i=0;i<crew.length;i++) if(g.ents.indexOf(crew[i])<0) bad.push('TWO: a body of the train is not in the world');
       for(i=0;i<crew.length;i++) if(crew[i].arcWave) bad.push('TWO: a body of the train is flagged as a wave (the cull would take it)');
       // THREE: they march: the carrier for the destination, the others on the carrier; a body that is fighting is left alone
       crew[2].state='chase';
       flowTick(0.25);
       if(car.state!=='investigate'||Math.hypot(car.tx-ev.d.dx,car.ty-ev.d.dy)>1) bad.push('THREE: the carrier is '+car.state+' heading '+Math.round(car.tx)+','+Math.round(car.ty)+', not for the destination');
       if(crew[1].state!=='investigate'||Math.hypot(crew[1].tx-car.x,crew[1].ty-car.y)>60) bad.push('THREE: an escort is not on the carrier ('+crew[1].state+')');
       if(crew[2].state!=='chase') bad.push('THREE: an escort that was fighting was sent marching');
       // FOUR: the mark and the ring are on the carrier
       car.x+=300; car.y+=40;
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='ev'&&Math.abs(M[i].x-car.x)<1&&Math.abs(M[i].y-car.y)<1) mk++;
       if(!mk) bad.push('FOUR: the mark is not on the carrier');
       render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(car.x,0,car.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2&&Math.abs(cap[i][2]-ev.r*ZOOM())<1.5) hit++;
       if(!hit) bad.push('FOUR: no ring was drawn on the carrier ('+cap.length+' arcs)');
       // FIVE: the carrier dies where it stands: the crate, with loot, marked, and the event ends
       car.hp=0; car.x-=300; car.y-=40; nCr=0; lines.length=0;
       flowTick(0.25);
       for(i=0;i<g.containers.length;i++){ cr=g.containers[i]; if(cr&&cr.tag===tagC){ nCr++; if(!cr.loot||cr.loot.length<4) bad.push('FIVE: the crate holds '+(cr.loot?cr.loot.length:0)+' items'); if(Math.hypot(cr.x-car.x,cr.y-car.y)>1) bad.push('FIVE: the crate is not where the carrier fell'); } }
       if(nCr!==1) bad.push('FIVE: '+nCr+' convoy crates');
       if(ev.ph!=='end') bad.push('FIVE: the event is '+ev.ph+' after the carrier died');
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='loot'&&Math.abs(M[i].x-car.x)<1) mk++;
       if(!mk) bad.push('FIVE: the crate is not a mark on the maps');
       // SIX: a second convoy gets away: the train is gone, no crate
       for(i=0;i<20;i++) flowTick(0.25);
       ev2=evLaunch('convoy');
       if(ev2){
         liveIt(ev2); car=ev2.d.car; crew=ev2.d.crew;
         if(!car) bad.push('SIX: the second train never formed');
         else {
           car.x=ev2.d.dx-20; car.y=ev2.d.dy; lines.length=0;
           flowTick(0.25);
           if(ev2.ph!=='end') bad.push('SIX: the event is '+ev2.ph+' with the carrier at the destination');
           for(i=0;i<crew.length;i++) if(g.ents.indexOf(crew[i])>=0) bad.push('SIX: a body of the train is still in the world');
           n=0; for(i=0;i<g.containers.length;i++) if(g.containers[i]&&g.containers[i].tag===tagC) n++;
           if(n!==1) bad.push('SIX: '+n+' convoy crates after a train got away');
           e=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf(needA)>=0) e=1;
           if(!e) bad.push('SIX: no CONVOY AWAY callout');
         }
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
  {v:'26.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
