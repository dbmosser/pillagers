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

if ($s.Contains("  {v:'26.83',what:")) { throw "check 26.83 is in the fixture already" }

SubRx @'
  {v:'26.82',what:
'@ @'
  {v:'26.83',what:'flow8, his yes to the coolant rupture event: a ring and a countdown, then for 75 s a cloud in which the player sees 45 percent as far at the middle, a cryo round builds cold twice as fast, and every shut crate, locker, safe and cache inside holds one more item; outside it nothing changes, and it ends and all goes back',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, E, ev, i, d, cin, cout, cop, cfar, n0, v1, v2, v3, e1, e2, cap=[], proto, oArc, s, hit, c1, c2, M, mk;
     function liveIt(x){ for(i=0;i<200&&x.ph==='warn';i++) flowTick(0.25); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof evLaunch!=='function'||typeof flowTick!=='function'||!EVENTS.cool) return 'there is no coolant event in this build';
       p=g.player; keys={};
       say=function(m,kd,o){};
       own=true;
       ARCADE.mine=0; ARCADE.holdT=0; g.t=5; flowTick(0.1); E=g.flow.ev; E.plan.length=0;
       // ONE: a launch, 450 to 1000 away, off the rings
       ev=evLaunch('cool');
       if(!ev) return 'SKIP: staging: the coolant rupture found no ground';
       d=Math.hypot(ev.x-p.x,ev.y-p.y);
       if(d<449||d>1001) bad.push('ONE: the cloud is '+Math.round(d)+' from the player');
       // crates: one inside and shut, one inside and opened, one far outside
       cin=mkContainer(ev.x+60,ev.y,'crate'); cop=mkContainer(ev.x-60,ev.y,'crate'); cop.opened=true; cfar=mkContainer(ev.x+ev.r+250,ev.y,'crate');
       g.containers.push(cin,cop,cfar); n0=[cin.loot.length,cop.loot.length,cfar.loot.length];
       // TWO: before it is live nothing has changed
       p.x=ev.x; p.y=ev.y; v1=VF();
       p.x=ev.x+ev.r+300; p.y=ev.y; v2=VF();
       if(Math.abs(v1-v2)>1e-6||flowVis()!==1) bad.push('TWO: the view changed before the cloud was live ('+v1.toFixed(0)+' against '+v2.toFixed(0)+')');
       // THREE: live: the crates inside gain an item
       liveIt(ev);
       if(ev.ph!=='live') bad.push('THREE: the cloud never went live');
       if(!cin.rich||cin.loot.length!==n0[0]+1) bad.push('THREE: the shut crate inside holds '+cin.loot.length+', not '+(n0[0]+1));
       if(cop.rich||cop.loot.length!==n0[1]) bad.push('THREE: an opened crate was enriched');
       if(cfar.rich||cfar.loot.length!==n0[2]) bad.push('THREE: a crate outside was enriched');
       // FOUR: inside the player sees less; at the rim and outside, as before
       p.x=ev.x; p.y=ev.y; v1=VF();
       p.x=ev.x+ev.r+300; p.y=ev.y; v2=VF();
       p.x=ev.x+ev.r*0.75; p.y=ev.y; v3=VF();
       if(!(v1<=v2*0.46)) bad.push('FOUR: the view in the middle is '+v1.toFixed(0)+', against '+v2.toFixed(0)+' outside');
       if(!(v3<v2&&v3>v1)) bad.push('FOUR: the view at three quarters out ('+v3.toFixed(0)+') is not between '+v1.toFixed(0)+' and '+v2.toFixed(0));
       p.x=ev.x; p.y=ev.y; v1=AMBR(); p.x=ev.x+ev.r+300; v2=AMBR();
       if(!(v1<=v2*0.46)) bad.push('FOUR: the ambient reach in the middle is '+v1.toFixed(0)+', against '+v2.toFixed(0)+' outside');
       // FIVE: a cryo round builds twice the cold inside
       e1=mkCrawler(ev.x,ev.y+20); e2=mkCrawler(ev.x+ev.r+300,ev.y+20); g.ents.push(e1,e2);
       elemHit(e1,'cryo',50,0,0,0); elemHit(e2,'cryo',50,0,0,0);
       if(Math.abs((e1.chill||0)-2*(e2.chill||0))>0.01||!(e2.chill>0)) bad.push('FIVE: a cryo hit gave '+(e1.chill||0)+' cold inside and '+(e2.chill||0)+' outside');
       // SIX: the cloud and the glints are drawn, and the mark is on the maps
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='ev'&&Math.abs(M[i].x-ev.x)<1) mk++;
       if(!mk) bad.push('SIX: the cloud is not a mark on the maps');
       p.x=ev.x+ev.r+300; p.y=ev.y; render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(ev.x,0,ev.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2&&cap[i][2]>ev.r*ZOOM()) hit++;
       if(!hit) bad.push('SIX: no cloud was drawn over the district ('+cap.length+' arcs)');
       // SEVEN: it ends: after 75 s the view is back
       ev.lt=ev.dur-0.1; flowTick(0.25);
       if(ev.ph!=='end') bad.push('SEVEN: the cloud is '+ev.ph+' after its time');
       p.x=ev.x; p.y=ev.y; v1=VF(); p.x=ev.x+ev.r+300; v2=VF();
       if(Math.abs(v1-v2)>1e-6) bad.push('SEVEN: the view is still short after the cloud ended');
       e1.chill=0; elemHit(e1,'cryo',50,0,0,0);
       if(Math.abs((e1.chill||0)-2)>0.01) bad.push('SEVEN: a cryo hit still gives double cold after it ended ('+e1.chill+')');
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
  {v:'26.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
