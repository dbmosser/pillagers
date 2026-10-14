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

if ($s.Contains("  {v:'26.82',what:")) { throw "check 26.82 is in the fixture already" }

SubRx @'
  {v:'26.81',what:
'@ @'
  {v:'26.82',what:'flow7, his yes to the bounty pillager event: a ring where he comes in, then a hostile pillager with four times the health, plate and a rich bag hunts the player every frame with the mark and ring on him; downing him pays 1,500 into the score once, a kill that was not the player pays nothing, and after 150 s on the hunt he slips away',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], E, ev, ev2, ev3, i, d, e, M, mk, cap=[], proto, oArc, s, hit, m0, saw, needC='BOUNTY '+'CLAIMED';
     function liveIt(x){ for(i=0;i<200&&x.ph==='warn';i++) flowTick(0.25); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof evLaunch!=='function'||typeof flowTick!=='function'||!EVENTS.bounty) return 'there is no bounty event in this build';
       p=g.player; keys={};
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0; g.t=5; flowTick(0.1); E=g.flow.ev; E.plan.length=0;
       // ONE: a launch, 700 to 1000 away; then the pillager steps in
       ev=evLaunch('bounty');
       if(!ev) return 'SKIP: staging: the bounty found no ground';
       d=Math.hypot(ev.x-p.x,ev.y-p.y);
       if(d<699||d>1001) bad.push('ONE: he comes in '+Math.round(d)+' from the player');
       liveIt(ev); e=ev.d.e;
       if(ev.ph!=='live'||!e) return 'ONE: no pillager after the warning';
       if(e.kind!=='raider'||!e.hostile) bad.push('ONE: the bounty is a '+e.kind+(e.hostile?'':' that is not hostile'));
       if(e.maxhp<78*CFG.eHp*3.9) bad.push('ONE: his health is '+e.maxhp);
       if(!(e.armor>=99)) bad.push('ONE: his plate is '+e.armor);
       if(!(e.bag&&e.bag.length>=3)) bad.push('ONE: his bag holds '+(e.bag?e.bag.length:0));
       if(g.ents.indexOf(e)<0) bad.push('ONE: he is not in the world');
       // TWO: he hunts: each frame on the chase toward where the player stands now
       p.x+=250; p.y+=30; e.state='patrol'; e.alert=0;
       flowTick(0.25);
       if(e.state!=='chase'||!(e.alert>=3)||Math.hypot(e.tx-p.x,e.ty-p.y)>1) bad.push('TWO: he is '+e.state+' with alert '+e.alert+' aimed at '+Math.round(e.tx)+','+Math.round(e.ty));
       // THREE: the mark and the ring are on him
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='ev'&&Math.abs(M[i].x-e.x)<1&&Math.abs(M[i].y-e.y)<1) mk++;
       if(!mk) bad.push('THREE: the mark is not on him');
       render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(e.x,0,e.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2&&Math.abs(cap[i][2]-ev.r*ZOOM())<1.5) hit++;
       if(!hit) bad.push('THREE: no ring was drawn on him ('+cap.length+' arcs)');
       // FOUR: downed by the player: the bounty is paid once, into the score
       m0=ARCADE.mine|0; lines.length=0; e.hp=0; e.byPlayer=true;
       flowTick(0.25);
       if((ARCADE.mine|0)!==m0+BOUNTY.pay) bad.push('FOUR: the bounty paid '+((ARCADE.mine|0)-m0)+', not '+BOUNTY.pay);
       if(ev.ph!=='end') bad.push('FOUR: the event is '+ev.ph+' after he went down');
       saw=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf(needC)>=0) saw=1;
       if(!saw) bad.push('FOUR: no BOUNTY CLAIMED callout');
       for(i=0;i<8;i++) flowTick(0.25);
       if((ARCADE.mine|0)!==m0+BOUNTY.pay) bad.push('FOUR: the bounty was paid again');
       // FIVE: killed by something else: nothing is paid
       ev2=evLaunch('bounty');
       if(ev2){
         liveIt(ev2); e=ev2.d.e; m0=ARCADE.mine|0;
         if(e){ e.hp=0; e.byPlayer=false; flowTick(0.25); if((ARCADE.mine|0)!==m0) bad.push('FIVE: a bounty was paid for a kill that was not the player'); if(ev2.ph!=='end') bad.push('FIVE: the event is '+ev2.ph+' after he was killed'); }
       }
       // SIX: after 150 s on the hunt he slips away
       ev3=evLaunch('bounty');
       if(ev3){
         liveIt(ev3); e=ev3.d.e;
         if(e){ ev3.lt=ev3.dur-0.1; flowTick(0.25); if(ev3.ph!=='end') bad.push('SIX: the hunt never ended ('+ev3.ph+')'); if(g.ents.indexOf(e)>=0) bad.push('SIX: he is still in the world after the hunt'); }
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
  {v:'26.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
