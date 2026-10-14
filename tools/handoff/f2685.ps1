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

if ($s.Contains("  {v:'26.85',what:")) { throw "check 26.85 is in the fixture already" }

SubRx @'
  {v:'26.84',what:
'@ @'
  {v:'26.85',what:'flow9, his yes to the lockdown alarm event: a ring with a cache in the middle and a countdown, then for 60 s the doors seal the district (bodies inside stay in, bodies outside stay out, the player too), the machines inside go berserk (faster, harder, on the chase) with a garrison made up to five, then the doors open, the berserk go on for 20 s, and it ends with the cache marked until opened',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, E, ev, i, j, d, a, ok, cache, inn, e, be, M, mk, cap=[], proto, oArc, s, hit, x0, y0, ang, tagC='LOCKDOWN '+'CACHE', spd0, tmp;
     function liveIt(x){ for(i=0;i<200&&x.ph==='warn';i++) flowTick(0.25); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof evLaunch!=='function'||typeof flowTick!=='function'||!EVENTS.lock) return 'there is no lockdown event in this build';
       p=g.player; keys={};
       say=function(m,kd,o){}; own=true;
       ARCADE.mine=0; ARCADE.holdT=0; g.t=5; flowTick(0.1); E=g.flow.ev; E.plan.length=0;
       // ONE: a launch with a cache already in the middle
       ev=evLaunch('lock');
       if(!ev) return 'SKIP: staging: the lockdown found no ground';
       d=Math.hypot(ev.x-p.x,ev.y-p.y);
       if(d<449||d>1001) bad.push('ONE: the district is '+Math.round(d)+' from the player');
       for(j=0;j<g.zones.length;j++) if(Math.hypot(ev.x-g.zones[j].x,ev.y-g.zones[j].y)<449) bad.push('ONE: the district is within 450 of ring '+j);
       cache=null; for(i=0;i<g.containers.length;i++) if(g.containers[i]&&g.containers[i].tag===tagC) cache=g.containers[i];
       if(!cache||cache.loot.length<4||Math.hypot(cache.x-ev.x,cache.y-ev.y)>1) bad.push('ONE: no cache of four items in the middle of the district');
       // TWO: nothing is sealed during the warning
       p.x=ev.x+ev.r-30; p.y=ev.y; tmp=p.x;
       flowTick(0.25);
       if(Math.abs(p.x-tmp)>0.01) bad.push('TWO: the player was moved during the warning');
       p.x=ev.x+ev.r+400; p.y=ev.y;
       // THREE: the doors slam: a garrison of five that is berserk, faster and harder
       liveIt(ev);
       if(ev.ph!=='live') bad.push('THREE: the lockdown never went live');
       inn=ev.d.in||[];
       if(inn.length<5) bad.push('THREE: '+inn.length+' machines inside, not five');
       for(i=0;i<inn.length;i++){
         e=inn[i];
         if(!e.berserk||!(e.lkSpd>0)||Math.abs(e.spd-e.lkSpd*LOCK.fast)>0.01) bad.push('THREE: a machine inside is not berserk and fast ('+e.spd+' of '+e.lkSpd+')');
         if(Math.hypot(e.x-ev.x,e.y-ev.y)>ev.r+1) bad.push('THREE: a machine of the garrison stands outside the ring');
       }
       if(ev.d.pSide!==2) bad.push('THREE: the player outside was counted inside');
       // an angle with open ground just inside and just outside the ring
       ok=0;
       for(j=0;j<48&&!ok;j++){
         ang=j*0.1309; x0=Math.cos(ang); y0=Math.sin(ang);
         if(spotFree(g.map,ev.x+x0*(ev.r-30),ev.y+y0*(ev.r-30),12)&&spotFree(g.map,ev.x+x0*(ev.r+40),ev.y+y0*(ev.r+40),12)&&spotFree(g.map,ev.x+x0*(ev.r-21),ev.y+y0*(ev.r-21),10)&&spotFree(g.map,ev.x+x0*(ev.r+17),ev.y+y0*(ev.r+17),8)) ok=1;
       }
       if(!ok) return 'SKIP: staging: no open ground across the ring';
       // FOUR: sealed: the player who crosses in is put back out; a machine who crosses out is put back in
       p.x=ev.x+x0*(ev.r-30); p.y=ev.y+y0*(ev.r-30);
       flowTick(0.25);
       d=Math.hypot(p.x-ev.x,p.y-ev.y);
       if(d<ev.r+(p.r||11)) bad.push('FOUR: the player who crossed in stands '+Math.round(d)+' from the middle of a ring of '+ev.r);
       e=mkCrawler(ev.x+x0*(ev.r+40),ev.y+y0*(ev.r+40)); e.lkSide=1; g.ents.push(e); be=inn[0];
       flowTick(0.25);
       d=Math.hypot(e.x-ev.x,e.y-ev.y);
       if(d>ev.r-(e.r||12)+0.5) bad.push('FOUR: a machine that crossed out stands '+Math.round(d)+' from the middle');
       // FIVE: the machines hunt the player, the ring is a mark and is drawn
       if(be.state!=='chase') bad.push('FIVE: a berserk machine is '+be.state);
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='ev'&&Math.abs(M[i].x-ev.x)<1) mk++;
       if(!mk) bad.push('FIVE: the district is not a mark on the maps');
       render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(ev.x,0,ev.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2&&Math.abs(cap[i][2]-ev.r*ZOOM())<1.5) hit++;
       if(hit<2) bad.push('FIVE: the ring was drawn '+hit+' times ('+cap.length+' arcs)');
       // SIX: at 60 s the doors open: nobody is held, the berserk stay on the chase
       ev.lt=LOCK.seal+0.2; flowTick(0.25);
       p.x=ev.x+x0*(ev.r-30); p.y=ev.y+y0*(ev.r-30); tmp=p.x;
       flowTick(0.25);
       if(Math.abs(p.x-tmp)>0.01) bad.push('SIX: the player was held after the doors opened');
       if(!be.berserk) bad.push('SIX: the machines calmed the moment the doors opened');
       // SEVEN: after 20 s more it ends and the machines are as they were
       spd0=be.lkSpd; ev.lt=ev.dur-0.1; flowTick(0.25);
       if(ev.ph!=='end') bad.push('SEVEN: the lockdown is '+ev.ph);
       if(be.berserk||Math.abs(be.spd-spd0)>0.01) bad.push('SEVEN: a machine is still berserk ('+be.spd+' against '+spd0+')');
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
  {v:'26.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
