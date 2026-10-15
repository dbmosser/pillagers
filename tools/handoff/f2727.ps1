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

if ($s.Contains("  {v:'27.27',what:")) { throw "check 27.27 is in the fixture already" }

SubRx @'
  {v:'27.26',what:
'@ @'
  {v:'27.27',what:'coop8, the two player first: the run goals are the party: player 2 has the three goals the host drew with their progress and says GOAL DONE, pays no chip of his own, player 2 kills and strikes and bounty kills count on the host, and the goals are in the hold Alt raid status',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof goalsTick!=='function'||typeof flowKill!=='function'||typeof raidStatusDraw!=='function'||typeof netEntsInit!=='function'||typeof evLaunch!=='function') return 'SKIP: no arcade, party or run goals in this fixture';
     var bad=[], g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, sent=[], posted=[], w=null, i, oIv, oSh, oAr, h={seat:0,state:'in'}, hp={seat:1,state:'in'}, staged=false, HGl=null, PGl, lines=[], rs=say, own=false, e=null, m0, kills0, ev, bo, c0, he, HE=null;
     function word(){ var q, r=null; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd'){ r=sent[q]; break; } return r; }
     function asHost(){ if(NET.role==='join') PGl=g.flow.goals; NET.role='host'; NET.seat=0; NET.peers=[hp]; g.flow.goals=HGl; }
     function asTwo(){ if(NET.role==='host') HGl=g.flow.goals; NET.role='join'; NET.seat=1; NET.peers=[h]; if(PGl) g.flow.goals=PGl; else delete g.flow.goals; }
     function sendTake(){ sent.length=0; asHost(); netWorldSend(); w=word(); asTwo(); if(w) netOnMsg(h,JSON.stringify(w)); return w; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; p.arcSh=0; p.armor=0; p.iv=0;
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       g.ents=g.ents.filter(function(q){ return !(q&&q.kind!=='peddler'&&q.kind!=='stray'&&dist(q,p)<1800); });
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0; NET.role='host'; NET.seat=0; NET.peers=[hp];
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ posted.push(JSON.parse(JSON.stringify(m))); return true; };
       g.t=2; flowTick(0.1);
       HGl=g.flow.goals; HE=evS(); HE.plan=[];
       if(!HGl||HGl.length!==3) return 'SKIP: staging: the raid drew no goals';
       // ONE: the host word carries the three goals, and player 2 has them
       sendTake();
       if(!w||!w.fl||!w.fl.r||w.fl.r.length!==3) bad.push('ONE: the host world word does not carry the goals (fl '+JSON.stringify(w&&w.fl&&Object.keys(w.fl))+')');
       if(!g.flow.goals||g.flow.goals.length!==3) bad.push('ONE: player 2 has '+(g.flow.goals?g.flow.goals.length:'no')+' goals, not 3');
       else for(i=0;i<3;i++) if(g.flow.goals[i].id!==HGl[i].id) bad.push('ONE: goal '+i+' is '+g.flow.goals[i].id+' for player 2 and '+HGl[i].id+' for the host');
       // TWO: a goal is met on the host: player 2 has it done, is told GOAL DONE, and is not paid a chip of his own
       asHost(); HGl[0].v=HGl[0].n; HGl[0].done=1; m0=ARCADE.mine|0;
       lines.length=0; sendTake();
       if(!g.flow.goals||!g.flow.goals[0]||!g.flow.goals[0].done) bad.push('TWO: the goal is done on the host and not for player 2');
       if(!lines.some(function(m){ return /^GOAL DONE/.test(m); })) bad.push('TWO: player 2 was not told GOAL DONE ('+lines.join(' / ')+')');
       flowTick(0.1);
       if((ARCADE.mine|0)!==m0) bad.push('TWO: player 2 window paid a chip into the score ('+m0+' to '+ARCADE.mine+')');
       // THREE: a body player 2 killed leaves the host list: the host counts it for the run goals
       asHost(); netEntsInit(g);
       he=mkCrawler(p.x+900,p.y); he.nid=g.nidN++; he.hp=0; he.bySeat=1; he.byPlayer=false; NET.entMap[he.nid]=he; g.ents.push(he);
       kills0=(g.flow.kills|0);
       g.ents.splice(g.ents.indexOf(he),1);
       netEntsTick();
       if(((g.flow.kills|0)-kills0)!==1) bad.push('THREE: a kill of player 2 counted '+((g.flow.kills|0)-kills0)+' on the host run goals, not 1');
       // FOUR: player 2 called a strike: it counts for AIR STRIKE on the host
       asHost(); c0=goalProg('air1',g.flow);
       netOnMsg(hp,JSON.stringify({t:'fl',k:'air',x:Math.round(p.x+700),y:Math.round(p.y),a:1.5,s:1}));
       if(goalProg('air1',g.flow)!==c0+1) bad.push('FOUR: a strike player 2 called did not count for AIR STRIKE ('+c0+' to '+goalProg('air1',g.flow)+')');
       // FIVE: player 2 kills the bounty pillager: the host claims the bounty
       asHost(); HE.live=[];
       ev=evLaunch('bounty');
       if(ev){
         ev.t=ev.warn; evTick(0.01);
         bo=ev.d.e;
         if(bo){ m0=ARCADE.mine|0; bo.hp=0; bo.byPlayer=false; bo.bySeat=1; evTick(0.01); if((ARCADE.mine|0)-m0!==BOUNTY.pay) bad.push('FIVE: player 2 killed the bounty pillager and the host score rose '+((ARCADE.mine|0)-m0)+', not '+BOUNTY.pay); }
       }
       // SIX: the goals are on the hold Alt raid status
       asHost(); RSTAT.lines=[]; render2D(0);
       if(raidStatusDraw()!==true) bad.push('SIX: the raid status did not draw');
       else if(!RSTAT.lines.some(function(m){ return /RUN GOAL/.test(m); })) bad.push('SIX: the raid status shows no run goal ('+RSTAT.lines.join(' / ').slice(0,200)+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       netSendFast=oSF; netSend=oS;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       keys={};
       try{ if(g&&HGl) g.flow.goals=HGl; }catch(_sh){}
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; p.hp=100; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
