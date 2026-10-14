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

if ($s.Contains("  {v:'26.70',what:")) { throw "check 26.70 is in the fixture already" }

SubRx @'
  {v:'26.69',what:
'@ @'
  {v:'26.70',what:'his yes (suggestion 24): THE OVERSEER has three phases by health: at 66 percent it pauses and calls crawlers, at 33 percent it begins a sweeping laser that hurts anyone in the beam, and when the sweep ends its core is exposed (it vents and takes half as much again); the beam is drawn and rides the network flags',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof bossTick!=='function'||typeof updateBullets!=='function'||typeof render2D!=='function'||typeof spotFree!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, e=null, all=null, a, k, i, n, minHp, lossA, lossB, cf, ex, oF, hF, nBeam=0, OWN=Object.prototype.hasOwnProperty;
     function keep(){ e.seenYou=true; e.sumT=1e9; }
     function frames(nf,fn){ var j; for(j=0;j<nf;j++){ if(fn) fn(); __sim(1/60); } }
     function shoot(){
       var h0=e.hp, j, dy=0, cand=[80,-80,60,-60];
       for(j=0;j<cand.length&&!dy;j++){ if(rayHitG(e.x,e.y+cand[j],0,-cand[j]/Math.abs(cand[j]),Math.abs(cand[j]))>=Math.abs(cand[j])-0.5) dy=cand[j]; }
       if(!dy) dy=80;
       g.bullets.length=0;
       g.bullets.push({x:e.x,y:e.y+dy,vx:0,vy:(dy>0?-1180:1180),dmg:100,life:0.3,player:true,owner:p,tint:'#ffffff',el:'',thru:0});
       for(j=0;j<8;j++) updateBullets(1/60);
       return h0-e.hp;
     }
     try{
       if(typeof overseerTick!=='function') return 'the Overseer has no phases';
       if(overseerPhaseOf({hp:1000,maxhp:1000})!==1||overseerPhaseOf({hp:600,maxhp:1000})!==2||overseerPhaseOf({hp:300,maxhp:1000})!==3) bad.push('the phase thresholds are not 66 and 33 percent of health');
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; all=g.ents.slice(); g.t=5; g.bossDone=0;
       e=bossTick(true); if(!e) return 'SKIP: the Overseer could not be raised';
       g.ents=[e];
       for(k=0;k<24;k++){ a=k/24*6.2832; if(spotFree(g.map,e.x+Math.cos(a)*250,e.y+Math.sin(a)*250,20)&&losClear(e.x,e.y,e.x+Math.cos(a)*250,e.y+Math.sin(a)*250,G.vseg)) break; }
       if(k>=24) return 'SKIP: no open ground beside the Overseer';
       p.x=e.x+Math.cos(a)*250; p.y=e.y+Math.sin(a)*250; p.vx=0; p.vy=0; G.anchX=undefined; p.face=Math.atan2(e.y-p.y,e.x-p.x); p.iv=99; p.hp=100; p.downed=false;
       for(i in keys) keys[i]=false;
       e.seenYou=true; e.face=Math.atan2(p.y-e.y,p.x-e.x); e.cd=5;
       frames(2,keep);
       if(e.phase!==1) bad.push('at full health the Overseer is in phase '+e.phase);
       e.hp=Math.round(e.maxhp*0.6);
       frames(2,function(){ e.seenYou=true; });
       if(e.phase!==2) bad.push('at 60 percent health the Overseer is in phase '+e.phase);
       if(!(e.stagT>0)) bad.push('the Overseer does not pause at a phase change');
       frames(130,function(){ e.seenYou=true; p.hp=100; });
       n=g.ents.filter(function(x){ return x.summoned&&x.hp>0; }).length;
       if(n<2) bad.push('phase 2 called '+n+' crawlers (two or three expected)');
       g.ents=[e]; g.bullets.length=0;
       e.hp=Math.round(e.maxhp*0.2); p.iv=0; p.hp=100;
       frames(2,keep);
       if(e.phase!==3) bad.push('at 20 percent health the Overseer is in phase '+e.phase);
       e.stagT=0; e.sweepCd=0; e.cd=5; p.hp=100; p.iv=0; e.face=Math.atan2(p.y-e.y,p.x-e.x);
       for(i=0;i<20&&!(e.chgT>0);i++) frames(1,keep);
       if(!(e.chgT>0)) bad.push('phase 3 never began to charge a sweep');
       else if(!(e.windup>0)) bad.push('no aim lane (windup) shows while the sweep charges');
       for(i=0;i<90&&!(e.swpT>0);i++){ frames(1,keep); p.hp=100; }
       if(!(e.swpT>0)) bad.push('the charge never became a sweep');
       else {
         cf=netEntFlags(e); if(!(cf&1073741824)) bad.push('the party is not told the Overseer is sweeping');
         ex={kind:'warden',x:0,y:0,state:'chase',hp:50,maxhp:50}; netEntFlagsApply(ex,cf); if(!(ex.swpT>0)) bad.push('a linked window does not read the sweep flag');
         hF=OWN.call(wc,'fill'); oF=wc.fill;
         wc.fill=function(){ if(/255,\s*36,\s*28,\s*0\.3\)/.test(String(this.fillStyle))) nBeam++; return oF.apply(this,arguments); };
         p.face=Math.atan2(e.y-p.y,e.x-p.x);
         try{ render2D(0.016); } finally { if(hF) wc.fill=oF; else delete wc.fill; }
         if(!nBeam) bad.push('the sweep beam is not drawn in the world');
       }
       minHp=p.hp;
       for(i=0;i<220&&e.swpT>0;i++){ frames(1,keep); if(p.hp<minHp) minHp=p.hp; }
       if(!(minHp<100)) bad.push('a player standing in the sweep took no damage');
       if(!(e.overheat>0)) bad.push('after the sweep the Overseer core is not exposed (it does not vent)');
       p.iv=99; e.overheat=0; e.htImmune=0; e.face=0; e.hp=e.maxhp;
       lossA=shoot();
       e.hp=e.maxhp; e.overheat=2;
       lossB=shoot();
       if(!(lossA>=90&&lossA<=110)) bad.push('the control round did '+Math.round(lossA)+' to the Overseer, not 100');
       else if(!(lossB/lossA>=1.4&&lossB/lossA<=1.6)) bad.push('the same round does '+Math.round(lossB)+' to a venting Overseer against '+Math.round(lossA)+': the exposed core should take half as much again');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof oF==='function'&&hF!==undefined){ if(hF) wc.fill=oF; else delete wc.fill; } }catch(_e1){}
       try{ if(g&&all){ g.ents=all; g.bullets.length=0; g.bossRef=null; } var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
