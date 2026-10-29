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

if ($s.Contains("  {v:'36.40',what:")) { throw "check 36.40 is in the fixture already" }

SubRx @'
  {v:'36.39',what:
'@ @'
  {v:'36.40',what:'beast mode replaces kill-count rewards: five base-score kills, no chain alerts, sounds, badge or ring, and no grenade-double medal, in demo and career for either seat',
   run:function(){
     var g,p,mode,seat,i,n,before,base,body,id=98000,alerts=[],sounds=[],figures=[],texts=[],arcs=0;
     var oldSay=say,oldBlip=blip,oldSp=feedKillSp,oldFt=ctx.fillText,oldArc=ctx.arc,c0=CAREER_ON,d0=DMUL_ON;
     var funcs=[flowKill,pwrKill,teamKill,arcadeKillPerks,arcadeScSend],saved={},nk=['on','role','seat','upSeed','entMap','entDead'];
     function score(){return g.arcade?ARCADE.mine:g.cs.s;}
     function kill(blast){
       body=mkCrawler(p.x+220,p.y);body.elite=0;body.affix=null;body.state='chase';body.hp=-100;
       body.blow=blast?'x':'g';body.blowT=g.t;
       if(seat){
         NET.entMap[++id]=body;
         if(netKillTake({state:'in'},{seat:1,k:'crawler',id:id})!=='kill') throw Error('partner kill was not credited');
       }else{
         body.byPlayer=1;body.bySeat=0;g.ents.push(body);__ents(0);
         if(g.ents.indexOf(body)>=0) throw Error('host death was not processed');
       }
     }
     function draw(){
       texts=[];arcs=0;
       ctx.fillText=function(t){texts.push(String(t).toLowerCase());return oldFt.apply(this,arguments);};
       ctx.arc=function(){arcs++;return oldArc.apply(this,arguments);};
       try{arcadeScoreHud(0,1);styleDraw(ctx,p,W/2,H/2);}finally{ctx.fillText=oldFt;ctx.arc=oldArc;}
       if(texts.some(function(t){return /^x[2-5]$/.test(t);})) throw Error('a score-chain badge was drawn');
       // The clock may draw its own pop arc. Isolate the former cursor pass.
       arcs=0;ctx.arc=function(){arcs++;return oldArc.apply(this,arguments);};
       try{styleDraw(ctx,p,W/2,H/2);}finally{ctx.arc=oldArc;}
       if(arcs) throw Error('the old score-chain ring was drawn');
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       for(i=0;i<nk.length;i++)saved[nk[i]]=NET[nk[i]];
       DMUL_ON=0;CAREER_ON=1;
       flowKill=pwrKill=teamKill=arcadeKillPerks=arcadeScSend=function(){};
       say=function(t){alerts.push(String(t));};blip=function(t){sounds.push(String(t));};
       feedKillSp=function(t){figures.push(String(t));return oldSp.apply(this,arguments);};
       if(typeof dmgStreakKill!=='function')return 'beast mode must ship first';
       for(mode=0;mode<2;mode++){
         if(mode){if(!arcadeDeploy({mapIx:0,seed:4242}))throw Error('no demo raid');}
         else __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         g=__state();if(!g||!g.player||g.over||(!mode&&!g.cs))throw Error('no staged raid');
         p=g.player;g.hotZone=null;g.timeLeft=500;g.paused=false;g.bagOpen=false;g.mapOpen=false;p.iv=9999;
         g.ents=[];g.elemAny=1;ARCADE.holdT=0;ARCADE.waveT=0;
         CFG.xfStyle=1;xfSnap();base=arcadeKillPts('crawler',0,0);
         for(seat=0;seat<2;seat++){
           NET.on=!!seat;NET.role=seat?'join':'host';NET.seat=seat;NET.upSeed=g.seed;NET.entMap={};NET.entDead={};
           p.shStk=0;p.bmStk=0;p.bmUntil=0;g.sty=null;
           if(g.cs)g.cs.streak=null;ARCADE.streak=null;
           alerts=[];sounds=[];figures=[];
           for(i=0;i<5;i++){
             g.t=100+i;before=score();kill(false);n=score()-before;
             if(n!==base)throw Error('mode '+mode+' seat '+seat+' kill '+i+' paid '+n+', base '+base);
             if(figures[figures.length-1]!=='+'+arcadeCr(base))throw Error('base kill figure was lost');
             draw();
           }
           if(p.bmStk!==5)throw Error('quick kills lost beast mode');
           if((g.cs&&g.cs.streak)||ARCADE.streak)throw Error('a score chain is still recorded');
           before=score();g.t=106;kill(true);kill(true);
           if(score()-before!==base*2)throw Error('two grenade kills paid a count bonus');
           if((g.sty&&g.sty.pops||[]).some(function(q){return /MULTI.KILL|GRENADE DOUBLE/.test(q.txt);}))throw Error('a removed count medal appeared');
           if(alerts.some(function(t){return /DOUBLE KILL|TRIPLE KILL|MULTI.KILL|RAMPAGE|UNSTOPPABLE|GRENADE DOUBLE/i.test(t);}))throw Error('a removed kill-count alert appeared');
           if(sounds.some(function(t){return /^(medal|chainTick)/.test(t);}))throw Error('a kill-count sound played');
         }
         NET.on=false;NET.role='host';
         if(mode)arcadeLeave();
         if(__state()&&!__state().over)__endRaid('abandon');__topClear();
       }
       return null;
     }catch(e){return e.message||String(e);}finally{
       say=oldSay;blip=oldBlip;feedKillSp=oldSp;ctx.fillText=oldFt;ctx.arc=oldArc;
       flowKill=funcs[0];pwrKill=funcs[1];teamKill=funcs[2];arcadeKillPerks=funcs[3];arcadeScSend=funcs[4];
       CAREER_ON=c0;DMUL_ON=d0;NET.on=false;
       try{if(ARCADE.on)arcadeLeave();if(__state()&&!__state().over)__endRaid('abandon');}catch(e){}
       for(i=0;i<nk.length;i++)NET[nk[i]]=saved[nk[i]];
       __topClear();__resetCfg();__cleanProfile();
     } }},
  {v:'36.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
