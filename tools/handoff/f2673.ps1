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

if ($s.Contains("  {v:'26.73',what:")) { throw "check 26.73 is in the fixture already" }

SubRx @'
  {v:'26.72',what:
'@ @'
  {v:'26.73',what:'flow3, his yes to run goals: every raid draws three small goals (the same three for the same seed), the two kill doors count what died, a met goal pays its chip into the DEMO score and into the CAREER raid score and only once, and the panel draws all three',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], S, ids, t1={}, t2={}, i, sd, seen={}, nset=0, m0, k0, oA, oC, oCs, oSeed, sawG, needG='GOAL '+'DONE', rows;
     function idsOf(o){ return o.goals.map(function(q){ return q.id; }).join(','); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof goalsMake!=='function'||typeof flowTick!=='function') return 'there are no run goals in this build';
       p=g.player; keys={}; oA=g.arcade; oC=g.career; oCs=g.cs; oSeed=g.seed;
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0;
       // ONE: three goals, distinct, each with a chip
       flowTick(0.1); S=g.flow;
       if(!S||!S.goals||S.goals.length!==3) return 'ONE: the raid drew '+(S&&S.goals?S.goals.length:'no')+' goals';
       ids=S.goals.map(function(q){ return q.id; });
       if(ids[0]===ids[1]||ids[1]===ids[2]||ids[0]===ids[2]) bad.push('ONE: the goals repeat: '+ids.join(','));
       for(i=0;i<3;i++) if(!(S.goals[i].chip>0)||!(S.goals[i].n>0)||!S.goals[i].t) bad.push('ONE: goal '+i+' has no chip, count or words');
       // TWO: the same seed gives the same three, and the seeds differ from each other
       goalsMake(t1); goalsMake(t2);
       if(idsOf(t1)!==idsOf(t2)||idsOf(t1)!==ids.join(',')) bad.push('TWO: the same seed drew '+idsOf(t1)+' then '+idsOf(t2)+' (the raid has '+ids.join(',')+')');
       for(sd=1;sd<=8;sd++){ g.seed=sd*977; goalsMake(t1); if(!seen[idsOf(t1)]){ seen[idsOf(t1)]=1; nset++; } }
       g.seed=oSeed;
       if(nset<2) bad.push('TWO: eight seeds drew one set of goals');
       // THREE: the two kill doors count what died
       S.kills=0; S.kinds={}; S.elites=0; S.wardens=0;
       arcadeKill('crawler',true,false,p.x,p.y);
       if((S.kills|0)!==1||(S.elites|0)!==1) bad.push('THREE: arcadeKill left kills '+S.kills+' elites '+S.elites);
       arcadeKill('warden',false,false,p.x,p.y);
       if((S.wardens|0)!==1) bad.push('THREE: a warden kill counted '+S.wardens);
       arcadeKill('warden',false,true,p.x,p.y);
       if((S.wardens|0)!==1||(S.boss|0)!==1) bad.push('THREE: the Overseer counted as a warden ('+S.wardens+') or not as the boss ('+S.boss+')');
       g.arcade=0; g.career=1; g.cs={s:0,k:0,waveT:0,waveN:0};
       k0=S.kills|0; careerKill('raider',false,false,p.x,p.y);
       if((S.kills|0)!==k0+1||(S.kinds.raider|0)!==1) bad.push('THREE: careerKill left kills '+S.kills+' raiders '+(S.kinds.raider|0));
       // FOUR: a met goal pays its chip into the CAREER raid score as into the DEMO score
       g.cs.s=0; flowChip(150,'X','Y');
       if(g.cs.s!==150) bad.push('FOUR: a chip paid '+g.cs.s+' into the CAREER score, not 150');
       g.career=oC; g.arcade=oA; g.cs=oCs;
       // FIVE: the chip is paid once, when the goal is met
       S.goals=[{id:'kill10',t:'10 KILLS',n:10,chip:200,v:0,done:0},{id:'ward',t:'DOWN A WARDEN',n:1,chip:500,v:0,done:0},{id:'elite',t:'KILL AN ELITE',n:1,chip:400,v:0,done:0}];
       S.kills=9; S.wardens=0; S.elites=0; m0=ARCADE.mine|0; lines.length=0; flowTick(0.1);
       if((ARCADE.mine|0)!==m0||S.goals[0].done) bad.push('FIVE: a goal at 9 of 10 paid or finished');
       S.kills=10; flowTick(0.1);
       if((ARCADE.mine|0)!==m0+200||!S.goals[0].done) bad.push('FIVE: the goal met paid '+((ARCADE.mine|0)-m0)+', not 200');
       sawG=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf(needG)>=0) sawG=1;
       if(!sawG) bad.push('FIVE: no GOAL DONE callout (said: '+lines.slice(-3).join(' / ')+')');
       flowTick(0.1); flowTick(0.1);
       if((ARCADE.mine|0)!==m0+200) bad.push('FIVE: the chip was paid again ('+((ARCADE.mine|0)-m0)+')');
       // SIX: the panel draws every goal
       render2D(0); rows=goalsHud(ctx);
       if(rows!==3) bad.push('SIX: the panel drew '+rows+' goals');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(g){ g.arcade=oA; g.career=oC; g.cs=oCs; g.seed=oSeed; } }catch(_g){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
