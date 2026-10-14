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

if ($s.Contains("  {v:'26.80',what:")) { throw "check 26.80 is in the fixture already" }

SubRx @'
  {v:'26.79',what:
'@ @'
  {v:'26.80',what:'flow5, his yes to the raid events (the framework and the first, orbital debris): a raid plans one or two events on its seed, an event has a countdown ring and a map mark, then five pieces of debris come down on shadows, hurt what they land on, and leave burning wrecks with loot on their edge',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], E, ev, i, j, n, t1, t2, d, M, mk, c, cr, hp0, e, cap=[], proto, oArc, s, hit, oSh, oAr, oIv, pt, nW, nF, tagD='DEBRIS '+'WRECK', needN='ORBITAL '+'DEBRIS', saw, tw=0;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof evLaunch!=='function'||typeof flowTick!=='function') return 'there are no raid events in this build';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv;
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0;
       // ONE: the plan: one or two events, the first 150 to 215 s in, the second 150 to 200 s after it
       g.t=5; flowTick(0.1); E=g.flow&&g.flow.ev;
       if(!E||!E.plan||E.plan.length<1||E.plan.length>2) return 'ONE: the raid planned '+(E&&E.plan?E.plan.length:'no')+' events';
       if(!(E.plan[0].at>=149.9&&E.plan[0].at<=215.1)) bad.push('ONE: the first event is at '+E.plan[0].at.toFixed(0)+' s');
       if(E.plan.length===2&&!(E.plan[1].at-E.plan[0].at>=149.9&&E.plan[1].at-E.plan[0].at<=200.1)) bad.push('ONE: the second event is '+(E.plan[1].at-E.plan[0].at).toFixed(0)+' s after the first');
       t1=evPlan({}); t2=evPlan({});
       if(JSON.stringify(t1)!==JSON.stringify(t2)) bad.push('ONE: the same seed planned two different sets of events');
       // TWO: a launch: a place 500 to 1000 away, off the rings, a callout, a mark
       E.plan.length=0; lines.length=0;
       ev=evLaunch('debris');
       if(!ev) return 'SKIP: staging: the debris found no ground';
       d=Math.hypot(ev.x-p.x,ev.y-p.y);
       if(d<499||d>1001) bad.push('TWO: the event ring is '+Math.round(d)+' from the player');
       for(j=0;j<g.zones.length;j++) if(Math.hypot(ev.x-g.zones[j].x,ev.y-g.zones[j].y)<419) bad.push('TWO: the event ring is within 420 of ring '+j);
       saw=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf(needN)>=0) saw=1;
       if(!saw) bad.push('TWO: no callout (said: '+lines.slice(-3).join(' / ')+')');
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='ev'&&Math.abs(M[i].x-ev.x)<1&&String(M[i].txt).indexOf(needN)===0) mk++;
       if(!mk) bad.push('TWO: the event is not a mark on the maps');
       // THREE: the countdown ring is drawn on the HUD
       p.arcSh=0; p.armor=0; p.iv=0;
       render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(ev.x,0,ev.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2&&Math.abs(cap[i][2]-ev.r*ZOOM())<1.5) hit++;
       if(hit<2) bad.push('THREE: the countdown ring was drawn '+hit+' times at the event ('+cap.length+' arcs)');
       // FOUR: the countdown runs 22 s, then the event is live with its pieces planned
       for(i=0;i<200&&ev.ph==='warn';i++){ flowTick(0.25); tw+=0.25; }
       if(ev.ph!=='live') bad.push('FOUR: the event never went live ('+ev.ph+' at '+ev.t.toFixed(1)+')');
       if(Math.abs(tw-22)>0.6) bad.push('FOUR: the countdown took '+tw+' s, not 22');
       if(!(ev.d.pts&&ev.d.pts.length>=3)) bad.push('FOUR: the event planned '+(ev.d.pts?ev.d.pts.length:0)+' pieces');
       // FIVE: the pieces come down: fires and wrecks with loot, and the event ends and goes
       p.x=ev.x+ev.r*3; p.y=ev.y;
       for(i=0;i<200&&ev.ph==='live';i++) flowTick(0.25);
       nF=0; for(i=0;i<g.flow.fires.length;i++) if(g.flow.fires[i].src==='debris') nF++;
       nW=0; for(i=0;i<g.containers.length;i++){ cr=g.containers[i]; if(cr&&cr.tag===tagD){ nW++; if(!cr.loot||!cr.loot.length) bad.push('FIVE: a wreck holds nothing'); } }
       n=ev.d.pts.length;
       if(nF!==n) bad.push('FIVE: '+n+' pieces left '+nF+' fires');
       if(nW!==n) bad.push('FIVE: '+n+' pieces left '+nW+' wrecks');
       for(i=0;i<40&&g.flow.ev.live.length;i++) flowTick(0.25);
       if(g.flow.ev.live.length) bad.push('FIVE: the event never ended and went');
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='loot') mk++;
       if(mk!==nW) bad.push('FIVE: '+mk+' wrecks marked of '+nW);
       // SIX: a piece hurts what it lands on: a machine dies, the player is hurt, a far one is not
       pt={x:ev.x,y:ev.y,i:20}; p.x=pt.x+20; p.y=pt.y; hp0=p.hp;
       e=mkCrawler(pt.x-15,pt.y); g.ents.push(e); cr=mkCrawler(pt.x+400,pt.y); g.ents.push(cr);
       debrisImpact(ev,pt);
       if(!(e.hp<=0)) bad.push('SIX: a machine under a piece lives ('+e.hp+')');
       if(!(cr.hp>=cr.maxhp)) bad.push('SIX: a machine 400 away was hurt');
       if(!(p.hp<hp0)) bad.push('SIX: the player under a piece took nothing ('+hp0+' to '+p.hp+')');
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
  {v:'26.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
