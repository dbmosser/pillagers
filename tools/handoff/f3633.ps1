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

if ($s.Contains("  {v:'36.33',what:")) { throw "check 36.33 is in the fixture already" }

SubRx @'
  {v:'36.32',what:
'@ @'
  {v:'36.33',what:'changing run goals never pay SP: career cash and cache items settle only on extraction, each seat banks its own, and arcade goals drop power-ups once without team score',
   run:function(){
     var g, S, gl, before, score, drop, r, item, count, savedP=JSON.stringify(P), nk={}, k, lines=[], rs=say;
     function goal(id){ return {id:id,t:GOALS[id].t,n:GOALS[id].n,chip:GOALS[id].chip,v:0,done:0}; }
     function prep(){
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       NET.on=false; NET.role='host';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); careerPostBuild(g); g.ents.length=0; g.bag=[]; g.pedCarry=0; P.merc=null; g.mercId=null; P.racks=0; P.arrays=0;
       g.cs.s=0; g.cs.b={}; keys={}; mouse.down=false;
       S=flowS(); S.goals=[goal('kill10')]; S.kills=9;
       delete g.goalRewards; delete g.goalPaid;
     }
     try{
       for(k in NET) nk[k]=NET[k];
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); };
       prep(); before=P.credits; score=g.cs.s; r=RNGS;
       flowChip(200,'GOAL DONE','test'); if(g.cs.s!==score) return 'legacy goal score door still pays SP';
       goalsTick(0.1); if(S.goals[0].done||g.goalRewards) return '9 kills earned a reward';
       S.kills=10; goalsTick(0.1); goalsTick(0.1);
       if(g.cs.s!==score) return 'career goal changed SP by '+(g.cs.s-score);
       if(RNGS!==r) return 'goals advanced the world seed stream';
       if(!g.goalRewards||g.goalRewards.cash!==1000||P.credits!==before) return 'cash was not carried as $1,000 until extraction';
       if(!lines.some(function(s){ return s==='GOAL DONE|$1,000 at undercroft'; })) return 'goal callout omits its banked reward';
       __endRaid('extract');
       if(P.credits!==before+1000) return 'extract did not bank exactly $1,000: '+(P.credits-before);
       haulRevealSkip();
       if(!/run goals[\s\S]*?\$1,000/i.test(document.getElementById('oc_manifest').innerHTML)) return 'extracted card omits run goals $1,000';
       __endRaid('extract'); if(P.credits!==before+1000) return 'extract paid twice';
       prep(); before=P.credits; S.kills=10; goalsTick(0.1); __endRaid('dead');
       if(P.credits!==before||g.goalPaid) return 'death banked a goal reward';
       prep(); before=P.credits; S.kills=10; goalsTick(0.1); g.t=12; __endRaid('abandon');
       if(P.credits!==before||g.goalPaid) return 'abandon banked a goal reward';
       prep(); S.goals=[goal('vault'),goal('pill3'),goal('elite'),goal('ward')];
       S.kinds={raider:3}; S.elites=1; S.wardens=1;
       if(!g.map.locked||!g.map.locked.length) return 'staging: seed 4242 has no vault';
       g.map.locked[0].open=1; r=RNGS; goalsTick(0.1);
       if(!g.goalRewards||g.goalRewards.items.length!==4||g.goalRewards.cash||g.cs.s) return 'hard goals did not carry four cache items without SP';
       if(RNGS!==r) return 'item rewards advanced the world seed stream';
       item=g.goalRewards.items[0]; count=P.stash.filter(function(a){return a===item;}).length;
       __endRaid('extract');
       if(!g.goalPaid||g.goalPaid.items.length!==4) return 'hard goal items not settled';
       if(ITEMS[item].use==='gun'){ if(P.weapons.indexOf(ITEMS[item].gk)<0&&P.stash.indexOf(item)<0) return 'goal gun not banked'; }
       else if(P.stash.filter(function(a){return a===item;}).length<=count) return 'goal item not in stash';
       if(document.getElementById('oc_manifest').textContent.toLowerCase().indexOf('run goals: '+ITEMS[item].name.toLowerCase())<0) return 'goal item missing from extracted card';
       prep(); S.goals=null; goalsNetTake([[0,9,0]]); before=P.credits; r=RNGS;
       goalsNetTake([[0,10,1]]); goalsNetTake([[0,10,1]]); goalsTick(0.1);
       if(!g.goalRewards||g.goalRewards.cash!==1000||g.cs.s||P.credits!==before) return 'career peer reward missing, repeated, banked early or added SP';
       if(RNGS!==r) return 'peer rewards changed seed';
       __endRaid('extract'); if(P.credits!==before+1000) return 'career peer extraction did not bank its own reward';
       prep(); g.arcade=1; g.career=0; S.kills=10;
       before=ARCADE.mine|0; drop=pwrS().items.length; r=RNGS;
       goalsTick(0.1); goalsTick(0.1);
       if((ARCADE.mine|0)!==before||g.cs.s) return 'arcade goal changed team or career score';
       if(pwrS().items.length!==drop+1) return 'arcade goal did not drop exactly one power-up';
       gl=pwrS().items[drop]; if(gl.x!==g.player.x||gl.y!==g.player.y||!pwrDef(gl.k)) return 'arcade goal drop is not from the kill pool at player feet';
       if(RNGS!==r) return 'arcade goal advanced world RNG';
       S.goals=null; goalsNetTake([[0,9,0]]); drop=pwrS().items.length;
       goalsNetTake([[0,10,1]]); goalsNetTake([[0,10,1]]); goalsTick(0.1);
       if(pwrS().items.length!==drop+1||(ARCADE.mine|0)!==before) return 'arcade peer reward missing, duplicated or added SP';
       return null;
     } finally {
       say=rs;
       try{ if(g&&!g.over){ g.arcade=0; __endRaid('abandon'); } }catch(_e){}
       for(k in nk) NET[k]=nk[k];
       __topClear(); P=JSON.parse(savedP); saveProfile();
     }
   }},
  {v:'36.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
