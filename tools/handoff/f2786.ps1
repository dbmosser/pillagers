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

if ($s.Contains("  {v:'27.86',what:")) { throw "check 27.86 is in the fixture already" }

SubRx @'
  {v:'27.85',what:
'@ @'
  {v:'27.86',what:'partyp4, from the cloud review (8 and 23): the screen clear kills only ordinary machines, sparing the golden enemy, the convoy carrier, the bounty hunter, summoned machines, stronghold defenders (even the first stronghold, number 0), elites, bosses and pillagers; in a linked window it sends machines to the host as a pulse word that credits nobody, never charges the air strike, and the host applies it for nobody while a plain shot still credits the shooter',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof pwrPulse!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, S, pl, go, ca, bo, sh, su, el, bs, rd, i, sent=[], air=0, n0, oSend, oEP, oPS, oAir, oEH, oNet={}, k, hostE, peer, spared, ok;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof pwrSpecial!=='function') return 'the screen clear has no list of special machines in this build';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0; g.pwr=null; S=pwrS();
       function mk(f,dx,dy){ var e=f(p.x+dx,p.y+dy); return e; }
       function stage(){
         pl=mk(mkCrawler,100,20); pl.elite=0; go=mk(mkSentry,-120,-40); goldMake(go); ca=mk(mkBulwark,60,-80); ca.carrier=1; bo=mk(mkCrawler,160,-60); bo.bounty=1;
         sh=mk(mkCrawler,-70,100); sh.shi=0; su=mk(mkCrawler,90,90); su.summoned=1; el=mk(mkCrawler,-60,90); el.elite=1; bs=mk(mkCrawler,40,-120); bs.boss=1;
         rd=mkRaider(p.x+150,p.y+60,undefined,true); rd.hostile=true; rd.downed=0;
         g.ents=[pl,go,ca,bo,sh,su,el,bs,rd]; for(i=0;i<g.ents.length;i++) g.ents[i].nid=100+i;
       }
       render2D(0);
       // ONE: solo: the plain machine dies, everything special lives
       stage(); ARCADE.mine=0; ARCADE.streak=null;
       pwrPulse(p);
       if(!(pl.hp<=0)) bad.push('ONE: the plain machine survived the screen clear');
       spared=[['golden',go],['convoy carrier',ca],['bounty hunter',bo],['stronghold defender number 0',sh],['summoned machine',su],['elite',el],['boss',bs],['pillager',rd]];
       for(i=0;i<spared.length;i++) if(!(spared[i][1].hp>0)) bad.push('ONE: the screen clear killed the '+spared[i][0]);
       // TWO: a linked window: a pulse word for each plain machine, credited to nobody, no air strike charge, the flat medal paid
       stage(); ARCADE.mine=0; ARCADE.streak=null;
       oNet={on:NET.on,role:NET.role}; oSend=netSend; oEP=netEntsPeer; oPS=netPeerOfSeat; oAir=airCharge;
       NET.on=true; NET.role='join'; netEntsPeer=function(){ return true; }; netPeerOfSeat=function(){ return {state:'in',seat:0}; };
       netSend=function(q,m){ sent.push(m); return true; }; airCharge=function(){ air++; };
       try{ n0=pwrPulse(p); } finally { netSend=oSend; netEntsPeer=oEP; netPeerOfSeat=oPS; airCharge=oAir; NET.on=oNet.on; NET.role=oNet.role; }
       if(n0!==1||sent.length!==1) bad.push('TWO: the linked window sent '+sent.length+' words for '+n0+' plain machine');
       else {
         if(sent[0].t!=='shot'||sent[0].nc!==1) bad.push('TWO: the word is not a pulse word ('+JSON.stringify(sent[0])+')');
         if(!(sent[0].dmg>0&&sent[0].dmg<=1500)) bad.push('TWO: the pulse word carries '+sent[0].dmg+' damage, which the host throws away over 1500');
         if(sent[0].id!==100) bad.push('TWO: the word names body '+sent[0].id+', not the plain machine');
       }
       if(air) bad.push('TWO: the pulse charged the air strike '+air+' times');
       if(ARCADE.mine!==PWRX.pulsePer) bad.push('TWO: the linked window paid '+ARCADE.mine+' for the screen clear, not the flat '+PWRX.pulsePer);
       for(i=0;i<spared.length;i++) if(!(spared[i][1].hp>0)) bad.push('TWO: the linked window sent the '+spared[i][0]);
       // THREE: the host applies the pulse word for nobody, and a plain shot word for the shooter
       hostE=[mkCrawler(p.x+50,p.y),mkCrawler(p.x-50,p.y)]; g.ents=hostE.slice(); hostE[0].nid=201; hostE[1].nid=202;
       peer={state:'in',seat:1}; oEH=netEntsHost; oNet.em=NET.entMap; oNet.role=NET.role;
       NET.role='host'; NET.entMap={201:hostE[0],202:hostE[1]}; netEntsHost=function(){ return true; };
       try{
         netShotTake(peer,{t:'shot',id:201,dmg:1500,x:p.x,y:p.y,a:0.5,nc:1});
         netShotTake(peer,{t:'shot',id:202,dmg:1500,x:p.x,y:p.y,a:0.5});
       } finally { netEntsHost=oEH; NET.role=oNet.role; NET.entMap=oNet.em; }
       if(!(hostE[0].hp<=0)) bad.push('THREE: the host did not apply the pulse word');
       else if(hostE[0].bySeat!==0||hostE[0].byPlayer!==false) bad.push('THREE: the host credited the pulse word to seat '+hostE[0].bySeat+' (byPlayer '+hostE[0].byPlayer+')');
       if(!(hostE[1].hp<=0)||hostE[1].bySeat!==1) bad.push('THREE: a plain shot word no longer credits the shooter (seat '+hostE[1].bySeat+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(typeof ARCADE==='object'){ ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
